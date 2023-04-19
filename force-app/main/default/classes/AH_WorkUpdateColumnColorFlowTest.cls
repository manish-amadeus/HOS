/****************************************************************************************
Name            :  AH_WorkUpdateColumnColorFlowTest
Author          :  Kimberly Contreraz
Created Date    :  12/28/2022
Last Mod Date   :  02/13/2023
Last Mod By     : 
NICC Reference  : NICC-######
Description     :  Test Class for the Flow called "Work - Update Column and Color""
        : 
****************************************************************************************/
@isTest(SeeAllData=true)
public class AH_WorkUpdateColumnColorFlowTest{
    
    // * Constants
    Static final String statusNewScopeEdDev		= 'New Scope';
    Static final String statusEdDevTriaged		= 'Triaged';
    Static final String phaseDTS				= 'Technical Design';

//Tests changes to Column name based on Team of Educational Development and new Status of "New Scope"
    @isTest
    public static void updateStatusEdDevNewScopeTest(){
        
        //Find records relating to the Educational Development Team for use in updating records
        agf__ADM_Scrum_Team__c agileTeamExisting = [SELECT Id, Name FROM agf__ADM_Scrum_Team__c WHERE Name = 'Educational Development'];
        System.debug('>>>Team Record Id Found: ' + agileTeamExisting.Id);
        
        agf__ADM_Column__c edDevNewScopeColumn = [SELECT Id, Name FROM agf__ADM_Column__c 
                                               WHERE Name = 'New Scope' 
                                               AND agf__Team__c = :agileTeamExisting.Id ];
        System.debug('>>>New Scope Column Record Id Found: ' + edDevNewScopeColumn.Id);
        
        //Find a list of Work records for the Educational Development Team
        List<agf__ADM_Work__c> agileWorkRecords = [SELECT Id, agf__Status__c, agf__Scrum_Team__c, agf__Column__c FROM agf__ADM_Work__c 
                                                   WHERE agf__Scrum_Team__c = :agileTeamExisting.Id 
                                                   AND agf__Status__c = 'New' LIMIT 2];
        System.debug('>>>EdDevWork Record Found: ' + agileWorkRecords);
        System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
        
      
        Test.startTest();
        System.debug('>>>Test #1 New Scope Starts Here');{
            
            for(agf__ADM_Work__c work : agileWorkRecords){
                work.agf__Status__c = 'New Scope';  
            }
            update agileWorkRecords;
            System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
            List<agf__ADM_Work__c> updatedWorkRecords = [SELECT agf__Status__c, agf__Column__c FROM agf__ADM_Work__c 
                                                         WHERE Id IN :agileWorkRecords];
            System.debug('>>>List of Work Records Found after update New Scope: ' + updatedWorkRecords);
            
            for(agf__ADM_Work__c work : updatedWorkRecords) {
                System.debug('>>>System Debug Ready for Review Column Applied: '+ updatedWorkRecords);
                System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
                System.assertEquals(edDevNewScopeColumn.Id, work.agf__Column__c, 'Column should be: ' + edDevNewScopeColumn.Id);
                System.assertEquals(statusNewScopeEdDev, work.agf__Status__c, 'Status should be: ' + statusNewScopeEdDev);
                
            }    
            Test.stopTest();
            System.debug('>>>Test #1 New Scope Ends Here');
        }
    }//End of test #1 method    


