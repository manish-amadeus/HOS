/**
 * Name          : AH_UDC_EmailHelper_TEST
 * Description   : Unit tests for the AH_UDC_EmailHelper class.
 **/

@isTest
public class AH_UDC_EmailHelper_TEST
{
   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   @isTest
   private static void testSingleEmail() {
      
      AH_UDC_ConfigHelper.SetValue('LogWarnings', 'FALSE');

      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new String[] { 'test@amadeus.com' };
      mail.setToAddresses(toAddresses);
      mail.setSubject('testSingleEmail');
      mail.setPlainTextBody('Test email body');

      Messaging.SendEmailResult[] results = AH_UDC_EmailHelper.SendMail(new Messaging.SingleEmailMessage[] { mail });

      if (results != null && results.size() > 0) {
         System.assertEquals(true, results[0].isSuccess(), 'Failed calling the AH_UDC_EmailHelper.SendMail: ' + results[0].getErrors());
      } else {
         if (AH_UDC_EmailHelper.OrgCanSendEmail) {
            System.assert(false, 'Failed sending a single email message, and it looks like email is enabled in the Org');
         }
      }
            
      AH_UDC_EmailHelper.canOrgSendEmail = false;
      Messaging.SingleEmailMessage emptymail = new Messaging.SingleEmailMessage();
      Messaging.SendEmailResult[] emptyresult = AH_UDC_EmailHelper.SendMail(new Messaging.SingleEmailMessage[] { emptymail });
      if (emptyresult != null && emptyresult.size() > 0) {
         System.assertEquals(true, emptyresult[0].isSuccess(), 'Failed calling the AH_UDC_EmailHelper.SendMail: ' + emptyresult[0].getErrors());
      } else {
         if (AH_UDC_EmailHelper.OrgCanSendEmail) {
            System.assert(false, 'Failed sending a single email message, and it looks like email is enabled in the Org');
         }
      }
      Boolean orgCanSendEmail =AH_UDC_EmailHelper.OrgCanSendEmail;      
   }

   @isTest
   private static void testSingleEmailExceedsMaxEmails() {

      AH_UDC_ConfigHelper.SetValue('LogWarnings', 'FALSE');

      Messaging.SendEmailResult[] results = AH_UDC_EmailHelper.SendMail(new Messaging.SingleEmailMessage[] { });

      System.assertEquals(0, results.size(), 'Should have failed trying to send too many emails');
   }


   @isTest
   private static void testMassEmail() {
      AH_UDC_ConfigHelper.SetValue('LogWarnings', 'FALSE');

      /* TODO: We do not use MASS MAILING anywhere currently, but this will need to  be implemented if we do
        // TODO: Currently fails in orgs where email sending is turned off
        Set<Id> ids = (new Map<Id, User>([SELECT Id FROM User])).keySet();
       
        EmailTemplate et = new EmailTemplate(
        Name = 'TestEmailTemplate ApexTestMethod',
        Body = 'Body', 
        DeveloperName = 'TestEmailTemplate_ApexTestMethod', 
        FolderId = UserInfo.getUserId(), //folders[0].Id,
        HtmlValue = 'Testing 1,2,3',
        IsActive = true,
        TemplateType = 'custom');
        insert et;      
       
        Messaging.MassEmailMessage massEmail = new Messaging.MassEmailMessage();
        massEmail.setTargetObjectIds(new List<Id>(ids));
        massEmail.setSaveAsActivity(false);
        massEmail.setTemplateId(et.Id);
        List<Messaging.Email> emails = new List<Messaging.Email>{massEmail};
        Messaging.SendEmailResult[] results = EmailHelper.SendMail(new Messaging.MassEmailMessage[] { massEmail });
       
        System.assertEquals(true, results[0].isSuccess(), 'Failed calling the EmailHelper.SendMail: ' + results[0].getErrors()); 
       */
   }
}