/***********************************************************************************************
  Name            : AH_UDC_ViewWorkbook_Test
  Author          : Rob Stevens (Rob.Stevens@amadeus.com)
  Created Date    : 2021-04-12
  Description     : Test class for View Workbook Page
 ************************************************************************************************/
@isTest
public class AH_UDC_ViewWorkbook_Test {

   @testSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      Boolean isException = false;
      Account objAccount = null;
      Contact objContact = null;
      User objUser = null;
      User objUser1 = null;
      AH_UDC_PropertyAccount__c objProperty = null;
      NI_Documentation__c objNIDoc = null;
      NI_Documentation__c objNIDocForTestA = null;
      AH_UDC_Contact__c objUDCContact = null;
      AH_UDC_Workbook__c objWorkbook = null;
      AH_UDC_WorkbookStep__c objWorkbookStep = null;
      AH_UDC_WorkbookStep__c objWorkbookStep2 = null;
      FeedItem objFeedItem = null;
      FeedComment objFeedComment = null;
      String errorMessage = '';
      Boolean IsCommunityView = true;
      AH_UDC_PropertyAccount__c objProperty1 = null;
      NI_Documentation__c objNIDoc1 = null;
      AH_UDC_Workbook__c objWorkbook1 = null;
      AH_UDC_WorkbookStep__c objWorkbookStep3 = null;
      Contact objContact1 = null;
      AH_UDC_Contact__c objUDCContact1 = null;
      //Create Account record
      objAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account for Test class', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
      insert objAccount;

      //Create Contact record
      objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert objContact;

      objContact1 = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test1', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert objContact1;

      //Get ProfileId to create User record
      Id profileId = [SELECT Id FROM profile WHERE name = 'AH Customer Community Plus Login User'].Id;
      System.assertEquals(true, profileId != null, 'Profile (AH Customer Community Plus Login User) record not found');

      //Create Community user with no chatter
      AH_UDC_TestData.CreateUDCCommunityUser('CUserNoChatter', true);
      List<User> lstUser = [Select Id From User Where Email = 'TestCUserNoChatter@amadeus.com'];
      System.assert(lstUser.size() > 0, 'user could not be found.');

      //Insert into Property Account object with blank property name to get more code coverage
      objProperty = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
      insert objProperty;

      //Insert into Property Account object with blank property name to get more code coverage
      objProperty1 = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
      insert objProperty1;

      //Create NI Doc record
      objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
      insert objNIDoc;

      objNIDoc1 = AH_UDC_TestData.GetNIDocObject('Test NI Document 12', Date.newInstance(2021, 3, 31));
      objNIDoc1.AH_UDC_PropertyAccount__c = objProperty1.Id;
      objNIDoc1.AH_UDC_PropertyConfirmation__c = true;
      insert objNIDoc1;

