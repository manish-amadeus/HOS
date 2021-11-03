/****************************************************************************************
Name            : AH_SubsActvn_TriggerHandler_Test Test Class
Author          : Stuart Emery
Created Date    : 09/04/2017
Last Mod Date   : 06/26/2018
Last Mod By     : Stuart Emery
NICC Reference  : NICC-023777
Description     : test Class for AH_SubsActvn_TriggerHandler Class
                : Updated 06/26/2018 per NICC-028487
                : Updated on 9/26/2017 per NICC-024063
                : 
******************************************************************************************/
@isTest
private class AH_SubsActvn_TriggerHandler_Test 
{
    
    // =======================================================================================================================================
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.createTestData() - START ***'); 
        
        test.startTest();  
        
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtSalesOrderId = OpportunityRecordTypeInfo.get('Sales Order').getRecordTypeId(); 
        Id rtHRMAMOId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId(); 
        
        // CREATE A TEST USER WITH THE NI ADMINISTRATOR PROFILE TO USE AS THE RUNAS USER
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        u.FirstName = 'Apex';
        u.LastName = 'Testuser';
        insert u;    
        
        // CREATE A TEST ACCOUNT RECORD FOR THE 'ACCOUNT' FIELD ON THE SUBSCRIPTION ACTIVATION RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST ACCOUNT'; 
        insert a;
        
        // CREATE A TEST ACCOUNT RECORD FOR THE 'PARTNER NAME' FIELD ON THE SUBSCRIPTION ACTIVATION RECORD
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'TEST PARTNER NAME'; 
        insert a2;
        
        // CREATE A TEST ACCOUNT RECORD TO USE TO CHANGE THE 'PARTNER NAME' FIELD ON THE SUBSCRIPTION ACTIVATION RECORD 
        Account a3 = NI_TestClassData.createTestAccount(3);
        a3.Name = 'PARTNER CHANGE TO ACCOUNT'; 
        insert a3;
        
        //CREATE A TEST CONTACT TO BE CREATED AS A PARTNER COMMUNITY USER 
        Contact cnt = NI_TestClassData.createTestContact(1, a2.Id);
        cnt.FirstName = 'Dean';
        cnt.LastName = 'Gulbury';
        cnt.Email = 'dgulbury@amadeushospitality.com';
        insert cnt;
        
        //CREATE A TEST CONTACT TO BE CREATED AS A PARTNER COMMUNITY USER ON THE CHANGE TO PARTNER ACCOUNT
        Contact cnt2 = NI_TestClassData.createTestContact(2, a3.Id);
        cnt2.FirstName = 'Victor';
        cnt2.LastName = 'Hugo';
        cnt2.Email = 'vhugo@amadeushospitality.com';
        insert cnt2;
        
        //CREATE A TEST CONTACT TO BE USED AS THE 'CUSTOMER PROJECT CONTACT' ON THE OPPORTUNITY
        Contact cnt3 = NI_TestClassData.createTestContact(3, a.Id);
        cnt3.FirstName = 'Igor';
        cnt3.LastName = 'Stravinsky';
        cnt3.Email = 'istravinsky@amadeushospitality.com';
        insert cnt3;
        
        // CREATE TEST PARTNER COMMUNITY USER  
        User cu = NI_TestClassData.createTestUser(2, 'AH PartnerCentral User');     
        cu.ContactId = cnt.Id;
        cu.FirstName = 'Dean';
        cu.LastName = 'Gulbury';
        cu.Email = 'dgulbury@amadeushospitality.com';
        cu.Username = 'dgulbury@amadeushospitality.com.test';
        insert cu;
        
        // CREATE TEST PARTNER COMMUNITY USER RELATED TO THE CHANGE TO PARTNER ACCOUNT  
        User cu2 = NI_TestClassData.createTestUser(3, 'AH PartnerCentral User');     
        cu2.ContactId = cnt2.Id;
        cu2.FirstName = 'Victor';
        cu2.LastName = 'Hugo';
        cu2.Email = 'vhugo@amadeushospitality.com';
        cu2.Username = 'vhugo@amadeushospitality.com.test';
        insert cu2;
        
