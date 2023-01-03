/************************************************************************************************
Name            : AH_ProjectIntake_Functions_Test Class
Author          : Sean Harris
Created Date    : 10/12/2020
Last Mod Date   : 12/19/2020
Last Mod By     : Stuart Emery
NICC Reference  : NICC-047197
Description     : Test class for AH_ProjectIntake_Functions 
                : 
				: 
                :
*************************************************************************************************/
@isTest
public class AH_ProjectIntake_Functions_Test 
{

    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
/*
        // ADD RUNNING USER TO PUBLIC GROUP
        Group pg = [SELECT Id FROM Group WHERE Name = 'Recalculate Priorities Users'];
        GroupMember gm = new GroupMember();
        gm.GroupId = pg.Id;
        gm.UserOrGroupId = UserInfo.getUserId();
        insert gm;
*/
        // CREATE 20 TEST PROJECT BACKLOG RECORDS
        List<NI_Project_Backlog__c> lstPBs = new List<NI_Project_Backlog__c>();
        
        Id rt1 = Schema.SObjectType.NI_Project_Backlog__c.getRecordTypeInfosByName().get('Business Systems').getRecordTypeId();
        Id rt2 = Schema.SObjectType.NI_Project_Backlog__c.getRecordTypeInfosByName().get('Internal Project').getRecordTypeId();        
        
        Map<Integer, Decimal> mapRandomTestValues = new Map<Integer, Decimal>(); 
        mapRandomTestValues.put(1, 1000.00);
        mapRandomTestValues.put(2, 0.00);
        mapRandomTestValues.put(3, 10.00);
        mapRandomTestValues.put(4, 300.00);
        mapRandomTestValues.put(5, 100000.00);
        mapRandomTestValues.put(6, 2000.00);
        mapRandomTestValues.put(7, 1000.01);
        mapRandomTestValues.put(8, 0.00);
        mapRandomTestValues.put(9, 0.00);
        mapRandomTestValues.put(10, 50000.00);
        mapRandomTestValues.put(11, 7000.00);
        mapRandomTestValues.put(12, 900.00);
        mapRandomTestValues.put(13, 100.00);
        mapRandomTestValues.put(14, 70.00);
        mapRandomTestValues.put(15, 100000.00);
        mapRandomTestValues.put(16, 8000000.00);
        mapRandomTestValues.put(17, 7000000.00);
        mapRandomTestValues.put(18, 10000000.00);
        mapRandomTestValues.put(19, 99000.00);
        mapRandomTestValues.put(20, 50000.10);
        
        // ===========  Estimated_First_Year_Benefit__c (FORMULA)  =========================================
        // (Annual_Revenue_Increase_Confidence__c * Margin__c * Estimated_Annual_Revenue_Increase__c) +
        // (Annual_Cost_Reduction_Confidence__c * Estimated_Annual_Cost_Reduction__c) +
        // (Annual_Hours_Saved_Confidence__c * Annual_Productivity_Savings_hrs__c * Cost_of_Manhour__c)
        
        // ===========  Estimated_Total_Net_Project_Value__c (FORMULA)  ====================================
        // (Estimated_First_Year_Benefit__c * 3) - Estimated_Cost__c
        
