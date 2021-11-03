({
    retriveRecord: function(component, event, helper) {
        var recordId = component.get("v.recordId");	
        
        var action = component.get("c.getContentDocs");
        action.setParams({                
            "recId": recordId
        });
        
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            var sd = JSON.parse(res);               
            component.set("v.listOfFiles", sd);
            helper.hideSpinner(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    sendAttachment : function(component, event, helper,docId) {
        var action = component.get("c.sendAttachment");
        var recordId = component.get("v.recordId");
        helper.showSpinner(component, event, helper);
        
        action.setParams({                
            "recId": docId,
            "caseId":recordId
        });
        
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            console.log(res);
            var splitres=res.split('|');
            if(splitres[0]=='exception'){
                var appEvent = $A.get("e.c:aeEvent");
                appEvent.setParams({                                    
                    "message" :  splitres[1],
                    "flag" : true
                });
                appEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    showSpinner:function(component, event, helper){
        var appEvent = $A.get("e.c:aeSpinner");
        appEvent.setParams({                                    
            "message" :  'Loading please wait.....',
            "flag" : true
        });
        appEvent.fire();
    },
    hideSpinner:function(component, event, helper){
        var appEvent = $A.get("e.c:aeSpinner");
        appEvent.setParams({                                    
            "message" :  'Loading please wait.....',
            "flag" : false
        });
        appEvent.fire();
    },
    handleDelete: function(component, event, helper,docId) {
        
        if(confirm('Are sure you want to delete.')){
            helper.showSpinner(component, event, helper);
            var action = component.get("c.deleteFiles");
            
            action.setParams({                
                "recId": docId
            });
            
            action.setCallback(this, function(response){
                helper.retriveRecord(component, event, helper);
            });
            $A.enqueueAction(action);
        }
    },
    handleEdit: function(component, event, helper,docId) {
        var navEvt = $A.get("e.force:editRecord");       
        navEvt.setParams({
            "recordId": docId
        });
        navEvt.fire();
        $A.get("e.force:refreshView").fire();
    },
    fileAlreadySent: function(component, event, helper) {
        var appEvent = $A.get("e.c:aeEvent");
        appEvent.setParams({                                    
            "message" :  'File already sent to rally.',
            "flag" : true
        });
        appEvent.fire();
    }
    
})