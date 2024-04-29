({
	doInit : function(component, event, helper) {
		helper.getPrevisioneAvvioRapporto(component, event, helper);
	},

	filter : function(component, event, helper){
		helper.getFilteredData(component, event, helper, event.getParams());
	},

	navigateToReport : function(component, event, helper){
		var navigator = component.find('navService');

		var pg = {
			type: "standard__objectPage",
			attributes: {
				objectApiName: "Task",
				actionName: "list"
			},
			state: {
				filterName: component.get("v.linkReport")
			}
		};

		navigator.navigate(pg);
	},
})