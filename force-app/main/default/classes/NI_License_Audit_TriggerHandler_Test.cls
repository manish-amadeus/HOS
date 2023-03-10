/****************************************************************************************
Name            : NI_License_Audit_TriggerHandler_Test Class
Author          : Stuart Emery
Created Date    : 8/25/2015
Last Mod Date   : 9/1/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test Class for NI_License_Audit_TriggerHandler Class
: 
: 
******************************************************************************************/
@isTest (SeeAllData=false)
private class NI_License_Audit_TriggerHandler_Test 
{
    
    static testMethod void InsertTest_No_CustomSetting() 
    { 
        
        NI_License_Audit_TriggerHandler handler = new NI_License_Audit_TriggerHandler();
        
        //CREATE A TEST ACCOUNT  
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //CREATE A TEST USER
        User u = NI_TestClassData.createTestUser(2, 'NI Administrator');
        insert u;
        
        //CREATE A TEST USER
        //  User u2 = NI_TestClassData.createTestUser(3, 'NI Administrator');
        //  insert u2; 
        
        //CREATE A TEST USER TEAM MEMBER **DML OPERATION CURRENTLY NOT SUPPORTED ON UserTeamMeber OBJECT
        //UserTeamMember utm = new UserTeamMember();
        //utm.OwnerId = u.Id;
        //utm.UserId = u2.Id;
        //utm.TeamMemberRole = 'Contracts - Primary';
        //insert utm;   
        
        //CREATE A TEST PRODUCT GROUP  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //CREATE A TEST PRODUCT  
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        insert prd01;
        
        //CREATE A DEPLOYMENT INSTANCE RECORD
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        di.Name = 'Test';
        di.Status = 'Installed'; 
        di.Product_Group__c = pgp.Id;
        insert di;
        
        //CREATE A TEST NI LICENSE AUDIT RECORD 
        NI_License_Audit__c la = NI_TestClassData.createTestNiLicenseAudit(a.Id,di.Id);
        insert la;
        
        //VERIFY THAT THE CONTRACTS MANAGER FIELD HAS NOT BEEN UPDATED
        NI_License_Audit__c insertedLicAudit = [SELECT Id, Contracts_Manager__c FROM NI_License_Audit__c];
        System.assertEquals(null, insertedLicAudit.Contracts_Manager__c);
    }
    //=================================================================================================================== 
    static testMethod void InsertTest_with_CustomSetting() 
    { 
        
        NI_License_Audit_TriggerHandler handler = new NI_License_Audit_TriggerHandler();
        
        //INSERT A TEST RECORD INTO THE NI_License_Audit_Settings__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
        NI_License_Audit_Settings__c csFields = new NI_License_Audit_Settings__c();
        csFields.Name = 'Contract Manager';
        csFields.Default_Contract_Manager__c = 'Contracts - Primary';
        insert csFields;
        
        //CREATE A TEST ACCOUNT  
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //CREATE A TEST USER
        User u = NI_TestClassData.createTestUser(2, 'NI Administrator');
        insert u;      
        
        //CREATE A TEST USER
        //  User u2 = NI_TestClassData.createTestUser(3, 'NI Administrator');
        //  insert u2; 
        
        //CREATE A TEST USER TEAM MEMBER **DML OPERATION CURRENTLY NOT SUPPORTED ON UserTeamMeber OBJECT
        //UserTeamMember utm = new UserTeamMember();
        //utm.OwnerId = u.Id;
        //utm.UserId = u2.Id;
        //utm.TeamMemberRole = 'Contracts - Primary';
        //insert utm;
        
        //CREATE A TEST PRODUCT GROUP  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //CREATE A TEST PRODUCT  
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        insert prd01;
        
        //CREATE A DEPLOYMENT INSTANCE RECORD
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        di.Name = 'Test';
        di.Status = 'Installed'; 
        di.Product_Group__c = pgp.Id;
        insert di;
        
        //CREATE A TEST NI LICENSE AUDIT RECORD 
        NI_License_Audit__c la = NI_TestClassData.createTestNiLicenseAudit(a.Id,di.Id);
        insert la;
    }
    //==============================================================================================================
    static testMethod void InsertTest_No_AccountTeam() 
    { 
        
        NI_License_Audit_TriggerHandler handler = new NI_License_Audit_TriggerHandler();
        
        //INSERT A TEST RECORD INTO THE NI_License_Audit_Settings__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
        NI_License_Audit_Settings__c csFields = new NI_License_Audit_Settings__c();
        csFields.Name = 'Contract Manager';
        csFields.Default_Contract_Manager__c = 'Contracts - Primary';
        insert csFields;
        
        //CREATE A TEST ACCOUNT  
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //CREATE A TEST PRODUCT GROUP  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //CREATE A TEST PRODUCT  
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        insert prd01;
        
        //CREATE A DEPLOYMENT INSTANCE RECORD
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        di.Name = 'Test';
        di.Status = 'Installed'; 
        di.Product_Group__c = pgp.Id;
        insert di;
        
        //CREATE A TEST NI LICENSE AUDIT RECORD 
        NI_License_Audit__c la = NI_TestClassData.createTestNiLicenseAudit(a.Id,di.Id);
        insert la;
    }
    
    static testMethod void testCreateCompliance() 
    { 
        
        NI_License_Audit_TriggerHandler handler = new NI_License_Audit_TriggerHandler();
        
        //INSERT A TEST RECORD INTO THE NI_License_Audit_Settings__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
        NI_License_Audit_Settings__c csFields = new NI_License_Audit_Settings__c();
        csFields.Name = 'Contract Manager';
        csFields.Default_Contract_Manager__c = 'Contracts - Primary';
        insert csFields;
        
        //CREATE A TEST ACCOUNT  
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //CREATE A TEST PRODUCT GROUP  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //CREATE A TEST PRODUCT  
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        insert prd01;
        
        //CREATE A DEPLOYMENT INSTANCE RECORD
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        di.Name = 'Test';
        di.Status = 'Installed'; 
        di.Product_Group__c = pgp.Id;
        insert di;
        
        //CREATE A CLUSTER RECORD
        Cluster__c clus = new Cluster__c();
        clus.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'Delphi/Daylight');
        clus.Name = 'Cyb Cluster Test1';
        insert clus;
        
        //CREATE A TEST NI LICENSE AUDIT RECORD 
        NI_License_Audit__c la = NI_TestClassData.createTestNiLicenseAudit(a.Id,di.Id);
        la.Customer_Approval__c = true;       
        insert la;
        
        //CREATE A TEST NI LICENSE AUDIT RECORD 
        NI_License_Audit__c la2 = new NI_License_Audit__c();
        la2.Account__c = a.Id;
        la2.Customer_Approval__c = true;
        la2.Cluster__c = clus.Id;
        insert la2;
        
        la.License_Need__c = 2;
        la.Phase__c = 'Closed';
        update la;
        
        la2.License_Need__c = 2;
        la2.Phase__c = 'Closed';
        update la2;
        
        List<Compliance_Audit__c> complAuditList = [SELECT Id, Name FROM Compliance_Audit__c];
        system.debug('complAuditList'+complAuditList);
        
    }
}