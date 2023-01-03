/****************************************************************************************
Name            : NI_IMT_UpdatePropertyTimezoneBatchTest Class
Author          : Damodar Raut
Created Date    : 04/25/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Test Class that handles all test code for the NI_IMT_UpdatePropertyTimezoneBatch class
				: 
				: 
******************************************************************************************/
@isTest
private class NI_IMT_UpdatePropertyTimezoneBatchTest {

    static testMethod void testBatch() {
        Id imtPropRecordTypeId = Schema.getGlobalDescribe().get('NI_IMT_Property__c').getDescribe().getRecordTypeInfosByName().get('InterContinental Hotels Group').getRecordTypeId();
        //CREATE PROPERTY
        NI_IMT_Property__c prop = new NI_IMT_Property__c(
        	Name = 'TestProp',
            RecordTypeId = imtPropRecordTypeId,
            Country__c = 'US',
            State__c = 'CA',
            City__c = 'Los Angeles',
            Property_Code__c = 'TESTP'
        );
        insert prop;
        
        NI_IMT_UpdatePropertyTimezoneBatch batch = new NI_IMT_UpdatePropertyTimezoneBatch();
        Database.executeBatch(batch);
        NI_IMT_Property__c updatedProp = [SELECT Name,Timezone__c FROM NI_IMT_Property__c WHERE Id =:prop.Id];
		System.assert(updatedProp.Timezone__c != 'Unknown');
        
    }
}