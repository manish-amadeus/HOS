/**************************************************************************************** 
Name            : NITrustStatus Class 
Author          : Sean Harris
Created Date    : 05/07/2013
Last Mod Date   : 08/31/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-007128 
Description     : Extension controller for NITrustStatus page
                : Udated on 5/15/2017 per NICC-022330 
                :  
******************************************************************************************/
public class NITrustStatus 
{

    public String currentTime{ get; set; } 						// Variable to hold current time in specific format
    public Boolean showCalendar{ get; set; } 					// Variable to show/hide calendar
    public List<SelectOption> monthsOptionList{ get; set; } 	// Variable to hold values of all months used on calendar
    public String selectedMonth{ get; set; } 					// Variable to hold value of selected month on calendar
    public String platformId{ get; set; } 						// Variable to hold value of platform Id while displaying individial platform status
    //public String selectedDate{ get; set; }  					// Variable to hold value of selected date
    public Boolean showHistory{ get; set; }  					// Variable to show/hide history panel
    public Boolean showStatus{ get; set; } 						// Variable to show/hide all platforms status
    public List<SelectOption> platformSOList{ get; set; } 		// List variable to hold value of all platforms
    public Boolean displayPrev{ get; set; }						// Variable to display previous button on calendar
    public Boolean displayNext{ get; set; }						// Variable to display next button on calendar
    
    public Months monthlyData{ get; set; }
    public List<PlatformDetails> platformsList{ get; set; }	
    
    // HOLDS THE PLATFORM ID TO SEND TO VF COMPONENT ON PLATFORM SELECTION
    public String selectedPlatformId { get; set; }
    
    public DateTime currentDatetime {get; set; }
    public String minus_6_hours_time {get; set; }
    public String minus_12_hours_time {get; set; }
    public String minus_18_hours_time {get; set; } 
    public String minus_24_hours_time1 {get; set; }
    public static String currentDatetimeStr {get; set; }
    public static DateTime minus_24_hours_time {get; set; }
 
    
    // CONSTRUCTOR METHOD
    public NITrustStatus(ApexPages.StandardController controller)
    {
        dayMinus = 0;
        currentDatetime = system.now();
        selectedPlatformId = NULL;
        
        platformsList = new List<PlatformDetails>();
        platformSOList = new List<SelectOption>();
        showPlatformStatus();
    }

    private Boolean flagForRefresh;
    // @author Prashant Wayal
    // @description - METHOD TO SHOW ALL PLATFORM STATUSES
    public pageReference showPlatformStatus()
    {
        flagForRefresh = false;
        system.debug('Before currentTime : '+currentTime);
/*        Datetime oldDtTime;
        if(currentTime != NULL)
        {
            oldDtTime = Datetime.valueOfGMT(currentTime);
        }
*/        
        currentTime = System.now().formatGMT('MMM d yyyy HH:mm');
        system.debug('After currentTime : '+currentTime);
/*        
        if(oldDtTime != NULL && oldDtTime < system.now())
        {
            flagForRefresh = true;
        }
*/        
        Set<Id> platformIdSet = new Set<Id>();
        
        // THIS LOOP IS ADDED BCZ WHEN USER CLICKS ON REFRESH BUTTON....currentDatetime WAS NULL.....THIS LOOP SETS THE VALUE
        if(currentDatetime == NULL)
        {
            currentDatetime = system.now() - dayMinus;
            
        }
        if(dayMinus>0){
            currentDatetime = system.now() - dayMinus;
        }
        else{
            currentDatetime = system.now();
        }
		setDateTime(currentDatetime);

        
        // ADD DEFAULT PLATFORM OPTION
        platformSOList.add(new SelectOption('all', 'All'));

        // GET ALL PLATFORMS AND ADD TO PLATFORMS LIST
        for(NI_Trust__c platform: [Select Id, Platform_Name_External__c from NI_Trust__c WHERE IsActive__c = true]) //WHERE CLAUSE ADDED PER NICC-022330
        {
            platformIdSet.add(platform.Id);
            platformSOList.add(new SelectOption(platform.Id, platform.Platform_Name_External__c ));
        }
        
        // INITIALISE CLASS VARIABLE TO DEFAULT VALUES
        platformId = '';
        platformsList = showPlatformStatus(platformIdSet);
        showCalendar = false;
        showHistory = false;
        showStatus = true;
        monthlyData = null;
        selectedMonth = '';
        platformId = '';

        return null;
    }

    
    // STATIC VARIABLES TO HOLD THE MONTHS AND IT'S NUMBER
    public static Map<String, Integer> monthAndNumberMap = new Map<String, Integer>();
    public static Map<Integer, String> monthNumMonthNameMap = new Map<Integer, String>();
    public static Map<String, String> monthsMap
    {
        get {
            
            Map<String, String> monthsNumberMap = new Map<String, String>();
            
            // 2021-01-07 (START)
            List<String> monthsList = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'};
                
            // PREPARE MONTHS FOR NEXT 12 MONTHS
            Integer iIndx = 0;
            Integer iStartingMonth = Date.today().addMonths(-3).month();
            
            for (Integer i = iStartingMonth; i < (iStartingMonth + 12); i++)
            {
                monthsNumberMap.put('Month_' + Date.today().year() + '_' + monthsList[i - 1], monthsList[i - 1]);
                monthAndNumberMap.put(monthsList[i - 1], iIndx);
                monthNumMonthNameMap.put(iIndx, monthsList[i - 1]); 
                iIndx++;
            }  
          
/*            
            List<String> monthsList = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'};
                
            // PREPARE MONTHS FOR NEXT 12 MONTHS
            Integer currentMonth = Date.today().month();
            for(Integer i=currentMonth-3; i<=12; i++)
            {
                monthsNumberMap.put('Month_'+Date.today().year()+'_'+monthsList[i-1], monthsList[i-1]);
                monthAndNumberMap.put(monthsList[i-1], i);
                monthNumMonthNameMap.put(i, monthsList[i-1]);
            }
            for(Integer i=1; i<currentMonth-3; i++)
            {
                monthsNumberMap.put('Month_'+(Date.today().year()+1)+'_'+monthsList[i-1], monthsList[i-1]);
                monthAndNumberMap.put(monthsList[i-1], i);
                monthNumMonthNameMap.put(i, monthsList[i-1]);
            }
*/            
            
            // 2021-01-07 (END)           
            
            return monthsNumberMap;
            
        }
        
    }
    

