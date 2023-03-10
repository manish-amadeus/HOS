/****************************************************************************************
Name            : AH_UTIL_ResetPassword_Ctlr_Test
Author          : Sean Harris
Created Date    : 03/18/2020
Last Mod Date   : 08/11/2021
Last Mod By     : Stuart Emery
NICC Reference  : NICC-041882
Description     : UPDATED 08/11/2021 PER NICC-052490
                : Test class for controller class AH_UTIL_ResetPassword_Ctlr
                : *** THE RUNNING USER OF THIS TEST CLASS NEEDS TO BE SET UP IN THE 
                :     "Reset_Password_Utility_Settings__mdt" CUSTOM METADATA TYPE ***          
******************************************************************************************/
@isTest
public class AH_UTIL_ResetPassword_Ctlr_Test 
{

    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {

        // CREATE TEST USERS
        List<User> lstUserInsert = new List<User>();
        
        User u1 = NI_TestClassData.createTestUser(1, 'Standard User');
        u1.Alias = 'APEXMGR'; 
        lstUserInsert.Add(u1);   
        
        User u2 = NI_TestClassData.createTestUser(2, 'Standard User');
        u2.Alias = 'APEXSPTU'; 
        lstUserInsert.Add(u2);
                
        Database.insert(lstUserInsert);           
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================    
    @isTest static void test1() 
    {

        User u = [SELECT Id FROM User WHERE Alias = 'APEXMGR'];
        User u2 = [SELECT Id, Name, Email FROM User WHERE Alias = 'APEXSPTU'];
                
//        system.runAs(u) COMMENTED DUE TO ERROR. RUNAS NEEDS "Manage Users" SO THIS WILL NOT WORK
//        {        
            //try
            //{
            // SET THE CURRENT VF PAGE
            PageReference pr = Page.AH_UTIL_ResetPassword;
            Test.setCurrentPage(pr);
            AH_UTIL_ResetPassword_Ctlr ctrl = new AH_UTIL_ResetPassword_Ctlr(); 
            
            system.debug(ctrl.lstValidUsers.size());
            
            // TEST SUBMIT WITH NO USER SELECTED
            ctrl.seluser = '0';
            ctrl.confirmReset();
            system.assertEquals(ctrl.strErrorMsg, 'Please choose a user before submitting a reset.');
            
            // SELECT USER    
            ctrl.selUser = u2.Id;
            
            // TEST CANCELLING
            ctrl.retUserDetail();
        	ctrl.confirmReset();
            ctrl.hideDialog1();
            
            // TEST SUBMITTING RESET
            ctrl.confirmReset();
            system.assertEquals(ctrl.strConfirmationMsg, 'You are about to send a reset password email to: ' + u2.Email + ' for user: ' + u2.Name + '. Please confirm.'); 
            ctrl.submitDialog1(); 
        
        
        
        
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: TEST MOBILE PHONE UPDATE
    // =======================================================================================================================================    
    @isTest static void test2() 
    {

        User u = [SELECT Id FROM User WHERE Alias = 'APEXMGR'];
        User u2 = [SELECT Id, Name, Email FROM User WHERE Alias = 'APEXSPTU'];
                

            // SET THE CURRENT VF PAGE
            PageReference pr = Page.AH_UTIL_ResetPassword;
            Test.setCurrentPage(pr);
            AH_UTIL_ResetPassword_Ctlr ctrl = new AH_UTIL_ResetPassword_Ctlr(); 
            
            system.debug(ctrl.lstValidUsers.size());
            
            // TEST SUBMIT WITH NO USER SELECTED
            ctrl.seluser = '0';
            ctrl.confirmMobileUpdate();
            system.assertEquals(ctrl.strErrorMsg, 'Please choose a user.');
            
            // SELECT USER    
            ctrl.selUser = u2.Id;
            
         // TEST CANCELLING
            ctrl.retUserDetail();
        	ctrl.confirmMobileUpdate();
            ctrl.hideDialog2();
            
            // TEST SUBMITTING 
            ctrl.confirmMobileUpdate();
            system.assertEquals(ctrl.strConfirmationMsg, 'You are about to clear the Mobile Phone Number for user: ' + u2.Name + '. Please confirm.'); 
            ctrl.submitDialog2();
                          
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: TEST UNLOCK USER
    // =======================================================================================================================================    
    @isTest static void test3() 
    {

        User u = [SELECT Id FROM User WHERE Alias = 'APEXMGR'];
        User u2 = [SELECT Id, Name, Email FROM User WHERE Alias = 'APEXSPTU'];
                

            // SET THE CURRENT VF PAGE
            PageReference pr = Page.AH_UTIL_ResetPassword;
            Test.setCurrentPage(pr);
            AH_UTIL_ResetPassword_Ctlr ctrl = new AH_UTIL_ResetPassword_Ctlr(); 
            
            system.debug(ctrl.lstValidUsers.size());
            
            // TEST SUBMIT WITH NO USER SELECTED
            ctrl.seluser = '0';
            ctrl.confirmUserUnlock();
            system.assertEquals(ctrl.strErrorMsg, 'Please choose a user.');
            
            // SELECT USER    
            ctrl.selUser = u2.Id;
            
         // TEST CANCELLING
            ctrl.retUserDetail();
        	ctrl.confirmUserUnlock();
            ctrl.hideDialog3();
            
            // TEST SUBMITTING 
            ctrl.confirmUserUnlock();
            system.assertEquals(ctrl.strConfirmationMsg, 'You are about to unlock the user record for: ' + u2.Name + '. Please confirm.'); 
            ctrl.submitDialog3();
                          
    }

    
}