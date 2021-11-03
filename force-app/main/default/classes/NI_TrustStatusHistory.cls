/**************************************************************************************** 
Name            : NI_TrustStatusHistory Class 
Author          : 
Created Date    : 
Last Mod Date   : 05/25/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Extension controller for NI_StatusHistory Visualforce Page Component
                : 
                :  
******************************************************************************************/

public class NI_TrustStatusHistory 
{
    
    public String query{ get; set; } 						// dynamic query to be formed based on the history filters
    public String selectedPlatform{ get; set; } 			// Selected platform to filter history data
    public String selectedDate{ get; set; } 				// Selected date range to filter history data
    public List<SelectOption> platformSOList{ get; set; } 	// SelectOption list to show all platforms in filter criteria
    //public List<IncidenceHistory> incidenceHistoryList{ get; set; }
 
    public String ipPlatformName {get; set;}				// HOLDS PLATFROM ID SENT FROM VF PAGE
    public static Boolean isMadeNull = false;				// BOOLEAN VARIABLE
    
    // DEFAULT CONSTRUCTOR
    public NI_TrustStatusHistory()
    {
        system.debug('in VF Component Constructor ...ipPlatformName : '+ipPlatformName);
        
        // INITIALISE LIST AND SET DETAULT VALUES FOR FILTERS
        platformSOList = new List<SelectOption>();
        selectedPlatform = 'all';
        //selectedDate = '7';
        selectedDate = '90';
        platformSOList.add(new SelectOption('all', 'All'));
        
        // GET ALL PLATFORM RECORDS
        for(NI_Trust__c platform: [Select Id, Platform_Name_External__c from NI_Trust__c])
        {
            platformSOList.add(new SelectOption(platform.Id, platform.Platform_Name_External__c ));
        }

        // CALL REFRESH HISTORY METHOD TO SHOW HISTORY WITH DEFAULT VALUES
        refreshHistory();
    }
    
