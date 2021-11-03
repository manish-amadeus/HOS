/************************************************************************************************
Name            : AH_Trust_to_Incident_TriggerHandler Class
Author          : Shashikant Nikam
Created Date    : 01/17/2020
Last Mod Date   : 03/12/2020
Last Mod By     : Shashikant Nikam
NICC Reference  :
Description     : Trigger handler class of AH_Trust_to_Incident__c Object 
                : This class to populate the External & Internal Platform Names on Incident records 
                :
************************************************************************************************/

public class AH_Trust_to_Incident_TriggerHandler {

    
    // AFTER INSERT
    public void OnAfterInsert(List<AH_Trust_to_Incident__c> newTrigger)
    {
        
        Set<String> IdSet = new Set<String>();
        Set<String> incidentIdSet = new Set<String>();
        for(AH_Trust_to_Incident__c t: newTrigger)
        {
            IdSet.add(t.AH_Trust__c);
            incidentIdSet.add(t.AH_Trust_Incident__c);
        }
        
        updatePlatformNamesAfterInsert(newTrigger, IdSet, incidentIdSet);
        
    }
    
    
    // BEFORE DELETE 
    public void OnBeforeDelete(List<AH_Trust_to_Incident__c> oldTrigger){
        
		updatePlatformNamesBeforeDelete(oldTrigger);
    }
    
    
    // BEFORE UPDATE
    public void OnBeforeUpdate(List<AH_Trust_to_Incident__c> newTrigger, Map<Id, AH_Trust_to_Incident__c> oldMapTrigger){
        
		updatePlatformNamesBeforeUpdate(newTrigger, oldMapTrigger);
    }
    
    
    public void OnAfterUpdate (List<AH_Trust_to_Incident__c> newTrigger, Map<Id, AH_Trust_to_Incident__c> oldMap){
        
        updatePlatformNamesAfterUpdate(newTrigger, oldMap);
    }
    
    
    public void updatePlatformNamesAfterUpdate(List<AH_Trust_to_Incident__c> newTrigger, Map<Id, AH_Trust_to_Incident__c> oldMapTrigger)
    {
        Set<String> trustIdSet = new Set<String>();
        Set<String> incidentIdSet = new Set<String>();
        for(AH_Trust_to_Incident__c t: newTrigger)
        {
            trustIdSet.add(t.AH_Trust__c);
            incidentIdSet.add(t.AH_Trust_Incident__c);
        }

        List<NI_Trust__c> trustList = [SELECT ID, Name, Platform_Name_External__c, Platform_Name_Internal__c, 
                                            ( 
                                                SELECT ID, 
                                                Name,
                                                AH_Trust_Incident__c, 
                                                AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c,
                                                AH_Trust_Incident__r.Internal_Platform_Name_HIDDEN__c 
                                                FROM AH_Trusts_to_Incidents__r 
                                                WHERE AH_Trust_Incident__c IN: incidentIdSet
                                            ) 
                                       FROM NI_Trust__c
                                      WHERE ID IN: trustIdSet];
        
        Map<String, String> idMap = new Map<String, String>();
        Map<ID, NI_Trust_Outage__c> incidentsUpdateMap = new Map<ID, NI_Trust_Outage__c>();
        Set<String> incIdSet = new Set<String>();
        
        for(NI_Trust__c t: trustList)
        {
            system.debug('Trust : '+t);
            //system.debug('Trust OLD Platform_Name_External__c : '+oldMapTrigger.get(t.id).Platform_Name_External__c);
            
            for(AH_Trust_to_Incident__c juncObj : t.AH_Trusts_to_Incidents__r)
            {
                String externalPlatformName = juncObj.AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c;
                system.debug('External_Platform_Name_HIDDEN__c : '+externalPlatformName);
                
                idMap.put(t.id+'_'+juncObj.AH_Trust_Incident__c, juncObj.AH_Trust_Incident__c);
                
                NI_Trust_Outage__c incidentObj = new NI_Trust_Outage__c(id=juncObj.AH_Trust_Incident__c);
                
                incIdSet.add(juncObj.AH_Trust_Incident__c);
                
                // ============================================ POPULATE EXTRENAL PLATFORM NAME FIELD ON INCIDENT RECORD ============================================
                //if(externalPlatformName == NULL || !externalPlatformName.contains(t.id+ '_' +t.Platform_Name_External__c) )
                //{
                    
                    // POPULATE EXTERNAL PLATFORM NAME
                    if(externalPlatformName == '' || externalPlatformName == NULL)
                    {
                        incidentObj.External_Platform_Name_HIDDEN__c = t.id + '_' + t.Platform_Name_External__c;
                    }
                    else if (externalPlatformName != '' && externalPlatformName != NULL)
                    {
                        incidentObj.External_Platform_Name_HIDDEN__c = externalPlatformName + ',' + t.id + '_' + t.Platform_Name_External__c;
                    }
                    
                    // CODE TO POPULATE EXTERNAL PLATFORM NAMES BY REMOVING TRUST IDs
                    List<String> allNamesExternal = incidentObj.External_Platform_Name_HIDDEN__c.split(',');
                    List<String> updatedNamesExternal = new List<String>();
                    for(String name : allNamesExternal)
                    {
                        List<String> singleName = name.split('_');
                        updatedNamesExternal.add(singleName[1]);
                    }
                    system.debug('updatedNamesExternal : '+updatedNamesExternal);
                    incidentObj.External_Platform_Name_LIST__c = String.join(updatedNamesExternal, ', ');
                    system.debug('incidentObj.External_Platform_Name_LIST__c : '+incidentObj.External_Platform_Name_LIST__c);
                //}
                
                
                // ============================================ POPULATE INTRENAL PLATFORM NAME FIELD ON INCIDENT RECORD ============================================
                
                String internalPlatformName = juncObj.AH_Trust_Incident__r.Internal_Platform_Name_HIDDEN__c;
                system.debug('Internal_Platform_Name_HIDDEN__c : '+internalPlatformName);
               
                
                // POPULATE INTERNAL PLATFORM NAME
                if(internalPlatformName == '' || internalPlatformName == NULL)
                {
                    incidentObj.Internal_Platform_Name_HIDDEN__c = t.id + '_' + t.Platform_Name_Internal__c;
                }
                else if (internalPlatformName != '' && internalPlatformName != NULL)
                {
                    incidentObj.Internal_Platform_Name_HIDDEN__c = internalPlatformName + ',' + t.id + '_' + t.Platform_Name_Internal__c;
                }
                
                // CODE TO POPULATE INTERNAL PLATFORM NAMES BY REMOVING TRUST IDs
                List<String> allNamesInternal = incidentObj.Internal_Platform_Name_HIDDEN__c.split(',');
                List<String> updatedNamesInternal = new List<String>();
                for(String name : allNamesInternal)
                {
                    List<String> singleName = name.split('_');
                    updatedNamesInternal.add(singleName[1]);
                }
                system.debug('updatedNamesInternal : '+updatedNamesInternal);
                incidentObj.Internal_Platform_Name_LIST__c = String.join(updatedNamesInternal, ', ');
                system.debug('incidentObj.Internal_Platform_Name_LIST__c : '+incidentObj.Internal_Platform_Name_LIST__c);
                
                
                // ADD INCIDENT RECORDS IN MAP TO AVOID DUPLICATE VALUES
                incidentsUpdateMap.put(juncObj.AH_Trust_Incident__c, incidentObj);
            }
        }
        
        system.debug('incidentsUpdateMap size : '+incidentsUpdateMap.size());
        
        // FOR UPDATE QUERY WRITTEN TO AVOID LOCK ROW ERRORS
        List<NI_Trust_Outage__c> incList = new List<NI_Trust_Outage__c>([select ID FROM NI_Trust_Outage__c WHERE ID IN: incIdSet FOR UPDATE]);
        
        List<NI_Trust_Outage__c> updateIncList = new List<NI_Trust_Outage__c>();
        for(String incidentId : incidentsUpdateMap.keyset())
        {
            updateIncList.add(incidentsUpdateMap.get(incidentId));
        }
        system.debug('updateIncList size : '+updateIncList.size());
        
        // UPDATE AH TRUST INCIDENT RECORDS
        try
        {
            Database.update(updateIncList);
        }
        catch(Exception e)
        {
            system.debug('Found Exception : '+e);
        }
    }
    
    
    // =========================================================================================================================================================
    // TRIGGER METHODS 
    // =========================================================================================================================================================
    
