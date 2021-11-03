/************************************************************************************************
Name            : NI_IMT_BatchUpdatePropertyTimezone Class
Author          : Damodar Raut
Created Date    : 04/20/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that does batch update of Property timezone
                : 
*************************************************************************************************/
global class NI_IMT_UpdatePropertyTimezoneBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Country__c,State__c,City__c, Phone__c,Timezone__c FROM NI_IMT_Property__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<NI_IMT_Property__c> scope) {
        for (NI_IMT_Property__c property : scope) {
			property.Timezone__c =  getTimeZone(property.Country__c, property.State__c, property.City__c, property.Phone__c);
        }
        update scope;
    }  
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    private String getTimeZone(String country, String state, String city, String phone) {  
		String timeZone = '';
        String offset = '';
        String s = tz.LocalTime.CalculateLocalTime(country, state, city, phone);
        JSONParser parser = JSON.createParser(s);
		parser.nextToken();
        parser.nextValue();
        offset = parser.getText();
        parser.nextToken();
        parser.nextValue();
        String sEnd = parser.getText();
        if(offset != '' && offset!='N/A')
			timeZone = sEnd + ' ( GMT ' + offset + ' ) ';
		return timeZone;
    }
}