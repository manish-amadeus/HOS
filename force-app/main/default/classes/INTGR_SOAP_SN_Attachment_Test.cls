/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : INTGR_SOAP_SN_Attachment_Test 
Author          : Princy Jain
Created Date    : 06/13/2018
Last Mod Date   : 01/16/2019
Last Mod By     : Princy Jain
NICC Reference  : 
Description     : Test Class for INTGR_SOAP_SN_Attachment Class
                : 
                : 
******************************************************************************************/
@isTest
private class INTGR_SOAP_SN_Attachment_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================  
    static testmethod void coverSoapAttachmentWSDL() 
    {
        
        User cUser = NI_TestClassData.createTestUser(111, 'System Administrator');
        cUser.Email = 'testuserZzzzzz' + 111 + '@salesforce.com';
        cUser.Alias = '111user';
        insert cUser ; 
        
        INTGR_SOAP_SN_Attachment.insert_element insertObj = new INTGR_SOAP_SN_Attachment.insert_element();
        
        //POPULATE REQUEST PARAMS 
        insertObj.topic = 'AttachmentCreator';
        insertObj.agent = 'AttachmentCreator';
        insertObj.payload = String.valueOf('Test677485858854uhrhrytghrt');
        //Source = incident:dd90c5d70a0a0b39000aac5aee704ae8
        insertObj.source = 'incident:dd90c5d70a0a0b39000aac5aee704ae8';
        insertObj.name = 'TestFile.txt';
        
        INTGR_SOAP_SN_Attachment.update_element updateObj = new INTGR_SOAP_SN_Attachment.update_element();
        //updateObj.incident_state = 'New';
        INTGR_SOAP_SN_Attachment.ServiceNowSoap soap = new INTGR_SOAP_SN_Attachment.ServiceNowSoap();
        
        INTGR_SOAP_SN_Attachment.getRecords_element ele1 = new INTGR_SOAP_SN_Attachment.getRecords_element();
        INTGR_SOAP_SN_Attachment.getKeysResponse_element obj1 = new INTGR_SOAP_SN_Attachment.getKeysResponse_element();
        INTGR_SOAP_SN_Attachment.getRecordsResult_element obj2 = new INTGR_SOAP_SN_Attachment.getRecordsResult_element();
        INTGR_SOAP_SN_Attachment.getKeys_element obj3 = new INTGR_SOAP_SN_Attachment.getKeys_element();
        INTGR_SOAP_SN_Attachment.getResponse_element obj4 = new INTGR_SOAP_SN_Attachment.getResponse_element();
        INTGR_SOAP_SN_Attachment.getRecordsResponse_element obj5 = new INTGR_SOAP_SN_Attachment.getRecordsResponse_element();
        INTGR_SOAP_SN_Attachment.updateResponse_element obj6 = new INTGR_SOAP_SN_Attachment.updateResponse_element();
        INTGR_SOAP_SN_Attachment.get_element ele7 = new INTGR_SOAP_SN_Attachment.get_element();
        INTGR_SOAP_SN_Attachment.insertResponse_element ele8 = new INTGR_SOAP_SN_Attachment.insertResponse_element();
        
        try
        {
            ele8 = soap.insert_x(insertObj, 'https://login.salesforce.com');
        }
        catch(Exception e) 
        {
            system.debug('exception : ' + e.getMessage());
            system.debug('exception stack trace : ' + e.getStackTraceString());
        }
        
    }
    
}