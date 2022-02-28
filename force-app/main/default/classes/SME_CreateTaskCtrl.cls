public with sharing class SME_CreateTaskCtrl {
    @AuraEnabled(Cacheable = true)
    public static List<String> fetchPicklistValues(String object_name, String field_name) {
        List<String> values = new List<String>();
        String[] types = new String[]{object_name};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {values.add(entry.getValue());}
            }
        }
        return values;
    }
    @AuraEnabled
    public static String insertTask(String objTaskJSON){
        String returnMessage = null;
        List<Task> taskList = new List<Task>();
        Task t = new Task();
        System.debug('objTaskJSON' + objTaskJSON);
        JSONParser parser = JSON.createParser(objTaskJSON);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Subject')) {
                parser.nextToken();
                if(parser.getText() != '' && parser.getText() != null && parser.getText() != 'null'){
                	t.Subject = parser.getText();
                }
            }
            else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'ActivityDate')) {
                parser.nextToken();
                if(parser.getText() != '' && parser.getText() != null && parser.getText() != 'null'){
                	t.ActivityDate = parser.getDateValue();
                }
            }
            else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'WhatId')) {
                parser.nextToken();
                if(parser.getText() != '' && parser.getText() != null && parser.getText() != 'null'){
                	t.WhatId = parser.getIdValue();
                }
            }
            else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'WhoId')) {
                parser.nextToken();
                System.debug('value' + parser.getText());
                if(parser.getText() != '' && parser.getText() != null && parser.getText() != 'null'){
                	t.WhoId = parser.getIdValue();
                }
            }
            else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Priority')) {
                parser.nextToken();
                if(parser.getText() != '' && parser.getText() != null && parser.getText() != 'null'){
                	t.Priority = parser.getText();
                }
            }
            else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'OwnerId')) {
                while (parser.nextToken() != JSONToken.END_ARRAY) {
                    
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'recId')) {
                        parser.nextToken();
                        if(parser.getText() != '' && parser.getText() != null && parser.getText() != 'null'){
                            Task objTask = new Task();
                            objTask.Subject = t.Subject;
                            objTask.ActivityDate = t.ActivityDate;
                            objTask.WhatId = t.WhatId;
                            objTask.WhoId = t.WhoId;
                            objTask.Priority = t.Priority;
                        	objTask.OwnerId = parser.getIdValue();
                            taskList.add(objTask);
                        }
                	}
            	}
            }
        }
        for(Task ta: taskList ) {
            System.debug('List' + ta);
        }
        try {
            insert taskList;
            returnMessage = 'Success';
        }
        catch (Exception e) {
            returnMessage = e.getMessage();
        }
        return returnMessage;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SObJectResult> getLookupValues(String ObjectName, String fieldName, String value, String condition){
        
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        
        if(String.isNotEmpty(value)) {
            String query = 'Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\'';
            if(condition != null && String.isNotEmpty(condition)) {
                query += condition;
            }
            for(sObject so : Database.Query(query)) {
                String fieldvalue = (String)so.get(fieldName);
                sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
            }
        }
        return sObjectResultList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SObJectResult> getMultiLookupValues(String ObjectName, String fieldName, String value, List<String> selectedRecId, String condition) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        if(selectedRecId == null || (selectedRecId!= null && selectedRecId.size() == 0)) {
            selectedRecId = new List<String>();
        }
        if(String.isNotEmpty(value)) {
            String query = 'Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value.trim() + '%\' and ID NOT IN: selectedRecId';
            if(condition != null && String.isNotEmpty(condition)) {
                query += condition;
            }
            system.debug('>>>>'+query);
            
            for(sObject so : Database.Query(query)) {
                String fieldvalue = (String)so.get(fieldName);
                sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
            }
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
    
    @AuraEnabled(cacheable=true)
    public static String getAccountIdforPlan(String accPlanId){
        String accId = null;
        List<SME_Account_Plan__c> accPlanList = new List<SME_Account_Plan__c>();
        if(accPlanId != null && !String.isBlank(accPlanId)) {
            accPlanList = [SELECT id,Customer__c FROM SME_Account_Plan__c WHERE Id= :accPlanId];
        }
        if(accPlanList != null && accPlanList.size() > 0 ) {
            accId = accPlanList[0].Customer__c;
        }
        return accId;
    }
}