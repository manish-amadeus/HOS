/****************************************************************************************
Name            : AH_SalesforceTrustRefresh_Test Class 
Author          : Bhuleshwar Deshpande
Created Date    : 10/18/2018
Last Mod Date   : 05/28/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for AH_SalesforceTrustRefresh class
                :  
                : 
******************************************************************************************/
@isTest
public class AH_SalesforceTrustRefresh_Test 
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
    // = TEST METHOD 1: TEST CREATING INSTANCES
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        List<AH_Salesforce_Instance__c> lstInstanceAssert1 = new List <AH_Salesforce_Instance__c>(
            [SELECT Id FROM AH_Salesforce_Instance__c]); 
        system.debug(' **** lstInstanceAssert1.size() = ' + lstInstanceAssert1.size());
        system.assertEquals(1, lstInstanceAssert1.size());
        
        Test.setMock(HttpCalloutMock.class, new AH_SalesforceTrustRefresh_Mock());
                
        Test.StartTest();

        AH_SalesforceTrustRefresh.getInstances('https://api.status.salesforce.com/v1/instances?limit=2000&childProducts=false');
        
        Test.StopTest();

        List<AH_Salesforce_Instance__c> lstInstanceAssert2 = new List <AH_Salesforce_Instance__c>(
            [SELECT Id FROM AH_Salesforce_Instance__c]); 
        system.debug(' **** lstInstanceAssert2.size() = ' + lstInstanceAssert2.size());
        system.assertEquals(2, lstInstanceAssert2.size());
        
    }
   
    // ======================================================================================================================================= 
    // = TEST METHOD 2: TEST CREATING INCIDENTS
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {

        List<AH_Salesforce_Trust_Notification__c> lstIncident = new List<AH_Salesforce_Trust_Notification__c>(
            [SELECT Id, RecordType.Name 
             FROM AH_Salesforce_Trust_Notification__c 
             WHERE RecordType.Name = 'Incident']);
        
        system.debug(' **** lstIncident.size() = ' + lstIncident.size());

        List<AH_Salesforce_Trust_Impact_Event__c> lstIncImpact = new List <AH_Salesforce_Trust_Impact_Event__c>(
            [SELECT Id, SF_Trust_ID__c 
             FROM AH_Salesforce_Trust_Impact_Event__c 
             WHERE RecordType.Name = 'Impact']);      
        
        system.debug(' **** lstIncImpact.size() = ' + lstIncImpact.size());
        
        List<AH_Salesforce_Trust_Impact_Event__c> lstIncEvent = new List <AH_Salesforce_Trust_Impact_Event__c>(
            [SELECT Id, SF_Trust_ID__c 
             FROM AH_Salesforce_Trust_Impact_Event__c 
             WHERE RecordType.Name = 'Event']);
        
        system.debug(' **** lstIncEvent.size() = ' + lstIncEvent.size());
        
        List<AH_Salesforce_Instance_to_Notification__c> lstIncJunc = new List<AH_Salesforce_Instance_to_Notification__c>(
            [SELECT Id FROM AH_Salesforce_Instance_to_Notification__c]);
        
        system.debug(' **** lstIncJunc.size() = ' + lstIncJunc.size());
        
        Test.setMock(HttpCalloutMock.class, new AH_SalesforceTrustRefresh_Mock());
        
        Test.StartTest();
        
        AH_SalesforceTrustRefresh.getIncidents('https://api.status.salesforce.com/v1/incidents?limit=2000');
        
        Test.StopTest();

        List<AH_Salesforce_Trust_Notification__c> lstIncidentAssert = new List<AH_Salesforce_Trust_Notification__c>(
            [SELECT Id, RecordType.Name 
             FROM AH_Salesforce_Trust_Notification__c 
             WHERE RecordType.Name = 'Incident']);
        
        system.debug(' **** lstIncidentAssert.size() = ' + lstIncidentAssert.size());

        List<AH_Salesforce_Trust_Impact_Event__c> lstIncImpactAssert = new List <AH_Salesforce_Trust_Impact_Event__c>(
            [SELECT Id, SF_Trust_ID__c 
             FROM AH_Salesforce_Trust_Impact_Event__c 
             WHERE RecordType.Name = 'Impact']);      
        
        system.debug(' **** lstIncImpactAssert.size() = ' + lstIncImpactAssert.size());
        
        List<AH_Salesforce_Trust_Impact_Event__c> lstIncEventAssert = new List <AH_Salesforce_Trust_Impact_Event__c>(
            [SELECT Id, SF_Trust_ID__c 
             FROM AH_Salesforce_Trust_Impact_Event__c 
             WHERE RecordType.Name = 'Event']);
        
        system.debug(' **** lstIncEventAssert.size() = ' + lstIncEventAssert.size());
        
        List<AH_Salesforce_Instance_to_Notification__c> lstIncJuncAssert = new List<AH_Salesforce_Instance_to_Notification__c>(
            [SELECT Id FROM AH_Salesforce_Instance_to_Notification__c]);
        
        system.debug(' **** lstIncJuncAssert.size() = ' + lstIncJuncAssert.size());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: TEST CREATING MAINTENANCES
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {

        List<AH_Salesforce_Trust_Notification__c> lstMaintenance = new List<AH_Salesforce_Trust_Notification__c>(
            [SELECT Id, RecordType.Name 
             FROM AH_Salesforce_Trust_Notification__c 
             WHERE RecordType.Name = 'Maintenance']);
        
        system.debug(' **** lstMaintenance.size() = ' + lstMaintenance.size());

        List<AH_Salesforce_Trust_Impact_Event__c> lstMaintImpact = new List <AH_Salesforce_Trust_Impact_Event__c>(
            [SELECT Id, SF_Trust_ID__c 
             FROM AH_Salesforce_Trust_Impact_Event__c 
             WHERE RecordType.Name = 'Impact']);      
        
        system.debug(' **** lstMaintImpact.size() = ' + lstMaintImpact.size());
        
        List<AH_Salesforce_Trust_Impact_Event__c> lstMaintEvent = new List <AH_Salesforce_Trust_Impact_Event__c>(
            [SELECT Id, SF_Trust_ID__c 
             FROM AH_Salesforce_Trust_Impact_Event__c 
             WHERE RecordType.Name = 'Event']);
        
        system.debug(' **** lstMaintEvent.size() = ' + lstMaintEvent.size());
        
        List<AH_Salesforce_Instance_to_Notification__c> lstMaintJunc = new List<AH_Salesforce_Instance_to_Notification__c>(
            [SELECT Id FROM AH_Salesforce_Instance_to_Notification__c]);
        
        system.debug(' **** lstMaintJunc.size() = ' + lstMaintJunc.size());
                
        Test.setMock(HttpCalloutMock.class, new AH_SalesforceTrustRefresh_Mock());
                
        Test.StartTest();

        String strStartTime = String.valueOf(system.today() - 15);
        AH_SalesforceTrustRefresh.getMaintenances('https://api.status.salesforce.com/v1/maintenances?limit=1000&startTime=' + strStartTime + '&sort=plannedStartTime');
                
        Test.StopTest();     

        List<AH_Salesforce_Trust_Notification__c> lstMaintenanceAssert = new List<AH_Salesforce_Trust_Notification__c>(
            [SELECT Id, RecordType.Name 
             FROM AH_Salesforce_Trust_Notification__c 
             WHERE RecordType.Name = 'Maintenance']);
        
        system.debug(' **** lstMaintenanceAssert.size() = ' + lstMaintenanceAssert.size());

        List<AH_Salesforce_Trust_Impact_Event__c> lstMaintImpactAssert = new List <AH_Salesforce_Trust_Impact_Event__c>(
            [SELECT Id, SF_Trust_ID__c 
             FROM AH_Salesforce_Trust_Impact_Event__c 
             WHERE RecordType.Name = 'Impact']);      
        
        system.debug(' **** lstMaintImpactAssert.size() = ' + lstMaintImpactAssert.size());
        
        List<AH_Salesforce_Trust_Impact_Event__c> lstMaintEventAssert = new List <AH_Salesforce_Trust_Impact_Event__c>(
            [SELECT Id, SF_Trust_ID__c 
             FROM AH_Salesforce_Trust_Impact_Event__c 
             WHERE RecordType.Name = 'Event']);
        
        system.debug(' **** lstMaintEventAssert.size() = ' + lstMaintEventAssert.size());
        
        List<AH_Salesforce_Instance_to_Notification__c> lstMaintJuncAssert = new List<AH_Salesforce_Instance_to_Notification__c>(
            [SELECT Id FROM AH_Salesforce_Instance_to_Notification__c]);
        
        system.debug(' **** lstMaintJuncAssert.size() = ' + lstMaintJuncAssert.size());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: TEST CREATING GENERAL MESSAGES
    // ======================================================================================================================================= 
    @isTest static void test4() 
    {
        
        List<AH_Salesforce_Trust_Notification__c> lstGenMessage = new List<AH_Salesforce_Trust_Notification__c>(
            [SELECT Id, RecordType.Name 
             FROM AH_Salesforce_Trust_Notification__c 
             WHERE RecordType.Name = 'General Message']);
        
        system.debug(' **** lstGenMessage.size() = ' + lstGenMessage.size());
                
        Test.setMock(HttpCalloutMock.class, new AH_SalesforceTrustRefresh_Mock());
                
        Test.StartTest();

        AH_SalesforceTrustRefresh.getGeneralMessages('https://api.status.salesforce.com/v1/generalMessages?limit=1000');
                
        Test.StopTest();
        
        List<AH_Salesforce_Trust_Notification__c> lstGenMessageAssert = new List<AH_Salesforce_Trust_Notification__c>(
            [SELECT Id, RecordType.Name 
             FROM AH_Salesforce_Trust_Notification__c 
             WHERE RecordType.Name = 'General Message']);
        
        system.debug(' **** lstGenMessageAssert.size() = ' + lstGenMessageAssert.size());
        
    }
  
}