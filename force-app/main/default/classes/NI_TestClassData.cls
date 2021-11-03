/****************************************************************************************
Name            : NI_TestClassData Class
Author          : Sean Harris
Created Date    : 11/21/2012
Last Mod Date   : 05/09/2021 
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test Class for other test classes to point to when creating test data
                : Modified on 03/27/2021 PER NICC-048128
                : Modified on 12/19/2020 per NICC-047197
                : Modified on 6/14/2017 per NICC-022457
                : Modified on 3/30/2017 per NICC-021667
                : Modified on 9/7/2017 per NICC-023777
                : Modified on 11/6/2017 per NICC-024607
******************************************************************************************/
public class NI_TestClassData 
{
     
    public static Id getRecordTypeId(String sObjTypeName, String RecordTypeName)
    {
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType =: sObjTypeName AND Name =: RecordTypeName AND isActive = true];
        return rt.Id;
    }

    // ==============================================================================================================================================
    //     STANDARD OBJECT RECORD CREATE FUNCTIONS
    // ==============================================================================================================================================

    public static Account createTestAccount(Integer iRecordNumber)
    {
        Account a = new Account();
        a.Name = 'Test' + String.valueOf(iRecordNumber);        
        a.BillingPostalCode = '03801';
        a.BillingCountry = 'US';
        a.BillingState = 'NH';
        a.BillingStreet = '75 NH Ave';
        a.BillingCity = 'Portsmouth';
        a.Type = 'Customer';
        a.ShippingPostalCode = '03801';
        a.ShippingCountry = 'US';
        a.ShippingState = 'NH';
        a.ShippingStreet = '75 NH Ave';
        a.ShippingCity = 'Portsmouth';
        a.Legal_Entity_Name__c = 'Legal Entity';
        return a;     
    }
    
    public static Asset createTestasset(Integer iRecordNumber, Id testAccountId, Id testProduct2Id)
    {
        Asset asset = new Asset();
        asset.Name = 'Apex Test Asset' + iRecordNumber;        
        asset.AccountId = testAccountId;
        asset.Product2Id = testProduct2Id;
        asset.Parent_Relationship__c = 'Other';
        asset.Status = 'Purchased';
        return asset;     
    }
   
    public static Attachment createTestAttachment(Id testParentId)
    {    
        Attachment attach = new Attachment();     
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = testParentId;
        return attach;    
    }   
    
    public static Case createTestCase(Integer iRecordNumber, Id testAccountId)
    {
        Case c = new Case();
        //c.OwnerId = testUserId;     
        c.Description = 'Test Description';
        c.AccountId = testAccountId;
        c.Subject = 'Test Case' + iRecordNumber;
        c.Origin = 'Phone';
        c.Status = 'New';
        c.Has_No_DI__c = true;
        return c;      
    } 
    
    public static CaseComment createTestCaseComment(Integer iRecordNumber, Id testParentId)
    {
        CaseComment cc = new CaseComment();
        cc.ParentId = testParentId;
        cc.CommentBody = 'Apex Test Comment Body ' + iRecordNumber;
        return cc; 
    }
    
    public static CaseSolution createCaseSolution(Id idCaseId, Id idSolutionId) 
    {
        CaseSolution csol = new CaseSolution(CaseId = idCaseId, SolutionId = idSolutionId);
        return csol;
    }
        
    public static Contact createTestContact(Integer iRecordNumber, Id testAccountId)
    {
        Contact c = new Contact();
        c.LastName = 'Smith' + iRecordNumber;
        c.AccountId = testAccountId;
        c.Status__c = 'Active';
        c.MailingStreet = '75 NH Ave';
        c.MailingCity = 'Portsmouth';
        c.MailingState = 'NH';
        c.MailingCountry = 'US';
        c.MailingPostalCode = '03801';
        return c;      
    } 

    public static ContentVersion createContentVersion()
    {         
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion cntVers = new ContentVersion();
        cntVers.Title = 'APEX TEST TITLE v1'; 
        cntVers.PathOnClient = '/APEXTEST.csv';
        cntVers.VersionData = bodyBlob; 
        cntVers.Origin = 'H';
        return cntVers;
    }

    public static ContentDocumentLink createContentDocumentLink(Id ContentDocumentId, Id ParentId)
    { 
        ContentDocumentLink cntLnk = new ContentDocumentLink();
        cntLnk.ContentDocumentId = ContentDocumentId;
        cntLnk.LinkedEntityId = ParentId;    
        cntLnk.ShareType = 'V';
        return cntLnk;     
    }    

    public static EmailMessage createTestEmailMessage(Integer iRecordNumber, Id testParentId, String testFromName, String testFromAddress, String testToAddress, String testCcAddress, String testBccAddress, String testSubject, String testTextBody, String testStatus)
    {             
        EmailMessage em = new EmailMessage();
        em.ParentId = testParentId;
        em.FromName = testFromName;
        em.FromAddress = testFromAddress;
        em.ToAddress = testToAddress;
        em.CcAddress = testCcAddress;
        em.BccAddress = testBccAddress; 
        em.Subject = 'Apex Test Email # ' + iRecordNumber;
        em.TextBody = 'Apex Test Email # ' + iRecordNumber;
        em.Status = testStatus;
        return em;
    }         
    
    public static Group createGroup(String GroupName, String GroupDevName, String GroupType) 
    {
        Group grp = new Group();
        grp.Name = GroupName;
        grp.DeveloperName = GroupDevName;
        grp.Type = GroupType;
        return grp;
    }    
    
    public static GroupMember createGroupMember(Id idGroupId, Id idUserOrGroupId) 
    {
        GroupMember grpM = new GroupMember();
        grpM.GroupId= idGroupId;
        grpM.UserOrGroupId = idUserOrGroupId;
        return grpM;
    }    
    
    public static Note createNote(Integer iRecordNumber, Id OppId)
    {
        Note newNote = new Note();
        newNote.ParentId = OppId;
        newNote.Title = 'Test Note ' + String.valueOf(iRecordNumber);
        newNote.Body = 'Testing Adding a Note to an Opportunity';
        return newNote;
    }
    
    public static Opportunity createTestOpportunity(Integer iRecordNumber, Id testAccountId)
    {
        Opportunity o = new Opportunity();
        o.AccountId = testAccountId;
        o.Name = 'Apex Test Opportunity Name';
        o.StageName = 'Prospecting';
        o.Order_Status__c = 'Prospect';
        o.Amount = 25000;
        o.CloseDate = Date.Today();
        o.Effective_Date__c = Date.Today();
        o.Opportunity_Source__c = 'Support';
        o.Amadeus_Legal_Entity__c = 'Amadeus Hospitality Americas, Inc.';   // Shashikant Nikam (NICC-033453)
        return o;        
    } 
       
    public static OpportunityContactRole createTestOpportunityContactRole(Id testOpportunityId, Id testContactId, String testRole)
    {
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = testOpportunityId;
        ocr.ContactId = testContactId;
        ocr.Role = testRole;         
        return ocr;        
    }    
                             
    public static OpportunityLineItem createTestOpportunityLineItem(Integer iRecordNumber, Id testOpportunityId, Id testPricebookEntryId, Integer testQuantity) 
    {
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = testOpportunityId;
        oli.Description = 'Apex Test Line Item ' + iRecordNumber;
        oli.PricebookEntryId = testPricebookEntryId;
        oli.Quantity = testQuantity;  
        oli.TotalPrice = 1000;          
        return oli;
    }
         
    public static Pricebook2 createTestPricebook(String testPricebookName) 
    {    
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = testPricebookName;   
        pb2.Description = 'Apex Test Pricebook';
        pb2.IsActive = true;
        return pb2;         
    }
    
    public static PricebookEntry createTestPricebookEntry(Id testPricebook2Id, Id testProduct2Id, Decimal testUnitPrice) 
    {
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = testPricebook2Id;  
        pbe.Product2Id = testProduct2Id;
        pbe.UnitPrice = testUnitPrice;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        return pbe; 
    } 
    
    public static Product2 createProduct2(Integer iRecordNumber, Id ProductGroupId, String strSKU, String strFamily) 
    {
        Product2 p2 = new Product2();
        p2.Product_Group__c = ProductGroupId;
        p2.Product_Line__c = 'Delphi Single Property';
        p2.Revenue_Category__c = 'Services';
        p2.Unit__c = 'Subscription';
        p2.IsActive = true;
        p2.ProductCode = strSKU;
        p2.Description = 'APEX Test Class';
        p2.Family = strFamily;
        p2.Name = 'Embrace';
        // ADDED 7/16/2014
        p2.Line__c = 'Delphi';
        p2.Edition__c = 'Enterprise';
        p2.Classification__c = 'TEST DATA';
        p2.Support_Classification__c = 'Gold';
        p2.Interface_Classification__c = 'PMS';
        // ADDED 9/30/2014 
        p2.Corporate_Product_Group__c = 'Newmarket';
        return p2;
    }
    
    public static Solution createSolution(Integer iRecordNumber) 
    {
        Solution sol = new Solution(SolutionName = 'APEX TEST ' + iRecordNumber);
        return sol;
    }
    
    public static Task createTestTask(Integer iRecordNumber, Id testWhoId, Id testWhatId, Id testRecordTypeId, String testTaskType, String testTaskStatus, String testTaskPriority) 
    {
        Task tsk = new Task();
        tsk.WhoId = testWhoId;
        tsk.WhatId = testWhatId;
        tsk.RecordTypeId = testRecordTypeId;
        tsk.Type = testTaskType;
        tsk.Description = 'Test Description ' + iRecordNumber;
        tsk.Priority = testTaskPriority;
        tsk.Status = testTaskStatus;
        tsk.Subject = 'Test Description ' + iRecordNumber;
        return tsk; 
    }    

    public static User createTestUser(Integer iRecordNumber, String profilename) 
    {
        User newuser = new User();
        newuser.LastName = profilename + String.valueOf(iRecordNumber);
        newuser.Alias = 'user' + String.valueOf(iRecordNumber);
        newuser.Email = 'XXXXtestzzz@amadeushospitality.com';
        newuser.Username = 'XXXXtestzzz_00' + String.valueOf(iRecordNumber) + '@amadeushospitality.com';
        newuser.CommunityNickname = 'test_00' + String.valueOf(iRecordNumber) + '@amadeushospitality.com';
        newuser.ProfileId = [SELECT Id FROM Profile WHERE Name =: profilename].id;
        newuser.TimeZoneSidKey = 'America/New_York';
        newuser.LocaleSidKey = 'en_US';
        newuser.EmailEncodingKey = 'UTF-8';
        newuser.LanguageLocaleKey = 'en_US';
        newuser.isActive = true;
        newuser.Division = 'Support';
        newuser.ADUserName__c = 'ADNAME' + String.valueOf(iRecordNumber); 
        return newuser;
    }
  
    // ==============================================================================================================================================
    //     CUSTOM OBJECT RECORD CREATE FUNCTIONS
    // ==============================================================================================================================================
    
    public static AIP_GDS_Monthly_Revenue__c createAIP_GDS_MonthlyRevenue(Integer iRecordNumber, Date dtRevenueMonth) 
    {   
        AIP_GDS_Monthly_Revenue__c gds = new AIP_GDS_Monthly_Revenue__c();       
        gds.Amadeus_Property_Code__c = String.ValueOf(iRecordNumber);
        gds.Revenue_Amount__c = 100;
        gds.Revenue_Month__c = dtRevenueMonth;
        return gds;
    }

    public static IT_Hardware_Model__c createITHardwareModel(Integer iRecordNumber) 
    {   
        IT_Hardware_Model__c hm = new IT_Hardware_Model__c();
        hm.Name = 'TEST MODEL' + iRecordNumber;
        hm.Model_Description__c = 'TEST DESCRIPTION';
        return hm;
    }

    public static IT_Hardware_Asset__c createITHardwareAsset(Integer iRecordNumber, Id productId) 
    {   
        IT_Hardware_Asset__c ha = new IT_Hardware_Asset__c();
        ha.Product_ID__c = productId;
        return ha;
    }

    public static IT_Software_Package__c createITSoftwarePackage(Integer iRecordNumber) 
    {   
        IT_Software_Package__c sp = new IT_Software_Package__c();
        sp.Name = 'TEST PACKAGE' + iRecordNumber;
        return sp;
    }

    public static IT_Software_Asset__c createITSoftwareAsset(Integer iRecordNumber, Id softwarePackageId) 
    {   
        IT_Software_Asset__c sa = new IT_Software_Asset__c();
        sa.Software_Package_Name__c = softwarePackageId;
        sa.Date_Purchased__c = date.Today();
        return sa;
    }

    public static NI_Change_Control__c createNIChangeControl(Integer iRecordNumber, String strNIChangeControlName) 
    {   
        NI_Change_Control__c nicc = new NI_Change_Control__c();
        nicc.Request_Summary__c = strNIChangeControlName + ' ' + String.ValueOf(iRecordNumber);
        nicc.Date_Required__c = Date.Today();
        return nicc;
    }
    
    public static NICC_Artifact__c createArtifact(Integer iRecordNumber, String strArtifactName, Id NIChangeControlId, String strType) 
    {
        NICC_Artifact__c art = new NICC_Artifact__c();
        art.Artifact_Name__c = strArtifactName + ' ' + String.ValueOf(iRecordNumber);
        art.NI_Change_Control__c = NIChangeControlId;
        art.Type__c = strType;
        return art;
    }

    public static Product_Group__c createProductGroup(Integer iRecordNumber, String strProductGroupName) 
    {
        Product_Group__c pg = new Product_Group__c();
        pg.Name = strProductGroupName;
        pg.IsActive__c = true;
        pg.IsCoreProduct__c = true;
        return pg;
    }
    
    public static NI_Customization_Service__c createTestHRMService(Integer iRecordNumber, Id testAccountId, String strStatus, Integer iTimeUnitsBalance, Integer iTimeUnitsPerPeriod, Integer iTimeUnitsUsed) 
    {   
    
        Date tmpDate1 = Date.Today();
        Date tmpDate2 = tmpDate1.addDays(30);
        
        NI_Customization_Service__c cs = new NI_Customization_Service__c(); 
        cs.Account__c = testAccountId;
        cs.Expiration_Date__c = tmpDate1;
        cs.Period_Starting__c = tmpDate2; 
        cs.Period_Ending__c = tmpDate2; 
        cs.Period_Number__c = 1; 
        cs.Service_Name__c = 'Embrace';
        cs.Status__c = strStatus;
        cs.Time_Units_Balance__c = iTimeUnitsBalance;
        cs.Time_Units_Per_Period__c = iTimeUnitsPerPeriod;
        cs.Time_Units_Used__c = iTimeUnitsUsed;      
        return cs;        
    }
     
    public static NI_Customization_Detail__c createTestHRMCustomization(Integer iRecordNumber, Id testAccountId, Id testCaseId) 
    {      
        NI_Customization_Detail__c cd = new NI_Customization_Detail__c(); 
        cd.Account__c = testAccountId; 
        cd.Case__c = testCaseId; 
        cd.State__c = 'Incomplete';
        cd.Category__c = 'Reporting';
        cd.Type__c = 'Creating Reports';
        cd.Subject__c = 'Record Subject ' + iRecordNumber;
        cd.Description__c = 'Record Description ' + iRecordNumber;
        cd.Estimated_Hours__c = 1;
        return cd;
    }

    public static NI_CustomizationDetailToService__c createTestWorkHourAllocation(Id testAccountId, Id testCaseId, Id testNI_Customization_DetailId, Id testNI_Customization_ServiceId) 
    {           
        NI_CustomizationDetailToService__c d2s = new NI_CustomizationDetailToService__c(); 
        d2s.Account__c = testAccountId;
        d2s.Detail__c = testNI_Customization_DetailId; 
        d2s.Service__c = testNI_Customization_ServiceId;   
        d2s.Case__c = testCaseId;
        d2s.Actual_Hours__c = 1; 
        d2s.CompletedDate__c = Date.Today();
        d2s.IsRunningTest__c = true;    
        return d2s;
    }
    
    public static NI_Departments__c createTestNI_Department(Integer iRecordNumber) 
    {       
        NI_Departments__c d = new NI_Departments__c(); 
        d.Name = String.valueof(iRecordNumber);
        d.Active__c = true;
        d.Description__c = 'Test' + iRecordNumber;        
        return d;  
    }

    public static NI_DI_Reference__c createTestNI_DI_Reference(Integer iRecordNumber, Id testProductGroupId, Id testProductId) 
    {             
        NI_DI_Reference__c dir = new NI_DI_Reference__c(); 
        dir.Active__c = true;
        dir.Deployment_Instance_Name__c = 'Test DI'; 
        dir.HRM_Apps_Value__c = 'Test App1';   
        dir.Product__c = testProductId;
        dir.Product_Group__c = testProductGroupId;
        dir.Product_Line__c = 'Test Product Line';        
        return dir;        
    }
    
    public static NI_Job_Requisition__c createTestNI_Job_Requisition(Integer iRecordNumber, Id testOwner, Id testRecordType) 
    {       
        NI_Job_Requisition__c j = new NI_Job_Requisition__c(); 
        j.Job_Title__c = 'Test' + iRecordNumber;
        j.OwnerId = testOwner;
        j.RecordTypeId = testRecordType;        
        return j;  
    }

    public static NI_Location__c createTestNI_Location(Integer iRecordNumber) 
    {       
        NI_Location__c l = new NI_Location__c(); 
        l.Name = 'iRecordNumber';
        l.Location_Name__c = 'Test' + iRecordNumber;        
        return l;  
    }
    
    public static NI_Department_to_Location__c createTestNI_DepartmentToLocation(Integer iRecordNumber, Id testDepartment, Id testLocation, Id testEmployee, String testRole) 
    {       
        NI_Department_to_Location__c d2l = new NI_Department_to_Location__c(); 
        d2l.Employee__c = testEmployee;
        d2l.NI_Departments__c = testDepartment;
        d2l.Location__c = testLocation;
        d2l.Role__c = testRole;        
        return d2l;  
    }
    
    public static Marketing_Qualified_Lead__c createTestMarketingQualifiedLead(Id testContactId) 
    {              
        Marketing_Qualified_Lead__c mql = new Marketing_Qualified_Lead__c();
        mql.Contact_Name__c = testContactId;
        return mql;
    }   
    
    public static newmarketsvcs__Location__c createTestNewmarketsvcsLocation(Integer iRecordNumber) 
    {         
        newmarketsvcs__Location__c l = new newmarketsvcs__Location__c(); 
        l.newmarketsvcs__Name__c = 'TEST LOCATION' + iRecordNumber; 
        return l; 
    } 
    
    public static newmarketsvcs__Notification__c createTestNewmarketsvcsNotification(Integer iRecordNumber, Id testLocationId, String testSubject) 
    {   
        newmarketsvcs__Notification__c n = new newmarketsvcs__Notification__c(); 
        n.newmarketsvcs__Subject__c = testSubject;
        n.newmarketsvcs__Entity_ID__c = 'TEST ENDTITY ID'; 
        n.newmarketsvcs__Tracking_Entry_ID__c = 'TEST TRACKING ENTRY ID';   
        n.newmarketsvcs__Message_Type__c = 'TEST MESSAGE TYPE';
        n.newmarketsvcs__Notification_GUID__c = String.ValueOf(iRecordNumber);
        n.newmarketsvcs__Location__c = testLocationId;        
        return n;   
    }
    
    public static NI_License_Audit__c createTestNiLicenseAudit(Id AccountId, Id DeploymentInstanceId) 
    {              
        NI_License_Audit__c la = new NI_License_Audit__c(); 
        la.Account__c = AccountId;
        la.Asset__c = DeploymentInstanceId;     
        return la;        
    }

    public static NI_Office__c createTestNI_Office(Integer iRecordNumber) 
    {       
        NI_Office__c o = new NI_Office__c(); 
        o.Name = String.valueof(iRecordNumber);        
        return o;  
    }
    
    public static NI_Org_Details__c createTestNiOrgDetails(Id idRt, Integer iRecordNumber, String orgType) 
    {              
        NI_Org_Details__c od = new NI_Org_Details__c(); 
        od.RecordTypeId = idRt;
        od.Org_Name__c = 'TEST'+ iRecordNumber;
        od.Admin_Login_Name_Encrypted__c = 'test@test.com';
        od.Admin_Password_Encrypted__c = '123456789';        
        od.Org_Type__c = orgType;      
        return od;        
    }

    public static NI_Org_Details_to_Accounts__c createTestNIOrgDetails2Accounts(Id OrgDetailsId, Id AccountId)  
    {
        NI_Org_Details_to_Accounts__c o2a = new NI_Org_Details_to_Accounts__c();
        o2a.NIOrgDetailsID__c = OrgDetailsId;
        o2a.AccountID__c = AccountId;
        return o2a;
    }

    public static newmarketsvcs__IServer__c CreateTestNWS_IServer(Integer iIServer_ID, String sNewmarketUser)
    {
        newmarketsvcs__IServer__c nwsSys = new newmarketsvcs__IServer__c();
        string s = '000000000';
        nwsSys.newmarketsvcs__IServer_ID__c = 'IS-' + s.Substring(0, (s.Length() - String.valueOf(iIServer_ID).Length())) + String.valueOf(iIServer_ID);
        nwsSys.newmarketsvcs__NewmarketUser__c = sNewmarketUser;
        return nwsSys;
    }

    public static newmarketsvcs__Location__c createTestNWS_Location(Integer iRecordNumber, id NWS_IServerId, Id AccountId)
    {
        newmarketsvcs__Location__c nwsLoc = new newmarketsvcs__Location__c();
        nwsLoc.newmarketsvcs__IServerID__c = NWS_IServerId;
        nwsLoc.newmarketsvcs__Name__c = 'Test Location ' + String.valueof(iRecordNumber);
        nwsLoc.newmarketsvcs__Master_Location__c = AccountId;
        return nwsLoc; 
    }

    public static NI_Org_Details_To_Accounts__c CreateOrgDetailAccount(Id orgDetailsId, Id AccountId)
    {
        NI_Org_Details_to_Accounts__c orgDetailAccount = new NI_Org_Details_to_Accounts__c();
        orgDetailAccount.AccountID__c = AccountId;
        orgDetailAccount.NIOrgDetailsID__c = orgDetailsId;
        return orgDetailAccount;
    }

    public static Expense_Report__c createTestSalesExpenseReport(Integer iRecordNumber) 
    {              
        Expense_Report__c e = new Expense_Report__c(); 
        e.Name = 'TEST' + iRecordNumber;
        return e;        
    }   

    public static NI_Trust__c createTestNITrust(String strPlatformName, Integer iRecordNumber) 
    {              
        NI_Trust__c trust = new NI_Trust__c(); 
        trust.IsActive__c = true;
        trust.Platform_Name_External__c = strPlatformName;
        trust.Platform_Name_Internal__c = strPlatformName;
        trust.IsActive__c = true;
        trust.Sort_Order__c = 1;
        return trust;        
    }   

    public static NI_Trust_Outage__c createTestNITrustOutage(Id idTrust, Datetime dtOutageStart, Datetime dtOutageEnd, Integer iRecordNumber, Date stdate, String stTime, date endDate, String endtTime)
    {              
        NI_Trust_Outage__c trustOutage = new NI_Trust_Outage__c(); 
        trustOutage.NI_Trust__c = idTrust;
        trustOutage.Make_Public__c = true;
        trustOutage.Public_Details__c = 'APEX TEST DETAILS TEXT';
        trustOutage.Outage_Start_Date_Time__c = dtOutageStart;
        trustOutage.Outage_End_Date_Time__c = dtOutageEnd;
        trustOutage.Start_Date__c = stdate;
        trustOutage.Start_Time_GMT__c = stTime;
        trustOutage.End_Date__c = endDate;
        trustOutage.End_Time_GMT__c = endtTime;
        return trustOutage;        
    }   
   
    public static SFDC_CSP_Development_Request__c createChangeRequest(Id testProductGroupId, Id testVersionId, Id testPartId, Integer iRecordNumber) 
    {
        SFDC_CSP_Development_Request__c chngReq = new SFDC_CSP_Development_Request__c(); 
        chngReq.Type__c = 'Defect';
        chngReq.Title__c = 'NI CHANGE REQUEST RECORD ' + String.valueOf(iRecordNumber);
        chngReq.Description__c = 'NI CHANGE REQUEST RECORD';
        chngReq.Product_Group__c = testProductGroupId;
        chngReq.Version__c = testVersionId;
        chngReq.Part__c = testPartId;
        chngReq.Support_Priority__c = '4 - Low';
        return chngReq;        
    }      
   
    public static SFDC_CSP_Part__c createPart(Id testProduct2Id, Id testVersionId, Integer iRecordNumber) 
    {
        SFDC_CSP_Part__c niPrt = new SFDC_CSP_Part__c(); 
        niPrt.Name = 'TEST PART NAME ' + String.valueOf(iRecordNumber);
        niPrt.Product__c = testProduct2Id;
        niPrt.Version__c = testVersionId;
        return niPrt;        
    }    
   
    public static SFDC_CSP_Version__c createVersion(String strVersionName, Id strProductGroupId, Integer iRecordNumber) 
    {
        SFDC_CSP_Version__c niVrs = new SFDC_CSP_Version__c (); 
        niVrs.Name = strVersionName + ' ' + String.valueOf(iRecordNumber);
        niVrs.Product_Group__c = strProductGroupId;
        return niVrs;        
    } 
   
    public static NICC_Risk_Setup__c createNICCRiskSetup(String strRiskDesc, String strRiskType, Integer iSortNumber, Integer iRecordNumber) 
    {
        NICC_Risk_Setup__c niccRS = new NICC_Risk_Setup__c(); 
        niccRS.Description__c = strRiskDesc + ' ' + String.valueOf(iRecordNumber);
        niccRS.Level1Desc__c = 'level 1'; 
        niccRS.Level2Desc__c = 'level 2';
        niccRS.Level3Desc__c = 'level 3'; 
        niccRS.Level4Desc__c = 'level 4'; 
        niccRS.Level1Weight__c = 1; 
        niccRS.Level2Weight__c = 2; 
        niccRS.Level3Weight__c = 3;
        niccRS.Level4Weight__c = 4;
        niccRS.Type__c = strRiskType;
        niccRS.SortOrder__c = iSortNumber;
        return niccRS;        
    }     
    
    public static NICC_Risk__c createNICCRisk(String strRiskDesc, String strRiskType, Boolean bLvl1, Boolean bLvl2, Boolean bLvl3, Boolean bLvl4, String strNICC, Integer iSortNumber, Integer iRecordNumber) 
    {
        NICC_Risk__c niccRsk = new NICC_Risk__c(); 
        niccRsk.Description__c = strRiskDesc + ' ' + String.valueOf(iRecordNumber);
        niccRsk.Level1Desc__c = 'level 1'; 
        niccRsk.Level1Value__c = bLvl1; 
        niccRsk.Level2Desc__c = 'level 2'; 
        niccRsk.Level2Value__c = bLvl2; 
        niccRsk.Level3Desc__c = 'level 3';  
        niccRsk.Level3Value__c = bLvl3; 
        niccRsk.Level4Desc__c = 'level 4'; 
        niccRsk.Level4Value__c = bLvl4; 
        niccRsk.Type__c = strRiskType;
        niccRsk.SortOrder__c = iSortNumber;
        niccRsk.NICC_ID__c = strNICC;
        return niccRsk;        
    }      

    public static ICESubscription__c createICESubscription(Integer iRecordNumber, Decimal decSubscriptionID)
    {
        ICESubscription__c iceSub = new ICESubscription__c(); 
        iceSub.SubscriptionName__c = 'Test ' + String.valueOf(iRecordNumber);
        iceSub.DelphiNetIsActive__c = true; 
        iceSub.SubscriptionID__c = decSubscriptionID;        
        return iceSub;             
    }
    
    public static ICEProperty__c createICEProperty(Integer iRecordNumber, Decimal decSubscriptionID, Decimal decPropertyId)
    {        
        ICEProperty__c icePrp = new ICEProperty__c();         
        icePrp.PropertyName__c = 'Test ' + String.valueOf(iRecordNumber);  
        icePrp.DelphiNetIsActive__c = true;         
        icePrp.SubscriptionID__c = decSubscriptionID;     
        icePrp.PropertyId__c = decPropertyId;
        return icePrp;   
    }    
    
    public static ICEUser__c createICEUser(Integer iRecordNumber, Decimal decSubscriptionID, Decimal decPropertyId, Decimal decUserId)
    {
        ICEUser__c iceUsr = new ICEUser__c(); 
        iceUsr.DelphiNetIsActive__c = true;
        iceUsr.SubscriptionID__c = decSubscriptionID;
        iceUsr.DefaultPropertyId__c = decPropertyId;
        iceUsr.UserID__c = decUserId;
        iceUsr.Email__c = 'TestUser' + String.valueOf(iRecordNumber) + '@newmarketinc.com'; 
        iceUsr.LoginName__c = 'TestUser' + String.valueOf(iRecordNumber) + '@newmarketinc.com'; 
        iceUsr.UserName__c = 'Test User ' + String.valueOf(iRecordNumber);         
        return iceUsr;         
    }                                                        

    public static NI_Customer_Relations_Engagement__c createCustomerRelationsEngagement(Integer iRecordNumber, Id AccountId, Id EngagementContactId)
    {  
        NI_Customer_Relations_Engagement__c nicrengage = new NI_Customer_Relations_Engagement__c();
        nicrengage.Type__c = 'Reactive';
        nicrengage.Account__c = AccountId;
        nicrengage.Engagement_Contact__c = EngagementContactId;
        nicrengage.Summary__c = 'Apex Test #' + String.valueOf(iRecordNumber);  
        return nicrengage;
    }

    public static Softrax_Order_Line__c createStxOrderLines(Integer iRecordNumber, Id OppId)
    {  
        Softrax_Order_Line__c stxOl = new Softrax_Order_Line__c();
        stxOl.Name = 'APEX TEST' + iRecordNumber;
        stxOl.Opportunity_ID__c = OppId; 
        return stxOl;
    }

    public static SFDC_Acct_Plan__c createAccountPlan(Integer iRecordNumber, Id AcctId)
    {  
        SFDC_Acct_Plan__c acctPlan = new SFDC_Acct_Plan__c();
        acctPlan.Name = 'APEX TEST' + iRecordNumber;
        acctPlan.Account__c = AcctId; 
        return acctPlan;
    } 
    
    public static SFDC_Strategy__c createStrategy(Integer iRecordNumber, Id AcctId, Id AcctPlanId)
    {  
        SFDC_Strategy__c objStrategy = new SFDC_Strategy__c();
        objStrategy.Name = 'APEX TEST' + iRecordNumber;
        objStrategy.Account__c = AcctId; 
        objStrategy.SFDC_Acct_Plan__c = AcctPlanId;
        return objStrategy;
    }   
    
    public static NI_Employee_Performance_Evaluation__c createEmployee_Performance_Evaluation(Id ManagerId, Id CoManagerId)
    {
        NI_Employee_Performance_Evaluation__c objEPE = new NI_Employee_Performance_Evaluation__c();
        objEPE.Manager__c = ManagerId;
        objEPE.Collaborating_Manager__c = CoManagerId; 
        return objEPE;
    }      

    public static NI_PE_Assessment__c createPerfEvalAssessment(Id NI_Employee_Performance_EvaluationId)
    {
        NI_PE_Assessment__c objEPEAss = new NI_PE_Assessment__c();
        objEPEAss.NI_Employee_Performance_Evaluation__c = NI_Employee_Performance_EvaluationId;
        objEPEAss.Description__c = 'TEST DESC';
        return objEPEAss;
    }       
    
    public static NI_Career_Path__c createPerfEvalCareerPath(Id NI_Employee_Performance_EvaluationId)
    {
        NI_Career_Path__c objEPEPath = new NI_Career_Path__c();
        objEPEPath.NI_Employee_Performance_Evaluation__c = NI_Employee_Performance_EvaluationId;
        return objEPEPath;
    }     
    
    public static NI_PerfEval_Goals__c createPerfEvalGoals(Id NI_Employee_Performance_EvaluationId)
    {
        NI_PerfEval_Goals__c objEPEGoal = new NI_PerfEval_Goals__c();
        objEPEGoal.Employee_Performance_Evaluation__c = NI_Employee_Performance_EvaluationId;
        return objEPEGoal;
    }      

    public static NI_DeploymentInstanceIndex__c createDI_Index(Integer iRecordNumber, String indexName)
    {
        NI_DeploymentInstanceIndex__c testDI_Index = new NI_DeploymentInstanceIndex__c();
        testDI_Index.Name = indexName + ' ' + String.valueOf(iRecordNumber);
        return testDI_Index;
    }    
    
    public static Support_Tier_Designation__c createSupportTierDesignation(Integer iRecordNumber, Id idUserId,  String strRoleValue)
    {
        Support_Tier_Designation__c stdgn = new Support_Tier_Designation__c();
        stdgn.Support_Rep__c = idUserId;
        stdgn.Support_Rep_Role__c = strRoleValue;
        stdgn.Team__c = 'BRT';
        return stdgn;
    }

    public static AIP_Transactions__c createAIPTransaction(Id idOpportunityId)
    {
        AIP_Transactions__c aipT = new AIP_Transactions__c();
        aipT.Opportunity__c = idOpportunityId;
        return aipT;
    } 
    
    public static Market__c createAIPMarket(Integer iRecordNumber)
    {
        Market__c aipM = new Market__c();
        aipM.Name = 'XX' + String.valueOf(iRecordNumber);
        return aipM;
    }

    public static NI_Vendor_Agreement__c createTestVendorAgreement(Integer iRecordNumber)
    {  
        NI_Vendor_Agreement__c va = new NI_Vendor_Agreement__c();
        va.Name = 'APEX TEST' + iRecordNumber;
        va.Active__c = true;
        va.Amortization_Term__c = 12;
        va.Royalty_Percentage__c = 50;
        va.Royalty_Base_Amount__c = 100;
        va.General_Ledger_Credit_Account__c = 'Apex Test GL Credit Account';
        va.General_Ledger_Debit_Account__c = 'Apex Test GL Debit Account';
        return va;
    }
    
    public static NI_Customer_Agreement__c createTestCustomerAgreement(Id idOpportunityId, Id idProductId, Id idAccountId, Id idVendorAgreementId)
    {
        NI_Customer_Agreement__c ca = new NI_Customer_Agreement__c();
        ca.Account__c = idAccountId;
        ca.Status__c = 'Active';
        ca.Amortization_Term__c = 12;
        ca.Royalty_Percentage__c = 50;
        ca.Royalty_Base_Amount__c = 100;
        ca.Opportunity__c = idOpportunityId;
        ca.Account__c = idAccountId;
        ca.Product__c = idProductId;
        ca.Sale_Price__c = 1200;
        return ca;
    }

    public static NI_Invoice__c createTestNI_Invoice(String OppNumber, Id AccountId, Integer iRecordNumber)
    {  
        NI_Invoice__c i = new NI_Invoice__c();
        i.Account__c = AccountId;
        i.Order_Number__c = OppNumber;
        return i;
    }

    public static NI_Invoice_Detail__c createTestNI_InvoiceDetail(Id InvId, Id prodId)
    {  
        NI_Invoice_Detail__c iDet = new NI_Invoice_Detail__c();
        iDet.NI_Invoice__c = InvId;
        iDet.Product__c = prodId;
        return iDet;
    }

    public static NI_Product_Release__c createTestNI_Product_Release(Id productGroupId, Id ownerId, Integer iRecordNumber)
    {      
        NI_Product_Release__c prel = new NI_Product_Release__c();
        prel.Name = 'APEX TEST ' + String.ValueOf(iRecordNumber);
        prel.Product_Group__c = productGroupId;
        prel.Product_Line__c = 'Delphi Multi Property';
        prel.Product_Owner__c = ownerId;
        prel.Release_Type__c = 'Major';
        prel.Status__c = 'Development';    
        prel.Assigned_Product_Line__c = 'Delphi';
        return prel;
    }

    public static NI_Sprint__c createSprint(String sprintName)
    {
        NI_Sprint__c sprint = new NI_Sprint__c();
        sprint.Name__c = sprintName; 
        sprint.Sprint_Start_Date__c = Date.Today().addDays(2);
        sprint.Sprint_Completion_Date__c = Date.Today().addDays(14); 
        sprint.Team__c = 'Business Systems';
        return sprint;
    }

    public static NI_Project_Backlog__c createTestProjectBacklog(Integer iRecordNumber)
    {
        NI_Project_Backlog__c projBacklog = new NI_Project_Backlog__c(); 
        projBacklog.Name = 'Test Project' + String.valueOf(iRecordNumber);
        projBacklog.Affected_Objects__c = 'Account';
        return projBacklog;     
    }
    
    public static NI_Global_Acceptance_Criterion__c createTestGAC(Integer iRecordNumber, String applicableObj)
    {
        NI_Global_Acceptance_Criterion__c testGac = new  NI_Global_Acceptance_Criterion__c();
        testGac.Name = 'Test GAC '+ String.valueOf(iRecordNumber);
        testGac.Applicable_Object__c = applicableObj;
        testGac.Given__c = 'Test Given' + String.valueOf(iRecordNumber);
        testGac.When__c = 'Test When' + String.valueOf(iRecordNumber);
        testGac.Then__c = 'Test Then' + String.valueOf(iRecordNumber);
        return testGac;     
    }
    
    public static NI_Project_Acceptance_Criterion__c createTestPAC(Integer iRecordNumber, Id projBacklogId, String applicableObj)
    {
        NI_Project_Acceptance_Criterion__c testPac = new  NI_Project_Acceptance_Criterion__c();
        testPac.NI_Project_Backlog__c = projBacklogId;
        testPac.Name__c = 'Test PAC '+ String.valueOf(iRecordNumber);
        testPac.Applicable_Object__c = applicableObj;
        testPac.Given__c = 'Test Given' + String.valueOf(iRecordNumber);
        testPac.When__c =  'Test When' + String.valueOf(iRecordNumber);
        testPac.Then__c = 'Test Then' + String.valueOf(iRecordNumber);
        return testPac;     
    }
    
    public static SFDC_CSP_Flash_Message__c createFlashMessage(Id AccountId)
    {        
        SFDC_CSP_Flash_Message__c flshMsg = new SFDC_CSP_Flash_Message__c();
        flshMsg.Account__c = AccountId;
        return flshMsg;
    }

    public static Cluster__c createMPECluster(integer iRecordNumber)
    { 
        Cluster__c mpeCluster = new Cluster__c(); 
        mpeCluster.Name = 'Test Cluster '+ String.valueOf(iRecordNumber); 
        return mpeCluster; 
    } 

    public static Billing_Contract__c createBillingContract(integer iRecordNumber)
    { 
        Billing_Contract__c bllCntrct = new Billing_Contract__c(); 
        bllCntrct.Name = 'Test Billing Contract ' + String.valueOf(iRecordNumber); 
        return bllCntrct; 
    }     

    public static Billing_Contract_Line_Item__c createBillingContract(Id BillingContractId, Id ActivityLineItemId)
    { 
        Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c(); 
        bcli.Billing_Contract__c = BillingContractId;
        bcli.Activity_Line_Item__c = ActivityLineItemId;
        return bcli; 
    }   
        
    public static Activity_Line_Item__c createActivityLineItem(Id billingContractId)
    { 
        Activity_Line_Item__c actLineItem = new Activity_Line_Item__c(); 
        actLineItem.Billing_Contract__c = billingContractId; 
        return actLineItem; 
    }

    public static Subscription_Activation__c createSubscriptionActivation()
    { 
        Subscription_Activation__c subActivation = new Subscription_Activation__c();
        return subActivation; 
    }

    public static Subscription_Activation_Transaction__c createSubscriptionActivationTransaction(Id subActivationId)
    { 
        Subscription_Activation_Transaction__c subActivationTransaction = new Subscription_Activation_Transaction__c();
        subActivationTransaction.Subscription_Activation_No__c = subActivationId;
        return subActivationTransaction; 
    }    

    public static NI_Cancellation__c createCancellation(Id accountId)
    { 
        NI_Cancellation__c CxlRec = new NI_Cancellation__c();
        CxlRec.Account__c = accountId;
        return CxlRec; 
    } 
    
    public static Partners_Form_Template__c createPartnersFormTemplate()
    { 
        Partners_Form_Template__c pft = new Partners_Form_Template__c();
        pft.End_Date__c = Date.Today();
        pft.Start_Date__c = Date.Today();
        pft.Subject__c = 'APEX SUBJECT'; 
        pft.Terms__c = 'APEX TERMS';
        return pft;     
    }

    public static Partners_Form_Template_to_Account__c createPartnersFormTemplate2Account(Id PartnersFormTemplateId, Id AccountId)
    { 
        Partners_Form_Template_to_Account__c pft2a = new Partners_Form_Template_to_Account__c();
        pft2a.Partners_Form_Template__c = PartnersFormTemplateId;
        pft2a.Account__c = AccountId;
        return pft2a;     
    }  
    
    public static AH_CaseFlagPreferences__c createCaseFlagPreferences() 
    {
        AH_CaseFlagPreferences__c caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        caseFlagSetting.Age_1_Hours__c = 0.00;
        caseFlagSetting.Age_2_Hours__c = 0.50;
        caseFlagSetting.Age_3_Hours__c = 1.00;
        caseFlagSetting.Age_4_Hours__c = 1.50;
        caseFlagSetting.Clear_on_Activity__c = true;
        caseFlagSetting.Clear_On_Case_Close__c = true;
        caseFlagSetting.Clear_On_Company_Comment__c = true;
        caseFlagSetting.Clear_on_Outbound_Email__c = true;
        caseFlagSetting.Company_Domain__c = 'cybage.com';
        caseFlagSetting.Enable_History__c = true;
        caseFlagSetting.Set_On_Case_Attachment__c = true;
        caseFlagSetting.Set_On_Case_Create__c = true;
        caseFlagSetting.Set_On_Customer_Comment__c = true;
        caseFlagSetting.Set_On_Inbound_Email__c = true;
        caseFlagSetting.Track_Case_Ownership__c = true;
        caseFlagSetting.Track_Case_Status__c = true;
        caseFlagSetting.Track_Flag_Clear__c = true;
        caseFlagSetting.Track_Flag_Set__c = true;
        caseFlagSetting.Organisation_Wide__c = false;        
        return caseFlagSetting;
    }
    
    public static AH_Case_Flags_Store_Types__c createCaseFlageStoreType()
    {
        AH_Case_Flags_Store_Types__c cfst = new AH_Case_Flags_Store_Types__c();
        cfst.Name = 'Default';
        cfst.Clear_Case_Origins__c = 'LiveChat,Phone';
        cfst.Enabled_Activity_Types__c = 'Call,Email,Incoming Call,Information Sent,Left Message,Outgoing Call,Outgoing Email,Research';
        cfst.Enabled_Case_Type__c = '0126000000011YUAAY,01232000000JNnBAAW,0126000000011YWAAY';
        return cfst;
    }

    public static NI_Trust_Outage_Email__c createNITrustOutageCustomSettings()
    {
        NI_Trust_Outage_Email__c outageSettings = new NI_Trust_Outage_Email__c();
        outageSettings.Name = 'Default';
        outageSettings.Status_New__c = 'Amadeus Hospitality Incident - New';
        outageSettings.Status_Open_Stage_1__c = 'Amadeus Hospitality Incident - Update';
        outageSettings.Status_Open_Stage_2__c = 'Amadeus Hospitality Incident - Update';
        outageSettings.Status_Resolved__c = 'Amadeus Hospitality Incident - Resolved';
        outageSettings.Outgoing_Addresses__c = 'outgoingAddr@test.com';
        outageSettings.Record_Types__c = 'Unplanned';
        outageSettings.Reply_To_Address__c = 'hospitality.no-reply@amadeus.com';
        outageSettings.Delay_Time_Severity_1__c = '120';
        outageSettings.Delay_Time_Severity_2__c = '240';
        return outageSettings;
    }

    // CREATE A MILESTONE FORECAST RECORD
    public static Milestone_Forecast__c createTestMilestoneForecast(pse__Milestone__c milestone)
    {  
        Milestone_Forecast__c mf = new Milestone_Forecast__c();
        mf.Milestone__c = milestone.Id;
        mf.Forecast_Date__c = date.newInstance(2015, 05, 15);
        return mf;
    }          
    
    // CREATE A MILESTONE BATCH GENERATION RECORD
    public static Milestone_Batch_Generation__c createPSEMilestoneBatchGen(Id ProjectId, Id productPackageId)
    {        
        Milestone_Batch_Generation__c mbg = new Milestone_Batch_Generation__c();
        mbg.First_Milestone_Date__c = Date.newInstance(2011, 12, 1);
        mbg.Project__c = ProjectId;
        mbg.Product_Package__c = productPackageId;
        mbg.Total_Package_Amount__c = 10000;
        return mbg;    
    }

    public static PSA_Product_Package__c createPSAProductPackage()
    {
        PSA_Product_Package__c pp = new PSA_Product_Package__c();
        pp.Description__c = 'TEST PACKAGE';
        pp.Package_SKU__c = 'APEX-TEST-001';
        return pp;
    }
        
    public static Payment_Terms__c createInvoicePaymentTerms()
    {
        Payment_Terms__c ipt = new Payment_Terms__c();
        ipt.Name = '4 Installments';
        ipt.Type__c = 'Services';
        return ipt;
    } 
    
    public static Payment_Term_Line_Item__c createInvoicePaymentTermsLimeItem(Id PaymentTermsId)
    {
        Payment_Term_Line_Item__c iptli = new Payment_Term_Line_Item__c();
        iptli.Payment_Terms__c = PaymentTermsId;
        iptli.Duration_Units__c = 0;
        return iptli;
    } 
    
    public static Remittance_Info__c createRemittanceInfo(string strName)
    {
        Remittance_Info__c rInfo = new Remittance_Info__c(); 
        rInfo.Name = 'TEST Remittance Info Record'; 
        return rInfo;
    }
    
    public static ffrr__RecognitionYear__c createRecognitionYear(Date dt)
    {
        Date dtStart = Date.newInstance(dt.year(), 1, 1);
        Date dtEnd = Date.newInstance(dt.year(), 12, 31);
        ffrr__RecognitionYear__c ry = new ffrr__RecognitionYear__c();
        ry.Name = String.valueOf(dt.year());
        ry.ffrr__NumberOfMonths__c = 12;
        ry.ffrr__PeriodCalculationBasis__c = 'Month';
        ry.ffrr__StartDate__c = dtStart;
        ry.ffrr__EndDate__c = dtEnd;
        return ry;
    }
    
    public static ffrr__RecognitionPeriod__c createRecognitionPeriod(Date dt, Id RecognitionYearId)
    {
        
        Date dtStart = Date.newInstance(dt.year(), dt.month(), 1);
        Date dtEnd = (dtStart.addMonths(1) - 1);
        Map<Integer, String> mapPNums = new Map<Integer, String>();
        mapPNums.put(1, '001');
        mapPNums.put(2, '002');
        mapPNums.put(3, '003');
        mapPNums.put(4, '004');
        mapPNums.put(5, '005');
        mapPNums.put(6, '006');
        mapPNums.put(7, '007');
        mapPNums.put(8, '008');
        mapPNums.put(9, '009');
        mapPNums.put(10, '010');
        mapPNums.put(11, '011');
        mapPNums.put(12, '012');
        
        ffrr__RecognitionPeriod__c rp = new ffrr__RecognitionPeriod__c();
        
        rp.Name = String.valueOf(dt.year());
        rp.ffrr__RecognitionYear__c = RecognitionYearId;
        rp.ffrr__NumberOfWeeks__c = 0;
        rp.ffrr__PeriodNumber__c = mapPNums.get(dt.month());
        rp.ffrr__StartDate__c = dtStart;
        rp.ffrr__EndDate__c = dtEnd;
        
        return rp;
        
    }

    //===========================================================================================================================
    // Create Finance Request.  Added per NICC-030091
    // ==========================================================================================================================    
    public static AH_Finance_Request__c createFinanceRequest()
    {
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.AH_Finance_Request__c; 
        Map<String, Schema.RecordTypeInfo> financeRequestRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        //GET THE ID OF THE SALES CREDIT NOTE REQUEST RECORD TYPE
        Id rtSalesCredNote = financeRequestRecordTypeInfo.get('Sales Credit Note Request').getRecordTypeId();
        
        //INSERT TEST FINANCE REQUEST RECORD
        AH_Finance_Request__c fr = new AH_Finance_Request__c();
        fr.RecordTypeId = rtSalesCredNote;
        fr.Tax_Amount__c = 10;
        return fr;
    }
    
    //===========================================================================================================================
    // Create Finance Request to SIN Line Item.  Added per NICC-030091
    // ==========================================================================================================================      
    public static AH_Finance_Request_to_SIN_Line_Item__c createFinanceRequestToSINLineItem(Id sinLI, Id fRequest)
    {   
        AH_Finance_Request_to_SIN_Line_Item__c fToSin = new AH_Finance_Request_to_SIN_Line_Item__c();
        fToSin.Sales_Invoice_Line_Item__c = sinLI;
        fToSin.Finance_Request__c = fRequest;
        fToSin.Requested_Credit_Amount__c = 100; 
        return fToSin;
    }
    
    //===========================================================================================================================
    // Create Finance Request to SIN Line Item.  Added per NICC-030091
    // ==========================================================================================================================      
    public static AH_Manual_Credit_Lines__c createManualCreditLines(Id fRequest)
    {   
        AH_Manual_Credit_Lines__c mc = new AH_Manual_Credit_Lines__c();
        mc.Finance_Request__c = fRequest;
        mc.Requested_Credit_Amount__c = 100; 
        return mc;
    }
    
    
    
    
    
    
    
    
    // ========================================================================================================
    //      IHG CRS INTEGRATION WIN@PROACH TO SERVICE CUSTOM SETTINGS
    // ========================================================================================================
    
    public static ServiceNowIncidentSettings__c createServiceNowIncidentSettings()
    {
        
        Account a = createTestAccount(1);
        a.Name = 'IHG TEST ACCOUNT';
        insert a;
        
        ServiceNowIncidentSettings__c incidentSettings = new ServiceNowIncidentSettings__c();
        incidentSettings.Name = 'Default';
        incidentSettings.ServiceNow_Incident_Case_Record_Type__c = 'CRS Incident';
        incidentSettings.Attachment_Endpoint__c = 'https://ihgsndev.service-now.com/api/now/attachment';
        incidentSettings.Integration_UserId__c= '00517000001YWXyAAO';
        incidentSettings.Integration_Username__c= 'ihg_servicenow@newmarketinc.com.winaproach';
        incidentSettings.ServiceNow_Password__c = '3bPWPSER1ggC';
        incidentSettings.SerrviceNow_Username__c = 'integration_amadeus';
        incidentSettings.Incident_Endpoint__c = 'https://ihgsndev.service-now.com/api/now/table/incident';
        incidentSettings.ImportSet_Endpoint__c = 'https://ihgsndev.service-now.com/api/now/import/u_integ_amadeus_incidents';
        incidentSettings.Max_Count_To_Resend_Failed_Message__c = 10; //ADDED ON 3/30/2017 PER NICC-021667
        incidentSettings.Resend_Failed_Message_Interval__c = 1; //ADDED ON 3/30/2017 PER NICC-021667
        incidentSettings.AccountId__c = a.Id;
        return incidentSettings;
        
    }
    
    public static List<ServiceNow_Incident_Severity_Mapping__c> createIncidentSeverityMapping()
    {
        List<ServiceNow_Incident_Severity_Mapping__c> severityMappings = new List<ServiceNow_Incident_Severity_Mapping__c>();
        ServiceNow_Incident_Severity_Mapping__c incidentSeverityMapping = new ServiceNow_Incident_Severity_Mapping__c();
        incidentSeverityMapping.Name = '2';
        incidentSeverityMapping.ServiceNow_Mapped_Option__c = '3';
        severityMappings.add(incidentSeverityMapping);
        
        incidentSeverityMapping = new ServiceNow_Incident_Severity_Mapping__c();
        incidentSeverityMapping.Name = '1';
        incidentSeverityMapping.ServiceNow_Mapped_Option__c = '1';
        severityMappings.add(incidentSeverityMapping);
        return severityMappings;
    }
    
    public static List<ServiceNow_Incident_Status_Mapping__c> createSNIncidentStatusMapping()
    {
        List<ServiceNow_Incident_Status_Mapping__c> incidentStatusMappingList = new List<ServiceNow_Incident_Status_Mapping__c>();
        ServiceNow_Incident_Status_Mapping__c incidentStatusMapping = new ServiceNow_Incident_Status_Mapping__c();
        incidentStatusMapping.Name = 'New';
        incidentStatusMapping.ServiceNow_Mapped_Option__c = 'New';
        incidentStatusMappingList.add(incidentStatusMapping);
        incidentStatusMapping = new ServiceNow_Incident_Status_Mapping__c();
        incidentStatusMapping.Name = 'Open';
        incidentStatusMapping.ServiceNow_Mapped_Option__c = 'On Hold';
        incidentStatusMappingList.add(incidentStatusMapping);
        return incidentStatusMappingList;
    }
    
    public static ServiceNow_Pending_Code_Mapping__c createPendingCodeMapping()
    {
        ServiceNow_Pending_Code_Mapping__c pendingCode = new ServiceNow_Pending_Code_Mapping__c();
        pendingCode.Name = 'Customer Question';
        pendingCode.ServiceNow_Mapped_Option__c = 'Awaiting Customer';
        return pendingCode;
    }
    
    public static WinaproachIncidentSettings__c createWinaproachIncidentSettings()
    {
        WinaproachIncidentSettings__c winSettings = new WinaproachIncidentSettings__c();
        winSettings.Endpoint__c = 'https://aproach.amadeus.net/aproach/webserviceDEV/services/AproachWebServices';
        winSettings.Integration_Username__c = 'winaproach.user@newmarketinc.com.winaproach';
        winSettings.Max_Count_To_Resend_Failed_Message__c = 1;
        winSettings.Password__c = 'asdfsdfasdf';
        winSettings.Refresh_Interval__c = 30;
        winSettings.Resend_Failed_Message_Interval__c = 0;
        winSettings.Task_Record_Type__c = 'Amadeus Parallel Investigation';
        winSettings.Username__c = 'xnewmarket';
        winSettings.Name = 'Default';
        return winSettings;
    }
    
    public static Winaproach_Incident_Case_Record_Type__c createIncidentCaseRecordType()
    {
        Winaproach_Incident_Case_Record_Type__c niRecType = new Winaproach_Incident_Case_Record_Type__c();
        niRecType.Record_Type__c = 'CRS Incident';
        niRecType.Attachment_Size_Limit__c = 6000000;
        niRecType.name = 'Default';
        return niRecType;
    }
    
    public static WinaproachIncidentSeverityMapping__c createWinaproachIncidentSeverityMapping()
    {
        WinaproachIncidentSeverityMapping__c wSeverity = new WinaproachIncidentSeverityMapping__c();
        wSeverity.X1__c = '1';
        wSeverity.X2__c = '2';
        wSeverity.X2_Urgent__c = '2';
        wSeverity.X3__c = '3';
        wSeverity.X4__c = '4';
        wSeverity.name = 'Default';
        return wSeverity;
    }
    
    public static WinaproachIncidentStatusMapping__c createIncidentStatusMapping()
    {       
        WinaproachIncidentStatusMapping__c wStatus = new WinaproachIncidentStatusMapping__c();
        wStatus.Acknowledged__c = 'AC';
        wStatus.Assigned__c = 'AS';
        wStatus.Closed_as_recovered__c = 'CS';
        wStatus.Closed_as_rejected__c = 'CI';
        wStatus.Closed_as_withdrawn__c = 'CW';
        wStatus.Open__c = 'AA';
        wStatus.Pending_Master_Recovery__c = 'AD';
        wStatus.Pending_Vendor__c = 'AN';
        wStatus.Recovered__c = 'SU';
        wStatus.Rejected__c = 'AX';
        wStatus.Rejected_PCP__c = 'AX'; //NICC-026774
        wStatus.name = 'Default';
        wStatus.Verified_as_recovered__c = 'SL';
        wStatus.Returned_to_Customer__c = 'AX';
        wStatus.Returned_and_closed__c = 'CS';
        return wStatus;
    }
    
    public static WinaproachIncidentUrgencyMapping__c createUrgencyMapping()
    {
        WinaproachIncidentUrgencyMapping__c wUrgency = new WinaproachIncidentUrgencyMapping__c();
        wUrgency.X1__c = 'Y';
        wUrgency.X2__c = 'N';
        wUrgency.X2_Urgent__c = 'Y';
        wUrgency.X3__c = 'N';
        wUrgency.X4__c = 'N';
        wUrgency.name = 'Default';
        return wUrgency;
    }
    
    public static WinaproachIncidentCauseIdMapping__c createCauseIdMapping()
    {
        WinaproachIncidentCauseIdMapping__c causeId = new WinaproachIncidentCauseIdMapping__c();
        causeId.Application__c = 'APP';
        causeId.Change_request__c = 'CR';
        causeId.Claims_SMC_only__c = 'CLM';
        causeId.Code_issues__c = 'CODE';
        causeId.Configuration__c =  'CONFIG';
        causeId.Corruption_missing_or_invalid_data__c = 'DATA';
        causeId.Data_security__c = 'SECD';
        causeId.Database_corrupt__c = 'DBA';
        causeId.Documentation__c = 'DOC';
        causeId.Environmental_cause_Air_Cond_UPS_etc__c = 'ENVIRON';
        causeId.EUM_SMC_only__c = 'EUM';
        causeId.External_3rd_parties__c = 'EXTERN';
        causeId.Global_core_database__c = 'GCD';
        causeId.Hardware_part__c = 'HWPART';
        causeId.Hardware_problems_power_cabling_etc__c = 'PHYERR';
        causeId.Implementation_error__c = 'IMPL';
        causeId.Infrastructure__c = 'INFRA';
        causeId.JCL_error__c = 'JCL';
        causeId.Line__c = 'LINE';
        causeId.Malware__c = 'MALWR';
        causeId.Not_diagnosed__c = 'NOTDIA';
        causeId.Not_reproducable__c = 'NOTREP';
        causeId.Other__c = 'OTHER';
        causeId.Performance__c = 'PERF';
        causeId.Physsecurity__c = 'SECP';
        causeId.PNR_discrepancy_SMC_only__c = 'PNRDIS';
        causeId.Procedures__c = 'PROC';
        causeId.User_error__c = 'USER';
        causeId.Program__c = 'PGM';   
        causeId.name = 'Default';
        return causeId;
    }
    
    public static WinaproachIncidentResolutionCodeMapping__c createWinResolutionCodeMapping()
    {
        WinaproachIncidentResolutionCodeMapping__c ResolutionCode = new WinaproachIncidentResolutionCodeMapping__c();
        ResolutionCode.Code_Correction__c = 'CODE';
        ResolutionCode.Environment__c =  'ENVIRON';
        ResolutionCode.name = 'Default';
        return ResolutionCode;
    }
    
    public static WinaproachIncidentRejectedReasonCode__c createWinRejectedCode()
    {
        WinaproachIncidentRejectedReasonCode__c RejectedReasonCode = new WinaproachIncidentRejectedReasonCode__c();
        RejectedReasonCode.Change_required__c = 'C';
        RejectedReasonCode.Functional_Setting__c =  'F';
        RejectedReasonCode.name = 'Default';
        return RejectedReasonCode;
    }
    
    public static WinaproachIncidentInvestigationMapping__c createWinInvestigation()
    {
        WinaproachIncidentInvestigationMapping__c InvestigationMapping = new WinaproachIncidentInvestigationMapping__c();
        InvestigationMapping.SMC_Investigation_Completed__c = 'SE';
        InvestigationMapping.Name = 'Default';
        return InvestigationMapping;
    }
    
    public static Winaproach_Work_Order_Case_Record_Type__c createWorkOrderCaseRecordType()
    {
        Winaproach_Work_Order_Case_Record_Type__c workOrder = new Winaproach_Work_Order_Case_Record_Type__c();
        workOrder.Name = 'Default';
        workOrder.Attachment_Size_Limit__c = 6000000;
        workOrder.Record_Type__c = 'CRS Work Order';
        return workOrder;
    }
    
    public static WinaproachWorkOrderStatusMapping__c createWorkOrderStatusMapping()
    {
        WinaproachWorkOrderStatusMapping__c statusMapping = new WinaproachWorkOrderStatusMapping__c();
        statusMapping.Name = 'Default';
        statusMapping.Acknowledged__c = 'AC';
        statusMapping.Assigned__c = 'AA';
        statusMapping.Closed__c = 'SV';
        statusMapping.Closed_as_rejected__c = 'SI';
        statusMapping.Implemented__c = 'AL';
        statusMapping.Pending__c = 'PE';
        statusMapping.Rejected__c = 'AX';
        return statusMapping;
    }
    
    public static Winaproach_System_Affected__c creteSystemAffected()
    {
        Winaproach_System_Affected__c winSysAffected = new Winaproach_System_Affected__c();      
        winSysAffected.Name = 'Disaster Recovery';
        winSysAffected.System_Category__c = 'D';
        return winSysAffected;
    }
    
    public static Winaproach_PI_Activity_Field_Mapping__c cretePI_Activity_Field_Mapping()
    {
        Winaproach_PI_Activity_Field_Mapping__c Activity_Field = new Winaproach_PI_Activity_Field_Mapping__c();      
        Activity_Field.Name = 'Diagnosis';
        Activity_Field.Activity_Short_Name__c = 'D';
        return Activity_Field;
    }
    
    public static void createTestWinaproachServiceNowSettings()
    {
        
        User u = createTestUser(4321, 'System Administrator'); 
        insert u;
        
        List<User> lstUserAssert = new List<User>([SELECT Id FROM User WHERE Alias = 'user4321']);
        system.assertEquals(1, lstUserAssert.Size());
        
        system.runAs(u) 
        {            
            
            // CHECK FOR EXISTANCE OF CUSTOM SETTINGS TO PREVENT ERROR RAISED WHEN ANOTHER TEST CLASS HAS CREATED THEM ALREADY
            WinaproachIncidentSettings__c winAproachCS = WinaproachIncidentSettings__c.getValues('Default'); 
            
            if (winAproachCS != null) {return;}
            
            // CREATE TEST Win@proach CUSTOM SETTINGS 
            WinaproachIncidentSettings__c winSettings = createWinaproachIncidentSettings();        
            insert winSettings;

            Winaproach_Incident_Case_Record_Type__c niRecType = createIncidentCaseRecordType();
            insert niRecType;

            WinaproachIncidentSeverityMapping__c wSeverity = createWinaproachIncidentSeverityMapping();
            insert wSeverity;
                
            WinaproachIncidentStatusMapping__c wStatus = createIncidentStatusMapping();
            insert wStatus;
            
            WinaproachIncidentUrgencyMapping__c wUrgency = createUrgencyMapping();
            insert wUrgency;

            WinaproachIncidentCauseIdMapping__c causeId = createCauseIdMapping();
            insert causeId;

            WinaproachIncidentResolutionCodeMapping__c ResolutionCode = createWinResolutionCodeMapping();
            insert ResolutionCode;

            WinaproachIncidentRejectedReasonCode__c RejectedReasonCode = createWinRejectedCode();
            insert RejectedReasonCode;
            
            WinaproachIncidentInvestigationMapping__c InvestigationMapping = createWinInvestigation();
            insert InvestigationMapping;
            
            Winaproach_PI_Activity_Field_Mapping__c PI_Activity_Field_Mapping = cretePI_Activity_Field_Mapping();
            insert PI_Activity_Field_Mapping;

            Winaproach_Work_Order_Case_Record_Type__c WorkOrderCaseRecordType = createWorkOrderCaseRecordType();
            insert WorkOrderCaseRecordType;
            
            WinaproachWorkOrderStatusMapping__c WorkOrderStatusMapping = createWorkOrderStatusMapping();
            insert WorkOrderStatusMapping; 
            
            Winaproach_System_Affected__c SystemAffected = creteSystemAffected();
            insert SystemAffected;
            
            // CREATE TEST ServiceNow CUSTOM SETTINGS 
            ServiceNowIncidentSettings__c incidentSettings = createServiceNowIncidentSettings();
            insert incidentSettings;

            List<ServiceNow_Incident_Severity_Mapping__c> lstSeverityMappings = createIncidentSeverityMapping();
            database.insert(lstSeverityMappings);
            
            List<ServiceNow_Incident_Status_Mapping__c> lstIncidentStatusMapping = createSNIncidentStatusMapping();
            database.insert(lstIncidentStatusMapping);

            ServiceNow_Pending_Code_Mapping__c pendingCode = createPendingCodeMapping();
            insert pendingCode;
            
            Case_Record_Type_Status__c recType = new Case_Record_Type_Status__c();
            recType.Name = 'CRS Incident';
            recType.Status__c = 'New';
            insert recType;
            
        }

    }

    // ============================================================================================================================
    //  APTTUS TEST RECORD CREATION METHODS
    // ============================================================================================================================    

    public static Apttus__APTS_Agreement__c createTestApttusAgreement(Integer iRecordNumber, Id accountID, Id opportunityID, Id pricebookID)
    {
        Apttus__APTS_Agreement__c aa = new Apttus__APTS_Agreement__c();
        aa.Name = 'Apttus Agreement Test ' + String.valueOf(iRecordNumber); 
        aa.Apttus__Account__c = accountID;
        aa.Apttus__Related_Opportunity__c = opportunityID;
        aa.APTS_Legal_Entity__c = 'Amadeus Hospitality Americas, Inc.';
        aa.CurrencyIsoCode = 'USD';
        return aa;     
    } 

    public static Apttus__AgreementLineItem__c createTestAgreementLineItem(string strName, integer iItemSequence, integer iLineNumber, Id agreementID, Id product2ID)
    {
        Apttus__AgreementLineItem__c ali = new Apttus__AgreementLineItem__c();        
        ali.Apttus__Description__c = strName;
        ali.Apttus_CMConfig__ItemSequence__c = iItemSequence;
        ali.Apttus_CMConfig__LineNumber__c = iLineNumber;
        ali.Apttus__AgreementId__c = agreementID;
        ali.Apttus__ProductId__c = product2ID;
        ali.Apttus__Quantity__c = 1;         
        ali.Apttus__ListPrice__c = 1.00;             
        ali.Apttus__ExtendedPrice__c = 2.00;             
        ali.Apttus__NetPrice__c = 2.00; 
        ali.CurrencyIsoCode = 'USD';
        return ali;     
    }        
       
    // ============================================================================================================================
    //  CHANNEL_ORDERS TEST RECORD CREATION METHODS
    // ============================================================================================================================
    
    public static CHANNEL_ORDERS__Customer__c CreateCustomer(String orgId)
    {
        CHANNEL_ORDERS__Customer__c CO_cst = new CHANNEL_ORDERS__Customer__c();
        CO_cst.CHANNEL_ORDERS__Customer_City__c = 'Portsmouth';
        CO_cst.CHANNEL_ORDERS__Customer_Company_Name__c = 'Apex Test';
        CO_cst.CHANNEL_ORDERS__Customer_Country__c = 'US';
        CO_cst.CHANNEL_ORDERS__Customer_Org_ID__c = orgId;
        CO_cst.CHANNEL_ORDERS__Customer_State__c = 'NH';
        CO_cst.CHANNEL_ORDERS__Customer_Street__c = '75 New Hampshire Ave';
        CO_cst.CHANNEL_ORDERS__Customer_ZIP_Postal_Code__c  = '03801';
        return CO_cst;
    }    
    
    public static CHANNEL_ORDERS__Partner_Product_Catalog__c CreateProductCatalog(Id termsId, String ProductSKU)
    {
        CHANNEL_ORDERS__Partner_Product_Catalog__c product = new CHANNEL_ORDERS__Partner_Product_Catalog__c();
        product.Name = 'Apex Test Product';
        product.CHANNEL_ORDERS__Product_ID__c = ProductSKU;
        product.CHANNEL_ORDERS__Partner_Contract_Terms__c = termsId;       
        if (ProductSKU.Contains('EMD'))
        {
            product.CHANNEL_ORDERS__PNR__c = 10.00;
            product.CHANNEL_ORDERS__Pricing_Type__c = 'PNR';
            product.CHANNEL_ORDERS__Floor_Price__c = 10.00;
            product.CHANNEL_ORDERS__Pricing_Unit__c = 'User';
        }
        else
        {
            product.CHANNEL_ORDERS__Pricing_Type__c = 'FIXED';
            product.CHANNEL_ORDERS__Fixed_Price__c = 10.00;
            product.CHANNEL_ORDERS__Floor_Price__c = 10.00;
            product.CHANNEL_ORDERS__Pricing_Unit__c = 'User';
        }
        return product;   
    }
  
    public static CHANNEL_ORDERS__Partner_Contract_Terms__c CreateContract()
    {
        CHANNEL_ORDERS__Partner_Contract_Terms__c contractTerms = new CHANNEL_ORDERS__Partner_Contract_Terms__c();
        contractTerms.Name = 'Apex Test Term';
        contractTerms.CHANNEL_ORDERS__Partner_API_Key__c = '2';
        contractTerms.Active__c  = true;
        return contractTerms;
    }
   
    public static CHANNEL_ORDERS__Service_Order__c createTestCO_ServiceOrder()
    {
        CHANNEL_ORDERS__Service_Order__c retCOSO = new CHANNEL_ORDERS__Service_Order__c();
        return retCOSO;
    }    
    
    
    // ========================================================================================================
    //      SCMC TEST RECORD CREATION METHODS
    // ========================================================================================================
    public static void createSCMCurrency() 
    {
        SCMC__Currency_Master__c curr = new SCMC__Currency_Master__c();
        curr.SCMC__Active__c = true;
        curr.Name = 'USD';
        curr.SCMC__Number_of_decimals__c = 2;
        curr.SCMC__Corporate_Currency__c = true;
        insert curr;
    }

    // Create Inventory Control Point (ICP)
    public static SCMC__ICP__c createICP(String icpName) 
    {
        SCMC__ICP__c icp = new SCMC__ICP__c();
        icp.Name = icpName;
        return icp;
    }

    // Create Warehouse
    public static SCMC__Warehouse__c createWarehouse(String warehouseName, Id icpId) 
    {
        SCMC__Warehouse__c warehouse = new SCMC__Warehouse__c();
        warehouse.SCMC__ICP__c = icpId;
        warehouse.Name = warehouseName;
        return warehouse;
    }

    // Create Supplier Site
    public static SCMC__Supplier_Site__c createSupplierSite(String supplierSiteName, Id accountId) 
    {
        SCMC__Supplier_Site__c supplierSite = new SCMC__Supplier_Site__c();
        supplierSite.SCMC__Account__c = accountId;
        supplierSite.Name = supplierSiteName;
        supplierSite.SCMC__E_Mail__c = 'test@test.com';
        supplierSite.SCMC__Active__c = true;
        return supplierSite;
    }

    // Create Requisition with Description Lines
    public static SCMC__Requisition__c createRequisition(Id warehouseId, Id supplierSiteId) 
    {
        SCMC__Requisition__c req = new SCMC__Requisition__c();
        req.SCMC__Warehouse__c = warehouseId;
        req.SCMC__Supplier_Site__c = supplierSiteId;
        req.SCMC__Buyer__c = UserInfo.getUserId();
        req.Company__c = 'Newmarket US';
        req.Line_of_Business_Dimension_2__c = 'Newmarket Traditional';
        return req;
    }

    // Create Description Requisition Lines
    public static SCMC__Requisition_Line_Item__c createRequisitionLines(Id warehouseId, Id supplierSiteId, Id reqid, Id reqlinetypeid) 
    {
        SCMC__Requisition_Line_Item__c reqline = new SCMC__Requisition_Line_Item__c();
        reqline.RecordtypeId = reqlinetypeid;
        reqline.SCMC__Warehouse__c = warehouseId;
        reqline.SCMC__Quantity__c = 2;
        reqline.SCMC__Requisition__c = reqid;
        reqline.SCMC__Budget__c = 100;
        reqline.Unit_Cost__c = 100;
        reqline.SCMC__Suggested_Supplier__c = supplierSiteId;
        reqline.General_Ledger_Account_list__c = '60701201 - JOY GANG EXPENSES';
        reqline.Line_of_Business_Dimension_2__c = 'Newmarket Traditional';
        reqline.Department_Dimension_3__c = '110 - HUMAN RESOURCES';
        return reqline;
    }

    // ========================================================================================================
    //      PSE TEST RECORD CREATION METHODS
    // ========================================================================================================

    // CREATE A TEST REGION
    public static pse__Region__c createTestRegion(Integer iRecordNumber, String regionName)
    {
        pse__Region__c r = new pse__Region__c();
        r.Name = regionName + iRecordNumber;
        return r;
    }
    
    // CREATE A TEST PRACTICE
    public static pse__Practice__c createTestPractice(Integer iRecordNumber, String practiceName)
    {
        pse__Practice__c p = new pse__Practice__c();
        p.Name = practiceName + iRecordNumber;
        return p;
    }
    
    // CREATE A TEST PSA SCHEDULE
    public static pse__Schedule__c createTestSchedule(Date dtStart, Date dtEnd)
    {
        pse__Schedule__c s = new pse__Schedule__c();
        s.pse__Start_Date__c = dtStart;
        s.pse__End_Date__c = dtEnd;
        s.pse__Monday_Hours__c = 8;
        s.pse__Tuesday_Hours__c = 8;
        s.pse__Wednesday_Hours__c = 8;
        s.pse__Thursday_Hours__c = 8;
        s.pse__Friday_Hours__c = 8;        
        return s;
    }
    
    // CREATE A TEST PSA PERMISSION CONTROL
    public static pse__Permission_Control__c createTestPermissionControl(Id userId)
    {
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.pse__User__c = userId;
        return pc;
        // FIELD REFERENCES ====================================
        // pc.pse__Start_Date__c = Date;
        // pc.pse__End_Date__c = Date;
        // SWITCHES ============================================
        // pc.pse__Billing__c = false;                          // This checkbox governs the User's ability to generate and release Billing Events for Projects belonging to specified Regions/Practices/Groups, and to edit Billing-related fields (Billed checkbox and Billing Event Item) for Resources' business records.
        // pc.pse__Cascading_Permission__c = false;             // Checking this box for Permission Controls associated with a hierarchy (e.g. Region, Practice, or Group) means that the Permission also applies to (Resources belonging to) all nodes lower in the hierarchy, in addition to the specified node.
        // pc.pse__Expense_Entry__c = false;                    // This checkbox governs the User's ability to enter/edit Expenses and Expense Reports for Resources other than their own.
        // pc.pse__Expense_Ops_Edit__c = false;                 // This checkbox governs the User's ability to edit Expenses and Expense Reports for Resources after they have been approved but before they have been billed.
        // pc.pse__Forecast_Edit__c = false;                    // Allowed to perform editing on the Forecasts page for the Region/Practice/Group
        // pc.pse__Forecast_View__c = false;                    // Allowed to view the Forecasts page for the Region/Practice/Group
        // pc.pse__Invoicing__c = false;                        // This checkbox governs the User's ability to to edit Invoicing-related fields (Invoiced checkbox, Invoice Date, Invoice Number) for Project's business records.
        // pc.pse__Edit_Task_Manager__c = false;                // Indicates whether the selected user can use Project Task Gantt in edit mode if they are not the project manager of the selected project.
        // pc.pse__View_Task_Manager__c = false;                // Indicates whether the selected user can use Task Manager in read-only mode if they are not the project manager of the selected project.
        // pc.pse__Compare_Project_Version__c = false;          // Grants permission to the user to compare Project Versions.
        // pc.pse__Create_Project_Version__c = false;           // Grants permission to the user to create Project Versions.
        // pc.pse__Delete_Project_Version__c = false;           // Grants permission to the user to delete Project Versions.
        // pc.pse__Resource_Request_Entry__c = false;           // This checkbox governs the User's ability to enter/edit Resource Requests for specified Regions/Practices/Groups.
        // pc.pse__Skills_And_Certifications_Entry__c = false;  // This checkbox governs the User's ability to enter/edit Skills and Certifications for Resources other than their own.
        // pc.pse__Skills_And_Certifications_View__c = false;   // This checkbox governs the User's ability to view Expenses for Resources other than their own. If a user has Edit permission, they implicitly also have View permission.
        // pc.pse__Staffing__c = false;                         // This checkbox governs the User's ability to staff Resources from specified Regions/Practices/Groups.
        // pc.pse__Team_Create__c = false;                      // If selected, grants permission to the user to create a team.
        // pc.pse__Team_Edit__c = false;                        // Grants permission for the user to edit the indicated team if the user is not the team owner.
        // pc.pse__Team_View__c = false;                        // Grants permission for the user to view the indicated team in read-only mode if the user is not the team owner.
        // pc.pse__Timecard_Entry__c = false;                   // This checkbox governs the User's ability to enter/edit Timecards for Resources other than their own.
        // pc.pse__Timecard_Ops_Edit__c = false;                // This checkbox governs the User's ability to edit Timecards for Resources after they have been approved but before they have been billed.
        // LOOKUPS =============================================
        // pc.pse__Group__c = Lookup(Group);                    // This is the Group (pse__Grp__c) containing Resources that are the target of the specified action(s) - e.g. delegated Timecard Entry on behalf of Resources in this Group.
        // pc.pse__Practice__c = Lookup(Practice);              // This is the Practice (pse__Practice__c) containing Resources that are the target of the specified action(s) - e.g. delegated Timecard Entry on behalf of Resources in this Practice.
        // pc.pse__Project__c = Lookup(Project);                // This is the Project (pse__Proj__c) containing Assignments for Resources that are the target of the specified action(s) - e.g. delegated Timecard Entry on behalf of Resources in this Project, only in relation to the Project.     
        // pc.pse__Region__c = Lookup(Region);                  // This is the Region (pse__Region__c) containing Resources that are the target of the specified action(s) - e.g. delegated Timecard Entry on behalf of Resources in this Region.
        // pc.pse__Resource__c = Lookup(Contact);               // This is the Resource (Contact) who is the target of the specified action(s) - e.g. delegated Timecard Entry on behalf of this Resource.
        // pc.pse__Team__c = Lookup(Team);                      // This is the Team (pse__Team__c) that is the target of the specified action(s) – e.g. Team View on behalf of this User. 
    }
    
    // CREATE A TEST PSA WORK CALENDAR
    public static pse__Work_Calendar__c createTestWorkCalendar(String strCalendarName)
    {
        pse__Work_Calendar__c w = new pse__Work_Calendar__c();
        w.Name = strCalendarName;
        return w;
    }
        
    // CREATE A TEST PSA GROUP
    public static pse__Grp__c createTestPSEGroup(string strGroupName)
    {
        pse__Grp__c grp = new pse__Grp__c();
        grp.Name = strGroupName;
        /*
        grp.PSE__ACTION_UPDATE_CURRENT_TIME_PERIOD__C = FALSE;
        grp.PSE__BILLABLE_EXTERNAL_HOURS__C = 0;
        grp.PSE__BILLABLE_INTERNAL_HOURS__C = 0;
        grp.PSE__BILLED__C = 0;
        grp.PSE__BILLINGS__C = 0;
        grp.PSE__BOOKINGS__C = 0;
        grp.PSE__CREDITED_NON_BILLABLE_INTERNAL_HOURS__C = 0;
        grp.PSE__CURRENT_TIME_PERIOD_END_DATE__C = 9/30/2018;
        grp.PSE__CURRENT_TIME_PERIOD__C = a2o32000002XlhuAAC;
        grp.PSE__DEFAULT_WORK_CALENDAR__C = a3260000000GmbRAAS;
        grp.PSE__EXCLUDED_HOURS__C = 0;
        grp.PSE__EXPENSE_BUDGET__C = 0;
        grp.PSE__EXPENSE_COSTS__C = 0;
        grp.PSE__EXTERNAL_COSTS__C = 0;
        grp.PSE__GROUP_HEAD__C = 0036000000orYJ8AAM;
        grp.PSE__GROUP_ID_CHAIN__C = a2H320000009PtbEAE,a2H320000009PtCEAU;
        grp.PSE__GROUP_NAME_CHAIN__C = Sales and Catering->Amadeus Hospitality;
        grp.PSE__HIERARCHY_DEPTH__C = 1;
        grp.PSE__HISTORICAL_UTILIZATION_BILLABLE_HOURS__C = 0;
        grp.PSE__HISTORICAL_UTILIZATION_CALENDAR_HOURS__C = 0;
        grp.PSE__HISTORICAL_UTILIZATION__C = 0;
        grp.PSE__INACTIVE_PROJECT_BACKLOG__C = 0;
        grp.PSE__INCLUDE_IN_FORECASTING__C = TRUE;
        grp.PSE__INTERNAL_BUDGET__C = 0;
        grp.PSE__INTERNAL_COSTS__C = 0;
        grp.PSE__INVOICED__C = 0;
        grp.PSE__MARGIN__C = 0;
        grp.PSE__NON_BILLABLE_EXTERNAL_HOURS__C = 0;
        grp.PSE__NON_BILLABLE_INTERNAL_HOURS__C = 0;
        grp.PSE__OTHER_COSTS__C = 0;
        grp.PSE__PARENT_GROUP__C = a2H320000009PtCEAU;
        grp.PSE__PASS_THROUGH_BILLINGS__C = 0;
        grp.PSE__PLANNED_BILLINGS__C = 0;
        grp.PSE__PLANNED_BOOKINGS__C = 0;
        grp.PSE__PLANNED_EXTERNAL_COSTS__C = 0;
        grp.PSE__PLANNED_INTERNAL_COSTS__C = 0;
        grp.PSE__PLANNED_MARGIN__C = 0;
        grp.PSE__PLANNED_REVENUE__C = 0;
        grp.PSE__PLANNED_UTILIZATION__C = 0;
        grp.PSE__PRE_BILLED__C = 0;
        grp.PSE__REVENUE__C = 0;
        grp.PSE__SCHEDULED_BACKLOG_CALCULATED_DATE__C = 
        grp.PSE__SCHEDULED_BACKLOG_END_DATE__C = 
        grp.PSE__SCHEDULED_MILESTONE__C = 0;
        grp.PSE__SCHEDULED_TIME__C = 0;
        grp.PSE__SCHEDULED_UTILIZATION_BILLABLE_HOURS__C = 0;
        grp.PSE__SCHEDULED_UTILIZATION_CALENDAR_HOURS__C = 0;
        grp.PSE__SCHEDULED_UTILIZATION__C = 0;
        grp.PSE__TOP_LEVEL_GROUP__C = a2H320000009PtCEAU;
        grp.PSE__TOTAL_COSTS__C = 0;
        grp.PSE__TOTAL_TIME_PERIOD_HOURS__C = 
        grp.PSE__TOTAL_UTILIZATION__C = 0;
        grp.PSE__UNSCHEDULED_BACKLOG__C = 0;
        grp.PSE__UTILIZATION_CALCULATION_DATE__C = 
        grp.PSE__UTILIZATION_ELAPSED_HOURS__C = 
        grp.PSE__UTILIZATION_LAST_CALCULATION_DATE__C = 
        grp.PSE__UTILIZATION_OVER_FULL_TIME_PERIOD__C = 
        grp.PSE__UTILIZATION_PERIOD_END_DATE__C = 
        grp.PSE__UTILIZATION_PERIOD_START_DATE__C = 
        grp.PSE__UTILIZATION__C = 
        grp.PSE__ACTUALS_LAST_UPDATE_DATE__C = 0;
        grp.PSE__ACTUALS_LAST_UPDATED_BY__C = 2018-09-01T07:00:31.000Z;
        grp.PSE__BACKLOG_LAST_UPDATE_DATE__C = 00530000000xjfhAAA;
        grp.PSE__BACKLOG_LAST_UPDATED_BY__C = 2018-09-01T07:00:31.000Z;
        grp.PSE__HIST_SCH_UTILIZATION_BILLABLE_HOURS__C = 00530000000xjfhAAA;
        grp.PSE__HIST_SCH_UTILIZATION_CREDITED_HOURS__C = 0;
        grp.PSE__HIST_SCH_UTILIZATION_EXCLUDED_HOURS__C = 0;
        grp.PSE__HIST_SCH_UTILIZATION_NON_BILLABLE_HRS__C = 0;
        grp.PSE__HISTORICAL_UTILIZATION_CREDITED_HOURS__C = 0;
        grp.PSE__HISTORICAL_UTILIZATION_EXCLUDED_HOURS__C = 0;
        grp.PSE__HISTORICAL_UTILIZATION_NON_BILLABLE_HRS__C = 0;
        grp.PSE__HISTORICAL_UTILIZATION_TARGET_ATTAINMENT__C = 0;
        grp.PSE__HISTORICAL_UTILIZATION_TARGET_HOURS__C = 0;
        grp.PSE__HISTORICAL_UTILIZATION_TARGET__C = 0;
        grp.PSE__PLAN_LAST_UPDATE_DATE__C = 0;
        grp.PSE__PLAN_LAST_UPDATED_BY__C = 2018-09-01T07:00:31.000Z;
        grp.PSE__SCHEDULED_UTILIZATION_CREDITED_HOURS__C = 00530000000xjfhAAA;
        grp.PSE__SCHEDULED_UTILIZATION_EXCLUDED_HOURS__C = 0;
        grp.PSE__SCHEDULED_UTILIZATION_NON_BILLABLE_HRS__C = 0;
        grp.PSE__SCHEDULED_UTILIZATION_TARGET_ATTAINMENT__C = 0;
        grp.PSE__SCHEDULED_UTILIZATION_TARGET_HOURS__C = 0;
        grp.PSE__SCHEDULED_UTILIZATION_TARGET__C = 0;
        grp.PSE__UTILIZATION_LAST_UPDATE_DATE__C = 0;
        grp.PSE__UTILIZATION_LAST_UPDATED_BY__C = 2018-09-01T07:00:31.000Z;
        grp.PSE__UTILIZATION_TARGET_ATTAINMENT__C = 00530000000xjfhAAA;
        grp.PSE__UTILIZATION_TARGET_HOURS__C = 0;
        grp.PSE__UTILIZATION_TARGET__C = 0;
        grp.PSE__HIST_SCH_UTILIZATION_HELD_HOURS__C = 0;
        grp.PSE__SCHEDULED_UTILIZATION_HELD_HOURS__C = 0;
        grp.FFPSAI__OWNERCOMPANY__C = 0;
        */        
        return grp;
    }
    
    // CREATE A TEST PSA PROJECT 
    public static pse__Proj__c createTestProject(Integer iRecordNumber, String projectName, pse__Region__c region, pse__Practice__c practice, String projectStage, Opportunity opp)
    {
        pse__Proj__c p = new pse__Proj__c();        
        p.Name = projectName + iRecordNumber;
        p.pse__Region__c = region.Id;
        p.pse__Practice__c = practice.Id;
        p.pse__Stage__c = projectStage;        
        p.pse__Is_Active__c = true;
        p.pse__Is_Billable__c = true;
        p.pse__Allow_Timecards_Without_Assignment__c = true;
        p.pse__Allow_Expenses_Without_Assignment__c = true;
        p.pse__Project_Type__c = 'Customer Project';
        p.pse__Project_Status__c = 'Green'; 
        if (opp != null)
        {
            p.pse__Opportunity__c = opp.Id;
        }
        return p;        
    }
    
    // CREATE A TEST PSA ASSIGNMENT
    public static pse__Assignment__c createTestAssignment(Id contactId, Id scheduleId, Id projectId)
    {
        pse__Assignment__c a = new pse__Assignment__c();
        a.Name = 'Test Assignment';       
        a.pse__Is_Billable__c = true;
        a.pse__Project__c = projectId;
        a.pse__Resource__c = contactId;
        a.pse__Schedule__c = scheduleId;
        a.pse__Bill_Rate__c = 85;         
        return a;
    }
    
    // CREATE A TEST PSA MILESTONE 
    public static pse__Milestone__c createTestMilestone(String milestoneName, pse__Proj__c project, boolean cfte, boolean cfee, String milestoneType)
    {
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        
        // CREATE TEST BILLING CONTRACT                                     // NICC-028724 - New Validation Rule
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
        blgCnrct.Name = h;                                                  // NICC-025716 Prevents duplicate Billing Contract records from being created based on Billing Contract Name
        insert blgCnrct;

        // CREATE TEST ACTIVITY LINE ITEM                                   // NICC-028724 - New Validation Rule
        Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        insert actLI; 
        
        pse__Milestone__c testMilestone = new pse__Milestone__c();
        testMilestone.Name = milestoneName;
        testMilestone.pse__Project__c = project.Id;
        testMilestone.pse__Closed_for_Expense_Entry__c = cfee;
        testMilestone.pse__Closed_for_Time_Entry__c = cfte;
        testMilestone.pse__Target_Date__c = date.newInstance(2011, 12, 31);
        testMilestone.pse__Status__c = 'Draft/Tentative';
        testMilestone.Milestone_Type__c = milestoneType;
        testMilestone.Activity_Line_Item__c = actLI.Id;                     // NICC-028724 - New Validation Rule
        testMilestone.pse__Milestone_Amount__c = 1.00;                      // NICC-028724 - New Validation Rule
        return testMilestone;
        
    }

    // CREATE A TEST PSA MILESTONE 
    public static pse__Milestone__c createTestMilestoneNoALI(String milestoneName, pse__Proj__c project, boolean cfte, boolean cfee, String milestoneType)
    {

        pse__Milestone__c testMilestone = new pse__Milestone__c();
        testMilestone.Name = milestoneName;
        testMilestone.pse__Project__c = project.Id;
        testMilestone.pse__Closed_for_Expense_Entry__c = cfee;
        testMilestone.pse__Closed_for_Time_Entry__c = cfte;
        testMilestone.pse__Target_Date__c = date.newInstance(2011, 12, 31);
        testMilestone.pse__Status__c = 'Draft/Tentative';
        testMilestone.Milestone_Type__c = milestoneType;
        testMilestone.pse__Milestone_Amount__c = 1.00;                      // NICC-028724 - New Validation Rule
        return testMilestone;
        
    }    
    
    // CREATE A TEST PSA BILLING EVENT 
    public static pse__Billing_Event__c createTestBillingEvent(Id idBillingEventBatch, Id idProject)
    {
        pse__Billing_Event__c be = new pse__Billing_Event__c();
        be.pse__Billing_Event_Batch__c = idBillingEventBatch;
        be.pse__Project__c = idProject;
        return be;        
    }
    
    // CREATE A TEST PSA BILLING EVENT LINE ITEM
    public static pse__Billing_Event_Item__c createTestBillingEventItem(Id idBillingEventBatch, Id idBillingEvent, Id idProject, Id idMilestone)
    {
        pse__Billing_Event_Item__c bei = new pse__Billing_Event_Item__c();
        bei.pse__Billing_Event_Batch__c = idBillingEventBatch; 
        bei.pse__Billing_Event__c = idBillingEvent;  
        bei.pse__Project__c = idProject; 
        bei.pse__Object_Id__c = idMilestone;
        bei.pse__Category__c = 'Milestone';
        return bei;        
    }

    // CREATE A TEST PSA BILLING EVENT BATCH
    public static pse__Billing_Event_Batch__c createTestBillingEventBatch()
    {
        pse__Billing_Event_Batch__c beb = new pse__Billing_Event_Batch__c();
        return beb;        
    }
    
    // CREATE A TEST PSA EXPENSE REPORT 
    public static pse__Expense_Report__c createPSEExpenseReport(Id ResourceId, Id ProjectId)
    {
        pse__Expense_Report__c er = new pse__Expense_Report__c();
        er.Name = 'Test External Expense';
        er.pse__Resource__c = ResourceId;
        er.pse__Project__c = ProjectId;
        return er;
    }
    
    // CREATE A TEST PSA MISCELLANEOUS ADJUSTMENT 
    public static pse__Miscellaneous_Adjustment__c createMiscellaneousAdjustment(String strName, Id ProjectId)
    {
        pse__Miscellaneous_Adjustment__c ma = new pse__Miscellaneous_Adjustment__c();
        ma.Name = strName;
        ma.pse__Project__c = ProjectId;
        ma.pse__Transaction_Category__c = 'Ready-to-Bill Revenue';
        ma.pse__Amount__c = 500;
        ma.pse__Effective_Date__c = date.newInstance(2011, 11, 11);        
        return ma;
    }
    
    // CREATE TEST TIMECARD HEADER
    public static pse__Timecard_Header__c createTimecardHeader(Id idProject, Id idMilestone, Id idAssignment, Id idResource, Date dStart, Date dEnd)
    {
        pse__Timecard_Header__c tch = new pse__Timecard_Header__c();
        tch.pse__Project__c = idProject;
        tch.pse__Milestone__c = idMilestone;        
        tch.pse__Assignment__c = idAssignment; 
        tch.pse__Resource__c = idResource;
        tch.pse__Start_Date__c = dStart;
        tch.pse__End_Date__c = dEnd;        
        tch.pse__Billable__c = true;
        tch.pse__Bill_Rate__c = 100;
        tch.pse__Cost_Rate_Amount__c = 50;
        tch.pse__Monday_Hours__c = 5;
        tch.pse__Tuesday_Hours__c = 5;
        tch.pse__Project_Phase__c = 'Milestone in Progress';
        tch.pse__Status__c = 'Saved';
        tch.pse__Submitted__c = false;
        tch.pse__Approved__c = false;
        tch.pse__Include_In_Financials__c = false;     
        return tch;
    }        
    
    // ========================================================================================================
    //      FFA TEST RECORD CREATION METHODS
    // ========================================================================================================

    public static ffrr__Settings__c createSettings()
    {        
        ffrr__Settings__c ffrrS = new ffrr__Settings__c();
        ffrrS.ffrr__ActiveField__c = 'Include_in_Revenue_Recognition__c';
        ffrrS.ffrr__ActiveValue__c = 'TRUE';
        ffrrS.ffrr__Description__c = 'Name';
        ffrrS.ffrr__Object__c = 'Activity_Line_Item__c';
        ffrrS.ffrr__TotalRevenue__c = 'Total_Revenue_to_Recognize__c';
        ffrrS.ffrr__SettingsType__c = 'Actual';
        ffrrS.ffrr__TransactionLineRelationship__c = 'Activity_Line_Item__c';
        ffrrS.ffrr__IncomeStatementAccount__c = 'Revenue_Recognition_GLA__c';
        ffrrS.ffrr__BalanceSheetAccount__c = 'Deferred_Revenue_GLA__c';
        ffrrS.ffrr__Currency__c = 'CurrencyIsoCode';
        ffrrS.ffrr__IncludeActiveValue__c = 'Include';
        ffrrS.ffrr__IncludeCompletedValue__c = 'Include';
        ffrrS.ffrr__CompletedField__c = 'Include_in_Revenue_Recognition__c';
        ffrrS.ffrr__CompletedValue__c = 'true';        
        ffrrS.ffrr__EndDate__c = 'Contract_End_Date__c';
        ffrrS.ffrr__StartDate__c = 'Contract_Start_Date__c';
        
/*        
        ffrrS.ffrr__ParentSettings__c = 'Billing Contract';
        ffrrS.ffrr__PrimaryRelationship__c = 'Billing_Contract__c';       
        ffrrS.Name = 'APEX Activity Line Item';
        ffrrS.ffrr__PercentageComplete__c = 'Trans_Billing_Percent_Complete__c';
        ffrrS.ffrr__AccountName__c = '';
        ffrrS.ffrr__ActualVsForecastRelationship__c = '';        
        ffrrS.ffrr__BilledToDate__c = '';
        ffrrS.ffrr__ChainID__c = '';
        ffrrS.ffrr__CostCenter__c = '';        
        ffrrS.ffrr__DefaultFieldMappingDefinition__c = '';
        ffrrS.ffrr__Filter1__c = '';
        ffrrS.ffrr__Filter2__c = '';
        ffrrS.ffrr__Filter3__c = '';        
        ffrrS.ffrr__FixedBalanceSheetAccountCode__c = false;
        ffrrS.ffrr__FixedCostCenterCode__c = false;
        ffrrS.ffrr__FixedIncomeStatementAccountCode__c = false;
        ffrrS.ffrr__ForecastHeaderPrimaryRelationship__c = '';
        ffrrS.ffrr__ForecastTransactionLineRelationship__c = '';
        ffrrS.ffrr__GroupName__c = '';
        ffrrS.ffrr__POLISourceField__c = '';
        ffrrS.ffrr__Rate__c = '';
        ffrrS.ffrr__RecognizedToDateValue__c = 'Revenue_Recognized_to_Date__c';
        ffrrS.ffrr__RevenueRecognitionCompleted__c = '';
        ffrrS.ffrr__SettingsLevel__c = 'Level 2';
        ffrrS.ffrr__SSP__c = '';        
        ffrrS.ffrr__TotalUnits__c = '';
        ffrrS.ffrr__UseInRevenueContract__c = false;
        ffrrS.ffrr__VSOEPercent__c = '';
        ffrrS.ffrr__VSOERate__c = '';
*/
        return ffrrS;
        
    }
    
    public static ffrr__Template__c createffrrTemplate(Id ffrrSettingId)
    {
        ffrr__Template__c ffrrT = new ffrr__Template__c();
        ffrrT.Name = 'APEX TEST - Equal Split';
        ffrrT.ffrr__CalculationType__c = 'Days';
        // ffrrT.ffrr__ForecastScheduleDefinition__c = ;
        ffrrT.ffrr__RevenueBasis__c = 'Total Revenue';
        ffrrT.ffrr__RevenueSource__c = 'Activity_Line_Item__c';
        ffrrT.ffrr__Settings__c = ffrrSettingId;
        ffrrT.ffrr__RevRecType__c = 'Equal Split';        
        return ffrrT;
    }
    
    public static ffrr__ForecastScheduleDefinition__c createForecastScheduleDefinition()
    {
        ffrr__ForecastScheduleDefinition__c fsd = new ffrr__ForecastScheduleDefinition__c();
        return fsd;
    }
    
    public static ffrr__FieldMappingDefinition__c createFieldMappingDefinition()
    {
        ffrr__FieldMappingDefinition__c fmd = new ffrr__FieldMappingDefinition__c(); 
        fmd.Name = 'APEX TEST FieldMappingDefinition';
        fmd.ffrr__SourceObject__c = 'c2g__codaCreditNote__c'; 
        fmd.ffrr__TargetObject__c = 'c2g__codaCreditNote__c';
        return fmd;
    }

    public static ffrr__FieldMapping__c createFieldMapping(Id FieldMappingDefinitionId)
    {
        ffrr__FieldMapping__c fmp = new ffrr__FieldMapping__c(); 
        fmp.ffrr__FieldMappingDefinition__c  = FieldMappingDefinitionId; 
        //fmp.ffrr__FixedValue__c = 'ffrr__FixedValue__c';
        fmp.ffrr__InvertBooleanResult__c = false;
        fmp.ffrr__SourceField__c = 'c2g__Invoice__c';
        fmp.ffrr__TargetField__c = 'c2g__Invoice__c';
        fmp.ffrr__ValueForTrue__c = '';
        return fmp;
    }

    public static c2g__codaIntegrationRule__c createIntegrationRule()
    {
        c2g__codaIntegrationRule__c irl = new c2g__codaIntegrationRule__c();
        irl.Name = 'Map Analysis fields from Invoice to Credit Note';
        irl.c2g__Description__c = 'Map Analysis fields from Invoice to Credit Note';
        //irl.c2g__DocumentNumber__c = ;
        //irl.c2g__ExternalId__c = ;
        irl.c2g__MultiLineCashEntry__c = false;
        //irl.c2g__ProcessedIndicator__c = ;
        irl.c2g__RelationshipSourceField__c = 'c2g__Invoice__c';
        irl.c2g__RelationshipTargetField__c = 'c2g__CreditNote__c';
        irl.c2g__SourceDetailObject__c = 'c2g__codaInvoiceLineItem__c';
        irl.c2g__SourceObject__c = 'c2g__codaInvoice__c';
        irl.c2g__TargetDetailObject__c = 'Sales Credit Note Line Item';
        irl.c2g__TargetObject__c = 'Sales Credit Note';
        irl.c2g__UnitofWork__c = 14;
        return irl;
    }

    public static c2g__codaIntegrationRuleLineItem__c createIntegrationRuleLineItem(Id IntegrationRuleId, integer iLineNumber)
    {
        c2g__codaIntegrationRuleLineItem__c irli = new c2g__codaIntegrationRuleLineItem__c();
        //irli.c2g__ExternalId__c = ;
        irli.c2g__ForPrinting__c = false;
        irli.c2g__ForReading__c = false;
        irli.c2g__ForWriting__c = false;
        irli.c2g__IntegrationRule__c = IntegrationRuleId;
        irli.c2g__LineNumber__c = iLineNumber;
        
        irli.c2g__SourceField__c = 'Billing Event';
        //irli.c2g__SourceFieldDecimal__c = ;
        irli.c2g__SourceFieldPath__c = 'ffpsai__BillingEvent__c';
        irli.c2g__SourceFieldReadOnly__c = false;
        irli.c2g__SourceFieldReferenceTo__c = 'pse__Billing_Event__c';
        irli.c2g__SourceFieldRequired__c = false;
        irli.c2g__SourceFieldSize__c = 18;
        irli.c2g__SourceFieldType__c = 'REFERENCE';
        
        irli.c2g__TargetField__c = 'Billing Event';
        //irli.c2g__TargetFieldDecimal__c = ;
        irli.c2g__TargetFieldPath__c = 'ffpsai__BillingEvent__c';
        irli.c2g__TargetFieldReadOnly__c = false;
        irli.c2g__TargetFieldReferenceTo__c = 'pse__Billing_Event__c';
        irli.c2g__TargetFieldRequired__c = false;
        irli.c2g__TargetFieldSize__c = 18;
        irli.c2g__TargetFieldType__c = 'REFERENCE';
        
        irli.c2g__Type__c = 'Header';
        irli.c2g__UnitofWork__c = 27;
        return irli;
    }  
    
    public static c2g__codaDimension1__c createTestDimension1()
    {
        c2g__codaDimension1__c dim1 = new c2g__codaDimension1__c();
        dim1.Name = 'TEST DIM 1';
        dim1.c2g__ReportingCode__c = 'TESTDIM1';
        return dim1;
    }
    
    public static c2g__codaDimension2__c createTestDimension2()
    {
        c2g__codaDimension2__c dim2 = new c2g__codaDimension2__c();
        dim2.Name = 'TEST DIM 2';
        dim2.c2g__ReportingCode__c = 'TESTDIM2';
        return dim2;
    }
    
    public static c2g__codaDimension3__c createTestDimension3()
    {
        c2g__codaDimension3__c dim3 = new c2g__codaDimension3__c();
        dim3.Name = 'TEST DIM 3';
        dim3.c2g__ReportingCode__c = 'TESTDIM3';
        return dim3;
    }    

    public static c2g__codaDimension4__c createTestDimension4()
    {
        c2g__codaDimension4__c dim4 = new c2g__codaDimension4__c();
        dim4.Name = 'TEST DIM 4';
        dim4.c2g__ReportingCode__c = 'TESTDIM4';
        return dim4;
    }    

    public static c2g__codaCompany__c createFFACompany(String companyName, User contextUser, boolean addUser2Queue)
    {
        
        c2g__codaCompany__c company = new c2g__codaCompany__c();
        
        // FILL A LIST OF A QUEUE "SUPPORTED OBJECTS" API NAMES
        List<String> lstObjAPINames = new List<String>();
        lstObjAPINames.add('c2g__AsOfAging__c');
        lstObjAPINames.add('c2g__CancelPayment__c');
        lstObjAPINames.add('c2g__ReportingBalance__c');
        lstObjAPINames.add('c2g__codaAccountingCurrency__c');
        lstObjAPINames.add('c2g__codaBankAccount__c');
        lstObjAPINames.add('c2g__codaBankReconciliation__c');
        lstObjAPINames.add('c2g__codaBankStatement__c');
        lstObjAPINames.add('c2g__codaBudget__c');
        lstObjAPINames.add('c2g__codaCashEntry__c');
        lstObjAPINames.add('c2g__codaCashMatchingHistory__c');
        lstObjAPINames.add('c2g__codaCompany__c');
        lstObjAPINames.add('c2g__codaCreditNote__c');
        lstObjAPINames.add('c2g__codaCurrencyRevaluationGroup__c');
        lstObjAPINames.add('c2g__codaCurrencyRevaluation__c');
        lstObjAPINames.add('c2g__codaGroupingReference__c');
        lstObjAPINames.add('c2g__codaIntercompanyDefinition__c');
        lstObjAPINames.add('c2g__codaIntercompanyTransfer__c');
        lstObjAPINames.add('c2g__codaInvoice__c');
        lstObjAPINames.add('c2g__codaJournal__c');
        lstObjAPINames.add('c2g__codaMatchingReference__c');
        lstObjAPINames.add('c2g__codaPaymentMediaControl__c');
        lstObjAPINames.add('c2g__codaPaymentMediaSummary__c');
        lstObjAPINames.add('c2g__codaPaymentTemplate__c');
        lstObjAPINames.add('c2g__codaPayment__c');
        lstObjAPINames.add('c2g__codaPurchaseCreditNote__c');
        lstObjAPINames.add('c2g__codaPurchaseInvoice__c');
        lstObjAPINames.add('c2g__codaTextDefinition__c');
        lstObjAPINames.add('c2g__codaTransaction__c');
        lstObjAPINames.add('c2g__codaYear__c');

        // CREATE TEST COMPANY QUEUE 
        Group q = new Group();
        q.Type = 'Queue'; 
        q.Name = CompanyName;
        
        system.runAs(contextUser)
        { 
            
            insert q;
            
            List<QueueSObject> lstQueueObjects = new List<QueueSObject>();
            for (String o : lstObjAPINames)
            {
                QueueSObject qo = new QueueSObject();
                qo.SobjectType = o;
                qo.QueueId = q.Id;
                lstQueueObjects.add(qo);
            }
            
            database.insert(lstQueueObjects);
            
            // ADD contextUser AS A MEMBER OF THE TEST QUEUE
            if (addUser2Queue)
            {
                GroupMember gm = new GroupMember();
                gm.GroupId = q.Id; 
                gm.UserOrGroupId = contextUser.Id;
                insert gm;
            }
        }

        // CREATE TEST COMPANY
        company.Name = companyName; 
        //company.c2g__VATRegistrationNumber__c = taxRegistrationNumber;
        company.OwnerId = q.Id;
        company.RecordTypeId = Schema.SObjectType.c2g__codaCompany__c.RecordTypeInfosByName.get('VAT').RecordTypeId;
        return company;        
    }   
    
    public static c2g__codaYear__c createFFAYear(string strName, Id ffaCompanyId, Id testGroupId)
    {
        c2g__codaYear__c yr = new c2g__codaYear__c();
        yr.Name = strName;
        yr.c2g__OwnerCompany__c = ffaCompanyId;
        yr.c2g__AutomaticPeriodList__c = true;
        yr.c2g__ExternalId__c = 'yzsd1234';
        yr.c2g__NumberOfPeriods__c = 11;
        yr.c2g__StartDate__c = system.today() - 10;
        yr.c2g__Status__c = 'Open';
        yr.c2g__PeriodCalculationBasis__c = '445';
        yr.c2g__YearEndMode__c = 'Full Accounting Code' ; 
        yr.c2g__UnitOfWork__c = 12;
        if (testGroupId != null)
        {
            yr.ownerid = testGroupId;
        } 
        return yr;
    }

    public static c2g__codaPeriod__c createFFAPeriod(string strName, Id ffaCompanyId, Id ffaYearId)
    {
        c2g__codaPeriod__c prd = new c2g__codaPeriod__c();
        prd.Name = strName;
        prd.c2g__OwnerCompany__c = ffaCompanyId;
        prd.c2g__YearName__c = ffaYearId;
        prd.c2g__ExternalId__c ='abdc12345';
        prd.c2g__StartDate__c = System.today()-10;
        prd.c2g__EndDate__c = System.today()+10;
        prd.c2g__PeriodNumber__c = '123';
        prd.c2g__Description__c = 'test Desc';
        prd.c2g__PeriodGroup__c = 'Q1';
        prd.c2g__PeriodNumber__c = '1';
        return prd;
    }

    public static c2g__codaUserCompany__c createFFAUserCompany(Id ffaCompanyId, Id userId)
    {
        c2g__codaUserCompany__c c = new c2g__codaUserCompany__c();
        c.c2g__Company__c = ffaCompanyId;
        c.c2g__User__c = userId; 
        c.c2g__ExternalId__c = 'ABCDE1234567876';
        c.c2g__UnitOfWork__c = 111;
        return c;
    }

    public static c2g__codaAccountingCurrency__c createFFAAccountingCurrency(string strName, Id ffaCompanyId, Id testGroupId)
    {
        c2g__codaAccountingCurrency__c ac = new c2g__codaAccountingCurrency__c();
        ac.Name = strName; 
        ac.c2g__OwnerCompany__c = ffaCompanyId;
        ac.c2g__DecimalPlaces__c = 2;    
        ac.c2g__Dual__c = true ;
        if (testGroupId != null)
        {
            ac.ownerid = testGroupId;
        } 
        return ac;
    }

    public static c2g__codaExchangeRate__c createFFAcodaExchangeRate(Id ffaCompanyId, Id ffaAcctCurrencyId)
    {
        c2g__codaExchangeRate__c er = new c2g__codaExchangeRate__c();
        er.c2g__OwnerCompany__c = ffaCompanyId;
        er.c2g__ExchangeRateCurrency__c = ffaAcctCurrencyId;
        er.c2g__ExternalId__c = '12323232';
        er.c2g__Rate__c = 44.55;
        er.c2g__StartDate__c = system.today()-10;
        er.c2g__UnitOfWork__c = 10;
        return er;       
    }

    public static c2g__codaGeneralLedgerAccount__c createGeneralLedgerAccount(string strName)
    {
        c2g__codaGeneralLedgerAccount__c gla = new c2g__codaGeneralLedgerAccount__c();
        gla.Name = strName;
        gla.c2g__ReportingCode__c = '400000000';
        gla.c2g__Type__c = 'Income Statement';
        // gla.Name = 'Retained Earnings';
        // gla.c2g__BalanceSheet1__c = 'Balance Sheet'; 
        // gla.Description__c = 'test Desc';
        // gla.c2g__ExternalId__c = 'testID';
        // gla.Account_Level__c = 'CAB';
        // gla.Business_Unit__c = 'RG';
        // gla.c2g__UnitOfWork__c =123;
        // gla.Reconciliation_Frequency__c ='Quarterly';
        // gla.c2g__TrialBalance1__c = 'Balance Sheet' ;
        // gla.X10_Digit_GLA__c = false;
        return gla;        
    } 

    public static c2g__codaInvoice__c createSalesInvoice(Id accountId, Date invoiceDate, Decimal amount, Id dim1, Id dim2, Id dim3, Id dim4)
    {
        c2g__codaInvoice__c sin = new c2g__codaInvoice__c();
        sin.c2g__Account__c = accountId;
        sin.c2g__InvoiceDate__c = invoiceDate;
        sin.c2g__DeriveDueDate__c = true;
        sin.c2g__DeriveCurrency__c = true;
        sin.c2g__DerivePeriod__c = true;
        sin.c2g__Dimension1__c = dim1;
        sin.c2g__Dimension2__c = dim2;
        sin.c2g__Dimension3__c = dim3;
        sin.c2g__Dimension4__c = dim4;
        return sin;
    }
    
    public static c2g__codaInvoiceLineItem__c createSalesInvoiceLineItem(Id productId, Decimal amount, Id invoiceId, Id dim1, Id dim2, Id dim3, Id dim4)
    {
        c2g__codaInvoiceLineItem__c sinli = new c2g__codaInvoiceLineItem__c();
        sinli.c2g__Invoice__c = invoiceId;
        sinli.c2g__Product__c = productId;
        sinli.c2g__UnitPrice__c = amount;               
        sinli.c2g__Dimension1__c = dim1;
        sinli.c2g__Dimension2__c = dim2;
        sinli.c2g__Dimension3__c = dim3;
        sinli.c2g__Dimension4__c = dim4;
        sinli.c2g__LineNumber__c = 1;
        sinli.c2g__DeriveUnitPriceFromProduct__c = false;
        return sinli;
    }
    
    public static c2g__codaCreditNote__c createCreditNote(Id accountId, Date invoiceDate, Decimal amount, Id invoiceId, Id dim1, Id dim2, Id dim3, Id dim4)
    {
        c2g__codaCreditNote__c cn = new c2g__codaCreditNote__c();
        cn.c2g__Account__c = accountId;
        cn.c2g__Invoice__c = invoiceId;
        cn.c2g__InvoiceDate__c = invoiceDate;
        cn.c2g__DeriveDueDate__c = true;
        cn.c2g__DeriveCurrency__c = true;
        cn.c2g__Dimension1__c = dim1;
        cn.c2g__Dimension2__c = dim2;
        cn.c2g__Dimension3__c = dim3;
        cn.c2g__Dimension4__c = dim4;
        cn.c2g__DerivePeriod__c = true;
        cn.c2g__CreditNoteReason__c = 'User Reduction';
        return cn;
    }

    public static c2g__codaCreditNoteLineItem__c createCreditNoteLineItem(Id productId, Decimal amount, Id creditNoteId, Id dim1, Id dim2, Id dim3, Id dim4)
    {
        c2g__codaCreditNoteLineItem__c cnli = new c2g__codaCreditNoteLineItem__c(); 
        cnli.c2g__CreditNote__c = creditNoteId; 
        cnli.c2g__Product__c = productId; 
        cnli.c2g__UnitPrice__c = amount; 
        cnli.c2g__Dimension1__c = dim1; 
        cnli.c2g__Dimension2__c = dim2; 
        cnli.c2g__Dimension3__c = dim3; 
        cnli.c2g__Dimension4__c = dim4; 
        cnli.c2g__LineNumber__c = 1; 
        cnli.c2g__DeriveUnitPriceFromProduct__c = false; 
        return cnli;
    } 



    // NEXT PROJECT TESTS START 
    public static INTGR_Account__c createTestINTGR_Account(Integer iRecordNumber, Id testAccountId, Id testUserId) 
    {
        INTGR_Account__c a = new INTGR_Account__c();
        a.Name = 'Test' + String.valueOf(iRecordNumber);        
        a.RequestFormat__c = 'XML';
        if (null != testUserId) 
        {
            a.Integration_User__c = testUserId;
        }
        a.Integration_Endpoint__c = 'http://example.com/example/test';
        a.Integration_Endpoint_SOAP__c = 'http://example.com/example/test';
        a.External_System_Username__c = 'integrationuser';
        a.External_System_Password__c = 'password123';
        a.Attachment_Endpoint_SOAP__c = 'http://example.com/example/test';
        a.Attachment_Endpoint__c = 'http://example.com/example/test';
        a.External_Integration_System_Name__c = 'ServiceNow';
        a.Active__c = true;
        a.Account__c = testAccountId;
        a.Max_Count_To_Resend_Failed_Message__c = 2;
        a.Assignment_Group__c = 'Test Group' ;
        a.Case_Origin__c = 'ServiceNow';
        a.Logger_Desk_Agent_Name__c = 'ServiceNow';
        a.Default_New_Case_Status__c = 'New';
        a.Logger_Desk_Agent_Phone__c = '123456789';
        a.Logger_Group__c = 'ServiceNow';
        return a;     
    }
    
    public static List<INTGR_Field_Mapping__c> createTestINTGR_AccountMapping(Integer iRecordNumber, Id testINTAccountId)     
    {
        List<INTGR_Field_Mapping__c> mapList = new List<INTGR_Field_Mapping__c>();
        for (Integer i = 0; i <= iRecordNumber; i++)
        {
            INTGR_Field_Mapping__c a = new INTGR_Field_Mapping__c ();
            a.Integration_Account__c = testINTAccountId ;        
            a.Source_Field__c = 'Description__c';
            a.Source_Object_API_Name__c = 'INTGR_Case__c';
            a.Target_Field__c = 'Description';
            a.Target_Object_API_Name__c = 'Incident';
            mapList.add (a);
        }
        return mapList;     
    }
    
    public static INTGR_Case__c createTestINTGR_Case(Integer iRecordNumber, Id testAccountId, Id caseid)     
    {
        INTGR_Case__c a = new INTGR_Case__c();
        if (null != caseid) 
        {
            a.Case__c = caseid;
        }
        a.Description__c = 'Test Case Creation';
        a.INTGR_Account__c = testAccountId; 
        a.Status__c = 'New';
        a.Subject__c = 'Test Case Creation';
        a.Severity__c = '1';
        return a;     
    }
    
    public static INTGR_Case_Comment__c createTestINTGR_CaseComm(Id caseid)     
    {
        INTGR_Case_Comment__c a = new INTGR_Case_Comment__c();
        a.INTGR_Case__c = caseid;        
        a.CommentBody__c = 'Test Case Creation';
        a.CreateDate__c = system.now(); 
        return a;     
    }
    
    public static Case createInternalCase(Integer iRecordNumber, Id testAccountId, Id intCaseId , Id intAccId)
    {
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();

        Case c = new Case();
        //c.OwnerId = testUserId;     
        c.Description = 'Test Description';
        c.AccountId = testAccountId;
        c.Integration_Account__c = intAccId;
        c.Integration_Case__c = intCaseId;
        c.Subject = 'Test Case' + iRecordNumber;
        c.Origin = 'Phone';
        c.Status = 'New';
        c.Has_No_DI__c = true;
        c.recordtypeid = RecordTypeIdCase ;
        return c;      
    }

    public static Case createTestCaseIntegration(Integer iRecordNumber, Id testAccountId)
    {
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();

        Case c = new Case();
        //c.OwnerId = testUserId;     
        c.Description = 'Test Description';
        c.AccountId = testAccountId;
        c.Subject = 'Test Case' + iRecordNumber;
        c.Origin = 'Phone';
        c.Status = 'New';
        c.Has_No_DI__c = true;
        c.recordtypeid = RecordTypeIdCase ;
        c.Customer_Name__c = 'Test Customer';
        return c;      
    }        
    
    public static AH_Product_Migration__c createProductMigration(Id AccountId, Id OpportunityId, Id fromProduct2Id, Id toProduct2Id)
    {

        AH_Product_Migration__c pm = new AH_Product_Migration__c();
        pm.Account__c = AccountId; 
        pm.Opportunity__c = OpportunityId; 
        pm.From_Product__c = fromProduct2Id;
        pm.To_Product__c = toProduct2Id;
        return pm;
        
    }

    // ======================================================================================================================================= 
    // PLCM FUNCTIONS
    // =======================================================================================================================================     
    //Initialize the NI_Documentation object
    public static NI_Documentation__c createTestNI_Documentation(String docName, Double licenses, String completionDueDate, String migrationDate, String proposedMigrationDate, String portalProgress, Boolean propertyBubbleHelpSkipped, Boolean userBubbleHelpSkipped, Boolean userXRefBubbleHelpSkipped, String documentType) 
    { 
        Id strId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByName().get('PLCM Migrations').getRecordTypeId();
        //initialize the object 
        NI_Documentation__c niDoc = new NI_Documentation__c(); 
        niDoc.Document_Name__c = docName; 
        niDoc.AH_PLCM_Total_Available_Licenses__c = licenses; 
        niDoc.AH_PLCM_Portal_Completion_Due_Date__c = Date.parse(completionDueDate); 
        niDoc.AH_PLCM_Migration_Date__c = Date.parse(migrationDate); 
        niDoc.AH_PLCM_Proposed_Migration_Date__c = Date.parse(proposedMigrationDate); 
        niDoc.AH_PLCM_Portal_Progress__c = portalProgress; 
        niDoc.AH_PLCM_Is_Property_Bubble_Help_Skipped__c = propertyBubbleHelpSkipped; 
        niDoc.AH_PLCM_Is_User_Bubble_Help_Skipped__c = userBubbleHelpSkipped; 
        niDoc.AH_PLCM_Is_User_XRef_Bubble_Help_Skipped__c = userXRefBubbleHelpSkipped;
        niDoc.Document_Type__c = documentType;
        niDoc.RecordTypeId = strId;
        return niDoc; //return object
    } 

    //Initialize the AH_PLCM_Migration_Property object
    public static AH_PLCM_Migration_Property__c createTestAH_PLCM_Migration_Property(String projectId, String name, String siteName, String propertyState, String propertyCity, String currencyIsoCode) { 
        //initialize the object
        AH_PLCM_Migration_Property__c migrationProperty = new AH_PLCM_Migration_Property__c(); 
        migrationProperty.Name = name; 
        migrationProperty.Site_Name__c = siteName; 
        migrationProperty.Property_State__c = propertyState; 
        migrationProperty.Property_City__c = propertyCity; 
        migrationProperty.CurrencyIsoCode = currencyIsoCode; 
        migrationProperty.NI_Doc_Record__c = projectId;
        migrationProperty.IsActive__c = true;
        return migrationProperty; //return object
    }
    
    //Initialize the AH_PLCM_MigrationUser_Mapping object
    public static AH_PLCM_MigrationUser_Mapping__c createTestAH_PLCM_MigrationUser_Mapping(String projectId, String propertyId, String name, String email) { 
        //initialize the object
        AH_PLCM_MigrationUser_Mapping__c migrationUser = new AH_PLCM_MigrationUser_Mapping__c(); 
        migrationUser.Name = name; 
        migrationUser.User_Email_Address__c = email; 
        migrationUser.PLCM_Migration_Project_Name__c = projectId; 
        migrationUser.New_User__c = true; 
        if(!String.isBlank(PropertyId)) { 
            migrationUser.PLCM_Migration_Property_Assignment__c = propertyId; 
        } 
        return migrationUser; //return object
    } 
    
    //Initialize the AH_PLCM_Migration_User_c object
    public static AH_PLCM_Migration_User__c createTestAH_PLCM_Migration_User_c(String propertyId, String name, String userEmail, String currencyIsoCode) { 
        //initialize the object
        AH_PLCM_Migration_User__c migrationUser = new AH_PLCM_Migration_User__c(); 
        migrationUser.Name = name; 
        migrationUser.User_Email_Address__c = userEmail; 
        migrationUser.CurrencyIsoCode = currencyIsoCode; 
        migrationUser.PLCM_Migration_Property__c = propertyId; 
        migrationUser.IsActive__c = true;
        return migrationUser; //return object
    }
    
    //Initialize the AH_PLCM_TargetOrg_User_c object
    public static AH_PLCM_TargetOrg_User__c createTestAH_PLCM_TargetOrg_User_c(string projectId, String name, String userEmail) { 
        //initialize the object
        AH_PLCM_TargetOrg_User__c targetUser = new AH_PLCM_TargetOrg_User__c(); 
        targetUser.Name = name; 
        targetUser.User_Email_Address__c = userEmail; 
        targetUser.PLCM_Migration_Project_Name__c = projectId; 
        return targetUser; //return object
    }
    //ADDED ON 14/8/2019
    
     // ADDED / 7/26/2019
    public static Salesforce_User__c createTestSalesforceUserDetails(Id NiOrgId)
    {
        Salesforce_User__c sfUser = new Salesforce_User__c();
        sfUser.OrgName__c = NiOrgId;
        sfUser.User_Full_Name__c='Keith Adams';
        sfUser.UserEmail__c = 'newmarket_sm@newmarketinc.com';
        sfUser.UserName__c = 'newmarket_sm@newmarketinc.com.fdc';
        sfUser.User_Profile_Status__c ='Inactive';
        sfUser.userIDFromOrg__c = '005G0000003tCyeIAE';
        sfUser.testscheduler__c = DateTime.valueOf('2019-07-26 09:10:20');
        sfUser.User_License__c = 'Salesforce Platform';
        return sfUser;
    }
    
    // =======================================================================================================================================
    // PLCM - Meeting Matrix :: Start
    // =======================================================================================================================================
    //Initialize the NI_Documentation object
    //ADDED ON 10/9/2020
    public static NI_Documentation__c createTestNI_DocumentationForMM(String docName, string drcDate, String completionDueDate, String portalProgress, Boolean functionRoomBubbleHelpSkipped, Boolean RoomCapacitiesBubbleHelpSkipped, Boolean InventoryBubbleHelpSkipped, String documentType, Boolean termsAndConditions, string termsAndConditionsAcceptDate) {
        Id recordId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByName().get('PLCM MM Conversion').getRecordTypeId();
        //Initialize the object 
        NI_Documentation__c niDoc = new NI_Documentation__c(); 
        niDoc.Document_Name__c = docName; 
        niDoc.AH_PLCM_Portal_Completion_Due_Date__c = Date.parse(completionDueDate); 
        niDoc.DRC_Call_Date__c = Date.parse(drcDate); 
        niDoc.AH_PLCM_Portal_Progress__c = portalProgress; 
        niDoc.AH_PLCM_MM_Is_Function_Room_Bubble_Skip__c = functionRoomBubbleHelpSkipped; 
        niDoc.AH_PLCM_MM_Is_Room_Capacity_Bubble_Skip__c = RoomCapacitiesBubbleHelpSkipped; 
        niDoc.AH_PLCM_MM_Is_Inventory_Bubble_Skip__c = InventoryBubbleHelpSkipped;
        niDoc.Document_Type__c = documentType;
        niDoc.RecordTypeId = recordId;
        niDoc.AH_PLCM_IsTerms_and_Conditions_Accepted__c = termsAndConditions;
        niDoc.AH_PLCM_Terms_and_Cndtions_Accepted_Date__c = Date.parse(termsAndConditionsAcceptDate);
        niDoc.AH_PLCM_Product__c = 'Meeting Matrix Conversion';
        return niDoc; //return object
    }

    //Create function room
    //ADDED ON 10/9/2020
    public static AH_PLCM_MM_Room_Details__c createTest_FunctionRoom(string name, string sourceType, string sourceLocation, integer squareFeet, integer ceilingHeight, string functionRoomType, string floorPlanLevel, boolean seatingOrientation, string seatingOrientationDetails) {
        AH_PLCM_MM_Room_Details__c functionRoomValues = new AH_PLCM_MM_Room_Details__c();
        functionRoomValues.Name = name;
        functionRoomValues.MM_Source_Type__c = sourceType;
        functionRoomValues.MM_Source_Location__c = sourceLocation;
        functionRoomValues.MM_Square_Feet__c = squareFeet;
        functionRoomValues.MM_Ceiling_Height__c = ceilingHeight;
        functionRoomValues.MM_Function_Room_Type__c = functionRoomType;
        functionRoomValues.MM_Floor_Plan_Level__c = floorPlanLevel;
        functionRoomValues.MM_Is_Seating_Orientation_Non_Std__c = seatingOrientation;
        functionRoomValues.MM_Seating_Orientation_Details__c = seatingOrientationDetails;
        return functionRoomValues; //return object
    }

    //Create inventory
    //ADDED ON 10/9/2020
    public static AH_PLCM_MM_Inventory__c createTest_Inventory(boolean chair1IsDefault, string chair1Desription, integer chair1Height, integer chair1Length, integer chair1Width, Id projectId) {
       AH_PLCM_MM_Inventory__c inventory = new AH_PLCM_MM_Inventory__c();
       inventory.MM_Chair_1_Is_Default__c = chair1IsDefault;
       inventory.MM_Chair_1_Description__c = chair1Desription;
       inventory.MM_Chair_1_Height__c = chair1Height;
       inventory.MM_Chair_1_Length__c = chair1Length;
       inventory.MM_Chair_1_Width__c = chair1Width;
       inventory.NI_Doc_Record__c = projectId;
       return inventory; //return object
    }
    // =======================================================================================================================================
    // PLCM - Meeting Matrix :: End
    // =======================================================================================================================================
    
    //=======================================================================================================================================
    // PLCM - Email WorkFlow :: Start
    // =======================================================================================================================================
    //Initialize the NI_Documentation object
    public static NI_Documentation__c createTestNI_DocumentationForEmailWorkFlow(String docName, Double licenses, String completionDueDate, String migrationDate, String proposedMigrationDate, String portalProgress,
    Boolean propertyBubbleHelpSkipped, Boolean userBubbleHelpSkipped, Boolean userXRefBubbleHelpSkipped, String documentType, boolean techTransfer)
    {
    Id strId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByName().get('PLCM Migrations').getRecordTypeId();
    //initialize the object
    NI_Documentation__c niDoc = new NI_Documentation__c();
    niDoc.Document_Name__c = docName;
    niDoc.AH_PLCM_Total_Available_Licenses__c = licenses;
    niDoc.AH_PLCM_Portal_Completion_Due_Date__c = Date.parse(completionDueDate);
    niDoc.AH_PLCM_Migration_Date__c = Date.parse(migrationDate);
    niDoc.AH_PLCM_Proposed_Migration_Date__c = Date.parse(proposedMigrationDate);
    niDoc.AH_PLCM_Portal_Progress__c = portalProgress;
    niDoc.AH_PLCM_Is_Property_Bubble_Help_Skipped__c = propertyBubbleHelpSkipped;
    niDoc.AH_PLCM_Is_User_Bubble_Help_Skipped__c = userBubbleHelpSkipped;
    niDoc.AH_PLCM_Is_User_XRef_Bubble_Help_Skipped__c = userXRefBubbleHelpSkipped;
    niDoc.Document_Type__c = documentType;
    niDoc.RecordTypeId = strId;
    niDoc.AH_PLCM_Tech_Transfer__c = techTransfer;
    return niDoc; //return object
    }
    // =======================================================================================================================================
    // PLCM - Email WorkFlow :: END
    //
	// =======================================================================================================================================

	// // Added on 21-10-2020 
    // ======================================================================================================================================= 
    // PLCM - Extract Append :: Start
    // =======================================================================================================================================     
    //Initialize the NI_Documentation object
    public static NI_Documentation__c createTestNI_DocumentationForEA(String docName, Double licenses, String completionDueDate, String migrationDate, String proposedMigrationDate, String portalProgress, Boolean propertyBubbleHelpSkipped, Boolean userBubbleHelpSkipped, Boolean userXRefBubbleHelpSkipped, String documentType, String SourceOrgId, String TargetOrgId)
    { 
        Id strId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByName().get('PLCM S&E Extract Append').getRecordTypeId();
        //initialize the object 
        NI_Documentation__c niDoc = new NI_Documentation__c(); 
        niDoc.Document_Name__c = docName; 
        niDoc.AH_PLCM_Total_Available_Licenses__c = licenses; 
        niDoc.AH_PLCM_Portal_Completion_Due_Date__c = Date.parse(completionDueDate); 
        niDoc.AH_PLCM_Migration_Date__c = Date.parse(migrationDate); 
        niDoc.AH_PLCM_Proposed_Migration_Date__c = Date.parse(proposedMigrationDate); 
        niDoc.AH_PLCM_Portal_Progress__c = portalProgress; 
        niDoc.AH_PLCM_Is_Property_Bubble_Help_Skipped__c = propertyBubbleHelpSkipped; 
        niDoc.AH_PLCM_Is_User_Bubble_Help_Skipped__c = userBubbleHelpSkipped; 
        niDoc.AH_PLCM_Is_User_XRef_Bubble_Help_Skipped__c = userXRefBubbleHelpSkipped;
        niDoc.Document_Type__c = documentType;
        niDoc.RecordTypeId = strId;
        niDoc.AH_PLCM_Source_OrgID__c = SourceOrgId;
        niDoc.AH_PLCM_Target_OrgID__c = TargetOrgId;
        return niDoc; //return object
    }
    
    //Initialize the NI_Org_Details__c object
    public static NI_Org_Details__c createTestNI_OrgDetailsForEA(String orgName, String orgType, String orgStatus, String productType, String orgId, String packageVersion)
    { 
        Id strId = Schema.SObjectType.NI_Org_Details__c.getRecordTypeInfosByName().get('LOD Support Admin').getRecordTypeId();
        //initialize the object 
        NI_Org_Details__c niOrgDetails = new NI_Org_Details__c(); 
        niOrgDetails.Org_Name__c = orgName; 
        niOrgDetails.Org_Type__c = orgType; 
        niOrgDetails.Org_Status__c = orgStatus; 
        niOrgDetails.Product_Type__c = productType; 
        niOrgDetails.Org_ID__c = orgId; 
        niOrgDetails.PackageVersion__c = packageVersion;
        niOrgDetails.RecordTypeId = strId;
        return niOrgDetails; //return object
    }
    
    //Initialize the AH_PLCM_MigrationUser_Mapping object
    public static AH_PLCM_MigrationUser_Mapping__c createTestAH_PLCM_MigrationUser_MappingForEA(String projectId, String propertyId, String name, String email, Boolean isActive, string additionPropertyAccessToUser) { 
        //initialize the object
        AH_PLCM_MigrationUser_Mapping__c migrationUser = new AH_PLCM_MigrationUser_Mapping__c(); 
        migrationUser.Name = name; 
        migrationUser.User_Email_Address__c = email; 
        migrationUser.PLCM_Migration_Project_Name__c = projectId; 
        migrationUser.New_User__c = true; 
        if(!String.isBlank(PropertyId)) { 
            migrationUser.PLCM_Migration_Property_Assignment__c = propertyId; 
        }
        migrationUser.IsActive__c = isActive;
        migrationUser.Additional_Property_Access_to_User__c = additionPropertyAccessToUser;
        return migrationUser; //return object
    }
    
    //Initialize the AH_PLCM_Migration_Property__c object
    public static AH_PLCM_Migration_Property__c createTestAH_PLCM_Migration_PropertyForEA(String Name, String orgDetailsId, String currencyCode, String countryCode, String orgId, String majorVersion, Boolean isLimitedService, Boolean isActive, String orgName, String propertyId, String city, String state, String timeZone, String product, String productType, String zipCode, String projectId)
    {
        //initialize the object 
        AH_PLCM_Migration_Property__c propertyDetails = new AH_PLCM_Migration_Property__c(); 
        propertyDetails.Name = Name; 
        propertyDetails.Org_Details_ID__c = orgDetailsId;
        propertyDetails.CurrencyIsoCode = currencyCode;
        propertyDetails.Country_Code__c = countryCode;  
        propertyDetails.Org_ID__c = orgId;
        propertyDetails.Major_Version__c = majorVersion;
        propertyDetails.Is_Limited_Service__c = isLimitedService;
        propertyDetails.IsActive__c = isActive;
        propertyDetails.Org_Name__c = orgName;
        propertyDetails.Property_ID__c = propertyId;
        propertyDetails.External_ID__c = propertyId;
        propertyDetails.Property_City__c = city;
        propertyDetails.Property_State__c = state;
        propertyDetails.Property_Time_Zone_Name__c = timeZone;
        propertyDetails.Product__c = product;
        propertyDetails.Product_Type__c = productType;
        propertyDetails.Property_Zip_Code__c = zipCode;
        propertyDetails.NI_Doc_Record__c = projectId;
        return propertyDetails; //return object
    }
    
    //Initialize the AH_PLCM_Migration_User_c object
    public static AH_PLCM_Migration_User__c createTestAH_PLCM_Migration_User_cForEA(String propertyId, String name, String userEmail, String currencyIsoCode) { 
        //initialize the object
        AH_PLCM_Migration_User__c migrationUser = new AH_PLCM_Migration_User__c(); 
        migrationUser.Name = name; 
        migrationUser.User_Email_Address__c = userEmail; 
        migrationUser.CurrencyIsoCode = currencyIsoCode; 
        migrationUser.PLCM_Migration_Property__c = propertyId; 
        migrationUser.IsActive__c = true;
        return migrationUser; //return object
    }
    
    //Initialize the AH_PLCM_TargetOrg_User_c object
    public static AH_PLCM_TargetOrg_User__c createTestAH_PLCM_TargetOrg_User_cForEA(string projectId, String name, String userEmail) { 
        //initialize the object
        AH_PLCM_TargetOrg_User__c targetUser = new AH_PLCM_TargetOrg_User__c(); 
        targetUser.Name = name; 
        targetUser.User_Email_Address__c = userEmail; 
        targetUser.PLCM_Migration_Project_Name__c = projectId; 
        return targetUser; //return object
    }
    
    // =======================================================================================================================================
    // PLCM - Extract Append :: End
    // ========================================================================================================================================

