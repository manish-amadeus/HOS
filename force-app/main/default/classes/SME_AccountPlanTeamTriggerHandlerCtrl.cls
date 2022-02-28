/**
* Company     : PwC Sales & Marketing Excellence Solution.
* Description : 
* 
* ****************************************************************************************
* History     : 
* [1.APR.2019] Nagendra Singh - Created this class.
*/
public without sharing class SME_AccountPlanTeamTriggerHandlerCtrl extends TriggerHandler_Helper{
    public SME_AccountPlanTeamServiceCtrl accountPlanTeamService;
    
    // Description: Handle before insert trigger operation
    public override void beforeInsert() {
        accountPlanTeamService = new SME_AccountPlanTeamServiceCtrl();
        accountPlanTeamService.restrictNonAccountPlanTeamUsers((List<SME_Account_Plan_Team__c>) Trigger.new);
    }
    // Description: Handle before update trigger operation
    public override void beforeUpdate() {
        accountPlanTeamService = new SME_AccountPlanTeamServiceCtrl();
        accountPlanTeamService.restrictNonAccountPlanTeamUsers((List<SME_Account_Plan_Team__c>) Trigger.new);
    }
    // Description: Handle before delete trigger operation
    public override void beforeDelete() {
        accountPlanTeamService = new SME_AccountPlanTeamServiceCtrl();
        accountPlanTeamService.doNotDeleteAPTWithOwnerRole((List<SME_Account_Plan_Team__c>) Trigger.old);
        accountPlanTeamService.restrictNonAccountPlanTeamUsers((List<SME_Account_Plan_Team__c>) Trigger.old);
    }
    // Description: Handle after insert trigger operation
    public override void afterInsert() {
        accountPlanTeamService = new SME_AccountPlanTeamServiceCtrl();
        accountPlanTeamService.insertSharingRecord((List<SME_Account_Plan_Team__c>) Trigger.new);
        accountPlanTeamService.checkTeamMemberDuplication((List<SME_Account_Plan_Team__c>) Trigger.new, (Map<Id, SME_Account_Plan_Team__c>) Trigger.newMap);
    }
    // Description: Handle after update trigger operation
    public override void afterUpdate() {
        accountPlanTeamService = new SME_AccountPlanTeamServiceCtrl();
        accountPlanTeamService.checkTeamMemberDuplication((List<SME_Account_Plan_Team__c>) Trigger.new, (Map<Id, SME_Account_Plan_Team__c>) Trigger.newMap);   
    }
    // Description: Handle after delete trigger operation
    public override void afterDelete() {
        accountPlanTeamService = new SME_AccountPlanTeamServiceCtrl();
        accountPlanTeamService.deleteSharingRecord((List<SME_Account_Plan_Team__c>) Trigger.old);
    } 
}