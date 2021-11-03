// DISABLED "IMT" Implementation Tool designed for IHG 
/************************************************************************************************
Name            : NI_IMT_Assignment_TriggerHandlerTest Class
Author          : Damodar Raut
Created Date    : 04/25/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that handles all test code for the NI_IMT_Assignment_TriggerHandler class
                : 
*************************************************************************************************/
@isTest
private class NI_IMT_Assignment_TriggerHandlerTest 
{
    
    static testMethod void test1() 
    {  
        test.startTest();
        NI_IMT_Assignment_TriggerHandler cls = new NI_IMT_Assignment_TriggerHandler();
        system.assert(true);
        test.stopTest();
    }  
    
/*    
	@testsetup static void createCustomSettings() 
    {
        
        NI_IMT_TestDataFactory.createSchedulingSetConfig();
        
    	NI_IMT_Assignment_Settings__c  assignSetting = new NI_IMT_Assignment_Settings__c();
		assignSetting.Assignment_Project_Record_Type_Name__c = 'IMT - IHG GRS Project';
		assignSetting.Contact_Name_for_Migration_Operator__c = 'Migration Operator';
		assignSetting.Implementation_Lead_Profile_Name__c = 'NI IMT Implementation Leads';
		assignSetting.Regional_Admin_Profile_Name__c = 'NI IMT Regional Admin';
		assignSetting.Name = 'Default';
		insert assignSetting;
		
		CollaborationGroup myGroup = new CollaborationGroup();
		myGroup.Name='IMT - Global Super User - Regional Admin';
		myGroup.CollaborationType='Public'; //can be 'Public' or 'Private'                   
		insert myGroup;
		
		NI_IMT_Chatter_Settings__c  setting = new NI_IMT_Chatter_Settings__c();
		setting.Community_Name__c = 'IHG Implementation Tool Community';
		setting.Chatter_Group_Name__c = 'Global Super User';
		setting.Name = 'Default';
		insert setting;	
    }

	public static testmethod void testAfterInsert() 
    {
        
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
        
        //CREATE PROPERTIES
        List<NI_IMT_Property__c> props = new List<NI_IMT_Property__c>();
        List<String> propCode = new List<String> {'TESTA','TESTB','TESTC','TESTD'};
        List<String> opProfile = new List<String> {'A','B','C','D'};
        
        for(Integer i=1;i<5;i++) {
        	NI_IMT_Property__c property1 = new NI_IMT_Property__c (
	            Country__c = 'US',
	            State__c = 'CA',
	            City__c = 'Los Angeles',
	            Phone__c = '+1650 1234 5678',
	            IMT_Complexity_Value__c = i,
	            Property_Code__c = propCode[i-1],
	            Operational_Profile__c = opProfile[i-1]
	        );
        	props.add(property1);
        }
        insert props;
        
        //CREATE PROJECTS        
        List<pse__Proj__c> projs = new List<pse__Proj__c>();
        for(Integer i=1;i<5;i++) {
        	pse__Proj__c proj = new pse__Proj__c(
	        	Name = 'TestProj' + i,
	          	pse__Region__c	 = region.Id,
	            RecordTypeId = imtProjRecordTypeId,
	            pse__Allow_Self_Staffing__c = TRUE,
	            pse__Project_Manager__c = c.Id,
	            pse__Start_Date__c = Date.today(),
	            pse__End_Date__c = Date.today()+7,
	            IMT_Property__c = props[i-1].Id
	        );
        	projs.add(proj);
        }
        insert projs;
        
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
        
        IMT_Migration_Set__c mig = new IMT_Migration_Set__c(
            Name = 'TestMigration',
            Start__c = Date.today(),
            Budgeted_Complexity_Mix__c = 30,
            Budgeted_Complexity_1__c = 10
        );
        insert mig;
        
        List<pse__Assignment__c> assgnList = new List<pse__Assignment__c>();
      	System.runAs(u) {
      		for(Integer i=0;i<4; i++ ) {
	         	pse__Assignment__c assign1 = new pse__Assignment__c(
	                Name = 'assignmenttest' + i,
	                pse__Bill_Rate__c = 0,
	                pse__Schedule__c = sch.Id,
	                pse__Project__c = projs[i].Id,
	                pse__Resource__c = c.Id,
	                pse__Status__c = 'Scheduled',
	                Project_Manager__c = c.Id,
	                IMT_Migration_Set__c = mig.Id,
	                Project_Record_Type__c = 'IMT - IHG GRS Project'
	        	);
        		assgnList.add(assign1);
      		}
        	insert assgnList;
      	}
      	IMT_Migration_Set__c newMig = [SELECT Scheduled_Complexity_1__c,
	      									Scheduled_Complexity_2__c,
	      									Scheduled_Complexity_3__c,
	      									Scheduled_Complexity_4__c
      									FROM IMT_Migration_Set__c WHERE Id = :mig.Id];
        System.assertEquals(1, newMig.Scheduled_Complexity_1__c);
        System.assertEquals(1, newMig.Scheduled_Complexity_2__c);
        System.assertEquals(1, newMig.Scheduled_Complexity_3__c);
        System.assertEquals(1, newMig.Scheduled_Complexity_4__c);
		
	}
	
	public static testmethod void testCanceledFallback() 
    {
        
		pse__Region__c region = new pse__Region__c(Name='Asia Middle East Africa');
        insert region;
        
        Id imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
        
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
        
        IMT_Migration_Set__c mig = new IMT_Migration_Set__c(
            Name = 'TestMigration',
            Start__c = Date.today(),
            Budgeted_Complexity_Mix__c = 30,
            Budgeted_Complexity_1__c = 10
        );
        insert mig;
        
      	System.runAs(u) {
      	//CREATE RESOURCE
        Contact c = new Contact(
        	firstname = 'test1',
            lastname = 'test1',
            MailingCountry = 'IN',
            MailingStreet = 'fssf',
            MailingCity = 'Pune',
            pse__Is_Resource__c = true,
            pse__Is_Resource_Active__c = true,
            pse__Salesforce_User__c = u.Id
        );
        insert c;
        
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
          	pse__Region__c	 = region.Id,
            RecordTypeId = imtProjRecordTypeId,
            pse__Allow_Self_Staffing__c = TRUE,
            pse__Project_Manager__c = c.Id,
            pse__Start_Date__c = Date.today(),
            pse__End_Date__c = Date.today()+7,
            IMT_Property__c = property1.Id
        );
        insert proj;
         	pse__Assignment__c assign1 = new pse__Assignment__c(
                Name = 'assignmenttest',
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = sch.Id,
                pse__Project__c = proj.Id,
                pse__Resource__c = c.Id,
                pse__Status__c = 'Scheduled',
                Project_Manager__c = c.Id,
                IMT_Migration_Set__c = mig.Id,
                Project_Record_Type__c = 'IMT - IHG GRS Project'
        	);
        	insert assign1;
        	
        	assign1.pse__Status__c = 'Canceled';
        	assign1.Cancellation_Reason__c = 'Not in Good Standing';
        	update assign1;
      	}
      	
		
	}
*/    
}