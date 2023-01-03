@isTest
public class TestNI_Winaproach 
{

    /* SETUP USING NI_TESTCLASSDATA    
    static WinaproachIncidentSettings__c createCustomSettings()
    {
        //Custom Settings 
        WinaproachIncidentSettings__c winSettings = NI_TestClassData.createWinaproachIncidentSettings();
        insert winSettings;
        
        Winaproach_Incident_Case_Record_Type__c niRecType = NI_TestClassData.createIncidentCaseRecordType();
        insert niRecType;
        
        WinaproachIncidentSeverityMapping__c  wSeverity =  NI_TestClassData.createWinaproachIncidentSeverityMapping();
        insert wSeverity;
        
        WinaproachIncidentStatusMapping__c  wStatus =  NI_TestClassData.createIncidentStatusMapping();
        insert wStatus;
        
        WinaproachIncidentUrgencyMapping__c  wUrgency = NI_TestClassData.createUrgencyMapping();
        insert wUrgency;
        
        WinaproachIncidentCauseIdMapping__c causeId = NI_TestClassData.createCauseIdMapping();
        insert causeId;
        
        WinaproachIncidentResolutionCodeMapping__c ResolutionCode = NI_TestClassData.createWinResolutionCodeMapping();
        insert ResolutionCode;
        
        WinaproachIncidentRejectedReasonCode__c RejectedReasonCode = NI_TestClassData.createWinRejectedCode();
        insert RejectedReasonCode;
        
        WinaproachIncidentInvestigationMapping__c InvestigationMapping = NI_TestClassData.createWinInvestigation();
        insert InvestigationMapping;
        
        Winaproach_Owner_Group__c winOwnerGroup = new Winaproach_Owner_Group__c();
        winOwnerGroup.Name = 'MHDHOT';
        insert winOwnerGroup;
        
        Winaproach_Work_Order_Case_Record_Type__c workOrderRecordType = NI_TestClassData.createWorkOrderCaseRecordType();
        insert workOrderRecordType;
          
        WinaproachWorkOrderStatusMapping__c statusMapping = NI_TestClassData.createWorkOrderStatusMapping();
        insert statusMapping;
             
        Winaproach_System_Affected__c systemAffected = new Winaproach_System_Affected__c();
        systemAffected.Name = 'Disaster Recovery';
        systemAffected.System_Category__c = 'D';
        insert systemAffected;
             
     	//ServiceNow custom settings   	    	
        
        ServiceNowIncidentSettings__c incidentSettings = NI_TestClassData.createServiceNowIncidentSettings();
        insert incidentSettings;
              
        List<ServiceNow_Incident_Severity_Mapping__c> incidentSeverityMapping = NI_TestClassData.createIncidentSeverityMapping();
        insert incidentSeverityMapping;
        
        List<ServiceNow_Incident_Status_Mapping__c> incidentStatusMapping = NI_TestClassData.createSNIncidentStatusMapping();
        insert incidentStatusMapping;
        
        ServiceNow_Pending_Code_Mapping__c pendingCode = NI_TestClassData.createPendingCodeMapping();
        insert pendingCode;        
        //End of Custom Settings    
        return winSettings;
            
    }
	*/    
    
