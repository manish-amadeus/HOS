/****************************************************************************************
Name            :  AH_WorkAddThemeAssignmentsFlowTest
Author          :  Kimberly Contreraz
Created Date    :  03/02/2023
Last Mod Date   :  
Last Mod By     :  
NICC Reference  :  NICC-######
Description     :  Test Class for the Flow called "Work - Create Parent/Child Relationship for SLTC Bugs"
        : 
****************************************************************************************/
@isTest
public class AH_WorkParentChildFlowTest {
	    //Constants
    Static final Integer numberOfRecords 		= 2;
    Static final Integer numberOfRelatedWork 	= 2;
    
    @TestSetup
    static void makeData(){
     
    //Gets the ID of the "User Story" record type on the Work object
	Id workUserStoryRTID = Schema.SObjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId();
    
    
        
        //Create a Team
        agf__ADM_Scrum_Team__c agileTeam = new agf__ADM_Scrum_Team__c();
        agileTeam.agf__Active__c 	= true;
        agileTeam.Name 				= 'Sample SLTC Testing Agile Team';
        agileTeam.agf__Cloud__c 	= 'IT';
        
        insert agileTeam;
        System.debug('>>>Agile Team Created: ' + agileTeam);
        
        //Create a Product Tag
        agf__ADM_Product_Tag__c agileProductTag = new agf__ADM_Product_Tag__c();
        agileProductTag.agf__Active__c 	= true;
        agileProductTag.Name 			= 'Sample Random SLTC Testing Product Tag';
        agileProductTag.agf__Team__c 	= agileTeam.Id;
        agileProductTag.agf__Active__c	= true;
                
        insert agileProductTag;
        System.debug('>>>Product Tag Created: ' + agileProductTag);
        
        //Create a Build record to use with a new Bug
        agf__ADM_Build__c newBuild = new agf__ADM_Build__c();
        newBuild.Name = 'SampleSLTCTestingBuildTestClass';
        
        insert newBuild;
        
        //Create Work records
        List<agf__ADM_Work__c> workRecords = new List<agf__ADM_Work__c>();
        for (Integer i=1; i<=numberOfRecords; i++){
            workRecords.add(new agf__ADM_Work__c (	agf__Subject__c 		= 'Test User Story #' + i, 
                                                  	agf__Product_Tag__c 	= agileProductTag.Id, 
                                                  	recordtypeid 			=  workUserStoryRTID,
                                                  	AH_Team__c 				= 'SLTC Testing',
                                                 	agf__Scrum_Team__c 		= agileTeam.Id));
    
    }
        
        insert workRecords;
    
    
    }//end of makeData
    
    @isTest
    public static void workTestParentChildRelationship(){
        //Get the ID of the "Bug" record type on the Work object
		Id workBugRTID = Schema.SObjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('Bug').getRecordTypeId();
        
        //Get the product tag to create a new bug
        agf__ADM_Product_Tag__c myAgileProductTag = [SELECT Id from agf__ADM_Product_Tag__c];
        
        Test.startTest();
        System.debug('>>>Test Starts Here');
        
        List<agf__ADM_Work__c> agileWorkRecordsToUpdate = [SELECT Id FROM agf__ADM_Work__c];
        for(agf__ADM_Work__c work :agileWorkRecordsToUpdate ){
          	
            AH_TestCase__c testCase = new AH_TestCase__c();
        	testCase.User_Story__c 			= work.Id;
        	testCase.Test_Case_Status__c 	= 'Not Started';
        
        	insert testCase;
            System.debug('>>>New Test Case Created ' + testCase);
            
            agf__ADM_Work__c createDefect = new agf__ADM_Work__c();
            createDefect.agf__Subject__c 		= 'Test SLTC Testing Defect';
            createDefect.RecordTypeId 			= workBugRTID;
            createDefect.AH_Team__c 			= 'SLTC Testing';
            createDefect.AH_TestCase__c 		= testCase.Id;
            createDefect.agf__Priority__c		= 'High';
            createDefect.agf__Product_Tag__c	= myAgileProductTag.Id;
            
			insert createDefect;
            System.debug('>>>New Defect Created ' + createDefect);
 			}
        
        List<agf__ADM_Parent_Work__c> relatedWork = [SELECT agf__Child_Work__c, agf__Parent_Work__c, Id  
                                                                  	FROM agf__ADM_Parent_Work__c];
        System.debug('>>>List of Related Work Found after insert: ' + relatedWork);
        System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
        System.assertEquals(numberOfRecords, relatedWork.size(), 'Count of Related Work should be: '+numberOfRecords);
        
        Test.stopTest();
        System.debug('>>>Test Ends Here');
        
    }//end of test
    
}//end of test class