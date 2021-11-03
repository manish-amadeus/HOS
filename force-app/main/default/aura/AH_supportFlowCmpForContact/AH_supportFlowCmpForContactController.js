({
    init : function (component) {
        // Find the component whose aura:id is "contactFlowData"
        var flow = component.find("contactFlowData");
        var inputVariables = [
               {
                  name : "recordId",
                  type : "String",
                  value: component.get("v.recordId")
               }
            ];
        // In that component, start your flow. Reference the flow's API Name.
        // support Case Flow for Contact - Shashi
        // Support_Case_From_Contact_Flow_Solution

        flow.startFlow("Support_Case_Flow_for_Contact",inputVariables);
    },
})