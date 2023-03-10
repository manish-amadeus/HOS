/****************************************************************************************
Name            :  AH_WorkAddThemeAssignmentsFlowTest
Author          :  Kimberly Contreraz
Created Date    :  01/20/2023
Last Mod Date   :  01/30/2023
Last Mod By     :  
NICC Reference  :  NICC-063573
Description     :  Test Class for the Flow called "Work - Add Theme Assignments"
        : 
****************************************************************************************/
@isTest
public class AH_WorkAddThemeAssignmentsFlowTest{
   
    //Constants
    Static final Integer numberOfRecords                = 2;        
    Static final Integer numberOfThemesNewWork          = 4;
    Static final Integer numberOfThemesRemoveTheme      = 2;
    Static final Integer numberofThemesRemoveBothThemes = 0;
    
    @TestSetup
    static void makeData(){
        //Create a Team
        agf__ADM_Scrum_Team__c agileTeam = new agf__ADM_Scrum_Team__c();
        agileTeam.agf__Active__c    = true;
        agileTeam.Name              = 'Sample Agile Team';
        agileTeam.agf__Cloud__c     = 'IT';
        
        insert agileTeam;            
       
        //Create a Product Tag
        agf__ADM_Product_Tag__c agileProductTag = new agf__ADM_Product_Tag__c();
        agileProductTag.agf__Active__c  = true;
        agileProductTag.Name            = 'Sample Product Tag';
        agileProductTag.agf__Team__c    = agileTeam.Id;
        
        insert agileProductTag;
    
        //Create 3 Themes
        agf__ADM_Theme__c agileTheme1 = new agf__ADM_Theme__c();
        agileTheme1.agf__Active__c  = true;
        agileTheme1.Name            = 'Sample Theme 1 for Test Class';
        
        insert agileTheme1;
        
        agf__ADM_Theme__c agileTheme2 = new agf__ADM_Theme__c();
        agileTheme2.agf__Active__c  = true;
        agileTheme2.Name            = 'Sample Theme 2 for Test Class';
        
        insert agileTheme2;
        
        agf__ADM_Theme__c agileTheme3 = new agf__ADM_Theme__c();
        agileTheme3.agf__Active__c  = true;
        agileTheme3.Name            = 'Sample Theme 3 for Test Class';
        
        insert agileTheme3;    
    
        //Create Work records
        List<agf__ADM_Work__c> workRecords = new List<agf__ADM_Work__c>();
        for (Integer i=1; i<=numberOfRecords; i++){
            workRecords.add(new agf__ADM_Work__c (agf__Subject__c = 'Test Work Record #' + i, 
                                                  agf__Product_Tag__c = agileProductTag.Id, 
                                                  AH_Theme_One__c = agileTheme1.Id,
                                                  AH_Theme_Two__c = agileTheme2.Id, 
                                                  AH_Team__c = 'DTS Team' ));
        }
        
        insert workRecords;
    
    }//end of TestSetup section
    
    @isTest
    public static void workTestNewUserStories(){
        Test.startTest();
        System.debug('>>>Test #1 Starts Here');
        List<agf__ADM_Theme_Assignment__c> newThemeAssignments = [SELECT AH_CreatedByAutomation__c, agf__Theme__c, agf__Work__c  
                                                                    FROM agf__ADM_Theme_Assignment__c];
        System.debug('>>>Test 1 List of Theme Assignments Found after insert: ' + newThemeAssignments);
        System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
        System.assertEquals(numberOfThemesNewWork, newThemeAssignments.size(), '1. Count of Theme Assignments should be: '+numberOfThemesNewWork);
        
        Test.stopTest();
        System.debug('>>>Test #1 Ends Here');
    }//end of Test section #1
    