    // @author Prashant Wayal
    // @description - METHOD TO SHOW DETAILS OF SELECTED PLATFORM FOR LAST 24 HOURS ALONG WITHT CALENDAR
    public PageReference showPlatformDetails()
    {
        system.debug('** ENTERING showPlatformDetails METHOD...');
        system.debug('platformId : '+platformId);
        if(flag == false)
        {
            currentDatetime = system.now();
        	
            dayMinus = 0;
            dayPlus = 0;
        }
        setDateTime(currentDatetime);
        
        //update current time from maintenance calendar
        currentTime = system.now().formatGMT('MMM d yyyy HH:mm');
        
        // INITIALISE VARIABLE
        monthlyData = new Months();
        
        // GET RID OF THE SELECTED PLATFORM
        platformId = ApexPages.currentPage().getParameters().get('platformId');
        
        if(platformId != NULL && platformId != '')
        {
        	selectedPlatformId = platformId;
        }
        else 
        {
            selectedPlatformId = 'all';
        }
        system.debug('selectedPlatformId : '+selectedPlatformId);
        
        // PREPARE DROPDOWN LIST FOR NEXT 12 MONTHS LIST TO SHOW ON CALENDAR
        monthsOptionList = new List<SelectOption>();
        for(String s: monthsMap.keySet())
        {
            monthsOptionList.add(new SelectOption(s, monthsMap.get(s)));
        }
        
        // SET VALUE OF CURRENT MONTH AS SELCTED MONTH
        selectedMonth = monthsOptionList.get(3).getValue();
        
        // CLEAR UNUSED VARIABLES TO REDUCE VIEW-STATE SIZE AND ADD NEW VALUES 
        platformsList.clear();
        platformsList = showPlatformStatus(new Set<Id>{platformId});
        
        // INITIALIZE VAIRABLES WITH NEW VALUES
        showCalendar = true;
        showHistory = false;
        showStatus = false;
        displayPrev = true;
        displayNext = true;
        
        // UNCOMMENTED BY SHASHIKANT ON 05/22/2020 - TO SHOW THE CALENDAR ON PLATFORM SELECTION
        monthlyData = generateMonthlyData(selectedMonth, platformId);
        
        return null;
    }
    
    // @author Prashant Wayal
    // @description - METHOD TO SHOW THE STATUS OF ALL PLATFORMS AVAILABLE IN ORG
    public List<PlatformDetails> showPlatformStatus(Set<Id> platformIdSet)
    {
        
        system.debug('ENTERING IN showPlatformStatus METHOD.... platformId : '+platformId);        

        List<PlatformDetails> platformsList = new List<PlatformDetails>();
               
        // GET ALL PLATFORMS AND RELATED INCIDENCES FOR PAST 24 HOURS       
        for(NI_Trust__c platform: [select Id, Platform_Name_External__c, 
                                   ( 
                                       SELECT ID, 
                                       Name,
                                       AH_Trust_Incident__c, 
                                       AH_Trust_Incident__r.Name,
                                       AH_Trust_Incident__r.RecordType.Name,
                                       AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c, 
                                       AH_Trust_Incident__r.Outage_End_Date_Time__c, 
                                       AH_Trust_Incident__r.Public_Details__c, 
                                       AH_Trust_Incident__r.Resolution__c, 
                                       AH_Trust_Incident__r.Root_Cause_Analysis__c, 
                                       AH_Trust_Incident__r.Outage_Start_Date_Time__c, 
                                       AH_Trust_Incident__r.Incident_Start_Date_Time__c, 
                                       AH_Trust_Incident__r.Incident_End_Date_Time__c, 
                                       AH_Trust_Incident__r.Total_Duration__c, 
                                       AH_Trust_Incident__r.Type__c, 
                                       AH_Trust_Incident__r.Editable_Duration__c, 
                                       AH_Trust_Incident__r.Notification_Heading__c, 
                                       AH_Trust_Incident__r.Severity__c, 
                                       AH_Trust_Incident__r.HotSOS_Application__c, 
                                       AH_Trust_Incident__r.Case_Number__c, 
                                       AH_Trust_Incident__r.Estimated_Duration__c, 
                                       AH_Trust_Incident__r.Incident_Description__c, 
                                       AH_Trust_Incident__r.Customer_Impact__c, 
                                       AH_Trust_Incident__r.Description__c, 
                                       AH_Trust_Incident__r.Workaround_Information__c, 
                                       AH_Trust_Incident__r.Amadeus_Investigative_Action__c 
                                       FROM AH_Trusts_to_Incidents__r 
                                       WHERE AH_Trust_Incident__r.Make_Public__c = TRUE 
                                   ) 
                                   
                                   from NI_Trust__c where Id IN: platformIdSet ORDER BY Sort_Order__c 
                                  ])
        {
            platformsList.add(createPlatformDetailsObject(platform));
        }

        return platformsList;
    }

    Map<String, Map<String, String>> platformToOngoingStatusMap = new Map<String, Map<String, String>>();
    
