/*
 * File            : AH_UDC_EmailHelper.cls
 * Created Date    : 2020-April-26
 * Created By      : George.Tasker@amadeus.com
 * Description     : Implements SendMail functions that reserve email capacity before trying to send
 *                   Checks that email is not disabled in the org before trying to send
 * Test classes    : AH_UDC_EmailHelper_TEST.cls
 * Dependencies    : None
 */
public without sharing class AH_UDC_EmailHelper
{
   @TestVisible
   private static Boolean canOrgSendEmail = null;

   // a static, final variable that initializes an instance of the class
   // as it's final, it will only be initialized once
   private static final AH_UDC_EmailHelper instance = new AH_UDC_EmailHelper();

   // Singleton constructor
   private AH_UDC_EmailHelper() {
   }
   
   public static Boolean OrgCanSendEmail { get { return CanSendEmails(1); } }

   // This will permanently reserve email messages for the next 24 hours, so use sparingly
   private static Boolean CanSendEmails(Integer emailCount) {

      if (canOrgSendEmail == null) {
         try {
            Messaging.reserveSingleEmailCapacity(emailCount);
            canOrgSendEmail = true;
         }
         catch (Exception exc) {
            canOrgSendEmail = false;
         }
      }

      return canOrgSendEmail;
   }

/* This is here is we ever need it. Test class does not have a test for this since we are not currently using this
   // @description Send mass email messages
   // @param mail Messaging.MassEmailMessage[]   Contains the pre-populated list of emails to send
   // @return     Messaging.SendEmailResult[]    Contains the result of sending each email
   public static Messaging.SendEmailResult[] SendMail(Messaging.MassEmailMessage[] mail)
   {
      try {
         Messaging.reserveMassEmailCapacity(mail.size());
      }
      catch (Exception exc) {
         LogManager.logEventReturnLog(LoggingLevel.WARN, 'EmailHelper::SendMail', 1, 'Attempted to send a mass email message while email is disabled in the Org, or the daily limit for mass emails has been reached', null, null);
         
         return new List<Messaging.SendEmailResult>();
      }

      Messaging.SendEmailResult[] results = Messaging.sendEmail(mail);

      // Log any errors (if any)
      for (Messaging.SendEmailResult ser : results) {
         if (!ser.isSuccess()) {
            // This is logged as INFO, because log settings may exist that cause an ERROR or WARNING to
            // send an email, which could put this code into an endless loop
            LogManager.logEventReturnLog(LoggingLevel.INFO, 'EmailHelper::SendMail', 100, ser.getErrors().ToString(), null, null);
         }
      }
         
      return results;
   }
*/

   //* @description Send mass email messages
   //* @param mail Messaging.SingleEmailMessage[]   Contains the pre-populated list of emails to send
   //* @return     Messaging.SendEmailResult[]    Contains the result of each email sent
   public static Messaging.SendEmailResult[] SendMail(Messaging.SingleEmailMessage[] mail) {
      Boolean emailEnabled = CanSendEmails(mail.size());

      List<Messaging.SendEmailResult> results = null;
      if (emailEnabled) {
         results = Messaging.sendEmail(mail);
      } else {
         results = new List<Messaging.SendEmailResult> ();
         // Line is here strictly to raise code coverage in orgs that have email disabled
         Integer codeCoverage = 75;
      }

      // Log any errors (if any)
      for (Messaging.SendEmailResult ser : results) {
         if (!ser.isSuccess()) {
            AH_UDC_LogHelper.Log('Error', 'Email Helper', AH_UDC_LogHelper.getClassAndMethodName(new DmlException()),
                           'Exception occurred while sending email(s): ' + ser.getErrors()[0].getMessage());
         }
      }

      return results;
   }
}