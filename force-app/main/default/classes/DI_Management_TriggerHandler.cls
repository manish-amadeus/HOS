public class DI_Management_TriggerHandler {
	
    public void OnBeforeInsert(List<DI_Management__c> newTrigger)
    {
    	set<string> prodDIIndex = new set<string>();
        for(DI_Management__c dim: newTrigger){
            dim.Unique_Record__c = dim.Core_DI_Index__c+''+dim.Peripheral_DI_Product__c+dim.Relationship__c;
            
            dim.UniqueCoreDiDiIndex__c = dim.Core_DI_Index__c+''+dim.Product_DI_Index__c;
        }
    }
    public void OnBeforeUpdate(List<DI_Management__c> newTrigger,Map<Id, DI_Management__c> oldMapTrigger)
    {
        for(DI_Management__c dim: newTrigger){
            dim.Unique_Record__c = dim.Core_DI_Index__c+''+dim.Peripheral_DI_Product__c+dim.Relationship__c;
            dim.UniqueCoreDiDiIndex__c = dim.Core_DI_Index__c+''+dim.Product_DI_Index__c;
        }
    }
}