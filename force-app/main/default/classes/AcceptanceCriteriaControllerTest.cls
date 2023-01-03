/**********************************************************************************************************
Name            : AcceptanceCriteriaControllerTest Class
Author          : Nidhi Singh
Created Date    : 09/30/2016
Last Mod Date   : 04/11/2017
Last Mod By     : Supriya Galinde
NICC Reference  :
Description     : Test Class
***********************************************************************************************************/
@isTest 
public class AcceptanceCriteriaControllerTest {
	 static testMethod void testAcceptanceCriteriaControllerSave() {
         
        PageReference pref = Page.AssociateAcceptanceCriteria;
        Test.setCurrentPage(pref);
         List<NI_Project_Backlog__c> projBacklogList = new List<NI_Project_Backlog__c>();
         
        NI_Project_Backlog__c projBacklog1 = NI_TestClassData.createTestProjectBacklog(1);
		projBacklogList.add(projBacklog1);
         
         NI_Project_Backlog__c projBacklog2 = NI_TestClassData.createTestProjectBacklog(2);
		projBacklogList.add(projBacklog2);
         insert projBacklogList;
         
        ApexPages.currentPage().getParameters().put('NI_Project_Backlog__c', projBacklog1.Id); 
         List<NI_Global_Acceptance_Criterion__c> gacList = new List<NI_Global_Acceptance_Criterion__c>();
         NI_Global_Acceptance_Criterion__c objGac1 = NI_TestClassData.createTestGAC(1, 'Account');
         gacList.add(objGac1);
         
         NI_Global_Acceptance_Criterion__c objGac2 = NI_TestClassData.createTestGAC(2, 'Account');
         gacList.add(objGac2);
         
         NI_Global_Acceptance_Criterion__c objGac3 = NI_TestClassData.createTestGAC(3, 'Account');
         gacList.add(objGac3);
         insert gacList;
         
         List<NI_Project_Acceptance_Criterion__c> pacList = new List<NI_Project_Acceptance_Criterion__c>();
         NI_Project_Acceptance_Criterion__c objPac1 = NI_TestClassData.createTestPAC(1, projBacklog1.Id, 'Account');
         objPac1.NI_Global_Acceptance_Criterion__c = objGac1.Id;
         pacList.add(objPac1);
         
         NI_Project_Acceptance_Criterion__c objPac2 = NI_TestClassData.createTestPAC(2, projBacklog2.Id, 'Account');
         objPac2.NI_Global_Acceptance_Criterion__c = objGac2.Id;
         pacList.add(objPac2);
         insert pacList;
        
         AcceptanceCriteriaController.WrapperCriteria WC = new AcceptanceCriteriaController.WrapperCriteria(); 
         WC.acceptanceId = objPac1.id;
         WC.optionGiven = 'Account Given';
         WC.optionWhen = 'Account When';
         WC.optionThen = 'Account Then'; 
         WC.optionSelected = true;
         
         // Construct the standard controller
        ApexPages.StandardController con = new ApexPages.StandardController(projBacklog1);
        List<NI_Project_Acceptance_Criterion__c> pacListBefore = [SELECT Id, Name, NI_Project_Backlog__c FROM NI_Project_Acceptance_Criterion__c
                                                           WHERE NI_Project_Backlog__c = :projBacklog1.Id];
         system.debug('pacListBefore'+pacListBefore);
         system.assertEquals(1, pacListBefore.size());
        //create the controller
        AcceptanceCriteriaController acceptCriteria = new AcceptanceCriteriaController(con);
        acceptCriteria.selectedObject = 'Account';
        acceptCriteria.displayAccCriteria = false;
         
        acceptCriteria.displayAffectedObject();
        acceptCriteria.getAffectedObject(); 
        acceptCriteria.onchangeView();
        acceptCriteria.getAcceptanceCriteria();
         system.debug('acceptCriteria'+acceptCriteria.criteriaWrapper);
         //acceptCriteria.criteriaWrapper[1].optionSelected = false;
         acceptCriteria.criteriaWrapper[2].optionSelected = true;
         system.debug('WC->' + WC);
        acceptCriteria.actionSave();
        acceptCriteria.actionCancel();
        acceptCriteria.clearvalidationWarning();
        List<NI_Project_Acceptance_Criterion__c> pacListAfter = [SELECT Id, Name, NI_Project_Backlog__c FROM NI_Project_Acceptance_Criterion__c
                                                           WHERE NI_Project_Backlog__c = :projBacklog1.Id];
         system.debug('pacListAfter'+pacListAfter);
         system.assertEquals(2, pacListAfter.size());
     }
    
