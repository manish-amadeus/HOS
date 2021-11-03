/***********************************************************************************************
  Name            : AH_UDC_Chatter
  Author          : Sanjay Parmar
  Created Date    : 12-Mar-2021
  Last Mod Date   : 2-Apr-2021
  Last Mod By     : Sanjay Parmar
  NICC Reference  : 
  Description     : Apex class for Chatter page
 ************************************************************************************************/
public without sharing class AH_UDC_Chatter {
   public Boolean ChatterEnabled { get; set; } { ChatterEnabled = true; }
   public Boolean IsChatterEnableError { get; set; } { IsChatterEnableError = false; }
   public String IsChatterEnableErrorDetails { get; set; } { IsChatterEnableErrorDetails = ''; }
   public String NIDocumentName { get; set; } { NIDocumentName = ''; }

   public List<FeedWrapper> FeedList { get; set; }
   public String NIDocId { get; set; }
   public Boolean IsShowAllQuestions { get; set; }
   public Boolean IsErrorOccurred { get; set; }
   @TestVisible private string LogFunctionalArea = 'AH_UDC_Chatter'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages.size() > 0;
      }
   }

   //Wrapper class for Feed Messages
   public class FeedWrapper {
      public Id Id { get; set; }
      public String UserName { get; set; }
      public String BodyText { get; set; }
      public Boolean IsEditable { get; set; }
      public String SentBefore { get; set; }
      public List<FeedCommentWrapper> Comments { get; set; }
   }

   //Wrapper class for Feed Comments
   public class FeedCommentWrapper {
      public Id Id { get; set; }
      public String UserName { get; set; }
      public String BodyText { get; set; }
      public Boolean IsEditable { get; set; }
      public String SentBefore { get; set; }
   }

   public AH_UDC_Chatter() {
      IsErrorOccurred = false;

      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         //Proceed only for Chatter Enabled Users
         IsShowAllQuestions = false;

         // Need to sanitize the parameter to prevent injection attacks
         if (String.isBlank(apexpages.currentpage().getparameters().get('id'))) {
            LogException('Constructor', 'NI Document Id was not specified', null);
            return;
         }

         NIDocId = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('Id'));
         AH_UDC_LogHelper.Debug('###NIDocId: ' + NIDocId);

         if (!UserHasAccessToNIDoc()) {
            LogException('Constructor', 'User does not have access to the specified NI Document record', null);
            return;
         }

         //Detect if user has chatter profile
         User currentUser = [select Profile.name from user where Id = :UserInfo.getUserId()];
         String profileAllowedToChatter = AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER,
                                                                        AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER);
         AH_UDC_LogHelper.Debug('###profileAllowedToChatter: ' + profileAllowedToChatter);
         String userProfileName = String.valueOf(currentUser.getSObject('Profile').get('Name'));
         AH_UDC_LogHelper.Debug('###UserProfileName: ' + userProfileName);

         if (userProfileName != profileAllowedToChatter) {
            //No Chatter - this is not an error, the user will be show a section on the page allowing them to opt into chatter
            ChatterEnabled = false;
            return;
         }

         //If user has NI Doc record access then get messages and comments               
         AH_UDC_LogHelper.Debug('###GetFeedDetails:');
         NI_Documentation__c nidoc = [SELECT Id, Document_Name__c FROM NI_Documentation__c WHERE Id = :NIDocId];
         NIDocumentName = nidoc.Document_Name__c;

         //Get Feed for display
         GetFeedDetails();
      }
      catch(Exception ex) {
         LogException('Constructor', 'Error occurred in AH_UDC_Chatter() Constructor => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);
      }
      finally {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
      }
   }

   public void AgreeToUseChatter() {
      AH_UDC_LogHelper.Debug('###AgreeToUseChatter');
      if (IsChatterEnableError == true) return;

      try {
         Boolean ProfileChanged = AH_UDC_SharedWithoutSharing.ChangeUserProfileToChatter();
         //If profile change not successfull, log an error and simply show the page again to the user
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                              'AH_UDC_Chatter', 'AgreeToUseChatter',
                              'Failed to update uers profile to allow chatter (user id: ' + UserInfo.getUserId() + ') (user name:' + UserInfo.getName() + ')', null, UserInfo.getUserId(), 'User');
         //The page is refreshed on the callback
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Log('Exception', 'Chatter Page', 'AgreeToUseChatter', null, exc, UserInfo.getUserId(), 'User');
         IsChatterEnableErrorDetails = 'Exception: ' + exc.getMessage();
         IsChatterEnableError = true;
      }
   }

   //Get all messages along with comments
   public void GetFeedDetails() {
      List<FeedItem> lstFeeds = null;
      List<Id> lstContactIds = new List<Id> ();
      List<User> lstUsers = null;
      FeedWrapper objFeedWrapper = null;
      try {
         FeedList = new List<FeedWrapper> ();

         if (IsShowAllQuestions) {
            for (AH_UDC_Contact__c objUDCContact :[SELECT Contact__c
                 FROM AH_UDC_Contact__c
                 WHERE Document__c = :NIDocId]) {
               lstContactIds.add(objUDCContact.Contact__c);
            }

            if (lstContactIds.size() == 0) {
               LogException('GetFeedDetails', 'UDC Contact Record Not Found', null);
               return;
            }

            lstUsers = new List<User> ([SELECT Id
                                       FROM User
                                       WHERE ContactId IN :lstContactIds AND IsActive = true]);
         }
         else {
            lstUsers = new List<User> ();
            lstUsers.add(new User(Id = UserInfo.getUserId()));
         }

         if (lstUsers == null || lstUsers.size() == 0) {
            LogException('GetFeedDetails', 'User Record Not Found', null);
            return;
         }


         lstFeeds = new List<FeedItem> ([SELECT Id, InsertedById, InsertedBy.Name, Body, CommentCount, CreatedDate, LastEditDate
                                        FROM FeedItem
                                        WHERE ParentId = :NIDocId AND InsertedById IN :lstUsers
                                        ORDER BY LastModifiedDate DESC]);

         if (lstFeeds != null && lstFeeds.size() > 0) {
            for (FeedItem objFeed : lstFeeds) {
               objFeedWrapper = new FeedWrapper();
               objFeedWrapper.Id = objFeed.Id;
               objFeedWrapper.UserName = objFeed.InsertedBy.Name;
               objFeedWrapper.BodyText = String.valueOf(objFeed.Body).replace('\n', '<br>');
               AH_UDC_LogHelper.Debug('###BodyText: ' + objFeed.Body);
               objFeedWrapper.IsEditable = objFeed.InsertedById == UserInfo.getUserId(); //Allow edit only for user's own messages

               if (String.isNotBlank(String.valueOf(objFeed.LastEditDate))) {
                  objFeedWrapper.SentBefore = GetMessageSentTimeText(objFeed.LastEditDate);
               } else {
                  objFeedWrapper.SentBefore = GetMessageSentTimeText(objFeed.CreatedDate);
               }

               objFeedWrapper.Comments = new List<FeedCommentWrapper> ();

               if (objFeed.CommentCount > 0) {
                  objFeedWrapper.Comments = GetFeedComments(objFeed.Id);
               } else {
                  objFeedWrapper.Comments = new List<FeedCommentWrapper> ();
               }

               FeedList.add(objFeedWrapper);
            }
         }
      }
      catch(Exception ex) {
         LogException('GetFeedDetails', 'Error occurred in GetFeedDetails() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);
      }
   }

   //Get all comments based on feed item id
   // This method assumes this class is WITHOUT SHARING
   private List<FeedCommentWrapper> GetFeedComments(Id feedItemId) {
      List<FeedComment> lstFeedComments = null;
      List<FeedCommentWrapper> lstFeedCommentWrapper = null;
      FeedCommentWrapper objFeedCommentWrapper = null;

      try {
         lstFeedCommentWrapper = new List<FeedCommentWrapper> ();

         if (String.isBlank(feedItemId)) {
            LogException('GetFeedComments', 'feedItemId is not provided', null);
            return new List<FeedCommentWrapper> ();
         }

         lstFeedComments = new List<FeedComment> ([SELECT Id, InsertedById, InsertedBy.Name, CommentBody, CreatedDate, LastEditDate
                                                  FROM FeedComment
                                                  WHERE FeedItemId = :feedItemId AND ParentId = :NIDocId]);

         if (lstFeedComments != null && lstFeedComments.size() > 0) {
            for (FeedComment objFeedComment : lstFeedComments) {
               objFeedCommentWrapper = new FeedCommentWrapper();
               objFeedCommentWrapper.Id = objFeedComment.Id;
               objFeedCommentWrapper.UserName = objFeedComment.InsertedBy.Name;
               objFeedCommentWrapper.BodyText = objFeedComment.CommentBody;
               objFeedCommentWrapper.IsEditable = objFeedComment.InsertedById == UserInfo.getUserId(); //Allow edit only for user's own comments
               if (String.isNotBlank(String.valueOf(objFeedComment.LastEditDate))) {
                  objFeedCommentWrapper.SentBefore = GetMessageSentTimeText(objFeedComment.LastEditDate);
               } else {
                  objFeedCommentWrapper.SentBefore = GetMessageSentTimeText(objFeedComment.CreatedDate);
               }
               lstFeedCommentWrapper.add(objFeedCommentWrapper);
            }
         }
         return lstFeedCommentWrapper;
      }
      catch(Exception ex) {
         LogException('GetFeedComments', 'Error occurred in GetFeedComments() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);
         throw ex;
      }
   }

   // Returns message sent time text (Eg. '5 Days Ago').  If dtMessageSentTime
   // was not parsable, a blank string is returned   
   private String GetMessageSentTimeText(DateTime dtMessageSentTime) {
      try {
         Long milliseconds = Datetime.now().getTime() - dtMessageSentTime.getTime();
         Long seconds = milliseconds / 1000;
         Long minutes = seconds / 60;
         Long hours = minutes / 60;
         Long days = hours / 24;
         Long months = days / 30;
         Long years = months / 12;
         if (years > 0) {
            return years + ' ' + Label.AH_UDC_Chatter_Years_Ago;
         }
         if (months > 0) {
            return months + ' ' + Label.AH_UDC_Chatter_Months_Ago;
         }
         if (days > 0) {
            return days + ' ' + Label.AH_UDC_Chatter_Days_Ago;
         }
         if (hours > 0) {
            return hours + ' ' + Label.AH_UDC_Chatter_Hours_Ago;
         }
         if (minutes > 0) {
            return minutes + ' ' + Label.AH_UDC_Chatter_Minutes_Ago;
         }

         return Label.AH_UDC_Chatter_Just_Sent;
      }
      catch(Exception ex) {
         LogException('GetMessageSentTimeText', 'Error occurred in GetMessageSentTimeText() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);
         return '';
      }
   }

   //Post message with a new thread
   // This method assumes this class is WITHOUT SHARING
   public void PostFeedMessage() {
      FeedItem objFeedItem = null;
      String strMessage = null;

      try {
         if (String.isBlank(apexpages.currentpage().getparameters().get('message'))) {
            LogException('PostFeedMessage', 'message text is not provided', null);
            return;
         }
         strMessage = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('message'));

         objFeedItem = new FeedItem();
         objFeedItem.ParentId = NIDocId;
         objFeedItem.Type = 'TextPost';
         objFeedItem.IsRichText = false;
         objFeedItem.Body = strMessage.escapeHtml4();
         insert objFeedItem;

         //Update feed messages list
         GetFeedDetails();
      }
      catch(Exception ex) {
         LogException('PostFeedMessage', 'Error occurred in PostFeedMessage() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);
      }
   }

   //Post a comment on message
   // This method assumes this class is WITHOUT SHARING
   public void PostFeedComment() {
      FeedComment objFeedComment = null;
      String strComment = null;
      Id feedItemId = null;
      try {
         if (String.isBlank(apexpages.currentpage().getparameters().get('feedItemId'))
             ||
             String.isBlank(apexpages.currentpage().getparameters().get('comment'))) {
            LogException('PostFeedComment', 'Must specify a FeedItemId and text for the Comment', null);
            return;
         }

         feedItemId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('feedItemId'));
         strComment = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('comment'));

         if (String.isBlank(feedItemId) || String.isBlank(strComment)) {
            LogException('PostFeedComment', 'Must specify a FeedItemId and text for the Comment', null);
            return;
         }

         objFeedComment = new FeedComment();
         objFeedComment.FeedItemId = feedItemId;
         objFeedComment.CommentType = 'TextComment';
         objFeedComment.IsRichText = false;
         objFeedComment.CommentBody = strComment.escapeHtml4();
         insert objFeedComment;

         //Update feed messages list
         GetFeedDetails();
      }
      catch(Exception ex) {
         LogException('PostFeedComment', 'Error occurred in PostFeedComment() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);
      }
   }

   //Update existing message
   // This method assumes this class is WITHOUT SHARING
   public void UpdateFeedMessage() {
      FeedItem objFeedItem = null;
      String strFeedItemId = null, strMessage = null;
      try {
         if (String.isBlank(apexpages.currentpage().getparameters().get('feeditemid'))
             ||
             String.isBlank(apexpages.currentpage().getparameters().get('message'))) {
            LogException('UpdateFeedMessage', 'Must specify a FeedItemId and text for the Message', null);
            return;
         }

         strFeedItemId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('feeditemid'));
         strMessage = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('message'));

         objFeedItem = new FeedItem();
         objFeedItem.Id = strFeedItemId;
         objFeedItem.Body = strMessage.escapeHtml4();
         update objFeedItem;

         //Update feed messages list
         GetFeedDetails();
      }
      catch(Exception ex) {
         LogException('UpdateFeedMessage', 'Error occurred in UpdateFeedMessage() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);
      }
   }

   //Update existing comment message
   // This method assumes this class is WITHOUT SHARING
   public void UpdateFeedComment() {
      FeedComment objFeedComment = null;
      String strFeedCommentId = null;
      String strComment = null;
      try {
         if (String.isBlank(apexpages.currentpage().getparameters().get('feedcommentid'))
             ||
             String.isBlank(apexpages.currentpage().getparameters().get('comment'))) {
            LogException('UpdateFeedComment', 'Must specify a FeedCommentId and text for the Comment', null);
            return;
         }

         strFeedCommentId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('feedcommentid'));
         strComment = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('comment'));

         objFeedComment = new FeedComment();
         objFeedComment.Id = strFeedCommentId;
         objFeedComment.CommentBody = strComment.escapeHtml4();
         update objFeedComment;

         //Update feed messages list
         GetFeedDetails();
      }
      catch(Exception ex) {
         LogException('UpdateFeedComment', 'Error occurred in UpdateFeedComment() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);
      }
   }

   // Check if user has access of workbook or not.
   // This method assumes this class is WITHOUT SHARING
   private Boolean UserHasAccessToNIDoc() {
      User objUser = null;
      List<AH_UDC_Contact__c> lstUDCContacts = null;

      try {
         //Get logged-in user's contact id
         objUser = [SELECT Id, Username, ContactId FROM User WHERE Id = :UserInfo.getUserId() AND IsActive = true];
         AH_UDC_LogHelper.Debug('###objUser.ContactId: ' + objUser.ContactId);
         AH_UDC_LogHelper.Debug('###NIDocId: ' + NIDocId);

         if (objUser == null) {
            LogException('UserHasAccessToNIDoc', 'User record not found', null);
            return false;
         }

         //Get UDC Workbook records for logged-in user
         lstUDCContacts = [SELECT Id
                           FROM AH_UDC_Contact__c
                           WHERE Document__c = :NIDocId
                           AND Contact__c = :objUser.ContactId];
         AH_UDC_LogHelper.Debug('###lstUDCContacts: ' + lstUDCContacts);

         //Return true if user has NI Doc record Access otherwise return false
         return lstUDCContacts != null && lstUDCContacts.size() > 0;
      }
      catch(Exception ex) {
         LogException('UserHasAccessToNIDoc', 'Error occurred in UserHasAccessToNIDoc() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);
         throw ex;
      }
   }

   // This method assumes this class is WITHOUT SHARING
   public PageReference UpdateChatterAccessDetails() {
      try {
         if (!UserHasAccessToNIDoc()) {
            LogException('UpdateChatterAccessDetails', 'The user (' + System.UserInfo.getUserName() + ') is trying to access ChatterAccessDetails for NIDoc (' + NIDocId + ')', null);
            return null;
         }

         AH_UDC_LogHelper.Debug('NIDocId=>' + NIDocId);
         List<User> listUsers = [SELECT Id, ContactId, IsActive FROM User WHERE Id = :UserInfo.getUserId()];

         if (listUsers.Size() == 0) {
            LogException('UpdateChatterAccessDetails', 'User (' + UserInfo.getUserId() + ') was not found', null);
            return null;
         }

         if (!listUsers[0].IsActive) {
            LogException('UpdateChatterAccessDetails', 'User (' + UserInfo.getUserId() + ') is not active', null);
            return null;
         }

         //Set chatter access date time on load of page 
         AH_UDC_Contact__c oUdcContact = [SELECT Id, ChatterLastViewed__c
                                          FROM AH_UDC_Contact__c
                                          WHERE Document__c = :NIDocId
                                          AND Contact__c = :listUsers[0].ContactId];
         oUdcContact.ChatterLastViewed__c = Datetime.now();
         AH_UDC_LogHelper.Debug('oUdcContact=>' + oUdcContact);
         update oUdcContact;

         return null;
      }
      catch(Exception ex) {
         LogException('UpdateChatterAccessDetails', 'Error occurred in UpdateChatterAccessDetails() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);
         throw ex;
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc) {
      IsErrorOccurred = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message, exc);
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML retrictions
   public void ServerLogMessages() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages');
      try {
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0) {
            insert(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'ServerLogMessages',
                              'An exception occurred logging Page Load AH_UDC_Log entries',
                              exc, null, null);
      }
   }
}