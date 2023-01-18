/**********************************************************
*************************************
Name :   SLTC_Opportunity_TriggerHandler
Author : Jaswanth R
Created Date : 5/05/2022
Last Mod Date :  8/19/2022
Last Mod By : Jaswanth R
NICC Reference :
Description :Trigger handler to manage Opportunity before closed won and check their Contact Roles.
***********************************************************
*************************************/
public class SLTC_Opportunity_TriggerHandler {
    // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING.
    private NI_TriggerBypassSwitches__c bpSwitch;
    public SLTC_Opportunity_TriggerHandler(){
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE.
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }  
    
    // ===================================================================================
    // BeforeUpdate method to check Switch On/Off of TriggerHandler and custom Permission.
    // ===================================================================================
    public void onBeforeUpdate(List<Opportunity> newdata){
        // ONLY EXECUTE CODE IF BYBASS IS NOT CHECKED and custom permiision is not assigned
        if(!bpSwitch.Bypass_SLTC_Opportunity_Trigger__c && !FeatureManagement.checkPermission('SLTC_Bypass_ValidationRules_Automation')){
            beforeUpdateRecords(newdata);
            
        }  
    }
    
    
    private void beforeUpdateRecords(List<Opportunity> oppList){
        //check if persona has the custom permission to skip the contact role validation for opportunity has partial termiantion request.
        if(FeatureManagement.checkPermission('SLTC_Skip_the_contact_Role_Validation')){
            List<Opportunity> oppNewRecord_data  = new list<Opportunity>();        
            for(Opportunity record_data: oppList){
                if(record_data.SLTC_Termination_Type__c != 'Partial'){
                    oppNewRecord_data.add(record_data);
                }
            }
            if(!oppNewRecord_data.isEmpty()){
                validateOpportunityContactRole(oppNewRecord_data);
            }
        }
        else{
            validateOpportunityContactRole(oppList);
        }
    }
    
