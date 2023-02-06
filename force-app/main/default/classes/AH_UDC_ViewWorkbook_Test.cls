/***********************************************************************************************
  Name            : AH_UDC_ViewWorkbook_TEST
  Author          : Rob Stevens (Rob.Stevens@amadeus.com)
  Created Date    : 2021-04-12
  Description     : Test class for View Workbook Page
 ************************************************************************************************/
@isTest
private class AH_UDC_ViewWorkbook_TEST {
   @testSetup static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      Account objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      List<Contact> lstContacts = new List<Contact> ();
      lstContacts.add(AH_UDC_TestData.GetContactObject(objAccount.Id, 'ChatterUser1'));
      lstContacts.add(AH_UDC_TestData.GetContactObject(objAccount.Id, 'ChatterUser2'));
      lstContacts.add(AH_UDC_TestData.GetContactObject(objAccount.Id, 'NoChatterUser'));
      insert lstContacts;

      List<User> listUsers = new List<User> ();

      //Create community user with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                    'ChatterUser1', lstContacts[0].Id, true));

      //Create community user with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                    'ChatterUser2', lstContacts[1].Id, true));

      //Create community user without chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                    'NoChatterUser', lstContacts[2].Id, true));

      //Create Service user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                    'VW_ServiceUser1', null, false));

