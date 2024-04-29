({
	doInit : function(component, event, helper) {
		helper.initData(component);
	},

    navigateToMyComponent: function (component, event, helper) {

        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:Bussiness_DetailComponent",
            componentAttributes: {

            }
        });
        evt.fire();
        
    },
})