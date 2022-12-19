/**********************************************************
*************************************
Name :   SLTC_Account_Affiliation_TriggerHandler
Author : Jaswanth R
Created Date : 5/09/2022
Last Mod Date :  11/21/2022
Last Mod By : Jaswanth R
NICC Reference : 
Description :Trigger handler for SLTC_Account_Affiliation_Trigger(insert,update)
***********************************************************
*************************************/


public class SLTC_Account_Affiliation_TriggerHandler {  
    // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING.
    private NI_TriggerBypassSwitches__c bpSwitch;
    public SLTC_Account_Affiliation_TriggerHandler(){
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE.
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }  
    // ========================================
    // BeforeInsert method to check Switch On/Off of TriggerHandler and custom Permission.
    // ========================================
    
    public void onBeforeInsert(List<SLTC_Account_Affiliation__c> trigger_new){
        // ONLY EXECUTE CODE IF BYBASS IS NOT CHECKED and custom permiision is not assigned
        if(!bpSwitch.Bypass_SLTC_Account_Affiliation_Trigger__c && !FeatureManagement.checkPermission('SLTC_Bypass_ValidationRules_Automation')){
            beforeInsertRecords(trigger_new);
        }   
    }    
    // ========================================
    // BeforeUpdate method to check Switch On/Off of TriggerHandler and custom Permission.
    // ========================================
    
    public void onBeforeUpdate(List<SLTC_Account_Affiliation__c> trigger_new,Map<Id,SLTC_Account_Affiliation__c> trigger_old){
        // ONLY EXECUTE CODE IF BYBASS IS NOT CHECKED and custom permiision is not assigned
        if(!bpSwitch.Bypass_SLTC_Account_Affiliation_Trigger__c && !FeatureManagement.checkPermission('SLTC_Bypass_ValidationRules_Automation')){
            beforeUpdateRecords(trigger_new,trigger_old);
        }   
    } 
    
    // ========================================
    // BeforeUpdate method to check if Affiliation already has active records.
    // ========================================
    
    private void beforeInsertRecords(List<SLTC_Account_Affiliation__c> accountAffiliations){
        List<Id> accAffInacitve = validateAccountAffiliations(accountAffiliations);
        Map<Id,Set<String>> cplInformationMapFirst = createCPLInformationMap(accountAffiliations,accAffInacitve);
        Map<Id,Set<String>> cplOldMapOfferings = cplOldMapGenerate(cplInformationMapFirst);
        validateCPLInformation(cplInformationMapFirst,accountAffiliations,cplOldMapOfferings);
    }
    
    // ========================================
    // BeforeUpdate method to check if Affiliation already has active records.
    // ========================================
    
    private void beforeUpdateRecords(List<SLTC_Account_Affiliation__c> accountAffiliations,Map<Id,SLTC_Account_Affiliation__c> accountAffiliationsOld){
        List<SLTC_Account_Affiliation__c> accAffilitionsToUpdate = new List<SLTC_Account_Affiliation__c>();
        for(SLTC_Account_Affiliation__c accAffNew: accountAffiliations){
            SLTC_Account_Affiliation__c accAffCheckOld = accountAffiliationsOld.get(accAffNew.id);
            if(accAffNew.SLTC_Active__c!= accAffCheckOld.SLTC_Active__c){
                accAffilitionsToUpdate.add(accAffNew);
            }
        }
        List<Id> accAffInacitve = validateAccountAffiliations(accAffilitionsToUpdate);
        Map<Id,Set<String>> cplInformationMapFirst = createCPLInformationMap(accAffilitionsToUpdate,accAffInacitve);
       Map<Id,Set<String>> cplOldMapOfferings = cplOldMapGenerate(cplInformationMapFirst);
        validateCPLInformation(cplInformationMapFirst, accAffilitionsToUpdate, cplOldMapOfferings);
        
    }
    // ============================================================================================
    // Method to:
    // Mark old affiliations inactive of same type.
    // ->return List of <Id> which will not be checked for CPL Offerings.
    // ============================================================================================
    private static List<Id> validateAccountAffiliations(List<SLTC_Account_Affiliation__c> accountCPLAffiliations){

        List<String> affiliationType = new List<String>{'Management Company', 'Franchisor','Ownership Company','Regional Office/Cluster'};
        List<Id> affliationAccount = new List<Id>();
        List<String> affTypeUpdateList = new List<String>();
        List<SLTC_Account_Affiliation__c> affiliationInActiveList = new List<SLTC_Account_Affiliation__c>();
        List<Id> cplParentsOfferingBypass = new List<Id>();
        
        
        for(SLTC_Account_Affiliation__c item : accountCPLAffiliations){
            if( item.SLTC_Active__c == true && affiliationType.contains(item.SLTC_Affiliation_Type__c)){
                if(affiliationType.contains(item.SLTC_Affiliation_Type__c) && item.SLTC_Active__c == true){
                    affliationAccount.add(item.SLTC_Account_Affliation__c);
                    affTypeUpdateList.add(item.SLTC_Affiliation_Type__c);
                }
            }
        }
        if(!affliationAccount.isEmpty()){
            for(SLTC_Account_Affiliation__c affiliationItem : [SELECT Id, SLTC_Affiliation_Type__c,SLTC_Account_Affliation__c, SLTC_Active__c FROM SLTC_Account_Affiliation__c WHERE SLTC_Account_Affliation__c IN: affliationAccount AND SLTC_Affiliation_Type__c IN : affTypeUpdateList AND SLTC_Active__c = TRUE]){
                affiliationItem.SLTC_Active__c = FALSE;
                affiliationInActiveList.add(affiliationItem);
                cplParentsOfferingBypass.add(affiliationItem.SLTC_Account_Affliation__c);
            }
            if(affiliationInActiveList.size()!=0){
                UPDATE affiliationInActiveList;
            } 
        }
        return cplParentsOfferingBypass;
    }
    
