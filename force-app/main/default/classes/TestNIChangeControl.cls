@isTest
private class TestNIChangeControl 
{
    
    static testMethod void testaddArtifactTemplates() 
    {
        // ADDED BY STUART EMERY ON 2/24/2013 TO BULKIFY THE INSERT
        // CREATE LIST OF THE ARTIFACTS TO INSERT
        List<NICC_Artifact__c> lstArtToInsert = New List<NICC_Artifact__c>();
        
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        
        NI_Change_Control__c nicc = new NI_Change_Control__c (RecordTypeId = rt.Id, Request_Summary__c = 'Test Request Summary Text...', Date_Required__c = System.today());
        insert nicc;
               
        NICC_Artifact__c a1 = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Communication Plan');         
        //insert a1;
        lstArtToInsert.add(a1);
        
        NICC_Artifact__c a2 = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Deployment Plan');         
        //insert a2;
        lstArtToInsert.add(a2);
        
        NICC_Artifact__c a3 = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Monitoring Plan');         
        //insert a3;
        lstArtToInsert.add(a3);
        
        NICC_Artifact__c a4 = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Rollback Plan');         
        //insert a4;
        lstArtToInsert.add(a4);
        
        NICC_Artifact__c a5 = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Test Plan');         
        //insert a5;
        lstArtToInsert.add(a5);
        
        Database.insert(lstArtToInsert);
                
    }
    
    static testMethod void testaddCustomerSignOffArtifact() 
    {
        
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        
        NI_Change_Control__c nicc = new NI_Change_Control__c (RecordTypeId = rt.Id, Outage_Required__c = 'No', New_Custom_Script__c = 'No', Data_Change__c = 'No', Request_Summary__c = 'Test Request Summary Text...', Date_Required__c = System.today());
        insert nicc;         
        
        nicc.Outage_Required__c = 'Yes';
        nicc.Data_Change__c = 'Yes';         
        update nicc;
            
    }
    
    static testMethod void testValidateArtifacts() 
    {    
       
        // ADDED BY STUART EMERY ON 2/24/2013 TO BULKIFY THE INSERT
        // CREATE LIST OF THE ARTIFACTS TO INSERT
        List<NICC_Artifact__c> lstArtToInsert = New List<NICC_Artifact__c>();
        
        // CREATE LIST OF THE ARTIFACTS TO UPDATE
        List<NICC_Artifact__c> lstArtToUpdate = New List<NICC_Artifact__c>();
        
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        
        NI_Change_Control__c nicc = new NI_Change_Control__c (RecordTypeId = rt.Id, Outage_Required__c = 'No', New_Custom_Script__c = 'No', Data_Change__c = 'No', Request_Summary__c = 'Test Request Summary Text...', Date_Required__c = System.today());
        insert nicc;     
                  
        NICC_Artifact__c a1 = new NICC_Artifact__c (NI_Change_Control__c = nicc.Id, Type__c = 'Communication Plan', Document_Link__c = 'TEST', Description__c = 'TEST');
        //insert a1;
        lstArtToInsert.add(a1);
        a1.Description__c = 'Test Description';           
        lstArtToUpdate.add(a1);
        //update a1;
         
        NICC_Artifact__c a2 = new NICC_Artifact__c (NI_Change_Control__c = nicc.Id, Type__c = 'Deployment Plan', Document_Link__c = 'TEST', Description__c = 'TEST');
         //insert a2;
        lstArtToInsert.add(a2);
        a2.Description__c = 'Test Description';           
        lstArtToUpdate.add(a2);
        //update a2;
                
        NICC_Artifact__c a3 = new NICC_Artifact__c (NI_Change_Control__c = nicc.Id, Type__c = 'Monitoring Plan', Document_Link__c = 'TEST', Description__c = 'TEST');
         //insert a3;
        lstArtToInsert.add(a3);
        a3.Description__c = 'Test Description';           
        lstArtToUpdate.add(a3);
        //update a3;
                 
        NICC_Artifact__c a4 = new NICC_Artifact__c (NI_Change_Control__c = nicc.Id, Type__c = 'Rollback Plan', Document_Link__c = 'TEST', Description__c = 'TEST');
         //insert a4;
        lstArtToInsert.add(a4);
        a4.Description__c = 'Test Description';           
        lstArtToUpdate.add(a4);
        //update a4;
                  
        NICC_Artifact__c a5 = new NICC_Artifact__c (NI_Change_Control__c = nicc.Id, Type__c = 'Test Plan', Document_Link__c = 'TEST', Description__c = 'TEST');
        //insert a5;
        lstArtToInsert.add(a5);
        a5.Description__c = 'Test Description';           
        lstArtToUpdate.add(a5);
        //update a5;
                  
        NICC_Artifact__c a6 = new NICC_Artifact__c (NI_Change_Control__c = nicc.Id, Type__c = 'Customer Sign-off', Document_Link__c = 'TEST', Description__c = 'TEST');
         //insert a6;
        lstArtToInsert.add(a6);
        a6.Description__c = 'Test Description';           
        lstArtToUpdate.add(a6);
        //update a6;
        
        // INSERT ARTIFACTS
        Database.insert(lstArtToInsert);
        
        // UPDATE ARTIFACTS
        Database.update(lstArtToUpdate);
       
    }
    
