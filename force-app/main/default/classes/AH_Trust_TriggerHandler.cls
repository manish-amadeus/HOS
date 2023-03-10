/************************************************************************************************
Name            : AH_Trust_TriggerHandler Class
Author          : Shashikant Nikam
Created Date    : 01/14/2020
Last Mod Date   : 03/12/2020
Last Mod By     : Shashikant Nikam
NICC Reference  :
Description     : 
                : 
************************************************************************************************/

public class AH_Trust_TriggerHandler {

    public void OnAfterUpdate(List<NI_Trust__c> newTrigger, Map<Id, NI_Trust__c> oldMapTrigger)
    {
        Set<String> trustIdSet = new Set<String>();
        for(NI_Trust__c t: newTrigger)
        {
            trustIdSet.add(t.id);
        }
   		system.debug('trustIdSet  :' + trustIdSet);
        List<NI_Trust__c> trustList = [SELECT ID, Name, Platform_Name_External__c, Platform_Name_Internal__c, 
                                            ( 
                                                SELECT ID, 
                                                Name,
                                                AH_Trust_Incident__c, 
                                                AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c,
                                                AH_Trust_Incident__r.Internal_Platform_Name_HIDDEN__c 
                                                FROM AH_Trusts_to_Incidents__r 
                                            ) 
                                       FROM NI_Trust__c
                                      WHERE ID IN: trustIdSet];
        system.debug('trustIdSet  :' + trustIdSet);
        Map<String, String> idMap = new Map<String, String>();
        Map<ID, NI_Trust_Outage__c> incidentsUpdateMap = new Map<ID, NI_Trust_Outage__c>();
        Set<String> incIdSet = new Set<String>();
        
        for(NI_Trust__c t: trustList)
        {
            system.debug('Trust : '+t);
            system.debug('Trust OLD Platform_Name_External__c : '+oldMapTrigger.get(t.id).Platform_Name_External__c);
            
            for(AH_Trust_to_Incident__c juncObj : t.AH_Trusts_to_Incidents__r)
            {
                String externalPlatformName = juncObj.AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c;
                system.debug('External_Platform_Name_HIDDEN__c : '+externalPlatformName);
                
                idMap.put(t.id+'_'+juncObj.AH_Trust_Incident__c, juncObj.AH_Trust_Incident__c);
                
                system.debug('Collection Of CONCANICATED TRUST ID AND JUNS INCIDET ID VALUES --IDMap  :' + idMap);
                NI_Trust_Outage__c incidentObj = new NI_Trust_Outage__c(id=juncObj.AH_Trust_Incident__c);
                
                system.debug('INSERTED TRUST INCIDENT ID FROM JUNCOBJ--incidentObj  :' + incidentObj);
                incIdSet.add(juncObj.AH_Trust_Incident__c);
                
                 system.debug('COLLECTED JUNC TRUST INCIDENT ID --incIdSet  :' + incIdSet);
                
                if(externalPlatformName == NULL )
                {
                    externalPlatformName = t.id+'_'+t.Platform_Name_External__c;
                    incidentObj.External_Platform_Name_HIDDEN__c = externalPlatformName;
                }
                
                
                // ============================================ POPULATE EXTRENAL PLATFORM NAME FIELD ON INCIDENT RECORD ============================================
                if(externalPlatformName.contains(t.id) )
                {
                    system.debug('IF CONTAINS TRUST ID THEN INSIDE IF ---');
                    
                    // CHECK NAME PRESENT BETWEEN OTHER VALUES    
                    if(externalPlatformName.contains(oldMapTrigger.get(t.id).Platform_Name_External__c +','))
                    {
                        system.debug('in first if...');
                        String target = t.id + '_' + oldMapTrigger.get(t.id).Platform_Name_External__c +',';
                        String replacement = t.id + '_' + t.Platform_Name_External__c+ ',';
                        
                        system.debug('target : '+target);
                        system.debug('replacement : '+replacement);
                        
                        externalPlatformName = externalPlatformName.replace(target, replacement);
                        incidentObj.External_Platform_Name_HIDDEN__c = externalPlatformName;
                        
                        system.debug('Updated externalPlatformName : '+externalPlatformName);
                    }
                    
                    // CHECKS NAME IS ONLY VLAUE / PRESENT AT THE VERY END
                    else 
                    {
                        system.debug('in else');
                        List<String> extNmaes = externalPlatformName.split(',');
                        system.debug('extNmaes : '+extNmaes);
                        
                        // ONLY VALUE
                        if(extNmaes.size() == 1)
                        {
                            system.debug('in inner if');
                            externalPlatformName = t.id+'_'+t.Platform_Name_External__c;
                            incidentObj.External_Platform_Name_HIDDEN__c = externalPlatformName;
                        }
                        else if(extNmaes.size() > 1)
                        {
                            List<String> updExtNamesList = new List<String>();
                            system.debug('in inner else');
                            for(Integer i = 0; i < extNmaes.size() - 1; i++)
                            {
                                updExtNamesList.add(extNmaes[i]);
                            }
                            updExtNamesList.add(t.id+'_'+t.Platform_Name_External__c);
                            system.debug('updExtNamesList : '+updExtNamesList);
                            
                            externalPlatformName = String.join(updExtNamesList, ',');
                            system.debug('externalPlatformName : '+externalPlatformName);
                            
                            incidentObj.External_Platform_Name_HIDDEN__c = externalPlatformName;
							
                        }
                        
                        /*
                        String oldPlatformName = oldMapTrigger.get(t.id).Platform_Name_External__c;
                        System.debug('oldPlatformName  :  '+oldPlatformName);
                        
                        String regex = t.id +'_'+ oldPlatformName +'$';
                        System.debug('regex  :  '+regex);
                        Pattern regexPattern = Pattern.compile(regex);
                        System.debug('regexPattern  :  '+regexPattern);
                        Matcher regexMatcher = regexPattern.matcher(externalPlatformName);
                        System.debug('regexMatcher  :  '+regexMatcher);
                        
                        if(regexMatcher.find())
                        {
                            system.debug('INSIDE IF REGEX MATCHES  ..');
                            externalPlatformName = externalPlatformName.replaceAll(regex, t.id+'_'+t.Platform_Name_External__c);
                            System.debug('externalPlatformName INSIDE REGEX LOOP  :  '+ externalPlatformName);
                            
                            incidentObj.External_Platform_Name_HIDDEN__c = externalPlatformName;
                        }
						*/
                    }
                    
                    
                    
                    // CODE TO POPULATE EXTERNAL PLATFORM NAMES BY REMOVING TRUST IDs
                    List<String> allNames = externalPlatformName.split(',');
                    List<String> updatedNames = new List<String>();
                    for(String name : allNames)
                    {
                        name = name.trim();
                        List<String> singleName = name.split('_');
                        updatedNames.add(singleName[1]);
                    }
                    system.debug('updatedNames : '+updatedNames);
                    
                    incidentObj.External_Platform_Name_LIST__c = String.join(updatedNames, ', ');
                    
                    system.debug('incidentObj.External_Platform_Name_LIST__c : '+incidentObj.External_Platform_Name_LIST__c);

                }
                
                
                // ============================================ POPULATE INTRENAL PLATFORM NAME FIELD ON INCIDENT RECORD ============================================
                
                String internalPlatformName = juncObj.AH_Trust_Incident__r.Internal_Platform_Name_HIDDEN__c;
                system.debug('Internal_Platform_Name_HIDDEN__c : '+internalPlatformName);
                
                if(internalPlatformName == NULL )
                {
                    internalPlatformName = t.id+'_'+t.Platform_Name_Internal__c;
                    incidentObj.Internal_Platform_Name_HIDDEN__c = internalPlatformName;
                }
                
                if(internalPlatformName.contains(t.id) )
                {

                    // CHECK NAME PRESENT BETWEEN OTHER VALUES    
                    if(internalPlatformName.contains(oldMapTrigger.get(t.id).Platform_Name_Internal__c +','))
                    {
                        String target = t.id + '_' + oldMapTrigger.get(t.id).Platform_Name_Internal__c +',';
                        String replacement = t.id + '_' + t.Platform_Name_Internal__c+ ',';
                        
                        system.debug('target : '+target);
                        system.debug('replacement : '+replacement);
                        
                        internalPlatformName = internalPlatformName.replace(target, replacement);
                        incidentObj.Internal_Platform_Name_HIDDEN__c = internalPlatformName;
                        
                        system.debug('Updated internalPlatformName : '+internalPlatformName);
                    }
                    
                    // CHECKS NAME IS ONLY VLAUE / PRESENT AL THE VERY END
                    else 
                    {
                        
                        system.debug('in else');
                        List<String> intNmaes = internalPlatformName.split(',');
                        system.debug('intNmaes : '+intNmaes);
                        
                        // ONLY VALUE
                        if(intNmaes.size() == 1)
                        {
                            system.debug('in inner if');
                            internalPlatformName = t.id+'_'+t.Platform_Name_Internal__c;
                            incidentObj.Internal_Platform_Name_HIDDEN__c = internalPlatformName;
                        }
                        else if(intNmaes.size() > 1)
                        {
                            List<String> updIntNamesList = new List<String>();
                            system.debug('in inner else');
                            for(Integer i = 0; i < intNmaes.size() - 1; i++)
                            {
                                updIntNamesList.add(intNmaes[i]);
                            }
                            updIntNamesList.add(t.id+'_'+t.Platform_Name_Internal__c);
                            system.debug('updIntNamesList : '+updIntNamesList);
                            
                            internalPlatformName = String.join(updIntNamesList, ', ');
                            system.debug('internalPlatformName : '+internalPlatformName);
                            
                            incidentObj.Internal_Platform_Name_HIDDEN__c = internalPlatformName;
							
                        }
                     
                        /*
                        String oldPlatformName = oldMapTrigger.get(t.id).Platform_Name_Internal__c;
                        System.debug('oldPlatformName  :  '+oldPlatformName);
                        
                        String regex = t.id +'_'+ oldPlatformName +'$';
                        Pattern regexPattern = Pattern.compile(regex);
                        Matcher regexMatcher = regexPattern.matcher(internalPlatformName);
                        
                        if(regexMatcher.find()) 
                        {
                            internalPlatformName = internalPlatformName.replaceAll(regex, t.id+'_'+t.Platform_Name_Internal__c);
                            
                            system.debug('Updated internalPlatformName : '+internalPlatformName);
                            incidentObj.Internal_Platform_Name_HIDDEN__c = internalPlatformName;
                        }
						*/
                    }
                    
                    
                    // CODE TO POPULATE INTERNAL PLATFORM NAMES BY REMOVING TRUST IDs
                    List<String> allNames = internalPlatformName.split(',');
                    List<String> updatedNames = new List<String>();
                    for(String name : allNames)
                    {
                        name = name.trim();
                        List<String> singleName = name.split('_');
                        updatedNames.add(singleName[1]);
                    }
                    system.debug('updatedNames : '+updatedNames);
                    
                    incidentObj.Internal_Platform_Name_LIST__c = String.join(updatedNames, ', ');
                    
                    system.debug('incidentObj.Internal_Platform_Name_LIST__c : '+incidentObj.Internal_Platform_Name_LIST__c);
                    
                }
                
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
    
}