({
	doInit : function(component, event, helper) {
		helper.initialize(component, event, helper);
	},

	redirectReport: function(component, event, helper){
		helper.redirectReport(component, event, helper);
	},
	
	navigateToMyComponent: function (component, event, helper) {
		var navService = component.find("navService");
        var pageReference = {    
			"type": "standard__recordPage",
			"attributes": {
				"recordId": component.get("v.reportDettagli"),
				"objectApiName": "Report",
				"actionName": "view"
			}
	 	}

		navService.generateUrl(pageReference).then($A.getCallback(function(url) {
			window.open(url, '_blank');
		}));
		// navService.navigate(pageReference);
		
        // var navService = component.find("navService");
        // var pageReference = {    
		// 	"type": "standard__objectPage",
		// 	"attributes": {
		// 		"objectApiName": "Opportunity",
		// 		"actionName": "list"
		// 	},
		// 	"state": {
		// 		"filterName": "Recent"
		//   	}
		// }

        // navService.navigate(pageReference);
    },
})