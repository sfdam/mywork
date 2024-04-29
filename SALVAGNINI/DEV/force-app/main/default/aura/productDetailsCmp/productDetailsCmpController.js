({
    doInit : function(component, event, helper){
        var pageReference = component.get("v.pageReference");
        if(pageReference !== undefined && pageReference !== null && pageReference.state != null){
            var recordId = pageReference.state.c__recordId; 
            component.set("v.recordId", recordId);
            var action = component.get("c.getDescriptions");
                action.setParams({ recordId : component.get("v.recordId") });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // Alert the user with the value returned 
                    // from the server
                    console.log("RESPONSE: "+ JSON.stringify(response.getReturnValue(), undefined, 2));
                    //var responseMap = new Map(JSON.parse(response.getReturnValue()));
                    //responseMap = response.getReturnValue();
                    component.set("v.descriptions", response.getReturnValue());
                    var responseMap = component.get("v.descriptions");
                    var userLanguage = responseMap['USER'][0];
                    component.set("v.selectedLanguage", userLanguage);
                    component.set("v.shortDescriptionToShow", responseMap[userLanguage][0]);
                    component.set("v.descriptionToShow", responseMap[userLanguage][1]);
                    component.set("v.imgURL", responseMap['IMG_URL'][0]);
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    handleChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        var responseMap = component.get("v.descriptions");
        component.set("v.shortDescriptionToShow", responseMap[selectedOptionValue][0]);
        component.set("v.descriptionToShow", responseMap[selectedOptionValue][1]);
    },
})