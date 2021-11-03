/****************************************************************************************
Name            : AH_QueryCustomerIncident_Test Class
Author          : Stuart Emery
Created Date    : 11/06/2017
Last Mod Date   : 11/21/2017
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test for AH_QueryCustomerIncident_Ctlr Controller Class 
                : 
******************************************************************************************/
@isTest
public class AH_QueryCustomerIncident_Test 
{

    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST SUCCESS
    // =======================================================================================================================================     
    @isTest static void test1() 
    {
        
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_QueryCustomerIncident_Test ACCOUNT';
        insert a;        
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'AH_QueryCustomerIncident_Test CASE';
        c.INTGR_Customer_Ticket_System_Id__c = '38242f9adb3fb3c489e1138b4b961957';
        c.Status = 'New';
        c.Priority = '4 - Low';
        c.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        c.Customer_Ticket_Number__c = 'INC0000001';
        insert c;      
        
        PageReference pr = Page.AH_QueryCustomerIncident; 
        Test.setCurrentPage(pr); 
        ApexPages.StandardController sc = new ApexPages.StandardController(c); 
        AH_QueryCustomerIncident_Ctlr ctrl = new AH_QueryCustomerIncident_Ctlr(sc); 

/*        
        String strJSON = '[{';
        strJSON += '"sys_id":"38242f9adb3fb3c489e1138b4b961957",';
        strJSON += '"number":"INC0000001",';
        strJSON += '"short_description":"AH_QueryCustomerIncident_Test CASE",';
        strJSON += '"assignment_group":{';
        strJSON += '"display_value":"VN-GLBL-GRS Amadeus Level 3",';
        strJSON += '"link":"https://ihguat.service-now.com/api/now/table/sys_user_group/9f514d6cdbfe2200ddd1b34ffe96196f"},';
        strJSON += '"state":"New",';
        strJSON += '"priority":"4 - Low"';
        strJSON += '}]';
*/

        String strJSON = '{"result":[{';
        strJSON += '"number":{"display_value":"INC0000001","value":"INC0000001"},';
        strJSON += '"short_description":{"display_value":"AH_QueryCustomerIncident_Test CASE","value":"AH_QueryCustomerIncident_Test CASE"},'; 
        strJSON += '"assignment_group":{'; 
        strJSON += '"display_value":"VN-GLBL-GRS Amadeus Level 3",';
        strJSON += '"link":"https://ihguat.service-now.com/api/now/table/sys_user_group/9f514d6cdbfe2200ddd1b34ffe96196f",';
        strJSON += '"value":"9f514d6cdbfe2200ddd1b34ffe96196f"},'; 
        strJSON += '"state":{"display_value":"On Hold","value":"3"},';
        strJSON += '"priority":{"display_value":"4 - Low","value":"4"}'; 
        strJSON += '}]}';
        
        AH_QueryCustomerIncident_Mock fakeResponse = new AH_QueryCustomerIncident_Mock(200, 'Complete', strJSON); 
        
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        ctrl.doQuery(); 
        
        // ASSERT THAT VALUES DISPLAYED WERE PROPERLY PARSED         
        system.assertEquals('INC0000001', ctrl.strIncidentNumber);
        system.assertEquals('On Hold', ctrl.strState);
        system.assertEquals('4 - Low', ctrl.strPriority);
        system.assertEquals('AH_QueryCustomerIncident_Test CASE', ctrl.strShortDescription);
        system.assertEquals('VN-GLBL-GRS Amadeus Level 3', ctrl.strAssignmentGroup);            
        
        Test.stopTest(); 
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: TEST FAILURE
    // =======================================================================================================================================     
    @isTest static void test2() 
    {
        
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_QueryCustomerIncident_Test ACCOUNT';
        insert a;        
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'AH_QueryCustomerIncident_Test CASE';
        c.INTGR_Customer_Ticket_System_Id__c = '38242f9adb3fb3c489e1138b4b961957';
        c.Status = 'New';
        c.Priority = '4 - Low';
        c.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        c.Customer_Ticket_Number__c = 'INC0000001';
        insert c;      
        
        PageReference pr = Page.AH_QueryCustomerIncident; 
        Test.setCurrentPage(pr); 
        ApexPages.StandardController sc = new ApexPages.StandardController(c); 
        AH_QueryCustomerIncident_Ctlr ctrl = new AH_QueryCustomerIncident_Ctlr(sc); 
        
        String strJSON = '[{';
        strJSON += '"error":{';
        strJSON += '"message":"No Record found",';
        strJSON += '"detail":"Record does not exist or ACL restricts the record retrieval"';
        strJSON += '},';
        strJSON += '"status":"failure"';
        strJSON += '}]';
    
        AH_QueryCustomerIncident_Mock fakeResponse = new AH_QueryCustomerIncident_Mock(404, 'Failure', strJSON); 
        
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        ctrl.doQuery(); 
        
        Test.stopTest(); 
        
    }
    
}