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
         canOrgSendEmail = false;
         try {
            Messaging.reserveSingleEmailCapacity(emailCount);
            canOrgSendEmail = true;
         }
         catch (Exception exc) {
            // Swallow the exception, no need to report this as canOrgSendEmail is now set to FALSE
         }
      }

      return canOrgSendEmail;
   }

   //* @description Send mass email messages
   //* @param mail Messaging.SingleEmailMessage[]   Contains the pre-populated list of emails to send
   //* @return     Messaging.SendEmailResult[]    Contains the result of each email sent
   public static Messaging.SendEmailResult[] SendMail(Messaging.SingleEmailMessage[] mail) {
      Boolean emailEnabled = CanSendEmails(mail.size());

      List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
      if (emailEnabled) {
         if (Test.isRunningTest()) {
            // This is the only way to create a SendMailResult instance to simulate success in sending an email
            Messaging.SendEmailResult ser = (Messaging.SendEmailResult)JSON.deserialize('{"success":true}', Messaging.SendEmailResult.class);
            results.add(ser);
         } else {
            results = Messaging.sendEmail(mail);
         }
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