({
	doInit : function(component, event, helper) {
		// helper.setupSezioniEParametri(component);
	},

	reloadParameters : function(component, event, helper) {
		// helper.setupSezioniEParametri(component);
	},

	resetParameters : function(component, event, helper) {
		if (event.getParam("action") == "filter") {
			console.log("resetParameters OK >> " + event.getParam("paramsJSON"));
			console.log(JSON.parse(event.getParam("paramsJSON")));
			component.set("v.parametri", JSON.parse(event.getParam("paramsJSON")));
		}
	},

	selectParameter : function(component, event, helper) {
		var paramCode = event.target.getAttribute("data-param");
		var parametriESezioni = component.get("v.parametri");
		var param = null;
		
		parametriESezioni.some(ps => {
			ps.parameters.some(p => {
				if (p.codice == paramCode)
					param = p;
				return param !== null;
			});
			return param !== null;
		});
		
		var appEvent = $A.get("e.c:WGC_Parametri_Filter_Dashboard_Event");
		appEvent.setParams({ "paramsJSON" : JSON.stringify( param ) , "action" : "select" });
		appEvent.fire();
	}
})