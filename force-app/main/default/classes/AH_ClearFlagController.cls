/****************************************************************************************
Name            : AH_ClearFlagController Class
Author          : Cybage Developer - Ria Chawla
Created Date    : 01/15/2018
Last Mod Date   : 04/18/2018
Last Mod By     : Cybage Developer - Ria Chawla
NICC Reference  : NICC-026092
Description     : Controller for AH_ClearFlag VF Page.
				: If Case Flags is enabled for the case, the detail page button, 'Clear Flag', 
				: will clear the flag.
                :
*****************************************************************************************/
public class AH_ClearFlagController 
{
    
    public List<Case> casesList{get; set;}
    public Case caseToClear {get; set;}
    public Boolean showButton {get; set;}
    
    //CONSTRUCTOR
    public AH_ClearFlagController(ApexPages.StandardController std){
        this.caseToClear = (Case)std.getRecord();
        casesList = new List<Case>();
        //GET THE CASE TO PROCESS TO CLEAR
        casesList = [SELECT Id, AH_Initial_response__c, AH_Initial_Response_Business_Hours__c, RecordTypeId, CaseNumber, BusinessHoursId, AH_Flag__c, Status, CreatedById, Owner.Name, Owner.Id, AH_Flag_BH__c, AH_Case_Flagged_Date__c, 
                     AH_Enable_Case_Flag__c, AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c,
                     AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c,
                     AH_Case_Flag_Business_Age__c, Todays_End_Time__c, Todays_Start_Time__c, CreatedDate
                     FROM Case
                     WHERE Id = :caseToClear.Id];
    }
    
    //FUNCTION TO CLEAR FLAG
    public PageReference clearFlagNow(){
        //GET ORG DEFAULTS CUSTOM SETTING
        AH_CaseFlagPreferences__c caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        List<Case> casesToProcess = new List<Case>();
      
        //IF CASE FLAGS IS ENABLED, ADD TO LIST FOR CLEARING FLAG
        for(Case c : casesList){
            if(caseFlagSetting.Organisation_Wide__c == true
               || (caseFlagSetting.Organisation_Wide__c == false &&  c.AH_Enable_Case_Flag__c == true)
              )
            {
              casesToProcess.add(c);
            }
        }
        if(!casesToProcess.isEmpty())
        {
            NI_Case_TriggerHandler caseHandler = new NI_Case_TriggerHandler();
            caseHandler.clearCaseFlagRelatedData(casesToProcess, true, 'Clear Flag Button');
            PageReference pr = new PageReference('/'+caseToClear.Id);
            return pr;
        }
        else
        {
            showButton = true;  
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This case is not enabled for Case Flags. The flag was not cleared. Please contact your system administrator for assistance.'));
        }
        return null;
    }
}