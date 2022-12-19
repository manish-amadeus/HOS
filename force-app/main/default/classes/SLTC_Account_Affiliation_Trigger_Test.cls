/**********************************************************
*************************************
Name :   SLTC_Account_Affiliation_Trigger_Test
Author : Jaswanth R
Created Date : 5/11/2022
Last Mod Date :  5/14/2022
Last Mod By : Jaswanth R
NICC Reference : 
Description :Test class for SLTC_Account_Affiliation_Trigger
***********************************************************
*************************************/

@isTest
public class SLTC_Account_Affiliation_Trigger_Test {
    
    @testSetup
    static void setup(){
        
        List<PermissionSet> requirePermission = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionassignment = new List<PermissionSetAssignment>();
        User user = SLTC_TestDataFactory.createuser('SLTC Sales','First','Last','SLTC_Sales_Manger');  
        INSERT user;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            INSERT new NI_TriggerBypassSwitches__c(Name='Bypass Control Panel',BypassOpportunity_ON__c = true,BypassAccount_ON__c = true, Bypass_SLTC_Account_Affiliation_Trigger__c  = false);
            requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Affiliation_CRUD_Access'));
            requirePermission.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Brand_Edit_Access'));
            requirePermission.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
            for(PermissionSet ps: requirePermission){
                permissionassignment.add(new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id));          
            }
            
