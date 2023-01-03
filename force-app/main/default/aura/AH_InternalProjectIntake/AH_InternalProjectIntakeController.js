({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Create_Internal_Project_AH_Project_Backlog_Record");
    },
    
handleStatusChange : function (component, event) {

        if(event.getParam("status") === "FINISHED") {
        
            var outputVariables = event.getParam("outputVariables");

            // outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                var outputVar = outputVariables[i];
                if(outputVar.name === "vRecordWorkstreamForInsert") {

                    window.open('/apex/AH_ProjectIntakeFlowEndMessage?id='+outputVar.value.NI_Project_Backlog__c, "_self");
                }
                
                if(outputVar.name === "vProjectId") {

                    window.open('/apex/AH_ProjectIntakeFlowEndMessage?id='+outputVar.value, "_self");
                }
            }
        }
    }
})