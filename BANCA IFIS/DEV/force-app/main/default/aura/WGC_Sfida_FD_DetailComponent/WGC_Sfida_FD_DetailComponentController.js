({
	doInit : function(component, event, helper) {
		helper.initFilter(component, event, helper);
		helper.initialize(component, event, helper);
		helper.initializeTable(component, event, helper);
		helper.initializeTableData(component, event, helper);
	},

	otherDoInit : function(component, event, helper){
		helper.initialize(component, event, helper);
	},

	navigateToHome : function(component, event, helper){
		var navigator = component.find('navService');

		var pg = {    
			"type": "standard__namedPage",
			"attributes": {
				"pageName": "home"    
			}
		};

		navigator.navigate(pg);
	},

	navigateToReport : function(component, event, helper){
		var navigator = component.find('navService');

		var pg = {    
			"type": "standard__webPage",
			"attributes": {
				"url": component.get("v.dashboardId")
			}
		};

		navigator.navigate(pg);
	},
})