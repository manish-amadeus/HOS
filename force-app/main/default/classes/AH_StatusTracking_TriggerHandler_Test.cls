/****************************************************************************************
Name            : AH_StatusTracking_TriggerHandler_Test Class
Author          : Bhagwat Garkal
Created Date    : 04/08/2022
Last Mod Date   : 04/08/2022
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : AH_StatusTracking_TriggerHandler_Test Class
                : 
                : 
******************************************************************************************/
@isTest
public class AH_StatusTracking_TriggerHandler_Test 
{
	// ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData()
    {
        Request__c rq = new Request__c();
        rq.Open_Time__c = DateTime.Now().AddDays(-1);
        rq.Close_Time__c = system.now();  
        insert rq;
        
        // CREATE TEST Status Tracking Record
        Status_Tracking__c st = new Status_Tracking__c();
        st.Enter_Time__c = DateTime.Now().AddDays(-1);
        st.Exit_Time__c = system.now();
        st.OM_Request__c = rq.Id;
        st.Status_Name__c = 'Test Record';
        insert st;
    }

	// ===========================================================================================================================
    // = TEST METHODS FOR TESTING OnBeforeUpdate METHOD
    // ==========================================================================================================================
    @isTest static void testOnBeforeUpdateMethod()
    {
        AH_StatusTracking_TriggerHandler stth = new AH_StatusTracking_TriggerHandler();
        
        //  Check Status Tracking Record created or not.
        List<Status_Tracking__c> lstofSt = [Select Id,Enter_Time__c,Exit_Time__c,Time_Elapsed_Hours_24hr_day__c from Status_Tracking__c where Status_Name__c = 'Test Record'];
        System.debug('lstofSt==>'+lstofSt);
        system.assertEquals(1, lstofSt.size(), 'Status Tracking Created.');
        lstofSt[0].Time_Elapsed_Hours_24hr_day__c = 4.01;
        update lstofSt;
       
        //  Check Status Tracking Record Hours updated or not from trigger.
        List<Status_Tracking__c> lstofSt2 = [Select Id,Enter_Time__c,Exit_Time__c,Time_Elapsed_Hours_24hr_day__c from Status_Tracking__c where Status_Name__c = 'Test Record'];     
        System.debug('lstofSt==>'+lstofSt);
        system.assertNotEquals(lstofSt[0].Time_Elapsed_Hours_24hr_day__c, lstofSt2[0].Time_Elapsed_Hours_24hr_day__c);
    }
    
    // ===========================================================================================================================
    // = TEST METHODS FOR TESTING OnBeforeUpdate METHOD
    // ==========================================================================================================================
    @isTest static void testOnBeforeUpdateMethod2()
    {
        AH_StatusTracking_TriggerHandler stth = new AH_StatusTracking_TriggerHandler();
        
        //  Check Status Tracking Record created or not.
        List<Status_Tracking__c> lstofSt = [Select Id,Enter_Time__c,Exit_Time__c,Time_Elapsed_Hours_24hr_day__c from Status_Tracking__c where Status_Name__c = 'Test Record'];
        lstofSt[0].Exit_Time__c = DateTime.Now().AddDays(-2);
        
        // Check Error Message
        try 
        {
            update lstofSt;
        }
        catch(Exception e) 
        {
            System.assert(e.getMessage().contains('Exit Time should not be less than Enter Time'));
        }
    }
}