/****************************************************************************************
Name            : NI_IMT_TestDataFactory Class
Author          : Damodar Raut
Created Date    : 06/03/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class to create test data for IMT Tool testing
                : 
                : 
******************************************************************************************/
public class NI_IMT_TestDataFactory {
      
    //CREATE PROPERTY RECORDS
    public static List<NI_IMT_Property__c> createProperties( Integer numberOfProperties) {
        Id imtPropRecordTypeId = Schema.getGlobalDescribe().get('NI_IMT_Property__c').getDescribe().getRecordTypeInfosByName().get('InterContinental Hotels Group').getRecordTypeId();
        List<String> propCodes = new List<String>{'TESTA','TESTB','TESTC','TESTD','TESTE','TESTF','TESTG','TESTH','TESTI','TESTJ'};
        List<NI_IMT_Property__c> properties = new List<NI_IMT_Property__c>();
        for ( Integer i = 0 ; i < numberOfProperties ; i++ ) {
            NI_IMT_Property__c prop = new NI_IMT_Property__c( 
                Name = 'Test Property' + i,
                Country__c = 'US',
                State__c = 'CA',
                City__c = 'Los Angeles',
                Phone__c = '+1650 1234 5678',
                RecordTypeId = imtPropRecordTypeId,
                Property_Code__c = propCodes[i],
                IMT_Complexity_Value__c = 1,
                Operational_Profile__c = 'A'
            );
            properties.add( prop);
        }
        return properties;
    }
    
    // CREATE ROLE
    /*public static Id createRole() {
        UserRole role1 = new UserRole (
            Name = 'InterContinental Hotels Group, Americas Customer User',
            PortalType = 'CustomerPortal'
        );
        insert role1;
        return role1.Id;
    }*/
    
