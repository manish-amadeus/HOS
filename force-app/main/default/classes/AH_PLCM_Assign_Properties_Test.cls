/***********************************************************************************************
Name            : AH_PLCM_Assign_Properties_Test
Author          : Umang Ankleshwaria
Created Date    : 27-April-2020
Last Mod Date   : 27-April-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Test class for Assign Properties page
************************************************************************************************/
@IsTest
public class AH_PLCM_Assign_Properties_Test {
    //Set Default values for Variables
    static String NIDocId = 'aApm00000005DQa'; 
    static String NIDocNo = 'DOC-84950'; 
    static String NIDocName = 'TEST – AHC Hospitality– hSP to ASEM Migration';     
    
    static testMethod void AH_PLCM_Assign_Properties_Test_Method() {
      //insert new record into NI Documentatin object for testing
      NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', '', false, false, false, 'Project Plan' );
      insert niDoc;
      NIDocId = niDoc.Id;
      NIDocNo = niDoc.Name;
      NIDocName = niDoc.Document_Name__c;

      //Initialize the page AH_PLCM_Assign_Properties
      PageReference pRef = Page.AH_PLCM_Assign_Properties;
      pRef.getParameters().put('Id', niDoc.Id);  
      Test.setCurrentPage(pRef);
      Test.startTest();

      //Initialize the constructor of  AH_PLCM_Assign_Properties
      ApexPages.StandardController apexStdControl = new ApexPages.standardController(nidoc);
      AH_PLCM_Assign_Properties assignProperty = new AH_PLCM_Assign_Properties(apexStdControl);                           
      assignProperty.SortColumn = 'NI_Doc_Record__r.Name';
      assignProperty.SortDirection = 'ASC';
      PageReference pRef1 = assignProperty.FillPropertiesList();

      assignProperty.DatabaseName = 'a';
      assignProperty.PropertyName = 'a';
      PageReference pRef2 = assignProperty.SearchProperties();
      //assignProperty.Next();
      //assignProperty.Previous();
      //assignProperty.End();
      //assignProperty.Beginning();
      assignProperty.PageNumber = 2;
      PageReference cpn = assignProperty.ChangePageNumber();
      PageReference pRef3 = assignProperty.AssignProperties();

      List<SelectOption> listPageNo = assignProperty.lstPageNumbers;
      Test.stopTest();
  }

  //Access catch block to get more code coverage
  static testMethod void AH_PLCM_Assign_Properties_Test_Worst_Case() {
      NI_Documentation__c niDoc = new NI_Documentation__c();
      //Initialize the page AH_PLCM_Assign_Properties
      PageReference pRef = Page.AH_PLCM_Assign_Properties;
      pRef.getParameters().put('Id', niDoc.Id);  
      Test.setCurrentPage(pRef);
      Test.startTest();

      //Initialize the constructor of  AH_PLCM_Assign_Properties
      ApexPages.StandardController apexStdControl = new ApexPages.standardController(nidoc);
      AH_PLCM_Assign_Properties assignProperty = new AH_PLCM_Assign_Properties(apexStdControl);
      
      // set the lstProperties to null for check the AssignProperties worst case
      assignProperty.lstProperties = null;
      PageReference pRef3 = assignProperty.AssignProperties();

      // set the value of field to check the worst case
      assignProperty.RecordsPerPage = 0;
      assignProperty.TotalRecords = 1;
      try{
        integer tp = assignProperty.TotalPages;
      }
      catch (Exception ex){
        
      }
      Test.stopTest();
  }
}