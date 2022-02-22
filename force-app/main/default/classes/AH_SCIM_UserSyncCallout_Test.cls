/************************************************************************************************
Name            : AH_SCIM_UserSyncCallout_Test
Author          : Ganesh Bora
Created Date    : 12/01/2022
Last Mod Date   : 12/01/2022
Last Mod By     : Ganesh Bora
NICC Reference  : 
Description     : Test class for AH_SCIM_UserSyncCallout_Test.cls 
                : 
                : 
*************************************************************************************************/
@isTest //(SeeAllData=true)
public class AH_SCIM_UserSyncCallout_Test {
    public static AH_SCIM_UserSyncCallout objAH_SCIM_UserSyncCallout = new AH_SCIM_UserSyncCallout();
    @testSetup static void setup()
    {
    	// CREATE TEST PARENT ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        // CREATE A TEST CONTACT TO BE CREATED AS A PORTAL USER 
        Contact cnt1 = NI_TestClassData.createTestContact(1, a.Id);
        cnt1.FirstName = 'duck1';
        cnt1.LastName = 'donald';
        cnt1.Email = 'donald.duck01@valamis.comtest';
        insert cnt1;
        
        // CREATE A TEST CONTACT TO BE CREATED AS A PORTAL USER 
        Contact cnt2 = NI_TestClassData.createTestContact(1, a.Id);
        cnt2.FirstName = 'duck2';
        cnt2.LastName = 'donald';
        cnt2.Email = 'donald.duck01@valamis.comtest';
        insert cnt2;
        
        // CREATE A TEST USER WITH THE AH Customer Community Plus Login User PROFILE
        User u1 = NI_TestClassData.createTestUser(1, 'AH Customer Community Plus Login User');
        u1.ContactId = cnt1.Id;
        u1.FirstName = 'duck1';
        u1.LastName = 'donald';
        u1.Email = 'donald.duck01@valamis.comtest';
        u1.Username = 'donald.duck01@valamis.comtest.ahcc';
        u1.LMS_User_Access__c = 'No Access';
        u1.CommunityNickname = 'duck1donald';
        u1.ADUserName__c  = 'duck1donald';
        insert u1;   
        
        // CREATE A TEST USER WITH THE AH Customer Community Plus Login User PROFILE
        User u2 = NI_TestClassData.createTestUser(1, 'AH Customer Community Plus Login User');
        u2.ContactId = cnt2.Id;
        u2.FirstName = 'duck2';
        u2.LastName = 'donald';
        u2.Email = 'donald.duck02@valamis.comtest';
        u2.Username = 'donald.duck02@valamis.comtest.ahcc';
        u2.LMS_User_Access__c = 'No Access';
        u2.CommunityNickname = 'duck2donald';
        u2.ADUserName__c  = 'duck2donald';
        
        insert u2;   
    }

	@isTest static void testPing() 
    {
        Test.setMock(HttpCalloutMock.class, new AH_SCIM_UserSyncCallout_Mock());
        Test.startTest();
        objAH_SCIM_UserSyncCallout.ping();
        
        Test.stopTest();	
	}
    
    @isTest static void testPingFailed() 
    {
        Test.setMock(HttpCalloutMock.class, new AH_SCIM_UserSyncCalloutBadRequests_Mock());
        Test.startTest();
		try
        {
            objAH_SCIM_UserSyncCallout.ping();
        } 
        catch (Exception e) 
        {
            
        }  
        Test.stopTest();
	}
    
    @isTest static void testCreateUser() 
    {
        Test.setMock(HttpCalloutMock.class, new AH_SCIM_UserSyncCallout_Mock());
        Test.startTest();
        string email = 'donald.duck01@valamis.comtest';
        AH_SCIM_User userData = AH_SCIM_UserSyncCallout_Test.getTestUserData(email);
        objAH_SCIM_UserSyncCallout.syncUser(userData);
        Test.stopTest();
	}
    
    @isTest static void testCreateUserFailed() 
    {
        Test.setMock(HttpCalloutMock.class, new AH_SCIM_UserSyncCalloutBadRequests_Mock());
        Test.startTest();
        try
        {
        	string email = 'donald.duck01@valamis.comtest';
        	AH_SCIM_User userData = AH_SCIM_UserSyncCallout_Test.getTestUserData(email);
        	objAH_SCIM_UserSyncCallout.createUser(userData);
        } 
        catch (Exception e) 
        {
            
        } 
        Test.stopTest();
	}
    
    @isTest static void testUpdateUser() 
    {
        Test.setMock(HttpCalloutMock.class, new AH_SCIM_UserSyncCallout_Mock());
        Test.startTest();
        string email = 'donald.duck02@valamis.comtest';
        AH_SCIM_User userData = AH_SCIM_UserSyncCallout_Test.getTestUserData(email);
        objAH_SCIM_UserSyncCallout.syncUser(userData);
        Test.stopTest();
	}
    @isTest public static void testBatchSCIMUserSyncCallout()
    {
        Test.startTest();
        try 
        {
        	Test.setMock(HttpCalloutMock.class, new AH_SCIM_UserSyncCallout_Mock());
        	SchedulableContext sc = null; 		
        	AH_SCIM_UserSyncCallout_Schedule b = new AH_SCIM_UserSyncCallout_Schedule ();		
        	b.execute(sc);
        } 
        catch(Exception e) 
        {
            
        }
        Test.stopTest();
    }
    @isTest static void testUpdateUserFailed() 
    {
        Test.setMock(HttpCalloutMock.class, new AH_SCIM_UserSyncCalloutBadRequests_Mock());
        Test.startTest();
        try 
        {
        	string email = 'donald.duck02@valamis.comtest';
        	AH_SCIM_User userData = AH_SCIM_UserSyncCallout_Test.getTestUserData(email);
        	string uuid = 'ccc0f97f-db9d-f5b1-6aea-813c3bab4c';
        	objAH_SCIM_UserSyncCallout.updateUser(userData,uuid);
        } 
        catch (Exception e) 
        {
            
        }    
        Test.stopTest();
	}
    
    @isTest static void testCheckUserExistsFailed() 
    {
        Test.setMock(HttpCalloutMock.class, new AH_SCIM_UserSyncCalloutBadRequests_Mock());
        Test.startTest();
        try 
        {
        	string email = 'donald.duck02@valamis.comtest';
        	objAH_SCIM_UserSyncCallout.checkUserExistsByUserName(email);
        } 
        catch (Exception e) 
        {
            
        }     
        Test.stopTest();
	}
    
    public static AH_SCIM_User getTestUserData(string email)
    {
        AH_SCIM_User userData = objAH_SCIM_UserSyncCallout.getDummySCIMUserDataObject();
        userData.userName = email;
        userData.externalId = email;
        userdata.active = false;
        
        AH_SCIM_User.Emails e1 = new AH_SCIM_User.Emails();
        e1.value = email;
        e1.primary = true;
        
        userData.emails = new List <AH_SCIM_User.Emails>();
        userData.emails.add(e1);
        
        userData.name.familyName = 'duck';
        userData.name.givenName = 'donald';
        userData.name.formatted = 'donald duck';
        
        return userData;
    }
}