    // @author Prashant Wayal     
    // @description - METHOD TO CREATE THE PLATFORM DETAILS OBJECT BASED ON PLATFORM INFORMATION
    public PlatformDetails createPlatformDetailsObject(NI_Trust__c platform)
    {
        
        system.debug('** ENTERING IN createPlatformDetailsObject METHOD ..... currentDatetime : '+currentDatetime);
        DateTime past24Hours = currentDatetime.addHours(-24);

        // DEFAULT PLATFORM STATUS IS AVAILABLE
        String currentStatusCSS = 'platform-status-up';
        
        // CREATE platformDetails OBJECT
        PlatformDetails platformObj = new PlatformDetails();
        
        // SET VARIABLES VALUES
        platformObj.platformName = platform.Platform_Name_External__c;
        platformObj.platformId = platform.Id;
        
        // CREATE LIST FOR ALL INCIDENCES FOR SPECIFIC PLATFORM
        List<IncidenceDetails> incidenceList = new List<IncidenceDetails>();
        
        Boolean isOngoing = false;
        
        // ITERATE OVER ALL THE INCIDENCES 
        // ADDED BY SHASHIKANT ON - 01/15/2020
        for(AH_Trust_to_Incident__c juncObj : platform.AH_Trusts_to_Incidents__r)
        {
            system.debug('juncObj.AH_Trust_Incident__r.Type__c : '+juncObj.AH_Trust_Incident__r.Type__c);
            String externalPlatformName = juncObj.AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c;
            
            Datetime stDtTm1 = getDatetime(juncObj.AH_Trust_Incident__r.Incident_Start_Date_Time__c);
            String stDtTmie_GMT = stDtTm1.formatGMT('yyyy-MM-dd HH:mm:ss');
            Datetime stDtTime = Datetime.valueOfGMT(stDtTmie_GMT);
            
            Boolean isOngoingIncidence = false;
            
            Datetime endDtTime = NULL;
            
            if (juncObj.AH_Trust_Incident__r.Incident_End_Date_Time__c == NULL && stDtTime <= currentDatetime)
            {
                endDtTime = currentDatetime;
                isOngoingIncidence = true;
                isOngoing = true;
            }
            
            if (juncObj.AH_Trust_Incident__r.Incident_End_Date_Time__c != NULL){    
    
                Datetime endDtTm1 = getDatetime(juncObj.AH_Trust_Incident__r.Incident_End_Date_Time__c);
                String endDtTmie_GMT = endDtTm1.formatGMT('yyyy-MM-dd HH:mm:ss');
                endDtTime = Datetime.valueOfGMT(endDtTmie_GMT);
                if(endDtTime >= currentDateTime && stDtTime <= currentDatetime){
                    isOngoing = true;
                }
            } 
    
            if ( (stDtTime > past24Hours && stDtTime <= currentDatetime ) || (endDtTime > past24Hours || endDtTime <= currentDatetime ))
            {
		
                // CHECK THE CURRENT STATUS OF PLATFORM AND SET THE CSS CLASS ACCORDINGLY
                // COMMNETED ON 08/28/2020
                // if((stDtTime >= past24Hours && stDtTime <= currentDatetime ) || (endDtTime >= past24Hours && endDtTime <= currentDatetime) 
                //  || stDtTime < past24Hours &&  endDtTime > currentDatetime)
                if(isOngoing && endDtTime >= currentDateTime
                  && stDtTime <= currentDatetime )
                { 
                    currentStatusCSS = platformStatusMap.get(juncObj.AH_Trust_Incident__r.Type__c);
					system.debug(platformObj.platformId+' : currentStatusCSS : '+currentStatusCSS);
                }
				
                // ADD incidencOject IN LIST
                if( juncObj.AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c != NULL && juncObj.AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c != '')
                {
                    
                    List<String> names = juncObj.AH_Trust_Incident__r.External_Platform_Name_HIDDEN__c.split(',');
                    for(String name : names)
                    {
                        Pattern MyPattern = Pattern.compile('(.*?)_(.*?)$');
                        Matcher MyMatcher = MyPattern.matcher(name);
                        
                        if (MyMatcher.matches()  && MyMatcher.group(1) == platform.id && MyMatcher.group(2) == platform.Platform_Name_External__c)
                        {
                            String matchedString = MyMatcher.group(2);
                            incidenceList.add(createIncidenceDetailsObject(juncObj.AH_Trust_Incident__r, matchedString, String.valueOf(platform.id), stDtTime, endDtTime, isOngoingIncidence));
                        }
                    }
                }
            }
        }
        
        if(!platformToOngoingStatusMap.containsKey(platformObj.platformId))
        {
			Map<String, String> innerMap = new Map<String, String>();
            if(isOngoing == true)
            {
                innerMap.put('isOngoingInc', 'true');
            }
            else
            {
                innerMap.put('isOngoingInc', 'false');
            }
            
            innerMap.put('statusClass', currentStatusCSS);
            platformToOngoingStatusMap.put(platformObj.platformId, innerMap);
        }
        
        if(platformToOngoingStatusMap.containsKey(platformObj.platformId))
        {
            if(platformToOngoingStatusMap.get(platformObj.platformId).get('isOngoingInc') == 'true')
            {   	
                platformObj.hasOngoingIncidence = true;
            }
            else 
            {
                platformObj.hasOngoingIncidence = false;
            }
            platformObj.statusClass = platformToOngoingStatusMap.get(platformObj.platformId).get('statusClass');
        }
        
        // INITIALISE OTHER MEMBER VARIABLES
        platformObj.incidenceList = incidenceList;
        
        system.debug('platformToOngoingStatusMap : '+platformToOngoingStatusMap);
        
        //RETURN platformDetails OBJECT 
        return platformObj;
    }
    
    
    // @author Prashant Wayal
    // @description - METHOD TO CREATE THE incidenceDetails OBJECT FOR PLATFORM
    public IncidenceDetails createIncidenceDetailsObject(NI_Trust_Outage__c incident, String externalPlatformName, String platformId, Datetime stDtTime, Datetime endDtTime, Boolean isOngoingInc)
    {        
        // CREATE NEW IncidenceDetails OBJECT AND INITIALISE MEMBER VARIABLES
        IncidenceDetails incidence = new IncidenceDetails();
        incidence.incidenceDuration = incident.Total_Duration__c;
                
        // GET START TIME AND END TIME
        incidence.incidenceStartDate = stDtTime.format('h:mm z, MMMM d');
        incidence.incidenceEndDate = '';
        if (endDtTime != NULL)
        {
            incidence.incidenceEndDate = endDtTime.format('h:mm z, MMMM d');
        }
        
        incidence.incidenceSolution = incident.Resolution__c;
        incidence.incidenceType = incident.Type__c;
        incidence.cssClass = incidenceTypeMap.get(incident.Type__c);
        incidence.NotificationHeading = incident.Notification_Heading__c;
        incidence.Severity = incident.Severity__c;
        incidence.HotSOSApplication = incident.HotSOS_Application__c;
        incidence.CaseNumber = incident.Case_Number__c;
        incidence.startDtTime = stDtTime.formatGMT('yyyy-MM-dd HH:mm:ss')+ ' GMT';
        incidence.endDtTime = NULL;
        if (endDtTime != NULL)
        {
            incidence.endDtTime = endDtTime.formatGMT('yyyy-MM-dd HH:mm:ss');
        }
        
        incidence.EstimatedDuration = String.valueOf(incident.Estimated_Duration__c);
        incidence.IncidentDescription = incident.Incident_Description__c;
        incidence.CustomerImpact = incident.Customer_Impact__c;
        incidence.WorkaroundInformation = incident.Workaround_Information__c;
        incidence.AmadeusInvestigativeAction = incident.Amadeus_Investigative_Action__c;
        incidence.EditableDuration = String.valueOf(incident.Editable_Duration__c);
        
        // COMMENTED -> External_Platform_Name__c FIELD 
        //incidence.platformName = incident.External_Platform_Name__c;                          
        incidence.platformName = externalPlatformName;
                
        incidence.incidenceName = (incident.Description__c != null)?(' - '+incident.Description__c):'';
        incidence.rootCause = incident.Root_Cause_Analysis__c;
        incidence.RecordTypeName = incident.RecordType.Name;
        
        externalPlatformName = externalPlatformName.replace(' ', '_');
        externalPlatformName = externalPlatformName.replace('(', '');
        externalPlatformName = externalPlatformName.replace(')', '');
        externalPlatformName = externalPlatformName.replace('\'', '');
        
        incidence.incId = 'inc_'+ incident.Id +'_'+ platformId +'_'+ externalPlatformName;
        incidence.popupDivId = 'popup_'+ incident.Id +'_'+ platformId +'_'+ externalPlatformName;

        incidence.isOngoing = isOngoingInc;
        
        DateTime past24Hours = currentDatetime - 1;
        
        Datetime now = currentDatetime;
        
        incidence.left = null;
        incidence.right = null; 
        incidence.width = null;
        
        //system.debug('past24Hours : '+past24Hours+' .... now : '+now);
        //system.debug('stDtTime : '+ stDtTime +' .... endDtTime : '+endDtTime);
        
        //Boolean flagLoop_3 = false;
        //Boolean flagLoop_4 = false;
        
        // START TIME & END TIME FALLS WITHIN PAST 24 HOURS
        //if ( stDtTime > past24Hours && stDtTime <= now   &&   endDtTime < now && endDtTime > past24Hours)
        if ( stDtTime > past24Hours && stDtTime <= now   &&   endDtTime <= now && endDtTime > past24Hours)
        {
            system.debug('1...START TIME & END TIME FALLS WITHIN PAST 24 HOURS : '+stDtTime + ' =====> ' + endDtTime);
            
            incidence.left = calculatePercentage(past24Hours, stDtTime);
            incidence.width = calculatePercentage(stDtTime, endDtTime);
            incidence.right = 0.0; 
        }
        // START TIME & END TIME DON'T FALL WITHIN PAST 24 HOURS
        else if (stDtTime < past24Hours && endDtTime > now)
        {
            system.debug('2...START TIME & END TIME DONT FALL WITHIN PAST 24 HOURS : '+stDtTime + ' =====> ' + endDtTime);
            incidence.left = 0.0;
            incidence.width = calculatePercentage(past24Hours, now);
            incidence.right = 0.0; 
        }
        // START TIME FALLS WITHIN PAST 24 HOURS BUT END TIME DON'T
        else if (stDtTime > past24Hours && stDtTime < now && endDtTime > now)
        {
            system.debug('3...START TIME FALLS WITHIN PAST 24 HOURS BUT END TIME DONT : '+stDtTime + ' =====> ' + endDtTime);
            system.debug('past24Hours : '+past24Hours+' ======= now : '+now);
            incidence.left = calculatePercentage(past24Hours, stDtTime);
            incidence.width = calculatePercentage(stDtTime, now);
            incidence.right = 0.0; 
            
            //flagLoop_3 = true;
                
        }
        // END TIME FALLS WITHIN PAST 24 HOURS BUT START TIME DON'T
        //else if (stDtTime < past24Hours && endDtTime > past24Hours && endDtTime < now )
        else if (stDtTime < past24Hours && endDtTime > past24Hours && endDtTime <= now)
        {
            system.debug('4...END TIME FALLS WITHIN PAST 24 HOURS BUT START TIME DONT : '+stDtTime + ' =====> ' + endDtTime);
            incidence.left = 0.0;
            incidence.width = calculatePercentage(past24Hours, endDtTime);
            incidence.right = calculatePercentage(endDtTime,now);
            
            //flagLoop_4 = true;
        }
        
        system.debug('Before incidence.left : '+incidence.left);
        system.debug('Before incidence.width : '+incidence.width);
        system.debug('Before incidence.right : '+incidence.right);
        
        // ADDED ON 08/27/2020
        if(incidence.left != NULL &&  incidence.width != NULL)
        {
            Decimal total = incidence.left + incidence.width;
            system.debug('endDtTime > now : '+endDtTime +'.. '+now);
            if(total == 99 && endDtTime >= now)
            {
                incidence.width += 1;
            }
            
            if(incidence.left == 100 &&  incidence.width == 0)
            {
                incidence.left = 99;
                incidence.width = 1; 
            }
            
            if(incidence.left == 0 && incidence.right == 0 && incidence.width == 100 && stDtTime > past24Hours)
            {
                incidence.width = 99;
                incidence.left = 1 ;
            }
        }

        system.debug('stDtTime : '+stDtTime);
        system.debug('endDtTime : '+endDtTime);
        
        Long startSeconds = stDtTime.getTime();
        Long endSeconds = endDtTime.getTime();   
        
        Double diff = ((endSeconds - startSeconds)/(1000*60));
        system.debug('diff : '+diff);
        
        if(diff < 15 && incidence.width != NULL && incidence.width == 0 )
        {
			incidence.width = 1;
        }
        
        system.debug('Final incidence.left : '+incidence.left);
        system.debug('Final incidence.width : '+incidence.width);
        system.debug('Final incidence.right : '+incidence.right);
        
        //RETURN incidenceDetails OBJECT
        return incidence;
    }

    
    // @author Prashant Wayal     
    // @description - METHOD TO CALCULATE THE PERCENTAGE VALUES FOR PAST 24 HOURS
    public Decimal calculatePercentage(DateTime startDateTime, DateTime endDateTime)
    {
		system.debug('===================> In calculatePercentage method...');
        system.debug('startDateTime : '+startDateTime);
        system.debug('endDateTime : '+endDateTime);
        
        // GET WIDTH FOR 1 HOUR 
        Double standardOneHourWidth = 100/24;
        standardOneHourWidth = standardOneHourWidth / 60;

        // GET START TIME AND END TIME IN MILLISECONDS
        Long startSeconds = startDateTime.getTime();
        Long endSeconds = endDateTime.getTime();
        
        // CALCULATE ACTUAL HOURS FROM MILLISECONDS
        //Double actualHours = ((endSeconds - startSeconds)/(1000*60*60));
        Double actualHours = ((endSeconds - startSeconds)/(1000*60));
		system.debug('actualMins : '+actualHours);
        
        // CALCULATE PERCENTAGE FROM ACTUAL HOURS & 1 HOUR VALUE
        Double actualPercentage = actualHours * standardOneHourWidth;
        actualPercentage = actualHours * 0.07;
        system.debug('actualPercentage : '+actualPercentage);
        
        Integer s = integer.valueOf(actualPercentage);
        actualPercentage = Decimal.valueOf(s);
        //RETURN PERCENTAGE
        return actualPercentage;
    }

    
    // @author Prashant Wayal
    // @description - METHOD TO GET THE CALENDAR DATA ON NEWLY SELCTED MONTH
    public PageReference changeMonth()
    {
        
        Map<String, String> tmpMap = monthsMap;
        List<String> checkPreviousList = checkPrevious(selectedMonth);
        If(checkPreviousList[0].equalsIgnoreCase('true'))
        {
            displayPrev = true;
        }
        else{
            displayPrev = false;
        }
        
        List<String> checkNextList = checkNext(selectedMonth);
        If(checkNextList[0].equalsIgnoreCase('true')){
            displayNext = true;
        }
        else{
            displayNext = false;
        }
        
        // GET CALENDAR FOR NEWLY SELECTED MONTH
        monthlyData = generateMonthlyData(selectedMonth, platformId);
		
		//update current time from maintenance calendar
        currentTime = system.now().formatGMT('MMM d yyyy HH:mm');  
        
        //update previous day and current Date string
        currentDatetime = system.now() - dayMinus;
        setDateTime(currentDateTime);
        return null;
    }
    
    
    // @author Prashant Wayal - 13-May-2016
    // @description - METHOD TO CHECK IF NEXT AVAILABLE MONTH TO SHOW DATA OR NOT
    public List<String> checkNext(String selMonth)
    {
        System.debug('*** inside checkNext *** '+selMonth);
        List<String> statusAndDateList = new List<String>();
        List<String> splitMonthList = selMonth.split('_');
        Integer year = Integer.valueOf(splitMonthList[1]);
        String month = splitMonthList[2];
        Integer monthNumber = monthAndNumberMap.get(month);
        Integer newMonth = monthNumber;
        
        Integer crntMonth = Date.Today().month();
        Integer crntYear = Date.Today().year();
        
        Boolean monthCheck = false;
        Boolean yearCheck = false;
        
        System.debug('*** newMonth *** '+newMonth +' *** year *** '+year);
        
        if(crntMonth>newMonth && crntYear == year)
        {
            monthCheck = crntMonth >= (newMonth);
        	yearCheck = crntYear == year;
        }else{
            monthCheck = crntMonth > (newMonth+1);
        	yearCheck = crntYear != year;
        }
        
        // CHECK IF CURRENT MONTH IS GREATER THAN PREVIOS MONTH END
        //Boolean monthCheck = crntMonth > (newMonth+1);
        //Boolean yearCheck = crntYear != year;
        if(selMonth == monthsOptionList.get(monthsOptionList.size()-1).getValue())
        {
            monthCheck = false;
        }
        System.debug('*** monthCheck *** '+monthCheck +' *** yearCheck *** '+yearCheck);
        Boolean allowNext = ((monthCheck && yearCheck) || (!monthCheck && !yearCheck));
        System.debug('*** allow Next *** '+allowNext);
        
        String nextMonthValue = splitMonthList[0]+'_'+year+'_'+monthNumMonthNameMap.get(newMonth);
        System.debug('*** Next Month Value *** '+nextMonthValue);
        
        statusAnddateList.add(allowNext+'');
        statusAnddateList.add(nextMonthValue);
        
        return statusAnddateList;
    }
    