            INSERT permissionassignment;
        }
        System.runAs(user)
        {
            List<Account> accountList = SLTC_TestDataFactory.createAccounts('Partner','Test','MDM Approved','SLTC_ParentAccount','Prospect',1);
            INSERT accountList;
            List<Account> accountList1 = SLTC_TestDataFactory.createAccounts('Property','Test','MDM Approved','SLTC_Property','Prospect',1);
            INSERT accountList1;
            SLTC_Brand__c brandNew = SLTC_TestDataFactory.createBrandOnAccount(accountList[0].id,'Brand_test');
            INSERT brandNew;
        }
        
    }
    
    
    // ==========================================================
    // Test Method: Test Before Insert Scenario To mark previous Account Affilaition Inactive(Management Type Affiliation)
    // ==========================================================
    @isTest
    private static void beforeInsertManagementAffilaitionTest()
    {
        List<Account> getTestAccounts = [SELECT Id FROM Account WHERE Name !=NULL Order by Name ASC];
        
        User getUser = [SELECT Id FROM User WHERE FirstName='First' limit 1];
        
        Test.startTest();
        {
            
            System.runAs(getUser){ 
                List<SLTC_Account_Affiliation__c> accAffReturnList = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Management Company',TRUE,1,NULL);
                INSERT accAffReturnList;
                List<SLTC_Account_Affiliation__c> accAffReturnListDup = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Management Company',TRUE,1,NULL);
                INSERT accAffReturnListDup;
            }
        }
        
        Test.stopTest();
        SLTC_Account_Affiliation__c affAssert = [SELECT Id,SLTC_Active__c FROM SLTC_Account_Affiliation__c WHERE SLTC_Affiliation_Type__c='Management Company' AND SLTC_Active__c=TRUE LIMIT 1];
        System.assertEquals(true, affAssert.Id!=NULL,'New management affiliation was set to be active'); 
    }
    
    // ==========================================================
    // Test Method: Test Before Update Scenario To mark previous Account Affilaition Inactive(Ownership Type Affiliation)
    // ==========================================================
    
    
    @isTest private static void beforeUpdateOwnershipAffilaitionTest()
    {
        List<Account> getTestAccounts = [SELECT Id FROM Account WHERE Name !=NULL Order by Name ASC];
        User getUser = [SELECT Id FROM User WHERE FirstName='First' limit 1];
        
        Test.startTest();
        {
            
            System.runAs(getUser){ 
                List<SLTC_Account_Affiliation__c> accAffReturnList = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Ownership Company',TRUE,1,NULL);
                INSERT accAffReturnList;
                List<SLTC_Account_Affiliation__c> accAffReturnListDup = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Ownership Company',FALSE,1,NULL);
                INSERT accAffReturnListDup;
                accAffReturnListDup[0].SLTC_Active__c=TRUE;
                UPDATE accAffReturnListDup;
            }
        }
        
        Test.stopTest();
        SLTC_Account_Affiliation__c affAssert = [SELECT Id,SLTC_Active__c FROM SLTC_Account_Affiliation__c WHERE SLTC_Affiliation_Type__c='Ownership Company' AND SLTC_Active__c=TRUE LIMIT 1];
        System.assertEquals(true, affAssert.Id!=NULL,'New Ownership affiliation was set to be active'); 
    }
    
    // ==========================================================
    // Test Method: Test Before Insert Scenario To mark previous Account Affilaition Inactive(Franchisor Type Affiliation)
    // ==========================================================
    @isTest
    private static void beforeInsertFranchisorAffilaitionTest()
    {
        List<Account> getTestAccounts = [SELECT Id FROM Account WHERE Name !=NULL Order by Name ASC];
        User getUser = [SELECT Id FROM User WHERE FirstName='First' limit 1];
        SLTC_Brand__c getBrand = [SELECT Id,Name FROM SLTC_Brand__c WHERE Name LIKE '%Brand_test%' limit 1];
        
        Test.startTest();
        {
            
            System.runAs(getUser){ 
                List<SLTC_Account_Affiliation__c> accAffReturnList = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Franchisor',TRUE,1,NULL);
                accAffReturnList[0].SLTC_Brand__c=getBrand.Id;
                List<SLTC_Account_Affiliation__c> accAffReturnListDup = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Franchisor',TRUE,1,NULL);
                accAffReturnListDup[0].SLTC_Brand__c=getBrand.Id;
                INSERT accAffReturnList;
                INSERT accAffReturnListDup;
            }
        }
        
        Test.stopTest();
        SLTC_Account_Affiliation__c affAssert = [SELECT Id,SLTC_Active__c FROM SLTC_Account_Affiliation__c WHERE SLTC_Affiliation_Type__c='Franchisor' AND SLTC_Active__c=TRUE LIMIT 1];
        System.assertEquals(true, affAssert.Id!=NULL,'New Franchisor affiliation was set to be active'); 
    }
    // ==========================================================
    // Test Method: Test Before Update Scenario To mark previous Account Affilaition Inactive(Regional Type Affiliation)
    // ==========================================================
    @isTest
    private static void beforeUpdateRegionalAffilaitionTest()
    {
        List<Account> getTestAccounts = [SELECT Id FROM Account WHERE Name !=NULL Order by Name ASC];
        User getUser = [SELECT Id FROM User WHERE FirstName='First' limit 1];
        
        Test.startTest();
        {
            
            System.runAs(getUser){ 
                List<SLTC_Account_Affiliation__c> accAffReturnList = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Regional Office/Cluster',TRUE,1,NULL);
                INSERT accAffReturnList;
                List<SLTC_Account_Affiliation__c> accAffReturnListDup = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Regional Office/Cluster',FALSE,1,NULL);
                INSERT accAffReturnListDup;
                accAffReturnListDup[0].SLTC_Active__c=true;
                UPDATE accAffReturnListDup;
            }
        }
        
        Test.stopTest();
        SLTC_Account_Affiliation__c affAssert = [SELECT Id,SLTC_Active__c FROM SLTC_Account_Affiliation__c WHERE SLTC_Affiliation_Type__c='Regional Office/Cluster' AND SLTC_Active__c=TRUE LIMIT 1];
        System.assertEquals(true, affAssert.Id!=NULL,'New Regional affiliation was set to be active'); 
    }
    // ==========================================================
    // Test Method: Test Before Update Scenario To mark previous Account Affilaition Inactive(Regional Type Affiliation)
    // ==========================================================
    @isTest
    private static void beforeInsertThirdPartyTest()
    {
        List<Account> getTestAccounts = [SELECT Id FROM Account WHERE Name !=NULL Order by Name ASC];
        User getUser = [SELECT Id FROM User WHERE FirstName='First' limit 1];
        
        Test.startTest();
        {
            
            System.runAs(getUser){ 
                List<SLTC_Account_Affiliation__c> accAffReturnList = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Other Third-Party Company',TRUE,1,NULL);
                INSERT accAffReturnList;
                accAffReturnList[0].SLTC_Active__c=FALSE;
                UPDATE accAffReturnList;
            }
        }
        
        Test.stopTest();
        SLTC_Account_Affiliation__c affAssert = [SELECT Id,SLTC_Active__c FROM SLTC_Account_Affiliation__c WHERE SLTC_Affiliation_Type__c='Other Third-Party Company' AND SLTC_Active__c=FALSE LIMIT 1];
        System.assertEquals(true, affAssert.Id!=NULL,'New Third Party affiliation was set to be inactive'); 
    }  
    // ==========================================================
    // Test Method: Test Method To Test All flow elements before insert or update
    // ==========================================================
    @isTest
    private static void beforeInsertUpdateFlowsTest()
    {
        List<Account> getTestAccounts = [SELECT Id FROM Account WHERE Name !=NULL Order by Name ASC];
        User getUser = [SELECT Id FROM User WHERE FirstName='First' limit 1];
        SLTC_Brand__c getBrand= [SELECT Id,Name FROM SLTC_Brand__c WHERE Name LIKE '%Brand_test%' limit 1];
        Test.startTest();
        {
            
            System.runAs(getUser){ 
                List<SLTC_Account_Affiliation__c> accAffReturnList = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Other Third-Party Company',TRUE,1,NULL);
                accAffReturnList.addAll(SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Regional Office/Cluster',TRUE,1,NULL));
                accAffReturnList.addAll(SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Franchisor',TRUE,1,NULL));
                accAffReturnList.addAll(SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Ownership Company',TRUE,1,NULL));
                accAffReturnList.addAll(SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Management Company',TRUE,1,NULL));
                accAffReturnList[2].SLTC_Brand__c=getBrand.Id;
                INSERT accAffReturnList;
                List<SLTC_Account_Affiliation__c> accAffInactive = new List<SLTC_Account_Affiliation__c>();
                for(SLTC_Account_Affiliation__c accAffSingle:accAffReturnList){
                    accAffSingle.SLTC_Active__c=false;
                    accAffInactive.add(accAffSingle);
                }
                UPDATE accAffInactive;
            }
        }
        
        Test.stopTest();
        List<SLTC_Account_Affiliation__c> affAssert = [SELECT Id,SLTC_Active__c FROM SLTC_Account_Affiliation__c WHERE SLTC_Active__c=FALSE ];
        System.assertEquals(true, affAssert.size()==5,'All Affiliations Set to In-Active'); 
    }  
    // ==========================================================
    // Test Method: Test Method To Test All flow elements before delete
    // ==========================================================
    @isTest
    private static void beforeDeleteFlowsTest()
    {
        List<Account> getTestAccounts = [SELECT Id FROM Account WHERE Name !=NULL Order by Name ASC];
        User getUser = [SELECT Id FROM User WHERE FirstName='First' limit 1];
        SLTC_Brand__c getBrand = [SELECT Id,Name FROM SLTC_Brand__c WHERE Name LIKE '%Brand_test%' limit 1];
        Test.startTest();
        {
            
            System.runAs(getUser){ 
                List<SLTC_Account_Affiliation__c> accAffReturnList = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Other Third-Party Company',TRUE,1,NULL);
                accAffReturnList.addAll(SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Regional Office/Cluster',TRUE,1,NULL));
                accAffReturnList.addAll(SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Franchisor',TRUE,1,NULL));
                accAffReturnList.addAll(SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Ownership Company',TRUE,1,NULL));
                accAffReturnList.addAll(SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Management Company',TRUE,1,NULL));
                accAffReturnList[2].SLTC_Brand__c=getBrand.Id;
                INSERT accAffReturnList;
                DELETE accAffReturnList;
            }
        }
        
        Test.stopTest();
        List<SLTC_Account_Affiliation__c> affAssert = [SELECT Id,SLTC_Active__c FROM SLTC_Account_Affiliation__c WHERE (Id!=Null)];
        System.assertEquals(true, affAssert.size()==0,'All Account Affiliations Deleted'); 
    }
    // ==========================================================
    // Test Method: Test Method For CPL Full Scenario
    // ==========================================================
    @isTest
    private static void beforeInsertCplFullOfferingTest()
    {
        List<Account> getTestAccounts = [SELECT Id FROM Account WHERE Name !=NULL Order by Name ASC];  
        User getUser = [SELECT Id FROM User WHERE FirstName='First' limit 1];
        string Offerings = 'Full;Business Intelligence';
        System.runAs(getUser){
            Test.startTest();
            List<SLTC_Account_Affiliation__c> accAffReturnList = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Management Company',TRUE,1,NULL);
            accAffReturnList[0].SLTC_Offerings__c = Offerings;
            Database.SaveResult result = Database.insert(accAffReturnList[0],false);
            Test.stopTest();
            System.assertEquals(false, result.isSuccess(), result.getErrors()); 
        }
    }
    // ==========================================================
    // Test Method: Test Method For CPL Full plus Business Intelligence
    // ==========================================================
    @isTest
    private static void beforeInsertFullOfferingTest()
    { 
        List<Account> getTestAccounts = [SELECT Id FROM Account WHERE Name !=NULL Order by Name ASC];
        User getUser = [SELECT Id FROM User WHERE FirstName='First' limit 1];
        string Offerings='Reservation Solutions';
        string fullOfferings='Full';
        System.runAs(getUser){
            Test.startTest();
            List<SLTC_Account_Affiliation__c> accAffReturnList = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Management Company',TRUE,1,NULL);
           accAffReturnList.addAll( SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Ownership Company',TRUE,1,NULL));
           accAffReturnList.addAll( SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Regional Office/Cluster',TRUE,1,NULL));
            accAffReturnList[0].SLTC_Offerings__c = Offerings;
            accAffReturnList[1].SLTC_Offerings__c = Offerings;
            accAffReturnList[2].SLTC_Offerings__c = fullOfferings;
            Database.SaveResult result = Database.insert(accAffReturnList[0],false);
            Database.SaveResult resultNew = Database.insert(accAffReturnList[1],false);
            Database.SaveResult resultFull = Database.insert(accAffReturnList[2],false);
            accAffReturnList[0].SLTC_Offerings__c = fullOfferings;
            Database.SaveResult resultOnlyFull = Database.update(accAffReturnList[0],false);
            Test.stopTest();
            System.assertEquals(true, result.isSuccess(), result.getErrors()); 
            System.assertEquals(false, resultNew.isSuccess(), resultNew.getErrors()); 
            System.assertEquals(false, resultFull.isSuccess(), resultFull.getErrors()); 
            System.assertEquals(false, resultOnlyFull.isSuccess(), resultOnlyFull.getErrors()); 
        }
    }
    // ==========================================================
    // Test Method: Test Method For CPL Full Scenario
    // ==========================================================
    @isTest
    private static void beforeInsertCplFullOnlyTest()
    {
        List<Account> getTestAccounts = [SELECT Id FROM Account WHERE Name !=NULL Order by Name ASC];   
        User getUser = [SELECT Id FROM User WHERE FirstName='First' limit 1];
        string OfferingsFull='Full';
        string OfferingsRS='Reservation Solutions';
        System.runAs(getUser){
            Test.startTest();
            List<SLTC_Account_Affiliation__c> accAffReturnList = SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Management Company',TRUE,1,NULL);
             accAffReturnList.addAll( SLTC_TestDataFactory.createAccountAffiliation(getTestAccounts[0].Id,getTestAccounts[1].Id,'Ownership Company',TRUE,1,NULL));
            accAffReturnList[0].SLTC_Offerings__c=OfferingsFull;
            accAffReturnList[1].SLTC_Offerings__c=OfferingsRS;
            Database.SaveResult result = Database.insert(accAffReturnList[0],false);
            Database.SaveResult resultNew = Database.insert(accAffReturnList[1],false);
            Test.stopTest();
            System.assertEquals(true, result.isSuccess(), result.getErrors());
            System.assertEquals(false, resultNew.isSuccess(), resultNew.getErrors()); 
        }
    }
}