// ADDED 12/2/2020 PER NICC-046756
    public static AH_Workstream__c createTestWorkstream()
    {
        AH_Workstream__c ws = new AH_Workstream__c();
        ws.Name = 'Contract Management';
        ws.All_in_Costs__c = 65000;
        ws.Active__c = true;
        return ws;
    }
    
     // ADDED 12/2/2020 PER NICC-046756
     // UPDATED PER NICC-047851
    public static AH_Project_Backlog_Workstreams__c createTestProjectWorkstream(Id projectBacklogId)
    {
        AH_Project_Backlog_Workstreams__c pws = new AH_Project_Backlog_Workstreams__c();
        pws.Workstream_Name__c = 'Contract Management';
        pws.NI_Project_Backlog__c = projectBacklogId;
        pws.This_Project_Will_Increase_Efficiences__c = true;
        pws.This_Project_Will_Reduce_Costs__c = true;
        pws.Annual_Cost_Reduction_Confidence__c = 50;
        pws.Annual_Efficiencies_Savings_Confidence__c = 50;
        pws.Estimated_Annual_Cost_Reduction__c = 1000;
        pws.Annual_Efficiencies_Savings_hrs__c = 1000;
        
        return pws;
    }
    
    // ADDED BY STUART EMERY 03/27/2021 PER NICC-048128
    public static AH_Solution_Domain_Attributes__c createSolutionDomainAttributes()
    {
        AH_Solution_Domain_Attributes__c sda = new AH_Solution_Domain_Attributes__c();
        sda.Name = 'Apex Test';
        sda.Margin__c = 0.1;
        sda.Active__c = true;
        sda.Solution_Domain__c = 'Test Domain';
        return sda;
    }
    
     // ADDED BY STUART EMERY 08/27/2021 PER NICC-052490
    public static AH_Event_Log__c createAHEventLog(String strSummary, String strParentId, Id idUser)
    {
        AH_Event_Log__c evLog = new AH_Event_Log__c();
        evLog.Summary__c = strSummary;
        evLog.ParentId__c = strParentId;
        evLog.Running_User__c = idUser;
        return evLog;
    }


}