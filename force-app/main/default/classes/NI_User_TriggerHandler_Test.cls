/****************************************************************************************************************************
Name            : NI_User_TriggerHandler_Test Class
Author          : Stuart Emery
Created Date    : 03/30/2015
Last Mod Date   : 04/18/2020 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class for the NI_User_TriggerHandler
                : 






				MOVED TO AH_User_TriggerHandler_Test









****************************************************************************************************************************/
@isTest
private class NI_User_TriggerHandler_Test 
{
    
    // =====================================================================================================================
    //   CREATE TEST DATA 
    // =====================================================================================================================
    @testSetup static void createTestData() 
    {
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX NI_User_TriggerHandler_Test';
        insert a;     
    }
    
    @isTest static void test1()
    {
        Test.startTest();
        NI_User_TriggerHandler ctrl = new NI_User_TriggerHandler();
        system.assert(true);
        Test.stopTest();
    }
    
    
/*        
        Account a;
        Contact cnt;
        
        test.startTest();
        
        // CREATE A COMMUNITY USER
        User u1 = NI_TestClassData.createTestUser(1024, 'System Administrator');
        u1.Alias = 'APEXSYSU';
        u1.UserRoleId = [SELECT Id FROM UserRole WHERE Name LIKE 'CEO%' LIMIT 1].Id;
        insert u1; 
        
        system.runAs(u1)
        {
            
            a = NI_TestClassData.createTestAccount(1);
            a.Name = 'APEX NI_User_TriggerHandler_Test';
            insert a;       
            
            cnt = NI_TestClassData.createTestContact(1, a.Id);
            cnt.FirstName = 'Mike';
            cnt.LastName = 'Oxmaul';
            cnt.Email = 'CXLTEST1@amadeushospitality.com';
            cnt.Title = 'Junior Janitor'; 
            cnt.MailingStreet = '123 Street';   
            cnt.MailingState = 'NH';   
            cnt.MailingCity = 'Sometown';   
            cnt.MailingPostalCode = '04891';   
            cnt.MailingCountry = 'US';   
            cnt.Phone = '603-555-0001';   
            cnt.MobilePhone = '603-555-0002';   
            cnt.Fax = '603-555-0003';  
            insert cnt;
            
        }
        
        // CREATE TEST CUSTOMER PORTAL USER 
        User cu = NI_TestClassData.createTestUser(2, 'AH Customer Community Plus Login User'); 
        cu.ContactId = cnt.Id;
        //cu.UserRoleId = [SELECT Id FROM UserRole WHERE Name LIKE 'APEX NI_User_TriggerHandler_Test%' LIMIT 1].Id;
        cu.Alias = 'CXLTEST1';
        cu.Email = 'CXLTEST1@amadeushospitality.com';
        cu.Username = 'moxmaul@newmarketinc.com.ahcc';
        cu.CommunityNickname = 'CXLTEST1'; 
        cu.FirstName = 'Mike';
        cu.LastName = 'Oxmaul';
        cu.Email = 'CXLTEST1@amadeushospitality.com';
        cu.Title = 'Junior Janitor'; 
        cu.Street = '123 Street';   
        cu.State = 'NH';   
        cu.City = 'Sometown'; 
        cu.PostalCode = '04891';   
        cu.Country = 'US'; 
        cu.Phone = '603-555-0001'; 
        cu.MobilePhone = '603-555-0002'; 
        cu.Fax = '603-555-0003'; 
        insert cu; 
        
        // CREATE TEST USERS
        List<User> lstUserInsert = new List<User>();
        
        User u2 = NI_TestClassData.createTestUser(1025, 'NI Sales');
        u2.ManagerId = u1.Id;
        u2.Alias = 'APEXSLSU'; 
        lstUserInsert.Add(u2);   
        
        User u3 = NI_TestClassData.createTestUser(1026, 'NI Support CSR');
        u3.ManagerId = u2.Id;
        u3.Alias = 'APEXSPTU'; 
        lstUserInsert.Add(u3);
        
        User u4 = NI_TestClassData.createTestUser(1027, 'NI Administrator');
        u4.Alias = 'APEXINVU';
        lstUserInsert.Add(u4); 
        
        User u5 = NI_TestClassData.createTestUser(1028, 'NI Administrator');
        u5.Alias = 'APEXUSR1';
        //u5.FFA_Company__c = 'Newmarket AP';
        //u5.FFA_Dimension_3__c = '000 - BALANCE SHEET';
        //u5.FFA_Dimension_2__c = 'AIP';        
        //u5.Cost_Ctr__c = '12345';        
        lstUserInsert.Add(u5); 
        
        User u6 = NI_TestClassData.createTestUser(1029, 'NI Administrator');
        u6.Alias = 'APEXUSR2';
        //u6.FirstName = 'Dummy';
        //u6.FFA_Company__c = 'Newmarket US';
        //u6.FFA_Dimension_3__c = '100 - FINANCE - ACCOUNTING';
        //u6.FFA_Dimension_2__c = 'Amadeus';             
        lstUserInsert.Add(u6); 
        
        Database.insert(lstUserInsert);         
        
        test.stopTest();
        
    }
    
    //======================================================================================================================
    //  TEST USER PROFILE SELECTION VALIDATION
    //======================================================================================================================
    @isTest static void test1()
    {
        
        User cu = [SELECT Id FROM User WHERE Username = 'moxmaul@newmarketinc.com.ahcc'];
        
        User u = [SELECT ContactId, Email, FirstName, LastName, Title, Street, State, City, PostalCode, Country, Phone, MobilePhone, Fax 
                  FROM User 
                  WHERE IsActive = true 
                  AND Id =: cu.Id];
        
        system.runAs(cu)
        {
            u.FirstName = 'Michael';
            u.LastName = 'Hunt';
            u.Email = 'mhunt.CXLTEST@amadeushospitality.com';
            u.Title = 'Senior Janitor'; 
            u.Street = '456 Street'; 
            u.State = 'MA';   
            u.City = 'Gloucester';   
            u.PostalCode = '04501';   
            u.Country = 'US';   
            u.Phone = '603-555-0004';   
            u.MobilePhone = '603-555-0005';   
            u.Fax = '603-555-0006';  
            update u;
        }
        
    }
    
    //======================================================================================================================
    //  TEST USER PROFILE SELECTION VALIDATION
    //======================================================================================================================
   @isTest static void test2()
    {

        test.startTest();
        
        // CREATE TEST ACCOUNT RECORDS 
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();         
        Id rtPartnerAccountId = AccountRecordTypeInfo.get('Partner Account').getRecordTypeId();    
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();    
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'FA261ED8-AC9F-421D-AAB4-38A344A1BE44 Partner';
        a1.RecordTypeId = rtPartnerAccountId;
        insert a1;
        
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = '42A3C729-2341-40F5-83FC-49136913C423 Property';
        a2.RecordTypeId = rtPropertyAccountId;
        insert a2;        
        
        // CREATE TEST CONTACT RECORDS
        List<Contact> lstContactInsert = new List<Contact>();
        
        Contact c1 = NI_TestClassData.createTestContact(1, a1.Id);
        c1.FirstName = 'Partner';
        c1.LastName = 'Customer';
        c1.Email = 'partnercustomer@somedomain.com';
        lstContactInsert.Add(c1); 
        
        Contact c2 = NI_TestClassData.createTestContact(2, a2.Id);
        c2.FirstName = 'Support';
        c2.LastName = 'Customer';
        c2.Email = 'supportcustomer@somedomain.com';
        lstContactInsert.Add(c2);      
        
        Database.insert(lstContactInsert);  
        
        test.stopTest();        
        
        User uSysAdm = [SELECT Id FROM User WHERE Alias = 'APEXSYSU'];
        User uSlsUsr = [SELECT Id FROM User WHERE Alias = 'APEXSLSU'];
        User uSptTch = [SELECT Id FROM User WHERE Alias = 'APEXSPTU'];
        User uInvUsr = [SELECT Id FROM User WHERE Alias = 'APEXINVU'];
        User uSptTch2 = [SELECT Id FROM User WHERE Alias = 'CXLTEST1'];
        Contact cPrtCnt = [SELECT Id FROM Contact WHERE Email = 'partnercustomer@somedomain.com'];
        Contact cSptCnt = [SELECT Id FROM Contact WHERE Email = 'supportcustomer@somedomain.com'];
        
        // ASSERT USERS PROFILES
        Profile pPartPrf = [SELECT Id, UserType FROM Profile WHERE Name = 'AH PartnerCentral Login User'];   
        system.debug('pPartPrf.UserType    :' + pPartPrf.UserType);
        system.assertEquals('PowerPartner', pPartPrf.UserType);
        
        Profile pSuptPrf = [SELECT Id, UserType FROM Profile WHERE Name = 'AH Customer Community Plus Login User'];        
        system.debug('pPartPrf.UserType    :' + pPartPrf.UserType);
        system.assertEquals('PowerCustomerSuccess', pSuptPrf.UserType);
        
        Profile pInvSuptPrf = [SELECT Id, UserType FROM Profile WHERE Name = 'AH Customer Community Plus User']; 
        system.debug('pPartPrf.UserType    :' + pPartPrf.UserType);
        system.assertEquals('PowerCustomerSuccess', pSuptPrf.UserType);
        
        Profile pSalesPrf = [SELECT Id, UserType FROM Profile WHERE Name = 'AH Customer Community Plus Login - No Chatter']; 
        system.debug('pPartPrf.UserType    :' + pPartPrf.UserType);
        system.assertEquals('PowerCustomerSuccess', pSalesPrf.UserType);
        
        User u1 = NI_TestClassData.createTestUser(1, 'AH PartnerCentral Login User');
        u1.Username = 'user1@NI_User_TriggerHandler_Test.com.ahcc';        
        
        User u2 = NI_TestClassData.createTestUser(2, 'AH Customer Community Plus Login User');
    	u2.Username = 'user2@NI_User_TriggerHandler_Test.com.ahcc';
        
        system.runAs(uSlsUsr)
        {
            
            u1.ProfileId = pPartPrf.Id;
            u1.ContactId = cSptCnt.Id;
            u1.Partner_Permissions__c = 'Cendyn';
            u1.Partner_Terms_Accepted__c = 'True';
            
            
            // CREATING A USER WITH A FORBIDDEN PROFILE
            try 
            {
                insert u1; 
                system.assert(false, 'THIS OPERATION SHOULD HAVE BEEN BLOCKED!');
            }
            catch (Exception e1)
            {
                Boolean bIsExpectedErr1 = e1.getMessage().contains('You do not have permission to create or save a user with the profile of');
                system.AssertEquals(true, bIsExpectedErr1, 'Actual Error: ' + e1.getMessage());
            }  
            
            // CREATING A USER WITH AN ALLOWED PROFILE
            try 
            {
                u1.ProfileId = pSalesPrf.Id;
                insert u1; 
            }
            catch (Exception e2)
            {
                Boolean bIsExpectedErr2 = e2.getMessage().contains('You do not have permission to create or save a user with the profile of');
                system.AssertEquals(false, bIsExpectedErr2, 'Actual Error: ' + e2.getMessage());   
            } 
            
        }

        system.runAs(uSptTch)
        {
            
            u2.ProfileId = pPartPrf.Id;
            u2.ContactId = cSptCnt.Id;
            
            // CREATING A USER WITH A FORBIDDEN PROFILE
            try 
            {
                insert u2; 
                system.assert(false, 'THIS OPERATION SHOULD HAVE BEEN BLOCKED!');
            }
            catch (Exception e3)
            {
                Boolean bIsExpectedErr3 = e3.getMessage().contains('You do not have permission to create or save a user with the profile of AH PartnerCentral Login User');
                system.AssertEquals(true, bIsExpectedErr3, 'Actual Error: ' + e3.getMessage());
            }  
            
            // CREATING A USER WITH AN ALLOWED PROFILE
            try 
            {
                u2.ProfileId = pSuptPrf.Id;
                insert u2;                    
            }
            catch (Exception e4)
            {
                Boolean bIsExpectedErr4 = e4.getMessage().contains('You do not have permission to create or save a user with the profile of');
                system.AssertEquals(false, bIsExpectedErr4, 'Actual Error: ' + e4.getMessage());
            } 
            
        }      
        
        system.runAs(uInvUsr)
        {
            
            User u3 = [SELECT Id FROM User WHERE Username = 'moxmaul@newmarketinc.com.ahcc'];
            
            // UPDATING A USER WITH A MISSING CUSTOM METADATA TYPE
            try 
            {
                u3.ProfileId = pSuptPrf.Id;
                update u3;                    
            }
            catch (Exception e5)
            {
                Boolean bIsExpectedErr5 = e5.getMessage().contains('Your profile "NI Administrator" does not have permission to create or save user records');
                system.AssertEquals(true, bIsExpectedErr5, 'Actual Error: ' + e5.getMessage());
            } 
            
        } 
                       
        // ASSERT THAT SYSTEM ADMIN CAN CHANGE PROFILES
        system.runAs(uSysAdm)
        {
            User u4 = [SELECT Id FROM User WHERE ContactId =: cSptCnt.Id];
            u4.ProfileId = pInvSuptPrf.Id;
            update u4;
            List<User> lstUserAsserts = new List<User>([SELECT Id, ProfileId FROM User WHERE ContactId =: cSptCnt.Id AND ProfileId =: pInvSuptPrf.Id]);
            system.assertEquals(1, lstUserAsserts.size());
        } 
        
        // ASSERT THAT A USER CAN CHANGE THEIR OWN USER RECORD
        system.runAs(uSptTch)
        {
            
            User u5 = [SELECT Id, Phone FROM User WHERE Id =: uSptTch.Id];
            
            try 
            {
                u5.Phone = '603-123-4567';
                update u5;                    
            }
            catch (Exception e5)
            {
                system.Assert(false, e5.getMessage());
            } 
            
        }
        
    }
    
    //======================================================================================================================
    //  TEST USER FREEZING USER
    //======================================================================================================================    
    @isTest static void test3() 
    {
        
        //CREATE A TEST USER RECORD
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        insert u;
        
        Test.startTest();
        {
            u.Freeze_User__c = true;
            update u;  
        }
        Test.stopTest();
        
        //VERIFY THAT THE USER RECORD IS FROZEN  
        List<UserLogin> lstUserLogin = [SELECT Id, UserId, IsFrozen 
                                        FROM UserLogin 
                                        WHERE IsFrozen = true 
                                        AND UserId =: u.Id];
        
        system.assertEquals(1, lstUserLogin.size());
        
    }
    
    //======================================================================================================================
    //  CHANGE MANAGER PERFORMANCE EVALUATION SHARE TEST METHOD
    //======================================================================================================================
    @isTest static void test4() 
    {
        
        User u = [SELECT Id FROM User WHERE Alias = 'APEXSYSU'];
        User u1 = [SELECT Id FROM User WHERE Alias = 'APEXSLSU'];
        User u2 = [SELECT Id FROM User WHERE Alias = 'APEXSPTU'];
        User u3 = [SELECT Id FROM User WHERE Alias = 'APEXINVU'];
        User mgr = [SELECT Id FROM User WHERE Alias = 'APEXUSR1'];
        User colMgr = [SELECT Id FROM User WHERE Alias = 'APEXUSR2'];
        
        //CREATE A TEST PERFORMANCE EVALUATION RECORD
        NI_Employee_Performance_Evaluation__c perfEval1 = NI_TestClassData.createEmployee_Performance_Evaluation(mgr.Id, colMgr.Id);   
        
        perfEval1.OwnerId = u3.Id;
        perfEval1.Employee_Name__c = u3.Id;
        perfEval1.Status__c = 'Employee Draft'; 
        perfEval1.Time_in_Position__c = '300';
        insert perfEval1;
        
        Test.startTest();
        
        system.runAs(u)
        {
            u3.ManagerId = u2.Id;
            update u3;  
        }
        
        Test.stopTest();
        
        // LIST OF MANAGER CHANGE PERFORMANCE EVALUATION SHARES
        List<NI_Employee_Performance_Evaluation__Share> lstManagerChangeShare = new List<NI_Employee_Performance_Evaluation__Share>([
            SELECT Id
            FROM NI_Employee_Performance_Evaluation__Share
            WHERE ParentId =: perfEval1.Id AND
            RowCause = 'Manager_Change__c'
            AND UserOrGroupId =: u2.Id]);
        
        system.assertEquals(1, lstManagerChangeShare.size());
        
        //INVOKE THE MANAGER CHANGE LOGIC ONE MORE TIME
        system.runAs(u)
        {        
            u3.ManagerId = u.Id;
            update u3;
        }
        
        // LIST OF MANAGER HIERARCHY PERFORMANCE EVALUATION SHARES
        //        List<NI_Employee_Performance_Evaluation__Share> lstManagerHierarchyShare = new List<NI_Employee_Performance_Evaluation__Share>([
        //        SELECT Id
        //        FROM NI_Employee_Performance_Evaluation__Share
        //        WHERE ParentId =: perfEval1.Id AND
        //        RowCause = 'Manager_Hierarchy_Share__c']);        
        //        system.assertEquals(2, lstManagerHierarchyShare.size());        
        
    }
    
    //======================================================================================================================
    //  AH User Cost Control information from Amadeus Mapping - Sprint-00077 
    // =====================================================================================================================  
    @isTest static void test5()         
    {      
        
        User u = [SELECT Id FROM User WHERE Alias = 'APEXSYSU']; 
        User u1 = [SELECT Id FROM User WHERE Alias = 'APEXUSR1']; 
        User u2 = [SELECT Id FROM User WHERE Alias = 'APEXUSR2']; 
        User usr = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()]; 
        

        // INSERT TEST DIMENSIONS 
        c2g__codaDimension2__c dim2 = NI_TestClassData.createTestDimension2();
        dim2.Name = 'AIP';
        dim2.c2g__ReportingCode__c = 'TESTDIM2a';        
        insert dim2;
        
        c2g__codaDimension2__c dim12 = NI_TestClassData.createTestDimension2();
        dim12.Name = 'Amadeus';
        dim12.c2g__ReportingCode__c = 'TESTDIM2b';            
        insert dim12;
        
        c2g__codaDimension3__c dim3 = NI_TestClassData.createTestDimension3();
        dim3.Name = '000 - BALANCE SHEET';
        dim3.c2g__ReportingCode__c = 'TESTDIM3a';          
        insert dim3;   
        
        c2g__codaDimension3__c dim13 = NI_TestClassData.createTestDimension3();
        dim13.Name = '190 - FINANCE - CONTROLLING';
        dim13.c2g__ReportingCode__c = 'TESTDIM3b';           
        insert dim13;  
        
        
        //c2g__codaDimension2__c dim2 = new c2g__codaDimension2__c(Name='AIP', c2g__ReportingCode__c = 'Test code');
        //insert dim2;
        
        //c2g__codaDimension2__c dim12 = new c2g__codaDimension2__c(Name='Amadeus', c2g__ReportingCode__c = 'Test code1');
        //insert dim12;
             
        //c2g__codaDimension3__c dim3 = new c2g__codaDimension3__c(Name='000 - BALANCE SHEET', c2g__ReportingCode__c = 'Test code');
        //insert dim3;
        
        //c2g__codaDimension3__c dim13 = new c2g__codaDimension3__c(Name='100 - FINANCE - ACCOUNTING', c2g__ReportingCode__c = 'Test code1');
        //insert dim13;
        
        // Test data for Company        
        //RecordType rt_id = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'c2g__codaCompany__c' LIMIT 1];
        
        Id rtVAT = Schema.SObjectType.c2g__codaCompany__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
        
        c2g__codaCompany__c com = new c2g__codaCompany__c(RecordTypeID = rtVAT, Name='Newmarket AP', c2g__SalesTaxCompanyCode__c = 'Test Tax1');
        insert com;   
        
        //RecordType rt_id1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'c2g__codaCompany__c' LIMIT 1];
        Id rtSUT = Schema.SObjectType.c2g__codaCompany__c.getRecordTypeInfosByName().get('SUT').getRecordTypeId();
        
        c2g__codaCompany__c com1 = new c2g__codaCompany__c(RecordTypeID = rtSUT, Name='Newmarket US', c2g__SalesTaxCompanyCode__c = 'Test Tax1');
        insert com1;        
        
        // Test data for Amadeus
        Amadeus_Mapping_Table__c amd = new Amadeus_Mapping_Table__c(FFA_Company__c = com.id, Cost_Center_Dim_3__c = dim3.id, Business_Line_Dim_2__c = dim2.id, Output__c = '12345', Mapping_Type__c = 'BPC COST CENTER');
        insert amd;
        
        Amadeus_Mapping_Table__c amd1 = new Amadeus_Mapping_Table__c(FFA_Company__c = com1.id, Cost_Center_Dim_3__c = dim13.id, Business_Line_Dim_2__c = dim12.id, Output__c = null, Mapping_Type__c = 'BPC COST CENTER');
        insert amd1;
        
        Test.startTest();
        
        system.runAs(u)
        {
            
            u1.FFA_Company__c = 'Newmarket AP';
            u1.FFA_Dimension_3__c = '000 - BALANCE SHEET';
            u1.FFA_Dimension_2__c = 'AIP';        
            u1.Cost_Ctr__c = '12345';
            update u1;   
            
            u2.FirstName = 'Dummy';
            u2.FFA_Company__c = 'Newmarket US';
            u2.FFA_Dimension_3__c = '190 - FINANCE - CONTROLLING';
            u2.FFA_Dimension_2__c = 'Amadeus';     
            update u2;             
            
            testEmailTest();
            
        }           
        
        // VERIFY THAT THE USER COST FIELD IS UPDATED
        List<User> lstUser = [SELECT Id, FFA_Company__c, FFA_Dimension_3__c, FFA_Dimension_2__c, Cost_Ctr__c 
                              FROM User];
        system.assertNotEquals(1, lstUser.size());
        
        Test.stopTest();
        
    }

    //======================================================================================================================
    //  TEST WHEN A COMMUNITY USER UPDATES THEIR INFO
    //======================================================================================================================
   	@isTest static void test6()
    {   
        
        User communityUsr = [SELECT Id FROM User WHERE Alias = 'CXLTEST1'];
        Contact communityCnt = [SELECT Id, Phone FROM Contact WHERE FirstName = 'Mike' AND LastName = 'Oxmaul'];
        
        system.runAs(communityUsr)
        {
            communityUsr.FirstName = 'Fred';
            communityUsr.LastName = 'Sanford';
            communityUsr.Email = 'fredGsanford@apextest.gov';
            communityUsr.Title = 'Junk Dealer';
            communityUsr.Street = '81723 Avenue';
            communityUsr.City = 'El Segundo';
            communityUsr.State = 'CA';
            communityUsr.PostalCode = '90245';
            communityUsr.Phone = '613-431-0000';
            communityUsr.MobilePhone = '603-431-0001';
            communityUsr.Fax = '613-431-0002';
            update communityUsr;
        }        
        
        NI_User_TriggerHandler uTrig = new NI_User_TriggerHandler();
        List<User> lstUsrs = new List<User>();
        lstUsrs.add(communityUsr);
        uTrig.syncContactEmails(lstUsrs);
        uTrig.postToChatterGroup(communityUsr.Id, 'Test Error Message', communityCnt.Id);
        
        User usr = [SELECT Id, FirstName, LastName, Email, Title, 
                    Street, City, State, PostalCode, 
                    Phone, MobilePhone, Fax 
                    FROM User 
                    WHERE Id =: communityUsr.Id];        
        
        Contact cnt = [SELECT Id, FirstName, LastName, Email, Title, 
                       MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                       Phone, MobilePhone, Fax 
                       FROM Contact 
                       WHERE Id =: communityCnt.Id];
        
        // ASSERT THAT THE CONTACT RECORD WAS UPDATED CORRECTLY
        system.assertEquals(cnt.FirstName, usr.FirstName); 
        system.assertEquals(cnt.LastName, usr.LastName); 
        system.assertEquals(cnt.Title, usr.Title); 
        system.assertEquals(cnt.MailingStreet, usr.Street); 
        system.assertEquals(cnt.MailingCity, usr.City); 
        system.assertEquals(cnt.MailingState, usr.State); 
        system.assertEquals(cnt.MailingPostalCode, usr.PostalCode); 
        system.assertEquals(cnt.Phone, usr.Phone); 
        system.assertEquals(cnt.MobilePhone, usr.MobilePhone); 
        system.assertEquals(cnt.Fax, usr.Fax); 
        system.assertEquals(cnt.Email, usr.Email); 
        
    }

    @future
    private static void testEmailTest()        
    {  
        
        EmailTemplate e = new EmailTemplate(developerName = 'Unique_Name_Test', FolderId = UserInfo.getUserId(), TemplateType = 'Text', Name = 'Test'); 
        
        User usr = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];              
        system.RunAs(usr)
        {
            insert e;
        }      
        
    }
*/        
}