/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsLicenseCallout_Mock Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Cross_Orgs Project -> Mock callout repsonse for DTS_CrossOrgsLicenseCallout_Batch.cls
**********************************************************************************************************************************************/
 
@isTest
global class DTS_CrossOrgsLicenseCallout_Mock implements HttpCalloutMock {
	
/*──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 //Mock Callout Response (Licenses, Entitlements)
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────*/	

    global HTTPResponse respond(HttpRequest request) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"Id":"0UT0d0000004CSTGA2","MasterLabel":"API Request Limit per Month", "ResourceGroupKey": "(tenant)", "StartDate" : "2019-12-13", "EndDate" : "2019-12-23","Frequency" :"Monthly", "CurrentAmountAllowed" : 1000.20,"AmountUsed" : 500.0, "UsageDate" :"2019-10-20T23:59:59.000+0000","Status":"Active","TotalLicenses":500,"UsedLicenses":200}]');
        res.setStatusCode(200);
        return res;

    }
}