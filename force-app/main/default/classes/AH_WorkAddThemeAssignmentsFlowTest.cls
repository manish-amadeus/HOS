/****************************************************************************************
Name            :  AH_WorkAddThemeAssignmentsFlowTest
Author          :  Kimberly Contreraz
Created Date    :  01/20/2023
Last Mod Date   :  
Last Mod By     :  
NICC Reference  :  NICC-063573
Description     :  Test Class for the Flow called "Work - Add Theme Assignments"
        : 
****************************************************************************************/
@isTest
public class AH_WorkAddThemeAssignmentsFlowTest{
    @TestSetup
    static void makeData(){
        //Create a Team
        agf__ADM_Scrum_Team__c agileTeam = new agf__ADM_Scrum_Team__c();
        agileTeam.agf__Active__c 	= true;
        agileTeam.Name 				= 'Sample Agile Team';
        agileTeam.agf__Cloud__c 	= 'IT';
        
        insert agileTeam;
        
        //Create a Product Tag
        agf__ADM_Product_Tag__c agileProductTag = new agf__ADM_Product_Tag__c();
        agileProductTag.agf__Active__c 	= true;
        agileProductTag.Name 			= 'Sample Product Tag';
        agileProductTag.agf__Team__c 	= agileTeam.Id;
        
        insert agileProductTag;
        
        //Create 3 new Themes
        agf__ADM_Theme__c agileTheme1 = new agf__ADM_Theme__c();
        agileTheme1.agf__Active__c 	= true;
        agileTheme1.Name 			= 'Sample Theme 1 for Test Class';
        
        insert agileTheme1;
        
        agf__ADM_Theme__c agileTheme2 = new agf__ADM_Theme__c();
        agileTheme2.agf__Active__c 	= true;
        agileTheme2.Name 			= 'Sample Theme 2 for Test Class';
        
        insert agileTheme2;
        
        agf__ADM_Theme__c agileTheme3 = new agf__ADM_Theme__c();
        agileTheme3.agf__Active__c 	= true;
        agileTheme3.Name 			= 'Sample Theme 3 for Test Class';
        
        insert agileTheme3;
        
        //Create 2 Work records for testing
        agf__ADM_Work__c agileWork1 = new agf__ADM_Work__c();
        agileWork1.agf__Subject__c 		= 'Sample User Story 1 for Testing Theme Assignments';
        agileWork1.AH_Team__c 			= 'DTS Team';
        agileWork1.agf__Status__c 		= 'New';
        agileWork1.agf__Product_Tag__c 	= agileProductTag.Id;
        
        insert agileWork1;
        
        agf__ADM_Work__c agileWork2 = new agf__ADM_Work__c();
        agileWork2.agf__Subject__c 		= 'Sample User Story 2 for Testing Theme Assignments';
        agileWork2.AH_Team__c 			= 'DTS Team';
        agileWork2.agf__Status__c 		= 'New';
        agileWork2.agf__Product_Tag__c 	= agileProductTag.Id;
        
        insert agileWork2;
        
        //Create Theme Assignments for User Story #2
        agf__ADM_Theme_Assignment__c agileThemeAssignment1 = new agf__ADM_Theme_Assignment__c();
        agileThemeAssignment1.agf__Theme__c = agileTheme1.Id;
        agileThemeAssignment1.agf__Work__c = agileWork2.Id;
        
        insert agileThemeAssignment1;
        
    }//end adding data
    

} //end of test class