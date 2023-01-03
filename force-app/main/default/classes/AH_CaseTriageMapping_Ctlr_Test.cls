/****************************************************************************************
Name            : AH_CaseTriageMapping_Ctlr_Test
Author          : Sean Harris
Created Date    : 05/19/2021
Last Mod Date   : 05/19/2021
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : Test for the AH_CaseTriageMapping_Ctlr Apex Class.
                :            
******************************************************************************************/
@isTest
public class AH_CaseTriageMapping_Ctlr_Test 
{
    
    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {
        AH_Case_Triage_Mapping__c x = new AH_Case_Triage_Mapping__c();
        x.Active__c = true;
        x.Case_Record_Type__c = 'Case'; 
        x.Case_Product_Line__c = 'PMS Connect';
        //x.Component__c = ''; 
        //x.Module__c = ''; 
        //x.Queue_Assignment__c = '';
        x.Queue_Assignment_ID__c = '00G60000001DAkAEAW';
        x.Requested_By__c = 'Hugh Janus'; 
        x.Match_Type__c = 'Subject Only'; 
        x.Text_String_for_Match__c = '**PROBLEM'; 
        
        insert x;
    }
    
    
    // =======================================================================================================================================
    // = TEST METHOD 1: SEARCH & ATTACH EXISTING ESCALATION
    // =======================================================================================================================================    
    @isTest static void test1() 
    {
        
        AH_Case_Triage_Mapping__c triMap = [SELECT Id, Queue_Assignment_ID__c FROM AH_Case_Triage_Mapping__c WHERE Queue_Assignment_ID__c = '00G60000001DAkAEAW'];
        
        Test.startTest(); 
        
        // INSTANTIATE PAGE REFERENCE 
        PageReference pr = Page.AH_CaseTriageMapping; 
        Test.setCurrentPage(pr);       
        
        // ADD URL PARAMS 
        pr.getParameters().put('id', triMap.Id); 
        
        // INSTANTIATE PAGE CONTROLLER         
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(triMap);
        AH_CaseTriageMapping_Ctlr ctrl = new AH_CaseTriageMapping_Ctlr(stdCtrl); 
        
        system.debug(ctrl.lstQueues);  
        system.debug(ctrl.ctm); 
        system.debug(ctrl.selQueue); 
        system.debug(ctrl.redirectUrl); 
        system.debug(ctrl.shouldRedirect); 
        system.debug(ctrl.bInEdit); 
        system.debug(ctrl.bHasEdit);        
        ctrl.toggleEdit();
        ctrl.doCancel();
        ctrl.toggleEdit();
        ctrl.saveQueueChange();
        
        Test.stopTest(); 
        
    }
    
}