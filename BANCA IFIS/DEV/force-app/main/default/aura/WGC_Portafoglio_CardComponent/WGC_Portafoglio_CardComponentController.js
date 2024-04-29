({
	doInit : function(component, event, helper) { 

	},
    
    navigateToMyComponent : function(component, event, helper) {
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:BaseClienti_DetailComponent",
            componentAttributes: {

            }
        });
        evt.fire();
    },
})