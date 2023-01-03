/*
 * Name         : AH_UDC_LogHelper
 * Created By   : George Tasker (george.tasker@amadeus.com)
 * Created Date : 2020-Oct-06
 * Description  : Functions used for logging messages (debug, events, exceptions)
 * Dependencies : 
 * Test Class   : AH_UDC_LogHelper_TEST.cls
 *
 * This class supports immediate writes to the AH_UDC_Log__c object using the Log() function
 *
 * Example #1:
 *    AH_UDC_LogHelper.Log('Error', 'CustomCodeArea', AH_UDC_LogHelper.getClassAndMethodName(new DmException()),
 *                  'This is the message text that is being logged');
 *
 * Example #2:
 *    catch (Exception exc) {
 *       AH_UDC_LogHelper.Log('Exception', 'CustomCodeArea', AH_UDC_LogHelper.getClassAndMethodName(new DmException()),
 *                     'This is the message text that is being logged', exc, null, null);
 *    }
 *
 * Example #3:
 *    try {
 *       Rfp__c rfp = [SELECT Id, Name FROM RFP__C where Id = '...'];
 *         ...
 *       update rfp;
 *    }
 *    catch (DmlException exc) {
 *       AH_UDC_LogHelper.Log('Exception, 'CustomCodeArea', AH_UDC_LogHelper.getClassAndMethodName(new DmException()),
 *                     'The update failed', exc, rfp.Id, 'Rfp__c');
 *    }
 *
 * This class also supports queued logging, where logs are stored in memory rather
 *    than written immediately to the AH_UDC_Log__c object. Any logs that are queued are not
 *    written to the AH_UDC_Log__c object until the calling code executes writeQueuedLogs()
 *
 * The code using this instance of this class can force the use of queued logs by setting
 *    QueueLogs = true, or calling Queue() instead of Log().
 *
 * Any call to Log() while QueueLogs is true will not immediately log, instead it will queue
 *    the log entry. This allows code that needs to use queueing (like when there is a callout)
 *    to call other functions that may not know that queued logging is necessary, and still
 *    have the logging calls get logged when the code calls writeQueuedLogs()
 */
