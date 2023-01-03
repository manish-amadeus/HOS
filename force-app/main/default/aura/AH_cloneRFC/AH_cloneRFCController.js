({
	doInit : function(component, event, helper) {
        var url='/apex/AH_cloneRFC?id='+component.get("v.recordId")+'&flagOfRt=false&rt=0126000000016TJAAY';
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url,
            "isredirect": "true"
        });
        urlEvent.fire();
	}
})