public class IdeaAuthController {

   public PageReference Load() {

      PageReference pageRef = new PageReference(Label.BeMindful_Site_Url);
      Map<String, String> params = pageRef.getParameters();

      User CurrentUser = [SELECT Finance_Code__c FROM USER WHERE id = :UserInfo.getUserid()];
      system.debug('##IdeaAuthController.Load - CurrentUser: ' + CurrentUser.Finance_Code__c);
      params.put('u', IdeaBaseController.Encrypt(CurrentUser.Finance_Code__c));

      String Id = ApexPages.currentPage().getParameters().get('id');
      if (Id != null) {
         params.put('id', Id);
         system.debug('##IdeaAuthController.Load - Idea id: ' + Id);
      }

      pageRef.setRedirect(true);
      return pageRef;
   }
}