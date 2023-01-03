({
    cloneRFC : function(component, event, helper) 
    {
		console.log('record ID : '+component.get("v.recordId"));
        
        var recID = component.get("v.recordId");
        
        var action = component.get("c.cloneWithArtifacts");
        action.setParams({
            "recordId":recID
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log('State : '+state);
            if(state==='SUCCESS')
            {
                var newId = a.getReturnValue();
                console.log('Return value : '+newId);
                
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": newId
                });
                editRecordEvent.fire();
                component.set('v.newRecId',newId);
                
            }
            else
            {
                // toast with error message - dismissible
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "Error",
                    "message": "Error while cloning RFC.",
                    "mode": "dismissible" 
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    redirectToNewRec: function(component, event, helper){
        
        var recId=component.get('v.newRecId');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+recId
        });
        
        urlEvent.fire();
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
        $A.get('e.force:refreshView').fire();
    },
    
    cancelBtn : function(component, event, helper) 
    {
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
        $A.get('e.force:refreshView').fire();
	}
})