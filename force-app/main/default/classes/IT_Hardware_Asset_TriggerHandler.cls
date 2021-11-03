/************************************************************************************************
Name            : IT_Hardware_Asset_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 3/27/2015
Last Mod Date   : 3/27/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Class that handles all trigger code for the IT_Hardware_Asset__c Object
                :
*************************************************************************************************/
public class IT_Hardware_Asset_TriggerHandler {    
    
    public IT_Hardware_Asset_TriggerHandler()
    {
        
    }
    
     //===================================================================================================================    
    public void OnAfterInsert(List<IT_Hardware_Asset__c> newTrigger)
    {
        
        //CALL THE MANAGER APEX SHARING METHOD  
        Change_Custodian_Share(newTrigger);
    }
    
    //===================================================================================================================    
    public void OnAfterUpdate(List<IT_Hardware_Asset__c> newTrigger, Map<Id,IT_Hardware_Asset__c> oldMapTrigger)
    {  
        //CREATE  LIST TO HOLD ALL RECORDS WHERE THE NEW CUSTODIAN DOESN'T MATCH THE OLD CUSTODIAN
        List<IT_Hardware_Asset__c> lstCustodianShare = new List<IT_Hardware_Asset__c>();
        
        for (IT_Hardware_Asset__c hw : newTrigger) 
        {
            IT_Hardware_Asset__c oldHW = oldMapTrigger.get(hw.Id);
            
            if (hw.User__c != oldHW.User__c)
            {
                lstCustodianShare.add(hw);
            }
        }      
        
        //CALL THE MANAGER APEX SHARING METHOD
        if (lstCustodianShare.size() > 0)
        {  
            Change_Custodian_Share(lstCustodianShare);
        }      
        
    }        
    
    // ================================================================================================
    //  APEX SHARING METHODS
    // ================================================================================================

    //CUSTODIAN SHARE
    public void Change_Custodian_Share(List<IT_Hardware_Asset__c> newTrigger)
    {          
        
        //LIST OF SHARES THAT NEED TO BE REMOVED
        List<IT_Hardware_Asset__Share> lstSharesToRemove = new List<IT_Hardware_Asset__Share>([
            SELECT id 
            FROM IT_Hardware_Asset__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Custodian_Share__c']); 
        
        // BULK REMOVE SHARE RECORDS
        if (lstSharesToRemove.size() > 0)
        {
            Database.DeleteResult[] drList = Database.delete(lstSharesToRemove, false);
            for (Database.DeleteResult dr : drList) 
            {
                if (dr.isSuccess()) 
                {
                    System.debug('**SUCCESSFULLY DELETED SHARE RECORD ID: ' + dr.getId());
                }
                else 
                {
                    Database.Error err = dr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }        
        }
        
        //LIST OF SHARES THAT NEED TO BE ADDED   
        List<IT_Hardware_Asset__Share> lstSharesToInsert = new List<IT_Hardware_Asset__Share>();
        
        for (IT_Hardware_Asset__c hw : newTrigger)
        {
            if ((hw.User__c != hw.OwnerId) && (hw.User__c != null))
            {
                IT_Hardware_Asset__Share hwShare = new IT_Hardware_Asset__Share();
                hwShare.ParentId = hw.Id;
                hwShare.UserOrGroupId = hw.User__c;
                hwShare.AccessLevel = 'Read';
                hwShare.RowCause = Schema.IT_Hardware_Asset__Share.RowCause.Custodian_Share__c;
                lstSharesToInsert.add(hwShare);
            } 
            
        }
        
        //USE DATABASE DML METHOD TO ADD THE SHARES
        if(lstSharesToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstSharesToInsert,true);
            for(Database.SaveResult sr: results)
            {
                if(!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }
        } 
        
    }


}