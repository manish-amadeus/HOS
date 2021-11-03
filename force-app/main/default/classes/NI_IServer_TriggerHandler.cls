/************************************************************************************************
Name            : NI_IServer_TriggerHandler Class
Author          : Suzanne LeDuc
Created Date    : 09/10/2015
Last Mod Date   : 09/10/2015
Last Mod By     : Sean Harris
NICC Reference  : NICC-014223
Description     : Class that handles all trigger code for the newmarketsvcs__IServer__c Object
                :
                :
*************************************************************************************************/
public class NI_IServer_TriggerHandler 
{
    
    public NI_IServer_TriggerHandler()
    {

    }

    //public void OnBeforeInsert(List<newmarketsvcs__IServer__c> newTrigger)
    //{
    
    //}
    
    //public void OnBeforeUpdate(List<newmarketsvcs__IServer__c> newTrigger)
    //{
    
    //}
    
    //public void OnBeforeDelete(List<newmarketsvcs__IServer__c> newTrigger)
    //{
    
    //}    
    
    public void OnAfterInsert(List<newmarketsvcs__IServer__c> newTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('NWS IServer'))
        { 
            SystemToNIOrgDetails(newTrigger);
        }
    }
    
    public void OnAfterUpdate(List<newmarketsvcs__IServer__c> newTrigger)
    {           
        if (!NI_FUNCTIONS.bypassTriggerCode('NWS IServer'))
        { 
            SystemToNIOrgDetails(newTrigger);
        }    
    } 
    
    //public void OnAfterDelete(List<newmarketsvcs__IServer__c> newTrigger)
    //{
    
    //}
    
    //public void OnAfterUnDelete(List<newmarketsvcs__IServer__c> newTrigger)
    //{
    
    //}     
    
    public void SystemToNIOrgDetails(List<newmarketsvcs__IServer__c> newTrigger)
    {
        
        Set<String> setOrgIds = new Set<String>();
        for(newmarketsvcs__IServer__c nwsSystem : newTrigger )
        {
            //if (nwsSystem.newmarketsvcs__NewmarketUser__c.ContainsIgnoreCase('Delphi.fdc') )
            if ((nwsSystem.newmarketsvcs__NewmarketUser__c != null) && (nwsSystem.newmarketsvcs__NewmarketUser__c.ContainsIgnoreCase('Delphi.fdc')))
            {
               System.Debug('Delphi.fdc user' );
               //Org Id
               String OrgId = '';
               //Get the Org Id
               OrgId = nwsSystem.newmarketsvcs__NewmarketUser__c.Mid(4,15);
               System.Debug( 'Org Id ' + OrgId );
        
               setOrgIds.add(OrgId);
             }
        }
        
        List<NI_Org_Details__c> orgDetails = [ SELECT Id, Org_ID__c from NI_Org_Details__C where ORg_Id__c IN :setOrgIds];
        List<NI_Org_Details__C> orgDetailsToUpsert = new List<NI_Org_Details__c>();
        
        for (newmarketsvcs__IServer__c nwsSystem : newTrigger) 
        {
        
            System.Debug('User ' +nwsSystem.newmarketsvcs__NewmarketUser__c);
            // if (nwsSystem.newmarketsvcs__NewmarketUser__c.ContainsIgnoreCase('Delphi.fdc') )
            if ((nwsSystem.newmarketsvcs__NewmarketUser__c != null) && (nwsSystem.newmarketsvcs__NewmarketUser__c.ContainsIgnoreCase('Delphi.fdc')))
            {
               System.Debug('Delphi.fdc user' );
               //Org Id
               String OrgId = '';
               OrgId = nwsSystem.newmarketsvcs__NewmarketUser__c.Mid(4,15);
               System.Debug( 'Org Id ' + OrgId );
             
               //Get Org Details Record
               if( OrgId != '' )
               {
                   
                   for( NI_Org_Details__c orgDetail :orgDetails )
                   {
                      if( orgDetail.Org_Id__c == OrgId )
                      {
                           orgDetail.System__c = nwsSystem.Id;
                           orgDetailsToUpsert.Add(orgDetail); 
                      }
                   }
               }
               
            }
        }
        
        Database.upsert( orgDetailsToUpsert);
           
    }
    
}