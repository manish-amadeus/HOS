({
    handleRecord: function(component, event, helper) 
    {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getCases"); 
        action.setParams({  objId : recordId  }); 
        action.setCallback(this, function(response){
            var name = response.getState();
            if (name === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": 'Owner has been changed to login user',
                    "type": "success"
                });
                toastEvent.fire();  
                 $A.get("e.force:closeQuickAction").fire();
                 $A.get("e.force:refreshView").fire();
                return;  
            }
        });
        $A.enqueueAction(action);
    }
})