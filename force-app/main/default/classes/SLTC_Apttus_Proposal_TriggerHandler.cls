/**********************************************************
*************************************
Name : sltc_Apttus_Proposal_TriggerHandler
Author : Japtej Lamba
Created Date : 4/1/2022
Last Mod Date : 8/24/2022
Last Mod By : Japtej Lamba
NICC Reference :
Description : Handler Class for sltc_Apttus_Proposal_Trigger. Used to create Proposal Template Data records
***********************************************************
* Revision : 1.1
* LastModified : 05th Sept by Gopesh Banker
* Description : Adding checkDates()
*************************************/

public class SLTC_Apttus_Proposal_TriggerHandler {
    
    //public static boolean recursiveCheck = false;
    
    // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING
    private NI_TriggerBypassSwitches__c bpSwitch {get;
                                                  set;}
    // CONSTRUCTOR
    public sltc_Apttus_Proposal_TriggerHandler()
    {
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch =
            NI_TriggerBypassSwitches__c.getOrgDefaults();
    }
    
    public void onBeforeInsert(List<Apttus_Proposal__Proposal__c> listNewProposals)
    {
        /*List<Apttus_Proposal__Proposal__c> listNewProposalsApproved;
        //------------change made by jaswanth(28/9/22 Story No:W-037002)
        for(Apttus_Proposal__Proposal__c proposalSingle:listNewProposals){
            if(proposalSingle.Apttus_Proposal__Account__r.SLTC_Account_Validation_Status__c!='Approved'){
           // proposalSingle.addError('The Related account for this proposal is not Approved.');    
        }
            else
            {
                listNewProposalsApproved.add(proposalSingle);
            }
        }
        //------------*/
        for(Apttus_Proposal__Proposal__c objProposal : listNewProposals)
        {
            if(objProposal.Apttus_Proposal__ExpectedStartDate__c == null)
            {
               objProposal.Apttus_Proposal__ExpectedStartDate__c = System.today();
            }
            else
            {
                if(objProposal.Apttus_Proposal__ExpectedEndDate__c != null)
                {
                    objProposal.SLTC_Term_Length_Month__c = calcTerm(objProposal.Apttus_Proposal__ExpectedStartDate__c, objProposal.Apttus_Proposal__ExpectedEndDate__c);
                }
            }
            objProposal.SLTC_Original_Start_Date__c = objProposal.Apttus_Proposal__ExpectedStartDate__c;
        }
    }
    
    // ========================================
    // Before Update method to count and store number of properties related to each quote
    // ========================================
    public void onBeforeUpdate(List<Apttus_Proposal__Proposal__c> newTrigger,List<Apttus_Proposal__Proposal__c> oldTrigger,Map<Id,Apttus_Proposal__Proposal__c> mapNewTrigger, Map<Id,Apttus_Proposal__Proposal__c> mapOldTrigger){
        // ONLY EXECUTE CODE IF BYBASS IS NOT CHECKED
        if (!bpSwitch.Bypass_Apttus_Proposal_Proposal__c)
        {
            updateProposalProperties(newTrigger,mapNewTrigger);
            checkDates(newTrigger, mapOldTrigger);
            updateRenewalTerm(newTrigger,mapNewTrigger);
        }
    }
    
    // ========================================
    // After update method to store Proposal Template Data records based on Line Items
    // ========================================
    public void onAfterUpdate(List<Apttus_Proposal__Proposal__c> newTrigger,List<Apttus_Proposal__Proposal__c> oldTrigger,Map<Id,Apttus_Proposal__Proposal__c> mapNewTrigger, Map<Id,Apttus_Proposal__Proposal__c> mapOldTrigger){
        
        // ONLY EXECUTE CODE IF BYBASS IS NOT CHECKED
        if (!bpSwitch.Bypass_Apttus_Proposal_Proposal__c)
        {
            createProposalTemplateDataRecords(mapNewTrigger,mapOldTrigger);
        }
    }
    
    // ========================================
    // Before Update method to count and store number of properties related to each quote
    // ========================================
    private void updateProposalProperties(List<Apttus_Proposal__Proposal__c> newTrigger, Map<Id,Apttus_Proposal__Proposal__c> mapNewTrigger)
    {
        try{
        
        //Query Line Item records/data
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalAndLineItems = [SELECT Id,
                                                                             Apttus_Proposal__Proposal__c,
                                                                             Apttus_QPConfig__ShipToAccountId__c,
                                                                             Apttus_QPConfig__ShipToAccountId__r.Name,
                                                                             Apttus_QPConfig__LineStatus__c 
                                                                             from Apttus_Proposal__Proposal_Line_Item__c 
                                                                             WHERE Apttus_Proposal__Proposal__c IN: mapNewTrigger.keySet()
                                                                             AND Apttus_QPConfig__LineStatus__c != 'Cancelled'];
        
        Map<Id,Set<Id>> pliShipToList = new Map<Id,Set<Id>>();
        //Create mapping with list of Ship Tos for each Quote/Proposal
        for(Apttus_Proposal__Proposal_Line_Item__c pli: proposalAndLineItems){
            Set<Id> shipToIdSet = new Set<Id>();
            if(pliShipToList.containsKey(pli.Apttus_Proposal__Proposal__c)){
                shipToIdSet = pliShipToList.get(pli.Apttus_Proposal__Proposal__c);
            }
            shipToIdSet.add(pli.Apttus_QPConfig__ShipToAccountId__c);
            pliShipToList.put(pli.Apttus_Proposal__Proposal__c,shipToIdSet);
        }
        
        //Calculate unique Ship Tos
        if(!pliShipToList.IsEmpty() && pliShipToList!=null){
            for(Apttus_Proposal__Proposal__c proposal : newTrigger){
                if(pliShipToList.keyset().contains(proposal.Id) && (((proposal.SLTC_Number_Of_Properties__c != pliShipToList.get(proposal.Id).size()) || (proposal.SLTC_Number_Of_Properties__c != NULL)) && !proposal.SLTC_Is_Parent_Proposal__c)){
                    proposal.SLTC_Number_Of_Properties__c = pliShipToList.get(proposal.Id).size();
                }
            }
        }
        } catch (Exception exec) {
            String message = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
            NI_Error_Logger.WriteToLog(message, ' ProposalTemplateData', 'sltc_Apttus_Proposal_TriggerHandler-updateProposalProperties', 'Query');
        }
    }
    
    
    // ========================================
    // Delete Existing Proposal Template Data Records
    // ========================================
    private void deleteExistingRecords(Map<Id,Apttus_Proposal__Proposal__c> finalizedProposalMap)
    {
        try{
            //List of Existing Proposal Template Data records to be deleted
            List<SLTC_Proposal_Template_Data__c> existingPropTemp = [Select Id from SLTC_Proposal_Template_Data__c WHERE SLTC_Proposal__c IN:finalizedProposalMap.KeySet()];
            Delete existingPropTemp;
        }  catch (Exception exec) {
            String message = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
            NI_Error_Logger.WriteToLog(message, ' ProposalTemplateData', 'sltc_Apttus_Proposal_TriggerHandler-deleteExistingRecords', 'DELETE');
        }
    }
    
