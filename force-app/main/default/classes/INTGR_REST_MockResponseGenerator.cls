/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : INTGR_REST_MockResponseGenerator Class
Author          : Princy Jain
Created Date    : 04/19/2018
Last Mod Date   : 01/14/2019
Last Mod By     : 
NICC Reference  : 
Description     : Mockup for REST integration test coverage
				: 
************************************************************************************************/
@isTest
public class INTGR_REST_MockResponseGenerator implements HttpCalloutMock 
{
    
    // Implement this interface method
    public Integer isErrorResp = 0;
    public String reqFormat = '';
    
    
    public INTGR_REST_MockResponseGenerator() 
    {
      
    }
    
    public INTGR_REST_MockResponseGenerator(Integer i, String requestType) 
    {
        this.isErrorResp = i;
        this.reqFormat = requestType;
    }
    
    public HttpResponse respond(HTTPRequest req) 
    {
        
        system.debug('in mock response' + isErrorResp);
        
        HttpResponse res = new HttpResponse(); 
        
       // res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/XML');
        res.setHeader('Accept', 'application/XML');
        
       // if (isErrorResp == 0) {
            res.setStatus('Created');
            res.setStatusCode(201);
            String XMLResInsertBody = '<?xml version="1.0" encoding="UTF-8"?><response><result><parent></parent><made_sla>true</made_sla><caused_by></caused_by><watch_list></watch_list><upon_reject>cancel</upon_reject><sys_updated_on>2018-05-30 02:51:10</sys_updated_on><child_incidents>0</child_incidents><hold_reason></hold_reason><approval_history></approval_history><number>INC0010565</number><resolved_by></resolved_by><sys_updated_by>admin</sys_updated_by><opened_by><link>https://dev48905.service-now.com/api/now/table/sys_user/6816f79cc0a8016401c5a33be04be441</link><value>6816f79cc0a8016401c5a33be04be441</value></opened_by><user_input></user_input><sys_created_on>2018-05-30 02:51:10</sys_created_on><sys_domain><link>https://dev48905.service-now.com/api/now/table/sys_user_group/global</link><value>global</value></sys_domain><state>1</state><sys_created_by>admin</sys_created_by><knowledge>false</knowledge><order></order><calendar_stc></calendar_stc><closed_at></closed_at><cmdb_ci></cmdb_ci><delivery_plan></delivery_plan><impact>3</impact><active>true</active><work_notes_list></work_notes_list><business_service></business_service><priority>5</priority><sys_domain_path>/</sys_domain_path><rfc></rfc><time_worked></time_worked><expected_start></expected_start><opened_at>2018-05-30 02:51:10</opened_at><business_duration></business_duration><group_list></group_list><work_end></work_end><caller_id></caller_id><reopened_time></reopened_time><resolved_at></resolved_at><approval_set></approval_set><subcategory></subcategory><work_notes></work_notes><short_description>Test Case</short_description><close_code></close_code><correlation_display></correlation_display><delivery_task></delivery_task><work_start></work_start><assignment_group></assignment_group><additional_assignee_list></additional_assignee_list><business_stc></business_stc><description>Case Test</description><calendar_duration></calendar_duration><close_notes></close_notes><notify>1</notify><sys_class_name>incident</sys_class_name><closed_by></closed_by><follow_up></follow_up><parent_incident></parent_incident><sys_id>b6458ccf4f1253009ba3ff6f9310c7f3</sys_id><contact_type></contact_type><reopened_by></reopened_by><incident_state>1</incident_state><urgency>3</urgency><problem_id></problem_id><company></company><reassignment_count>0</reassignment_count><activity_due></activity_due><assigned_to></assigned_to><severity>3</severity><comments></comments><approval>not requested</approval><sla_due></sla_due><comments_and_work_notes></comments_and_work_notes><due_date></due_date><sys_mod_count>0</sys_mod_count><reopen_count>0</reopen_count><sys_tags></sys_tags><escalation>0</escalation><upon_approval>proceed</upon_approval><correlation_id></correlation_id><location></location><category>inquiry</category></result></response>';
            res.setBody(XMLResInsertBody);
            
       // }
       /* else {
            res.setStatus('Unauthorized');
            res.setStatusCode(404);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><root><response><error><detail>Required to provide Auth information</detail><message>User Not Authenticated</message></error><status>failure</status></response></root>');
            
        }*/
        
        
        /*if (reqFormat.equalsIgnoreCase('JSON')){
            system.debug ('JSON--->' + reqFormat);
            res.setHeader('Content-Type', 'text/json;charset=UTF-8');
        
        if (isErrorResp == 0) {
            res.setStatus('Created');
            res.setStatusCode(201);
            String body = '{"result": {"parent": "","made_sla": "true", "caused_by": "", "watch_list": "","upon_reject": "cancel","sys_updated_on": "2018-03-15 13:00:28","child_incidents": "0","hold_reason": "","approval_history": "","number": "INC0010002","resolved_by": "","sys_updated_by": "admin","opened_by": {"link": "https://dev48905.service-now.com/api/now/table/sys_user/6816f79cc0a8016401c5a33be04be441","value": "6816f79cc0a8016401c5a33be04be441"},"user_input": "","sys_created_on": "2018-03-15 13:00:28", "sys_domain": {"link": "https://dev48905.service-now.com/api/now/table/sys_user_group/global","value": "global"},"state": "1","sys_created_by": "admin","knowledge": "false","order": "","calendar_stc": "","closed_at": "","cmdb_ci": "","delivery_plan": "","impact": "3","active": "true","work_notes_list": "", "business_service": "","priority": "5","sys_domain_path": "/","rfc": "","time_worked": "","expected_start": "","opened_at": "2018-03-15 13:00:28", "business_duration": "","group_list": "","work_end": "", "caller_id": "", "reopened_time": "","resolved_at": "","approval_set": "","subcategory": "","work_notes": "","short_description": "Test Incident REST Call- SFDC","close_code": "","correlation_display": "","delivery_task": "","work_start": "", "assignment_group": "","additional_assignee_list": "","business_stc": "","description": "","calendar_duration": "","close_notes": "","notify": "1","sys_class_name": "incident","closed_by": "","follow_up": "","parent_incident": "","sys_id": "9fe7ba2a4f3013009ba3ff6f9310c789","contact_type": "","reopened_by": "","incident_state": "1", "urgency": "3", "problem_id": {"link": "https://dev48905.service-now.com/api/now/table/problem/5002F000002apyZ","value": "5002F000002apyZ" }, "company": "","reassignment_count": "0", "activity_due": "","assigned_to": "", "severity": "3","comments": "","approval": "not requested","sla_due": "", "comments_and_work_notes": "","due_date": "","sys_mod_count": "0","reopen_count": "0","sys_tags": "","escalation": "0","upon_approval": "proceed", "correlation_id": "", "location": "","category": "network"}}';
            res.setBody(body);
            
        }
        
        if (isErrorResp == 2) {
            
        } else {
            res.setStatus('Unauthorized');
            res.setStatusCode(404);
            res.setBody('{"response": {"error": { "detail": "Required to provide Auth information","message": "User Not Authenticated"},"status": "failure"}}');
            
        }
        }
        else {
            system.debug ('XML--->' + reqFormat);
            res.setHeader('Content-Type', 'application/XML');
            res.setHeader('Accept', 'application/XML');
        
        if (isErrorResp == 0) {
            res.setStatus('Created');
            res.setStatusCode(201);
            String XMLResInsertBody = '<?xml version="1.0" encoding="UTF-8"?><response><result><parent></parent><made_sla>true</made_sla><caused_by></caused_by><watch_list></watch_list><upon_reject>cancel</upon_reject><sys_updated_on>2018-05-30 02:51:10</sys_updated_on><child_incidents>0</child_incidents><hold_reason></hold_reason><approval_history></approval_history><number>INC0010565</number><resolved_by></resolved_by><sys_updated_by>admin</sys_updated_by><opened_by><link>https://dev48905.service-now.com/api/now/table/sys_user/6816f79cc0a8016401c5a33be04be441</link><value>6816f79cc0a8016401c5a33be04be441</value></opened_by><user_input></user_input><sys_created_on>2018-05-30 02:51:10</sys_created_on><sys_domain><link>https://dev48905.service-now.com/api/now/table/sys_user_group/global</link><value>global</value></sys_domain><state>1</state><sys_created_by>admin</sys_created_by><knowledge>false</knowledge><order></order><calendar_stc></calendar_stc><closed_at></closed_at><cmdb_ci></cmdb_ci><delivery_plan></delivery_plan><impact>3</impact><active>true</active><work_notes_list></work_notes_list><business_service></business_service><priority>5</priority><sys_domain_path>/</sys_domain_path><rfc></rfc><time_worked></time_worked><expected_start></expected_start><opened_at>2018-05-30 02:51:10</opened_at><business_duration></business_duration><group_list></group_list><work_end></work_end><caller_id></caller_id><reopened_time></reopened_time><resolved_at></resolved_at><approval_set></approval_set><subcategory></subcategory><work_notes></work_notes><short_description>Test Case</short_description><close_code></close_code><correlation_display></correlation_display><delivery_task></delivery_task><work_start></work_start><assignment_group></assignment_group><additional_assignee_list></additional_assignee_list><business_stc></business_stc><description>Case Test</description><calendar_duration></calendar_duration><close_notes></close_notes><notify>1</notify><sys_class_name>incident</sys_class_name><closed_by></closed_by><follow_up></follow_up><parent_incident></parent_incident><sys_id>b6458ccf4f1253009ba3ff6f9310c7f3</sys_id><contact_type></contact_type><reopened_by></reopened_by><incident_state>1</incident_state><urgency>3</urgency><problem_id></problem_id><company></company><reassignment_count>0</reassignment_count><activity_due></activity_due><assigned_to></assigned_to><severity>3</severity><comments></comments><approval>not requested</approval><sla_due></sla_due><comments_and_work_notes></comments_and_work_notes><due_date></due_date><sys_mod_count>0</sys_mod_count><reopen_count>0</reopen_count><sys_tags></sys_tags><escalation>0</escalation><upon_approval>proceed</upon_approval><correlation_id></correlation_id><location></location><category>inquiry</category></result></response>';
            res.setBody(XMLResInsertBody);
            
        }
        
        if (isErrorResp == 2) {
            
        } else {
            res.setStatus('Unauthorized');
            res.setStatusCode(404);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><root><response><error><detail>Required to provide Auth information</detail><message>User Not Authenticated</message></error><status>failure</status></response></root>');
            
        }
            
        }*/
        
        system.debug(' **** res = ' + res);
        system.debug(' **** res body = ' + res.getBody());
        
        return res;
        
    }
    
}