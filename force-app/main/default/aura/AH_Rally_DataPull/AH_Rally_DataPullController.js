({
    doInit : function(component, event, helper) {
        var id = component.get("v.recordId");
        component.set("v.pBar",true);
        var actionSetDate = component.get("c.callout");
        actionSetDate.setParams({
            "endPoint" : "",
            "CaseID" : id
        });
        helper.CaseUpdate(component, event, helper, actionSetDate, "helperMethod");
    }
})