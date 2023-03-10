/************************************************************************************************
Name            : AH_CxlCaseRuleProduct_TriggerHandler Class
Author          : Sean Harris
Created Date    : 05/09/2018
Last Mod Date   : 05/09/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all trigger code for the Cancellation_Case_Rule_Product__c Object
                : 
                : 
*************************************************************************************************/
public class AH_CxlCaseRuleProduct_TriggerHandler 
{
    
    public AH_CxlCaseRuleProduct_TriggerHandler()
    {
    }    
    
    // ========================================================================================================================
    //  ENTRY METHODS =========================================================================================================
    // ========================================================================================================================    
    public void OnBeforeInsert(List<Cancellation_Case_Rule_Product__c> newTrigger)
    {
        doValidate(newTrigger, 'insert');
    }
    
    public void OnBeforeUpdate(List<Cancellation_Case_Rule_Product__c> newTrigger)
    {
        doValidate(newTrigger, 'update');
    }    
    
    // ========================================================================================================================
    //  HANDLER FUNCTIONS =====================================================================================================
    // ========================================================================================================================  
    private void doValidate(List<Cancellation_Case_Rule_Product__c> newTrigger, string strDMLType)
    {
        Map<Id, Cancellation_Case_Rule_Product__c> mapR2P = new Map<Id, Cancellation_Case_Rule_Product__c>();
        findDuplicateProducts(newTrigger, mapR2P);
        
        // IF ANY DUPES WERE FOUND AND ADDED TO MAP
        if (!mapR2P.isEmpty())
        {
            // LOOP THROUGH ALL RECORDS IN THE TRIGGER
            for (Cancellation_Case_Rule_Product__c nt : newTrigger)
            {
                // LOOP THROUGH ALL THE RECORDS IN DUPE MAP
                for (Id k : mapR2P.keySet()) 
                {
                    // IF THIS IS AN UPDATE AND THEN ALLOW IF A DUPE IS FOUND BUT RULE IS THE SAME 
                    // OR IF THIS IS AN INSERT AND A DUPE IS FOUND
                    if (mapR2P.get(k).Product__c == nt.Product__c && 
                        ((strDMLType == 'update' && mapR2P.get(k).Id != nt.Id) || 
                        strDMLType == 'insert')
                       )
                    {
                        string strErr = 'This product is already associated with a Cancellation Case Rule \n';
                        strErr += '(Product) ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + String.valueOf(mapR2P.get(k).Product__c);
                        strErr += ' (Rule) ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + String.valueOf(k) + '\n';   
                        nt.Product__c.addError(strErr);
                    }
                }
            }       
        }         
    }
    
    private void findDuplicateProducts(List<Cancellation_Case_Rule_Product__c> newTrigger, Map<Id, Cancellation_Case_Rule_Product__c> mapRules2Prods)
    {
        
        // GET ALL THE CR PRODUCT IDS
        Set<Id> setProdIds = new Set<Id>();
        
        for (Cancellation_Case_Rule_Product__c ccr : newTrigger)
        {
            setProdIds.add(ccr.Product__c);
        }
        
        // FILL THE MAP PASSED IN WITH ALL Cancellation_Case_Rule__c TO Product__c IDS
        for (Cancellation_Case_Rule_Product__c p : [SELECT Id, Cancellation_Case_Rule__c, Product__c 
                                                    FROM Cancellation_Case_Rule_Product__c 
                                                    WHERE Product__c IN : setProdIds])
        {
            mapRules2Prods.put(p.Cancellation_Case_Rule__c, p);
        }
        
    }
    
}