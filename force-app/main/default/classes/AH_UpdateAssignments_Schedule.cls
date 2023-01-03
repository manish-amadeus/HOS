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
        system.debug('ENTERING Scheduler constructor method. ' + asnmtIds);
        assignmentIds.addAll(asnmtIds);
        strApexJobName = sJobName;
        system.debug('In scheduler Apex Job Name : ' + strApexJobName);
    }
    
	global void execute(SchedulableContext sc)
    {
        system.debug('ENTERING Scheduler execute method.');
        AH_UpdateAssignments_Batch batchable = new AH_UpdateAssignments_Batch(assignmentIds, strApexJobName);
        Database.executeBatch(batchable, 10); 
        system.debug('EXITING Scheduler execute method.');
    }
    
}