/***********************************************************************************************
  Name            : AH_UDC_Chatter_TEST
  Author          : Sanjay Parmar
  Created Date    : 2-Apr-2021
  Last Mod Date   : 2-Apr-2021
  Last Mod By     : Sanjay Parmar
  Description     : Test class for AH_UDC_Chatter
 ************************************************************************************************/
@isTest
private class AH_UDC_Chatter_TEST {

   private static final String TEST_CONTACT_FIRSTNAME = 'AH_UDC_Test';
   private static final String TEST_NI_DOC_NAME = 'Test NI Document 1';
   private static final String TEST_USER_NAME = 'test@user.com';

   @TestSetup
   private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      // Create Account record
      Account oAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert oAccount;

      // Create Contact record
      Contact oContact001 = AH_UDC_TestData.GetContactObject(oAccount.Id, TEST_CONTACT_FIRSTNAME + '001', 'AH_UDC_Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert oContact001;

      // Create Contact record
      Contact oContact002 = AH_UDC_TestData.GetContactObject(oAccount.Id, TEST_CONTACT_FIRSTNAME + '002', 'AH_UDC_Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert oContact002;

      // Create Contact record
      Contact oContact003 = AH_UDC_TestData.GetContactObject(oAccount.Id, TEST_CONTACT_FIRSTNAME + '003', 'AH_UDC_Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert oContact003;

      List<User> listUsers = new List<User> ();

      //Insert Community User with Chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER),
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              'ChatterCommunity001', oContact001.Id, true));
      //Insert Community User with Chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER),
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              'ChatterCommunity003', oContact003.Id, true));
      //Insert Community User without Chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER),
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              'ChatterCommunity002', oContact002.Id, true));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[2].Id);
      }

      // Create Property Account object with blank property name to get more code coverage
      AH_UDC_PropertyAccount__c oPropertyAccount = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      insert oPropertyAccount;

      // Create NI Doc record
      NI_Documentation__c oNiDoc = AH_UDC_TestData.GetNIDocObject(TEST_NI_DOC_NAME, Date.newInstance(2021, 3, 31));
      oNiDoc.AH_UDC_PropertyAccount__c = oPropertyAccount.Id;
      insert oNiDoc;

      // Create Contact NI Doc mapping record
      AH_UDC_Contact__c oUdcContact = AH_UDC_TestData.GetUDCContactObject(oNiDoc.Id, oContact001.Id, UserInfo.getDefaultCurrency());
      insert oUdcContact;
      oUdcContact = AH_UDC_TestData.GetUDCContactObject(oNiDoc.Id, oContact002.Id, UserInfo.getDefaultCurrency());
      insert oUdcContact;

      // Create Workbook Record
      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      AH_UDC_Workbook__c oWorkbook = AH_UDC_TestData.GetWorkbookObject(oNiDoc.Id, 'Test Workbook 1',
                                                                       'Test Workbook 1 Description', product);
      insert oWorkbook;
   }

   /**
   * @description 
   */ 
   @isTest
   private static void testUserWithChatter() {
      Boolean isException = false;
      String errorMessage = '';
      Id ItemId = null;

      List<NI_Documentation__c> lstNiDoc = [SELECT Id FROM NI_Documentation__c WHERE Document_Name__c = :TEST_NI_DOC_NAME];
      System.assert(lstNiDoc.size() > 0, 'Could not find an NI Document with a name of: ' + TEST_NI_DOC_NAME);

      User uWITH = [SELECT Id FROM User where Email like 'TestChatterCommunity001%'];
      System.runAs(uWITH) {
         FeedItem oFeedItem = null;
         try {
            oFeedItem = new FeedItem();
            oFeedItem.ParentId = lstNIDoc[0].Id;
            oFeedItem.Type = 'TextPost';
            oFeedItem.IsRichText = false;
            oFeedItem.Body = 'Test Message 1';
            AH_UDC_SystemContext.CreateObject(oFeedItem);
         }
         catch(Exception ex) {
            System.assert(false, 'Error occurred in creating feed item record - ' + ex.getMessage());
         }
         ItemId = oFeedItem.Id;
         FeedComment oFeedComment = null;
         try {
            oFeedComment = new FeedComment();
            oFeedComment.FeedItemId = oFeedItem.Id;
            oFeedComment.CommentType = 'TextComment';
            oFeedComment.IsRichText = false;
            oFeedComment.CommentBody = 'Test Comment 1';
            AH_UDC_SystemContext.CreateObject(oFeedComment);
         }
         catch(Exception ex) {
            System.assert(false, 'Error occurred in creating feed comment record - ' + ex.getMessage());
         }

         PageReference pageRef = Page.AH_UDC_Chatter;
         pageRef.getParameters().put('Id', lstNIDoc[0].Id); //Pass NI Doc Id as a parameter
         pageRef.getParameters().put('message', 'Test Message 2'); //Pass message text as a parameter
         pageRef.getParameters().put('feedItemId', oFeedItem.Id); //Pass feed item id as a parameter
         pageRef.getParameters().put('feedCommentId', oFeedComment.Id); //Pass feed comment id as a parameter         
         pageRef.getParameters().put('comment', 'Test Comment 1'); //Pass comment text Id as a parameter
         Test.setCurrentPageReference(pageRef);

         Test.startTest();

         AH_UDC_Chatter objChatter = new AH_UDC_Chatter();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in Chatter Page execution');

         if (ApexPages.getMessages().size() > 0) {
            System.assert(false, 'Error(s) occurred initializing the Chatter page: ' + ApexPages.getMessages());
         }

         objChatter.serverUpdateChatterLastViewed(); // Action method

         objChatter.IsShowAllQuestions = true;
         objChatter.GetFeedDetails();
         System.debug('GetFeedDetails() error messages: ' + ApexPages.getMessages());
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in GetFeedDetails execution: IsErrorOccurred is true');
         System.assert(objChatter.FeedList != null, 'Error occurred in GetFeedDetails execution: FeedList was null');
         System.assert(objChatter.FeedList.size() > 0, 'Error occurred in GetFeedDetails execution: Feedlist was empty');

         objChatter.PostFeedMessage();
         List<FeedItem> oFeedItemPost = AH_UDC_SystemContext.query('SELECT Body FROM FeedItem where Id = \'' + oFeedItem.Id + '\'');
         System.assert(oFeedItemPost[0].Body != 'Test Message 2', 'Error occurred in PostFeedMessage execution');

         objChatter.PostFeedComment();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in UpdateFeedComment execution');

         objChatter.UpdateFeedMessage();
         List<FeedItem> oFeedItemUpdateFeed = AH_UDC_SystemContext.query('SELECT Body FROM FeedItem where Id = \'' + oFeedItem.Id + '\'');
         System.assert(oFeedItemUpdateFeed[0].Body == '<p>Test Message 2</p>', 'Error occurred in UpdateFeedMessage execution');

         objChatter.UpdateFeedComment();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in UpdateFeedComment execution');

         // Since test code cannot make a real callout, the only way to test that the AgreeToUserChatter() can be tested is
         // to look for Log messages containing errors. We cannot query the User record to see if the Profile is changes
         Integer expectedLogCount = 1;
         List<AH_UDC_Log__c> logs = AH_UDC_LogHelper.GetTestMethodLogs(AH_UDC_LogHelper.getClassAndMethodName(new DmlException()));
         for (Integer index = 0; index<logs.size(); index++) {
            switch on index {
               when 0 { System.assert(logs[index].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not find the expected Log Message.'); }
               when else { System.assert(false, 'Missing an ASSERT that should check the validity of the Log message at index ' + index + ': ' + logs[index].LogText__c); }
            }
         }
         System.assertEquals(expectedLogCount, logs.size(), 'Found ' + (logs.size()> expectedLogCount ? 'more' : 'fewer') + ' Log messages than expected. Search the debug log for "Actual log" to see all Log messages');
      }
      
      List<FeedComment> oFeedCommentUpdateFeed = [SELECT CommentBody FROM FeedComment where FeedItemId = :ItemId AND ParentId = :lstNIDoc[0].Id];
      System.assert(oFeedCommentUpdateFeed[0].CommentBody == '<p>Test Comment 1</p>', 'Error occurred in UpdateFeedComment execution');
      Test.stopTest();
   }

   /**
   * @description Test that changing the USer's profile to allow Chatter was successful
   */ 
   @isTest
   private static void testAgreeToUseChatter_SUCCESS() {
      User uWITHOUT = [SELECT Id FROM User where Email like 'TestChatterCommunity002%'];
      List<NI_Documentation__c> lstNiDoc = [SELECT Id FROM NI_Documentation__c WHERE Document_Name__c = :TEST_NI_DOC_NAME];
      System.assert(lstNiDoc.size() > 0, 'Could not log an NI Document with a name of: ' + TEST_NI_DOC_NAME);

      System.runAs(uWITHOUT) {
         PageReference pageRef = Page.AH_UDC_Chatter;
         pageRef.getParameters().put('Id', lstNIDoc[0].Id); //Pass NI Doc Id as a parameter
         Test.setCurrentPageReference(pageRef);

         Test.startTest();

         AH_UDC_Chatter objChatter = new AH_UDC_Chatter();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in Chatter Page execution');

         if (ApexPages.getMessages().size() > 0) {
            System.assert(false, 'Error(s) occurred initializing the Chatter page: ' + ApexPages.getMessages());
         }

         AH_UDC_MockResponseGenerator mock;
         mock = new AH_UDC_MockResponseGenerator(AH_UDC_MockResponseGenerator.ResponseType.SetCommunityUserProfile, 200);
         Test.setMock(HttpCalloutMock.class, mock);
         
         objChatter.AgreeToUseChatter();
         System.assert(objChatter.IsErrorOccurred == false, 'Error should not have occurred in AgreeToUseChatter execution');

         //ApexPages.Message[] pageMessages = ApexPages.getMessages();
         //System.assertNotEquals(0, pageMessages.size(), 'There should not have been any Apex Messages');

         AH_UDC_LogHelper.writeQueuedLogs();

         Integer expectedLogCount = 1;
         List<AH_UDC_Log__c> logs = AH_UDC_LogHelper.GetTestMethodLogs(AH_UDC_LogHelper.getClassAndMethodName(new DmlException()));
         for (Integer index = 0; index<logs.size(); index++) {
            switch on index {
               when 0 { System.assert(logs[index].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not find the expected Log Message.'); }
               when else { System.assert(false, 'Missing an ASSERT that should check the validity of the Log message at index ' + index + ': ' + logs[index].LogText__c); }
            }
         }
         System.assertEquals(expectedLogCount, logs.size(), 'Found ' + (logs.size()> expectedLogCount ? 'more' : 'fewer') + ' Log messages than expected. Search the debug log for "Actual log" to see all Log messages');
      }

      Test.stopTest();
   }

   /**
   * @description  Test that changing the User's profile to allow Chatter was fails if the callout fails
   */ 
   @isTest
   private static void testAgreeToUseChatter_FAIL() {
      User uWITHOUT = [SELECT Id FROM User where Email like 'TestChatterCommunity002%'];
      List<NI_Documentation__c> lstNiDoc = [SELECT Id FROM NI_Documentation__c WHERE Document_Name__c = :TEST_NI_DOC_NAME];
      System.assert(lstNiDoc.size() > 0, 'Could not find an NI Document with a name of: ' + TEST_NI_DOC_NAME);

      System.runAs(uWITHOUT) {
         PageReference pageRef = Page.AH_UDC_Chatter;
         pageRef.getParameters().put('Id', lstNIDoc[0].Id); //Pass NI Doc Id as a parameter
         Test.setCurrentPageReference(pageRef);

         Test.startTest();

         AH_UDC_Chatter objChatter = new AH_UDC_Chatter();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in Chatter Page execution');

         if (ApexPages.getMessages().size() > 0) {
            System.assert(false, 'Error(s) occurred initializing the Chatter page: ' + ApexPages.getMessages());
         }
 
         AH_UDC_MockResponseGenerator mock;
         mock = new AH_UDC_MockResponseGenerator(AH_UDC_MockResponseGenerator.ResponseType.SetCommunityUserProfile, 500);
         Test.setMock(HttpCalloutMock.class, mock);

         AH_UDC_LogHelper.QueueLogs = true;
         objChatter.AgreeToUseChatter();
         System.assert(objChatter.IsErrorOccurred == true, 'Error should have occurred in AgreeToUseChatter execution');

         //ApexPages.Message[] pageMessages = ApexPages.getMessages();
         //System.assertNotEquals(1, pageMessages.size(), 'Apex Message should not be blank.');
         //System.assert(pageMessages[0].getSummary().contains(Label.AH_UDC_Common_Error_Message), 'Did not find the expected Error Message that will be displayed to the user: ' + pageMessages[0].getSummary());

         Integer expectedLogCount = 3;
         AH_UDC_LogHelper.writeQueuedLogs();

         List<AH_UDC_Log__c> logs = AH_UDC_LogHelper.GetTestMethodLogs(AH_UDC_LogHelper.getClassAndMethodName(new DmlException()));
         for (Integer index = 0; index<logs.size(); index++) {
            switch on index {
               when 0 { System.assert(logs[index].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not find the expected Log Message.'); }
               when 1 { System.assert(logs[index].LogText__c.contains('Unknown HTTP Status when calling endpoint: 500'), 'Did not find the expected Log Message on index ' + index); }
               when 2 { System.assert(logs[index].LogText__c.contains('Failed to update the profile of the User to allow chatter (user id: ' + uWITHOUT.Id), 'Did not find the expected Log Message on index '  + index); }
               when else { System.assert(false, 'Missing an ASSERT that should check the validity of the Log message at index ' + index + ': ' + logs[index].LogText__c); }
            }
         }
         System.assertEquals(expectedLogCount, logs.size(), 'Found ' + (logs.size()> expectedLogCount ? 'more' : 'fewer') + ' Log messages than expected. Search the debug log for "Actual log" to see all Log messages');
         Test.stopTest();
      }
   }

   @isTest
   private static void TestMissingNiDocId() {

      PageReference pageRef = Page.AH_UDC_Chatter; //Call chatter page without Id parameter to generate error      
      Test.setCurrentPageReference(pageRef);

      Test.startTest();
      AH_UDC_Chatter objChatter = new AH_UDC_Chatter();
      System.assert(objChatter.IsErrorOccurred, 'Expected an error to occur because Id for the NI Doc was not passed in');

      //Set name to generate error in LogException method
      objChatter.LogFunctionalArea = 'TestException';
      System.assert(objChatter.IsErrorOccurred, 'Error not occurred while executing page without id parameter');
      System.assert(objChatter.HasPageLoadLogMessages, 'No log entries found in queue list');

      objChatter.ServerLogMessages();
      System.assertEquals(false, objChatter.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');

      Test.stopTest();
   }


   @isTest
   private static void TestBadMissingIds() {
      FeedItem oFeedItem = null;
      FeedComment oFeedComment = null;

      List<NI_Documentation__c> oNiDoc = [SELECT Id FROM NI_Documentation__c WHERE Document_Name__c = :TEST_NI_DOC_NAME];
      System.assert(oNiDoc.size() > 0, 'Could not find an NI Document with a name of: ' + TEST_NI_DOC_NAME);

      PageReference pageRef = Page.AH_UDC_Chatter; //Call chatter page without Id parameter to generate error
      pageRef.getParameters().put('Id', '0000000000000000000'); //Pass bad NI Doc Id as a parameter
      pageRef.getParameters().put('message', 'Test Message 2');
      pageRef.getParameters().put('feedItemId', '');
      pageRef.getParameters().put('feedCommentId', '');
      pageRef.getParameters().put('comment', 'Test Comment 1');
      Test.setCurrentPageReference(pageRef);

      Test.startTest();
      AH_UDC_Chatter objChatter = new AH_UDC_Chatter();
      System.assert(objChatter.IsErrorOccurred, 'Expected an error to occur because User does not have access to the speicfied NI Doc: ' + ApexPages.getMessages());

      pageRef.getParameters().put('Id', oNiDoc[0].Id); //Pass bad NI Doc Id as a parameter
      objChatter = new AH_UDC_Chatter();
      System.assert(objChatter.IsErrorOccurred, 'Expected an error to occur because FeedItemId was not specified: ' + ApexPages.getMessages());

      User uWITH = [SELECT Id FROM User where Email like 'TestChatterCommunity003%'];
      System.runAs(uWITH) {
         try {
            oFeedItem = new FeedItem();
            oFeedItem.ParentId = oNIDoc[0].Id;
            oFeedItem.Type = 'TextPost';
            oFeedItem.IsRichText = false;
            oFeedItem.Body = 'Test Message 1';
            AH_UDC_SystemContext.CreateObject(oFeedItem);
         }
         catch(Exception ex) {
            System.assert(false, 'Error occurred in creating feed item record - ' + ex.getMessage());
         }

         try {
            oFeedComment = new FeedComment();
            oFeedComment.FeedItemId = oFeedItem.Id;
            oFeedComment.CommentType = 'TextComment';
            oFeedComment.IsRichText = false;
            oFeedComment.CommentBody = 'Test Comment 1';
            AH_UDC_SystemContext.CreateObject(oFeedComment);
         }
         catch(Exception ex) {
            System.assert(false, 'Error occurred in creating feed comment record - ' + ex.getMessage());
         }
         pageRef.getParameters().put('feedCommentId', null);
         objChatter = new AH_UDC_Chatter();

         objChatter.UpdateFeedMessage();
         System.assert(objChatter.IsErrorOccurred, 'Expected an error to occur because FeedItemtId was not specified: ' + ApexPages.getMessages());

         objChatter.UpdateFeedComment();
         System.assert(objChatter.IsErrorOccurred, 'Expected an error to occur because FeedCommentId was not specified: ' + ApexPages.getMessages());

      }
      Test.stopTest();
   }


   @isTest
   private static void testUserWithoutChatter() {
      Id ItemId = null;

      List<NI_Documentation__c> oNiDoc = [SELECT Id FROM NI_Documentation__c WHERE Document_Name__c = :TEST_NI_DOC_NAME];
      System.assert(oNiDoc.size() > 0, 'Could not find an NI Document with a name of: ' + TEST_NI_DOC_NAME);

      User uWITHOUT = [SELECT Id, ProfileId FROM User where Email like 'TestChatterCommunity002%'];
      System.runAs(uWITHOUT) {
         FeedItem oFeedItem = null;
         try {
            oFeedItem = new FeedItem();
            oFeedItem.ParentId = oNiDoc[0].Id;
            oFeedItem.Type = 'TextPost';
            oFeedItem.IsRichText = false;
            oFeedItem.Body = 'Test Message 1';
            AH_UDC_SystemContext.CreateObject(oFeedItem);
         }
         catch(Exception ex) {
            System.assert(false, 'Error occurred in creating feed item record - ' + ex.getMessage());
         }
         ItemId = oFeedItem.Id;

         FeedComment oFeedComment = null;
         try {
            oFeedComment = new FeedComment();
            oFeedComment.FeedItemId = oFeedItem.Id;
            oFeedComment.CommentType = 'TextComment';
            oFeedComment.IsRichText = false;
            oFeedComment.CommentBody = 'Test Comment 1';
            AH_UDC_SystemContext.CreateObject(oFeedComment);
         }
         catch(Exception ex) {
            System.assert(false, 'Error occurred in creating feed comment record - ' + ex.getMessage());
         }

         PageReference pageRef = Page.AH_UDC_Chatter;
         pageRef.getParameters().put('Id', oNiDoc[0].Id); //Pass NI Doc Id as a parameter
         pageRef.getParameters().put('message', 'Test Message 2'); //Pass message text as a parameter
         pageRef.getParameters().put('feedItemId', oFeedItem.Id); //Pass feed item id as a parameter
         pageRef.getParameters().put('feedCommentId', oFeedComment.Id); //Pass feed comment id as a parameter
         pageRef.getParameters().put('comment', 'Test Comment 1'); //Pass comment text Id as a parameter
         Test.setCurrentPageReference(pageRef);

         Test.startTest();

         //TODO: this test is not running as a specific user, it is running as whoever initiated the test.  This causes
         //      the code in AH_UDC_Chatter.UserHasAccessToNIDoc() to fail unless AH_UDC_Chatter class is defined
         //      as WITHOUT SHARING because the ContactId of the current user has 

         AH_UDC_Chatter objChatter = new AH_UDC_Chatter();
         System.assert(!objChatter.IsErrorOccurred, 'Error occurred in Chatter Page execution');

         objChatter.IsShowAllQuestions = true;
         objChatter.GetFeedDetails();
         System.assert(objChatter.FeedList != null && objChatter.FeedList.size() > 0, 'Error occurred in GetFeedDetails execution');

         objChatter.PostFeedMessage();
         List<FeedItem> oFeedItemPost = AH_UDC_SystemContext.query('SELECT Body FROM FeedItem where Id = \'' + oFeedItem.Id + '\'');
         System.assert(oFeedItemPost[0].Body != 'Test Message 2', 'Error occurred in PostFeedMessage execution');

         objChatter.PostFeedComment();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in PostFeedComment execution');

         objChatter.UpdateFeedMessage();
         List<FeedItem> oFeedItemUpdateFeed = AH_UDC_SystemContext.query('SELECT Body FROM FeedItem where Id = \'' + oFeedItem.Id + '\'');
         System.assert(oFeedItemUpdateFeed[0].Body == '<p>Test Message 2</p>', 'Error occurred in UpdateFeedMessage execution');

         objChatter.UpdateFeedComment();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in UpdateFeedComment execution');

         // Since test code cannot make a real callout, the only way to test that the AgreeToUserChatter() can be tested is
         // to look for Log messages containing errors. We cannot query the User record to see if the Profile is changes
         Integer expectedLogCount = 1;
         List<AH_UDC_Log__c> logs = AH_UDC_LogHelper.GetTestMethodLogs(AH_UDC_LogHelper.getClassAndMethodName(new DmlException()));
         for (Integer index = 0; index<logs.size(); index++) {
            switch on index {
               when 0 { System.assert(logs[index].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not find the expected Log Message.'); }
               when else { System.assert(false, 'Missing an ASSERT that should check the validity of the Log message at index ' + index + ': ' + logs[index].LogText__c); }
            }
         }
         System.assertEquals(expectedLogCount, logs.size(), 'Found ' + (logs.size()> expectedLogCount ? 'more' : 'fewer') + ' Log messages than expected. Search the debug log for "Actual log" to see all Log messages');
      }
      
      List<FeedComment> oFeedCommentUpdateFeed = AH_UDC_SystemContext.query('SELECT CommentBody FROM FeedComment where FeedItemId = \'' + ItemId + '\'');
      System.assert(oFeedCommentUpdateFeed[0].CommentBody == '<p>Test Comment 1</p>', 'Error occurred in UpdateFeedComment execution');
      Test.stopTest();
   }
}