({
	doInit : function(component, event, helper) {
		helper.initialize(component, event, helper);
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

	filter : function(component, event, helper){
		console.log('@@@ parametri ' , JSON.stringify(event.getParams()));

		if(event.getParam('isAllUser') == true){
			component.set("v.isDirezioneFD", true);
			helper.initialize(component, event, helper);
			component.set("v.isDirezioneFD", false);
		} else {
			helper.getDataFiltered(component, event, helper, event.getParams());
		}
	},
	
})