/************************************************************************************************
Name            : DetailUpdateButtonController  Class
Author          : Supriya Galinde
Created Date    : 3/20/2017
Last Mod Date   : 4/6/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : Class that handles code for the UpdateGlobal onclick javascript Button.
:
*************************************************************************************************/
global class DetailUpdateButtonController 
{
    global static NI_Project_Acceptance_Criterion__c objProject {get;set;}
    global static NI_Global_Acceptance_Criterion__c objGlobal {get;set;}
    global static string Message {get;set;}
    
    webservice static String updateGAC(Id ProjectId)
    {
        
        system.debug('in updateGAC');
        List<NI_Global_Acceptance_Criterion__c> gacList = new List<NI_Global_Acceptance_Criterion__c>();
        objGlobal = new NI_Global_Acceptance_Criterion__c();
        objProject =  [SELECT id, Name__c, Given__c, When__c,Then__c, NI_Global_Acceptance_Criterion__c, Applicable_Object__c
                       FROM NI_Project_Acceptance_Criterion__c WHERE id =: ProjectId];
        
        //get NI_Global_Acceptance_Criterion__c from lookup field of PAC in GAC id.
        if(objProject.NI_Global_Acceptance_Criterion__c != null)
        {
            system.debug('in if1');
            objGlobal = [SELECT id,Name,Given__c,When__c,Then__c, Applicable_Object__c FROM NI_Global_Acceptance_Criterion__c 
                         where Id=: objProject.NI_Global_Acceptance_Criterion__c];
            system.debug('objGlobal'+objGlobal);
        }
        else
        {
            system.debug('in else');
            message = 'No GAC to update.';
        }
        
        system.debug('objGlobal');
        //message = 'GAC have same Name, Given, When, Then';
        
        if(objGlobal.id != null)
        {
            //if PAC Name__c is equal to GAC Name and when we clik on update Global button then update the GAC fields to match the fields in PAC.
            if(objProject.Name__c == objGlobal.Name)
            {
                system.debug('in if2');
                if((objProject.Name__c == objGlobal.Name) && 
                   (objProject.Given__c != objGlobal.Given__c ||
                    objProject.When__c != objGlobal.When__c ||
                    objProject.Then__c != objGlobal.Then__c || 
                   	objProject.Applicable_Object__c != objGlobal.Applicable_Object__c))
                {
                    objGlobal.Given__c = objProject.Given__c ;
                    objGlobal.When__c = objProject.When__c ;
                    objGlobal.Then__c = objProject.Then__c ;
                    objGlobal.Applicable_Object__c = objProject.Applicable_Object__c;
                    //update objGlobal;
                    gacList.add(objGlobal);
                    system.debug('objGlobal' + objGlobal);
                    message = 'GAC updated succesfully';
                }
                else
                {
                     message = 'GAC have same Name, Given, When, Then';
                }
            }
            //if PAC Name__c is not equal to GAC Name and we try to update the name__c field on PAC then display an error message
            else
            {
                message = 'You cannot update the Name on an existing Global Acceptance Criterion record';
            }
            
        }
        if(!gacList.isEmpty()){
            update gacList;
            system.debug('gacList'+gacList);
        }

            return message;
        
        //PageReference orderPage = new PageReference('/force_OrderDetail?id=' + NI_Global_Acceptance_Criterion__c.id);
        //orderPage.setRedirect(true);
        //return orderPage;
    }
}