({
	doInit : function(component, event, helper) {
		helper.initData(component);
		helper.reloadReferenti(component);
	},

	onChangeCrossSelling : function(component, event, helper) {
		component.set("v.showNext", false);
	},

	refreshActiveItem : function(component, event, helper) {
		helper.refreshActiveItem(component, event);
	}
})