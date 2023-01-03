/************************************************************************************************
Name            : NI_IMT_BatchUpdatePropertyTimezone Class
Author          : Damodar Raut
Created Date    : 04/20/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that does batch update of Property timezone
                : 
*************************************************************************************************/
global class NI_IMT_UpdatePropertyTimezoneScheduler implements Schedulable {
     global void execute(SchedulableContext sc) {
        // Call the batch class to be scheduled
        NI_IMT_UpdatePropertyTimezoneBatch batch = new NI_IMT_UpdatePropertyTimezoneBatch(); 
        
        //Parameters of ExecuteBatch(context,BatchSize)
        Database.executebatch(batch);
     }
  }