/***********************************************************************************************
Name            : AH_Contact_Trigger_Handler_Test
Author          : Shashikant Nikam
Created Date    : 04/09/2018
Last Mod Date   : 04/17/2018
Last Mod By     : Stuart Emery
NICC Reference  : NICC-027123
Description     : This class handles all the test code for AH_Contact_Trigger_Handler class
                :
                :
************************************************************************************************/
@isTest
public class AH_Contact_Trigger_Handler_Test 
{
    
    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // ======================================================================================================================================= 
    @testSetup static void createTestData()
    {
        
		system.debug(' *** START AH_Contact_Trigger_Handler_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        // CREATE TEST ACCOUNT RECORDS  
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'Apex Test AH_Contact_Trigger_Handler_Test 1'; 
        insert a1;
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'AH_Contact_Trigger_Handler_Test Apex Test 2';
        insert a2;
        
        // CREATE A TEST STANDARD CONTACT
        Contact c1 = NI_TestClassData.createTestContact(1, a1.Id);
        c1.FirstName = 'TESTERA';
        c1.LastName = 'TESTERA';
        c1.Email = 'TESTA@TESTER.COM';
        insert c1;
        
        // CREATE A TEST SUNSET CONTACT
        Contact c2 = NI_TestClassData.createTestContact(2, a2.Id);
        c2.Sunset_Contact__c = true;
        c2.FirstName = 'TESTERB';
        c2.LastName = 'TESTERB';
        c2.Email = 'TESTB@TESTER.COM';        
        insert c2;
        
        Account a3 = NI_TestClassData.createTestAccount(3);
        a3.Name = 'AH_Contact_Trigger_Handler Account';
        a3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        insert a3;
        
        // CREATE A CONTACT TO TEST UPDATING Cancellation_User__c TO TRUE THEN FALSE
        Contact c3 = NI_TestClassData.createTestContact(3, a3.Id);
        c3.FirstName = 'Randy';
        c3.LastName = 'West';
        c3.Email = 'rwest@someemail.org';
        insert c3;        

        // CREATE A TEST CONTACT TO BE CREATED AS A PORTAL USER 
        Contact cnt = NI_TestClassData.createTestContact(4, a3.Id);
        cnt.FirstName = 'Jerry';
        cnt.LastName = 'Butler';
        cnt.Email = 'CONTACTTEST1@amadeushospitality.com';
        insert cnt;
        
        // CREATE TEST COMMUNITY USER 
        User u = NI_TestClassData.createTestUser(1, Label.Community_User_From_Contact_Default_Profile); 
        u.ContactId = cnt.Id;
        u.FirstName = 'Jerry';
        u.LastName = 'Butler';
        u.Alias = 'CNTTEST1';
        u.Email = 'CONTACTTEST1@amadeushospitality.com';
        u.Username = 'CONTACTTEST1@amadeushospitality.com.ahcc';
        u.CommunityNickname = 'CONTACTTEST1'; 
        insert u;
        
        List<User> lstUserAssert1 = new List<User>([SELECT Id, Cancellation_User__c 
                                                    FROM User 
                                                    WHERE Username = 'CONTACTTEST1@amadeushospitality.com.ahcc' 
                                                    AND AccountId =: a3.Id 
                                                    AND ContactId =: cnt.Id]);
        
        system.assertEquals(1, lstUserAssert1.size());        
        system.assertEquals('False', lstUserAssert1[0].Cancellation_User__c); 
        
        User sysUsr = NI_TestClassData.createTestUser(1872, 'System Administrator'); 
        sysUsr.FirstName = 'Jamie';
        sysUsr.LastName = 'Gillis';
        sysUsr.Alias = 'JGAPXTS';
        sysUsr.Email = 'JGAPXTS@amadeushospitality.com.org';
        sysUsr.Username = 'JGAPXTS@amadeushospitality.com.org';        
        insert sysUsr;
        
		system.debug(' ***  END  AH_Contact_Trigger_Handler_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
     
    // =======================================================================================================================================
    // = TEST METHOD 1: TESTING FOR SUNSET CONTACT
    // =======================================================================================================================================    
    @isTest static void test1()
    {
        
		system.debug(' *** START AH_Contact_Trigger_Handler_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	

        Account a1 = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Name = 'Apex Test AH_Contact_Trigger_Handler_Test 1'];
        Account a2 = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Name = 'AH_Contact_Trigger_Handler_Test Apex Test 2'];
        Contact c1 = [SELECT Id, Name, Sunset_Contact__c FROM Contact WHERE FirstName = 'TESTERA' AND LastName = 'TESTERA' AND Email = 'TESTA@TESTER.COM'];
        Contact c2 = [SELECT Id, Name, Sunset_Contact__c FROM Contact WHERE FirstName = 'TESTERB' AND LastName = 'TESTERB' AND Email = 'TESTB@TESTER.COM'];
        
        Test.startTest();        
                
        // INSERT CONTACT TO COVER AFTER INSERT TRIGGER & HANDLER CODE
        Contact cnt1 = NI_TestClassData.createTestContact(1, a1.Id);
        cnt1.Sunset_Contact__c = true;
        insert cnt1;
        
        Account acctAssert1 = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Id =: a1.Id];
        system.assertEquals(true, acctAssert1.Has_Sunset_Contact__c);
        
        // UPDATE CONTACT TO COVER AFTER UPDATE TRIGGER & HANDLER CODE
        Contact cnt2 = new Contact();
        cnt2.Id = c2.Id;
        cnt2.Sunset_Contact__c = false;
        update cnt2;
        
        Account acctAssert2 = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Id =: a2.Id];
        system.assertEquals(false, acctAssert2.Has_Sunset_Contact__c);
        
        // DELETE CONTACT TO COVER AFTER DELETE TRIGGER & HANDLER CODE
        delete cnt1;
        
        Account acctAssert3 = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Id =: a1.Id];
        system.assertEquals(false, acctAssert3.Has_Sunset_Contact__c);
        
