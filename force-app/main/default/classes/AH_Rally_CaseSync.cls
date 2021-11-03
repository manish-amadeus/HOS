/****************************************************************************************
Name            : AH_Rally_CaseSync  (TC Org Name: RallyCaseSync)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : This class is used to get the total number of Updated User stories in Rally 
				: and after get the count call the Batch to process further.
				: 
******************************************************************************************/
public class AH_Rally_CaseSync 
{
    
    public Integer totalUpdatedRecords = 0; 
    public String workspaceUrl; 
    public String countResponse; 
    
    public AH_Rally_CaseSync()
    {
        if (test.isRunningTest())
        {
            init();
        }
    }
    
    public Integer init()
    {        
        
        workspaceUrl = AH_Rally_Library.workspaceUrl();
        System.debug(' aaa workspaceUrl : ' + workspaceUrl);  
        
        //convert to GMT
        String lastUpdateDate = AH_Rally_Credentials.dateFilterValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        System.debug('*** LastUpdateDate *** '+lastUpdateDate);
        String lastUpdateEndPoint = lastUpdateDate.replace(':','%3A');        
        String queryEndPointForCount = AH_Rally_Credentials.endPoint+'/slm/webservice/'+AH_Rally_Credentials.versionNumber+'/hierarchicalrequirement.js?workspace='+workspaceUrl+'&query=(LastUpdateDate'+'%20%3E%3D%20%22'+lastUpdateEndPoint+'%22%20)';
        System.debug('Query End Pount'+queryEndPointForCount); 
        countResponse = AH_Rally_Library.sendRequestObject('GET',queryEndPointForCount,null);
        System.debug(countResponse);
        
        JSONParser recordParser = JSON.createParser(countResponse);
        while (recordParser.nextToken() != null) 
        {
            if (recordParser.getText() == 'TotalResultCount')
            {
                recordParser.nextToken();
                totalUpdatedRecords = Integer.valueOf(recordParser.getText());   //Get the record Count             
            }
        }
        
        System.debug('TotalResultCount = ' + totalUpdatedRecords);
        return totalUpdatedRecords;
        
    }
    
    public void calloutMaker()
    {
        Database.executeBatch(new AH_Rally_CaseSyncBatch(1, this.totalUpdatedRecords), 200);                
    }    
    
}