    // @author Prashant Wayal - 13-May-2016
    // @description - METHOD TO CHECK IF THERE IS PREVIOUS MONTH IS AVAILABLE TO SHOW DATA OR NOT
    public List<String> checkPrevious(String selMonth)
    {
        system.debug('currentDatetimeStr : '+currentDatetimeStr);
        System.debug('*** inside checkPrevious *** '+selMonth);
        List<String> statusAndDateList = new List<String>();
        List<String> splitMonthList = selMonth.split('_');
        Integer year = Integer.valueOf(splitMonthList[1]);
        String month = splitMonthList[2];
        Integer monthNumber = monthAndNumberMap.get(month);
        System.debug('*** monthNumber *** '+monthNumber);
        Integer newMonth = monthNumber;
        
        Boolean monthCheck = false;
        Boolean yearCheck = false;
        
        Integer crntMonth = Date.Today().month();
        Integer crntYear = Date.Today().year();
        
        System.debug('*** newMonth *** '+newMonth +' *** year *** '+year);
        
        // CHECK IF CURRENT MONTH IS GREATER THAN PREVIOUS MONTH
        monthCheck = crntMonth < newMonth;
        yearCheck = crntYear <= year;
        
        if(newMonth<=crntMonth)
        {
            monthCheck = true;
        }
        //added for disabling previous button when it is the first month in the list
        if(selMonth == monthsOptionList.get(0).getValue())
        {
            monthCheck = false;
        }
        System.debug('*** monthCheck *** '+monthCheck +' *** yearCheck *** '+yearCheck);
        
        Boolean allowPrevious = ((monthCheck && yearCheck) || (!monthCheck && !yearCheck));
        System.debug('*** allow Previous *** '+allowPrevious);
        
        String nextMonthValue = splitMonthList[0]+'_'+year+'_'+monthNumMonthNameMap.get(newMonth);
        System.debug('*** Previous Month Value *** '+nextMonthValue);
        
        statusAnddateList.add(allowPrevious+'');
        statusAnddateList.add(nextMonthValue);
        
        return statusAnddateList;
    }
    
