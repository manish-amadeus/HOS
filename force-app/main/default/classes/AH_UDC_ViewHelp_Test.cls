<<<<<<< HEAD
/***********************************************************************************************
  Name            : AH_UDC_ViewHelp_TEST
  Author          : Tushar Gupta
  Created Date    : 14-Apr-2021
  Last Mod Date   : 14-Apr-2021 , 15-June-2021
  Last Mod By     : Tushar Gupta , Ravi Shah
  Description     : Test class for AH_UDC_PopOut_Help
 ************************************************************************************************/
@isTest
public class AH_UDC_ViewHelp_TEST {

   private static final String TEST_CONTACT_FIRSTNAME = 'AH_UDC_Test';
   private static final String TEST_USER_NAME = 'testViewHelp@user.com';
   private static final String TEST_Workbook_Name = 'Test Workbook 1';

   @TestSetup
   private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      //Create Account record
      Account objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      //Create Contact record
      Contact objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, TEST_CONTACT_FIRSTNAME+'001', 'AH_UDC_Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert objContact;

      // Create Property Account object with blank property name to get more code coverage
      AH_UDC_PropertyAccount__c objProperty = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      insert objProperty;

      //Create NI Doc record
      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
      insert objNIDoc;

      //Insert Contact NI Doc mapping record
      AH_UDC_Contact__c objUDCContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContact.Id, UserInfo.getDefaultCurrency());
      insert objUDCContact;

      //Insert Workbook Record
      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, TEST_Workbook_Name, 'Test Workbook 1 Description', product);
      insert objWorkbook;

      //Insert Workbook Step Record
      AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
      objWorkbookStep.URL__c = 'https://www.lipsum.com/';
      objWorkbookStep.Description__c = 'Test Step 1 Description';
      insert objWorkbookStep;

      List<User> listUsers = new List<User> ();
      //Build Community User with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                    'ViewHelpCommunityUser', objContact.Id, true));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[0].Id);
      }
   }

   @isTest
   private static void AH_UDC_ViewHelp_Test() {

      User u = [SELECT Id FROM User where Username = :('TestViewHelpCommunityUser@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];

      AH_UDC_WorkbookStep__c wbs = [SELECT Id, Name, Help__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__r.Name = :TEST_Workbook_Name];

      System.runAs(u) {
         PageReference pageRef = Page.AH_UDC_ViewHelp;
         pageRef.getParameters().put('id', wbs.Id);
         Test.setCurrentPageReference(pageRef);

         Test.startTest();
         AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
         System.assert(!ApexPages.hasMessages(), 'Errors occurred while in the AH_UDC_ViewHelp constructor: ' + ApexPages.getMessages());
         System.assertEquals(popout.IsErrorOccurred, false, 'An error occurred in the the AH_UDC_ViewHelp constructor');
         System.assertEquals(wbs.Name, popout.StepName, 'Workbook Step name could not matched');
         System.assertEquals(wbs.Help__c, popout.HelpText, 'Workbook Step help text could not matched');
         Test.stopTest();
      }
   }

   @isTest
   // Test passing an invalid Workbook Step ID to the AH_UDC_ViewHelp
   private static void AH_UDC_ViewHelp_Negative_Test1() {
      PageReference pageRef = Page.AH_UDC_ViewHelp;
      pageRef.getParameters().put('id', 'a1029000002aFZ2AAM'); // Input invalid Step id
      pageRef.getParameters().put('Popout', 'false');
      Test.setCurrentPageReference(pageRef);

      Test.startTest();
      AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
      System.assert(popout.IsErrorOccurred, 'Error should have occurred in the AH_UDC_ViewHelp constructor');
      Test.stopTest();
   }

   @isTest
   // Test not passing a Workbook Step ID
   private static void AH_UDC_ViewHelp_Negative_Test2() {
      PageReference pageRef = Page.AH_UDC_ViewHelp;
      pageRef.getParameters().put('Popout', 'true');
      Test.setCurrentPageReference(pageRef);

      Test.startTest();
      AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
      System.assert(popout.IsErrorOccurred, 'Error should have occurred in the AH_UDC_ViewHelp constructor');
      Test.stopTest();
   }

   @isTest
   // Test Help being accessed by a user that is not a Community user
   private static void AH_UDC_ViewHelp_Negative_Test3() {
      AH_UDC_WorkbookStep__c wbs = [SELECT Id, Name, Help__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__r.Name = :TEST_Workbook_Name];

      PageReference pageRef = Page.AH_UDC_ViewHelp;
      pageRef.getParameters().put('id', wbs.Id);
      pageRef.getParameters().put('community', 'false'); // Input community false
      Test.setCurrentPageReference(pageRef);

      Test.startTest();
      AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
      System.assert(!popout.IsCommunityView, 'AH_UDC_ViewHelp should not have been set to COMMUNITY view');
      Test.stopTest();
   }

   @isTest
   // Pass "TestException" to force code to fall into the CATCH block of the AH_UDC_ViewHelp constructor
   private static void AH_UDC_ViewHelp_Negative_Test4() {
      PageReference pageRef = Page.AH_UDC_ViewHelp;
      pageRef.getParameters().put('id', 'TestException');
      pageRef.getParameters().put('community', 'false'); // Input community false
      Test.setCurrentPageReference(pageRef);

      Test.startTest();
      AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
      System.assert(popout.IsErrorOccurred, 'Error should have occurred in the AH_UDC_ViewHelp constructor due to passing TestException as the WorkbookStep Id');
      Test.stopTest();
   }

   @isTest
   private static void AH_UDC_ViewHelp_ServerLogMessage() {
      Test.startTest();
      Test.clearApexPageMessages();

      AH_UDC_ViewHelp vh = new AH_UDC_ViewHelp();
      vh.LogFunctionalArea = 'TestException';
      vh.serverLogMessages();
      System.assert(vh.HasPageLoadLogMessages != true, 'HasPageLoadLogMessages should be false now as we have inserted all pending logs');

      Test.stopTest();
   }
=======
/***********************************************************************************************
  Name            : AH_UDC_ViewHelp_TEST
  Author          : Tushar Gupta
  Created Date    : 14-Apr-2021
  Last Mod Date   : 14-Apr-2021 , 15-June-2021
  Last Mod By     : Tushar Gupta , Ravi Shah
  Description     : Test class for AH_UDC_ViewHelp
 ************************************************************************************************/
@isTest
public class AH_UDC_ViewHelp_TEST {

   private static final String TEST_CONTACT_FIRSTNAME = 'AH_UDC_Test';
   private static final String TEST_USER_NAME = 'testViewHelp@user.com';
   private static final String TEST_Workbook_Name = 'Test Workbook 1';

   @TestSetup
   private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      //Create Account record
      Account objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      //Create Contact record
      Contact objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, TEST_CONTACT_FIRSTNAME + '001', 'AH_UDC_Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert objContact;

      // Create Property Account object with blank property name to get more code coverage
      AH_UDC_PropertyAccount__c objProperty = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      insert objProperty;

      //Create NI Doc record
      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
      insert objNIDoc;

      //Insert Contact NI Doc mapping record
      AH_UDC_Contact__c objUDCContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContact.Id, UserInfo.getDefaultCurrency());
      insert objUDCContact;

      //Insert Workbook Record
      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, TEST_Workbook_Name, 'Test Workbook 1 Description', product);
      insert objWorkbook;

      //Insert Workbook Step Record
      AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
      objWorkbookStep.URL__c = 'https://www.lipsum.com/';
      objWorkbookStep.Description__c = 'Test Step 1 Description';
      insert objWorkbookStep;

      List<User> listUsers = new List<User> ();
      //Build Community User with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              'ViewHelpCommunityUser', objContact.Id, true));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[0].Id);
      }
   }

   @isTest
   private static void AH_UDC_ViewHelp_Test() {

      User u = [SELECT Id FROM User where Username = :('TestViewHelpCommunityUser@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];

      AH_UDC_WorkbookStep__c wbs = [SELECT Id, Name, Help__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__r.Name = :TEST_Workbook_Name];

      System.runAs(u) {
         PageReference pageRef = Page.AH_UDC_ViewHelp;
         pageRef.getParameters().put('id', wbs.Id);
         Test.setCurrentPageReference(pageRef);

         Test.startTest();
         AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
         System.assert(!ApexPages.hasMessages(), 'Errors occurred while in the AH_UDC_ViewHelp constructor: ' + ApexPages.getMessages());
         System.assertEquals(popout.IsErrorOccurred, false, 'An error occurred in the the AH_UDC_ViewHelp constructor');
         System.assertEquals(wbs.Name, popout.StepName, 'Workbook Step name could not matched');
         System.assertEquals(wbs.Help__c, popout.HelpText, 'Workbook Step help text could not matched');
         Test.stopTest();
      }
   }

   @isTest
   // Test passing an invalid Workbook Step ID to the AH_UDC_ViewHelp
   private static void AH_UDC_ViewHelp_Negative_Test1() {
      User u = [SELECT Id FROM User where Username = :('TestViewHelpCommunityUser@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      PageReference pageRef = Page.AH_UDC_ViewHelp;
      pageRef.getParameters().put('id', 'a1029000002aFZ2AAM'); // Input invalid Step id
      pageRef.getParameters().put('Popout', 'false');
      System.runAs(u) {
         Test.setCurrentPageReference(pageRef);

         Test.startTest();
         AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
         System.assert(popout.IsErrorOccurred, 'Error should have occurred in the AH_UDC_ViewHelp constructor');
         Test.stopTest();
      }
   }

   @isTest
   // Test not passing a Workbook Step ID
   private static void AH_UDC_ViewHelp_Negative_Test2() {
      User u = [SELECT Id FROM User where Username = :('TestViewHelpCommunityUser@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      PageReference pageRef = Page.AH_UDC_ViewHelp;
      pageRef.getParameters().put('Popout', 'true');
      System.runAs(u) {
         Test.setCurrentPageReference(pageRef);

         Test.startTest();
         AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
         System.assert(popout.IsErrorOccurred, 'Error should have occurred in the AH_UDC_ViewHelp constructor');
         Test.stopTest();
      }
   }

   @isTest
   // Test Help being accessed by a user that is not a Community user
   private static void AH_UDC_ViewHelp_Negative_Test3() {
      AH_UDC_WorkbookStep__c wbs = [SELECT Id, Name, Help__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__r.Name = :TEST_Workbook_Name];
      User u = [SELECT Id FROM User where Username = :('TestViewHelpCommunityUser@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      PageReference pageRef = Page.AH_UDC_ViewHelp;
      pageRef.getParameters().put('id', wbs.Id);
      pageRef.getParameters().put('community', 'false'); // Input community false
      System.runAs(u) {
         Test.setCurrentPageReference(pageRef);

         Test.startTest();
         AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
         System.assert(!popout.IsCommunityView, 'AH_UDC_ViewHelp should not have been set to COMMUNITY view');
         Test.stopTest();
      }
   }

   @isTest
   // Pass "TestException" to force code to fall into the CATCH block of the AH_UDC_ViewHelp constructor
   private static void AH_UDC_ViewHelp_Negative_Test4() {
      User u = [SELECT Id FROM User where Username = :('TestViewHelpCommunityUser@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      PageReference pageRef = Page.AH_UDC_ViewHelp;
      pageRef.getParameters().put('id', 'TestException');
      pageRef.getParameters().put('community', 'false'); // Input community false
      System.runAs(u) {
         Test.setCurrentPageReference(pageRef);

         Test.startTest();
         AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
         System.assert(popout.IsErrorOccurred, 'Error should have occurred in the AH_UDC_ViewHelp constructor due to passing TestException as the WorkbookStep Id');
         Test.stopTest();
      }
   }

   @isTest
   private static void AH_UDC_ViewHelp_ServerLogMessage() {
      User u = [SELECT Id FROM User where Username = :('TestViewHelpCommunityUser@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      System.runAs(u) {
         Test.startTest();
         Test.clearApexPageMessages();

         AH_UDC_ViewHelp vh = new AH_UDC_ViewHelp();
         vh.LogFunctionalArea = 'TestException';
         vh.serverLogMessages();
         System.assert(vh.HasPageLoadLogMessages != true, 'HasPageLoadLogMessages should be false now as we have inserted all pending logs');

         Test.stopTest();
      }
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}