    //Tests changes to Column name based on Team of Educational Development and new Status of "Triaged"
    @isTest
    public static void updateStatusEdDevTriagedTest(){
        
        //Find records relating to the Educational Development Team for use in updating records
        agf__ADM_Scrum_Team__c agileTeamExisting = [SELECT Id, Name FROM agf__ADM_Scrum_Team__c WHERE Name = 'Educational Development'];
        System.debug('Team Record Id Found: ' + agileTeamExisting.Id);
        
        agf__ADM_Column__c edDevTriagedColumn = [SELECT Id, Name FROM agf__ADM_Column__c WHERE Name = 'X - Sprint - 1'];
        System.debug('>>>Triaged Column Record Id Found: ' + edDevTriagedColumn.Id); 
        System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
        
        
        //Find a list of Work records for the Educational Development Team
        List<agf__ADM_Work__c> agileWorkRecords = [SELECT Id, agf__Status__c, agf__Scrum_Team__c, agf__Column__c FROM agf__ADM_Work__c 
                                                   WHERE agf__Scrum_Team__c = :agileTeamExisting.Id 
                                                   AND agf__Status__c = 'New' LIMIT 2];
        System.debug('>>>EdDevWork Record Found: ' + agileWorkRecords);
        System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
        
        
        Test.startTest();
        System.debug('>>>Test #2 Triaged Starts Here');{
            
            for(agf__ADM_Work__c work : agileWorkRecords){
                work.agf__Status__c = 'Triaged';  
            }
            update agileWorkRecords;
            List<agf__ADM_Work__c> updatedWorkRecordsTriaged = [SELECT agf__Status__c, agf__Column__c FROM agf__ADM_Work__c 
                                                                WHERE Id IN :agileWorkRecords];
            System.debug('>>>List of Work Records Found after Triaged update: ' + updatedWorkRecordsTriaged);
            System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
            
            for(agf__ADM_Work__c work : updatedWorkRecordsTriaged) {
                System.debug('>>>System Debug Column Applied: '+ updatedWorkRecordsTriaged);
                System.assertEquals(edDevTriagedColumn.Id, work.agf__Column__c, 'Column should be: ' + edDevTriagedColumn.Id);
                System.assertEquals(statusEdDevTriaged, work.agf__Status__c, 'Status should be: ' + statusEdDevTriaged);
                
            }    
            Test.stopTest();
            System.debug('>>>Test #2 Triaged Ends Here');
        }
    }//End of test method #2

    @isTest
    public static void updateDTSPhaseTest(){
    
         //Find records relating to the DTS Team for use in updating records
        agf__ADM_Scrum_Team__c dtsTeam = [SELECT Id, Name FROM agf__ADM_Scrum_Team__c WHERE Name = 'DTS Team'];
        
        agf__ADM_Product_Tag__c dtsProductTag = [SELECT Id, Name FROM agf__ADM_Product_Tag__c 
                                                 WHERE Name = 'DTS Team Miscellaneous Work'];
        
        agf__ADM_Column__c dtsTechDesignColumn = [SELECT Id, Name, Color__c FROM agf__ADM_Column__c 
                                                  WHERE Name = 'Technical Design(K)' 
                                                  AND agf__Team__c = :dtsTeam.Id];
        System.debug('>>>DTS Technical Design Column Record Id Found: ' + dtsTechDesignColumn.Id);
        System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
        
        //Find a list of Work records for the DTS Team
        List<agf__ADM_Work__c> agileWorkRecordsDTS = [SELECT Id, agf__Status__c, agf__Scrum_Team__c, agf__Column__c, agf__Product_Area__c, agf__Color__c FROM agf__ADM_Work__c 
                                                      WHERE agf__Scrum_Team__c = :dtsTeam.Id 
                                                      AND agf__Status__c = 'New' LIMIT 2];
        System.debug('>>>DTS Work Record Found: ' + agileWorkRecordsDTS);
        System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());    
        
        Test.startTest();
        System.debug('>>>Test #3 Starts Here');{
            for(agf__ADM_Work__c work : agileWorkRecordsDTS){
                work.agf__Product_Area__c 	= 'Technical Design';
            }
            update agileWorkRecordsDTS;
            List<agf__ADM_Work__c> updatedDTSWorkRecords = [SELECT agf__Column__c, agf__Product_Area__c, agf__Color__c  FROM agf__ADM_Work__c 
                                                            WHERE Id IN :agileWorkRecordsDTS];
            System.debug('>>>List of DTS Work Records Found after update: ' + updatedDTSWorkRecords);  
            System.debug(' ##### Limits.getQueries() = ' + Limits.getQueries());
            
            for(agf__ADM_Work__c work1 : updatedDTSWorkRecords) {
                System.debug('>>>DTS System Debug Column Applied: '+ updatedDTSWorkRecords);
                System.assertEquals(dtsTechDesignColumn.Id, work1.agf__Column__c, 'Column should be: ' + dtsTechDesignColumn.Id);
                System.assertEquals(phaseDTS, work1.agf__Product_Area__c, 'Project Phase should be: ' + phaseDTS);
            }
            Test.stopTest();
            System.debug('>>>Test #3 Ends Here');
           
        }
    
} //end of test class

}