        for (Integer i = 1; i < 21; i++)
        {
            NI_Project_Backlog__c pb = NI_TestClassData.createTestProjectBacklog(i);
            
            // FIELDS FOR Estimated_First_Year_Benefit__c FORMULA:
            pb.Annual_Revenue_Increase_Confidence__c = 10; 
            pb.Margin__c = 10;
            pb.Estimated_Annual_Revenue_Increase__c = 1000;
            pb.Annual_Cost_Reduction_Confidence__c = 80;
            pb.Estimated_Annual_Cost_Reduction__c = 10; 
            pb.Annual_Hours_Saved_Confidence__c = 100;   
            pb.Annual_Productivity_Savings_hrs__c = 10;  
            pb.Cost_of_Manhour__c = 5000;  

            // FIELD FOR Estimated_Total_Net_Project_Value__c FORMULA:
            pb.Estimated_Cost__c = mapRandomTestValues.get(i);
            
            pb.RecordTypeId = rt1;
            
            // SET DIFFERENT RECORD TYPE FOR LAST 10
            if (i > 10)
            {
                pb.RecordTypeId = rt2;
            }
            
            // ADD A OVERRIDDEN PRIORITY TO BOTH RECORD TYPE ARRAYS
            if ((i == 9) || (i == 19))
            {
                pb.Priority__c = 5;
                pb.Priority_Overriden__c = true;
            }
            
            // ADD RECORDS WITH COMPLIANCE CHECKBOXES CHECKED
            if ((i == 4) || (i == 7) || (i == 14))
            {
                pb.Required_for_Security_Compliance__c = true;
            }
            
            lstPBs.add(pb);
            
        }
        
		Database.insert(lstPBs);
        
        Test.startTest(); 
        		
        List<NI_Project_Backlog__c> lstPBAsserts = new List<NI_Project_Backlog__c>([SELECT Id FROM NI_Project_Backlog__c]);
        system.assertEquals(20, lstPBAsserts.size());

        Test.stopTest();
        
    }
  
 
    // =======================================================================================================================================
    // = TEST METHOD 1: UNIT TESTING FOR 
    // =======================================================================================================================================
    @isTest static void test1() 
    {
     	AH_ProjectIntake_Functions.recalcPriority();
    }
 
    // =======================================================================================================================================
    // = TEST METHOD 2: UNIT TESTING FOR 
    // =======================================================================================================================================
    @isTest static void test2() 
    {
     	AH_ProjectIntake_Functions.recalcPriorityOnDemand();    
    }    
 
    // =======================================================================================================================================
    // = TEST METHOD 3: UNIT TESTING FOR VF PAGE FOR ON DEMAND BUTTON
    // =======================================================================================================================================
    @isTest static void test3() 
    {
        
        List<NI_Project_Backlog__c> lstPBs = new List<NI_Project_Backlog__c>([SELECT Id FROM NI_Project_Backlog__c]);

        // TEST CONSTRUCTOR 1 (DEFAULT SCENARIO)
        PageReference pr1 = Page.AH_ProjectIntake_RecalcPriorities;
        Test.setCurrentPage(pr1);
        AH_ProjectIntake_Functions ctrl = new AH_ProjectIntake_Functions(); 
       
        // TEST CONSTRUCTOR 2 (LIST VIEW BUTTON SCENARIO)
        Test.startTest();
        
        PageReference pr2 = Page.AH_ProjectIntake_RecalcPriorities;
        Test.setCurrentPage(pr2);
        ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(lstPBs);
        setCntrlr.setSelected(lstPBs);       
        AH_ProjectIntake_Functions ctrl2 = new AH_ProjectIntake_Functions(setCntrlr); 
        ctrl2.doRecalc();
        ctrl2.goBack();  
        
        Test.stopTest();        
        
        // TEST CONSTRUCTOR 3 (DETAIL BUTTON SCENARIO)
        PageReference pr3 = Page.AH_ProjectIntake_RecalcPriorities;
        String strURL = System.URL.getSalesforceBaseURL().toExternalForm() + '/aEQ/o';
        pr3.getParameters().put('retURL', strURL);
        Test.setCurrentPage(pr3);
        ApexPages.StandardController stdCntrlr = new ApexPages.StandardController(lstPBs[0]);   
        AH_ProjectIntake_Functions ctrl3 = new AH_ProjectIntake_Functions(stdCntrlr); 
		ctrl2.goBack();
        
    }   
    
    // =======================================================================================================================================
    // = TEST METHOD 4: 
    // =======================================================================================================================================
    @isTest static void test4() 
    {    
        Database.executeBatch(new AH_ProjectIntake_Batch());
    }
    
}