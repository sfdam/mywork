({
    doInit : function(component, event, handler) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's Unique Name.
        var inputVariables = [{
            name: "AccountId",
            type: "String",
            value: component.get("v.accountId")
        }];
        console.log(JSON.parse(JSON.stringify(inputVariables)));
        flow.startFlow("Crea_Opportunit", inputVariables);
    },

    statusChange : function(component, event, helper) {
        if (event.getParam('status') === "ERROR") {
            var output = event.getParams();   
            console.log(JSON.parse(JSON.stringify(output)));
        }
        if (event.getParam('status') === "FINISHED") {
            var output = event.getParam("outputVariables");
            var opportunityId = "";
            output.forEach(o => {
                if (o.name === "OpportunityId")
                    opportunityId = o.value;
            });

            var urlEvent = $A.get("e.force:navigateToComponent");
            urlEvent.setParams({
                "componentDef" : "c:AccountOpportunity_Detail",
                "componentAttributes": {
                    "opportunityId" : opportunityId
                }
            });
            urlEvent.fire();

            // var navService = component.find("navService");
            // var pageReference = {    
            //     "type": "standard__recordPage",
            //     "attributes": {
            //         "recordId": eventId,
            //         "objectApiName": "Event",
            //         "actionName": "view"
            //     }
            // };

            // navService.navigate(pageReference);
        }
    }
})