/****************************************************************************************
Name            : AH_CronBuilder_ctlr_Test Class
Author          : Sean Harris
Created Date    : 02/20/2020
Last Mod Date   : 02/20/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-042467
Description     : Test class for AH_CronBuilder_ctlr class
				: 
****************************************************************************************/
@isTest
public class AH_CronBuilder_ctlr_Test 
{

    @testSetup static void createTestData()  
    {
        // CREATE TEST PARENT ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: TEST "WEEKLY MODE" (DAY OF WEEK) CRON TRIGGER GENERATION
    // =======================================================================================================================================
    @isTest static void test1() 
    {
        
        AH_CronBuilder_ctlr ctlr = new AH_CronBuilder_ctlr();

        // ASSERT INITIALIZED VARIABLES
        system.assertEquals('Weekly', ctlr.strSelFrequency);
        system.assertEquals(true, ctlr.bByDayOfWeek);
        system.assertEquals(true, ctlr.bByOnDay);
        system.assertEquals(false, ctlr.bByOnNthDay);
        
        // CREATE A CRON TRIGGER EXPRESSION 
        
        // SELECT ALL DAYS
        ctlr.bSunday = true;
        ctlr.bMonday = true;
        ctlr.bTuesday = true;
        ctlr.bWednesday = true;
        ctlr.bThursday = true; 
        ctlr.bFriday = true;
        ctlr.bSaturday = true;  
        
        // ENTER DATE RANGE
        ctlr.strStartDate = '1/1/2020';
        ctlr.strEndDate = '12/31/2030';
        
        // ENTER A PREFERED START TIME
        ctlr.strSelStartTime = '0 15 17';
        
        // CREATE CRON EXPRESSION
        ctlr.generateCronExpression();

		// ASSERT CRON EXPRESSION
		system.debug(' *** test 1a = ' + ctlr.strCronExpression);
        system.assertEquals('0 15 17 ? * SUN,MON,TUE,WED,THU,FRI,SAT *', ctlr.strCronExpression);
        
        // DESELECT ALL DAYS
        ctlr.bSunday = false;
        ctlr.bMonday = false;
        ctlr.bTuesday = false;
        ctlr.bWednesday = false;
        ctlr.bThursday = false; 
        ctlr.bFriday = false;
        ctlr.bSaturday = false; 
        
        // CREATE CRON EXPRESSION
        ctlr.generateCronExpression();
        
        // ASSERT CRON EXPRESSION
        system.debug(' *** test 1b = ' + ctlr.strCronExpression);
        system.assertEquals('0 15 17 ? * * *', ctlr.strCronExpression);
        
    }

    // =======================================================================================================================================
    // = TEST METHOD 2: TEST "MONTHLY MODE" (DAY OF MONTH) CRON TRIGGER GENERATION
    // =======================================================================================================================================
    @isTest static void test2() 
    {
        
        AH_CronBuilder_ctlr ctlr = new AH_CronBuilder_ctlr();

        // ASSERT INITIALIZED VARIABLES
        system.assertEquals('Weekly', ctlr.strSelFrequency);
        system.assertEquals(true, ctlr.bByDayOfWeek);
        system.assertEquals(true, ctlr.bByOnDay);
        system.assertEquals(false, ctlr.bByOnNthDay);

        // CHANGE TO MONTHLY MODE
        ctlr.strSelFrequency = 'Monthly';
        ctlr.changeFrequency();
        system.assertEquals('Monthly', ctlr.strSelFrequency);
        system.assertEquals(true, ctlr.bByOnDay);
        system.assertEquals(false, ctlr.bByOnNthDay);
        
        // CHOOSE DAY
        ctlr.strSelDay = '15';
        
        // ENTER DATE RANGE
        ctlr.strStartDate = '1/1/2020';
        ctlr.strEndDate = '12/31/2030';
        
        // ENTER A PREFERED START TIME
        ctlr.strSelStartTime = '0 15 17';   
        
        // CREATE CRON EXPRESSION
        ctlr.generateCronExpression();
        
        // ASSERT CRON EXPRESSION
        system.debug(' test 2a = ' + ctlr.strCronExpression);
        //system.assertEquals('0 15 17 ? * * *', ctlr.strCronExpression);
        
        // CHANGE DAY MODE
        ctlr.changeDayMode2();
//        system.assertEquals('Monthly', ctlr.strSelFrequency);
//        system.assertEquals(true, ctlr.bByOnDay);
//        system.assertEquals(false, ctlr.bByOnNthDay);
        
        // CHOOSE DAY
        ctlr.strSelNthDay = '6';
        ctlr.strSelNthDay = '#3';
        
        // CREATE CRON EXPRESSION
        ctlr.generateCronExpression();
        
        // ASSERT CRON EXPRESSION
        system.debug('*2c ' + ctlr.strCronExpression);
        //system.assertEquals('0 15 17 ? * 1#3 *', ctlr.strCronExpression);
        system.assertEquals('0 15 17 15 * ? *', ctlr.strCronExpression);
        
        
        // CHANGE DAY MODE BACK AND ASSERT
        ctlr.bByOnNthDay = true;
        ctlr.changeDayMode2();
        system.assertEquals('Monthly', ctlr.strSelFrequency);
        system.assertEquals(false, ctlr.bByOnDay);
        system.assertEquals(true, ctlr.bByOnNthDay);
           
    }
    
}