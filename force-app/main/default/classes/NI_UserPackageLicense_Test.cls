/****************************************************************************************
Name            : NI_UserPackageLicense_Test Class
Author          : Stuart Emery
Created Date    : 2/6/2015
Last Mod Date   : 5/11/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-013795
Description     : Test Class for the NI_UserPackageLicense: 
                :    
                :
******************************************************************************************/
@isTest(SeeAllData=False)
private class NI_UserPackageLicense_Test {
    
    static testMethod void myUnitTest() 
    {  
        
        //CREATE A TEST USER RECORD
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        insert u;
        
        //GET THE LICENSES FOR THE USER
        List<UserPackageLicense> lstUsrLicenses = NI_UserPackageLicense.getUserLicenses(u.Id);
        
        //GET THE LICENSES FOR THE USER
        Set<String> setUsrLicenses = NI_UserPackageLicense.strUserLicenseNameSpace(u.Id);
        
        
        //GET THE PROFILE NAME OF THE SELECTED USER  
        String strUsrProfile = NI_UserPackageLicense.strProfileName(u.Id);
        
    }  
}