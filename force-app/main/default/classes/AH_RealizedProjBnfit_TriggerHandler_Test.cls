/****************************************************************************************
Name            : AH_RealizedProjBnfit_TriggerHandler_Test Class 
Author          : Sean Harris
Created Date    : 12/06/2021
Last Mod Date   : 12/06/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for AH_RealizedProjBnfit_TriggerHandler
                : 
                :
                :
******************************************************************************************/
@isTest
public class AH_RealizedProjBnfit_TriggerHandler_Test 
{
    
    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {

        agf__ADM_Scrum_Team__c st = new agf__ADM_Scrum_Team__c();
        st.agf__Active__c = true;
        st.RecordTypeId = Schema.SObjectType.agf__ADM_Scrum_Team__c.getRecordTypeInfosByName().get('Scrum Team').getRecordTypeId(); 
        st.Name = 'CBS Team TEST';
        st.agf__Cloud__c = 'Core Infrastructure';
        st.agf__Story_Point_Scale__c = '1,2,3,5,8,13,21';
        st.agf__Domain__c = '__';
        insert st;
            
            
        Id rt1 = Schema.SObjectType.NI_Project_Backlog__c.getRecordTypeInfosByName().get('Business Systems').getRecordTypeId(); 
        
        //GET WORKSTREAM NAME PICKLIST VALUES FROM PROJECT BACKLOG WORKSTREAM OBJECT 
        String strWorkstreamName1 = SObjectType.AH_Project_Backlog_Workstreams__c.Fields.Workstream_Name__c.PicklistValues[0].getValue(); 
        String strWorkstreamName2 = SObjectType.AH_Project_Backlog_Workstreams__c.Fields.Workstream_Name__c.PicklistValues[1].getValue(); 
        
        // CREATE TEST PROJECT BACKLOG RECORDS     
        NI_Project_Backlog__c pb1 = NI_TestClassData.createTestProjectBacklog(1);
        pb1.RecordTypeId = rt1;
        insert pb1;
        
        NI_Project_Backlog__c pb2 = NI_TestClassData.createTestProjectBacklog(2);
        pb2.RecordTypeId = rt1;
        insert pb2;
        
        // CREATE TEST AH WORKSTREAM RECORDS.  SET THE NAMES TO THE VALUES FROM THE WORKSTREAM NAME PICKLIST FIELD    
        AH_Workstream__c ws1 = NI_TestClassData.createTestWorkstream();
        ws1.Name = strWorkstreamName1;
        insert ws1;
        
        AH_Workstream__c ws2 = NI_TestClassData.createTestWorkstream();
        ws2.Name = strWorkstreamName2;
        insert ws2;
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: UNIT TESTING FOR INSERTING A REALIZED PROJECT BENEFIT RECORD
    // =======================================================================================================================================
    @isTest static void test1() 
    {
        
        // GET THE TEST PROJECT BACKLOG RECORD
        NI_Project_Backlog__c pb = [SELECT Id FROM NI_Project_Backlog__c LIMIT 1];
        
        // GET THE TEST WORKSTREAM RECORD
        AH_Workstream__c ws = [SELECT Id, Name, Hourly_Cost__c FROM AH_Workstream__c LIMIT 1];
        
        Test.startTest();  
        
        // CREATE A TEST AH_Realized_Project_Benefits__c RECORD
        AH_Realized_Project_Benefits__c rpb = new AH_Realized_Project_Benefits__c();
        rpb.Project_Backlog_Record__c = pb.Id;
        rpb.Workstream_Name__c = ws.Name;
        rpb.Start_Date__c = system.today();
        rpb.End_Date__c = system.today();
        insert rpb;
        
        // ASSERT THAT THE AH_Realized_Project_Benefits__c HOURLY COST EQUALS THE WORKSTREAM HOURLY COST
        AH_Realized_Project_Benefits__c rpbAssert = [SELECT Id, Hourly_Cost__c 
                                                     FROM AH_Realized_Project_Benefits__c
                                                     WHERE Workstream_Name__c =: ws.Name 
                                                     LIMIT 1];
        
        system.assertEquals(ws.Hourly_Cost__c, rpbAssert.Hourly_Cost__c);
        
        Test.stopTest();
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: UNIT TESTING FOR UPDATING A PROJECT BACKLOG WORKSTREAM RECORD
    // =======================================================================================================================================
    @isTest static void test2() 
    {
        
        // GET THE TEST PROJECT BACKLOG RECORD
        NI_Project_Backlog__c pb = [SELECT Id FROM NI_Project_Backlog__c LIMIT 1];
        
        // GET A TEST WORKSTREAM RECORD
        AH_Workstream__c ws = [SELECT Id, Name, Hourly_Cost__c FROM AH_Workstream__c LIMIT 1];
        
        // GET A SECOND TEST WORKSTREAM RECORD
        AH_Workstream__c ws2 = [SELECT Id, Name, Hourly_Cost__c FROM AH_Workstream__c WHERE Id !=: ws.Id LIMIT 1];
        
        
        Test.startTest();  
        
        // CREATE A TEST AH_Realized_Project_Benefits__c RECORD
        AH_Realized_Project_Benefits__c rpb = new AH_Realized_Project_Benefits__c();
        rpb.Project_Backlog_Record__c = pb.Id;
        rpb.Workstream_Name__c = ws.Name;
        rpb.Start_Date__c = system.today();
        rpb.End_Date__c = system.today();        
        insert rpb;
        
        // ASSERT THAT THE AH_Realized_Project_Benefits__c HOURLY COST EQUALS THE WORKSTREAM HOURLY COST
        AH_Realized_Project_Benefits__c rpbAssert1 = [SELECT Id, Hourly_Cost__c 
                                                      FROM AH_Realized_Project_Benefits__c
                                                      WHERE Workstream_Name__c =: ws.Name 
                                                      LIMIT 1];
        
        system.assertEquals(ws.Hourly_Cost__c, rpbAssert1.Hourly_Cost__c);
        
        
        AH_Realized_Project_Benefits__c rpb2 = [SELECT Id, Hourly_Cost__c 
                                                FROM AH_Realized_Project_Benefits__c
                                                WHERE Workstream_Name__c =: ws.Name 
                                                LIMIT 1];
        
        // UPDATE THE AH_Realized_Project_Benefits__c TEST THE UPDATE METHOD
        rpb2.Workstream_Name__c = ws2.Name;
        update rpb2;
        
        // ASSERT THAT THE AH_Realized_Project_Benefits__c HOURLY COST EQUALS THE WORKSTREAM HOURLY COST AFTER UPDATE
        AH_Realized_Project_Benefits__c rpbAssert2 = [SELECT Id, Hourly_Cost__c 
                                                        FROM AH_Realized_Project_Benefits__c
                                                        WHERE Workstream_Name__c =: ws2.Name 
                                                        LIMIT 1];
        
        system.assertEquals(rpb2.Hourly_Cost__c, ws2.Hourly_Cost__c);
        
        Test.stopTest();
        
    }
    
}