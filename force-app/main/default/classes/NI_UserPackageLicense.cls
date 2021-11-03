/****************************************************************************************
Name            : NI_UserPackageLicense Class
Author          : Stuart Emery
Created Date    : 2/6/2015
Last Mod Date   : 5/11/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-013795
Description     : Helper Class for the NI_JobReq_Ext: 
                :    
                :
******************************************************************************************/
public class NI_UserPackageLicense {

public Static List<UserPackageLicense> getUserLicenses(Id UserId) 
    {
        List<UserPackageLicense> lstUsrLicense = [SELECT UserId, PackageLicense.NamespacePrefix, PackageLicenseId 
                                                  FROM UserPackageLicense
                                                  WHERE UserId =: UserId];
        return lstUsrLicense;     
    }
    
public Static Set<String> strUserLicenseNameSpace(Id UserId) 
    {
        Set<String> setLicenseNameSpace = new Set<String>();
        List<UserPackageLicense> lstUsrLicense = [SELECT PackageLicense.NamespacePrefix 
                                                  FROM UserPackageLicense
                                                  WHERE UserId =: UserId];
        for(UserPackageLicense l : lstUsrLicense)
        {
          setLicenseNameSpace.add(l.PackageLicense.NamespacePrefix);     
        }
        
        return setLicenseNameSpace;     
    }
    
public Static String strProfileName(Id UserId) 
    {
        String strProfileName;
        User u = [SELECT Id, ProfileId FROM User WHERE Id =: UserId];
        Profile p = [SELECT Name FROM Profile WHERE Id =: u.ProfileId];
        strProfileName = p.Name;
                  
        return strProfileName;     
    }     
    
}