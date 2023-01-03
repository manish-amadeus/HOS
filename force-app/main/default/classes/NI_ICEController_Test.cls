/****************************************************************************************
Name            : NI_ICEController_Test Class
Author          : Sean Harris
Created Date    : 02/26/2014 
Last Mod Date   : 05/03/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
@isTest 
private class NI_ICEController_Test
{
    
    public static testMethod void testICEBulk() 
    {
        
        List<ICESubscription__c> lstSubs = new List<ICESubscription__c>();
        List<ICEProperty__c> lstPrps = new List<ICEProperty__c>();
        List<ICEUser__c> lstUsrs = new List<ICEUser__c>();
        
        // LOOP THROUGH AND CREATE 200 ICESubscription__c, ICEProperty__c, ICEUser__c RECORDS 
        for (integer j = 1; j < 201; j++)
        {
            
            ICESubscription__c s = new ICESubscription__c();
            s.SubscriptionName__c = 'APEX BULK TEST SUBSCRIPTION';
            s.SubscriptionID__c = j + 5000000;
            lstSubs.Add(s);
            
            ICEProperty__c p = new ICEProperty__c();
            p.PropertyName__c = 'APEX BULK TEST PROPERTY';
            p.SubscriptionID__c = j + 5000000;
            p.PropertyId__c = j + 6000000; 
            lstPrps.Add(p);
            
            ICEUser__c u = new ICEUser__c();
            u.UserName__c = 'APEX BULK TEST USER';
            u.SubscriptionID__c = j + 5000000;
            u.DefaultPropertyId__c = j + 6000000; 
            u.UserID__c = j + 7000000;  
            lstUsrs.Add(u);
            
        }
        
        // ASSERT THAT ALL 200 ICESubscription__c RECORDS INSERTED  
        Database.Insert(lstSubs);
        List<ICESubscription__c> lstSubsTest = new List<ICESubscription__c>([SELECT Id, MigrationPortalKey__c FROM ICESubscription__c WHERE SubscriptionName__c = 'APEX BULK TEST SUBSCRIPTION']);        
        System.assertEquals(lstSubsTest.Size(), 200, 'Bulk test failed because lstSubsTest.Size() is not equal to 200'); 
        
        // ASSERT THAT ALL THE MigrationPortalKey__c VALUES ARE UNIQUE  
        Set<String> setKeys = new Set<String>();        
        for (ICESubscription__c st : lstSubsTest)
        {
            setKeys.Add(st.MigrationPortalKey__c);
        }
        
        system.assertEquals(setKeys.Size(), 200, 'Bulk test failed because setKeys.Size() is not equal to 200. All MigrationPortalKey__c are not unique.');         
        
        // ASSERT THAT ALL 200 ICEProperty__c RECORDS INSERTED AND ICESubscriptionId__c WAS UPDATED IN TRIGGER
        Database.Insert(lstPrps);
        List<ICEProperty__c> lstPrpsTest = new List<ICEProperty__c>([SELECT Id FROM ICEProperty__c WHERE PropertyName__c = 'APEX BULK TEST PROPERTY' AND ICESubscriptionId__c != null]);
        System.assertEquals(lstPrpsTest.Size(), 200, 'Bulk test failed because lstPrpsTest.Size() is not equal to 200'); 
        
        // ASSERT THAT ALL 200 ICEUser__c RECORDS INSERTED AND ICESubscriptionId__c & ICEPropertyId__c WERE UPDATED IN TRIGGER 
        Database.Insert(lstUsrs);
        List<ICEUser__c> lstUsrsTest = new List<ICEUser__c>([SELECT Id FROM ICEUser__c WHERE UserName__c = 'APEX BULK TEST USER' AND ICEPropertyId__c != null AND ICESubscriptionId__c != null]);
        System.assertEquals(lstUsrsTest.Size(), 200, 'Bulk test failed because lstUsrsTest.Size() is not equal to 200'); 
        
    }
    
    public static testMethod void testICEController() 
    {
        NI_TestClassData.createTestWinaproachServiceNowSettings();       
        String strAuthKey = null;
        
        
        // START CREATE TEST DATA ===================================================================        
        
        // CREATE PARENT ACCOUNT TEST RECORD ================================================ 
        Account parentacc = NI_TestClassData.createTestAccount(123); 
        insert parentacc; 
        
        System.assertNotEquals(parentacc, null, 'Test Parent Account record is null');
        
        // CREATE CONTACT TEST RECORD =======================================================           
        Contact cnct = NI_TestClassData.createTestContact(123, parentacc.Id);        
        insert cnct;
        
        System.assertNotEquals(cnct, null, 'Test Contact record is null');          
        
        // CREATE TEST ICE SUBSCRIPTION ===========================================================
        ICESubscription__c iceSub1 = NI_TestClassData.createICESubscription(1, 1000000000);
        iceSub1.ScheduledMigrationDate__c = Date.today().addDays(14);
        iceSub1.Contact__c = cnct.Id;
        insert iceSub1; 
        
        System.assertNotEquals(iceSub1, null, 'Test ICESubscription__c record is null');  
        
        ICESubscription__c iceAuthKey = [SELECT MigrationPortalKey__c, Contact__c FROM ICESubscription__c WHERE Id = : iceSub1.Id];
        strAuthKey = iceAuthKey.MigrationPortalKey__c;        
        System.assertNotEquals(strAuthKey, null, 'Test MigrationPortalKey__c is null'); 
        
        Id idContact = iceAuthKey.Contact__c;        
        System.assertNotEquals(idContact, null, 'Test iceAuthKey.Contact__c is null'); 
        
        // CREATE TEST ICE SUBSCRIPTION ===========================================================
        ICESubscription__c iceSub2 = NI_TestClassData.createICESubscription(2, 2000000000);
        //iceSub2.ScheduledMigrationDate__c = Date.today().addDays(14);
        //iceSub2.Contact__c = cnct.Id;
        insert iceSub2; 
        
        System.assertNotEquals(iceSub2, null, 'Test ICESubscription__c record is null'); 
        
        // CREATE TEST ICE PROPERTY ===============================================================
        ICEProperty__c icePrp1 = NI_TestClassData.createICEProperty(1, 1000000000, 1000000001);
        insert icePrp1; 
        
        System.assertNotEquals(icePrp1, null, 'Test ICEProperty__c record is null');
        
        // CREATE TEST ICE USER (ACTIVE) ==========================================================
        ICEUser__c iceUsr1 = NI_TestClassData.createICEUser(1, 1000000000, 1000000001, 1000000002);
        iceUsr1.DelphiNetIsActive__c = true;
        insert iceUsr1; 
        
        System.assertNotEquals(iceUsr1, null, 'Test ICEUser__c (Active) record is null'); 
        
        // CREATE TEST ICE USER (INACTIVE) ========================================================
        ICEUser__c iceUsr2 = NI_TestClassData.createICEUser(1, 1000000000, 1000000001, 1000000003);
        iceUsr2.DelphiNetIsActive__c = false;
        insert iceUsr2; 
        
        System.assertNotEquals(iceUsr2, null, 'Test ICEUser__c (Inactive) record is null');  
        
        // CREATE TEST ICE USER (ACTIVE) ==========================================================
        ICEUser__c iceUsr3 = NI_TestClassData.createICEUser(1, 1000000000, 1000000001, 1000000004);
        iceUsr3.DelphiNetIsActive__c = true;
        insert iceUsr3; 
        
        System.assertNotEquals(iceUsr1, null, 'Test ICEUser__c 2 (Active) record is null'); 
        
        // END CREATE TEST DATA ====================================================================
        
        PageReference pageRef = Page.NI_ICE_Home; 
        System.assertNotEquals(pageRef, null, 'NI_ICE_Home page reference is null'); 
        
        pageRef.getParameters().put('authkey', strAuthKey); 
        pageRef.getParameters().put('pageid', 'Test'); 
        pageRef.getParameters().put('stepsaved', '1'); 
        Test.setCurrentPage(pageRef); 
        
        List<ICESubscription__c> lstICE = new List<ICESubscription__c>([
            SELECT Id, AcceptOnlineTermsCompleted__c, AgreementAcceptedIP__c, Contact__c, ContactCityStateZip__c, ContactEmail__c, 
            ContactName__c, ContactStreetAddress__c, ContactTitle__c, ContactVenue__c, DelphiNetIsActive__c, IAcknowledgeandHavetheAuthority__c, 
            ICE_Link__c, MigrationPortalKey__c, PropertySettingsCompleted__c, ReviewPropertiesAndUsersCompleted__c, ScheduledMigrationDate__c, 
            Status__c, StatusReason__c, SubscriptionID__c, SubscriptionName__c, UploadMergeDocumentsCompleted__c, UserSettingsCompleted__c       
            FROM ICESubscription__c
            WHERE MigrationPortalKey__c = : strAuthKey LIMIT 1
        ]);           
        
        System.AssertEquals(lstICE.Size(), 1, 'lstICE.Size() is NOT equal to 1!'); 
        
        NI_ICEController controller = new NI_ICEController();
        System.assertNotEquals(controller, null, 'NI_ICEController controller was not created');    
        
        controller.loggedincontact = cnct;
        controller.iceSub = iceSub1;
        
        System.assertEquals(controller.iceSub.Id, iceSub1.Id, 'controller.iceSub.Id != iceSub1.Id. controller.iceSub.Id = ' + controller.iceSub.Id + ', iceSub1.Id = ' + iceSub1.Id);
        
        List<ICEProperty__c> lstMPs = controller.getICEProperties();
        System.assertNotEquals(lstMPs.Size(), 0, 'lstMPs is empty!!!');
        
        List<ICEProperty__c> lstSelMPs = controller.getSelectedProperties();
        System.assertNotEquals(lstSelMPs.Size(), 0, 'lstSelMPs is empty!!!');
        
        List<ICEUser__c> lstMEUs = controller.getICEUsers();
        System.assertNotEquals(lstMEUs.Size(), 0, 'lstMEUs is empty!!!');
        
        List<ICEUser__c> lstSelMEUs = controller.getSelectedUsers();
        System.assertNotEquals(lstSelMEUs.Size(), 0, 'lstSelMEUs is empty!!!');     
        
        List<SelectOption> lstMItems = controller.getItems();
        System.assertNotEquals(lstMItems.Size(), 0, 'lstMItems is empty!!!'); 
        
        List<SelectOption> lstMTypes = controller.getTypes(); 
        System.assertNotEquals(lstMTypes.Size(), 0, 'lstMTypes is empty!!!'); 
        
        // ====================================================================    
        // NI_ICE_Selection PAGE FUNCTIONS (INITIAL STEP)
        // ====================================================================                    
        PageReference prHome = Page.NI_ICE_Home; 
        prHome.getParameters().put('authkey', strAuthKey);
        prHome.getParameters().put('pageid', 'Test');
        prHome.getParameters().put('stepsaved', '1');
        Test.setCurrentPage(prHome);
        
        
        // ===================================================================    
        // NI_ICE_Selection PAGE FUNCTIONS (STEP 1)
        // ===================================================================        
        PageReference pr1 = Page.NI_ICE_Selection; 
        pr1.getParameters().put('authkey', strAuthKey);
        pr1.getParameters().put('pageid', 'Test');
        pr1.getParameters().put('stepsaved', '1');        
        Test.setCurrentPage(pr1); 
        
        controller.submitReviewPropertiesUsers();
        PageReference pg1 = controller.completeReviewPropertiesUsers(); 
        
        // ===================================================================    
        // NI_ICE_Property PAGE FUNCTIONS (STEP 2)   
        // ===================================================================   
        PageReference pr2 = Page.NI_ICE_Property;  
        pr2.getParameters().put('authkey', strAuthKey);
        pr2.getParameters().put('pageid', 'Test');
        pr2.getParameters().put('stepsaved', '2'); 
        Test.setCurrentPage(pr2); 
        
        controller.submitPropertySettings();         
        PageReference pg2 = controller.completePropertySettings(); 
        
        // ===================================================================    
        // NI_ICE_User PAGE FUNCTIONS (STEP 3)   
        // ===================================================================    
        PageReference pr3 = Page.NI_ICE_User;  
        pr3.getParameters().put('authkey', strAuthKey);
        pr3.getParameters().put('pageid', 'Test');
        pr3.getParameters().put('stepsaved', '3'); 
        Test.setCurrentPage(pr3); 
        
        controller.submitUsersSettings(); 
        PageReference pg3 = controller.completeUsersSettings();
        
        
        // ===================================================================    
        // NIMigrationPortal PAGE FUNCTIONS (STEP 4)   
        // ===================================================================      
        PageReference pr4 = Page.NI_ICE_Agreement;  
        pr4.getParameters().put('authkey', strAuthKey);
        pr4.getParameters().put('pageid', 'Test');
        pr4.getParameters().put('stepsaved', '4'); 
        Test.setCurrentPage(pr4); 
        
        controller.prepareacceptterms();    
        PageReference pg4 = controller.acceptTerms(); 
        
        // ===================================================================    
        // NIMigrationPortal PAGE FUNCTIONS (STEP 5)   
        // ===================================================================  
        PageReference pr5 = Page.NI_ICE_Upload; 
        pr5.getParameters().put('authkey', strAuthKey);
        pr5.getParameters().put('pageid', 'Test');
        pr5.getParameters().put('stepsaved', '5'); 
        Test.setCurrentPage(pr5); 
        
        controller.authenticated = true;
        controller.uploadeddocbody = Blob.valueOf('test');
        controller.uploadeddocname = 'test';
        controller.uploaddocs();    
        
        Attachment att = [SELECT Id, Name FROM Attachment WHERE ParentId = : iceSub1.Id LIMIT 1];        
        System.assertNotEquals(att, null, 'Query for related Attachment record failed because it is null');
        string strAttachId = (String)att.Id;
        
        //        controller.deleteAttachment(strAttachId);    
        //        PageReference pg5 = controller.completeuploaddocsstep();                 
        
        controller.backtohome();
        controller.filetodelete = att.Name;
        controller.deletedoc(); 
        controller.completeuploaddocsstep();  
        
        
        
        // SECOND PASS CLEAN UP ===============================================
        
        Test.startTest();  //      
        
        // CREATE WITH NO URL PARAMS
        PageReference pr6 = Page.NI_ICE_Home; 
        Test.setCurrentPage(pr6);    
        
        NI_ICEController controller1 = new NI_ICEController();
        System.assertNotEquals(controller1, null, 'NI_ICEController controller1 was not created');  
        
        // CREATE WITH NO CONTACT
        ICESubscription__c iceAuthKey2 = [SELECT MigrationPortalKey__c, Contact__c FROM ICESubscription__c WHERE Id = : iceSub2.Id];
        strAuthKey = iceAuthKey2.MigrationPortalKey__c;        
        System.assertNotEquals(strAuthKey, null, 'Test iceAuthKey2.MigrationPortalKey__c is null'); 
        
        PageReference pr7 = Page.NI_ICE_Home;  
        pr7.getParameters().put('authkey', strAuthKey);
        pr7.getParameters().put('pageid', 'Test');
        pr7.getParameters().put('stepsaved', '1'); 
        Test.setCurrentPage(pr7); 
        
        NI_ICEController controller2 = new NI_ICEController();
        System.assertNotEquals(controller2, null, 'NI_ICEController controller2 was not created');  
        
        // CREATE WITH NO MIGRATION DATE
        strAuthKey = iceAuthKey2.MigrationPortalKey__c;        
        iceSub2.Contact__c = cnct.Id;
        update iceSub2;
        
        PageReference pr8 = Page.NI_ICE_Home;  
        pr8.getParameters().put('authkey', strAuthKey);
        pr8.getParameters().put('pageid', 'Test');
        pr8.getParameters().put('stepsaved', '1'); 
        Test.setCurrentPage(pr8); 
        
        NI_ICEController controller3 = new NI_ICEController();
        System.assertNotEquals(controller3, null, 'NI_ICEController controller3 was not created'); 
        
        iceSub2.ScheduledMigrationDate__c = Date.today();
        update iceSub2;
        
        PageReference pr9 = Page.NI_ICE_Home;  
        pr9.getParameters().put('authkey', strAuthKey);
        pr9.getParameters().put('pageid', 'Test');
        pr9.getParameters().put('stepsaved', '1'); 
        Test.setCurrentPage(pr9); 
        
        NI_ICEController controller4 = new NI_ICEController();
        System.assertNotEquals(controller4, null, 'NI_ICEController controller4 was not created');   
        
        Test.stopTest();  // 
        
        
        
        
        // TEST RELATED TRIGGERS =============================================================  
        
        List<ICESubscription__c> lst1 = new List<ICESubscription__c>();
        lst1.Add(iceSub1);
        
        NI_ICESubscription_TriggerHandler handler1 = new NI_ICESubscription_TriggerHandler(true); 
        boolean IsTriggerContext1 = handler1.IsTriggerContext; 
        
        handler1.OnBeforeInsert(lst1); 
        handler1.OnBeforeUpdate(lst1); 
        handler1.OnBeforeDelete(lst1); 
        //handler1.OnAfterInsert(lst1); 
        handler1.OnAfterUpdate(lst1); 
        handler1.OnAfterDelete(lst1); 
        handler1.OnAfterUndelete(lst1); 
        
        List<ICEProperty__c> lst2 = new List<ICEProperty__c>();
        lst2.Add(icePrp1);
        
        NI_ICEProperty_TriggerHandler handler2 = new NI_ICEProperty_TriggerHandler(true); 
        boolean IsTriggerContext2 = handler2.IsTriggerContext; 
        
        //handler2.OnBeforeInsert(lst2); 
        handler2.OnBeforeUpdate(lst2); 
        handler2.OnBeforeDelete(lst2); 
        handler2.OnAfterInsert(lst2); 
        handler2.OnAfterUpdate(lst2); 
        handler2.OnAfterDelete(lst2); 
        handler2.OnAfterUndelete(lst2); 
        
        
        List<ICEUser__c> lst3 = new List<ICEUser__c>();
        lst3.Add(iceUsr1);
        
        NI_ICEUser_TriggerHandler handler3 = new NI_ICEUser_TriggerHandler(true); 
        boolean IsTriggerContext3 = handler3.IsTriggerContext; 
        
        //handler3.OnBeforeInsert(lst3); 
        handler3.OnBeforeUpdate(lst3); 
        handler3.OnBeforeDelete(lst3); 
        handler3.OnAfterInsert(lst3); 
        handler3.OnAfterUpdate(lst3); 
        handler3.OnAfterDelete(lst3); 
        handler3.OnAfterUndelete(lst3); 
        
    }
    
    
}