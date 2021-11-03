/***********************************************************************************************
  Name            : AH_UDC_ViewWorkbook
  Author          : Rob Stevens (Rob.Stevens@amadeus.com)
  Created Date    : 2021-04-12
  Description     : Controller class for View Workbook Page
 ************************************************************************************************/
public without sharing class AH_UDC_ViewWorkbook {
   private string LogFunctionalArea = 'ViewWorkbook'; //This is used for AH_UDC_Log Entries being written on this page
   public Boolean DisplayConsoleLogMessages{ get; set; } { DisplayConsoleLogMessages= AH_UDC_ConfigHelper.GetBoolean('AH_UDC_ViewWorkbookDisplayConsoleLogMessages',false);}

   public Integer CollapsedMenuCirclesPerPage{ get; set; } { CollapsedMenuCirclesPerPage= AH_UDC_ConfigHelper.GetInteger('AH_UDC_CollapsedMenuCirclesPerPage',10);}
   public Integer CollapsedMenuCirclePage{ get; set; } { CollapsedMenuCirclePage= 1;}
   public Boolean ShowCollapsedMenuUpNavigation{ get; set; } { ShowCollapsedMenuUpNavigation= false;}
   public Boolean ShowCollapsedMenuDownNavigation{ get; set; } { ShowCollapsedMenuDownNavigation= false;}
   public Integer collapsedMenuMoveDirection{ get; set; } { collapsedMenuMoveDirection= 0;}
   

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
   public Integer currentPosition { get; set; } //-1 is End, 0 is start, all other steps are the same as their order.
   public Integer changeToPositionNumber { get; set; } //-1 is End, 0 is start, all other steps are the same as their order.
   public String changeToStepUrl { get; set; }
   public String changeToStepMessage { get; set; }

   //This is used to cause the client page to show a generic error message
   public Boolean ShowErrorMessage { get; set; } { ShowErrorMessage = false; }

   //This is used to cause the client page to show a generic error message
   public string NotificationToShow { get; set; } { NotificationToShow = ''; }
   public boolean CallbackErrorOccurred { get; set; } { CallbackErrorOccurred = false; }

   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }

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
      try
      {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         if (String.isBlank(ApexPages.currentPage().getParameters().get('id'))) {
            LogException('Constructor', 'Workbook Id not found', null);
            return;
         }
         WorkbookId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));

         workbook = new AH_UDC_CommunityWorkbook();
         currentPosition = 0;

         //Trace for Loading Workbook
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE, 'ViewWorkbook Page',
                              'AH_UDC_ViewWorkbook', 'The User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName()
                              + ') is opening UDC Workbook ID: ' + WorkbookId);

         //Determine if page is loading from Community Site
         if (ApexPages.currentPage().getParameters().get('community') == 'false') {
            IsCommunityView = false;
         }
         AH_UDC_LogHelper.Debug('IsCommunityView value=>' + IsCommunityView);

         //Check that the user has access
         Boolean userHasAccess = AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess(WorkbookId);
         AH_UDC_LogHelper.Debug('###userHasAccess: ' + userHasAccess);

         iF (!userHasAccess)
         {
            AH_UDC_LogHelper.Debug('###AH_UDC_ViewWorkbook - User does not have access to workbook');
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR, 'ViewWorkbook Page',
                                 'AH_UDC_ViewWorkbook', 'The User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName()
                                 + ') does not have access to requested UDC Workbook ID: ' + WorkbookId);
            ShowErrorMessage();
            return;
         }

         //Get the workbook steps
         List<AH_UDC_WorkbookStep__c> wbSteps = [select id, name, description__c,
                                                 Workbook__r.RelatedTo__r.Id, Workbook__r.RelatedTo__r.Document_Name__c, Workbook__r.RelatedTo__r.AH_UDC_WorkbookDueDate__c,
                                                 Workbook__r.StepsinOrder__c, Workbook__r.SentStatus__c,
                                                 SortOrder__c, StepStatus__c, URL__c, form__c, help__c,
                                                 Prerequisite_Step__c, Prerequisite_Step__r.StepStatus__c,
                                                 Workbook__r.RelatedTo__r.AH_UDC_PropertyConfirmation__c,
                                                 Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c
                                                 from AH_UDC_WorkbookStep__c
                                                 where Enabled__c = true and Workbook__c = :WorkbookId order by SortOrder__c asc];
         workbook.id = WorkbookId;
         workbook.isCompleted = (wbSteps[0].Workbook__r.SentStatus__c == AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED);
         workbook.documentId = String.valueOf(wbSteps[0].Workbook__r.RelatedTo__r.Id);
         workbook.name = String.valueOf(wbSteps[0].Workbook__r.RelatedTo__r.Document_Name__c);
         workbook.propertyInfo.id = String.valueOf(wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c);
         workbook.propertyInfo.isPropertyConfirmed = Boolean.valueOf(wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_PropertyConfirmation__c);
         if (wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_WorkbookDueDate__c != null) workbook.dueDate = wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_WorkbookDueDate__c;

         if (String.isNotBlank(workbook.propertyInfo.id))
         {
            // Get property account details
            List<AH_UDC_PropertyAccount__c> propertyAccounts = [SELECT PropertyName__c,
                                                                AddressLine1__c, City__c, StateProvince__c,
                                                                PostalCode__c, Country__c, Phone__c
                                                                FROM AH_UDC_PropertyAccount__c
                                                                WHERE Id = :workbook.propertyInfo.id];
            workbook.propertyInfo.address = GetAddress(propertyAccounts[0]);
            workbook.propertyInfo.phone = propertyAccounts[0].Phone__c;
            workbook.propertyInfo.name = propertyAccounts[0].PropertyName__c;
         }

         Integer Position = 1;
         workbook.allStepsComplete = true;

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
            if (wbs.status != AH_UDC_Constants.STEP_STATUS_COMPLETED && wbs.status != AH_UDC_Constants.STEP_STATUS_LOCKED) workbook.allStepsComplete = false;
            wbs.css = String.valueOf(wbStep.StepStatus__c).replaceAll(' ', '-').toLowerCase();
            wbs.cssI = 'default-step-i';
            wbs.cssCurrent = '';
            if (wbs.status == AH_UDC_Constants.STEP_STATUS_COMPLETED || wbs.status == AH_UDC_Constants.STEP_STATUS_LOCKED) wbs.cssI = 'fas fa-check';

            if (String.isNotBlank(wbStep.URL__c))
            {
               wbs.url = wbStep.URL__c;
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
               if (workbook.propertyInfo.isPropertyConfirmed)
               {
                  //Determine/Set the current step
                  if (currentStep == null)
                  {
                     currentStep = wbs;
                     wbs.cssCurrent += 'current-step';
                     if (String.isNotBlank(wbStep.Form__c)) currentStep.url = AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrl(wbStep.id);
                     currentPosition = Position;
                  }
               }
            }
            Position++;
         }

         //Set Collapsed Menu Step Visibility
         if (currentPosition==0 || currentPosition==-1)
         {
            CollapsedMenuCirclePage = 1; //Default to first page of cicles
            ShowCollapsedMenuUpNavigation = false;
            if (workbook.steps.size() > CollapsedMenuCirclesPerPage) ShowCollapsedMenuDownNavigation = true;
         }
         else
         {
            //Determine Collapsed Circle Page
            Decimal calcMaxPages = (Decimal)workbook.steps.size() / (Decimal)CollapsedMenuCirclesPerPage;
            Integer maxPages = (integer)calcMaxPages.round(System.RoundingMode.UP);
            for(integer findCirclePage = 1; findCirclePage <= maxPages; findCirclePage++)
            {
               if ((currentPosition > CollapsedMenuCirclesPerPage * (findCirclePage-1)) && 
                  (currentPosition <= CollapsedMenuCirclesPerPage * findCirclePage))
               {
                  CollapsedMenuCirclePage = findCirclePage;
                  break;
               }
            }
            if (CollapsedMenuCirclePage > 1) ShowCollapsedMenuUpNavigation = true;
            if (CollapsedMenuCirclePage < maxPages) ShowCollapsedMenuDownNavigation = true;
         }
         SetCollapsedMenuDisplay();

         CheckChatterFeedNotification();
         Workbook.totalSteps = workbook.steps.size();

         //If all Steps are complete set the current position to the Complete step
         if (workbook.steps.size() == workbook.completedSteps) currentPosition = - 1;
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + ' - Exception on page load: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'AH_UDC_ViewWorkbook',
                              'An exception occurred loading workbook for user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook ID: ' + WorkbookId,
                              exc, null, null);
         ShowErrorMessage();
      }
      finally
      {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
      }
   }

   public void serverCollapsedMenuMove()
   {
      //Determine Collapsed Circle Page
      System.Debug('$$$workbook.steps.size(): ' + workbook.steps.size());
      System.Debug('$$$CollapsedMenuCirclesPerPage: ' + CollapsedMenuCirclesPerPage);
      Decimal calcMaxPages = (Decimal)workbook.steps.size() / (Decimal)CollapsedMenuCirclesPerPage;
      Integer maxPages = (integer)calcMaxPages.round(System.RoundingMode.UP);
      System.Debug('$$$maxPages: ' + maxPages);

      System.Debug('$$$collapsedMenuMoveDirection: ' + collapsedMenuMoveDirection);
      if(collapsedMenuMoveDirection ==1  && CollapsedMenuCirclePage + 1 <= maxPages) CollapsedMenuCirclePage++;
      if(collapsedMenuMoveDirection ==-1  && CollapsedMenuCirclePage > 1) CollapsedMenuCirclePage--;

      System.Debug('$$$CollapsedMenuCirclePage: ' + CollapsedMenuCirclePage);

      //Set Collapsed Menu Step Visibility
      if (CollapsedMenuCirclePage==1)
      {
         ShowCollapsedMenuUpNavigation = false;
         ShowCollapsedMenuDownNavigation = workbook.steps.size() > CollapsedMenuCirclesPerPage;
      }
      else
      {
         ShowCollapsedMenuUpNavigation = CollapsedMenuCirclePage > 1;
         ShowCollapsedMenuDownNavigation = CollapsedMenuCirclePage < maxPages;
      }
      System.Debug('$$$ShowCollapsedMenuUpNavigation: ' + ShowCollapsedMenuUpNavigation);
      System.Debug('$$$ShowCollapsedMenuDownNavigation: ' + ShowCollapsedMenuDownNavigation);
      SetCollapsedMenuDisplay();
   }

   private void SetCollapsedMenuDisplay()
   {
      //Set Collapsed Menu Step Visibility
      System.debug('$$$CollapsedMenuCirclePage:' + CollapsedMenuCirclePage);
      integer iCollapsedStepDisplayStartPosition = ((CollapsedMenuCirclePage -1) * CollapsedMenuCirclesPerPage) + 1;
      integer iCollapsedStepDisplayStopPosition = CollapsedMenuCirclePage * CollapsedMenuCirclesPerPage;
      System.debug('$$$iCollapsedStepDisplayStartPosition:' + iCollapsedStepDisplayStartPosition);
      System.debug('$$$iCollapsedStepDisplayStopPosition:' + iCollapsedStepDisplayStopPosition);
      for(AH_UDC_CommunityWorkbook.WorkbookStep wbs: workbook.steps)
      {
         System.debug('$$$evalcss for step position:' + wbs.position);
         if(wbs.position >= iCollapsedStepDisplayStartPosition && 
            wbs.position <= iCollapsedStepDisplayStopPosition)
         {
            System.debug('$$$evalcss for step position: Dont Hide');
            //Show Collapsed Step
            wbs.cssCollapsedMenuStep = '';
         }
         else
         {
            System.debug('$$$evalcss for step position: Hide');
            wbs.cssCollapsedMenuStep = 'display_none';
         }
      }
   }

   //Create property address string
   private string GetAddress(AH_UDC_PropertyAccount__c propertyAccount) {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.GetAddress');
      string PropertyAddress = '';
      try {
         List<String> lstAddress = null;
         lstAddress = new List<String> ();
         if (String.isNotBlank(propertyAccount.AddressLine1__c)) {
            lstAddress.add(propertyAccount.AddressLine1__c);
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
         if (lstAddress != null && lstAddress.Size() > 0) {
            PropertyAddress = String.join(lstAddress, ', ');
         }
      } catch(Exception exc) {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.GetAddress - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'GetAddress',
                              'An exception occurred formatting the address',
                              exc, String.valueOf(propertyAccount.id), 'AH_UDC_PropertyAccount__c');
         throw exc;
      } finally {
      }
      return PropertyAddress;
   }

   //This method is used to show a single error message to the user
   public void ShowErrorMessage()
   {
      try
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ShowErrorMessage');
         if (!ShowErrorMessage)
         {
            ShowErrorMessage = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ShowErrorMessage - Exception: ' + exc);
         //NOTE: There is no throw or log for this since it is called by the page load
         ShowErrorMessage = true;
      }
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML retrictions
   public void serverLogMessages()
   {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverLogMessages');
      try
      {
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0)
         {
            insert(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();
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

   public void serverSubmit()
   {
      try
      {
         List<AH_UDC_Workbook__c> workbooks = [SELECT id, CompletedDate__c, SentStatus__c, RelatedTo__c, CompletedBy__c, RelatedTo__r.AH_UDC_ChatterWorkbookCompleted__c
                                               FROM ah_udc_workbook__c
                                               WHERE id = :workbook.id];
         if (workbooks[0].SentStatus__c == AH_UDC_Constants.SENT_STATUS_IN_PROGRESS)
         {
            workbooks[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
            workbooks[0].CompletedDate__c = Datetime.now();
            workbooks[0].CompletedBy__c = UserInfo.getUserId();
            update workbooks[0];

            //Send chatter if enabled
            Boolean sendChatter = (Boolean) workbooks[0].RelatedTo__r.AH_UDC_ChatterWorkbookCompleted__c;
            if (sendChatter) AH_UDC_SharedWithoutSharing.CreateChatter((ID) workbooks[0].RelatedTo__c, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookComplete);
         }
         NotificationToShow = System.Label.AH_UDC_Workbook_Completion_Confirmation_Msg;
         refreshSteps();
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverConfirmProperty - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'serverConfirmProperty',
                              'An exception occurred Confirming the Property',
                              exc, null, null);
         ShowErrorMessage();
      }
   }

   public void serverConfirmProperty() {
      try
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ConfirmFromPropertyInformation');

         //Select the record with a For Update Lock to ensure another user hasn't changed the data
         List<AH_UDC_Workbook__c> workbooks = [SELECT SentStatus__c, RelatedTo__c,
                                               RelatedTo__r.AH_UDC_PropertyConfirmation__c, RelatedTo__r.AH_UDC_PropertyConfirmationAccepted_Date__c, RelatedTo__r.AH_UDC_ChatterWorkbookAccessed__c
                                               FROM AH_UDC_Workbook__c
                                               WHERE Id = :workbook.id FOR UPDATE];

         if (workbooks.size() == 0) {
            //TODO return Error
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
            update niDoc;

            workbook.propertyInfo.isPropertyConfirmed = true;
         }

         //If neeeded, update Workbook Sent Status from New to In Progress
         if (workbooks[0].SentStatus__c == AH_UDC_Constants.SENT_STATUS_NEW) {
            AH_UDC_Workbook__c workbookUpdateStatus = new AH_UDC_Workbook__c(
                                                                             Id = workbook.id,
                                                                             SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS);
            update workbookUpdateStatus;

            //Send Chatter
            //Failure to create chatter will be logged and not cause exception or be shown to community user
            if (workbooks[0].RelatedTo__c != null &&
                workbooks[0].RelatedTo__r.AH_UDC_ChatterWorkbookAccessed__c == true)
            AH_UDC_SharedWithoutSharing.CreateChatter((ID)workbooks[0].RelatedTo__c, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookAccessed);
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverConfirmProperty - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'serverConfirmProperty',
                              'An exception occurred Confirming the Property',
                              exc, null, null);
         ShowErrorMessage();
      }
   }

   //Used to mark the current step complete; can only be set to complete if the step has a response
   public void serverMarkStepComplete() {
      System.debug('$$$serverMarkStepComplete');
      try
      {
         List<AH_UDC_WorkbookStep__c> wbSteps = [select id, StepStatus__c, StepCompleted__c, form__c,
                                                 Workbook__r.RelatedTo__r.AH_UDC_ChatterWorkbookStepCompleted__c
                                                 from AH_UDC_WorkbookStep__c
                                                 where id = :currentStep.id FOR UPDATE];
         List<AH_UDC_Response__c> wbStepResponses = [select id
                                                     from AH_UDC_Response__c
                                                     where WorkbookStep__r.id = :currentStep.id and IsMostRecentResponse__c = true];
         if (wbSteps.size() != 1)
         {
            NotificationToShow = System.Label.AH_UDC_Common_Error_Message; //This is the generic error shown to community users
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                 LogFunctionalArea, 'serverMarkStepComplete',
                                 'Request Step Not Found',
                                 null, currentStep.id, 'AH_UDC_WorkbookStep__c');
            return;
         }
         System.debug('$$$wbStepResponses.size(): ' + wbStepResponses.size());
         if (String.isNotBlank(wbSteps[0].form__c) && wbStepResponses.size() == 0)
         {
            //Can not mark compelte if there are no responses
            NotificationToShow = System.Label.AH_UDC_ViewWorkbook_ResponseRequiredForMarkComplete;
            return;
         }
         if (String.valueOf(wbSteps[0].StepStatus__c) != AH_UDC_Constants.STEP_STATUS_COMPLETED)
         {
            //Only update the step if it's not completed
            wbSteps[0].StepStatus__c = AH_UDC_Constants.STEP_STATUS_COMPLETED;
            wbSteps[0].StepCompleted__c = Datetime.now();
            update(wbSteps[0]);

            //Send chatter if enabled
            Boolean sendChatter = (Boolean) wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_ChatterWorkbookStepCompleted__c;
            if (sendChatter) AH_UDC_SharedWithoutSharing.CreateChatter((ID) wbSteps[0].Workbook__r.RelatedTo__c, wbSteps[0].id, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookStepComplete);
         }
         NotificationToShow = System.Label.AH_UDC_ViewWorkbook_StepMarkedComplete;
         refreshSteps();
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverMarkStepComplete - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'serverMarkStepComplete',
                              'An exception occurred Marking a Step Complete',
                              exc, (currentStep == null?null:currentStep.id), (currentStep == null?null:'AH_UDC_WorkbookStep__c'));
         ShowErrorMessage();
      }
   }

   //This is used by the client actionfunction to on regular intervals get updated information about the workbook since there are multiple UDC Contacts working on it
   public void serverUpdateTimer()
   {
      refreshSteps();
   }

   public void refreshSteps()
   {
      try
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverUpdateTimer');

         //Verify the user is still logged in and has access to the workbook
         if (!AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess(workbook.id)) return; //TODO: determine how to notify user that refresh is not possible WITHOUT causing form that is open and possibly not saved

         //Check for new comments to the logged in user's FeedItems
         CheckChatterFeedNotification();

         //update workbook if it has changed

         //Get the workbook steps
         List<AH_UDC_WorkbookStep__c> wbSteps = [select id, StepStatus__c,
                                                 Workbook__r.SentStatus__c,
                                                 Workbook__r.RelatedTo__r.AH_UDC_PropertyConfirmation__c
                                                 from AH_UDC_WorkbookStep__c
                                                 where Enabled__c = true and Workbook__c = :workbook.id
                                                 order by SortOrder__c asc];
         workbook.propertyInfo.isPropertyConfirmed = Boolean.valueOf(wbSteps[0].Workbook__r.RelatedTo__r.AH_UDC_PropertyConfirmation__c);
         workbook.isCompleted = (wbSteps[0].Workbook__r.SentStatus__c == AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED);

         Boolean allStepsComplete = true;
         workbook.completedSteps = 0;

         //Update Steps for Display in page
         Map<Id, AH_UDC_WorkbookStep__c> refreshWorkbookSteps = new Map<Id, AH_UDC_WorkbookStep__c> ();
         for (AH_UDC_WorkbookStep__c wbStep : wbSteps)
         {
            refreshWorkbookSteps.put(wbStep.Id, wbStep);
         }
         for (AH_UDC_CommunityWorkbook.WorkbookStep wbs : workbook.steps)
         {
            AH_UDC_WorkbookStep__c refreshWorkbookStep = refreshWorkbookSteps.get(wbs.id);

            wbs.status = String.valueOf(refreshWorkbookStep.StepStatus__c);
            if (wbs.status != AH_UDC_Constants.STEP_STATUS_COMPLETED && wbs.status != AH_UDC_Constants.STEP_STATUS_LOCKED) workbook.allStepsComplete = false;
            wbs.css = String.valueOf(refreshWorkbookStep.StepStatus__c).replaceAll(' ', '-').toLowerCase();
            wbs.cssI = 'default-step-i';
            if (wbs.status == AH_UDC_Constants.STEP_STATUS_COMPLETED || wbs.status == AH_UDC_Constants.STEP_STATUS_LOCKED) wbs.cssI = 'fas fa-check';

            wbs.cssCurrent = '';
            if (currentStep != null && currentStep.id == wbs.id)
            {
               wbs.cssCurrent = 'current-step';
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
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverUpdateTimer - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'serverUpdateTimer',
                              'An exception occurred refreshing workbook information',
                              exc,(workbook == null?null:workbook.id), (workbook == null?null:'AH_UDC_Workbook__c'));
         ShowErrorMessage();
      }
   }

   //This method is called by the client actionfunction to move to the next not completed step
   //TODO - Needs to take into account Step Prerequisits 
   public void serverChangeToNextStepNotCompleted() {
      //Find the next step not completed or locked
      try
      {
         System.debug('$$$serverChangeToNextStepNotCompleted');
         refreshSteps();

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
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverChangeToNextStepNotCompleted - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'serverChangeToNextStepNotCompleted',
                              'An exception occurred determining the next step',
                              exc, (workbook == null?null:workbook.id), (workbook == null?null:'AH_UDC_Workbook__c'));
         ShowErrorMessage();
      }
   }

   //This method is called by the actionfuction to change to a specific step
   public void serverChangeToStep() {
      try
      {
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

            //TODO: Check if step is not locked, workbook is not locked, get updated status
            AH_UDC_LogHelper.Debug('###moveToStep.id: ' + moveToStep.id);
            AH_UDC_LogHelper.Debug('###moveToStep.name: ' + moveToStep.name);
            changeToStepUrl = AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrl(moveToStep.id);
            AH_UDC_LogHelper.Debug('###changeToStepUrl: ' + changeToStepUrl);

            //TODO: if allowed move to new step
            currentStep = moveToStep;
            AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverChangeToStep: currentStep : Name: ' + currentStep.name);
            currentStep.url = changeToStepUrl;
            currentPosition = changeToPositionNumber;
            changeToStepMessage = '';
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverChangeToStep - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'serverChangeToStep',
                              'An exception occurred determining the next step',
                              exc, (workbook == null?null:workbook.id), (workbook == null?null:'AH_UDC_Workbook__c'));
         ShowErrorMessage();
      }
   }

   //This is used to determine if the UDC Contact has unread chatter comments
   public void CheckChatterFeedNotification() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.CheckChatterFeedNotification');

      List<FeedComment> lstFeedComments = null;
      User objUser = null;
      try {
         //Change the default back to false;
         chatterUpdate = false;
         System.debug('IsCommunityView => ' + IsCommunityView);
         System.debug('Workbook => ' + Workbook);
         if (!IsCommunityView) return; //Chatter alert only applies to Community View
         if (String.isNotBlank(Workbook.documentId)) {
            objUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() AND IsActive = true];
            System.debug('objUser => ' + objUser);
            if (objUser != null)
            {
               AH_UDC_Contact__c udcContactDetails = [SELECT ChatterLastViewed__c, Id
                                                      FROM AH_UDC_Contact__c
                                                      WHERE Document__c = :Workbook.documentId AND Contact__c = :objUser.ContactId];
               List<Id> lstFeedItemIds = new List<Id> ();
               List<FeedItem> lstFeedItems = new List<FeedItem> ([SELECT Id
                                                                 FROM FeedItem
                                                                 WHERE ParentId = :Workbook.documentId AND CreatedById != :objUser.Id]);
               //If there are no feed items just return the default of false
               if (lstFeedItems.size() == 0)
               {
                  return;
               }
               //Get the IDs of the Feed Items
               for (FeedItem feedItem : lstFeedItems)
               {
                  lstFeedItemIds.add(feedItem.id);
               }
               if (udcContactDetails.ChatterLastViewed__c == null)
               {
                  //It doesn't matter how many records just that one exists
                  lstFeedComments = new List<FeedComment> ([SELECT Id
                                                           FROM FeedComment
                                                           WHERE ParentId = :Workbook.documentId
                                                           AND CreatedById = :objUser.Id
                                                           AND FeedItemId = :lstFeedItemIds
                                                           LIMIT 1]);
                  if (lstFeedComments != null && lstFeedComments.size() > 0) {
                     chatterUpdate = true;
                  }
               }
               else
               {
                  //It doesn't matter how many records just that one exists
                  lstFeedComments = new List<FeedComment> ([SELECT Id
                                                           FROM FeedComment
                                                           WHERE ParentId = :Workbook.documentId
                                                           AND CreatedById != :objUser.Id
                                                           AND CreatedDate >= :udcContactDetails.ChatterLastViewed__c
                                                           AND FeedItemId = :lstFeedItemIds
                                                           LIMIT 1]);
                  if (lstFeedComments != null && lstFeedComments.size() > 0) {
                     chatterUpdate = true;
                  }
               }
            }
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.CheckChatterFeedNotification - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'CheckChatterFeedNotification',
                              'An exception occurred determining if the user has unread chatter comments',
                              exc, String.valueOf(Workbook.documentId), 'NI_Documentation__c');
         ShowErrorMessage();
      }
      finally {
         lstFeedComments = null;
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc) {
      //IsErrorOccurred = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message, exc);
   }
}