({
	caseDiagnose : function(component, event, helper) {
		
        console.log('record ID : '+component.get("v.recordId"));
        //console.log(' : '+component.get("v.recordId.Acknowledged__c"));
        var recID = component.get("v.recordId");
        
        var action = component.get("c.diagnoseCase");
        action.setParams({
            "recordId":recID
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            //console.log('State : '+state);
            if(state==='SUCCESS')
            {
                var flag = a.getReturnValue();
               
                if( flag == true)
                {
                    
                   // alert(' RETURN VALUE' + flag );
                    //Toast for success
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "message": "CASE DIAGNOSED SUCCESSFULLY.."
                    });
                    toastEvent.fire();   
                    
                }
                else
                {
                    //alert(' RETURN VALUE' + flag );
                    //Toast for success
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "Error",
                        "message": "THIS CASE HAS ALREADY BEEN DIAGNOSED ."
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