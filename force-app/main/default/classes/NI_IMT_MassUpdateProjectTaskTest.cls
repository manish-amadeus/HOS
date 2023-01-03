@isTest
public with sharing class NI_IMT_MassUpdateProjectTaskTest {
    
    static testmethod void testUpdateProjectTask(){
    	
    	NI_Project_Task_Profile_Access__c profile1 = new NI_Project_Task_Profile_Access__c();
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
	        
    	pse__Region__c region = new pse__Region__c(Name='Asia Middle East Africa');
        insert region;
        
        Id imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
    	Id imtPropRecordTypeId = Schema.getGlobalDescribe().get('NI_IMT_Property__c').getDescribe().getRecordTypeInfosByName().get('InterContinental Hotels Group').getRecordTypeId();
    	
    	//CREATE PROPERTY
        NI_IMT_Property__c prop = new NI_IMT_Property__c(
          	Name = 'TestProp',
            RecordTypeId = imtPropRecordTypeId,
            Country__c = 'SG',
            Street__c = 'street 1',
            State__c = 'test',
            City__c = 'test',
          	Timezone__c = 'IST ( GMT 5.50 )',
            Phone__c = '1234567890',
            IMT_Complexity_Value__c = 3,
            Property_Code__c = 'TESTP'
        );
        insert prop;
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
    	
    	//CREATE PROJECT
        pse__Proj__c proj = new pse__Proj__c(
        	Name = 'TestProj',
          	pse__Region__c	 = region.Id,
            RecordTypeId = imtProjRecordTypeId,
            pse__Allow_Self_Staffing__c = TRUE,
            pse__Project_Manager__c = c.Id,
            pse__Start_Date__c = Date.today(),
            pse__End_Date__c = Date.today()+7,
            IMT_Property__c = prop.Id
        );
        insert proj;
        
        //CREATE USER AND ASSIGN STAFFING PERMISSION
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      	User u = new User(Alias = 'standt', Email='admnuser@testorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
     	 LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='admnuser@testorg.com',No_AD_Account_Standard_User__c =TRUE);
		insert u;
		
		System.runAs(u) {
    
	    	pse__Project_Task__c projTask =  new pse__Project_Task__c(
	                Name = 'Testmtask1',
	                pse__Status__c = 'Started',
	                pse__Project__c = proj.Id
	            );
	        insert projTask;
	            
	        pse__Project_Task__c[] projectTaskList = [Select id,name,pse__Started__c,pse__Completed__c,pse__Status__c from pse__Project_Task__c where name = 'Testmtask1'];
	        
	        PageReference testPage = Page.NI_IMT_MassUpdateProjectTask;
	        
	        ApexPages.StandardSetController sc = new ApexPages.standardSetController(projectTaskList);
		sc.setSelected(projectTaskList);
		NI_IMT_MassUpdateProjectTask p1 = new NI_IMT_MassUpdateProjectTask(sc);
		
		p1.getNewProjectTask().pse__Status__c='Planned';
        p1.doSave();
		p1.cancel();
            
		}
            
            
    }
    
    
    
    static testmethod void testUpdateProjectTask4(){
    	
    	NI_Project_Task_Profile_Access__c profile1 = new NI_Project_Task_Profile_Access__c();
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
	        
    	pse__Region__c region = new pse__Region__c(Name='Asia Middle East Africa');
        insert region;
        
        Id imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
    	Id imtPropRecordTypeId = Schema.getGlobalDescribe().get('NI_IMT_Property__c').getDescribe().getRecordTypeInfosByName().get('InterContinental Hotels Group').getRecordTypeId();
    	
    	//CREATE PROPERTY
        NI_IMT_Property__c prop = new NI_IMT_Property__c(
          Name = 'TestProp',
            RecordTypeId = imtPropRecordTypeId,
            Country__c = 'SG',
            Street__c = 'street 1',
            State__c = 'test',
            City__c = 'test',
          	Timezone__c = 'IST ( GMT 5.50 )',
            Phone__c = '1234567890',
            IMT_Complexity_Value__c = 3,
            Property_Code__c = 'TESTP'
        );
        insert prop;
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
    	
    	//CREATE PROJECT
        pse__Proj__c proj = new pse__Proj__c(
        	Name = 'TestProj',
          	pse__Region__c	 = region.Id,
            RecordTypeId = imtProjRecordTypeId,
            pse__Allow_Self_Staffing__c = TRUE,
            pse__Project_Manager__c = c.Id,
            pse__Start_Date__c = Date.today(),
            pse__End_Date__c = Date.today()+7,
            IMT_Property__c = prop.Id
        );
        insert proj;
        
        //CREATE USER AND ASSIGN STAFFING PERMISSION
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      	User u = new User(Alias = 'standt', Email='admnuser@testorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
     	 LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='admnuser@testorg.com',No_AD_Account_Standard_User__c =TRUE);
		insert u;
		
		List<pse__Proj__c> projs = new List<pse__Proj__c>();
		
		System.runAs(u) {
    		
	    	pse__Project_Task__c projTask1 =  new pse__Project_Task__c(
	                Name = 'Testmtask1',
	                pse__Status__c = 'Planned',
	                pse__Started__c = false,
	                pse__Completed__c = false,
	                pse__Project__c = proj.Id
	            );
	      
	        insert projTask1;
	        
	        pse__Project_Task__c projTask2 =  new pse__Project_Task__c(
	                Name = 'Testmtask2',
	                pse__Status__c = 'Started',
	                pse__Started__c = true,
	                pse__Completed__c = false,
	                pse__Project__c = proj.Id
	            );
	      
	        insert projTask2;
	        
	        
	            
	        pse__Project_Task__c[] projectTaskList = [Select id,name,pse__Started__c,pse__Completed__c,pse__Status__c from pse__Project_Task__c where name = 'Testmtask3'];
	        
	        PageReference testPage = Page.NI_IMT_MassUpdateProjectTask;
	        
	        ApexPages.StandardSetController sc = new ApexPages.standardSetController(projectTaskList);
			sc.setSelected(projectTaskList);
			NI_IMT_MassUpdateProjectTask p1 = new NI_IMT_MassUpdateProjectTask(sc);
			
			p1.getNewProjectTask().pse__Status__c ='Complete';
			p1.getNewProjectTask().pse__Started__c = true;
			p1.getNewProjectTask().pse__Completed__c = true;
			p1.getNewProjectTask().name = 'Testmtask4';
	        p1.doSave();
			p1.cancel();
            
		}
            
            
    }
    
     static testmethod void testUpdateProjectTask5(){
    	
    	NI_Project_Task_Profile_Access__c profile1 = new NI_Project_Task_Profile_Access__c();
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
    	
    	pse__Region__c region = new pse__Region__c(Name='Asia Middle East Africa');
        insert region;
        
        Id imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
    	Id imtPropRecordTypeId = Schema.getGlobalDescribe().get('NI_IMT_Property__c').getDescribe().getRecordTypeInfosByName().get('InterContinental Hotels Group').getRecordTypeId();
    	
    	//CREATE PROPERTY
        NI_IMT_Property__c prop = new NI_IMT_Property__c(
          Name = 'TestProp',
            RecordTypeId = imtPropRecordTypeId,
            Country__c = 'SG',
            Street__c = 'street 1',
            State__c = 'test',
            City__c = 'test',
          	Timezone__c = 'IST ( GMT 5.50 )',
            Phone__c = '1234567890',
            IMT_Complexity_Value__c = 3,
            Property_Code__c = 'TESTP'
        );
        insert prop;
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
    	
    	//CREATE PROJECT
        pse__Proj__c proj = new pse__Proj__c(
        	Name = 'TestProj',
          	pse__Region__c	 = region.Id,
            RecordTypeId = imtProjRecordTypeId,
            pse__Allow_Self_Staffing__c = TRUE,
            pse__Project_Manager__c = c.Id,
            pse__Start_Date__c = Date.today(),
            pse__End_Date__c = Date.today()+7,
            IMT_Property__c = prop.Id
        );
        insert proj;
        
        //CREATE USER AND ASSIGN STAFFING PERMISSION
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      	User u = new User(Alias = 'standt', Email='admnuser@testorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
     	 LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='admnuser@testorg.com',No_AD_Account_Standard_User__c =TRUE);
		insert u;
		
		List<pse__Proj__c> projs = new List<pse__Proj__c>();
		
		System.runAs(u) {
    		
	    	pse__Project_Task__c projTask1 =  new pse__Project_Task__c(
	                Name = 'Testmtask1',
	                pse__Status__c = 'Planned',
	                pse__Started__c = false,
	                pse__Completed__c = false,
	                pse__Project__c = proj.Id
	            );
	      
	        insert projTask1;
	        
	        pse__Project_Task__c projTask2 =  new pse__Project_Task__c(
	                Name = 'Testmtask2',
	                pse__Status__c = 'Started',
	                pse__Started__c = true,
	                pse__Completed__c = false,
	                pse__Project__c = proj.Id
	            );
	      
	        insert projTask2;
	        
	        pse__Project_Task__c projTask3 =  new pse__Project_Task__c(
	                Name = 'Testmtask3',
	                pse__Status__c = 'Started',
	                pse__Started__c = true,
	                pse__Completed__c = true,
	                pse__Project__c = proj.Id
	            );
	      
	        insert projTask3;
	        
	        
	            
	        pse__Project_Task__c[] projectTaskList = [Select id,name,pse__Started__c,pse__Completed__c,pse__Status__c from pse__Project_Task__c where pse__Completed__c = true];
	        
	        PageReference testPage = Page.NI_IMT_MassUpdateProjectTask;
	        
	        ApexPages.StandardSetController sc = new ApexPages.standardSetController(projectTaskList);
			sc.setSelected(projectTaskList);
			NI_IMT_MassUpdateProjectTask p1 = new NI_IMT_MassUpdateProjectTask(sc);
			
			
			p1.getNewProjectTask().pse__Started__c = true;
			p1.getNewProjectTask().pse__Status__c ='Blocked';
			p1.getNewProjectTask().pse__Completed__c = false;
			p1.getNewProjectTask().name = 'Testmtask4';
	        p1.doSave();
			p1.cancel();
            
		}
            
            
    } 
    
       
    
    	
}