    // METHOD TO POPULATE THE EXTERNAL & INTERNAL PLATFORM NAMES ON INCIDENT RECORDS
    public void updatePlatformNamesAfterInsert(List<AH_Trust_to_Incident__c> newTrigger, Set<String> trustIdSet, Set<String> incidentIdSet)
    {
        
        List<NI_Trust__c> trustList = [SELECT ID, Name, Platform_Name_External__c, Platform_Name_Internal__c, 
                                            ( 
                                                SELECT ID, 
                                                Name,
                                                AH_Trust_Incident__c, 
                                                AH_Trust_Incident__r.Name, 
                                                AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c,
                                                AH_Trust_Incident__r.Internal_Platform_Name_HIDDEN__c 
                                                FROM AH_Trusts_to_Incidents__r 
                                                WHERE AH_Trust_Incident__c IN: incidentIdSet
                                            ) 
                                       FROM NI_Trust__c
                                      WHERE ID IN: trustIdSet];
        
        Map<ID, NI_Trust_Outage__c> incidentsUpdateMap = new Map<ID, NI_Trust_Outage__c>();
        Set<String> incIdSet = new Set<String>();
        
        system.debug('trustList size : '+trustList.size());
        
        for(NI_Trust__c t: trustList)
        {
            system.debug('t name : '+t.Name);
            for(AH_Trust_to_Incident__c juncObj : t.AH_Trusts_to_Incidents__r)
            {
                system.debug('Incident name : '+juncObj.AH_Trust_Incident__r.Name);
                
                String externalPlatformName = juncObj.AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c;
                String internalPlatformName = juncObj.AH_Trust_Incident__r.Internal_Platform_Name_HIDDEN__c;
                
                system.debug('External_Platform_Name_HIDDEN__c : '+externalPlatformName);
                system.debug('Internal_Platform_Name_HIDDEN__c : '+internalPlatformName);
                system.debug('juncObj : '+juncObj);
                
                NI_Trust_Outage__c incidentObj = new NI_Trust_Outage__c(id=juncObj.AH_Trust_Incident__c);
                incIdSet.add(juncObj.AH_Trust_Incident__c);
                
                // POPULATE EXTERNAL PLATFORM NAME
                if(externalPlatformName == '' || externalPlatformName == NULL)
                {
                    incidentObj.External_Platform_Name_HIDDEN__c = t.id + '_' + t.Platform_Name_External__c;
                }
                else if (externalPlatformName != '' && externalPlatformName != NULL)
                {
                    incidentObj.External_Platform_Name_HIDDEN__c = externalPlatformName + ',' + t.id + '_' + t.Platform_Name_External__c;
                }
                
                
                // POPULATE INTERNAL PLATFORM NAME
                if(internalPlatformName == '' || internalPlatformName == NULL)
                {
                    incidentObj.Internal_Platform_Name_HIDDEN__c = t.id + '_' + t.Platform_Name_Internal__c;
                }
                else if (internalPlatformName != '' && internalPlatformName != NULL)
                {
                    incidentObj.Internal_Platform_Name_HIDDEN__c = internalPlatformName + ',' + t.id + '_' + t.Platform_Name_Internal__c;
                }
                

                // CODE TO POPULATE EXTERNAL PLATFORM NAMES BY REMOVING TRUST IDs
                List<String> allNamesExternal = incidentObj.External_Platform_Name_HIDDEN__c.split(',');
                system.debug('allNamesExternal : '+allNamesExternal);
                List<String> updatedNamesExternal = new List<String>();
                for(String name : allNamesExternal)
                {
                    List<String> singleName = name.split('_');
                    updatedNamesExternal.add(singleName[1]);
                }
                system.debug('updatedNamesExternal : '+updatedNamesExternal);
                incidentObj.External_Platform_Name_LIST__c = String.join(updatedNamesExternal, ', ');
                system.debug('incidentObj.External_Platform_Name_LIST__c : '+incidentObj.External_Platform_Name_LIST__c);
                
                
                // CODE TO POPULATE INTERNAL PLATFORM NAMES BY REMOVING TRUST IDs
                List<String> allNamesInternal = incidentObj.Internal_Platform_Name_HIDDEN__c.split(',');
                List<String> updatedNamesInternal = new List<String>();
                for(String name : allNamesInternal)
                {
                    List<String> singleName = name.split('_');
                    updatedNamesInternal.add(singleName[1]);
                }
                system.debug('updatedNamesInternal : '+updatedNamesInternal);
                incidentObj.Internal_Platform_Name_LIST__c = String.join(updatedNamesInternal, ', ');
                system.debug('incidentObj.Internal_Platform_Name_LIST__c : '+incidentObj.Internal_Platform_Name_LIST__c);
                
                incidentsUpdateMap.put(juncObj.AH_Trust_Incident__c, incidentObj);
            }
        }
        
        system.debug('incidentsUpdateMap : '+incidentsUpdateMap);
        
        List<NI_Trust_Outage__c> incList = new List<NI_Trust_Outage__c>([select ID FROM NI_Trust_Outage__c WHERE ID IN: incIdSet FOR UPDATE]);
        
        List<NI_Trust_Outage__c> updateIncList = new List<NI_Trust_Outage__c>();
        for(String incidentId : incidentsUpdateMap.keyset())
        {
            updateIncList.add(incidentsUpdateMap.get(incidentId));
        }

        system.debug('updateIncList size : '+updateIncList.size());
        if(!updateIncList.isEmpty())
        {
            try
            {
                Database.update(updateIncList);
            }
            catch(Exception e)
            {
                system.debug('Found Exception while updating Incident records : '+e);
            }
        }
    }
    
    
    public void updatePlatformNamesBeforeUpdate(List<AH_Trust_to_Incident__c> newTrigger, Map<Id, AH_Trust_to_Incident__c> oldMapTrigger)
    {

        Set<String> trustIdSet_old = new Set<String>();
        Set<String> incidentIdSet_old = new Set<String>();
        
        // CHECK WHAT CHNAGES ARE DONE ON JUNCTION OBJECT 
        for(AH_Trust_to_Incident__c t : newTrigger) 
        {
            if(t.AH_Trust__c != oldMapTrigger.get(t.id).AH_Trust__c || t.AH_Trust_Incident__c != oldMapTrigger.get(t.id).AH_Trust_Incident__c) {
                
                system.debug('AH_Trust__c / AH_Trust_Incident__c is updated');
                trustIdSet_old.add(oldMapTrigger.get(t.id).AH_Trust__c);
                incidentIdSet_old.add(oldMapTrigger.get(t.id).AH_Trust_Incident__c);
            }
        }
        
        if(!trustIdSet_old.isEmpty() || !incidentIdSet_old.isEmpty())
        {
            List<NI_Trust__c> trustList = [SELECT ID, Name, Platform_Name_External__c, Platform_Name_Internal__c, 
                                           ( 
                                               SELECT ID, 
                                               Name,
                                               AH_Trust_Incident__c, 
                                               AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c,
                                               AH_Trust_Incident__r.Internal_Platform_Name_HIDDEN__c 
                                               FROM AH_Trusts_to_Incidents__r 
                                               WHERE AH_Trust_Incident__c IN: incidentIdSet_old
                                           ) 
                                           FROM NI_Trust__c
                                           WHERE ID IN: trustIdSet_old];
            
            // THIS METHOD CALL WILL REMOVE THE PLATFORM NAEMS FROM INCIDENT RECORDS & RETURN THE LIST COLLECTION
            List<NI_Trust_Outage__c> updateIncList = removeTrustfrmIncidentRecord(trustList);
            system.debug('updateIncList : '+updateIncList );
                        
            // UPDATE AH TRUST INCIDENT RECORDS
            try
            {
                Database.update(updateIncList);
            }
            catch(Exception e)
            {
                system.debug('Found Exception : '+e);
            } 
        }
        
    }
    
    
    
