/****************************************************************************************
Name            : NI_MilestoneForecast_TriggerHandler_Test Class
Author          : Stuart Emery
Created Date    : 5/1/2014
Last Mod Date   : 5/7/2014 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-010123
Description     : Test Class for the NI_MilestoneForecast_TriggerHandler Class
                : 
******************************************************************************************/
@isTest (SeeAllData=true)
private class NI_MilestoneForecast_TriggerHandler_Test 
{
    
  //SINGLE INSERT TEST METHOD  
    static testMethod void singleInsertTest() 
    {    
        //ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT  
        pse__Triggers__c pt = [SELECT Id, pse__Resource_Geolocation_Trigger_Disabled__c FROM pse__Triggers__c]; 
        pt.pse__Resource_Geolocation_Trigger_Disabled__c = true;
        update(pt); 
        
        NI_MilestoneForecast_TriggerHandler handler = new NI_MilestoneForecast_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
       
        pse__Region__c defaultRegion =  NI_TestClassData.createTestRegion(1, 'psaTestRegion');
        insert defaultRegion; 
       
        pse__Practice__c defaultPractice = NI_TestClassData.createTestPractice(1, 'psaTestPractice');
        insert defaultPractice;  
          
      //CREATE A PROJECT
        pse__Proj__c tp = NI_TestClassData.createTestProject(1,'Assignment/Milestone Date Test Project', defaultRegion, defaultPractice, 'Draft', null);
        insert tp;
        
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('PSA Test Milestone', tp, false, false, 'Billable Milestone');
        insert milestone;  
                
        test.StartTest();
      
      //CREATE A MILESTONE FORECAST RECORD
        Date dt = Date.TODAY(); //GET THE CURRENT DATE
        
        Milestone_Forecast__c mf = new Milestone_Forecast__c();
        mf.Milestone__c = milestone.Id;
        mf.Forecast_Date__c = dt;
        insert mf;
        
       test.StopTest();
     
       Milestone_Forecast__c insertedMF = [SELECT Id, Forecast_Date__c, Forecast_Period__c FROM Milestone_Forecast__c WHERE Id = :mf.Id];
       
        system.debug('insertedMF'+insertedMF);
        
     //GET A LIST OF ALL MONTH TIME PERIODS
     //
     ///CREATE A TEST TIME PERIOD RECORD
        List<pse__Time_Period__c> lstTimePeriodsToInsert = new List<pse__Time_Period__c>();  
        pse__Time_Period__c tperiod = new pse__Time_Period__c();
        tperiod.Name = insertedMF.Forecast_Period__c;
        //tperiod.pse__Start_Date__c = Date.NewInstance(2014, 01, 01);
        tperiod.pse__Start_Date__c = Date.today().addDays(-2);
        //tperiod.pse__End_Date__c = Date.NewInstance(2014, 01, 31);
        tperiod.pse__End_Date__c = Date.today().addDays(30);
        tperiod.pse__Type__c = 'Month';
        lstTimePeriodsToInsert.add(tperiod);
               
        Database.insert(lstTimePeriodsToInsert);
        
        system.debug('tperiod'+tperiod);
       /*pse__Time_Period__c tperiod = [SELECT Name, pse__Start_Date__c, pse__End_Date__c, pse__Type__c
       FROM pse__Time_Period__c 
       WHERE pse__Type__c = 'Month'
       AND Name = :insertedMF.Forecast_Period__c LIMIT 1]; */
       
     //VERIFY THAT THE FORECAST PERIOD ON THE MILESTONE FORECAST EQUALS THE NAME OF THE TIME PERIOD RECORD  
       System.AssertEquals(tperiod.Name,insertedMF.Forecast_Period__c); 
       
     //TEST FOR NULL FORECAST DATE  
       insertedMF.Forecast_Date__c = null;
       update insertedMF;
       
     //TEST FOR NO MATCHING TIME PERIOD  
       insertedMF.Forecast_Date__c = Date.newInstance(2025, 12, 31);
       update insertedMF;  
       
            
    }

//=======================================================================================================    
  //BULK INSERT TEST METHOD  
    static testMethod void bulkInsertTest() 
    {    
        //ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT  
        pse__Triggers__c pt = [SELECT Id, pse__Resource_Geolocation_Trigger_Disabled__c FROM pse__Triggers__c]; 
        pt.pse__Resource_Geolocation_Trigger_Disabled__c = true;
        update(pt); 
        
        NI_MilestoneForecast_TriggerHandler handler = new NI_MilestoneForecast_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
       
        pse__Region__c defaultRegion =  NI_TestClassData.createTestRegion(1, 'psaTestRegion');
        insert defaultRegion; 
       
        pse__Practice__c defaultPractice = NI_TestClassData.createTestPractice(1, 'psaTestPractice');
        insert defaultPractice;  
          
      //CREATE A PROJECT
        pse__Proj__c tp = NI_TestClassData.createTestProject(1,'Assignment/Milestone Date Test Project', defaultRegion, defaultPractice, 'Draft', null);
        insert tp;
        
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('PSA Test Milestone', tp, false, false, 'Billable Milestone');
        insert milestone;  
                
        test.StartTest();
      Date dt = Date.TODAY(); //GET THE CURRENT DATE
        
         ///CREATE A TEST TIME PERIOD RECORD
        List<pse__Time_Period__c> lstTimePeriodsToInsert = new List<pse__Time_Period__c>();  
        pse__Time_Period__c tperiod = new pse__Time_Period__c();
        //tperiod.Name = insertedMF.Forecast_Period__c;
        //tperiod.pse__Start_Date__c = Date.NewInstance(2014, 01, 01);
        tperiod.pse__Start_Date__c = Date.today();
        //tperiod.pse__Start_Date__c = Date.today().addDays(-2);
        //tperiod.pse__End_Date__c = Date.NewInstance(2014, 01, 31);
        tperiod.pse__End_Date__c = Date.today().addDays(30);
        tperiod.pse__Type__c = 'Month';
     //   tperiod.Name =
        lstTimePeriodsToInsert.add(tperiod);
               
        Database.insert(lstTimePeriodsToInsert);
        
        system.debug('tperiod'+tperiod);
        
      //CREATE A MILESTONE FORECAST RECORD
        
        
      //LIST TO HOLD THE MIULESTONE FORECAST RECORDS TO INSERT
        List<Milestone_Forecast__c> lstMFToInsert = new List<Milestone_Forecast__c>();  
        for (Integer j=0;j<25;j++) 
            {
              Milestone_Forecast__c mf = new Milestone_Forecast__c();
              mf.Milestone__c = milestone.Id;
              mf.Forecast_Date__c = dt;
              lstMFToInsert.add(mf);
            }  
        Database.insert(lstMFToInsert);
        
       test.StopTest();
     
       List<Milestone_Forecast__c> insertedMF = [SELECT Id, Forecast_Date__c, Forecast_Period__c FROM Milestone_Forecast__c WHERE Id IN :lstMFToInsert];
       
     //GET THE MONTH TIME PERIOD FOR THE dt DATE
     /*  pse__Time_Period__c tperiod = [SELECT Name, pse__Start_Date__c, pse__End_Date__c, pse__Type__c
       FROM pse__Time_Period__c 
       WHERE pse__Type__c = 'Month'
       AND pse__Start_Date__c <= :dt
       AND pse__End_Date__c >= :dt LIMIT 1];*/
        
       
       for(Milestone_Forecast__c m : insertedMF)
          {         
             //VERIFY THAT THE FORECAST PERIOD ON THE MILESTONE FORECAST EQUALS THE NAME OF THE TIME PERIOD RECORD  
               System.AssertEquals(tperiod.pse__Start_Date__c,m.Forecast_Date__c);
          }      
            
    }
     
    
}