    static testMethod void testNICCCompShare()   
    {
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        NI_Change_Control__c NI = new NI_Change_Control__c(RecordTypeId = rt.Id, Change_Steps__c = 'test', Date_Required__c = system.today(), Request_Summary__c = 'Test');
        insert NI;
    } 
          
    static testMethod void testNICCMRShare()   
    {
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        NI_Change_Control__c NI = new NI_Change_Control__c(RecordTypeId = rt.Id, Change_Steps__c = 'test', Date_Required__c = system.today(), Request_Summary__c = 'Test');
        insert NI;
    }  
         
    static testMethod void testAddCase_To_NICCRequestCaseJunction()   
    {
        // CREATE A TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        // CREATE A TEST CASE
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        insert c;
        
        //Case c = [Select Id from Case Where AccountId !=null limit 1];
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        NI_Change_Control__c NI = new NI_Change_Control__c(RecordTypeId = rt.Id, Change_Steps__c = 'test', Date_Required__c = system.today(), Request_Summary__c = 'Test', Case_Id__c = c.Id);
        insert NI;
        
        //Account a = [Select Id from Account limit 1];
        //NICCRequestAccountJunction__c newA = new NICCRequestAccountJunction__c(Account__c = a.Id, NI_Change_Control_Request__c = NI.Id);
        
    }  
         
    static testMethod void testNICCpeerReviewerShare()   
    {
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        NI_Change_Control__c NI = new NI_Change_Control__c(RecordTypeId = rt.Id, Change_Steps__c = 'test', Date_Required__c = system.today(), Request_Summary__c = 'Test');
        insert NI;
    }
    
    static testMethod void testNICC_HRFCcompilerBlank()
    {
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        NI_Change_Control__c NI = new NI_Change_Control__c(RecordTypeId = rt.Id, Change_Steps__c = 'test', Date_Required__c = system.today(), Request_Summary__c = 'Test');
        insert NI;
    }
    
    static testMethod void testNICCdevReviewerShare()   
    {
        User u = [Select Id from User Where UserType = 'Standard' AND IsActive = true limit 1];
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        NI_Change_Control__c NI = new NI_Change_Control__c(RecordTypeId = rt.Id, Change_Steps__c = 'test', Date_Required__c = system.today(), Request_Summary__c = 'Test', Developer_Reviewer__c = u.Id);
        insert NI;
        
        //Create the Share
        NI_Change_Control__Share prShr = new NI_Change_Control__Share();
        prShr.ParentId = NI.Id;
        prShr.UserOrGroupId = NI.Developer_Reviewer__c;
        prShr.AccessLevel = 'edit';
        prShr.RowCause = Schema.NI_Change_Control__Share.RowCause.Developer_Reviewer_Share__c;
        Insert prShr;
    }
    
}