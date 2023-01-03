@isTest
public with sharing class NI_IMT_MassUpdateProjectsTest {
    
    static testmethod void testProjectUpdate(){
   
        pse__Region__c region = new pse__Region__c(Name='Asia Middle East Africa');
        insert region;
        
        NI_Projects_Profile_Access__c profile1 = new NI_Projects_Profile_Access__c();
        profile1.name= 'System Administrator';
        profile1.Profile_Name__c='System Administrator';
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
        
         //CREATE USER AND ASSIGN STAFFING PERMISSION
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      	User u = new User(Alias = 'standt', Email='admnuser@testorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
     	 LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='admnuser@testorg.com',No_AD_Account_Standard_User__c =TRUE);
		insert u;
        
        //CREATE PROJECTS        
        List<pse__Proj__c> projs = new List<pse__Proj__c>();
        System.runAs(u) {
        for(Integer i=1;i<11;i++) {
        	pse__Proj__c proj = new pse__Proj__c(
	        	Name = 'TestProj' + i,
	          	pse__Region__c	 = region.Id,
	            RecordTypeId = imtProjRecordTypeId,
	            pse__Allow_Self_Staffing__c = TRUE,
	            pse__Stage__c = 'Draft',
	            pse__Project_Manager__c = c.Id,	           
	            pse__Start_Date__c = Date.today(),
	            pse__End_Date__c = Date.today()+7,
	            IMT_Property__c = props[i-1].Id
	        );
        	projs.add(proj);
        }
        insert projs;
        
        
    	
    	pse__Proj__c[] projList = [Select id,pse__Stage__c, pse__Project_Manager__c from pse__Proj__c where pse__Stage__c = 'Draft'];
    	
    	
    	PageReference testPage = Page.NI_IMT_MassUpdateProjects;
    	
    	    	
		ApexPages.StandardSetController sc = new ApexPages.standardSetController(projList);
		sc.setSelected(projList);
		NI_IMT_MassUpdateProjects p1 = new NI_IMT_MassUpdateProjects(sc);
    	
    	p1.getNewProject();
        p1.doSave();
		p1.cancel();
		
        } 
		
    }
    
  
    static testmethod void testProjectUpdateForError(){
    	
    	 pse__Region__c region = new pse__Region__c(Name='Asia Middle East Africa');
        insert region;
        
        NI_Projects_Profile_Access__c profile1 = new NI_Projects_Profile_Access__c();
        profile1.name= 'System Administratorr';
        profile1.Profile_Name__c='System Administratorr';
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
        
         //CREATE USER AND ASSIGN STAFFING PERMISSION
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      	User u = new User(Alias = 'standt', Email='admnuser@testorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
     	 LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='admnuser@testorg.com',No_AD_Account_Standard_User__c =TRUE);
		insert u;
        
        //CREATE PROJECTS        
        List<pse__Proj__c> projs = new List<pse__Proj__c>();
        System.runAs(u) {
        for(Integer i=1;i<11;i++) {
        	pse__Proj__c proj = new pse__Proj__c(
	        	Name = 'TestProj' + i,
	          	pse__Region__c	 = region.Id,
	            RecordTypeId = imtProjRecordTypeId,
	            pse__Allow_Self_Staffing__c = TRUE,
	            pse__Stage__c = 'Draft',
	            pse__Project_Manager__c = c.Id,	           
	            pse__Start_Date__c = Date.today(),
	            pse__End_Date__c = Date.today()+7,
	            IMT_Property__c = props[i-1].Id
	        );
        	projs.add(proj);
        }
        insert projs;
        
        
    	
    	pse__Proj__c[] projList = [Select id,pse__Stage__c, pse__Project_Manager__c from pse__Proj__c where name = 'TestProj21'];
    	
    	PageReference testPage = Page.NI_IMT_MassUpdateProjects;
    	
    	ApexPages.StandardSetController sc = new ApexPages.standardSetController(projList);
		//sc.setSelected('');
		NI_IMT_MassUpdateProjects p1 = new NI_IMT_MassUpdateProjects(sc);
    	
    	p1.getNewProject().pse__Stage__c = 'Live';
		p1.doSave();
		p1.cancel();
    
    }
    }
    
    static testmethod void testProjectUpdateForUpdate(){
    	
    	 pse__Region__c region = new pse__Region__c(Name='Asia Middle East Africa');
        insert region;
        
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
        
       
         //CREATE USER AND ASSIGN STAFFING PERMISSION
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      	User u = new User(Alias = 'standt', Email='admnuser@testorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
     	 LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='admnuser@testorg.com',No_AD_Account_Standard_User__c =TRUE);
		insert u;
        
        //CREATE PROJECTS        
        List<pse__Proj__c> projs = new List<pse__Proj__c>();
        System.runAs(u) {
        for(Integer i=1;i<11;i++) {
        	pse__Proj__c proj = new pse__Proj__c(
	        	Name = 'TestProj' + i,
	          	pse__Region__c	 = region.Id,
	            RecordTypeId = imtProjRecordTypeId,
	            pse__Allow_Self_Staffing__c = TRUE,
	            pse__Stage__c = 'Draft',
	            pse__Project_Manager__c = c.Id,	           
	            pse__Start_Date__c = Date.today(),
	            pse__End_Date__c = Date.today()+7,
	            IMT_Property__c = props[i-1].Id
	        );
        	projs.add(proj);
        }
        insert projs;
 
    	pse__Proj__c[] projList = [Select id,pse__Stage__c, pse__Project_Manager__c from pse__Proj__c where name = 'TestProj2'];
    
    	PageReference testPage = Page.NI_IMT_MassUpdateProjects;
 
		ApexPages.StandardSetController sc = new ApexPages.standardSetController(projList);
		sc.setSelected(projList);
		NI_IMT_MassUpdateProjects p1 = new NI_IMT_MassUpdateProjects(sc);
    	
    	p1.getNewProject().pse__Stage__c = 'Live';
		p1.doSave();
		p1.cancel();
    
    }
    }
    
  
    
}