        //CREATE A TEST PRODUCT GROUP
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //CREATE A TEST PRODUCT WITH A VALUE IN THE PARTNER NAME FIELD
        Product2 p = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Support');
        p.Partner_Name__c = a2.Id;
        p.Apttus_Config2__HasOptions__c = false;
        insert p;
        
        //CREATE A TEST PRODUCT WITHOUT A VALUE IN THE PARTNER NAME FIELD
        Product2 p2 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Support');
        p2.Apttus_Config2__HasOptions__c = false;
        insert p2;
        
        //GET THE ID FOR THE STANDARD PRICEBOOK
        Id pbkId = Test.getStandardPricebookId(); 
        
        //CREATE A TEST PRICEBOOK ENTRY RECORD
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(pbkId, p.Id, 1000);
        insert pbe;
        
        //CREATE A TEST PRICEBOOK ENTRY RECORD
        PricebookEntry pbe2 = NI_TestClassData.createTestPricebookEntry(pbkId, p2.Id, 1000);
        insert pbe2;
        
        //CREATE A TEST OPPORTUNITY
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id);
        opp1.RecordTypeId = rtHRMAMOId;
        opp1.Name = 'APEX TEST OPPORTUNITY';
        opp1.Notes_to_Partners__c = 'Apex Note To Partner';
        insert opp1;
        
        //CREATE A TEST CUSTOMER PROJECT CONTACT ROLE ON THE OPPORTUNITY
        OpportunityContactRole ocr = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, cnt3.Id, 'Customer Project Contact');
        insert ocr;        
        
        //CREATE A TEST OPPORTUNITY FOR THE PRODUCT WITHOUT THE PARTNER NAME
        Opportunity opp2 = NI_TestClassData.createTestOpportunity(2, a.Id);
        opp2.RecordTypeId = rtHRMAMOId;
        opp2.Name = 'APEX TEST OPPORTUNITY WITHOUT PARTNER NAME';
        insert opp2;
        
        //CREATE A TEST OPPORTUNITY LINE ITEM FOR THE PRODUCT WITH A PARTNER NAME
        OpportunityLineItem oli = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe.Id, 1);
        insert oli;
        
        //CREATE A TEST OPPORTUNITY LINE ITEM FOR THE PRODUCT WITHOUT A PARTNER NAME
        OpportunityLineItem oli2 = NI_TestClassData.createTestOpportunityLineItem(2, opp2.Id, pbe2.Id, 1);
        insert oli2;
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvn_TriggerHandler_Test.createTestData');  
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.createTestData() - END ***'); 
        test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD BEFORE INSERT WITH PARTNER NAME FIELD UPDATED ON RELATED PRODUCT RECORD: 
    // ======================================================================================================================================= 
    @isTest static void SubActivTrigBeforeInsertWithPartnerName() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigBeforeInsertWithPartnerName() - START ***');
        
        Opportunity opp = [SELECT Id, Notes_to_Partners__c FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'TEST PARTNER NAME'];
        Contact c = [SELECT Id From Contact WHERE LastName = 'Stravinsky'];
        OpportunityContactRole ocr = [SELECT Id, ContactId FROM OpportunityContactRole];
        
        
        // CREATE A TEST SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c sa = NI_TestClassData.createSubscriptionActivation();
        sa.Opportunity__c = opp.Id;
        sa.Product_ID__c = oli.Id;
        insert sa;
        
        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c saInserted = [Select Id, Partner_Name__c, Customer_Contact__c, Notes_to_Partners__c FROM Subscription_Activation__c];
        
        //VERIFY THE PARTNER NAME FIELD ON THE SUBSCRIPTION ACTIVATION MATCHES THE PARTNER NAME ON THE PRODUCT RECORD RELATED TO THE 
        //OPPORTUNITY LINE ITEM ID IN THE PRODUCT_ID__C FIELD
        System.AssertEquals(partnerAccount.Id, saInserted.Partner_Name__c);
        
        //VERIFY THE CUSTOMER CONTACT ON THE SUBSCRIPTION ACTIVATION MATCHES THE CONTACT IN THE CUSTOMER PROJECCT CONTACT ROLE ON THE OPPORTUNITY
        System.AssertEquals(ocr.ContactId, saInserted.Customer_Contact__c);
        
        //VERIFY THE NOTES TO PARTNERS FIELD ON THE SUBSCRIPTION ACTIVATION MATCHES THE NOTES TO PARTNERS FIELD ON THE RELATED OPPORTUNITY
        System.AssertEquals('Apex Note To Partner', saInserted.Notes_to_Partners__c);
        
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvn_TriggerHandler_Test.SubActivTrigBeforeInsertWithPartnerName');        
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigTest1() - END ***'); 
        test.stopTest();  
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD BEFORE INSERT WITHOUT PARTNER NAME FIELD UPDATED ON RELATED PRODUCT RECORD: 
    // ======================================================================================================================================= 
    @isTest static void SubActivTrigBeforeInsertWithoutPartnerName() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigBeforeInsertWithoutPartnerName() - START ***');
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY WITHOUT PARTNER NAME'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'TEST PARTNER NAME'];
        
        
        // CREATE A TEST SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c sa = NI_TestClassData.createSubscriptionActivation();
        sa.Opportunity__c = opp.Id;
        sa.Product_ID__c = oli.Id;
        insert sa;
        
        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c saInserted = [Select Id, Partner_Name__c FROM Subscription_Activation__c];
        
        
        //VERIFY THE PARTNER NAME FIELD ON THE SUBSCRIPTION ACTIVATION IS NULL
        System.AssertEquals(null, saInserted.Partner_Name__c);
        
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvn_TriggerHandler_Test.SubActivTrigBeforeInsertWithoutPartnerName');        
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigTest1() - END ***'); 
        test.stopTest();  
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD AFTER INSERT: 
    // ======================================================================================================================================= 
    @isTest static void SubActivTrigAfterInsert() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigAfterInsert() - START ***');
        
        //POPULATE THE CUSTOM SETTING THAT IS REFERENCED BY THE SHARING METHOD
        AH_Partner_Community_Record_Share__c cs = new AH_Partner_Community_Record_Share__c();
        cs.Name = 'AH PartnerCentral User';
        insert cs;
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'TEST PARTNER NAME'];
        User partnerUser = [SELECT Id FROM User WHERE Username = 'dgulbury@amadeushospitality.com.test'];
        
        
        // CREATE A TEST SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c sa = NI_TestClassData.createSubscriptionActivation();
        sa.Opportunity__c = opp.Id;
        sa.Product_ID__c = oli.Id;
        insert sa;
        
        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c saInserted = [SELECT Id, Partner_Name__c FROM Subscription_Activation__c];
        
        //VERIFY THE 'Partner_Community_User_Share' METHOD IN THE 'AH_SubsActvn_TriggerHandler' Class
        List<Subscription_Activation__Share> lstSaShares = [SELECT Id 
                                                            FROM Subscription_Activation__Share 
                                                            WHERE ParentId =: saInserted.Id
                                                            AND UserOrGroupId =: partnerUser.Id
                                                            AND RowCause = 'Partner_Community_User_Share__c'];
        
        System.AssertEquals(1, lstSaShares.size());
        
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvn_TriggerHandler_Test.SubActivTrigAfterInsert');        
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigTest1() - END ***'); 
        test.stopTest();  
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD AFTER INSERT WITHOUT PARTNER COMMUNITY USER PROFILE RECORD SHARE CUSTOM SETTING: 
    // ======================================================================================================================================= 
    @isTest static void SubActivTrigAfterInsertNoCustomSetting() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigAfterInsertNoCustomSetting() - START ***');
        
        //POPULATE THE CUSTOM SETTING THAT IS REFERENCED BY THE SHARING METHOD
        //AH_Partner_Community_Record_Share__c cs = new AH_Partner_Community_Record_Share__c();
        //cs.Name = 'AH PartnerCentral User';
        //insert cs;
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'TEST PARTNER NAME'];
        User partnerUser = [Select Id FROM User WHERE Username = 'dgulbury@amadeushospitality.com.test'];
        
        
        // CREATE A TEST SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c sa = NI_TestClassData.createSubscriptionActivation();
        sa.Opportunity__c = opp.Id;
        sa.Product_ID__c = oli.Id;
        insert sa;
        
        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c saInserted = [Select Id, Partner_Name__c FROM Subscription_Activation__c];
        
        //VERIFY THE 'Partner_Community_User_Share' METHOD IN THE 'AH_SubsActvn_TriggerHandler' Class
        List <Subscription_Activation__Share> lstSaShares = [SELECT Id 
                                                             FROM Subscription_Activation__Share 
                                                             WHERE ParentId =: saInserted.Id
                                                             AND UserOrGroupId =: partnerUser.Id
                                                             AND RowCause = 'Partner_Community_User_Share__c'];
        
        System.AssertEquals(0, lstSaShares.size());
        
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvn_TriggerHandler_Test.SubActivTrigAfterInsertNoCustomSetting');        
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigAfterInsertNoCustomSetting() - END ***'); 
        test.stopTest();  
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD AFTER UPDATE: 
    // ======================================================================================================================================= 
    @isTest static void SubActivTrigAfterUpdate() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigAfterUpdate() - START ***');
        
        //POPULATE THE CUSTOM SETTING THAT IS REFERENCED BY THE SHARING METHOD
        AH_Partner_Community_Record_Share__c cs = new AH_Partner_Community_Record_Share__c();
        cs.Name = 'AH PartnerCentral User';
        insert cs;
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        Account partnerAccount1 = [SELECT Id FROM Account WHERE Name = 'TEST PARTNER NAME'];
        Account partnerAccount2 = [SELECT Id FROM Account WHERE Name = 'PARTNER CHANGE TO ACCOUNT'];
        User partnerUser = [Select Id FROM User WHERE Username = 'dgulbury@amadeushospitality.com.test'];
        User partnerUserChangeTo = [Select Id FROM User WHERE Username = 'vhugo@amadeushospitality.com.test'];
        
        
        // CREATE A TEST SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c sa = NI_TestClassData.createSubscriptionActivation();
        sa.Opportunity__c = opp.Id;
        sa.Product_ID__c = oli.Id;
        insert sa;
        
        sa.Partner_Name__c = partnerAccount2.Id;
        update sa;
        
        
        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c saInserted = [Select Id, Partner_Name__c FROM Subscription_Activation__c];
        
        //VERIFY THE 'Partner_Community_User_Share' METHOD IN THE 'AH_SubsActvn_TriggerHandler' Class
        //VERIFY THE PARTNER COMMUNITY USER SHARES HAVE BEEN REMOVED FOR USER RELATED TO THE ORIGINAL PARTNER ACCOUNT
        List <Subscription_Activation__Share> lstSaSharesRemove = [SELECT Id 
                                                                   FROM Subscription_Activation__Share 
                                                                   WHERE ParentId =: saInserted.Id
                                                                   AND UserOrGroupId =: partnerUser.Id
                                                                   AND RowCause = 'Partner_Community_User_Share__c'];
        
        System.AssertEquals(0, lstSaSharesRemove.size());
        
        
        //VERIFY THE 'Partner_Community_User_Share' METHOD IN THE 'AH_SubsActvn_TriggerHandler' Class
        //VERIFY THE PARTNER COMMUNITY USER SHARES HAVE BEEN ADDED FOR USER RELATED TO THE 'CHANGE TO' PARTNER ACCOUNT
        List <Subscription_Activation__Share> lstSaSharesAdd = [SELECT Id 
                                                                FROM Subscription_Activation__Share 
                                                                WHERE ParentId =: saInserted.Id
                                                                AND UserOrGroupId =: partnerUserChangeTo.Id
                                                                AND RowCause = 'Partner_Community_User_Share__c'];
        
        System.AssertEquals(1, lstSaSharesAdd.size());
        
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvn_TriggerHandler_Test.SubActivTrigAfterUpdate');        
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigTest1() - END ***'); 
        test.stopTest();  
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD AFTER UPDATE PARTNER NAME IS SET TO NULL: 
    // ======================================================================================================================================= 
    @isTest static void SubActivTrigAfterUpdateNoPartnerName() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigAfterUpdateNoPartnerName() - START ***');
        
        //POPULATE THE CUSTOM SETTING THAT IS REFERENCED BY THE SHARING METHOD
        AH_Partner_Community_Record_Share__c cs = new AH_Partner_Community_Record_Share__c();
        cs.Name = 'AH PartnerCentral User';
        insert cs;
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        Account partnerAccount1 = [SELECT Id FROM Account WHERE Name = 'TEST PARTNER NAME'];
        //Account partnerAccount2 = [SELECT Id FROM Account WHERE Name = 'PARTNER CHANGE TO ACCOUNT'];
        User partnerUser = [Select Id FROM User WHERE Username = 'dgulbury@amadeushospitality.com.test'];
        User partnerUserChangeTo = [Select Id FROM User WHERE Username = 'vhugo@amadeushospitality.com.test'];
        
        
        // CREATE A TEST SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c sa = NI_TestClassData.createSubscriptionActivation();
        sa.Opportunity__c = opp.Id;
        sa.Product_ID__c = oli.Id;
        sa.Partner_Name__c = partnerAccount1.Id;
        insert sa;
        
        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c saInserted = [Select Id, Partner_Name__c FROM Subscription_Activation__c];
        
        //VERIFY THE 'Partner_Community_User_Share' METHOD IN THE 'AH_SubsActvn_TriggerHandler' Class
        List <Subscription_Activation__Share> lstExistingShares = [SELECT Id 
                                                                   FROM Subscription_Activation__Share 
                                                                   WHERE ParentId =: saInserted.Id
                                                                   AND UserOrGroupId =: partnerUser.Id
                                                                   AND RowCause = 'Partner_Community_User_Share__c'];
        
        System.AssertEquals(1, lstExistingShares.size());
        
        
        //SET THE PARTNER NAME TO NULL
        sa.Partner_Name__c = null;
        update sa;
        
        
        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c saUpdated = [Select Id, Partner_Name__c FROM Subscription_Activation__c];
        
        //VERIFY THE 'Partner_Community_User_Share' METHOD IN THE 'AH_SubsActvn_TriggerHandler' Class
        //VERIFY THE PARTNER COMMUNITY USER SHARES HAVE BEEN REMOVED FOR USER RELATED TO THE ORIGINAL PARTNER ACCOUNT
        List <Subscription_Activation__Share> lstSaSharesRemoved = [SELECT Id 
                                                                    FROM Subscription_Activation__Share 
                                                                    WHERE ParentId =: saUpdated.Id
                                                                    AND UserOrGroupId =: partnerUser.Id
                                                                    AND RowCause = 'Partner_Community_User_Share__c'];
        
        System.AssertEquals(0, lstSaSharesRemoved.size());
        
        
        //VERIFY THE 'Partner_Community_User_Share' METHOD IN THE 'AH_SubsActvn_TriggerHandler' Class
        List <Subscription_Activation__Share> lstSaSharesAdd = [SELECT Id 
                                                                FROM Subscription_Activation__Share 
                                                                WHERE ParentId =: saInserted.Id
                                                                AND UserOrGroupId =: partnerUserChangeTo.Id
                                                                AND RowCause = 'Partner_Community_User_Share__c'];
        
        //NO SHARES SHOULD HAVE BEEN ADDED
        System.AssertEquals(0, lstSaSharesAdd.size());
        
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvn_TriggerHandler_Test.SubActivTrigAfterUpdateNoPartnerName');        
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigTest1() - END ***'); 
        test.stopTest();  
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD AFTER UPDATE WITHOUT PARTNER COMMUNITY USER PROFILE RECORD SHARE CUSTOM SETTING: 
    // ======================================================================================================================================= 
    @isTest static void SubActivTrigAfterUpdateNoCustomSetting() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigAfterUpdateNoCustomSetting() - START ***');
        
        //POPULATE THE CUSTOM SETTING THAT IS REFERENCED BY THE SHARING METHOD
        //AH_Partner_Community_Record_Share__c cs = new AH_Partner_Community_Record_Share__c();
        //cs.Name = 'AH PartnerCentral User';
        //insert cs;
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        Account partnerAccount1 = [SELECT Id FROM Account WHERE Name = 'TEST PARTNER NAME'];
        Account partnerAccount2 = [SELECT Id FROM Account WHERE Name = 'PARTNER CHANGE TO ACCOUNT'];
        User partnerUser = [Select Id FROM User WHERE Username = 'dgulbury@amadeushospitality.com.test'];
        User partnerUserChangeTo = [Select Id FROM User WHERE Username = 'vhugo@amadeushospitality.com.test'];
        
        
        // CREATE A TEST SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c sa = NI_TestClassData.createSubscriptionActivation();
        sa.Opportunity__c = opp.Id;
        sa.Product_ID__c = oli.Id;
        insert sa;
        
        sa.Partner_Name__c = partnerAccount2.Id;
        update sa;
        
        
        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c saInserted = [Select Id, Partner_Name__c FROM Subscription_Activation__c];
        
        //VERIFY THE 'Partner_Community_User_Share' METHOD IN THE 'AH_SubsActvn_TriggerHandler' Class
        //VERIFY THE PARTNER COMMUNITY USER SHARES HAVE BEEN REMOVED FOR USER RELATED TO THE ORIGINAL PARTNER ACCOUNT
        List <Subscription_Activation__Share> lstSaSharesRemove = [SELECT Id 
                                                                   FROM Subscription_Activation__Share 
                                                                   WHERE ParentId =: saInserted.Id
                                                                   AND UserOrGroupId =: partnerUser.Id
                                                                   AND RowCause = 'Partner_Community_User_Share__c'];
        
        System.AssertEquals(0, lstSaSharesRemove.size());
        
        
        //VERIFY THE 'Partner_Community_User_Share' METHOD IN THE 'AH_SubsActvn_TriggerHandler' Class
        List <Subscription_Activation__Share> lstSaSharesAdd = [SELECT Id 
                                                                FROM Subscription_Activation__Share 
                                                                WHERE ParentId =: saInserted.Id
                                                                AND UserOrGroupId =: partnerUserChangeTo.Id
                                                                AND RowCause = 'Partner_Community_User_Share__c'];
        
        //NO SHARES SHOULD HAVE BEEN ADDED SINCE THERE ARE NO RECORDS IN THE CUSTOM SETTING
        System.AssertEquals(0, lstSaSharesAdd.size());
        
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvn_TriggerHandler_Test.SubActivTrigAfterUpdateNoCustomSetting');        
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubActivTrigTest1() - END ***'); 
        test.stopTest();  
        
    }
    
    // ======================================================================================================================================= 
    // = BULK TEST METHOD AFTER INSERT: 
    // ======================================================================================================================================= 
    @isTest static void SubBulkActivTrigAfterInsert() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubBulkActivTrigAfterInsert() - START ***');
        
        //POPULATE THE CUSTOM SETTING THAT IS REFERENCED BY THE SHARING METHOD
        AH_Partner_Community_Record_Share__c cs = new AH_Partner_Community_Record_Share__c();
        cs.Name = 'AH PartnerCentral User';
        insert cs;
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'TEST PARTNER NAME'];
        User partnerUser = [Select Id FROM User WHERE Username = 'dgulbury@amadeushospitality.com.test'];
        
         //BULK INSERT SUBSCRIPTION ACTIVATION RECORDS
        List<Subscription_Activation__c> lstToInsert = new List<Subscription_Activation__c>();
        
        for(Integer i = 3 ; i < 203 ; i++){
            Subscription_Activation__c sa = NI_TestClassData.createSubscriptionActivation();
            sa.Opportunity__c = opp.Id;
            sa.Product_ID__c = oli.Id;
            lstToInsert.add(sa);
        }
        
        insert lstToInsert;
   
        
        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        List<Subscription_Activation__c> lstSaInserted = [Select Id, Partner_Name__c FROM Subscription_Activation__c];
        
        //VERIFY 200 SUBSCRIPTION ACTIVATION RECORDS WERE INSERTED
        System.AssertEquals(200, lstSaInserted.size());
        
        Set<Id> setSaIds = new Set<Id>();
        
        for(Subscription_Activation__c sa2 : lstSaInserted)
        {
          setSaIds.add(sa2.Id);  
        }
        
        //VERIFY THE 'Partner_Community_User_Share' METHOD IN THE 'AH_SubsActvn_TriggerHandler' Class
        List <Subscription_Activation__Share> lstSaShares = [SELECT Id 
                                                             FROM Subscription_Activation__Share 
                                                             WHERE ParentId IN: setSaIds
                                                             AND UserOrGroupId =: partnerUser.Id
                                                             AND RowCause = 'Partner_Community_User_Share__c'];
        
        System.AssertEquals(200, lstSaShares.size());
        
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvn_TriggerHandler_Test.SubBulkActivTrigAfterInsert');        
        system.debug(' *** AH_SubsActvn_TriggerHandler_Test.SubBulkActivTrigAfterInsert() - END ***'); 
        test.stopTest();  
        
    }
    
}