/***********************************************************************************************
Name            : AH_PLCM_Update_Email_Trigger_Date_Test
Author          : Tushar Gupta
Created Date    : 07-Oct-2020
Last Mod Date   : 07-Oct-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Test class for Email WorkFlow Trigger
************************************************************************************************/
@isTest
public class AH_PLCM_Update_Email_Trigger_Date_Test {
    static testMethod void AH_PLCM_Update_Email_Trigger_Date_Test_Method() { 
        
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForEmailWorkFlow('Hotel Wonderful MM Conversion',1, '10/09/2020', '10/09/2020','10/09/2020', 'Portal Invitation Sent', false, false, false, 'Project Plan', true);
        insert niDoc;
        System.debug('niDoc'+niDoc.AH_PLCM_Migration_Reminder_2_Date__c);
        Test.startTest();
        NI_Documentation__c niDocDetails = [Select AH_PLCM_Migration_Reminder_2_Date__c,AH_PLCM_Migration_Reminder_3_Date__c, AH_PLCM_End_of_Migration_Validation_Date__c From NI_Documentation__c Where Id =: niDoc.Id];
        System.assertEquals(niDocDetails.AH_PLCM_Migration_Reminder_2_Date__c, Date.parse('10/06/2020'));
        System.assertEquals(niDocDetails.AH_PLCM_Migration_Reminder_3_Date__c, Date.parse('10/08/2020'));
        System.assertEquals(niDocDetails.AH_PLCM_End_of_Migration_Validation_Date__c, Date.parse('10/13/2020'));
        
        Test.stopTest();
    }
}