	// METHOD TO REMOVE THE EXTERNAL & INTERNAL PLATFORM NAMES FROM INCIDENT RECORDS
    public void updatePlatformNamesBeforeDelete(List<AH_Trust_to_Incident__c> oldTrigger)
    {
        
        Set<String> trustIdSet = new Set<String>();
        Set<String> incidentIdSet = new Set<String>();
        
        for(AH_Trust_to_Incident__c t: oldTrigger)
        {
            trustIdSet.add(t.AH_Trust__c);
            incidentIdSet.add(t.AH_Trust_Incident__c);
        }
   
        List<NI_Trust__c> trustList = [SELECT ID, Name, Platform_Name_External__c, Platform_Name_Internal__c, 
                                            ( 
                                                SELECT ID, 
                                                Name,
                                                AH_Trust_Incident__c, 
                                                AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c,
                                                AH_Trust_Incident__r.Internal_Platform_Name_HIDDEN__c 
                                                FROM AH_Trusts_to_Incidents__r 
                                                WHERE AH_Trust_Incident__c IN: incidentIdSet
                                            ) 
                                       FROM NI_Trust__c
                                      WHERE ID IN: trustIdSet];
        
        
        List<NI_Trust_Outage__c> updateIncList = removeTrustfrmIncidentRecord(trustList);
        
        // UPDATE AH TRUST INCIDENT RECORDS
        try
        {
            Database.update(updateIncList);
        }
        catch(Exception e)
        {
            system.debug('Found Exception : '+e);
        } 
    }
    
