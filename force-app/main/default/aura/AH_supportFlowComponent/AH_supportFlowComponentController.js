({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
               {
                  name : "recordId",
                  type : "String",
                  value: component.get("v.recordId")
               }
            ];
        // In that component, start your flow. Reference the flow's API Name. Support_Case_Flow_Solution
        flow.startFlow("Support_Case_Flow_for_Account",inputVariables); 
    },
})