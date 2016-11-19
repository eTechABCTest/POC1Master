/*
Purpose:            Import Bluebook updates for hospital accounts
Create By:          Jeffery Sun
Current Version:    v1.0
*/
public class BluebookController {
    public Account FakeAccount {get; set; }
    public String Result { get; private set; }

    static Pattern patternNewsItem = Pattern.compile('\\<p\\>\\<strong\\>([^\\<]+?)\\s-\\s\\<\\/strong\\>([^\\<]*?)\\<\\/p\\>');
    static Pattern patternData = Pattern.compile('\\[([^]]+?)\\]');

    public Boolean InTestMode { get; set; }
    static String TestData = '<p><strong>state1 - </strong>BB Institution 1 [BBId1] News 1: BB Institution 2 [BBId2].</p><p><strong>state2 - </strong>BB Institution 1 [BBId1] News 2: BB Institution 3 [BBId3].</p>';

    public BluebookController() {
        InTestMode = false;
        FakeAccount = new Account();
        FakeAccount.Today__c = date.today();
        FakeAccount.EA_AE__c = UserInfo.getUserId();
        FakeAccount.Name = '';
        //FakeAccount.Name = 'http://links.mkt2300.com/servlet/MailView?ms=MzgyMjY4MwS2&r=NTczMTkxNTU3NwS2&j=MTE4MjM3NTg5S0&mt=2&rj=MTE4MjM3NTg5S0&rt=0';
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please make sure that the url above has been added to "Remote Sites" setting.'));
    }

    public void loadData() {
        String pageContent = downloadPage(FakeAccount.Name);
        if(pageContent == '' || pageContent == null){
            Result = 'Nothing is imported.\r\n<br/>\r\n<br/>';
            return;
        }
        Map<String, List<String>> mapBluebook = parseData(pageContent);
        if(mapBluebook == null || mapBluebook.isEmpty()) return;
        
        Datetime createdDate = Datetime.newInstance(FakeAccount.Today__c.Year(), FakeAccount.Today__c.Month(), FakeAccount.Today__c.Day());
        Id createdByUserId = FakeAccount.EA_AE__c;
        
        addBluebookPostsToAccounts(mapBluebook, createdDate, createdByUserId);
    }

    private String downloadPage(String url) {
        HttpRequest request = new HttpRequest();
        request.setEndPoint(url);
        request.setMethod('GET');

        String pageContent;
        if(InTestMode) {
            pageContent = TestData;
        }
        else {        
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() != 200) {
                Result = 'Load Page Error: ' + response;
                return null;
            }
            pageContent = response.getBody();
        }
 
        Result = 'Page is downloaded successfully.\r\n<br/>\r\n<br/>';
        return pageContent;
    }
        
    private Map<String, List<String>> parseData(String pageContent) {
        Map<String, List<String>> mapBluebook = new Map<String, List<String>>();
                
        Matcher matchNewsItem = patternNewsItem.matcher(pageContent);
        while (matchNewsItem.find()) {
            if(matchNewsItem.groupCount() != 2) continue;
            
            // Within Chatter Post Item, the max length for body is 1000.
            String newsItem = '#Bluebook ' + matchNewsItem.group(2);
            if(newsItem.length() > 1000)
                newsItem = newsItem.subString(0, 1000);
            parseNewsItem(mapBluebook, newsItem);
        }
        
        Result += 'There are ' + mapBluebook.size() + ' bluebook items.\r\n<br/>\r\n<br/>';
        return mapBluebook;
    }
    
    private void parseNewsItem(Map<String, List<String>> mapBluebook, String newsItem) {           
        Matcher matchData = patternData.matcher(newsItem);
        while (matchData .find()) {
            if(matchData.groupCount() == 0) continue;
            
            String bluebookId = matchData.group(1);
            if(mapBluebook.containsKey(bluebookId)) {
                List<String> items = mapBluebook.get(bluebookId);
                items.add(newsItem);
                //items.put(bluebookId, items);
            }
            else {
                List<String> items = new List<String>();
                items.add(newsItem);
                mapBluebook.put(bluebookId, items);              
            }
        }
    }
    
    private void addBluebookPostsToAccounts(Map<String, List<String>> mapBluebook, Datetime createdDate, Id createdByUserId) {
        List<FeedItem> posts = new List<FeedItem>();
        List<Account> accounts = [SELECT Id, Name, Blue_Book_Institution_ID__c FROM Account
                                    WHERE Blue_Book_Institution_ID__c IN :mapBluebook.keyset()];
        for(Account account : accounts) {
            List<String> items = mapBluebook.get(account.Blue_Book_Institution_ID__c);
            for(String item : items) {
                FeedItem post = new FeedItem();
                post.ParentId = account.Id;
                post.Body = item;
                post.CreatedDate = createdDate;
                if(createdByUserId != null) post.CreatedById = createdByUserId;
                posts.Add(post);
            }
            
            Result += 'Add '+ items.size() + ' bluebook update(s) to ' + account.Name + '.\r\n<br/>';
        }
        
        if(!posts.isEmpty())
            insert posts;
    }
}