    public List<NI_Trust_Outage__c> removeTrustfrmIncidentRecord(List<NI_Trust__c> trustList)
    {
        Map<String, String> idMap = new Map<String, String>();
        Map<ID, NI_Trust_Outage__c> incidentsUpdateMap = new Map<ID, NI_Trust_Outage__c>();
        Set<String> incIdSet = new Set<String>();
        
        for(NI_Trust__c t: trustList)
        {
            system.debug('Trust : '+t);
            
            for(AH_Trust_to_Incident__c juncObj : t.AH_Trusts_to_Incidents__r)
            {
                if (juncObj.AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c != NULL 
                    && juncObj.AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c != '')
                {
                    String externalPlatformName = juncObj.AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c;
                    system.debug('External_Platform_Name_HIDDEN__c : '+externalPlatformName);
                    
                    idMap.put(t.id+'_'+juncObj.AH_Trust_Incident__c, juncObj.AH_Trust_Incident__c);
                    
                    NI_Trust_Outage__c incidentObj = new NI_Trust_Outage__c(id=juncObj.AH_Trust_Incident__c);
                    
                    incIdSet.add(juncObj.AH_Trust_Incident__c);
                    
                    // =============================== REMOVE DELETED PLATFORM NAME FROM EXTRENAL PLATFORM NAME FIELD OF INCIDENT RECORD ===============================
                    if(( t.Platform_Name_External__c != NULL && t.Platform_Name_External__c!= '')
                       && externalPlatformName.contains(t.id+ '_' + t.Platform_Name_External__c) )
                    {
                        
                        system.debug('in if...');
                        
                        if(externalPlatformName.contains(t.id+ '_' + t.Platform_Name_External__c +','))
                        {
                            system.debug('in inner if...');
                            String target = t.id+ '_' + t.Platform_Name_External__c +',';
                            String replacement = '';
                            
                            system.debug('target : '+target);
                            system.debug('replacement : '+replacement);
                            
                            externalPlatformName = externalPlatformName.replace(target, replacement);
                            system.debug('Updated externalPlatformName : '+externalPlatformName);
                        }
                        else
                        {
                            system.debug('in inner else...');
                            String target = t.id+ '_' + t.Platform_Name_External__c;
                            String replacement = '';
                            
                            system.debug('target : '+target);
                            system.debug('replacement : '+replacement);
                            
                            externalPlatformName = externalPlatformName.replace(target, replacement);
                            system.debug('Updated externalPlatformName : '+externalPlatformName);
                        }
                        
                        externalPlatformName = externalPlatformName.removeEnd(',');

                        
                        /*
                        // DELETE "TRUST ID_EXTERNAL PLATFORM NAME"  
                        String regex = t.id+ '_' + t.Platform_Name_External__c;
                        Pattern regexPattern = Pattern.compile(regex);
                        Matcher regexMatcher = regexPattern.matcher(externalPlatformName);
                        if(regexMatcher.find()) {
                            externalPlatformName = externalPlatformName.replaceAll(regex, '');
                        }
                        
                        // REMOVE DOUBLA COMMA FROM EXTERNAL PLATFORM NAME TEXT
                        String commaRegex = ',,';
                        Pattern regexPattern1 = Pattern.compile(commaRegex);
                        Matcher regexMatcher1 = regexPattern1.matcher(externalPlatformName);
                        
                        if(regexMatcher1.find()) {
                            externalPlatformName = externalPlatformName.replaceAll(commaRegex, ',');
                        }
                        externalPlatformName = externalPlatformName.replace(',,', ',');
                        
                        
                        // DELETE STARTING , 
                        externalPlatformName = externalPlatformName.removeStart(',');
                        // DELETE ENDING , 
                        externalPlatformName = externalPlatformName.removeEnd(',');
                        
                        
                        */
                        
                        system.debug('Updated externalPlatformName : '+externalPlatformName);
                        incidentObj.External_Platform_Name_HIDDEN__c = externalPlatformName;
                        
                        
                        
                        
                        
                        // CODE TO POPULATE EXTERNAL PLATFORM NAMES BY REMOVING TRUST IDs
                        if(externalPlatformName != NULL && externalPlatformName != '' )
                        {
                            List<String> allNames = externalPlatformName.split(',');
                            List<String> updatedNames = new List<String>();
                            for(String name : allNames)
                            {
                                List<String> singleName = name.split('_');
                                updatedNames.add(singleName[1]);
                            }
                            
                            incidentObj.External_Platform_Name_LIST__c = String.join(updatedNames, ', ');
                        }
                        else if(externalPlatformName == NULL || externalPlatformName == '' ) 
                        {
                            incidentObj.External_Platform_Name_LIST__c = '';
                        }
                        
                        system.debug('incidentObj.External_Platform_Name_LIST__c : '+incidentObj.External_Platform_Name_LIST__c);
                    }
                    
                    
                    // ============================================ REMOVE DELETED PLATFORM NAME FROM EXTRENAL PLATFORM NAME FIELD OF INCIDENT RECORD ============================================
                    
                    String internalPlatformName = juncObj.AH_Trust_Incident__r.Internal_Platform_Name_HIDDEN__c;
                    system.debug('Internal_Platform_Name_HIDDEN__c : '+internalPlatformName);
                    
                    if(internalPlatformName!= NULL && internalPlatformName.contains(t.id+ '_' + t.Platform_Name_Internal__c) 
                       && ( t.Platform_Name_Internal__c != NULL && t.Platform_Name_Internal__c!= '') )   // NEED TO CHECK
                    {
                        system.debug('in if...');
                        
                        if(internalPlatformName.contains(t.id+ '_' + t.Platform_Name_Internal__c +','))
                        {
                            system.debug('in inner if...');
                            String target = t.id+ '_' + t.Platform_Name_Internal__c +',';
                            String replacement = '';
                            
                            system.debug('target : '+target);
                            system.debug('replacement : '+replacement);
                            
                            internalPlatformName = internalPlatformName.replace(target, replacement);
                            system.debug('Updated internalPlatformName : '+internalPlatformName);
                        }
                        else
                        {
                            system.debug('in inner else...');
                            String target = t.id+ '_' + t.Platform_Name_Internal__c;
                            String replacement = '';
                            
                            system.debug('target : '+target);
                            system.debug('replacement : '+replacement);
                            
                            internalPlatformName = internalPlatformName.replace(target, replacement);
                            system.debug('Updated internalPlatformName : '+internalPlatformName);
                        }
                        
                        internalPlatformName = internalPlatformName.removeEnd(',');
                        
                        
                        
                        /*
                        // DELETE "TRUST ID_INTERNAL PLATFORM NAME" 
                        String regex = t.id+ '_' + t.Platform_Name_Internal__c;
                        Pattern regexPattern = Pattern.compile(regex);
                        Matcher regexMatcher = regexPattern.matcher(internalPlatformName);
                        if(regexMatcher.find()) {
                            internalPlatformName = internalPlatformName.replaceAll(regex, '');
                        }
                        
                        // REMOVE DOUBLA COMMA FROM INTERNAL PLATFORM NAME TEXT
                        String commaRegex = ',,';
                        Pattern regexPattern1 = Pattern.compile(commaRegex);
                        Matcher regexMatcher1 = regexPattern1.matcher(internalPlatformName);
                        
                        if(regexMatcher1.find()) {
                            internalPlatformName = internalPlatformName.replaceAll(commaRegex, ',');
                        }
                        internalPlatformName = internalPlatformName.replace(',,', ',');
                        
                        
                        // DELETE STARTING , 
                        internalPlatformName = internalPlatformName.removeStart(',');
                        // DELETE ENDING , 
                        internalPlatformName = internalPlatformName.removeEnd(',');
                        */
                        
                        system.debug('Updated internalPlatformName : '+internalPlatformName);
                        incidentObj.Internal_Platform_Name_HIDDEN__c = internalPlatformName;
                        
                        
                        
                        
                        // CODE TO POPULATE INTERNAL PLATFORM NAMES BY REMOVING TRUST IDs
                        if(internalPlatformName != NULL && internalPlatformName != '' )
                        {
                            List<String> allNames = internalPlatformName.split(',');
                            List<String> updatedNames = new List<String>();
                            for(String name : allNames)
                            {
                                List<String> singleName = name.split('_');
                                updatedNames.add(singleName[1]);
                            }
                            system.debug('updatedNames : '+updatedNames);
                            
                            incidentObj.Internal_Platform_Name_LIST__c = String.join(updatedNames, ', ');
                        }
                        else if(internalPlatformName == NULL || internalPlatformName == '' )
                        {
                            incidentObj.Internal_Platform_Name_LIST__c = '';
                        }
                        
                        system.debug('incidentObj.Internal_Platform_Name_LIST__c : '+incidentObj.Internal_Platform_Name_LIST__c);
                        
                    }
                    
                    // ADD INCIDENT RECORDS IN MAP TO AVOID DUPLICATE VALUES
                    incidentsUpdateMap.put(juncObj.AH_Trust_Incident__c, incidentObj);
                }
            }
        }
        
        system.debug('incidentsUpdateMap size : '+incidentsUpdateMap.size());
        
        // FOR UPDATE QUERY WRITTEN TO AVOID LOCK ROW ERRORS
        List<NI_Trust_Outage__c> incList = new List<NI_Trust_Outage__c>([select ID FROM NI_Trust_Outage__c WHERE ID IN: incIdSet FOR UPDATE]);
        
        List<NI_Trust_Outage__c> updateIncList = new List<NI_Trust_Outage__c>();
        for(String incidentId : incidentsUpdateMap.keyset())
        {
            updateIncList.add(incidentsUpdateMap.get(incidentId));
        }
        system.debug('updateIncList size : '+updateIncList.size());
        
		return updateIncList;
    }
    
}