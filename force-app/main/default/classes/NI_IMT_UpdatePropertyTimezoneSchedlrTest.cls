/****************************************************************************************
Name            : NI_IMT_UpdatePropertyTimezoneSchedlrTest Class
Author          : Damodar Raut
Created Date    : 04/25/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Test Class that handles all test code for the NI_IMT_UpdatePropertyTimezoneScheduler class
				: 
				: 
******************************************************************************************/
@isTest
public with sharing class NI_IMT_UpdatePropertyTimezoneSchedlrTest {

	// CRON expression: midnight on March 15.
	// Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void test() {
      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new NI_IMT_UpdatePropertyTimezoneScheduler());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
      Test.stopTest();

   }
}