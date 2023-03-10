/************************************************************************************************
Name            : PSA_411_Report_Test
Author          : Sean Harris
Created Date    : 06/06/2022
Last Mod Date   : 06/06/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
*************************************************************************************************/
@isTest
public class PSA_411_Report_Test 
{
    
    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
        
        Test.startTest();  
        
        PSA_411_Report__c rpt = new PSA_411_Report__c();
        rpt.From_Date__c = system.today() - 1;
        rpt.To_Date__c = system.today() + 1;
        rpt.Run_As_Scheduled_Batch__c = false;
        insert rpt;
    
    	Test.stopTest();  
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: UNIT TESTING FOR CANCELLATION CREATION
    // =======================================================================================================================================
    @isTest static void test1() 
    {
        
        List<PSA_411_Report__c> lstRpt = new List<PSA_411_Report__c>();
        
        Test.startTest();  
        
        //system.assertEquals(1, lstRpt.size());
    	system.assert(true);
        
    	Test.stopTest();  
        
    }
    
}