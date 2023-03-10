/************************************************************************************************
Name            : AH_JobScheduler_Ctlr Class
Author          : Shashikant Nikam
Created Date    : 02/21/2020
Last Mod Date   : 05/11/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Controller for AH_JobScheduler VF Page
                : 
                : 
*************************************************************************************************/
public class AH_JobScheduler_Ctlr extends AH_JobScheduler_Ctlr_Base 
{

    // COLLECTIONS
	public List<SelectOption> classOptions {get; set;}
    public List<jobData> schldJobsData {get; set;} 
    public Map<String, Map<String, String>> schldClassDetails {get; set;}
    public Map<String, String> IdclassMap;
    public Set<String> classNamesSet;
    public Map<String, String> usersMap;
    
    // STRINGS
    public String jobName {get; set;}
    public String selectedClass {get;set;}
    public String sessionId; 
    private String endPointUrl;
    
    // BOOLEANS
    public Boolean isCheckAllJobs {get; set;}
    
    // OBJECTS
    public Profile currentUserPrf;
   	public AH_CronBuilder_ctlr myComponentController {get; set;}
    
    // CUSTOM OBJECTS
    public Apex_Job_Scheduler_Setting__c settingsObj {get; set;}
    
    
    // CONSTRUCTOR METHOD
    public AH_JobScheduler_Ctlr()
    {

        usersMap = new Map<String, String>();
        
        isCheckAllJobs = false;
        schldClassDetails = new Map<String, Map<String, String>>();
        schldJobsData = new List<jobData>();
        
        // GET RUNNING USER'S PROFILE ID
        String profileId = UserInfo.getProfileId(); 
        
        // GET RUNNING USER'S PROFILE NAME USING RUNNING USER'S PROFILE ID
        currentUserPrf = [SELECT ID, NAME FROM Profile WHERE ID =: profileId];
        
        // RETRIEVE DATA FROM CUSTOM OBJECT - Apex_Job_Scheduler_Setting__c 
        List<Apex_Job_Scheduler_Setting__c> schldrSettingsList = new List<Apex_Job_Scheduler_Setting__c>(
            [SELECT Id, 
             Name, 
             Endpoint__c,
             Context_Username__c, 
             Context_User_Password__c, 
             Context_User_Security_Token__c, 
             Running_User_Profile_Name__c, 
             Schedulable_Classes__c, 
             Environment__c, 
             User_Name__c, 
             Schedulable_Classes_with_ID__c 
             FROM Apex_Job_Scheduler_Setting__c 
             WHERE Running_User_Profile_Name__c =: currentUserPrf.Name]);

        settingsObj = schldrSettingsList[0];
        endPointUrl = settingsObj.Endpoint__c;
        
        if (settingsObj.Context_User_Password__c != null && settingsObj.Context_User_Security_Token__c != null)
        {
            // GENERATE PICKLIST OF AVAILABLE CLASSES
            setClassOptsList();
            
            if(!Test.isRunningTest())
            {
                // CALL METHOD TO LOGIN TO REMOTE SF ORG
                login(settingsObj.Context_Username__c, settingsObj.Context_User_Password__c, settingsObj.Context_User_Security_Token__c);
                system.debug('Logged in...');
            }
        }
    }
    
    
    // METHOD TO LOGIN TO REMOTE SALESFORCE ORG
    public void login(String uName, String pwd, String securityToken) 
    {

        // CREATE SET FROM LISTED CLASSES IN CUSTOM OBJECT
        classNamesSet = new Set<String>(settingsObj.Schedulable_Classes__c.split(','));
        
        try 
        {
            String sEndPoint = '';
            if(settingsObj.Environment__c == 'Production')
            {
            	sEndPoint = 'https://login.salesforce.com/services/Soap/u/55.0'; 
            }
            else if(settingsObj.Environment__c == 'Sandbox')
            {
                sEndPoint = 'https://test.salesforce.com/services/Soap/u/55.0';
            }

            PartnerRemote.Soap soap = new PartnerRemote.Soap();
            
            PartnerRemote.LoginResult loginResult = soap.login(uName, pwd + securityToken, sEndPoint);
            soap.endpoint_x = loginResult.serverUrl; 
            sessionId = loginResult.sessionId; 
        }
        catch(Exception e)
        {
            system.debug('Found exception : '+e); 
            system.debug('Line Number : '+e.getLineNumber());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exception in login to remote org. '+ e));
        }
        
        
        // GET ALREADY SCHEDULED JOBS LIST
        if(!Test.isRunningTest())
        {
            getScheduledJobsList();
        }
    }

    
	// METHOD TO REFRESH THE SCHEDULED JOBS LIST 
    public void refreshJobsList()
    {
        getScheduledJobsList();
    }

    
	// METHOD TO RETRIEVE ALREADY SCHEDULED JOBS
	public void getScheduledJobsList()
    {
        
        try 
        {
            Apex_Job_Scheduler_Setting__c settingsObject = [select id, 
                                                               Name, 
                                                               Schedulable_Classes__c, 
                                                               Schedulable_Classes_with_ID__c 
                                                               FROM Apex_Job_Scheduler_Setting__c 
                                                               WHERE Running_User_Profile_Name__c =: currentUserPrf.Name];
            
            List<String> classwithIdList = new List<String>();
            
            if (settingsObject.Schedulable_Classes_with_ID__c != null & settingsObject.Schedulable_Classes_with_ID__c != '')
            {
            	classwithIdList = settingsObject.Schedulable_Classes_with_ID__c.split(',');
            }
            
            Map<String, String> existingClassMap = new Map<String, String>();
            if (settingsObject.Schedulable_Classes__c != null & settingsObject.Schedulable_Classes__c != '')
            {
            	List<String> classList = settingsObject.Schedulable_Classes__c.split(',');
                for(String clsName : classList)
                {
                    existingClassMap.put(clsName, clsName);
                }
            }
                        
            // CREATE MAP OF SCHEDULED CLASSES AS => CRON_TRIGGER_ID => CLASS_NAME
            if (!classwithIdList.isEmpty())
            {
                for (String s : classwithIdList)
                {
                    List<String> lst = new List<String>();
                    lst = s.split('=');
                    IdclassMap.put(lst[1], lst[0]);
                }
            }
            
            String idString = '';
            if(!IdclassMap.isEmpty())
            {
                for(String str : IdclassMap.keySet())
                {
                    if(idString == '')
                    {
                        idString = '\'' + str + '\'';
                    }
                    else {
                        idString += ',\'' + str + '\''; 
                    }
                }
            }
            
            system.debug('idString : '+idString);
            system.debug('IdclassMap.keys() : '+IdclassMap.keySet());
            schldClassDetails = new Map<String, Map<String, String>>();
            
            if (!classNamesSet.isEmpty())
            {
             
                // RETRIEVE ALL THE SCHEDULED JOBS FROM REMOTE ORG
				String sql = 'SELECT Id, CronJobDetail.Name, CronJobDetail.JobType, CronJobDetailId, NextFireTime, OwnerId FROM CronTrigger WHERE ID IN ( '+idString + ' ) ';
                
                Httprequest request = getHttpRequests(endPointUrl + '/services/Soap/c/36.0');
                httpresponse jobsResp = getHttpResponse(request, sessionId, sql);
                String resp= jobsResp.getBody();
                system.debug('resp : '+resp);
                
                if (!resp.containsignorecase('<soapenv:Fault><faultcode>'))
                {                    
                    Dom.XmlNode resultElmtPerm = jobsResp.getBodyDocument().getRootElement()
                        .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                        .getChildElement('queryResponse', 'urn:enterprise.soap.sforce.com')
                        .getChildElement('result', 'urn:enterprise.soap.sforce.com');
                    
                    if (resultElmtPerm != null) 
                    {
                        for (Dom.XMLNode child : resultElmtPerm.getChildElements()) 
                        {
                            
                            if (child.getName() == 'records' ) 
                            {
                                Map<String, String> innerMap = new Map<String, String>();
                                
                                for (Dom.XMLNode innerChild : child.getChildElements()) 
                                {

                                    if (innerChild.getName() != null && innerChild.getName() == 'Id') 
                                    {
                                        innerMap.put('Id', innerChild.getText());
                                    }
                                    
                                    if (innerChild.getName() != null && innerChild.getName() == 'CronJobDetailId') 
                                    {
                                        innerMap.put('CronJobDetailId', innerChild.getText());
                                    }
                                    
                                    if (innerChild.getName() != null && innerChild.getName() == 'NextFireTime') 
                                    {
                                        innerMap.put('NextFireTime', innerChild.getText());
                                    }
                                    
                                    if (innerChild.getName() != null && innerChild.getName() == 'OwnerId') 
                                    {
                                        innerMap.put('OwnerId', innerChild.getText());
                                    }
                                    
                                    if (innerChild.getName() != null && innerChild.getName() == 'CronJobDetail') 
                                    {
                                        for (Dom.XMLNode innerChild1 : innerChild.getChildElements()) 
                                        {
                                            
                                            if (innerChild1.getName() != null && innerChild1.getName() == 'JobType') 
                                            {
                                                innerMap.put('CronJobDetail JobType', innerChild1.getText());
                                            }
                                            
                                            if (innerChild1.getName() != null && innerChild1.getName() == 'Name') 
                                            {
                                                innerMap.put('CronJobDetail Name', innerChild1.getText());
                                            }
                                        }
                                    }
                                }

                                //system.debug('IdclassMap.get(innerMap.get(\'Id\')) : '+IdclassMap.get(innerMap.get('Id')));
                                if (IdclassMap.containsKey(innerMap.get('Id')) && existingClassMap.containsKey(IdclassMap.get(innerMap.get('Id'))) )
                                {
                                    schldClassDetails.put(innerMap.get('Id'), innerMap);
                                }
                            }
                        }
                        
                    }
                    
                }
            }
		}
        catch(Exception e)
        {
            system.debug('Exception found in retrieving scheduled jobs data : '+e + '. Line Number : '+e.getLineNumber());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,  'Exception found in retrieving scheduled jobs data : '+e + '. Line Number : '+e.getLineNumber()));
        }
        
        //system.debug('schldClassDetails : '+schldClassDetails);
        
        String runningUserName = '';
        //system.debug('usersMap size : '+usersMap.size());
        
        // CREATE COLLECTION TO SHOW SCHEDULED JOBS DATA ON VF PAGE
        schldJobsData = new List<jobData>();
        for (String cronTriggerId : schldClassDetails.keySet())
        {
            if (IdclassMap.containsKey(cronTriggerId))
            {
                Map<String, String> innerMap = schldClassDetails.get(cronTriggerId);
                
                jobData job = new jobData();
                job.jobId = innerMap.get('Id');
                job.ClassName = IdclassMap.get(cronTriggerId);
                if(innerMap.get('CronJobDetail JobType') == '7')
                {
                    job.JobType = 'Scheduled Apex';
                }
                job.JobName = innerMap.get('CronJobDetail Name');
                job.CreatedBy = innerMap.get('OwnerId');
                job.CronJobDetailId = innerMap.get('CronJobDetailId');
                job.NextFireTime = innerMap.get('NextFireTime');
                system.debug('OwnerId : '+innerMap.get('OwnerId') );
                if(usersMap.containsKey(innerMap.get('Id')))
                {
                    job.runningUserName = usersMap.get(innerMap.get('Id'));
                }
                else 
                {
                    job.runningUserName = '';
                }
                schldJobsData.add(job);
            }
        }
        
    }
       
     
    // METHOD TO SCHEDULE THE JOBS ON REMOTE ORGS
    public void scheduleJob()
    {
        if(jobName == NULL || jobName == '')
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Job Name cannot be NULL.'));
            return;
        }
        
        if(selectedClass == NULL || selectedClass == '--None--')
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Apex Class cannot be NULL.'));
            return;
        }
        
        String strCronX = myComponentController.strCronExpression;
        
        //	===================================================================        
        //		SECONDS, MINUTES, HOURS
        //	===================================================================
        if (myComponentController.strSelStartTime == '--None--')
        {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter the time.'));
            return;
        }
        
		//	===================================================================        
        //		DAY OF MONTH
        //	===================================================================
        myComponentController.strDoM = '*';
        
        if (!myComponentController.bByDayOfWeek)
        {
            if (myComponentController.bByOnDay)
            {
                myComponentController.strDoM = myComponentController.strSelDay;
            }
            else
            {
                myComponentController.strDoM = '?';
            }
		}        
        
        //	===================================================================        
        //		MONTH
        //	===================================================================
        myComponentController.strMonths = '*';
        myComponentController.strDoW = '?';
        
        if (!myComponentController.bByDayOfWeek)
        {
            if (!myComponentController.bByOnDay)
            {
                myComponentController.strDoW = myComponentController.strSelDayofWeek + myComponentController.strSelNthDay;
            }
        }
        
		//	===================================================================        
        //		DAY OF WEEK
        //	===================================================================
        if (myComponentController.bByDayOfWeek)
        {
            
            myComponentController.strDoW = '';
            myComponentController.strDoM = '?';
            
            if (myComponentController.bSunday)
            {
                myComponentController.strDoW += 'SUN,';
            }
            if (myComponentController.bMonday)
            {
                myComponentController.strDoW += 'MON,';
            }
            if (myComponentController.bTuesday)
            {
                myComponentController.strDoW += 'TUE,';
            }
            if (myComponentController.bWednesday)
            {
                myComponentController.strDoW += 'WED,';
            }
            if (myComponentController.bThursday)
            {
                myComponentController.strDoW += 'THU,';
            }
            if (myComponentController.bFriday)
            {
                myComponentController.strDoW += 'FRI,';
            }
            if (myComponentController.bSaturday)
            {
                myComponentController.strDoW += 'SAT,';
            }        
            
            if (myComponentController.strDoW != '')
            {
                myComponentController.strDoW = (myComponentController.strDoW.mid(0, myComponentController.strDoW.length() - 1));
                myComponentController.strDoM = '?';
            }
            else
            {
                myComponentController.strDoW = '*';
            }
            
        }
        
        //	===================================================================        
        //		YEAR  
        //	===================================================================
		myComponentController.strYears = '*';
        
        //	===================================================================        
        //		BUILD CRON EXPRESSION  
        //	===================================================================
        String pageCronExpr = myComponentController.strSelStartTime + ' ' + myComponentController.strDoM + ' ' + myComponentController.strMonths + ' ' + myComponentController.strDoW + ' ' + myComponentController.strYears; 
        system.debug('Cron Expression : '+pageCronExpr);
        
        if (!pageCronExpr.containsIgnoreCase('--NONE--') && pageCronExpr != '')
        {
            scheduleClasses(pageCronExpr);
            
            setClassOptsList();
        } 
        
    }
    
    
    // SCHEDULE SELECTED CLASS ON REMOTE ORG
    public void scheduleClasses(String cronString)
    {
        try 
        {
            // CREATE NEW HTTP REQUEST TO SCHEDULE JOB IN ORG  
            Httprequest request = getHttpRequests(endPointUrl + 'services/Soap/s/36.0');
            
            //system.debug('Before jobName : '+jobName+'*');
            jobName = jobName.trim();
            //system.debug('After jobName : '+jobName+'*');
            
            String apexString = selectedClass+' sch2 = new '+selectedClass+'();String sch = \''+cronString+'\'; Id jobId = system.schedule(\''+jobName+'\', sch, sch2);system.debug(\'=====jobId : \'+jobId+\'=====\');';
            
            request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:apex="http://soap.sforce.com/2006/08/apex"><soapenv:Header><apex:DebuggingHeader><apex:categories><apex:category>Apex_code</apex:category><apex:level>FINEST</apex:level></apex:categories><apex:debugLevel>DETAIL</apex:debugLevel></apex:DebuggingHeader><apex:SessionHeader><apex:sessionId>'+ sessionId +'</apex:sessionId></apex:SessionHeader></soapenv:Header><soapenv:Body><apex:executeAnonymous><apex:String>'+ apexString +'</apex:String></apex:executeAnonymous></soapenv:Body></soapenv:Envelope>');
            httpresponse schldResponse = (new Http()).send(request);
            string resp= schldResponse.getBody(); 
            //system.debug(' **** Response = ' + resp);
            
            // CHECK FOR FAULT  
            if (resp.containsignorecase('<soapenv:Fault><faultcode>'))
            {
                Dom.XmlNode resultElmt1 = schldResponse.getBodyDocument().getRootElement()
                    .getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/')
                    .getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                String faultcode = resultElmt1.getChildElement('faultcode', null).getText();
                String faultstring = resultElmt1.getChildElement('faultstring', null).getText();
                
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,  faultstring));
            }
            
            // CHECK IF SUCCESS == TRUE 
            if (resp.containsignorecase('<success>true</success>'))
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,  'Job scheduled succesfully.'));
                
                Dom.XmlNode resultElmt = schldResponse.getBodyDocument().getRootElement()
                    .getChildElement('Header', 'http://schemas.xmlsoap.org/soap/envelope/')
                    .getChildElement('DebuggingInfo', 'http://soap.sforce.com/2006/08/apex');
                
                String log = resultElmt.getChildElement('debugLog', 'http://soap.sforce.com/2006/08/apex').getText();
                List<String> logList = log.split('=====');
                String jobID = logList[3];
                jobID = jobID.replace('jobId : ', '');
                
                
                // UPDATE CUSTOM OBJECT WITH "APEX CLASS NAME_CRON TRIGGER ID"
                Apex_Job_Scheduler_Setting__c updateSettingsObj = [select id, 
                                                               Name, 
                                                               Schedulable_Classes__c, 
                                                               Schedulable_Classes_with_ID__c 
                                                               FROM Apex_Job_Scheduler_Setting__c 
                                                               WHERE Running_User_Profile_Name__c =: currentUserPrf.Name];
                
                
                if ( updateSettingsObj.Schedulable_Classes_with_ID__c != NULL && updateSettingsObj.Schedulable_Classes_with_ID__c != '' ) {
                    
                    updateSettingsObj.Schedulable_Classes_with_ID__c = updateSettingsObj.Schedulable_Classes_with_ID__c +','+ selectedClass + '=' + jobID ;
                }
                else {
                    updateSettingsObj.Schedulable_Classes_with_ID__c = selectedClass + '=' + jobID ;
                }
                
                try {
                    Database.update(updateSettingsObj);
                }
                catch(Exception e)
                {
                    system.debug('Found exception while updating custom object.'+e);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,  'Found exception while updating custom object.'+e));
                }
                
            }
            else if(resp.containsIgnoreCase('<compiled>false</compiled>'))
            {
                List<String> errors = resp.split('<compileProblem>');
                List<String> errors1 = errors[1].split('</compileProblem>');
                system.debug('Compiler Error : '+errors1[0]);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,  errors1[0]));
            }
            else if (resp.containsignorecase('<success>false</success'))
            {
                List<String> errors = resp.split('<exceptionMessage>');
                List<String> errors1 = errors[1].split('</exceptionMessage>');
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,  errors1[0]));
            }
            
        }
        catch (Exception e) 
        {
            system.debug('Exception occured at ' + e.getlinenumber() + '\n\n' + e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,  + e.getMessage()));
        }
    }
    
    
	// DELETE SCHEDULED JOBS
    public void deleteJobs()
    {
        
        Map<String, String> delJobIdMap = new Map<String, String>();

        Apex_Job_Scheduler_Setting__c updateSettingsObj = [select id, 
                                                               Name, 
                                                               Schedulable_Classes__c, 
                                                               Schedulable_Classes_with_ID__c 
                                                               FROM Apex_Job_Scheduler_Setting__c 
                                                               WHERE Running_User_Profile_Name__c =: currentUserPrf.Name];
        List<String> clswithIdList = new List<String>();
        if(updateSettingsObj.Schedulable_Classes_with_ID__c != NULL && updateSettingsObj.Schedulable_Classes_with_ID__c != '')
        {
        	clswithIdList = updateSettingsObj.Schedulable_Classes_with_ID__c.split(',');
        }
        Boolean isDelete = false;
        String apexString = '';
        
        for (jobData job : schldJobsData)
        {
            if (job.check == true)
            {
                delJobIdMap.put(job.jobId, job.jobId);
                if (apexString == '')
                {
                	apexString = 'System.abortJob(\''+ job.jobId +'\');';
                }
                else
                {
                    apexString = apexString + 'System.abortJob(\''+ job.jobId +'\');';
                }
                isDelete = true;
            }
        }
 
        if (isDelete)
        {
            try 
            {
                // CREATE NEW HTTP REQUEST TO DELETE JOBS
                Httprequest request = getHttpRequests(endPointUrl+'services/Soap/s/36.0');

                request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:apex="http://soap.sforce.com/2006/08/apex"><soapenv:Header><apex:DebuggingHeader><apex:categories><apex:category>Apex_code</apex:category><apex:level>FINEST</apex:level></apex:categories><apex:debugLevel>DETAIL</apex:debugLevel></apex:DebuggingHeader><apex:SessionHeader><apex:sessionId>'+ sessionId +'</apex:sessionId></apex:SessionHeader></soapenv:Header><soapenv:Body><apex:executeAnonymous><apex:String>'+ apexString +'</apex:String></apex:executeAnonymous></soapenv:Body></soapenv:Envelope>');
                httpresponse deleteResponse = (new Http()).send(request);
                string resp= deleteResponse.getBody(); 
                system.debug('Delete response : '+resp);

                // CHECK FOR FAULT 
                if (resp.containsignorecase('<soapenv:Fault><faultcode>'))
                {
                    Dom.XmlNode resultElmt1 = deleteResponse.getBodyDocument().getRootElement()
                        .getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/')
                        .getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                    String faultcode = resultElmt1.getChildElement('faultcode', null).getText();
                    String faultstring = resultElmt1.getChildElement('faultstring', null).getText();
                    
                    system.debug(' **** faultstring = ' + faultstring);
                }
                else if (resp.containsignorecase('<success>true</success>'))
                { 
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,  'Jobs deleted succesfully.'));
                    Dom.XmlNode resultElmt = deleteResponse.getBodyDocument().getRootElement()
                        .getChildElement('Header', 'http://schemas.xmlsoap.org/soap/envelope');

                    Map<String, String> IdclsMap = new Map<String, String>();
                    
                    Boolean isUpdatable = false;
                    for (String s : clswithIdList)
                    {
                        List<String> lst = new List<String>();
                        lst = s.split('=');
                        
                        if (delJobIdMap.containsKey(lst[1]))
                        {
                            isUpdatable = true;
                            delJobIdMap.remove(lst[1]);
                        }
                        else 
                        {
                            IdclsMap.put(lst[1], lst[0]);
                        }
                    }
                    
                    // CODE TO UPDATE OTHER Apex_Job_Scheduler_Setting__c OBJECT AFTER JOB IS DELETED
                    if(delJobIdMap.size() > 0)
                    {
                        UpdateSettingsObj(delJobIdMap);
                    }
                    system.debug('IdclsMap : '+IdclsMap);
                    
                    if (isUpdatable)
                    {
                        String clsWithIdString  = '';
                        for(String triggerId : IdclsMap.keyset())
                        {
                            if (clsWithIdString == '')
                            {
                                clsWithIdString = IdclsMap.get(triggerId) + '=' + triggerId ;
                            }
                            else
                            {
                                clsWithIdString += ',' + IdclsMap.get(triggerId) + '=' +triggerId;
                            }
                        }
                        updateSettingsObj.Schedulable_Classes_with_ID__c = clsWithIdString;
                        
                        //system.debug('updateSettingsObj.Schedulable_Classes_with_ID__c : '+updateSettingsObj.Schedulable_Classes_with_ID__c);
                        
                        // DELETE CRONTRIGGER ID FROM CUSTOM OBJECT
                        try 
                        {
                            Database.update(updateSettingsObj);
                            
                            setClassOptsList();
                        }
                        catch (Exception e)
                        {
                            system.debug('Found exception while updating Apex_Job_Scheduler_Setting__c object...'+e+ '\nLine Number : '+e.getLineNumber());
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error while removing crontrigger id from custom object. '+ e));
                        }
                    }
                }
                
            }
            catch(Exception e)
            {
                system.debug('Exception while deleting scheduled jobs : '+e + '\nLine Number : '+e.getLineNumber());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exception found while deleting scheduled jobs. '+ e));
            }
        }
        else 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, 'Select atleast 1 job to delete.'));
        }
    }
    
    
    // METHOS TO REMOVE ENTRY OF SCHEDUELD JOB OF OTHER USER 
    private void UpdateSettingsObj(Map<String, String> deljobIdMap)
    {
        List<String> uNameList = new List<String>();
        Map<String, List<String>> uNametoCronIdMap = new Map<String, List<String>>();
        
        system.debug('deljobIdMap : '+deljobIdMap);
        
        for(string triggerId : deljobIdMap.keyset())
        {
            uNameList.add(usersMap.get(triggerId));
            //system.debug('usersMap.get(triggerId) : '+usersMap.get(triggerId));
            
            if(!uNametoCronIdMap.containsKey(usersMap.get(triggerId)))
            {
                List<String> idList = new List<String>();
                idList.add(triggerId);
                uNametoCronIdMap.put(usersMap.get(triggerId), idList);
            }
            else 
            {
                List<String> idList = new List<String>();
                idList = uNametoCronIdMap.get(usersMap.get(triggerId));
                idList.add(triggerId);
                uNametoCronIdMap.put(usersMap.get(triggerId), idList);
			}
		}
        
        if(!uNameList.isEmpty())
        {
            List<Apex_Job_Scheduler_Setting__c> objList = new List<Apex_Job_Scheduler_Setting__c>([select id, Name, User_Name__c,
                                                                                                             Schedulable_Classes_with_ID__c 
                                                                                                             FROM Apex_Job_Scheduler_Setting__c 
                                                                                                             WHERE User_Name__c IN: uNameList]);
            system.debug('objList : '+objList);
            
            List<Apex_Job_Scheduler_Setting__c> updateSettingsObjList = new List<Apex_Job_Scheduler_Setting__c>();
            for(Apex_Job_Scheduler_Setting__c updateSettingsObj : objList)
            {
                
                if(updateSettingsObj.Schedulable_Classes_with_ID__c != NULL && updateSettingsObj.Schedulable_Classes_with_ID__c != '')
                {
                    List<String> clswithIdList = new List<String>();
                    clswithIdList = updateSettingsObj.Schedulable_Classes_with_ID__c.split(',');
                    
                    Map<String, String> IdclsMap = new Map<String, String>();
                    
                    for (String s : clswithIdList)
                    {
                        List<String> lst = new List<String>();
                        lst = s.split('=');
                        
                        if (deljobIdMap.containsKey(lst[1]))
                        {
                            deljobIdMap.remove(lst[1]);
                        }
                        else 
                        {
                            IdclsMap.put(lst[1], lst[0]);
                        }
                    }
                    
                    //system.debug('IdclsMap : '+IdclsMap);
                    
                    String clsWithIdString  = '';
                    for(String triggerId : IdclsMap.keyset())
                    {
                        if (clsWithIdString == '')
                        {
                            clsWithIdString = IdclsMap.get(triggerId) + '=' + triggerId ;
                        }
                        else
                        {
                            clsWithIdString += ',' + IdclsMap.get(triggerId) + '=' +triggerId;
                        }
                    }
                    updateSettingsObj.Schedulable_Classes_with_ID__c = clsWithIdString;
                    
                    system.debug(updateSettingsObj.User_Name__c +' : updateSettingsObj.Schedulable_Classes_with_ID__c : '+updateSettingsObj.Schedulable_Classes_with_ID__c);
                    
                    updateSettingsObjList.add(updateSettingsObj);
                }
			}
            
            if(!updateSettingsObjList.isEmpty())
            {
                try 
                {
                    Database.update(updateSettingsObjList);
                    
                    setClassOptsList();
                }
                catch (Exception e)
                {
                    system.debug('Found exception while updating Apex_Job_Scheduler_Setting__c object...'+ '\nLine Number : '+e.getLineNumber());
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error while removing crontrigger id from custom object. '+ e));
                }
            }
		}
    }
    
    
    // CREATE CLASS NAMES PICKLIST
    public void setClassOptsList()
    {
        IdclassMap = new Map<String, String>();
        
        // RETRIEVE DATA FROM CUSTOM OBJECT - Apex_Job_Scheduler_Setting__c 
        List<Apex_Job_Scheduler_Setting__c> schldrSettingsList = new List<Apex_Job_Scheduler_Setting__c>(
            [SELECT Id, 
             Name, 
             Endpoint__c,
             Context_Username__c, 
             Context_User_Password__c, 
             Context_User_Security_Token__c, 
             Running_User_Profile_Name__c, 
             Schedulable_Classes__c, 
             Environment__c, 
             User_Name__c, 
             Schedulable_Classes_with_ID__c 
             FROM Apex_Job_Scheduler_Setting__c ]);

        Map<String, String> allScheduledClasses = new Map<String, String>();
        Map<String, String> thiObjSchldClasses = new Map<String, String>();
        
		for(Apex_Job_Scheduler_Setting__c a :schldrSettingsList)
        {
            if(a.Running_User_Profile_Name__c == currentUserPrf.Name)
            {
                settingsObj = a;
			}
            if(a.Schedulable_Classes_with_ID__c != '' && a.Schedulable_Classes_with_ID__c != NULL)
            {
                List<String> clswthIdLIst = new List<String>();
                clswthIdLIst = a.Schedulable_Classes_with_ID__c.split(',');
                for(String s : clswthIdLIst)
                {
                    List<String> clsList = new List<String>();
                    clsList = s.split('=');
                    allScheduledClasses.put(clsList[0], clsList[0]);
                    IdclassMap.put(clsList[1], clsList[0]);
                    
                    usersMap.put(clsList[1], a.User_Name__c);
                }
            }
        }
        
        system.debug('usersMap : '+usersMap);
        
        List<String> classList = settingsObj.Schedulable_Classes__c.split(',');
        classOptions = new List<SelectOption>();
        classOptions.add(new SelectOption('','--None--'));
        
        for(String className : classList)
        {
            if(!allScheduledClasses.containsKey(className))
            {
                classOptions.add(new SelectOption(className,className));
            }
        }
    }

     
    public override void setComponentController(AH_CronBuilder_ctlr_Base compController) 
    {
        myComponentController = (AH_CronBuilder_ctlr)compController;
    }
    
    public override AH_CronBuilder_ctlr_Base getMyComponentController() 
    {
        return myComponentController;
    }
    
    public PageReference callComponentControllerMethod() 
    {
        myComponentController.generateCronExpression(); 
        return null;
    }
    
    
    //==============================================================================================================
    //		UTILITY FUNCTIONS
    //==============================================================================================================

    // CREATE HTTP REQUEST
    public static httprequest getHttpRequests(string SERVER_URL)
    {
        Httprequest request = new HttpRequest();  // + '/services/Soap/c/36.0'
        request.setEndpoint(SERVER_URL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        request.setTimeout(120000);
        return request;
    }    
    
    // SEND HTTP_REQUEST & GET HTTP RESPONSE
    public static HttpResponse getHttpResponse (Httprequest request, String SESSION_ID, String sql)
    {
        
        HttpResponse response = new HttpResponse();
        try 
        {
            request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">'+
                            '<soapenv:Header><urn:QueryOptions><urn:batchSize>2</urn:batchSize></urn:QueryOptions>'+
                            '<urn:SessionHeader><urn:sessionId>'+SESSION_ID+'</urn:sessionId></urn:SessionHeader>'+
                            '</soapenv:Header><soapenv:Body>'+
                            '<urn:query><urn:queryString>'+sql+'</urn:queryString>'+
                            '</urn:query></soapenv:Body></soapenv:Envelope>');      
            
            response = (new Http()).send(request);
        } 
        catch(Exception e) 
        {
            System.debug('Exception captured in getHttpRespose : '+e.getlinenumber()+'\n\n'+e.getMessage());
        }
        return response;
    }
    

    //==============================================================================================================
    //		WRAPPER CLASSES
    //==============================================================================================================
    
    // WRAPPER CLASS TO HOLD SCHEDULED JOBS INFORMATION
    public class jobData 
    {        
        public Boolean check {get; set;}
        public String jobId {get; set;}
        public String ClassName {get; set;}
        public String JobType {get; set;}
        public String status {get; set;}
        public String CreatedBy {get; set;}
        public String JobName {get; set;}
        public String CronJobDetailId {get; set;}
        public String NextFireTime {get; set;}
        public String runningUserName {get; set;}
        
        public jobData()
        {
            check = false;
        }
    } 
    
}