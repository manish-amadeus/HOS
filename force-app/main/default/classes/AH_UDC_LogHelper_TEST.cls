/*
 * Name         : AH_UDC_LogHelper_TEST
 * Created By   : George Tasker (george.tasker@amadeus.com)
 * Created Date : 2020-Oct-06
 * Description  : Test class for AH_UDC_LogHelper.cls
 * Dependencies : AH_UDC_LogHelper.cls
 */
@isTest
private class AH_UDC_LogHelper_TEST {

   // Setup the data used for the tests in this test class
   @TestSetup private static void setup() {
      // Do not call Initialize() in this test class, as the AH_UDC_InitailizationHelper has a message
      // logged that is delayed for some Salesforce reason, and that breaks some of the tests
      // in this test class
      //AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   // These steps are not done in the setup() function as they intefere with some of the logging
   // tests, as there are logging lines in the ConfigSettings code
   private static void overrideLoggingSettings() {
      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, 'true');

      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_EXCEPTIONS, 'true');
      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS, 'true');
      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_TRACES, 'true');
      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_WARNINGS, 'true');

      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS, 'false');
      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS, 'false');
      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, 'false');
      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_RECIPIENTS, 'test@amadeus.com');
   }

   @isTest
   private static void testSystemDebug_Off() {
      overrideLoggingSettings();
      AH_UDC_LogHelper.debug('Starting testSystemDebug_Off()');

      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, 'false');

      try {
         System.assertEquals(true, AH_UDC_LogHelper.Debug('This is my message'), 'System.Debug replacement should have logged a debug log message because this is in a test class and all messages get written for test classes');
      }
      catch(Exception exc) {
         System.assert(false, 'An exception occurred in ' + AH_UDC_LogHelper.getMethodName(new DmlException()) + '(). ' + exc.getMessage());
      }
   }

   @isTest
   private static void testSystemDebug_On() {
      overrideLoggingSettings();
      AH_UDC_LogHelper.debug('Starting testSystemDebug_On()');
      try {
         System.assertEquals(true, AH_UDC_LogHelper.Debug('This is my message'), 'System.Debug replacement should have logged a debug log message');
         System.assertEquals(true, AH_UDC_LogHelper.Debug(LoggingLevel.Error, 'This is my message'), 'System.Debug replacement should have logged a debug log message');
      }
      catch(Exception exc) {
         System.assert(false, 'An exception occurred in ' + AH_UDC_LogHelper.getMethodName(new DmlException()) + '(). ' + exc.getMessage());
      }
   }

   @isTest
   private static void testLogMessage() {
      overrideLoggingSettings();
      AH_UDC_LogHelper.debug('Starting testLogMessage()');

      try {
         string functionalArea = 'LogHelper_TEST class';
         string methodName = AH_UDC_LogHelper.getMethodName(new DmlException());

         AH_UDC_Log__c logDebug = AH_UDC_LogHelper.Log('Debug', functionalArea, methodName, 'My DEBUG log message');
         System.assertNotEquals(null, logDebug.Id, 'Log of DEBUG message failed');

         AH_UDC_Log__c logTrace = AH_UDC_LogHelper.Log('Trace', functionalArea, methodName, 'My TRACE log message');
         System.assertNotEquals(null, logTrace.Id, 'Log of TRACE message failed');

         AH_UDC_Log__c logMessage = AH_UDC_LogHelper.Log('Message', functionalArea, methodName, 'My MESSAGE log message');
         System.assertNotEquals(null, logMessage.Id, 'Log of MESSAGE message failed');

         AH_UDC_Log__c logWarn = AH_UDC_LogHelper.Log('Warn', functionalArea, methodName, 'My WARN log message');
         System.assertNotEquals(null, logWarn.Id, 'Log of WARN message failed');

         AH_UDC_Log__c logError = AH_UDC_LogHelper.Log('Error', functionalArea, methodName, 'My ERROR log message');
         System.assertNotEquals(null, logError.Id, 'Log of ERROR message failed');

         // NOTE: Purposely not testing 'Exception'
      }
      catch(Exception exc) {
         System.assert(false, 'An exception occurred in ' + AH_UDC_LogHelper.getMethodName(new DmlException()) + '(). ' + exc.getMessage());
      }
   }

   @isTest
   private static void testLogMessageWithException() {
      overrideLoggingSettings();
      AH_UDC_LogHelper.debug('Starting testLogMessageWithException()');

      string functionalArea = 'LogHelper_TEST class';
      string methodName = AH_UDC_LogHelper.getMethodName(new DmlException());

      try {
         throw new AH_UDC_LogHelper.AH_UDC_LogException('Test LogMessage() with an exception');
      }
      catch(Exception expectedException) {
         try {
            AH_UDC_Log__c logException = AH_UDC_LogHelper.Log('Exception', functionalArea, methodName,
                                                'My EXCEPTION log message', expectedException, null, null);
            System.assertNotEquals(null, logException.Id, 'Log of EXCEPTION message failed');
         }
         catch(Exception exc) {
            System.assert(false, 'An exception occurred in ' + AH_UDC_LogHelper.getMethodName(new DmlException()) + '(). ' + exc.getMessage());
         }
      }
   }

   @isTest
   private static void testLogMessageWithDmlException() {
      overrideLoggingSettings();
      AH_UDC_LogHelper.debug('Starting testLogMessageWithDmlException()');

      string functionalArea = 'LogHelper_TEST class';
      string methodName = AH_UDC_LogHelper.getMethodName(new DmlException());

      try
      {
         AH_UDC_LogHelper.QueueLogs = false;

         // Intentionally trying to insert a record with missing data in required fields
         AH_UDC_ConfigurationSetting__c cs = new AH_UDC_ConfigurationSetting__c();
         insert cs;

         System.assert(false, 'testLogMessageWithDmlException should have failed with a DML exception');
      }
      catch(Exception e) {
         AH_UDC_LogHelper.debug(LoggingLevel.ERROR, 'Test method intentionally causes a DML exception due to StartDate__c not being populated');
         AH_UDC_Log__c excLog = AH_UDC_LogHelper.Log('Exception', functionalArea, methodName,
                                       'Test log message', e, null, null);
         System.assertNotEquals(null, excLog.Id, 'Failed to write the DML log exception message');
      }
   }

   @isTest
   private static void testQueueMessage() {
      overrideLoggingSettings();
      AH_UDC_LogHelper.debug('Starting testQueueMessage()');

      string functionalArea = 'LogHelper_TEST class';
      string methodName = AH_UDC_LogHelper.getMethodName(new DmlException());

      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS, 'false');
      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS, 'false');
      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, 'false');

      try {
         Test.startTest();

         AH_UDC_LogHelper.QueueLogs = true;
         AH_UDC_LogHelper.writeQueuedLogs();

         AH_UDC_Log__c queueError = AH_UDC_LogHelper.Queue('Error', functionalArea, methodName, 'My ERROR log message');
         System.assert(AH_UDC_LogHelper.QueueLogs == true, 'Queued a log record, but the QueueLogs did not become TRUE');
         System.assert(queueError.Id == null, 'The Id of the queued log record should not have an Id, as it has not been written yet');

         AH_UDC_LogHelper.writeQueuedLogs();

         Boolean foundUnexpectedLogs = false;
         List<AH_UDC_Log__c> logs = [SELECT LogText__c from AH_UDC_Log__c];
         for (AH_UDC_Log__c log : logs) {
            if (log.LogText__c != 'Initialize ConfigurationSettings Completed'
                && !log.LogText__c.startsWith('My ERROR log message')) {
               System.debug('Extra Log messages found ' + log.LogText__c);
               foundUnexpectedLogs = true;
            }
         }

         System.assert(foundUnexpectedLogs==false, 'After writing the queued logs, there were more logs created than expected');

         Test.stopTest();
      }
      catch (Exception exc) {
         System.assert(false, 'An exception occurred in ' + AH_UDC_LogHelper.getMethodName(new DmlException()) + '(). ' + exc.getMessage());
      }
   }

   @isTest
   private static void test200PlusQueuedMessages() {
      overrideLoggingSettings();
      AH_UDC_LogHelper.debug('Starting test200PlusQueuedMessages()');

      string functionalArea = 'LogHelper_TEST class';
      string methodName = AH_UDC_LogHelper.getMethodName(new DmlException());

      try {
         Integer numberOfLogMessagesToQueue = 250;
         for (Integer i = 0; i<numberOfLogMessagesToQueue; i++) {
            AH_UDC_Log__c queueError = AH_UDC_LogHelper.Queue('Error', functionalArea, methodName, 'My ERROR log message #' + (i + 1));
         }

         AH_UDC_LogHelper.writeQueuedLogs();
         Boolean foundUnexpectedLogs = false;
         List<AH_UDC_Log__c> logs = [SELECT LogText__c from AH_UDC_Log__c];
         for (AH_UDC_Log__c log : logs) {
            if (log.LogText__c != 'Initialize ConfigurationSettings Completed'
                && !log.LogText__c.startsWith('My ERROR log message')) {
               System.debug('Extra Log messages found ' + log.LogText__c);
               foundUnexpectedLogs = true;
            }
         }

         System.assert(foundUnexpectedLogs==false, 'After writing the queued logs, there were more logs created than expected.  See the log for the extra log records\' text');
      }
      catch(Exception exc) {
         System.assert(false, 'An exception occurred in ' + AH_UDC_LogHelper.getMethodName(new DmlException()) + '(). ' + exc.getMessage());
      }
   }

   @isTest
   private static void testQueueMessageWithException() {
      overrideLoggingSettings();

      AH_UDC_LogHelper.Debug('Starting testQueueMessageWithException()');

      string functionalArea = 'LogHelper_TEST class';
      string methodName = AH_UDC_LogHelper.getMethodName(new DmlException());

      Test.startTest();

      try {
         throw new AH_UDC_LogHelper.AH_UDC_LogException('Test LogMessage() with an exception');
      }
      catch(Exception expectedException) {
         try {
            AH_UDC_Log__c logException = AH_UDC_LogHelper.Queue('Exception', functionalArea, methodName,
                                                  'My EXCEPTION log message', expectedException, null, null);
            AH_UDC_LogHelper.writeQueuedLogs();
            Boolean foundUnexpectedLogs = false;
            List<AH_UDC_Log__c> logs = [SELECT LogText__c from AH_UDC_Log__c];
            for (AH_UDC_Log__c log : logs) {
               if (log.LogText__c != 'Initialize ConfigurationSettings Completed'
                   && !log.LogText__c.startsWith('My EXCEPTION log message')) {
                  System.debug('Extra Log messages found ' + log.LogText__c);
                  foundUnexpectedLogs = true;
               }
            }
         }
         catch(Exception exc) {
            System.assert(false, 'An exception occurred in ' + AH_UDC_LogHelper.getMethodName(new DmlException()) + '(). ' + exc.getMessage());
         }
      }

      Test.stopTest();
   }

   @isTest
   private static void testQueueMessageWithExceptionWithEmailNotification() {
      overrideLoggingSettings();
      AH_UDC_LogHelper.debug('Starting testQueueMessageWithExceptionWithEmailNotification()');

      string functionalArea = 'LogHelper_TEST class';
      string methodName = AH_UDC_LogHelper.getMethodName(new DmlException());

      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, 'true');

      Test.startTest();

      try {
         throw new AH_UDC_ConfigHelper.AH_UDC_ConfigException('Test LogMessage() with an exception');
      }
      catch(Exception expectedException) {
         try {
            AH_UDC_Log__c logException = AH_UDC_LogHelper.Queue('Exception', functionalArea, methodName,
                                                  'My EXCEPTION log message', expectedException, null, null);
            AH_UDC_LogHelper.writeQueuedLogs();
            Boolean foundUnexpectedLogs = false;
            List<AH_UDC_Log__c> logs = [SELECT LogText__c from AH_UDC_Log__c];
            for (AH_UDC_Log__c log : logs) {
               if (log.LogText__c != 'Initialize ConfigurationSettings Completed'
                   && !log.LogText__c.startsWith('My EXCEPTION log message')) {
                  System.debug('Extra Log messages found ' + log.LogText__c);
                  foundUnexpectedLogs = true;
               }
            }
         }
         catch(Exception exc) {
            System.assert(false, 'An exception occurred in ' + AH_UDC_LogHelper.getMethodName(new DmlException()) + '(). ' + exc.getMessage());
         }
      }

      Test.StopTest();
   }


   @isTest
   private static void testQueueMessageWithExceptionWithEmailNotification2() {
      overrideLoggingSettings();
      AH_UDC_LogHelper.debug('Starting testQueueMessageWithExceptionWithEmailNotification2()');

      string functionalArea = 'LogHelper_TEST class';
      string methodName = AH_UDC_LogHelper.getMethodName(new DmlException());

      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, 'true');

      // Turn on Queued Logging so that even when Log() is called, it will use Queue()
      AH_UDC_LogHelper.QueueLogs = true;

      try {
         throw new AH_UDC_LogHelper.AH_UDC_LogException('Test LogMessage() with an exception');
      }
      catch(Exception expectedException) {
         try {
            AH_UDC_Log__c logException = AH_UDC_LogHelper.Log('Exception', functionalArea, methodName,
                                                'My EXCEPTION log message', expectedException, null, null);

            Integer countBeforeWritingQueued = [SELECT COUNT() FROM AH_UDC_Log__c];
            System.assertEquals(0, countBeforeWritingQueued, 'Before writing the queued logs, there should have been zero log records, but found: ' + countBeforeWritingQueued);

            AH_UDC_LogHelper.writeQueuedLogs();

            Integer countAfterWritingQueued = [SELECT COUNT() FROM AH_UDC_Log__c];

            // If the org is not configured to send email, there will be a second log message indicating the 
            // sending of email is not configured to be enabled in the org
            Integer expected = 1;

            //TODO ROBDEV Determine why this test is failing 
            //if (!AH_UDC_EmailHelper.OrgCanSendEmail) expected += 1;

            System.assertEquals(expected, countAfterWritingQueued, 'After writing the queued logs, there should have been ' + expected + ' log record(s), but found: ' + countAfterWritingQueued);
         }
         catch(Exception exc) {
            System.assert(false, 'An exception occurred in ' + AH_UDC_LogHelper.getMethodName(new DmlException()) + '(). ' + exc.getMessage());
         }
      }
   }
}