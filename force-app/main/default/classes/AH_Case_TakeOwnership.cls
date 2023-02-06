/****************************************************************************************
Name            : AH_Case_TakeOwnership 
Author          : Sean Harris
Created Date    : 11/02/2022
Last Mod Date   : 11/02/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for LEX Component on Case Feed quick action that changes 
                : Case record owner to the user who clicks it.
				: 
****************************************************************************************/
public class AH_Case_TakeOwnership 
{
    @auraEnabled
    public static List<Case> getCases(string objId) 
    {
        List<Case> lstCase = [SELECT Id, OwnerId FROM Case WHERE Id =: objId LIMIT 1]; 
        lstCase[0].OwnerId = UserInfo.getUserId();
        update lstCase;
        return lstCase; 
    } 
}