({
	setupTitles : function(component) {
		let type = component.get("v.type");
		let item = component.get("v.item");
		let matriceGaranzie = component.get("v.matriceGaranzie");
		let garanzieDivise = component.get("v.garanzieDivise");

		if (item != null && matriceGaranzie.length > 0 && garanzieDivise != null) {
			let matG = matriceGaranzie.find(mg => {return item.CodiceGaranzia__c == mg.CodiceKNET__c;});
			let title = (type == "garanzia" ?
				matG.Label :
				item.Nome__c);
			let subtitle = (type == "garanzia" ?
				(new Intl.NumberFormat('it-IT').format(item.Importo__c) + " " + garanzieDivise.find(d => {return d.value == item.DivisaNew__c;}).label + " - " + item.Tipo__c) : "NDG: " + item.NDG__c);

			component.set("v.title", title);
			component.set("v.subtitle", subtitle);
		}
	},

	fireGaranEvent : function(component, action, params) {
		let cmpEvent = component.getEvent("garanEvent");
		let json = { action: action };

		if (params != null && params != undefined)
			Object.assign(json, params);

        cmpEvent.setParams({ "json" : JSON.stringify(json) });
        cmpEvent.fire();
	}
})