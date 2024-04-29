({
	doInit : function(component, event, helper) {
		helper.setPrecisioneDecimali(component);
		helper.setDefaultValue(component);
		helper.setupPicklistOptions(component);
		helper.reloadPreview(component);
	},

	onChangeParam : function(component, event, helper) {
		var param = component.get("v.parameter");
		param.value = event.getSource().get("v.value");
		component.set("v.parameter", param);

		helper.reloadPreview(component);

		var cmpEvent = component.getEvent("changeParam");
        cmpEvent.setParams({ "param" : param });
        cmpEvent.fire();
	},

	onFocusCurrency : function(component, event, helper) {
		component.set("v.showPreview", true);
	},

	onBlurCurrency : function(component, event, helper) {
		component.set("v.showPreview", false);
	},

	reloadValue : function(component, event, helper) {
		// helper.setDefaultValue(component, event);
		helper.setReadOnlyValue(component, event);
	}
})