/****************************************************************************************
Name            : NI_IMT_TestDataFactoryTest Class
Author          : Damodar Raut
Created Date    : 06/21/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that contains all test cases for NI_IMT_TestDataFactory class
                : 
                : 
******************************************************************************************/
@isTest
public class NI_IMT_TestDataFactoryTest {
	
	public static testmethod void testCreateProperties() {
		List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(2);
		system.assertEquals(2 , props.size());
	}
	
	public static testmethod void testCreateRole() {
		List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 2, NULL);
		system.assertEquals(2 , imtUsers.size());
	}
	
	public static testmethod void testCreateImtContacts() {
		List<NI_IMT_Contact__c> contacts = NI_IMT_TestDataFactory.createImtContacts(2);
		system.assertEquals(2 , contacts.size());
	}
	
	public static testmethod void testCreateContacts() {
		List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
		system.assertEquals(2 , contacts.size());
	}
	
	public static testmethod void testGetRegionId() {
		Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
		system.assertNotEquals(NULL ,regionId);
	}
	
	public static testmethod void testCreateProjects() {
		Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
    	
    	List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
        Contact contact1 = contacts[0];
        insert contact1;
        
		List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(2, regionId, testProp1.Id, contact1.Id);
		system.assertEquals(2 , projects.size());
	}
	
	public static testmethod void testCreateProjectTask() {
		Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
    	
    	List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
        Contact contact1 = contacts[0];
        insert contact1;
        
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();
        
    	List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
    	pse__Proj__c testProj1 = projects[0];
    	testProj1.pse__Start_Date__c = Date.today() + 2;
    	insert testProj1;
    	
    	List<pse__Project_Task__c> projTasks =  NI_IMT_TestDataFactory.createProjectTask(2, testProj1.Id); 	
 		system.assertEquals(2 , projTasks.size());
	}
	
	public static testmethod void testCreateSchedulingSet() {
		List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(2);
    	system.assertEquals(2 , schedulingSets.size());
	}
	
	public static testmethod void testCreateSchedule() {
		List<pse__Schedule__c> schduleList = NI_IMT_TestDataFactory.createSchedule(2);
		system.assertEquals(2 , schduleList.size());
	}
	
	public static testmethod void testCreateAssignments() {
		NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();	
        NI_IMT_TestDataFactory.createSchedulingSetConfig();	
		Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
    	
    	Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
    	
    	
    	List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        Contact contact1 = contacts[1];
        contact1.pse__Is_Resource__c = true;
        contact1.pse__Is_Resource_Active__c = true;
        insert contact1;
        
    	List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
    	pse__Proj__c testProj1 = projects[0];
    	insert testProj1;
    	
    	List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
    	IMT_Migration_Set__c set1 = schedulingSets[0];
    	set1.RecordTypeId = imtSchdlSetRecordTypeId;
    	insert set1;
	
		List<pse__Schedule__c> schduleList = NI_IMT_TestDataFactory.createSchedule(1);
    	pse__Schedule__c schedule1 = schduleList[0];
    	insert schedule1;
	
    	List<pse__Assignment__c> assignments = NI_IMT_TestDataFactory.createAssignments(1,schedule1.Id,testProj1.Id,contact1.Id,set1.Id);
    	system.assertEquals(1 , assignments.size());
	}
	
	public static testmethod void testCreateKnowledgeArticles() {
		List<NI_IMT_Knowledge__c> objList = NI_IMT_TestDataFactory.createKnowledgeArticles(2);
		system.assertEquals(2 , objList.size());
	}
	
	public static testmethod void testCreateMigrationOperator() {
		Id operatorId = NI_IMT_TestDataFactory.createMigrationOperator();
		system.assertNotEquals(NULL ,operatorId);
	}
}