public without sharing class AH_UDC_LogHelper {
   public static final string Debug_Prefix = '#UDC#';

   //These are the log levels that can be sent
   public static final string LogLevel_DEBUG = 'Debug'; // Used only for development, will never write to the log in Production
   public static final string LogLevel_TRACE = 'Trace'; // Used to log messages that can be used in troubleshooting production issues
   public static final string LogLevel_MESSAGE = 'Message'; // Used to always log the message text, will never be blocked from logging
   public static final string LogLevel_WARN = 'Warn'; // Message warns of a situation that does not prevent processing, but might be helpful to know it is happening
   public static final string LogLevel_ERROR = 'Error'; // Code detected an error occurred during execution. This type is for errors that are expected/handled
   public static final string LogLevel_EXC = 'Exception'; // Code experienced a thrown exception that was caught by a TRY/CATCH block.  Stack trace is also logged


   public static final string CONFIG_KEY_LOG_DEBUG_MESSAGES = 'LogDebugMessages';

   public static final string CONFIG_KEY_LOG_SETTINGS_LOG_TRACES = 'LogTraces';
   public static final string CONFIG_KEY_LOG_SETTINGS_LOG_WARNINGS = 'LogWarnings';
   public static final string CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS = 'LogErrors';
   public static final string CONFIG_KEY_LOG_SETTINGS_LOG_EXCEPTIONS = 'LogExceptions';

   public static final string CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS = 'EmailLogWarnings';
   public static final string CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS = 'EmailLogErrors';
   public static final string CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS = 'EmailLogExceptions';
   public static final string CONFIG_KEY_LOG_SETTINGS_EMAIL_RECIPIENTS = 'EmailLogRecipients';

   private static final string TIMESTAMP_FORMAT = 'yyyy-MM-dd HH:mm:ss';

   // When set to TRUE, any calls to Log() will be redirected to QueueMessage. This way, if the code 
   // that is executing will make a callout, but calls a general helper class that logs a message, the logging
   // will atomatically be queued instead of causing an error due to the callout.
   public static Boolean QueueLogs { get; set; }

   // Singleton pattern - Static, final variable that initializes an instance of the class.
   // As the function final, it will only be initialized once.
   private static final AH_UDC_LogHelper instance = new AH_UDC_LogHelper();

   // Contains any Log records that have been queued to be written
   private static List<AH_UDC_log__c> QueuedLogRecords = new List<AH_UDC_log__c> ();

   private static AH_UDC_SystemContext m_sysContext = new AH_UDC_SystemContext();

   // Singleton constructor
   private AH_UDC_LogHelper() {
      QueueLogs = false;
   }

   // Use this function instead of System.debug() for debugging lines that will go to production
   // that can be temporarily turned on in production only if needed to troubleshoot issues 
   // without negatively affecting performance when LogDebugMessages is set to false
   //
   // NOTE: This uses Salesforce's LoggingLevel, not LogLevel
   //
   // The return value indicates if a message was logged or not
   public static Boolean Debug(string message) {
      if (!Test.isRunningTest() && !AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, false)) {
         return false;
      }

      System.debug(Debug_Prefix + message);
      return true;
   }

   // Use this function instead of System.debug() for debugging lines that will go to production
   // that can be temporarily turned on in production only if needed to troubleshoot issues 
   // without negatively affecting performance when LogDebugMessages is set to false
   //
   // NOTE: This uses Salesforce's LoggingLevel, not LogLevel
   public static Boolean Debug(LoggingLevel level, string message) {
      if (!Test.isRunningTest() && !AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, false)) {
         return false;
      }

      System.debug(level, Debug_Prefix + message);
      return true;
   }

   // Short-hand parameter list with fewer parameters for logging a message that does not require an exception,
   // relatedRecordId, or relatedRecordType to be specified
   //
   // logLevel - should normally use one of the constant strings defined in the LogLevel class
   //
   // functionalArea - indicates the area of the program that the log message was generated in (e.g. 'ELS',
   //            'Create RFP', 'Clone Opportunity' and can be used for grouping/filters log entries
   //
   // sourceMethod - Name of the function in which the error occurred
   //
   // details - Human readable text containing the message that is to be logged
   //
   // If logging is turned off, the return value will be null
   //
   // If the Log Message was written immediately, the Id on the return AH_UDC_Log__c will be populated.  Queued
   // log messages will not have the Id populated
   public static AH_UDC_log__c Log(string logLevel, string functionalArea, string sourceMethod, string details) {
      return Log(logLevel, functionalArea, sourceMethod, details, null, null, null);
   }

   // Logs a message with the indicated Log Level, specifying the functionalArea that the error occurred in
   // (e.g. ELS, Create RFP, Clone Opportunity, etc), the name of the source code Method that the error
   // occurred in, and then the details (text) of the message that is to be logged
   //
   // logLevel - should normally use one of the constant strings defined in the LogLevel class
   //
   // functionalArea - indicates the area of the program that the log message was generated in (e.g. 'ELS',
   //            'Create RFP', 'Clone Opportunity' and can be used for grouping/filters log entries
   //
   // sourceMethod - Name of the function in which the error occurred
   //
   // details - Human readable text containing the message that is to be logged
   //
   // e - [Optional] Points to an exception instance whose message/stacktrace are to be logged. Will be
   //             ignored if the value is NULL
   //
   // relatedRecordId - [Optional] Id of the record that was being processed when this log was sent.  Will 
   //             be ignored if the value is NULL.
   //
   // relatedRecordType - [Optional] Data type of the record that was being processed when this log was sent.
   //             Will be ignored if the value is NULL
   //
   // If QueueLogs is TRUE, this function will automatically redirect the logging to QueueMessage.
   // This way if an operation is being performed that calls out to a generic function that needs to log
   // a message, it will automatically queue the message instead of trying to write immediately, which
   // could fail due to actions being performed, such as a callout
   //
   // If the Log Message was written immediately, the Id on the return AH_UDC_Log__c will be populated.  Queued
   // log messages will not have the Id populated
   public static AH_UDC_log__c Log(string logLevel, string functionalArea, string sourceMethod, string details,
                                   Exception e, String relatedRecordId, string relatedRecordType) {
      
      // Check if the instance of this class has been set to force queued logging
      if (QueueLogs) {
         return Queue(logLevel, functionalArea, sourceMethod, details, e, relatedRecordId, relatedRecordType);
      }

      AH_UDC_log__c log = BuildLogRecord(logLevel, functionalArea, sourceMethod, details, e, relatedRecordId, relatedRecordType);
      if (log != null) {
         write(log);
      }

      return log;
   }

   // Short-hand parameter list with fewer parameters for queueing a log message that does not require an exception,
   // relatedRecordId, or relatedRecordType to be specified
   //
   // logLevel - should normally use one of the constant strings defined in the LogLevel class
   //
   // functionalArea - indicates the area of the program that the log message was generated in (e.g. 'ELS',
   //            'Create RFP', 'Clone Opportunity' and can be used for grouping/filters log entries
   //
   // sourceMethod - Name of the function in which the error occurred
   //
   // details - Human readable text containing the message that is to be logged
   //
   // Calling this function will automatically set the QueueLogs value to TRUE
   //
   // The returned AH_UDC_Log__c instance will not have an Id value
   public static AH_UDC_log__c Queue(string logLevel, string functionalArea, string sourceMethod, string details) {
      return Queue(logLevel, functionalArea, sourceMethod, details, null, null, null);
   }

   // Queues a log message with the indicated LogLevel, specifying the functionalArea that the error occurred in
   // (e.g. ELS, Create RFP, Clone Opportunity, etc), the name of the source code Method that the error
   // occurred in, and then the details (text) of the message that is to be logged
   //
   // logLevel - should normally use one of the constant strings defined in the LogLevel class
   //
   // functionalArea - indicates the area of the program that the log message was generated in (e.g. 'ELS',
   //            'Create RFP', 'Clone Opportunity' and can be used for grouping/filters log entries
   //
   // sourceMethod - Name of the function in which the error occurred
   //
   // details - Human readable text containing the message that is to be logged
   //
   // e - [Optional] Points to an exception instance whose message/stacktrace are to be logged. Will be
   //             ignored if the value is NULL
   //
   // relatedRecordId - [Optional] Id of the record that was being processed when this log was sent.  Will 
   //             be ignored if the value is NULL.
   //
   // relatedRecordType - [Optional] Data type of the record that was being processed when this log was sent.
   //             Will be ignored if the value is NULL
   //
   // Calling this function will automatically set the QueueLogs value to TRUE
   //
   // The returned AH_UDC_Log__c instance will not have an Id value
   public static AH_UDC_log__c Queue(string logLevel, string functionalArea, string sourceMethod, string details,
                                    Exception exc, String relatedRecordId, string relatedRecordType) {
      QueueLogs = true;

      AH_UDC_log__c log = BuildLogRecord(logLevel, functionalArea, sourceMethod, details, exc, relatedRecordId, relatedRecordType);
      if (log != null) {
         write(log);
      }
      
      return log;
   }

   //Allow Page Controllers to get any queued logs so that they can be put in page property for logging on callback from javascript
   public static List<AH_UDC_log__c> GetQueuedLogs() {
      return QueuedLogRecords;
   }

   // Returns a AH_UDC_Log__c record that is ready to be inserted.  If logging for the LogLevel
   // is turned off, then NULL is returned
   private static AH_UDC_log__c BuildLogRecord(string level, string functionalArea, string sourceMethod, string details,
                                     Exception e, String relatedRecordId, string relatedRecordType) { 
      
      // Check if logging is turned OFF for this message level, and if it is, return NULL to the calling code
      if (level.toUpperCase() == 'TRACE'
          &&
          !AH_UDC_ConfigHelper.GetBoolean(CONFIG_KEY_LOG_SETTINGS_LOG_TRACES, false)) {
          return null;
      }
      if (level.toUpperCase() == 'WARN'
          &&
          !AH_UDC_ConfigHelper.GetBoolean(CONFIG_KEY_LOG_SETTINGS_LOG_WARNINGS, false)) {
          return null;
      }
      if (level.toUpperCase() == 'ERROR'
          &&
          !AH_UDC_ConfigHelper.GetBoolean(CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS, true)) {
          return null;
      }
      if (level.toUpperCase() == 'EXCEPTION'
          &&
          !AH_UDC_ConfigHelper.GetBoolean(CONFIG_KEY_LOG_SETTINGS_LOG_EXCEPTIONS, true)) {
          return null;
      }

      AH_UDC_log__c log = new AH_UDC_log__c();
      log.LogDate__c = System.now();
      log.Level__c = level;
      log.FunctionalArea__c = functionalArea;
      log.Source__c = sourceMethod;
      log.Message__c = details.left(255);
      log.LogText__c = details;
      log.RecordId__c = relatedRecordId;
      log.RelatedObjectType__c = relatedRecordType;

      if (e != null) {
         log.LogText__c += ' | ' + FormatException(e);
      }

      return log;
   }

   // Assembles all details available from an exception in the style of .Net ToString()
   public static String FormatException(System.Exception exceptionToFormat)
   {
      if (exceptionToFormat == null) return '';

      String messages = '';
      String dmlInfo = '';
      System.Exception nextException = exceptionToFormat;

      try
      {
         // Loop through all the nested exceptions
         while (nextException != null)
         {
            if (messages != '') messages += ' ---> ';

            messages += nextException.getTypeName() + ': ' + nextException.getMessage();

            // DMLException has additional details for each data row
            if (nextException instanceOf DMLException) {
               try {
                  DMLException dmlException = (DMLException) nextException;
                  Integer rowCount = dmlException.getNumDml();
                  dmlInfo = '--- DML Information for ' + rowCount.format() + ' rows ---\n';

                  for (Integer i=0; i<rowCount; i++) {
                     dmlInfo += 'Row ' + i.format() + '\n';
                     dmlInfo += '  StatusCode: ' + dmlException.getDmlType(i) + '\n';
                     dmlInfo += '  Record Id: ' + dmlException.getDmlId(i) + '\n';
                     dmlInfo += '  Index: ' + dmlException.getDmlIndex(i).format() + '\n';
                     dmlInfo += '  Fields: ' + getDmlFieldList(dmlException, i);
                     dmlInfo += '  Message: ' + dmlException.getDmlMessage(i) + '\n';
                  }
               }
               catch(Exception dmlInfoFormattingException) {
                  dmlInfo = 'DML Info not available: ' + dmlInfoFormattingException.getMessage();
               }
            }
            nextException = nextException.getCause();
         }

         return messages + '\n' + exceptionToFormat.getStackTraceString() + '\n' + dmlInfo;
      }
      catch(System.Exception formatFailedException) {
         return exceptionToFormat.getMessage() + '(Full exception formatting failed: ' + formatFailedException.getMessage() + ')';
      }
   }

   // Gathers and returns the names of the fields included in the exception
   private static String getDmlFieldList(DMLException e, Integer i)
   {
      String result = null;
      Schema.sObjectField[] fields = e.getDmlFields(i);
      for (Schema.sObjectField field : fields) {
         if (result != null) result += ', ';
         result += field.getDescribe().getName();
      }

      return result;
   }

   private static void write(AH_UDC_Log__c log)
   {
      if (Test.isRunningTest()) {
         System.debug('TEST CLASS LogText: ' + log.LogText__c);
         System.debug('TEST CLASS FunctionalArea: ' + log.FunctionalArea__c);
         System.debug('TEST CLASS Source: ' + log.Source__c);
      }

      // Protect from strings that are longer than the fields to which they will be written
      if (!String.isBlank(log.LogText__c)) {
         log.LogText__c = log.LogText__c.left(131072);
      }
      if (!String.isBlank(log.FunctionalArea__c)) {
         log.FunctionalArea__c = log.FunctionalArea__c.left(100);
      }
      if (!String.isBlank(log.Source__c)) {
         log.Source__c = log.Source__c.left(255);
      }

      // By default, writing a AH_UDC_Log__c record will also write a message into the debug log.  This way
      // log messages written while running test classes or when in a class constructor where
      // Log__c records are not possible, the message will appear in debug logs
      if (String.isBlank(log.LogText__c)) {
         Debug(LoggingLevel.Warn, '[' + log.Level__c + '] Message logged to AH_UDC_Log__c: But LogText__c was empty');
      } else {
         Debug('[' + log.Level__c + '] Message logged to AH_UDC_Log__c: ' + log.LogText__c);
      }

      // If queueing messages, add this log to the queue, otherwise write it immediately to AH_UDC_Log__c
      if (QueueLogs) {
         QueuedLogRecords.add(log);
      } else {
         m_sysContext.upsertSObj(log);
      }

      // Check the settings to see if this Log message should be emailed
      if ((log.Level__c.toUpperCase() == 'ERROR' && AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS, false))
          ||
          (log.Level__c.toUpperCase() == 'WARN' && AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS, false))
          ||
          (log.Level__c.toUpperCase() == 'EXCEPTION' && AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, false)))
      {
         EmailLog(AH_UDC_ConfigHelper.GetString(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_RECIPIENTS, ''), log);
      }
   }

   // Will return up to 'count' SObjects from the 'fullList' of SObjects, starting at element 'startIndex'.  If there
   // are less than 'count' elements remaining starting at the element indicated in 'startIndex', all remaining 
   // elements from 'startIndex' on are returned
   private static List<SObject> subset(List<SObject> fullList, Integer startIndex, Integer count) {
      List<SObject> returnList = new List<SObject>();
      Integer fullListLength = fullList.size();
      if (fullList != null && fullListLength > 0 && startIndex >= 0 && startIndex <= fullListLength-1 && count > 0) {
         for (Integer i = startIndex; i < fullListLength && i-startIndex < count; i++) {
            returnList.add(fullList.get(i));
         }
      }
      return returnList;
   }

   // Called to have all queued AH_UDC_Log__c records be written to the database
   public static void writeQueuedLogs() {

      // If there are no queued log records, then nothing to do
      if (QueuedLogRecords == null || QueuedLogRecords.size() == 0) {
         return;
      }

      Debug('Number of log records queued: ' + QueuedLogRecords.size());

      //Insert Objects
      m_sysContext.insertSobjList(QueuedLogRecords);

      // Determine which log levels are configured to be emailed
      Set <String> emailMsgTypes = new Set<String>();
      if (AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS, false)) {
         emailMsgTypes.add('Error');
      }
      if (AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS, false)) {
         emailMsgTypes.add('Warn');
      }
      if (AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, false)) {
         emailMsgTypes.add('Exception');
      }
      
      AH_UDC_LogHelper.debug('## These log types are configured to be emailed: ' + emailMsgTypes);

      // Send one email for all queued log messages whose Level is set to be emailed
      String subject = '';
      String msg = '';
      for (AH_UDC_Log__c log : QueuedLogRecords) {
         if (emailMsgTypes.contains(log.Level__c)) {
            if (String.isBlank(subject)) {
               subject = getEmailSubject(log);
            }
            msg += '\r\n------------------\r\n' + getEmailBody(log);
         }
      }

      // if there were any log messages that are set to be mailed, SUBJECT will not be blank
      if (!String.isBlank(subject)) {
         EmailMessage(AH_UDC_ConfigHelper.GetString(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_RECIPIENTS, ''),
                        subject, msg);
      }

      // Clear these records that have already been written, so that they will not be written
      // again in the calling code has more logging to do
      QueuedLogRecords.clear();
   }

   // Extracts the name of the Method from the stacktrace of where the exception was generated
   public static string getClassName(DmlException e) {
      if (e == null) {
         Debug(LoggingLevel.ERROR, 'LogHelper.getClassName() was called without passing in a DmlException instance');
         return '';
      }
      String className = e.getStackTraceString().substringAfter('Class.').substringBefore('.');
      return className;
   }

   // Extracts the name of the Method from the stacktrace of where the exception was generated
   public static string getMethodName(Exception e) {
      if (e == null) {
         Debug(LoggingLevel.ERROR, 'LogHelper.getMethodName() was called without passing in a DmlException instance');
         return '';
      }
      string methodName = e.getStackTraceString().substringBefore(':').substringAfterLast('.');
      return methodName;
   }

   // Extracts both the Class and Method name from the exception, and returns them with a '.' between the two strings
   public static string getClassAndMethodName(DmlException e) {
      return getClassName(e) + '.' + getMethodName(e);
   }

   private static void EmailMessage(string notifyEmails, string subject, string message)
   {
      if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations())
      {
         List<String> ccEmails = new List<String>();

         // If user to email is not found, use the first active user with administrator profile
         String toEmail = notifyEmails;

         if (String.isBlank(toEmail)) {
            toEmail = [SELECT email FROM User where Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1].Email;
         }

         String senderDisplayName = AH_UDC_Constants.APPLICATION_NAME + ' at ' + UserInfo.getOrganizationName();
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         mail.setSenderDisplayName(senderDisplayName);
         //mail.setToAddresses(new List<String> { toEmail });
         mail.setToAddresses(toEmail.split(','));

         mail.setSubject(subject);
         mail.setPlainTextBody(message);

         Messaging.SendEmailResult[] emailResults = AH_UDC_EmailHelper.sendMail(new List<Messaging.SingleEmailMessage> { mail });

         String emailFailures = null;
         for (Messaging.SendEmailResult emailResult : emailResults) {
            if (!emailResult.isSuccess()) {
               for (Messaging.SendEmailError error : emailResult.getErrors()) {
                  emailFailures = emailFailures + error.getMessage() + '\r\n';
               }
            }
         }

         if (emailFailures != null) {
            throw new AH_UDC_LogException('Email Failures Occurred: ' + emailFailures);
         }
      } else {
         throw new AH_UDC_LogException('Maximum number of emails reached. Cannot send.');
      }
   }

   // Sends the LogEvent details to the email addresses listed in the comma-separated string:
   // 
   //    notifyEmails - Comma-separated list of email addresses to send this email to
   //    log          - Log record containing the details to mail to the addressees
   //    
   private static void EmailLog(string notifyEmails, AH_UDC_Log__c log)
   {
      EmailMessage(notifyEmails, getEmailSubject(log), getEmailBody(log));
   }

   public static String getEmailSubject(AH_UDC_Log__c log)
   {
      String subject = log.Level__c + ': ' 
                     + log.Source__c + ': '; 
                     + log.LogText__c.left(80);

      return subject;
   }

   public static String getEmailBody(AH_UDC_Log__c log)
   {
      String body = 'Log: ' + log.LogDate__c + ' GMT'
                  + '\nLevel: ' + log.Level__c
                  + '\nSource: ' + log.Source__c
                  + '\nOrganization Name: ' + UserInfo.getOrganizationName()
                  + '\nOrganizationId: ' + UserInfo.getOrganizationId()
                  + '\nUser Name: ' + UserInfo.getName()
                  + '\n\n' + log.LogText__c;

      return body;
   }

   public class AH_UDC_LogException extends Exception {}
}