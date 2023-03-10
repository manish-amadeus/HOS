/****************************************************************************************
Name            : AH_SalesforceTrustRefresh_Schedule_Test Class 
Author          : Shashikant Nikam
Created Date    : 10/23/2018
Last Mod Date   : 10/24/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_Schedule_BatchSalesforceTrustRefresh class
:  
: 
******************************************************************************************/
@isTest
public class AH_SalesforceTrustRefresh_Schedule_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.runAs([SELECT Id FROM User WHERE Id =: UserInfo.getUserId()][0]) 
        {
            
            // CREATE TEST INSTANCE RECORD
            List<AH_Salesforce_Instance__c> lstInstances = new List<AH_Salesforce_Instance__c>();
            
            AH_Salesforce_Instance__c a1 = new AH_Salesforce_Instance__c();
            a1.Name = 'NA67';
            a1.Key__c = 'na67';
            a1.Location__c = 'MAPC';
            a1.Environment__c = 'production';
            a1.Release_Version__c = 'Winter \'19 Patch 9.7';
            a1.Release_Number__c = '216.9.7';
            a1.Status__c = 'OK';
            a1.Is_Active__c = TRUE;
            a1.Services__c = '(CPQandBilling, analytics, search, liveAgent, coreService)';
            a1.Products__c = '(Community_Cloud, Einstein_Analytics)';
            
            lstInstances.add(a1);
            
            insert lstInstances;
            
            // ASSERT INSERT SUCCESSFUL
            List<AH_Salesforce_Instance__c> instanceList = new List <AH_Salesforce_Instance__c>([SELECT Id FROM AH_Salesforce_Instance__c]);
            system.assertEquals(1, instanceList.size(), 'Record count mismatch in Instance record in test Data..');
            
			// CREATE TEST NOTIFICATION RECORDS
            List<AH_Salesforce_Trust_Notification__c> IncidentsList1 = new List<AH_Salesforce_Trust_Notification__c>();
            
            AH_Salesforce_Trust_Notification__c notify1 = new AH_Salesforce_Trust_Notification__c();
            notify1.SF_Trust_ID__c = 'INCDNT-2992';
            notify1.RecordTypeId = Schema.SObjectType.AH_Salesforce_Trust_Notification__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            IncidentsList1.add(notify1);
            
            AH_Salesforce_Trust_Notification__c notify2 = new AH_Salesforce_Trust_Notification__c();
            notify2.SF_Trust_ID__c = 'INCDNT-2698';
            notify2.RecordTypeId = Schema.SObjectType.AH_Salesforce_Trust_Notification__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            IncidentsList1.add(notify2);
                        
            AH_Salesforce_Trust_Notification__c notify3 = new AH_Salesforce_Trust_Notification__c();
            notify3.SF_Trust_ID__c = 'MNTNCE-3299';
            notify3.RecordTypeId = Schema.SObjectType.AH_Salesforce_Trust_Notification__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
            IncidentsList1.add(notify3);

            AH_Salesforce_Trust_Notification__c notify4 = new AH_Salesforce_Trust_Notification__c();
            notify4.SF_Trust_ID__c = 'GENMSG-2687';
            notify4.RecordTypeId = Schema.SObjectType.AH_Salesforce_Trust_Notification__c.getRecordTypeInfosByName().get('General Message').getRecordTypeId();
            IncidentsList1.add(notify4);

            insert IncidentsList1;
            
			// ASSERT INSERT SUCCESSFUL
            List<AH_Salesforce_Trust_Notification__c> LstNotificationAssert = new List<AH_Salesforce_Trust_Notification__c>([SELECT Id FROM AH_Salesforce_Trust_Notification__c]);
            system.assertEquals(4, LstNotificationAssert.size(), 'Record count mismatch in Trust notification record in test Data..');
            
            // CREATE TEST JUNCTION RECORD
            AH_Salesforce_Instance_to_Notification__c i2n = new AH_Salesforce_Instance_to_Notification__c();
            i2n.AH_Salesforce_Instance__c = a1.Id;
            i2n.AH_Salesforce_Notification__c = notify2.Id; 
            i2n.Key__c = (i2n.AH_Salesforce_Instance__c + '-' + i2n.AH_Salesforce_Notification__c);
            insert i2n;
            
            // ASSERT INSERT SUCCESSFUL
            List<AH_Salesforce_Instance_to_Notification__c> lstJuncAssert = new List<AH_Salesforce_Instance_to_Notification__c>([SELECT Id FROM AH_Salesforce_Instance_to_Notification__c]);
            system.assertEquals(1, lstJuncAssert.size(), 'Record count mismatch in AH_Salesforce_Instance_to_Notification__c record in test Data..');
            
        }
        
    } 
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        List<AH_Salesforce_Instance__c> lstInstance = new List <AH_Salesforce_Instance__c>([SELECT Id FROM AH_Salesforce_Instance__c]);
        system.debug(' **** lstInstance.size() = ' + lstInstance.size());
        
        List<AH_Salesforce_Trust_Notification__c> lstNotification = new List<AH_Salesforce_Trust_Notification__c>([SELECT Id FROM AH_Salesforce_Trust_Notification__c]);
        system.debug(' **** lstNotification.size() = ' + lstNotification.size());
        
        List<AH_Salesforce_Trust_Impact_Event__c> lstImpactEvent = new List<AH_Salesforce_Trust_Impact_Event__c>([SELECT Id FROM AH_Salesforce_Trust_Impact_Event__c]);
        system.debug(' **** lstImpactEventsize() = ' + lstImpactEvent.size());
        
        List<AH_Salesforce_Instance_to_Notification__c> lstJunc = new List<AH_Salesforce_Instance_to_Notification__c>([SELECT Id FROM AH_Salesforce_Instance_to_Notification__c]);
        system.debug(' **** lstJunc.size() = ' + lstJunc.size());       
        
        Test.setMock(HttpCalloutMock.class, new AH_SalesforceTrustRefresh_Mock());
        
        Test.StartTest();
        
        AH_SalesforceTrustRefresh_Schedule s = new AH_SalesforceTrustRefresh_Schedule();
        String sch = '0 0 0 * * ?';
        String jobId = system.schedule('Schedule Trust Refresh Test', sch, s);
        
        Test.StopTest();
        
        List<AH_Salesforce_Instance__c> lstInstanceAssert = new List <AH_Salesforce_Instance__c>([SELECT Id FROM AH_Salesforce_Instance__c]);
        system.debug(' **** lstInstanceAssert.size() = ' + lstInstanceAssert.size());
        
        List<AH_Salesforce_Trust_Notification__c> lstNotificationAssert = new List<AH_Salesforce_Trust_Notification__c>([SELECT Id FROM AH_Salesforce_Trust_Notification__c]);
        system.debug(' **** lstNotificationAssert.size() = ' + lstNotificationAssert.size());
        
        List<AH_Salesforce_Trust_Impact_Event__c> lstImpactEventAssert = new List<AH_Salesforce_Trust_Impact_Event__c>([SELECT Id FROM AH_Salesforce_Trust_Impact_Event__c]);
        system.debug(' **** lstImpactEventAssert.size() = ' + lstImpactEventAssert.size());
        
        List<AH_Salesforce_Instance_to_Notification__c> lstJuncAssert = new List<AH_Salesforce_Instance_to_Notification__c>([SELECT Id FROM AH_Salesforce_Instance_to_Notification__c]);
        system.debug(' **** lstJuncAssert.size() = ' + lstJuncAssert.size());
        
    }
    
}