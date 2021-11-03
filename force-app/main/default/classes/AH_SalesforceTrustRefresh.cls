/****************************************************************************************
Name            : AH_SalesforceTrustRefresh Class
Author          : Bhuleshwar Deshpande
Created Date    : 10/03/2018       
Last Mod Date   : 05/28/2018 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that is scheduled to pull data into our org from Salesforce Trust
				: 
				: 
******************************************************************************************/
public class AH_SalesforceTrustRefresh 
{    
    
    @future(callout=true)
    public static void getInstances(String strEndPoint) 
    {
        
        // THIS FUNCTION MAINTAINS AH_Salesforce_Instance__c RECORDS BY CALLING OUT TO TRUST API AND UPSERTING RESULTS
        
        // ESTABLISH A HTTP REQUEST AND QUERY SALESFORCE SERVER INSTANCES
        Http http = new Http();      
        HttpRequest request = new HttpRequest();
        request.setEndpoint(strEndPoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) 
        {
            
            try
            {
                
                List<AH_Salesforce_Instance__c> lstInstanceUpserts = new List<AH_Salesforce_Instance__c>();
                List<Object> lstResults = (List<object>)JSON.deserializeUntyped(response.getBody());
                
                // ITERATE OVER DESERIALIZED RESPONSE
                for (Object obj : lstResults)
                {
                    
                    Map<String, Object> mapResult = (Map<String, Object>)obj;
                    String str = '';
                    
                    if (mapResult.containsKey('key'))
                    {
                        
                        AH_Salesforce_Instance__c si = new AH_Salesforce_Instance__c();
                        
                        str = String.valueOf(mapResult.get('key'));
                        
                        si.Name = str;
                        si.Key__c = str;
                        
                        // PARENT NODE
                        if (mapResult.containsKey('location'))
                        {
                            si.Location__c = String.valueOf(mapResult.get('location'));
                        }
                        
                        if (mapResult.containsKey('environment'))
                        {
                            si.Environment__c = String.valueOf(mapResult.get('environment'));
                        }
                        
                        if (mapResult.containsKey('releaseNumber'))
                        {
                            si.Release_Number__c = String.valueOf(mapResult.get('releaseNumber'));
                        }
                        
                        if (mapResult.containsKey('releaseVersion'))
                        {
                            si.Release_Version__c = String.valueOf(mapResult.get('releaseVersion'));
                        }
                        
                        if (mapResult.containsKey('status'))
                        {
                            si.Status__c = String.valueOf(mapResult.get('status'));
                        }
                        
                        if (mapResult.containsKey('isActive'))
                        {
                            si.Is_Active__c = boolean.valueOf(mapResult.get('isActive'));
                        }
                        
                        // SERVICES NODE 
                        if (mapResult.containsKey('Services'))
                        {
                            
                            List<String> serviceList = new List<String>();
                            List<Object> serMaplist = (List<Object>)mapResult.get('Services');
                            List<Object> keylist = new List<Object>();
                            
                            for (Object serList : serMaplist)
                            {
                                Map<String, Object> serviceMap = (Map<String, Object>)serList;
                                if (serviceMap.containskey('key'))
                                {
                                    keylist.add(serviceMap.get('key'));     
                                    String allstring = String.join(keylist, ',');
                                }
                            } 	
                            
                            si.Services__c = String.valueOf(keylist);
                            
                        }
                        
                        // PRODUCTS NODE
                        if (mapResult.containsKey('Products'))
                        {
                            
                            List<Object> prodList = (List<Object>) mapResult.get('Products');
                            List<Object> prkeylist = new List<Object>();
                            
                            for (Object pList : prodList)
                            {
                                Map<String, Object> productMap = (Map<String, Object>)pList;
                                
                                if (productMap.containskey('key'))
                                {
                                    prkeylist.add(productMap.get('key'));     
                                    String prstring = String.join(prkeylist, ',');
                                }
                            }
                            si.Products__c = String.valueOf(prkeylist);
                        }
                        
                        lstInstanceUpserts.add(si);   
                        
                    }
                    
                }
                
                system.debug(' **** NUMBER OF INSTANCE UPSERTS = ' + lstInstanceUpserts.size());
                
                // SYNC AH_Salesforce_Instance__c RECORDS WITH TRUST DB
                if (!lstInstanceUpserts.isEmpty())
                {
                    
                    // DEACTIVATE INSTANCES MISSING FROM RESULTS
                    for (AH_Salesforce_Instance__c oldSI : [SELECT Id, Key__c FROM AH_Salesforce_Instance__c WHERE Is_Active__c = true])
                    {
                        boolean bExists = false;
                        for (AH_Salesforce_Instance__c newSI : lstInstanceUpserts)
                        {
                            if (oldSI.Key__c == newSI.Key__c)
                            {
                                bExists = true;
                            }
                        }
                        if (!bExists)
                        {
                            AH_Salesforce_Instance__c osi = oldSI;
                            osi.Is_Active__c = false;
                            lstInstanceUpserts.add(osi);
                        }
                    }   
                    
                    Schema.SObjectField f = AH_Salesforce_Instance__c.Fields.Key__c;          
                    Database.upsert(lstInstanceUpserts, f, false);
                    
                }
                
            }
            catch (Exception ex)
            {
                String strExDetails = 'Error occurred in AH_SalesforceTrustRefresh.getInstances() on Line#' + ex.getLineNumber() + '\n' + ex.getMessage();
                NI_Error_Logger.WriteToLog(strExDetails, 'AH_Salesforce_Instance__c', 'AH_SalesforceTrustRefresh', 'Upsert');                  
            }
            
        }
        else
        {          
            String strDetails = 'Error code ' + response.getStatusCode() + ' in AH_SalesforceTrustRefresh.getInstances() at endpoint https://api.status.salesforce.com/v1/instances';
            NI_Error_Logger.WriteToLog(strDetails, 'AH_Salesforce_Instance__c', 'AH_SalesforceTrustRefresh', 'Upsert');             
        }
        
    }
    