        // UNDELETE CONTACT TO COVER AFTER UNDELETE TRIGGER & HANDLER CODE
        undelete cnt1;
        
        Account acctAssert4 = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Id =: a1.Id];
        system.assertEquals(true, acctAssert4.Has_Sunset_Contact__c);
        
        Test.stopTest();
        
		system.debug(' ***  END  AH_Contact_Trigger_Handler_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: BULK TESTING FOR SUNSET CONTACT
    // =======================================================================================================================================    
    @isTest static void test2()
    {
        
		system.debug(' *** START AH_Contact_Trigger_Handler_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Account a1 = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Name = 'Apex Test AH_Contact_Trigger_Handler_Test 1'];
        Account a2 = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Name = 'AH_Contact_Trigger_Handler_Test Apex Test 2'];

        Test.startTest();        
                 
        List<Contact> contact_listToInsert = new List<Contact>();
        List<Contact> contact_listToUpdate = new List<Contact>();
        List<Contact> contactList = new List<Contact>();
        
        List<Account> acc_list = [SELECT Id, name, Has_Sunset_Contact__c FROM Account WHERE Name LIKE '%Test%'];
        system.assertEquals(false, acc_list[0].Has_Sunset_Contact__c, 'No sunset contact on account.');
        
        //BULK INSERT CONTACTS
        for (Integer i = 3; i < 203; i++)
        {
            Contact con = NI_TestClassData.createTestContact(i, acc_list[0].Id);
            contact_listToInsert.add(con);
        }
        
        for (Integer i = 202; i < 1000; i++)
        {
            Contact con = NI_TestClassData.createTestContact(i, acc_list[1].Id);
            if (i != 202)
            {
                con.Sunset_Contact__c = true;
            }
            contact_listToInsert.add(con);
        }
        
        insert contact_listToInsert;
        
        
        Account testAcc = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Id =: a1.Id];
        system.assertEquals(false, testAcc.Has_Sunset_Contact__c);
        
        //ACCOUNT'S Has_Sunset_Contact__c IS SET TO TRUE SINCE SUNSET CONATACTS ARE INSERTED
        testAcc = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Id =: a2.Id];
        system.assertEquals(true, testAcc.Has_Sunset_Contact__c);
        
        //BULK DELETE - DELETE ALL CONTACTS INSERTED on ACCOUNT TEST2
        contactList = [SELECT Id, Name, Account.Id, Sunset_Contact__c FROM Contact WHERE Account.Id =: a2.Id];
        
        if (!contactList.isEmpty())
        {
            delete contactList;
        }
        
        //ACCOUNT'S Has_Sunset_Contact__c FIELD IS UPDATED TO FALSE SINCE THERE ARE NO SUNSET CONTACTS ON IT
        testAcc = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Id =: a2.Id];
        system.assertEquals(false, testAcc.Has_Sunset_Contact__c);
        
        
        //BULK UNDELETE ALL THE ABOVE DELETED RECORDS
        if (!contactList.isEmpty())
        {
            undelete contactList;
        }
        
        testAcc = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Id =: a2.Id];
        system.assertEquals(true, testAcc.Has_Sunset_Contact__c);
        
        //BULK UPDATE CONTACTS
        contactList = [SELECT Id, Name, Account.Id, Sunset_Contact__c FROM Contact WHERE Account.Id =: a1.Id];
        
        for (Contact c : contactList)
        {
            if (c.Sunset_Contact__c == true)
            {
                c.Sunset_Contact__c = false;
                contact_listToUpdate.add(c);
            }
        }
        
        if (!contact_listToUpdate.isEmpty())
        {
            update contact_listToUpdate;
        }
        
        //ACCOUNT'S Has_Sunset_Contact__c FIELD IS UPDATED TO FALSE SINCE THERE ARE NO SUNSET CONTACTS ON IT
        testAcc = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Id =: a1.Id];
        system.assertEquals(false, testAcc.Has_Sunset_Contact__c);
        
        Test.stopTest();
        
		system.debug(' ***  END  AH_Contact_Trigger_Handler_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }

    // =======================================================================================================================================
    // = TEST METHOD 3: TEST createCommunityUsers() METHOD
    // =======================================================================================================================================    
    @isTest static void test3()
    {
        
		system.debug(' *** START AH_Contact_Trigger_Handler_Test.test3() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Test.startTest();  

        Account a = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Name = 'AH_Contact_Trigger_Handler Account'];
		Contact c1 = [SELECT Id, Name, Cancellation_User__c FROM Contact WHERE FirstName = 'Randy' AND LastName = 'West' AND Email = 'rwest@someemail.org'];
       	User sysUsr = [SELECT Id FROM user WHERE FirstName = 'Jamie' AND LastName = 'Gillis'];
        
        // ASSERT Cancellation_User__c CHECKBOX DEFAULTS TO False
        Contact contactAssert1 = [SELECT Id, Cancellation_User__c FROM Contact WHERE Id =: c1.Id];
        system.assertEquals(false, contactAssert1.Cancellation_User__c);
        
        // ASSERT NO USER EXISTS YET FOR CONTACT
        List<User> lstUserAssert1 = new List<User>([SELECT Id, Cancellation_User__c FROM User WHERE AccountId =: a.Id AND ContactId =: c1.Id]);
        system.assertEquals(0, lstUserAssert1.size());
        
        // CHECK THE Cancellation_User__c CHECKBOX 
        system.runAs(sysUsr) // SHOULD CREATE A USER RECORD SO "RUN AS" A TEST ADMIN USER TO PREVENT MIXED-DML ERRORS
        {       
            contactAssert1.Cancellation_User__c = true;
            update contactAssert1;
        }
        
        // ASSERT USER WAS CREATED FOR CONTACT AND Cancellation_User__c WAS SET TO 'True'
        List<User> lstUserAssert2 = new List<User>([SELECT Id, Cancellation_User__c FROM User WHERE AccountId =: a.Id AND ContactId =: c1.Id]);
        system.assertEquals(1, lstUserAssert2.size());
        system.assertEquals('True', lstUserAssert2[0].Cancellation_User__c);
        
        // UNCHECK THE Cancellation_User__c CHECKBOX 
        system.runAs(sysUsr) // SHOULD UPDATE A USER RECORD SO "RUN AS" A TEST ADMIN USER TO PREVENT MIXED-DML ERRORS
        {            
            contactAssert1.Cancellation_User__c = false;
            update contactAssert1;        
        }    
        
        // ASSERT Cancellation_User__c WAS SET TO 'False' ON CONTACT'S USER RECORD
        List<User> lstUserAssert3 = new List<User>([SELECT Id, Cancellation_User__c FROM User WHERE AccountId =: a.Id AND ContactId =: c1.Id]);
        system.assertEquals(1, lstUserAssert3.size());
        system.assertEquals('False', lstUserAssert3[0].Cancellation_User__c); 
        
        // TEST CHECKING THE Cancellation_User__c CHECKBOX ON A PRE-EXISTING NON-CANCELLATION USER
        Contact existingUser = [SELECT Id, Cancellation_User__c FROM Contact WHERE FirstName = 'Jerry' AND LastName = 'Butler' AND Email = 'CONTACTTEST1@amadeushospitality.com'];
        system.assertEquals(false, existingUser.Cancellation_User__c); 
        
        // CHECK THE Cancellation_User__c CHECKBOX 
        system.runAs(sysUsr) // SHOULD UPDATE A USER RECORD SO "RUN AS" A TEST ADMIN USER TO PREVENT MIXED-DML ERRORS
        {    
            existingUser.Cancellation_User__c = true;
            update existingUser;
        }
        
        // ASSERT Cancellation_User__c WAS SET TO 'True' ON EXITING CONTACT'S USER RECORD
        List<User> lstUserAssert4 = new List<User>([SELECT Id, Cancellation_User__c FROM User WHERE AccountId =: a.Id AND ContactId =: existingUser.Id]);
        system.assertEquals(1, lstUserAssert4.size());
        system.assertEquals('True', lstUserAssert4[0].Cancellation_User__c);  
        
        Test.stopTest();
        
		system.debug(' ***  END  AH_Contact_Trigger_Handler_Test.test3() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }

    // =======================================================================================================================================
    // = TEST METHOD 4: TEST CONTACT VALIDATION FOR CANCELLATION USER SWITCH
    // =======================================================================================================================================    
    @isTest static void test4()
    {
        
		system.debug(' *** START AH_Contact_Trigger_Handler_Test.test4() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Account a = [SELECT Id, Name, Has_Sunset_Contact__c FROM Account WHERE Name = 'AH_Contact_Trigger_Handler Account'];
        User sysUsr = [SELECT Id FROM user WHERE FirstName = 'Jamie' AND LastName = 'Gillis'];
        
        Test.startTest(); 
        
        // CREATE CONTACT WITH BAD DATA
        Contact c1 = NI_TestClassData.createTestContact(1, a.Id);
        c1.FirstName = null;
        c1.LastName = 'H';
        c1.Email = null;
        insert c1;
        
        // ASSERT CONTACT WAS CREATED AND Cancellation_User__c IS FALSE
        Contact cnt = [SELECT Id, Cancellation_User__c FROM Contact WHERE FirstName = null AND LastName = 'H' AND Email = null];
        system.assertEquals(false, cnt.Cancellation_User__c);        
        
        // UPDATE CONTACT WITH BAD DATA (SENARIO 1 - BAD FIRSTNAME, LASTNAME & EMAIL) 
        try
        {      
            // CHECK THE Cancellation_User__c CHECKBOX 
            cnt.Cancellation_User__c = true;
            update cnt;             
        }
        catch (Exception ex)
        {           
            // ASSERT THAT THE VALIDATION WAS SUCCESSFUL AND RAISED THE EXPECTED ERROR TO RUNNING USER
            Boolean expectedExceptionThrown = false;
            if (ex.getMessage().contains('when Cancellation User is checked'))
            {
                expectedExceptionThrown = true;
            }
            system.AssertEquals(true, expectedExceptionThrown, ex.getMessage()); 
        }
        
        // ASSERT THAT Cancellation_User__c CHECKBOX UPDATE WAS NOT SUCCESSFUL
        cnt = [SELECT Id, Cancellation_User__c FROM Contact WHERE FirstName = null AND LastName = 'H' AND Email = null];
        system.assertEquals(false, cnt.Cancellation_User__c);
        
        // UPDATE CONTACT WITH BAD DATA (SENARIO 2 - BAD EMAIL)    
        try
        {
            // CHECK THE Cancellation_User__c CHECKBOX 
            cnt.Cancellation_User__c = true;
            cnt.FirstName = 'Mike';
            cnt.LastName = 'Horner';
            cnt.Email = null;            
            update cnt;
        }
        catch (Exception ex)
        {
            // ASSERT THAT THE VALIDATION WAS SUCCESSFUL AND RAISED THE EXPECTED ERROR TO RUNNING USER
            Boolean expectedExceptionThrown = false;
            if (ex.getMessage().contains('when Cancellation User is checked'))
            {
                expectedExceptionThrown = true;
            }
            system.AssertEquals(true, expectedExceptionThrown, ex.getMessage()); 
        }
        
        // ASSERT THAT Cancellation_User__c CHECKBOX UPDATE WAS NOT SUCCESSFUL
        cnt = [SELECT Id, Cancellation_User__c FROM Contact WHERE FirstName = null AND LastName = 'H' AND Email = null];
        system.assertEquals(false, cnt.Cancellation_User__c);        
        
        // UPDATE CONTACT WITH VALID DATA (SENARIO 3)    
        system.runAs(sysUsr) // SHOULD CREATE USER RECORD SO RUN AS TO PREVENT MIXED-DML ERRORS
        {                
            try
            {
                // CHECK THE Cancellation_User__c CHECKBOX 
                cnt.Cancellation_User__c = true;
                cnt.FirstName = 'Mike';
                cnt.LastName = 'H';
                cnt.Email = 'mhornertestapex@someemailaddr.com';            
                update cnt;
            }
            catch (Exception ex)
            {
                system.AssertEquals(false, true, 'Contact save should be valid'); 
            }
        }
        
        // ASSERT THAT Cancellation_User__c CHECKBOX UPDATE WAS NOT SUCCESSFUL
        cnt = [SELECT Id, Cancellation_User__c FROM Contact WHERE FirstName = 'Mike' AND LastName = 'H' AND Email = 'mhornertestapex@someemailaddr.com'];
        system.assertEquals(true, cnt.Cancellation_User__c);           
        
        // ASSERT Cancellation_User__c WAS SET TO 'True' ON EXISTING CONTACT'S USER RECORD
        List<User> lstUserAssert1 = new List<User>([SELECT Id, Cancellation_User__c FROM User WHERE AccountId =: a.Id AND ContactId =: cnt.Id]);
        system.assertEquals(1, lstUserAssert1.size());
        system.assertEquals('True', lstUserAssert1[0].Cancellation_User__c);          

        
        // INSERT A CANCELLATION CONTACT THAT IMMEDIATELY CREATES A COMMUNITY USER
        Contact cUser = NI_TestClassData.createTestContact(1, a.Id);
        cUser.FirstName = 'John';
        cUser.LastName = 'Leslie';
        cUser.Email = 'jleslietestapex@someemailaddr.com';
        cUser.Cancellation_User__c = true;
        insert cUser;        

        // ASSERT Cancellation_User__c WAS CREATE AND SET TO 'True'
        List<User> lstUserAssert2 = new List<User>([SELECT Id, Cancellation_User__c FROM User WHERE AccountId =: a.Id AND ContactId =: cUser.Id]);
        system.assertEquals(1, lstUserAssert2.size());
        system.assertEquals('True', lstUserAssert2[0].Cancellation_User__c); 
        
        Test.stopTest();
        
		system.debug(' ***  END  AH_Contact_Trigger_Handler_Test.test4() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
  	
}