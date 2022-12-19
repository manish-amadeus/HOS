/**************************************************************************************
******************************
Name 			: SLTC_Account_TriggerHandler_Test 
Author 			: Lamu Sreeharsha
Created Date 	: 5/24/22
Last Mod Date 	: 5/24/22
Last Mod By 	: Lamu Sreeharsha
NICC Reference 	: 
Description 	: Test class for SLTC_Account_TriggerHandler.
***************************************************************************************
*******************************/

@isTest
public class SLTC_Account_TriggerHandler_Test {
    
    // ==========================================================
    // Create Test Data
    // ==========================================================
    @testSetup static void setup(){
        List<User> user_data = NEW List<User>();
        user_data.add(SLTC_TestDataFactory.createuser('SLTC Data Governance','Data','Governance','ContractsAdministrator'));   
        INSERT user_data;
        List<PermissionSetAssignment> permissionassignment_data= new List<PermissionSetAssignment>();
        List<PermissionSet> requirePermission = new List<PermissionSet>();
        requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
        requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_delete'));
                              
        for(PermissionSet ps: requirePermission){
            permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[0].Id, PermissionSetId = ps.Id)); 
         }                     
        INSERT permissionassignment_data;
        //run in context of Data Governance
        System.runAs(user_data[0]){
            //Account with type Preliminary type
            List<Account> account_data_prelimibnary = SLTC_TestDataFactory.createAccounts('SLTC','Test','MDM Approved', 'SLTC_Property','Preliminary',1);
            INSERT account_data_prelimibnary;
            //Account with type Customer
            List<Account> account_data_customer = SLTC_TestDataFactory.createAccounts('second','account','MDM Approved', 'SLTC_Property','Customer',1);
            INSERT account_data_customer; 
        }
    }
    
    // ======================================================================================
    // Test Method (Positive useCase): Merge Preliminary type Account to customer type Account (Master)
    // ======================================================================================
    @istest static void afterdeleteRecordsPositiveTest(){ 
        User user =  [SELECT Id FROM User WHERE (FirstName='Data') limit 1]; 
        System.runAs(user){
            List<Account> preliminary_account = [SELECT ID FROM Account WHERE type = 'Preliminary'];
            List<Account> account_data = SLTC_TestDataFactory.createAccounts('sltc_customer','Test','MDM Approved', 'SLTC_Property','Customer',1);
            INSERT account_data;         
            Test.startTest();    
            Database.MergeResult result = Database.merge( account_data[0], preliminary_account[0], false);
            Test.stopTest();
            System.assertEquals(true, result.isSuccess());          
        }       
    }
      
    // ======================================================================================
    // Test Method (Negative useCase): Merge Customer type account to Preliminary type Account(Master).
    // ======================================================================================
    @istest static void afterdeleteRecordsNegativeTest(){             
        User user =  [SELECT Id FROM User WHERE (FirstName='Data') limit 1];   
        System.runAs(user){
            List<Account> customer_account = [SELECT ID FROM Account WHERE type = 'Customer'];
            List<Account> account_data = SLTC_TestDataFactory.createAccounts('sltc_Preliminary','Test','MDM Approved', 'SLTC_Property','Preliminary',1);
            INSERT account_data;
            Test.startTest();           
            Database.MergeResult result = Database.merge( account_data[0], customer_account[0], false);
            Test.stopTest();
            System.assertEquals(false, result.isSuccess());
        }
    }
}