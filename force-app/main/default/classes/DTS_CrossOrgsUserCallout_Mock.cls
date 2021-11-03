/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsUserCallout_Mock Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Cross_Orgs Project -> Mock callout repsonse for DTS_CrossOrgsUserCallout_Batch.cls			
**********************************************************************************************************************************************/
 
@isTest
global class DTS_CrossOrgsUserCallout_Mock implements HttpCalloutMock {

    global HTTPResponse respond(HttpRequest request) {
		
/*──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 //Mock Callout Response for Users (Acitve, Inactive, Frozen)
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────*/	

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"totalSize" : 2492, "done" : false, "nextRecordsUrl" : "/services/data/v49.0/query/01g1100001E5JRyAAN-2000", "Id" : "00532000005mS19AAE", "FirstName" : "Douwe", "LastName" : "van Houte", "Name" : "Douwe van Houte", "Username" : "douwe.vanhoute@newmarketinc.com.intake", "IsActive" : false, "LastLoginDate" : "2019-04-24T07:38:44.000+0000", "Id" : "0Yw400000007AnBCAU",   "UserId" : "005400000010izAAAQ","IsFrozen" : true,"LastModifiedDate" : "2020-09-08T13:29:21.000+0000","LastModifiedById" : "005400000010PrMAAU"}]');
        res.setStatusCode(200);
        return res;

    }
}