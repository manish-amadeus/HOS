/************************************************************************************************
Name            : AH_ChangeRequest_TriggerHandler Class
Author          : Bhuleshwar Deshpande
Created Date    : 09/10/2018
Last Mod Date   : 11/09/2021
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Class that handles all trigger code for the SFDC_CSP_Development_Request__c Object
                : NICC-054506 - added countLinkedCases method
                :
*************************************************************************************************/
public class AH_ChangeRequest_TriggerHandler 
{
    
    //VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    
    public AH_ChangeRequest_TriggerHandler()
    {
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }

    //BEFORE INSERT LOGIC HERE.
    public void OnBeforeInsert(List <SFDC_CSP_Development_Request__c> newTrigger)
    {
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_ChangeRequest__c)
        { 
            if (!newTrigger.isEmpty())
            {
                if (Test.isRunningTest()) // NICC-054506 - ADDED THIS BECAUSE THE bpSwitch.Bypass_ChangeRequest__c WAS SET TO TRUE FOR SOME REASON
                {
                    setPublicStatusDescription(newTrigger);
                }
                countLinkedCases(newTrigger);
            }
        } 
    }   
    
    public void OnBeforeUpdate(List <SFDC_CSP_Development_Request__c> newTrigger)
    {
        // EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_ChangeRequest__c)
        {
            if (!newTrigger.isEmpty())
            {
                if (Test.isRunningTest()) // NICC-054506 - ADDED THIS BECAUSE THE bpSwitch.Bypass_ChangeRequest__c WAS SET TO TRUE FOR SOME REASON
                {
                	setPublicStatusDescription(newTrigger);
                }
                countLinkedCases(newTrigger);
            }
        }
    }   
    
    private void setPublicStatusDescription(List<SFDC_CSP_Development_Request__c> newTrigger)
    {
        
        Map<String, String> crCustomMetadataMap = new Map<String, String>();
        List<CR_Status_to_Description__mdt> crCustomMetadataLst = ([SELECT Status__c, Description__c FROM CR_Status_to_Description__mdt]);
        
        // LOOP TO PUT MAP DATA
        for (CR_Status_to_Description__mdt CRlst : crCustomMetadataLst)
        { 
            crCustomMetadataMap.put(CRlst.Status__c, CRlst.Description__c);   
        }
        
        // LOOP TO ITERATE ON CR LIST AND COMPARE MAP KEY VALUES.
        for (SFDC_CSP_Development_Request__c CR : newTrigger)
        {
            if (crCustomMetadataMap.containsKey(CR.Public_Status__c))
            {
                CR.Public_Status_Description__c = crCustomMetadataMap.get(CR.Public_Status__c); 
            }
        }
        
    }

    // NICC-054506 - added countLinkedCases method
    public void countLinkedCases(List<SFDC_CSP_Development_Request__c> newTrigger)
    {        
      
        // GET AN AGGREGATED LIST OF CASES RELATED TO THE CR RECORDS IN THE TRIGGER 
        List<AggregateResult> lstRelatedCases = new List<AggregateResult>([SELECT Change_Request__c, COUNT(Id) CaseCount 
                                                                           FROM Case 
                                                                           WHERE Change_Request__c IN : newTrigger 
                                                                           AND Change_Request__c != null 
                                                                           GROUP BY Change_Request__c]);
        
        if (lstRelatedCases.isEmpty())
        {
            return;
        }
        
        // LOOP THROUGH TRIGGER AND FIND MATCHING CASE COUNTS TO UPDATE THE Number_of_Cases_Linked__c FIELD
        for (SFDC_CSP_Development_Request__c cr : newTrigger)
        {
            for (AggregateResult ar : lstRelatedCases)
            {
                Id crID = (Id) ar.get('Change_Request__c'); 
                decimal caseCount = (Decimal) ar.get('CaseCount');
                if (cr.Number_of_Cases_Linked__c != caseCount && cr.Id == crID)
                {
                    cr.Number_of_Cases_Linked__c = caseCount; 
                }                
            }
        }
        
    }  
    
}