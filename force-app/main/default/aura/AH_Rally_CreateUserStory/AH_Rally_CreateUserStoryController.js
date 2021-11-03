({
    myAction1 : function(component, event, helper) 
    {
        var recId = component.get("v.recordId");
        recId = recId.substring(0,15);
        var artifactId = '' ;
        var msgs = component.find("msgs");
        var callAura = component.get("c.returnCaseRecs");
        callAura.setParams(
            {"caseId" : recId}
        );
        callAura.setCallback(this, function(response){
            
            var res = response.getState();
            
            if (res === "SUCCESS")
            {
                var returnedMapValues = response.getReturnValue();
                var rallyURL = returnedMapValues.getRallySM.RallyURL__c;
                var apiVersion = returnedMapValues.getRallySM.API_Version__c;
                var workspaceName = returnedMapValues.getRallySM.workspace__c;
                // ASSIGN VAULES TO VARIABLES FROM AH_Rally_LEXMethods.returnCaseRecs() METHOD
                var artifactId = returnedMapValues.getCase.Rally_Artifact_Ref__c;
                var l3StepsToProduce = returnedMapValues.getCase.L3_Steps_To_Reproduce__c;
                var l3TicketSummary  = returnedMapValues.getCase.L3_Ticket_Summary__c;
                var RallyCaseType = returnedMapValues.getCase.Rally_Case_Type__c;
				
				if (RallyCaseType == undefined || RallyCaseType == '' || RallyCaseType == null)
                {
                    msgs.throwError('ERROR', 'error', 'Please choose a valid Rally Case Type');
                    return;
                }                
                if (l3StepsToProduce == undefined && l3TicketSummary == undefined)
                {
                    msgs.throwError('ERROR', 'error', 'Please click Edit and fill mandatory fields');
                    return;
                }
                if (artifactId != undefined)
                {                    
                    //alert("User Story is already Associated");
                    //helper.closePopUpShowToast(component, event, helper , "error");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message: 'User Story is already Associated!',
                        messageTemplate: 'Record {0} created! See it {1}!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    return;
                }
                else
                {
                    if (returnedMapValues.getCase != null)
                    {
                        helper.createUserStory(recId, component, rallyURL, apiVersion, workspaceName);
                    }
                }                
            }
        });
        $A.enqueueAction(callAura);
        
    },
    showSpinner: function(component, event, helper) 
    {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component, event, helper)
    {
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
    
})