    // @author Prashant Wayal - 9-May-2016
    // @description - METHOD TO GET CALENDAR DATA FOR NEXT MONTH
    public PageReference nextMonth()
    {
        System.debug('*** inside nextMonth *** '+selectedMonth);
        //monthlyData = new Months();
        Map<String, String> tmpMap = monthsMap;
        
        List<String> splitMonthList = selectedMonth.split('_');
        Integer year = Integer.valueOf(splitMonthList[1]);
        String month = splitMonthList[2];
        
        //Integer monthNumber = monthAndNumberMap.get(month);
        Integer crntMonth = Date.Today().month();
        Integer crntYear = Date.Today().year();
        
        Integer monthNumber = monthAndNumberMap.get(month)+1;
        Integer newMonth = ((monthNumber <= 12)?(monthNumber):1);
        year = ((monthNumber > crntMonth && newMonth == 1)?(year+1):(year));
        
        //Integer newMonth = ((monthNumber <= 12)?(monthNumber):1);
        String newMonthName = splitMonthList[0]+'_'+year+'_'+monthNumMonthNameMap.get(newMonth);
        List<String> checkNextList = checkNext(newMonthName);
        
        If(checkNextList[0].equalsIgnoreCase('true'))
        {
            displayNext = true;
        }
        else
        {
            displayNext = false;
        }
        String nextMonthValue = checkNextList[1]; 
        System.debug('*** next Month *** '+nextMonthValue );
        selectedMonth = nextMonthValue;
        
        // GET CALENDAR DATA FOR NEWLY SELECTED MONTH
        monthlyData = generateMonthlyData(nextMonthValue, platformId);
        displayPrev = true;
        
        //update current time from maintenance calendar
        currentTime = system.now().formatGMT('MMM d yyyy HH:mm');
        
        //update previous day and current Date string
        currentDatetime = system.now() - dayMinus;
        setDateTime(currentDateTime);
        return null;
    }


    // @author Prashant Wayal - 9-May-2016
    // @description - METHOD TO GET CALENDAR DATA FOR NEXT MONTH
    public PageReference previousMonth()
    {
        System.debug('*** inside previousMonth *** '+selectedMonth);
        //monthlyData = new Months();
        Map<String, String> tmpMap = monthsMap;
        
        List<String> splitMonthList = selectedMonth.split('_');
        Integer year = Integer.valueOf(splitMonthList[1]);
        String month = splitMonthList[2];

        Integer crntMonth = Date.Today().month();
        Integer crntYear = Date.Today().year();
        
        Integer monthNumber = monthAndNumberMap.get(month)-1;
        System.debug('*** previousMonth monthNumber *** ' + monthNumber);
        Integer newMonth = ((monthNumber > 0 )?(monthNumber):12);
        year = ((monthNumber < crntMonth && newMonth == 12)?(year-1):(year));
        
        String newMonthName = splitMonthList[0] + '_' + year + '_' + monthNumMonthNameMap.get(newMonth);
        List<String> checkPreviousList = checkPrevious(newMonthName);
        if (checkPreviousList[0].equalsIgnoreCase('true'))
        {
            displayPrev = true;
        }
        else
        {
            displayPrev = false;
        }
        
        String prevMonthValue = checkPreviousList[1];
        System.debug('*** next Month *** ' + prevMonthValue);
        selectedMonth = prevMonthValue;
        
        // GET CALENDAR DATA FOR NEWLY SELECTED MONTH
        monthlyData = generateMonthlyData(prevMonthValue, platformId);
        displayNext = true;
        
        //update current time from maintenance calendar
        currentTime = system.now().formatGMT('MMM d yyyy HH:mm');
        
        //update previous day and current Date string
        currentDatetime = system.now() - dayMinus;
        setDateTime(currentDateTime);
        return null;
    }
    

