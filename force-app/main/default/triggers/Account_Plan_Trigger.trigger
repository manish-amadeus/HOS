/**
 * Company     : PwC Sales & Marketing Excellence Solution.
 * Description : 
 * 
 * ****************************************************************************************
 * History     : 
 * [1.APR.2019] Nagendra - Created this trigger.
 */
trigger Account_Plan_Trigger on SME_Account_Plan__c (before insert, after insert,before update, after update,before delete, after delete) {
     SME_Disable_Flows_Process_Triggers__c triggerRunSettings = SME_Disable_Flows_Process_Triggers__c.getInstance(userInfo.getUserId());
    if(!triggerRunSettings.SME_Skip_All_objects__c && !triggerRunSettings.SME_Skip_Account_Plan__c){
        new SME_AccountPlanTriggerHandlerCtrl().run();
    }
      
}