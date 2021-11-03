/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsLoginCallout_Mock Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Cross_Orgs Project -> Mock callout repsonse for DTS_CrossOrgsLoginCallout_Batch.cls
**********************************************************************************************************************************************/
 
@isTest
global class DTS_CrossOrgsLoginCallout_Mock implements HttpCalloutMock {
	
/*──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 //Mock Callout Response for Users Login History
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────*/	

    global HTTPResponse respond(HttpRequest request) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"totalSize" : 2390, "done" : false, "nextRecordsUrl" : "/services/data/v49.0/query/01g6f00009LSXI2AAP-2000", "Id" : "0Ya6f0000A7dqltCQA","UserId" : "0051W000003qE3BQAU","LoginTime" : "2020-11-06T06:00:45.000+0000", "SourceIp" : "199.15.215.245", "LoginType" : "Other Apex API", "Status" : "Success", "LoginUrl" : "login.salesforce.com", "Application" : "N/A", "CountryIso" : "US"}]');
        res.setStatusCode(200);
        return res;

    }
}