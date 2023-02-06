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
}