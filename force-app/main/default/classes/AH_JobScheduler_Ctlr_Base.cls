/****************************************************************************************
Name            : AH_JobScheduler_Ctlr_Base Class
Author          : Sean Harris
Created Date    : 04/01/2020
Last Mod Date   : 04/01/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-042467
Description     : Virtual class used by AH_JobScheduler_Ctlr class for VF Controller
				: 
****************************************************************************************/
public virtual class AH_JobScheduler_Ctlr_Base 
{

    private AH_CronBuilder_ctlr_Base myComponentController;
    
    public AH_JobScheduler_Ctlr_Base getThis() 
    {
        return this;
    }  
    
    public virtual AH_CronBuilder_ctlr_Base getMyComponentController() 
    {
        return myComponentController;
    }
    
    public virtual void setComponentController(AH_CronBuilder_ctlr_Base compController) 
    {
        myComponentController = compController;
    }

}