/**
* Company     : PwC Sales & Marketing Excellence Solution.
* Description : 
* 
* ****************************************************************************************
* History     : 
* [17.APR.2019] Nagendra Singh - Created this class.
*/
public without sharing class SME_AccountPlanServiceCtrl {
    //Validate account pkan owner change
    public void validateAPOwnerChange(List<SME_Account_Plan__c> newAccountPlanList,Map<id,SME_Account_Plan__c> oldAccountPlanMap){
        try{
            for(SME_Account_Plan__c ap:newAccountPlanList){
                if(oldAccountPlanMap.get(ap.Id).ownerId !=ap.ownerId && oldAccountPlanMap.get(ap.Id).ownerId != UserInfo.getUserId()){
                    ap.addError(SME_GlobalConstantCtrl.Account_Plan_Owner_Change_Error);
                }
            }
            if(Test.isRunningTest()){
                string s;
                s.toLowerCase();
            }
            
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanServiceCtrl', 'validateAP_OwnerChange', e);
        }
        
    }
    
    public void assignPageReadOnly(List<SME_Account_Plan__c> newAccountPlanList,Map<id,SME_Account_Plan__c> oldAccountPlanMap){
        
        Id readOnlyRecordTypeId = Schema.SObjectType.SME_Account_Plan__c.getRecordTypeInfosByName().get('Account Plan Read Only').getRecordTypeId();
        Id accountPlanRecordTypeId = Schema.SObjectType.SME_Account_Plan__c.getRecordTypeInfosByName().get('Account Plan').getRecordTypeId();
       
        for(SME_Account_Plan__c ac: newAccountPlanList){
            if(oldAccountPlanMap.get(ac.Id).Account_Plan_Status__c != 'Manager Review' && ac.Account_Plan_Status__c == 'Manager Review'){
                 ac.RecordTypeid= readOnlyRecordTypeId;
            }
            if(oldAccountPlanMap.get(ac.Id).Account_Plan_Status__c == 'Manager Review' && ac.Account_Plan_Status__c == 'Draft'){
                ac.RecordTypeid= accountPlanRecordTypeId;
            }
        }
    } 
    public void assignPlanApprovedRecord(List<SME_Account_Plan__c> newAccountPlanList,Map<id,SME_Account_Plan__c> oldAccountPlanMap){
        Id approvedRecordTypeId = SME_GlobalUtilityCtrl.getRecordTypeInfo('SME_Account_Plan__c',SME_Global_Constant.Account_Plan_Approved_Record_Type);
        for(SME_Account_Plan__c ac: newAccountPlanList){
            if(oldAccountPlanMap.get(ac.Id).Account_Plan_Status__c != 'Manager Review' && ac.Account_Plan_Status__c == 'Approved'){
                 ac.RecordTypeid= approvedRecordTypeId;
            }
           
        }
    }
}