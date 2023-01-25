trigger OrgSecurityLogTrigger on OrgSecurityLog__c (before delete, before update, before insert) {
        OrgSecurityLogCls handler = new OrgSecurityLogCls();
        handler.handle();
}