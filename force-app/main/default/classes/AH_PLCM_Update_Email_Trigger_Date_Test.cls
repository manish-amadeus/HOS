/***********************************************************************************************
Name            : AH_PLCM_Update_Email_Trigger_Date_Test
Author          : Tushar Gupta
Created Date    : 07-Oct-2020
Last Mod Date   : 14-Sep-2022
Last Mod By     : Hardik Doshi - Modified as per new requirement to consider Reminder date2, Reminder date3
NICC Reference  : 
Description     : Test class for Email WorkFlow Trigger
************************************************************************************************/
@isTest
public class AH_PLCM_Update_Email_Trigger_Date_Test {
    @TestSetup
   	private static void setup() {
    	List<pse__HolidayObj__c> lstHolidays = new List<pse__HolidayObj__c>();
        lstHolidays.add(new pse__HolidayObj__c(
        	Name = 'Thanksgiving',
            pse__Date__c = Date.parse('11/24/2022')
        ));
        
        lstHolidays.add(new pse__HolidayObj__c(
        	Name = 'Day After Thanksgiving',
            pse__Date__c = Date.parse('11/25/2022')
        ));
        insert lstHolidays;
    }
    
    static testMethod void AH_PLCM_Update_Email_Trigger_Date_Test_Method() { 
        
        NI_Documentation__c niDoc1 = NI_TestClassData.createTestNI_Documentation('Hotel Wonderful Migration',1, '11/28/2022', '11/28/2022', '11/28/2022', 'Portal Invitation Sent', false, false, false, 'Project Plan');
        insert niDoc1;
        
        NI_Documentation__c niDoc2 = NI_TestClassData.createTestNI_Documentation('Hotel Wonderful Migration',1, '11/21/2022', '11/21/2022', '11/21/2022', 'Portal Invitation Sent', false, false, false, 'Project Plan');
        insert niDoc2;
        
        System.debug('niDoc'+niDoc1.AH_PLCM_Migration_Reminder_2_Date__c);
        Test.startTest();
        NI_Documentation__c niDocDetails1 = [Select AH_PLCM_Migration_Reminder_2_Date__c,AH_PLCM_Migration_Reminder_3_Date__c, AH_PLCM_End_of_Migration_Validation_Date__c From NI_Documentation__c Where Id =: niDoc1.Id];
        System.assertEquals(niDocDetails1.AH_PLCM_Migration_Reminder_2_Date__c, Date.parse('11/23/2022'));
        System.assertEquals(niDocDetails1.AH_PLCM_Migration_Reminder_3_Date__c, Date.parse('12/05/2022'));
        
        NI_Documentation__c niDocDetails2 = [Select AH_PLCM_Migration_Reminder_2_Date__c,AH_PLCM_Migration_Reminder_3_Date__c, AH_PLCM_End_of_Migration_Validation_Date__c From NI_Documentation__c Where Id =: niDoc2.Id];
        System.assertEquals(niDocDetails2.AH_PLCM_Migration_Reminder_2_Date__c, Date.parse('11/18/2022'));
        System.assertEquals(niDocDetails2.AH_PLCM_Migration_Reminder_3_Date__c, Date.parse('11/30/2022'));
        
        Test.stopTest();
    }
}