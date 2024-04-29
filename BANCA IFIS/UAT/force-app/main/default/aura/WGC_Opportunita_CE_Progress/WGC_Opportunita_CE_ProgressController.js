({
	doInit : function(component, event, helper) {
		helper.initialize(component, event, helper);
	},
	
	navigateToMyComponent: function (component, event, helper) {
		helper.getCurrentDashboard(component, event);
    }
})