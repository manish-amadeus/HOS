/************************************************************************************************
Name            : NI_IServer_TriggerHandler_Test Class
Author          : Suzanne LeDuc
Created Date    : 09/10/2015
Last Mod Date   : 08/02/2019
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : NICC-014223
Description     : Class that tests NI_IServer_TriggerHandler_Test Class
                :
                :
*************************************************************************************************/
@isTest
public class NI_IServer_TriggerHandler_Test 
{
    
    
    public static testMethod void NI_IServerInsertHandlerTest() 
    {
        ///Create Org Details Record
        Account a = NI_TestClassData.CreateTestAccount(1);
        
        NI_Org_Details__c orgDetails = NI_TestClassData.createTestNiOrgDetails( '01260000000DnbPAAS',1,'Salesforce Production');
        insert orgDetails;
        
        //Create System Record
        newmarketsvcs__IServer__c nwsSystem = new newmarketsvcs__IServer__c();
        nwsSystem.newmarketsvcs__IServer_ID__c = 'IS-99999';
        nwsSystem.newmarketsvcs__NewmarketUser__c = 'Org.00D00000000abce@Delphi.fdc';
        insert nwsSystem;
        
       

    }
    
    
    
    // ======================================================================================================================================= //
    // = BULK INSERT TEST
    // ======================================================================================================================================= //
    public static testMethod void NWS_Newmarketsvcs_IServer_BulkTest() 
    {    
        
        List<NI_Org_Details__c> lstOrgDetailsInsert = new List<NI_Org_Details__c>();
        List<newmarketsvcs__IServer__c> lstNWS_IServerInsert = new List<newmarketsvcs__IServer__c>();
        
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin');   
        
        String s = '00000';
        
        /**********
        NI_TriggerBypassSwitches__c niNWSCustomSetting = new NI_TriggerBypassSwitches__c();         
        niNWSCustomSetting.Name = 'BypassNWSIServer_ON__c';        
        niNWSCustomSetting.BypassNWSIServer_ON__c = true;        
        insert niNWSCustomSetting;
        
        List<NI_TriggerBypassSwitches__c> custLst = [Select id,BypassNWSIServer_ON__c from NI_TriggerBypassSwitches__c];
        system.debug('custLst' + custLst);
        //update niNWSCustomSetting;
        ***********/
        // CREATE TEST ACCOUNT RECORD
        Account a = NI_TestClassData.CreateTestAccount(1);
        insert a;        
        
		test.startTest();        
        // CREATE 200+ ORG DETAILS & NWS I-SERVER RECORDS 
        for (integer i = 2; (i < 202); i++)
        {
            NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production');
            
            od.Org_Name__c = a.Name;
            string strOrgId = 'XXXXXXXXXX' + s.Substring(0, (s.Length() - String.valueOf(i).Length())) + String.valueOf(i);
            od.Org_ID__c = strOrgId;
            od.AdminLoginName__c = 'test@test.com';
            od.AdminPassword__c = '123456789';
            od.License_Type__c =  'Enterprise';
            od.Org_Status__c = 'In Process';
            od.Inactive__c = false;
            
            lstOrgDetailsInsert.add(od);   
            
           
            newmarketsvcs__IServer__c nwsSys = NI_TestClassData.CreateTestNWS_IServer(i, 'Org.' + strOrgId + '@Delphi.fdc');
            lstNWS_IServerInsert.add(nwsSys);
            
        }
        
        Database.insert(lstOrgDetailsInsert);
        
        Database.insert(lstNWS_IServerInsert);
        
        test.stopTest();
        
    }   
    
    public static testMethod void NI_IServerInsertHandlerNegativeTest() 
    {
        ///Create Org Details Record
        Account a = NI_TestClassData.CreateTestAccount(1);
        
        NI_Org_Details__c orgDetails = NI_TestClassData.createTestNiOrgDetails( '01260000000DnbPAAS',1,'Salesforce Production');
        insert orgDetails;
        
        //Create System Record
        newmarketsvcs__IServer__c nwsSystem = new newmarketsvcs__IServer__c();
        nwsSystem.newmarketsvcs__IServer_ID__c = 'IS-99999';
        //nwsSystem.newmarketsvcs__NewmarketUser__c = 'Org.00D00000000abce@Delphi.fdc';
        insert nwsSystem;
        
    }

}