    static testMethod void testAcceptanceCriteriaControllerDelete() {
         
      PageReference pref = Page.AssociateAcceptanceCriteria;
        Test.setCurrentPage(pref);
         List<NI_Project_Backlog__c> projBacklogList = new List<NI_Project_Backlog__c>();
         
        NI_Project_Backlog__c projBacklog1 = NI_TestClassData.createTestProjectBacklog(1);
		projBacklogList.add(projBacklog1);
         
         //NI_Project_Backlog__c projBacklog2 = NI_TestClassData.createTestProjectBacklog(2);
		//projBacklogList.add(projBacklog2);
         insert projBacklogList;
         
        ApexPages.currentPage().getParameters().put('NI_Project_Backlog__c', projBacklog1.Id); 
         List<NI_Global_Acceptance_Criterion__c> gacList = new List<NI_Global_Acceptance_Criterion__c>();
         NI_Global_Acceptance_Criterion__c objGac1 = NI_TestClassData.createTestGAC(1, 'Account');
         gacList.add(objGac1);
         
         NI_Global_Acceptance_Criterion__c objGac2 = NI_TestClassData.createTestGAC(2, 'Account');
         gacList.add(objGac2);
         
         //NI_Global_Acceptance_Criterion__c objGac3 = NI_TestClassData.createTestGAC(3, 'Account');
         //gacList.add(objGac3);
         insert gacList;
         
         List<NI_Project_Acceptance_Criterion__c> pacList = new List<NI_Project_Acceptance_Criterion__c>();
         //createTestPAC(Integer iRecordNumber, Id projBacklogId, String applicableObj)
         NI_Project_Acceptance_Criterion__c objPac1 = NI_TestClassData.createTestPAC(1, projBacklog1.Id, 'Account');
         objPac1.NI_Global_Acceptance_Criterion__c = objGac1.Id;
         pacList.add(objPac1);
         
         NI_Project_Acceptance_Criterion__c objPac2 = NI_TestClassData.createTestPAC(2, projBacklog1.Id, 'Account');
         objPac2.NI_Global_Acceptance_Criterion__c = objGac2.Id;
         pacList.add(objPac2);
         insert pacList;
        
        List<NI_Project_Acceptance_Criterion__c> pacListBefore = [SELECT Id, Name, NI_Project_Backlog__c 
                                                                  FROM NI_Project_Acceptance_Criterion__c
                                                                  WHERE NI_Project_Backlog__c = :projBacklog1.Id];
         system.debug('pacListBefore'+pacListBefore);
        
         AcceptanceCriteriaController.WrapperCriteria WC = new AcceptanceCriteriaController.WrapperCriteria(); 
         WC.acceptanceId = objPac1.id;
         WC.optionGiven = 'Account Given';
         WC.optionWhen = 'Account When';
         WC.optionThen = 'Account Then'; 
         WC.optionSelected = true;
         
         // Construct the standard controller
        ApexPages.StandardController con = new ApexPages.StandardController(projBacklog1);
        
        //create the controller
        AcceptanceCriteriaController acceptCriteria = new AcceptanceCriteriaController(con);
        acceptCriteria.selectedObject = 'Account';
        acceptCriteria.displayAccCriteria = false;
         
        acceptCriteria.displayAffectedObject();
        acceptCriteria.getAffectedObject(); 
        acceptCriteria.onchangeView();
        acceptCriteria.getAcceptanceCriteria();
         //acceptCriteria.recordsToInsert = new Set<Id>();
         //acceptCriteria.recordsToInsert.add(projAccepCriteria2.Id);
         system.debug('acceptCriteria'+acceptCriteria.criteriaWrapper);
         acceptCriteria.criteriaWrapper[1].optionSelected = false;
         //acceptCriteria.criteriaWrapper[2].optionSelected = true;
         system.debug('WC->' + WC);
        acceptCriteria.actionSave();
        //acceptCriteria.actionCancel();
        //acceptCriteria.clearvalidationWarning();
         List<NI_Project_Acceptance_Criterion__c> pacListAfter = [SELECT Id, Name, NI_Project_Backlog__c FROM NI_Project_Acceptance_Criterion__c
                                                           WHERE NI_Project_Backlog__c = :projBacklog1.Id];
         system.debug('pacListAfter'+pacListAfter);
     }
}