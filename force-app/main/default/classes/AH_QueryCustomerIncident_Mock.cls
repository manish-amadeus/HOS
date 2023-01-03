/****************************************************************************************
Name            : AH_QueryCustomerIncident_Mock Class 
Author          : Sean Harris
Created Date    : 09/13/2019
Last Mod Date   : 09/13/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : This is Mock Class used in AH_QueryCustomerIncident_Test class 
                :  
                : 
******************************************************************************************/
@isTest
public class AH_QueryCustomerIncident_Mock implements HttpCalloutMock 
{
    
    protected Integer iCode;
    protected String strStatus;
    protected String strBody;

    public AH_QueryCustomerIncident_Mock(Integer iCode, String strStatus, String strBody) 
    {
        this.iCode = iCode;
        this.strStatus = strStatus;
        this.strBody = strBody;
    }    
    
    public HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(iCode);
        resp.setStatus(strStatus);
        resp.setBody(strBody);
        return resp;
    }

}