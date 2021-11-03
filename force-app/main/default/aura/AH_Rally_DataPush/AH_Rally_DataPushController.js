({
    doInit : function(component, event, helper) 
    {
        var id = component.get("v.recordId");
        component.set("v.pBar", true);
        var actionSetDate = component.get("c.LRReSubmit");
        actionSetDate.setParams({
            "dataID" : id
        });
        actionSetDate.setCallback(this, function(response) {
            
            var stateDate = response.getState();
            
            if (stateDate === "SUCCESS") 
            {
                if (response.getReturnValue() == "Y" || response.getReturnValue() == "X")
                {
                    component.set("v.msg", true);
                    component.set("v.pBar", false);
                    if (response.getReturnValue() == "Y")
                    {
                        component.set("v.dataLink", "Please press OK to reopen the User story to Advance Investigation state");
                    }
                    else
                    {
                        component.set("v.dataLink", "Rally State will be changed to Advance Investigation. Please press OK to confirm");
                    }
                }
                else
                {
                    var msgs = component.find("msgs");
                    msgs.throwError('ERROR', 'error', response.getReturnValue());
                    component.set("v.pBar", false);
                }
            }
            else 
            {
                var msgs = component.find("msgs");
                msgs.throwError('ERROR', 'error', 'Something went wrong, please contact to admin');
                component.set("v.pBar", false);
            }
            
        });
        $A.enqueueAction(actionSetDate);
        
    },
    handleSaveRecord : function(component, event, helper) {
        
        component.set("v.msg",false);
        var id = component.get("v.recordId");
        component.set("v.pBar",true);
        var actionSetDate = component.get("c.LRReSubmiteSendCallout");
        
        actionSetDate.setParams({
            "dataID" : id
        });
        
        actionSetDate.setCallback(this, function(response){
            var stateDate = response.getState();
            if (stateDate === "SUCCESS") 
            {
                if (response.getReturnValue() == "Refresh")
                {
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Saved",
                        "message": "Data Updated"
                    });
                    resultsToast.fire(); 
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:refreshView").fire();
                }
                else
                {
                    var msgs = component.find("msgs");
                    msgs.throwError('ERROR', 'error', response.getReturnValue());
                    component.set("v.pBar",false);
                }
            }
            else 
            {
                var msgs = component.find("msgs");
                msgs.throwError('ERROR', 'error', 'Something went wrong, please contact to admin');
                component.set("v.pBar", false);
            }
            
        });
        
        $A.enqueueAction(actionSetDate);
        
    }
    
})