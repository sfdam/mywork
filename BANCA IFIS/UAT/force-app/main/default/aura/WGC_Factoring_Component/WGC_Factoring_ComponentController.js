({
	doInit : function(component, event, helper) {
;
	},

	goToDetail : function(component, event, helper){
		//Non utilizzare target perchè non recupera id correttamente
		//var itemId = event.target.getAttribute("data-index");
		/*
		var itemId = event.currentTarget.getAttribute("data-index");

		var pg = {    
			"type": "standard__recordPage",
			"attributes": {
				"recordId": itemId,
				"objectApiName": "WGC_Posizione__c",
				"actionName": "view"
			}
		}

		var nav = component.find("navService");
		nav.navigate(pg);
		*/
	},

	updateParams : function(component, event, helper){
		var accountId = component.get('v.recordId');
		helper.showSpinner(component, event);
		helper.apex(component, event, 'aggiornaCampi_Prodotti_Posizione', { 'objType': 'Posizione', 'accountId': accountId })
			.then(function (result) { // SUCCESS
				console.log('ALL PARAMS result: ', result);
				return helper.apex(component, event, 'getFacCedente', { 'accountId': accountId });
			}).then(function (result) { // SUCCESS
				console.log('ALL LAST result: ', result);
				var list = [];
				list.push(result);
				component.set('v.listaPosCedente', list);
				let d = new Date(result.posizione.LastModifiedDate);
					let formattedDate = Intl.DateTimeFormat(undefined, {
						year: 'numeric',
						month: 'numeric',
						day: 'numeric',
						hour: 'numeric',
						minute: 'numeric',
						second: 'numeric'
					}).format(d);
					component.set('v.lastUpdateFactCedente', formattedDate);
			}).finally($A.getCallback(function () {
				helper.hideSpinner(component, event);
			}));
	},

})