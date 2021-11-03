/************************************************************************************************
Name            : NI_Global_Acceptance_TriggerHandler  Class
Author          : Supriya Galinde
Created Date    : 3/20/2017
Last Mod Date   : 4/6/2017
Last Mod By     : Supriya Galinde
NICC Reference  : NICC-021925 
Description     : Class that handles all trigger code for the NI_Global_Acceptance_TriggerHandler Object
				: Class that tests this is called NI_GAC_TriggerHandler_Test
*************************************************************************************************/
public class NI_Global_Acceptance_TriggerHandler 
{
    //link NI_Global_Acceptance_Criterion__c name in PAC NI_Global_Acceptance_Criterion__c lookup field
    public void OnAfterInsert(List<NI_Global_Acceptance_Criterion__c> newTrigger)
    {
        List<NI_Project_Acceptance_Criterion__c> listProjectAcceptance = new List<NI_Project_Acceptance_Criterion__c>();
        Map<String,NI_Project_Acceptance_Criterion__c> MapPAC = new Map<String,NI_Project_Acceptance_Criterion__c> ();
        Set<String> setGACName = new Set<String>();
        List<NI_Global_Acceptance_Criterion__c> lstGAC = new List<NI_Global_Acceptance_Criterion__c>();
        
        
        for(NI_Global_Acceptance_Criterion__c objGlobal : newTrigger)
        {
            setGACName.add(objGlobal.Name);
        }
        
        for(NI_Project_Acceptance_Criterion__c objProject : [Select id, name,Name__c,NI_Global_Acceptance_Criterion__c  from NI_Project_Acceptance_Criterion__c where Name__c IN : setGACName])
        {
            MapPAC.put(objProject.Name__c,objProject);
        }
        
        
        for(NI_Global_Acceptance_Criterion__c objGlobal : newTrigger)
        {
            system.debug('in for2');
            //if objGlobal.Name then assign to objProject.NI_Global_Acceptance_Criterion__c field
            if(MapPAC.containsKey(objGlobal.Name))
            {
                system.debug('in if');
                NI_Project_Acceptance_Criterion__c objProject = MapPAC.get(objGlobal.Name);
                objProject.NI_Global_Acceptance_Criterion__c = objGlobal.id;
                listProjectAcceptance.add(objProject);
                system.debug('listProjectAcceptance'+listProjectAcceptance);
            }  
        }
        if(listProjectAcceptance.size() > 0){
            //update PAC
            update listProjectAcceptance;
        } 
    }
}