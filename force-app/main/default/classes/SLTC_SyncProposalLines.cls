/****************************************************************************************
Name            : SLTC_SyncProposalLines 
Author          : Japtej Lamba
Created Date    : 9/28/2022
Last Mod Date   : 12/06/2022 
Last Mod By     : Japtej Lamba
NICC Reference  : 
Description     : Controller class for SLTC_SyncProposalLines VF Page. Clones Propsal 
				  Template Data and Proposal Template story records from all child records
				  to the Parent record and Redirect/refresh to Quote record page.
****************************************************************************************/
public class SLTC_SyncProposalLines {


    Id proposalId  = apexpages.currentpage().getparameters().get('id');
    Apttus_Proposal__Proposal__c parentProposal = [Select Id,Apttus_Proposal__Opportunity__c, SLTC_Number_Of_Properties__c from Apttus_Proposal__Proposal__c WHERE Id=:proposalId];
    List<Apttus_Proposal__Proposal__c> childProposalList = [Select Id, SLTC_Number_Of_Properties__c from Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c in (Select Id from Opportunity WHERE Master_Opportunity__c=: parentProposal.Apttus_Proposal__Opportunity__c) ];
    
    public PageReference syncChildLineItems()
    {
        List<Id> childProposalIdList = new List<Id>();
        for(Apttus_Proposal__Proposal__c prop: childProposalList){
            childProposalIdList.add(prop.Id);
        }

        List<SLTC_Proposal_Template_Data__c> templateData = [Select Name,id,SLTC_BDID__c,SLTC_Bundle_Name__c,SLTC_Campaign_Set_Up_Fee__c,SLTC_Creative_Design_Development_Fee__c, SLTC_Delta_One_Time_Price__c,SLTC_Delta_Quantity__c,
        SLTC_Delta_Recurring_Price__c, SLTC_OneTime_Discount__c, SLTC_Recurring_Discount__c,SLTC_Duplicate_Property_Check__c,SLTC_Frequency__c,SLTC_Is_Bundle_Product__c,SLTC_Line_Status__c,SLTC_Management_Fee__c,SLTC_Monthly_Fee__c,
        SLTC_One_Time_List_Price__c, SLTC_One_Time_Net_Price__c,SLTC_Option_Group__c,SLTC_Parent_Product__c,SLTC_Product_Family__c,SLTC_Product_Name__c,SLTC_Product_Name_2__c,
        SLTC_Proposal_Product_Attribute_Value__c,SLTC_Proposal__c,SLTC_Recurring_List_Price__c,SLTC_Recurring_Net_Price__c,SLTC_Sequence__c,SLTC_Ship_To__c,SLTC_Product_Total__c,
        SLTC_Ship_To_Bundle__c,SLTC_Ship_To_Number__c,SLTC_Ship_To_One_Time_Total__c,SLTC_Ship_To_Recurring_Total__c,SLTC_Ship_To_Usage__c,
        SLTC_Agreement__c,SLTC_Product__c,SLTC_Total_Recurring_Price__c,SLTC_Units__c,SLTC_Usage_Fee__c from SLTC_Proposal_Template_Data__c WHERE SLTC_Proposal__c IN: childProposalIdList];

        List<SLTC_Proposal_Template_Data__c> existingTemplateData = [Select Id from SLTC_Proposal_Template_Data__c WHERE SLTC_Proposal__c =: proposalId];
        
        List<OpportunityTeamMember> childOpptyMembers = [Select Id, SLTC_Proposal__c from OpportunityTeamMember WHERE SLTC_Proposal__c IN: childProposalIdList];
        
        List<SLTC_Proposal_Customer_Story__c> childCustomerStories = [Select Id,SLTC_Customer_Story__c, SLTC_Column_Number__c,SLTC_Customer_Logo__c,SLTC_Testimonial__c,SLTC_Proposal__c,SLTC_Line_Number__c,SLTC_Line_Item__c from SLTC_Proposal_Customer_Story__c WHERE SLTC_Proposal__c IN :childProposalIdList];
        
        List<SLTC_Proposal_Customer_Story__c> existingCustomerStories = [Select Id from SLTC_Proposal_Customer_Story__c WHERE SLTC_Proposal__c =: proposalId];
        
        Map<Id,Decimal> solutionTotal = new Map<Id,Decimal>();
        Map<String,Decimal> shipToUsageTotalMap = new Map<String,Decimal>();
        Map<String,Decimal> shipToOneTimeTotalMap = new Map<String,Decimal>();
        Map<String,Decimal> shipToRecurringTotalMap = new Map<String,Decimal>();
        Map<String,String> shipToProductMap = new Map<String,String>();

        PageReference pg;

        if(!existingTemplateData.isEmpty()){
            try{
                DELETE existingTemplateData;
            } catch(Exception exec){
                    NI_Error_Logger.WriteToLog(exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(), ' ProposalTemplateData', 'SLTC_SyncProposalLines-syncChildLineItems', 'DELETE');
            }
            
        }
        if(!templateData.isEmpty()){
            Decimal tempTotal = 0;
            List<SLTC_Proposal_Template_Data__c> tempDataInsertList = new List<SLTC_Proposal_Template_Data__c>();
            for(SLTC_Proposal_Template_Data__c tempData : templateData){
                String shipToProducts = '';
                Decimal shipToOneTimeTotal = 0;
                Decimal shipToRecurringTotal = 0;
                Decimal shipToUsageTotal = 0;
                if(tempData.SLTC_Is_Bundle_Product__c){
                    if(solutionTotal!=null && solutionTotal.containsKey(tempData.SLTC_Product__c)){
                        tempTotal = solutionTotal.get(tempData.SLTC_Product__c) + tempData.SLTC_Product_Total__c;
                    }
                    else{
                        tempTotal = tempData.SLTC_Product_Total__c;
                    }
                    solutionTotal.put(tempData.SLTC_Product__c,tempTotal);
                
                    if(shipToUsageTotalMap!=null && shipToUsageTotalMap.containsKey(tempData.SLTC_Ship_To__c)){
                        shipToUsageTotal = shipToUsageTotalMap.get(tempData.SLTC_Ship_To__c) + tempData.SLTC_Usage_Fee__c;
                    }
                    else{
                        shipToUsageTotal = tempData.SLTC_Usage_Fee__c;
                    }
                    if(shipToOneTimeTotalMap!=null && shipToOneTimeTotalMap.containsKey(tempData.SLTC_Ship_To__c)){
                        shipToOneTimeTotal = shipToOneTimeTotalMap.get(tempData.SLTC_Ship_To__c) + tempData.SLTC_One_Time_Net_Price__c;
                    }
                    else{
                        shipToOneTimeTotal = tempData.SLTC_One_Time_Net_Price__c;
                    }
                    if(shipToRecurringTotalMap!=null && shipToRecurringTotalMap.containsKey(tempData.SLTC_Ship_To__c)){
                        shipToRecurringTotal = shipToRecurringTotalMap.get(tempData.SLTC_Ship_To__c) + tempData.SLTC_Total_Recurring_Price__c;
                    }
                    else{
                        shipToRecurringTotal = tempData.SLTC_Total_Recurring_Price__c;
                    }
                    if(shipToProductMap!=null && shipToProductMap.containsKey(tempData.SLTC_Ship_To__c)){
                        shipToProducts = shipToProductMap.get(tempData.SLTC_Ship_To__c) + ', ' + tempData.SLTC_Bundle_Name__c;
                    }
                    else{
                        shipToProducts = tempData.SLTC_Bundle_Name__c;
                    }
                    shipToUsageTotalMap.put(tempData.SLTC_Ship_To__c,shipToUsageTotal);
                    shipToOneTimeTotalMap.put(tempData.SLTC_Ship_To__c,shipToOneTimeTotal);
                    shipToRecurringTotalMap.put(tempData.SLTC_Ship_To__c,shipToRecurringTotal);
                    shipToProductMap.put(tempData.SLTC_Ship_To__c,shipToProducts);
                }
                SLTC_Proposal_Template_Data__c record = tempData.clone();
                record.SLTC_Duplicate_Property_Check__c=false;
                record.SLTC_Proposal__c = proposalId;
                tempDataInsertList.add(record);
            }

            //INSERT template data record from Child to Parent Quote
            for(SLTC_Proposal_Template_Data__c tempData : tempDataInsertList){
                
                if(solutionTotal!=null && solutionTotal.containsKey(tempData.SLTC_Product__c) && tempData.SLTC_Is_Bundle_Product__c){
                    tempData.SLTC_Included_in_Solution_Overview__c=true;
                    tempData.SLTC_Solution_Overview_Total__c = solutionTotal.get(tempData.SLTC_Product__c);
                    solutionTotal.remove(tempData.SLTC_Product__c);
                }
                if(shipToUsageTotalMap!=null && shipToUsageTotalMap.containsKey(tempData.SLTC_Ship_To__c) && tempData.SLTC_Is_Bundle_Product__c){
                    tempData.SLTC_Duplicate_Property_Check__c=true;
                    tempData.SLTC_Ship_To_Usage__c = shipToUsageTotalMap.get(tempData.SLTC_Ship_To__c);
                    shipToUsageTotalMap.remove(tempData.SLTC_Ship_To__c);
                }
                if(shipToRecurringTotalMap!=null && shipToRecurringTotalMap.containsKey(tempData.SLTC_Ship_To__c) && tempData.SLTC_Is_Bundle_Product__c){
                    tempData.SLTC_Duplicate_Property_Check__c=true;
                    tempData.SLTC_Ship_To_Recurring_Total__c = shipToRecurringTotalMap.get(tempData.SLTC_Ship_To__c);
                    shipToRecurringTotalMap.remove(tempData.SLTC_Ship_To__c);
                }
                if(shipToOneTimeTotalMap!=null && shipToOneTimeTotalMap.containsKey(tempData.SLTC_Ship_To__c) && tempData.SLTC_Is_Bundle_Product__c){
                    tempData.SLTC_Duplicate_Property_Check__c=true;
                    tempData.SLTC_Ship_To_One_Time_Total__c = shipToOneTimeTotalMap.get(tempData.SLTC_Ship_To__c);
                    shipToOneTimeTotalMap.remove(tempData.SLTC_Ship_To__c);
                }
                if(shipToProductMap!=null && shipToProductMap.containsKey(tempData.SLTC_Ship_To__c) && tempData.SLTC_Is_Bundle_Product__c){
                    tempData.SLTC_Duplicate_Property_Check__c=true;
                    tempData.SLTC_Ship_To_Bundle__c = shipToProductMap.get(tempData.SLTC_Ship_To__c);
                    shipToProductMap.remove(tempData.SLTC_Ship_To__c);
                }
                
            }
            insert tempDataInsertList;
        }
        if(!childProposalList.isEmpty()){
            parentProposal.SLTC_Number_Of_Properties__c = childProposalList.size();
            UPDATE parentProposal;
        }
        
        //Update opportunity Team Members to Parent Quote
        if(!childOpptyMembers.isEmpty()){
            for(OpportunityTeamMember om: childOpptyMembers){
                om.SLTC_Proposal__c = proposalId;
            }
            try{
                UPDATE childOpptyMembers;
            } catch(Exception exec){
                    NI_Error_Logger.WriteToLog(exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(), ' OpportunityTeamMember', 'SLTC_SyncProposalLines-syncChildLineItems', 'UPDATE');
            }
            
        }
        
        //Delete any existing Customer Story Records
        if(!existingCustomerStories.isEmpty()){
            try{
                DELETE existingCustomerStories;
            } catch(Exception exec){
                    NI_Error_Logger.WriteToLog(exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(), ' ProposalCustomerStory', 'SLTC_SyncProposalLines-syncChildLineItems', 'DELETE');
            }
        }
        
        List<SLTC_Proposal_Customer_Story__c> storyInsertList = new List<SLTC_Proposal_Customer_Story__c>();
        List<Id> storyList = new List<Id>();
        
        //Clone customer story from Child to Parent Proposal
        if(!childCustomerStories.isEmpty()){
            for(SLTC_Proposal_Customer_Story__c story : childCustomerStories){
                SLTC_Proposal_Customer_Story__c tempStory = story.clone();
                tempStory.SLTC_Proposal__c = proposalId;
                if(storyList.isEmpty() || !storyList.contains(story.SLTC_Customer_Story__c)){
                    storyList.add(story.SLTC_Customer_Story__c);
                    tempStory.SLTC_Column_Number__c = math.mod(storyList.size(),3);
                    
                    storyInsertList.add(tempStory);
                }
            }
            insert storyInsertList;
        }
        
        //Reload/Redirect to Quote Record Page
        pg = new PageReference('/'+proposalId);
        pg.setRedirect(true);
        return pg;
    }
}