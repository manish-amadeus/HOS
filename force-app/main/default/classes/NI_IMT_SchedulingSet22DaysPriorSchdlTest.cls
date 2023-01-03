/****************************************************************************************
Name            : NI_IMT_SchedulingSet22DaysPriorSchdlTest Class
Author          : Damodar Raut
Created Date    : 05/23/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Test Class that handles all test code for the NI_IMT_SchedulingSet22DaysPriorScheduler class
                : 
                : 
******************************************************************************************/
@IsTest
public with sharing class NI_IMT_SchedulingSet22DaysPriorSchdlTest {
    // CRON expression: midnight on Oct 15.
    // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 10 ? 2022';

   static testmethod void test() {
      NI_IMT_Chatter_Settings__c  setting = new NI_IMT_Chatter_Settings__c();
      setting.Community_Name__c = 'IHG Implementation Tool Community';
      setting.Chatter_Group_Name__c = 'Global Super User';
      setting.Name = 'Default';
      insert setting;
      
      CollaborationGroup myGroup = new CollaborationGroup();
      myGroup.Name='Global Super User';
      myGroup.CollaborationType='Public'; //can be 'Public' or 'Private'                   
      insert myGroup;
      
      NI_IMT_Assignment_Settings__c  assignSetting = new NI_IMT_Assignment_Settings__c();
     assignSetting.Assignment_Project_Record_Type_Name__c = 'IMT - IHG GRS Project';
     assignSetting.Contact_Name_for_Migration_Operator__c = 'Migration Operator';
     assignSetting.Implementation_Lead_Profile_Name__c = 'NI IMT Implementation Leads';
     assignSetting.Regional_Admin_Profile_Name__c = 'NI IMT Regional Admin';
     assignSetting.Name = 'Default';
     insert assignSetting;

      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new NI_IMT_SchedulingSet22DaysPriorScheduler());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-10-15 00:00:00', String.valueOf(ct.NextFireTime));
      
      pse__Region__c region = new pse__Region__c(Name='Asia Middle East Africa');
        insert region;
        
        Id imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
        
        //CREATE RESOURCE
        Contact c = new Contact(
            firstname = 'test1',
            lastname = 'test1',
            MailingCountry = 'IN',
            MailingStreet = 'fssf',
            MailingCity = 'Pune',
            pse__Is_Resource__c = true,
            pse__Is_Resource_Active__c = true
        );
        insert c;
        
        //CREATE PROPERTY
        NI_IMT_Property__c property1 = new NI_IMT_Property__c (
            Country__c = 'US',
            State__c = 'CA',
            City__c = 'Los Angeles',
            Phone__c = '+1650 1234 5678',
            IMT_Complexity_Value__c = 1,
            Property_Code__c = 'TESTA',
            Operational_Profile__c = 'A'
        );
        insert property1;
        
        //CREATE PROJECTS        
        pse__Proj__c proj = new pse__Proj__c(
            Name = 'TestProj',
            pse__Region__c   = region.Id,
            RecordTypeId = imtProjRecordTypeId,
            pse__Allow_Self_Staffing__c = TRUE,
            pse__Project_Manager__c = c.Id,
            pse__Start_Date__c = Date.today(),
            pse__End_Date__c = Date.today()+7,
            IMT_Property__c = property1.Id
        );
        insert proj;
        
        //CREATE SCHEDULE
        pse__Schedule__c sch = new pse__Schedule__c (
            pse__Start_Date__c = Date.today(),
            pse__End_Date__c = Date.today()+7,
            pse__Monday_Hours__c = 10,
            pse__Tuesday_Hours__c = 10,
            pse__Wednesday_Hours__c = 10,
            pse__Thursday_Hours__c = 10,
            pse__Friday_Hours__c = 10,
            pse__Saturday_Hours__c = 10,
            pse__Sunday_Hours__c =10
        );
        insert sch;
        
        //CREATE USER AND ASSIGN STAFFING PERMISSION
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='admnuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='admnuser@testorg.com',No_AD_Account_Standard_User__c =TRUE);
        insert u;
        
        pse__Permission_Control__c permissioncntrl = new pse__Permission_Control__c(
            pse__User__c = u.Id,
            pse__Staffing__c = TRUE,
            pse__Resource__c = c.Id        
        );
        insert permissioncntrl;
        
        pse__Permission_Control__c permissioncntrl2 = new pse__Permission_Control__c(
            pse__User__c = u.Id,
            pse__Staffing__c = TRUE,
            pse__Region__c = region.Id        
        );
        insert permissioncntrl2;
        
        Date chckdate = system.today().addDays(-22);
        NI_IMT_TestDataFactory.createSchedulingSetConfig();	
		Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
		
        IMT_Migration_Set__c mig = new IMT_Migration_Set__c(
            Name = 'TestMigration',
            Start__c = chckdate,
            Budgeted_Complexity_Mix__c = 30,
            Budgeted_Complexity_1__c = 10,
            Status__c = 'Open',
            RecordTypeId = imtSchdlSetRecordTypeId
        );
        insert mig;
        
        System.runAs(u) {
            pse__Assignment__c assign1 = new pse__Assignment__c(
                Name = 'assignmenttest',
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = sch.Id,
                pse__Project__c = proj.Id,
                pse__Resource__c = c.Id,
                pse__Status__c = 'Tentative',
                Project_Manager__c = c.Id,
                IMT_Migration_Set__c = mig.Id,
                Project_Record_Type__c = 'IMT - IHG GRS Project',
                IMT_Project_Region__c = ' '
            );
            insert assign1;
        }
      
      Test.stopTest();

   }
}