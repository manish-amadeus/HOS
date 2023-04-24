({
	assignToQueue : function(component, event, helper) {
		var action = component.get("c.updateCase");
        action.setParams({"caseId": component.get("v.recordId")});
        action.setCallback(component,
        function(response) {
            var state = response.getReturnValue();
            if (state === true){
                $A.get('e.force:refreshView').fire();
                component.set("v.smsg", true);
            } else {
                 component.set("v.emsg", true);
            }
        }
        );
        $A.enqueueAction(action);
	}
})