    // @author Prashant Wayal - 9-May-2016
    // @description - METHOD TO GET DATA FOR NEXT MONTH
    public PageReference todayDate()
    {
        System.debug('*** inside todayDate *** '+selectedMonth);
        //monthlyData = new Months();
        Map<String, String> tmpMap = monthsMap;
        
        // GET MONTH NAME AND YEAR FOR SELECTED MONTH
        List<String> splitMonthList = selectedMonth.split('_');
        Integer year = Date.today().year();
        //String month = splitMonthList[2];
        //Integer monthNumber = monthAndNumberMap.get(month);
        String nextMonthValue = splitMonthList[0]+'_'+year+'_'+monthNumMonthNameMap.get(Date.Today().month());
        System.debug('*** next Month *** '+nextMonthValue );
        selectedMonth = nextMonthValue;
        
        displayPrev = true;
        displayNext = true;
        
        // GET CALENDAR DATA FOR NEWLY SELECTED MONTH
        monthlyData = generateMonthlyData(nextMonthValue, platformId);
        
        //update current time from maintenance calendar
        currentTime = system.now().formatGMT('MMM d yyyy HH:mm');
        
        //update previous day and current Date string
        currentDatetime = system.now() - dayMinus;
        setDateTime(currentDateTime);
        return null;
    }
   
    
    // @author Prashant Wayal     
    // @description  - METHOD TO GENERATE MONTHLY DATA BASED ON THE SELECTED MONTH
    public Months generateMonthlyData(String selectedMonth, String platformId)
    {
        if(currentDatetimeStr == Null)
        {
            // USED TO SHOW CURRENT TIME IN GMT FORMAT ON VF PAGE
            currentDatetimeStr = (System.now() - dayMinus).formatGMT('MMM d yyyy HH:mm');
        }
        
        // GET THE MONTH NAME AND YEAR FROM SELECTED MONTH
        List<String> splitMonthList = selectedMonth.split('_');
        Integer year = Integer.valueOf(splitMonthList[1]);
        String month = splitMonthList[2];
system.debug(' ^ selectedMonth = ' + selectedMonth); 
system.debug(' ^ platformId = ' + platformId);   
system.debug(' ^ splitMonthList = ' + splitMonthList);   
system.debug(' ^ year = ' + year);   
system.debug(' ^ month = ' + month);   
system.debug(' ^ monthAndNumberMap = ' + monthAndNumberMap);   
        // GET NUMBER OF DAYS IN SELECTED MONTH
        Integer days = Date.daysInMonth(year, monthAndNumberMap.get(month));
        
        // GET START DATE OF THE SELECTED MONTH
        DateTime startDate = DateTime.newInstance(year, monthAndNumberMap.get(month), 1, 0, 0, 1);
        
        // GET END DATE OF THE SELECTED MONTH
        DateTime endDate = DateTime.newInstance(year, monthAndNumberMap.get(month), days, 23, 59, 59);
        
        // GET ALL THE INCIDENTS LIST FOR TYPE "Maintenance" AND WITHIN SELECTED MONTH
        String updatedPlatformID = '%' + platformId + '%';
        
        // QUERY TO RETRIEVE ALL THE RECORDS OF TYPE "Maintenance"
        List<NI_Trust_Outage__c> outageList1 = [SELECT ID, Name, Outage_End_Date_Time__c, 
                                                Public_Details__c, 
                                                Incident_Description__c,
                                                Description__c, 
                                                Outage_Start_Date_Time__c, 
                                                Incident_Start_Date_Time__c, 
                                                Incident_End_Date_Time__c,
                                                Start_Time_GMT__c,
                                                End_Time_GMT__c,
                                                Total_Duration__c, 
                                                Type__c, 
                                                ( SELECT id, Name, AH_Trust__c, AH_Trust__r.Platform_Name_External__c 
                                                 FROM AH_Trusts_to_Incidents__r WHERE AH_Trust__c =: platformId ) 
                                                FROM NI_Trust_Outage__c 
                                                WHERE 
                                               	Make_Public__c = TRUE 
                                                AND RecordType.Name = 'Planned'];
                                    			//AND Type__c = 'Maintenance' ];

        
        List<NI_Trust_Outage__c> outageList = new List<NI_Trust_Outage__c>();
        for (NI_Trust_Outage__c out: outageList1)
        {
			// INCIDENT START DATE TIME 
            Datetime stDtTm = getDatetime(out.Incident_Start_Date_Time__c);
            String stDtTmie_GMT = stDtTm.formatGMT('yyyy-MM-dd HH:mm:ss');
            Datetime stDtTmie = Datetime.valueOfGMT(stDtTmie_GMT);
            
            // INCIDENT END DATE TIME
            system.debug('out.id : '+out.id);
            Datetime endDtTm = getDatetime(out.Incident_End_Date_Time__c);
            if(endDtTm == NULL)
            {
                endDtTm = endDate;
            }
            system.debug('endDtTm : '+endDtTm);
            String endDtTmie_GMT = endDtTm.formatGMT('yyyy-MM-dd HH:mm:ss');
            Datetime endDtTmie = Datetime.valueOfGMT(endDtTmie_GMT);
            
            outageList.add(out);
        }
        system.debug('outageList size : '+outageList.size());
        system.debug('outageList : '+outageList);
        
        List<MonthsDays> monthDaysList = new List<MonthsDays>();
        
        // GET MONTH START DATE
        Date monthStart = Date.newInstance(year, monthAndNumberMap.get(month), 1);
        
        // GET WEEK START DTAE OF MONTH IS NOT STARTING AT WEEK START DATE
        Date weekStart = monthStart.toStartOfWeek();
        
        // FROM WEEK START DAYS TO MONTH START DAY, ADD BLANK VALUES SO THAT CELLS ON CALENDAR ARE DISABLED AND MONTH SRAT DATE WIL SHOW CORRECTLY
        for(Integer i=0; i<(weekStart.daysBetween(monthStart)); i++)
        {
            MonthsDays monthDay = new MonthsDays();
            monthDaysList.add(monthDay);
        }
        
        // ITERATE OVER ALL MONTH DAYS FROM SELECTED MONTH
        for(Integer i=0; i<days; i++)
        {
            // CREATE THE NEW OBJECT FOR MONTHDAY
            MonthsDays monthDay = new MonthsDays();
            monthDay.dayName = i+1+'';
            
            // FROMAT DAY ID
            monthDay.dayId = 'day_'+year+'_'+month+(i+1);
            Date dt = Date.newInstance(year, monthAndNumberMap.get(month), i+1);
            
            // CHECK IF DATE IS TODAY'S DATE
            Boolean isToday = (Date.today() == dt)? true: false;
            monthDay.isToday = isToday;
            
            // FORMAT POPUP div id FOR DAY
            monthDay.popupDivId = 'popup_'+year+'_'+month+(i+1);
            
            // IF TODAY'S DATE THEN ADD SPECIAL CSS CLASS TO INDICATE THE DAY
            if(isToday)
            {
                monthDay.cssClassToday = 'platform-calendar-date-today';
                monthDay.isSelectedClass = 'platform-calendar-date-selected';
                monthDay.popupDisplay = 'display:block;';
            }
            else
            {
                if((monthAndNumberMap.get(month) != Date.Today().month()) && ((i+1) == 1))
                {
                    monthDay.isSelectedClass = 'platform-calendar-date-selected';
                    monthDay.popupDisplay = 'display:block;';
                }
                else
                {
                    monthDay.isSelectedClass = '';
                    monthDay.popupDisplay = 'display:none;';
                }
                monthDay.cssClassToday = '';
                //monthDay.popupDisplay = 'display:none;';
            }
            
            // CREATE LIST TO HOLD VALUES FOR ALL INCIDENCES ON THE PARTICULAR DAY
            List<DaysIncidence> incidenceList = new List<DaysIncidence>();
            
            // CREATE START DATETIME AND END DATETIME FOR DAY
            //DateTime stdt = DateTime.newInstance(year, monthAndNumberMap.get(month), (i+1), 0, 0, 1);
            //DateTime eddt = DateTime.newInstance(year, monthAndNumberMap.get(month), (days), 23, 59, 59);
            
            DateTime stdtGMT = DateTime.newInstanceGMT(year, monthAndNumberMap.get(month), (i+1), 0, 0, 1);
            Date stdtGMT1 = Date.newInstance(year, monthAndNumberMap.get(month), (i+1));
            Date eddtGMT1 = Date.newInstance(year, monthAndNumberMap.get(month), (days));
            
            
            Map<String,String> plannedIncTypes = new Map<String,String>();
            plannedIncTypes.put('Maintenance', 'Maintenance');
            plannedIncTypes.put('Upgrade', 'Upgrade');
            
            // LOOP THROUGH ALL THE INCIDENCES
            for(NI_Trust_Outage__c outage: outageList)
            {
                Datetime stDtTm1 = getDatetime(outage.Incident_Start_Date_Time__c);
                // COMMNETED ON 06/23/2020 
                //String stDtTmie_GMT = stDtTm1.formatGMT('yyyy-MM-dd HH:mm:ss');
                //Datetime stDtTm = Datetime.valueOfGMT(stDtTmie_GMT);
                Date stDtTm = date.newInstance(stDtTm1.year(), stDtTm1.month(), stDtTm1.day());
                
                Datetime endDtTm1 = getDatetime(outage.Incident_End_Date_Time__c);
                
                if(endDtTm1 == NULL)
                {
                    endDtTm1 = endDate;
                }
                system.debug(outage.id+' : endDtTm1 : '+endDtTm1);
                
                // COMMNETED ON 06/23/2020 
                //String endDtTmie_GMT = endDtTm1.formatGMT('yyyy-MM-dd HH:mm:ss');
                //Datetime endDtTm = Datetime.valueOfGMT(endDtTmie_GMT);
                Date endDtTm = date.newInstance(endDtTm1.year(), endDtTm1.month(), endDtTm1.day());
				system.debug(outage.id+' : endDtTm : '+endDtTm);
                
                // CHECK FOR SPECIFIC DAY'S INCIDENCE 
                //if(stDtTm <= stdt && (endDtTm < eddt || endDtTm >= eddt) && endDtTm >= stdt)
                if(stDtTm <= stdtGMT1 && (endDtTm < eddtGMT1 || endDtTm >= eddtGMT1) && endDtTm >= stdtGMT1)
                {

                    for(AH_Trust_to_Incident__c juncObj: outage.AH_Trusts_to_Incidents__r)
                    {
                        system.debug('outage id : '+outage.id);
                        system.debug('stDtTm : '+stDtTm+'...endDtTm : '+endDtTm);
                        system.debug('stdtGMT1 : '+stdtGMT1+'...eddtGMT1 : '+eddtGMT1);
                        
                        // CREATE NEW INCIDENCE RECORD FOR EACH INCIDENCE
                        DaysIncidence inc = new DaysIncidence();
                        inc.incidenceName = outage.Description__c;
                        //inc.incidenceDetails = outage.Public_Details__c;  	// COMMENTED ON 06/03/2020 FOR NEW REQUIREMENT
                        inc.incidenceDetails = outage.Incident_Description__c; 	// ADDED ON 06/03/2020 FOR NEW REQUIREMENT
                        
                        //inc.startTime = stDtTm.format('h:mm a');
                        //inc.endTime = endDtTm.format('h:mm a');
                        inc.startTime = outage.Start_Time_GMT__c;
                        inc.endTime = outage.End_Time_GMT__c;
                        
                        inc.platformName = juncObj.AH_Trust__r.Platform_Name_External__c;                     
                        
                        // ADD TO INCIDENCE LIST 
                        incidenceList.add(inc);
                        if(monthDay.dayIncidence != NULL && monthDay.dayIncidence != '' && monthDay.dayIncidence != outage.Type__c 
                           && (monthDay.dayIncidence != 'Maintenance,Upgrade' || monthDay.dayIncidence != 'Upgrade,Maintenance' )) 
                              //|| monthDay.dayIncidence != 'Maintenance,Maintenance' || monthDay.dayIncidence != 'Upgrade,Upgrade'  ))
                        {
                            monthDay.dayIncidence = monthDay.dayIncidence + ',' +outage.Type__c;
                        }
                        else 
                        {
                        	monthDay.dayIncidence = outage.Type__c;
                        }
                        //monthDay.dayIncidence = 'Maintenance';
                    }
                }
            }
            
            // SET DAY DATE IN SPECIFIC FORMAT
            //monthDay.dayDate = stdt.format('MMMM dd, yyyy');
            monthDay.dayDate = stdtGMT.format('MMMM dd, yyyy');
            monthDay.incidenceList = incidenceList;
            
            // ADD TO monthsDaysList VARIABLE
            monthDaysList.add(monthDay);
        }

        // CREATE monthData OBJECT AND ASSIGN DAYS RECORDS FOR SEELCTED MONTH
        Months monthData = new Months();
        monthData.monthName = month;
        monthData.monthId = selectedMonth;
        monthData.daysList = monthDaysList;
        
        // RETURN months OBJECT
        return monthData;
    }

    
    // THIS MAP WILL HOLD THE VALUES OF CSS CLASS FOR SPECIFIC INCIDENCE TYPE
    public static Map<String, String> incidenceTypeMap
    {
        get{
            Map<String, String> incidenceMap = new Map<String, String>();
            incidenceMap.put('Service Disruption', 'instance-span-disruption');
            incidenceMap.put('Degraded Service', 'instance-span-performance');
            incidenceMap.put('Maintenance', 'instance-span-maintenance');
            incidenceMap.put('Upgrade', 'instance-span-info');
            return incidenceMap;
        }
    }
    