    @future(callout=true)
    public static void getIncidents(String strEndPoint)
    {
        
        // METHOD TO INSERT INCIDENT INFORMATION 
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(strEndPoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200)
        {
            
            try
            {
                
                Map<String, List<String>> mapNotification2Instances = new Map<String, List<String>>();
                Set<String> setNotificationIds = new Set<String>();
                List<AH_Salesforce_Trust_Notification__c> lstNotificationUpserts = new List<AH_Salesforce_Trust_Notification__c>();
                List<AH_Salesforce_Trust_Impact_Event__c> lstImpactEventUpserts = new List<AH_Salesforce_Trust_Impact_Event__c>();
                List<Object> lstResults = (List<Object>)JSON.deserializeUntyped(response.getBody());
                
                // ITERATE OVER API RESPONSE
                for (Object obj : lstResults)
                {
                    
                    Map<String, Object> mapResult = (Map<String, Object>)obj;
                    String strNotificationId = 'INCDNT-';
                    
                    if (mapResult.containsKey('id'))
                    {
                        
                        AH_Salesforce_Trust_Notification__c stn = new AH_Salesforce_Trust_Notification__c();
                        
                        strNotificationId += String.valueOf(mapResult.get('id'));
                        
                        // ADD Notification Id TO SET
                        setNotificationIds.add(strNotificationId);
                        
                        stn.RecordTypeId = Schema.SObjectType.AH_Salesforce_Trust_Notification__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
                        
                        stn.SF_Trust_ID__c = strNotificationId;
                        
                        // MESSAGE NODE =================================================================================================
                        if (mapResult.containsKey('message'))
                        {
                            
                            Map<String, Object> mapMsgs = (Map<String, Object>)mapResult.get('message');
                            
                            if (mapMsgs.containskey('pathToResolution'))
                            {
                                stn.Path_to_Resolution__c = String.valueOf(mapMsgs.get('pathToResolution'));
                            }      
                            
                            if (mapMsgs.containskey('actionPlan'))
                            {
                                stn.Action_Plan__c = String.valueOf(mapMsgs.get('actionPlan'));
                            }
                            
                            if (mapMsgs.containskey('rootCause'))
                            {
                                stn.Root_Cause__c = String.valueOf(mapMsgs.get('rootCause'));
                            }
                            
                        }  	
                        
                        if (mapResult.containsKey('additionalInformation'))
                        {
                            stn.Additional_Information__c = String.valueOf(mapResult.get('additionalInformation'));
                        }   
                        
                        if (mapResult.containsKey('isCore'))
                        {
                            stn.Is_Core__c = boolean.valueOf(mapResult.get('isCore'));
                        }
                        
                        if (mapResult.containsKey('affectsAll'))
                        {
                            stn.Affects_All__c = boolean.valueOf(mapResult.get('affectsAll'));
                        }
                        
                        if (mapResult.containsKey('createdAt'))
                        {
                            String str1 = String.valueOf(mapResult.get('createdAt'));
                            DateTime dt1 = (DateTime)Json.deserialize('"' + str1 + '"', DateTime.class);
                            stn.Created_At__c = dt1;
                        }
                        
                        if (mapResult.containsKey('updatedAt'))
                        {
                            String str2 = String.valueOf(mapResult.get('updatedAt'));
                            DateTime dt2 = (DateTime)Json.deserialize('"' + str2 + '"', DateTime.class);
                            stn.Updated_At__c = dt2;
                        }
                        
                        // INCIDENT IMPACTS NODE ========================================================================================
                        if (mapResult.containsKey('IncidentImpacts'))
                        {
                            
                            List<Object> lstImpacts = (List<Object>)mapResult.get('IncidentImpacts');
                            
                            for (Object imp : lstImpacts)
                            {
                                
                                Map<String, Object> mapImpact = (Map<String, Object>)imp;
                                
                                if (mapImpact.containskey('id'))
                                {
                                    
                                    AH_Salesforce_Trust_Impact_Event__c ie1 = new AH_Salesforce_Trust_Impact_Event__c();
                                    
                                    ie1.SF_Trust_ID__c = 'IIMPACT-' + String.valueOf(mapImpact.get('id'));
                                    
                                    ie1.SF_Notification_ID__c = strNotificationId; 
                                    
                                    ie1.RecordTypeId = Schema.SObjectType.AH_Salesforce_Trust_Impact_Event__c.getRecordTypeInfosByName().get('Impact').getRecordTypeId();
                                    
                                    if (mapImpact.containskey('startTime'))
                                    {
                                        if (String.valueOf(mapImpact.get('startTime')) != null && String.valueOf(mapImpact.get('startTime')) != '')
                                        {
                                            String str3 = String.valueOf(mapImpact.get('startTime'));
                                            DateTime dt3 = (DateTime)Json.deserialize('"' + str3 + '"', DateTime.class);
                                            ie1.Start_Time__c = dt3;                                         
                                        }
                                    }  
                                    
                                    if (mapImpact.containskey('endTime'))
                                    {
                                        if (String.valueOf(mapImpact.get('endTime')) != null && String.valueOf(mapImpact.get('endTime')) != '')
                                        {
                                            String str4 = String.valueOf(mapImpact.get('endTime'));
                                            DateTime dt4 = (DateTime)Json.deserialize('"' + str4 + '"', DateTime.class);
                                            ie1.End_Time__c = dt4;                                        
                                        }
                                    }
                                    
                                    if (mapImpact.containskey('type'))
                                    {
                                        ie1.Type__c = string.valueOf(mapImpact.get('type'));     
                                    } 
                                    
                                    if (mapImpact.containskey('severity'))
                                    {
                                        ie1.Severity__c = string.valueOf(mapImpact.get('severity'));     
                                    }
                                    
                                    if (mapImpact.containskey('createdAt'))
                                    {
                                        String str5 = String.valueOf(mapImpact.get('createdAt'));
                                        DateTime dt5 = (DateTime)Json.deserialize('"' + str5 + '"', DateTime.class);
                                        ie1.Created_At__c = dt5;    
                                    }
                                    
                                    if (mapImpact.containskey('updatedAt'))
                                    {
                                        String str6 = String.valueOf(mapImpact.get('updatedAt'));
                                        DateTime dt6 = (DateTime)Json.deserialize('"' + str6 + '"', DateTime.class);
                                        ie1.Updated_At__c = dt6; 
                                    }    
                                    
                                    if (mapImpact.containskey('startTimeCreatedAt')) 
                                    {
                                        if (String.valueOf(mapImpact.get('startTimeCreatedAt')) != null && String.valueOf(mapImpact.get('startTimeCreatedAt')) != '')
                                        {
                                            String str7 = String.valueOf(mapImpact.get('startTimeCreatedAt'));
                                            DateTime dt7 = (DateTime)Json.deserialize('"' + str7 + '"', DateTime.class);
                                            ie1.Start_Time_Created_At__c = dt7;                                          
                                        }
                                    }
                                    
                                    if (mapImpact.containskey('startTimeModifiedAt'))
                                    {
                                        if (String.valueOf(mapImpact.get('startTimeModifiedAt')) != null && String.valueOf(mapImpact.get('startTimeModifiedAt')) != '')
                                        {
                                            String str8 = String.valueOf(mapImpact.get('startTimeModifiedAt'));
                                            DateTime dt8 = (DateTime)Json.deserialize('"' + str8 + '"', DateTime.class);
                                            ie1.Start_Time_Modified_At__c = dt8;                                           
                                        }  
                                    }
                                    
                                    if (mapImpact.containskey('endTimeCreatedAt'))
                                    {
                                        if (String.valueOf(mapImpact.get('endTimeCreatedAt')) != null && String.valueOf(mapImpact.get('endTimeCreatedAt')) != '')
                                        {
                                            String str9 = String.valueOf(mapImpact.get('endTimeCreatedAt'));
                                            DateTime dt9 = (DateTime)Json.deserialize('"' + str9 + '"', DateTime.class);
                                            ie1.End_Time_Created_At__c = dt9;                                            
                                        }
                                    }
                                    
                                    if (mapImpact.containskey('endTimeModifiedAt'))
                                    {
                                        if (String.valueOf(mapImpact.get('endTimeModifiedAt')) != null && String.valueOf(mapImpact.get('endTimeModifiedAt')) != '')
                                        {
                                            String str10 = String.valueOf(mapImpact.get('endTimeModifiedAt'));
                                            DateTime dt10 = (DateTime)Json.deserialize('"' + str10 + '"', DateTime.class);
                                            ie1.End_Time_Modified_At__c = dt10;                                           
                                        }
                                    }
                                    
                                    lstImpactEventUpserts.add(ie1);
                                    
                                }
                                
                            } 	
                            
                        }   
                        
                        // INCIDENT EVENTS NODE =========================================================================================
                        if (mapResult.containsKey('IncidentEvents'))
                        {
                            
                            List<Object> lstEvents = (List<Object>)mapResult.get('IncidentEvents');
                            
                            for (Object evt : lstEvents)
                            {
                                
                                Map<String, Object> mapEvent = (Map<String, Object>)evt;
                                
                                AH_Salesforce_Trust_Impact_Event__c ie2 = new AH_Salesforce_Trust_Impact_Event__c();
                                
                                ie2.SF_Trust_ID__c = 'IEVENT-' + String.valueOf(mapEvent.get('id'));
                                
                                ie2.SF_Notification_ID__c = strNotificationId; 
                                
                                ie2.RecordTypeId = Schema.SObjectType.AH_Salesforce_Trust_Impact_Event__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
                                
                                if (mapEvent.containskey('type'))
                                {
                                    ie2.Type__c = String.valueOf(mapEvent.get('type'));     
                                }
                                
                                if (mapEvent.containskey('message'))
                                {
                                    ie2.Message__c = String.valueOf(mapEvent.get('message'));     
                                }
                                
                                if (mapEvent.containskey('createdAt'))
                                {
                                    if (String.valueOf(mapEvent.get('createdAt')) != null && String.valueOf(mapEvent.get('createdAt')) != '')
                                    {                                
                                        String str1 = String.valueOf(mapEvent.get('createdAt'));
                                        DateTime dt1 = (DateTime)Json.deserialize('"' + str1 + '"', DateTime.class);
                                        ie2.Created_At__c = dt1;  
                                    }
                                }
                                
                                if (mapEvent.containskey('updatedAt'))
                                {
                                    if (String.valueOf(mapEvent.get('updatedAt')) != null && String.valueOf(mapEvent.get('updatedAt')) != '')
                                    {                                   
                                        String str2 = String.valueOf(mapEvent.get('updatedAt'));
                                        DateTime dt2 = (DateTime)Json.deserialize('"' + str2 + '"', DateTime.class);
                                        ie2.Updated_At__c = dt2;
                                    }
                                }
                                
                                lstImpactEventUpserts.add(ie2);
                                
                            }
                            
                        }
                        
                        // INSTANCE KEYS NODE ===========================================================================================
                        if (mapResult.containsKey('instanceKeys'))
                        {
                            
                            List<Object> lstInstances = (List<Object>)mapResult.get('instanceKeys');                        
                            List<String> lstInstanceKeys = new List<String>();
                            
                            for (Object inst : lstInstances)
                            {
                                lstInstanceKeys.add(String.valueOf(inst));
                            }
                            
                            mapNotification2Instances.put(strNotificationId, lstInstanceKeys);
                            
                        }
                        
                        // SERVICE KEYS NODE ============================================================================================
                        if (mapResult.containsKey('serviceKeys')) 
                        {
                            List<Object> lstServiceKeys = (List<Object>)mapResult.get('serviceKeys');
                            List<Object> lstKeys = new List<Object>();
                            for (Object sKey : lstServiceKeys)
                            {
                                lstKeys.add(sKey);     
                            }
                            String strKeys = String.join(lstKeys, ',');
                            stn.Services__c = strKeys;			//String.valueOf(lstKeys);																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																															
                        }
                        
                        lstNotificationUpserts.add(stn);
                        
                    }
                    
                }
				
                system.debug(' **** NUMBER OF INCIDENT UPSERTS = ' + lstNotificationUpserts.size());
                
                // UPSERT NOTIFICATION RECORDS
                if (!lstNotificationUpserts.isEmpty())
                {
                    
                    Schema.SObjectField f1 = AH_Salesforce_Trust_Notification__c.Fields.SF_Trust_ID__c;          
                    Database.upsert(lstNotificationUpserts, f1, false); 
                    
                    // LOOP THROUGH AH_Salesforce_Trust_Impact_Event__c AND ASSIGN RELATED AH_Salesforce_Trust_Notification__c LOOKUP IDS
                    for (AH_Salesforce_Trust_Notification__c sfTN : lstNotificationUpserts)
                    {
                        for (AH_Salesforce_Trust_Impact_Event__c sfIE : lstImpactEventUpserts)
                        {
                            if (sfTN.SF_Trust_ID__c == sfIE.SF_Notification_ID__c)
                            {
                                sfIE.AH_Salesforce_Trust_Notification__c = sfTN.Id;
                            }
                        }
                    }
                    
                    // UPSERT IMPACT/EVENT RECORDS
                    if (!lstImpactEventUpserts.isEmpty())
                    {
                        Schema.SObjectField f2 = AH_Salesforce_Trust_Impact_Event__c.Fields.SF_Trust_ID__c;          
                        Database.upsert(lstImpactEventUpserts, f2, false); 
                    }
                    
                    // CREATE A MAP OF INSTANCE IDS WITH Key__c AS THE KEY
                    Map<String, Id> mapKey2Id = new Map<String, Id>();
                    for (AH_Salesforce_Instance__c i : [SELECT Id, Key__c FROM AH_Salesforce_Instance__c])
                    {
                        mapKey2Id.put(i.Key__c, i.Id);
                    }            
                    
                    // CREATE A LIST OF JUNCTION OBJECT RECORDS FOR UPSERT
                    List<AH_Salesforce_Instance_to_Notification__c> lstJunctionUpserts = new List<AH_Salesforce_Instance_to_Notification__c>();
                    
                    for (AH_Salesforce_Trust_Notification__c n : lstNotificationUpserts)
                    {
                        for (String ks : mapNotification2Instances.keySet())
                        {
                            if (n.SF_Trust_ID__c == ks)
                            {
                                for (String ins : mapNotification2Instances.get(ks))
                                {
                                    AH_Salesforce_Instance_to_Notification__c i2n = new AH_Salesforce_Instance_to_Notification__c();
                                    i2n.AH_Salesforce_Notification__c = n.Id;
                                    i2n.AH_Salesforce_Instance__c = mapKey2Id.get(ins);
                                    i2n.Key__c = (i2n.AH_Salesforce_Instance__c + '-' + i2n.AH_Salesforce_Notification__c);                                 
                                    lstJunctionUpserts.add(i2n);
                                }
                            }
                        }
                    } 
                    
                    // UPSERT JUNCTION RECORDS
                    if (!lstJunctionUpserts.isEmpty())
                    {
                        Schema.SObjectField f = AH_Salesforce_Instance_to_Notification__c.Fields.Key__c; 
                        Database.upsert(lstJunctionUpserts, f, false);  
                    }
                    
                }
                
            }
            catch (Exception ex)
            {
                String strExDetails = 'Error occurred in AH_SalesforceTrustRefresh.getIncidents() on Line#' + ex.getLineNumber() + '\n' + ex.getMessage();
                NI_Error_Logger.WriteToLog(strExDetails, 'AH_Salesforce_Trust_Notification__c', 'AH_SalesforceTrustRefresh', 'Upsert');                  
            }
            
        }
        else
        {          
            String strDetails = 'Error code ' + response.getStatusCode() + ' in AH_SalesforceTrustRefresh.getIncidents() at endpoint https://api.status.salesforce.com/v1/incidents';
            NI_Error_Logger.WriteToLog(strDetails, 'AH_Salesforce_Instance__c', 'AH_SalesforceTrustRefresh', 'Upsert');             
        } 
        
    }
    
