/****************************************************************************************
Name            : AH_UpdateAssignments_Schedule Class
Author          : Shashikant Nikam
Created Date    : 06/15/2020
Last Mod Date   : 08/11/2020
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Scheduler class calls "AH_UpdateAssignments_Batch" to update assignments only when Assignment inserted 
				:
                :
******************************************************************************************/
global class AH_UpdateAssignments_Schedule implements Schedulable 
{
    
    Set<Id> assignmentIds = new Set<Id>();
    String strApexJobName = '';
    
    public AH_UpdateAssignments_Schedule(Set<Id> asnmtIds, String sJobName)
    {
        assignmentIds.addAll(asnmtIds);
        strApexJobName = sJobName;
    }
    
	global void execute(SchedulableContext sc)
    {
        AH_UpdateAssignments_Batch batchable = new AH_UpdateAssignments_Batch(assignmentIds, strApexJobName);
        Database.executeBatch(batchable, 10); 
    }
    
}