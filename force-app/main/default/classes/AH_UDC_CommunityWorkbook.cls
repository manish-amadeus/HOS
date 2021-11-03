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
   public List<WorkbookStep> steps { get; set; }
   public boolean isCompleted { get; set; }

   public AH_UDC_CommunityWorkbook() {
      steps = new List<WorkbookStep> ();
      propertyInfo = new PropertyInfo();
      completedSteps = 0;
      dueDate = null;
      Submitted = false;
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
      public string helpurl { get; set; }
      public string description { get; set; }

      public WorkbookStep() {
      }
   }

   public class PropertyInfo {
      public Boolean isPropertyConfirmed { get; set; }
      public string name { get; set; }
      public string address { get; set; }
      public string phone { get; set; }
      public string id { get; set; }
      public PropertyInfo() {
      }
   }
}