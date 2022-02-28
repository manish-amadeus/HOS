public without sharing class SME_ResuableCustomLookupCtrl {
    @AuraEnabled(cacheable = true)
    public static List<SObject> findRecords(String searchKey, String objectName, String searchField, String recordTypeName){
        
        String key = '%' + searchKey + '%';
        String QUERY;
        if(recordTypeName != null && recordTypeName != '')
        {
            
            QUERY = 'Select Id, '+searchField+' From '+objectName +' Where '+searchField + ' LIKE :key AND RecordType.Name =:recordTypeName limit 5';
        }
        else
        {
            QUERY = 'Select Id, '+searchField+' From '+objectName +' Where '+searchField +' LIKE :key limit 5';
        }
        System.debug(System.LoggingLevel.DEBUG, QUERY);
        List<SObject> sObjectList = Database.query(QUERY);
        return sObjectList;
    }
}