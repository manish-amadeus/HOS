/****************************************************************************************
Name            : AH_CancelRFC_Test Class
Author          : Shashikant Nikam
Created Date    : 09/19/2019
Last Mod Date   : 09/19/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_cancelRFC_Cntlr class
				: 
******************************************************************************************/
@isTest  
public class AH_CancelRFC_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup 
    static void createTestData()
    {
        NI_Change_Control__c nicc = NI_TestClassData.createNIChangeControl(1, 'Test Record');
        nicc.Salesforce_Application__c = 'Salesforce';
        nicc.Change_Reason__c = 'Additional Functionality';
        nicc.Priority__c = 'Medium';
        nicc.Date_Required__c = Date.today().addDays(7);
        nicc.Approval_Status__c = 'Not Submitted';
        nicc.Change_Status__c = 'Open';
        nicc.Request_Summary__c = 'Test summmary.';
        nicc.Request_Details__c = 'Test request details.';
        nicc.Change_Type__c = 'Add Field History Tracking';
		nicc.Functional_Area__c = 'Sales';
        insert nicc;
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // =======================================================================================================================================     
    @isTest
    static void testMethod1()
    {
        Test.startTest();
        
        List<NI_Change_Control__c> niccList = new List<NI_Change_Control__c>([SELECT Id FROM NI_Change_Control__c]);
        
        AH_CancelRFC_Cntlr.updateRecord(niccList[0].Id);
        
        List<NI_Change_Control__c> niccListUptd = new List<NI_Change_Control__c>([SELECT Id, Change_Status__c FROM NI_Change_Control__c]);
        system.assertEquals('Cancelled', niccListUptd[0].Change_Status__c, 'Status not updated.');
        
        Test.stopTest();
    }
}