    static testMethod void winAproachWebServiceCoverage() {
        
        List<Case> lstCase = new List<Case>();	
        /*
        THIS CODE PRODUCES FOLLOWING ERROR:
        The username already exists in this or another Salesforce organization. Usernames must be unique across all Salesforce organizations. 
        To resolve, use a different username (it doesn't need to match the user's email address). : [Username] 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt1', Email='standarduser10@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, DepartmentCode__c = 'Dev',No_AD_Account_Standard_User__c = true,
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser10@testorg.com');
        */
        User u = NI_TestClassData.createTestUser(120, 'System Administrator'); 
        insert u;
        
        System.runAs(u) {
            //Custom Settings 
            //       		WinaproachIncidentSettings__c winSettings = TestNI_Winaproach.createCustomSettings();
            NI_TestClassData.createTestWinaproachServiceNowSettings();
            WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default'); 
            //End of Custom Settings
            
            //      	Case cs = new Case();
            //      	
            Account a1 = NI_TestClassData.createTestAccount(1);
            Case cs = NI_TestClassData.createTestCase(1, a1.Id);
            cs.Subject = 'TestBK- ttest10';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '4';
            cs.Amadeus_ExternalSystemAssigneeGroup__c	= 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs.status = 'Open';
            cs.Winaproach_Logger__c = 'test';
            cs.Description = 'Test description';
            cs.Cause_Id_Code__c = 'CONFIG';
            cs.Resolution_Code__c = 'CODE';
            cs.Reject_Reason_Code__c = 'C';		
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            
            insert cs;
            
            lstCase.add(cs);
            //		Case updateCs = new Case();
            Case updateCs = NI_TestClassData.createTestCase(2, a1.Id);
            updateCs.Id = cs.Id;
            updateCs.Status = 'Acknowledged';
            updateCs.Customer_Severity__c ='3';
            updateCs.Amadeus_External_System_Id__c = '10762030';
            updateCs.Cause_Id_Code__c = 'APP';
            updateCs.Resolution_Code__c = 'ENVIRON';
            updateCs.Reject_Reason_Code__c = 'F';		
            update updateCs;
            
            
            List<case> lstUpdate = new List<Case>();
            lstUpdate.add(updateCs);
            
            //		Attachment attach=new Attachment();   	
            Attachment attach = NI_TestClassData.createTestAttachment(a1.Id);
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=updateCs.id;
            insert attach;
            
            /* SET THIS UP TO USE TEST CLASS DATA AND REMOVED HARD-CODED RECORDTYPE THAT ONLY EXISTED IN DEV ORG -sharris
            Task t = new Task();
            t.OwnerId = UserInfo.getUserId();		
            t.RecordTypeID = '012170000008l5k';
            t.Subject='Donni';
            t.Status='Not Started';
            t.Priority='Normal';
            t.WhatId = cs.id;
            t.Parallel_Investigation_Group__c = 'MHDHOT';
            t.Parallel_Investigation_Reason_Code__c = 'SMC Investigation Completed';
            t.Added_By_Group__c = 'MHDHOT';
            t.Description = 'Comments';
            t.PI_Group_Long_Names__c = 'Service Reliability Engineers - OCHOOO';
            insert t;    
            */
            // GET RECORDTYPE INFO
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Task; 
            Map<String, Schema.RecordTypeInfo> TaskRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
            
            Id rtAmadeusParallelInvestigationId = TaskRecordTypeInfo.get('Amadeus Parallel Investigation').getRecordTypeId(); 
            
            Task t = NI_TestClassData.createTestTask(1, null, cs.id, rtAmadeusParallelInvestigationId, 'Call', 'Not Started', 'Normal');
            t.OwnerId = UserInfo.getUserId();		
            t.Subject='Donni';
            t.Parallel_Investigation_Group__c = 'MHDHOT';
            t.Parallel_Investigation_Reason_Code__c = 'SMC Investigation Completed';
            t.Added_By_Group__c = 'MHDHOT';
            t.Description = 'Comments';
            t.PI_Group_Long_Names__c = 'Service Reliability Engineers - OCHOOO';             
            
            List<Task> lstTask = new List<task>();
            lstTask.add(t);
            
            NI_WinaproachService niwin = new NI_WinaproachService('Create',lstCase);
            String request = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><update><incomingXML>&lt;?xml version="1.0" encoding="UTF-8"?>&lt;ticket_exchange>&lt;update>&lt;record_type>incident&lt;/record_type>&lt;external_record_id>001534576&lt;/external_record_id>&lt;record_id>10762030&lt;/record_id>&lt;status>AA&lt;/status>&lt;severity>3&lt;/severity>&lt;urgency>N&lt;/urgency>&lt;assignee>&lt;group>MHDAIT&lt;/group>&lt;/assignee>&lt;resolution_code>CODE&lt;/resolution_code>&lt;/update>&lt;/ticket_exchange></incomingXML></update></soapenv:Body></soapenv:Envelope>';
            String response = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><updateResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><updateReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-03-31 11:23:23 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10762030&lt;/record_id&gt;&lt;external_record_id&gt;001534576&lt;/external_record_id&gt; &lt;comment&gt;Record updated successfully.&lt;/comment&gt;&lt;comment&gt;IrStatusAACorrection: S0BEE: 10762030: Update state is changed from \'AA\' to \'AS\'.UnchangedFieldsCorrection: S0BE7: Value of sword is not changed: \'3\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</updateReturn></updateResponse></soapenv:Body></soapenv:Envelope>';
            String createResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><createResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><createReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-01 10:46:26 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10763085&lt;/record_id&gt;&lt;external_record_id&gt;001534583&lt;/external_record_id&gt;&lt;comment&gt;Record created successfully.&lt;/comment&gt;&lt;comment&gt;InvalidValueOfComboCorrection: S81AB: SWord is not valid for the record type \'IR\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</createReturn></createResponse></soapenv:Body></soapenv:Envelope>';
            String unAuthResponse = '<html><head><title>401 Unauthorized</title></head><body><h1>Unauthorized</h1><p>This server could not verify that you are authorized to access the document requested.  Either you supplied the wrong credentials (e.g., bad password), or your browser doesn\'t understand how to supply the credentials required.</p></body></html>';
            
            String taskResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><updateResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><updateReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-26 10:10:36 GMT&quot;&gt;  &lt;success&gt;    &lt;record_id&gt;10786919&lt;/record_id&gt;    &lt;external_record_id&gt;5001700000475ulAAA&lt;/external_record_id&gt;    &lt;parallel_investigation_list&gt;     &lt;parallel_investigation&gt;        &lt;investigation_id&gt;169227&lt;/investigation_id&gt;       &lt;external_investigation_id&gt;00T17000008hVRREA2&lt;/external_investigation_id&gt;      &lt;/parallel_investigation&gt;      &lt;parallel_investigation&gt;       &lt;investigation_id&gt;169231&lt;/investigation_id&gt;        &lt;external_investigation_id&gt;00T17000008hVRREA2&lt;/external_investigation_id&gt;     &lt;/parallel_investigation&gt;    &lt;/parallel_investigation_list&gt;    &lt;comment&gt;Record updated successfully.&lt;/comment&gt;    &lt;comment&gt;FftForPiCorrection: S0E02:FFT Parallel investigation added: &lt;/comment&gt;  &lt;/success&gt;&lt;/ticket_response&gt;</updateReturn></updateResponse></soapenv:Body></soapenv:Envelope>';
            //String faultString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring><![CDATA[<?xml version="1.0" encoding="UTF-8"?><ticket_response version="1.0"  timestamp="2016-04-05 10:33:02 GMT">  <failure>    <record_id>10764497</record_id>   <external_record_id>001534593</external_record_id>    <comment>Duplicate Create recieved with extID:001534593 - Record:10764497already created earlier</comment>    <error_type>EAPR-CRE-DUPL</error_type>    <error_msg />    <resend>false</resend>  </failure></ticket_response>]]></faultstring>         <detail>            <ns1:hostnamexmlns:ns1="http://xml.apache.org/axis/">aprtst03</ns1:hostname>         </detail>      </soapenv:Fault>   </soapenv:Body></soapenv:Envelope>';
            String taskRequest = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><update><incomingXML>&lt;?xml version="1.0" encoding="UTF-8"?>&lt;ticket_exchange>&lt;update>&lt;record_type>incident&lt;/record_type>&lt;external_record_id>500170000048c6EAAQ&lt;/external_record_id>&lt;record_id>10812414&lt;/record_id>&lt;status>AC&lt;/status>&lt;assignee>&lt;group>MHDAIT&lt;/group>&lt;/assignee>&lt;parallel_investigation_list>&lt;parallel_investigation>&lt;external_investigation_id>00T17000008hkWlEAI&lt;/external_investigation_id>&lt;investigation_reason_code>SE&lt;/investigation_reason_code>&lt;investigation_added_by_group>MHDHOT&lt;/investigation_added_by_group>&lt;investigation_group>MHDHOT&lt;/investigation_group>&lt;investigation_comment>Comments&lt;/investigation_comment>&lt;/parallel_investigation>&lt;/parallel_investigation_list>&lt;/update>&lt;/ticket_exchange></incomingXML></update></soapenv:Body></soapenv:Envelope>';
            
            
            List<NI_Integration_Log__c> lstnLog = new List<NI_Integration_Log__c>();
            lstnLog.add(NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), response, 'Success', 'Update','CaseComment',winSettings.Endpoint__c,'Win@proach', request));
            
