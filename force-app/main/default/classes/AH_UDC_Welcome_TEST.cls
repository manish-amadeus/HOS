/***********************************************************************************************
  Name            : AH_UDC_Welcome_TEST
  Author          : Umang Ankleshwaria
  Created Date    : 05-Jan-2021
  Last Mod Date   : 25-Mar-2022
  Last Mod By     : Vaishali Patel
  Description     : Test class for Welcome page of UDC  
 ************************************************************************************************/

@isTest
private class AH_UDC_Welcome_TEST {
   @TestSetup private static void setup() {
      UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEOCFO' Limit 1];

    User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and IsActive = true Limit 1];
    
    adminUser.UserRoleId = userRole.Id;
    update adminUser;
    
    System.runAs(adminUser){
          AH_UDC_InitializationHelper.Initialize('All');
    
          String uniqueId = AH_UDC_Shared.generateGUID();
          Account newAccount = AH_UDC_TestData.GetAccountObject(uniqueId);
          insert newAccount;
    
          Contact newContact = AH_UDC_TestData.GetContactObject(newAccount.id, uniqueId);
          insert newContact;
    
          List<User> listUsers = new List<User> ();
          //Build Community User with chatter
          listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER,
                                        AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                        'Welcome', newContact.Id, true));
    
          User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
          oCurrentUser.ContactId = null;
    
          System.runAs(oCurrentUser) {
             //AH_UDC_TestData.InsertWithRetries(listUsers);
             insert listUsers;
    
             // Community Users
             AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[0].Id);
          }
      }
   }

   @isTest
   public static void AH_UDC_Welcome_Test() {
      //TODO: ROBDEV: Test data should be created in Setup or inside of a Run As
      //Insert new record into NI Documentation object for testing
      UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEOCFO' Limit 1];

    User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and IsActive = true Limit 1];
    
    adminUser.UserRoleId = userRole.Id;
    update adminUser;
    
    System.runAs(adminUser){
          NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
          objNIDoc.AH_UDC_ChatterWorkbookAccessed__c = false;
          objNIDoc.AH_UDC_ChatterWorkbookCompleted__c = false;
          insert objNIDoc;
    
          NI_Documentation__c objNIDoc1 = AH_UDC_TestData.GetNIDocObject('Test NI Doc1', Date.newInstance(2021, 12, 31));      
          objNIDoc1.AH_UDC_ChatterWorkbookAccessed__c = false;
          objNIDoc1.AH_UDC_ChatterWorkbookCompleted__c = false;
          objNIDoc1.AH_UDC_WorkbookWithdrawn__c = true;
          insert objNIDoc1;
    
          NI_Documentation__c objNIDoc2 = AH_UDC_TestData.GetNIDocObject('Test NI Doc2', Date.newInstance(2021, 12, 31));     
          insert objNIDoc2;
    
          NI_Documentation__c objNIDoc3 = AH_UDC_TestData.GetNIDocObject('Test NI Doc3', Date.newInstance(2021, 12, 31));
          insert objNIDoc3;
    
          User objUser = [SELECT Id, ContactId from User WHERE Username = :('TestWelcome@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
          System.assert(objUser != null, 'Community user with chatter record not found');
    
          //TODO: ROBDEV: This is be inserted with a Workbook User not the community user
          //System.runAs(objUser) {
             List<AH_UDC_Contact__c> lstUDCContacts = new List<AH_UDC_Contact__c> ();
             lstUDCContacts.add(AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objUser.ContactId, 'USD'));
             lstUDCContacts.add(AH_UDC_TestData.GetUDCContactObject(objNIDoc1.Id, objUser.ContactId, 'USD'));
             lstUDCContacts.add(AH_UDC_TestData.GetUDCContactObject(objNIDoc2.Id, objUser.ContactId, 'USD'));
             lstUDCContacts.add(AH_UDC_TestData.GetUDCContactObject(objNIDoc3.Id, objUser.ContactId, 'USD'));
             for (integer i = 0; i<lstUDCContacts.size(); i++)
             lstUDCContacts[i].TermsandConditionsAccepted__c = true;
             //Assign workbook to community user
             //AH_UDC_SystemContext.CreateObjects(lstUDCContacts);
             insert(lstUDCContacts);
          //}
    
          //Insert Workbook Record
          AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 0', 'Test Workbook 0 Description', 'Central Sales');
          objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
          insert objWorkbook;
    
          AH_UDC_Workbook__c objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(objNIDoc1.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
          objWorkbook1.SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
          insert objWorkbook1;
    
          AH_UDC_Workbook__c objWorkbook2 = AH_UDC_TestData.GetWorkbookObject(objNIDoc2.Id, 'Test Workbook 2', 'Test Workbook 2 Description', 'Central Sales');
          objWorkbook2.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
          insert objWorkbook2;
    
          AH_UDC_Workbook__c objWorkbook3 = AH_UDC_TestData.GetWorkbookObject(objNIDoc3.Id, 'Test Workbook 3', 'Test Workbook 3 Description', 'Central Sales');
          objWorkbook3.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
          insert objWorkbook3;
    
          List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id FROM AH_UDC_Workbook__c WHERE Name = :'Test Workbook 0'];
          System.assert(lstWorkbook.size()> 0, 'workbooks could not be found.');
    
          System.runAs(objUser) {
             Test.startTest();
             PageReference pageRef = Page.AH_UDC_Welcome;
             Test.setCurrentPageReference(pageRef);
    
             AH_UDC_Welcome objWelcome = new AH_UDC_Welcome();
             System.debug('objWelcome' + objWelcome);
             System.assertEquals(true, (objWelcome.WorkbookList != null), 'Error occurred in welcome page execution');
             System.debug('(objWelcome.WorkbookList:' + objWelcome.WorkbookList);
             
             System.assertEquals(3, objWelcome.WorkbookList.size(), 'Total Workbook count should match');
    
             objWelcome.Opt_Into_Social_Media_Feature = true;
    
             objWelcome.LogFunctionalArea = 'TermsAndConditionNext';
    
             AH_UDC_MockResponseGenerator mock;
             mock = new AH_UDC_MockResponseGenerator(AH_UDC_MockResponseGenerator.ResponseType.SetCommunityUserProfile, 200);
             Test.setMock(HttpCalloutMock.class, mock);
    
             objWelcome.TermsAndConditionNext();
             System.assertEquals(true, objWelcome.isProfileChanged, 'External User profile has not been changed');
             List<AH_UDC_Contact__c> lstUDCContact = AH_UDC_SystemContext.query('SELECT Id, TermsandConditionsAcceptedDate__c, TermsandConditionsAccepted__c' + 
                                                                                ' FROM AH_UDC_Contact__c' + 
                                                                                ' WHERE Contact__c = \'' + objUser.ContactId + '\'' +
                                                                                ' ORDER BY CreatedDate DESC' +
                                                                                ' LIMIT 1');
             System.assertEquals(1, lstUDCContact.size(), 'Contact not found');
             System.assertEquals(true, lstUDCContact[0].TermsandConditionsAcceptedDate__c != null, 'TermsandConditionsAcceptedDate__c should not have been null');
             
             objWelcome.LogFunctionalArea = 'TestRecordType';
             objWelcome.IsErrorOccurred = false;
             objWelcome.FillWorkbookList();
             System.assert(objWelcome.IsErrorOccurred, 'IsErrorOccurred should be true as recordtype set to null');
    
             Test.stopTest();
          }
      }
   }

   @isTest
   private static void NegativeTest()
   {
       UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEOCFO' Limit 1];

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and IsActive = true Limit 1];
        
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        System.runAs(adminUser){
          User objUser = [SELECT Id, FirstName from User WHERE Username = :('TestWelcome@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
          System.assert(objUser != null, 'Community user with chatter record not found');
          objUser.FirstName = 'TestWelcomeException';
          update objUser;
    
          System.runAs(objUser) {
             Test.startTest();
             PageReference pageRef = Page.AH_UDC_Welcome;
             Test.setCurrentPageReference(pageRef);
             
             AH_UDC_Welcome objWelcome = new AH_UDC_Welcome();
             System.assert(objWelcome.HasPageLoadLogMessages, 'HasPageLoadLogMessages should be true as error generated in the constructor');
    
             objWelcome.LogFunctionalArea = 'TestException';
             objWelcome.serverLogMessages();
             System.assert(objWelcome.HasPageLoadLogMessages != true, 'HasPageLoadLogMessages should be false now as we have inserted all pending logs');
    
             objWelcome.IsErrorOccurred = false;
             try {
                //This method is throwing an exception from catch block so need to handle it in try catch
                objWelcome.FillWorkbookList();
             }
             catch(Exception ex) {
                System.assert(ex.getMessage().indexOf('Divide by 0') > - 1, 'Different error occurred in the method GetAddress. Error: ' + ex.getMessage() + ' at line number ' + ex.getLineNumber());
             }
             System.assert(objWelcome.IsErrorOccurred, 'IsErrorOccurred should be true as workbook is not assigned to the user');
    
             AH_UDC_MockResponseGenerator mock;
             //TODO: Need a MockGenerator ResponseType added for this
             mock = new AH_UDC_MockResponseGenerator(AH_UDC_MockResponseGenerator.ResponseType.Unknown, 200);
             Test.setMock(HttpCalloutMock.class, mock);
    
             objWelcome.IsErrorOccurred = false;
             objWelcome.TermsAndConditionNext();
             System.assert(objWelcome.IsErrorOccurred, 'IsErrorOccurred should be true as user not found');
    
             objWelcome.IsErrorOccurred = false;
             objWelcome.LogFunctionalArea = 'TestException';
             objWelcome.TermsAndConditionNext();
             System.assert(objWelcome.IsErrorOccurred, 'IsErrorOccurred should be true');
             Test.stopTest();
          }
      }
   }
}