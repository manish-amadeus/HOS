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
   public static final string LOGGING_DEBUG_PREFIX = '#UDC#';
   public static final string FORCE_WRITE_LOG_EXCEPTION_FUNCTIONAL_AREA = 'TestWriteLogException';

   //These are the log levels that can be sent
   public static final string LogLevel_DEBUG = 'Debug'; // Used only for development, will never write to the log in Production
   public static final string LogLevel_TRACE = 'Trace'; // Used to log messages that can be used in troubleshooting production issues
   public static final string LogLevel_MESSAGE = 'Message'; // Used to always log the message text, will never be blocked from logging
   public static final string LogLevel_AUDIT = 'Audit'; // Used to always log the audit text, will never be blocked from logging
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

   private static Boolean m_queuedLogs = false;

   // When set to TRUE, any calls to Log() will be redirected to QueueMessage. This way, if the code 
   // that is executing will make a callout, but calls a general helper class that logs a message, the logging
   // will atomatically be queued instead of causing an error due to the callout.
   public static Boolean QueueLogs {
      get {
         return m_queuedLogs;
      }
      set {
         if (Test.isRunningTest()) {
            DmlException de = new DmlException();
            Debug(LoggingLevel.Info, 'QueueLogs set to: ' + value + '\n' + de.getStackTraceString());
         }
         m_queuedLogs = value;
      }
   }

   // Singleton pattern - Static, final variable that initializes an instance of the class.
   // As the function final, it will only be initialized once.
   private static final AH_UDC_LogHelper instance = new AH_UDC_LogHelper();

   // Contains any Log records that have been queued to be written
   private static List<AH_UDC_log__c> m_queuedLogRecords = new List<AH_UDC_log__c> ();

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

      System.debug(LOGGING_DEBUG_PREFIX + message);
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

      System.debug(level, LOGGING_DEBUG_PREFIX + message);
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

      AH_UDC_Log__c log = BuildLogRecord(logLevel, functionalArea, sourceMethod, details, e, relatedRecordId, relatedRecordType);

      // Check if the instance of this class has been set to force queued logging
      if (m_queuedLogs) {
         return Queue(log);
      }

      return Log(log);
   }

   // Writes an already created log__c record to the database
   //
   // If the Log Message was written immediately, the Id on the return Log__c will be populated.  Queued
   // log messages will not have the Id populated
   public static AH_UDC_Log__c Log(AH_UDC_Log__c log) {
      if (log != null) {
         write(log, false);
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

      return Queue(BuildLogRecord(logLevel, functionalArea, sourceMethod, details, exc, relatedRecordId, relatedRecordType));
   }

   // Queues an already created log__c record to be written to the database at a later time
   // The returned log__c instance will not have an Id value
   public static AH_UDC_Log__c Queue(AH_UDC_Log__c log) {
      QueueLogs = true;

      if (log != null) {
         write(log, false);
      }

      return log;
   }

   // Allow Page Controllers to get any queued logs so that they can be put in page property for logging on callback from javascript
   // Creates a copy of the log messages that have been queued, and return it to the calling program
   // Copies are returned, so that a hacker cannot clear/modify the logs before they are written
   public static List<AH_UDC_Log__c> GetQueuedLogs() {
      List<AH_UDC_Log__c> copyOfQueuedLogs = new List<AH_UDC_Log__c> ();
      for (AH_UDC_Log__c log : m_queuedLogRecords) {
         copyOfQueuedLogs.add(log.clone());
      }
      return copyOfQueuedLogs;
   }

   // Returns a AH_UDC_Log__c record that is ready to be inserted.  If logging for the LogLevel
   // is turned off, then NULL is returned
   private static AH_UDC_log__c BuildLogRecord(string level, string functionalArea, string sourceMethod, string details,
                                               Exception e, String relatedRecordId, string relatedRecordType) {
      // Check if logging is turned OFF for this message level, and if it is, return NULL to the calling code
      if (level.equalsIgnoreCase(LogLevel_TRACE)) {
         // The default is NOT to log TRACEs, so if the KEY is missing, or the config
         // setting is set to FALSE, do not log TRACEs
         if (!AH_UDC_ConfigHelper.GetBoolean(CONFIG_KEY_LOG_SETTINGS_LOG_TRACES, false)
              ||
             !AH_UDC_ConfigHelper.ContainsKey(CONFIG_KEY_LOG_SETTINGS_LOG_TRACES)) {
            return null;
         }
      }
      if (level.equalsIgnoreCase(LogLevel_WARN)) {
         // The default is NOT to log WARNINGs, so if the KEY is missing, or the config
         // setting is set to FALSE, do not log WARNINGs
         if (!AH_UDC_ConfigHelper.GetBoolean(CONFIG_KEY_LOG_SETTINGS_LOG_WARNINGS, false)
              ||
             !AH_UDC_ConfigHelper.ContainsKey(CONFIG_KEY_LOG_SETTINGS_LOG_WARNINGS)) {
            return null;
         }
      }
      if (level.equalsIgnoreCase(LogLevel_ERROR)) {
         // The default is to log ERRORs. If the KEY does not yet exist,
         // force the code to log the ERROR, otherwise use the config setting
         if (!AH_UDC_ConfigHelper.GetBoolean(CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS, true)
             &&
             AH_UDC_ConfigHelper.ContainsKey(CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS)) {
            return null;
         }
      }
      if (level.equalsIgnoreCase(LogLevel_EXC)) {
         // The default is to log EXCEPTIONs. If the KEY does not yet exist,
         // force the code to log the EXCEPTION, otherwise use the config setting
         if (!AH_UDC_ConfigHelper.GetBoolean(CONFIG_KEY_LOG_SETTINGS_LOG_EXCEPTIONS, true)
             &&
             AH_UDC_ConfigHelper.ContainsKey(CONFIG_KEY_LOG_SETTINGS_LOG_EXCEPTIONS)) {
            return null;
         }
      }

      AH_UDC_log__c log = new AH_UDC_log__c();
      log.LogDate__c = System.now();
      log.Level__c = level;
      log.FunctionalArea__c = (String.isBlank(functionalArea) ? functionalArea : functionalArea.left(100));
      log.Source__c = (String.isBlank(sourceMethod) ? sourceMethod : sourceMethod.left(255));
      log.Message__c = (String.isBlank(details) ? details : details.left(255));
      log.LogText__c = ((String.isBlank(details) ? '' : details) + (e != null ? ' | ' + FormatException(e) : '')).left(131072);
      log.RecordId__c = (String.isBlank(relatedRecordId) ? relatedRecordId : relatedRecordId.left(255));
      log.RelatedObjectType__c = (String.isBlank(relatedRecordType) ? relatedRecordType : relatedRecordType.left(255));

      return log;
   }

   // Assembles all details available from an exception in the style of .Net ToString()
   public static String FormatException(System.Exception exceptionToFormat) {
      if (exceptionToFormat == null) return '';

      String messages = '';
      String dmlInfo = '';
      System.Exception nextException = exceptionToFormat;

      try {
         // Loop through all the nested exceptions
         while (nextException != null) {
            if (messages != '') messages += ' ---> ';

            messages += nextException.getTypeName() + ': ' + nextException.getMessage();

            // DMLException has additional details for each data row
            if (nextException instanceOf DMLException) {
               try {
                  DMLException dmlException = (DMLException) nextException;
                  Integer rowCount = dmlException.getNumDml();
                  dmlInfo = '--- DML Information for ' + rowCount.format() + ' rows ---\n';

                  for (Integer i = 0; i<rowCount; i++) {
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
   private static String getDmlFieldList(DMLException e, Integer i) {
      String result = null;
      Schema.sObjectField[] fields = e.getDmlFields(i);
      for (Schema.sObjectField field : fields) {
         if (result != null) result += ', ';
         result += field.getDescribe().getName();
      }

      return result;
   }

   private static void write(AH_UDC_Log__c log, Boolean skipSendingEmail) {
      if (Test.isRunningTest()) {
         System.debug('TEST CLASS LogText: ' + log.LogText__c);
         System.debug('TEST CLASS FunctionalArea: ' + log.FunctionalArea__c);
         System.debug('TEST CLASS Source: ' + log.Source__c);

         if (log.FunctionalArea__c == FORCE_WRITE_LOG_EXCEPTION_FUNCTIONAL_AREA) integer i = 1 / 0;
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
      if (m_queuedLogs) {
         m_queuedLogRecords.add(log);
      } else {
         AH_UDC_SystemContext.CreateObject(log);
      }

      if (!skipSendingEmail) {
         Boolean EmailDeliverabilityEnabled = true;
         try {
             Messaging.reserveSingleEmailCapacity(1);
             Messaging.reserveMassEmailCapacity(1);
         } catch (System.NoAccessException e) {
             EmailDeliverabilityEnabled = false;
         }
         Debug('EmailDeliverabilityEnabled: ' + EmailDeliverabilityEnabled);

         if (EmailDeliverabilityEnabled)
         {
            // Check the settings to see if this Log message should be emailed
            if ((log.Level__c.equalsIgnoreCase(LogLevel_ERROR) && AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS, false))
                ||
            (log.Level__c.equalsIgnoreCase(LogLevel_WARN) && AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS, false))
                ||
            (log.Level__c.equalsIgnoreCase(LogLevel_EXC) && AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, false))) {
               EmailLog(AH_UDC_ConfigHelper.GetString(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_RECIPIENTS, ''), log);
            }
         }
      }
   }

   // Called to have all queued AH_UDC_Log__c records be written to the database
   public static void writeQueuedLogs() {

      // If there are no queued log records, then nothing to do
      if (m_queuedLogRecords == null || m_queuedLogRecords.size() == 0) {
         return;
      }

      Debug('Number of log records queued: ' + m_queuedLogRecords.size());

      AH_UDC_SystemContext.CreateObjects(m_queuedLogRecords);

      // Determine which log levels are configured to be emailed
      Set<String> emailMsgTypes = new Set<String> ();
      if (AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS, false)) {
         emailMsgTypes.add(LogLevel_ERROR);
      }
      if (AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS, false)) {
         emailMsgTypes.add(LogLevel_WARN);
      }
      if (AH_UDC_ConfigHelper.GetBoolean(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, false)) {
         emailMsgTypes.add(LogLevel_EXC);
      }

      AH_UDC_LogHelper.debug('## These log types are configured to be emailed: ' + emailMsgTypes);

      // Send one email for all queued log messages whose Level is set to be emailed
      String subject = '';
      String msg = '';
      for (AH_UDC_Log__c log : m_queuedLogRecords) {
         if (emailMsgTypes.contains(log.Level__c)) {
            if (String.isBlank(subject)) {
               subject = getEmailSubject(log);
            }
            msg += '\r\n------------------\r\n' + getEmailBody(log);
         }
      }

      // if there were any log messages that are set to be mailed, SUBJECT will not be blank
      if (!String.isBlank(subject)) {
         String result = EmailMessage(AH_UDC_ConfigHelper.GetString(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_RECIPIENTS, ''),
                                      subject, msg);
         if (String.isNotBlank(result)) {
            AH_UDC_Log__c logEmailWarning = BuildLogRecord(LogLevel_WARN, 'AH_UDC_LogHelper', getClassAndMethodName(new DmlException()),
                                                           result, null, null, null);
            if (logEmailWarning != null) {
               write(logEmailWarning, true);
            }
         }
      }

      clearQueuedLogs();
   }

   public static void clearQueuedLogs() {
      // Clear these records that have already been written, so that they will not be written
      // again in the calling code has more logging to do
      m_queuedLogRecords.clear();
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

   // Returns an empty string if successful, or a string containing the reason for failure it emails failed to be sent
   private static String EmailMessage(string notifyEmails, string subject, string message) {
      // If no recipients, then nothing to do
      if (String.isBlank(notifyEmails)) return '';

      if (Limits.getEmailInvocations() >= Limits.getLimitEmailInvocations()) {
         return 'Maximum number of user emails sent (' + Limits.getLimitEmailInvocations() + ') has been reached. User cannot send another email until the time-limited count has rolled over';
      }

      List<String> ccEmails = new List<String> ();

      // If user to email is not found, use the first active user with administrator profile
      String toEmail = notifyEmails;

      if (String.isBlank(toEmail)) {
         List<User> listUsers = [SELECT Email FROM User WHERE Profile.Name = :AH_UDC_Constants.PROFILE_DEFAULT_NAME_SYSTEM_ADMINISTRATOR AND IsActive = true LIMIT 1];
         toEmail = listUsers[0].Email;
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
         return 'Emailing of Log Message failed to send correctly: ' + emailFailures;
      }

      return '';
   }

   // Sends the LogEvent details to the email addresses listed in the comma-separated string:
   // 
   //    notifyEmails - Comma-separated list of email addresses to send this email to
   //    log          - Log record containing the details to mail to the addressees
   //    
   private static void EmailLog(string notifyEmails, AH_UDC_Log__c log) {
      String result = EmailMessage(notifyEmails, getEmailSubject(log), getEmailBody(log));

      if (String.isNotBlank(result)) {
         AH_UDC_Log__c logWarning = BuildLogRecord(LogLevel_WARN, 'AH_UDC_LogHelper', getClassAndMethodName(new DmlException()),
                                                   result, null, null, null);
         if (logWarning != null) {
            write(logWarning, true);
         }
      }
   }

   public static String getEmailSubject(AH_UDC_Log__c log) {
      String subject = UserInfo.getOrganizationName() + ': '
      + log.Level__c + ': '
      + log.FunctionalArea__c + ': '
      + log.Source__c + ': ';
      + log.LogText__c.left(80);

      return subject;
   }

   public static String getEmailBody(AH_UDC_Log__c log) {
      String body = 'Log: ' + log.LogDate__c + ' GMT'
      + '\nLevel: ' + log.Level__c
      + '\nFunctional Area: ' + log.FunctionalArea__c
      + '\nSource: ' + log.Source__c
      + '\nOrganization Name: ' + UserInfo.getOrganizationName()
      + '\nOrganizationId: ' + UserInfo.getOrganizationId()
      + '\nUser Name: ' + UserInfo.getName()
      + '\n\n' + log.LogText__c;

      return body;
   }

   // Retrieves the log__c records created during execution of a test method, also
   // writing them to the debug log for easy reference when troubleshooting tests
   public static List<AH_UDC_Log__c> GetTestMethodLogs(string classAndMethodName) {
      // If this is not called by a test method, do not return any log__c records
      if (!Test.isRunningTest()) return new List<AH_UDC_Log__c> ();

      System.debug('Logs for ' + classAndMethodName + ':');

      List<AH_UDC_Log__c> logs = AH_UDC_SystemContext.query('SELECT LogText__c FROM AH_UDC_Log__c WHERE Level__c not in (\'' + LogLevel_TRACE + '\', \'' + LogLevel_DEBUG + '\')  LIMIT 20');
      // Log #0 will always be: AH_UDC_TestClassHelper.CONFIG_SETTINGS_INITIALIZED
      Integer i = 0;
      for (AH_UDC_Log__c l : logs) {
         System.debug('Actual Log[' + i++ + ']: ' + l.LogText__c);
      }

      return logs;
   }

   public class AH_UDC_LogException extends Exception { }

}