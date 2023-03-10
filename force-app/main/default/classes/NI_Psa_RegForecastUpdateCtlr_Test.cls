/****************************************************************************************
Name            : NI_Psa_RegForecastUpdateCtlr_Test Class
Author          : Stuart Emery
Created Date    : 1/10/2014
Last Mod Date   : 9/21/2018
Last Mod By     : BHULESHWAR DESHPANDE
NICC Reference  : NICC-009265
Description     : Test Class for the NI_Psa_RegForecastUpdateCtlr Controller
:            
******************************************************************************************/

@isTest(SeeAllData=false)
private class NI_Psa_RegForecastUpdateCtlr_Test 
{
    
    static testMethod void myUnitTest() 
    {
        
        Opportunity o = new Opportunity();
        
        //PAGE REFERENCE
        //PageReference pageRef = Page.NI_SoftraxAssetsOpportunityVF;
        //Test.setCurrentPage(pageRef);
        
        //CREATE A TEST TIME PERIOD RECORD
        List<pse__Time_Period__c> lstTimePeriodsToInsert = new List<pse__Time_Period__c>();  
        pse__Time_Period__c t = new pse__Time_Period__c();
        t.Name = 'TEST TIME PERDIOD';
        t.pse__Start_Date__c = Date.NewInstance(2014, 01, 01);
        t.pse__End_Date__c = Date.NewInstance(2014, 01, 31);
        lstTimePeriodsToInsert.add(t);
        
        Database.insert(lstTimePeriodsToInsert);
        
        system.assert(t.Id != null);
        
        //CREATE A TEST REGION RECORD
        List<pse__Region__c> lstRegionsToInsert = new List<pse__Region__c>();  
        pse__Region__c r = new pse__Region__c();
        t.Name = 'TEST REGION';
        lstRegionsToInsert.add(r);
        
        Database.insert(lstRegionsToInsert);
        
        system.assert(r.Id != null);
        
        //CREATE A TEST FORECAST RECORD
        List<pse__Forecast__c> lstForecastsToInsert = new List<pse__Forecast__c>();  
        pse__Forecast__c f = new pse__Forecast__c();
        f.pse__Region__c = r.Id;
        f.pse__Time_Period__c = t.Id;
        lstForecastsToInsert.add(f);
        
        Database.insert(lstForecastsToInsert);
        
        //INSTANTIATE CONTROLLER
        NI_Psa_RegForecastUpdateCtlr ctrl = new NI_Psa_RegForecastUpdateCtlr(new ApexPages.StandardController(r));            
        
        ctrl.disableListEdit();
        
        ctrl.EnableListEdit();
        ctrl.save();
        ctrl.search();
        
        
        // ADDED BY BHULESHWAR ON 09/21/2018
        //CREATE A TEST REGION RECORD
        pse__Region__c r2 = NI_TestClassData.createTestRegion(2, 'TEST REGION');
        Database.insert(r2);
        system.assert(r2.Id != null);
        
        // CREATE A TEST PRACTICE
        pse__Practice__c pr2 = NI_TestClassData.createTestPractice(2, 'TEST PRACTICE');
        Database.insert(pr2);
        system.assert(pr2.Id != null);
        
        // CREATE A TEST GROUP
        pse__Grp__c gr2 = new pse__Grp__c();
        gr2.Name = 'TEST GROUP 2';
        Database.insert(gr2);
        system.assert(gr2.Id != null);
        
        //CREATE A TEST FORECAST RECORD
        pse__Forecast__c f2 = new pse__Forecast__c();
        f2.pse__Region__c = r2.Id;
        f2.pse__Time_Period__c = t.Id;
        f2.pse__Group__c = gr2.Id;
        f2.pse__Practice__c = pr2.Id;
        Database.insert(f2);
        system.assert(f2.Id != null);
        
        ctrl.forecast.pse__Region__c = r2.id;
        ctrl.forecast.pse__Group__c = gr2.id;
        ctrl.forecast.pse__Practice__c = pr2.id;
        ctrl.search();
        system.assertEquals(0, ctrl.lstFcast.size(), 'Error in result size..');
     }
}