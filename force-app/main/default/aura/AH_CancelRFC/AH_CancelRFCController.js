({
     
	cancelRFC : function(component, event) 
    {
        console.log('record ID : '+component.get("v.recordId"));
        
        var recID = component.get("v.recordId");
        
        var action = component.get("c.updateRecord");
        action.setParams({
            "recordId":recID
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log('State : '+state);
            if(state==='SUCCESS')
            {
                //Toast for success
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
                dismissActionPanel.fire(); 
                $A.get('e.force:refreshView').fire();
                 
            }
            else
            {
                // toast with error message - dismissible
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "Error",
                    "message": "Error while cancelling RFC.",
                    "mode": "dismissible"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
	},
    
    cancelBtn : function(component, event, helper) 
    { 
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
    }
})