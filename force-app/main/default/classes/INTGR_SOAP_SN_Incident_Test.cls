/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_SOAP_SN_Incident_Test Test Class
Author          : Princy Jain
Created Date    : 06/13/2018
Last Mod Date   : 01/16/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class for INTGR_SOAP_SN_Incident Class
                : 
                : 
******************************************************************************************/
@isTest
private class INTGR_SOAP_SN_Incident_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================   
    static testmethod void coverSoapIncidentWSDL() 
    {
        
        User cUser = NI_TestClassData.createTestUser(111, 'System Administrator');
        cUser.Email = 'testuserZzzzzz' + 111 + '@salesforce.com';
        cUser.Alias = '111user';
        insert cUser ; 
        
/*
        Account a1 = NI_TestClassData.createTestAccount(1);
        insert a1;
        
        INTGR_Account__c acc= NI_TestClassData.createTestINTGR_Account(1, a1.id, cUser.id) ;
        acc.Active__c =true;
        insert acc;
        
        List<INTGR_Field_Mapping__c> fMapping = NI_TestClassData.createTestINTGR_AccountMapping  (1,acc.id);
        insert fMapping ;
        
        Map <String, String> srcTargetFieldMap1 = new Map < String, String >();
        srcTargetFieldMap1.put ('Description__c', 'Description');
        
        Case cs = NI_TestClassData.createTestCaseIntegration(1, a1.Id);
        cs.Integration_Account__c = acc.Id;
        insert cs;
        
        INTGR_Case__c  caseObj =  NI_TestClassData.createTestINTGR_Case(1, acc.id, cs.id) ;
        insert caseObj; 
*/
        
        INTGR_SOAP_SN_Incident.insert_element insertObj = new INTGR_SOAP_SN_Incident.insert_element();
        insertObj.incident_state = 'New';
        INTGR_SOAP_SN_Incident.update_element updateObj = new INTGR_SOAP_SN_Incident.update_element();
        updateObj.incident_state = 'New';
        INTGR_SOAP_SN_Incident.ServiceNowSoap soap = new INTGR_SOAP_SN_Incident.ServiceNowSoap();
        
        INTGR_SOAP_SN_Incident.getRecords_element ele1 = new INTGR_SOAP_SN_Incident.getRecords_element();
        INTGR_SOAP_SN_Incident.getKeysResponse_element obj1 = new INTGR_SOAP_SN_Incident.getKeysResponse_element();
        INTGR_SOAP_SN_Incident.getRecordsResult_element obj2 = new INTGR_SOAP_SN_Incident.getRecordsResult_element();
        INTGR_SOAP_SN_Incident.getKeys_element obj3 = new INTGR_SOAP_SN_Incident.getKeys_element();
        INTGR_SOAP_SN_Incident.getResponse_element obj4 = new INTGR_SOAP_SN_Incident.getResponse_element();
        INTGR_SOAP_SN_Incident.getRecordsResponse_element obj5 = new INTGR_SOAP_SN_Incident.getRecordsResponse_element();
        INTGR_SOAP_SN_Incident.updateResponse_element obj6 = new INTGR_SOAP_SN_Incident.updateResponse_element();
        INTGR_SOAP_SN_Incident.get_element ele7 = new INTGR_SOAP_SN_Incident.get_element();
        INTGR_SOAP_SN_Incident.insertResponse_element ele8 = new INTGR_SOAP_SN_Incident.insertResponse_element();
        
        try
        {
            ele8 = soap.insert_x(insertObj, 'https://login.salesforce.com');
            String response = soap.update_x(updateObj, 'https://login.salesforce.com');
        }
        catch (Exception e) 
        {
            system.debug('exception : ' + e.getMessage());
            system.debug('exception stack trace : ' + e.getStackTraceString());
        }
        
    }
    
}