    // STATUS MAP VARIABLE TO HOLD VALUES OF PLATRORM TYPE AND RELATED CSS CALSS TO SHOW ON VF PAGE
    public static Map<String, String> platformStatusMap
    {
        get{
            Map<String, String> platformMap = new Map<String, String>();
            platformMap.put('Service Disruption', 'platform-status-down');
            platformMap.put('Degraded Service', 'platform-status-slow');
            platformMap.put('Maintenance', 'platform-status-maintenance');
            platformMap.put('Upgrade', 'platform-status-info');
            return platformMap;
        }
    }
    
   
    // @author Prashant Wayal
    // @description - METHOD TO DISPLAY THE HISTORY OF PLATFORMS
    public PageReference displayHistory()
    {
        showCalendar = false;
        showHistory = true;
        showStatus = false;
        return null;
    }
    
    
    // PREVIOUS ARROW BUTTON ON CALENDAR PAGE
    public Boolean flag = false;
    public void previousDay1()
    {
        flag = true;
        dayMinus++;
        dayPlus++;

        currentDatetime = system.now() - dayMinus;
        currentTime = system.now().formatGMT('MMM d yyyy HH:mm');
        selectedPlatformId = platformId;
        ApexPages.currentPage().getParameters().put('platformId', selectedPlatformId);
        
        platformsList = new List<PlatformDetails>();
        showPlatformDetails();
    }
    
    // NEXT ARROW BUTTON ON CALENDAR PAGE
    public void nextDay1()
    {
        flag = true; 
        dayMinus--;
        dayPlus--;

        currentDatetime = system.now() - dayMinus;
        currentTime = system.now().formatGMT('MMM d yyyy HH:mm');
        selectedPlatformId = platformId;
        ApexPages.currentPage().getParameters().put('platformId', selectedPlatformId);
        
        platformsList = new List<PlatformDetails>();
        showPlatformDetails();
    }
    
    
    public Integer dayMinus {get; set;} 
    public Integer dayPlus = 0;
    
