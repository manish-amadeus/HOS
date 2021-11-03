/****************************************************************************************
Name            : AH_BusinessSystemsLoginFlowHandlerTest
Author          : Stuart Emery
Created Date    : 02/07/2019
Last Mod Date   : 02/07/2019
Last Mod By     : Stuart Emery
NICC Reference  : NICC-032808
Description     : Test Class for AH_BusinessSystemsLoginFlowHandler which is a controller for 
				: AH_BusinessSystemsAnnouncementLoginFlow VF Page.
Unit Testing
============

******************************************************************************************/
@isTest
public class AH_BusinessSystemsLoginFlowHandlerTest {
    
    public static testMethod void testMyController()
    {
    
    // PAGE REFERENCE        
        PageReference pageRef = Page.AH_BusinessSystemsAnnouncementLoginFlow;
        
        // SET TEST PAGE
		Test.setCurrentPage(pageRef);       
    
    // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_BusinessSystemsLoginFlowHandler ctrl = new AH_BusinessSystemsLoginFlowHandler();  
    
        // TEST CLICKING THE CONTINUE BUTTON   
        ctrl.FinishLoginFlowHome();
    }     

}