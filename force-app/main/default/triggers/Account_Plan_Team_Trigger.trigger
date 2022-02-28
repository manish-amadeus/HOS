/**
 * Company     : PwC Sales & Marketing Excellence Solution.
 * Description : 
 * 
 * ****************************************************************************************
 * History     : 
 * [17.APR.2019] Shreyas - Created this class.
 */
trigger Account_Plan_Team_Trigger on SME_Account_Plan_Team__c (before insert,before delete, before update,after insert, after update, after delete) {
    SME_Disable_Flows_Process_Triggers__c triggerRunSettings = SME_Disable_Flows_Process_Triggers__c.getInstance(userInfo.getUserId());
    if(!triggerRunSettings.SME_Skip_All_objects__c && !triggerRunSettings.SME_Skip_Account_Plan_Team__c){
        new SME_AccountPlanTeamTriggerHandlerCtrl().run();
    }
    
}