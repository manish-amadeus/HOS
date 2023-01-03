/************************************************************************************************
Name            : PrepareSandboxPostRefresh_Test
Author          : Princy Jain
Created Date    : 11/28/2018
Last Mod Date   : 11/28/2018
Last Mod By     : Princy Jain
NICC Reference  : 
Description     : Tests PrepareSandboxPostRefresh
                : 
************************************************************************************************/
@isTest
public class PrepareSandboxPostRefresh_Test 
{

    @isTest
    static void testSandboxPrep() 
    {
        
        // WinaproachIncidentSettings__c winAppCS2 = NI_TestClassData.createWinaproachIncidentSettings();
        // insert winAppCS2;
        // ServiceNowIncidentSettings__c snSett
        
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        system.debug('Value is :>>>>>>>>>>>> ' + ServiceNowIncidentSettings__c.getValues('Default'));
        system.debug ('CS Default value is :>>>>>>>>>>>> ' + WinaproachIncidentSettings__c.getValues('Default'));
        
        Test.startTest();

        Test.testSandboxPostCopyScript(new PrepareSandboxPostRefresh(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());

        Test.stopTest();
        
        system.debug('Value is :>>>>>>>>>>>> ' + ServiceNowIncidentSettings__c.getValues('Default'));
        system.debug ('CS Default value is :>>>>>>>>>>>> ' + WinaproachIncidentSettings__c.getValues('Default'));
        
    }
    
}