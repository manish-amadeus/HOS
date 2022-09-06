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
        
        //Create user with SLTC_Account_Create_Modify_View permsiion set
        User user = SLTC_TestDataFactory.createuser('SLTC Data Governance','Data','Governance','SLTC_Data_Governance_Team');   
        INSERT user;
        PermissionSet requirePermission = SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View');
        PermissionSetAssignment permissionassignment = new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = requirePermission.Id);
        INSERT permissionassignment;
        
        //creating account context of User
        System.runAs(user){
            
            //Account with type Preliminary type
            List<Account> account_data_prelimibnary = SLTC_TestDataFactory.createAccounts('SLTC','Test','Approved', 'SLTC_Corporate','Preliminary',1);
            INSERT account_data_prelimibnary;
            
            //Account with type Customer
            List<Account> account_data_customer = SLTC_TestDataFactory.createAccounts('second','account','Approved', 'SLTC_Corporate','Customer',1);
            INSERT account_data_customer;
            
            
        }
    }
    
    // ==========================================================
    // Test Method (Positive useCase): Merge account of  Preliminary Account(Master) to  customer type.
    // ==========================================================
    @istest static void afterdeleteRecords_PTest(){ 
        User user =  [SELECT Id FROM User WHERE Email = 'Abc@pwc.com']; 
        
        List<Account> preliminary_account = [SELECT ID FROM Account WHERE type = 'Preliminary'];
        System.debug([SELECT Id, Type FROM Account]);
        System.runAs(user){
        
            List<Account> account_data = SLTC_TestDataFactory.createAccounts('sltc_customer','Test','Approved', 'SLTC_Corporate','Customer',1);
            INSERT account_data;
            Test.startTest();    
            Database.MergeResult result = Database.merge( account_data[0], preliminary_account[0], false);
            Test.stopTest();
            System.assertEquals(true, result.isSuccess());          
        }       
    }
    
    
    // ==========================================================
    // Test Method (Negative useCase): Merge account of  Customer type to Preliminary Account(Master).
    // ==========================================================
    @istest static void afterdeleteRecords_NTest(){             
        User user =  [SELECT Id FROM User WHERE Email = 'Abc@pwc.com'];   
        System.runAs(user){
            List<Account> customer_account = [SELECT ID FROM Account WHERE type = 'Customer'];
            List<Account> account_data = SLTC_TestDataFactory.createAccounts('sltc_Preliminary','Test','Approved', 'SLTC_Corporate','Preliminary',1);
            INSERT account_data;
            Test.startTest();           
            Database.MergeResult result = Database.merge( account_data[0], customer_account[0], false);
            Test.stopTest();
            System.assertEquals(false, result.isSuccess());
        }
    }
}