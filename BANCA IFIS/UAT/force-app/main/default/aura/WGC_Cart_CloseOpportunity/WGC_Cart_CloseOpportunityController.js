({
	handleSuccess : function(component, event, helper) {
		helper.showToast(component, $A.get("$Label.c.WGC_Cart_ToastSuccessTitle"), "Opportunità chiusa correttamente.", "success");
		helper.hideSpinner(component);
		window.open(location, '_self', '');
	},

	onLoad : function(component, event, helper) {
	},
    
	handleSubmit : function(component, event, helper) {
		event.preventDefault();       // stop the form from submitting
        component.set("v.disableMotivo", true);
		let fields = event.getParam('fields');
		fields.StageName = 'Persa';
		helper.showSpinner(component);
		component.find('recordEditForm').submit(fields);
	},

	onChangeCategoria : function(component, event, helper) {
		let value = event.getParam("value");

		component.set("v.disableMotivo", (value == null || value == ""));
	}
})