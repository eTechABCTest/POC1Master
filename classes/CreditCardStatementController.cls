//Modified By - Abhinav Sharma - 06/11/2014 - CR-20140610-5763
public class CreditCardStatementController{
    
    @TestVisible private Map<Id,List<Credit_Card_Transaction__c>> ccts;
    public Id idCreditCard {get; set;}
    
    public CreditCardStatementController() {
        /*if(ccts == null){
            //Query the data and build the map
            ccts = getTransactionData();
        }else{
            //nothing, map already built
        }*/
    }
    
    public List<Credit_Card_Transaction__c> getTransactions() {
        
        System.debug('Test:::::' + idCreditCard);
        
        if(ccts == null){
            //Query the data and build the map
            ccts = getTransactionData();
        }
        
        if(ccts.keySet().contains(idCreditCard)){
            system.debug('CreditCardStatementComponent.getTransactions - idCreditCard: '+idCreditCard);
            system.debug('CreditCardStatementComponent.getTransactions - ccts.get(idCreditCard): '+ccts.get(idCreditCard));
            return ccts.get(idCreditCard); 
        }else{
             return null;
        }         
    }
    
    private Map<Id,List<Credit_Card_Transaction__c>> getTransactionData() {
        
        map<Id,List<Credit_Card_Transaction__c>> mapCCT = new map<Id,List<Credit_Card_Transaction__c>>();
        //List<Credit_Card_Transaction__c> listCCT = new List<Credit_Card_Transaction__c>();
        
        //Modified query where clause - Abhinav Sharma - 06/11/2014 - CR-20140610-5763
        //get all transactions
        for(Credit_Card_Transaction__c CCT : [SELECT Id, Cleared__c, Posted_Date_Time__c, Merchant_Name__c, Accept_Location__c, Amount__c, Credit_Card__c
                                               FROM Credit_Card_Transaction__c
                                               WHERE Cleared__c = FALSE 
                                                     AND Transaction_Status__c !=: CreditCardConstants.CCT_TRANSACTION_STATUS_AUTHORIZED 
                                                     AND Pre_Auth_Amount__c != '0.00' 
                                                     AND Pre_Auth_Amount__c != '0' 
                                                     AND Pre_Auth_Amount__c != null 
                                                     AND Pre_Auth_Amount__c != '' 
                                                     AND Credit_Card__c =: idCreditCard
                                               ORDER BY Posted_Date_Time__c, Transaction_Date_Time__c]){
                                                  
                                                  if(mapCCT.keySet().contains(CCT.Credit_Card__c)){
                                                      mapCCT.get(CCT.Credit_Card__c).add(CCT);
                                                  }else{
                                                      list<Credit_Card_Transaction__c> c = new list<Credit_Card_Transaction__c>();
                                                      c.add(CCT);
                                                      mapCCT.put(CCT.Credit_Card__c,c);
                                                  }
                                              }
         
        system.debug('CreditCardStatementComponent.getTransactionData - mapCCT: '+mapCCT);
                                                     
        return mapCCT;
    }
}