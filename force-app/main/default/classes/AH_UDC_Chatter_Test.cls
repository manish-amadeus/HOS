/***********************************************************************************************
  Name            : AH_UDC_Chatter
  Author          : Sanjay Parmar
  Created Date    : 2-Apr-2021
  Last Mod Date   : 2-Apr-2021
  Last Mod By     : Sanjay Parmar
  NICC Reference  : 
  Description     : Test class for AH_UDC_Chatter
 ************************************************************************************************/
@isTest
private class AH_UDC_Chatter_Test {

   private static final String TEST_NI_DOC_NAME = 'Test NI Document 1';
   private static final String TEST_USER_NAME = 'test@user.com';

   @TestSetup
   private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      // Create Account record
      Account oAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account for Test class', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
      insert oAccount;

      // Create Contact record
      Contact oContact = AH_UDC_TestData.GetContactObject(oAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert oContact;

      // Create Contact record
      Contact oContact2 = AH_UDC_TestData.GetContactObject(oAccount.Id, 'Test2', 'Contact2', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert oContact2;

      // Get ProfileId to create User WITH chatter
      Profile oProfile = [SELECT Id FROM profile WHERE name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER,
                                                                                             AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER)];
      System.assert(oProfile != null && oProfile.Id != null, 'Profile (' + AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER + ') record not found');

      // Create User record
      User oUser = AH_UDC_TestData.GetUserObject(oContact.Id, oProfile.Id, 'Test', 'User', 'Mr.', 'test@user.com', TEST_USER_NAME + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
      insert oUser;

      // Get ProfileId to create User WITH chatter
      Profile oProfile2 = [SELECT Id FROM profile WHERE name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER,
                                                                                              AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER)];
      System.assert(oProfile2 != null && oProfile2.Id != null, 'Profile (' + AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER + ') record not found');

      // Create User record
      User oUser2 = AH_UDC_TestData.GetUserObject(oContact2.Id, oProfile2.Id, 'Test2', 'User2', 'Mrs.', 'test2@user.com', '2' + TEST_USER_NAME + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
      insert oUser2;

      // Create Property Account object with blank property name to get more code coverage
      AH_UDC_PropertyAccount__c oPropertyAccount = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
      insert oPropertyAccount;

      // Create NI Doc record
      NI_Documentation__c oNiDoc = AH_UDC_TestData.GetNIDocObject(TEST_NI_DOC_NAME, Date.newInstance(2021, 3, 31));
      oNiDoc.AH_UDC_PropertyAccount__c = oPropertyAccount.Id;
      insert oNiDoc;

      // Create Contact NI Doc mapping record
      AH_UDC_Contact__c oUdcContact = AH_UDC_TestData.GetUDCContactObject(oNiDoc.Id, oContact.Id, UserInfo.getDefaultCurrency());
      insert oUdcContact;
      oUdcContact = AH_UDC_TestData.GetUDCContactObject(oNiDoc.Id, oContact2.Id, UserInfo.getDefaultCurrency());
      insert oUdcContact;

      // Create Workbook Record
      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      AH_UDC_Workbook__c oWorkbook = AH_UDC_TestData.GetWorkbookObject(oNiDoc.Id, 'Test Workbook 1',
                                                                       'Test Workbook 1 Description', product);
      insert oWorkbook;
   }

   @isTest
   private static void testUserWithChatter() {
      Boolean isException = false;
      String errorMessage = '';
      String userNamePostfix = AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX);

      List<NI_Documentation__c> lstNiDoc = [SELECT Id FROM NI_Documentation__c WHERE Document_Name__c = :TEST_NI_DOC_NAME];
      System.assert(lstNiDoc.size() > 0, 'Could not find an NI Document with a name of: ' + TEST_NI_DOC_NAME);

      List<User> lstUser = [SELECT Id
                            FROM User
                            WHERE UserName = :(TEST_USER_NAME + userNamePostfix)];
      System.assert(lstUser.size() > 0, 'User records could not be found.');

      List<PermissionSet> lstPermissionSets = new List<PermissionSet> ([SELECT Id FROM PermissionSet WHERE Name = 'AH_UDC_CommunityUser']);
      System.assertEquals(true, lstPermissionSets != null && lstPermissionSets.size() > 0, 'Could not get Permission Set Id of AH_UDC_CommunityUser');

      PermissionSetAssignment objPermissionSetAssignment = null;
      //Assign UDC Community Portal permission set to the user
      objPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = lstPermissionSets[0].Id, AssigneeId = lstUser[0].Id);
      insert objPermissionSetAssignment;
      System.assertEquals(false, isException, 'Could not assign AH_UDC_CommunityUser permission set to the user : ' + errorMessage);
      Id ItemId = null;
      System.runAs(lstUser[0]) {

         FeedItem oFeedItem = null;
         try {
            oFeedItem = new FeedItem();
            oFeedItem.ParentId = lstNIDoc[0].Id;
            oFeedItem.Type = 'TextPost';
            oFeedItem.IsRichText = false;
            oFeedItem.Body = 'Test Message 1';
            insert oFeedItem;
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
            insert oFeedComment;
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

         objChatter.UpdateChatterAccessDetails(); // Action method

         objChatter.IsShowAllQuestions = true;
         objChatter.GetFeedDetails();
         System.debug('GetFeedDetails() error messages: ' + ApexPages.getMessages());
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in GetFeedDetails execution: IsErrorOccurred is true');
         System.assert(objChatter.FeedList != null, 'Error occurred in GetFeedDetails execution: FeedList was null');
         System.assert(objChatter.FeedList.size() > 0, 'Error occurred in GetFeedDetails execution: Feedlist was empty');

         objChatter.PostFeedMessage();
         List<FeedItem> oFeedItemPost = [SELECT Body FROM FeedItem where Id = :oFeedItem.Id];
         System.assert(oFeedItemPost[0].Body != 'Test Message 2', 'Error occurred in PostFeedMessage execution');

         objChatter.PostFeedComment();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in UpdateFeedComment execution');

         objChatter.UpdateFeedMessage();
         List<FeedItem> oFeedItemUpdateFeed = [SELECT Body FROM FeedItem where Id = :oFeedItem.Id];
         System.assert(oFeedItemUpdateFeed[0].Body == 'Test Message 2', 'Error occurred in UpdateFeedMessage execution');

         objChatter.UpdateFeedComment();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in UpdateFeedComment execution');

         objChatter.IsChatterEnableError = true;
         objChatter.AgreeToUseChatter();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in AgreeToUseChatter execution');

      }
      List<FeedComment> oFeedCommentPostFeed = [SELECT FeedItemId, ParentId, CommentBody FROM FeedComment where FeedItemId = :ItemId AND ParentId = :lstNIDoc[0].Id];
      System.assert(oFeedCommentPostFeed[0].CommentBody == 'Test Comment 1', 'Error occurred in UpdateFeedComment execution');

      List<FeedComment> oFeedCommentUpdateFeed = [SELECT CommentBody FROM FeedComment where FeedItemId = :ItemId AND ParentId = :lstNIDoc[0].Id];
      System.assert(oFeedCommentUpdateFeed[0].CommentBody == 'Test Comment 1', 'Error occurred in UpdateFeedComment execution');
      Test.stopTest();
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

      List<User> lstUser = [SELECT Id FROM User WHERE UserName = :TEST_USER_NAME + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];

      System.runAs(lstUser[0]) {
         try {
            oFeedItem = new FeedItem();
            oFeedItem.ParentId = oNIDoc[0].Id;
            oFeedItem.Type = 'TextPost';
            oFeedItem.IsRichText = false;
            oFeedItem.Body = 'Test Message 1';
            insert oFeedItem;
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
            insert oFeedComment;
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
      NI_Documentation__c oNiDoc = [SELECT Id FROM NI_Documentation__c WHERE Document_Name__c = :TEST_NI_DOC_NAME];

      List<User> lstUserWithoutChatter = [SELECT Id, ProfileId FROM User WHERE UserName = :('2' + TEST_USER_NAME + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX))];
      Id ItemId = null;

      System.runAs(lstUserWithoutChatter[0]) {

         FeedItem oFeedItem = null;
         try {
            oFeedItem = new FeedItem();
            oFeedItem.ParentId = oNiDoc.Id;
            oFeedItem.Type = 'TextPost';
            oFeedItem.IsRichText = false;
            oFeedItem.Body = 'Test Message 1';
            insert oFeedItem;
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
            insert oFeedComment;
         }
         catch(Exception ex) {
            System.assert(false, 'Error occurred in creating feed comment record - ' + ex.getMessage());
         }

         PageReference pageRef = Page.AH_UDC_Chatter;
         pageRef.getParameters().put('Id', oNiDoc.Id); //Pass NI Doc Id as a parameter
         pageRef.getParameters().put('message', 'Test Message 2'); //Pass message text as a parameter
         pageRef.getParameters().put('feedItemId', oFeedItem.Id); //Pass feed item id as a parameter
         pageRef.getParameters().put('feedCommentId', oFeedComment.Id); //Pass feed comment id as a parameter
         pageRef.getParameters().put('comment', 'Test Comment 1'); //Pass comment text Id as a parameter
         Test.setCurrentPageReference(pageRef);

         Test.startTest();
         AH_UDC_Chatter objChatter = new AH_UDC_Chatter();
         System.assert(!objChatter.IsErrorOccurred, 'Error occurred in Chatter Page execution');

         objChatter.IsShowAllQuestions = true;
         objChatter.GetFeedDetails();
         System.assert(objChatter.FeedList != null && objChatter.FeedList.size() > 0, 'Error occurred in GetFeedDetails execution');

         objChatter.PostFeedMessage();
         List<FeedItem> oFeedItemPost = [SELECT Body FROM FeedItem where Id = :oFeedItem.Id];
         System.assert(oFeedItemPost[0].Body != 'Test Message 2', 'Error occurred in PostFeedMessage execution');

         objChatter.PostFeedComment();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in PostFeedComment execution');

         objChatter.UpdateFeedMessage();
         List<FeedItem> oFeedItemUpdateFeed = [SELECT Body FROM FeedItem where Id = :oFeedItem.Id];
         System.assert(oFeedItemUpdateFeed[0].Body == 'Test Message 2', 'Error occurred in UpdateFeedMessage execution');

         objChatter.UpdateFeedComment();
         System.assert(objChatter.IsErrorOccurred != true, 'Error occurred in UpdateFeedComment execution');

         System.debug('objChatter.IsChatterEnableError =>' + objChatter.IsChatterEnableError);
         objChatter.IsChatterEnableError = false;
         objChatter.AgreeToUseChatter();
         List<User> lstUserProfile = [SELECT Id, ProfileId FROM User WHERE UserName = :('2' + TEST_USER_NAME + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX))];
         System.assert(lstUserWithoutChatter[0].ProfileId == lstUserProfile[0].ProfileId, 'Error occurred in AgreeToUseChatter execution');
      }
      List<FeedComment> oFeedCommentPostFeed = [SELECT FeedItemId, ParentId, CommentBody FROM FeedComment where FeedItemId = :ItemId];
      System.assert(oFeedCommentPostFeed[0].CommentBody == 'Test Comment 1', 'Error occurred in UpdateFeedComment execution');

      List<FeedComment> oFeedCommentUpdateFeed = [SELECT CommentBody FROM FeedComment where FeedItemId = :ItemId];
      System.assert(oFeedCommentUpdateFeed[0].CommentBody == 'Test Comment 1', 'Error occurred in UpdateFeedComment execution');
      Test.stopTest();
   }
}