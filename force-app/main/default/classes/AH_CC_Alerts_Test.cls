/****************************************************************************************
Name            : AH_CC_Alerts_Test
Author          : Sean Harris
Created Date    : 12/10/2019
Last Mod Date   : 12/10/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
******************************************************************************************/
@isTest
public class AH_CC_Alerts_Test 
{

    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
        
        Customer_Community_Alerts__c cca = new Customer_Community_Alerts__c();
        cca.Alert_Message__c = 'test message';
        cca.Font_Color__c = 'Red';
        cca.Font_Size__c = '12pt';
        cca.Show_in_Community__c = false;
		insert cca;
             	   
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: UNIT TESTING FOR COMMUNITY ALERT VF PAGE
    // =======================================================================================================================================
    @isTest static void test1() 
    {    
             
        PageReference pr = Page.AH_CC_Alerts;
        Test.setCurrentPage(pr);
        AH_CC_Alerts ctrl = new AH_CC_Alerts();  
        
        //system.assertEquals(1, ctrl.lstMsgs.size());
        system.assertEquals(false, ctrl.hasMsgs);
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: UNIT TESTING FOR COMMUNITY ALERT VF PAGE
    // =======================================================================================================================================
    @isTest static void test2() 
    {   
        
        Customer_Community_Alerts__c cca = [SELECT Id, Show_in_Community__c FROM Customer_Community_Alerts__c LIMIT 1];
        cca.Show_in_Community__c = true;  
        update cca;
        
        PageReference pr = Page.AH_CC_Alerts;
        Test.setCurrentPage(pr);
        AH_CC_Alerts ctrl = new AH_CC_Alerts();  
        
        system.assertEquals(1, ctrl.lstMsgs.size());
        system.assertEquals(true, ctrl.hasMsgs);
        
    }
    
}