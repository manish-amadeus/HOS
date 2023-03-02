/**
 * Name          : AH_UDC_REST_WorkbookSentInfo
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-01-12
 * Description   : This class accepts a WorkBookSent Id and returns data about the workbook.  This is used by integrating applications.
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_WorkbookSentInfo')
global with sharing class AH_UDC_REST_WorkbookSentInfo {
   public static final Integer QAJsonMaxPerRequest = 20;

   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('AH_UDC_REST_WorkbookSentInfo');
      WorkbookSentInfoResponse resp = new WorkbookSentInfoResponse();
      RestRequest req = RestContext.request;
      try {
         String workbookSentId = RestContext.request.params.get('workbookSentId');
<<<<<<< HEAD
<<<<<<< HEAD
         if (Test.isRunningTest() && workbookSentId=='exception1') integer e = 1/0;
=======
         if (Test.isRunningTest() && workbookSentId == 'exception1') integer e = 1 / 0;
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
         if (Test.isRunningTest() && workbookSentId == 'exception1') integer e = 1 / 0;
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a

         if (String.isBlank(workbookSentId)) {
            resp.statusCode = '400';
            resp.message = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Check that Workbook Sent ID is valid and that the user has access to it
<<<<<<< HEAD
<<<<<<< HEAD
         List<AH_UDC_WorkbookStep__c> workbooksteps = [SELECT id, name, StepStatus__c, StepCompleted__c,
                                                       Workbook__r.SecurityCode__c, Workbook__r.RelatedToDocName__c, Workbook__r.SentDate__c, Workbook__r.SentStatus__c,
                                                       Workbook__r.RelatedTo__r.Name, Workbook__r.RelatedTo__r.Document_Name__c,
                                                       Form__r.id
                                                       FROM AH_UDC_WorkbookStep__c
                                                       WHERE Workbook__c = :workbookSentId
                                                       AND Enabled__c = true
                                                       ORDER BY SortOrder__c asc];

         if (workbooksteps == null || workbooksteps.size() == 0) {
=======
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         List<AH_UDC_Workbook__c> workbooks = [SELECT id, name, SecurityCode__c, RelatedToDocName__c, SentDate__c, SentStatus__c, CreatedById, CreatedBy.Name, LastModifiedBy.Id, LastModifiedBy.Name,
                                               RelatedTo__c, RelatedTo__r.AH_UDC_PropertyAccount__c, OriginalWorkbook__c, ParentWorkbookSent__c
                                               FROM AH_UDC_Workbook__c
                                               WHERE id = :workbookSentId];

         if (workbooks.size() != 1) {
            resp.statusCode = '404';
            resp.message = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Get the original workbook
         List<AH_UDC_Workbook__c> origWorkbooks = [SELECT Id, Archive__c, CompletedBy__c, CompletedBy__r.Name, CompletedDate__c, CreatedById, CreatedBy.Name, Description__c, EmailTemplate__c,
                                                   Enabled__c, InternalUseOnly__c, LastModifiedBy.Id, LastModifiedBy.Name, NumberOfStepsCompleted__c, OriginalWorkbook__c,
                                                   OwnerId, Owner.Name, ParentWorkbookSent__c, ParentWorkbookSent__r.Name, PercentageComplete__c, Product__c,
                                                   RelatedTo__c, Released__c, SecurityCode__c, SentDate__c, SentStatus__c, StepsinOrder__c, TimeToComplete__c,
                                                   TotalNumberOfSteps__c, Withdrawn__c, Name, WorkbookSentDueDate__c
                                                   FROM AH_UDC_Workbook__c
                                                   WHERE id = :workbooks[0].OriginalWorkbook__c];
         AH_UDC_LogHelper.Debug('AH_UDC_REST_WorkbookSentInfo.Get - origWorkbooks.size(): ' + origWorkbooks.size());
         if (origWorkbooks.size() != 1) {
<<<<<<< HEAD
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
            resp.statusCode = '404';
            resp.message = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }
<<<<<<< HEAD
<<<<<<< HEAD

         resp.workbookSentId = workbookSentId;
         resp.documentName = workbooksteps[0].Workbook__r.RelatedTo__r.Document_Name__c;
         resp.documentId = workbooksteps[0].Workbook__r.RelatedTo__r.Name;
         resp.sentDate = workbooksteps[0].Workbook__r.SentDate__c;
         resp.sentStatus = workbooksteps[0].Workbook__r.SentStatus__c;

         string StepToken = AH_UDC_Shared.CreateStepToken(workbooksteps[0].Workbook__r.SecurityCode__c, workbooksteps[0].Form__r.id);
=======
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         resp.originalWorkbook = origWorkbooks[0];

         //Get the parent workbook
         List<AH_UDC_Workbook__c> parentWorkbooks = null;
         if (workbooks[0].ParentWorkbookSent__c != null) {
            parentWorkbooks = [SELECT Id, Archive__c, CompletedBy__c, CompletedBy__r.Name, CompletedDate__c, CreatedById, CreatedBy.Name, Description__c, EmailTemplate__c,
                               Enabled__c, InternalUseOnly__c, LastModifiedBy.Id, LastModifiedBy.Name, NumberOfStepsCompleted__c, OriginalWorkbook__c,
                               OwnerId, Owner.Name, ParentWorkbookSent__c, ParentWorkbookSent__r.Name, PercentageComplete__c, Product__c,
                               RelatedTo__c, Released__c, SecurityCode__c, SentDate__c, SentStatus__c, StepsinOrder__c, TimeToComplete__c,
                               TotalNumberOfSteps__c, Withdrawn__c, Name, WorkbookSentDueDate__c
                               FROM AH_UDC_Workbook__c
                               WHERE id = :workbooks[0].ParentWorkbookSent__c];
            resp.parentWorkbook = parentWorkbooks[0];
         }

         //Get the property account
         List<AH_UDC_PropertyAccount__c> propertyAccounts = [SELECT
                                                             X100NonSmoking__c, AAADiamondRating__c, Abandonment__c, Account__c, AdditionalTranslatedLanguages__c, Address__c, AirportDirectionDirection__c, AirportName1__c,
                                                             AirportName2__c, AirportName3__c, BID__c, Brand__c, CallCenter__c, CancellationTime__c, ChannelManager__c, CheckInTime__c, CheckOutTime__c, City__c,
                                                             ConsortiaProgram__c, Country__c, CountryCode__c, CRM__c, CRS__c, Currency__c, CurrencyIsoCode, DaylightSavingsTimeObserved__c, DirectionfromAirporttoProperty1__c,
                                                             DirectionfromAirporttoProperty2__c, DirectionfromAirporttoProperty3__c, DisplayMarketing__c, DistancetoNearestAirport1__c, DistancetoNearestAirport2__c,
                                                             DistancetoNearestAirport3__c, EmailGroupReservations__c, EmailIndividualReservations__c, EmailMarketing__c, EnhancementsUpgrade__c, Facebook__c, Fax__c,
                                                             FoursquareURL__c, GDS__c, GuestFaxNumber__c, GuestStaySurveys__c, Instagram__c, IsPropertyAllInclusive__c, ISOCertified__c, LargestMeetingRoomSize__c,
                                                             LargestSeatingCapacity__c, Latitude__c, ListSafetyMeasures__c, Locale__c, Longitude__c, ManagementAffiliation__c, MarketTier__c, MaxRoomsBookingEngine__c,
                                                             MaxRoomsCallCenter__c, MobileStarRating__c, NameofChannelManagerSystem__c, NameofPropertyManagementSystemPMS__c, NearestAirportCode1__c,
                                                             NearestAirportCode2__c, NearestAirportCode3__c, NumberofNonSmokingRooms__c, NumberofRoomTypes__c, OHGRating__c, OverflowCallCenter__c, OwnershipAffiliation__c,
                                                             PaidSearch__c, PetsAllowed__c, Phone__c, PhoneGroupReservations__c, PhoneIndividualReservations__c, PinterestURL__c, PMS__c, PostalCode__c, PrePostStayMessaging__c,
                                                             PrimaryLanguage__c, PrimaryPropertyType__c, PropertyAbbreviation__c, PropertyAccountName__c, PropertyChainCode__c, PropertyCode__c, PropertyDescrption__c,
                                                             PropertyEmail__c, PropertyLogo__c, PropertyName__c, PropertyNameAlternateLanguage__c, PropertyNameShort__c, PropertyOpenDate__c, PropertysIPAddress__c,
                                                             PSAAccountNumber__c, PSAAccountRecordID__c, PublicHealthSafetyMeasures__c, RACStarRating__c, ReportingDataWarehouse__c, ReservationEmail__c,
                                                             ReservationFaxNumber__c, RevenueManagementSystem__c, SecondaryPropertyType__c, SmallestMeetingRoomSize__c, SmallestSeatingCapacity__c,
                                                             StandardTravelAgentCommission__c, StarRanking__c, StateProvince__c, SystemofMeasurement__c, TimeZone__c, TollFree__c, TotalFloors__c, TotalFunctionRooms__c,
                                                             TotalGuestrooms__c, TotalMeetingSpaceSqFootMeter__c, Transportation_Information__c, Twitter__c, Name, Website__c, WebsiteProvider__c, WebsiteVideo__c, YouTubeURL__c
                                                             FROM AH_UDC_PropertyAccount__c where id = :workbooks[0].RelatedTo__r.AH_UDC_PropertyAccount__c];
         resp.propertyAccount = propertyAccounts[0];

         List<NI_Documentation__c> niDocs = [SELECT ID, Name, Document_Name__c, AH_UDC_WorkbookDueDate__c, AH_UDC_WorkbookLocked__c, AH_UDC_WorkbookWithdrawn__c
                                             FROM NI_Documentation__c
                                             where id = :workbooks[0].RelatedTo__c];
         resp.niDocumentation = niDocs[0];

         //Get the Workbook Steps
         List<AH_UDC_WorkbookStep__c> workbookSteps = [SELECT id, name, Description__c, Enabled__c, URL__c, RecordType.Name, SortOrder__c, StepCompleted__c, StepCompletedBy__c, StepCompletedBy__r.Name, StepStatus__c,
                                                       Workbook__r.SentDate__c, Workbook__r.SentStatus__c, Form__r.id
                                                       FROM AH_UDC_WorkbookStep__c
                                                       WHERE Workbook__c = :workbookSentId
                                                       AND Enabled__c = true
                                                       ORDER BY SortOrder__c asc];
         List<Id> wbStepIds = new List<Id>();
         For (AH_UDC_WorkbookStep__c workbookstep : workbookSteps){
            wbStepIds.add(workbookstep.id);
         }
         List<AH_UDC_WorkbookStepResponse__c> responses = [select id, WorkbookStep__c, IsMostRecentResponse__c, CreatedDate, Response__r.Responded__c, Response__r.Responder__r.id, Response__r.Responder__r.Name
                                                           from AH_UDC_WorkbookStepResponse__c
                                                           where IsDeleted = false and Response__r.IsDeleted = false and WorkbookStep__c in :wbStepIds
                                                           Order by WorkbookStep__c, IsMostRecentResponse__c DESC, CreatedDate DESC];
         List<Id> formIds = new List<Id> ();
         for (AH_UDC_WorkbookStep__c workbookstep : workbookSteps) {
            if (workbookstep.Form__c != null) formIds.add(workbookstep.Form__c);
         }

         //Get the Workbook Step Forms
         List<AH_UDC_Form__c> wbStepForms = [SELECT id, AllowedExtensions__c, CopyResponseWhenSendingNew__c, CustomUrlId__c, Definition__c, Description__c, FormAssemblyId__c,
                                             Name, FormType__c, HeightMaximumPixels__c, HeightMinimumPixels__c, MaxIndividualFileSizeMB__c, NumberOfFiles__c, OwnerId, Owner.Name,
                                             RecordType.Name, WidthMaximumPixels__c, WidthMinimumPixels__c
                                             FROM AH_UDC_Form__c
                                             WHERE id in :formIds];

         resp.workbookSentId = workbookSentId;
         resp.documentName = niDocs[0].Document_Name__c;
         resp.documentId = niDocs[0].Name;
         resp.sentDate = workbooks[0].SentDate__c;
         resp.sentStatus = workbooks[0].SentStatus__c;

         string StepToken = AH_UDC_Shared.CreateStepToken(workbooks[0].SecurityCode__c, workbooksteps[0].Form__r.id, workbooksteps[0].id);
<<<<<<< HEAD
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         string ExportUrl = AH_UDC_ConfigHelper.GetString('AH_UDC_ExportUrl', '');
         resp.ExportCsvUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'CSV').replace('{STEP}', '*');
         resp.ExportJsonUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'JSON').replace('{STEP}', '*');

         for (AH_UDC_WorkbookStep__c WorkbookStep : WorkbookSteps) {
            WorkbookStep wbs = new WorkbookStep();
            wbs.id = WorkbookStep.Id;
            wbs.name = WorkbookStep.name;
<<<<<<< HEAD
<<<<<<< HEAD
            wbs.stepStatus = WorkbookStep.StepStatus__c;
            wbs.ExportCsvUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'CSV').replace('{STEP}', WorkbookStep.id);
            wbs.ExportJsonUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'JSON').replace('{STEP}', WorkbookStep.id);
=======
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
            wbs.description = WorkbookStep.Description__c;
            wbs.enabled = WorkbookStep.Enabled__c;
            wbs.recordTypeName = WorkbookStep.RecordType.Name;
            wbs.sortOrder = String.valueOf(WorkbookStep.SortOrder__c);
            wbs.stepCompleted = WorkbookStep.StepCompleted__c;
            wbs.stepCompletedBy = WorkbookStep.StepCompletedBy__c;
            wbs.stepCompletedByName = WorkbookStep.StepCompletedBy__r.Name;
            wbs.stepStatus = WorkbookStep.StepStatus__c;

            wbs.ExportCsvUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'CSV').replace('{STEP}', WorkbookStep.id);
            wbs.ExportJsonUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'JSON').replace('{STEP}', WorkbookStep.id);
            if (WorkbookStep.Form__c != null)
            {
               for (AH_UDC_Form__c wbStepForm : wbStepForms)
               {
                  if (wbStepForm.id == WorkbookStep.Form__c)
                  {
                     wbs.form = wbStepForm;
                     break;
                  }
               }
            }
            for(AH_UDC_WorkbookStepResponse__c response : responses)
            {
               if(response.WorkbookStep__c == WorkbookStep.id){
                  wbs.responseHistory.add(response);
               }
            }
<<<<<<< HEAD
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
            resp.WorkbookSteps.add(wbs);
         }

         resp.statusCode = '200';
         resp.message = 'Ok';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
<<<<<<< HEAD
<<<<<<< HEAD
=======
         AH_UDC_LogHelper.Debug('AH_UDC_REST_WorkbookSentInfo.Get - Error Occurred: ' + e.getMessage() + ' at line number ' + e.getLineNumber());
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
         AH_UDC_LogHelper.Debug('AH_UDC_REST_WorkbookSentInfo.Get - Error Occurred: ' + e.getMessage() + ' at line number ' + e.getLineNumber());
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_WorkbookSentInfo', 'get',
                              'An exception occurred processing a response: ' + e.getMessage(),
                              e, null, null);

         //Set the Return code
<<<<<<< HEAD
<<<<<<< HEAD
=======
         resp = new WorkbookSentInfoResponse();
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
         resp = new WorkbookSentInfoResponse();
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         resp.statusCode = '500';
         resp.message = 'Exception Occurred';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         try {
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_WorkbookSentInfo.Get - Failed to write QueuedLogs');
         }
      }
   }

   @TestVisible
   private class WorkbookSentInfoResponse {
      public String statusCode { get; set; }
      public String message { get; set; }
<<<<<<< HEAD
<<<<<<< HEAD
=======

>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======

>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
      public String workbookSentId { get; set; }
      public string documentName { get; set; }
      public string documentId { get; set; }
      public DateTime sentDate { get; set; }
      public string sentStatus { get; set; }

      public string exportCsvUrl { get; set; }
      public string exportJsonUrl { get; set; }

<<<<<<< HEAD
<<<<<<< HEAD
      public List<WorkbookStep> WorkbookSteps { get; set; }
=======
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
      public AH_UDC_Workbook__c workbook { get; set; }
      public AH_UDC_Workbook__c parentWorkbook { get; set; }
      public AH_UDC_Workbook__c originalWorkbook { get; set; }
      public NI_Documentation__c niDocumentation { get; set; }
      public AH_UDC_PropertyAccount__c propertyAccount { get; set; }

      public List<WorkbookStep> workbookSteps { get; set; }
<<<<<<< HEAD
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a

      public WorkbookSentInfoResponse() {
         this.WorkbookSteps = new List<WorkbookStep> ();
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this, true);
      }
   }

   class WorkbookStep {
      public string id { get; set; }
      public string name { get; set; }
<<<<<<< HEAD
<<<<<<< HEAD
      public string stepStatus { get; set; }

      public string exportCsvUrl { get; set; }
      public string exportJsonUrl { get; set; }
   }


=======
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
      public string description { get; set; }
      public Boolean enabled { get; set; }
      public string recordTypeName { get; set; }
      public string sortOrder { get; set; }
      public DateTime stepCompleted { get; set; }
      public string stepCompletedBy { get; set; }
      public string stepCompletedByName { get; set; }
      public string stepStatus { get; set; }
      public List<AH_UDC_WorkbookStepResponse__c> responseHistory { get; set; } {responseHistory = new List<AH_UDC_WorkbookStepResponse__c>();}

      public string exportCsvUrl { get; set; }
      public string exportJsonUrl { get; set; }

      public AH_UDC_Form__c form { get; set; }
   }



<<<<<<< HEAD
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}