/***********************************************************************************************
  Name            : AH_UDC_CloneWorkbook
  Author          : Tushar Gupta
  Created Date    : 25-Jan-2021
  Last Mod Date   : 25-Jan-2021
  Last Mod By     : Tuhsar Gupta
  NICC Reference  : 
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
   public Boolean IsAnyError { get; set; }
   public String WorkbookId { get; set; }
   private Integer WorkbookCount { get; set; }
   public String AccessMessage { get; set; }

   //Only Workbooks and not Workbooks SENT can be cloned
   private Id recordTypeIdWorkbook = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();

   private string LogFunctionalArea = 'AH_UDC_CloneWorkbook'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
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

         //Set default value as false
         IsWorkbookNameValid = false;
         IsAnyError = false;
         if (String.isBlank(apexpages.currentpage().getparameters().get('id'))) {
            LogException('Constructor', 'Workbook ID is blank in query string', null, null);
            return;
         }

         WorkbookId = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('id'));


         //Check if logged in user has modify access to the workbook or not
         CheckWBCloneAccess();

         Workbook = [SELECT Name, Enabled__c, Description__c, Product__c, RecordTypeId, RelatedToDocName__c,
                     RelatedTo__c, SentStatus__c, StepsinOrder__c
                     FROM AH_UDC_Workbook__c
                     WHERE Id = :WorkbookId
                     and recordtypeid = :recordTypeIdWorkbook];

         if (Workbook == null) {
            LogException('Constructor', 'Ah_UDC_Workbook__c Not Found', null, null);
            return;
         }

         WorkbookName = Workbook.Name;
         Workbook.Name = System.Label.AH_UDC_Clone_Of_Label_Prefix_Text + ' ' + Workbook.Name;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strErrorMessage, ex, null);
      }
      finally {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
      }
   }

   //Check if user has rights to clone workbook 
   private void CheckWBCloneAccess()
   {
      string strError = null;
      try{
         if (AH_UDC_SharedWithoutSharing.CheckWorkbookReadUserAccess(WorkbookId)) //Only user with Read Access to the Workbook can clone it
         {
            //TODO ... this should allow UDC System Admin and UDC Workbook Admin... rather than just excluding UDC Workbook user... since there could be other reasons the user has Read access
            //check for workbookuser permissionset. This user won't have clone permisssion so set the label to display on screen
            List<PermissionSetAssignment> lstUserPermission = [SELECT Id FROM PermissionSetAssignment
                                                   WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name =: AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER];
            if (lstUserPermission.size() > 0)
            {
               AccessMessage = Label.AH_UDC_NoCreateAccessMessage;
               strError = System.UserInfo.getUserName() + ' do not have clone access for workbook : ' + WorkbookId;
               IsAnyError = true;
               return;
            }
         }
      }
      catch(Exception ex) {
         LogException('CheckWBCloneAccess', strError, ex, null);
      }
   }
   //Create a clone of selected workbook
   public void CloneWorkbook() {
      //Code for manage the rollback is any error occurred
      Savepoint sp = Database.setSavepoint();
      IsAnyError = false;
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
         if (Workbook != null) {
            //Check input workbook name with existing workbooks (exclude workbook sent)
            WorkbookCount = [SELECT Count() FROM AH_UDC_Workbook__c WHERE Name = :Workbook.Name.trim() and recordtypeid = :recordTypeIdWorkbook];
            if (WorkbookCount > 0) {
               IsWorkbookNameValid = false;
            } else {
               IsWorkbookNameValid = true;
            }

            if (IsWorkbookNameValid) {
               //Clone of workbook
               AH_UDC_Workbook__c objCloneWorkbook = Workbook.clone(false, false, false, false);
               objCloneWorkbook.Enabled__c = false;
               objCloneWorkbook.OwnerId = UserInfo.getUserId();

               //Initialize list to prevent error
               lstWorkbookClone = new List<AH_UDC_WorkbookStep__c> ();
               if (objCloneWorkbook != null) {

                  insert objCloneWorkbook; //Insert the new workbook

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
                        insert lstWorkbookSteps;

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
                           update lstWorkbookSteps;
                        }
                     }
                  }
               } else {
                  LogException('CloneWorkbook', 'Cloning of workbook is failed and new workbbok is not inserted.', null, sp);
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
      IsAnyError = true;
      IsWorkbookNameValid = false;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message, exc, objSavePoint);
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML retrictions
   public void ServerLogMessages() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages');
      try {
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0) {
            insert(PageLoadLogMessages);
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