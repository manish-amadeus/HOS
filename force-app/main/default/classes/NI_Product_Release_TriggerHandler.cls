/************************************************************************************************
Name            : NI_Product_Release_TriggerHandler Class
Author          : Sean Harris
Created Date    : 01/22/2016
Last Mod Date   : 01/22/2016
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_Product_Release__c Object
:
:
*************************************************************************************************/
public class NI_Product_Release_TriggerHandler
{
    
    public NI_Product_Release_TriggerHandler()
    {
    }
    
//	public void OnBeforeInsert(List<NI_Product_Release__c> newTrigger)
//    {
        
//    }
    
//    public void OnBeforeUpdate(List<NI_Product_Release__c> newTrigger)
//    {

//    }
    
//    public void OnBeforeDelete(List<NI_Product_Release__c> newTrigger)
//    {
        
//    }
    
    public void OnAfterInsert(List<NI_Product_Release__c> newTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('PRODUCT RELEASE'))
        {                     
        	syncVersion(newTrigger);
        }
    }
    
    public void OnAfterUpdate(List<NI_Product_Release__c> newTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('PRODUCT RELEASE'))
        {                     
			syncVersion(newTrigger);
        }
    }
    
//    public void OnAfterDelete(List<NI_Product_Release__c> newTrigger)
//    {
        
//    }
    
//    public void OnAfterUnDelete(List<NI_Product_Release__c> newTrigger)
//    {
        
//    }   
    
    private void syncVersion(List<NI_Product_Release__c> nTrig)
    {
        
        List<SFDC_CSP_Version__c> lstVersions = new List<SFDC_CSP_Version__c>();
        
        // CREATE LIST OF VERSIONS FOR ALL PRODUCT RELEASES WITH STATUS OF "Released" 
        for (NI_Product_Release__c pr : nTrig) 
        { 
            if (pr.Status__c == 'Released') 
            { 
                if (pr.Product_Group__c != null) 
                { 
                    SFDC_CSP_Version__c v = new SFDC_CSP_Version__c(); 
                    v.Product_Group__c = pr.Product_Group__c; 
                    v.Inactive__c = false; 
                    v.Name = pr.Name; 
                    v.Product_Release__c = pr.Id; 
                    lstVersions.add(v); 
                } 
            } 
        } 
        
        for (SFDC_CSP_Version__c lstVers : [SELECT Id, Name, Product_Release__c FROM SFDC_CSP_Version__c])
        {
            for (SFDC_CSP_Version__c vs : lstVersions)
            {
                if (lstVers.Product_Release__c == vs.Product_Release__c) 
                {
                    vs.Id = lstVers.Id;
                }
            }
        }
        
        Database.upsert(lstVersions);
                        
    }
    
    
}