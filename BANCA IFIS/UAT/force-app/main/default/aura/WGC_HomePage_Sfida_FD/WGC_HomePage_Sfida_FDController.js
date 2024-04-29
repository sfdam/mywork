({
	doInit : function(component, event, helper) {
		helper.initialize(component, event, helper);
	},

	navigateToMyComponent : function(component, event, helper){
		var navigator = component.find('navService');

		var pg = {    
            "type": "standard__component",
            "attributes": {
                "componentName": "c__WGC_Sfida_FD_DetailComponent",
			},
			"state":{
				"c__isDirezioneFD": component.get("v.isDirezioneFD"),
				"c__dashboardId" : component.get("v.dashboardId")
			}
		};

		navigator.navigate(pg);
	},
})