      //Create workbook user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'VW_WBUser1', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[2].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE, listUsers[3].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[4].Id);
      }

      AH_UDC_PropertyAccount__c objProperty = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      insert objProperty;

      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
      insert objNIDoc;

      List<AH_UDC_Contact__c> lstUDCContacts = new List<AH_UDC_Contact__c> ();
      lstUDCContacts.add(AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, listUsers[0].ContactId, 'USD'));
      lstUDCContacts.add(AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, listUsers[2].ContactId, 'USD'));
      lstUDCContacts.add(AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, listUsers[1].ContactId, 'USD'));
      lstUDCContacts[2].ChatterLastViewed__c = Datetime.now(); //Get code coverge of else block in the method CheckChatterFeedNotification
      //Assign workbook to both the users
      insert lstUDCContacts;

      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      //Set workbook status to new to cover code of changing workbook status in-progress in the method serverConfirmProperty
      objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
      insert objWorkbook;

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
      for (Integer i = 1; i <= 5; i++) {
         AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step ' + i);
         objWorkbookStep.SortOrder__c = i;
         objWorkbookStep.URL__c = 'https://www.amadeus.com/' + i;

         if (i == 1) {
            objWorkbookStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_LOCKED; //Lock first step
            objWorkbookStep.Help__c = 'Test help text';
         }
         lstWorkbookSteps.add(objWorkbookStep);
      }
      insert lstWorkbookSteps;

      //For each Workbook Sent Step create a response
      List<AH_UDC_Response__c> lstResponses = new List<AH_UDC_Response__c> ();
      for (Integer i = 1; i <= 5; i++) {
         AH_UDC_Response__c objResponse = AH_UDC_TestData.GetStepResponseObject();
         lstResponses.add(objResponse);
      }
      insert lstResponses;

      //For each Workbook Sent Step create a WorkbookStepResponse
      List<AH_UDC_WorkbookStepResponse__c> lstWBStepResponses = new List<AH_UDC_WorkbookStepResponse__c> ();
      for (Integer i = 1; i <= 5; i++) {
         AH_UDC_WorkbookStepResponse__c objWBStepResponse = AH_UDC_TestData.GetWorkbookStepResponseObject(lstWorkbookSteps[i-1].id,lstResponses[i-1].id);
         lstWBStepResponses.add(objWBStepResponse);
      }
      insert lstWBStepResponses;

      //Set prerequisite steps for some of the steps
      lstWorkbookSteps[3].Prerequisite_Step__c = lstWorkbookSteps[1].Id; //Set 2nd step as a prerequisite of 4th step
      lstWorkbookSteps[4].Prerequisite_Step__c = lstWorkbookSteps[2].Id; //Set 3rd step as a prerequisite of 5th step
      update lstWorkbookSteps;

      NI_Documentation__c objNIDoc2 = AH_UDC_TestData.GetNIDocObject('Test Exception NI Doc', Date.newInstance(2021, 12, 31));
      insert objNIDoc2;

      AH_UDC_Workbook__c objWorkbook2 = AH_UDC_TestData.GetWorkbookObject(objNIDoc2.Id, 'Test Exception Workbook', 'Test Exception Workbook Description', 'Central Sales');
      objWorkbook2.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
      insert objWorkbook2;

      //Test Data for FileUpload
      NI_Documentation__c objNIDoc3 = AH_UDC_TestData.GetNIDocObject('Test FileUpload NI Doc', Date.newInstance(2021, 12, 31));
      objNIDoc3.AH_UDC_PropertyAccount__c = objProperty.Id;
      insert objNIDoc3;

      // Find the "Workbook Sent" record type Id
      Id rtWbSentId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      AH_UDC_Workbook__c objWorkbook3 = AH_UDC_TestData.GetWorkbookObject(objNIDoc3.Id, 'Test FileUpload Workbook', 'Test FileUpload Workbook Description', 'SO');
      objWorkbook3.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
      objWorkbook3.RecordtypeId = rtWbSentId;
      insert objWorkbook3;

      //Insert Contact NI Doc mapping record
      AH_UDC_Contact__c objUDCContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc3.Id, lstContacts[2].Id, UserInfo.getDefaultCurrency());
      insert objUDCContact;

      Id fileUploadRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      AH_UDC_Form__c fileUploadForm = AH_UDC_TestData.GetForm('', '', 'TestFormFileUpload', '');
      fileUploadForm.RecordTypeId = fileUploadRecordTypeId;
      insert fileUploadForm;
      // Find the Workbook Step Sent Record Type
      Id rtWbsSentId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

      // Create Workbook Sent Step
      AH_UDC_WorkbookStep__c fileUploadWBS = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook3.Id, 'TestFileUpload');
      fileUploadWBS.RecordTypeId = rtWbsSentId;
      fileUploadWBS.Workbook__c = objWorkbook3.Id;
      fileUploadWBS.Form__c = fileUploadForm.Id;
      insert fileUploadWBS;

      Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing');
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'VW_ServiceUser1'];

      System.runAs(UDCServiceUser1)
      {
         ContentVersion cv = new ContentVersion(
                                                Title = 'TestFileUpload',
                                                PathOnClient = 'TestFileUpload.txt',
                                                VersionData = bodyBlob,
                                                ContentLocation = 'S',
                                                OwnerId = UDCServiceUser1.Id);

         insert cv;

         ContentVersion cvWithCDId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

         ContentDocumentLink contentlink = new ContentDocumentLink();
         contentlink.LinkedEntityId = objNIDoc3.id;
         contentlink.Visibility = 'AllUsers';
         contentlink.ContentDocumentId = cvWithCDId.ContentDocumentId;
         insert contentlink;
      }

      System.runAs(listUsers[0]) {
         FeedItem objFeedItem = new FeedItem();
         objFeedItem.ParentId = objNIDoc.Id;
         objFeedItem.Type = 'TextPost';
         objFeedItem.IsRichText = false;
         objFeedItem.Body = 'Test Message 1';
         AH_UDC_SystemContext.CreateObject(objFeedItem);

         FeedComment objFeedComment = new FeedComment();
         objFeedComment.FeedItemId = objFeedItem.Id;
         objFeedComment.CommentType = 'TextComment';
         objFeedComment.IsRichText = false;
         objFeedComment.CommentBody = 'Test Comment 1';
         AH_UDC_SystemContext.CreateObject(objFeedComment);
      }

      System.runAs(listUsers[1]) {
         FeedItem objFeedItem = new FeedItem();
         objFeedItem.ParentId = objNIDoc.Id;
         objFeedItem.Type = 'TextPost';
         objFeedItem.IsRichText = false;
         objFeedItem.Body = 'Test Message 2';
         AH_UDC_SystemContext.CreateObject(objFeedItem);
      }
   }

   @isTest static void TestWithChatterUser() {
      String strUserName = 'TestChatterUser1@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX;
      List<User> lstCommunityUsers = [SELECT ContactId FROM User
                                      WHERE Username = :strUserName
                                      AND IsActive = true];
      System.assert(lstCommunityUsers.size() > 0, 'Chatter user 1 record not found');

      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id, RelatedTo__c, SentStatus__c, CompletedBy__c, CompletedDate__c
                                               FROM AH_UDC_Workbook__c
                                               WHERE Name = 'Test Workbook 1'
                                               AND Enabled__c = true
                                               AND RecordTypeId = :workbookSentRecordTypeId];
      System.assert(lstworkbooks.size() > 0, 'Workbook sent records not found with the name - Test Workbook 1');

      //Retrieve messages created by chatter user 1
      List<FeedItem> lstFeedItems = AH_UDC_SystemContext.query('SELECT Id FROM FeedItem WHERE ParentId = \'' + lstWorkbooks[0].RelatedTo__c + '\' AND InsertedById = \'' + lstCommunityUsers[0].Id + '\'');
      System.assert(lstFeedItems.size() > 0, 'Feed item record not found created by chatter user 1');

      System.runAs(lstCommunityUsers[0]) { //Test using chatter user
         Test.startTest();
         //Run as community portal
         TestViewWorkbook(lstWorkbooks[0].Id, false, lstFeedItems[0].Id, true);
         Test.stopTest();
      }
   }

   @isTest static void TestWithNoChatterUser() {
      String strUserName = 'TestNoChatterUser@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX;
      List<User> lstCommunityUsers = [SELECT ContactId FROM User
                                      WHERE Username = :strUserName
                                      AND IsActive = true];
      System.assert(lstCommunityUsers.size() > 0, 'No chatter user record not found');

      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id, RelatedTo__c, SentStatus__c, CompletedBy__c, CompletedDate__c
                                               FROM AH_UDC_Workbook__c
                                               WHERE Name = 'Test Workbook 1'
                                               AND Enabled__c = true
                                               AND RecordTypeId = :workbookSentRecordTypeId];
      System.assert(lstworkbooks.size() > 0, 'Workbook sent records not found with the name - Test Workbook 1');

      List<NI_Documentation__c> lstNIDocs = [SELECT AH_UDC_PropertyConfirmation__c, AH_UDC_PropertyConfirmationAccepted_Date__c
                                             FROM NI_Documentation__c
                                             WHERE Document_Name__c = 'Test NI Document 1'];
      System.assert(lstNIDocs.size() > 0, 'NI Document record not found with the name Test NI Document 1');

      lstNIDocs[0].AH_UDC_PropertyConfirmation__c = true;
      lstNIDocs[0].AH_UDC_PropertyConfirmationAccepted_Date__c = Datetime.now();
      update lstNIDocs; //Confirm property to cover more coverage

      lstWorkbooks[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
      update lstWorkbooks[0]; //Make workbook status in-progress because property is already confirmed so it will not update workbook status to in-progress

      System.runAs(lstCommunityUsers[0]) { //Test using no chatter user
         Test.startTest();
         //Run as community portal
         TestViewWorkbook(lstWorkbooks[0].Id, true, null, true);
         Test.stopTest();
      }
   }

   @isTest static void TestWBUser() {
      List<User> lstWBUsers = [SELECT ContactId FROM User
                                      WHERE Username like '%VW_WBUser1%'
                                      AND IsActive = true];
      System.assert(lstWBUsers.size() > 0, 'No chatter user record not found');

      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id, RelatedTo__c, SentStatus__c, CompletedBy__c, CompletedDate__c
                                               FROM AH_UDC_Workbook__c
                                               WHERE Name = 'Test Workbook 1'
                                               AND Enabled__c = true
                                               AND RecordTypeId = :workbookSentRecordTypeId];
      System.assert(lstworkbooks.size() > 0, 'Workbook sent records not found with the name - Test Workbook 1');

      System.runAs(lstWBUsers[0]) { //Test using no chatter user
         Test.startTest();
         //Run without community portal
         TestViewWorkbook(lstWorkbooks[0].Id, false, null, false);
         Test.stopTest();
      }
   }

   @isTest static void TestFileUploadWithCommunityUser() {

      String strUserName = 'TestNoChatterUser@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX;
      List<User> lstCommunityUsers = [SELECT ContactId FROM User
                                      WHERE Username = :strUserName
                                      AND IsActive = true];
      System.assert(lstCommunityUsers.size() > 0, 'No chatter user record not found');

      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id, RelatedTo__c, SentStatus__c, CompletedBy__c, CompletedDate__c
                                               FROM AH_UDC_Workbook__c
                                               WHERE Name = 'Test FileUpload Workbook'
                                               AND Enabled__c = true
                                               AND RecordTypeId = :workbookSentRecordTypeId];
      System.assert(lstworkbooks.size() > 0, 'Workbook sent records not found with the name - Test FileUpload Workbook');
      List<AH_UDC_WorkbookStep__c> wbSteps = [SELECT id, name, Form__r.RecordTypeId
                                              FROM AH_UDC_WorkbookStep__c
                                              WHERE Enabled__c = true and Workbook__c = :lstWorkbooks[0].Id order by SortOrder__c asc];
      System.assert(wbSteps.size() > 0, 'WorkbookStep sent records not found');

      List<NI_Documentation__c> lstNIDocs = [SELECT Id, AH_UDC_PropertyConfirmation__c, AH_UDC_PropertyConfirmationAccepted_Date__c
                                             FROM NI_Documentation__c
                                             WHERE Document_Name__c = 'Test FileUpload NI Doc'];
      System.assert(lstNIDocs.size() > 0, 'NI Document record not found with the name Test FileUpload NI Document');

      List<ContentDocumentLink> lstCDL = [SELECT ContentDocument.title, ContentDocument.CreatedDate, ContentDocumentId FROM ContentDocumentLink
                                          WHERE IsDeleted = false AND LinkedEntityId = :lstNIDocs[0].Id];
      System.assert(lstCDL.size() > 0, 'File not exist for Test FileUpload NI Doc');

      lstNIDocs[0].AH_UDC_PropertyConfirmation__c = true;
      lstNIDocs[0].AH_UDC_PropertyConfirmationAccepted_Date__c = Datetime.now();
      update lstNIDocs; //Confirm property to cover more coverage

      System.runAs(lstCommunityUsers[0]) { //Test using community user no chatter
         Test.startTest();
         PageReference pageRef = Page.AH_UDC_ViewWorkbook;
         pageRef.getParameters().put('Id', lstworkbooks[0].Id); //Pass Workbook Id as a parameter
         pageRef.getParameters().put('community', 'true');
         Test.setCurrentPageReference(pageRef);

         AH_UDC_ViewWorkbook objViewWorkbook = new AH_UDC_ViewWorkbook();
         System.assertEquals(true, objViewWorkbook.currentStep.isAmadeusFileUpload, 'isAmadeusFileUpload should be true');
         System.assertEquals(1, objViewWorkbook.workbook.steps.size(), 'Workbook step count did not match');
         System.assertEquals(1, objViewWorkbook.UploadedFileList.size(), 'UploadedFileList count did not match');

         //Change file upload step status to in-progress
         objViewWorkbook.serverSetStepInProgress();
         System.assertEquals(AH_UDC_Constants.STEP_STATUS_IN_PROGRESS, objViewWorkbook.currentStep.status, 'Current step status should be ' + AH_UDC_Constants.STEP_STATUS_IN_PROGRESS);

         String strQuery = 'SELECT Id, StepStatus__c FROM AH_UDC_WorkbookStep__c WHERE Id = \'' + objViewWorkbook.currentStep.id + '\'';
         AH_UDC_LogHelper.Debug('strQuery: ' + strQuery);
         List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = (List<AH_UDC_WorkbookStep__c>) AH_UDC_SystemContext.query(strQuery);
         AH_UDC_LogHelper.Debug('lstWorkbookSteps: ' + lstWorkbookSteps);
         System.assert(lstWorkbookSteps.size() > 0, 'Current step record not found');
         System.assertEquals(AH_UDC_Constants.STEP_STATUS_IN_PROGRESS, lstWorkbookSteps[0].StepStatus__c, 'Workbook step status should be ' + AH_UDC_Constants.STEP_STATUS_IN_PROGRESS);

         objViewWorkbook.DeleteFileID = null;
         objViewWorkbook.serverDeleteFile(); //Try to delete file without id
         System.assert(String.isNotBlank(objViewWorkbook.NotificationToShow), 'NotificationToShow should be a message to display as trying to delete file without id');

         objViewWorkbook.isPageLoadErrorMessage = false;
         objViewWorkbook.DeleteFileID = objViewWorkbook.UploadedFileList[0].ContentDocumentId;
         objViewWorkbook.serverDeleteFile();
         System.assertEquals(0, objViewWorkbook.UploadedFileList.size(), 'After Delete : File still exists for Test FileUpload NI Doc');
         Test.stopTest();
      }
   }

   static void TestViewWorkbook(Id WorkbookId, Boolean IsPropertyConfirmed, Id FeedItemId, Boolean IsCommunityPortal) {
      PageReference pageRef = Page.AH_UDC_ViewWorkbook;
      pageRef.getParameters().put('Id', WorkbookId); //Pass Workbook Id as a parameter
      pageRef.getParameters().put('community', String.valueOf(IsCommunityPortal));
      Test.setCurrentPageReference(pageRef);

      AH_UDC_ViewWorkbook objViewWorkbook = new AH_UDC_ViewWorkbook();
      System.assert(objViewWorkbook.isPageLoadErrorMessage != true, 'Workbook is not assigned to the user or error occurred view workbook constructor. Username - ' + UserInfo.getUserName());
      System.assertEquals(WorkbookId, objViewWorkbook.workbook.id, 'Workbook Id did not match');
      System.assert(objViewWorkbook.workbook.isCompleted != true, 'isCompleted should not be true because workbook status is In Progress');
      System.assert(objViewWorkbook.workbook.allStepsComplete != true, 'allStepsComplete should not be true because all steps are not completed');
      System.assertEquals(5, objViewWorkbook.workbook.steps.size(), 'Workbook step count did not match');
      if (IsCommunityPortal)
         System.assert(objViewWorkbook.workbook.steps[0].isLocked, 'First step should be locked as per data setup');
      else
         System.assert(!objViewWorkbook.workbook.steps[0].isLocked, 'First step should be locked as per data setup');
      System.assertEquals(2, objViewWorkbook.workbook.steps[3].prerequisiteStepPosition, '4th Step should have 2nd step as a prerequisite step');
      System.assertEquals(3, objViewWorkbook.workbook.steps[4].prerequisiteStepPosition, '5th Step should have 3rd step as a prerequisite step');
      System.assertEquals(1, objViewWorkbook.workbook.completedSteps, '1st locked step should be calculated as completed');
      System.assert(objViewWorkbook.LastUpdatedByHelpText.indexOf(UserInfo.getLocale()) > -1, 'User locale did not match in help text');
      System.assert(objViewWorkbook.LastUpdatedByHelpText.indexOf(String.valueOf(UserInfo.getTimeZone())) > -1, 'User timezone did not match in help text');
      if (IsPropertyConfirmed) {
         System.assert(objViewWorkbook.workbook.propertyInfo.isPropertyConfirmed, 'isPropertyConfirmed should be true because property is already confirmed');
      }
      else {
         System.assert(objViewWorkbook.workbook.propertyInfo.isPropertyConfirmed != true, 'isPropertyConfirmed should not be true as property is not confirmed yet');
         objViewWorkbook.serverConfirmProperty();
         String strQuery = 'SELECT RelatedTo__r.AH_UDC_PropertyConfirmation__c, RelatedTo__r.AH_UDC_PropertyConfirmationAccepted_Date__c FROM AH_UDC_Workbook__c WHERE Id = \'' + WorkbookId + '\'';
         List<AH_UDC_Workbook__c> lstWorkbook = (List<AH_UDC_Workbook__c>) AH_UDC_SystemContext.query(strQuery);

         System.assert(lstWorkbook.size() > 0, 'Workbook sent record not found');
         System.assert(lstWorkbook[0].RelatedTo__r.AH_UDC_PropertyConfirmation__c, 'AH_UDC_PropertyConfirmation__c should be true after confirming property');
         System.assert(lstWorkbook[0].RelatedTo__r.AH_UDC_PropertyConfirmationAccepted_Date__c != null, 'AH_UDC_PropertyConfirmationAccepted_Date__c should not be null after confirming property');
      }

      objViewWorkbook.collapsedMenuMoveDirection = 1;
      objViewWorkbook.serverCollapsedMenuMove();
      System.assert(objViewWorkbook.ShowCollapsedMenuUpNavigation == false, 'ShowCollapsedMenuUpNavigation should be false');

      objViewWorkbook.serverChangeToNextStepNotCompleted();
      System.assertEquals(2, objViewWorkbook.currentPosition, '1st step is locked so it should open 2nd second step by default');
      System.assertEquals(1, objViewWorkbook.currentStep.lastUpdatedByUsersList.size(), 'Step response has already been submitted so last updated by users list should have 1 element');

      AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c(Id = objViewWorkbook.workbook.steps[0].id);
      objWorkbookStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_IN_PROGRESS;
      AH_UDC_SystemContext.UpdateObject(objWorkbookStep); //Unlock first step before marking it complete

      //Complete all steps before completing workbook
      for (Integer i = 1; i <= 5; i++) {
         objViewWorkbook.changeToPositionNumber = i;
         objViewWorkbook.serverChangeToStep();
         System.assertEquals(objViewWorkbook.changeToPositionNumber, objViewWorkbook.currentPosition, 'currentPosition should be ' + i);

         //The steps can not be marked complete unless there are responses.
         objViewWorkbook.serverMarkStepComplete();
         String strQuery = 'SELECT StepStatus__c, StepCompletedBy__c, StepCompleted__c FROM AH_UDC_WorkbookStep__c WHERE Id = \'' + objViewWorkbook.workbook.steps[i - 1].id + '\'';
         List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = (List<AH_UDC_WorkbookStep__c>) AH_UDC_SystemContext.query(strQuery);

         System.assert(lstWorkbookSteps.size() > 0, 'Step record not found at position ' + i);
         System.assertEquals(AH_UDC_Constants.STEP_STATUS_COMPLETED, lstWorkbookSteps[0].StepStatus__c, 'Step status should be ' + AH_UDC_Constants.STEP_STATUS_COMPLETED + ' for the Step ' + i);
         System.assertEquals(UserInfo.getUserId(), lstWorkbookSteps[0].StepCompletedBy__c, 'Step completed by did not match with the current user for the Step ' + i);
         System.assert(lstWorkbookSteps[0].StepCompleted__c != null, 'Step completed by date should not be null for the Step ' + i);
      }

      if (String.isNotBlank(String.valueOf(FeedItemId))) { //If feed item id is provided then check logic for chatter notification
         List<User> lstUsers = [SELECT Id FROM User WHERE UserName = :'TestChatterUser2@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX];
         System.assert(lstUsers.size() > 0, 'Chatter user 2 record not found');

         System.runAs(lstUsers[0]) {
            objViewWorkbook.CheckChatterFeedNotification();
            System.assert(objViewWorkbook.chatterUpdate != true, 'chatterUpdate should not be true because no new comments added on the message');

            FeedComment objFeedComment = new FeedComment();
            objFeedComment.FeedItemId = FeedItemId;
            objFeedComment.CommentType = 'TextComment';
            objFeedComment.IsRichText = false;
            objFeedComment.CommentBody = 'Test Comment 2';
            AH_UDC_SystemContext.CreateObject(objFeedComment); //Add comment on chatter user 1's message by chatter user 2
         }
      }

      objViewWorkbook.serverUpdateTimer(); //Refresh workbook data
      //System.assert(objViewWorkbook.workbook.isCompleted, 'isCompleted should be true as workbook status is Completed/Locked');
      System.assertEquals(5,objViewWorkbook.workbook.steps.size(), 'Step Count should be 5');
      for(AH_UDC_CommunityWorkbook.WorkbookStep wbs : objViewWorkbook.workbook.steps)
      {
         System.assert(wbs.status == 'Completed' || wbs.status == 'Locked', 'Expected Step to be completed: ' + wbs.name + ';status: ' + wbs.status);
      }
      System.assert(objViewWorkbook.workbook.allStepsComplete, 'allStepsComplete should be true as all steps are completed');
      if (String.isNotBlank(String.valueOf(FeedItemId))) {
         System.assert(objViewWorkbook.chatterUpdate, 'chatterUpdate should be true because chatter user 2 commented on a message created by chatter user 1');
      }

      //Complete the workbook 
      objViewWorkbook.serverSubmit();
      String strQuery = 'SELECT SentStatus__c, CompletedBy__c, CompletedDate__c FROM AH_UDC_Workbook__c WHERE Id = \'' + WorkbookId + '\'';
      List<AH_UDC_Workbook__c> lstWorkbook = (List<AH_UDC_Workbook__c>) AH_UDC_SystemContext.query(strQuery);

      System.assert(lstWorkbook.size() > 0, 'Workbook sent record not found');
      System.assertEquals(AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED, lstWorkbook[0].SentStatus__c, 'Workbook sent status should be ' + AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED);
      System.assertEquals(UserInfo.getUserId(), lstWorkbook[0].CompletedBy__c, 'Workbook completed by did not match with the current user');
      System.assert(lstWorkbook[0].CompletedDate__c != null, 'Workbook completed by date should not be null');
   }

   @isTest static void TestExceptionHandling() {
      String strUserName = 'TestChatterUser2@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX;
      List<User> lstCommunityUsers = [SELECT ContactId FROM User
                                      WHERE Username = :strUserName
                                      AND IsActive = true];
      System.assert(lstCommunityUsers.size() > 0, 'TestExceptionHandling - Chatter 2 user not found');

      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id, RelatedTo__c FROM AH_UDC_Workbook__c
                                               WHERE Name = 'Test Exception Workbook'
                                               AND Enabled__c = true
                                               AND RecordTypeId = :workbookSentRecordTypeId];
      System.assert(lstworkbooks.size() > 0, 'Workbook sent records not found with the name - Test Exception Workbook');

      System.runAs(lstCommunityUsers[0]) {
         Test.startTest();
         PageReference pageRef = Page.AH_UDC_ViewWorkbook;
         pageRef.getParameters().put('Id', lstWorkbooks[0].Id); //Pass Workbook Id which is not assigned to the user
         Test.setCurrentPageReference(pageRef);

         AH_UDC_ViewWorkbook objViewWorkbook = new AH_UDC_ViewWorkbook();
         System.assert(objViewWorkbook.HasPageLoadLogMessages, 'HasPageLoadLogMessages should be true as error generated in the constructor');
         
         objViewWorkbook.LogFunctionalArea = 'TestException';
         objViewWorkbook.serverLogMessages();
         System.assert(objViewWorkbook.HasPageLoadLogMessages != true, 'HasPageLoadLogMessages should be false now as we have inserted all pending logs');

         try {
            //This method is throwing an exception from catch block so need to handle it in try catch
            objViewWorkbook.GetAddress(new AH_UDC_PropertyAccount__c());
         }
         catch(Exception ex) {
            System.assert(ex.getMessage().indexOf('Divide by 0') > - 1, 'Different error occurred in the method GetAddress. Error: ' + ex.getMessage() + ' at line number ' + ex.getLineNumber());
         }

         objViewWorkbook.isPageLoadErrorMessage = false;
         objViewWorkbook.NotificationToShow = '';
         objViewWorkbook.serverConfirmProperty();
         System.assert(String.isNotBlank(objViewWorkbook.NotificationToShow), 'NotificationToShow should be a message to display because workbook Id will be null so it would not retrieve workbook information');

         objViewWorkbook.isPageLoadErrorMessage = false;
         objViewWorkbook.NotificationToShow = '';
         objViewWorkbook.serverChangeToNextStepNotCompleted();
         System.assert(String.isNotBlank(objViewWorkbook.NotificationToShow), 'NotificationToShow should be a message to display as it will generate exception for LogFunctionalArea TestException');

         objViewWorkbook.isPageLoadErrorMessage = false;
         objViewWorkbook.NotificationToShow = '';
         objViewWorkbook.serverSetStepInProgress();
         System.assert(String.isNotBlank(objViewWorkbook.NotificationToShow), 'NotificationToShow should be a message to display as it will generate exception for LogFunctionalArea TestException');

         objViewWorkbook.serverMarkStepComplete();
         System.assertEquals(Label.AH_UDC_Common_Error_Message, objViewWorkbook.NotificationToShow, 'ServerMarkStepComplete - Notification message did not match');

         objViewWorkbook.isPageLoadErrorMessage = false;
         objViewWorkbook.NotificationToShow = '';
         objViewWorkbook.serverSubmit();
         System.assert(String.isNotBlank(objViewWorkbook.NotificationToShow), 'NotificationToShow should be a message to display as it will generate exception for LogFunctionalArea TestException');

         objViewWorkbook.isPageLoadErrorMessage = false;
         objViewWorkbook.NotificationToShow = '';
         objViewWorkbook.serverUpdateTimer();
         System.assert(String.isNotBlank(objViewWorkbook.NotificationToShow), 'NotificationToShow should be a message to display as it will generate exception for LogFunctionalArea TestException');
         System.assertEquals('There was an issue refreshing steps; you may not see workbook updates from other users.', objViewWorkbook.NotificationToShow, 'Notification error not as expected');

         objViewWorkbook.isPageLoadErrorMessage = false;
         objViewWorkbook.NotificationToShow = '';
         objViewWorkbook.CheckChatterFeedNotification();
         System.assert(String.isNotBlank(objViewWorkbook.NotificationToShow), 'NotificationToShow should be a message to display as it will generate exception for LogFunctionalArea TestException');

         try {
            //This method is throwing an exception from catch block so need to handle it in try catch
            objViewWorkbook.serverLogClientException();
         }
         catch(Exception ex) {
            System.assert(ex.getMessage().indexOf('Divide by 0') > - 1, 'Different error occurred in the method GetAddress. Error: ' + ex.getMessage() + ' at line number ' + ex.getLineNumber());
         }
         objViewWorkbook.isPageLoadErrorMessage = false;
         objViewWorkbook.NotificationToShow = '';
         objViewWorkbook.serverGetFiles();
         System.assert(String.isNotBlank(objViewWorkbook.NotificationToShow), 'NotificationToShow should be a message to display as it will generate exception for LogFunctionalArea TestException');

         objViewWorkbook.isPageLoadErrorMessage = false;
         objViewWorkbook.NotificationToShow = '';
         objViewWorkbook.serverDeleteFile();
         System.assert(String.isNotBlank(objViewWorkbook.NotificationToShow), 'NotificationToShow should be a message to display as it will generate exception for LogFunctionalArea TestException');

         objViewWorkbook.isPageLoadErrorMessage = false;
         objViewWorkbook.NotificationToShow = '';
         objViewWorkbook.DeleteFileID = 'WrongDeleteId';
         objViewWorkbook.serverDeleteFile();
         System.assert(String.isNotBlank(objViewWorkbook.NotificationToShow), 'NotificationToShow should be a message to display as it will generate exception because of wrong NIDoc and attached file name');

         Test.stopTest();
      }
   }
}