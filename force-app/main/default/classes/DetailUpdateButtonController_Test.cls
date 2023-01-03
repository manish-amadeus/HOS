/****************************************************************************************
Name            : DetailUpdateButtonController_Test Class
Author          : Supriya Galinde
Created Date    : 3/20/2017
Last Mod Date   : 4/6/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : test Class for DetailUpdateButtonController Class
:  
******************************************************************************************/
@isTest
public class DetailUpdateButtonController_Test 
{
    static testMethod void testMethod1()
    {
        
        List<NI_Project_Backlog__c> projBacklogList = new List<NI_Project_Backlog__c>();
        NI_Project_Backlog__c projBacklog1 = NI_TestClassData.createTestProjectBacklog(1);
        projBacklogList.add(projBacklog1);
        insert projBacklogList;
        
        List<NI_Global_Acceptance_Criterion__c> gacList = new List<NI_Global_Acceptance_Criterion__c>();
        NI_Global_Acceptance_Criterion__c objGac1 = NI_TestClassData.createTestGAC(1, 'Account');
        insert objGac1;
        
        NI_Project_Acceptance_Criterion__c objPac1 = NI_TestClassData.createTestPAC(1, projBacklog1.Id, 'Account');
        insert objPac1;
        
        objPac1.Then__c = 'Test Then123';
        update objPac1;
        
        objGac1 = [SELECT Name,Given__c,when__c,then__c, Applicable_Object__c FROM NI_Global_Acceptance_Criterion__c WHERE Name ='Test GAC 1'];
        DetailUpdateButtonController.updateGAC(objPac1.Id);
        
        List<NI_Project_Acceptance_Criterion__c> lstPAC = new List<NI_Project_Acceptance_Criterion__c>();
        lstPAC = [select Name__c,Applicable_Object__c, Given__c,when__c,then__c from NI_Project_Acceptance_Criterion__c where Name__c = 'Test Name1'];
        system.debug('lstPAC'+lstPAC);
        
        List<NI_Global_Acceptance_Criterion__c> lstGAC = new List<NI_Global_Acceptance_Criterion__c>();
        lstGAC = [select Name,Given__c,when__c,then__c, Applicable_Object__c from NI_Global_Acceptance_Criterion__c where Name = 'Test Name1'];
        system.debug('lstGAc'+lstGAC);
        
        System.assertEquals(objPAC1.Then__c, 'Test Then123');
    }
    
    static testMethod void testMethod2()
    { 
        List<NI_Project_Backlog__c> projBacklogList = new List<NI_Project_Backlog__c>();
        NI_Project_Backlog__c projBacklog2 = NI_TestClassData.createTestProjectBacklog(2);
        projBacklogList.add(projBacklog2);
        insert projBacklogList;
        
        NI_Project_Acceptance_Criterion__c objPac2 = NI_TestClassData.createTestPAC(2, projBacklog2.Id, 'Account');
        insert objPac2;
        
        objPac2.Name__c = 'Test Name123';
        update objPac2;
        
        DetailUpdateButtonController.updateGAC(objPAC2.Id);
        List<NI_Project_Acceptance_Criterion__c> lstPAC2 = new List<NI_Project_Acceptance_Criterion__c>();
        lstPAC2 = [select Name__c,Applicable_Object__c,Given__c,when__c,then__c from NI_Project_Acceptance_Criterion__c where Name__c = 'Test Name2'];
        system.debug('lstPAC2'+lstPAC2);
        
        System.assertEquals(objPac2.Name__c, 'Test Name123');
    }
}