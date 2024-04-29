({
	initialize : function(component, event, helper) {
		var actionToCallForData = '';
		switch(component.get('v.WGC_opportunity_CE_type')) {
			case 'In Bonis':
			  actionToCallForData = 'c.getOpportunityInBonis';
			  break;
			case 'Procedurali':
			default:
			  actionToCallForData = 'c.getOpportunityProcedurali';
		}
		
		var action = component.get(actionToCallForData);
		action.setCallback(this, response =>{
			if(response.getState() == "SUCCESS"){
				component.set("v.counter", response.getReturnValue());
			}
			else{
				console.log('@@@ errore ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	},

	getCurrentDashboard: function (component,event){
		var action = component.get('c.getDashboard');
		action.setCallback(this, response =>{
			if(response.getState() == "SUCCESS"){
				var dashboardId = response.getReturnValue();
				var urlEvent = $A.get("e.force:navigateToURL");
				urlEvent.setParams({
					"url": "/"+dashboardId
				});
				urlEvent.fire()
			}
			else{
				console.log('@@@ errore ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	}
})