/****************************************************************************************
Name            : AH_ClearFlagsController Class
Author          : Cybage Developer - Ria Chawla
Created Date    : 01/15/2018
Last Mod Date   : 04/18/2018
Last Mod By     : Cybage Developer - Ria Chawla
NICC Reference  : NICC-026092
Description     : Controller for AH_ClearFlags VF Page.
				: If Case Flags is enabled for the list of cases, the list view button, 'Clear Flags',
				: will clear the flag.
                :
*****************************************************************************************/
public class AH_ClearFlagsController 
{
    
    private ApexPages.StandardSetController setController {get; set;}
    public List<Case> casesNotToProcess {get; set;}
    public Boolean showTable {get; set;}
    public List<Case> casesToProcess {get; set;}
    public List<Case> casesToClear {get; set;}
    public List<Case> selectedCases {get; set;}
    
    //CONSTRUCTOR
    public AH_ClearFlagsController(ApexPages.StandardSetController controller)
    {
    	this.setController = controller;
    }
    
    //FUNCTION TO PROCESS CASES TO CLEAR FLAG
    public PageReference clearFlagsNow()
    {
        system.debug('setController'+setController);
        selectedCases = (List<Case>) setController.getSelected();
        casesToClear = new List<Case>();
        casesToProcess = new List<Case>();
        casesNotToProcess = new List<Case>();
        Set<Id> caseIdSet = new Set<Id>();
        
        AH_CaseFlagPreferences__c caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        
        for (Case cs : selectedCases)
        {
            caseIdSet.add(cs.Id);
        }
        
        //GET LIST OF CASES TO CLEAR FLAG
        if (!caseIdSet.isEmpty())
        {
            casesToClear = [SELECT Id, CaseNumber, RecordTypeId, BusinessHoursId, AH_Flag__c, Status, CreatedById, Owner.Name, Owner.Id, AH_Flag_BH__c, AH_Case_Flagged_Date__c, 
                            AH_Enable_Case_Flag__c, AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c,
                            AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c,
                            AH_Case_Flag_Business_Age__c, Todays_End_Time__c, Todays_Start_Time__c, CreatedDate
                            FROM Case WHERE Id IN :caseIdSet];
           //SYSTEM.debug('casesToClear'+casesToClear); 
            for (Case c : casesToClear)
            {
                //system.debug('caseFlagSetting.Organisation_Wide__c'+caseFlagSetting.Organisation_Wide__c);
                //system.debug('c.AH_Enable_Case_Flag__c'+c.AH_Enable_Case_Flag__c);
                if (caseFlagSetting.Organisation_Wide__c == true || 
                    (caseFlagSetting.Organisation_Wide__c == false && c.AH_Enable_Case_Flag__c == true))
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
                csHandler.clearCaseFlagRelatedData(casesToProcess, true, 'Clear Flag Button');
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
            caseHandler.clearCaseFlagRelatedData(casesToProcess, true, 'Clear Flag Button');
            return pr;
        }
        return pr;
    }
    
}