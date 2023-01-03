/************************************************************************************************
Name            : WebServiceMockImpl Class
Author          : Stuart Emery
Created Date    : 02/24/2013
Last Mod Date   : 04/15/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Mock class
                : Updated for NICC-042467 4/15/2020
                : 
************************************************************************************************/
@isTest
global class WebServiceMockImpl implements WebServiceMock 
{
    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) 
    {
        
        //system.debug('request : '+request);
        
        if(request instanceof MetadataService.listMetadata_element)
        {
            system.debug('listMetadata_element request : ');
            MetadataService.listMetadataResponse_element respElement = new  MetadataService.listMetadataResponse_element();
            
            MetadataService.FileProperties p = new MetadataService.FileProperties();
            p.fullName = 'ap1111';
            p.type_x = 'RemoteSiteSetting';
            
            List<MetadataService.FileProperties> pList = new List<MetadataService.FileProperties>();
            pList.add(p);
            
            respElement.result = pList;
            
            response.put('response_x', respElement);
        }
        else if(request instanceof MetadataService.createMetadata_element)
        {
            MetadataService.createMetadataResponse_element respElement = new  MetadataService.createMetadataResponse_element();
            
            List<MetadataService.SaveResult> saveList = new List<MetadataService.SaveResult>();
            MetadataService.SaveResult s = new MetadataService.SaveResult();
            s.fullName = 'ap1111_API';
            s.success = true;
            saveList.add(s);
            
            respElement.result = saveList;
            response.put('response_x', respElement);
        }
        else if (request instanceof PartnerRemote.login_element)
        {
            PartnerRemote.loginResponse_element  respElement =  new PartnerRemote.loginResponse_element();
            
            respElement.result = new PartnerRemote.LoginResult();
            respElement.result.serverUrl = 'd/services/d';
            respElement.result.sessionId = '';
            respElement.result.userInfo = new PartnerRemote.GetUserInfoResult();
            respElement.result.userInfo.organizationId = '';
            respElement.result.userInfo.organizationName = '';
            response.put('response_x', respElement); 
        }
    }
}