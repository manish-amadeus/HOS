@isTest
public with sharing class NI_IMT_MassUpdateAssignmentTest {

	static testmethod void testStatusUpdate(){
	
		NI_Assignments_Profile_Access__c profile1 = new NI_Assignments_Profile_Access__c();
		profile1.name = 'System Administrator';
		profile1.Profile_Name__c = 'System Administrator';
		insert profile1;
		
		NI_IMT_Assignment_Settings__c  assignSetting = new NI_IMT_Assignment_Settings__c();
         assignSetting.Assignment_Project_Record_Type_Name__c = 'IMT - IHG GRS Project';
         assignSetting.Contact_Name_for_Migration_Operator__c = 'Migration Operator';
         assignSetting.Implementation_Lead_Profile_Name__c = 'NI IMT Implementation Leads';
         assignSetting.Regional_Admin_Profile_Name__c = 'NI IMT Regional Admin';
         assignSetting.Name = 'Default';
         insert assignSetting;
       
		
		NI_IMT_Chatter_Settings__c  setting = new NI_IMT_Chatter_Settings__c();
	      setting.Community_Name__c = 'IHG Implementation Tool Community';
	      setting.GSU_RA_Group__c = 'IMT - Global Super User - Regional Admin';
	      setting.Name = 'Default';
	      insert setting;
      
      	CollaborationGroup myGroup = new CollaborationGroup();
	        myGroup.Name='IMT - Global Super User - Regional Admin';
	        myGroup.CollaborationType='Public'; //can be 'Public' or 'Private'                   
	        insert myGroup;
			
        pse__Region__c region = new pse__Region__c(Name='Asia Middle East Africa');
        insert region;
        
        Id imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
        
         //CREATE USER AND ASSIGN STAFFING PERMISSION
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      	User u = new User(Alias = 'standt', Email='admnuser@testorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
     	 LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='admnuser@testorg.com',No_AD_Account_Standard_User__c =TRUE);
		insert u;
        
        //CREATE RESOURCE
        Contact c = new Contact(
        	firstname = 'test1',
            lastname = 'test1',
            MailingCountry = 'IN',
            MailingStreet = 'fssf',
            MailingCity = 'Pune',
            pse__Is_Resource__c = true,
            pse__Is_Resource_Active__c = true,
            pse__Salesforce_User__c = u.id
        ); 
        insert c;
        
        //CREATE PROPERTIES
        List<NI_IMT_Property__c> props = new List<NI_IMT_Property__c>();
        List<String> propCode = new List<String> {'TESTA','TESTB','TESTC','TESTD','TESTE','TESTF','TESTG','TESTH','TESTI','TESTJ'};
        for(Integer i=1;i<11;i++) {
        	NI_IMT_Property__c property1 = new NI_IMT_Property__c (
	            Country__c = 'US',
	            State__c = 'CA',
	            City__c = 'Los Angeles',
	            Phone__c = '+1650 1234 5678',
	            IMT_Complexity_Value__c = i,
	            Property_Code__c = propCode[i-1]
	        );
        	props.add(property1);
        }
        insert props;
        
        //CREATE PROJECTS        
        List<pse__Proj__c> projs = new List<pse__Proj__c>();
        for(Integer i=1;i<11;i++) {
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
        NI_IMT_TestDataFactory.createSchedulingSetConfig();	
		Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
		
        IMT_Migration_Set__c mig = new IMT_Migration_Set__c(
            Name = 'TestMigration',
            Start__c = Date.today().addDays(-370),
            //End__c = Date.today()
            Budgeted_Complexity_Mix__c =500,
            Budgeted_Complexity_1__c = 1,
            Budgeted_Complexity_2__c = 1,
            Budgeted_Complexity_3__c = 1,
            Budgeted_Complexity_4__c = 1,
            Status__c = 'Open',
            RecordTypeId = imtSchdlSetRecordTypeId
        );
        insert mig;
        
        List<pse__Assignment__c> assgnList = new List<pse__Assignment__c>();
      	System.runAs(u) {
      		for(Integer i=0;i<1; i++ ) {
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
        	
     
		pse__Assignment__c[] assignment2 = [Select id,pse__Status__c from pse__Assignment__c where name = 'assignmenttest2']; 
		
		
		//Construct your pagereference
		//PageReference testPage = new pagereference('/apex/NI_IMT_MassUpdateAssignment');
		PageReference testPage = Page.NI_IMT_MassUpdateAssignment;
		
		for(pse__Assignment__c a : assignment2){
		testPage.getParameters().put('id', a.id);
		
		Test.setCurrentPage(testPage);
		}
		
		ApexPages.StandardSetController sc = new ApexPages.standardSetController(assignment2);
		sc.setSelected(assignment2);
		NI_IMT_MassUpdateAssignment a = new NI_IMT_MassUpdateAssignment(sc);
		
		a.getNewAssignment();
		a.getNewAssignment().pse__Status__c = 'Live';
		a.doSave();
		a.cancel();
		
        }
		
		
	}  
	
	static testmethod void testStatusUpdate2(){
	
		NI_Assignments_Profile_Access__c profile1 = new NI_Assignments_Profile_Access__c();
		profile1.name = 'System Administratorr';
		profile1.Profile_Name__c = 'System Administratorr';
		insert profile1;
		
		NI_IMT_Assignment_Settings__c  assignSetting = new NI_IMT_Assignment_Settings__c();
         assignSetting.Assignment_Project_Record_Type_Name__c = 'IMT - IHG GRS Project';
         assignSetting.Contact_Name_for_Migration_Operator__c = 'Migration Operator';
         assignSetting.Implementation_Lead_Profile_Name__c = 'NI IMT Implementation Leads';
         assignSetting.Regional_Admin_Profile_Name__c = 'NI IMT Regional Admin';
         assignSetting.Name = 'Default';
         insert assignSetting;
       
		
		NI_IMT_Chatter_Settings__c  setting = new NI_IMT_Chatter_Settings__c();
	      setting.Community_Name__c = 'IHG Implementation Tool Community';
	      setting.GSU_RA_Group__c = 'IMT - Global Super User - Regional Admin';
	      setting.Name = 'Default';
	      insert setting;
      
      	CollaborationGroup myGroup = new CollaborationGroup();
	        myGroup.Name='IMT - Global Super User - Regional Admin';
	        myGroup.CollaborationType='Public'; //can be 'Public' or 'Private'                   
	        insert myGroup;
			
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
        List<String> propCode = new List<String> {'TESTA','TESTB','TESTC','TESTD','TESTE','TESTF','TESTG','TESTH','TESTI','TESTJ'};
        for(Integer i=1;i<11;i++) {
        	NI_IMT_Property__c property1 = new NI_IMT_Property__c (
	            Country__c = 'US',
	            State__c = 'CA',
	            City__c = 'Los Angeles',
	            Phone__c = '+1650 1234 5678',
	            IMT_Complexity_Value__c = i,
	            Property_Code__c = propCode[i-1]
	        );
        	props.add(property1);
        }
        insert props;
        
        //CREATE PROJECTS        
        List<pse__Proj__c> projs = new List<pse__Proj__c>();
        for(Integer i=1;i<11;i++) {
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
        NI_IMT_TestDataFactory.createSchedulingSetConfig();	
		Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
		
        IMT_Migration_Set__c mig = new IMT_Migration_Set__c(
            Name = 'TestMigration',
            Start__c = Date.today(),
            //End__c = Date.today()
            Budgeted_Complexity_Mix__c =500,
            Budgeted_Complexity_1__c = 1,
            Budgeted_Complexity_2__c = 1,
            Budgeted_Complexity_3__c = 1,
            Budgeted_Complexity_4__c = 1,
            Status__c = 'Open',
            RecordTypeId = imtSchdlSetRecordTypeId
        );
        insert mig;
        
        List<pse__Assignment__c> assgnList = new List<pse__Assignment__c>();
      	System.runAs(u) {
      		for(Integer i=0;i<10; i++ ) {
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
        	
     
		pse__Assignment__c[] assignment2 = [Select id,pse__Status__c from pse__Assignment__c where name = 'assignmenttest2']; 
		
		
		//Construct your pagereference
		//PageReference testPage = new pagereference('/apex/NI_IMT_UpdateAssignmentStatus');
		PageReference testPage = Page.NI_IMT_MassUpdateAssignment;
		
		
		ApexPages.StandardSetController sc = new ApexPages.standardSetController(assignment2);
		//sc.setSelected(assignment2);
		NI_IMT_MassUpdateAssignment a = new NI_IMT_MassUpdateAssignment(sc);
		a.getNewAssignment();
		//a.getNewAssignment().pse__Status__c = '';
		
		a.doSave();
		a.cancel();
		
        }
		
		
	}      
    	static testmethod void testStatusUpdate3(){
	
		NI_Assignments_Profile_Access__c profile1 = new NI_Assignments_Profile_Access__c();
		profile1.name = 'System Administratorr';
		profile1.Profile_Name__c = 'System Administratorr';
		insert profile1;
		
		NI_IMT_Assignment_Settings__c  assignSetting = new NI_IMT_Assignment_Settings__c();
         assignSetting.Assignment_Project_Record_Type_Name__c = 'IMT - IHG GRS Project';
         assignSetting.Contact_Name_for_Migration_Operator__c = 'Migration Operator';
         assignSetting.Implementation_Lead_Profile_Name__c = 'NI IMT Implementation Leads';
         assignSetting.Regional_Admin_Profile_Name__c = 'NI IMT Regional Admin';
         assignSetting.Name = 'Default';
         insert assignSetting;
       
		
		NI_IMT_Chatter_Settings__c  setting = new NI_IMT_Chatter_Settings__c();
	      setting.Community_Name__c = 'IHG Implementation Tool Community';
	      setting.GSU_RA_Group__c = 'IMT - Global Super User - Regional Admin';
	      setting.Name = 'Default';
	      insert setting;
      
      	CollaborationGroup myGroup = new CollaborationGroup();
	        myGroup.Name='IMT - Global Super User - Regional Admin';
	        myGroup.CollaborationType='Public'; //can be 'Public' or 'Private'                   
	        insert myGroup;
			
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
        List<String> propCode = new List<String> {'TESTA','TESTB','TESTC','TESTD','TESTE','TESTF','TESTG','TESTH','TESTI','TESTJ'};
        for(Integer i=1;i<11;i++) {
        	NI_IMT_Property__c property1 = new NI_IMT_Property__c (
	            Country__c = 'US',
	            State__c = 'CA',
	            City__c = 'Los Angeles',
	            Phone__c = '+1650 1234 5678',
	            IMT_Complexity_Value__c = i,
	            Property_Code__c = propCode[i-1]
	        );
        	props.add(property1);
        }
        insert props;
        
        //CREATE PROJECTS        
        List<pse__Proj__c> projs = new List<pse__Proj__c>();
        for(Integer i=1;i<11;i++) {
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
        NI_IMT_TestDataFactory.createSchedulingSetConfig();	
		Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
		
        IMT_Migration_Set__c mig = new IMT_Migration_Set__c(
            Name = 'TestMigration',
            Start__c = Date.today(),
            //End__c = Date.today()
            Budgeted_Complexity_Mix__c =500,
            Budgeted_Complexity_1__c = 1,
            Budgeted_Complexity_2__c = 1,
            Budgeted_Complexity_3__c = 1,
            Budgeted_Complexity_4__c = 1,
            Status__c = 'Open',
            RecordTypeId = imtSchdlSetRecordTypeId
        );
        insert mig;
        
        List<pse__Assignment__c> assgnList = new List<pse__Assignment__c>();
      	System.runAs(u) {
      		for(Integer i=0;i<10; i++ ) {
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
        	
     
		pse__Assignment__c[] assignment2 = [Select id,pse__Status__c from pse__Assignment__c where name = 'assignmenttest2']; 
		
		
		//Construct your pagereference
		//PageReference testPage = new pagereference('/apex/NI_IMT_UpdateAssignmentStatus');
		PageReference testPage = Page.NI_IMT_MassUpdateAssignment;
		
		
		ApexPages.StandardSetController sc = new ApexPages.standardSetController(assignment2);
		sc.setSelected(assignment2);
		NI_IMT_MassUpdateAssignment a = new NI_IMT_MassUpdateAssignment(sc);
		a.getNewAssignment();
		a.getNewAssignment().pse__Status__c = 'Tentative';
		
		a.doSave();
		a.cancel();
		
        }
		
		
	} 
	
	
	static testmethod void testStatusUpdate4(){
	
		NI_Assignments_Profile_Access__c profile1 = new NI_Assignments_Profile_Access__c();
		profile1.name = 'System Administratorr';
		profile1.Profile_Name__c = 'System Administratorr';
		insert profile1;
		
		NI_IMT_Assignment_Settings__c  assignSetting = new NI_IMT_Assignment_Settings__c();
         assignSetting.Assignment_Project_Record_Type_Name__c = 'IMT - IHG GRS Project';
         assignSetting.Contact_Name_for_Migration_Operator__c = 'Migration Operator';
         assignSetting.Implementation_Lead_Profile_Name__c = 'NI IMT Implementation Leads';
         assignSetting.Regional_Admin_Profile_Name__c = 'NI IMT Regional Admin';
         assignSetting.Name = 'Default';
         insert assignSetting;
       
		
		NI_IMT_Chatter_Settings__c  setting = new NI_IMT_Chatter_Settings__c();
	      setting.Community_Name__c = 'IHG Implementation Tool Community';
	      setting.GSU_RA_Group__c = 'IMT - Global Super User - Regional Admin';
	      setting.Name = 'Default';
	      insert setting;
      
      	CollaborationGroup myGroup = new CollaborationGroup();
	        myGroup.Name='IMT - Global Super User - Regional Admin';
	        myGroup.CollaborationType='Public'; //can be 'Public' or 'Private'                   
	        insert myGroup;
	        	
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
        List<String> propCode = new List<String> {'TESTA','TESTB','TESTC','TESTD','TESTE','TESTF','TESTG','TESTH','TESTI','TESTJ'};
        for(Integer i=1;i<11;i++) {
        	NI_IMT_Property__c property1 = new NI_IMT_Property__c (
	            Country__c = 'US',
	            State__c = 'CA',
	            City__c = 'Los Angeles',
	            Phone__c = '+1650 1234 5678',
	            IMT_Complexity_Value__c = i,
	            Property_Code__c = propCode[i-1]
	        );
        	props.add(property1);
        }
        insert props;
        
        //CREATE PROJECTS        
        List<pse__Proj__c> projs = new List<pse__Proj__c>();
        for(Integer i=1;i<11;i++) {
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
        NI_IMT_TestDataFactory.createSchedulingSetConfig();	
		Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
		
        IMT_Migration_Set__c mig = new IMT_Migration_Set__c(
            Name = 'TestMigration',
            Start__c = Date.today(),
            //End__c = Date.today()
            Budgeted_Complexity_Mix__c =500,
            Budgeted_Complexity_1__c = 1,
            Budgeted_Complexity_2__c = 1,
            Budgeted_Complexity_3__c = 1,
            Budgeted_Complexity_4__c = 1,
            Status__c = 'Open',
            RecordTypeId = imtSchdlSetRecordTypeId
        ); 
        insert mig;
        
        List<pse__Assignment__c> assgnList = new List<pse__Assignment__c>();
      	System.runAs(u) {
      		for(Integer i=0;i<10; i++ ) {
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
        	
     
		pse__Assignment__c[] assignment2 = [Select id,Cancellation_Reason__c,pse__Status__c from pse__Assignment__c where name = 'assignmenttest2']; 
		
		
		//Construct your pagereference
		//PageReference testPage = new pagereference('/apex/NI_IMT_UpdateAssignmentStatus');
		PageReference testPage = Page.NI_IMT_MassUpdateAssignment;
		
		
		ApexPages.StandardSetController sc = new ApexPages.standardSetController(assignment2);
		sc.setSelected(assignment2);
		NI_IMT_MassUpdateAssignment a = new NI_IMT_MassUpdateAssignment(sc);
		a.getNewAssignment();
		a.getNewAssignment().pse__Status__c = 'Canceled';
		a.getNewAssignment().Cancellation_Reason__c = 'Act of God';
		
		a.doSave();
		a.cancel();
		
        }
		
		
	} 
	
}