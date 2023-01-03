/****************************************************************************************
Name            : AH_BusinessSystemsLoginFlowHandler
Author          : Stuart Emery
Created Date    : 02/07/2019
Last Mod Date   : 02/07/2019
Last Mod By     : Stuart Emery
NICC Reference  : NICC-032808
Description     : Controller for the AH_BusinessSystemsAnnouncementLoginFlow VF Page.
                : 


******************************************************************************************/
public class AH_BusinessSystemsLoginFlowHandler {
    
    public PageReference FinishLoginFlowHome() {
               
        //finish the login flow and send you the default homepage
        return Auth.SessionManagement.finishLoginFlow();
    }

}