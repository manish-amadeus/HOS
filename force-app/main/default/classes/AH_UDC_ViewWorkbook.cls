/***********************************************************************************************
  Name            : AH_UDC_ViewWorkbook
  Author          : Rob Stevens (Rob.Stevens@amadeus.com)
  Created Date    : 2021-04-12
  Description     : Controller class for View Workbook Page
 ************************************************************************************************/
public without sharing class AH_UDC_ViewWorkbook {
   @TestVisible private string LogFunctionalArea = 'ViewWorkbook'; //This is used for AH_UDC_Log Entries being written on this page
   public Boolean DisplayConsoleLogMessages { get; set; } { DisplayConsoleLogMessages = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_ViewWorkbookDisplayConsoleLogMessages', false); }
   Boolean isPageLoad { get; set; } { isPageLoad = false; }

   public Boolean isViewWorkbookEnabled { get { return AH_UDC_ConfigHelper.GetBoolean('AH_UDC_ViewWorkbookEnabled', false); } }

   public Integer CollapsedMenuCirclesPerPage { get; set; } { CollapsedMenuCirclesPerPage = AH_UDC_ConfigHelper.GetInteger('AH_UDC_CollapsedMenuCirclesPerPage', 10); }
   public Integer CollapsedMenuCirclePage { get; set; } { CollapsedMenuCirclePage = 1; }
   public Boolean ShowCollapsedMenuUpNavigation { get; set; } { ShowCollapsedMenuUpNavigation = false; }
   public Boolean ShowCollapsedMenuDownNavigation { get; set; } { ShowCollapsedMenuDownNavigation = false; }
   public Integer collapsedMenuMoveDirection { get; set; } { collapsedMenuMoveDirection = 0; }

   public Boolean IsCommunityView { get; set; } { IsCommunityView = true; } //Used to determine if it's a community user viewing the page
   public string ReturnToWelcomePageUrl { get; set; } { ReturnToWelcomePageUrl = AH_UDC_ConfigHelper.GetString('AH_UDC_ReturnToWelcomePageURL', ''); } //This is the URL for the top bar menu
   public Boolean chatterUpdate { get; set; } { chatterUpdate = false; } //This is used to show if there are new chatter messages

   //Used by the client to determine when to refresh data
   public Integer UpdateTimerIntervalInMilliSeconds { get; set; } { UpdateTimerIntervalInMilliSeconds = AH_UDC_ConfigHelper.GetInteger('AH_UDC_ViewWorkbookUpdateTimerIntervalInSeconds', 60) * 1000; }
   //Used by the client to determine when to refresh data
   public Integer NotificationDisplayMilliseconds { get; set; } { NotificationDisplayMilliseconds = AH_UDC_ConfigHelper.GetInteger('AH_UDC_ViewWorkbookNotificationDisplayInSeconds', 5) * 1000; }

   //Used to Store the workbook for display on the page (has to be a non SF object due to Community Site)
   public AH_UDC_CommunityWorkbook workbook { get; set; }

   //These are used to track step navigation; IMPORTANT: Start Step =0, Compelte Step = -1, all other steps are the same as their order.
   public AH_UDC_CommunityWorkbook.WorkbookStep currentStep { get; set; }
   public Integer currentPosition { get; set; } { currentPosition = 0; } //-1 is End, 0 is start, all other steps are the same as their order.
   public Integer changeToPositionNumber { get; set; } //-1 is End, 0 is start, all other steps are the same as their order.
   public String changeToStepUrl { get; set; }
   public String changeToStepMessage { get; set; }

   public Boolean ShowErrorMessage { get; set; } { ShowErrorMessage = false; } //TODO: Deprecate in 2.2
   public Boolean ShowErrorMessageAsNotification { get; set; } { ShowErrorMessageAsNotification = false; } //TODO: Deprecate in 2.2
   public boolean CallbackErrorOccurred { get; set; } { CallbackErrorOccurred = false; } //TODO: Remove in V2.2
   
   //This is used to cause the client page to show a generic error message in the page message block
   public Boolean isPageLoadErrorMessage { get; set; } { isPageLoadErrorMessage = false; }

   //This is used to cause the client page to show a generic error message
   public string NotificationToShow { get; set; } { NotificationToShow = ''; }
   
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }

   //File Upload Variables
   public String DeleteFileID { get; set; }
   public List<ContentDocumentLink> UploadedFileList { get; set; } { UploadedFileList = new List<ContentDocumentLink> (); } //This is used to diplay a file list on the Amadeus File Update component
   public Integer FileUploadCount { get; set; } { FileUploadCount = AH_UDC_ConfigHelper.GetInteger('AH_UDC_FileUploadMaximumFileCount', 5); } //Used by the client to determine how many file upload at time
   public Integer FileUploadMaximumSize { get; set; } { FileUploadMaximumSize = AH_UDC_ConfigHelper.GetInteger('AH_UDC_FileUploadMaximumSizeInMB', 35); } //Used by the client to determine maximum file upload size
   public string FileUploadExtension { get; set; } { FileUploadExtension = AH_UDC_ConfigHelper.GetString('AH_UDC_FileUploadAllowedExtensions', ''); } //Used by the client to determine which file upload extension should upload
   public string FileUploadUrl { get; set; } { FileUploadUrl = AH_UDC_ConfigHelper.GetString('AH_UDC_FileUploadUrl', ''); } //This is the URL of the File Upload REST API

   //API URL to get/save form response data
   public string AmdeusCustomFormAPIUrl { get; set; } { AmdeusCustomFormAPIUrl = AH_UDC_ConfigHelper.GetString('AH_UDC_APIUrl', ''); }

   //TODO: Deprecate in V2.2
   public void clientLogException() {
   }
   //TODO: Deprecate in V2.2
   public void GetFiles()
   {
   }
   //TODO: Deprecate in V2.2
   public void DeleteFile() {
   }
   //TODO: Deprecate in V2.2
   public void SetStepInProgress() {
   }

   public String LastUpdatedByHelpText {
      get {
         //Add time zone and date format in custom label text
         String strHelpText = string.format(Label.AH_UDC_ViewWorkbook_LastUpdatedByHelpText,
                                             new String[] { UserTimeZone, UserLocale });
         return strHelpText.replace('\n', '<br/>'); //Display text in new line if new line exists
      }
   }
   public String UserLocale { get { return UserInfo.getLocale(); } }
   public String UserTimeZone { get { return String.valueOf(UserInfo.getTimeZone()); } }

   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('###PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages.size() > 0;
      }
   }

   public AH_UDC_ViewWorkbook() {
      AH_UDC_LogHelper.Debug('###AH_UDC_ViewWorkbook');
      ID WorkbookId;
      isPageLoad = true;
      try
      {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         //Determine if the current user has the UDC System Admin permission set assigned to them
         String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
         Boolean isUDCSysAdmin = 0 < (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :System.UserInfo.getUserId() AND PermissionSet.Name = :UDCSystemAdminPermissionSetName];
         Boolean isUDCUserOrUDCWBAdmin = 0 < (Integer) [SELECT COUNT()
                                                        FROM PermissionSetAssignment
                                                        WHERE AssigneeId = :System.UserInfo.getUserId()
                                                        AND(PermissionSet.Name = :AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetWorkbookAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN)
                                                            or PermissionSet.Name = :AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetWorkbookUser', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER))];

         //Alert the user if viewing workbooks is disabled; UDC System Admins are excluded
         if (!isUDCSysAdmin && !isViewWorkbookEnabled) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, AH_UDC_ConfigHelper.GetString('AH_UDC_ViewWorkbookDisabledMessage', 'View Workbook is currently disabled.')));
            isPageLoadErrorMessage = true;
            return;
         }

         if (String.isBlank(ApexPages.currentPage().getParameters().get('id'))) {
            LogException('Constructor', 'Workbook Id parameter is missing from request', null, null, null, null);
            return;
         }
         WorkbookId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceViewWorkbookLoadError', FALSE))
         {
            throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'View Workbook Load'));
         }

         workbook = new AH_UDC_CommunityWorkbook();
         currentPosition = 0;

         //Trace for Loading Workbook
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE, 'ViewWorkbook Page',
                              'AH_UDC_ViewWorkbook', 'The User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName()
                              + ') is opening UDC Workbook ID: ' + WorkbookId);

         //Determine if page is loading from Community Site
         //TODO: It would be best not to pass this on the URL... there were issues when trying to determine it using "Host" name
         if (ApexPages.currentPage().getParameters().get('community') == 'false') {
            IsCommunityView = false;
         }
         AH_UDC_LogHelper.Debug('IsCommunityView value=>' + IsCommunityView);

         //Check that the user has access
         Boolean userHasAccess = AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess(WorkbookId);
         AH_UDC_LogHelper.Debug('###userHasAccess: ' + userHasAccess);

         iF (!userHasAccess)
         {
            LogException('Constructor', 'The User ('
                         + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName()
                         + ') does not have access to requested UDC Workbook ID: ' + WorkbookId, null, null, null, null);
            return;
         }

         //Get the workbook steps
         List<AH_UDC_WorkbookStep__c> wbSteps = [select id, name, description__c,
                                                 Workbook__r.RelatedTo__r.Id, Workbook__r.RelatedTo__r.Document_Name__c, Workbook__r.RelatedTo__r.AH_UDC_WorkbookDueDate__c,
                                                 Workbook__r.StepsinOrder__c, Workbook__r.SentStatus__c,
                                                 Workbook__r.Archive__c, SortOrder__c, StepStatus__c, URL__c, form__c, help__c,
                                                 Prerequisite_Step__c, Prerequisite_Step__r.StepStatus__c,
                                                 Workbook__r.RelatedTo__r.AH_UDC_PropertyConfirmation__c,
                                                 Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c, Workbook__r.SecurityCode__c, Form__r.id,
                                                 Form__r.RecordTypeId,
                                                 Workbook__r.RelatedTo__r.Project__r.name,Workbook__r.RelatedTo__r.project__r.pse__Project_Manager__r.name
                                                 from AH_UDC_WorkbookStep__c
                                                 where Enabled__c = true and Workbook__c = :WorkbookId order by SortOrder__c asc];

         AH_UDC_LogHelper.Debug(LogFunctionalArea + ' - wbSteps: ' + wbSteps);
         if (wbSteps.size() == 0)
         {
            LogException('Constructor', 'An error "Workbook has no steps" occurred loading workbook for user ('
                         + System.UserInfo.getUserId() + ' : '
                         + System.UserInfo.getUserName() + ') and Workbook ID: ' + WorkbookId, null, null, null, null);
            return;
         }
         workbook.id = WorkbookId;
         workbook.isCompleted = (wbSteps[0].Workbook__r.SentStatus__c == AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED);
         workbook.isArchived = wbSteps[0].Workbook__r.Archive__c;
         workbook.documentId = String.valueOf(wbSteps[0].Workbook__r.RelatedTo__r.Id);
         workbook.name = String.valueOf(wbSteps[0].Workbook__r.RelatedTo__r.Document_Name__c);
         workbook.propertyInfo.id = String.valueOf(wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c);
         workbook.propertyInfo.isPropertyConfirmed = Boolean.valueOf(wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_PropertyConfirmation__c);
         workbook.ProjectName = wbSteps[0].Workbook__r.RelatedTo__r.Project__r.name;
         workbook.ProjectContact = wbSteps[0].Workbook__r.RelatedTo__r.project__r.pse__Project_Manager__r.name;

         if (wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_WorkbookDueDate__c != null) workbook.dueDate = wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_WorkbookDueDate__c;

         AH_UDC_LogHelper.Debug(LogFunctionalArea + ' - workbook.propertyInfo.id: ' + workbook.propertyInfo.id);
         if (String.isBlank(workbook.propertyInfo.id))
         {
            LogException('Constructor', 'An error "Property Info ID missing" occurred loading workbook for user ('
                         + System.UserInfo.getUserId() + ' : '
                         + System.UserInfo.getUserName() + ') and Workbook ID: ' + WorkbookId, null, null, null, null);
            return;
         }

         // Get property account details
         List<AH_UDC_PropertyAccount__c> propertyAccounts = [SELECT PropertyName__c,
                                                             Address__c, City__c, StateProvince__c,
                                                             PostalCode__c, Country__c, Phone__c
                                                             FROM AH_UDC_PropertyAccount__c
                                                             WHERE Id = :workbook.propertyInfo.id];
         workbook.propertyInfo.address = GetAddress(propertyAccounts[0]);
         workbook.propertyInfo.phone = propertyAccounts[0].Phone__c;
         workbook.propertyInfo.name = propertyAccounts[0].PropertyName__c;

         Integer Position = 1;
         workbook.allStepsComplete = true;

         Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
         Id AmadeusFileUploadRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
         Id FormAssemblyFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();

         //Build Steps for Display in page
         for (AH_UDC_WorkbookStep__c wbStep : wbSteps)
         {
            AH_UDC_CommunityWorkbook.WorkbookStep wbs = new AH_UDC_CommunityWorkbook.WorkbookStep();
            wbs.name = wbStep.Name;
            wbs.id = wbStep.Id;
            wbs.description = wbStep.description__c;

            //Determine the Step Help Url
            wbs.helpurl = '';
            if (String.isNotEmpty(wbStep.Help__c))
            {
               string hostVal = ApexPages.currentPage().getHeaders().get('Host');
               if (IsCommunityView)
               {
                  wbs.helpurl = 'https://' + hostVal + '/customers/AH_UDC_ViewHelp?Popout=false&community=' + IsCommunityView + '&id=' + wbStep.Id;
               }
               else
               {
                  wbs.helpurl = 'https://' + hostVal + '/apex/AH_UDC_ViewHelp?Popout=false&community=' + IsCommunityView + '&id=' + wbStep.Id;
               }
            }
            wbs.position = Position;
            wbs.status = String.valueOf(wbStep.StepStatus__c);
            wbs.isLocked = false;
            if (!(isUDCUserOrUDCWBAdmin || isUDCSysAdmin) && wbs.status == AH_UDC_Constants.STEP_STATUS_LOCKED) wbs.isLocked = true; //Locked status only impacts Community users
            if (wbs.status != AH_UDC_Constants.STEP_STATUS_COMPLETED && wbs.status != AH_UDC_Constants.STEP_STATUS_LOCKED) workbook.allStepsComplete = false;
            //Adding completed class to display green color for locked step
            wbs.css = String.valueOf(wbStep.StepStatus__c).replaceAll(AH_UDC_Constants.STEP_STATUS_LOCKED, AH_UDC_Constants.STEP_STATUS_COMPLETED);
            wbs.css = wbs.css.replaceAll(' ', '-').toLowerCase();
            wbs.cssI = 'default-step-i';
            wbs.cssCurrent = '';
            if (wbs.status == AH_UDC_Constants.STEP_STATUS_COMPLETED || wbs.status == AH_UDC_Constants.STEP_STATUS_LOCKED) wbs.cssI = 'fas fa-check';

            AH_UDC_LogHelper.Debug('###wbStep.URL__c: ' + wbStep.URL__c);
            AH_UDC_LogHelper.Debug('###wbStep.Form__r: ' + wbStep.Form__r.RecordTypeId);
            AH_UDC_LogHelper.Debug('###AmadeusFileUploadRecordTypeId: ' + AmadeusFileUploadRecordTypeId);
            if (String.isNotBlank(wbStep.URL__c))
            {
               wbs.url = wbStep.URL__c;
               wbs.isExternalUrl = true;
            }
            else if (wbStep.Form__r.RecordTypeId == AmadeusFormRecordTypeId) {
               wbs.isamadeuscustomform = true;
               wbs.token = AH_UDC_Shared.CreateStepToken(wbStep.Workbook__r.SecurityCode__c, wbStep.Form__r.id);
            }
            else if (wbStep.Form__r.RecordTypeId == AmadeusFileUploadRecordTypeId) {
               wbs.isAmadeusFileUpload = true;
               if (String.isEmpty(wbStep.Description__c)){
                  wbs.description = Label.AH_UDC_FileUploadNotes;
                  wbs.description = wbs.description.replace('{0}',  String.valueOf(FileUploadCount)).replace('{1}', String.valueOf(FileUploadMaximumSize)).replace('{2}', FileUploadExtension);
               }
               //Don't set token value for generating unit test error
               if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceFileUploadError', false) == false)
                  wbs.token = AH_UDC_Shared.CreateStepToken(wbStep.Workbook__r.SecurityCode__c, wbStep.Form__r.id);
            }
            else if (wbStep.Form__r.RecordTypeId == FormAssemblyFormRecordTypeId) {
               wbs.isFormAssemblyForm = true;
            }

            Integer intPrereqStepIndex = - 1;
            wbs.isPrerequisiteStepNotCompleted = false;
            if (wbSteps[0].Workbook__r.StepsinOrder__c) {
               //If steps in order is set to true then set previous step as a prerequisite step
               intPrereqStepIndex = workbook.steps.size() - 1;
            }
            else if (wbStep.Prerequisite_Step__c != null) {
               //Find index of prerequisite step from the prepared steps list
               for (Integer i = 0; i<workbook.steps.size(); i++) {
                  if (workbook.steps[i].id == String.valueOf(wbStep.Prerequisite_Step__c)) {
                     intPrereqStepIndex = i;
                     break;
                  }
               }
            }

            if (intPrereqStepIndex> - 1) {
               //This will be used to display prerequisite step name in client side notification message
               wbs.prerequisiteStepName = workbook.steps[intPrereqStepIndex].name;
               //This will be used to display prerequisite step number in client side notification message
               wbs.prerequisiteStepPosition = intPrereqStepIndex + 1;
               wbs.isPrerequisiteStepNotCompleted = workbook.steps[intPrereqStepIndex].status != AH_UDC_Constants.STEP_STATUS_COMPLETED
               && workbook.steps[intPrereqStepIndex].status != AH_UDC_Constants.STEP_STATUS_LOCKED;
            }

            workbook.steps.add(wbs);
            //System.debug('wbStep.StepStatus__c => ' + wbStep.StepStatus__c);
            //Determine number of steps complete
            if (wbStep.StepStatus__c == AH_UDC_Constants.STEP_STATUS_COMPLETED || wbStep.StepStatus__c == AH_UDC_Constants.STEP_STATUS_LOCKED)
            {
               workbook.completedSteps++;
            }
            else
            {
               AH_UDC_LogHelper.Debug(LogFunctionalArea + ' - isPropertyConfirmed: ' + workbook.propertyInfo.isPropertyConfirmed);
               if (workbook.propertyInfo.isPropertyConfirmed)
               {
                  //Determine/Set the current step
                  if (currentStep == null)
                  {
                     currentStep = wbs;
                     wbs.cssCurrent += 'current-step';
                     if (String.isNotBlank(wbStep.Form__c)) currentStep.url = AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrl(wbStep.id);
                     currentPosition = Position;

                     //Check if current Step is a File Upload step
                     if (currentStep.isAmadeusFileUpload) serverGetFiles();
                     else {
                        List<SelectOption> lstLastUpdatedByUsers = GetStepLastUpdatedByUsersList(currentStep.id);
                        if(lstLastUpdatedByUsers != null && lstLastUpdatedByUsers.size() > 0) {
                           currentStep.lastUpdatedByUsersList = lstLastUpdatedByUsers;
                           currentStep.selectedLastUpdatedById = lstLastUpdatedByUsers[0].getValue();
                        }
                     }
                  }
               }
            }
            Position++;
         }

         //Set Collapsed Menu Step Visibility
         if (currentPosition == 0 || currentPosition == - 1)
         {
            CollapsedMenuCirclePage = 1; //Default to first page of cicles
            ShowCollapsedMenuUpNavigation = false;
            if (workbook.steps.size() > CollapsedMenuCirclesPerPage) ShowCollapsedMenuDownNavigation = true;
         }
         else
         {
            //Determine Collapsed Circle Page
            Decimal calcMaxPages = (Decimal) workbook.steps.size() / (Decimal) CollapsedMenuCirclesPerPage;
            Integer maxPages = (integer) calcMaxPages.round(System.RoundingMode.UP);
            for (integer findCirclePage = 1; findCirclePage <= maxPages; findCirclePage++)
            {
               if ((currentPosition > CollapsedMenuCirclesPerPage * (findCirclePage - 1)) &&
               (currentPosition <= CollapsedMenuCirclesPerPage * findCirclePage))
               {
                  CollapsedMenuCirclePage = findCirclePage;
                  break;
               }
            }
            if (CollapsedMenuCirclePage > 1) ShowCollapsedMenuUpNavigation = true;
            if (CollapsedMenuCirclePage<maxPages) ShowCollapsedMenuDownNavigation = true;
         }
         SetCollapsedMenuDisplay();

         if (IsCommunityView) CheckChatterFeedNotification(); //Only Community Users see the chatter icon

         Workbook.totalSteps = workbook.steps.size();

         //If all Steps are completed then set current position to the Complete step
         if (workbook.steps.size() == workbook.completedSteps) currentPosition = - 1;
      }
      catch(Exception exc)
      {
         LogException('Constructor', 'An exception occurred loading workbook for user ('
                      + System.UserInfo.getUserId() + ' : '
                      + System.UserInfo.getUserName() + ') and Workbook ID: ' + WorkbookId, null, exc, null, null);
      }
      finally
      {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   public void serverCollapsedMenuMove()
   {
      NotificationToShow = '';
      isPageLoad = false;
      //Determine Collapsed Circle Page
      //System.Debug('$$$workbook.steps.size(): ' + workbook.steps.size());
      //System.Debug('$$$CollapsedMenuCirclesPerPage: ' + CollapsedMenuCirclesPerPage);
      Decimal calcMaxPages = (Decimal) workbook.steps.size() / (Decimal) CollapsedMenuCirclesPerPage;
      Integer maxPages = (integer) calcMaxPages.round(System.RoundingMode.UP);
      //System.Debug('$$$maxPages: ' + maxPages);

      //System.Debug('$$$collapsedMenuMoveDirection: ' + collapsedMenuMoveDirection);
      if (collapsedMenuMoveDirection == 1 && CollapsedMenuCirclePage + 1 <= maxPages) CollapsedMenuCirclePage++;
      if (collapsedMenuMoveDirection == - 1 && CollapsedMenuCirclePage> 1) CollapsedMenuCirclePage--;

      //System.Debug('$$$CollapsedMenuCirclePage: ' + CollapsedMenuCirclePage);

      //Set Collapsed Menu Step Visibility
      if (CollapsedMenuCirclePage == 1)
      {
         ShowCollapsedMenuUpNavigation = false;
         ShowCollapsedMenuDownNavigation = workbook.steps.size() > CollapsedMenuCirclesPerPage;
      }
      else
      {
         ShowCollapsedMenuUpNavigation = CollapsedMenuCirclePage > 1;
         ShowCollapsedMenuDownNavigation = CollapsedMenuCirclePage<maxPages;
      }
      //System.Debug('$$$ShowCollapsedMenuUpNavigation: ' + ShowCollapsedMenuUpNavigation);
      //System.Debug('$$$ShowCollapsedMenuDownNavigation: ' + ShowCollapsedMenuDownNavigation);
      SetCollapsedMenuDisplay();
   }

   private void SetCollapsedMenuDisplay()
   {
      //Set Collapsed Menu Step Visibility
      //System.debug('$$$CollapsedMenuCirclePage:' + CollapsedMenuCirclePage);
      integer iCollapsedStepDisplayStartPosition = ((CollapsedMenuCirclePage - 1) * CollapsedMenuCirclesPerPage) + 1;
      integer iCollapsedStepDisplayStopPosition = CollapsedMenuCirclePage * CollapsedMenuCirclesPerPage;
      //System.debug('$$$iCollapsedStepDisplayStartPosition:' + iCollapsedStepDisplayStartPosition);
      //System.debug('$$$iCollapsedStepDisplayStopPosition:' + iCollapsedStepDisplayStopPosition);
      for (AH_UDC_CommunityWorkbook.WorkbookStep wbs : workbook.steps)
      {
         //System.debug('$$$evalcss for step position:' + wbs.position);
         if (wbs.position >= iCollapsedStepDisplayStartPosition &&
             wbs.position <= iCollapsedStepDisplayStopPosition)
         {
            //System.debug('$$$evalcss for step position: Dont Hide');
            //Show Collapsed Step
            wbs.cssCollapsedMenuStep = '';
         }
         else
         {
            //System.debug('$$$evalcss for step position: Hide');
            wbs.cssCollapsedMenuStep = 'display_none';
         }
      }
   }

   //Create property address string
   @TestVisible 
   private string GetAddress(AH_UDC_PropertyAccount__c propertyAccount) {

      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.GetAddress');
      string PropertyAddress = '';
      try {
         List<String> lstAddress = null;
         lstAddress = new List<String> ();
         if (String.isNotBlank(propertyAccount.Address__c)) {
            lstAddress.add(propertyAccount.Address__c);
         }
         if (String.isNotBlank(propertyAccount.StateProvince__c)) {
            lstAddress.add(propertyAccount.StateProvince__c);
         }
         if (String.isNotBlank(propertyAccount.City__c)) {
            lstAddress.add(propertyAccount.City__c);
         }
         if (String.isNotBlank(propertyAccount.Country__c)) {
            lstAddress.add(propertyAccount.Country__c);
         }
         if (String.isNotBlank(propertyAccount.PostalCode__c)) {
            lstAddress.add(propertyAccount.PostalCode__c);
         }

         //Set address
         if (lstAddress != null && lstAddress.Size()> 0) {
            PropertyAddress = String.join(lstAddress, ', ');
         }

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      } catch(Exception exc) {

         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.GetAddress - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'GetAddress',
                              'An exception occurred formatting the address',
                              exc, String.valueOf(propertyAccount.id), 'AH_UDC_PropertyAccount__c');
         throw exc;
      }
      return PropertyAddress;
   }

   //This method is used to show a single error message to the user
   public void ShowErrorMessage()
   {
      ShowErrorMessage(System.Label.AH_UDC_Common_Error_Message);
   }

   //This method is used to show a single error message to the user
   public void ShowErrorMessage(string ErrorMessage)
   {
      try
      {
         if (String.isBlank(ErrorMessage)) ErrorMessage = System.Label.AH_UDC_Common_Error_Message;

         if (isPageLoad && !isPageLoadErrorMessage)
         {
            isPageLoadErrorMessage = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ErrorMessage));
         }

         if (!isPageLoad && String.isBlank(NotificationToShow))
         {
            NotificationToShow = ErrorMessage;
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ShowErrorMessage - Exception: ' + exc);
         //NOTE: There is no throw or log for this since it is called by the page load
         isPageLoadErrorMessage = true;
      }
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML retrictions
   public void serverLogMessages()
   {
      NotificationToShow = '';
      isPageLoad = false;
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverLogMessages');
      try
      {
         NotificationToShow = '';
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0)
         {
            AH_UDC_SystemContext.CreateObjects(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverLogMessages - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'serverLogMessages',
                              'An exception occurred logging Page Load AH_UDC_Log entries',
                              exc, null, null);
      }
   }

   //Log error message if error occurred in javascript code
   public void serverLogClientException() {
      try {
         NotificationToShow = '';
         isPageLoad = false;
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
         if (String.isBlank(ApexPages.currentPage().getParameters().get('errormsg'))) {
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                 LogFunctionalArea, 'serverLogClientException', 'Parameter not found - errormsg. Error occurred in the JS function ' + ApexPages.currentPage().getParameters().get('methodname'), null, null, null);
            return;
         }
         String strErrorMessage = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('errormsg'));
         String strMethodName = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('methodname'));

         AH_UDC_LogHelper.Debug('Error occurred in the method ' + strMethodName);
         AH_UDC_LogHelper.Debug('Error : ' + strErrorMessage);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea, strMethodName, strErrorMessage, null, null, null);
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverLogClientException - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'serverLogClientException',
                              'An exception occurred while logging error message',
                              exc, null, null);
      }
   }

   public void serverSubmit()
   {
      try
      {
         NotificationToShow = '';
         isPageLoad = false;
         List<AH_UDC_Workbook__c> workbooks = [SELECT Id, CompletedDate__c, SentStatus__c, RelatedTo__c, CompletedBy__c, RelatedTo__r.AH_UDC_ChatterWorkbookCompleted__c
                                               FROM AH_UDC_Workbook__c
                                               WHERE Id = :workbook.Id];

         if (workbooks.size() == 0) {
            LogException('serverSubmit', 'Workbook not found with the Id - ' + workbook.id, null, null, null, null);
            return;
         }
         else if (workbooks[0].SentStatus__c != AH_UDC_Constants.SENT_STATUS_IN_PROGRESS) {
            LogException('serverSubmit', 'Workbook sent status should be ' + AH_UDC_Constants.SENT_STATUS_IN_PROGRESS + ' in order to complete. Actual sent status is ' + workbooks[0].SentStatus__c, null, null, null, null);
            return;
         }

         Integer WBTotalNotCompletedSteps = [SELECT COUNT() FROM AH_UDC_workbookstep__c
                                             WHERE Enabled__c = true 
                                             AND stepStatus__c != :AH_UDC_Constants.STEP_STATUS_COMPLETED 
                                             AND stepStatus__c != :AH_UDC_Constants.STEP_STATUS_LOCKED
                                             AND Workbook__r.Id = :workbook.id];

         if (WBTotalNotCompletedSteps > 0) {
            LogException('serverSubmit', 'Workbookstep not completed record found. WorkbookId - ' + workbook.id, null, null, null, null);
            return;
         }

         //Send chatter if enabled - this calls external API so must execute before any data is written
         Boolean sendChatter = (Boolean) workbooks[0].RelatedTo__r.AH_UDC_ChatterWorkbookCompleted__c;
         if (sendChatter) AH_UDC_SharedWithoutSharing.CreateChatter((ID) workbooks[0].RelatedTo__c, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookComplete);

         workbooks[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         workbooks[0].CompletedDate__c = Datetime.now();
         workbooks[0].CompletedBy__c = UserInfo.getUserId();
         AH_UDC_SystemContext.UpdateObject(workbooks[0]);
         AH_UDC_LogHelper.Debug('serverSubmit => SentStatus after update: ' + workbooks[0].SentStatus__c);
         NotificationToShow = System.Label.AH_UDC_Workbook_Completion_Confirmation_Msg;

         if (!Test.isRunningTest()) { //Skip refreshSteps to prevent 101 error during test class execution
            refreshSteps();
         }

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception exc)
      {
         LogException('serverSubmit', 'An exception occurred Confirming the Property', null, null, null, null);
      }
   }

   public void serverConfirmProperty() {
      try
      {
         NotificationToShow = '';
         isPageLoad = false;
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ConfirmFromPropertyInformation');
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
         //Select the record with a For Update Lock to ensure another user hasn't changed the data
         List<AH_UDC_Workbook__c> workbooks = [SELECT SentStatus__c, RelatedTo__c,
                                               RelatedTo__r.AH_UDC_PropertyConfirmation__c, RelatedTo__r.AH_UDC_PropertyConfirmationAccepted_Date__c, RelatedTo__r.AH_UDC_ChatterWorkbookAccessed__c
                                               FROM AH_UDC_Workbook__c
                                               WHERE Id = :workbook.id FOR UPDATE];

         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ConfirmFromPropertyInformation => workbooks.size(): ' + workbooks.size());
         if (workbooks.size() == 0) {
            LogException('serverConfirmProperty', 'Workbook record not found. WorkbookId - ' + workbook.id, null, null, null, null);
            return;
         }

         //If neeeded, update Workbook Sent Status from New to In Progress
         if (workbooks[0].SentStatus__c == AH_UDC_Constants.SENT_STATUS_NEW) {
            //Send chatter if enabled - this calls external API so must execute before any data is written
            //Failure to create chatter will be logged and not cause exception or be shown to community user
            if (workbooks[0].RelatedTo__c != null &&
                workbooks[0].RelatedTo__r.AH_UDC_ChatterWorkbookAccessed__c == true) {
               AH_UDC_SharedWithoutSharing.CreateChatter((ID) workbooks[0].RelatedTo__c, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookAccessed);
            }

            AH_UDC_Workbook__c workbookUpdateStatus = new AH_UDC_Workbook__c(
                                                                             Id = workbook.id,
                                                                             SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS);
            AH_UDC_SystemContext.UpdateObject(workbookUpdateStatus);
         }

         //Check if Property hasn't been confirmed
         workbook.propertyInfo.isPropertyConfirmed = workbooks[0].RelatedTo__r.AH_UDC_PropertyConfirmation__c;
         if (workbooks[0].RelatedTo__r.AH_UDC_PropertyConfirmation__c == false ||
             workbooks[0].RelatedTo__r.AH_UDC_PropertyConfirmationAccepted_Date__c == null)
         {
            //Update status of property confirmation flag and it's date
            NI_Documentation__c niDoc = new NI_Documentation__c(Id = workbooks[0].RelatedTo__c);
            niDoc.AH_UDC_PropertyConfirmation__c = true;
            niDoc.AH_UDC_PropertyConfirmationAccepted_Date__c = DateTime.now();
            AH_UDC_SystemContext.UpdateObject(niDoc);

            workbook.propertyInfo.isPropertyConfirmed = true;
         }
      }
      catch(Exception exc)
      {
         LogException('serverConfirmProperty', 'An exception occurred Confirming the Property', null, null, null, null);
      }
   }

   //Used to mark the current step complete; can only be set to complete if the step has a response
   public void serverMarkStepComplete() {
      //System.debug('$$$serverMarkStepComplete');
      try
      {
         NotificationToShow = '';
         isPageLoad = false;
         List<AH_UDC_WorkbookStep__c> wbSteps = [select id, StepStatus__c, StepCompleted__c, form__c,
                                                 Workbook__r.RelatedTo__r.AH_UDC_ChatterWorkbookStepCompleted__c, Form__r.RecordTypeId
                                                 from AH_UDC_WorkbookStep__c
                                                 where id = :currentStep.id FOR UPDATE];
         List<AH_UDC_WorkbookStepResponse__c> wbsResponses = [select id
                                                              from AH_UDC_WorkbookStepResponse__c
                                                              where WorkbookStep__c = :currentStep.id and IsMostRecentResponse__c = true];

         if (wbSteps.size() != 1)
         {
            NotificationToShow = System.Label.AH_UDC_Common_Error_Message; //This is the generic error shown to community users
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                 LogFunctionalArea, 'serverMarkStepComplete',
                                 'Requested Step Not Found',
                                 null, currentStep.id, 'AH_UDC_WorkbookStep__c');
            return;
         }
         //System.debug('$$$wbStepResponses.size(): ' + wbsResponses.size());
         Id AmadeusFileUploadRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
         if (String.isNotBlank(wbSteps[0].form__c) && wbsResponses.size() == 0 && (wbSteps[0].Form__r.RecordTypeId != AmadeusFileUploadRecordTypeId))
         {
            //Can not mark compelte if there are no responses
            ShowErrorMessage(System.Label.AH_UDC_ViewWorkbook_ResponseRequiredForMarkComplete);
            return;
         }

         //Only update the step if it's not completed
         if (wbSteps[0].StepStatus__c != AH_UDC_Constants.STEP_STATUS_COMPLETED && wbSteps[0].StepStatus__c != AH_UDC_Constants.STEP_STATUS_LOCKED)
         {
            //Send chatter if enabled - this calls external API so must execute before any data is written
            Boolean sendChatter = (Boolean) wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_ChatterWorkbookStepCompleted__c;
            if (sendChatter) AH_UDC_SharedWithoutSharing.CreateChatter((ID) wbSteps[0].Workbook__r.RelatedTo__c, wbSteps[0].id, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookStepComplete);

            wbSteps[0].StepStatus__c = AH_UDC_Constants.STEP_STATUS_COMPLETED;
            wbSteps[0].StepCompleted__c = Datetime.now();
            wbSteps[0].StepCompletedBy__c = UserInfo.getUserId();
            AH_UDC_SystemContext.UpdateObject(wbSteps[0]);
         }
         NotificationToShow = System.Label.AH_UDC_ViewWorkbook_StepMarkedComplete;

         if (!Test.isRunningTest()) { //Skip refreshSteps to prevent 101 error during test class execution
            refreshSteps();
         }
      }
      catch(Exception exc)
      {
         LogException('serverMarkStepComplete', 'An exception occurred Marking a Step Complete', null, exc, (currentStep == null ? null : currentStep.id), (currentStep == null ? null : 'AH_UDC_WorkbookStep__c'));
      }
   }

   //This is used by the client actionfunction to on regular intervals get updated information about the workbook since there are multiple UDC Contacts working on it
   public void serverUpdateTimer()
   {
      NotificationToShow = '';
      isPageLoad = false;
      refreshSteps();
   }

   public void refreshSteps()
   {
      try
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.refreshSteps');

         //Determine if the current user has the UDC System Admin permission set assigned to them
         String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
         Boolean isUDCSysAdmin = 0 < (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :System.UserInfo.getUserId() AND PermissionSet.Name = :UDCSystemAdminPermissionSetName];
         Boolean isUDCUserOrUDCWBAdmin = 0 < (Integer) [SELECT COUNT()
                                                        FROM PermissionSetAssignment
                                                        WHERE AssigneeId = :System.UserInfo.getUserId()
                                                        AND(PermissionSet.Name = :AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetWorkbookAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN)
                                                            or PermissionSet.Name = :AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetWorkbookUser', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER))];

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceViewWorkbookRefreshError', FALSE)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Refresh Workbook Steps'));

         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.refreshSteps - CheckViewWorkbookUserAccess: ' + AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess(workbook.id));
         //Verify the user is still logged in and has access to the workbook
         //TODO:ROBDEV - ON HOLD determine how to notify user that refresh is not possible WITHOUT causing form that is open and possibly not saved
         if (!AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess(workbook.id)) return;

         //Check for new comments to the logged in user's FeedItems
         CheckChatterFeedNotification();
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.refreshSteps - workbook.id: ' + workbook.id);
         //update workbook if it has changed

         //Get the workbook steps
         List<AH_UDC_WorkbookStep__c> wbSteps = [select id, StepStatus__c, Workbook__r.Archive__c,
                                                 Workbook__r.SentStatus__c, Prerequisite_Step__c, Prerequisite_Step__r.StepStatus__c,
                                                 Workbook__r.RelatedTo__r.AH_UDC_PropertyConfirmation__c
                                                 from AH_UDC_WorkbookStep__c
                                                 where Enabled__c = true and Workbook__c = :workbook.id
                                                 order by SortOrder__c asc];

         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.refreshSteps => wbSteps:' + wbSteps);
         //TODO: ROBDEV - ONHOLD - We should check wbSteps.size() > 0 before proceeding further
         workbook.propertyInfo.isPropertyConfirmed = Boolean.valueOf(wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_PropertyConfirmation__c);
         workbook.isCompleted = (wbSteps[0].Workbook__r.SentStatus__c == AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED);
         workbook.isArchived = wbSteps[0].Workbook__r.Archive__c;
         Boolean allStepsComplete = true;
         workbook.completedSteps = 0;

         //Update Steps for Display in page
         Map<Id, AH_UDC_WorkbookStep__c> refreshWorkbookSteps = new Map<Id, AH_UDC_WorkbookStep__c> ();
         for (AH_UDC_WorkbookStep__c wbStep : wbSteps)
         {
            refreshWorkbookSteps.put(wbStep.Id, wbStep);
         }

         workbook.allStepsComplete = true;
         for (AH_UDC_CommunityWorkbook.WorkbookStep wbs : workbook.steps)
         {
            AH_UDC_WorkbookStep__c refreshWorkbookStep = refreshWorkbookSteps.get(wbs.id);

            wbs.status = String.valueOf(refreshWorkbookStep.StepStatus__c);
            wbs.isLocked = false;
            if (!(isUDCUserOrUDCWBAdmin || isUDCSysAdmin) && wbs.status == AH_UDC_Constants.STEP_STATUS_LOCKED) wbs.isLocked = true; //Locked status only impacts Community users
            if (wbs.status != AH_UDC_Constants.STEP_STATUS_COMPLETED && wbs.status != AH_UDC_Constants.STEP_STATUS_LOCKED) workbook.allStepsComplete = false;
            //Adding completed class to display green color for locked step
            wbs.css = String.valueOf(refreshWorkbookStep.StepStatus__c).replaceAll(AH_UDC_Constants.STEP_STATUS_LOCKED, AH_UDC_Constants.STEP_STATUS_COMPLETED);
            wbs.css = wbs.css.replaceAll(' ', '-').toLowerCase();
            wbs.cssI = 'default-step-i';
            if (wbs.status == AH_UDC_Constants.STEP_STATUS_COMPLETED || wbs.status == AH_UDC_Constants.STEP_STATUS_LOCKED) wbs.cssI = 'fas fa-check';

            wbs.cssCurrent = '';
            if (currentStep != null && currentStep.id == wbs.id)
            {
               wbs.cssCurrent = 'current-step';
            }

            //If step has prerequisite step not completed then check if it is completed now
            if (wbs.prerequisiteStepPosition != null && wbs.isPrerequisiteStepNotCompleted) {
               //For the workbook with Steps In Order set to true, wbs.prerequisiteStepPosition will have the value of position of previous step
               AH_UDC_WorkbookStep__c objPrereqStep = wbSteps[wbs.prerequisiteStepPosition - 1];

               AH_UDC_LogHelper.Debug('refreshSteps => objPrereqStep.StepStatus__c : ' + objPrereqStep.StepStatus__c);
               //Check if prerequisite step is completed or not
               wbs.isPrerequisiteStepNotCompleted = objPrereqStep.StepStatus__c != AH_UDC_Constants.STEP_STATUS_COMPLETED
               && objPrereqStep.StepStatus__c != AH_UDC_Constants.STEP_STATUS_LOCKED;
            }

            //Determine number of steps complete
            if (refreshWorkbookStep.StepStatus__c == AH_UDC_Constants.STEP_STATUS_COMPLETED || refreshWorkbookStep.StepStatus__c == AH_UDC_Constants.STEP_STATUS_LOCKED)
            {
               workbook.completedSteps++;
            }
            else
            {
               allStepsComplete = false;
            }
         }

         AH_UDC_LogHelper.Debug('refreshSteps => currentStep : ' + currentStep);
         if(currentStep != null && String.isNotBlank(String.valueOf(currentStep.id))
            && currentStep.isAmadeusFileUpload != true) {
            List<SelectOption> lstLastUpdatedByUsers = GetStepLastUpdatedByUsersList(currentStep.id);
            if(lstLastUpdatedByUsers != null && lstLastUpdatedByUsers.size() > 0) {
               currentStep.lastUpdatedByUsersList = lstLastUpdatedByUsers;
               currentStep.selectedLastUpdatedById = lstLastUpdatedByUsers[0].getValue();
            }
         }
      }
      catch(Exception exc)
      {
         //TODO: Need label for user facing text
         LogException('refreshSteps', 'An exception occurred refreshing workbook steps', 'There was an issue refreshing steps; you may not see workbook updates from other users.',
                      exc, (workbook == null ? null : workbook.id), (workbook == null ? null : 'AH_UDC_Workbook__c'));
      }
   }

   //This method is called by the client actionfunction to move to the next not completed step
   public void serverChangeToNextStepNotCompleted() {
      //Find the next step not completed or locked
      try
      {
         NotificationToShow = '';
         isPageLoad = false;
         //System.debug('$$$serverChangeToNextStepNotCompleted');
         if (!Test.isRunningTest()) { //Skip refreshSteps to prevent 101 error during test class execution
            refreshSteps();
         }

         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverChangeToNextStepNotCompleted');
         Boolean foundStep = false;

         AH_UDC_LogHelper.debug('$$$foundStep: b4: ' + foundStep);
         for (AH_UDC_CommunityWorkbook.WorkbookStep wbs : workbook.steps)
         {
            AH_UDC_LogHelper.debug('$$$foundStep:  wbs.status: ' + wbs.status);
            if (wbs.status != AH_UDC_Constants.STEP_STATUS_LOCKED && wbs.status != AH_UDC_Constants.STEP_STATUS_COMPLETED)
            {
               changeToPositionNumber = wbs.position;
               AH_UDC_LogHelper.debug('$$$foundStep:  changeToPositionNumber: ' + changeToPositionNumber);
               foundStep = true;
               break;
            }
         }
         AH_UDC_LogHelper.debug('$$$foundStep: after: ' + foundStep);
         if (!foundStep)
         {
            changeToPositionNumber = - 1; //-1 = the "Complete" step
         }
         serverChangeToStep();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception exc)
      {
         LogException('serverChangeToNextStepNotCompleted', 'An exception occurred determining the next step', null,
                      exc, (workbook == null ? null : workbook.id), (workbook == null ? null : 'AH_UDC_Workbook__c'));
      }
   }

   //This method is called by the actionfuction to change to a specific step
   public void serverChangeToStep() {
      try
      {
         NotificationToShow = '';
         isPageLoad = false;
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverChangeToStep');
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverChangeToStep - changeToPositionNumber:' + changeToPositionNumber);
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverChangeToStep - currentPosition:' + currentPosition);

         //Validate that changeToPositionNumber is a valid step
         if (changeToPositionNumber == 0) //START
         {
            currentPosition = 0;
            currentStep = new AH_UDC_CommunityWorkbook.WorkbookStep();
            currentStep.helpurl = '';
         }
         else if (changeToPositionNumber == - 1) //COMPLETE
         {
            currentPosition = - 1;
            currentStep = new AH_UDC_CommunityWorkbook.WorkbookStep();
            currentStep.helpurl = '';
         }
         else //Normal Steps
         {
            Integer iStep = Integer.valueOf(changeToPositionNumber) - 1;

            //Find Change To Step
            AH_UDC_CommunityWorkbook.WorkbookStep moveToStep = workbook.steps[iStep];

            //TODO:ROBDEV-ONHOLD Check if step is not locked, workbook is not locked, get updated status
            AH_UDC_LogHelper.Debug('###moveToStep.id: ' + moveToStep.id);
            AH_UDC_LogHelper.Debug('###moveToStep.name: ' + moveToStep.name);
            changeToStepUrl = AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrl(moveToStep.id);
            //AH_UDC_LogHelper.Debug('###changeToStepUrl: ' + changeToStepUrl);

            //TODO:ROBDEV-ONHOLD if allowed move to new step
            currentStep = moveToStep;
            AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverChangeToStep: currentStep : Name: ' + currentStep.name);
            currentStep.url = changeToStepUrl;
            currentPosition = changeToPositionNumber;
            changeToStepMessage = '';

            //Check if current Step is a File Upload step
            if (currentStep.isAmadeusFileUpload) serverGetFiles();
            else {
               List<SelectOption> lstLastUpdatedByUsers = GetStepLastUpdatedByUsersList(currentStep.id);
               if(lstLastUpdatedByUsers != null && lstLastUpdatedByUsers.size() > 0) {
                  currentStep.lastUpdatedByUsersList = lstLastUpdatedByUsers;
                  currentStep.selectedLastUpdatedById = lstLastUpdatedByUsers[0].getValue();
               }
            }
         }
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception exc)
      {
         LogException('serverChangeToStep', 'An exception occurred determining the next step', null, exc, (workbook == null ? null : workbook.id), (workbook == null ? null : 'AH_UDC_Workbook__c'));
      }
   }

   private List<SelectOption> GetStepLastUpdatedByUsersList(Id StepId) {
      try {
         AH_UDC_LogHelper.Debug('GetStepLastUpdatedByUsersList => StepId : ' + StepId);
         if(String.isBlank(String.valueOf(StepId))) {
            LogException('GetStepLastUpdatedByUsersList', 'Error: StepId is blank.', null, null, null, null);
            return null;
         }

         List<SelectOption> lstLastUpdatedByUsers = new List<SelectOption>();
         List<AH_UDC_WorkbookStepResponse__c> lstStepResponses = [SELECT Response__c, Response__r.Responded__c, Response__r.Responder__r.Name
                                                                  FROM AH_UDC_WorkbookStepResponse__c
                                                                  WHERE WorkbookStep__c = :StepId
                                                                  ORDER BY Response__r.Responded__c DESC ];
         Integer index = 0;
         for(AH_UDC_WorkbookStepResponse__c objStepResponse : lstStepResponses) {
            //Gives a string version of the date formatted in the current user's locale
            String strCreatedDate = objStepResponse.Response__r.Responded__c.format();
            lstLastUpdatedByUsers.add(new SelectOption(objStepResponse.Response__c,
                                                      (String.isEmpty(objStepResponse.Response__r.Responder__r.Name) ? '' : objStepResponse.Response__r.Responder__r.Name + ' ') + strCreatedDate,
                                                      index > 0)); //Make all options disabled other than 1st
            index++;
         }
         return lstLastUpdatedByUsers;
      }
      catch(Exception exc) {
         LogException('GetStepLastUpdatedByUsersList', 'An exception occurred in getting last updated by users list for the StepId: ' + StepId, null, exc, (workbook == null ? null : workbook.id), (workbook == null ? null : 'AH_UDC_Workbook__c'));
         return null;
      }
   }

   //This is used to determine if the UDC Contact has unread chatter comments
   public void CheckChatterFeedNotification() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.CheckChatterFeedNotification');

      List<FeedComment> lstFeedComments = null;
      User objUser = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         //Change the default back to false;
         chatterUpdate = false;
         //System.debug('IsCommunityView => ' + IsCommunityView);
         //System.debug('Workbook => ' + Workbook);
         if (!IsCommunityView) return; //Chatter alert only applies to Community View
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.CheckChatterFeedNotification - Workbook.documentId: ' + Workbook.documentId);
         if (String.isNotBlank(Workbook.documentId)) {
            objUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() AND IsActive = true];
            //System.debug('objUser => ' + objUser);
            if (objUser != null)
            {
               List<AH_UDC_Contact__c> udcContactDetails = [SELECT ChatterLastViewed__c, Id
                                                            FROM AH_UDC_Contact__c
                                                            WHERE Document__c = :Workbook.documentId AND Contact__c = :objUser.ContactId];
               if (udcContactDetails.size() == 0) return;

               List<Id> lstFeedItemIds = new List<Id> ();
               List<FeedItem> lstFeedItems = [SELECT Id
                                              FROM FeedItem
                                              WHERE ParentId = :Workbook.documentId AND CreatedById = :objUser.Id];
               //If there are no feed items just return the default of false
               if (lstFeedItems.size() == 0) return;
               
               //Get the IDs of the Feed Items
               for (FeedItem feedItem : lstFeedItems)
               {
                  lstFeedItemIds.add(feedItem.id);
               }
               if (udcContactDetails[0].ChatterLastViewed__c == null)
               {
                  //It doesn't matter how many records just that one exists
                  lstFeedComments = [SELECT Id
                                     FROM FeedComment
                                     WHERE ParentId = :Workbook.documentId
                                     AND CreatedById != :objUser.Id
                                     AND FeedItemId = :lstFeedItemIds
                                     LIMIT 1];
                  if (lstFeedComments != null && lstFeedComments.size() > 0) {
                     chatterUpdate = true;
                  }
               }
               else
               {
                  //It doesn't matter how many records just that one exists
                  lstFeedComments = [SELECT Id
                                     FROM FeedComment
                                     WHERE ParentId = :Workbook.documentId
                                     AND CreatedById != :objUser.Id
                                     AND CreatedDate >= :udcContactDetails[0].ChatterLastViewed__c
                                     AND FeedItemId = :lstFeedItemIds
                                     LIMIT 1];
                  if (lstFeedComments != null && lstFeedComments.size() > 0) {
                     chatterUpdate = true;
                  }
               }
            }
         }
      }
      catch(Exception exc) {
         LogException('CheckChatterFeedNotification', 'An exceptiton occurred determining if the user has unread chatter comments', null, exc, String.valueOf(Workbook.documentId), 'NI_Documentation__c');
      }
      finally {
         lstFeedComments = null;
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessageToLog, String strErrorMessageToDisplay, Exception exc, String relatedRecordId, string relatedRecordType) {
      //NOTE: this is NOT using the shared LogException since Page Messages are used only on controller load and not on Action Functions
      try {
         AH_UDC_LogHelper.Debug('Exception Occurred in the method ' + strMethodName);
         AH_UDC_LogHelper.Debug('Exception : ' + (exc != null ? (exc.getMessage() + ' at Line Number ' + exc.getLineNumber()) : strErrorMessageToLog));
         AH_UDC_LogHelper.Log(exc != null ? AH_UDC_LogHelper.LogLevel_EXC : AH_UDC_LogHelper.LogLevel_ERROR,
                              LogFunctionalArea,
                              strMethodName, strErrorMessageToLog,
                              exc, null, null);
         ShowErrorMessage(strErrorMessageToDisplay);

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') { Integer a = 1 / 0; }
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.LogException - Exception: ' + ex);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'LogException',
                              'An exception occurred in LogException method',
                              ex, null, null);
      }
   }

   public void serverGetFiles()
   {
      try {
         NotificationToShow = '';
         isPageLoad = false;
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
         List<PermissionSetAssignment> lstPSA = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = :AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE];
         Set<Id> setServiceUserIds = new Set<Id> ();
         for (PermissionSetAssignment psa : lstPSA) {
            setServiceUserIds.Add(psa.AssigneeId);
         }
         UploadedFileList = [SELECT ContentDocument.title, ContentDocument.CreatedDate, ContentDocumentId FROM ContentDocumentLink
                             WHERE IsDeleted = false AND LinkedEntityId = :workbook.documentId
                             AND ContentDocument.OwnerId IN :setServiceUserIds
                             ORDER BY ContentDocument.CreatedDate DESC];
      }
      catch(Exception exc) {
         LogException('serverGetFiles', 'An exception occurred while fetching files', null, exc, String.valueOf(workbook.documentId), 'NI_Documentation__c');
      }
   }

   // handle the action of the commandlink
   public void serverDeleteFile() {
      try {
         NotificationToShow = '';
         isPageLoad = false;
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         if (!AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess(workbook.id)) {
            LogException('serverDeleteFile', 'Error: User does not have access to current Workbook. User Id:' + System.UserInfo.getUserId() + ' and Workbook Id: ' + workbook.id, 
               null, null, null, null);
            return;
         }

         if (String.isBlank(DeleteFileID)) {
            LogException('serverDeleteFile', 'Error: DeleteFileID is blank.', null, null, null, null);
            return;
         }

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceFileDeleteError', FALSE))
         {
            throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'File Delete'));
         }

         List<ContentDocumentLink> objCDL = [SELECT ContentDocumentId FROM ContentDocumentLink
                                             WHERE IsDeleted = false AND LinkedEntityId = :workbook.documentId
                                             AND ContentDocumentId = :DeleteFileID];
         if (objCDL.size() > 0) {
            List<ContentDocument> lstCD = [SELECT Id FROM ContentDocument WHERE Id = :DeleteFileID];
            if (lstCD.size() > 0) {
               AH_UDC_SystemContext.DeleteObjects(lstCD);
               serverGetFiles();
            }
         }
         else {
            LogException('serverDeleteFile', 'Error: Content Document Id (' + DeleteFileID + ') does not belong to current NIDoc (' + workbook.documentId + ') / Workbook (' + workbook.id + ')',
                         null, null, String.valueOf(workbook.documentId), 'NI_Documentation__c');
            return;
         }
      }
      catch(Exception exc) {
         LogException('serverDeleteFile', 'An exception occurred while deleting files', null, exc, String.valueOf(workbook.documentId), 'NI_Documentation__c');
      }
   }

   //Set Currect Step to in progress (used for file upload)
   public void serverSetStepInProgress() {
      try {
         NotificationToShow = '';
         isPageLoad = false;
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         if (!AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess(workbook.id)) {
            LogException('serverSetStepInProgress', 'Error: User does not have access to current Workbook. User Id:' + System.UserInfo.getUserId() + ' and Workbook Id: ' + workbook.id, null, null, null, null);
            return;
         }
         //Only change the step status if the status is still new
         List<AH_UDC_WorkbookStep__c> wbUpdateSteps = [select Id, StepStatus__c FROM AH_UDC_WorkbookStep__c WHERE Id = :currentStep.id FOR UPDATE];
         if (wbUpdateSteps.size() == 1 && !AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceViewWorkbookFileUploadStepInProgressError', false))
         {
            if (wbUpdateSteps[0].StepStatus__c == AH_UDC_Constants.STEP_STATUS_NEW)
            {
               wbUpdateSteps[0].StepStatus__c = AH_UDC_Constants.STEP_STATUS_IN_PROGRESS;
               update wbUpdateSteps[0];
            }
            currentStep.status = AH_UDC_Constants.STEP_STATUS_IN_PROGRESS;
            workbook.steps[currentPosition - 1].status = wbUpdateSteps[0].StepStatus__c;
            workbook.steps[currentPosition - 1].css = String.valueOf(currentStep.status).replaceAll(' ', '-').toLowerCase();
         }
         else
         {
            LogException('serverSetStepInProgress', 'Error: Workbook Step Not Found. User Id:' + System.UserInfo.getUserId() + ' and Workbook Step Id: ' + currentStep.id, null, null, null, null);
            return;
         }
      }
      catch(Exception exc) {
         LogException('serverSetStepInProgress', 'An exception occurred while changing step status to in-progress. Step Id: ' + currentStep.id, null,
                      exc, String.valueOf(workbook.documentId), 'NI_Documentation__c');
      }
   }
}