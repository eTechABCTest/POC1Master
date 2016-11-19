public  class IntegrationMappingHelper {

    public static void updateIntegrationRecType(list<Integration_Mapping__c> intMapping){
    
        list<Integration_Job__c> listIntJobs = Integration_Job__c.getAll().values();
        system.debug('listIntJobs: '+listIntJobs);
        
        map<string,string> mapJobToRecType = new map<String,string>();
        for(Integration_Job__c ij : listIntJobs){
            mapJobToRecType.put(ij.Integration_Job_Name__c,ij.Name);
        }
        system.debug('mapJobToRecType: '+mapJobToRecType);
                
        for(Integration_Mapping__c im : intMapping){
        	String idRecType = mapJobToRecType.get(im.Integration_Name__c);
            im.Integration_RecordTypeId__c = idRecType;
        }
    }
    
    
}