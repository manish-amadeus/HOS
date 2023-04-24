({
	doInit : function(component, event, helper) {
		
        var url = '/apex/AH_New_NI_Change_Request?bklogTaskId='+ component.get("v.recordId")+'&flagOfRt=false&rt=01260000000166yAAA';
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url,
            "isredirect": "true"
        });
        urlEvent.fire();
	}
})