({
	myAction : function(component, event, helper) {
		
	},

	navigateToMyComponent: function (component, event, helper) {

        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__namedPage",
            "attributes": {
                "pageName": "home"
            }
        }

        navService.navigate(pageReference);
    },
})