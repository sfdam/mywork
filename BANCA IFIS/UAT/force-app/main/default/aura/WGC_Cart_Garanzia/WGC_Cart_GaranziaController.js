({
	doInit : function(component, event, helper) {
		helper.setupTitles(component);
	},

	onChangeMatrice : function(component, event, helper) {
		helper.setupTitles(component);
	},

	addNew : function(component, event, helper) {
		helper.fireGaranEvent(component, "addGaranzia");
	},

	addNewPF : function(component, event, helper) {
		helper.fireGaranEvent(component, "addNewPF");
	},
	
	addNewPG : function(component, event, helper) {
		helper.fireGaranEvent(component, "addNewPG");
	},

	addNewCointPF : function(component, event, helper) {
		helper.fireGaranEvent(component, "addNewCointPF");
	},

	addNewCointPG : function(component, event, helper) {
		helper.fireGaranEvent(component, "addNewCointPG");
	},

	onClickGaranzia : function(component, event, helper) {
		if (component.get("v.type") == "garanzia")
			helper.fireGaranEvent(component, "selectGaranzia", { garanzia: component.get("v.item") });
	},

	onRemoveItem : function(component, event, helper) {
		helper.fireGaranEvent(component, "removeItem", { type: component.get("v.type") , item: component.get("v.item") });
	},

	onEditItem : function(component, event, helper) {
		helper.fireGaranEvent(component, "editGaranzia");
	}

})