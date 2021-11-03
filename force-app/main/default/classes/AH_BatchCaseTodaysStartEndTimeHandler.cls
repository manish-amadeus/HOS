/****************************************************************************************
Name            : AH_BatchCaseTodaysStartEndTimeHandler Class
Author          : Cybage Developer - Shashikant Nikam
Created Date    : 01/15/2018
Last Mod Date   : 02/15/2018
Last Mod By     : Cybage Developer - Shashikant Nikam
NICC Reference  : NICC-026092
Description     : Test Class is: AH_BatchTodaysStartEndTimeHandlerTest 
                : This class calculates Todays Start Time & Todays End Time on Case.
				: This class calculate AH_Previous_Business_Hours__c on Case.
				: 
*****************************************************************************************/
public class AH_BatchCaseTodaysStartEndTimeHandler {

    public static String dayOfWeek = System.now().format('EEEE');
    public static boolean incomplete_week_flag_endTime = false;
    public static boolean std_hrs_flag = false;
    public static boolean bsns_hrs_flag = false;
    public static boolean st_end_null_flag = false;
    
    public List<Case> getCasesWithTime(List<Case> cases){
        
        List<Case> case_list = new List<Case>();
        try { 
            AH_CaseFlagPreferences__c flag_pref = AH_CaseFlagPreferences__c.getInstance();
			String stdHours = flag_pref.Hours__c;
			System.debug('stdHours : '+stdHours);
            
            for (Case c : cases) {
                
                Datetime startTime;
                Datetime endTime;
                System.debug('Case : '+c);
                System.debug('Case  Wednesday startTime: '+c.BusinessHours.WednesdayStartTime);
                System.debug('Case  Wednesday EndTime: '+c.BusinessHours.WednesdayEndTime);
                
                if (stdHours == '24'){ // || (Test.isRunningTest() && std_hrs_flag == true)) {
                    
					Date myDate = Date.today();
                    Date weekStart = myDate.toStartofWeek();
                    Date weekEnd = weekStart.addDays(+7);

                    startTime = Datetime.newInstance(weekStart.year(),weekStart.month(),weekStart.day(),00,00,00);
					endTime = Datetime.newInstance(weekEnd.year(),weekEnd.month(),weekEnd.day(),00,00,00);
                }
                else { //if (Test.isRunningTest() && bsns_hrs_flag == true) {
                    
                    // GET CURRENT DAYS DATE & TIME USING getTime FUNCTION
                    Map<String,datetime> mapofDatetime = getTime(System.now(),dayOfWeek, c);
                    system.debug('mapofDatetime'+mapofDatetime);
                    startTime = mapofDatetime.get('startTime');
                    endTime = mapofDatetime.get('endTime');
    
                    Date myDate = Date.today();
                    Date weekStart = myDate.toStartofWeek();
                    Date weekEnd = weekStart.addDays(+6);
                    
                    System.debug('Start & End Time : '+ startTime + ','+endTime); 
                    System.debug('WeekStart : '+weekStart +'weekEnd : '+weekEnd);
    
                    // IF TODAY IS NO HOURS (in STANDARD BUSINESS HOURS), 
                    // CALCULATE NEXT WORKING DAYS START AND END TIME
                    if ( startTime == Null && endTime == Null ){
                        // || (Test.isRunningTest() && st_end_null_flag == true)) {
                        Integer i = 0 ;
                        Integer j = 1 ;
    
                        Datetime current_time = System.now();                    
                        Date Todays_Date = Date.newInstance(current_time.year(),current_time.month(),current_time.day());
                        do 
                        {
                            System.debug('in while loop : '+j+' : '+ startTime + ','+endTime);
                            System.debug('Todays_Date : ' +Todays_Date);
                            System.debug('WeekStart : '+weekStart +'weekEnd : '+weekEnd);
                            
                            if (startTime == Null && endTime == Null && Todays_Date == weekEnd){
                                weekStart = weekStart.addDays(+7);
                                weekEnd = weekEnd.addDays(+7);
                            }
                            
                            Map<String,datetime> mapofDatetime_3 = getTime(current_time.addDays(j), current_time.addDays(j).format('EEEE'), c);
                            startTime = mapofDatetime_3.get('startTime');
                            endTime = mapofDatetime_3.get('endTime');
                            
                            if ( startTime != Null && endTime != Null) 
                            {
                                System.debug('in if loop to break while loop..');
                                break;
                            }
                            
                            j++;
                            Todays_Date = Todays_Date.addDays(1);
                        } while (Todays_Date <= weekEnd);
                    }
                    System.debug('After While Loop => Start and End Time : '+ startTime +' : '+ endTime);
                    
                    // CALCULATE END TIME 
                    System.debug('=== CALCULATE END TIME ===');
                    if ( startTime != Null && endTime != Null && (startTime == endTime || 
                         endTime == Datetime.newInstance(endTime.year(),endTime.month(),endTime.day(),00,00,00))) 
                    {
                        System.debug('WeekStart : '+weekStart +' weekEnd : '+weekEnd);
                        Map<String,datetime> mapofDatetime2 = setEndTime(c, endTime, weekStart, weekEnd);
                        System.debug('mapofDatetime2 : '+mapofDatetime2);
                        endTime = mapofDatetime2.get('endTime');
                        
                        Date endDate = Date.newInstance(endTime.year(),endTime.month(),endTime.day());
                        // IF END DATE == WEEKEND DATE & TIME IS 12:00 AM
                        if ( endDate == weekEnd &&
                            endTime == Datetime.newInstance(endTime.year(),endTime.month(),endTime.day(),00,00,00) &&
                           !incomplete_week_flag_endTime )
                        {
                            endTime = endTime.addDays(1);
                        }
                    }
    
                    System.debug('=== CALCULATE START TIME ===');
                    // CALCULATE START TIME 
                    if ( startTime != Null && endTime != Null && 
                        (startTime == endTime || startTime == Datetime.newInstance(startTime.year(),startTime.month(),startTime.day(),00,00,00))) 
                    {
                        System.debug(myDate + ' - '+  weekStart  + ' - '+  weekEnd);
                        System.debug('Start Time : '+startTime);
                        Map<String,datetime> mapofDatetime1 = setStartTime(c, startTime, weekStart, weekEnd);
                        System.debug('mapofDatetime1 : '+mapofDatetime1);
                        startTime = mapofDatetime1.get('startTime');
                    }

                    if (startTime == endTime){
                        endTime = endTime.addDays(1);
                    }
                }
                
                System.debug('Final Start and End Time : '+ startTime +' : '+ endTime);

				// ASSIGN Start and End Time 
                c.Todays_Start_Time__c = startTime;
                c.Todays_End_Time__c = endTime;
 
                c.AH_CaseFlagsEscalationTime_1__c = BusinessHours.add(c.BusinessHoursId, c.AH_Case_Flagged_Date__c, (c.AH_Case_Flags_Age_1_Hours__c*60*60*1000).longValue());
                c.AH_CaseFlagsEscalationTime_2__c = BusinessHours.add(c.BusinessHoursId, c.AH_Case_Flagged_Date__c, (c.AH_Case_Flags_Age_2_Hours__c*60*60*1000).longValue());
                c.AH_CaseFlagsEscalationTime_3__c = BusinessHours.add(c.BusinessHoursId,c.AH_Case_Flagged_Date__c, (c.AH_Case_Flags_Age_3_Hours__c*60*60*1000).longValue());
                c.AH_CaseFlagsEscalationTime_4__c = BusinessHours.add(c.BusinessHoursId,c.AH_Case_Flagged_Date__c, (c.AH_Case_Flags_Age_4_Hours__c*60*60*1000).longValue());

                Date todays_Date = Date.today();
                
                //if (caseId_to_startTime.get(c.id) == NULL && caseId_to_endTime.get(c.id) == NULL){
                if (c.Todays_Start_Time__c == NULL && c.Todays_End_Time__c == NULL){
                    System.debug('Both the dates are NULL..');
                    c.Todays_Start_Time__c = NULL;
                    c.Todays_End_Time__c = NULL;
                }
                else {
                    //Datetime dt1 = caseId_to_endTime.get(c.id);
                    Datetime dt1 = c.Todays_End_Time__c;
                    System.debug('out of if dt1 : '+dt1);
                    Datetime dt = dt1.addDays(-1);
                    Datetime endDate;
                    System.debug('out of if dt : '+dt);
                    
                    //Date TodaysStartTime_Date = Date.newInstance(caseId_to_startTime.get(c.id).year(), caseId_to_startTime.get(c.id).month(), caseId_to_startTime.get(c.id).day());
                    Date TodaysStartTime_Date = Date.newInstance(c.Todays_Start_Time__c.year(), c.Todays_Start_Time__c.month(), c.Todays_Start_Time__c.day());
                    system.debug('c.Todays_Start_Time__c.day()'+c.Todays_Start_Time__c.day());
                    system.debug('TodaysStartTime_Date.toStartofWeek().day()'+TodaysStartTime_Date.toStartofWeek().day());
                    Datetime k;
                    if(TodaysStartTime_Date != todays_Date
                       && c.AH_Case_Flagged_Date__c < TodaysStartTime_Date.toStartofWeek()
                      && (c.Todays_Start_Time__c.day() == TodaysStartTime_Date.toStartofWeek().day()))
                    {
                        system.debug('in if');
                        k = TodaysStartTime_Date.toStartofWeek().addDays(-1);
                    }    
                    else {
                        system.debug('in else');
                        //k = caseId_to_startTime.get(c.id).addDays(-1);
                        k = c.Todays_Start_Time__c.addDays(-1);
                    }
                    endDate = Datetime.newInstance(k.year(),k.month(),k.day(),23,59,00);
                    
                    System.debug('Calculate time from : ' + endDate + '   TO   '+c.AH_Case_Flagged_Date__c);
                    
                    Double finalValue = 0.0;
                    
                    Datetime startTime2 = c.Todays_Start_Time__c;  
                    Datetime endTime2 = c.Todays_End_Time__c;  
                    
                    c.Todays_Start_Time__c = startTime2;
                    c.Todays_End_Time__c = endTime2;
                    if(c.AH_Case_Flagged_Date__c != null && endDate != null) {
                        
                        finalValue = BusinessHours.diff(c.BusinessHoursId, c.AH_Case_Flagged_Date__c, endDate);
                        finalValue = finalValue/3600000;
                        system.debug('finalValue'+finalValue);
                        
                        Decimal d = Decimal.ValueOf(finalValue);
                        d = d.setScale(2);
                        if (d < 0){// || numberDaysDue > 1){
                            d = 0;
                        }
                        c.AH_Previous_Business_Hours__c = d; //Double.valueOf(d);
                       
                    }
                }
                
       
                case_list.add(c);
            }
            System.debug('Case List to be updated : '+case_list);
        } 
        catch (exception e){
            System.debug('Exception occured at line : '+e.getLineNumber() +' => '+e);
        }
        return case_list;
    }
    
