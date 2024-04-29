({
	doInit: function (component, event, helper) {
		helper.showSpinner(component, event);
		helper.configureWizard(component, event);
		//Metodo per recuperare i dati dei prodotti reali

		var accountId = component.get('v.recordId');

		// helper.apex(component, event, 'aggiornaCampi_Prodotti_Posizione', { 'objType': 'Prodotto', 'accountId': accountId })
		// 	.then(function (result) { // SUCCESS
		// 		console.log('SUCCESS Call aggiornaCampi_Prodotti_Posizione result: ', result);
		helper.apex(component, event, 'getAllProducts', { 'accountId': accountId })
			.then(function (result) { // SUCCESS
				console.log('ALL Product result: ', result);
				component.set('v.listaProdFactCed', result.factoringCedente);
					component.set('v.listaProdFactDeb', result.factoringDebitore);
					component.set('v.listaProdFinanziamenti', result.finanziamenti);
					component.set('v.listaProdLeasing', result.leasing);
					component.set('v.listaProdAltro', result.altro);
                	component.set('v.listaProdCorporateEstero', result.corporateEstero);
					if(result.factoringCedente.length > 0 && result.factoringCedente[0].prodotto != null){
						let d = new Date(result.factoringCedente[0].prodotto.LastModifiedDate);
						let formattedDate = Intl.DateTimeFormat(undefined, {
							year: 'numeric',
							month: 'numeric',
							day: 'numeric',
							hour: 'numeric',
							minute: 'numeric',
							second: 'numeric'
						}).format(d);
						component.set('v.lastUpdateFactCedente', formattedDate);
					}

					//Metodo per conteggiare il numero di prodotti
					helper.countProdGroupByStato(component, result);
					//Raggruppo le posizioni in base al record type
					console.log('@@@ QUA ');
					helper.sectorByRT(component, result.altro);

			}).finally($A.getCallback(function () {
				helper.hideSpinner(component, event);
			}));
	},

	selectWizardItem: function (component, event, helper) {
		helper.selectWizardItem(component, event.getSource().get("v.name"));
	  },

	changeTab: function (component, event, helper) {
		console.log('@@@ event.currentTarget ', event.currentTarget.getAttribute("data-att"));
		var attrId = event.currentTarget.getAttribute("data-att");
		var tab = component.find(attrId);
		console.log('@@@ tab ', tab);
		//Aggiungo la classe all'elemento cliccato
		$A.util.addClass(tab, 'selected-tab');
		//Prendo il valore dell'ultimo tab attivo e lo trovo con il find, e dopo gli rimuovo la classe
		var valueLastTab = component.get('v.lastActiveTab');
		var lastActiveTab = component.find(valueLastTab);
		if (valueLastTab != attrId) {
			$A.util.removeClass(lastActiveTab, 'selected-tab');
			//Disattivo il flag dell'ultima sezione
			component.set('v.' + valueLastTab, false);
			//Aggiorno l'attributo con l'ultimo tab selezionato
			component.set('v.lastActiveTab', attrId);
			//Aggiorno inoltre il flag per mostrare la sezione corretta dei prodotti
			component.set('v.' + attrId, true);
		}
	},

	goToDetail : function(component, event, helper){
		var prodId = event.currentTarget.getAttribute("data-index");
		console.log('@@@ prodId ' + prodId);

		var pg = {
			"type": "standard__recordPage",
			"attributes": {
				"recordId": prodId,
				"objectApiName": "WGC_Linea_Prodotto__c",
				"actionName": "view"
			}
		};

		var navigator = component.find("navService");
		navigator.navigate(pg);
	},

	updateParams : function(component, event, helper){
		var accountId = component.get('v.recordId');
		helper.showSpinner(component, event);
		helper.apex(component, event, 'aggiornaCampi_Prodotti_Posizione', { 'objType': 'Prodotto', 'accountId': accountId })
			.then(function (result) { // SUCCESS
				console.log('ALL PARAMS result: ', result);
				return helper.apex(component, event, 'getFacCedente', { 'accountId': accountId });
			}).then(function (result) { // SUCCESS
				console.log('ALL LAST result: ', result);
				component.set('v.listaProdFactCed', result.factoringCedente);
				if(result.factoringCedente.length > 0 && result.factoringCedente[0].prodotto != null){
					let d = new Date(result.factoringCedente[0].prodotto.LastModifiedDate);
					let formattedDate = Intl.DateTimeFormat(undefined, {
						year: 'numeric',
						month: 'numeric',
						day: 'numeric',
						hour: 'numeric',
						minute: 'numeric',
						second: 'numeric'
					}).format(d);
					component.set('v.lastUpdateFactCedente', formattedDate);
				}
				
			}).finally($A.getCallback(function () {
				helper.hideSpinner(component, event);
			}));
	},


})