    //CREATE USERS
    public static List<User> createUsers(String profileName, Integer numberOfUsers, Id roleId) {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String randomNumber = EncodingUtil.convertToHex(hash);

        Account a = new Account(
            Name='Test Account Name'+randomNumber,           
            BillingState = 'LA',
            BillingCountry = 'US',
            BillingPostalCode = '9045',
            BillingStreet = 'Street 1'+randomNumber,  
            BillingCity = 'Los Angeles' 
        );
        insert a;
  
        List<Contact> contacts = new List<Contact>();
        for ( Integer i = 0 ; i < numberOfUsers ; i++ ) {   
            Contact con = new Contact(
                firstname = 'Test' + i,
                lastname = 'Contact',
                MailingCountry = 'IN',
                MailingStreet = 'Street 1',
                MailingCity = 'Pune',
                AccountId = a.Id          
            );
            contacts.add(con);
        }
        insert contacts;

        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName]; 
        List<User> users = new List<User>();
        for ( Integer i = 0 ; i < numberOfUsers ; i++ ) {
            User newUser = new User(
                Alias = 'tstUser'+i, 
                Email='tstuser'+i+'@niimttestorg.com', 
                LastName='Testing', 
                ProfileId = p.Id, 
                UserName='nn.tstuser'+i+'@niimttestorg.com',
                No_AD_Account_Standard_User__c =TRUE,
                TimeZoneSidKey='America/Los_Angeles',
                EmailEncodingKey='UTF-8',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ContactId = contacts[i].Id,
                UserRoleId = roleId
            );
            users.add(newUser);
        }
        return users;
    }
    
    //CREATE IMT CONTACT
    public static List<NI_IMT_Contact__c> createImtContacts(Integer numberOfContacts) {
    	List<NI_IMT_Contact__c> imtContacts = new List<NI_IMT_Contact__c>();
        for ( Integer i = 0 ; i < numberOfContacts ; i++ ) {
        	NI_IMT_Contact__c con = new NI_IMT_Contact__c(
	          	First_Name__c = 'IMT',
	            Last_Name__c = 'Contact' + i,
	            Country__c = 'US',
	            City__c = 'LA',
	            Email__c = 'imtcontact'+i+'@imtautotest.com',
	            Phone__c = '1212243567',
	            Postal_Code__c = '9090',
	            Street__c = 'Street 1',
	            Title__c = 'Mr'          
	        );
	        imtContacts.add(con);
        }
        return imtContacts;
    }
    
    
    //CREATE CONTACTS
    public static List<Contact> createContacts( Integer numberOfContacts){
    	List<Contact> contacts = new List<Contact>();
        for ( Integer i = 0 ; i < numberOfContacts ; i++ ) {   
            Contact con = new Contact(
                firstname = 'Test' + i,
                lastname = 'Contact',
                MailingCountry = 'IN',
                MailingStreet = 'Street 1',
                MailingCity = 'Pune'         
            );
            contacts.add(con);
        }
        return contacts;
    }
    
    //CREATE REGION 
    public static Id getRegionId(String nameVal) {
    	pse__Region__c region = new pse__Region__c(Name=nameVal);
        insert region;
        return region.Id;
    }
    
    //CREATE PROJECTS
    public static List<pse__Proj__c> createProjects(Integer numberOfProjects, Id regionId, Id propertyId, Id contactId) {
    	Id imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
	    List<pse__Proj__c> projects = new List<pse__Proj__c>();
    	for ( Integer i = 0 ; i < numberOfProjects ; i++ ) {
	        pse__Proj__c proj = new pse__Proj__c(
	        	Name = 'TestProj' + i,
	          	pse__Region__c	 = regionId,
	            RecordTypeId = imtProjRecordTypeId,
	            pse__Allow_Self_Staffing__c = TRUE,
	            pse__Project_Manager__c = contactId,
	            pse__Start_Date__c = Date.today(),
	            pse__End_Date__c = Date.today()+7,
	            IMT_Property__c = propertyId
	        );
	        projects.add(proj);
    	}
    	return projects;
    }
    
    //CREATE PROJECT TASKS
    public static List<pse__Project_Task__c>  createProjectTask(Integer numberOfProjectTasks, Id projectId) {
    	List<pse__Project_Task__c> projTasks = new List<pse__Project_Task__c>();
    	for ( Integer i = 0 ; i < numberOfProjectTasks ; i++ ) {
	    	pse__Project_Task__c projTask =  new pse__Project_Task__c(
                Name = 'TestTask' + i,
                pse__Status__c = 'Draft',
                pse__Project__c = projectId
            );
            projTasks.add(projTask);
    	}
    	return projTasks;
    }
    
    //CREATE SCHEDULING SET
    public static List<IMT_Migration_Set__c> createSchedulingSet(Integer numberOfSets) {
    	List<IMT_Migration_Set__c> schedulingSets = new List<IMT_Migration_Set__c>();
    	for ( Integer i = 0 ; i < numberOfSets ; i++ ) {
	    	IMT_Migration_Set__c mig = new IMT_Migration_Set__c(
	            Name = 'TestMigration' + i,
	            Start__c = Date.today(),
	            Budgeted_Complexity_Mix__c = 10,
	            Budgeted_Complexity_1__c = 10,
	            Status__c = 'Open'
	        );
	        schedulingSets.add(mig);
    	}
    	return schedulingSets;
    }
    
    //CREATE CUSTOM SETTINGS
    public static void createCustomSettings() {
        NI_IMT_Assignment_Settings__c  assignSetting = new NI_IMT_Assignment_Settings__c();
        assignSetting.Assignment_Project_Record_Type_Name__c = 'IMT - IHG GRS Project';
        assignSetting.Contact_Name_for_Migration_Operator__c = 'Migration Operator';
        assignSetting.Implementation_Lead_Profile_Name__c = 'NI IMT Implementation Leads';
        assignSetting.Regional_Admin_Profile_Name__c = 'NI IMT Regional Admin';
        assignSetting.Name = 'Default';
        insert assignSetting;
        
        NI_IMT_Chatter_Settings__c  setting = new NI_IMT_Chatter_Settings__c();
        setting.Community_Name__c = 'IHG Implementation Tool Community';
        setting.Chatter_Group_Name__c = 'Global Super User';
        setting.Name = 'Default';
        insert setting; 
    }
    
    //CREATE CHATTER GROUPS
    public static void createChatterGroups() {
        CollaborationGroup myGroup1 = new CollaborationGroup();
        myGroup1.Name='IMT - Global Super User - Regional Admin';
        myGroup1.CollaborationType='Public';                   
        insert myGroup1;
        
        CollaborationGroup myGroup2 = new CollaborationGroup();
        myGroup2.Name='Global Super User';
        myGroup2.CollaborationType='Public';                  
        insert myGroup2;    
    }
    
    //CHECK REPORT PERMISSION FOR PROFILE
    public static Profile reportAccess(String profileName) {
    	Profile prof = [SELECT Name,
    							PermissionsCreateCustomizeReports,
    							PermissionsEditMyReports,
    							PermissionsNewReportBuilder,
    							PermissionsManageReportsInPubFolders  
    						FROM Profile
    						WHERE Name = :profileName];
		return prof;
    } 
    
    
    //CHECK ACTIVITY PERMISSION FOR PROFILE
    public static Profile activityAccess(String profileName) {
    	Profile prof = [SELECT Name,
    							PermissionsEditEvent,
    							PermissionsEditTask
    						FROM Profile
    						WHERE Name = :profileName];
		return prof;
    }
    
    //CREATE PERMISION CONTROL
    public static void createPermissionControl(Id userId, Id contactId, Id regionId ) {
    	List<pse__Permission_Control__c> permissionList = new List<pse__Permission_Control__c>();
    	pse__Permission_Control__c permissioncntrl = new pse__Permission_Control__c(
        	pse__User__c = userId,
            pse__Staffing__c = TRUE,
            pse__Resource__c = contactId       
        );
        permissionList.add(permissioncntrl);
        
        pse__Permission_Control__c permissioncntrl2 = new pse__Permission_Control__c(
        	pse__User__c = userId,
            pse__Staffing__c = TRUE,
            pse__Region__c = regionId        
        );
        permissionList.add(permissioncntrl2);
        insert permissionList;
    }
    
    //CREATE SCHEDULE
    public static List<pse__Schedule__c> createSchedule(Integer numberOfSchedule) {
        List<pse__Schedule__c> schdlList = new List<pse__Schedule__c>();
        for ( Integer i = 0 ; i < numberOfSchedule ; i++ ) {
        	pse__Schedule__c sch = new pse__Schedule__c (
	       		pse__Start_Date__c = Date.today(),
	            pse__End_Date__c = Date.today()+7,
	            pse__Monday_Hours__c = 10,
	            pse__Tuesday_Hours__c = 10,
	            pse__Wednesday_Hours__c = 10,
	            pse__Thursday_Hours__c = 10,
	            pse__Friday_Hours__c = 10,
	            pse__Saturday_Hours__c = 10,
	            pse__Sunday_Hours__c = 10
	        );
        	schdlList.add(sch);
        }
        return schdlList;
    }
    
    //CREATE ASSIGNMENTS
    public static List<pse__Assignment__c> createAssignments(Integer numberOfAssignments,Id scheduleId,Id projId, Id contactId, Id schdlsetId){
    	List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
        for ( Integer i = 0 ; i < numberOfAssignments ; i++ ) {
    		pse__Assignment__c assign1 = new pse__Assignment__c(
                Name = 'TestAssignment' + i,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = scheduleId,
                pse__Project__c = projId,
                pse__Resource__c = contactId,
                pse__Status__c = 'Scheduled',
                Project_Manager__c = contactId,
                IMT_Migration_Set__c = schdlsetId,
                Project_Record_Type__c = 'IMT - IHG GRS Project'
        	);
        	assignmentList.add(assign1);
        }
        return assignmentList;
    }
    
    //CREATE MIGRATION OPERATOR
    public static Id createMigrationOperator() {
    	Contact migrationOperator = new Contact(
          	firstname = 'Migration',
            lastname = 'Operator',
            MailingCountry = 'IN',
            MailingStreet = 'fssf',
            MailingCity = 'Pune',
            pse__Is_Resource__c = true,
            pse__Is_Resource_Active__c = true
        );
        insert migrationOperator;
        return migrationOperator.Id;
    }
    
    //CREATE KNOWLEDGE
    public static List<NI_IMT_Knowledge__c> createKnowledgeArticles(Integer numberOfArticles) {
    	List<NI_IMT_Knowledge__c> knowledgeList = new List<NI_IMT_Knowledge__c>();
        for ( Integer i = 0 ; i < numberOfArticles ; i++ ) {
    		NI_IMT_Knowledge__c knowldege1 = new NI_IMT_Knowledge__c(	
    			Article_Type__c = 'How Do I',
    			Title__c = 'Test Title' + i,
    			Resolution__c = 'test resolution'
    		);
    		knowledgeList.add(knowldege1);
        }
        return knowledgeList;
    }
    
    //CREATE SCHEDULING SET CONFIG
    public static void createSchedulingSetConfig() {
		IMT_Scheduling_Set_Config__c  schdlsetConfig = new IMT_Scheduling_Set_Config__c();
		schdlsetConfig.Name = 'IMT - InterContinental Hotels Group';
		schdlsetConfig.Record_Type__c = 'IMT - IHG GRS Project';
		schdlsetConfig.Total_Planned__c = 100;
		schdlsetConfig.Project_Status__c = 'Not Scheduled';
		schdlsetConfig.Resource__c = 'Migration Operator';
		schdlsetConfig.Close_Date__c = 21;
		schdlsetConfig.Complete_Date__c = 2;
		schdlsetConfig.Timezone_Limit__c = 3.00;
		schdlsetConfig.Number_of_Assignments_per_Project__c = 1;
		insert schdlsetConfig;
    }
    
    //CREATE NON IMT USER
    public static User createNonImtUser(String profileName) {
    	Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
		User nonImtUser = new User(
                Alias = 'noImtUsr', 
                Email='nonImt@niimttestorg.com', 
                LastName='Testing', 
                ProfileId = p.Id, 
                UserName='nn.nonimt@niimttestorg.com',
                No_AD_Account_Standard_User__c =TRUE,
                TimeZoneSidKey='America/Los_Angeles',
                EmailEncodingKey='UTF-8',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US'
            );
        return nonImtUser;    
    }
    
}