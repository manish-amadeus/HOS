/****************************************************************************************
Name            : AH_GetProjectRecord_Test Class 
Author          : Shashikant Nikam
Created Date    : 10/28/2020
Last Mod Date   : 10/28/2020 
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_GetProjectRecord 
                : 
                : 
******************************************************************************************/

@isTest
public with sharing class AH_GetProjectRecord_Test {
    
    @testSetup
    static void createTestData(){
        
        // CREATE REGION PROJECT RECORD
        pse__Region__c region = NI_TestClassData.createTestRegion(1, 'Test Region');
        insert region;
        
        // CREATE TEST PROJECT RECORD
        pse__Proj__c testProject = new pse__Proj__c();
        testProject.Name = 'Test Project';
        testProject.pse__Region__c = region.Id;
        insert testProject;
        
    }
    
    
    // ======================================================================================================================================= 
    //  TEST METHOD 1: testGetProjectRecord()
    // ======================================================================================================================================= 
    @isTest
    static void testGetProjectRecord() {
        
        // SOQL QUERY TO RETRIEVE PROJECT RECORD
        pse__Proj__c testProject = [select id, Name from pse__Proj__c where Name =: 'Test Project'];

        pse__Proj__c tempProject = AH_GetProjectRecord.returnProjectRecordDetails(testProject.Id);
    
        // ASSERT STATEMENT
        system.assertEquals(tempProject.Id,testProject.Id,'Project ID is not matching');
    }
}