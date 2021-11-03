/****************************************************************************************
Name            : NI_Change_Control_TriggerHandler_Test Class
Author          : Sean Harris
Created Date    : 2/15/2013
Last Mod Date   : 5/19/2013
Last Mod By     : Sean Harris (NICC-026507)
NICC Reference  : 
Description     : test Class for NI_Change_Control_TriggerHandler Class
				: 
				: 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_Change_Control_TriggerHandler_Test
{
   
    static void createCustomSettings()
    {
        //Custom Settings 
        WinaproachIncidentSettings__c winSettings = NI_TestClassData.createWinaproachIncidentSettings();
        insert winSettings;
        
        Winaproach_Incident_Case_Record_Type__c niRecType = NI_TestClassData.createIncidentCaseRecordType();
        insert niRecType;
        
        //ServiceNow custom settings
        ServiceNowIncidentSettings__c incidentSettings = new ServiceNowIncidentSettings__c();
        incidentSettings.Name = 'Default';
        incidentSettings.ServiceNow_Incident_Case_Record_Type__c = 'CRS Incident';
        incidentSettings.Attachment_Endpoint__c = 'https://ihgsndev.service-now.com/api/now/attachment';
        incidentSettings.Integration_UserId__c= '00517000001YWXyAAO';
        incidentSettings.Integration_Username__c= 'ihg_servicenow@newmarketinc.com.winaproach';
        incidentSettings.ServiceNow_Password__c = '3bPWPSER1ggC';
        incidentSettings.SerrviceNow_Username__c = 'integration_amadeus';
        incidentSettings.Incident_Endpoint__c = 'https://ihgsndev.service-now.com/api/now/table/incident';
        incidentSettings.ImportSet_Endpoint__c = 'https://ihgsndev.service-now.com/api/now/import/u_integ_amadeus_incidents';
        insert incidentSettings;
    }
    
    public static testMethod void testTrigHandler() 
    {
        
        NI_Change_Control_TriggerHandler_Test.createCustomSettings();
        
        User u = NI_TestClassData.createTestUser(1, 'NI Support CSR');
        insert u;
        
        system.runAs(u)
        {
            
            Id rtId = NI_TestClassData.getRecordTypeId('NI_Change_Control__c', 'Hosted RFC');  
            
            Account a = NI_TestClassData.createTestAccount(1);
            insert a;
            
            Case c = NI_TestClassData.createTestCase(1, a.Id);
            insert c;
            
            List<NI_Change_Control__c> lstNICC = new List<NI_Change_Control__c>();
            
            Map<id,NI_Change_Control__c> oldMap=new Map<id,NI_Change_Control__c>();
            
            
            NI_Change_Control_TriggerHandler handler = new NI_Change_Control_TriggerHandler(true);
            boolean IsTriggerContext = handler.IsTriggerContext;

            // FIRST NICC RECORD =====================================================================================
            NI_Change_Control__c nicc1 = NI_TestClassData.createNIChangeControl(1, 'APEX TEST'); 
            nicc1.Change_Status__c = 'Compile'; 
            nicc1.Data_Change__c = 'Yes'; 
            nicc1.Developer_Compiler__c = u.Id; 
            nicc1.Manager_Reviewer__c = u.Id; 
            nicc1.New_Custom_Script__c = 'No'; 
            nicc1.NI_Change_Owner__c = u.Id; 
            nicc1.Outage_Required__c = 'Yes'; 
            nicc1.Priority__c = 'Normal'; 
            nicc1.Re_submit_for_Approval__c = false; 
            nicc1.Ready_for_Manager_Reviewer_Approval__c = true; 
            nicc1.RecordTypeId = rtId; 
            nicc1.Case_Id__c = c.Id;             
            
            // SECOND NICC RECORD =====================================================================================
            NI_Change_Control__c nicc2 = NI_TestClassData.createNIChangeControl(2, 'APEX TEST');
            nicc2.Change_Status__c = 'Compile';
            nicc2.Data_Change__c = 'Yes';
            nicc2.Developer_Compiler__c = u.Id; 
            nicc2.Manager_Reviewer__c = u.Id;
            nicc2.New_Custom_Script__c = 'No'; 
            nicc2.NI_Change_Owner__c = u.Id;
            nicc2.Outage_Required__c = 'Yes'; 
            nicc2.Priority__c = 'Normal';
            nicc2.Re_submit_for_Approval__c = false;
            nicc2.Ready_for_Manager_Reviewer_Approval__c = true;
            nicc2.RecordTypeId = rtId;            
            
            // THIRD NICC RECORD ======================================================================================  
            Id rtHRMId = NI_TestClassData.getRecordTypeId('NI_Change_Control__c', 'HRM RFC');  
            
            NI_Change_Control__c nicc3 = NI_TestClassData.createNIChangeControl(3, 'APEX TEST');
            nicc3.Change_Status__c = 'Compile';
            // nicc3.Data_Change__c = 'Yes';
            nicc3.Developer_Compiler__c = u.Id; 
            nicc3.Manager_Reviewer__c = u.Id;
            // nicc3.New_Custom_Script__c = 'No'; 
            nicc3.NI_Change_Owner__c = u.Id;
            // nicc3.Outage_Required__c = 'Yes'; 
            nicc3.Priority__c = 'Standard';
            nicc3.Re_submit_for_Approval__c = false;
            nicc3.Ready_for_Manager_Reviewer_Approval__c = true;
            nicc3.RecordTypeId = rtHRMId;            
            nicc3.Peer_Reviewer_Approved__c = 'Yes';
            nicc3.Developer_Reviewer__c = u.Id;
            
            // ADD NICC REDORDS TO LIST FOR INSERT/UPDATE
            lstNICC.add(nicc1);
            lstNICC.add(nicc2);
            lstNICC.add(nicc3);
            
            Database.Insert(lstNICC); 
            
            test.startTest();
            NICC_Artifact__c art1 = NI_TestClassData.createArtifact(1, 'APEX TEST', nicc1.Id, 'Customer Sign-off');
            insert art1;             
            
            List<NI_Change_Control__c> lstUpdateNICC = new List<NI_Change_Control__c>();
            
            for (NI_Change_Control__c niccUpdates : [SELECT Id, Re_submit_for_Approval__c FROM NI_Change_Control__c])
            {
                niccUpdates.Re_submit_for_Approval__c = true;
                lstUpdateNICC.Add(niccUpdates);
            } 
            
            // NI Change Control: Hosted RFC: Normal Approval
            // (NI Change Control: Record Type EQUALS Hosted RFC) AND (NI Change Control: Ready for Manager Reviewer Approval EQUALS True) AND (NI Change Control: Priority EQUALS Normal)            
            
            // NI Change Control: Hosted RFC: Standard Approval
            // (NI Change Control: Record Type EQUALS Hosted RFC) AND (NI Change Control: Ready for Manager Reviewer Approval EQUALS True) AND (NI Change Control: Priority EQUALS Standard) AND ((NI Change Control: Peer Reviewer Approved? EQUALS Yes) OR (NI Change Control: Change Type INCLUDES Product: RFP Toolkit))
            
            // NI Change Control: HRM RFC: Normal Approval
            // (NI Change Control: Record Type EQUALS HRM RFC) AND (NI Change Control: Ready for Manager Reviewer Approval EQUALS True) AND (NI Change Control: Priority EQUALS Normal)
            
            // NI Change Control: HRM RFC: Standard Approval
            // (NI Change Control: Record Type EQUALS HRM RFC) AND (NI Change Control: Ready for Manager Reviewer Approval EQUALS True) AND (NI Change Control: Priority EQUALS Standard) AND ((NI Change Control: Peer Reviewer Approved? EQUALS Yes) OR (NI Change Control: Change Type INCLUDES Product: RFP Toolkit))
            
            
            oldMap.put(nicc1.id,nicc1);
            oldMap.put(nicc2.id,nicc2);
            oldMap.put(nicc3.id,nicc3);
            
            Database.Update(lstUpdateNICC);
            
            NI_TriggerManager.isFirstTime = true;
            handler.OnBeforeInsert(lstNICC);
            NI_TriggerManager.isFirstTime = true;
            handler.OnBeforeUpdate(lstNICC,oldMap);
            NI_TriggerManager.isFirstTime = true;
            
            test.stopTest(); 
            
        }    
        
    }
    
    public static testMethod void testTriggers_Hosted_HRM()
    {
        
        NI_Change_Control_TriggerHandler_Test.createCustomSettings();
        
        User usr = NI_TestClassData.createTestUser(1, 'System Administrator');
        
        insert usr;
        
        System.runAs(usr)
        {
            
            Id rtId = NI_TestClassData.getRecordTypeId('NI_Change_Control__c', 'Hosted RFC');  
            
            Account a = NI_TestClassData.createTestAccount(1);
            insert a;
            
            Case c = NI_TestClassData.createTestCase(1, a.Id);
            insert c;
            
            List<NI_Change_Control__c> lstNICC = new List<NI_Change_Control__c>();
            
            //        NI_Change_Control_TriggerHandler handler = new NI_Change_Control_TriggerHandler(true);
            //      boolean IsTriggerContext = handler.IsTriggerContext;
            
            //Creating NICC Record
            NI_Change_Control__c nicc1 = NI_TestClassData.createNIChangeControl(1, 'APEX TEST_Demo'); 
            nicc1.RecordTypeId = rtId; 
            nicc1.Date_Scheduled__c = DateTime.parse('4/6/2017 7:09 AM');
            nicc1.Assigned_Production_End_Date__c = null;
            nicc1.Date_Required__c = Date.parse('4/11/2017');
            nicc1.Request_Summary__c = 'Demo Test Summary For NICC1';
            nicc1.Change_Status__c = 'CRB Approved';
            //nicc1.Change_Status__c = 'New';
            lstNICC.add(nicc1);
            
            //Inserting NICC and Creating Event
            insert lstNICC;
            
            //nicc1.Change_Status__c = 'CRB Approved';
            //update nicc1;
            
            //Updating NICC and Updating Event
            nicc1.Date_Scheduled__c = DateTime.parse('4/5/2017 7:09 AM');
            nicc1.Assigned_Production_End_Date__c = null;
            update nicc1;
            
            //Updating NICC and Updating Event by Setting Both date as a NULL.
            nicc1.Date_Scheduled__c = null;
            nicc1.Assigned_Production_End_Date__c = null;
            update nicc1;
            
            nicc1.Date_Scheduled__c = Date.parse('4/11/2017');
            nicc1.Assigned_Production_End_Date__c = DateTime.parse('4/13/2017 7:09 AM');
            update nicc1;
            
            //Creting NICC Record 
            NI_Change_Control__c nicc2 = NI_TestClassData.createNIChangeControl(2, 'APEX TEST');
            nicc2.RecordTypeId = rtId; 
            nicc2.Date_Scheduled__c = DateTime.parse('4/6/2017 7:09 AM');
            nicc2.Assigned_Production_End_Date__c = DateTime.parse('4/1/2017 7:09 AM');
            nicc2.Date_Required__c = Date.parse('4/5/2017');
            nicc2.Request_Summary__c = 'Demo Test Summary For NICC2';
            nicc2.Change_Status__c = 'CRB Approved';
            
            // Inserting NICC
            // To Check Assigned Production Date is less than Assigned Production End Date.
            try
            {     
                nicc2.Date_Scheduled__c = DateTime.parse('4/8/2017 7:09 AM');
                nicc2.Assigned_Production_End_Date__c = DateTime.parse('4/6/2017 7:09 AM');
                insert nicc2;
            }
            catch (Exception ex)
            {
                //System.assertEquals('System.DmlException',ex.getTypeName());
            }
            
            // Updating NICC
            // To Check Assigned Production Date is less than Assigned Production End Date.
            try 
            {     
                nicc1.Date_Scheduled__c = DateTime.parse('4/8/2017 7:09 AM');
                nicc1.Assigned_Production_End_Date__c = DateTime.parse('4/6/2017 7:09 AM');
                update nicc1;
            }
            catch (Exception ex)
            {
                //System.assertEquals('System.DmlException',ex.getTypeName());
            }
            
        }
        
    } 
    
    public static testMethod void testTriggers_Hosted_HRM2()
    {
        
        NI_Change_Control_TriggerHandler_Test.createCustomSettings();
        
        User usr = NI_TestClassData.createTestUser(1, 'System Administrator');
        
        insert usr;
        
        System.runAs(usr)
        {
            
            Id rtId = NI_TestClassData.getRecordTypeId('NI_Change_Control__c', 'Hosted RFC');  
            
            Account a = NI_TestClassData.createTestAccount(1);
            insert a;
            
            Case c = NI_TestClassData.createTestCase(1, a.Id);
            insert c;
            
            List<NI_Change_Control__c> lstNICC = new List<NI_Change_Control__c>();
            
            //     NI_Change_Control_TriggerHandler handler = new NI_Change_Control_TriggerHandler(true);
            //    boolean IsTriggerContext = handler.IsTriggerContext;
            
            //Creating NICC Record
            NI_Change_Control__c nicc3 = NI_TestClassData.createNIChangeControl(3, ' -- APEX TEST_Demo --'); 
            nicc3.RecordTypeId = rtId; 
            nicc3.Date_Scheduled__c = DateTime.parse('5/6/2017 7:09 AM');
            nicc3.Assigned_Production_End_Date__c = DateTime.parse('6/11/2017 7:09 AM');
            nicc3.Date_Required__c = Date.parse('6/11/2017');
            nicc3.Request_Summary__c = 'Demo Test Summary For NICC3';
            nicc3.Change_Status__c = 'Compile';
            //lstNICC.add(nicc3);
            
            //Inserting NICC and Creating Event
            insert nicc3;
            
            test.startTest();

            nicc3.Change_Status__c = 'CRB Approved';
            //nicc3.Date_Scheduled__c = DateTime.parse('5/16/2017 7:09 AM');
            //nicc3.Assigned_Production_End_Date__c = DateTime.parse('5/18/2017 7:09 AM');
            update nicc3;
            
            //system.debug('ev' + ev);
            
            //Creating NICC Record
            NI_Change_Control__c nicc4 = NI_TestClassData.createNIChangeControl(25, ' -- APEX TEST_Demo4 --'); 
            nicc4.RecordTypeId = rtId; 
            nicc4.Date_Scheduled__c = null;
            nicc4.Assigned_Production_End_Date__c = DateTime.parse('6/11/2017 7:09 AM');
            nicc4.Date_Required__c = Date.parse('6/11/2017');
            nicc4.Request_Summary__c = 'Demo Test Summary For NICC3';
            nicc4.Change_Status__c = 'Compile';
            //lstNICC.add(nicc3);
            
            //Inserting NICC and Creating Event
            insert nicc4;
            nicc4.Change_Status__c = 'CRB Approved';
            //nicc3.Date_Scheduled__c = DateTime.parse('5/16/2017 7:09 AM');
            //nicc3.Assigned_Production_End_Date__c = DateTime.parse('5/18/2017 7:09 AM');
            update nicc4;
            test.stopTest();
        }
        
    }
    
    public static testMethod void testDates()
    {
        
        // COVERAGE FOR CYBAGE CODE NICC-026348   
        
        // VARIABLES 
		DateTime dt = DateTime.newInstance(2017, 6, 18, 0, 0, 0);
        string strDateUS = '';
        string strDateSG = '';
        Id rtId = NI_TestClassData.getRecordTypeId('NI_Change_Control__c', 'Hosted RFC'); 
        List<Event> lstEventsUS;
        List<Event> lstEventsSG;
        
        // CREATE US USER
        User usa = NI_TestClassData.createTestUser(1011, 'NI Support CSR');
        usa.DefaultCurrencyIsoCode = 'USD';
        usa.LocaleSidKey = 'en_US';
        usa.TimeZoneSidKey = 'America/New_York';
        insert usa;
        
        // CREATE SINGAPORE USER 
        User sg = NI_TestClassData.createTestUser(1211, 'NI Support CSR'); 
        sg.DefaultCurrencyIsoCode = 'SGD'; 
        sg.LocaleSidKey = 'en_GB'; 
        sg.TimeZoneSidKey = 'Asia/Singapore'; 
        insert sg; 

        system.runAs(usa)
        {
            
            strDateUS = dt.format(); 
            system.debug('USA Date = ' + strDateUS); 
            
            NI_Change_Control__c cc1 = NI_TestClassData.createNIChangeControl(1, 'APEX TEST'); 
            
            cc1.RecordTypeId = rtId; 
            cc1.Priority__c = 'Normal'; 
            cc1.Ready_for_Manager_Reviewer_Approval__c = true;
            
            cc1.Developer_Compiler__c = usa.Id; 
            cc1.Manager_Reviewer__c = usa.Id; 
            cc1.NI_Change_Owner__c = usa.Id; 
            
            cc1.Change_Status__c = 'Compile'; 
            cc1.Data_Change__c = 'Yes'; 
            cc1.New_Custom_Script__c = 'No'; 
            cc1.Outage_Required__c = 'Yes'; 

            cc1.Date_Scheduled__c = dt;
            cc1.Assigned_Production_End_Date__c = dt; 

			insert cc1; 
            
           	cc1.Change_Status__c = 'Approved - Standard Change';
			update cc1;
            
            // SUBMIT NICC RECORD FOR APPROVAL             
            Approval.ProcessSubmitRequest app1 = new Approval.ProcessSubmitRequest();
            app1.setObjectId(cc1.Id);
            Approval.ProcessResult result1 = Approval.process(app1); 
            
            // VERIFY APPROVAL SUBMISSION
            system.assert(result1.isSuccess());

            lstEventsUS = new List<Event>([SELECT StartDateTime, EndDateTime, Subject FROM Event WHERE whatId =: cc1.Id]);
            system.assertEquals(1, lstEventsUS.size());
            
            for (Event e1 : lstEventsUS)
            {
                system.debug('strDateUS = ' + strDateUS + ', e1.StartDateTime.format() = ' + e1.StartDateTime.format());
                system.assertEquals(strDateUS, e1.StartDateTime.format());
            }
            
        }

test.startTest();
        
        system.runAs(sg)
        {
            
            strDateSG = dt.format();
            system.debug('Singapore Date = ' + strDateSG);
            
            NI_Change_Control__c cc2 = NI_TestClassData.createNIChangeControl(1, 'APEX TEST'); 
            
            cc2.RecordTypeId = rtId; 
            cc2.Priority__c = 'Normal'; 
            cc2.Ready_for_Manager_Reviewer_Approval__c = true;
            
            cc2.Developer_Compiler__c = usa.Id; 
            cc2.Manager_Reviewer__c = usa.Id; 
            cc2.NI_Change_Owner__c = usa.Id; 
            
            cc2.Change_Status__c = 'Compile'; 
            cc2.Data_Change__c = 'Yes'; 
            cc2.New_Custom_Script__c = 'No'; 
            cc2.Outage_Required__c = 'Yes'; 

            cc2.Date_Scheduled__c = dt;
            cc2.Assigned_Production_End_Date__c = dt; 

			insert cc2; 
            
           	cc2.Change_Status__c = 'Approved - Standard Change';
			update cc2;
            
            // SUBMIT NICC RECORD FOR APPROVAL             
            Approval.ProcessSubmitRequest app2 = new Approval.ProcessSubmitRequest();
            app2.setObjectId(cc2.Id);
            Approval.ProcessResult result2 = Approval.process(app2);
            
            // VERIFY APPROVAL SUBMISSION
            system.assert(result2.isSuccess());

            lstEventsSG = new List<Event>([SELECT StartDateTime, EndDateTime, Subject FROM Event WHERE whatId =: cc2.Id]);
            system.assertEquals(1, lstEventsSG.size());
            
            for (Event e2 : lstEventsSG)
            {
                system.debug('strDateSG = ' + strDateSG + ', e2.StartDateTime.format() = ' + e2.StartDateTime.format());
                system.assertEquals(strDateSG, e2.StartDateTime.format());
            }
                        
        }
        
test.stopTest();        
        
        for (Event e3 : lstEventsUS)
        {
            system.assertEquals(dt.format(), e3.StartDateTime.format());
        }
        
        for (Event e4 : lstEventsSG)
        {
            system.assertEquals(dt.format(), e4.StartDateTime.format());
        }
        
    }

    
}