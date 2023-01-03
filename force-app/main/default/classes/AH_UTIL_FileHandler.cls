/************************************************************************************************
Name            : AH_UTIL_FileHandler
Author          : Sean Harris
Created Date    : 05/16/2019
Last Mod Date   : 05/16/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Utility class for creating files in Content 
                : 
                : 
*************************************************************************************************/
public class AH_UTIL_FileHandler 
{

    public static Id createCSV_File(String strFileName, String strHeaders, List<String> lstValues, Id parentId, Id communityId)
    {

        Id retId = null;

        try 
        {
            String csv = strHeaders + '\n';

            for (String s : lstValues) 
            {
                List<String> row = s.split(',');
                String str = '';
                for (String r : row) 
                {   
                    str += r + ',';
                }
                csv += str + '\n';
            }

            ContentVersion cv = new ContentVersion();
            cv.title = strFileName;
            cv.versionData = Blob.valueOf(csv);
            cv.pathOnClient = '/' + strFileName + '.csv';
            if (communityId != null)
            {
                cv.NetworkId = communityId;
            }
            insert cv;

            // SET ID TO RETURN
            retId = cv.Id;
            
            if (parentId != null)
            {
                ContentVersion newCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id];
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = newCV.ContentDocumentId; 
                cdl.LinkedEntityId = parentId; 
                cdl.ShareType = 'V'; 
                //cdl.Visibility = 'AllUsers';
                insert cdl;
            }
                    
        } 
        catch (Exception ex) { system.debug(' **** Error Occurred in AH_UTIL_FileHandler.createCSV_File(): ' + ex.getMessage()); }

        return retId;

    }

}