      //Insert Contact NI Doc mapping record
      objUDCContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContact.Id, 'USD');
      insert objUDCContact;

      System.debug('$$$UserInfo.getUserName: #1');
      System.debug('$$$UserInfo.getUserName: ' + UserInfo.getUserName());

      System.runAs(lstUser[0]) {
         Schema.DescribeFieldResult fieldResult = null;
         List<Schema.PicklistEntry> pickListEntry = null;
         fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();
         if (fieldResult != null) {
            pickListEntry = fieldResult.getPicklistValues();
         }
         System.debug('$$$UserInfo.getUserName: #2');
         System.debug('$$$UserInfo.getUserName: ' + UserInfo.getUserName());
         //Insert Workbook Record
         objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         objWorkbook.Product__c = pickListEntry[0].getLabel();
         objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
         insert objWorkbook;

         System.debug('$$$Workbook ID: ' + objWorkbook.ID);
         List<AH_UDC_Workbook__c> workbooks = [SELECT ID, CreatedBy.Name from AH_UDC_Workbook__c where ID =:objWorkbook.ID];
         System.debug('$$$Workbook CreatedBy: ' + workbooks[0].CreatedBy.Name);
         

         objFeedItem = new FeedItem();
         objFeedItem.ParentId = objNIDoc.Id;
         objFeedItem.Type = 'TextPost';
         objFeedItem.IsRichText = false;
         objFeedItem.Body = 'Test Message 1';
         insert objFeedItem;

         objFeedComment = new FeedComment();
         objFeedComment.FeedItemId = objFeedItem.Id;
         objFeedComment.CommentType = 'TextComment';
         objFeedComment.IsRichText = false;
         objFeedComment.CommentBody = 'Test Comment 1';
         insert objFeedComment;

         //Insert Workbook Step Record
         objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
         objWorkbookStep.Help__c = 'google';
         objWorkbookStep.URL__c = 'www.google.com';
         objWorkbookStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_NEW;
         insert objWorkbookStep;

      }
      System.debug('$$$UserInfo.getUserName: #3');
      System.debug('$$$UserInfo.getUserName: ' + UserInfo.getUserName());

      //Create User record
      objUser = AH_UDC_TestData.GetUserObject(objContact.Id, profileId, 'Test', 'User', 'Mr.', 'test@user.com', 'test@user.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
      insert objUser;

      objUser1 = AH_UDC_TestData.GetUserObject(objContact1.Id, profileId, 'Test1', 'User1', 'Mr.', 'test1@user.com', 'test1@user.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
      insert objUser1;

      System.runAs(objUser1) {
         Schema.DescribeFieldResult fieldResult = null;
         List<Schema.PicklistEntry> pickListEntry = null;
         fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();
         if (fieldResult != null) {
            pickListEntry = fieldResult.getPicklistValues();
         }

         //Insert Workbook Record
         objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(objNIDoc1.Id, 'Test Workbook 1-1', 'Test Workbook 1-1 Description', 'Central Sales');
         objWorkbook1.Product__c = pickListEntry[0].getLabel();
         objWorkbook1.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
         insert objWorkbook1;

         //Insert Workbook Step Record
         objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook1.Id, 'Test Step 1');
         objWorkbookStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_NEW;
         objWorkbookStep.URL__c = 'https://www.lipsum.com/';
         insert objWorkbookStep;

         System.runAs(objUser) {
            //Insert into Property Account object with blank property name to get more code coverage
            objProperty = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
            insert objProperty;

            //Create NI Doc record
            objNIDocForTestA = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
            objNIDocForTestA.AH_UDC_PropertyAccount__c = objProperty.Id;
            insert objNIDocForTestA;

            //Insert Contact NI Doc mapping record
            objUDCContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContact.Id, 'USD');
            insert objUDCContact;

            objUDCContact1 = AH_UDC_TestData.GetUDCContactObject(objNIDoc1.Id, objContact1.Id, 'USD');
            insert objUDCContact1;

            fieldResult = null;
            pickListEntry = null;
            fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();
            if (fieldResult != null) {
               pickListEntry = fieldResult.getPicklistValues();
            }

            objWorkbook = null;
            //Insert Workbook Record
            objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDocForTestA.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
            objWorkbook.Product__c = pickListEntry[0].getLabel();
            objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
            insert objWorkbook;

            objFeedItem = new FeedItem();
            objFeedItem.ParentId = objNIDocForTestA.Id;
            objFeedItem.Type = 'TextPost';
            objFeedItem.IsRichText = false;
            objFeedItem.Body = 'Test Message 1';
            objFeedItem.CreatedById = objUser.Id;
            insert objFeedItem;

            objFeedComment = new FeedComment();
            objFeedComment.FeedItemId = objFeedItem.Id;
            objFeedComment.CommentType = 'TextComment';
            objFeedComment.IsRichText = false;
            objFeedComment.CommentBody = 'Test Comment 1';
            insert objFeedComment;

            //Insert Workbook Step Record
            objWorkbookStep3 = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1-1');
            objWorkbookStep3.Help__c = 'google';
            objWorkbookStep3.URL__c = 'www.google.com';
            objWorkbookStep3.StepStatus__c = AH_UDC_Constants.STEP_STATUS_NEW;
            insert objWorkbookStep3;
         }
      }
   }

   @isTest
   private static void AH_UDC_ViewWorkbook_Test() {
      List<User> lstUser = [Select Id From User Where Email = 'TestCUserNoChatter@amadeus.com'];
      System.assert(lstUser.size() > 0, 'User could not be found.');
      System.runAs(lstUser[0]) {
         List<AH_UDC_Workbook__c> lstWorkbook = [Select Id, RelatedTo__c From AH_UDC_Workbook__c Where Name = 'Test Workbook 1'];
         System.assert(lstWorkbook.size() > 0, 'Workbooks could not be found.');
         PageReference pageRef = Page.AH_UDC_ViewWorkbook;
         pageRef.getParameters().put('Id', lstWorkbook[0].Id); //Pass Workbook Id as a parameter
         pageRef.getParameters().put('community', 'false');
         Test.setCurrentPageReference(pageRef);

         Test.startTest();
         AH_UDC_ViewWorkbook objViewWorkbook = new AH_UDC_ViewWorkbook();
         Boolean HasPageLoadLogMessages = objViewWorkbook.HasPageLoadLogMessages;
         objViewWorkbook.ShowErrorMessage();
         System.assert(objViewWorkbook.ShowErrorMessage, 'ShowErrorMessage could not be true');

         objViewWorkbook.serverLogMessages();
         System.assert(objViewWorkbook.PageLoadLogMessages != null, 'PageLoadLogMessages could not be null');

         objViewWorkbook.serverConfirmProperty();
         List<NI_Documentation__c> lstNIdoc = [Select Id, AH_UDC_PropertyConfirmation__c From NI_Documentation__c Where Id = :lstWorkbook[0].RelatedTo__c];
         System.assert(lstNIdoc.size() > 0, 'Ni Documentation could not be found.');
         System.assert(lstNIdoc[0].AH_UDC_PropertyConfirmation__c, 'Property Confirmation could not be marked as complete.');

         //objViewWorkbook.ActionFunction_LogMessages();
         objViewWorkbook.serverChangeToNextStepNotCompleted();
         System.assert(objViewWorkbook.currentPosition == 1, 'Current position could not be matched.');
         objViewWorkbook.serverUpdateTimer();
         objViewWorkbook.serverMarkStepComplete();

         List<AH_UDC_WorkbookStep__c> lstwbStep = [select id, StepStatus__c, StepCompleted__c
                                                   from AH_UDC_WorkbookStep__c
                                                   where id = :objViewWorkbook.currentStep.id];

         System.assert(lstwbStep.size() > 0, 'Workbook steps could not be found.');
         System.assert(lstwbStep[0].StepStatus__c == AH_UDC_Constants.STEP_STATUS_COMPLETED, 'Workbook steps could not be found.');

         objViewWorkbook.serverUpdateTimer();
         //objViewWorkbook.serverMarkStepComplete();
         objViewWorkbook.serverChangeToStep();
         System.assert(objViewWorkbook.currentPosition == 1, 'Current position could not be matched.');

         objViewWorkbook.CheckChatterFeedNotification();
         System.assert(!objViewWorkbook.chatterUpdate, 'ChatterUpdate value should be false.');
         Test.stopTest();
      }
   }

   @isTest
   private static void AH_UDC_ViewWorkbook_Test_A() {
      List<User> lstUser = [Select Id From User Where Email = 'test@user.com'];
      System.assert(lstUser.size() > 0, 'User could not be found.');

      System.runAs(lstUser[0]) {
         List<User> lstUser1 = [Select Id From User Where Email = 'test1@user.com'];
         System.assert(lstUser1.size() > 0, 'User could not be found.');
         System.runAs(lstUser1[0]) {
            List<AH_UDC_Workbook__c> lstWorkbook = [Select Id, RelatedTo__c From AH_UDC_Workbook__c Where Name = 'Test Workbook 1-1'];
            System.assert(lstWorkbook.size() > 0, 'Workbooks could not be found.');

            PageReference pageRef = Page.AH_UDC_ViewWorkbook;
            pageRef.getParameters().put('Id', lstWorkbook[0].Id); //Pass Workbook Id as a parameter 
            pageRef.getParameters().put('community', 'true');
            Test.setCurrentPageReference(pageRef);
            Test.startTest();
            AH_UDC_ViewWorkbook objViewWorkbook = new AH_UDC_ViewWorkbook();
            //objViewWorkbook.GetAddress(objProperty);
            objViewWorkbook.ShowErrorMessage();
            System.assert(objViewWorkbook.ShowErrorMessage, 'ShowErrorMessage could not be true');

            objViewWorkbook.serverLogMessages();
            System.assert(objViewWorkbook.PageLoadLogMessages != null, 'PageLoadLogMessages could not be null');

            objViewWorkbook.serverConfirmProperty();
            List<NI_Documentation__c> lstNIdoc = [Select Id, AH_UDC_PropertyConfirmation__c From NI_Documentation__c Where Id = :lstWorkbook[0].RelatedTo__c];
            System.assert(lstNIdoc.size() > 0, 'Ni Documentation could not be found.');
            System.assert(lstNIdoc[0].AH_UDC_PropertyConfirmation__c, 'Property Confirmation could not be marked as complete.');

            objViewWorkbook.serverSubmit();
            System.assertEquals(System.Label.AH_UDC_Workbook_Completion_Confirmation_Msg,objViewWorkbook.NotificationToShow, 'Workbook sent status could not be updated as locked.');

            objViewWorkbook.serverChangeToNextStepNotCompleted();
            System.assert(objViewWorkbook.currentPosition == 1, 'Current position could not be matched.');
            objViewWorkbook.serverUpdateTimer();
            objViewWorkbook.serverMarkStepComplete();

            List<AH_UDC_WorkbookStep__c> lstwbStep = [select id, StepStatus__c, StepCompleted__c
                                                      from AH_UDC_WorkbookStep__c
                                                      where id = :objViewWorkbook.currentStep.id];

            System.assert(lstwbStep.size() > 0, 'Workbook steps could not be found.');
            System.assert(lstwbStep[0].StepStatus__c == AH_UDC_Constants.STEP_STATUS_COMPLETED, 'Workbook steps could not be found.');

            objViewWorkbook.serverChangeToStep();
            System.assert(objViewWorkbook.currentPosition == 1, 'Current position could not be matched.');

            objViewWorkbook.CheckChatterFeedNotification();
            System.assert(!objViewWorkbook.chatterUpdate, 'ChatterUpdate value should be false.');
            
            objViewWorkbook.serverCollapsedMenuMove();
            System.assert(!objViewWorkbook.ShowCollapsedMenuUpNavigation, 'ShowCollapsedMenuUpNavigation value should be false.');
            Test.stopTest();
         }
      }
   }
   //TODO ROBDEV need to fix and restore
   //@isTest
   //private static void AH_UDC_ViewWorkbook_Test_B() {
      //List<User> lstUser = [Select Id From User Where Email = 'test@user.com'];
      //System.assert(lstUser.size() > 0, 'User could not be found.');
      //NI_Documentation__c nidoc = [select id from NI_Documentation__c where Name='Test NI Document 1'];

      //System.runAs(lstUser[0]) {
         //Schema.DescribeFieldResult fieldResult = null;
         //List<Schema.PicklistEntry> pickListEntry = null;
         //fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();
         //if (fieldResult != null) {
            //pickListEntry = fieldResult.getPicklistValues();
         //}

         //System.debug('$$$UserInfo.getUserName: #T2');
         //System.debug('$$$UserInfo.getUserName: ' + UserInfo.getUserName());
         ////Insert Workbook Record
         //AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(nidoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         //objWorkbook.Product__c = pickListEntry[0].getLabel();
         //objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
         //insert objWorkbook;

         //System.debug('$$$Workbook ID: ' + objWorkbook.ID);
         //List<AH_UDC_Workbook__c> workbooks = [SELECT ID, CreatedBy.Name from AH_UDC_Workbook__c where ID =:objWorkbook.ID];
         //System.debug('$$$Workbook CreatedBy: ' + workbooks[0].CreatedBy.Name);

         //List<AH_UDC_Workbook__c> lstWorkbook = [Select Id, RelatedTo__c From AH_UDC_Workbook__c Where Name = 'Test Workbook 1'];
         //System.assert(lstWorkbook.size() > 0, 'Workbooks could not be found.');
         //PageReference pageRef = Page.AH_UDC_ViewWorkbook;
         //pageRef.getParameters().put('Id', lstWorkbook[0].Id); //Pass Workbook Id as a parameter
         //pageRef.getParameters().put('community', 'false');
         //Test.setCurrentPageReference(pageRef);
         //Test.startTest();

         //AH_UDC_ViewWorkbook objViewWorkbook = new AH_UDC_ViewWorkbook();
         //objViewWorkbook.ShowErrorMessage();
         //System.assert(objViewWorkbook.ShowErrorMessage, 'ShowErrorMessage could not be true');

         //objViewWorkbook.serverLogMessages();
         //System.assert(objViewWorkbook.PageLoadLogMessages != null, 'PageLoadLogMessages could not be null');

         //objViewWorkbook.serverConfirmProperty();
         //List<NI_Documentation__c> lstNIdoc = [Select Id, AH_UDC_PropertyConfirmation__c From NI_Documentation__c Where Id = :lstWorkbook[0].RelatedTo__c];
         //System.assert(lstNIdoc.size() > 0, 'Ni Documentation could not be found.');
         //System.assert(lstNIdoc[0].AH_UDC_PropertyConfirmation__c, 'Property Confirmation could not be marked as complete.');

         //objViewWorkbook.serverSubmit();
         //List<AH_UDC_Workbook__c> lstWorkbook1 = [Select Id, SentStatus__c From AH_UDC_Workbook__c Where Name = 'Test Workbook 1'];
         //System.assert(lstWorkbook1.size() > 0, 'Workbooks could not be found.');
         //System.assert(AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED == lstWorkbook1[0].SentStatus__c, 'Workbook sent status could not be updated as locked.');

         ////objViewWorkbook.ActionFunction_LogMessages();
         //objViewWorkbook.serverChangeToNextStepNotCompleted();
         //System.assert(objViewWorkbook.currentPosition == 1, 'Current position could not be matched.');

         //objViewWorkbook.serverUpdateTimer();
         //System.assert(objViewWorkbook.workbook.completedSteps == 0, 'Completed Steps could not be matched.');
         
         //objViewWorkbook.CheckChatterFeedNotification();
         //System.assert(!objViewWorkbook.chatterUpdate, 'ChatterUpdate value should be false.');

         //Test.stopTest();
      //}
   //}
   @isTest
   private static void NegativeTestA() {
      List<User> lstUser = [Select Id From User Where Email = 'test@user.com'];
      System.assert(lstUser.size() > 0, 'User could not be found.');

      System.runAs(lstUser[0]) {
         PageReference pageRef = Page.AH_UDC_ViewWorkbook;
         pageRef.getParameters().put('Id', lstUser[0].Id); //Passing junk/invalid id
         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         AH_UDC_ViewWorkbook objViewWorkbook = new AH_UDC_ViewWorkbook();
         objViewWorkbook.ShowErrorMessage();
         System.assert(objViewWorkbook.ShowErrorMessage, 'ShowErrorMessage could not be true');

         objViewWorkbook.serverLogMessages();
         System.assert(objViewWorkbook.PageLoadLogMessages != null, 'PageLoadLogMessages could not be null');

         objViewWorkbook.serverConfirmProperty();
         System.assert(objViewWorkbook.workbook.propertyInfo.isPropertyConfirmed == null, 'isPropertyConfirmed could be null');

         objViewWorkbook.serverSubmit();
         System.assert(String.isBlank(objViewWorkbook.NotificationToShow), 'NotificationToShow could be blank/null');

         objViewWorkbook.serverChangeToNextStepNotCompleted();
         System.assert(objViewWorkbook.changeToPositionNumber != 1, 'changeToPositionNumber could not match');

         objViewWorkbook.serverUpdateTimer();
         System.assert(objViewWorkbook.workbook.completedSteps == 0, 'completedSteps could not match');

         objViewWorkbook.CheckChatterFeedNotification();
         System.assert(objViewWorkbook.chatterUpdate == false, 'chatterUpdate could be false');

         objViewWorkbook.serverMarkStepComplete();
         System.assertEquals(System.Label.AH_UDC_Common_Error_Message, objViewWorkbook.NotificationToShow, 'NotificationToShow could not be matched');

         objViewWorkbook.serverChangeToStep();
         System.assert(objViewWorkbook.changeToPositionNumber != 1, 'changeToPositionNumber could not match');

         Test.stopTest();
      }
   }

   @isTest
   private static void NegativeTestB() {
      List<User> lstUser1 = [Select Id From User Where Email = 'test1@user.com'];
      System.assert(lstUser1.size() > 0, 'User could not be found.');

      List<AH_UDC_Workbook__c> lstWorkbook = [Select Id, RelatedTo__c From AH_UDC_Workbook__c Where Name = 'Test Workbook 1'];
      System.assert(lstWorkbook.size() > 0, 'Workbooks could not be found.');

      System.runAs(lstUser1[0]) {
         PageReference pageRef = Page.AH_UDC_ViewWorkbook;
         pageRef.getParameters().put('id', lstWorkbook[0].Id); //Pass the workbook id, which is not assign to the user
         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         AH_UDC_ViewWorkbook objViewWorkbook = new AH_UDC_ViewWorkbook();
         objViewWorkbook.ShowErrorMessage();
         System.assert(objViewWorkbook.ShowErrorMessage, 'ShowErrorMessage could not be true');
         Test.stopTest();
      }
   }

   //TODO ROBDEV Fix test
   //@isTest
   //private static void NegativeTestC() {
      //List<User> lstUser1 = [Select Id From User Where Email = 'test1@user.com'];
      //System.assert(lstUser1.size() > 0, 'User could not be found.');

      //System.runAs(lstUser1[0]) {
         //PageReference pageRef = Page.AH_UDC_ViewWorkbook;
         ////Did not pass any query string value
         //Test.setCurrentPageReference(pageRef);
         //Test.startTest();
         //AH_UDC_ViewWorkbook objViewWorkbook = new AH_UDC_ViewWorkbook();
         //objViewWorkbook.serverChangeToNextStepNotCompleted();
         //System.assert(objViewWorkbook.changeToPositionNumber != 1, 'changeToPositionNumber could not match');

         //objViewWorkbook.serverMarkStepComplete();
         //System.debug('objViewWorkbook.NotificationToShow'+ objViewWorkbook.NotificationToShow);
         //System.assertEquals(System.Label.AH_UDC_Common_Error_Message,objViewWorkbook.NotificationToShow, 'NotificationToShow could be blank'); 

         //objViewWorkbook.serverChangeToStep();
         //System.assert(objViewWorkbook.changeToPositionNumber != 1, 'changeToPositionNumber could not match');

         //objViewWorkbook.serverCollapsedMenuMove();
         //System.assert(!objViewWorkbook.ShowCollapsedMenuUpNavigation, 'ShowCollapsedMenuUpNavigation value should be false.');
         //Test.stopTest();
      //}
   //}
}