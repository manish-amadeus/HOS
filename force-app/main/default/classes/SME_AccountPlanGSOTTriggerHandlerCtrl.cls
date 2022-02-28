/**
 * Company     : PwC Sales & Marketing Excellence Solution.
 * Description : 
 * 
 * ****************************************************************************************
 * History     : 
 * [10.MAY.2019] Nagendra Singh - Created this class.
 */
public class SME_AccountPlanGSOTTriggerHandlerCtrl extends TriggerHandler_Helper{
       public SME_AccountPlanGSOTServiceCtrl accountPlanGSOTService;
    // Description: Handle before  insert trigger operation
    public override void beforeInsert() {
        accountPlanGSOTService = new SME_AccountPlanGSOTServiceCtrl();
        SME_AccountPlanGSOTServiceCtrl.checkDuplicateGSO((List<SME_Account_Plan_GSOT__c>) Trigger.new,(Map<Id,SME_Account_Plan_GSOT__c>) Trigger.oldMap);
    }
    // Description: Handle after insert trigger operation
    public override void afterInsert() {
        accountPlanGSOTService = new SME_AccountPlanGSOTServiceCtrl();
        accountPlanGSOTService.rollUpSummary((List<SME_Account_Plan_GSOT__c>) Trigger.new);
        SME_AccountPlanGSOTServiceCtrl.updateStatus((List<SME_Account_Plan_GSOT__c>) Trigger.new);
    }
      // Description: Handle before  update trigger operation
    public override void beforeUpdate() {
        accountPlanGSOTService = new SME_AccountPlanGSOTServiceCtrl();
        SME_AccountPlanGSOTServiceCtrl.checkDuplicateGSO((List<SME_Account_Plan_GSOT__c>) Trigger.new,(Map<Id,SME_Account_Plan_GSOT__c>) Trigger.oldMap);
    }
    // Description: Handle after insert trigger operation
    public override void afterUpdate() {
       accountPlanGSOTService = new SME_AccountPlanGSOTServiceCtrl();
        accountPlanGSOTService.rollUpSummary((List<SME_Account_Plan_GSOT__c>) Trigger.new);
        SME_AccountPlanGSOTServiceCtrl.updateStatus((List<SME_Account_Plan_GSOT__c>) Trigger.new); 
    }
    // Description: Handle after delete trigger operation
    public override void afterDelete() {
       accountPlanGSOTService = new SME_AccountPlanGSOTServiceCtrl();
        accountPlanGSOTService.rollUpSummary((List<SME_Account_Plan_GSOT__c>) Trigger.Old);
        
    }
    
}