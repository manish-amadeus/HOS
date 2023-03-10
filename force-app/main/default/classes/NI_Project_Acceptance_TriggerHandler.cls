/************************************************************************************************
Name            : NI_Project_Acceptance_TriggerHandler  Class
Author          : Supriya Galinde
Created Date    : 3/20/2017
Last Mod Date   : 4/6/2017
Last Mod By     : Supriya Galinde
NICC Reference  : NICC-021925 
Description     : Class that handles all trigger code for the NI_Project_Acceptance_TriggerHandler Object
				: Class that tests this is called NI_PAC_TriggerHandler_Test
*************************************************************************************************/
public class NI_Project_Acceptance_TriggerHandler 
{
    public void OnAfterInsert(List<NI_Project_Acceptance_Criterion__c> newTrigger)
    {
        system.debug('afterInsert');
        
        List<NI_Global_Acceptance_Criterion__c> lstGAC = new List<NI_Global_Acceptance_Criterion__c>();
        set<Id> setIds = new set<Id>();
        
        for(NI_Project_Acceptance_Criterion__c objProject : newTrigger)
        {
            if(objProject.NI_Global_Acceptance_Criterion__c != null){
                setIds.add(objProject.NI_Global_Acceptance_Criterion__c); 
            }
        }
        
        Map<Id,NI_Global_Acceptance_Criterion__c> MapGlobal = new Map<Id,NI_Global_Acceptance_Criterion__c>();   
        
        if(setIds.size() > 0)
        {
            for(NI_Global_Acceptance_Criterion__c objGlobal : [SELECT Id,Name,Applicable_Object__c,Given__c,when__c,Then__c FROM NI_Global_Acceptance_Criterion__c WHERE ID IN:setIds ])
            {
                MapGlobal.put(objGlobal.Id,objGlobal);
            }
        }
        
        for(NI_Project_Acceptance_Criterion__c objProject : newTrigger){
            system.debug('in for gac'+ objProject );
            
            //if NI_Global_Acceptance_Criterion__c lookup is equal to null then create new GAC with PAC fields.
            if(objProject.NI_Global_Acceptance_Criterion__c == null)
            {
                NI_Global_Acceptance_Criterion__c objGAC = new NI_Global_Acceptance_Criterion__c();
                // do mapping
                objGAC.Name = objProject.Name__c;
                objGAC.Given__c = objProject.Given__c;
                objGAC.When__c = objProject.When__c;
                objGAC.Then__c = objProject.Then__c;
                objGAC.Applicable_Object__c = objProject.Applicable_Object__c;
                //objProject.NI_Global_Acceptance_Criterion__c = objGAC.Name;
                
                lstGAC.add(objGAC);
                system.debug('lstGAC' + lstGAC);
            }
            
            //GAC is linked to PAC and we update existing GAC fields with newly ctreated PAC fields.
            else
            {
                if(MapGlobal.containsKey(objProject.NI_Global_Acceptance_Criterion__c))
                {
                    NI_Global_Acceptance_Criterion__c objGAC2 =  MapGlobal.get(objProject.NI_Global_Acceptance_Criterion__c);
                    //if(objGAC2.Name == objProject.Name__c){
                    objGAC2.Given__c = objProject.Given__c ;
                    objGAC2.When__c = objProject.When__c ;
                    objGAC2.Then__c = objProject.Then__c ;
                    objGAC2.Applicable_Object__c = objProject.Applicable_Object__c;
                    //update objGlobal;
                    lstGAC.add(objGAC2);
                    //}
                    /*else{
                    objProject.NI_Global_Acceptance_Criterion__c.addError('Name field must be same on Global Acceptance Criterion.');
                    }*/
                }
                
            }
        }
        system.debug('lstGAC-->' + lstGAC);
        
        if(lstGAC.size()>0){
            //Insert a new GAC on creation of PAC and update the fields of PAC in GAC.
            upsert lstGAC;
        }    
    }
}