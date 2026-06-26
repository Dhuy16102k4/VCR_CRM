({
    doInit : function(component, event, helper) {
        var flow = component.find("flowData");
        flow.startFlow("Opportunity_Creation_Wizard");
    },
    handleStatusChange : function (component, event, helper) {
        if (event.getParam('status') === "FINISHED") {
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            if (outputVariables) {
                for(var i = 0; i < outputVariables.length; i++) {
                    outputVar = outputVariables[i];
                    if(outputVar.name === "varOpportunityId" && outputVar.value) {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": outputVar.value,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                        return;
                    }
                }
            }
            // Fallback if no varOpportunityId returned but finished
            var navEvtFallback = $A.get("e.force:navigateToObjectHome");
            navEvtFallback.setParams({
                "scope": "Opportunity"
            });
            navEvtFallback.fire();
        }
    }
})
