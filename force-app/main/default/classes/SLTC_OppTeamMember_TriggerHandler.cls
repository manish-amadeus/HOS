/**********************************************************
*************************************
Name 			: SLTC_OppTeamMember_TriggerHandler
Author 			: Lamu Sreeharsha
Created Date 	: 4/1/2022
Last Mod Date 	: 5/2/2022
Last Mod By 	: Lamu Sreeharsha
NICC Reference 	:
Description 	: TriggerHandler used to prevent the deletion of opportunity team member when Opportuntiy(SLTC) Stage is Awaiting QA, CLosed Won, Closed Lost.
                  Custome permiision assign to user them only allowd to delete opprtunity team memeber for above stages.
***********************************************************
*************************************/

public class SLTC_OppTeamMember_TriggerHandler {  
    // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING.
    private NI_TriggerBypassSwitches__c bpSwitch;
    public SLTC_OppTeamMember_TriggerHandler(){
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE.
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }
    
    // ========================================================================================================
    // BeforeDelete method to check Switch On/Off of TriggerHandler and custom Permission.
    // ========================================================================================================
    public void onBeforeDelete(List<OpportunityTeamMember> olddata){
        // ONLY EXECUTE CODE IF BYBASS IS NOT CHECKED and custom permiision is not assigned
        if(!bpSwitch.Bypass_SLTCOpportunityTeamMember_Trigger__c && !FeatureManagement.checkPermission('SLTC_Bypass_ValidationRules_Automation') ){
            BeforedeleteRecords(olddata);
        }   
    }
    
    // ========================================================================================================
    // Before Delete method to check StageName and Display Message Record Is Deleted.
    // ========================================================================================================
    private void beforedeleteRecords(List<OpportunityTeamMember> oldRecords){       
        try{
            //list of profile's to exclude the validation message  
            List<String> listOfprofile = New List<String>{'SLTC Data Governance','SLTC Sales Operations','SLTC Order Management'};
            Id profileId = userinfo.getProfileId();
            String profileName = [Select Name from Profile where Id=:profileId].Name;
            
            If(listOfprofile.contains(profileName)){
                RETURN;
            }
            
            Set<Id> opportunityIdList = new Set<Id>();
            for(OpportunityTeamMember oppTeamMemeberItem : oldRecords) {
                    opportunityIdList.add(oppTeamMemeberItem.OpportunityId);
            }   
            
            //Opportinity stages to lock related object for delete
            List<String> opportunityStages = New list<String>{'Awaiting QA','Closed Won','Closed Lost'};
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id,StageName,RecordType.DeveloperName FROM Opportunity WHERE Id IN : opportunityIdList AND StageName IN : opportunityStages]);
            If(opportunityMap.isEmpty()){
                   RETURN;
            }
            
            //Loop on OpportunityTeamMember Records
            for(OpportunityTeamMember oppTeam : oldRecords) {
                    Opportunity currentopportunity = opportunityMap.get(oppTeam.OpportunityId);
                    String recordTypeName = currentopportunity.RecordType.DeveloperName;
                    if((recordTypeName.contains('SLTC') == True) && opportunityStages.contains(currentopportunity.stageName) && !checkBypassValidation(currentopportunity.stageName)){
                            oppTeam.addError('The opportunity is locked, cannot delete opportunity team members details. Please reach out to commercial operations team for further assistance.');
                    }
            }
        }
        Catch(Exception exec){
            String message = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
            NI_Error_Logger.WriteToLog(message, 'OpportunityTeamMember', 'SLTC_OppTeamMember_TriggerHandler ', 'Delete');   
        }
    }
    //Get the custom permission 
    private Boolean checkBypassValidation(String stageName){
        String customPermission = '';
        If(stageName == 'Awaiting QA'){
            customPermission = 'SLTC_Bypass_Opportunity_Lock_stage_Awaiting_QA';
        }
        else if(stageName == 'Closed Won'){
            customPermission = 'SLTC_Bypass_Opportunity_Lock_stage_Closed_Won';
        }
        else  If(stageName == 'Closed Lost'){
            customPermission = 'SLTC_Bypass_Opportunity_Lock_stage_ClosedLost';
        }
        return FeatureManagement.checkPermission(customPermission);   
    }
}