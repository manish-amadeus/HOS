<<<<<<< HEAD
/***********************************************************************************************
  Name            : AH_UDC_Archive_Test
  Description     : Class that represents Workbooks to Community Users who don't have access to the object
 ************************************************************************************************/
public class AH_UDC_CommunityWorkbook {
   public string id { get; set; }
   public string name { get; set; }
   public string documentId { get; set; }
   public string documentName { get; set; }
   public integer completedSteps { get; set; }
   public integer totalSteps { get; set; }
   public Boolean allStepsComplete { get; set; }
   public DateTime dueDate { get; set; }
   public PropertyInfo propertyInfo { get; set; }
   public boolean Submitted { get; set; }
   public boolean isArchived { get; set; }
   public string StartVideo { get; set; }
   public List<WorkbookStep> steps { get; set; }
   public boolean isCompleted { get; set; }
   public string ProjectName { get; set; }
   public string ProjectContact { get; set; }

   public AH_UDC_CommunityWorkbook() {
      steps = new List<WorkbookStep> ();
      propertyInfo = new PropertyInfo();
      completedSteps = 0;
      dueDate = null;
      Submitted = false;
      isCompleted = false;
      isArchived = false;
      allStepsComplete = false;
      StartVideo = AH_UDC_ConfigHelper.GetString('AH_UDC_ViewWorkbookStartVideo','');
   }

   public class WorkbookStep {
      public integer position { get; set; }
      public string name { get; set; }
      public string id { get; set; }
      public string status { get; set; }
      public string css { get; set; }
      public string cssI { get; set; }
      public string cssCurrent { get; set; }
      public string cssCollapsedMenuStep { get; set; }
      public string url { get; set; }
      public string token { get; set; }
      public string helpurl { get; set; }
      public string description { get; set; }
      public string prerequisiteStepName { get; set; }
      public integer prerequisiteStepPosition { get; set; }
      public boolean isPrerequisiteStepNotCompleted { get; set; } {isPrerequisiteStepNotCompleted= false;}
      public boolean isLocked { get; set; }{isLocked= false;}
      public boolean isFormAssemblyForm { get; set; }{isFormAssemblyForm= false;}
      public boolean isAmadeusCustomForm { get; set; }{isamadeusCustomForm= false;}
      public boolean isAmadeusFileUpload { get; set; }{isamadeusFileUpload= false;}
      public boolean isExternalUrl { get; set; }{isExternalUrl= false;}
      public List<SelectOption> lastUpdatedByUsersList { get; set; } { lastUpdatedByUsersList = new List<SelectOption>(); }
      public Id selectedLastUpdatedById { get; set; }
      public WorkbookStep() {
      }
   }

   public class PropertyInfo {
      public Boolean isPropertyConfirmed { get; set; }{isPropertyConfirmed= false;}
      public string name { get; set; }
      public string address { get; set; }
      public string phone { get; set; }
      public string id { get; set; }
      public PropertyInfo() {
      }
   }   
=======
/***********************************************************************************************
  Name            : AH_UDC_Communityworkbook
  Description     : Class that represents Workbooks to Community Users who don't have access to the object
 ************************************************************************************************/
public class AH_UDC_CommunityWorkbook {
   public string id { get; set; }
   public string name { get; set; }
   public string documentId { get; set; }
   public string documentName { get; set; }
   public integer completedSteps { get; set; }
   public integer totalSteps { get; set; }
   public Boolean allStepsComplete { get; set; }
   public DateTime dueDate { get; set; }
   public PropertyInfo propertyInfo { get; set; }
   public boolean Submitted { get; set; }
   public boolean isArchived { get; set; }
   public string StartVideo { get; set; }
   public List<WorkbookStep> steps { get; set; }
   public boolean isCompleted { get; set; }
   public boolean isSent { get; set; }
   public string ProjectName { get; set; }
   public string ProjectContact { get; set; }
   public string Title { get; set; }
   public WorkbookStep currentStep { get; set; }

   public AH_UDC_CommunityWorkbook() {
      steps = new List<WorkbookStep> ();
      propertyInfo = new PropertyInfo();
      completedSteps = 0;
      dueDate = null;
      Submitted = false;
      isCompleted = false;
      isArchived = false;
      isSent = true;
      allStepsComplete = false;
      StartVideo = AH_UDC_ConfigHelper.GetString('AH_UDC_ViewWorkbookStartVideo', '');
   }

   public class WorkbookStep {
      public integer position { get; set; }
      public string name { get; set; }
      public string id { get; set; }
      public string status { get; set; }
      public string css { get; set; }
      public string cssI { get; set; }
      public string cssCurrent { get; set; }
      public string cssCollapsedMenuStep { get; set; }
      public string url { get; set; }
      public string token { get; set; }
      public string helpurl { get; set; }
      public string description { get; set; }
      public string prerequisiteStepName { get; set; }
      public integer prerequisiteStepPosition { get; set; }
      public boolean isPrerequisiteStepNotCompleted { get; set; } { isPrerequisiteStepNotCompleted = false; }
      public boolean isLocked { get; set; } { isLocked = false; }
      public boolean isFormAssemblyForm { get; set; } { isFormAssemblyForm = false; }
      public boolean isAmadeusCustomForm { get; set; } { isamadeusCustomForm = false; }
      public boolean isAmadeusFileUpload { get; set; } { isamadeusFileUpload = false; }
      public FileUploadInfo fileUploadInfo { get; set; }
      public string amdeusFormAPIUrl { get; set; }
      public boolean isExternalUrl { get; set; } { isExternalUrl = false; }
      public List<SelectOption> lastUpdatedByUsersList { get; set; } { lastUpdatedByUsersList = new List<SelectOption> (); }
      public Id selectedLastUpdatedById { get; set; }
      public WorkbookStep() {
         fileUploadInfo = new FileUploadInfo();
      }
   }

   public class PropertyInfo {
      public Boolean isPropertyConfirmed { get; set; } { isPropertyConfirmed = false; }
      public string name { get; set; }
      public string address { get; set; }
      public string phone { get; set; }
      public string id { get; set; }
      public PropertyInfo() {
      }
   }

   public class FileUploadInfo {
      public string fileUploadDescription { get; set; }
      public string fileUploadExtension { get; set; }
      public string fileUploadMaximumSize { get; set; }
      public string maxHeight { get; set; }
      public string minHeight { get; set; }
      public string maxWidth { get; set; }
      public string minWidth { get; set; }
      public string maxFileUploadCount { get; set; }
      public string fileUploadUrl { get; set; }
      public string fileId { get; set; }
      public List<ContentDocumentLink> uploadedFileList { get; set; } { uploadedFileList = new List<ContentDocumentLink> (); } //This is used to diplay a file list on the Amadeus File Update component

      public FileUploadInfo() {
      }
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}