    // ========================================
    // Create Proposal Template Data Records
    // ========================================
    private void createProposalTemplateDataRecords(Map<Id,Apttus_Proposal__Proposal__c> mapNewTrigger, Map<Id,Apttus_Proposal__Proposal__c> mapOldTrigger)
    {
        try{
            Map<Id,Apttus_Proposal__Proposal__c> finalizedProposalMap = new Map<Id,Apttus_Proposal__Proposal__c>();
            
            //Create map of proposal Id and proposal record
            for(Id propId : mapNewTrigger.keySet()){
                if(mapOldTrigger.get(propId).Apttus_QPConfig__ConfigurationFinalizedDate__c != mapNewTrigger.get(propId).Apttus_QPConfig__ConfigurationFinalizedDate__c){
                    finalizedProposalMap.put(propId,mapNewTrigger.get(propId));
                }
            }
            
            if(finalizedProposalMap!=null && finalizedProposalMap.size()>0){
                //Delete existing template data records
                deleteExistingRecords(finalizedProposalMap);
                
                //Get Line Item records/Data for all proposals
                List<Apttus_Proposal__Proposal_Line_Item__c> proposalAndLineItems = [Select Id,
                                                                                    Apttus_Proposal__Proposal__c,
                                                                                    Apttus_QPConfig__ClassificationId__r.Name, 
                                                                                    Apttus_QPConfig__SellingFrequency__c, 
                                                                                    Apttus_QPConfig__ListPrice__c,
                                                                                    Apttus_QPConfig__NetPrice__c,
                                                                                    Apttus_QPConfig__ProductOptionId__c,
                                                                                    Apttus_QPConfig__OptionId__c,
                                                                                    Apttus_Proposal__Product__c,
                                                                                    Apttus_Proposal__Product__r.Name,
                                                                                    Apttus_Proposal__Product__r.Family,
                                                                                    Apttus_QPConfig__LineNumber__c,
                                                                                    Apttus_QPConfig__ItemSequence__c,
                                                                                    Apttus_QPConfig__PriceType__c,
                                                                                    Apttus_QPConfig__Quantity2__c,
                                                                                    Apttus_QPConfig__ShipToAccountId__c,
                                                                                    Apttus_QPConfig__ShipToAccountId__r.Name,
                                                                                    Apttus_QPConfig__NetUnitPrice__c,
                                                                                    SLTC_Discount_for_Template__c,
                                                                                    Apttus_Proposal__Proposal__r.SLTC_Number_Of_Properties__c,
                                                                                    Apttus_QPConfig__DeltaPrice__c,
                                                                                    Apttus_QPConfig__DeltaQuantity__c,
                                                                                    Apttus_QPConfig__LineStatus__c,
                                                                                    Apttus_QPConfig__ChargeType__c,
                                                                                    Apttus_QPConfig__AttributeValueId__c,
                                                                                    Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__OptionGroupLabel__c,
                                                                                    Apttus_QPConfig__OptionId__r.Name,
                                                                                    SLTC_Related_Escalator_Adjustment_Amount__c,
                                                                                    Apttus_QPConfig__BillToAccountId__c,
                                                                                    Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__RelatedAdjustmentType__c from Apttus_Proposal__Proposal_Line_Item__c 
                                                                                    WHERE Apttus_Proposal__Proposal__c IN: finalizedProposalMap.KeySet()
                                                                                    ];
                                                                                    //AND Apttus_QPConfig__LineStatus__c != 'Cancelled'];
                
                Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>> level1Map = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>>();
                Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>> productLineMap = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>>();
                Map<String,Integer> shipToMap = new Map<String,Integer>();
                Map<Id,List<String>> proposalShipToMap = new Map<Id,List<String>>();
                Map<String,String> bundleFamilyMap = new Map<String,String>();
                Map<String,Set<String>> shipToBundleMap = new Map<String,Set<String>>();
                Map<String,Decimal> shipToRecurringMap = new Map<String,Decimal>();
                Map<String,Decimal> shipToOneTimeMap = new Map<String,Decimal>();
                Map<String,Decimal> shipToCampaignSetupMap = new Map<String,Decimal>();
                Map<String,Decimal> shipToCreativeDesignMap = new Map<String,Decimal>();
                Map<String,Decimal> shipToMonthlyFeeMap = new Map<String,Decimal>();
                Map<String,Decimal> shipToManagementFeeMap = new Map<String,Decimal>();
                Map<String,Decimal> shipToUsageMap = new Map<String,Decimal>();
                Map<String,Decimal> solutionOverviewMap = new Map<String,Decimal>();
                
                for(Apttus_Proposal__Proposal_Line_Item__c pli : proposalAndLineItems){
                    String uniqueId = pli.Apttus_Proposal__Product__c + ':' + pli.Apttus_QPConfig__LineNumber__c;
                    String uniqueOptionId = pli.Apttus_QPConfig__OptionId__c + ':' + pli.Apttus_QPConfig__LineNumber__c;
                    //Map of Product and Line Item
                    if(productLineMap.containsKey(uniqueId)){
                        List<Apttus_Proposal__Proposal_Line_Item__c> l = productLineMap.get(uniqueId);
                        l.add(pli);
                        productLineMap.put(uniqueId,l);
                    } 
                    else{
                        List<Apttus_Proposal__Proposal_Line_Item__c> l = new List<Apttus_Proposal__Proposal_Line_Item__c>();
                        l.add(pli);
                        productLineMap.put(uniqueId,l);
                    }
                    
                    //Check if bundle product/Level 1 and Map Product and Line Item
                    if(pli.Apttus_QPConfig__ProductOptionId__c == NULL){
                        List<Apttus_Proposal__Proposal_Line_Item__c> l1 = new List<Apttus_Proposal__Proposal_Line_Item__c>();
                        if(level1Map.containsKey(uniqueId)){
                            l1 = level1Map.get(uniqueId);
                        }
                        l1.add(pli);
                        level1Map.put(uniqueId,l1);
                        bundleFamilyMap.put(pli.Apttus_Proposal__Product__r.Family,pli.Apttus_QPConfig__ClassificationId__r.Name);
                    }
                    //Map of Option Product and Line Item (excluding L1 Products)
                    else{
                        if(productLineMap.containsKey(uniqueOptionId)){
                            List<Apttus_Proposal__Proposal_Line_Item__c> l = productLineMap.get(uniqueOptionId);
                            l.add(pli);
                            productLineMap.put(uniqueOptionId,l);
                        } 
                        else{
                            List<Apttus_Proposal__Proposal_Line_Item__c> l = new List<Apttus_Proposal__Proposal_Line_Item__c>();
                            l.add(pli);
                            productLineMap.put(uniqueOptionId,l);
                        }
                    }
                    
                    //Create Map for Ship To
                    if(shipToMap==null){
                        shipToMap.put(pli.Apttus_QPConfig__ShipToAccountId__r.Name,1);
                    }
                    else{
                        if(!shipToMap.containsKey(pli.Apttus_QPConfig__ShipToAccountId__r.Name)){
                            shipToMap.put(pli.Apttus_QPConfig__ShipToAccountId__r.Name,shipToMap.size()+1);
                        }
                    }
                    
                    String bundleCategory = pli.Apttus_QPConfig__ClassificationId__r.Name;
                    String key = pli.Apttus_Proposal__Proposal__c + pli.Apttus_QPConfig__ShipToAccountId__r.Name;
                    if(bundleCategory!=Null){
                        shipToRecurringMap.put(key,0.0);
                        shipToOneTimeMap.put(key,0.0);
                        shipToUsageMap.put(key,0.0);
                        shipToCampaignSetupMap.put(key,0.0);
                        shipToCreativeDesignMap.put(key,0.0);
                        shipToManagementFeeMap.put(key,0.0);
                        shipToMonthlyFeeMap.put(key,0.0);
                        Set<String> temp = new Set<String>();
                        if(shipToBundleMap!=Null && shipToBundleMap.containsKey(key)){
                            temp = shipToBundleMap.get(key);
                        }
                        temp.add(bundleCategory);
                        shipToBundleMap.put(key,temp);
                    }
                }
                
                //Calculate prices for Level 1 products and store in Proposal Template Data records
                List<SLTC_Proposal_Template_Data__c> propTemplateList = new List<SLTC_Proposal_Template_Data__c>();
                List<SLTC_Proposal_Template_Data__c> propTemplateListMultiProperty = new List<SLTC_Proposal_Template_Data__c>();
                for(String plId : level1Map.KeySet()){
                    SLTC_Proposal_Template_Data__c propTemplate = initializePropTemplateData(productLineMap,plId);
                    propTemplate.SLTC_Is_Bundle_Product__c = true;
                    propTemplate.SLTC_Ship_To_Bundle__c='';
                    propTemplate.SLTC_Units__c = productLineMap.get(plId)[0].Apttus_QPConfig__Quantity2__c;
                    propTemplate.SLTC_Product__c = productLineMap.get(plId)[0].Apttus_Proposal__Product__c;
                    List<Apttus_Proposal__Proposal_Line_Item__c> pliList = productLineMap.get(plId);
                    if(pliList!=null && !pliList.isEmpty()){
                        String key = propTemplate.SLTC_Proposal__c + propTemplate.SLTC_Ship_To__c;
                        for(Apttus_Proposal__Proposal_Line_Item__c pli : pliList){
                            if(pli.Apttus_QPConfig__ProductOptionId__c != NULL){
                                propTemplate = prepareProposalTemplate(propTemplate, pli, shipToMap, productLineMap, plId, bundleFamilyMap);
                                propTemplate.SLTC_Product_Name__c=pli.Apttus_QPConfig__ClassificationId__r.Name;
                                List<String> shipToList = new List<String>();
                                if(proposalShipToMap!=null && proposalShipToMap.get(propTemplate.SLTC_Proposal__c)!=null){
                                    shipToList=proposalShipToMap.get(propTemplate.SLTC_Proposal__c);
                                }
                                key = propTemplate.SLTC_Proposal__c + propTemplate.SLTC_Ship_To__c;
                                if(!shipToList.contains(propTemplate.SLTC_Ship_To__c)){
                                    propTemplate.SLTC_Duplicate_Property_Check__c=true;
                                    shipToList.add(propTemplate.SLTC_Ship_To__c);
                                    
                                    if(shipToBundleMap!=null && shipToBundleMap.containsKey(key)){
                                        List<String> bundleNames = new List<String>(shipToBundleMap.get(key));
                                        propTemplate.SLTC_Ship_To_Bundle__c=String.join(bundleNames,', ');
                                    }
                                }
                                
                                propTemplate.SLTC_Recurring_Net_Price__c=productLineMap.get(plId)[0].Apttus_QPConfig__NetUnitPrice__c;
                                proposalShipToMap.put(propTemplate.SLTC_Proposal__c,shipToList);
                            }
                            if(pli.Apttus_QPConfig__SellingFrequency__c!='One Time'){
                                propTemplate.SLTC_Frequency__c = pli.Apttus_QPConfig__SellingFrequency__c;
                            }
                            if(pli.Apttus_QPConfig__SellingFrequency__c=='One Time' && propTemplate.SLTC_Frequency__c==''){
                                propTemplate.SLTC_Frequency__c = pli.Apttus_QPConfig__SellingFrequency__c;
                            }
                            if(pli.Apttus_QPConfig__LineStatus__c!='Existing' && pli.Apttus_QPConfig__ProductOptionId__c == NULL ){
                                    propTemplate.SLTC_Line_Status__c=pli.Apttus_QPConfig__LineStatus__c;
                            }
                        }
                        if(propTemplate.SLTC_Proposal__c!=NULL){
                            if(shipToRecurringMap!=null && shipToRecurringMap.containsKey(key)){
                                shipToRecurringMap.put(key,shipToRecurringMap.get(key)+propTemplate.SLTC_Total_Recurring_Price__c);
                            }
                            if(shipToOneTimeMap!=null && shipToOneTimeMap.containsKey(key)){
                                shipToOneTimeMap.put(key,shipToOneTimeMap.get(key)+propTemplate.SLTC_One_Time_Net_Price__c);
                            }
                            if(shipToUsageMap!=null && shipToUsageMap.containsKey(key)){
                                shipToUsageMap.put(key,shipToUsageMap.get(key)+propTemplate.SLTC_Usage_Fee__c);
                            }
                            if(shipToCampaignSetupMap!=null && shipToCampaignSetupMap.containsKey(key)){
                                shipToCampaignSetupMap.put(key,shipToCampaignSetupMap.get(key)+propTemplate.SLTC_Campaign_Set_Up_Fee__c);
                            }
                            if(shipToCreativeDesignMap!=null && shipToCreativeDesignMap.containsKey(key)){
                                shipToCreativeDesignMap.put(key,shipToCreativeDesignMap.get(key)+propTemplate.SLTC_Creative_Design_Development_Fee__c);
                            }
                            if(shipToManagementFeeMap!=null && shipToManagementFeeMap.containsKey(key)){
                                shipToManagementFeeMap.put(key,shipToManagementFeeMap.get(key)+propTemplate.SLTC_Management_Fee__c);
                            }
                            if(shipToMonthlyFeeMap!=null && shipToMonthlyFeeMap.containsKey(key)){
                                shipToMonthlyFeeMap.put(key,shipToMonthlyFeeMap.get(key)+propTemplate.SLTC_Monthly_Fee__c);
                            }
                            String solutionMapKey = String.valueOf(propTemplate.SLTC_Proposal__c) + String.valueOf(propTemplate.SLTC_Product__c);
                            Decimal solutionTotal = propTemplate.SLTC_Total_Recurring_Price__c + propTemplate.SLTC_One_Time_Net_Price__c + propTemplate.SLTC_Usage_Fee__c;
                            if(solutionOverviewMap!=null && solutionOverviewMap.containsKey(solutionMapKey)){
                                solutionTotal += solutionOverviewMap.get(solutionMapKey);
                                solutionOverviewMap.put(solutionMapKey,solutionTotal);
                            }
                            else{
                                solutionOverviewMap.put(solutionMapKey,solutionTotal);
                            }
                            if(finalizedProposalMap.get(propTemplate.SLTC_Proposal__c).SLTC_Number_Of_Properties__c > 1){
                                propTemplateListMultiProperty.add(propTemplate);
                            }
                            else{
                                propTemplateList.add(propTemplate);
                            }
                        } 
                    }
                }
                
                //Calculate prices for non Level 1 products and store in Proposal Template Data
                for(String plId : productLineMap.KeySet()){
                    if(!level1Map.ContainsKey(plId)){
                        SLTC_Proposal_Template_Data__c propTemplate = initializePropTemplateData(productLineMap,plId);
                        propTemplate.SLTC_Is_Bundle_Product__c = false;
                        for(Apttus_Proposal__Proposal_Line_Item__c pli : productLineMap.get(plId)){
                            propTemplate = prepareProposalTemplate(propTemplate, pli, shipToMap, productLineMap, plId, bundleFamilyMap);
                            propTemplate.SLTC_Product_Name__c=pli.Apttus_QPConfig__OptionId__r.Name;
                            propTemplate.SLTC_Product__c = pli.Apttus_QPConfig__OptionId__c;
                            propTemplate.SLTC_Parent_Product__c = pli.Apttus_Proposal__Product__c;
                            propTemplate.SLTC_Units__c=pli.Apttus_QPConfig__Quantity2__c;
                            if(pli.Apttus_QPConfig__SellingFrequency__c!='One Time'){
                                propTemplate.SLTC_Frequency__c = pli.Apttus_QPConfig__SellingFrequency__c;
                            }
                            if(pli.Apttus_QPConfig__SellingFrequency__c=='One Time' && propTemplate.SLTC_Frequency__c==''){
                                propTemplate.SLTC_Frequency__c = pli.Apttus_QPConfig__SellingFrequency__c;
                            }
                        }
                        if(finalizedProposalMap.get(propTemplate.SLTC_Proposal__c).SLTC_Number_Of_Properties__c > 1  && finalizedProposalMap.get(propTemplate.SLTC_Proposal__c).SLTC_Number_Of_Properties__c !=null){
                            propTemplateListMultiProperty.add(propTemplate);
                        }
                        else{
                            propTemplateList.add(propTemplate);
                        }
                    }
                }
                //Sort Proposal Template Data records according to sequence & Insert
                if(propTemplateList!=null && !propTemplateList.isEmpty()){
                    propTemplateList = sortProposalTemplate(propTemplateList,false,shipToRecurringMap,shipToOneTimeMap,shipToUsageMap,solutionOverviewMap);
                    insert propTemplateList;
                }
                if(propTemplateListMultiProperty!=null && !propTemplateListMultiProperty.isEmpty()){
                    propTemplateListMultiProperty = sortProposalTemplate(propTemplateListMultiProperty,true,shipToRecurringMap,shipToOneTimeMap,shipToUsageMap,solutionOverviewMap);
                    insert propTemplateListMultiProperty;
                }
            }
        }  catch (Exception exec) {
            String message = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
            NI_Error_Logger.WriteToLog(message, ' ProposalTemplateData', 'sltc_Apttus_Proposal_TriggerHandler-createProposalTemplateDataRecords', 'INSERT');
        }
    }
    