            system.assert(lstnLog.size() ==1);
            
            niwin.parseAndLogResponse(response,String.valueOf(cs.Id),winSettings.Endpoint__c, 'Update', 'CaseComment', lstUpdate, lstnLog,request,null, null);

            List<NI_Integration_Log__c> lstnLog2 = new List<NI_Integration_Log__c>();
            lstnLog2.add(NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), createResponse, 'Success', 'Insert',null,winSettings.Endpoint__c,'Win@proach', request));
            
            system.assert(lstnLog2.size() ==1);
            //String response,String cs,String endPoint, String opType, String updateFor, List<Case> resUpdateCase, List<NI_Integration_Log__c> resInsertLog,String xmlRequest, List<Task> resUpdateTask, Attachment at
            
            niwin.parseAndLogResponse(createResponse,String.valueOf(cs.Id),winSettings.Endpoint__c, 'Insert', null, lstUpdate, lstnLog2,request,null, null);
            
            List<NI_Integration_Log__c> lstnLog3 = new List<NI_Integration_Log__c>();
            lstnLog3.add(NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), unAuthResponse, 'Failed', 'Insert',null,winSettings.Endpoint__c,'Win@proach', request));
            
            system.assert(lstnLog3.size() ==1);
            niwin.parseAndLogResponse(unAuthResponse,String.valueOf(cs.Id),winSettings.Endpoint__c, 'Insert', null, lstUpdate, lstnLog3,request,null, null);
            
            List<NI_Integration_Log__c> lstnLog4 = new List<NI_Integration_Log__c>();
            lstnLog.add(NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), taskResponse, 'Success', 'Update','Task',winSettings.Endpoint__c,'Win@proach', taskRequest));
            //system.debug(lstnLog4.size());
            system.assert(lstnLog4.size() ==0);		
            niwin.parseAndLogResponse(taskResponse,String.valueOf(cs.Id),winSettings.Endpoint__c, 'Update', 'Task', lstUpdate, lstnLog4,taskRequest,lstTask, null);

        }
        
    }
    
    static testmethod void winAproachHTTPRequest(){
        
        List<Case> lstCase = new List<Case>();	
        /*
        THIS CODE PRODUCES FOLLOWING ERROR:
        The username already exists in this or another Salesforce organization. Usernames must be unique across all Salesforce organizations. 
        To resolve, use a different username (it doesn't need to match the user's email address). : [Username] 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt1', Email='standarduser10@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, DepartmentCode__c = 'Dev',No_AD_Account_Standard_User__c = true,
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser10@testorg.com');
        */
        User u = NI_TestClassData.createTestUser(121, 'System Administrator'); 
        insert u;
        
        System.runAs(u) {
            //Custom Settings 
            //       		WinaproachIncidentSettings__c winSettings = TestNI_Winaproach.createCustomSettings();      
            NI_TestClassData.createTestWinaproachServiceNowSettings();
            WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default'); 
            //End of Custom Settings
            //  
            Test.startTest();

            String createResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><createResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><createReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-01 10:46:26 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10763085&lt;/record_id&gt;&lt;external_record_id&gt;001534583&lt;/external_record_id&gt;&lt;comment&gt;Record created successfully.&lt;/comment&gt;&lt;comment&gt;InvalidValueOfComboCorrection: S81AB: SWord is not valid for the record type \'IR\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</createReturn></createResponse></soapenv:Body></soapenv:Envelope>';
            TestWinaproachMockRequest fakeResponse = new TestWinaproachMockRequest(200,
                                                                                   'Complete',
                                                                                   createResponse,
                                                                                   null);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            
            
            //Case cs = new Case();
            Account a1 = NI_TestClassData.createTestAccount(1);
            Case cs = NI_TestClassData.createTestCase(1, a1.Id);
            cs.Subject = 'TestBK- ttest10';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '4';
            cs.Amadeus_ExternalSystemAssigneeGroup__c	= 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs.status = 'Open';
            cs.Winaproach_Logger__c = 'test';
            cs.Description = 'Test description';
            cs.Cause_Id_Code__c = 'CONFIG';
            cs.Resolution_Code__c = 'CODE';
            cs.Reject_Reason_Code__c = 'C';		
            
            lstCase.add(cs);
            //}
            insert cs;
            NI_BatchWinaproachResend c = new NI_BatchWinaproachResend();
            Database.executeBatch(c);
            
            String strupdateResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><updateResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><updateReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-03-31 11:23:23 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10762030&lt;/record_id&gt;&lt;external_record_id&gt;001534576&lt;/external_record_id&gt; &lt;comment&gt;Record updated successfully.&lt;/comment&gt;&lt;comment&gt;IrStatusAACorrection: S0BEE: 10762030: Update state is changed from \'AA\' to \'AS\'.UnchangedFieldsCorrection: S0BE7: Value of sword is not changed: \'3\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</updateReturn></updateResponse></soapenv:Body></soapenv:Envelope>';
            TestWinaproachMockRequest updateResponse = new TestWinaproachMockRequest(200,
                                                                                     'Complete',
                                                                                     strupdateResponse,
                                                                                     null);
            Test.setMock(HttpCalloutMock.class, updateResponse);

            //			Attachment attach=new Attachment();   	
            Attachment attach = NI_TestClassData.createTestAttachment(a1.Id);
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=cs.id;
            insert attach;	

            cs.Customer_Severity__c = '3';
            cs.Amadeus_External_System_Id__c = '10762030';
            /*cs.Amadeus_ExternalSystemAssigneeGroup__c	= 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs.status = 'Open';
            cs.Winaproach_Logger__c = 'test';
            cs.Description = 'Test description';
            cs.Cause_Id_Code__c = 'CONFIG';
            cs.Resolution_Code__c = 'CODE';
            cs.Reject_Reason_Code__c = 'C';		
            */
            //   lstCase.add(cs);
            //
            update cs;
            
            /*Task t = new Task();
            t.OwnerId = UserInfo.getUserId();		
            t.RecordTypeID = '012170000008l5k';
            t.Subject='Donni';
            t.Status='Not Started';
            t.Priority='Normal';
            t.WhatId = cs.id;
            t.Parallel_Investigation_Group__c = 'MHDHOT';
            t.Parallel_Investigation_Reason_Code__c = 'SMC Investigation Completed';
            t.Added_By_Group__c = 'MHDHOT';
            t.PI_Group_Long_Names__c = 'Service Reliability Engineers - OCHOOO';
            t.Description = 'Comments';
            insert t;    
            */
            List<Task> lstTask = new List<task>();
            //lstTask.add(t);
  
            NI_BatchWinaproachResend d = new NI_BatchWinaproachResend();
            Database.executeBatch(d);

            String request = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><update><incomingXML>&lt;?xml version="1.0" encoding="UTF-8"?>&lt;ticket_exchange>&lt;update>&lt;record_type>incident&lt;/record_type>&lt;external_record_id>001534576&lt;/external_record_id>&lt;record_id>10762030&lt;/record_id>&lt;status>AA&lt;/status>&lt;severity>3&lt;/severity>&lt;urgency>N&lt;/urgency>&lt;assignee>&lt;group>MHDAIT&lt;/group>&lt;/assignee>&lt;resolution_code>CODE&lt;/resolution_code>&lt;/update>&lt;/ticket_exchange></incomingXML></update></soapenv:Body></soapenv:Envelope>';
            String response = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><updateResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><updateReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-03-31 11:23:23 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10762030&lt;/record_id&gt;&lt;external_record_id&gt;001534576&lt;/external_record_id&gt; &lt;comment&gt;Record updated successfully.&lt;/comment&gt;&lt;comment&gt;IrStatusAACorrection: S0BEE: 10762030: Update state is changed from \'AA\' to \'AS\'.UnchangedFieldsCorrection: S0BE7: Value of sword is not changed: \'3\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</updateReturn></updateResponse></soapenv:Body></soapenv:Envelope>';
            //String createResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><createResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><createReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-01 10:46:26 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10763085&lt;/record_id&gt;&lt;external_record_id&gt;001534583&lt;/external_record_id&gt;&lt;comment&gt;Record created successfully.&lt;/comment&gt;&lt;comment&gt;InvalidValueOfComboCorrection: S81AB: SWord is not valid for the record type \'IR\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</createReturn></createResponse></soapenv:Body></soapenv:Envelope>';
            String createRequest = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>001534593</external_record_id><severity>4</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>MHDAIT</group><name>Swapnil Patil</name></logger><title>Test subject</title><description><entry><date_time>2016-04-04 02:14</date_time><group>MHDHOT</group><name>Swapnil Patil</name><text><line>Test desc</line></text></entry></description></create></ticket_exchange>';
            String strcreateResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><createResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><createReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-01 10:46:26 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10763085&lt;/record_id&gt;&lt;external_record_id&gt;001534583&lt;/external_record_id&gt;&lt;comment&gt;Record created successfully.&lt;/comment&gt;&lt;comment&gt;InvalidValueOfComboCorrection: S81AB: SWord is not valid for the record type \'IR\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</createReturn></createResponse></soapenv:Body></soapenv:Envelope>';
            String unAuthResponse = '<html><head><title>401 Unauthorized</title></head><body><h1>Unauthorized</h1><p>This server could not verify that you are authorized to access the document requested.  Either you supplied the wrong credentials (e.g., bad password), or your browser doesn\'t understand how to supply the credentials required.</p></body></html>';
            //String taskResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><updateResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><updateReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-26 10:10:36 GMT&quot;&gt;  &lt;success&gt;    &lt;record_id&gt;10786919&lt;/record_id&gt;    &lt;external_record_id&gt;5001700000475ulAAA&lt;/external_record_id&gt;    &lt;parallel_investigation_list&gt;     &lt;parallel_investigation&gt;        &lt;investigation_id&gt;169227&lt;/investigation_id&gt;       &lt;external_investigation_id&gt;00T17000008hVRREA2&lt;/external_investigation_id&gt;      &lt;/parallel_investigation&gt;      &lt;parallel_investigation&gt;       &lt;investigation_id&gt;169231&lt;/investigation_id&gt;        &lt;external_investigation_id&gt;00T17000008hVRREA2&lt;/external_investigation_id&gt;     &lt;/parallel_investigation&gt;    &lt;/parallel_investigation_list&gt;    &lt;comment&gt;Record updated successfully.&lt;/comment&gt;    &lt;comment&gt;FftForPiCorrection: S0E02:FFT Parallel investigation added: &lt;/comment&gt;  &lt;/success&gt;&lt;/ticket_response&gt;</updateReturn></updateResponse></soapenv:Body></soapenv:Envelope>';
            //String faultString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring><![CDATA[<?xml version="1.0" encoding="UTF-8"?><ticket_response version="1.0"  timestamp="2016-04-05 10:33:02 GMT">  <failure>    <record_id>10764497</record_id>   <external_record_id>001534593</external_record_id>    <comment>Duplicate Create recieved with extID:001534593 - Record:10764497already created earlier</comment>    <error_type>EAPR-CRE-DUPL</error_type>    <error_msg />    <resend>false</resend>  </failure></ticket_response>]]></faultstring>         <detail>            <ns1:hostnamexmlns:ns1="http://xml.apache.org/axis/">aprtst03</ns1:hostname>         </detail>      </soapenv:Fault>   </soapenv:Body></soapenv:Envelope>';
            List<NI_Integration_Log_Message__c> resInsertLogMsg = new List<NI_Integration_Log_Message__c>();
            List<Id> resUpdateLog = new List<Id>();
            List<Id> resFailedLog = new List<Id>(); 
            //System.debug([select id, name from NI_Integration_Log__c]);
            //NI_WinaproachServiceHelper.parseAndLogResponse(String logId,String cs, String reqBody, String response,String resHeader, List<Case> resUpdateCase, List<NI_Integration_Log_Message__c> resInsertLogMsg, List<Id> resUpdateLog, List<Id> resFailedLog){
            NI_WinaproachServiceHelper niwin = new NI_WinaproachServiceHelper();
            niwin.parseAndLogResponse('a0w17000002W0R7','500170000040e4kAAA', request, response,'HTTP Ok', lstCase, resInsertLogMsg, resUpdateLog, resFailedLog,lstTask);
            niwin.parseAndLogResponse('a0w17000002W0R7','500170000040e4kAAA', createRequest, strcreateResponse,'HTTP Ok', lstCase, resInsertLogMsg, resUpdateLog, resFailedLog,null);
            niwin.parseAndLogResponse('a0w17000002W0R7','500170000040e4kAAA', createRequest, unAuthResponse,'HTTP Ok', lstCase, resInsertLogMsg, resUpdateLog, resFailedLog,null);
            //niwin.parseAndLogResponse('a0w17000002W0R7','500170000040e4kAAA', request, taskResponse,'HTTP Ok', lstCase, resInsertLogMsg, resUpdateLog, resFailedLog,lstTask);
            //niwin.parseAndLogResponse('a0w17000002W0R7','500170000040e4kAAA', createRequest, faultString,'HTTP Ok', lstCase, resInsertLogMsg, resUpdateLog, resFailedLog);

            Test.stopTest();
            //CalloutAccounts.getAccounts();
        }
    }
    
    static testmethod void winaproachUpdateForTask(){

        List<Case> lstCase = new List<Case>();	
        /*
        THIS CODE PRODUCES FOLLOWING ERROR:
        The username already exists in this or another Salesforce organization. Usernames must be unique across all Salesforce organizations. 
        To resolve, use a different username (it doesn't need to match the user's email address). : [Username] 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt1', Email='standarduser10@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, DepartmentCode__c = 'Dev',No_AD_Account_Standard_User__c = true,
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser10@testorg.com');
        */
        User u = NI_TestClassData.createTestUser(122, 'System Administrator'); 
        insert u;
        
        System.runAs(u) {
            
            //Custom Settings 
            //       		WinaproachIncidentSettings__c winSettings = TestNI_Winaproach.createCustomSettings();
            NI_TestClassData.createTestWinaproachServiceNowSettings();
            WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default'); 
            //End of Custom Settings
            
            Test.startTest();
            
            String createResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><createResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><createReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-01 10:46:26 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10763085&lt;/record_id&gt;&lt;external_record_id&gt;001534583&lt;/external_record_id&gt;&lt;comment&gt;Record created successfully.&lt;/comment&gt;&lt;comment&gt;InvalidValueOfComboCorrection: S81AB: SWord is not valid for the record type \'IR\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</createReturn></createResponse></soapenv:Body></soapenv:Envelope>';
            TestWinaproachMockRequest fakeResponse = new TestWinaproachMockRequest(200,
                                                                                   'Complete',
                                                                                   createResponse,
                                                                                   null);
            Test.setMock(HttpCalloutMock.class, fakeResponse);			 
            
            //Case cs = new Case();
            Account a1 = NI_TestClassData.createTestAccount(1);
            Case cs = NI_TestClassData.createTestCase(1, a1.Id);
            cs.Subject = 'TestBK- ttest10';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '4';
            cs.Amadeus_ExternalSystemAssigneeGroup__c	= 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs.status = 'Open';
            cs.Winaproach_Logger__c = 'test';
            cs.Description = 'Test description';
            cs.Cause_Id_Code__c = 'CONFIG';
            cs.Resolution_Code__c = 'CODE';
            cs.Reject_Reason_Code__c = 'C';		
            
            lstCase.add(cs);
            //}
            insert cs;
            NI_BatchWinaproachResend c = new NI_BatchWinaproachResend();
            Database.executeBatch(c);
            
            String strupdateResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><updateResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><updateReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-03-31 11:23:23 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10762030&lt;/record_id&gt;&lt;external_record_id&gt;001534576&lt;/external_record_id&gt; &lt;comment&gt;Record updated successfully.&lt;/comment&gt;&lt;comment&gt;IrStatusAACorrection: S0BEE: 10762030: Update state is changed from \'AA\' to \'AS\'.UnchangedFieldsCorrection: S0BE7: Value of sword is not changed: \'3\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</updateReturn></updateResponse></soapenv:Body></soapenv:Envelope>';
            TestWinaproachMockRequest updateResponse = new TestWinaproachMockRequest(200,
                                                                                     'Complete',
                                                                                     strupdateResponse,
                                                                                     null);
            Test.setMock(HttpCalloutMock.class, updateResponse);
            
            /* SET THIS UP TO USE TEST CLASS DATA AND REMOVED HARD-CODED RECORDTYPE THAT ONLY EXISTED IN DEV ORG -sharris          
            Task t = new Task();
            t.OwnerId = UserInfo.getUserId();		
            t.RecordTypeID = '012170000008l5k';
            t.Subject='Donni';
            t.Status='Not Started';
            t.Priority='Normal';
            t.WhatId = cs.id;
            t.Parallel_Investigation_Group__c = 'MHDHOT';
            t.Parallel_Investigation_Reason_Code__c = 'SMC Investigation Completed';
            t.Added_By_Group__c = 'MHDHOT';
            t.Description = 'Comments';
            t.PI_Group_Long_Names__c = 'Service Reliability Engineers - OCHOOO';
            insert t; 
            */
            // GET RECORDTYPE INFO
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Task; 
            Map<String, Schema.RecordTypeInfo> TaskRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
            
            Id rtAmadeusParallelInvestigationId = TaskRecordTypeInfo.get('Amadeus Parallel Investigation').getRecordTypeId(); 
            
            Task t = NI_TestClassData.createTestTask(1, null, cs.id, rtAmadeusParallelInvestigationId, 'Call', 'Not Started', 'Normal');
            t.OwnerId = UserInfo.getUserId();		
            t.Subject='Donni';
            t.Parallel_Investigation_Group__c = 'MHDHOT';
            t.Parallel_Investigation_Reason_Code__c = 'SMC Investigation Completed';
            t.Added_By_Group__c = 'MHDHOT';
            t.Description = 'Comments';
            t.PI_Group_Long_Names__c = 'Service Reliability Engineers - OCHOOO';             
            
            List<Task> lstTask = new List<task>();
            lstTask.add(t);

            NI_BatchWinaproachResend d = new NI_BatchWinaproachResend();
            Database.executeBatch(d);

            String request = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><update><incomingXML>&lt;?xml version="1.0" encoding="UTF-8"?>&lt;ticket_exchange>&lt;update>&lt;record_type>incident&lt;/record_type>&lt;external_record_id>001534576&lt;/external_record_id>&lt;record_id>10762030&lt;/record_id>&lt;status>AA&lt;/status>&lt;severity>3&lt;/severity>&lt;urgency>N&lt;/urgency>&lt;assignee>&lt;group>MHDAIT&lt;/group>&lt;/assignee>&lt;resolution_code>CODE&lt;/resolution_code>&lt;/update>&lt;/ticket_exchange></incomingXML></update></soapenv:Body></soapenv:Envelope>';
            String response = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><updateResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><updateReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-03-31 11:23:23 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10762030&lt;/record_id&gt;&lt;external_record_id&gt;001534576&lt;/external_record_id&gt; &lt;comment&gt;Record updated successfully.&lt;/comment&gt;&lt;comment&gt;IrStatusAACorrection: S0BEE: 10762030: Update state is changed from \'AA\' to \'AS\'.UnchangedFieldsCorrection: S0BE7: Value of sword is not changed: \'3\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</updateReturn></updateResponse></soapenv:Body></soapenv:Envelope>';
            //String createResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><createResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><createReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-01 10:46:26 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10763085&lt;/record_id&gt;&lt;external_record_id&gt;001534583&lt;/external_record_id&gt;&lt;comment&gt;Record created successfully.&lt;/comment&gt;&lt;comment&gt;InvalidValueOfComboCorrection: S81AB: SWord is not valid for the record type \'IR\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</createReturn></createResponse></soapenv:Body></soapenv:Envelope>';
            String createRequest = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>001534593</external_record_id><severity>4</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>MHDAIT</group><name>Swapnil Patil</name></logger><title>Test subject</title><description><entry><date_time>2016-04-04 02:14</date_time><group>MHDHOT</group><name>Swapnil Patil</name><text><line>Test desc</line></text></entry></description></create></ticket_exchange>';
            String strcreateResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><createResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><createReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-01 10:46:26 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10763085&lt;/record_id&gt;&lt;external_record_id&gt;001534583&lt;/external_record_id&gt;&lt;comment&gt;Record created successfully.&lt;/comment&gt;&lt;comment&gt;InvalidValueOfComboCorrection: S81AB: SWord is not valid for the record type \'IR\'. Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</createReturn></createResponse></soapenv:Body></soapenv:Envelope>';
            String unAuthResponse = '<html><head><title>401 Unauthorized</title></head><body><h1>Unauthorized</h1><p>This server could not verify that you are authorized to access the document requested.  Either you supplied the wrong credentials (e.g., bad password), or your browser doesn\'t understand how to supply the credentials required.</p></body></html>';
            String taskResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><updateResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><updateReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-26 10:10:36 GMT&quot;&gt;  &lt;success&gt;    &lt;record_id&gt;10786919&lt;/record_id&gt;    &lt;external_record_id&gt;5001700000475ulAAA&lt;/external_record_id&gt;    &lt;parallel_investigation_list&gt;     &lt;parallel_investigation&gt;        &lt;investigation_id&gt;169227&lt;/investigation_id&gt;       &lt;external_investigation_id&gt;00T17000008hVRREA2&lt;/external_investigation_id&gt;      &lt;/parallel_investigation&gt;      &lt;parallel_investigation&gt;       &lt;investigation_id&gt;169231&lt;/investigation_id&gt;        &lt;external_investigation_id&gt;00T17000008hVRREA2&lt;/external_investigation_id&gt;     &lt;/parallel_investigation&gt;    &lt;/parallel_investigation_list&gt;    &lt;comment&gt;Record updated successfully.&lt;/comment&gt;    &lt;comment&gt;FftForPiCorrection: S0E02:FFT Parallel investigation added: &lt;/comment&gt;  &lt;/success&gt;&lt;/ticket_response&gt;</updateReturn></updateResponse></soapenv:Body></soapenv:Envelope>';
            //String faultString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring><![CDATA[<?xml version="1.0" encoding="UTF-8"?><ticket_response version="1.0"  timestamp="2016-04-05 10:33:02 GMT">  <failure>    <record_id>10764497</record_id>   <external_record_id>001534593</external_record_id>    <comment>Duplicate Create recieved with extID:001534593 - Record:10764497already created earlier</comment>    <error_type>EAPR-CRE-DUPL</error_type>    <error_msg />    <resend>false</resend>  </failure></ticket_response>]]></faultstring>         <detail>            <ns1:hostnamexmlns:ns1="http://xml.apache.org/axis/">aprtst03</ns1:hostname>         </detail>      </soapenv:Fault>   </soapenv:Body></soapenv:Envelope>';
            String taskRequest = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><update><incomingXML>&lt;?xml version="1.0" encoding="UTF-8"?>&lt;ticket_exchange>&lt;update>&lt;record_type>incident&lt;/record_type>&lt;external_record_id>500170000048c6EAAQ&lt;/external_record_id>&lt;record_id>10812414&lt;/record_id>&lt;status>AC&lt;/status>&lt;assignee>&lt;group>MHDAIT&lt;/group>&lt;/assignee>&lt;parallel_investigation_list>&lt;parallel_investigation>&lt;external_investigation_id>00T17000008hkWlEAI&lt;/external_investigation_id>&lt;investigation_reason_code>SE&lt;/investigation_reason_code>&lt;investigation_added_by_group>MHDHOT&lt;/investigation_added_by_group>&lt;investigation_group>MHDHOT&lt;/investigation_group>&lt;investigation_comment>Comments&lt;/investigation_comment>&lt;/parallel_investigation>&lt;/parallel_investigation_list>&lt;/update>&lt;/ticket_exchange></incomingXML></update></soapenv:Body></soapenv:Envelope>';
            List<NI_Integration_Log_Message__c> resInsertLogMsg = new List<NI_Integration_Log_Message__c>();
            List<Id> resUpdateLog = new List<Id>();
            List<Id> resFailedLog = new List<Id>(); 
            //System.debug([select id, name from NI_Integration_Log__c]);
            //NI_WinaproachServiceHelper.parseAndLogResponse(String logId,String cs, String reqBody, String response,String resHeader, List<Case> resUpdateCase, List<NI_Integration_Log_Message__c> resInsertLogMsg, List<Id> resUpdateLog, List<Id> resFailedLog){
            NI_WinaproachServiceHelper niwin = new NI_WinaproachServiceHelper();
            niwin.parseAndLogResponse('a0w17000002W0R7','500170000040e4kAAA', request, response,'HTTP Ok', lstCase, resInsertLogMsg, resUpdateLog, resFailedLog,null);
            niwin.parseAndLogResponse('a0w17000002W0R7','500170000040e4kAAA', createRequest, strcreateResponse,'HTTP Ok', lstCase, resInsertLogMsg, resUpdateLog, resFailedLog,null);
            niwin.parseAndLogResponse('a0w17000002W0R7','500170000040e4kAAA', createRequest, unAuthResponse,'HTTP Ok', lstCase, resInsertLogMsg, resUpdateLog, resFailedLog,null);
            niwin.parseAndLogResponse('a0w17000002W0R7','500170000040e4kAAA', taskRequest, taskResponse,'Task', lstCase, resInsertLogMsg, resUpdateLog, resFailedLog,lstTask);
            //niwin.parseAndLogResponse('a0w17000002W0R7','500170000040e4kAAA', createRequest, faultString,'HTTP Ok', lstCase, resInsertLogMsg, resUpdateLog, resFailedLog);

            Test.stopTest();
            //CalloutAccounts.getAccounts();
        }
	
    }
    
    static testMethod void winAproachWorkOrderRequest() {
        
        List<Case> lstCase = new List<Case>();	
        /*
        THIS CODE PRODUCES FOLLOWING ERROR:
        The username already exists in this or another Salesforce organization. Usernames must be unique across all Salesforce organizations. 
        To resolve, use a different username (it doesn't need to match the user's email address). : [Username] 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt1', Email='standarduser10@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, DepartmentCode__c = 'Dev',No_AD_Account_Standard_User__c = true,
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser10@testorg.com');
        */
        User u = NI_TestClassData.createTestUser(123, 'System Administrator'); 
        insert u;
        
        System.runAs(u) {
            //Custom Settings 
            //       		WinaproachIncidentSettings__c winSettings = TestNI_Winaproach.createCustomSettings();
            NI_TestClassData.createTestWinaproachServiceNowSettings();
            WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default'); 
            //End of Custom Settings
            
            //Case cs = new Case();
            Account a1 = NI_TestClassData.createTestAccount(1);
            Case cs = NI_TestClassData.createTestCase(1, a1.Id);
            cs.Subject = 'TestBK- ttest10';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Work Order').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '4';
            cs.Amadeus_ExternalSystemAssigneeGroup__c	= 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs.status = 'Assigned';
            cs.Winaproach_Logger__c = 'test';
            cs.Description = 'Test description';		
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Origin = 'ServiceNow Integration';
            insert cs;
            
            //Case csUpdate = new Case();
            Case csUpdate = NI_TestClassData.createTestCase(1, a1.Id);
            csUpdate.id = cs.Id;
            csUpdate.Amadeus_External_System_Id__c = '123456';
            csUpdate.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Work Order').getRecordTypeId();
            csUpdate.Description = 'Updated desc';
            update csUpdate;
            
            system.debug(cs.RecordTypeID);
            lstCase.add(cs);
            
            NI_WinaproachService niwin = new NI_WinaproachService('Create',lstCase);
            String request = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><create><incomingXML>&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_exchange&gt;&lt;create&gt;&lt;record_type&gt;WO&lt;/record_type&gt;&lt;external_record_id&gt;50017000004KDuIAAW&lt;/external_record_id&gt;&lt;severity&gt;4&lt;/severity&gt;&lt;urgency&gt;N&lt;/urgency&gt;&lt;category&gt;&lt;system_category&gt;T&lt;/system_category&gt;&lt;work_order_type&gt;OTHER&lt;/work_order_type&gt;&lt;/category&gt;&lt;Status&gt;AA&lt;/Status&gt;&lt;logger&gt;&lt;group&gt;MHDHOT&lt;/group&gt;&lt;name&gt;loggername&lt;/name&gt;&lt;tel&gt;123456&lt;/tel&gt;&lt;/logger&gt;&lt;dates&gt;&lt;requested_date_time&gt;2016-06-24 06:38:43&lt;/requested_date_time&gt;&lt;/dates&gt;&lt;affected_service&gt;property_change_of_brand&lt;/affected_service&gt;&lt;title&gt;WorkOrder Resend Test 2&lt;/title&gt;&lt;overview&gt;&lt;entry&gt;&lt;date_time&gt;2016-06-24 06:38:43&lt;/date_time&gt;&lt;group&gt;MHDHOT&lt;/group&gt;&lt;name&gt;loggername&lt;/name&gt;&lt;tel&gt;123456&lt;/tel&gt;&lt;text&gt;&lt;line&gt;WorkOrder Resend Test 2&lt;/line&gt;&lt;/text&gt;&lt;/entry&gt;&lt;/overview&gt;&lt;/create&gt;&lt;/ticket_exchange&gt;</incomingXML></create></soapenv:Body></soapenv:Envelope>';
            
            String createResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><createResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><createReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-06-24 09:12:32 GMT&quot;&gt;  &lt;success&gt;   &lt;record_id&gt;10908651&lt;/record_id&gt;    &lt;external_record_id&gt;50017000004K8I4AAM&lt;/external_record_id&gt;    &lt;comment&gt;Recordcreated successfully.&lt;/comment&gt;  &lt;/success&gt;&lt;/ticket_response&gt;</createReturn></createResponse></soapenv:Body></soapenv:Envelope>';
            
            List<NI_Integration_Log__c> lstnLog2 = new List<NI_Integration_Log__c>();
            lstnLog2.add(NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), createResponse, 'Success', 'Insert',null,winSettings.Endpoint__c,'Win@proach', request));
            
            system.assert(lstnLog2.size() ==1);
            
            niwin.parseAndLogResponse(createResponse,String.valueOf(cs.Id),winSettings.Endpoint__c, 'Insert', null, lstCase, lstnLog2,request,null, null);
            
        }
        
    }
    
}