/************************************************************************************************
Name            : FillAccountSchedule Schedulable Class
Author          : Artem Glynskyi 
Created Date    : 02/01/2013
Last Mod Date   : 05/03/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-006221
Description     : 
                : 
*************************************************************************************************/
global class FillAccountSchedule implements Schedulable
{
	
	global Boolean isTest {get; set;}				// isTest Switch
	private string[] ids;							// An array of Account ids
	private Integer everyHours;						// Job frequency in hours
	public String schedName {get; private set;}	// Scheduled Job Name
	
	// METHOD THAT SETS THE ATTRIBUTES OF THE APEX JOB TO BE SCHEDULED. 
	// Called by apex / OrgsInfo "Schedule" Button.
	// ===========================================================================
	// ids = An array of Account ids
	// everyHours = Job frequency in hours
	// schedName = Scheduled Job Name
	global FillAccountSchedule(string[] ids, Integer everyHours, string schedName) 
	{
		this.ids = ids;
		this.everyHours = everyHours;
		this.schedName = schedName; 
		isTest = false;
	}
	
	// METHOD THAT EXECUTES BATCHABLE CLASS, SETS NEXT RUN TIME, THEN SCHEDULES NEXT JOB
	global void execute(SchedulableContext sc) 
	{
    	String schedTime = getNextRun(DateTime.now().addHours(everyHours));
    	
    	// IF NOT IN TEST MODE
    	if (!isTest) 
    	{ 
    		Database.executeBatch(new FillAccountBatch(ids), 1);
    		system.abortJob(sc.getTriggerId()); 
    		system.schedule(schedName, schedTime, this);
    	}
	}
	
	// METHOD THAT BUILDS THE CRONTRIGGER EXPRESSION FROM A DATETIME VALUE PASSED IN
    private String getNextRun(DateTime dt) 
    {		
        return '0 ' + string.valueOf(dt.minute()) + ' ' + string.valueOf(dt.hour()) + ' ' + string.valueOf(dt.day()) + ' ' + string.valueOf(dt.month()) + ' ' + '? ' + string.valueOf(dt.year());
    }
	
}