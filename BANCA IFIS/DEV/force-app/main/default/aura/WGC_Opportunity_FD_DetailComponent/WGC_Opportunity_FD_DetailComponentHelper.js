({
	helperMethod: function () {

	},

	apex: function (component, event, apexAction, params) {
		var p = new Promise($A.getCallback(function (resolve, reject) {
			var action = component.get("c." + apexAction + "");
			action.setParams(params);
			action.setCallback(this, function (callbackResult) {
				if (callbackResult.getState() == 'SUCCESS') {
					resolve(callbackResult.getReturnValue());
				}
				if (callbackResult.getState() == 'ERROR') {
					console.log('ERROR', callbackResult.getError());
					reject(callbackResult.getError());
				}
			});
			$A.enqueueAction(action);
		}));
		return p;
	},

	generateChart: function (data, chartOptions, type, ctx, component, event) {

		var itemNode = document.getElementById('chartJS_OppFD');
		itemNode.parentNode.removeChild(itemNode);
		document.getElementById('chart-container_Opp').innerHTML = '<canvas aura:id="chartJS_OppFD" id="chartJS_OppFD" style="height:40vh" ></canvas>';

		var myLineChart = new Chart(ctx, {
			type: type,
			data: data,
			options: chartOptions
		});
	},

	optionsChart: function (component, event) {

		var chartOptions = {
			responsive: true,
			maintainAspectRatio: false,
			layout: { padding: { top: 0, right: 0, down: 0, lefth: 0 } },
			legend: {
				display: true,
				labels: {
					boxWidth: 12,
					fontSize: 12
				}
			},
			tooltips: {
				enabled: true,
				mode: 'label',
				callbacks: {
					title: function (tooltipItem, data) { 
						// console.log(tooltipItem);
						// console.log(data);
						return (tooltipItem[0].xLabel[1] == 'Visite' ? 'Positivo' : tooltipItem[0].xLabel[1] == 'Opportunità' ? 'Opportunità in valutazione' : tooltipItem[0].xLabel[1] == 'Pratiche' ? 'Approvate' : 'Avviati');
					},
					label: function(tooltipItem, data) {
						var tot = tooltipItem.xLabel[1] == 'Clienti' ? (component.get('v.clientiTotTab') + component.get('v.clientiTotGraf')) : tooltipItem.xLabel[1] == 'Pratiche' ? (component.get('v.praticheTotTab') + component.get('v.praticheTotGraf')) : tooltipItem.xLabel[1] == 'Opportunità' ?  (component.get('v.oppTotTab') + component.get('v.oppTotGraf')) : (component.get('v.visiteTotTab') + component.get('v.visiteTotGraf'));
						var percentage = tot > 0 ? ((tooltipItem.yLabel / tot) * 100) : 0;
						var corporation = data.datasets[tooltipItem.datasetIndex].label;
						return corporation + ': ' + new Intl.NumberFormat().format(tooltipItem.yLabel) + ' - ' + percentage.toFixed(2).replace('.', ',') + '%';
					}
				}
			},
			scales: {
				yAxes: [{
					display: false,
					ticks: {
						reverse: false,
						beginAtZero: true,
					}
				}],
				xAxes: [{
					categoryPercentage: 1.0,
					ticks: {
						display: false,
						min: 0,
						autoSkip: false
					},

					stacked: true,
					gridLines: {
						offsetGridLines: true
					}
				}],

			}
		};

		return chartOptions;
	},

	dataChart: function (choiseObj, result, component, event) {
		var today = new Date();
		var yearDate = today.getFullYear();

		if (choiseObj.periodo == 'lastYear') {
			yearDate = yearDate - 1;
		} else if (choiseObj.periodo == 'last2Year'){
			yearDate = undefined;
		}

		var userInfo = component.get('v.userInfo');

		var data = {};

		var clientiTot = 0;
		var clientiInBound = 0;
		var clientiOutBound = 0;
		var clientiIndiretto = 0;
		var clientiPortafoglio = 0;
		var clientiNonCategorizzato = 0;

		var visiteTot = 0;
		var visiteInBound = 0;
		var visiteOutBound = 0;
		var visiteIndiretto = 0;
		var visitePortafoglio = 0;
		var visiteNonCategorizzato = 0;

		var opportunitaTot = 0;
		var opportunitaInBound = 0;
		var opportunitaOutBound = 0;
		var opportunitaIndiretto = 0;
		var opportunitaPortafoglio = 0;
		var opportunitaNonCategorizzato = 0;

		var praticheTot = 0;
		var praticheInBound = 0;
		var praticheOutBound = 0;
		var praticheIndiretto = 0;
		var pratichePortafoglio = 0;
		var praticheNonCategorizzato = 0;

		result.dettaglioVisiteList.forEach(function (element) {
			var elementYear = new Date(element.Data_Visita_Commerciale__c).getFullYear();
			let fil = element.Filiale_Settorista__c ? element.Filiale_Settorista__c.toUpperCase() : 'NULL';

			if ((elementYear == yearDate || yearDate == undefined) && (choiseObj.operatore == 'all' ? true : choiseObj.operatore == element.Operatore_Filo_Diretto_Actual__c) && (choiseObj.filiale == 'all' ? true : choiseObj.filiale.toUpperCase() == fil)  && (choiseObj.categoria == 'all' ? true : choiseObj.categoria.toUpperCase() == element.Iniziativa__c.toUpperCase()) ) {
				
					if(element.hasOwnProperty('Iniziativa__c') && element.Iniziativa__c.toUpperCase() == 'INBOUND'){
						if(element.Macro_Esito__c == 'Positivo' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing'){
							visiteInBound++;
							if(element.Pratica_Presentata__c == 'Si' || element.Pratica_Presentata__c == 'WIP' ){
								opportunitaInBound++;
								if(element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Data_Esito_Pratica__c != null){
									praticheInBound++;
									if(element.Rapporto_Avviato__c == 'Si' && element.Primo_Prodotto__c != null && element.Data_avvio_rapporto__c != null && element.Previsione_Avvio_Rapporto__c != null){
										clientiInBound++;
									}
								}
							}
						}
					} else if(element.hasOwnProperty('Iniziativa__c') && element.Iniziativa__c.toUpperCase() == 'OUTBOUND'){
						if(element.Macro_Esito__c == 'Positivo' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing'){
							visiteOutBound++;
							if(element.Pratica_Presentata__c == 'Si' || element.Pratica_Presentata__c == 'WIP' ){
								opportunitaOutBound++;
								if(element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Data_Esito_Pratica__c != null){
									praticheOutBound++;
									if(element.Rapporto_Avviato__c == 'Si' && element.Primo_Prodotto__c != null && element.Data_avvio_rapporto__c != null && element.Previsione_Avvio_Rapporto__c != null){
										clientiOutBound++;
									}
								}
							}
						}
					} else if(element.hasOwnProperty('Iniziativa__c') && element.Iniziativa__c.toUpperCase() == 'INDIRETTO'){
						if(element.Macro_Esito__c == 'Positivo' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing'){
							visiteIndiretto++;
							if(element.Pratica_Presentata__c == 'Si' || element.Pratica_Presentata__c == 'WIP' ){
								opportunitaIndiretto++;
								if(element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Data_Esito_Pratica__c != null){
									praticheIndiretto++;
									if(element.Rapporto_Avviato__c == 'Si' && element.Primo_Prodotto__c != null && element.Data_avvio_rapporto__c != null && element.Previsione_Avvio_Rapporto__c != null){
										clientiIndiretto++;
									}
								}
							}
						}
					} else if(element.hasOwnProperty('Iniziativa__c') && element.Iniziativa__c.toUpperCase() == 'PORTAFOGLIO'){
						if(element.Macro_Esito__c == 'Positivo' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing'){
							visitePortafoglio++;
							if(element.Pratica_Presentata__c == 'Si' || element.Pratica_Presentata__c == 'WIP' ){
								opportunitaPortafoglio++;
								if(element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Data_Esito_Pratica__c != null){
									pratichePortafoglio++;
									if(element.Rapporto_Avviato__c == 'Si' && element.Primo_Prodotto__c != null && element.Data_avvio_rapporto__c != null && element.Previsione_Avvio_Rapporto__c != null){
										clientiPortafoglio++;
									}
								}
							}
						} 	
					} else {
						if(element.Macro_Esito__c == 'Positivo' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing'){
							visiteNonCategorizzato++;
							if(element.Pratica_Presentata__c == 'Si' || element.Pratica_Presentata__c == 'WIP' ){
								opportunitaNonCategorizzato++;
								if(element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Data_Esito_Pratica__c != null){
									praticheNonCategorizzato++;
									if(element.Rapporto_Avviato__c == 'Si' && element.Primo_Prodotto__c != null && element.Data_avvio_rapporto__c != null && element.Previsione_Avvio_Rapporto__c != null){
										clientiNonCategorizzato++;
									}
								}
							}
						} 
					}								
			}
		});

		visiteTot = visiteInBound + visiteOutBound + visiteIndiretto + visitePortafoglio + visiteNonCategorizzato;
		opportunitaTot = opportunitaInBound + opportunitaOutBound + opportunitaIndiretto + opportunitaPortafoglio + opportunitaNonCategorizzato;
		praticheTot = praticheInBound + praticheOutBound + praticheIndiretto + pratichePortafoglio + praticheNonCategorizzato;
		clientiTot = clientiInBound + clientiOutBound + clientiIndiretto + clientiPortafoglio + clientiNonCategorizzato;

		component.set('v.visiteTotGraf', visiteTot);
		component.set('v.oppTotGraf', opportunitaTot);
		component.set('v.praticheTotGraf', praticheTot);
		component.set('v.clientiTotGraf', clientiTot);
		
		data = {
			labels: [[visiteTot, 'Visite', ''], [opportunitaTot, 'Opportunità', ''], [praticheTot, 'Pratiche', ''], [clientiTot, 'Clienti', '']],
			// labels: [ 100, 80, 68, 50, 15, 22, 20, 12, '', 8 ],
			datasets: [
				{
					label: "Totale",
					backgroundColor: 'rgba(166, 162, 166, 0.75)',
					borderColor: 'rgba(166, 162, 166, 1)',
					fill: true,
					stack: 'tot',
					data: [visiteTot, opportunitaTot, praticheTot, clientiTot]
				},{
				  label: "Inbound",
				  backgroundColor: 'rgba(71, 146, 225, 0.75)',
				  borderColor: 'rgba(71, 146, 225, 1)',
				  fill: true,
				  stack: 'inbound',
				  	data: [visiteInBound, opportunitaInBound, praticheInBound, clientiInBound]
				}, {
				  label: "Outbound",
				  backgroundColor: 'rgba(189,236,211, 0.75)',
				  borderColor: 'rgba(189,236,211, 1)',
				  fill: true,
				  stack: 'outbound',
				  data: [visiteOutBound, opportunitaOutBound, praticheOutBound, clientiOutBound]
				}, {
				  label: "Indiretto",
				  backgroundColor: 'rgba(246, 167, 36, 0.75)',
				  borderColor: 'rgba(246, 167, 36, 1)',
				  fill: true,
				  stack: 'indiretto',
				  data: [visiteIndiretto, opportunitaIndiretto, praticheIndiretto, clientiIndiretto]
				}, {
				  label: "Portafoglio",
				  backgroundColor: 'rgba(246, 216, 24, 0.75)',
				  borderColor: 'rgba(246, 216, 24, 1)',
				  fill: true,
				  stack: 'portafoglio',
				  data: [visitePortafoglio, opportunitaPortafoglio, pratichePortafoglio, clientiPortafoglio] 
				}, {
					label: "Non Categorizzato",
					backgroundColor: 'rgba(207, 0, 15, 0.75)',
					borderColor: 'rgba(207, 0, 15, 1)',
					fill: true,
					stack: 'noCat',
					data: [visiteNonCategorizzato, opportunitaNonCategorizzato, praticheNonCategorizzato, clientiNonCategorizzato] 
				  }
			]
		};

		return data;
	},

	generateTable: function (choiseObj, result, component, event) {

		var today = new Date();
		var yearDate = today.getFullYear();

		if (choiseObj.periodo == 'lastYear') {
			yearDate = yearDate - 1;
		} else if (choiseObj.periodo == 'last2Year'){
			yearDate = undefined;
		}

		var userInfo = component.get('v.userInfo');

		//console.log('SV RESULT', JSON.stringify(result));

		var visiteAScadere = 0;
		var visiteInScadenza = 0;
		var visiteScadute = 0;
		var visitePositive = 0;
		var visiteInCorsoDiSviluppo = 0;
		var visiteDaSviluppare = 0;
		var visiteRSFNonFirmate = 0;

		var oppInValutazione = 0;
		var oppAbbandonate = 0;
		var oppDaCompletare = 0;
        var oppSenzaOpp = 0;

		var praticheApprovate = 0;
		var praticheInLavorazione = 0;
		var praticheInValutazione = 0;
		var praticheDeclinate = 0;

		var clientiAvviati = 0;
		var clientiDaAvviare = 0;
		var clientiNonAvviati = 0;

		result.dettaglioVisiteList.forEach(function (element) {
			var elementDate = new Date(element.Data_Visita_Commerciale__c);
			var elementYear = elementDate.getFullYear();
			let fil = element.Filiale_Settorista__c ? element.Filiale_Settorista__c.toUpperCase() : 'NULL';
			var iniz = element.Iniziativa__c;
			/* && (choiseObj.categoria == 'all' ? true : choiseObj.categoria.toUpperCase() == element.Iniziativa__c.toUpperCase()) */
			
			if ((elementYear == yearDate || yearDate == undefined) && (choiseObj.operatore == 'all' ? true : choiseObj.operatore == element.Operatore_Filo_Diretto_Actual__c) && (choiseObj.filiale == 'all' ? true : choiseObj.filiale.toUpperCase() == fil) && ( choiseObj.iniziativa == 'Totale' ? true : choiseObj.iniziativa == '' && iniz == undefined ? true : choiseObj.iniziativa == iniz ? true : false ) ) {
                if(element.Macro_Esito__c == undefined){					
                    if(elementDate > today) visiteAScadere++;
					if(elementDate == today) visiteInScadenza++;
					if(elementDate < today) visiteScadute++;
				}
				//if(element.Esito_Visita__c == 'Utente in corso di sviluppo') visiteInCorsoDiSviluppo++;
				if(element.Macro_Esito__c == 'Positivo' && element.Esito_Visita__c == 'Individuata opportunità' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing') visitePositive++;
				if(element.Macro_Esito__c == 'Neutro') visiteInCorsoDiSviluppo++;
				if(element.Macro_Esito__c == 'Negativo') visiteRSFNonFirmate++;

				console.log('@@@ condizione in valutazione ' , element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' &&  (!element.hasOwnProperty('Esito_Pratica__c') || element.Esito_Pratica__c == '') && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing');
				
				/* && element.Pratica_Presentata__c == 'Si' &&  (!element.hasOwnProperty('Esito_Pratica__c') || element.Esito_Pratica__c == '')  */
				if(element.Macro_Esito__c == 'Positivo' && (element.Pratica_Presentata__c == 'Si' || element.Pratica_Presentata__c == 'WIP') && element.Esito_Visita__c == 'Individuata opportunità' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing') oppInValutazione++;
				if(element.Macro_Esito__c == 'Positivo' && element.Esito_Visita__c == 'Individuata opportunità' && element.Pratica_Presentata__c == 'No' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing') oppAbbandonate++;
				if(element.Macro_Esito__c == 'Positivo' && element.Esito_Visita__c == 'Individuata opportunità' && element.Pratica_Presentata__c == 'Opportunità in istruttoria' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing') oppDaCompletare++;
				if(element.Macro_Esito__c == 'Positivo' && element.Esito_Visita__c == 'Individuata opportunità' && (!element.hasOwnProperty('Pratica_Presentata__c') || element.Pratica_Presentata__c == '')&& element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing') oppSenzaOpp++;
				
				if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' &&  element.Esito_Pratica__c == 'Approvata' && element.Esito_Visita__c == 'Individuata opportunità' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing' && element.Data_Esito_Pratica__c != null) praticheApprovate++;
				if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'WIP' &&  (!element.hasOwnProperty('Esito_Pratica__c') || element.Esito_Pratica__c == '')) praticheInLavorazione++;
				if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && (!element.hasOwnProperty('Esito_Pratica__c') || element.Esito_Pratica__c == '' || ( element.Esito_Pratica__c == 'Approvata' && element.Data_Esito_Pratica__c == null) ) ) praticheInValutazione++;
				if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Declinata') praticheDeclinate++;
				
				if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Esito_Visita__c == 'Individuata opportunità' && element.Data_Esito_Pratica__c != null && element.Rapporto_Avviato__c == 'Si' && element.Primo_Prodotto__c != null && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing' && element.Data_avvio_rapporto__c != null && element.Previsione_Avvio_Rapporto__c != null) clientiAvviati++;
				if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Esito_Visita__c == 'Individuata opportunità' && element.Data_Esito_Pratica__c != null &&  (!element.hasOwnProperty('Rapporto_Avviato__c') || element.Rapporto_Avviato__c == '' || ( element.Rapporto_Avviato__c == 'Si' && ( element.Data_avvio_rapporto__c == null || element.Previsione_Avvio_Rapporto__c == null || element.Primo_Prodotto__c == null)))&& element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing') clientiDaAvviare++;
				if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Esito_Visita__c == 'Individuata opportunità' && element.Data_Esito_Pratica__c != null &&  element.Rapporto_Avviato__c == 'No' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing') clientiNonAvviati++;			}
		});
        visiteDaSviluppare = visiteAScadere + visiteInScadenza + visiteScadute;
        
		component.set('v.visiteTotTab', visitePositive + visiteRSFNonFirmate + visiteInCorsoDiSviluppo + visiteDaSviluppare);
		component.set('v.oppTotTab', oppInValutazione + oppDaCompletare + oppAbbandonate + oppSenzaOpp);
		component.set('v.praticheTotTab', praticheApprovate + praticheInLavorazione + praticheInValutazione + praticheDeclinate);
		component.set('v.clientiTotTab', clientiAvviati + clientiDaAvviare + clientiNonAvviati);

		// var tot = tooltipItem.xLabel[1] == 'Clienti' ? (component.get('v.clientiTotTab') + component.get('v.clientiTotGraf')) : tooltipItem.xLabel[1] == 'Pratiche' ? (component.get('v.praticheTotTab') + component.get('v.praticheTotGraf')) : tooltipItem.xLabel[1] == 'Opportunità' ?  (component.get('v.oppTotTab') + component.get('v.oppTotGraf')) : (component.get('v.visiteTotTab') + component.get('v.visiteTotGraf'));
		// var percentage = tot > 0 ? ((tooltipItem.yLabel / tot) * 100) : 0;
		let totVisite = component.get('v.visiteTotTab');

		component.set('v.columnsV', [
            {label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Descrizione"), fieldName: 'desc', initialWidth: 240, type: 'string', cellAttributes:{ class:{ fieldName:"cellClass" } }},
			{label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Status") , fieldName: 'val', type: 'string', cellAttributes:{ class:{ fieldName:"col2" } }},
			{label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Percentuale") , fieldName: 'per', type: 'percent', cellAttributes:{ class:{ fieldName:"col1" } }},
		]);
		
		var resultsV = [];

		var descriptionsV = ["Positivo", $A.get("$Label.c.WGC_Opportunity_Dettaglio_Negativo"), $A.get("$Label.c.WGC_Opportunity_Dettaglio_Neutro"), $A.get("$Label.c.WGC_Opportunity_Dettaglio_VC_a_scadere"), $A.get("$Label.c.WGC_Opportunity_Dettaglio_VC_in_scadenza"), $A.get("$Label.c.WGC_Opportunity_Dettaglio_VC_scadute"), $A.get("$Label.c.WGC_Opportunity_Dettaglio_VC_pianificate")];
		
		resultsV.push(
			{ desc: descriptionsV[0] , per : totVisite > 0 ? (visitePositive / totVisite) : 0, val : new Intl.NumberFormat().format(visitePositive) },
            { desc: descriptionsV[1], per : totVisite > 0 ? (visiteRSFNonFirmate / totVisite) : 0, val : new Intl.NumberFormat().format(visiteRSFNonFirmate) },
    		{ desc: descriptionsV[2], per : totVisite > 0 ? (visiteInCorsoDiSviluppo / totVisite) : 0, val : new Intl.NumberFormat().format(visiteInCorsoDiSviluppo) },
			{ desc: descriptionsV[3], per : totVisite > 0 ? (visiteAScadere / totVisite) : 0, val : new Intl.NumberFormat().format(visiteAScadere) },
			{ desc: descriptionsV[4], per : totVisite > 0 ? (visiteInScadenza / totVisite) : 0, val : new Intl.NumberFormat().format(visiteInScadenza) },
			{ desc: descriptionsV[5], per : totVisite > 0 ? (visiteScadute / totVisite) : 0, val : new Intl.NumberFormat().format(visiteScadute) },
			{ desc: descriptionsV[6], per : totVisite > 0 ? (visiteDaSviluppare / totVisite) : 0, val : new Intl.NumberFormat().format(visiteDaSviluppare) }
		);

		component.set('v.dataV', resultsV);

		let totOpp = component.get('v.oppTotTab');

		component.set('v.columnsO', [
            {label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Descrizione"), fieldName: 'desc', initialWidth: 240, type: 'string', cellAttributes:{ class:{ fieldName:"cellClass" } }},
			{label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Status") , fieldName: 'val', type: 'string', cellAttributes:{ class:{ fieldName:"col2" } }},
			{label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Percentuale") , fieldName: 'per', type: 'percent', cellAttributes:{ class:{ fieldName:"col1" } }},
		]);
		
		var resultsO = [];

		var descriptionsO = ["Opportunità in valutazione", $A.get("$Label.c.WGC_Opportunity_Dettaglio_Senza_Opportunita"), $A.get("$Label.c.WGC_Opportunity_Dettaglio_Opportunita_Istruttoria"), $A.get("$Label.c.WGC_Opportunity_Dettaglio_Opportunita_ChiusaPersa")];
		
		resultsO.push(
			{ desc: descriptionsO[0], per : totOpp > 0 ? (oppInValutazione / totOpp) : 0, val : new Intl.NumberFormat().format(oppInValutazione) },
            { desc: descriptionsO[1], per : totOpp > 0 ? (oppSenzaOpp / totOpp) : 0, val : new Intl.NumberFormat().format(oppSenzaOpp) },
			{ desc: descriptionsO[2], per : totOpp > 0 ? (oppDaCompletare / totOpp) : 0, val : new Intl.NumberFormat().format(oppDaCompletare) },
			{ desc: descriptionsO[3], per : totOpp > 0 ? (oppAbbandonate / totOpp) : 0, val : new Intl.NumberFormat().format(oppAbbandonate) }
		);

		component.set('v.dataO', resultsO);

		let totPratiche = component.get('v.praticheTotTab');

		component.set('v.columnsP', [
            {label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Descrizione"), fieldName: 'desc', initialWidth: 240, type: 'string', cellAttributes:{ class:{ fieldName:"cellClass" } }},
			{label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Status") , fieldName: 'val', type: 'string', cellAttributes:{ class:{ fieldName:"col2" } }},
			{label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Percentuale") , fieldName: 'per', type: 'percent', cellAttributes:{ class:{ fieldName:"col1" } }},
		]);
		
		var resultsP = [];

		var descriptionsP = ["Approvate", $A.get("$Label.c.WGC_Opportunity_Dettaglio_InLavorazione"), $A.get("$Label.c.WGC_Opportunity_Dettaglio_InValutazione"), $A.get("$Label.c.WGC_Opportunity_Dettaglio_Declinate")];
		
		resultsP.push(
			{ desc: descriptionsP[0], per : totPratiche > 0 ? (praticheApprovate / totPratiche) : 0, val : new Intl.NumberFormat().format(praticheApprovate) },
			{ desc: descriptionsP[1], per : totPratiche > 0 ? (praticheInLavorazione / totPratiche) : 0, val : new Intl.NumberFormat().format(praticheInLavorazione) },
			{ desc: descriptionsP[2], per : totPratiche > 0 ? (praticheInValutazione / totPratiche) : 0, val : new Intl.NumberFormat().format(praticheInValutazione) },
			{ desc: descriptionsP[3], per : totPratiche > 0 ? (praticheDeclinate / totPratiche) : 0, val : new Intl.NumberFormat().format(praticheDeclinate) }
		);

		component.set('v.dataP', resultsP);

		let totClienti = component.get('v.clientiTotTab');

		component.set('v.columnsC', [
            {label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Descrizione"), fieldName: 'desc', initialWidth: 240, type: 'string', cellAttributes:{ class:{ fieldName:"cellClass" } }},
			{label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Status") , fieldName: 'val', type: 'string', cellAttributes:{ class:{ fieldName:"col2" } }},
			{label: $A.get("$Label.c.WGC_Opportunity_Dettaglio_Percentuale") , fieldName: 'per', type: 'percent', cellAttributes:{ class:{ fieldName:"col1" } }},
		]);
		
		var resultsC = [];

		var descriptionsC = ["Avviati", $A.get("$Label.c.WGC_Opportunity_Dettaglio_DaAvviare"), $A.get("$Label.c.WGC_Opportunity_Dettaglio_NonAvviati")];
		
		resultsC.push(
			{ desc: descriptionsC[0], per : totClienti > 0 ? (clientiAvviati / totClienti) : 0, val : new Intl.NumberFormat().format(clientiAvviati) },
			{ desc: descriptionsC[1], per : totClienti > 0 ? (clientiDaAvviare / totClienti) : 0, val : new Intl.NumberFormat().format(clientiDaAvviare) },
			{ desc: descriptionsC[2], per : totClienti > 0 ? (clientiNonAvviati / totClienti) : 0, val : new Intl.NumberFormat().format(clientiNonAvviati) }
		);

		component.set('v.dataC', resultsC);

	},

	fetchPickListVal: function (component, fieldName, object, elementId) {
        var action = component.get("c.getselectOptions_User");
        action.setParams({
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log('@@@ allValues ' , allValues);

                // opts.push({
                //     class: "optionClass",
                //     label: "All",
                //     value: "all"
                // });

				// allValues.forEach((item,index) =>{
				// 	for (var k in allValues) {
				// 		opts.push({
				// 			class: "optionClass",
				// 			label: k,
				// 			value: allValues[k]
				// 		});
				// 	}
				// });

				
                component.set("v." + elementId, allValues);
            } else {
				console.log('@@@ error ' , response.getError());
			}
        });
        $A.enqueueAction(action);
	},
	
	populateFilialePicklist : function(component, event, helper){
		var wrapper = component.get("v.allDataValue");

		var filialeArray = [];

		wrapper.dettaglioVisiteList.forEach((item,index) =>{
			if(!filialeArray.includes(item.Filiale_Settorista__c) && item.Filiale_Settorista__c != undefined) filialeArray.push(item.Filiale_Settorista__c);
		});

		component.set("v.filiali", filialeArray);
	},
})