({
	doInit : function(component, event, helper) {
        helper.getUserInfo(component, event);

	},
    
    navigateToMyComponent : function(component, event, helper) {
        // var navService = component.find("navService");
        // var pageReference = {
        //     type: "standard__objectPage",
        //     attributes: {
        //         objectApiName: "Opportunity",
        //         actionName: "list"
        //     },
        //     state: {
        //         filterName: "Recent"
        //     }
        // }
    
        // navService.navigate(pageReference);
        var navService = component.find("navService");
        var pageReference = {    
            "type": "standard__component",
            "attributes": {
                "componentName": "c__WGC_Opportunity_DetailComponent"    
            },    
            "state": {
                "c__idDashboard": component.get('v.idDashboard')
            }
        };

		navService.navigate(pageReference);
    },
})