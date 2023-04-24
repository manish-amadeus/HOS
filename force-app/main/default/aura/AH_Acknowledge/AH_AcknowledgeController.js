({
	acknowledgedCase : function(component, event, helper) {
		
        console.log('record ID : '+component.get("v.recordId"));
        var recID = component.get("v.recordId");
        
        var action = component.get("c.acknowledgeCase");
        action.setParams({
            "recordId":recID
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state==='SUCCESS')
            {
                var flag = a.getReturnValue();
               
                if( flag == true)
                {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "message": "The case has been acknowledged successfully."
                    });
                    toastEvent.fire();                    
                }
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "Error",
                        "message": "This case has already been acknowledged."
                    });
                    toastEvent.fire();    
                }
            }
           
        });
        $A.enqueueAction(action);
	},
     redirectToCaserec: function(component, event, helper){
        
         var recId = component.get('v.recordId');
         var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
                    "url": "/" + recId
         });
         urlEvent.fire();
         
          var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
        $A.get('e.force:refreshView').fire();
        
     }
})