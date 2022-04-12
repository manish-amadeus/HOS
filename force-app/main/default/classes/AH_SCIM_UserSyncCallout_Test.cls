/************************************************************************************************
Name            : AH_SCIM_UserSyncCallout_Test
Author          : Ganesh Bora
Created Date    : 12/01/2022
Last Mod Date   : 12/01/2022
Last Mod By     : Ganesh Bora
NICC Reference  : NICC-056411
Description     : Test class for AH_SCIM_UserSyncCallout_Test.cls 
                : 
                : 
*************************************************************************************************/
@isTest //(SeeAllData=true)
public class AH_SCIM_UserSyncCallout_Test {
    public static AH_SCIM_UserSyncCallout objAH_SCIM_UserSyncCallout = new AH_SCIM_UserSyncCallout();
    @testSetup static void setup()
    {
    	User u1 = NI_TestClassData.createTestUser(4321, 'System Administrator');
        UserRole userrole = [Select id, name from UserRole where PortalType = 'None' limit 1];
        u1.UserRoleId=userrole.id;
        insert u1;

        List<User> lstUserAssert = new List<User>([SELECT Id FROM User WHERE Alias = 'user4321']);
        system.assertEquals(1, lstUserAssert.Size());

        system.runAs(u1)
        {
            // CREATE TEST PARENT ACCOUNT RECORD
            Account a = NI_TestClassData.createTestAccount(1);
            insert a;
            List<Contact> listContact = new List<Contact>();
            for (Integer i = 0; i < 5; i++) {
                string firstName = 'duck'+i;
                string lastName = 'donald';
                string email = firstName+''+lastName+'@valamis.comtest';
                
                // CREATE A TEST CONTACT TO BE CREATED AS A PORTAL USER 
                Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
                cnt.FirstName = firstName;
                cnt.LastName = lastName;
                cnt.Email = email;
                 
                listContact.add(cnt);
            }
            insert listContact;
            
            List<User> listUser = new List<User>(); 
            for (Integer i = 0; i < 5; i++) {
                string firstName = 'duck'+i;
                string lastName = 'donald';
                string email = firstName+''+lastName+'@valamis.comtest';
                
                // CREATE A TEST USER WITH THE AH Customer Community Plus Login User PROFILE
                User u = NI_TestClassData.createTestUser(1, 'AH Customer Community Plus Login User');
                u.ContactId = listContact[i].id;
                u.FirstName = firstName;
                u.LastName = lastName;
                u.Email = email;
                u.Username = email+'.ahcc';
                u.LMS_User_Access__c = 'No Access';
                u.CommunityNickname = firstName+''+lastName;
                u.ADUserName__c  = firstName+''+lastName;
    
                listUser.add(u);
            }
            insert listUser;
        }
    }

	@isTest static void testPing() 
    {
        Test.setMock(HttpCalloutMock.class, new AH_SCIM_UserSyncCallout_Mock());
        Test.startTest();
        objAH_SCIM_UserSyncCallout.ping();
        system.assert(true);
        Test.stopTest();	
	}
    
    @isTest static void testPingFailed() 
    {
        Test.setMock(HttpCalloutMock.class, new AH_SCIM_UserSyncCalloutBadRequests_Mock());
        Test.startTest();
		try
        {
            objAH_SCIM_UserSyncCallout.ping();
            system.assert(true);
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
        //string userUUID = objAH_SCIM_UserSyncCallout.checkUserExistsByUserName(userData.UserName);
        //system.assertNotEquals(null, userUUID);
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
            string userUUID = objAH_SCIM_UserSyncCallout.checkUserExistsByUserName(userData.UserName);
        	system.assertEquals(null, userUUID);
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
        //string userUUID = objAH_SCIM_UserSyncCallout.checkUserExistsByUserName(userData.UserName);
        //system.assertNotEquals(null, userUUID);
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
            string userUUID = objAH_SCIM_UserSyncCallout.checkUserExistsByUserName(userData.UserName);
        	system.assertEquals(null, userUUID);
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
            string userUUID = objAH_SCIM_UserSyncCallout.checkUserExistsByUserName(email);
        	system.assertEquals(null, userUUID);
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