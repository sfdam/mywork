({
	doInit : function(component, event, helper) {
		helper.getDatiFirstChart(component, event, helper);
		helper.getDatiSecondChart(component, event, helper);
	},

	filter : function(component, event, helper){
		helper.getFilteredData_FirstChart(component, event, helper, event.getParams());
		helper.getFilteredData_SecondChart(component, event, helper, event.getParams());
	},

	navigateToMyComponent : function(component, event, helper){
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