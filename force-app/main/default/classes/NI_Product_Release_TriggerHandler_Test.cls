/****************************************************************************************
Name            : NI_Product_Release_TriggerHandler_Test Class
Author          : Sean Harris
Created Date    : 1/27/2016
Last Mod Date   : 1/27/2016
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_Product_Release_TriggerHandler_Test
{

    public static testMethod void testTrigHandler() 
    {

        Date myDate1 = Date.newInstance(2015, 1, 1);
		Date myDate2 = Date.newInstance(2015, 1, 1);
                
        User ManagerId = NI_TestClassData.createTestUser(1, 'NI Administrator'); 
        insert ManagerId;

        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;

        List<SFDC_CSP_Version__c> lstVersions = new List<SFDC_CSP_Version__c>();
            
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        lstVersions.Add(vrs01);
        SFDC_CSP_Version__c vrs02 = NI_TestClassData.createVersion('v2.', pgp.Id, 2);
        lstVersions.Add(vrs02);
        SFDC_CSP_Version__c vrs03 = NI_TestClassData.createVersion('v3.', pgp.Id, 3);
        lstVersions.Add(vrs03);
        
        Database.insert(lstVersions);
        
        NI_Product_Release__c prdRel = NI_TestClassData.createTestNI_Product_Release(pgp.Id, ManagerId.Id, 201);
        insert prdRel;
        
        prdRel.Status__c = 'Released'; 
        update prdRel;
        
        prdRel.Name = 'v1.1'; 
        update prdRel;

    }

}