({
    throwError: function(component,event,helper) 
    {
        
        var params = event.getParam('arguments');
        
        if (params) {
            $A.createComponents([
                ["ui:message",{
                    "title" : params.title,
                    "severity" : params.severity,
                }],
                ["ui:outputText",{
                    "value" : params.msg
                }]
            ],
            function(components, status, errorMessage)
            {
            	if (status === "SUCCESS") 
                {
                	var message = components[0];
                    var outputText = components[1];
                    // set the body of the ui:message to be the ui:outputText
                    message.set("v.body", outputText);
                    var div1 = component.find("div1");
                   	// Replace div body with the dynamic component
                    div1.set("v.body", message);
                }
                else if (status === "INCOMPLETE") 
                {
                	console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") 
                {
                	console.log("Error: " + errorMessage);
                }
            });
            
        }
        
    }
    
})