    // ========================================
    //  Prepare Proposal Template Data Record
    // ========================================
    private SLTC_Proposal_Template_Data__c prepareProposalTemplate(SLTC_Proposal_Template_Data__c propTemp, Apttus_Proposal__Proposal_Line_Item__c pli, Map<String,Integer> shipToMap, Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>> productLineMap,String plId, Map<String,String> bundleFamilyMap)
    {
        SLTC_Proposal_Template_Data__c propTemplate = propTemp;
        if(pli.Apttus_QPConfig__PriceType__c=='Recurring'){
            if(pli.Apttus_QPConfig__ListPrice__c!=null){
                propTemplate.SLTC_Recurring_List_Price__c+=pli.Apttus_QPConfig__ListPrice__c;
            } 
            if(pli.Apttus_QPConfig__NetUnitPrice__c!=null && pli.Apttus_QPConfig__Quantity2__c !=null){
                //propTemplate.SLTC_Recurring_Net_Price__c+=pli.Apttus_QPConfig__NetUnitPrice__c;
                propTemplate.SLTC_Recurring_Net_Price__c+=(pli.Apttus_QPConfig__NetUnitPrice__c*pli.Apttus_QPConfig__Quantity2__c);
            } 
            if(pli.Apttus_QPConfig__NetPrice__c!=null){
                propTemplate.SLTC_Total_Recurring_Price__c +=pli.Apttus_QPConfig__NetPrice__c;
            } 
            if(pli.SLTC_Discount_for_Template__c!=null){
                propTemplate.SLTC_Recurring_Discount__c = pli.SLTC_Discount_for_Template__c;
            }
            if(propTemplate.SLTC_Delta_Recurring_Price__c==0){
                propTemplate.SLTC_Delta_Recurring_Price__c = pli.Apttus_QPConfig__DeltaPrice__c;
            }
            if(propTemplate.SLTC_Delta_Quantity__c==0){
                propTemplate.SLTC_Delta_Quantity__c = pli.Apttus_QPConfig__DeltaQuantity__c;
            }
        }
        if(pli.Apttus_QPConfig__PriceType__c=='One Time'){
            if(pli.Apttus_QPConfig__ListPrice__c!=null){
                propTemplate.SLTC_One_Time_List_Price__c+=pli.Apttus_QPConfig__ListPrice__c;
            } 
            if(pli.Apttus_QPConfig__NetPrice__c!=null){
                propTemplate.SLTC_One_Time_Net_Price__c+=pli.Apttus_QPConfig__NetPrice__c;
            } 
            if(pli.SLTC_Discount_for_Template__c!=null){
                propTemplate.SLTC_OneTime_Discount__c = pli.SLTC_Discount_for_Template__c;
            } 
            if(propTemplate.SLTC_Delta_One_Time_Price__c==0){
                propTemplate.SLTC_Delta_One_Time_Price__c = pli.Apttus_QPConfig__DeltaPrice__c;
            }
            if(propTemplate.SLTC_Delta_Quantity__c==0){
                propTemplate.SLTC_Delta_Quantity__c = pli.Apttus_QPConfig__DeltaQuantity__c;
            }
        }
        if(pli.Apttus_QPConfig__PriceType__c=='Usage'){
            //propTemplate.SLTC_Usage_Fee__c+=pli.Apttus_QPConfig__NetPrice__c;
            propTemplate.SLTC_Usage_Fee__c=pli.SLTC_Related_Escalator_Adjustment_Amount__c;
        }
        propTemplate.SLTC_Ship_To__c=pli.Apttus_QPConfig__ShipToAccountId__r.Name;
        if(shipToMap!=null){
            propTemplate.SLTC_Ship_To_Number__c=shipToMap.get(pli.Apttus_QPConfig__ShipToAccountId__r.Name);
        } 
        propTemplate.SLTC_Proposal__c=pli.Apttus_Proposal__Proposal__c;
        if(pli.Apttus_Proposal__Product__c!=NULL && pli.Apttus_Proposal__Product__r.Family!=null && bundleFamilyMap!=null){
            propTemplate.SLTC_Bundle_Name__c = bundleFamilyMap.get(pli.Apttus_Proposal__Product__r.Family);
        }
        if(propTemplate.SLTC_Is_Bundle_Product__c==false && pli.Apttus_QPConfig__LineStatus__c!='Existing'){
            propTemplate.SLTC_Line_Status__c=pli.Apttus_QPConfig__LineStatus__c;
        }
        if(pli.Apttus_QPConfig__ChargeType__c=='Setup Fees'  && pli.Apttus_QPConfig__NetPrice__c!=null){
            propTemplate.SLTC_Campaign_Set_Up_Fee__c +=pli.Apttus_QPConfig__NetPrice__c;
        }
        if(pli.Apttus_QPConfig__ChargeType__c=='Creative Fees' && pli.Apttus_QPConfig__NetPrice__c!=null){
            propTemplate.SLTC_Creative_Design_Development_Fee__c +=pli.Apttus_QPConfig__NetPrice__c;
        }
        if(pli.Apttus_QPConfig__ChargeType__c=='Subscription Fee' && pli.Apttus_QPConfig__NetPrice__c!=null){
            propTemplate.SLTC_Management_Fee__c +=pli.Apttus_QPConfig__NetPrice__c;
        }
        if(pli.Apttus_QPConfig__ChargeType__c=='Monthly Budget' && pli.Apttus_QPConfig__NetPrice__c!=null){
            propTemplate.SLTC_Monthly_Fee__c +=pli.Apttus_QPConfig__NetPrice__c;
        }
        propTemplate.SLTC_Proposal_Product_Attribute_Value__c = pli.Apttus_QPConfig__AttributeValueId__c;
        propTemplate.SLTC_Option_Group__c= pli.Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__OptionGroupLabel__c;
        propTemplate.SLTC_Product_Family__c=pli.Apttus_Proposal__Product__r.Family;
        propTemplate.SLTC_Product_Name_2__c=pli.Apttus_Proposal__Product__r.Name;
        
        return propTemplate;
    }
    
