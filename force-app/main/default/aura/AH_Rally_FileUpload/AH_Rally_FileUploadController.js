({
    init : function(component, event, helper) {
        var path = $A.get("$Resource.LRFileExtensions");
        var req = new XMLHttpRequest();
        req.open("GET", path);
        req.addEventListener("load", $A.getCallback(function() {
            component.set("v.accept", req.response);
            console.log(req.response);
        }));
        req.send(null);
    },
    handleUploadFinished: function (cmp, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        var appEvent = $A.get("e.c:AH_Rally_Event");
        appEvent.setParams({
            "message" : "An application event fired me. " +
            "It all happened so fast. Now, I'm everywhere!" });
        appEvent.fire();
        
        console.log(uploadedFiles);
    }
})