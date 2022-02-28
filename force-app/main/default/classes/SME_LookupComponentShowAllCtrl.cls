public class SME_LookupComponentShowAllCtrl {
    public static Boolean throwException = false;
   @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        try{
        for(sObject so : Database.Query('Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\'')) {
            String fieldvalue = (String)so.get(fieldName);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        }
            if(throwException) {
                Integer i = 1/0;
            }
        }catch(Exception e){
         	SME_GlobalExceptionHandlerCtrl.processException('SME_LookupSearchComponentController', 'getResults', e);
            return null;
        }
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
}