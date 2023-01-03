/****************************************************************************************
Name            : AH_ProjBacklgWorkstrm_TriggerHandlerTest Class 
Author          : Stuart Emery
Created Date    : 11/26/2020
Last Mod Date   : 11/26/2020 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-047197
Description     : Test class for AH_ProjBacklogWorkstream_TriggerHandler Class 
				:
******************************************************************************************/
@isTest
public class AH_ProjBacklgWorkstrm_TriggerHandlerTest 
{
    
    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
      Id rt1 = Schema.SObjectType.NI_Project_Backlog__c.getRecordTypeInfosByName().get('Business Systems').getRecordTypeId();  
      
      //GET WORKSTREAM NAME PICKLIST VALUES FROM PROJECT BACKLOG WORKSTREAM OBJECT
      String strWorkstreamName1 = SObjectType.AH_Project_Backlog_Workstreams__c.Fields.Workstream_Name__c.PicklistValues[0].getValue();
      String strWorkstreamName2 = SObjectType.AH_Project_Backlog_Workstreams__c.Fields.Workstream_Name__c.PicklistValues[1].getValue();   
        
        
        // CREATE TEST PROJECT BACKLOG RECORDS     
        Integer i = 1;
        NI_Project_Backlog__c pb1 = NI_TestClassData.createTestProjectBacklog(i);
        pb1.RecordTypeId = rt1;
        insert pb1;
        
        i = i++;
        NI_Project_Backlog__c pb2 = NI_TestClassData.createTestProjectBacklog(i);
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
    // = TEST METHOD 1: UNIT TESTING FOR INSERTING A PROJECT BACKLOG WORKSTREAM RECORD
    // =======================================================================================================================================
    @isTest static void test1() 
    {
     	//GET THE TEST PROJECT BACKLOG RECORD
        NI_Project_Backlog__c pb = [SELECT Id FROM NI_Project_Backlog__c Limit 1];
        
        //GET THE TEST WORKSTREAM RECORD
        AH_Workstream__c ws = [SELECT Id, Name, Hourly_Cost__c FROM AH_Workstream__c Limit 1];
     
      Test.startTest();  
        
        //CREATE A TEST PROJECT BACKLOG WORKSTREAM RECORD
        AH_Project_Backlog_Workstreams__c pbw = NI_TestClassData.createTestProjectWorkstream(pb.Id);
        pbw.Workstream_Name__c = ws.Name;
        insert pbw;
        
        //ASSERT THAT THE PROJECT BACKLOG WORKSTREAM HOURLY COST EQUALS THE WORKSTREAM HOURLY COST
        AH_Project_Backlog_Workstreams__c pbw1 = [SELECT Id, Hourly_Cost__c FROM AH_Project_Backlog_Workstreams__c
                                                  WHERE Workstream_Name__c =: ws.Name LIMIT 1];
        system.assertEquals(pbw1.Hourly_Cost__c, ws.Hourly_Cost__c);
        
        Test.stopTest();
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: UNIT TESTING FOR UPDATING A PROJECT BACKLOG WORKSTREAM RECORD
    // =======================================================================================================================================
    @isTest static void test2() 
    {
     	//GET THE TEST PROJECT BACKLOG RECORD
        NI_Project_Backlog__c pb = [SELECT Id FROM NI_Project_Backlog__c Limit 1];
        
        //GET A TEST WORKSTREAM RECORD
        AH_Workstream__c ws = [SELECT Id, Name, Hourly_Cost__c FROM AH_Workstream__c Limit 1];
        
        //GET A SECOND TEST WORKSTREAM RECORD
        AH_Workstream__c ws2 = [SELECT Id, Name, Hourly_Cost__c FROM AH_Workstream__c
                                WHERE Id !=: ws.Id Limit 1];
     
      Test.startTest();  
        
        //CREATE A TEST PROJECT BACKLOG WORKSTREAM RECORD
        AH_Project_Backlog_Workstreams__c pbw = NI_TestClassData.createTestProjectWorkstream(pb.Id);
        pbw.Workstream_Name__c = ws.Name;
        insert pbw;
        
        AH_Project_Backlog_Workstreams__c pbw1 = [SELECT Id, Hourly_Cost__c FROM AH_Project_Backlog_Workstreams__c
                                                  WHERE Workstream_Name__c =: ws.Name LIMIT 1];
        
        //UPDATE THE PROJECT BACKLOG WORKSTREAM TEST THE UPDATE METHODS
        pbw1.Workstream_Name__c = ws2.Name;
        update pbw1;
        
        //ASSERT THAT THE NET CREDIT AMOUNT ON THE FINANCE REQUEST REFLECTS THE TAX AMOUNT
        AH_Project_Backlog_Workstreams__c pbw2 = [SELECT Id, Hourly_Cost__c FROM AH_Project_Backlog_Workstreams__c
                                                  WHERE Workstream_Name__c =: ws2.Name LIMIT 1];
        system.assertEquals(pbw2.Hourly_Cost__c, ws2.Hourly_Cost__c);
        
        Test.stopTest();
    }
    
}