    // ==================================================================================================
    // Method to:
    // create a map of affiliations for which cpl offerings have to be verified with other affiliations
    // add error if more than one cpl when full is selected.
    // returns a MAP of <Id,String>
    // ==================================================================================================
    private static Map<Id,Set<String>> createCPLInformationMap(List<SLTC_Account_Affiliation__c> accountCPLAffiliations,List<Id> cplInActiveParents){
        Map<Id,Set<String>> cplInformationMap = new Map<Id,Set<String>>();
        for(SLTC_Account_Affiliation__c item : accountCPLAffiliations){
            if( item.SLTC_Active__c == true && item.SLTC_Offerings__c!= NULL && !cplInActiveParents.contains(item.SLTC_Account_Affliation__c)){
                if(item.SLTC_Offerings__c.contains('Full') && item.SLTC_Offerings__c.split(';').size()>1){
                    item.addError(SLTC_Global_Constant.errorMessageFullOffering); 
                  }
                if(!cplInformationMap.containsKey(item.SLTC_Account_Affliation__c)){
                    cplInformationMap.put(item.SLTC_Account_Affliation__c, new Set<String>());
                    cplInformationMap.get(item.SLTC_Account_Affliation__c).addAll(item.SLTC_Offerings__c.split(';'));
                }       
            }
        }
        return cplInformationMap;
    }
    // =============================================================================================================================================
    // Method to:
    // validate if the CPL Picklist values do not matchup for different records where child and active are same but affiliation type is different.
    // ==============================================================================================================================================
    private static void validateCPLInformation(Map<Id,Set<String>>cplInformationMap,List<SLTC_Account_Affiliation__c> accountCPLAffiliations,Map<Id,Set<String>> cplInformationMapActive){

        Set<String> finalCPL= new Set<String>();
        for(SLTC_Account_Affiliation__c errCPL : accountCPLAffiliations ){
            if(cplInformationMap.containsKey(errCPL.SLTC_Account_Affliation__c) && cplInformationMapActive.containsKey(errCPL.SLTC_Account_Affliation__c)){
                finalCPL.addAll(cplInformationMap.get(errCPL.SLTC_Account_Affliation__c));
                finalCPL.addAll(cplInformationMapActive.get(errCPL.SLTC_Account_Affliation__c));
                integer listSize=cplInformationMap.get(errCPL.SLTC_Account_Affliation__c).size()+cplInformationMapActive.get(errCPL.SLTC_Account_Affliation__c).size();
                if(cplInformationMap.get(errCPL.SLTC_Account_Affliation__c).contains('Full') && cplInformationMapActive.get(errCPL.SLTC_Account_Affliation__c).size()!=0){
                    errCPL.addError(SLTC_Global_Constant.errorMessageNoFull);
                }
                if(cplInformationMapActive.get(errCPL.SLTC_Account_Affliation__c).contains('Full')){
                    errCPL.addError(SLTC_Global_Constant.errorMessageFullSelected);
                }
                if(finalCPL.size()!= listSize){
                    errCPL.addError('The Offerings that are unavailable to select for this child affiliation are:'+cplInformationMapActive.get(errCPL.SLTC_Account_Affliation__c));
                }
            }
        }    
    }
    
    // =============================================================================================================================================
    // Method to:
    // return map of old cpl offerings affiliations
    // ==============================================================================================================================================
    private static Map<Id,Set<String>> cplOldMapGenerate(Map<Id,Set<String>>cplInformationMap){
                Map<Id,Set<String>> cplInformationMapActive = new Map<Id,Set<String>>();
        for(SLTC_Account_Affiliation__c CPLItem :[SELECT Id,SLTC_Offerings__c,SLTC_Account_Affliation__c from SLTC_Account_Affiliation__c WHERE(SLTC_Account_Affliation__c in: cplInformationMap.keySet() AND SLTC_Active__c=TRUE AND SLTC_Offerings__c!=NULL)] ){
            if(!cplInformationMapActive.containsKey(CPLItem.SLTC_Account_Affliation__c)){
                cplInformationMapActive.put(CPLItem.SLTC_Account_Affliation__c, new Set<String>());   
                cplInformationMapActive.get(CPLItem.SLTC_Account_Affliation__c).addAll(CPLItem.SLTC_Offerings__c.split(';'));
            }
        }
        return cplInformationMapActive;
    }
}