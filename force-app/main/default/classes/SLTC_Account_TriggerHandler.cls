/****************************************************************************************
*****************************************************
Name 			: SLTC_Account_TriggerHandler
Author 			: Lamu Sreeharsha
Created Date 	: 5/23/2022
Last Mod Date 	: 5/23/2022
Last Mod By 	: Lamu Sreeharsha
NICC Reference 	:
Description 	: TriggerHandler used to prevent  Accounts(SLTC) merge for certain  
                    type field value like 'Customer','Former Customer','Permanently Closed'
*****************************************************************************************
*****************************************************/

public class SLTC_Account_TriggerHandler {
    // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING.
    Private NI_TriggerBypassSwitches__c bpSwitch;
    Public SLTC_Account_TriggerHandler(){
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE.
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }
    
    // ================================================================================
    // Method to check Switch On/Off the TriggerHandler and custom Permission.
    // ================================================================================
    public void OnAfterDelete(List<Account> olddata){
        // ONLY EXECUTE CODE IF BYBASS IS NOT CHECKED and custom permiision is not assigned 
        if(!bpSwitch.Bypass_SLTC_Account_AfterDelete__c && !FeatureManagement.checkPermission('SLTC_Bypass_ValidationRules_Automation')){
            afterdeleteRecords(olddata);
          }   
    }
    
    // ======================================================================================
    // Method to check Account - Type and MasterRecordId and Display Message to Stop Mergeing Accounts
    // ======================================================================================
    private void afterdeleteRecords(List<Account> oldRecords){
        List<String> accountTypevalues =  new List<String>{'Customer','Former Customer','Permanently Closed'};
        //Get All RecordTypes related to Account    
        Map<ID, Schema.RecordTypeInfo> accountrecordtypes = Schema.SObjectType.Account.getRecordTypeInfosById();    
        for(Account currentAccount: oldRecords){
            System.debug(currentAccount);
            String recordTypeName = accountrecordtypes.get(currentAccount.RecordTypeId).getDeveloperName(); 
            If(currentAccount.MasterRecordId != NULL && accountTypevalues.contains(currentAccount.Type) && recordTypeName.contains('SLTC') == True){
                 currentAccount.addError('Only Accounts of the Type "Prospect" and "Preliminary" are only allowed to merge');
              }   
        } 
    }
}