    // CALCULATE THE START DATETIME
    private Map<String,datetime> setStartTime (Case c, Datetime stDtTime, Date weekStart, Date weekEnd){
        
        System.debug('Inside setStartTime method.... ipDateTime : ' + stDtTime);
        Map<String,datetime> mapofDatetime = new Map<String,datetime>();
        Map<String,datetime> mapofDatetime1 = new Map<String,datetime>();
        
        mapofDatetime.put('ipDateTime', stDtTime);
        Date ip_Date = Date.newInstance(stDtTime.year(),stDtTime.month(),stDtTime.day());
        
        System.debug('stDtTime Day : ' +stDtTime.day());
        System.debug('weekStart Day : ' +weekStart.day());

        Datetime prevDay = stDtTime.addDays(-1);
        Date prev_Date = Date.newInstance(prevDay.year(),prevDay.month(),prevDay.day());
        String prevdayOfWeek = prevDay.format('EEEE');
		System.debug('Prev Day : '+prevDay);
		
        // GET DATE & TIME OF PREVIOUS DAY
        Map<String,datetime> mapofDatetime_2 = getTime(prevDay, prevdayOfWeek, c);
        Datetime prevDay_startTime = mapofDatetime_2.get('startTime');
		Datetime prevDay_endTime = mapofDatetime_2.get('endTime');
        System.debug('prev start & end time : '+prevDay_startTime + ' '+ prevDay_endTime);		
        
        Time prevDay_endTime_only = null;
        Time ipDay_endTime_only = null;
            
        if (prevDay_startTime != Null && prevDay_endTime != Null ) 
        {
			prevDay_endTime_only = Time.newInstance(prevDay_endTime.hour(),prevDay_endTime.minute(),prevDay_endTime.second(),0);
        	ipDay_endTime_only = Time.newInstance(mapofDatetime.get('ipDateTime').hour(),mapofDatetime.get('ipDateTime').minute(),mapofDatetime.get('ipDateTime').second(),0);
        }
        System.debug('time match in setStartTime method..' +prevDay_endTime_only + ' : '+ ipDay_endTime_only);

        if ( prevDay_startTime != Null && prevDay_endTime != Null && 
            (prevDay_startTime == prevDay_endTime ) && 
            prev_Date > weekStart) 
        {
            System.debug('In first if...');
			mapofDatetime1 = setStartTime(c, prevDay_startTime, weekStart, weekEnd);
		}
        
        // TESTING for one condition
        else if ( prevDay_startTime != Null && prevDay_endTime != Null && 
            prevDay_startTime != prevDay_endTime && prevDay_endTime_only == ipDay_endTime_only && 
            prevDay_endTime_only != NULL && ipDay_endTime_only != NULL && 
            prev_Date >= weekStart) 
        {
            System.debug('In testing if...');
			mapofDatetime1.put('startTime', prevDay_startTime);
		}
        else if ( prevDay_startTime != Null && prevDay_endTime != Null && 
				prevDay_startTime == prevDay_endTime && 
				prev_Date == weekStart) 
        {
			System.debug('In second if...');
            mapofDatetime1.put('startTime', prevDay_startTime);
        }
        else if ( prevDay_startTime != Null && prevDay_endTime != Null &&
				prevDay_startTime != prevDay_endTime &&
                prev_Date >= weekStart)
        {
            System.debug('in third if.. : '+mapofDatetime.get('ipDateTime'));
			mapofDatetime1.put('startTime', mapofDatetime.get('ipDateTime'));
        }
        else if (prevDay_startTime == Null && prevDay_endTime == Null &&
                prev_Date >= weekStart)
        {
            System.debug('in last else');
            mapofDatetime1.put('startTime', mapofDatetime.get('ipDateTime'));
        }
		// ===== ADDED on LATER 1 ===== working fine
        else if (prevDay_startTime != Null && prevDay_endTime != Null &&
                prev_Date <= weekStart)
        {
            System.debug('in lastest if');
            mapofDatetime1.put('startTime', mapofDatetime.get('ipDateTime'));
        }
        // ===== ADDED LATER =====
        // ===== ADDED LATER 2 =====
        else if (prevDay_startTime == Null && prevDay_endTime == Null &&
                prev_Date <= weekStart)
        {
            System.debug('in last else');
            mapofDatetime1.put('startTime', mapofDatetime.get('ipDateTime'));
        }

        System.debug('mapofDatetime : '+mapofDatetime1);
        return mapofDatetime1;
    }

