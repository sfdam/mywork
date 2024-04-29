({
	doInit : function(component, event, helper) {
		helper.setupData(component);
		if (component.get("v.isEdit") == true) {
			helper.setupCoperture(component, component.get("v.garanzia").tipologia);
			helper.setupTipoGaranzia(component, event.getSource().get("v.value"), "");
			helper.checkValidGaranzia(component);
			component.set("v.garanzia", component.get("v.garanzia"));
		}
	},

	onChangeTipologia : function(component, event, helper) {
		if (component.get("v.isEdit") == false) {
			helper.setupCoperture(component, event.getSource().get("v.value"));
			helper.setupTipoGaranzia(component, event.getSource().get("v.value"), "tipo");
			helper.checkValidGaranzia(component);
		}
	},

	onChangeLinea : function(component, event, helper) {
		helper.setupTipoGaranzia(component, event.getSource().get("v.value"), "linea");
		helper.checkValidGaranzia(component);
	},

	onChangePerc : function(component, event, helper) {
		helper.setupTipoGaranzia(component, event.getSource().get("v.value"), "perc");
		helper.checkValidGaranzia(component);
		helper.checkValidGaranzia(component);
	},

	onChangeCopertura : function(component, event, helper) {
		helper.validateCopertura(component, event.getSource().get("v.value"));
		helper.checkValidGaranzia(component);
	},

	onChangeImporto : function(component, event, helper) {
		helper.checkValidGaranzia(component);
	},

	saveGaranzia : function(component, event, helper) {
		helper.saveGaranzia(component);
	}
})