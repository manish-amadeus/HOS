/**
 * Company     : PwC Sales & Marketing Excellence Solution.
 * Description : 
 * 
 * ****************************************************************************************
 * History     : 
 * [10.MAY.2019] Nagendra Singh - Created this class.
 */
trigger Account_Plan_GSO_Trigger on SME_Account_Plan_GSOT__c (after insert,after update,before insert,before update,after delete) {
   SME_Disable_Flows_Process_Triggers__c triggerRunSettings = SME_Disable_Flows_Process_Triggers__c.getInstance(userInfo.getUserId());
    if(!triggerRunSettings.SME_Skip_All_objects__c && !triggerRunSettings.SME_Skip_Account_Plan_GSO__c){
         new SME_AccountPlanGSOTTriggerHandlerCtrl().run();
    }
   
}