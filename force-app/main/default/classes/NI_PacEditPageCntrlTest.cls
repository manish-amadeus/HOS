/****************************************************************************************
Name            : NI_PacEditPageCntrlTest Class
Author          : Supriya Galinde
Created Date    : 3/20/2017
Last Mod Date   : 4/11/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : test Class for NI_PACEditPageController Class
:  
******************************************************************************************/
@isTest
public class NI_PacEditPageCntrlTest 
{
    static testMethod void testMethod1()
    {
        NI_Project_Backlog__c objProjectBacklog = NI_TestClassData.createTestProjectBacklog(1);
		insert objProjectBacklog;
        
         NI_Global_Acceptance_Criterion__c objGAC1 = NI_TestClassData.createTestGAC(1, 'Account');
         objGAC1.Name = 'Test PAC 1';
         insert objGAC1;
        
        NI_Project_Acceptance_Criterion__c objPAC1 = NI_TestClassData.createTestPAC(1, objProjectBacklog.Id, 'Acceptance Criterion');
         objPac1.NI_Global_Acceptance_Criterion__c = objGac1.Id;
         insert objPAC1;
        
        ApexPages.StandardController stdLead = new ApexPages.StandardController(objPAC1);
		NI_PACEditPageController pacCntrl = new NI_PACEditPageController(stdLead);
        objPAC1.Then__c = 'Test Then123';
        update objPAC1;       
        
        pacCntrl.DoSave();
        pacCntrl.DoSaveNew();
        pacCntrl.DoCancel();
        System.assertEquals(objPAC1.Then__c, 'Test Then123');
    }
    
    static testMethod void testMethod2()
    {
        NI_Project_Backlog__c objProjectBacklog = NI_TestClassData.createTestProjectBacklog(1);
		insert objProjectBacklog;
        
         NI_Global_Acceptance_Criterion__c objGAC2 = NI_TestClassData.createTestGAC(1, 'Acceptance Criterion');
         insert objGAC2;
        
        NI_Project_Acceptance_Criterion__c objPAC2 = NI_TestClassData.createTestPAC(1, objProjectBacklog.Id, 'Acceptance Criterion');
         objPAC2.NI_Global_Acceptance_Criterion__c = objGac2.Id;
         insert objPAC2;
        
        objPAC2.Name__c = 'Test Name123';
        update objPAC2;   
        
        ApexPages.StandardController stdCntrl = new ApexPages.StandardController(objPAC2);
		NI_PACEditPageController pacCntrl = new NI_PACEditPageController(stdCntrl);
        objPAC2.Then__c = 'Test Then123';
        update objPAC2;     
        
        pacCntrl.DoSave();
        pacCntrl.DoSaveNew();
        pacCntrl.DoCancel();
        
        System.assertEquals(objPAC2.Name__c, 'Test Name123');
    }
}