    // CALCULATE THE END DATETIME 
    private Map<String,datetime> setEndTime (Case c, Datetime endDtTime, Date weekStart, Date weekEnd){
        
        System.debug('Inside setEndTime method....' + endDtTime); 
        Map<String,datetime> mapofDatetime = new Map<String,datetime>();
        Map<String,datetime> mapofDatetime1 = new Map<String,datetime>();
        
        mapofDatetime.put('ipDateTime', endDtTime); 
        
        Date ip_Date = Date.newInstance(endDtTime.year(),endDtTime.month(),endDtTime.day());
        
        System.debug('endDtTime Day : ' +endDtTime.day());
        System.debug('weekEnd Day : ' +weekEnd.day());

		// FIND NEXT DAY BASED ON CURRENT END  DATETIME PASSED HERE
        Datetime nextDay = endDtTime.addDays(+1);
        Date next_Date = Date.newInstance(nextDay.year(),nextDay.month(),nextDay.day());
        String nextDayOfWeek = nextDay.format('EEEE');
		System.debug('next Day : '+nextDay);
		
        // GET NEXT DAYs DATE & TIME, USING getTime FUNCTION
        Map<String,datetime> mapofDatetime_2 = getTime(nextDay, nextDayOfWeek, c);
        Datetime nextDay_startTime = mapofDatetime_2.get('startTime');
		Datetime nextDay_endTime = mapofDatetime_2.get('endTime');
        System.debug('Next start & end time : '+ nextDay_startTime + ' '+ nextDay_endTime);		
        
        // when next datetime == NULL  &  ip endDateTime is 12:00 AM  &  ipDateTime < weekend day
		if (nextDay_startTime == NULL && nextDay_endTime == NULL &&
           	mapofDatetime.get('ipDateTime') == Datetime.newInstance(mapofDatetime.get('ipDateTime').year(),mapofDatetime.get('ipDateTime').month(),mapofDatetime.get('ipDateTime').day(),00,00,00) &&
           ip_Date < weekEnd)
        {
            System.debug('in first topmost if');
            mapofDatetime1.put('endTime', mapofDatetime.get('ipDateTime').addDays(1));
            incomplete_week_flag_endTime = true;
        }
       
		// CHECK FOR NEXT DAYS ENDTIME USING RECURSION
        else if ( nextDay_startTime != Null && nextDay_endTime != Null && 
            nextDay_startTime == nextDay_endTime && 
            next_Date < weekEnd) 
        {
            System.debug('In RECURSION if...');
			mapofDatetime1 = setEndTime(c, nextDay_endTime, weekStart, weekEnd);
		}
        // next datetime != NULL  &  next start and end time is SAME  &  next day == week end day 
        else if ( nextDay_startTime != Null && nextDay_endTime != Null && 
				nextDay_startTime == nextDay_endTime && 
				next_Date == weekEnd) 
        {
			System.debug('In second if...');
            mapofDatetime1.put('endTime', nextDay_endTime);
        }
        
        // next datetime != NULL  &  next datetime != SAME  &  nextDay <= weekend day  &  next startTime = 12:00 AM
        else if ( nextDay_startTime != Null && nextDay_endTime != Null &&
				nextDay_startTime != nextDay_endTime &&
                next_Date <= weekEnd &&
                nextDay_startTime == Datetime.newInstance(nextDay_startTime.year(),nextDay_startTime.month(),nextDay_startTime.day(),00,00,00))
        {
            System.debug('in trird if.. : ');
			mapofDatetime1.put('endTime', nextDay_endTime);
        }
        
        // next datetime != NULL  &  next datetime != SAME  &  nextDay <= weekend day
        else if ( nextDay_startTime != Null && nextDay_endTime != Null &&
				nextDay_startTime != nextDay_endTime &&
                next_Date <= weekEnd)
        {
            System.debug('in last if.. : '+mapofDatetime.get('ipDateTime'));
			//mapofDatetime1.put('endTime', mapofDatetime.get('ipDateTime')); //added 8:21 PM FRIDAY 25 JAN
			mapofDatetime1.put('endTime', mapofDatetime.get('ipDateTime').addDays(1));
        }
        
        //
        else if (nextDay_startTime != Null && nextDay_endTime != Null &&
                next_Date <= weekEnd)
        {
            System.debug('in last else if');
            mapofDatetime1.put('endTime', mapofDatetime.get('ipDateTime'));
        }
        else if (nextDay_startTime != Null && nextDay_endTime != Null) {
            System.debug('in last else');
            mapofDatetime1.put('endTime', nextDay_endTime);
        }
        
        // ADDED on SUNDAY =====
        else if (nextDay_startTime == Null && nextDay_endTime == Null &&
                next_Date >= weekEnd)
        {
            System.debug('in last else if');
            mapofDatetime1.put('endTime', mapofDatetime.get('ipDateTime'));
        }
        
        System.debug('mapofDatetime1 : '+mapofDatetime1);
        return mapofDatetime1;
    }