    // ========================================
    //  Sort Proposal Template Data Records
    // ========================================
    private List<SLTC_Proposal_Template_Data__c> sortProposalTemplate(List<SLTC_Proposal_Template_Data__c> propTemplateList,
                                                                       Boolean isMultiProp,
                                                                       Map<String,Decimal> shipToRecurringMap,
                                                                       Map<String,Decimal> shipToOneTimeMap,
                                                                       Map<String,Decimal> shipToUsageMap,
                                                                       Map<String,Decimal> solutionOverviewMap)
    {
        List<SLTC_Proposal_Template_Data__c> sortedTempList = new List<SLTC_Proposal_Template_Data__c>();
        List<SLTC_Proposal_Template_Data__c> sortedTempListMultiProp = new List<SLTC_Proposal_Template_Data__c>();
        List<Decimal> sortedSequenceList = new List<Decimal>();
        Set<String> sortedPropertyList = new Set<String>();
        Map<Decimal,SLTC_Proposal_Template_Data__c> sequenceMap = new Map<Decimal,SLTC_Proposal_Template_Data__c>();
        Map<String,List<SLTC_Proposal_Template_Data__c>> propertyMap = new Map<String,List<SLTC_Proposal_Template_Data__c>>();
        for(SLTC_Proposal_Template_Data__c prop : propTemplateList){
            String solutionMapKey = String.valueOf(prop.SLTC_Proposal__c) + String.valueOf(prop.SLTC_Product__c);
            sequenceMap.put(prop.SLTC_Sequence__c,prop);
            sortedSequenceList.add(prop.SLTC_Sequence__c);
            sortedPropertyList.add(prop.SLTC_Ship_To__c);
            
            String key = prop.SLTC_Proposal__c + prop.SLTC_Ship_To__c;
            
            if(prop.SLTC_Duplicate_Property_Check__c == true){
                if(shipToRecurringMap.containsKey(key)){
                    prop.SLTC_Ship_To_Recurring_Total__c=shipToRecurringMap.get(key);
                }
                if(shipToOneTimeMap.containsKey(key)){
                    prop.SLTC_Ship_To_One_Time_Total__c=shipToOneTimeMap.get(key);
                }
                if(shipToUsageMap.containsKey(key)){
                    prop.SLTC_Ship_To_Usage__c=shipToUsageMap.get(key);
                }
                
            }
            if(solutionOverviewMap!=null && solutionOverviewMap.containsKey(solutionMapKey) && prop.SLTC_Is_Bundle_Product__c){
                prop.SLTC_Included_in_Solution_Overview__c=true;
                prop.SLTC_Solution_Overview_Total__c = solutionOverviewMap.get(solutionMapKey);
                solutionOverviewMap.remove(solutionMapKey);
            }
            
            if(isMultiProp){
                List<SLTC_Proposal_Template_Data__c> tempList = new List<SLTC_Proposal_Template_Data__c>();
                if(propertyMap.containsKey(prop.SLTC_Ship_To__c)){
                    tempList=propertyMap.get(prop.SLTC_Ship_To__c);
                }
                tempList.add(prop);
                propertyMap.put(prop.SLTC_Ship_To__c,tempList);
            }
        }
        
        sortedSequenceList.sort();
        List<String> convertedSortPropertList = new List<String>(sortedPropertyList);
        convertedSortPropertList.sort();
        
        for(Decimal deci : sortedSequenceList){
            sortedTempList.add(sequenceMap.get(deci));
        }
        
        //Sorting by Property Name for MultiProperty Quotes
        if(isMultiProp && propertyMap!=null){
            for(String str: convertedSortPropertList){
                List<SLTC_Proposal_Template_Data__c> propertyList = propertyMap.get(str);
                List<SLTC_Proposal_Template_Data__c> tempList = new List<SLTC_Proposal_Template_Data__c>();
                for(Decimal deci : sortedSequenceList){
                    if(propertyList.contains(sequenceMap.get(deci))){
                        tempList.add(sequenceMap.get(deci));
                    }
                }
                sortedTempListMultiProp.addAll(tempList);
            }
            return sortedTempListMultiProp;
        }
        return sortedTempList;
    }
    
