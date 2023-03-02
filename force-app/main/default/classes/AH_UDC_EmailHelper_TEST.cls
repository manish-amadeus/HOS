<<<<<<< HEAD
<<<<<<< HEAD
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
=======
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
   private static void testMultipleEmails() {
      
      AH_UDC_ConfigHelper.SetValue('LogWarnings', 'FALSE');

      Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
      String[] toAddresses1 = new String[] { 'test1@amadeus.com' };
      mail1.setToAddresses(toAddresses1);
      mail1.setSubject('testSingleEmail1');
      mail1.setPlainTextBody('Test email body 1');

      Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
      String[] toAddresses2 = new String[] { 'test2@amadeus.com' };
      mail2.setToAddresses(toAddresses2);
      mail2.setSubject('testSingleEmail2');
      mail2.setPlainTextBody('Test email body 2');

      Messaging.SendEmailResult[] results = AH_UDC_EmailHelper.SendMail(new Messaging.SingleEmailMessage[] { mail1, mail2 });

      if (results != null && results.size() == 2) {
         System.assertEquals(true, results[0].isSuccess(), 'Failed calling the AH_UDC_EmailHelper.SendMail1: ' + results[0].getErrors());
         System.assertEquals(false, results[1].isSuccess(), 'Email 2 should be failed to send');
         Integer intCount = [SELECT COUNT()
                              FROM AH_UDC_Log__c
                              WHERE Level__c = 'Error'
                              AND FunctionalArea__c = 'Email Helper'
                              AND Source__c = 'AH_UDC_EmailHelper.SendMail'
                              AND Message__c LIKE '%Test error in sending email%'];
         System.assertEquals(1, intCount, 'There must be an error log for second email');
      } else {
         if (AH_UDC_EmailHelper.OrgCanSendEmail) {
            System.assert(false, 'Failed sending multiple email messages, and it looks like email is enabled in the Org');
         }
      }      
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
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
   private static void testMultipleEmails() {
      
      AH_UDC_ConfigHelper.SetValue('LogWarnings', 'FALSE');

      Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
      String[] toAddresses1 = new String[] { 'test1@amadeus.com' };
      mail1.setToAddresses(toAddresses1);
      mail1.setSubject('testSingleEmail1');
      mail1.setPlainTextBody('Test email body 1');

      Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
      String[] toAddresses2 = new String[] { 'test2@amadeus.com' };
      mail2.setToAddresses(toAddresses2);
      mail2.setSubject('testSingleEmail2');
      mail2.setPlainTextBody('Test email body 2');

      Messaging.SendEmailResult[] results = AH_UDC_EmailHelper.SendMail(new Messaging.SingleEmailMessage[] { mail1, mail2 });

      if (results != null && results.size() == 2) {
         System.assertEquals(true, results[0].isSuccess(), 'Failed calling the AH_UDC_EmailHelper.SendMail1: ' + results[0].getErrors());
         System.assertEquals(false, results[1].isSuccess(), 'Email 2 should be failed to send');
         Integer intCount = [SELECT COUNT()
                              FROM AH_UDC_Log__c
                              WHERE Level__c = 'Error'
                              AND FunctionalArea__c = 'Email Helper'
                              AND Source__c = 'AH_UDC_EmailHelper.SendMail'
                              AND Message__c LIKE '%Test error in sending email%'];
         System.assertEquals(1, intCount, 'There must be an error log for second email');
      } else {
         if (AH_UDC_EmailHelper.OrgCanSendEmail) {
            System.assert(false, 'Failed sending multiple email messages, and it looks like email is enabled in the Org');
         }
      }      
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}