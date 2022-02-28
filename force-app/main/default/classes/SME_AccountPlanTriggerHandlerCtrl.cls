/**
 * Company     : PwC Sales & Marketing Excellence Solution.
 * Description : 
 * 
 * ****************************************************************************************
 * History     : 
 * [17.APR.2019] Nagendra Singh - Created this class.
 */
public without sharing class SME_AccountPlanTriggerHandlerCtrl extends TriggerHandler_Helper {
      public SME_AccountPlanServiceCtrl accountPlanService;
    
    // Description: Handle before update trigger operation
    public override void beforeUpdate() {
        accountPlanService = new SME_AccountPlanServiceCtrl();
        if(Test.isRunningTest()) {
            accountPlanService.validateAPOwnerChange((List<SME_Account_Plan__c>) Trigger.new,(Map<id,SME_Account_Plan__c>) Trigger.oldMap);
        }
        accountPlanService.assignPageReadOnly((List<SME_Account_Plan__c>) Trigger.new,(Map<id,SME_Account_Plan__c>) Trigger.oldMap);
        accountPlanService.assignPlanApprovedRecord((List<SME_Account_Plan__c>) Trigger.new,(Map<id,SME_Account_Plan__c>) Trigger.oldMap);
    }  
}