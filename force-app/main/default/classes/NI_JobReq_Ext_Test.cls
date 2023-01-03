/****************************************************************************************
Name            : NI_JobReq_Ext_Test Class
Author          : Stuart Emery
Created Date    : 2/23/2015
Last Mod Date   : 5/11/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test Class for NI_JobReq_Ext
                :              
******************************************************************************************/
@isTest(SeeAllData=False)
private class NI_JobReq_Ext_Test {
    
    static testMethod void myUnitTest() 
    {
system.debug('====================== ENTERING NI_JobReq_Ext_Test.myUnitTest ==========================');        
        //TEST REDIRECT NEW PAGE
        
        NI_Job_Requisition__c j = new NI_Job_Requisition__c();
        
        //PAGE REFERENCE
        PageReference pageRef = Page.NI_JobReq_Edit;
        Test.setCurrentPage(pageRef);
        
        //GET THE JOB REQUISITION RECORD TYPE ID FOR THE "STANDARD" RECORD TYPE
        Id rtIdStandard = NI_TestClassData.getRecordTypeId('NI_Job_Requisition__c', 'Standard');
        System.Debug('rtIdStandard: ' + rtIdStandard);
        
        //GET THE JOB REQUISITION RECORD TYPE ID FOR THE "OFFSHORE CONTRACTOR - OPEN" RECORD TYPE
        Id rtIdOffShore = NI_TestClassData.getRecordTypeId('NI_Job_Requisition__c', 'Offshore Contractor - Open');
        
        //CREATE A TEST NI DEPARTMENT RECORD  
        NI_Departments__c d = NI_TestClassData.createTestNI_Department(1);
        insert d;
        
        //CREATE TEST NI_Job_Req_FF_PSA_License_Types__c CUSTOM SETTINGS RECORDS
        List<NI_Job_Req_FF_PSA_License_Types__c> lstFFPSALicenseTypesToInsert = new List<NI_Job_Req_FF_PSA_License_Types__c>();
        
        NI_Job_Req_FF_PSA_License_Types__c l1 = New NI_Job_Req_FF_PSA_License_Types__c();
        l1.Name = 'NI PSA Administrator';
        l1.License_Type__c = 'Full PSA User';
        lstFFPSALicenseTypesToInsert.add(l1);
        
        NI_Job_Req_FF_PSA_License_Types__c l2 = New NI_Job_Req_FF_PSA_License_Types__c();
        l2.Name = 'NI PSA T&E - Platform';
        l2.License_Type__c = 'Time & Expense User';
        lstFFPSALicenseTypesToInsert.add(l2);
        
        database.insert(lstFFPSALicenseTypesToInsert);
        
        //CREATE TEST NI_Job_Req_Salesforce_Apps__c CUSTOM SETTINGS RECORDS
        List<NI_Job_Req_Salesforce_Apps__c> lstSFAppsToInsert = new List<NI_Job_Req_Salesforce_Apps__c>();
        
        NI_Job_Req_Salesforce_Apps__c sf1 = new NI_Job_Req_Salesforce_Apps__c();
        sf1.Name = 'amorgan';
        sf1.JobRegApiName__c = 'FunnelSource__c';
        lstSFAppsToInsert.add(sf1);
        
        database.insert(lstSFAppsToInsert);
        
        //CREATE TEST NI_Job_Req_Record_Type_VF_Edit_Page__c CUSTOM SETTINGS RECORDS
        List<NI_Job_Req_Record_Type_VF_Edit_Page__c> lstRecordTypeCSToInsert = new List<NI_Job_Req_Record_Type_VF_Edit_Page__c>();
        
        NI_Job_Req_Record_Type_VF_Edit_Page__c csRtype = new NI_Job_Req_Record_Type_VF_Edit_Page__c();
        csRtype.Name = 'Standard';
        lstRecordTypeCSToInsert.add(csRtype);
        
        database.insert(lstRecordTypeCSToInsert);
        
        //CREATE A TEST NI LOCATION RECORD  
        NI_Location__c l = NI_TestClassData.createTestNI_Location(1);
        insert l;
        
        //CREATE A TEST NI OFFICE RECORD
        NI_Office__c o = NI_TestClassData.createTestNI_Office(1);
        insert o;
        
        //CREATE A TEST USER RECORD
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        u.DepartmentCode__c = d.Name;
        u.NI_Location__c = l.Name;
        u.NI_Office__c = o.Name;
        insert u;
        
        //CREATE A SECOND TEST USER RECORD
        User u2 = NI_TestClassData.createTestUser(2, 'NI Administrator');
        insert u2;        
        
        //INSTANTIATE CONTROLLER
        NI_JobReq_Ext ctrl = new NI_JobReq_Ext(new ApexPages.StandardController(j)); 
        //ctrl.rType = rtIdStandard;
        
        //INVOKE THE redirectNewPage METHOD AS THE USER PASSING IN THE "Standard" RECORD TYPE 
        System.runAs(u)
        {
            //PAGE REFERENCE
            PageReference redirectPageRef = Page.NI_JobReqRedirectVF;
            redirectPageRef.getParameters().put('RecordType', rtIdStandard);
            Test.setCurrentPage(redirectPageRef);
            System.debug('TEST PAGE1 RECORD TYPE ID: ' + ApexPages.currentPage().getParameters().get('RecordType'));
            ctrl.redirectNewPage();
            
        }
        
        //INVOKE THE redirectNewPage METHOD AS THE USER PASSING IN THE "Standard" RECORD TYPE AS A USER
        //THAT DOESN'T HAVE A LOCATION, DEPARTMENT AND OFFICE 
        System.runAs(u2)
        {
            //PAGE REFERENCE
            PageReference redirectPageRef = Page.NI_JobReqRedirectVF;
            redirectPageRef.getParameters().put('RecordType', rtIdStandard);
            Test.setCurrentPage(redirectPageRef);
            System.debug('TEST2 PAGE RECORD TYPE ID: ' + ApexPages.currentPage().getParameters().get('RecordType'));
            ctrl.redirectNewPage();
        }
        
        //INVOKE THE redirectNewPage METHOD AS THE USER PASSING IN THE "Offshore Contractor - Open" RECORD TYPE 
        System.runAs(u2)
        {
            //PAGE REFERENCE
            PageReference redirectPageRef = Page.NI_JobReqRedirectVF;
            redirectPageRef.getParameters().put('RecordType', rtIdOffShore);
            Test.setCurrentPage(redirectPageRef);
            System.debug('TEST2 PAGE RECORD TYPE ID: ' + ApexPages.currentPage().getParameters().get('RecordType'));
            ctrl.redirectNewPage();
        }
        
        //=======================TEST REDIRECT EDIT PAGE ========================================================================        
        
        //CREATE A STANDARD - OPEN JOB REQ
        NI_Job_Requisition__c j1 = new NI_Job_Requisition__c();
        j1.Job_Title__c = 'TEST TITLE';
        j1.Manager__c = u.Id;
        j1.Job_Posting_URL__c = 'https://www.google.com';
        j1.RecordTypeId = rtIdStandard;
        insert j1;
        
        //CREATE AN OFFSHORE CONTRACTOR JOB REQ
        NI_Job_Requisition__c j2 = new NI_Job_Requisition__c();
        j2.Job_Title__c = 'TEST TITLE';
        j2.RecordTypeId = rtIdOffShore;
        insert j2;
        
        //INSTANTIATE CONTROLLER FOR THE j1 ROB REQ TEST RECORD
        NI_JobReq_Ext ctrl2 = new NI_JobReq_Ext(new ApexPages.StandardController(j1));
        //ApexPages.StandardController stdJR = new ApexPages.StandardController(j1);
        //NI_JobReq_Ext ctrl = new NI_JobReq_Ext(stdJR);
        
        //INVOKE THE redirectNewPage METHOD PASSING IN THE "Standard - Open" RECORD TYPE 
        PageReference redirectStandardPageRef = Page.NI_JobReqRedirectEditPage;
        //redirectStandardPageRef.getParameters().put('id',j1.Id);
        Test.setCurrentPage(redirectStandardPageRef);
        ApexPages.currentPage().getParameters().put('id',j1.Id);
        //System.debug('TEST PAGE1 RECORD TYPE ID: ' + ApexPages.currentPage().getParameters().get('RecordType'));
        ctrl2.id=j1.Id;
        ctrl2.redirectEditPage();
        
        
        //INSTANTIATE CONTROLLER FOR THE j2 ROB REQ TEST RECORD
        NI_JobReq_Ext ctrl3 = new NI_JobReq_Ext(new ApexPages.StandardController(j2));
        
        //INVOKE THE redirectNewPage METHOD PASSING IN THE "Offshore Contractor - Open" RECORD TYPE 
        PageReference redirectOffShorePageRef = Page.NI_JobReqRedirectEditPage;
        //redirectOffShorePageRef.getParameters().put('id',j2.Id);
        Test.setCurrentPage(redirectOffShorePageRef);
        ApexPages.currentPage().getParameters().put('id',j2.Id);
        //System.debug('TEST2 PAGE RECORD TYPE ID: ' + ApexPages.currentPage().getParameters().get('RecordType'));
        ctrl3.id=j2.Id;
        ctrl3.redirectEditPage();
        
        //======================================TEST "deleteJobReq()" METHOD ==================================================
        
        ctrl2.deleteJobReq();       
        
        //======================================INVOKE METHODS ================================================================
        
        //INVOKE THE mainHardware false METHOD********************************************************* 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Main_Hardware__c = 'No Hardware Needed';
            ctrl.mainHardware();
            
        }  
        //INVOKE THE mainHardware true METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Main_Hardware__c = 'Windows Desktop';
            ctrl.mainHardware();
            
        }
        //**************************************************************************************
        //INVOKE THE showNewmarketSalesforceOrgReason false METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Newmarket_Salesforce_Org_Required__c = 'Yes';
            ctrl.showNewmarketSalesforceOrgReason();
            
        }
        
        //INVOKE THE showNewmarketSalesforceOrgReason true METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Newmarket_Salesforce_Org_Required__c = 'No';
            ctrl.showNewmarketSalesforceOrgReason();
            
        }
        
        
        //*******************************************************************************       
        //INVOKE THE showSecondaryHardwareDetails false METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Secondary_Hardware_Required__c = 'Yes';
            ctrl.showSecondaryHardwareDetails();
            
        }
        
        //INVOKE THE showSecondaryHardwareDetails true METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Secondary_Hardware_Required__c = 'No';
            ctrl.showSecondaryHardwareDetails();
            
        }
        
        //********************************************************************************** 
        //INVOKE THE showReplacementName true METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Job_Type__c = 'Replacement';
            ctrl.showReplacementName();
            
        }
        
        //INVOKE THE showReplacementName false METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Job_Type__c = 'Addition to Staff';
            ctrl.showReplacementName();
            
        }
        //********************************************************************************** 
        //INVOKE THE checkUserLicenses true METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Mirror_Existing_Salesforce_User__c = u.Id;
            ctrl.checkUserLicenses();
            
        }
        
        //INVOKE THE checkUserLicenses false METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Mirror_Existing_Salesforce_User__c = u.Id;
            ctrl.checkUserLicenses();
            
        }
        //********************************************************************************** 
        //INVOKE THE changeSalesforceLicenseType Standard METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Salesforce_com_License_Type__c = 'Standard';
            ctrl.changeSalesforceLicenseType();
            
        }
        
        //INVOKE THE changeSalesforceLicenseType Platform METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Salesforce_com_License_Type__c = 'Platform';
            ctrl.changeSalesforceLicenseType();
            
        }
        //********************************************************************************** 
        //INVOKE THE showFinancialforcePSALicenseOptions true METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Financialforce_PSA__c = true;
            ctrl.showFinancialforcePSALicenseOptions();
            
        }
        
        //INVOKE THE changeSalesforceLicenseType Platform METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.jr.Financialforce_PSA__c = false;
            ctrl.showFinancialforcePSALicenseOptions();
            
        }
        
        //INVOKE THE hasFileName METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.hasFileName();
            
        }
        
        //INVOKE THE getExecApprover METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.getExecApprover();
            
        }
        
        //INVOKE THE hideAddAttachment METHOD 
        System.runAs(u)
        {
            ctrl.id=j.Id;
            ctrl.hideAddAttachment();
            
        }
        
        //CREATE A STANDARD - OPEN JOB REQ
        NI_Job_Requisition__c j4 = new NI_Job_Requisition__c();
        j4.Job_Title__c = 'TEST TITLE';
        j4.RecordTypeId = rtIdStandard;
        j4.Manager__c = u.Id;
        j4.Job_Posting_URL__c = 'https://www.google.com';
        j4.Newmarket_Salesforce_Org_Required__c = 'Yes';
        j4.Employee_First_Name__c = 'FirstName1';
        j4.Employee_Last_Name__c = 'LastName1';
        j4.Mirror_Existing_Salesforce_User__c = u.Id;
        insert j4;        
        
        //INSTANTIATE CONTROLLER
        NI_JobReq_Ext ctrl4 = new NI_JobReq_Ext(new ApexPages.StandardController(j4)); 
        
        
        //INVOKE THE changeManager METHOD 
        System.runAs(u)
        {
            ctrl4.id=j4.Id;
            ctrl4.changeManager();
            
        }
        
        //INVOKE THE uploadAttachment METHOD 
        System.runAs(u)
        {
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            ctrl4.jobDescription = bodyBlob;
            ctrl4.filename = 'Test';
            ctrl4.id=j4.Id;
            
            ctrl4.uploadAttachment();
            
        }
        //CREATE TEST NI_Job_Req_Chatter_Group_Post__c CUSTOM SETTINGS RECORD
        NI_Job_Req_Chatter_Group_Post__c csChatterGroup = new NI_Job_Req_Chatter_Group_Post__c();
        csChatterGroup.Name = 'Test Chatter Group1';        
        insert csChatterGroup;
        System.debug('CUSTOMER SETTING CHATTER GROUP: ' + csChatterGroup.Name);
        
        //CREATE A TEST CHATTER GROUP
        CollaborationGroup cg = new CollaborationGroup();
        cg.Name = csChatterGroup.Name;
        cg.CollaborationType = 'Public';
        cg.OwnerId = u.Id;
        insert cg;
        
        CollaborationGroup cgInserted = [SELECT Id, Name FROM CollaborationGroup WHERE Name =: cg.Name];
        System.assertEquals(cg.Name, cgInserted.Name);
        //System.debug('TEST INSERTED CHATTER GROUP NAME: ' + cgInserted.Name);
        
        //INVOKE THE createChatterPost METHOD 
        System.runAs(u)
        {
            ctrl4.id=j4.Id;
            ctrl4.createChatterPost();
            
        }
        
        //INVOKE THE sendToIT METHOD 
        System.runAs(u)
        {
            ctrl4.id=j4.Id;
            ctrl4.sendToIT();
            
        }
        
        //INVOKE THE cloneStandardReq METHOD 
        System.runAs(u)
        {
            ctrl4.id=j4.Id;
            ctrl4.cloneStandardReq();
            
        }
        
        //INVOKE THE createSalesforceUser METHOD 
        System.runAs(u)
        {
            ctrl4.id=j4.Id;
            ctrl4.createSalesforceUser();
            
        }
    }    
}