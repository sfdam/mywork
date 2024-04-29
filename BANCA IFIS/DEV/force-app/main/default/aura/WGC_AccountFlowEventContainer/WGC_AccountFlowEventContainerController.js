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
        flow.startFlow("New_Event", inputVariables);
    },

    statusChange : function(component, event, helper) {
        if (event.getParam('status') === "FINISHED") {
            var output = event.getParam("outputVariables");
            var eventId = "";
            
            output.forEach(o => {
                if (o.name === "EventId")
                    eventId = o.value;
            });

            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/" + eventId
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