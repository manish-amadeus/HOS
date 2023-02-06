/*

IMPORTANT!

BEFORE SCHEDULING, ADD YOURSELF TO THE "Validation Rule Exempt User" Permission Set:
https://amadeus-hospitality--sbfull.lightning.force.com/0PS320000000VAD
After the apex job Completes, delete the scheduled job so it doesn't run in future AND

REMOVE YOURSELF FROM THE "Validation Rule Exempt User" Permission Set
String hour = String.valueOf(Datetime.now().hour());
String min = String.valueOf(Datetime.now().minute() + 2);
String ss = String.valueOf(Datetime.now().second());
String strCronEx = ss + ' ' + min + ' ' + hour + ' * * ?';
INIT_MassUpdateContactEmailsSched.scheduleIt(strCronEx);

*/

global class INIT_MassUpdateContactEmailsSched implements Schedulable 
{

   // RUN INIT_MassUpdateContactEmailsSched.scheduleIt(); IN DEV CONSOLE TO CREATE SCHEDULED APEX JOB
   global static String scheduleIt(String CRON_EXP)
   {
       INIT_MassUpdateContactEmailsSched sched = new INIT_MassUpdateContactEmailsSched();
       return System.schedule('Mass Update Contact Emails', CRON_EXP, sched);
   }   
   
   global void execute(SchedulableContext sc)
   {
       INIT_MassUpdateContactEmailsBatch b = new INIT_MassUpdateContactEmailsBatch();
       ID batchprocessid = Database.executeBatch(b);
   }       
   
}