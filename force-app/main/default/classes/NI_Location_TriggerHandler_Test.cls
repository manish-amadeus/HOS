/************************************************************************************************
Name            : NI_Location_TriggerHandler_Test Class
Author          : Suzanne LeDuc
Created Date    : 09/10/2015
Last Mod Date   : 09/10/2015
Last Mod By     : Sean Harris
NICC Reference  : NICC-014223
Description     : Class that tests NI_Location_TriggerHandler Class
                :
                :
*************************************************************************************************/
@isTest
public class NI_Location_TriggerHandler_Test  
{
 
    
    // ======================================================================================================================================= 
    // CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
		system.debug(' *** START NI_Location_TriggerHandler_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Test.startTest();
        
		// CREATE TEST ACCOUNT RECORD 
        List<Account> lstAccountInserts = new List<Account>();
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'NI_Location_TriggerHandler_Test ACCOUNT';
        lstAccountInserts.add(a1);  
        
        Account a2 = NI_TestClassData.CreateTestAccount(2);
        lstAccountInserts.add(a2);  
        
        database.insert(lstAccountInserts);
                                       
        // CREATE TEST ORG DETAIL RECORD
        Id rtInit = Schema.SObjectType.NI_Org_Details__c.getRecordTypeInfosByName().get('LOD Support Admin').getRecordTypeId();
        NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production');
        
        od.Org_Name__c = a1.Name;
        od.Org_Id__c = 'XXXXXXXXXX00001';
        od.AdminLoginName__c = 'test@test.com';
        od.AdminPassword__c = '123456789';
        od.License_Type__c =  'Enterprise';
        od.Org_Status__c = 'In Process';
        od.Inactive__c = false;
		insert od;

        // CREATE NI_Org_Details_to_Accounts__c RECORD
        NI_Org_Details_to_Accounts__c O2A = NI_TestClassData.createTestNIOrgDetails2Accounts(od.Id, a1.Id); 
        insert O2A;
        
        // CREATE newmarketsvcs__IServer__c RECORD
        newmarketsvcs__IServer__c nwsSys = NI_TestClassData.CreateTestNWS_IServer(1, 'Org.XXXXXXXXXX00001@Delphi.fdc');
        nwsSys.newmarketsvcs__NewmarketUser__c = 'Org.XXXXXXXXXX00001@Delphi.fdc';
        insert nwsSys;

        // CREATE newmarketsvcs__Location__c RECORD
        newmarketsvcs__Location__c nwsLoc = NI_TestClassData.createTestNWS_Location(1, nwsSys.Id, a1.Id);
        nwsLoc.newmarketsvcs__Master_Location__c = a1.Id;
        nwsLoc.newmarketsvcs__IServerID__c = nwsSys.Id;
        nwsLoc.newmarketsvcs__Name__c = 'Test';
        nwsLoc.newmarketsvcs__Source_System_Type__c = 'Delphifdc'; 
        insert nwsLoc;    
        
        nwsLoc.newmarketsvcs__City__c = 'Portsmith';
        update nwsLoc;

        // Update the Location
        nwsLoc.newmarketsvcs__Master_Location__c = a2.Id;
        update nwsLoc;

		system.debug(' *** END NI_Location_TriggerHandler_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
       
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        system.debug(' *** START NI_Location_TriggerHandler_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Account a1 = [SELECT Id, Name FROM Account WHERE Name = 'NI_Location_TriggerHandler_Test ACCOUNT'];
        
        Test.startTest();
        

        // CREATE TEST ORG DETAILS RECORD
        Id rtInit = Schema.SObjectType.NI_Org_Details__c.getRecordTypeInfosByName().get('HRM Support Admin').getRecordTypeId();
        
        NI_Org_Details__c o = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production');
        o.Org_Name__c = a1.Name;
        o.AdminLoginName__c = 'test@test.com';
        o.AdminPassword__c = '123456789';
        o.License_Type__c = 'Enterprise';
        o.Org_Status__c = 'In Process';
        o.Inactive__c = false;        
        insert o;
        
        // CREATE TEST ORG DETAILS TO ACCOUNT RECORD
        NI_Org_Details_to_Accounts__c o2a = NI_TestClassData.createTestNIOrgDetails2Accounts(o.Id, a1.Id); 
        insert o2a;
        
        // CREATE TEST ISERVER "SYSTEM" RECORD
        newmarketsvcs__IServer__c nwsSystem = new newmarketsvcs__IServer__c();
        nwsSystem.newmarketsvcs__IServer_ID__c = 'IS-99999';
        nwsSystem.newmarketsvcs__NewmarketUser__c = 'Org.' + String.valueOf(o.Id) + '@Delphi.fdc';
        insert nwsSystem;
        
        // CREATE TEST LOCATION RECORD
        newmarketsvcs__Location__c loc1 = new newmarketsvcs__Location__c();
        loc1.newmarketsvcs__Master_Location__c = a1.Id;
        loc1.newmarketsvcs__IServerID__c = nwsSystem.Id;
        loc1.newmarketsvcs__Name__c = 'Test';
        loc1.newmarketsvcs__Source_System_Type__c = 'Delphifdc';
        insert loc1;
        
        Test.stopTest();
        
        system.debug(' ***  END  NI_Location_TriggerHandler_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }        
   
}