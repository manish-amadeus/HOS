/****************************************************************************************
Name            : NI_GAC_TriggerHandler_Test Class
Author          : Supriya Galinde
Created Date    : 3/20/2017
Last Mod Date   : 4/6/2017
Last Mod By     : Supriya Galinde
NICC Reference  : NICC-021925 
Description     : test Class for NI_Global_Acceptance_TriggerHandler Class
				:  
******************************************************************************************/
@isTest
public class NI_GAC_TriggerHandler_Test 
{
    static testMethod void testMethod1()
    {
        List<NI_Project_Backlog__c> projBacklogList = new List<NI_Project_Backlog__c>();
        NI_Project_Backlog__c projBacklog1 = NI_TestClassData.createTestProjectBacklog(1);
        projBacklogList.add(projBacklog1);
        insert projBacklogList;
        
        NI_Project_Acceptance_Criterion__c objPac1 = NI_TestClassData.createTestPAC(1, projBacklog1.Id, 'Account');
        insert objPac1;
        
        List<NI_Global_Acceptance_Criterion__c> gacList = new List<NI_Global_Acceptance_Criterion__c>();
        NI_Global_Acceptance_Criterion__c objGac1 = NI_TestClassData.createTestGAC(1, 'Account');
        insert objGac1;
        
        objPac1.NI_Global_Acceptance_Criterion__c = objGac1.Id;
        update objPac1;
        
        System.assertEquals(objPac1.NI_Global_Acceptance_Criterion__c, objGac1.Id);
    }
}