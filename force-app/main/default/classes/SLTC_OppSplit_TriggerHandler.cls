/**********************************************************
*************************************
Name 			: SLTC_OppSplit_TriggerHandler
Author 			: Lamu Sreeharsha
Created Date 	: 4/1/2022
Last Mod Date 	: 5/2/2022
Last Mod By 	: Lamu Sreeharsha
NICC Reference  :
Description 	: TriggerHandler used to prevent the deletion of records when Opportuntiy(SLTC) Stage is Awaiting QA, CLosedWon, Closed Lost.
***********************************************************
*************************************/

Public class SLTC_OppSplit_TriggerHandler {  
    // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING.
    Private NI_TriggerBypassSwitches__c bpSwitch;
    Public SLTC_OppSplit_TriggerHandler(){
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE.
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }
    
    // ============================================================================================================
    // BeforeDelete method to check Switch On/Off of TriggerHandler and custom Permission.
    // ============================================================================================================
    Public void onBeforeDelete(List<OpportunitySplit> olddata){
        // ONLY EXECUTE CODE IF BYBASS IS NOT CHECKED and custom permiision is not assigned
        if(!bpSwitch.Bypass_SLTC_OpportunitySplit_Trigger__c  && !FeatureManagement.checkPermission('SLTC_Bypass_ValidationRules_Automation')){
            BeforedeleteRecords(olddata);
        }   
    }
    
    // ==============================================================================================================================================
    // Related object Opportinuty team memeber should can not be deleted if Opportunity is in  'Awaiting QA','Closed Won','Closed Lost' Stage
    // ==============================================================================================================================================
    private void beforedeleteRecords(List<OpportunitySplit> oldRecords){       
        try{
            //list of profile's to exclude the validation message  
            List<String> listOfprofile = New List<String>{'SLTC Data Governance','SLTC Sales Operations','SLTC Order Management'};
            Id profileId = Userinfo.getProfileId();
            String profileName = [Select Name from Profile where Id=:profileId LIMIT 1].Name;
            
            If(listOfprofile.contains(profileName)){
                RETURN;
            }
            
            Set<Id> opportunitysplitIdList = new Set<Id>();
            for(OpportunitySplit oppsplitItem : oldRecords) {
                  opportunitysplitIdList.add(oppsplitItem.OpportunityId);
            } 
            
            List<String> opportunityStages = New list<String>{'Awaiting QA','Closed Won','Closed Lost'};
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id,StageName,RecordType.DeveloperName FROM Opportunity WHERE Id IN : opportunitysplitIdList AND StageName IN : opportunityStages]);
            If(opportunityMap.isEmpty()){
             		RETURN;
            }
            
            for(OpportunitySplit oppsplit : oldRecords) {
                   Opportunity currentopportunity = opportunityMap.get(oppsplit.OpportunityId);
                   String recordTypeName = currentopportunity.RecordType.DeveloperName;
                   If((recordTypeName.contains('SLTC') == True) && opportunityStages.contains(currentopportunity.stageName) && !checkBypassValidation(currentopportunity.stageName)){
                           oppsplit.addError('The opportunity is locked, cannot delete opportunity split details. Please reach out to commercial operations team for further assistance.');
                    }
             }
        }
         Catch(Exception exec){
            String message = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
            NI_Error_Logger.WriteToLog(message, 'OpportunitySplit', 'SLTC_OppSplit_TriggerHandler', 'Delete');   
        }
    }
    
    //Get the custom permission 
    private Boolean checkBypassValidation(String stageName){
        String customPermission = '';
        if(stageName == 'Awaiting QA'){
            customPermission = 'SLTC_Bypass_Opportunity_Lock_stage_Awaiting_QA';
        }
        else{
            if(stageName == 'Closed Won'){
                customPermission = 'SLTC_Bypass_Opportunity_Lock_stage_Closed_Won';
            }
            else{
                If(stageName == 'Closed Lost'){
                    customPermission = 'SLTC_Bypass_Opportunity_Lock_stage_ClosedLost';
                }
            }
        }
        return FeatureManagement.checkPermission(customPermission);   
    }
}