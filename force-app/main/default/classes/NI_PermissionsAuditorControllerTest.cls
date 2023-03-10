/****************************************************************************************
Name            : NI_PermissionsAuditorControllerTest Class 
Author          : Cybage
Created Date    : 6/30/2016
Last Mod Date   : 10/15/2016
Last Mod By     : Stuart Emery
NICC Reference  : NICC-018245
Description     :  This class the test class for the NI_PermissionsAuditorController class
                : 
******************************************************************************************/
@isTest
public class NI_PermissionsAuditorControllerTest{
    
    public TestMethod static void findObjectListTest(){
        List<NI_PermissionsAuditorController.SFObjects> objList = NI_PermissionsAuditorController.findObjectList();
        List<NI_PermissionsAuditorController.ProfilePermissionSetDetails> objectPermissionList = NI_PermissionsAuditorController.findObjectPermissions('Accolade__c');
        List<NI_PermissionsAuditorController.ProfilePermissionSetDetails> fieldPermissionList = NI_PermissionsAuditorController.findFieldLevelPermissions('Accolade__c', 'Comments__c', objectPermissionList);
        Map<Id, NI_PermissionsAuditorController.Permissions> permissionsMap = fieldPermissionList[0].permissionsMap;
        List<NI_PermissionsAuditorController.UserInfo> usersList = fieldPermissionList[0].userInfoList;
        List<NI_PermissionsAuditorController.UserInfo> userInfoList = NI_PermissionsAuditorController.updateUsersPermissions(permissionsMap, usersList);
    }
}