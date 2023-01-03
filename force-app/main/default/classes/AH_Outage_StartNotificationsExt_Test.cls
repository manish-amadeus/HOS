/***********************************************************************************************
Name            : AH_Outage_StartNotificationsExt_Test
Author          : Shashikant Nikam
Created Date    : 06/08/2018
Last Mod Date   : 06/21/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : This class handles all the test code for AH_Outage_StartNotificationsExt class 
                :
                :
************************************************************************************************/
@isTest
public class AH_Outage_StartNotificationsExt_Test {
    
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
        
        Id unPlanrecTypeId;
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.NI_Trust_Outage__c.getRecordTypeInfosByName();
        if (recordTypesMap.containsKey('Unplanned')) 
        {
            Schema.RecordTypeInfo rr = recordTypesMap.get('Unplanned');
            unPlanrecTypeId = rr.getRecordTypeId();
        }
        Id planRecTypeId;
        if (recordTypesMap.containsKey('Planned')) 
        {
            Schema.RecordTypeInfo rr = recordTypesMap.get('Planned');
            planRecTypeId = rr.getRecordTypeId();
        }
       
        // CREATE TEST NI Trust Outage Object
        List<NI_Trust_Outage__c> incidents = new List<NI_Trust_Outage__c>();
        for (Integer i = 0; i<=2; i++) 
        {
        	NI_Trust_Outage__c outage = NI_TestClassData.createTestNITrustOutage(trust.id, System.now(), System.now().addDays(5), 1, System.now().date(), '10:00', System.now().addDays(5).date(), '15:00');
            outage.Status__c = 'New';
            incidents.add(outage);
        }
        
		incidents[0].Severity__c = '1 - Critical';
		incidents[0].RecordTypeID = unPlanrecTypeId;
        
		incidents[1].Severity__c = '3 - Medium';
		incidents[1].RecordTypeID = unPlanrecTypeId;
        
		incidents[2].Severity__c = '2 - Urgent';
		incidents[2].RecordTypeID = planRecTypeId;
        
        insert incidents;

        // UPDATE INCIDETNS TO EVALUATE FORMULA FIELD
        List<NI_Trust_Outage__c> outList = new List<NI_Trust_Outage__c>();
        for (Integer i = 0; i <= 2; i++)
        {
            NI_Trust_Outage__c outage1 = new NI_Trust_Outage__c(id = incidents[i].id );
            outage1.Start_Time_GMT__c = '11:00';
            outage1.End_Time_GMT__c = '16:00';
            outList.add(outage1);
        }
        update outList;
        
        
        List<NI_Trust_Outage__c> outages = [ select id, Name from NI_Trust_Outage__c ];
        system.assertEquals(3, outages.size(), 'Assert error in insert count');
    }
    
    //TEST METHOD
    @isTest
    static void test1() {
        
        Test.startTest();
        
        List<NI_Trust_Outage__c> outage_List = new List<NI_Trust_Outage__c>();
        outage_List = [select id, Name, RecordTypeID, Status__c, Send_Notifications__c from NI_Trust_Outage__c where Status__c = 'New'];
        
        ApexPages.StandardController ctrller1 = new ApexPages.StandardController(outage_List[0]);
        AH_Outage_StartNotificationsExt start1 = new AH_Outage_StartNotificationsExt(ctrller1);
        start1.startNotifications();
        
        NI_Trust_Outage__c out1 = [select id, Name, Status__c, Send_Notifications__c from NI_Trust_Outage__c where id =: outage_List[0].id];
        system.assertEquals(True, out1.Send_Notifications__c);
        
        ApexPages.StandardController ctrller2 = new ApexPages.StandardController(outage_List[1]);
        AH_Outage_StartNotificationsExt start2 = new AH_Outage_StartNotificationsExt(ctrller2);
        start2.startNotifications();
        
        NI_Trust_Outage__c out2 = [select id, Name, Status__c, Send_Notifications__c from NI_Trust_Outage__c where id =: outage_List[1].id];
        system.assertEquals(False, out2.Send_Notifications__c);
        
        ApexPages.StandardController ctrller3 = new ApexPages.StandardController(outage_List[2]);
        AH_Outage_StartNotificationsExt start3 = new AH_Outage_StartNotificationsExt(ctrller3);
        start3.startNotifications();
        
        NI_Trust_Outage__c out3 = [select id, Name, Status__c, Send_Notifications__c from NI_Trust_Outage__c where id =: outage_List[2].id];
        system.assertEquals(False, out3.Send_Notifications__c);
        
        ApexPages.StandardController ctrller4 = new ApexPages.StandardController(outage_List[0]);
        AH_Outage_StartNotificationsExt start4 = new AH_Outage_StartNotificationsExt(ctrller4);
        start4.startNotifications();
        
        NI_Trust_Outage__c out = new NI_Trust_Outage__c(); 	
        out.Id = outage_List[0].Id;
        out.Send_Notifications__c = False;
        update out;
        
        ApexPages.StandardController ctrller5 = new ApexPages.StandardController(out);
        AH_Outage_StartNotificationsExt start5 = new AH_Outage_StartNotificationsExt(ctrller5);
        start5.startNotifications();
        
        NI_Trust_Outage__c out4 = [select id, Name, Status__c, Send_Notifications__c from NI_Trust_Outage__c where id =: outage_List[0].id];
        system.assertEquals(False, out4.Send_Notifications__c);
        
        Test.stopTest();
    }
}