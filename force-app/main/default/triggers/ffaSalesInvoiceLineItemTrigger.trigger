/*******************************************************************************************
Name            : ffaSalesInvoiceLineItemTrigger
Author          : CLD Partners
Created Date    : Apr 1, 2016
Description     : Trigger on SIN Line
*******************************************************************************************/

trigger ffaSalesInvoiceLineItemTrigger on c2g__codaInvoiceLineItem__c (before delete, before insert) {
    
    // Check to see if trigger is enabled before continuing
    NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
    if(ffaTriggers.Bypass_ffaSaleInvoiceLineItemTrigger__c == true)
    {
        System.Debug('************ ffaSaleInvoiceLineItemTrigger trigger is disabled');
        return;
    }

    if(trigger.isDelete){
    
      Set<Id> billingLineIds = new Set<Id>();
      for(c2g__codaInvoiceLineItem__c line : Trigger.old)
      {
        billingLineIds.add(line.Billing_Contract_Line_Item__c);
      }

      List<Billing_Contract_Line_Item__c> bcLineList = [
      SELECT Id, Invoiced__c FROM Billing_Contract_Line_Item__c WHERE Id in : billingLineIds];
      for(Billing_Contract_Line_Item__c bl : bcLineList){
        bl.Invoiced__c = false;
      }
      update bcLineList;
    }

    if(Trigger.isInsert){
        Set<Id> productIds = new Set<Id>();
        for(c2g__codaInvoiceLineItem__c line : Trigger.new){
            productIds.add(line.c2g__Product__c);
        }
        Map<Id, Product2> productMap = new Map<Id, Product2>([
            SELECT Id,
                Dimension_2__c,
                Dimension_3__c
            FROM Product2
            WHERE id in :productIds]);
        for(c2g__codaInvoiceLineItem__c line : Trigger.new){
            line.c2g__Dimension2__c = productMap.containsKey(line.c2g__Product__c) && productMap.get(line.c2g__Product__c).Dimension_2__c != null ? productMap.get(line.c2g__Product__c).Dimension_2__c : line.c2g__Dimension2__c;
            line.c2g__Dimension3__c = productMap.containsKey(line.c2g__Product__c) && productMap.get(line.c2g__Product__c).Dimension_3__c != null ? productMap.get(line.c2g__Product__c).Dimension_3__c : line.c2g__Dimension3__c;
        }
    }
      

}