/****************************************************************************************
Name            : NI_PAC_TriggerHandler_Test Class
Author          : Supriya Galinde
Created Date    : 3/20/2017
Last Mod Date   : 4/6/2017
Last Mod By     : Supriya Galinde
NICC Reference  : NICC-021925 
Description     : test Class for NI_Project_Acceptance_TriggerHandler Class
				:  
******************************************************************************************/
@isTest
public class NI_PAC_TriggerHandler_Test 
{
    static testMethod void testPACInsert()
    {
        NI_PAC_TriggerHandler_Test handler = new NI_PAC_TriggerHandler_Test();
        
        List<NI_Project_Backlog__c> projBacklogList = new List<NI_Project_Backlog__c>();
        NI_Project_Backlog__c projBacklog1 = NI_TestClassData.createTestProjectBacklog(1);
        projBacklogList.add(projBacklog1);
        insert projBacklogList;
        
        NI_Project_Acceptance_Criterion__c objPac1 = NI_TestClassData.createTestPAC(1, projBacklog1.Id, 'Account');
        insert objPac1;
        
        System.assertEquals(objPAC1.Name__c, 'Test PAC 1');   
    }
    
    static testMethod void testMethod2()
    {
        
        List<NI_Project_Backlog__c> projBacklogList = new List<NI_Project_Backlog__c>();
        NI_Project_Backlog__c projBacklog2 = NI_TestClassData.createTestProjectBacklog(2);
        projBacklogList.add(projBacklog2);
        insert projBacklogList;
        
        List<NI_Global_Acceptance_Criterion__c> gacList = new List<NI_Global_Acceptance_Criterion__c>();
        NI_Global_Acceptance_Criterion__c objGac1 = NI_TestClassData.createTestGAC(1, 'Account');
        insert objGac1;
        
        List<NI_Project_Acceptance_Criterion__c> pacList = new List<NI_Project_Acceptance_Criterion__c>();
        NI_Project_Acceptance_Criterion__c objPac2 = NI_TestClassData.createTestPAC(2, projBacklog2.Id, 'Account');
        objPac2.NI_Global_Acceptance_Criterion__c = objGac1.Id;
        pacList.add(objPac2);
        insert pacList;
        
        System.assertEquals(objPAC2.Name__c, 'Test PAC 2');
    }
    
}