({
	doInit : function(component, event, helper) {
		var action = component.get("c.getAddressInfo");
		action.setParams({
			accountId : component.get("v.recordId")
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				component.set("v.address", risposta);
			}
			else{
				console.log('@@@ error ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	}
})