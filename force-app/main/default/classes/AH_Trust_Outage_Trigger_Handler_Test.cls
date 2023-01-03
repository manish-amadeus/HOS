/***********************************************************************************************
Name            : AH_Trust_Outage_Trigger_Handler_Test
Author          : Shashikant Nikam
Created Date    : 05/25/2018
Last Mod Date   : 05/31/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : This class handles all the test code for AH_Trust_Outage_Trigger_Handler class
:
:
************************************************************************************************/
@isTest
public class AH_Trust_Outage_Trigger_Handler_Test {

    @testSetup static void createData(){
        
        //CREATE TEST ACCOUNT 
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'Amadeus Hospitality Business Systems';
        insert a1;
        
        //CREATE TEST CONTACT
        Contact c1 = NI_TestClassData.createTestContact(1, a1.id);
        c1.FirstName = 'Dummy';
        c1.LastName = 'Contact';
        c1.Email = 'abc@test.com';
        insert c1;
        
        // CREATE TEST NI Trust Object
        NI_Trust__c trust = NI_TestClassData.createTestNITrust('Test Platform Name', 1);
        insert trust;
        
        NI_Trust_Outage_Email__c outageSettings = NI_TestClassData.createNITrustOutageCustomSettings();
        outageSettings.Record_Types__c = 'Unplanned';
        insert outageSettings;
        
        Id recTypeId;
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.NI_Trust_Outage__c.getRecordTypeInfosByName();
        if (recordTypesMap.containsKey('Unplanned')) 
        {
            Schema.RecordTypeInfo rr = recordTypesMap.get('Unplanned');
            recTypeId = rr.getRecordTypeId();
        }
        
        // CREATE TEST NI Trust Outage Object
        NI_Trust_Outage__c outage = NI_TestClassData.createTestNITrustOutage(trust.id, System.now(), System.now().addDays(5), 1, System.now().date(), '10:00', System.now().addDays(5).date(), '15:00');
        outage.Status__c = 'New';
        outage.Severity__c = '1 - Critical';
        outage.RecordTypeID = recTypeId;
        insert outage;
        
        NI_Trust_Outage__c outage1 = new NI_Trust_Outage__c(id = outage.id );
        outage1.Start_Time_GMT__c = '11:00';
        outage1.End_Time_GMT__c = '16:00';
        update outage1;
        
        List<NI_Trust_Outage__c> outages = [select id, Name from NI_Trust_Outage__c ];
        system.assertEquals(1, outages.size(), 'Assert error in insert count');
    }
    
    // TEST METHOD
    @isTest static void test1(){
        
        Test.startTest();
            
        NI_Trust_Outage__c outage = [select id, Name, RecordTypeID, Status__c, Send_Notifications__c from NI_Trust_Outage__c where Status__c = 'New'];
        
        outage.Status__c = 'Open Stage 1';
		outage.Send_Notifications__c = True;
        update outage;
		NI_Trust_Outage__c outage1 = [select Name, Status__c from NI_Trust_Outage__c where Status__c = 'Open Stage 1'];
        system.assertEquals('Open Stage 1', outage1.Status__c, 'Open Stage 1 Status not matching');
        
        // CHANGE STATUS
		outage.Status__c = 'Open Stage 2';
        update outage;
        NI_Trust_Outage__c outage2 = [select Name, Status__c from NI_Trust_Outage__c where Status__c = 'Open Stage 2'];
        system.assertEquals('Open Stage 2', outage2.Status__c, 'Open Stage 2 Status not matching');
        
        // CHANGE SEVERITY
        outage.Severity__c = '2 - Urgent';
        update outage;
        NI_Trust_Outage__c outage3 = [select Name, Severity__c from NI_Trust_Outage__c where Status__c = 'Open Stage 2'];
        system.assertEquals('2 - Urgent', outage3.Severity__c, 'Severity 2 not matching');
        
        // CHANGE STATUS
		outage.Status__c = 'Resolved';
        update outage;
        NI_Trust_Outage__c outage4 = [select Name, Status__c, Send_Notifications__c from NI_Trust_Outage__c where Status__c = 'Resolved'];
        system.assertEquals('Resolved', outage4.Status__c, 'Resolved Status not matching');
        system.assertEquals(False, outage4.Send_Notifications__c, 'Send Notification Status not updated');
        
        Test.stopTest();
    }
}