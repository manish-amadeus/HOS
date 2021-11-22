/**
 * Name          : AH_UDC_FormTriggerHelper
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is the single entry point for processing triggers on object AH_UDC_WorkbookStep
 * Dependencies  : 
 **/

public with sharing class AH_UDC_FormTriggerHelper {
   public static void onTrigger() {
      //This logic should execute once and not occur recursively if other triggers make changes to the records
      try
      {       
         if (Test.isRunningTest() && ((AH_UDC_Form__c) Trigger.new[0]).name == 'TestException') integer i = 1/0;

        
         //TODO: code for undelete

         if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
         {
            List<Id> dupeNameIds = new List<Id>();
            List<String> newNames = new List<string>();
            List<Id> upsertedIds = new List<Id>();

            //Determine if multiple records are being upsert and they have new name duplicates
            for (SObject sObj: Trigger.new)
            {
               AH_UDC_Form__c form = (AH_UDC_Form__c) sObj;
               upsertedIds.add(form.id);
               string formName = form.name.toUpperCase();
               if(newNames.contains(formName))
               {
                  if (!dupeNameIds.contains(form.Id)) dupeNameIds.add(form.id);
               }
               else
               {
                  newNames.add(formName);
               }
            }

            //Get existing name ignoring records that are being updated
            List<AH_UDC_Form__c> forms = [select id, name from AH_UDC_Form__c where Name in :newNames];
            List<String> existingNames = new List<string>();
            for(AH_UDC_Form__c form : forms)
            {
               if (!upsertedIds.contains(form.id))
               {
                  string formName = form.name.toUpperCase();
                  if(!existingNames.contains(formName)) existingNames.add(formName);
               }
            }

            //Check if records have a dupe name
            for (SObject sObj: Trigger.new)
            {
               AH_UDC_Form__c form = (AH_UDC_Form__c) sObj;
               string formName = form.name.toUpperCase();
               if (existingNames.contains(formName) && !dupeNameIds.contains(form.id)) dupeNameIds.add(form.id);
            }

            //Add an error for each record that is a dupe name
            for (SObject sObj: Trigger.new)
            {
               AH_UDC_Form__c form = (AH_UDC_Form__c) sObj;
               if (dupeNameIds.contains(form.id)) {
                  AH_UDC_LogHelper.Debug('Duplicate Form Name: ' + form.name);
                  form.name.addError(System.Label.AH_UDC_DuplicateFormNameError); // prevent upsert
               }
            }
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_FormTriggerHelper','onTrigger',
                              'An exception occurred: ' + exc.getMessage(),
                              exc, null, null);
         for (SObject sObj: Trigger.new)
         {
            //sObj.addError(System.Label.AH_UDC_FormTriggerHelper_ExceptionOccurred); // prevent upsert
         }
      }
   }
}