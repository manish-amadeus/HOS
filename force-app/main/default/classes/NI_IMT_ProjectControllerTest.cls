/****************************************************************************************
Name            : NI_IMT_ProjectControllerTest Class
Author          : Damodar Raut
Created Date    : 04/18/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Test Class that handles all code for the NI_IMT_ProjectController class
				: 
				: 
******************************************************************************************/
@isTest
private class NI_IMT_ProjectControllerTest {
    
    public testmethod static void testController() {
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
            Status__c = 'Active'
        );
        insert prop;
        prop.Timezone__c = 'IST ( GMT 5.50 )';
        update prop;
        
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
        
        NI_IMT_TestDataFactory.createSchedulingSetConfig();	
		Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
		List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
    	IMT_Migration_Set__c set1 = schedulingSets[0];
    	set1.RecordTypeId = imtSchdlSetRecordTypeId;
    	insert set1;
		
        //TEST INIT
        ApexPages.currentPage().getParameters().put('migrationSetID', set1.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(proj);
        NI_IMT_ProjectController cntrlObj = new NI_IMT_ProjectController(sc);
        cntrlObj.init();
        System.assertEquals(1, cntrlObj.projectList.size());
        
        //TEST FILTERS
        ApexPages.currentPage().getParameters().put('projectName','test');
        ApexPages.currentPage().getParameters().put('region',region.Name);
        ApexPages.currentPage().getParameters().put('tzone',prop.Timezone__c);
        ApexPages.currentPage().getParameters().put('limitSize','20');
        ApexPages.currentPage().getParameters().put('complexity','3');
        cntrlObj.runSearch();
        System.assertEquals(1, cntrlObj.projectList.size());
        System.assertEquals(1, cntrlObj.getRegionList().size());
        System.assertEquals(1, cntrlObj.getTimezoneList().size());
        
        //TEST CREATE ASSIGNMENT
        PageReference ref = cntrlObj.createAssignment();
        System.assertEquals(null, ref);
        cntrlObj.projectList[0].selected = TRUE;
        ref = cntrlObj.createAssignment();
        System.assertNotEquals(null, ref);
    }

}