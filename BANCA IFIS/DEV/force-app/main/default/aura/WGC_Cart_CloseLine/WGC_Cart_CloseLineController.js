({
    handleSuccess : function(component, event, helper) {
		helper.showToast(component, $A.get("$Label.c.WGC_Cart_ToastSuccessTitle"), "Linea chiusa correttamente.", "success");
		helper.hideSpinner(component);
		window.open(location, '_self', '');
	},

	onLoad : function(component, event, helper) {
		// component.find("opportunityFase").set("v.value", "Persa");
		// component.find("opportunityFase").set("v.disabled", true);
	},

	handleSubmit : function(component, event, helper) {
		event.preventDefault();       // stop the form from submitting
		
		let fields = event.getParam('fields');
		let numLineaCredito = component.get("v.numLineaCredito");
		let faseDiCaduta = component.get("v.faseLinea");
		let lineId = component.get("v.lineId");

		fields.Codice_Linea__c = numLineaCredito;
		fields.Data_Chiusura_Linea__c = new Date();
        fields.Opportunit__c = component.get("v.opportunityId");
		fields.Stato_PEF_pre_chiusura__c = component.get("v.statusPEF");
		
		console.log("fields: ", fields);
		helper.showSpinner(component);
		
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.updateLinesAfterClosing" , "params" : {lineId: lineId, faseDiCaduta: faseDiCaduta, chiusuraLinea: fields}});
		appEvent.fire();
		
		// helper.callServerSync(component, "c.updateLinesAfterClosing", {numLineaCredito: numLineaCredito, faseDiCaduta: faseDiCaduta})
		// .then(function(result) {
		// 	console.log("updateLinesAfterClosing: ", result);
		// 	if (result)
		// 		component.find('recordEditForm').submit(fields);
		// });
	},

	onChangeCategoria : function(component, event, helper) {
		let value = event.getParam("value");

		component.set("v.disableMotivo", (value == null || value == ""));
	}
})