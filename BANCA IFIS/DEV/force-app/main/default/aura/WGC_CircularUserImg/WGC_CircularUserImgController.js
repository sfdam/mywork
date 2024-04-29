({
	doInit : function(component, event, helper) {
		var action = component.get("c.getUser");
        action.setParams({
            userId : component.get("v.userId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                console.log(response.getReturnValue());
                component.set("v.user", response.getReturnValue());
            } else {
                console.log('There was an error');
            }
        });
        $A.enqueueAction(action);
	}
})