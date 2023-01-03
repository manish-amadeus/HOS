/****************************************************************************************
Name            : NI_HRM_SignUpRequestTest Class 
Author          : Suzanne LeDuc
Created Date    : 
Last Mod Date   : 3/30/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Tests NI_HRM_SignUpRequest
                :  
                : 
                : 
******************************************************************************************/
@isTest (SeeAllData=true)
public class NI_HRM_SignUpRequestTest 
{    
    
    public static testMethod void testHRMOrgCreation()
    { 
    
        // CALLOUTS ARE NOT ALLOWED IN TEST CLASSES. THUS THIS SETMOCK CLASS SETS UP A FAKE CALLOUT FOR TESTING PURPOSES.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // SETUP THE CLASS
        NI_HRM_SignUpRequest controller = new NI_HRM_SignUpRequest();
        
        // CREATE A SIGNUP REQUEST
        string signupId = controller.CreateSignUpRequest('0TTi0000003UUzM', 'sleduc@newmarketinc.com', 'SuzanneLeDuc24@newmarketinc.com', 'US', 'Newmarket', 'LeDuc');
        
        // WITH THE RESULT OF THE SIGNUP REQUEST FIND THE ORGID
        string response = controller.GetSignUpRequestOrgId( signupId );        
        
        // CREATE A SIGNUPREQUESTRESPONSE
        NI_HRM_SignUpRequest.SignupRequestResponse responseClass = new NI_HRM_SignUPRequest.SignupRequestResponse();
        responseClass.Company = 'Test';
        responseClass.Country = 'Test';
        responseClass.CreatedBy = 'Test';
        responseClass.CreatedById = 'Test';
        responseClass.CreatedDate = date.Today();
        responseClass.CreatedOrgId = 'Test';
        responseClass.ErrorCode = 'Test';
        responseClass.FirstName = 'Test';
        responseClass.IsDeleted = false;
        responseClass.LastModifiedBy = 'Test';
        responseClass.LastModifiedDate = date.today();
        responseClass.LastName = 'Test';
        responseClass.Name = 'Test';
        responseClass.Owner = 'Test';
        responseClass.OwnerId = 'Test';
        responseClass.ProcessInstances = 'Test';
        responseClass.ProcessSteps = 'Test';
        responseClass.SignupEmail = 'Test';
        responseClass.Status = 'Test';
        responseClass.SystemModStamp = 'Test';
        responseClass.TemplateDescription = 'Test';
        responseClass.TemplateId = 'Test';
        responseClass.TrialDays = 30;
        responseClass.TrialSourceOrgId = 'Test';
        responseClass.UserName = 'Test';        
        
        // CREATE A CREATERESPONSE
        NI_HRM_SignUpRequest.OrgCreateResponse createResponse = new NI_HRM_SignUpRequest.OrgCreateResponse(); 
        createResponse.Id = 'TEST';
        createResponse.Success = true;
        List<String> errors = new List<String>();
        errors.add('test');
        createResponse.Errors = errors;        
        
    }
    
    // THIS CLASS SETS UP THE CUSTOM SETTINGS THAT ARE NEEDED FOR THE TEST
    public static void CreateCustomSettings()
    {
        
        NI_HRM_SignUp_Request_Settings__c hrmSettings;
        hrmSettings = NI_HRM_SignUp_Request_Settings__c.getValues('HRMSignUpSettings');
        
        if (hrmSettings == null)
        {
            String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            system.debug('baseURL : '+baseURL);
            
            hrmSettings = new NI_HRM_SignUp_Request_Settings__c();
            hrmSettings.Name = 'HRMSignUpSettings';
            hrmSettings.Org_Details_Record_Type__c = 'LOD Support Admin';
            hrmSettings.SignUp_Request_Case_Owner__c = 'Q-Subscription Management';
            hrmSettings.SignUp_Request_Email__c = 'sleduc@newmarketinc.com';
            hrmSettings.SignUp_Request_Get_URL__c = '/services/data/v27.0/sobjects/SignupRequest/Id/';
            hrmSettings.SignUp_Request_URL__c = '/services/data/v27.0/sobjects/SignupRequest/';
            //hrmSettings.TSO_Auth_Endpoint__c = 'https://na15.salesforce.com/services/oauth2/token';
            hrmSettings.TSO_Auth_Endpoint__c = baseURL + '/services/oauth2/token';
            hrmSettings.TSO_ClientId__c = '3MVG9A2kN3Bn17hvDn2BxxKxE65ay9FYQN6yXlry_Lt_Us2_bg8DS.VdNEPBXrrOAfGHv7tIPkkb0hZ4C.EpB';
            hrmSettings.TSO_Client_Secret__c = '4548215696913861118';
            hrmSettings.TSO_Password__c = '0llieRocks!AUnWGPWdQ7mgFV1uOx1uX5gn';
            //hrmSettings.TSO_Server__c = 'https://na15.salesforce.com';
            hrmSettings.TSO_Server__c = baseURL;
            hrmSettings.TSO_User_Name__c = 'sleduc@trialforcemanagement.org';
            
            Database.insert(hrmSettings);
            
        }
        
    }
    
}