({
	doInit : function(component, event, helper) {
        helper.configureSelectedProducts(component);
	},

	collapse : function(component, event, helper) {
		component.set("v.IsCollapsed", !component.get("v.IsCollapsed"));		
	},

	collapse2 : function(component, event, helper) {
		component.set("v.IsCollapsed2", !component.get("v.IsCollapsed2"));		
	},

	collapse3 : function(component, event, helper) {
		component.set("v.IsCollapsed3", !component.get("v.IsCollapsed3"));		
	},

	collapse4 : function(component, event, helper) {
		component.set("v.IsCollapsed4", !component.get("v.IsCollapsed4"));		
	}
})