    public void checkDates(List<Apttus_Proposal__Proposal__c> listNewProposals, Map<Id,Apttus_Proposal__Proposal__c> mapOldProposals)
    {
        Set<Id> setOppId = new Set<Id>();
        Set<Id> setProdConfigs = new Set<Id>();
        for(Apttus_Proposal__Proposal__c objProposal : listNewProposals)
        {
            if(objProposal.Apttus_Proposal__Opportunity__c != null)
            {
                setOppId.add(objProposal.Apttus_Proposal__Opportunity__c);
                setProdConfigs.add(objProposal.SLTC_Product_Configuration__c);
            }
            
            //logic to stamp proposal accepted date when the proposal is accepted
            if(objProposal.Apttus_Proposal__Approval_Stage__c == 'Accepted' && mapOldProposals.get(objProposal.Id).Apttus_Proposal__Approval_Stage__c != 'Accepted')
            {
                objProposal.SLTC_Proposal_Accepted_Date__c = System.today();
            }
        }
        
        Map<Id, Apttus_Config2__ProductConfiguration__c> mapProdConfigs = new Map<Id, Apttus_Config2__ProductConfiguration__c>([SELECT Id, SLTC_Number_of_ASEM_Lines__c, Apttus_Config2__Status__c, Apttus_QPConfig__Proposald__c, Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Target_HRM_Org__c, Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Target_HRM_Org__r.Annual_Salesforce_Renewal_Date__c FROM Apttus_Config2__ProductConfiguration__c WHERE Id IN :setProdConfigs]);
        Map<Id, Integer> mapProposalToFinalizedCartCount = new Map<Id, Integer>();
        //get count of finalized carts in a proposal for error handling mechanism
        for(Apttus_Config2__ProductConfiguration__c objProdConfig : mapProdConfigs.values())
        {
            if(objProdConfig.Apttus_Config2__Status__c == 'Apttus_Config2__Status__c')
            {
                if(!mapProposalToFinalizedCartCount.containsKey(objProdConfig.Apttus_QPConfig__Proposald__c))
                {
                    mapProposalToFinalizedCartCount.put(objProdConfig.Apttus_QPConfig__Proposald__c, 0);
                }
                Integer count = mapProposalToFinalizedCartCount.get(objProdConfig.Apttus_QPConfig__Proposald__c);
                count++;
                mapProposalToFinalizedCartCount.put(objProdConfig.Apttus_QPConfig__Proposald__c, count);
            }
        }
        
        for(Apttus_Proposal__Proposal__c objProposal : listNewProposals)
        {
            //allow changing start date when seller defined dates is true and update is done before finalize and from UI only and not from flow of product config
            if(objProposal.Apttus_Proposal__ExpectedStartDate__c != mapOldProposals.get(objProposal.Id).Apttus_Proposal__ExpectedStartDate__c
               && objProposal.SLTC_Is_Date_Calculation_required__c && objProposal.SLTC_Is_Date_Calculation_required__c == mapOldProposals.get(objProposal.Id).SLTC_Is_Date_Calculation_required__c && objProposal.Apttus_QPConfig__ConfigurationFinalizedDate__c == null
              && !objProposal.SLTC_Flow_Updated_Dates_FLag__c)
            {
                objProposal.SLTC_Update_Count__c = 1;
            }

            //error handling criteria
            //error handling for restriction of editing dates in case of auto renewal quote created from flow 
            if(objProposal.SLTC_Is_Date_Calculation_required__c && objProposal.SLTC_Renewal_Proposal_Created_via_Flow__c && 
               (objProposal.Apttus_Proposal__ExpectedStartDate__c != mapOldProposals.get(objProposal.Id).Apttus_Proposal__ExpectedStartDate__c ||
                objProposal.Apttus_Proposal__ExpectedEndDate__c != mapOldProposals.get(objProposal.Id).Apttus_Proposal__ExpectedEndDate__c || 
               objProposal.SLTC_Term_Length_Month__c != mapOldProposals.get(objProposal.Id).SLTC_Term_Length_Month__c))
            {
                objProposal.addError('You cannot edit dates or term on the proposal that is automatically created from renewal process.');
            }
            //error handling for rest of the scenarios
            if(objProposal.SLTC_Update_Count__c > 1)
            {
                //dont allow changing start date in case of seller defined dates = false and when not done from flow
                if((objProposal.Apttus_Proposal__ExpectedStartDate__c != mapOldProposals.get(objProposal.Id).Apttus_Proposal__ExpectedStartDate__c
                    && (!objProposal.SLTC_Flow_Updated_Dates_FLag__c || 
                        (mapProposalToFinalizedCartCount.containsKey(objProposal.Id) && mapProposalToFinalizedCartCount.get(objProposal.Id) > 1)) )
                  || (objProposal.SLTC_Is_Date_Calculation_required__c != mapOldProposals.get(objProposal.Id).SLTC_Is_Date_Calculation_required__c && !objProposal.SLTC_Is_Date_Calculation_required__c))
                {
                   objProposal.addError('You cannot change the date calculation logic once it has been set');
                }
                else
                {
                    // System.debug('Not going in if loop');
                }
                //term can never be changed
                if(objProposal.SLTC_Term_Length_Month__c != mapOldProposals.get(objProposal.Id).SLTC_Term_Length_Month__c && !objProposal.SLTC_Is_Date_Calculation_required__c)
                {
                        objProposal.addError('You cannot change the Term Length (Months) once it has been set');
                }
            }
            else if(objProposal.SLTC_Update_Count__c == 1)
            {
               if(objProposal.SLTC_Term_Length_Month__c == null && objProposal.Apttus_Proposal__ExpectedEndDate__c == null && !objProposal.SLTC_Is_Date_Calculation_required__c)
                {
                    objProposal.addError('You cannot have Term Length (Months) as blank in case of automatic date calculation');
                }   
            }
            else
            {
                objProposal.SLTC_Original_Start_Date__c = objProposal.Apttus_Proposal__ExpectedStartDate__c;
            }
            // calc end date from start date and term in case of seller defined dates = false or asem not existing
            if(objProposal.SLTC_Term_Length_Month__c != null && objProposal.Apttus_Proposal__ExpectedStartDate__c != null && ((((mapProdConfigs.get(objProposal.SLTC_Product_Configuration__c) !=null && mapProdConfigs.get(objProposal.SLTC_Product_Configuration__c).SLTC_Number_of_ASEM_Lines__c<1))) || (!objProposal.SLTC_Is_Date_Calculation_required__c)))
            {
                objProposal.Apttus_Proposal__ExpectedEndDate__c = objProposal.Apttus_Proposal__ExpectedStartDate__c.addMonths(Integer.valueOf(objProposal.SLTC_Term_Length_Month__c)) - 1;   
            }
            // if ASEM Lines > 1 and Target HRM ORG Renewal Date is defined
            if(objProposal.SLTC_Term_Length_Month__c != null && mapProdConfigs.get(objProposal.SLTC_Product_Configuration__c) !=null && mapProdConfigs.get(objProposal.SLTC_Product_Configuration__c).SLTC_Number_of_ASEM_Lines__c>1 && mapProdConfigs.get(objProposal.SLTC_Product_Configuration__c).Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Target_HRM_Org__c!= null && mapProdConfigs.get(objProposal.SLTC_Product_Configuration__c).Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Target_HRM_Org__r.Annual_Salesforce_Renewal_Date__c != null && !objProposal.SLTC_Is_Date_Calculation_required__c){
                objProposal.Apttus_Proposal__ExpectedEndDate__c = mapProdConfigs.get(objProposal.SLTC_Product_Configuration__c).Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Target_HRM_Org__r.Annual_Salesforce_Renewal_Date__c;
            }
            //calc term in case of seller defined dates = true 
            if(objProposal.Apttus_Proposal__ExpectedStartDate__c!=null && objProposal.Apttus_Proposal__ExpectedEndDate__c!=null && objProposal.SLTC_Is_Date_Calculation_required__c)
            {                
              objProposal.SLTC_Term_Length_Month__c = calcTerm(objProposal.Apttus_Proposal__ExpectedStartDate__c, objProposal.Apttus_Proposal__ExpectedEndDate__c);
            }
            //calc end date from start date and term in case of seller defined dates = true and end date seems to be blank in above if condition
            else if(objProposal.Apttus_Proposal__ExpectedStartDate__c != null && objProposal.SLTC_Term_Length_Month__c != null && objProposal.SLTC_Is_Date_Calculation_required__c)
            {
                objProposal.Apttus_Proposal__ExpectedEndDate__c = objProposal.Apttus_Proposal__ExpectedStartDate__c.addMonths(Integer.valueOf(objProposal.SLTC_Term_Length_Month__c)) - 1;
            }
            //update count during each update time
            if(mapOldProposals.get(objProposal.Id).SLTC_Update_Count__c == null)
            {
               objProposal.SLTC_Update_Count__c = 0;   
            }
            objProposal.SLTC_Update_Count__c++;
        }
    }
    
