/****************************************************************************************
Name            : AH_Rally_SendAttachmentSchedule (TC Org Name: ScheduleAttachmentToTeam)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : 
				: 
				: 
******************************************************************************************/
global class AH_Rally_SendAttachmentSchedule implements Schedulable
{
    
    global void execute(SchedulableContext sc)
    {
        AH_Rally_SendAttachmentBatch b = new AH_Rally_SendAttachmentBatch(); 
        database.executebatch(b);
    }
    
}