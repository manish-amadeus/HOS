/****************************************************************************************
Name            : AH_SetFlagController Class
Author          : Cybage Developer - Ria Chawla
Created Date    : 01/15/2018
Last Mod Date   : 04/18/2018
Last Mod By     : Cybage Developer - Ria Chawla
NICC Reference  : NICC-026092
Description     : Controller for AH_SetFlag VF Page.
				: If Case Flags is enabled for the case, the detail page button,'Set Flag', will set the flag.
                :
*****************************************************************************************/
public class AH_SetFlagController 
{
    
    public List<Case> casesList{get; set;}
    //public Id caseId {get; set;}
    public Case caseToSet {get; set;}
    public Boolean showButton {get; set;}
    
    public AH_SetFlagController(ApexPages.StandardController std)
    {
        this.caseToSet = (Case)std.getRecord();
        casesList = new List<Case>();
        casesList = [SELECT Id, RecordTypeId, CaseNumber, BusinessHoursId, AH_Flag__c, Status, CreatedById, Owner.Name, Owner.Id, AH_Flag_BH__c, AH_Case_Flagged_Date__c, 
                     AH_Enable_Case_Flag__c, AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c,
                     AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c,
                     AH_Case_Flag_Business_Age__c, Todays_End_Time__c, Todays_Start_Time__c, CreatedDate
                     FROM Case
                     WHERE Id = :caseToSet.Id];
        
    }
    
    public PageReference setFlagNow()
    {
        
        AH_CaseFlagPreferences__c caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        List<Case> casesToProcess = new List<Case>();
        System.debug('Setting flag..');
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        List<String> selected_case_types = new List<String>();
        Map <String, String> MapSelectedCaseTypes = new Map <String, String>();
        
        // CREATE LIST OF SELECTED CASE RECORD TYPE
        try
        {
            flagRecTypes = [SELECT  Name, Enabled_Activity_Types__c, Clear_Case_Origins__c, Enabled_Case_Type__c            
                            FROM AH_Case_Flags_Store_Types__c
                            WHERE Name = 'Default' LIMIT 1];
            system.debug('flagRecTypes'+flagRecTypes);
            if (flagRecTypes.Enabled_Case_Type__c != null)
            {
                selected_case_types = flagRecTypes.Enabled_Case_Type__c.split(',');
                /*for(String s : selected_case_types){
                MapSelectedCaseTypes.put(s,s);
                }*/
            }
            else
            {
                selected_case_types.add('None');
            }
        }
        catch (Exception e)
        {
            system.debug('e'+e.getMessage());
            //DO NOTHING
        }
        
        System.debug('selected_case_types : '+selected_case_types);
        
        if (!selected_case_types.isEmpty())
        {
            for (Case c : casesList)
            {
                if (selected_case_types.contains(c.RecordTypeId) && 
                    (caseFlagSetting.Organisation_Wide__c == true || 
                     (caseFlagSetting.Organisation_Wide__c == false &&  c.AH_Enable_Case_Flag__c == true)))
                {
                    casesToProcess.add(c);
                }
            }
            if(!casesToProcess.isEmpty())
            {
                NI_Case_TriggerHandler caseHandler = new NI_Case_TriggerHandler();
                try
                {
                    caseHandler.setCaseFlagRelatedData(casesToProcess, true, 'Set Flag Button');
                    PageReference pr = new PageReference('/' + caseToSet.Id);
                    return pr;
                }
                catch(Exception e)
                {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception: This case is not enabled for Case Flags. The flag was not set. Please contact your system administrator for assistance.'));
                }
            }
            else
            {
                showButton = true;    
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'1. This case is not enabled for Case Flags. The flag was not set. Please contact your system administrator for assistance.'));
            }  
        }
        else
        {
            showButton = true;    
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'2. This case is not enabled for Case Flags. The flag was not set. Please contact your system administrator for assistance.'));
        }  
        return null;
    }
    
}