    // =================================================================
    // BeforeUpdate method to check opportunity closed won contact roles
    // =================================================================
    //Method To check the associated contact roles for each opportunity which is marked Awaiting QA/Closed-Won
    private void validateOpportunityContactRole(List<Opportunity> oppList){
        try{
            Map<Id, RecordType> recordtype = new Map<Id, RecordType>([SELECT Id, Name,DeveloperName FROM RecordType WHERE (SobjectType = 'Opportunity')]);
            List<Id>  opportunityId = new List<Id>();
            for(Opportunity item : oppList){
                String recordTypeName = recordtype.get(item.recordTypeId).developerName;
                if((item.StageName=='Awaiting QA' || item.StageName=='Closed Won') && recordTypeName.startsWith('SLTC')){
                    opportunityId.add(item.Id);  
                }
            }
            
            if(opportunityId.isEmpty()){
                return;
            }
            
            List<String> invoiceType = new List<String>{'Ind to Ind', 'Corp to Ind'};
            List<Apttus_Proposal__Proposal__c> proposalList = [select Id, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Primary__c
                                                                   FROM Apttus_Proposal__Proposal__c
                                                                   WHERE( Apttus_Proposal__Opportunity__c IN : opportunityId
                                                                         AND Apttus_Proposal__Primary__c = True
                                                                         AND SLTC_Type_of_Invoice__c IN : invoiceType)];  
            
            Map<Id, Id> proposal_opportunity = new Map<Id, Id>();
            for(Apttus_Proposal__Proposal__c item : proposalList){
                proposal_opportunity.put(item.Id, item.Apttus_Proposal__Opportunity__c);
            }
            
            
            //Store AggregateResult Count of distinct bill-to from proposal line item.
            AggregateResult[] proposalLineItemAggregate = [SELECT Apttus_Proposal__Proposal__c, count_distinct(Apttus_QPConfig__BillToAccountId__c) FROM Apttus_Proposal__Proposal_Line_Item__c
                                                           WHERE Apttus_Proposal__Proposal__c IN : proposalList
                                                           AND Apttus_QPConfig__BillToAccountId__c != Null
                                                           GROUP BY Apttus_Proposal__Proposal__c];
            
            
            //Generate Map to store the count of bill-To associated with each Opportunity primary proposal
            Map<Id, Integer> billToCount = new Map<Id, Integer>();
            
            for(AggregateResult result : proposalLineItemAggregate){
                Integer countBill = (Integer)result.get('expr0');
                Id proposalId =  String.valueOf(result.get('Apttus_Proposal__Proposal__c'));
                Id currentOpportunityId = proposal_opportunity.get(proposalId);
                billToCount.put(currentOpportunityId, countBill);
            }
            
            //Generate a map of Opportunity with the list of OpportunityContactRole <string:OpportunityId,List:OppContactRole>.
            Map<Id,List<OpportunityContactRole>> opportunity_contactRoleMap = genrateOpporunityContactRoleMap(opportunityId);
            
            for(Opportunity item : oppList){
                List<OpportunityContactRole> opportunityContactRole = new List<OpportunityContactRole>();
                if(opportunity_contactRoleMap.containsKey(item.Id)){
                    opportunityContactRole.addAll(opportunity_contactRoleMap.get(item.Id)); 
                }
                if(opportunityContactRole.isEmpty()){
                    item.addError(SLTC_Global_Constant.errorMessageNoContactRoles);
                    continue;
                }
                Integer opportunityBillToCount = 1;
                if(billToCount.get(item.Id) != NULL){
                    opportunityBillToCount = billToCount.get(item.Id);
                }
                
                Map<String, Integer> groupByRole = new Map<String, Integer>{'Authorizer' => 0, 'Bill To' => 0, 'Sold To' => 0, 'Customer Project Contact' => 0};
                if(opportunityContactRole.size() != 0){
                    for(OpportunityContactRole contactRoleItem : opportunityContactRole){
                        Integer groupCount = groupByRole.get(contactRoleItem.Role)+1;
                        groupByRole.put(contactRoleItem.Role, groupCount);
                    }
                }

                String message = '';
                //Bill-to contact role requirements based on invoice type
                if(groupByRole.get('Bill To') != opportunityBillToCount){
                    message += '->['+groupByRole.get('Bill To') +']Bill-To Contact Roles are associated with this Opportunity and ['+opportunityBillToCount+'] are required.Please add/remove the required Bill-Tos to close the opportunity.\n';
                }
                //sold to contact roles are required only when opportunity stage is set to closed won.
                if(groupByRole.get('Sold To') != 1 && item.StageName=='Closed Won'){
                    message += '->'+SLTC_Global_Constant.errorMessageSoldTo;
                }
                //Atleast one Customer Project Contact required to mark Awaiting Qa
                if(groupByRole.get('Customer Project Contact') < 1){
                    message +=  '->' + SLTC_Global_Constant.errorMessageProjectContact;
                }
                //Atleast one Authorizer required to mark Awaiting QA
                if(groupByRole.get('Authorizer') < 1){
                    message += '->' + SLTC_Global_Constant.errorMessageAuthorizer;  
                }
                message = message.removeStart(',');
                if(message.length() > 0){
                    item.addError('$'+message+'$');
                }
            }
        }Catch(Exception exec){
            String messageExc = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
            NI_Error_Logger.WriteToLog(messageExc, 'Opportunity', 'SLTC_Opportunity_TriggerHandler', 'Update');   
        }
    }
    
    
    // ================================================================================================
    // Method where List of Opportunity Id is passed and a Map of Contact role associated is returned
    // ================================================================================================
    
    //Generate Map Opprtunity Id with respective contact role
    private static Map<Id, List<OpportunityContactRole>> genrateOpporunityContactRoleMap(List<Id> opprtunityId){
        Map<Id, List<OpportunityContactRole>> reqMap = new Map<Id, List<OpportunityContactRole>>();
        List<OpportunityContactRole> contactRoles = [SELECT Id, role, OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN : opprtunityId];
        for(OpportunityContactRole result : contactRoles){
            if(!reqMap.containsKey(result.OpportunityId)){
                reqMap.put(result.OpportunityId, new List<OpportunityContactRole>());
            }
            reqMap.get(result.OpportunityId).add(result);
        }
        return reqMap;
    }
    
}