    // PREVIOUS ARROW BUTTON ON MAIN PAGE
    public void previousDay ()
    {
        dayMinus++;
        dayPlus++;

        currentDatetime = system.now() - dayMinus;
        selectedPlatformId = NULL;
        
        platformsList = new List<PlatformDetails>();
        platformSOList = new List<SelectOption>();
        showPlatformStatus();
    }

    // NEXT ARROW BUTTON ON MAIN PAGE
    public void nextDay ()
    {
        dayMinus--;
        dayPlus--;

        currentDatetime = system.now() - dayMinus;
        selectedPlatformId = NULL;
        
        platformsList = new List<PlatformDetails>();
        platformSOList = new List<SelectOption>();
        showPlatformStatus();
    }

    
    // =========================================================================================================================================
    //			WRAPPER CLASSES 
    // =========================================================================================================================================

    // WRAPPER CLASS TO HOLD VALUES OF INCIDENCES FOR SPECIFIC PLATFORM
    public class IncidenceDetails
    {
        public Decimal incidenceDuration{ get; set; } 		// Total Minutes
        public String incidenceStartDate{ get; set; }		// Incidence start date
        public String incidenceEndDate{ get; set; } 		// Incidence end date
        public String incidenceDesc{ get; set; } 			// Incidence Description
        public String incidenceSolution{ get; set; } 		// Incidence solution
        public String incidenceType{ get; set; } 			// Type of incidence
        public Decimal width{ get; set; } 					// CSS width property to show incidence specific color
        public Decimal left{ get; set; } 					// CSS left property to show incidence color from left side
        public String cssClass{ get; set; } 				// CSS class for specific incidence
        public String incId{ get; set; } 					// Incidence Id
        public String popupDivId{ get; set; } 				// Popup DIV Id to show when user clicks on incidence color
        
        // ADDED BY SHASHIKANT - 06/08/2018
        public String startDtTime{ get; set; } 				// Incidence start time
        public String endDtTime{ get; set; } 				// Incidence end time
        public String NotificationHeading{ get; set; } 		// Incidence Notification Heading        
        public String Severity{ get; set; } 				// Severity of the incidence
        public String HotSOSApplication{ get; set; } 		// Hot SOS Application of the incidence
        public String CaseNumber{ get; set; } 				// Case Number of the incidence
        public String EstimatedDuration{ get; set; } 		// Estimated Duration of the incidence
        public String IncidentDescription{ get; set; } 		// Incident Description of the incidence
        public String CustomerImpact{ get; set; } 			// Customer Impact of the incidence
        public String WorkaroundInformation{ get; set; } 	// Workaround Information of the incidence
        public String AmadeusInvestigativeAction{ get; set; } // Amadeus Investigative Action of the incidence
        public String EditableDuration{ get; set; } 		// Total Duration (Editable) of the incidence
        public String rootCause{ get; set; } 				// Root cause of incidence
        public String platformName{ get; set; } 			// Platform on which incidence is reported
        public String incidenceName{ get; set; } 			// Incidence name
        public Decimal right { get; set; }					// CSS right property to show incidence color from left side
        public String RecordTypeName { get; set; } 			// Record Type of the incidence
        public Boolean isOngoing {get; set;}
    }
    
    // WRAPPER CLASS TO HOLD VALUES OF PLATFORMS
    public class PlatformDetails
    {
        public String platformName{ get; set; } 		// Platform name
        public String platformId{ get; set; } 			// Platform Id
        public String statusClass{ get; set; } 			// CSS class to show platform Status
        public Boolean hasOngoingIncidence{get;set;}
        public List<IncidenceDetails> incidenceList{ get; set; } // List of incidences for specific platform
    }
    
    // WRAPPER CLASS TO HOLD VALUES OF MONTHS DATA ON CALENDAR
    public class Months
    {
        public String monthName{ get; set; } 			// Month name
        public String monthId{ get; set; } 				// Month Id
        public List<MonthsDays> daysList{ get; set; } 	// List of all days in a month
    }
    
    // WRAPPER CLASS TO HOLD VALUES OF ALL THE DAYS IN A SPECIFIC MONTH
    public class MonthsDays
    {
        public String dayName{ get; set; } 				// Day name
        public String dayId{ get; set; } 				// Day Id
        public String dayDate{ get; set; } 				// Day Date
        public String dayIncidence{ get; set; } 		// Incidence reported on day
        public Boolean isToday{ get; set; } 			// Flag to check if date is today's date
        public String cssClassToday{ get; set; } 		// CSS class for today's date
        public String popupDivId{ get; set; } 			// DIV Id to be shown when user clicks on specific day
        public String popupDisplay{ get; set; }
        public List<DaysIncidence> incidenceList{ get; set; } // Incidence list reported on specific day
        public String isSelectedClass{ get; set; }
    }
    
    // WRAPPER CLASS TO HOLD VALUES OF INCIDENCES REPORTED ON SPECIFIC DAY
    public class DaysIncidence
    {
        public String incidenceName{ get; set; } 		// Incidence Name
        public String incidenceDetails{ get; set; } 	// Incidence details
        public String startTime{ get; set; } 			// Incidence start time
        public String endTime{ get; set; } 				// Incidence end time
        public String platformName{ get; set; } 		// Platform name on which incidence reported
    }

    // ========================================================================================================================================
    //			UTILITY FUNCTIONS 
    // ========================================================================================================================================
    
    
    
    // METHOD TO SET THE CURRENT AND PAST 24 HOURS DATE AND TIME ... THIS WILL REFLECT ON MAIN PAGE 
    private void setDateTime(Datetime todaysDatetime) 
    {    
        
        // USED IN OTHER METHODS COLOR BAR CALCULATION
        minus_24_hours_time = todaysDatetime.addHours(-24);
        
        // USED TO SHOW TIME IN 6 HOURS INTERVAL IN GMT FORMAT ON VF PAGE
        minus_6_hours_time = todaysDatetime.addHours(-6).formatGMT('MMM d yyyy HH:mm'); 
        minus_12_hours_time = todaysDatetime.addHours(-12).formatGMT('MMM d yyyy HH:mm');
        minus_18_hours_time = todaysDatetime.addHours(-18).formatGMT('MMM d yyyy HH:mm');
        minus_24_hours_time1 = todaysDatetime.addHours(-24).formatGMT('MMM d yyyy HH:mm');

        // USED TO SHOW CURRENT TIME IN GMT FORMAT ON VF PAGE
        currentDatetimeStr = todaysDatetime.formatGMT('MMM d yyyy HH:mm');
    }
    
    
    private Datetime getDatetime(String str)
    {    
        Datetime newDate;
        if (str != NULL) 
        {
            List<String> dtTme = str.split(' ');
            List<String> dtValues = dtTme[0].split('/');
            Date dt = Date.newInstance(Integer.valueof(dtValues[2]), Integer.valueof(dtValues[0]), Integer.valueof(dtValues[1]));
            
            List<String> timeValues = dtTme[1].split(':');
            Time tm = Time.newInstance(Integer.valueof(timeValues[0]), Integer.valueof(timeValues[1]), 0, 0);
            newDate = Datetime.newInstanceGMT(dt, tm);
        }
        return newDate;
    }
    
}