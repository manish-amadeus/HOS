/************************************************************************************************
Name            : MetadataServiceTest Class
Author          : Shashikant Nikam 
Created Date    : 03/26/2018
Last Mod By     : Shashikant Nikam
Last Mod Date   : 04/06/2018
NICC Reference  : NICC-026755
Description     : Test class for MetadataService class.
                : UPDATED 05/07/2019 PER NICC-034473
                : 
*************************************************************************************************/
@isTest
public class MetadataServiceTest{

    private class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			if(request instanceof MetadataService.readMetadata_element)
				response.put('response_x', new MetadataService.readInstalledPackageResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
			else if(request instanceof MetadataService.listMetadata_element)
				response.put('response_x', new MetadataService.listMetadataResponse_element());
            
			return;
		}
	}
    
    @IsTest
	private static void coverGeneratedCodeCRUDOperations()
	{	
    	// Null Web Service mock implementation
        // System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations     
        Test.startTest();    
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        Test.stopTest();
	}
    
    @IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {    	
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations    
        Test.startTest();     
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.listMetadata(null, null);
        metaDataPort.readMetadata(null, null);
        /*
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.describeMetadata(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.updateMetadata(null);
        metaDataPort.renameMetadata(null, null, null);
        metaDataPort.cancelDeploy(null);
		*/
        Test.stopTest();
    }
    
    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations     
        Test.startTest();    
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        //metaDataPort.deleteMetadata(null, null);
        //metaDataPort.upsertMetadata(null);
        metaDataPort.createMetadata(null);
        //metaDataPort.deployRecentValidation(null);
        //metaDataPort.describeValueType(null);
        //metaDataPort.checkRetrieveStatus(null, null);
        Test.stopTest();
    }
    
    @IsTest
    private static void coverGeneratedCodeTypes()
    {    	       
        // Reference types
        Test.startTest();
        new MetadataService();
        new MetadataService.SessionHeader_element();
        new MetadataService.DebuggingInfo_element();
        new MetadataService.readMetadata_element();
        new MetadataService.PackageTypeMembers();
        new MetadataService.ProfileObjectPermissions();
        new MetadataService.Package_x();
        new MetadataService.ReadInstalledPackageResult();
        new MetadataService.readInstalledPackageResponse_element();
        new MetadataService.ReadInstalledPackageResult().getRecords();
        new MetadataService.readInstalledPackageResponse_element().getResult();
        new MetadataService.InstalledPackage();
        
        //ADDED ON04/22/2019
        new MetadataService.createMetadataResponse_element();
        new MetadataService.createMetadata_element();
        new MetadataService.SaveResult();
        new MetadataService.Error();
        new MetadataService.ReadRemoteSiteSettingResult();
        new MetadataService.readRemoteSiteSettingResponse_element();
        new MetadataService.RemoteSiteSetting();
        new MetadataService.listMetadata_element();
        new MetadataService.ListMetadataQuery();
        new MetadataService.listMetadataResponse_element();
        new MetadataService.FileProperties();
        new MetadataService.SaveResult();
        new MetadataService.FileProperties();
        
        Test.stopTest();
    }
}