    public void updateRenewalTerm(List<Apttus_Proposal__Proposal__c> listNewProposals, Map<Id,Apttus_Proposal__Proposal__c> mapNewProposal)
    {
        for(Apttus_Proposal__Proposal__c objProposal : listNewProposals){
            if(objProposal.SLTC_Renewal_Period__c == null && objProposal.SLTC_Term_Length_Month__c != null ){
                objProposal.SLTC_Renewal_Period__c = objProposal.SLTC_Term_Length_Month__c;
          }
            
        }
    }
    public static Decimal calcTerm(Date startDate, Date endDate)
    {
        Integer monthDiff = startDate.monthsBetween(endDate);
        if (endDate.day() > startDate.day()) {monthDiff++;}
        return Decimal.valueOf(monthDiff);
    }

    public SLTC_Proposal_Template_Data__c initializePropTemplateData(Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>> productLineMap,String plId){
        SLTC_Proposal_Template_Data__c propTemplate = new SLTC_Proposal_Template_Data__c();
        propTemplate.SLTC_Recurring_List_Price__c = 0;
        propTemplate.SLTC_Recurring_Net_Price__c = 0;
        propTemplate.SLTC_Total_Recurring_Price__c = 0;
        propTemplate.SLTC_One_Time_List_Price__c = 0;
        propTemplate.SLTC_One_Time_Net_Price__c = 0;
        propTemplate.SLTC_Usage_Fee__c=0;
        propTemplate.SLTC_Campaign_Set_Up_Fee__c=0;        
        propTemplate.SLTC_Creative_Design_Development_Fee__c=0;
        propTemplate.SLTC_Management_Fee__c=0;
        propTemplate.SLTC_Monthly_Fee__c=0;
        propTemplate.SLTC_Product_Name__c = '';
        propTemplate.SLTC_Delta_Quantity__c = 0;
        propTemplate.SLTC_Delta_One_Time_Price__c=0;
        propTemplate.SLTC_Delta_Recurring_Price__c=0;
        propTemplate.SLTC_Line_Status__c='Existing';
        propTemplate.SLTC_Campaign_Set_Up_Fee__c=0;
        propTemplate.SLTC_Creative_Design_Development_Fee__c=0;
        propTemplate.SLTC_Management_Fee__c=0;
        propTemplate.SLTC_Monthly_Fee__c=0;
        Decimal sequence = 0.0;
        sequence += productLineMap.get(plId)[0].Apttus_QPConfig__LineNumber__c;
        sequence += productLineMap.get(plId)[0].Apttus_QPConfig__ItemSequence__c/1000;
        propTemplate.SLTC_Sequence__c = sequence;
        propTemplate.SLTC_Option_Group__c='';
        propTemplate.SLTC_Solution_Overview_Total__c=0;
        propTemplate.SLTC_Frequency__c = '';

        return propTemplate;
    }
}