/****************************************************************************************
Name            : AH_CBS_LicenseReq_ctrl_Test
Author          : Sean Harris
Created Date    : 12/21/2020
Last Mod Date   : 12/21/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for controller class AH_CBS_LicenseReq_ctrl
                :            
******************************************************************************************/
@isTest
public class AH_CBS_LicenseReq_ctrl_Test 
{

    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {
        
        CBS_License_Type__c lt = new CBS_License_Type__c();
        lt.License_Name__c = 'AH_CBS_LicenseReq_ctrl_Test - CBS_License_Type__c';
        lt.License_Description__c = 'FOR apex test'; 
        lt.Cost__c = 1000;
        lt.Is_Retired__c = false;
        insert lt;

        CBS_License_Request__c lr = new CBS_License_Request__c();
        //lr.Name = 'AH_CBS_LicenseReq_ctrl_Test - CBS_License_Request';
        insert lr;
        
        CBS_License_Request_Line_Item__c lri = new CBS_License_Request_Line_Item__c();
        lri.CBS_License_Type__c = lt.Id;
        lri.CBS_License_Request__c = lr.Id;
        insert lri;
        
    }
    
   
    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================    
    @isTest static void test1() 
    {

        CBS_License_Request__c lr = [SELECT Id FROM CBS_License_Request__c]; // WHERE Name = 'AH_CBS_LicenseReq_ctrl_Test - CBS_License_Request'];
        
        // SET THE CURRENT VF PAGE 
        PageReference pr = Page.AH_Amadeus_LicenseReq;
        pr.getParameters().put('id', lr.Id);
        Test.setCurrentPage(pr);
        AH_CBS_LicenseReq_ctrl ctrl = new AH_CBS_LicenseReq_ctrl(); 

        system.assertEquals(1, ctrl.lstLicenseLineItems.size());
        
        ctrl.strMsg = '';
        
        ctrl.lstLicenseLineItems[0].isSelected = true;
        
        ctrl.doLineEdit();
        ctrl.doSubmit();
        ctrl.doCancel();
 
    }
    
}