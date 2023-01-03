/****************************************************************************************
Name            : AH_CronBuilder_ctlr_Base Class
Author          : Sean Harris
Created Date    : 04/01/2020
Last Mod Date   : 04/01/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-042467
Description     : Virtual class used by AH_CronBuilder_ctlr class for VF Component
				: 
****************************************************************************************/
public virtual class AH_CronBuilder_ctlr_Base 
{
    
    public AH_JobScheduler_Ctlr_Base pageController {get; 
		set 
        {
			if (value != null) 
            {
            	pageController = value;
                pageController.setComponentController(this);
            }
		}
	}
    
}