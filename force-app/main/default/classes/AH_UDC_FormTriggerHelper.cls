/**
 * Name          : AH_UDC_FormTriggerHelper
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is the single entry point for processing triggers on object AH_UDC_Form
 * Dependencies  : 
 **/

public with sharing class AH_UDC_FormTriggerHelper {
   @TestVisible private static Boolean IsException = false;
   public static void onTrigger() {
      //This logic should execute once and not occur recursively if other triggers make changes to the records
      try
      {

         if (Test.isRunningTest() && IsException == true) {
            AH_UDC_LogHelper.Debug('In AH_UDC_FormTriggerHelper - In Exception');
            integer i = 1 / 0;
         }

         if (Trigger.isBefore && Trigger.isDelete)
         {
            List<Id> setFormId = new List<Id> ();
            for (SObject sObj : Trigger.old)
            {
               AH_UDC_Form__c form = (AH_UDC_Form__c) sObj;
               setFormId.add(form.id);
            }
            List<Id> formIdswithStep = new List<Id> ();
            AggregateResult[] groupedResults = [SELECT Form__c, count(id) totalForm
                                                FROM AH_UDC_WorkbookStep__c
                                                WHERE Form__c IN :setFormId
                                                GROUP BY Form__c];

            for (AggregateResult ar : groupedResults) {
               Integer totalForm = (Integer) ar.get('totalForm');
               Id newFormId = (Id) ar.get('Form__c');
               if (totalForm > 0) formIdswithStep.add(newFormId);
            }
            if (formIdswithStep.size() > 0)
            {
               for (SObject obj : Trigger.old) {
                  AH_UDC_Form__c objForm = (AH_UDC_Form__c) obj;
                  if (formIdswithStep.contains(objForm.Id)) {
                     obj.addError(Label.AH_UDC_FormTriggerDelete_Error);
                     break;
                  }
               }
            }
         }

         else if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete))
         {
            //Build dictionary of allowed extensions
            Set<String> udcAllowedExtensions = new Set<String>();
            for(string ext : AH_UDC_ConfigHelper.GetString('AH_UDC_FileUploadAllowedExtensions', '').split(',')){
               udcAllowedExtensions.add(ext.trim());
            }
            //Get max allowed file size
            Decimal udcFileUploadMaximumSizeInMB = Decimal.valueOf(AH_UDC_ConfigHelper.GetString('AH_UDC_FileUploadMaximumSizeInMB',AH_UDC_Constants.FILE_UPLOAD_MAXIMUM_SIZE_IN_MB_DEFAULT));
            for (SObject sObj : Trigger.new){
               AH_UDC_Form__c formNew = (AH_UDC_Form__c)sObj;
               //Check Number of Files
               if(formNew.NumberOfFiles__c != null){
                  formNew.NumberOfFiles__c = formNew.NumberOfFiles__c.round(System.RoundingMode.HALF_UP);
                  if(formNew.NumberOfFiles__c < 1) sObj.addError(System.Label.AH_UDC_FormNumberOfFilesLessThanOneError);
               }
               //Check Max File Size
               if(formNew.MaxIndividualFileSizeMB__c != null){
                  formNew.MaxIndividualFileSizeMB__c = formNew.MaxIndividualFileSizeMB__c.round(System.RoundingMode.HALF_UP);
                  if(formNew.MaxIndividualFileSizeMB__c > udcFileUploadMaximumSizeInMB) sObj.addError(System.Label.AH_UDC_FormMaxFileSizeError.replace('{MAX}',String.valueOf(udcFileUploadMaximumSizeInMB)));
                  if(formNew.MaxIndividualFileSizeMB__c < 1) sObj.addError(System.Label.AH_UDC_FormMaxFileSizeLessThanOneError);
               }
               //Check Pixels for negative values
               if(formNew.HeightMinimumPixels__c != null) formNew.HeightMinimumPixels__c=formNew.HeightMinimumPixels__c.round(System.RoundingMode.HALF_UP);
               if(formNew.HeightMaximumPixels__c != null) formNew.HeightMaximumPixels__c=formNew.HeightMaximumPixels__c.round(System.RoundingMode.HALF_UP);
               if(formNew.WidthMinimumPixels__c != null) formNew.WidthMinimumPixels__c=formNew.WidthMinimumPixels__c.round(System.RoundingMode.HALF_UP);
               if(formNew.WidthMaximumPixels__c != null) formNew.WidthMaximumPixels__c=formNew.WidthMaximumPixels__c.round(System.RoundingMode.HALF_UP);
               if(formNew.HeightMinimumPixels__c != null && formNew.HeightMinimumPixels__c < 1) sObj.addError(System.Label.AH_UDC_FormHeightMinimumError);
               if(formNew.HeightMaximumPixels__c != null && formNew.HeightMaximumPixels__c < 1) sObj.addError(System.Label.AH_UDC_FormHeightMaximumError);
               if(formNew.WidthMinimumPixels__c != null && formNew.WidthMinimumPixels__c < 1) sObj.addError(System.Label.AH_UDC_FormWidthMinimumError);
               if(formNew.WidthMaximumPixels__c != null && formNew.WidthMaximumPixels__c < 1) sObj.addError(System.Label.AH_UDC_FormWidthMaximumError);
               //Verify max's are > mins
               if(formNew.HeightMinimumPixels__c != null && formNew.HeightMaximumPixels__c != null && formNew.HeightMaximumPixels__c <= formNew.HeightMinimumPixels__c) sObj.addError(System.Label.AH_UDC_FormHeightMaximumError);
               if(formNew.WidthMinimumPixels__c != null && formNew.WidthMaximumPixels__c != null && formNew.WidthMaximumPixels__c <= formNew.WidthMinimumPixels__c) sObj.addError(System.Label.AH_UDC_FormWidthMaximumError);
               //Check Extensions
               if (String.isNotEmpty(formNew.AllowedExtensions__c))
               {
                  Set<String> stepAllowedExtensions = new Set<String>();
                  for(string ext : formNew.AllowedExtensions__c.split(',',-1)){
                     string extTrim = ext.trim();
                     if (String.isEmpty(extTrim) || !udcAllowedExtensions.contains(extTrim))
                     {
                        sObj.addError(System.Label.AH_UDC_FormExtensionNotAllowed.replace('{EXT}',extTrim).replace('{ALLOWED}',AH_UDC_ConfigHelper.GetString('AH_UDC_FileUploadAllowedExtensions', '')));
                     }
                  }
               }
            }
         }

         else if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete))
         {
            //Get existing forms
            List<AH_UDC_Form__c> forms = [SELECT Id, name, RecordTypeId, FormAssemblyId__c FROM AH_UDC_Form__c LIMIT 50000];

            Set<Id> dupeNameIds = new Set<Id> ();
            Set<Id> dupeFAIds = new Set<Id> ();
            List<string> newFAIds = new List<string> ();
            List<String> newNames = new List<string> ();
            List<Id> upsertedIds = new List<Id> ();
            Id formAssemblyRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();

            for (SObject sObj : Trigger.new)
            {
               AH_UDC_Form__c newform = (AH_UDC_Form__c) sObj;
               AH_UDC_Form__c oldForm;
               if (Trigger.isUpdate) oldForm = (AH_UDC_Form__c) Trigger.oldMap.get(newForm.Id);
               AH_UDC_LogHelper.Debug('FormTriggerHelper New Form Id: ' + newform.id);
               upsertedIds.add(newform.id);
               if (Trigger.isInsert || (Trigger.isUpdate && newForm.Name != oldForm.Name))
               {
                  string formName = newform.name.toUpperCase();
                  if (newNames.contains(formName))
                  {
                     dupeNameIds.add(newform.id);
                  }
                  else {
                     newNames.add(formName);
                  }
               }
               if ((newform.RecordTypeId == formAssemblyRecordTypeId) || (Trigger.isUpdate && newForm.FormAssemblyId__c != oldForm.FormAssemblyId__c))
               {
                  if (newFAIds.contains(newform.FormAssemblyId__c))
                  {
                     dupeFAIds.add(newform.id); // Add id of duplicate formassemblyid
                  }
                  else {
                     newFAIds.add(newform.FormAssemblyId__c);
                  }
               }
            }
            //Build list of uppercase existing names
            Set<String> existingNames = new Set<string> ();
            Set<String> existingFAIds = new Set<String> ();
            for (AH_UDC_Form__c form : forms)
            {
               string formName = form.name.toUpperCase();
               if (newNames.contains(formName) && !upsertedIds.contains(form.id))
               {
                  existingNames.add(formName);
               }
               //Add Form Assembly form in the list
               if (form.RecordTypeId == formAssemblyRecordTypeId && !upsertedIds.contains(form.id))
               {
                  existingFAIds.add(form.FormAssemblyId__c);
               }
            }

            //Check if records have a dupe name for all record type  & formassemblyId for formassembly type form 
            for (SObject sObj : Trigger.new)
            {
               AH_UDC_Form__c form = (AH_UDC_Form__c) sObj;
               string formName = form.name.toUpperCase();

               if (existingNames.contains(formName)) dupeNameIds.add(form.id);
               if (existingFAIds.contains(form.FormAssemblyId__c)) dupeFAIds.add(form.id);
            }


            //Add an error for each record that is a dupe name
            for (SObject sObj : Trigger.new)
            {
               AH_UDC_Form__c form = (AH_UDC_Form__c) sObj;
               if (dupeNameIds.size() > 0 && dupeNameIds.contains(form.id))
               {
                  AH_UDC_LogHelper.Debug('Duplicate Form Name: ' + form.name);
                  sObj.addError(System.Label.AH_UDC_DuplicateFormNameError); // prevent upsert
               }

               //Check that if the Record Type is "Form Assembly" that FormAssemblyId__c is not null and unique
               if (form.RecordTypeId == formAssemblyRecordTypeId)
               {
                  if (form.FormAssemblyId__c == null || dupeFAIds.contains(form.id))
                  {
                     AH_UDC_LogHelper.Debug('Duplicate FormAssemblyId__c: ' + form.FormAssemblyId__c);
                     sObj.addError(System.Label.AH_UDC_FormAssemblyIdError);
                  }
               }
            }
         }
      }
      catch(exception exc) {
         System.Debug(AH_UDC_LogHelper.getClassAndMethodName(new DmlException())
                      + ': Exception occurred: ' + exc.getMessage() + ' | ' + exc.getStackTraceString());
         for (SObject sObj : (Trigger.new != null ? Trigger.new : Trigger.old))
         {
            sObj.addError(System.Label.AH_UDC_FormTriggerHelper_ExceptionOccurred); // prevent upsert
         }
      }
   }
}