    @future(callout=true)
    public static void getMaintenances(String strEndPoint)
    {
        
        // METHOD TO INSERT MAINTENANCE RECORDS

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(strEndPoint);
        request.setMethod('GET');       
        Transient HttpResponse response = http.send(request);        
        
        if (response.getStatusCode() == 200)
        {
            
            try
            {
                
                Map<String, List<String>> mapNotification2Instances = new Map<String, List<String>>();
                Set<String> setNotificationIds = new Set<String>();
                List<AH_Salesforce_Trust_Notification__c> lstNotificationUpserts = new List<AH_Salesforce_Trust_Notification__c>();
                List<AH_Salesforce_Trust_Impact_Event__c> lstImpactEventUpserts = new List<AH_Salesforce_Trust_Impact_Event__c>();       
                Transient List<Object> lstResults = (List<Object>)JSON.deserializeUntyped(response.getBody());
                
                // ITERATE OVER API RESPONSE
                for (Object obj : lstResults)
                {
                    
                    Map<String, Object> mapResult = (Map<String, Object>)obj;
                    String strNotificationId = 'MNTNCE-';
                    DateTime dtPlannedStartTime;
                    
                    if (mapResult.containsKey('id'))
                    {
                        
                        if (mapResult.containskey('plannedStartTime'))
                        {
                            String strPlannedStartTime = String.valueOf(mapResult.get('plannedStartTime'));
                            dtPlannedStartTime = (DateTime)Json.deserialize('"' + strPlannedStartTime + '"', DateTime.class);
                        }
                        
                        // PREVENTS FUTURE MAINTENCE RECORDS FROM BEING IMPORTED
                        if (dtPlannedStartTime < system.now())
                        {
                            
                            AH_Salesforce_Trust_Notification__c stn = new AH_Salesforce_Trust_Notification__c();
                            
                            strNotificationId += String.valueOf(mapResult.get('id'));
                            
                            stn.SF_Trust_ID__c = strNotificationId;
                            
                            stn.RecordTypeId = Schema.SObjectType.AH_Salesforce_Trust_Notification__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
                            
                            // MESSAGE NODE =================================================================================================
                            if (mapResult.containskey('message'))
                            {
                                
                                Map<String, Object> mapMsg = (Map<String, Object>)mapResult.get('message');
                                
                                if (mapMsg.containskey('maintenanceType'))
                                {
                                    stn.Maintenance_Type__c = String.valueOf(mapMsg.get('maintenanceType'));
                                }
                                
                                if (mapMsg.containskey('availability'))
                                {
                                    stn.Availability__c = String.valueOf(mapMsg.get('availability'));
                                }
                                
                                if (mapMsg.containskey('eventStatus'))
                                {
                                    stn.Event_Status__c = String.valueOf(mapMsg.get('eventStatus'));
                                }
                                
                            }
                            
                            if (mapResult.containskey('plannedStartTime'))
                            {
                                String str1 = String.valueOf(mapResult.get('plannedStartTime'));
                                DateTime dt1 = (DateTime)Json.deserialize('"' + str1 + '"', DateTime.class);
                                stn.Planned_Start_Time__c = dt1;
                            }
                            
                            if (mapResult.containskey('plannedEndTime'))
                            {
                                String str2 = String.valueOf(mapResult.get('plannedEndTime'));
                                DateTime dt2 = (DateTime)Json.deserialize('"' + str2 + '"', DateTime.class);
                                stn.Planned_End_Time__c = dt2;
                            }
                            
                            if (mapResult.containskey('additionalInformation'))
                            {
                                stn.Additional_Information__c = String.valueOf(mapResult.get('additionalInformation'));
                            } 
                            
                            if (mapResult.containskey('createdAt'))
                            {
                                String str3 = String.valueOf(mapResult.get('createdAt'));
                                DateTime dt3 = (DateTime)Json.deserialize('"' + str3 + '"', DateTime.class);
                                stn.Created_At__c = dt3;
                            }
                            
                            if (mapResult.containskey('updatedAt'))
                            {
                                String str4 = String.valueOf(mapResult.get('updatedAt'));
                                DateTime dt4 = (DateTime)Json.deserialize('"' + str4 + '"', DateTime.class);
                                stn.Updated_At__c = dt4;
                            }
                            
                            // MAINTENANCE IMPACTS NODE =====================================================================================
                            if (mapResult.containsKey('MaintenanceImpacts'))
                            {
                                
                                List<Object> lstImpacts = (List<Object>)mapResult.get('MaintenanceImpacts');
                                
                                for (Object imp : lstImpacts)
                                {
                                    
                                    Map<String, Object> mapImpact = (Map<String, Object>)imp;
                                    
                                    if (mapImpact.containskey('id'))
                                    {
                                        
                                        AH_Salesforce_Trust_Impact_Event__c ie1 = new AH_Salesforce_Trust_Impact_Event__c();
                                        
                                        ie1.SF_Trust_ID__c = 'MIMPACT-' + String.valueOf(mapImpact.get('id'));
                                        
                                        ie1.SF_Notification_ID__c = strNotificationId; 
                                        
                                        ie1.RecordTypeId = Schema.SObjectType.AH_Salesforce_Trust_Impact_Event__c.getRecordTypeInfosByName().get('Impact').getRecordTypeId();
                                        
                                        if (mapImpact.containskey('startTime'))
                                        {
                                            if (String.valueOf(mapImpact.get('startTime')) != null && String.valueOf(mapImpact.get('startTime')) != '')
                                            {
                                                String str1 = String.valueOf(mapImpact.get('startTime'));
                                                DateTime dt1 = (DateTime)Json.deserialize('"' + str1 + '"', DateTime.class);
                                                ie1.Start_Time__c = dt1;                                         
                                            }
                                        }  
                                        
                                        if (mapImpact.containskey('endTime'))
                                        {
                                            if (String.valueOf(mapImpact.get('endTime')) != null && String.valueOf(mapImpact.get('endTime')) != '')
                                            {
                                                String str2 = String.valueOf(mapImpact.get('endTime'));
                                                DateTime dt2 = (DateTime)Json.deserialize('"' + str2 + '"', DateTime.class);
                                                ie1.End_Time__c = dt2;                                        
                                            }
                                        }
                                        
                                        if (mapImpact.containskey('type'))
                                        {
                                            ie1.Type__c = string.valueOf(mapImpact.get('type'));     
                                        } 
                                        
                                        if (mapImpact.containskey('severity'))
                                        {
                                            ie1.Severity__c = string.valueOf(mapImpact.get('severity'));     
                                        }
                                        
                                        if (mapImpact.containskey('createdAt'))
                                        {
                                            String str3 = String.valueOf(mapImpact.get('createdAt'));
                                            DateTime dt3 = (DateTime)Json.deserialize('"' + str3 + '"', DateTime.class);
                                            ie1.Created_At__c = dt3; 
                                        }
                                        
                                        if (mapImpact.containskey('updatedAt'))
                                        {
                                            String str4 = String.valueOf(mapImpact.get('updatedAt'));
                                            DateTime dt4 = (DateTime)Json.deserialize('"' + str4 + '"', DateTime.class);
                                            ie1.Updated_At__c = dt4; 
                                        }    
                                        
                                        if (mapImpact.containskey('startTimeCreatedAt')) 
                                        {
                                            if (String.valueOf(mapImpact.get('startTimeCreatedAt')) != null && String.valueOf(mapImpact.get('startTimeCreatedAt')) != '')
                                            {
                                                String str5 = String.valueOf(mapImpact.get('startTimeCreatedAt'));
                                                DateTime dt5 = (DateTime)Json.deserialize('"' + str5 + '"', DateTime.class);
                                                ie1.Start_Time_Created_At__c = dt5; 
                                            }
                                        }
                                        
                                        if (mapImpact.containskey('startTimeModifiedAt'))
                                        {
                                            if (String.valueOf(mapImpact.get('startTimeModifiedAt')) != null && String.valueOf(mapImpact.get('startTimeModifiedAt')) != '')
                                            {
                                                String str6 = String.valueOf(mapImpact.get('startTimeModifiedAt'));
                                                DateTime dt6 = (DateTime)Json.deserialize('"' + str6 + '"', DateTime.class);
                                                ie1.Start_Time_Modified_At__c = dt6; 
                                            }  
                                        }
                                        
                                        if (mapImpact.containskey('endTimeCreatedAt'))
                                        {
                                            if (String.valueOf(mapImpact.get('endTimeCreatedAt')) != null && String.valueOf(mapImpact.get('endTimeCreatedAt')) != '')
                                            {
                                                String str7 = String.valueOf(mapImpact.get('endTimeCreatedAt'));
                                                DateTime dt7 = (DateTime)Json.deserialize('"' + str7 + '"', DateTime.class);
                                                ie1.End_Time_Created_At__c = dt7; 
                                            }
                                        }
                                        
                                        if (mapImpact.containskey('endTimeModifiedAt'))
                                        {
                                            if (String.valueOf(mapImpact.get('endTimeModifiedAt')) != null && String.valueOf(mapImpact.get('endTimeModifiedAt')) != '')
                                            {
                                                String str8 = String.valueOf(mapImpact.get('endTimeModifiedAt'));
                                                DateTime dt8 = (DateTime)Json.deserialize('"' + str8 + '"', DateTime.class);
                                                ie1.End_Time_Modified_At__c = dt8; 
                                            }
                                        }
                                        
                                        lstImpactEventUpserts.add(ie1);
                                        
                                    }
                                    
                                } 	
                                
                            }   
                            
                            // MAINTENANCE EVENTS NODE ======================================================================================
                            if (mapResult.containsKey('MaintenanceEvents'))
                            {
                                
                                List<Object> lstEvents = (List<Object>)mapResult.get('MaintenanceEvents');
                                
                                for (Object evt : lstEvents)
                                {
                                    
                                    Map<String, Object> mapEvent = (Map<String, Object>)evt;
                                    
                                    AH_Salesforce_Trust_Impact_Event__c ie2 = new AH_Salesforce_Trust_Impact_Event__c();
                                    
                                    ie2.SF_Trust_ID__c = 'MEVENT-' + String.valueOf(mapEvent.get('id'));
                                    
                                    ie2.SF_Notification_ID__c = strNotificationId; 
                                    
                                    ie2.RecordTypeId = Schema.SObjectType.AH_Salesforce_Trust_Impact_Event__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
                                    
                                    if (mapEvent.containskey('type'))
                                    {
                                        ie2.Type__c = String.valueOf(mapEvent.get('type'));     
                                    }
                                    
                                    if (mapEvent.containskey('message'))
                                    {
                                        ie2.Message__c = String.valueOf(mapEvent.get('message'));     
                                    }
                                    
                                    if (mapEvent.containskey('createdAt'))
                                    {
                                        if (String.valueOf(mapEvent.get('createdAt')) != null && String.valueOf(mapEvent.get('createdAt')) != '')
                                        {                                
                                            String str1 = String.valueOf(mapEvent.get('createdAt'));
                                            DateTime dt1 = (DateTime)Json.deserialize('"' + str1 + '"', DateTime.class);
                                            ie2.Created_At__c = dt1;  
                                        }
                                    }
                                    
                                    if (mapEvent.containskey('updatedAt'))
                                    {
                                        if (String.valueOf(mapEvent.get('updatedAt')) != null && String.valueOf(mapEvent.get('updatedAt')) != '')
                                        {                                   
                                            String str2 = String.valueOf(mapEvent.get('updatedAt'));
                                            DateTime dt2 = (DateTime)Json.deserialize('"' + str2 + '"', DateTime.class);
                                            ie2.Updated_At__c = dt2;
                                        }
                                    }
                                    
                                    lstImpactEventUpserts.add(ie2);
                                    
                                }
                                
                            }
                            
                            // INSTANCE KEYS NODE ===========================================================================================
                            if (mapResult.containsKey('instanceKeys'))
                            {
                                
                                List<Object> lstInstances = (List<Object>)mapResult.get('instanceKeys');                        
                                List<String> lstInstanceKeys = new List<String>();
                                
                                for (Object inst : lstInstances)
                                {
                                    lstInstanceKeys.add(String.valueOf(inst));
                                }
                                
                                mapNotification2Instances.put(strNotificationId, lstInstanceKeys);
                                
                            }
                            
                            lstNotificationUpserts.add(stn);
                            
                        } 
                        
                    }  
                    
                }

                system.debug(' **** NUMBER OF MAINTENANCE UPSERTS = ' + lstNotificationUpserts.size());
                                
                // UPSERT NOTIFICATION RECORDS
                if (!lstNotificationUpserts.isEmpty())
                {
                    
                    Schema.SObjectField f1 = AH_Salesforce_Trust_Notification__c.Fields.SF_Trust_ID__c;          
                    Database.upsert(lstNotificationUpserts, f1, false); 
                    
                    // LOOP THROUGH AH_Salesforce_Trust_Impact_Event__c AND ASSIGN RELATED AH_Salesforce_Trust_Notification__c LOOKUP IDS
                    for (AH_Salesforce_Trust_Notification__c sfTN : lstNotificationUpserts)
                    {
                        for (AH_Salesforce_Trust_Impact_Event__c sfIE : lstImpactEventUpserts)
                        {
                            if (sfTN.SF_Trust_ID__c == sfIE.SF_Notification_ID__c)
                            {
                                sfIE.AH_Salesforce_Trust_Notification__c = sfTN.Id;
                            }
                        }
                    }
                    
                    // UPSERT IMPACT/EVENT RECORDS
                    if (!lstImpactEventUpserts.isEmpty())
                    {
                        Schema.SObjectField f2 = AH_Salesforce_Trust_Impact_Event__c.Fields.SF_Trust_ID__c;          
                        Database.upsert(lstImpactEventUpserts, f2, false); 
                    }
                    
                    // CREATE A MAP OF INSTANCE IDS WITH Key__c AS THE KEY
                    Map<String, Id> mapKey2Id = new Map<String, Id>();
                    for (AH_Salesforce_Instance__c i : [SELECT Id, Key__c FROM AH_Salesforce_Instance__c])
                    {
                        mapKey2Id.put(i.Key__c, i.Id);
                    }            
                    
                    // CREATE A LIST OF JUNCTION OBJECT RECORDS FOR UPSERT
                    List<AH_Salesforce_Instance_to_Notification__c> lstJunctionUpserts = new List<AH_Salesforce_Instance_to_Notification__c>();
                    
                    for (AH_Salesforce_Trust_Notification__c n : lstNotificationUpserts)
                    {
                        for (String ks : mapNotification2Instances.keySet())
                        {
                            if (n.SF_Trust_ID__c == ks)
                            {
                                for (String ins : mapNotification2Instances.get(ks))
                                {
                                    AH_Salesforce_Instance_to_Notification__c i2n = new AH_Salesforce_Instance_to_Notification__c();
                                    i2n.AH_Salesforce_Notification__c = n.Id;
                                    i2n.AH_Salesforce_Instance__c = mapKey2Id.get(ins);
                                    i2n.Key__c = (i2n.AH_Salesforce_Instance__c + '-' + i2n.AH_Salesforce_Notification__c);
                                    lstJunctionUpserts.add(i2n);
                                }
                            }
                        }
                    } 
                    
                    // UPSERT JUNCTION RECORDS
                    if (!lstJunctionUpserts.isEmpty())
                    {
                        Schema.SObjectField f = AH_Salesforce_Instance_to_Notification__c.Fields.Key__c; 
                        Database.upsert(lstJunctionUpserts, f, false);  
                    }
                    
                }
                
            }
            catch (Exception ex)
            {
                String strExDetails = 'Error occurred in AH_SalesforceTrustRefresh.getMaintenances() on Line#' + ex.getLineNumber() + '\n' + ex.getMessage();
                NI_Error_Logger.WriteToLog(strExDetails, 'AH_Salesforce_Trust_Notification__c', 'AH_SalesforceTrustRefresh', 'Upsert');                  
            }
            
        }       
        else
        {          
            String strDetails = 'Error code ' + response.getStatusCode() + ' in AH_SalesforceTrustRefresh.getMaintenances() at endpoint https://api.status.salesforce.com/v1/maintenances';
            NI_Error_Logger.WriteToLog(strDetails, 'AH_Salesforce_Trust_Notification__c', 'AH_SalesforceTrustRefresh', 'Upsert');             
        } 
        
    }
    
