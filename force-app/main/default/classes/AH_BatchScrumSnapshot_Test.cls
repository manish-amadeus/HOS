/****************************************************************************************
Name            : AH_BatchScrumSnapshot_Test
Author          : Shashikant Nikam
Created Date    : 6/27/2018
Modified Date	: 6/27/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_BatchScrumSnapshot apex class
******************************************************************************************/
@isTest
public class AH_BatchScrumSnapshot_Test {

    @testsetup
    static void createTestData (){
        
        //CREATE A TEST ACCOUNT  
        List<Services_Scrum_Snapshot__c> sn_list = new List<Services_Scrum_Snapshot__c>();
        for (Integer i=0; i<1; i++){
            Services_Scrum_Snapshot__c sn = new Services_Scrum_Snapshot__c();
            
            sn.Actual_Amount__c 	= 100;
            sn.Backlog_Amount__c 	= 20;
            sn.Budget_Amount__c 	= 200;
            sn.Comp_Amount__c 		= 150;
            sn.Date_of_Pull__c	 	= Date.today();
            sn.Downside_Amount__c 	= 12;
            sn.Forecast_Amount__c	= 250;
            sn.Group__c 			= 'Group_'+i;
            sn.Service_Group__c 	= 'Practice_'+i;
            sn.Region_Name__c 		= 'Region_'+i;
            sn.Reimbursable_Expenses__c = 300;
            sn.Scheduled_Amount__c 	= 240;
            sn.Scheduled_Hours__c 	= 2;
            sn.Target_Period__c 	= '2';
            sn.Tentative_Value__c 	= 150;
            sn.Upside_Amount__c 	= 150;
            
            sn_list.add(sn);
        }
        
        Database.insert(sn_list);
        
        // ASSERT STATEMENTS HERE
        List<Services_Scrum_Snapshot__c> sn_list1 = [SELECT id, Name from Services_Scrum_Snapshot__c];
        system.assertEquals(1, sn_list1.size(), 'Record count mismatch..');
    }
    
    @isTest
    static void test1 (){
        
        //List<Services_Scrum_Snapshot__c> sn_list1 = [select ID, Name, Actual_Amount__c, Backlog_Amount__c, Budget_Amount__c, Comp_Amount__c,Date_of_Pull__c, Downside_Amount__c, Forecast_Amount__c, Group__c, Service_Group__c, Region_Name__c, Reimbursable_Expenses__c, Scheduled_Amount__c, Scheduled_Hours__c, Target_Period__c, Tentative_Value__c, Upside_Amount__c from Services_Scrum_Snapshot__c];
        
        Datetime n = Datetime.now();                                                                                                                                                                                   
        n = n.addMinutes(5);                                                                                      
        String CRON_EXP = '0 ' + n.format('m') + ' ' + n.format('H') + ' ' + n.format('d') + ' ' + n.format('M') + ' ? '+ n.format('yyyy');

        Test.StartTest();
        AH_ScheduleBatchScrumSnapshot sh1 = new AH_ScheduleBatchScrumSnapshot();
        system.schedule('Test', CRON_EXP, sh1);
        Test.stopTest();
        List<AsyncApexJob> asyncJob = new List<AsyncApexJob>();
        asyncJob = [SELECT ApexClassId, CompletedDate, CreatedById, CreatedDate, Id, NumberOfErrors, Status
                    FROM AsyncApexJob
                    WHERE Status = 'Completed'
                    AND ApexClassId IN (Select Id from ApexClass where Name = 'AH_BatchScrumSnapshot')
                    ORDER BY CompletedDate DESC];
        System.debug('AsyncJob : '+asyncJob);
    }
}