    private Map<String,datetime> getTime (Datetime DateAndTime, String dayOfWeek, Case c) {
        
        System.debug('===== Inside getTime method =====');
        Map<String,datetime> mapofDatetime = new Map<String,datetime>();
        Datetime startTime;
        Datetime endTime;
		Date thisDate = Date.newInstance(DateAndTime.year(),DateAndTime.month(),DateAndTime.day());
        System.debug('Inside getTime dayOfWeek : '+dayOfWeek);
        
        if (dayOfWeek == 'Monday'){
            if (c.BusinessHours.MondayStartTime == NULL && c.BusinessHours.MondayEndTime == NULL){
                startTime = Null;
                endTime = Null;
            }
            else {
                startTime = Datetime.newInstance(thisDate, c.BusinessHours.MondayStartTime); 
                endTime = Datetime.newInstance(thisDate, c.BusinessHours.MondayEndTime); 
            }
        }
        else if (dayOfWeek == 'Tuesday'){
            if (c.BusinessHours.TuesdayStartTime == NULL && c.BusinessHours.TuesdayEndTime == NULL){
                startTime = Null;
                endTime = Null;
            }
            else {
                startTime = Datetime.newInstance(thisDate, c.BusinessHours.TuesdayStartTime); 
                endTime = Datetime.newInstance(thisDate, c.BusinessHours.TuesdayEndTime); 
            }
        }
        else if (dayOfWeek == 'Wednesday'){
            if (c.BusinessHours.WednesdayStartTime == NULL && c.BusinessHours.WednesdayEndTime == NULL){
                startTime = Null;
                endTime = Null;
            }
            else {
                startTime = Datetime.newInstance(thisDate, c.BusinessHours.WednesdayStartTime); 
                endTime = Datetime.newInstance(thisDate, c.BusinessHours.WednesdayEndTime); 
            }
        }
        else if (dayOfWeek == 'Thursday'){
            if (c.BusinessHours.ThursdayStartTime == NULL && c.BusinessHours.ThursdayEndTime == NULL){
                startTime = Null;
                endTime = Null;
            }
            else {
                startTime = Datetime.newInstance(thisDate, c.BusinessHours.ThursdayStartTime); 
                endTime = Datetime.newInstance(thisDate, c.BusinessHours.ThursdayEndTime); 
            }
        }
        else if (dayOfWeek == 'Friday'){
            if (c.BusinessHours.FridayStartTime == NULL && c.BusinessHours.FridayEndTime == NULL){
                startTime = Null;
                endTime = Null;
            }
            else {
                startTime = Datetime.newInstance(thisDate, c.BusinessHours.FridayStartTime); 
                endTime = Datetime.newInstance(thisDate, c.BusinessHours.FridayEndTime); 
            }
        }
        else if (dayOfWeek == 'Saturday'){
            if (c.BusinessHours.SaturdayStartTime == NULL && c.BusinessHours.SaturdayEndTime == NULL){
                startTime = Null;
                endTime = Null;
            }
            else {
                startTime = Datetime.newInstance(thisDate, c.BusinessHours.SaturdayStartTime); 
                endTime = Datetime.newInstance(thisDate, c.BusinessHours.SaturdayEndTime); 
            }
        } 
        else if (dayOfWeek == 'Sunday'){
            if (c.BusinessHours.SundayStartTime == NULL && c.BusinessHours.SundayEndTime == NULL){
                startTime = Null;
                endTime = Null;
            }
            else {
                startTime = Datetime.newInstance(thisDate, c.BusinessHours.SundayStartTime); 
                endTime = Datetime.newInstance(thisDate, c.BusinessHours.SundayEndTime); 
            }
        }
		mapofDatetime.put('startTime',startTime);
		mapofDatetime.put('endTime',endTime);
        
        return mapofDatetime;
    }
}