    @future(callout=true)
    public static void getGeneralMessages(String strEndPoint)
    {  
        
        // METHOD TO GET GENERAL MESSAGE RECORDS
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(strEndPoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200)
        {
            
            try
            {
                
                List<AH_Salesforce_Trust_Notification__c> lstNotificationUpserts = new List<AH_Salesforce_Trust_Notification__c>();
                List<Object> lstResults = (List<Object>)JSON.deserializeUntyped(response.getBody());
                
                // ITERATE OVER API RESPONSE
                for (Object obj : lstResults)
                {
                    
                    Map<String, Object> mapResult = (Map<string, Object>)obj;
                    
                    if (mapResult.containsKey('id'))
                    {
                        
                        AH_Salesforce_Trust_Notification__c stn = new AH_Salesforce_Trust_Notification__c();
                        
                        stn.RecordTypeId = Schema.SObjectType.AH_Salesforce_Trust_Notification__c.getRecordTypeInfosByName().get('General Message').getRecordTypeId();
                        
                        stn.SF_Trust_ID__c = 'GENMSG-' + String.valueOf(mapResult.get('id'));
                        
                        if (mapResult.containsKey('subject'))
                        {
                            stn.Subject__c = string.valueOf(mapResult.get('subject'));
                        }
                        
                        if (mapResult.containsKey('body'))
                        {
                            stn.Message_Body__c = string.valueOf(mapResult.get('body'));
                        }
                        
                        if (mapResult.containsKey('startDate'))
                        {
                            if (String.valueOf(mapResult.get('startDate')) != null && String.valueOf(mapResult.get('startDate')) != '')
                            {                        
                                String str1 = String.valueOf(mapResult.get('startDate'));
                                DateTime dt1 = (DateTime)Json.deserialize('"' + str1 + '"', DateTime.class);
                                stn.Start_Date__c = dt1;
                            }
                        }
                        
                        if (mapResult.containsKey('endDate'))
                        {   
                            if (String.valueOf(mapResult.get('endDate')) != null && String.valueOf(mapResult.get('endDate')) != '')
                            {
                                String str1 = String.valueOf(mapResult.get('endDate'));
                                DateTime dt2 = (DateTime)Json.deserialize('"' + str1 + '"', DateTime.class);
                                stn.End_Date__c = dt2; 
                            }
                        }      
                        
                        if (mapResult.containsKey('createdAt'))       
                        { 
                            if (String.valueOf(mapResult.get('createdAt')) != null && String.valueOf(mapResult.get('createdAt')) != '')
                            {
                                String str3 = String.valueOf(mapResult.get('createdAt'));
                                DateTime dt3 = (DateTime)Json.deserialize('"' + str3 + '"', DateTime.class);
                                stn.Created_At__c = dt3;
                            }
                        } 
                        
                        if (mapResult.containsKey('updatedAt'))
                        {
                            if (String.valueOf(mapResult.get('updatedAt')) != null && String.valueOf(mapResult.get('updatedAt')) != '')
                            {                        
                                String str4 = String.valueOf(mapResult.get('updatedAt'));
                                DateTime dt4 = (DateTime)Json.deserialize('"' + str4 + '"', DateTime.class);
                                stn.Updated_At__c = dt4;
                            }
                        }  
                        
                        lstNotificationUpserts.add(stn);
                        
                    }
                }  

                system.debug(' **** NUMBER OF MESSAGE UPSERTS = ' + lstNotificationUpserts.size());
                                
                // INSERT GENERAL MESSAGE RECORDS
                if (!lstNotificationUpserts.isEmpty())
                {
                    Schema.SObjectField f = AH_Salesforce_Trust_Notification__c.Fields.SF_Trust_ID__c;          
                    Database.upsert(lstNotificationUpserts, f, false); 
                }
                
            }
            catch (Exception ex)
            {
                String strExDetails = 'Error occurred in AH_SalesforceTrustRefresh.getGeneralMessages() on Line# ' + ex.getLineNumber() + '\n' + ex.getMessage();
                NI_Error_Logger.WriteToLog(strExDetails, 'AH_Salesforce_Trust_Notification__c', 'AH_SalesforceTrustRefresh', 'Upsert');                  
            }
            
        }
        else
        {          
            String strDetails = 'Error code ' + response.getStatusCode() + ' in AH_SalesforceTrustRefresh.getGeneralMessages() at endpoint https://api.status.salesforce.com/v1/generalMessages';
            NI_Error_Logger.WriteToLog(strDetails, 'AH_Salesforce_Trust_Notification__c', 'AH_SalesforceTrustRefresh', 'Upsert');             
        }  
        
    }
    
}