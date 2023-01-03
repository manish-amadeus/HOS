/****************************************************************************************
Name            : NI_IMT_CreateScheduleControllerTest Class
Author          : Damodar Raut
Created Date    : 04/18/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that handles all test code for the NI_IMT_CreateScheduleController Class
                : 
                : 
******************************************************************************************/
@isTest
private class NI_IMT_CreateScheduleControllerTest {
    public static testmethod void testController() {
    	pse__Region__c region = new pse__Region__c(Name='Asia Middle East Africa');
        insert region;
        pse__Region__c region2 = new pse__Region__c(Name='Americas');
        insert region2;
        Id imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
        //Create Custom Setting
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
         
         
        
        //CREATE USER AND ASSIGN STAFFING PERMISSION
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      	User u = new User(Alias = 'standt', Email='admnuser@testorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
     	 LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='admnuser@testorg.com',No_AD_Account_Standard_User__c =TRUE);
		insert u;
		
        System.runAs(u) {
        //CREATE RESOURCE
        Contact c = new Contact(
          firstname = 'Migration',
            lastname = 'Operator',
            MailingCountry = 'IN',
            MailingStreet = 'fssf',
            MailingCity = 'Pune',
            pse__Is_Resource__c = true,
            pse__Is_Resource_Active__c = true,
            pse__Salesforce_User__c = u.id
            
        );
        insert c;
        
         Id imtPropRecordTypeId = Schema.getGlobalDescribe().get('NI_IMT_Property__c').getDescribe().getRecordTypeInfosByName().get('InterContinental Hotels Group').getRecordTypeId();
        //CREATE PROPERTY
        NI_IMT_Property__c prop = new NI_IMT_Property__c(
          Name = 'TestProp',
            RecordTypeId = imtPropRecordTypeId,
            Country__c = 'IN',
            Street__c = 'street 1',
            State__c = 'test',
            City__c = 'test',
          	Timezone__c = 'IST ( GMT 5.50 )',
            Phone__c = '1234567890',
            IMT_Complexity_Value__c = 3,
            Property_Code__c = 'TESTP'
        );
        insert prop;
        prop.Timezone__c = 'IST ( GMT 5.50 )';
        update prop;
        
        NI_IMT_Property__c prop2 = new NI_IMT_Property__c(
          Name = 'TestProp2',
            RecordTypeId = imtPropRecordTypeId,
            Country__c = 'DE',
            Street__c = 'street 1',
            State__c = 'test',
            City__c = 'test',
          	Timezone__c = 'CET ( GMT 1.00 )',
            Phone__c = '1234567890',
            IMT_Complexity_Value__c = 3,
            Property_Code__c = 'TESTY'
        );
        insert prop2;
        prop2.Timezone__c = 'CET ( GMT 1.00 )';
        update prop2;
        //CREATE PROJECT
        pse__Proj__c proj = new pse__Proj__c(
          Name = 'TestProj',
            pse__Region__c   = region.Id,
            RecordTypeId = imtProjRecordTypeId,
            pse__Allow_Self_Staffing__c = TRUE,
            pse__Project_Manager__c = c.Id,
            pse__Start_Date__c = Date.today(),
            pse__End_Date__c = Date.today()+7,
            IMT_Property__c = prop.Id
        );
        insert proj;
        
        pse__Proj__c proj2 = new pse__Proj__c(
          Name = 'TestProj2',
            pse__Region__c   = region2.Id,
            RecordTypeId = imtProjRecordTypeId,
            pse__Allow_Self_Staffing__c = TRUE,
            pse__Project_Manager__c = c.Id,
            pse__Start_Date__c = Date.today(),
            pse__End_Date__c = Date.today()+7,
            IMT_Property__c = prop2.Id
        );
        insert proj2;
        
        NI_IMT_TestDataFactory.createSchedulingSetConfig();	
		Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
		
    	IMT_Migration_Set__c mig = new IMT_Migration_Set__c(
            Name = 'TestMigration',
            Start__c = Date.today().addDays(-370),
            //End__c = Date.today().addDays(370),
            Budgeted_Complexity_Mix__c =10,
            Budgeted_Complexity_1__c = 1,
            Budgeted_Complexity_2__c = 1,
            Budgeted_Complexity_3__c = 1,
            Budgeted_Complexity_4__c = 1,
            Status__c = 'Open',
            RecordTypeId = imtSchdlSetRecordTypeId
        );
        insert mig;
    	
        
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
        
        pse__Permission_Control__c permissioncntrl3 = new pse__Permission_Control__c(
        	pse__User__c = u.Id,
            pse__Staffing__c = TRUE,
            pse__Region__c = region2.Id        
        );
        insert permissioncntrl3;
        
      	
        //TEST CREATE ASSIGNMENT
        
            ApexPages.currentPage().getParameters().put('Ids',+proj.Id+':'+proj2.Id+'|');
            ApexPages.currentPage().getParameters().put('migrationSetID',mig.Id);
            NI_IMT_CreateScheduleController cntrlObj = new NI_IMT_CreateScheduleController();
            cntrlObj.init();
            System.assertEquals(2, cntrlObj.projDetails.size());
            PageReference ref = cntrlObj.createAssignment();
            System.assertNotEquals(null, ref);
            
            
        }
    }
}