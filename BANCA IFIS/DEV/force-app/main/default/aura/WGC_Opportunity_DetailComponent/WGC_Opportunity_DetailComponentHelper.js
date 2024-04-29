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

		var itemNode = document.getElementById('chartJS_Opp');
		itemNode.parentNode.removeChild(itemNode);
		document.getElementById('chart-container_Opp').innerHTML = '<canvas aura:id="chartJS_Opp" id="chartJS_Opp" style="height:40vh" ></canvas>';

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
				display: false,
			},
			tooltips: {
				enabled: true,
				mode: 'label',
				callbacks: {
					title: function () { }
				}
			},
			// tooltips: {
			//   callbacks: {
			//       label: function(tooltipItem, data) {
			//         var corporation = data.datasets[tooltipItem.datasetIndex].label;
			//         return corporation + ': ' + tooltipItem.yLabel.toFixed(2).replace('.', ',');
			//       }
			//   }
			// },
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
						display: true,
						min: 0,
						autoSkip: false
					},

					stacked: true,
					gridLines: {
						offsetGridLines: false
					}
				}],

			}
		};

		return chartOptions;
	},

	dataChart: function (year, result, component, event) {

		var today = new Date();
		var yearDate = today.getFullYear();

		if (year != 'thisYear') {
			yearDate = yearDate - 1;
		}
		console.log(yearDate);

		var userInfo = component.get('v.userInfo');

		var data = {};
		if(userInfo.Qualifica_Utente__c == 'Filo Diretto'){

			var clientiAvviatiInBound = 0;
			var clientiAvviatiOutBound = 0;
			var clientiAvviatiIndiretto = 0;
			var clientiAvviatiPortafoglio = 0;

			result.data[0].dettaglioVisiteList.forEach(function (element) {
				var elementYear = new Date(element.CreatedDate).getFullYear();
				console.log(elementYear);
				console.log('QUA', element);
				if (elementYear == yearDate) {
					if(element.Iniziativa__c){
						if(element.Iniziativa__c.toUpperCase() == 'INBOUND') clientiAvviatiInBound++;
						if(element.Iniziativa__c.toUpperCase() == 'OUTBOUND') clientiAvviatiOutBound++;
						if(element.Iniziativa__c.toUpperCase() == 'INDIRETTO') clientiAvviatiIndiretto++;
						if(element.Iniziativa__c.toUpperCase() == 'PORTAFOGLIO') clientiAvviatiPortafoglio++;	
					}				
				}
			});

			console.log('INBOUND', clientiAvviatiInBound);
			console.log('OUTBOUND', clientiAvviatiOutBound);
			console.log('INDIRETTO', clientiAvviatiIndiretto);		
			console.log('PORTAFOGLIO', clientiAvviatiPortafoglio);		

		} else {

			var accountId = [];
			var clientiAvviati = 0;
			result.data[0].accountList.forEach(function (element) {
				var elementYear = new Date(element.Data_New_Business__c).getFullYear();
				console.log(elementYear);
				if (elementYear == yearDate) {
					if (true) {
						clientiAvviati++;
						accountId.push(element.Anagrafica__r.Id);
					}
				}
			});

			var oppInRedazioneContratti = 0;
			var oppInRedazioneContrattiDiretto = 0;
			var oppInValutazionePratica = 0;
			var oppInValutazionePraticaDiretto = 0;
			var oppInIstruttoria = 0;
			var oppInIstruttoriaDiretto = 0;
			var oppCadutaNegativi = 0;
			result.data[0].opportunityList.forEach(function (element) {
				var elementYear = new Date(element.Data_Inizio__c).getFullYear();
				if (elementYear == yearDate) {
					if (element.StageName == 'Perfezionamento Contratto' || (element.hasOwnProperty('FaseDiCaduta__c') && element.FaseDiCaduta__c == 'Perfezionamento Contratto')) {
						if (!accountId.includes(element.AccountId)) {
							accountId.push(element.AccountId);
							if (element.Originator__c == 'Diretto') {
								oppInRedazioneContrattiDiretto++;
							} else {
								oppInRedazioneContratti++;
							}

							if(element.hasOwnProperty('FaseDiCaduta__c') && element.FaseDiCaduta__c == 'Perfezionamento Contratto'){
								oppCadutaNegativi++;
							}
						}
					}
				}
			});

			oppInRedazioneContrattiDiretto = oppInRedazioneContrattiDiretto + clientiAvviati;
			oppInRedazioneContratti = oppInRedazioneContratti + 0;

			result.data[0].opportunityList.forEach(function (element) {
				var elementYear = new Date(element.Data_Inizio__c).getFullYear();
				if (elementYear == yearDate) {
					if (element.StageName == 'Valutazione Pratica') {
						if (!accountId.includes(element.AccountId)) {
							accountId.push(element.AccountId);
							if (element.Originator__c == 'Diretto') {
								oppInValutazionePraticaDiretto++;
							} else {
								oppInValutazionePratica++;
							}
						}
					}
				}
			});

			oppInValutazionePraticaDiretto = oppInValutazionePraticaDiretto + oppInRedazioneContrattiDiretto;
			oppInValutazionePratica = oppInValutazionePratica + oppInRedazioneContratti;

			result.data[0].opportunityList.forEach(function (element) {
				var elementYear = new Date(element.Data_Inizio__c).getFullYear();
				if (elementYear == yearDate) {
					if (element.StageName == 'In Istruttoria') {
						if (!accountId.includes(element.AccountId)) {
							accountId.push(element.AccountId);
							if (element.Originator__c == 'Diretto') {
								oppInIstruttoriaDiretto++;
							} else {
								oppInIstruttoria++;
							}
						}
					}
				}
			});

			oppInIstruttoriaDiretto = oppInIstruttoriaDiretto + oppInValutazionePraticaDiretto;
			oppInIstruttoria = oppInIstruttoria + oppInValutazionePratica;

			var evnChiuso = 0;
			var evnChiusoDiretto = 0;
			var evnAperto = 0;
			var evnApertoDiretto = 0;
			var evnCadutaNegativi = 0;
			result.data[0].eventList.forEach(function (element) {
				var elementYear = new Date(element.Data_Inizio__c).getFullYear();
				if (elementYear == yearDate) {
					if (!accountId.includes(element.AccountId)) {
						if (element.Stato__c.indexOf('alt="Chiuso"') != -1) {
							accountId.push(element.AccountId);
							if (element.Originator__c == 'Diretto') {
								evnChiusoDiretto++;
							} else {
								evnChiuso++;
							}

							if (element.WGC_Macro_Esito__c == 'Negativo') {
								evnCadutaNegativi++;
							}
						}
					}
				}
			});

			evnChiusoDiretto = evnChiusoDiretto + oppInIstruttoriaDiretto;
			evnChiuso = evnChiuso + oppInIstruttoria;

			result.data[0].eventList.forEach(function (element) {
				var elementYear = new Date(element.Data_Inizio__c).getFullYear();
				if (elementYear == yearDate) {
					if (!accountId.includes(element.AccountId)) {
						if (element.Stato__c.indexOf('alt="Aperto"') != -1) {
							accountId.push(element.AccountId);
							if (element.Originator__c == 'Diretto') {
								evnApertoDiretto++;
							} else {
								evnAperto++;
							}
						}
					}
				}
			});

			evnApertoDiretto = evnApertoDiretto + evnChiusoDiretto;
			evnAperto = evnAperto + evnChiuso;

			var taskChiusoWithoutNeutro = 0;
			var taskChiusoDirettoWithoutNeutro = 0;
			var taskChiuso = 0;
			var taskChiusoDiretto = 0;
			var taskAperto = 0;
			var taskApertoDiretto = 0;
			var taskCadutaNegativi = 0;
			result.data[0].taskList.forEach(function (element) {
				var elementYear = new Date(element.Data_Inizio__c).getFullYear();
				if (elementYear == yearDate) {
					if (!accountId.includes(element.AccountId)) {
						if (element.RecordType.DeveloperName != 'Promemoria') {
							if (element.Status == 'Chiuso' && element.WGC_Macro_Esito__c != 'Neutro') {
								accountId.push(element.AccountId);
								console.log(element.AccountId);
								if (element.WGC_Macro_Esito__c == 'Negativo') {
									taskCadutaNegativi++;
								}
								if (element.Originator__c == 'Diretto') {
									taskChiusoDirettoWithoutNeutro++;
								} else if (element.WGC_Macro_Esito__c != 'Neutro') {
									taskChiusoWithoutNeutro++;
								}
							}
						}
					}
				}
			});

			taskChiusoDirettoWithoutNeutro = taskChiusoDirettoWithoutNeutro + evnApertoDiretto;
			taskChiusoWithoutNeutro = taskChiusoWithoutNeutro + evnAperto;

			result.data[0].taskList.forEach(function (element) {
				var elementYear = new Date(element.Data_Inizio__c).getFullYear();
				if (elementYear == yearDate) {
					if (!accountId.includes(element.AccountId)) {
						if (element.RecordType.DeveloperName != 'Promemoria') {
							if (element.Status == 'Chiuso' && element.WGC_Macro_Esito__c == 'Neutro') {
								accountId.push(element.AccountId);
								if (element.Originator__c == 'Diretto') {
									taskChiusoDiretto++;
								} else if (element.WGC_Macro_Esito__c == 'Neutro') {
									taskChiuso++;
								}
							}
						}
					}
				}
			});

			taskChiusoDiretto = taskChiusoDiretto + taskChiusoDirettoWithoutNeutro;
			taskChiuso = taskChiuso + taskChiusoWithoutNeutro;

			result.data[0].taskList.forEach(function (element) {
				var elementYear = new Date(element.Data_Inizio__c).getFullYear();
				if (elementYear == yearDate) {
					if (!accountId.includes(element.AccountId)) {
						if (element.RecordType.DeveloperName != 'Promemoria') {
							if (element.Status == 'Aperto') {
								accountId.push(element.AccountId);
								if (element.Originator__c == 'Diretto') {
									taskApertoDiretto++;
								} else {
									taskAperto++;
								}
							}
						}
					}
				}
			});

			taskApertoDiretto = taskApertoDiretto + taskChiusoDiretto;
			taskAperto = taskAperto + taskChiuso;

			data = {
				labels: [[taskApertoDiretto + taskAperto, 'Aziende da', 'contattare'], [taskChiusoDiretto + taskChiuso, 'Aziende', 'contattate'], [taskChiusoDirettoWithoutNeutro + taskChiusoWithoutNeutro, 'Aziende c.', 'con esito'], [evnApertoDiretto + evnAperto, 'Aziende', 'da visitare'], [evnChiusoDiretto + evnChiuso, 'Aziende', 'visitate'], [oppInIstruttoriaDiretto + oppInIstruttoria, 'Opportunità', ''], [oppInValutazionePraticaDiretto + oppInValutazionePratica, 'Pratiche', 'presentate'], [oppInRedazioneContrattiDiretto + oppInRedazioneContratti, 'Pratiche', 'deliberate'], [clientiAvviati, 'Clienti', 'avviati']],
				// labels: [ 100, 80, 68, 50, 15, 22, 20, 12, '', 8 ],
				datasets: [
					{
						label: "Aziende sviluppo diretto",
						backgroundColor: '#0064B5',
						borderColor: 'rgba(74, 144, 226, 1)',
						stack: 'stackOpp',
						data: [taskApertoDiretto, taskChiusoDiretto, taskChiusoDirettoWithoutNeutro, evnApertoDiretto, evnChiusoDiretto, oppInIstruttoriaDiretto, oppInValutazionePraticaDiretto, oppInRedazioneContrattiDiretto, clientiAvviati]
					}, {
						label: "Aziende iniziative dal centro",
						backgroundColor: 'rgba(198, 212, 229, 0.75)',
						borderColor: 'rgba(198, 212, 229, 1)',
						stack: 'stackOpp',
						data: [taskAperto, taskChiuso, taskChiusoWithoutNeutro, evnAperto, evnChiuso, oppInIstruttoria, oppInValutazionePratica, oppInRedazioneContratti, 0]
					}
				]
			};

			component.set('v.oppCadutaNegativi', oppCadutaNegativi);
			component.set('v.evnCadutaNegativi', evnCadutaNegativi);
			component.set('v.taskCadutaNegativi', taskCadutaNegativi);
			component.set('v.redemption', clientiAvviati / (taskChiusoDiretto + taskChiuso));
			component.set('v.convertion', clientiAvviati / (evnChiusoDiretto + evnChiuso));
			component.set('v.qualita', (oppInRedazioneContrattiDiretto + oppInRedazioneContratti) / (oppInValutazionePraticaDiretto + oppInValutazionePratica));


		}

		return data;
	},
})