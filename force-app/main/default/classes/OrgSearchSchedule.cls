/************************************************************************************************
Name            : OrgSearchSchedule - Schedulable class
Author          : Michael Pedro
Last Mod Date   : 05/05/2022
Last Mod By     : Michael Pedro
Description     : Class for scheduling org searches 
*************************************************************************************************/

global class OrgSearchSchedule implements Schedulable
{
	
	private string[] ids;
	private Integer interval;
	public String schedName {get; private set;}	
	global Boolean isTest {get; set;}				// isTest Switch
	
	
	global OrgSearchSchedule(string[] ids, Integer interval, string name) 
	{
		this.ids = ids;
		this.interval = interval;
		this.schedName = name; 
		isTest = false;
	}
	
	global void execute(SchedulableContext sc) 
	{
    	String schedTime = getNextRun(DateTime.now().addHours(interval));
		if (!isTest) 
    	{ 
			Database.executeBatch(new OrgInfoBatch(ids), 1);
			system.abortJob(sc.getTriggerId()); 
			system.schedule(schedName, schedTime, this);
		}
	}
	
    private String getNextRun(DateTime dt) 
    {		
        return '0 ' + string.valueOf(dt.minute()) + ' ' + string.valueOf(dt.hour()) + ' ' + string.valueOf(dt.day()) + ' ' + string.valueOf(dt.month()) + ' ' + '? ' + string.valueOf(dt.year());
    }
	
}