    @isTest
    public static void workTestUpdateOneTheme(){
        agf__ADM_Theme__c agileTheme3 = [SELECT Id FROM agf__ADM_Theme__c WHERE Name = 'Sample Theme 3 for Test Class'];
        
        Test.startTest();
        System.debug('>>>Test #2 Starts Here');
        
        List<agf__ADM_Work__c> agileWorkRecordsToUpdate = [SELECT AH_Theme_One__c FROM agf__ADM_Work__c];
        for(agf__ADM_Work__c work :agileWorkRecordsToUpdate ){
            work.AH_Theme_One__c = agileTheme3.Id;
        }
        
        List<agf__ADM_Theme_Assignment__c> updatedThemeOne = [SELECT AH_CreatedByAutomation__c, agf__Theme__c, agf__Work__c  
                                                                    FROM agf__ADM_Theme_Assignment__c];
        System.debug('>>>Test 2 List of Theme Assignments Found after insert: ' + updatedThemeOne);
        System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
        System.assertEquals(numberOfThemesNewWork, updatedThemeOne.size(), '2. Count of Theme Assignments should be: '+numberOfThemesNewWork);
        
        Test.stopTest();
        System.debug('>>>Test #2 Ends Here');
        
    }//end of Test section #2
    
@isTest
    public static void workTestUpdateDeleteThemeOne(){
        
        Test.startTest();
        System.debug('>>>Test #3 Starts Here');
        
        List<agf__ADM_Work__c> agileWorkRecordsRemoveThemeOne = [SELECT AH_Theme_One__c FROM agf__ADM_Work__c];
        for(agf__ADM_Work__c work :agileWorkRecordsRemoveThemeOne ){
            work.AH_Theme_One__c = null;
            
            update work;
        }
        
        List<agf__ADM_Theme_Assignment__c> updatedRemoveThemeOne = [SELECT AH_CreatedByAutomation__c, agf__Theme__c, agf__Work__c  
                                                                    FROM agf__ADM_Theme_Assignment__c];
        System.debug('>>>Test 3 List of Theme Assignments Found after insert: ' + updatedRemoveThemeOne);
        System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
        System.assertEquals(numberOfThemesRemoveTheme, updatedRemoveThemeOne.size(), '3. Count of Theme Assignments should be: '+numberOfThemesRemoveTheme);
        
        Test.stopTest();
        System.debug('>>>Test #3 Ends Here');
        
    }//end of Test section #3   
    
    @isTest
    public static void workTestUpdateDeleteThemeTwo(){
        
        Test.startTest();
        System.debug('>>>Test #4 Starts Here');
        
        List<agf__ADM_Work__c> agileWorkRecordsRemoveThemeTwo = [SELECT AH_Theme_One__c FROM agf__ADM_Work__c];
        for(agf__ADM_Work__c work :agileWorkRecordsRemoveThemeTwo ){
            work.AH_Theme_Two__c = null;
            
            update work;
        }
        
        List<agf__ADM_Theme_Assignment__c> updatedRemoveThemeTwo = [SELECT AH_CreatedByAutomation__c, agf__Theme__c, agf__Work__c  
                                                                    FROM agf__ADM_Theme_Assignment__c];
        System.debug('>>>Test 4 List of Theme Assignments Found after insert: ' + updatedRemoveThemeTwo);
        System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
        System.assertEquals(numberOfThemesRemoveTheme, updatedRemoveThemeTwo.size(), '4. Count of Theme Assignments should be: '+numberOfThemesRemoveTheme);
        
        Test.stopTest();
        System.debug('>>>Test #4 Ends Here');
        
    }//end of Test section #4   

    
    @isTest
    public static void workTestUpdateDeleteTwoThemes(){
        
        Test.startTest();
        System.debug('>>>Test #5 Starts Here');
        
        List<agf__ADM_Work__c> agileWorkRecordsRemove2Themes = [SELECT AH_Theme_One__c FROM agf__ADM_Work__c];
        for(agf__ADM_Work__c work :agileWorkRecordsRemove2Themes ){
            work.AH_Theme_One__c = null;
            work.AH_Theme_Two__c = null;
            
            update work;
        }
        
        List<agf__ADM_Theme_Assignment__c> updatedRemoveThemeTwoThemes = [SELECT AH_CreatedByAutomation__c, agf__Theme__c, agf__Work__c  
                                                                            FROM agf__ADM_Theme_Assignment__c];
        System.debug('>>>Test 5 List of Theme Assignments Found after insert: ' + updatedRemoveThemeTwoThemes);
        System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
        System.assertEquals(numberofThemesRemoveBothThemes, updatedRemoveThemeTwoThemes.size(), '5. Count of Theme Assignments should be: '+numberofThemesRemoveBothThemes);
        
        Test.stopTest();
        System.debug('>>>Test #4 Ends Here');
        
    }//end of Test section #5 
    
   
} //end of test class