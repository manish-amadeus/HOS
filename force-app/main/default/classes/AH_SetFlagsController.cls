/****************************************************************************************
Name            : AH_SetFlagsController Class
Author          : Cybage Developer - Ria Chawla
Created Date    : 01/15/2018
Last Mod Date   : 04/18/2018
Last Mod By     : Cybage Developer - Ria Chawla
NICC Reference  : NICC-026092
Description     : Controller for AH_SetFlags VF Page.
				: If Case Flags is enabled for the list of cases, the list view button, 'Set Flags',
				: will clear the flag.
                :
*****************************************************************************************/
public class AH_SetFlagsController 
{
    
    public ApexPages.StandardSetController setController {get; set;}
    public List<Case> casesNotToProcess {get; set;}
    public Boolean showTable {get; set;}
    public List<Case> casesToProcess {get; set;}
    public List<Case> casesToSet {get; set;}
    public List<Case> selectedCases {get; set;}
    
    public AH_SetFlagsController(ApexPages.StandardSetController controller)
    {
        this.setController = controller;
    }
    
    //FUNCTION TO SET FLAG FOR THE LIST OF CASES SELECTED FROM LIST VIEW VF PAGE
    public PageReference setFlagsNow()
    {
        system.debug('setController'+setController);
        selectedCases = (List<Case>) setController.getSelected();
        casesToSet = new List<Case>();
        casesToProcess = new List<Case>();
        casesNotToProcess = new List<Case>();
        system.Debug('selectedCases'+selectedCases);
        Set<Id> caseIdSet = new Set<Id>();
        NI_Case_TriggerHandler caseHandler = new NI_Case_TriggerHandler();
        AH_CaseFlagPreferences__c caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        
        for (Case cs : selectedCases)
        {
            caseIdSet.add(cs.Id);
        }
        
        if (!caseIdSet.isEmpty())
        {
            
            casesToSet = [SELECT Id, RecordTypeId, CaseNumber, BusinessHoursId, AH_Flag__c, Status, CreatedById, Owner.Name, Owner.Id, OwnerId, 
                          AH_Flag_BH__c, AH_Case_Flagged_Date__c, AH_Enable_Case_Flag__c, 
                          AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c,
                          AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c,
                          AH_Case_Flag_Business_Age__c, Todays_End_Time__c, Todays_Start_Time__c, CreatedDate   
                          FROM Case 
                          WHERE Id IN :caseIdSet];
            
            for (Case c : casesToSet)
            {
                if (caseFlagSetting.Organisation_Wide__c == true || 
                   (caseFlagSetting.Organisation_Wide__c == false &&  c.AH_Enable_Case_Flag__c == true))
                {
                    casesToProcess.add(c);
                }
                else
                {
                    showTable = true;
                    casesNotToProcess.add(c);
                }
            }
            
        }
        
        if (casesNotToProcess.isEmpty())
        {
            NI_Case_TriggerHandler csHandler = new NI_Case_TriggerHandler();
            PageReference pr = new PageReference('/500');
            if (!casesToProcess.isEmpty())
            {
                csHandler.setCaseFlagRelatedData(casesToProcess, true, 'Set Flag Button');
                return pr;
            }
        }
        return null;
    }
    
    public PageReference continueProcessing()
    {
        NI_Case_TriggerHandler caseHandler = new NI_Case_TriggerHandler();
        PageReference pr = new PageReference('/500');
        if (!casesToProcess.isEmpty())
        {
            caseHandler.setCaseFlagRelatedData(casesToProcess, true, 'Set Flag Button');
            return pr;
        }
        return pr;
    }
    
}