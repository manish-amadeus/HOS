/**********************************************************
*************************************
Name          : SLTC_TerminatedProducts_List
Author        : Sreeharsha L
Created Date  : 08-04-22
Last Mod Date : 08-04-22
Last Mod By   : Sreeharsha L
Description   : Class is used to overcome the flow limitation to filter and remove duplicate from List<sObject>. It called from Request 
                Object screen flow (SLTC Request Clone Button) .
***********************************************************
*************************************/

global class SLTC_TerminatedProducts_List {
    
    //Method generate unique list of Product for terminated Proposal line items
    @InvocableMethod(label='Get ProposalLineItem of Cancelled Status' description='Returns the Terminated Products')
    
    global static List<List<Product2>> getProposalLineItem(List<List<Apttus_Proposal__Proposal_Line_Item__c>> proposalLineItems) {
        List<Product2> products = new List<Product2>();
        try{
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            for(List<Apttus_Proposal__Proposal_Line_Item__c> item : proposalLineItems){
                proposalLineItem.addAll(item);
            }
            
            Set<Id> productIds = new Set<Id>();
            for(Apttus_Proposal__Proposal_Line_Item__c item : proposalLineItem){
                Id productId = item.Apttus_QPConfig__OptionId__c != NULL ? item.Apttus_QPConfig__OptionId__c : item.Apttus_Proposal__Product__c;
                if(productIds.contains(productId)){
                    continue;
                }
                products.add(new Product2(Id= productId, Name = item.Product_for_Template__c));
                productIds.add(productId);
            }
            
        }Catch(Exception exec){
            String message = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
            NI_Error_Logger.WriteToLog(message, ' Apttus_Proposal__Proposal_Line_Item__c', ' SLTC_TerminatedProducts_List', 'Query');   
            return new List<List<Product2>>();
        }
        List<List<Product2>> terminatedList= new  List<List<Product2>>();
        terminatedList.add(products);
        return terminatedList;
    }
    
}