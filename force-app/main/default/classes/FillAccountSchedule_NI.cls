/************************************************************************************************
Name            : FillAccountSchedule_NI Schedulable Class
Author          : Sean Harris 
Created Date    : 07/24/2013
Last Mod By     : 
Last Mod Date   : 
NICC Reference  : NICC-006221
Description     : Created this version to be able to schedule by day and not by hour
                : 
                : 
*************************************************************************************************/
global class FillAccountSchedule_NI implements Schedulable
{
    
    global Boolean isTest { get; set; }  // isTest Switch
    
    global FillAccountSchedule_NI() 
    {
        isTest = false;
    }
    
    // METHOD THAT EXECUTES BATCHABLE CLASS, SETS NEXT RUN TIME, THEN SCHEDULES NEXT JOB
    global void execute(SchedulableContext sc) 
    {
        String schedTime = getNextRun(DateTime.now().addDays(1));
        
        // IF NOT IN TEST MODE
        if (!isTest) 
        { 
            string[] ids;
            Database.executeBatch(new FillAccountBatch(ids), 1);
            system.abortJob(sc.getTriggerId()); 
            System.schedule('HRM Polling Job - ' + schedTime, schedTime, this);
        }
    }
    
    // METHOD THAT BUILDS THE CRONTRIGGER EXPRESSION FROM A DATETIME VALUE PASSED IN
    private String getNextRun(DateTime dt) 
    {       
        return '0 ' + 
               string.valueOf(dt.minute()) + ' ' +
               string.valueOf(dt.hour()) + ' ' + 
               string.valueOf(dt.day()) + ' ' +
               string.valueOf(dt.month()) + ' ' + 
               '? '  + 
               string.valueOf(dt.year());
    }
    
}