    // STANDARDSET CONSTRUCTOR   =    THIS WILL BEUSED FOR PAGINATION
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                // SETS THE NUMBER OF RECORDS IN EACH PAGE SET
                con.setPageSize(10); 
            }
            return con;
        }
        set;
    }
    
    // METHOD TO RETURN THE DATE REANGE FOR FILTERS ON HISTPRY PAGE
    public List<SelectOption> getDateRangeOptions()
    {
        List<SelectOption> dateList = new List<SelectOption>();
        dateList.add(new SelectOption('7', 'Most Recent'));
        dateList.add(new SelectOption('2', 'Last 48 Hours'));
        dateList.add(new SelectOption('LAST_WEEK', 'Last Week'));
        dateList.add(new SelectOption('LAST_MONTH', 'Last Month'));
        dateList.add(new SelectOption('90', 'Last 90 Days'));
        //dateList.add(new SelectOption('THIS_YEAR', 'This Year'));
        return dateList;
    }
    
    // @author Prashant Wayal
    // @description - METHOD TO FETCH THE HISTORY DATA BASED ON THE FILTER CRITERIA
    public PageReference refreshHistory()
    {
        //incidenceHistoryList.clear();
        
        // SET con VARIABLE TO NULL TO GET NEW DATA BASED ON FILTERS
        con = null;
		
        ipPlatformName= NULL;
        isMadeNull = true;
        
        // CHANGED BY SHASHIKANT ON 01/15/2020 
        String query1 = 'select Id, Name, Outage_End_Date_Time__c,  Description__c, Root_Cause_Analysis__c, RecordType.Name, '+                                          
                        ' Notification_Heading__c, Severity__c, HotSOS_Application__c, Case_Number__c, Estimated_Duration__c, '+
                        ' Incident_Description__c, Customer_Impact__c, Workaround_Information__c, Editable_Duration__c, '+
                        ' Incident_Start_Date_Time__c, Incident_End_Date_Time__c, Start_Date__c, '+
                        ' ( SELECT id, AH_Trust__c, AH_Trust__r.Platform_Name_External__c FROM AH_Trusts_to_Incidents__r ';

        if(!selectedPlatform.equals('all'))
        {
            query1 += ' WHERE AH_Trust__c = \''+selectedPlatform+'\'), '; 
        }
        else{
            query1 += ' ), ';
        }
        query1 += 	' Outage_Start_Date_Time__c, Total_Duration__c, Type__c, Amadeus_Investigative_Action__c '+
            		' from NI_Trust_Outage__c where Make_Public__c = TRUE '+
        			' ORDER BY Start_Date__c DESC';
        
        /*
        if(selectedDate.equals('LAST_WEEK') || selectedDate.equals('LAST_MONTH')){// || selectedDate.equals('THIS_YEAR')){
            query1 += ' AND Start_Date__c  = '+selectedDate;
        }
        else{
            query1 += ' AND Start_Date__c = LAST_N_DAYS:'+selectedDate;
        }
        */
        
        // INITIALISE CLASS QUERY VARIABLE WITH NEW QUERY
        this.query = query1;
        
        system.debug('query1 : '+query1);
        
        // CALL incidenceHistoryList METHOD TO FETCH NEW HISTORY DATA
        getIncidenceHistoryList();
        
        // START PAGINATION FROM PAGE NO 1
        con.setPageNumber(1);
        
        return null;
    }
    
    // @author Prashant Wayal
    // @description - METHOD TO GET THE INCIDENCE HISTORY DATA
    public List<IncidenceHistory> getIncidenceHistoryList()
    {
        system.debug('============================in getIncidenceHistoryList.....selectedPlatform : '+selectedPlatform+'...ipPlatformName : '+ipPlatformName);
        
        // GET HISTORY DATA
        Map<String, List<DaysIncidence>> historyMap = showHistory();
        List<IncidenceHistory> incList = new List<IncidenceHistory>();
        
        // LOOP THROUGH HISTORY DATA TO FORMAT DATA IN PROPER FORMAT
        for(String s: historyMap.keySet())
        {
            // CREATE NEW IncidenceHistory OBJECT AND ASSIGN VALUES TO MEMBER VARIABLES
            IncidenceHistory hist = new IncidenceHistory();
            hist.monthName = s;
            hist.incidenceList = historyMap.get(s);
            
            // ADD IncidenceHistory OBJECT TO LIST
            incList.add(hist);
        }
        system.debug('incList size : '+incList.size());
        
        // RETURN IncidenceHistory LIST
        return incList;
    }
    
    // @author Prashant Wayal
    // @description - METHOD TO GET THE HISTORY DATA BASED ON NEW FILTERS & QUERY
    public Map<String, List<DaysIncidence>> showHistory()
    {
        
        Map<String, List<DaysIncidence>> historyMap = new Map<String, List<DaysIncidence>>();
        
        system.debug('in showHistory.....selectedPlatform : '+selectedPlatform+'...ipPlatformName : '+ipPlatformName + '...isMadeNull : '+isMadeNull);
        
        Boolean isPlatformChanged = false;
        
        // GET ALL INCIDENVE RECORDS BASED ON THE NEWLY FORMATTED QUERY FROM STANDARD SET CONTROLLER
        if(ipPlatformName != NULL && ipPlatformName != '' && isMadeNull == false)
        {            
            // CALL METHOD TO REFRESH THE QUERY RESULT ACCORDIN TO SELECTED PLATFORM
        	updateRefreshHistory();
            
            isPlatformChanged = true;
        }
        
        system.debug('con.getRecords() size : '+con.getRecords().size());
        
        List<NI_Trust_Outage__c> newOutList = new List<NI_Trust_Outage__c>();
        for(NI_Trust_Outage__c outage: (List<NI_Trust_Outage__c>) con.getRecords())
        {
            //system.debug('outage.id : '+outage.Name);
            
            // GET MONTH OF THE YEAR 
            //String monthYear = outage.Outage_Start_Date_Time__c.format('MMMM yyyy');
            Datetime stDtTime = getDatetime(outage.Incident_Start_Date_Time__c);
            
            if(selectedDate.equals('LAST_WEEK'))
            {
                Date myDate = Date.today().addDays(-7);
                Date weekStart = myDate.toStartofWeek();
                Date weekEnd = weekStart.addDays(+7);
                
                Datetime LastweekstartTime = Datetime.newInstanceGMT(weekStart.year(),weekStart.month(),weekStart.day(),00,00,00);
                Datetime LastweekendTime = Datetime.newInstanceGMT(weekEnd.year(),weekEnd.month(),weekEnd.day(),00,00,00);

                if (stDtTime >=LastweekstartTime && stDtTime <= LastweekendTime){
                    newOutList.add(outage);
                }
            }
            else if(selectedDate.equals('LAST_MONTH'))
            {
                Date myDate = Date.today().addMonths(-1);
                Date mnthStart = myDate.toStartOfMonth();
                Integer noOfDays = date.daysInMonth(mnthStart.year(), mnthStart.month());
                Date mnthEnd = mnthStart.addDays(+noOfDays);
                
                Datetime LastmnthstartTime = Datetime.newInstanceGMT(mnthStart.year(),mnthStart.month(),mnthStart.day(),00,00,00);
                Datetime LastmnthsendTime = Datetime.newInstanceGMT(mnthEnd.year(),mnthEnd.month(),mnthEnd.day(),00,00,00);

                if (stDtTime >=LastmnthstartTime && stDtTime <= LastmnthsendTime){
                    newOutList.add(outage);
                }
            } 
            else 
            {
                Datetime stDtTm = System.now().addDays(-Integer.valueOf(selectedDate));

                if (stDtTime >=stDtTm){
                    newOutList.add(outage);
                }
            }
        }    
        system.debug('newOutList size : '+newOutList.size());
        
        for(NI_Trust_Outage__c outage: newOutList)
        {
            
            Datetime stDtTime = getDatetime(outage.Incident_Start_Date_Time__c);
            String monthYear = stDtTime.format('MMMM yyyy');

            // CHECK IF historyMap CONTAINS RECORDS FOE PARTICULAR MONTH
            // IF KEY IS PRESENT, ADD INCIDENCE RECORD IN THE SAME APP
            if(historyMap.get(monthYear) != null)
            {
                List<DaysIncidence> dList = createHistoryRecord(outage);
                for(DaysIncidence d : dList)
                {
                    if(d.incId != NULL)
                    {
                        String key = d.incId +'_'+  d.trustId  +'_'+  monthYear;
                        historyMap.get(monthYear).add(d);
                    }
                }
            }
            else
            {
                // ADD NEW MONTH RECORD FOR SHOWING HISTORY
                List<DaysIncidence> dList = createHistoryRecord(outage);
                for(DaysIncidence d : dList)
                {
                    if(d.incId != NULL)
                    {
                        if( historyMap.containsKey(monthYear) )
                        {
                            historyMap.get(monthYear).add(d);
                        }
                        else 
                        {
                            historyMap.put(monthYear, new List<DaysIncidence>{d});
						}
                        
                        String key = d.incId +'_'+  d.trustId  +'_'+  monthYear;
                    }
                }
            }
        }
        system.debug('historyMap size : '+historyMap.size());

        // ADDED BY SHASHIKANT ON 05/13/2020
        if(isPlatformChanged)
        {
            List<IncidenceHistory> incList = new List<IncidenceHistory>();
            
            // LOOP THROUGH HISTORY DATA TO FORMAT DATA IN PROPER FORMAT
            for(String s: historyMap.keySet())
            {
                // CREATE NEW IncidenceHistory OBJECT AND ASSIGN VALUES TO MEMBER VARIABLES
                IncidenceHistory hist = new IncidenceHistory();
                hist.monthName = s;
                hist.incidenceList = historyMap.get(s);
                
                // ADD IncidenceHistory TO LIST 
                incList.add(hist);
            }
        }
        
        // RETURN history map
        return historyMap;
    }
    
    
    // ADDED BY SHASHIKANT ON 05/13/2020
    // METHOD TO FETCH THE DATA OF PARTICULAR PATFORM AND SET THE con VARIABLE
    public void updateRefreshHistory()
    {
        
        con = null;
        
        system.debug('in updateRefreshHistory....selectedPlatform : '+selectedPlatform+'.....ipPlatformName : '+ipPlatformName);
        
        String query1 = 'select Id, Name, Outage_End_Date_Time__c,  Description__c, Root_Cause_Analysis__c, RecordType.Name, '+                                          
            ' Notification_Heading__c, Severity__c, HotSOS_Application__c, Case_Number__c, Estimated_Duration__c, '+
            ' Incident_Description__c, Customer_Impact__c, Workaround_Information__c, Editable_Duration__c, '+
            ' Incident_Start_Date_Time__c, Incident_End_Date_Time__c, Start_Date__c, '+
            ' ( SELECT id, AH_Trust__c, AH_Trust__r.Platform_Name_External__c FROM AH_Trusts_to_Incidents__r ';
        
        if( (ipPlatformName != NULL || ipPlatformName != '') )
        {
            query1 += ' WHERE AH_Trust__c = \''+ipPlatformName+'\'), '; 
        }
        else{
            query1 += ' ), ';
        }
        query1 += 	' Outage_Start_Date_Time__c, Total_Duration__c, Type__c, Amadeus_Investigative_Action__c '+
            ' from NI_Trust_Outage__c where Make_Public__c = TRUE '+
            ' ORDER BY Start_Date__c DESC';
        
        // INITIALISE CLASS QUERY VARIABLE WITH NEW QUERY
        this.query = query1;
        
        system.debug('query1 : '+query1);
        
        selectedPlatform = ipPlatformName;
        ipPlatformName = NULL;
        
        // START PAGINATION FROM PAGE NO 1
        con.setPageNumber(1); 
    }
  
    
    // @author Prashant Wayal
    // @description - METHOD TO CREATE DaysIncidence RECORD BASED ON THE INCIDENCE DETAILS
    public List<DaysIncidence> createHistoryRecord(NI_Trust_Outage__c outage)
    {
        
        system.debug('In createHistoryRecord method...'+outage.id);

		List<DaysIncidence> incList = new List<DaysIncidence>();
        for(AH_Trust_to_Incident__c juncObj: outage.AH_Trusts_to_Incidents__r)
        {
            // CREATE DaysIncidence OBJECT FOR INCIDENCE RECORD AND INITIALISE MEMBER VARIABLES
        	DaysIncidence inc = new DaysIncidence();
            
			system.debug('juncObj.AH_Trust__c : '+juncObj.AH_Trust__c +' => '+juncObj.AH_Trust__r.Platform_Name_External__c);
            inc.trustId = juncObj.AH_Trust__c;
            inc.incId = outage.Id;
            inc.incidenceName = (outage.Description__c != null)?(' - '+outage.Description__c):'';
            //inc.incidenceDetails = outage.Public_Details__c;
            
            Datetime stDtTime = getDatetimeWtGMT(outage.Incident_Start_Date_Time__c);
            Datetime endDtTime = NULL;
            if (outage.Incident_End_Date_Time__c!= NULL){
                endDtTime = getDatetimeWtGMT(outage.Incident_End_Date_Time__c);
            }
            
            //ADDED BY SHASHIKANT ON 05/30/2018
            inc.NotificationHeading = outage.Notification_Heading__c;
            inc.Severity = outage.Severity__c;
            inc.HotSOSApplication = outage.HotSOS_Application__c;
            inc.CaseNumber = outage.Case_Number__c;
            inc.startDtTime = NULL;
            if (stDtTime != NULL){
                inc.startDtTime = String.valueOf(stDtTime) + ' GMT';
            }
            inc.endDtTime = NULL;
            if (endDtTime != NULL){
                inc.endDtTime = String.valueOf(endDtTime);
            }
            inc.EstimatedDuration = String.valueOf(outage.Estimated_Duration__c);
            inc.IncidentDescription = outage.Incident_Description__c;
            inc.CustomerImpact = outage.Customer_Impact__c;
            inc.WorkaroundInformation = outage.Workaround_Information__c;
            inc.EditableDuration = String.valueOf(outage.Editable_Duration__c);
            inc.AmadeusInvestigativeAction = outage.Amadeus_Investigative_Action__c;
            
            // FORMAT START TIME
            inc.dayName = stDtTime.format('M/d');
            
            //COMENTED External_Platform_Name__c FIELD on 01/15/2020
            //inc.platformName = outage.External_Platform_Name__c;   
            inc.platformName = juncObj.AH_Trust__r.Platform_Name_External__c;   
            inc.type = ' - '+outage.Type__c;
            inc.rootCause = outage.Root_Cause_Analysis__c;
            inc.RecordTypeName = outage.RecordType.Name;
            
            incList.add(inc);
        }
        
        // RETURN DaysIncidence OBJECT
        return incList;
    }
    

    private Datetime getDatetime(String str){
        
        Datetime newDate;
            
        if (str != NULL) {
            List<String> dtTme = str.split(' ');
            List<String> dtValues = dtTme[0].split('/');
            Date dt = Date.newInstance(Integer.valueof(dtValues[2]), Integer.valueof(dtValues[0]), Integer.valueof(dtValues[1]));
            
            List<String> timeValues = dtTme[1].split(':');
            Time tm = Time.newInstance(Integer.valueof(timeValues[0]), Integer.valueof(timeValues[1]), 0, 0);
            newDate = Datetime.newInstanceGMT(dt, tm);
        }
        return newDate;
    }
    
    private Datetime getDatetimeWtGMT(String str){
        
        Datetime newDate;
            
        if (str != NULL) {
            List<String> dtTme = str.split(' ');
            List<String> dtValues = dtTme[0].split('/');
            Date dt = Date.newInstance(Integer.valueof(dtValues[2]), Integer.valueof(dtValues[0]), Integer.valueof(dtValues[1]));
            
            List<String> timeValues = dtTme[1].split(':');
            Time tm = Time.newInstance(Integer.valueof(timeValues[0]), Integer.valueof(timeValues[1]), 0, 0);
            newDate = Datetime.newInstance(dt, tm);
        }
        return newDate;
    }
    
    // =========================================================================================================================================
    //			PAGINATION METHODS 
    // =========================================================================================================================================
    
    // INDICATES WHETHER THERE ARE MORE RECORDS AFTER THE CURRENT PAGE SET
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // INDICATES WHETHER THERE ARE MORE RECORDS BEFORE THE CURRENT PAGE SET 
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // RETURNS THE PAGE NUMBER OF THE CURRENT PAGE SET 
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    // RETURNS FIRST PAGE OF RECORDS
     public void first() {
         con.first();
     }

     // RETURNS LAST PAGE OF RECORDS
     public void last() {
         con.last();
     }

     // RETURNS PREVIOUS PAGE OF RECORDS
     public void previous() {
         con.previous();
     }

     // RETURNS NEXT PAGE OF RECORDS
     public void next() {
         con.next();
     }

     // RETUNS THE PageReference OF THE ORIGINAL PAGE, IF KNOWN, OF THE HOME PAGE
     public void cancel() {
         con.cancel();
     }
      
    
    // =========================================================================================================================================
    //			WRAPPER CLASSES 
    // =========================================================================================================================================

    // WRAPPER CLASS TO HOLD VALUES FOR INCIDENCES REPORTED IN SPECIFIC MONTH
    public class IncidenceHistory
    {
        public String monthName{ get; set; } 					//month name
        public List<DaysIncidence> incidenceList{ get; set; } 	//List of all incidences reported in month
    }
    
    // WRAPPER CLASS TO HOLD VALUES OF INCIDENCE REPORTED
    public class DaysIncidence
    {
        public Id trustId { get; set; } 						//Trust Id
        public Id incId { get; set; } 							//Incidence Id
        public String incidenceName{ get; set; } 				//Incidence name
        //public String startTime{ get; set; } 					//Incidence start time
        //public String endTime{ get; set; } 					//Incidence end time
        public String platformName{ get; set; } 				//Platform on which incidence is reported
        public String type{ get; set; } 						//Type of incidence 
        public String rootCause{ get; set; } 					//Root cause of incidence
        public String dayName{ get; set; } 						//Day name on which incidence is reported

        // ADDED BY SHASHIKANT - 05/30/2018
        public String startDtTime{ get; set; } 					//Incidence start time
        public String endDtTime{ get; set; } 					//Incidence end time
        public String NotificationHeading{ get; set; } 			//Incidence Notification Heading        
        public String Severity{ get; set; } 					//Severity of the incidence
        public String HotSOSApplication{ get; set; } 			//Hot SOS Application of the incidence
        public String CaseNumber{ get; set; } 					//Case Number of the incidence
        public String EstimatedDuration{ get; set; } 			//Estimated Duration of the incidence
        public String IncidentDescription{ get; set; } 			//Incident Description of the incidence
        public String CustomerImpact{ get; set; } 				//Customer Impact of the incidence
        public String WorkaroundInformation{ get; set; } 		//Workaround Information of the incidence
        public String AmadeusInvestigativeAction{ get; set; } 	//Amadeus Investigative Action of the incidence
        public String EditableDuration{ get; set; } 			//Total Duration (Editable) of the incidence
        public String RecordTypeName { get; set; } 				//Record Type of the incidence
    }
}