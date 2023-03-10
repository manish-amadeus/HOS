/***********************************************************************************************
  Name            : AH_UDC_CloneWorkbook
  Author          : Tushar Gupta
  Created Date    : 25-Jan-2021
  User Story ID   : 574902
  Description     : Controller class for Workbook clone of UDC
  Change History  :
  1. 590046 - Refactoring Code - Changed by Ravi Shah on 5-Feb-2021 
  2. 594855 - Refactoring Code - Changed by Tushar Gupta on 23-Feb-2021
 ************************************************************************************************/
public with sharing class AH_UDC_CloneWorkbook {
   //Declare properties
   public AH_UDC_Workbook__c Workbook { get; set; }
   public string WorkbookName { get; set; }
   public Id NewWorkbookId { get; set; }
   public Boolean IsWorkbookNameValid { get; set; }
   public Boolean IsErrorOccurred { get; set; }
   public String WorkbookId { get; set; }
   private Integer WorkbookCount { get; set; }

   //Only Workbooks and not Workbooks SENT can be cloned
   private Id recordTypeIdWorkbook = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();

   @TestVisible private string LogFunctionalArea = 'AH_UDC_CloneWorkbook'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_Log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages.size() > 0;
      }
   }

   //Initialize constructor
   public AH_UDC_CloneWorkbook(ApexPages.StandardController controller) {
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;
         //Set default value as true
         IsWorkbookNameValid = true;
         IsErrorOccurred = false;
         if (String.isBlank(apexpages.currentpage().getparameters().get('id'))) {
            LogException('Constructor', 'Workbook ID is blank in query string', null, null);
            return;
         }
         WorkbookId = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('id'));

         //Check if logged in user has clone access to the workbook or not
         if (AH_UDC_SharedWithoutSharing.CheckWorkbookReadUserAccess(WorkbookId)) //Only user with Read Access to the Workbook can clone it
         {
            //check for workbookadmin and systemadmin permissionset. If user won't have that permisssionset assigned than they can't clone workbook
            List<PermissionSetAssignment> lstUserPermission = [SELECT Id FROM PermissionSetAssignment
                                                               WHERE AssigneeId = :UserInfo.getUserId()
                                                               AND
                                                               (PermissionSet.Name = :AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN
                                                               OR
                                                               PermissionSet.Name = :AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN)];
            AH_UDC_LogHelper.Debug('CheckWBCloneAccess => ' + lstUserPermission.size());
            AH_UDC_LogHelper.Debug('CheckWBCloneAccess => UserInfo.getUserId()' + UserInfo.getUserId());
            if (lstUserPermission.size() == 0)
            {
               IsErrorOccurred = true;
               //Display error message on the page for no access rights on workbook for current user 
               if (!ApexPages.hasMessages()) { //If there is already a message added then do not add
                  //Display error message to user
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_UserWorkbookAccessErrorMessage));
               }
               String strErr = 'The user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') tried to access the workbook on which the user do not have clone rights.';
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_WARN, LogFunctionalArea, 'Constructor', strErr, null, null, null);
               return;
            }
         }
         Workbook = [SELECT Name, Enabled__c, Description__c, Product__c, RecordTypeId, RelatedToDocName__c,
                     RelatedTo__c, SentStatus__c, StepsinOrder__c, EmailTemplate__c,
                     Reminder1EmailTemplate__c, Reminder1Days__c, Reminder1Enabled__c,
                     Reminder2EmailTemplate__c, Reminder2Days__c, Reminder2Enabled__c,
                     Reminder3EmailTemplate__c, Reminder3Days__c, Reminder3Enabled__c,
                     Reminder4EmailTemplate__c, Reminder4Days__c, Reminder4Enabled__c
                     FROM AH_UDC_Workbook__c
                     WHERE Id = :WorkbookId
                     and recordtypeid = :recordTypeIdWorkbook];

         if (Workbook == null) {
            LogException('Constructor', 'Ah_UDC_Workbook__c Not Found', null, null);
            return;
         }

         WorkbookName = Workbook.Name;
         Workbook.Name = System.Label.AH_UDC_Clone_Of_Label_Prefix_Text.escapeHtml4() + ' ' + Workbook.Name;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strErrorMessage, ex, null);
      }
      finally {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //Create a clone of selected workbook
   public void CloneWorkbook() {
      //Code for manage the rollback is any error occurred
      Savepoint sp = Database.setSavepoint();
      IsErrorOccurred = false;
      List<AH_UDC_WorkbookStep__c> lstWorkBookStepsList = null;
      List<AH_UDC_WorkbookStep__c> lstWorkbookClone = null;
      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = null;
      Map<Id, Decimal> workbookSortOrderWithStepIdMap = null;
      Map<Decimal, Id> workbookSortOrderWithPreqStepIdMap = null;
      Map<Decimal, Id> workbookSortOrderWithCloneStepIdMap = null;
      Boolean isNeedtoBeUpdate = false;
      try {
         workbookSortOrderWithStepIdMap = new Map<Id, Decimal> (); // store all the old workbook sort order with step id
         workbookSortOrderWithPreqStepIdMap = new Map<Decimal, Id> (); // store only old workbook preq. step id with sort order
         workbookSortOrderWithCloneStepIdMap = new Map<Decimal, Id> ();
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
         if (Workbook != null) {
            //Check input workbook name with existing workbooks (exclude workbook sent)
            WorkbookCount = [SELECT COUNT() FROM AH_UDC_Workbook__c WHERE Name = :Workbook.Name.trim() AND RecordtypeId = :recordTypeIdWorkbook];
            IsWorkbookNameValid = WorkbookCount == 0;

            if (IsWorkbookNameValid) {
               //Clone of workbook
               AH_UDC_Workbook__c objCloneWorkbook = Workbook.clone(false, false, false, false);
               objCloneWorkbook.Enabled__c = false;
               objCloneWorkbook.OwnerId = UserInfo.getUserId();

               //Initialize list to prevent error
               lstWorkbookClone = new List<AH_UDC_WorkbookStep__c> ();
               if (objCloneWorkbook != null) {
                  AH_UDC_Security.CreateObject(objCloneWorkbook); //Insert the new workbook

                  //Assign value in workbook value which use in UI
                  NewWorkbookId = objCloneWorkbook.Id;

                  //Get all the workbook steps of selected workbook
                  lstWorkBookStepsList = [SELECT Id, Name,
                                          Description__c, Enabled__c,
                                          URL__c, Form__c, Help__c, Prerequisite_Step__c,
                                          RecordTypeId, SortOrder__c, Workbook__c
                                          FROM AH_UDC_WorkbookStep__c
                                          WHERE Workbook__c = :Workbook.Id ORDER BY SortOrder__c];

                  if (lstWorkBookStepsList != null && lstWorkBookStepsList.size() > 0) {
                     lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();

                     //Create copy of workbook steps

                     for (AH_UDC_WorkbookStep__c wbs : lstWorkBookStepsList) {
                        AH_UDC_WorkbookStep__c workbookStepClone = wbs.clone(false, false, false, false);
                        workbookStepClone.Workbook__c = NewWorkbookId;

                        //get and map the prereq id 
                        if (String.isNotBlank(wbs.Prerequisite_Step__c)) {
                           workbookSortOrderWithPreqStepIdMap.put(wbs.SortOrder__c, wbs.Prerequisite_Step__c);
                        }
                        //for clone set default prereq to null
                        workbookStepClone.Prerequisite_Step__c = null;
                        lstWorkbookSteps.add(workbookStepClone);
                        workbookSortOrderWithStepIdMap.put(wbs.Id, wbs.SortOrder__c);
                     }
                     if (lstWorkbookSteps != null && lstWorkbookSteps.size() > 0) {
                        //Insert clone workbook steps
                        //While the Workbook Admin's have access to create they do not have access to every field so the clone needs to happen using System Context
                        AH_UDC_SystemContext.CreateObjects(lstWorkbookSteps);

                        AH_UDC_LogHelper.Debug('workbookSortOrderWithPreqStepIdMap' + workbookSortOrderWithPreqStepIdMap);
                        AH_UDC_LogHelper.Debug('workbookSortOrderWithStepIdMap' + workbookSortOrderWithStepIdMap);

                        for (AH_UDC_WorkbookStep__c wbs : lstWorkbookSteps) {
                           workbookSortOrderWithCloneStepIdMap.put(wbs.SortOrder__c, wbs.Id);

                           if (workbookSortOrderWithPreqStepIdMap.get(wbs.SortOrder__c) != null)
                           {
                              if (workbookSortOrderWithStepIdMap.get(workbookSortOrderWithPreqStepIdMap.get(wbs.SortOrder__c)) != null) {

                                 if (workbookSortOrderWithCloneStepIdMap.get(workbookSortOrderWithStepIdMap.get(workbookSortOrderWithPreqStepIdMap.get(wbs.SortOrder__c))) != null) {
                                    //Called once prerequisite step is assigned to Step
                                    wbs.Prerequisite_Step__c = workbookSortOrderWithCloneStepIdMap.get(workbookSortOrderWithStepIdMap.get(workbookSortOrderWithPreqStepIdMap.get(wbs.SortOrder__c)));
                                    isNeedtoBeUpdate = true;
                                 }
                              }
                           }
                        }

                        AH_UDC_LogHelper.Debug('workbookSortOrderWithCloneStepIdMap' + workbookSortOrderWithCloneStepIdMap);
                        //Update the prereq in clone workbook steps
                        if (isNeedtoBeUpdate) {
                           AH_UDC_SystemContext.UpdateObjects(lstWorkbookSteps);
                        }

                        //Clone Responses
                        List<AH_UDC_WorkbookStepResponse__c> lstCloneWBStepResponses = new List<AH_UDC_WorkbookStepResponse__c> ();
                        List<AH_UDC_WorkbookStepResponse__c> lstWBStepResponses = [SELECT WorkbookStep__c, WorkbookStep__r.SortOrder__c, Response__c
                                                                                   FROM AH_UDC_WorkbookStepResponse__c
                                                                                   WHERE WorkbookStep__c in :workbookSortOrderWithStepIdMap.keySet()
                                                                                   AND IsMostRecentResponse__c = true];

                        for (AH_UDC_WorkbookStepResponse__c wbsResponse : lstWBStepResponses) {
                           if (workbookSortOrderWithCloneStepIdMap.containsKey(wbsResponse.WorkbookStep__r.SortOrder__c)) {
                              lstCloneWBStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = workbookSortOrderWithCloneStepIdMap.get(wbsResponse.WorkbookStep__r.SortOrder__c),
                                                                                             Response__c = wbsResponse.Response__c));
                           }
                        }

                        AH_UDC_LogHelper.Debug('CloneStepResponses - lstWBStepResponses: ' + lstWBStepResponses);

                        if (lstWBStepResponses.size() > 0) {
                           //Insert records into the object AH_UDC_WorkbookStepResponse__c
                           AH_UDC_SystemContext.CreateObjects(lstCloneWBStepResponses);
                        }
                     }
                  }
               }
               else {
                  LogException('CloneWorkbook', 'Failed to clone the workbook.', null, sp);
                  return;
               }
            }
         }
      } catch(Exception ex) {
         lstWorkbookSteps = null;
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CloneWorkbook', strErrorMessage, ex, sp);
      }
      finally { //Dispose unused variables/object
         lstWorkBookStepsList = null;
         lstWorkbookClone = null;
         workbookSortOrderWithStepIdMap = null;
         workbookSortOrderWithPreqStepIdMap = null;
         workbookSortOrderWithCloneStepIdMap = null;
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc, Savepoint objSavePoint) {
      IsErrorOccurred = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message_Backend, exc, objSavePoint);
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML restrictions
   public void ServerLogMessages() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages');
      try {
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0) {
            AH_UDC_SystemContext.CreateObjects(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'ServerLogMessages',
                              'An exception occurred logging Page Load AH_UDC_Log entries',
                              exc, null, null);
      }
   }
}