/**
 * Name          : AH_UDC_FormTriggerHelper_Test
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is a tet class for AH_UDC_FormTriggerHelper
 * Dependencies  : AH_UDC_FormTriggerHelper
 **/

@isTest
private class AH_UDC_FormTriggerHelper_Test {
   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   @isTest
   private static void testInsertSteps() {
      Test.startTest();
      //Create Form
      AH_UDC_Form__c form1 = new AH_UDC_Form__c(
                                                Name = 'TestForm1',
                                                FormAssemblyId__c = '123'
      );
      insert form1;

      Boolean InsertException = false;
      try {
         //Create Form with dupe name
         AH_UDC_Form__c form2 = new AH_UDC_Form__c(
                                                   Name = 'TestForm1',
                                                   FormAssemblyId__c = '456'
         );
         insert form2;
      }
      catch(exception exc) {
         InsertException = true;
      }

      Test.stopTest();
      List<AH_UDC_Form__c> forms = [select id, name from AH_UDC_Form__c];
      System.assertEquals(true, InsertException, 'Expected Insert Dupe Name Exception');
      System.assertEquals(1, forms.size(), 'Expected Only 1 Form');
   }

   @isTest
   private static void testInsertMultipleSteps() {
      Test.startTest();

      Boolean InsertException = false;
      try {
         List<AH_UDC_Form__c> newForms = new List<AH_UDC_Form__c> ();
         //Create Form
         AH_UDC_Form__c form1 = new AH_UDC_Form__c(
                                                   Name = 'TestForm1',
                                                   FormAssemblyId__c = '123'
         );
         newForms.add(form1);

         //Create Form 
         AH_UDC_Form__c form2 = new AH_UDC_Form__c(
                                                   Name = 'TestForm1',
                                                   FormAssemblyId__c = '456'
         );
         newForms.add(form2);

         insert newForms;
      }
      catch(exception exc) {
         InsertException = true;
      }

      Test.stopTest();
      List<AH_UDC_Form__c> forms = [select id, name from AH_UDC_Form__c];
      System.assertEquals(true, InsertException, 'Expected Insert Dupe Name Exception');
      System.assertEquals(0, forms.size(), 'Expected No Forms');
   }

   @isTest
   private static void testUpdateStep() {
      Test.startTest();
      //Create Form
      AH_UDC_Form__c form1 = new AH_UDC_Form__c(
                                                Name = 'TestForm1',
                                                FormAssemblyId__c = '123'
      );
      insert form1;

      //Create Form
      AH_UDC_Form__c form2 = new AH_UDC_Form__c(
                                                Name = 'TestForm2',
                                                FormAssemblyId__c = '456'
      );
      insert form2;

      Boolean UpdateException = false;
      try {
         form2.name = 'TestForm1';
         update form2;
      }
      catch(exception exc) {
         UpdateException = true;
      }

      Test.stopTest();
      List<AH_UDC_Form__c> forms = [select id, name from AH_UDC_Form__c];
      System.assertEquals(true, UpdateException, 'Expected Update Dupe Name Exception');
   }

   @isTest
   private static void testDuplicateException() {
      Test.startTest();

      try {
         //Create Form
         AH_UDC_Form__c form1 = new AH_UDC_Form__c(
                                                   Name = 'TestDupeException',
                                                   FormAssemblyId__c = '123'
         );
         insert form1;

         AH_UDC_Form__c form2 = new AH_UDC_Form__c(
                                                   Name = 'TestDupeException',
                                                   FormAssemblyId__c = '123'
         );
         insert form2;
         System.assert(false, 'A duplicate exception should have occurred');
      }
      catch(exception exc) {
         System.assert(exc.getMessage().contains('Form Name must be unique'), 'Expected an exception about duplicates, but a different excpetion occurred: ' + exc.getMessage());
      }

      Test.stopTest();
      
      List<AH_UDC_Form__c> forms = [select id, Name from AH_UDC_Form__c];
      System.assertEquals(1, forms.size(), 'Only one of the duplicate named forms should have been saved');
   }
}