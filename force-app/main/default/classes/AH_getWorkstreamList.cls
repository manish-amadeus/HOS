/*************************************************************************************************
Name            : AH_getWorkstreamList Class
Author          : Shashikant Nikam
Created Date    : 10/05/2020
Last Mod Date   : 12/19/2020 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-047197
Description     : Class to handle the check box group values passed from Lightning flow
                : Referenced in the "Create Internal Project AH Project Backlog Record" flow
*************************************************************************************************/

global class AH_getWorkstreamList {
    
    @InvocableMethod
    public static List<flowOutputvalues> handleWorkStreamsData(List<flowInputvalues> flowinput){
        
        system.debug('parameter check –> '+flowinput[0].workstreamsImpactedChkboxGroup);
        system.debug('parameter check –> '+flowinput[0].TechworkstreamsImpactedChkboxGroup);
        
        // SPLIT INPUT IMPACTED WORKSTREAM ID STRING 
        List<String> workstreamsImpactedList = new List<String>();
        if(flowinput[0].workstreamsImpactedChkboxGroup != NULL && flowinput[0].workstreamsImpactedChkboxGroup != '')
        {
            workstreamsImpactedList = flowinput[0].workstreamsImpactedChkboxGroup.split('; ');
        }
        system.debug('workstreamsImpactedList : '+workstreamsImpactedList);
        
        // SPLIT INPUT TECH IMPACTED WORKSTREAM ID STRING
        List<String> TechworkstreamsImpactedList = new List<String>();
        if(flowinput[0].TechworkstreamsImpactedChkboxGroup != NULL && flowinput[0].TechworkstreamsImpactedChkboxGroup != '')
        {
            TechworkstreamsImpactedList = flowinput[0].TechworkstreamsImpactedChkboxGroup.split('; ');
        }
        system.debug('TechworkstreamsImpactedList : '+TechworkstreamsImpactedList);

		// COMBINE BOTH LISTS        
        workstreamsImpactedList.addAll(TechworkstreamsImpactedList);

        // CREATE OUTPUT LIST TO SEND TO FLOW
        List<flowOutputvalues> outputList = new List<flowOutputvalues>();
        flowOutputvalues outputVar = new flowOutputvalues();
        outputVar.outputBusinessWorkstreams  = workstreamsImpactedList;
        outputList.add(outputVar);
        
        system.debug('outputList –> '+outputList);
        
        return outputList;
    }
    
    // WRAPPER CLASS TO HOLD INPUT VALUES FROM LIGHTNING FLOW TO APEX
    public class flowInputvalues{
        
        @invocablevariable
        public String workstreamsImpactedChkboxGroup;
        
        @invocablevariable
        public string TechworkstreamsImpactedChkboxGroup;
    }
    
    // WRAPPER CLASS TO HOLD OUTPUT VALUES TO BE SENT TO LIGHTNING FLOW FROM APEX
    public class flowOutputvalues{
        
        @invocablevariable
        public List<string> outputBusinessWorkstreams; 

    }
    
}