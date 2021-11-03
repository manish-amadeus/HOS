// DISABLED "IMT" Implementation Tool designed for IHG 
/****************************************************************************************
Name            : NI_IMT_Property_TriggerTest Class
Author          : Damodar Raut
Created Date    : 04/08/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Test Class for NI_IMT_Property_TriggerHandler
				: 
				: 
******************************************************************************************/
@isTest
private class NI_IMT_Property_TriggerTest 
{

    static testMethod void test1() 
    {      
        test.startTest();
        NI_IMT_Property_TriggerHandler cls = new NI_IMT_Property_TriggerHandler();
        system.assert(true);
        test.stopTest();
    }
    
/*    
    public static testmethod void testTimeZoneOnInsert() {

        NI_IMT_Property_TriggerHandler handler = new NI_IMT_Property_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
        
        Id imtPropRecordTypeId = Schema.getGlobalDescribe().get('NI_IMT_Property__c').getDescribe().getRecordTypeInfosByName().get('InterContinental Hotels Group').getRecordTypeId();
        //CREATE PROPERTY
        NI_IMT_Property__c prop = new NI_IMT_Property__c(
        	Name = 'TestProp',
            RecordTypeId = imtPropRecordTypeId,
            Country__c = 'US',
            State__c = 'CA',
            City__c = 'Los Angeles',
            Phone__c = '+1650 1234 5678',
            Property_Code__c = 'TESTP'
        );
        insert prop;
        NI_IMT_Property__c propNew = [select Name,Timezone__c FROM NI_IMT_Property__c WHERE Id= :prop.Id];
        system.debug('Prop' + propNew);
        system.assert(propNew.Timezone__c != 'Unknown');
    }
    
    public static testmethod void testPropertyChangedToInactive() {
        NI_IMT_Chatter_Settings__c  setting = new NI_IMT_Chatter_Settings__c();
		setting.Community_Name__c = 'IHG Implementation Tool Community';
		setting.GSU_RA_Group__c = 'IMT - Global Super User - Regional Admin';
		setting.Name = 'Default';
		insert setting;
		
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
		
		pse__Region__c region = new pse__Region__c(Name='Asia Middle East Africa');
        insert region;
        
        //CREATE USER AND ASSIGN STAFFING PERMISSION
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      	User u = new User(Alias = 'standt', Email='admnuser@testorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
     	 LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='admnuser@testorg.com',No_AD_Account_Standard_User__c =TRUE);
		insert u;
                
      	System.runAs(u) {
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
	            Property_Code__c = 'TESTP',
            	Operational_Profile__c = 'A'
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
	            pse__Is_Resource_Active__c = true,
	             pse__Salesforce_User__c = u.id	            
	        );
	        insert c;
	        
	         pse__Permission_Control__c permissioncntrl = new pse__Permission_Control__c(
	        	pse__User__c = u.Id,
	            pse__Staffing__c = TRUE,
	            pse__Resource__c = c.Id        
	        );
	        insert permissioncntrl;
	          
	        //ADDED BY STUART EMERY ON 3/31/2016
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
	            End__c = Date.today(),
	            Budgeted_Complexity_Mix__c = 30,
	            Budgeted_Complexity_1__c = 10,
	            Status__c = 'Open',
            	RecordTypeId = imtSchdlSetRecordTypeId
	        );
	        insert mig;
        
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
        
         	pse__Assignment__c assign1 = new pse__Assignment__c(
                Name = 'assignmenttest1',
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = sch.Id,
                pse__Project__c = proj.Id,
                pse__Resource__c = c.Id,
                pse__Status__c = 'Complete',
                Project_Manager__c = c.Id,
                IMT_Migration_Set__c = mig.Id,
                Project_Record_Type__c = 'IMT - IHG GRS Project',
                IMT_Project_Region__c = ''
        	);
        	insert assign1;
            
            pse__Project_Task__c projTask =  new pse__Project_Task__c(
                Name = 'Testmtask1',
                pse__Status__c = 'Draft',
                pse__Project__c = proj.Id
            );
            insert projTask;
            
            try {
            	//CHANGE STATUS TO Inactive
		        prop.Status__c = 'Inactive';
		        update prop;
            }
            catch(Exception e) {
                
            }
            //ASSERT CONDITIONS
            pse__Proj__c updatedProj = [SELECT pse__Stage__c FROM pse__Proj__c WHERE Id = :proj.Id];
            System.assertEquals('Canceled', updatedProj.pse__Stage__c);
            
            pse__Assignment__c updatedAssign = [SELECT pse__Status__c from pse__Assignment__c WHERE  id =:assign1.Id];
            System.assertEquals('Canceled', updatedAssign.pse__Status__c);
            
            pse__Project_Task__c updatedTask = [SELECT pse__Status__c FROM pse__Project_Task__c WHERE Id=:projTask.Id];
      		System.assertEquals('Canceled', updatedTask.pse__Status__c);
      	}    
	        
        
    }
*/
}