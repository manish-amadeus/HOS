/************************************************************************************************
Name            : NI_Location_TriggerHandler Class
Author          : Suzanne LeDuc
Created Date    : 09/10/2015
Last Mod Date   : 07/05/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-014223
Description     : Class that handles all trigger code for the newmarketsvcs__Location__c Object
                : NICC-0##### Duplicate id in list: a4N0d000000DTzLEAW
                :
*************************************************************************************************/
public class NI_Location_TriggerHandler 
{
    
    private NI_TriggerBypassSwitches__c ffaTriggers {get; set;}
    
    public NI_Location_TriggerHandler()
    {
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();         
    }
    
    public void OnAfterInsert(List<newmarketsvcs__Location__c> newTrigger)
    {
        if (!ffaTriggers.BypassNWSLocation_ON__c)
        {
            AddMasterLocationsToOrgDetails(newTrigger);
        }
    }
    
    public void OnAfterUpdate(List<newmarketsvcs__Location__c> newTrigger)
    { 
        if (!ffaTriggers.BypassNWSLocation_ON__c)
        {        
            AddMasterLocationsToOrgDetails(newTrigger); 
        }
    } 
    
    public void AddMasterLocationsToOrgDetails(List<newmarketsvcs__Location__c> newTrigger)
    {
        		
        system.debug(' *** ENTERING NI_Location_TriggerHandler.AddMasterLocationsToOrgDetails() - QUERIES ISSUED = ' + Limits.getQueries());

system.debug(' *^* newTrigger.size() = ' + newTrigger.size()); 
system.debug(' *^* newTrigger[0].newmarketsvcs__Source_System_Type__c = ' + newTrigger[0].newmarketsvcs__Source_System_Type__c); 
system.debug(' *^* newTrigger[0].newmarketsvcs__IServerID__c = ' + newTrigger[0].newmarketsvcs__IServerID__c); 
system.debug(' *^* newTrigger[0].newmarketsvcs__Master_Location__c = ' + newTrigger[0].newmarketsvcs__Master_Location__c); 
        
        List<newmarketsvcs__Location__c> lstDelphiFDCLocs = new List<newmarketsvcs__Location__c>();
        List<NI_Org_Details_to_Accounts__c> lstOrgAccountsToInsert = new List<NI_Org_Details_to_Accounts__c>();
        List<NI_Org_Details_to_Accounts__c> lstOrgAccountsToRemove = new List<NI_Org_Details_to_Accounts__c>();
        //List<NI_Org_Details_to_Accounts__c> lstOrgAccountsToUpdate = new List<NI_Org_Details_to_Accounts__c>();
        Map<Id, NI_Org_Details_to_Accounts__c> mapOrgAccountsToUpdate = new Map<Id, NI_Org_Details_to_Accounts__c>();
        
        // FILL SETS WITH ALL RELATED NWS ISERVER & MASTER LOCATION IDS 
        Set<Id> setNWS_IServerIDs = new Set<Id>();
        Set<Id> setNWS_Master_LocationIds = new Set<Id>();
        for (newmarketsvcs__Location__c nwsLocation : newTrigger)
        {
            if (nwsLocation.newmarketsvcs__Source_System_Type__c == 'Delphifdc')
            {
                lstDelphiFDCLocs.add(nwsLocation);
                
                setNWS_IServerIDs.add(nwsLocation.newmarketsvcs__IServerID__c);
                
                if (nwsLocation.newmarketsvcs__Master_Location__c != null)   
                {
                    setNWS_Master_LocationIds.add(nwsLocation.newmarketsvcs__Master_Location__c);
                }
            }
        }
        
        // FILL LIST OF RELATED (SYSTEM) ISERVER RECORDS
        List<newmarketsvcs__IServer__c> lstAllRelated_IServers = new List<newmarketsvcs__IServer__c>(
            [SELECT Id, newmarketsvcs__NewmarketUser__c 
             FROM newmarketsvcs__IServer__c 
             WHERE Id IN : setNWS_IServerIDs  
             AND newmarketsvcs__NewmarketUser__c != null]);

system.debug(' *^* lstAllRelated_IServers = ' + lstAllRelated_IServers); 

        // FILL A SET OF ORG IDS PARSED OUT FROM ISERVER NEWMARKET USER NAMES
        Set<String> setOrgIds = new Set<String>();
        
        for (newmarketsvcs__IServer__c nwsIServer : lstAllRelated_IServers)   
        {
            if (nwsIServer.newmarketsvcs__NewmarketUser__c.ContainsIgnoreCase('Delphi.fdc')) 
            {
                String OrgId = nwsIServer.newmarketsvcs__NewmarketUser__c.Mid(4, 15);
                
                if (OrgId.length() == 15)
                {
                    setOrgIds.add(OrgId);
                }
            }
        }

        // FILL LIST OF ORG DETAILS HAVING ORG IDS OF PREVIOUSLY PARSED
        List<NI_Org_Details__c> lstOrgDetails = [SELECT Id, Org_ID__c FROM NI_Org_Details__c WHERE Org_Id__c IN : setOrgIds];

system.debug(' *^* lstOrgDetails = ' + lstOrgDetails); 
        
        Set<Id> setOrgDetIds = new Set<Id>();
        
        for (NI_Org_Details__c orgDets : lstOrgDetails)
        {
            setOrgDetIds.add(orgDets.Id);
        }
        
        // FILL LIST OF "ORG DETAUI TO ACCOUNT" JUNCTION OBJECT RECORDS 
        List<NI_Org_Details_to_Accounts__c> lstOrgDetail2Account = new List<NI_Org_Details_to_Accounts__c>(
            [SELECT Id, AccountID__c, NIOrgDetailsID__c, Status__c
             FROM NI_Org_Details_to_Accounts__c 
             WHERE NIOrgDetailsID__c IN : setOrgDetIds]); 	// AND AccountID__c IN : setNWS_Master_LocationIds

system.debug(' *^* lstOrgDetail2Account = ' + lstOrgDetail2Account); 
       
        // LOOP THROUGH TRIGGER AGAIN TO LOCATE MISSING JUNCTION RECORDS FOR INSERTION 
        for (newmarketsvcs__Location__c nwsLocation : lstDelphiFDCLocs)
        {   
            // LOOP THROUGH ALL RELATED NWS I-SERVERS 
            for (newmarketsvcs__IServer__c nwsISvr : lstAllRelated_IServers)
            {   
                // FIND THE MATCHING I_SERVER RECORD IN ITERATION 
                if (nwsISvr.Id == nwsLocation.newmarketsvcs__IServerID__c)
                {
                    // IF THE I-SERVER USER CONTAINS 'Delphi.fdc' 
                    if (nwsISvr.newmarketsvcs__NewmarketUser__c.ContainsIgnoreCase('Delphi.fdc'))
                    {
                        String OrgId = ''; 
                        // NULL CHECK USER VALUE THEN PARSE ORG ID OUR OF USER NAME 
                        if (nwsISvr.newmarketsvcs__NewmarketUser__c != null)
                        {
                            OrgId = nwsISvr.newmarketsvcs__NewmarketUser__c.Mid(4, 15); 
                        } 
                        
                        // IF PARSED ID WAS SUCCESSFUL 
                        if ((OrgId != '') && (OrgId.length() == 15)) 
                        {   
                            // FIND THE MATCHING ORG DETAIL RECORD BY PARSED ID                         
                            for (NI_Org_Details__c orgDetail : lstOrgDetails)
                            {   
                                // IF MATCHING ORG DETAIL RECORD FOUND
                                if (orgDetail.Org_Id__c == OrgId)
                                {   
                                    
                                    boolean bFoundLink = false;
                                    
                                    // LOOP THROUGH ALL RELATED JUNCTION RECORDS TO FIND A MATCH
                                    for (NI_Org_Details_to_Accounts__c j : lstOrgDetail2Account)
                                    {   
                                        
                                        // IF FOUND SET FLAG TO TRUE
                                        if ((j.NIOrgDetailsID__c == orgDetail.Id) && (j.AccountID__c == nwsLocation.newmarketsvcs__Master_Location__c))
                                        {
                                            
                                            bFoundLink = true;
                                            
                                            // if the location is inactive and the association is not Inactive - make it inactive
                                            if (nwsLocation.newmarketsvcs__Status__c == false && j.Status__c != 'Inactive')
                                            {
                                                j.Status__c = 'Inactive';
                                                //lstOrgAccountsToUpdate.add(j);
                                                mapOrgAccountsToUpdate.put(j.Id, j);
                                            }
                                            
                                            // If the location is active and the association is not Active - make it active
                                            if (nwsLocation.newmarketsvcs__Status__c == true && j.Status__c != 'Active')
                                            {
                                                j.Status__c = 'Active';
                                                //lstOrgAccountsToUpdate.add(j);
                                                mapOrgAccountsToUpdate.put(j.Id, j);
                                            }
                                            
                                        }
                                        
                                        // If we are removing the master account we need to remove the association to org details
                                        if (Trigger.oldMap != null)
                                        {
                                            
                                            newmarketsvcs__Location__c oldRecord = (newmarketsvcs__Location__c)Trigger.oldMap.get(nwsLocation.Id);
                                            
                                            if ((j.NIOrgDetailsID__c == orgDetail.Id) && (j.AccountID__c == oldRecord.newmarketsvcs__Master_Location__c))
                                            {
                                                if (oldRecord.newmarketsvcs__Master_Location__c != null && 
                                                    (oldRecord.newmarketsvcs__Master_Location__c != nwsLocation.newmarketsvcs__Master_Location__c))
                                                {
                                                    lstOrgAccountsToRemove.add(j);  
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    // IF MATCH NOT FOUND, CREATE RELATED JUNCTION RECORD
                                    if (!bFoundLink && nwsLocation.newmarketsvcs__Master_Location__c != null)
                                    {
                                        
                                        NI_Org_Details_to_Accounts__c orgAccount = new NI_Org_Details_to_Accounts__c();
                                        orgAccount.AccountID__c = nwsLocation.newmarketsvcs__Master_Location__c;
                                        orgAccount.NIOrgDetailsID__c = orgDetail.Id;
                                        
                                        if (nwsLocation.newmarketsvcs__Status__c == false)
                                        {
                                            orgAccount.Status__c = 'Inactive';
                                        }                                            
                                        else
                                        {
                                            orgAccount.Status__c = 'Active';
                                        }
                                        
                                        lstOrgAccountsToInsert.add(orgAccount); 
                                        
                                    }  
                                }
                            }
                        }                        
                    }                      
                }                
            }            
        }
        
        if (!lstOrgAccountsToInsert.isEmpty())
        {
            insert lstOrgAccountsToInsert;              
        }
        
        if (!lstOrgAccountsToRemove.isEmpty())
        {
            // Remove the link to org details if the master account is removed from the location
            delete lstOrgAccountsToRemove;              
        }
        
        if (!mapOrgAccountsToUpdate.isEmpty())
        {
            //update lstOrgAccountsToUpdate; 
            database.update(mapOrgAccountsToUpdate.Values());             
        }
        		
        system.debug(' *** EXITING NI_Location_TriggerHandler.AddMasterLocationsToOrgDetails() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
}