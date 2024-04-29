({  
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

	reloadData: function (component, event, filter, data) {
		const monthNames = [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")];
		
		var today = new Date(Date.now());
        var x = new Date(Date.now());
        var y = new Date(Date.now());
        var d = new Date();
        var n = d.getFullYear();
        var m = d.getMonth();
        //m++;
		console.log('@mese ', m);
		
		var chartJS_Data_Clienti = { actual : [0,0,0,0,0,0,0,0,0,0,0,0], budget : [0,0,0,0,0,0,0,0,0,0,0,0], potenziale : [0,0,0,0,0,0,0,0,0,0,0,0], previsione : [0,0,0,0,0,0,0,0,0,0,0,0] };

		var result = data;

		var impostazione_rolling_dataAvvioRapporto = new Date(x.setMonth(x.getMonth() - result.data[0].impostazioni.Clienti_Avviati_Mesi_Rolling__c));
		var impostazione_rolling_dataVisitaCommerciale = new Date(y.setMonth(y.getMonth() - result.data[0].impostazioni.Data_Inizio_Rolling_FD__c));
        
        impostazione_rolling_dataAvvioRapporto = new Date(impostazione_rolling_dataAvvioRapporto.setDate(1));
        impostazione_rolling_dataVisitaCommerciale = new Date(impostazione_rolling_dataVisitaCommerciale.setDate(1));

        console.log('SV impostazione_rolling_dataAvvioRapporto ', impostazione_rolling_dataAvvioRapporto);
        console.log('SV impostazione_rolling_dataVisitaCommerciale', impostazione_rolling_dataVisitaCommerciale);
        console.log('SV impostazione_rolling_dataVisitaCommerciale', result.data[0].impostazioni.Data_Inizio_Rolling_FD__c);

		var teams = component.get('v.mapTeamUserFD');
        var usersInTeam = [];
        if(filter.teamName != ''){
            usersInTeam = teams.get(filter.teamName);
        }
        
        console.log('usersInTeam', usersInTeam);
        var usersIdTeam = [];
        usersInTeam.forEach(function (element) {
            usersIdTeam.push(element.Id);
        });
		console.log('usersIdTeam', usersIdTeam);
		
		var clientiAvviatiTotMonth = 0;
		var listNewBusinessMonth = [];
		var listNewBusinessYear = [];

		
		var numPrevisione = 0;
		var numAvvio = 0;
		var dayMagazziono = 0;
        var giorniDifferenzaMagazzino = 0;
        var diffGiorni = 0;

		result.data[0].dettaglioVisiteList.forEach(function (element) {
			var elementDate = new Date(element.Data_avvio_rapporto__c);
			var elementYear = elementDate.getFullYear();
			var elementMonth = elementDate.getMonth();
			var elementDay = elementDate.getDate();
			
			var elementPrevisioneDate = new Date(element.Previsione_Avvio_Rapporto__c);
			var elementtPrevisioneYear = elementPrevisioneDate.getFullYear();
			var elementPrevisioneMonth = elementPrevisioneDate.getMonth();

			var dataVisitaCommerciale = new Date(element.Data_Visita_Commerciale__c);

			
			if(filter.isAllUser){
				
				if(element.Qualifica_Corporate__c = 'New Business'){
                    
                    if(element.Esito_Visita__c == 'Individuata opportunità' && element.Pratica_Presentata__c == 'Si' && element.hasOwnProperty('Data_Esito_Pratica__c') && !element.hasOwnProperty('Primo_Prodotto__c') && element.Esito_Pratica__c == 'Approvata'){
                        if(elementtPrevisioneYear == n && elementPrevisioneMonth == m){
                            let nbPElement = {};
                            nbPElement.Id        = element.Ragione_Sociale__c;
                            nbPElement.Famiglia  = element.Famiglia_Primo_Prodotto__c;
                            find = false;
                            listNewBusinessMonth.forEach(function (el) {
                                if(el.Id == nbPElement.Id && el.Famiglia == nbPElement.Famiglia) find = true;
                            });
                            if(!find) {
                                numPrevisione++;
                            }
                        }
                    }
                    
                    if(element.Esito_Visita__c == 'Individuata opportunità' && element.Pratica_Presentata__c == 'Si' && element.hasOwnProperty('Data_Esito_Pratica__c') && (element.hasOwnProperty('Primo_Prodotto__c') && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing') && element.Esito_Pratica__c == 'Approvata'){
                                
                        if(element.hasOwnProperty('Previsione_Avvio_Rapporto__c') && elementYear == n && elementMonth == m && element.Rapporto_Avviato__c == 'Si'){
                            let nbElement = {};
                            nbElement.Id        = element.Ragione_Sociale__c;
                            nbElement.Famiglia  = element.Famiglia_Primo_Prodotto__c;
                            find = false;
                            listNewBusinessMonth.forEach(function (el) {
                                if(el.Id == nbElement.Id && el.Famiglia == nbElement.Famiglia) find = true;
                            });
                            if(!find) {
                                listNewBusinessMonth.push(nbElement);
                                
                                numAvvio++;
                                clientiAvviatiTotMonth++;  
                                chartJS_Data_Clienti.actual[elementMonth]++;
                                if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
                                    if(elementDate < new Date( new Date().setDate(1)) && elementDate >= impostazione_rolling_dataAvvioRapporto && dataVisitaCommerciale < new Date( new Date().setDate(1)) && dataVisitaCommerciale >= impostazione_rolling_dataVisitaCommerciale){
                                        giorniDifferenzaMagazzino = new Date(element.Data_avvio_rapporto__c) - new Date(element.Data_Visita_Commerciale__c);
                                        diffGiorni += giorniDifferenzaMagazzino / (1000 * 60 * 60 * 24);
                                        dayMagazziono++;  
                                    } 
                                }
                            }
                        }
                        if(element.hasOwnProperty('Previsione_Avvio_Rapporto__c') && elementYear == n && elementMonth < m && element.Rapporto_Avviato__c == 'Si'){
                            
                            let nbElementYear = {};
                            nbElementYear.Id        = element.Ragione_Sociale__c;
                            nbElementYear.Famiglia  = element.Famiglia_Primo_Prodotto__c;
                            find = false;
                            listNewBusinessYear.forEach(function (el) {
                                if(el.Id == nbElementYear.Id && el.Famiglia == nbElementYear.Famiglia) find = true;
                            });
                            if(!find) {
                                listNewBusinessYear.push(nbElementYear);
                                chartJS_Data_Clienti.actual[elementMonth]++;
                                
                                if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
                                    if(elementDate < new Date( new Date().setDate(1)) && elementDate >= impostazione_rolling_dataAvvioRapporto && dataVisitaCommerciale < new Date( new Date().setDate(1)) && dataVisitaCommerciale >= impostazione_rolling_dataVisitaCommerciale){
                                        giorniDifferenzaMagazzino = new Date(element.Data_avvio_rapporto__c) - new Date(element.Data_Visita_Commerciale__c);
                                        diffGiorni += giorniDifferenzaMagazzino / (1000 * 60 * 60 * 24);
                                        dayMagazziono++;  
                                    } 
                                }						
                            }
                        }
                    }
					
				}
				
			} else if(filter.teamName != ''){
				if(usersIdTeam.includes(element.Operatore_Filo_Diretto__c)){
					if(element.Qualifica_Corporate__c = 'New Business'){
                        
                    	if(element.Esito_Visita__c == 'Individuata opportunità' && element.Pratica_Presentata__c == 'Si' && element.hasOwnProperty('Data_Esito_Pratica__c') && !element.hasOwnProperty('Primo_Prodotto__c') && element.Esito_Pratica__c == 'Approvata'){
                            if(elementtPrevisioneYear == n && elementPrevisioneMonth == m){
                                let nbPElement = {};
                                nbPElement.Id        = element.Ragione_Sociale__c;
                                nbPElement.Famiglia  = element.Famiglia_Primo_Prodotto__c;
                                find = false;
                                listNewBusinessMonth.forEach(function (el) {
                                    if(el.Id == nbPElement.Id && el.Famiglia == nbPElement.Famiglia) find = true;
                                });
                                if(!find) {
                                    numPrevisione++;
                                }
                            }
                    	}
                    
                    	if(element.Esito_Visita__c == 'Individuata opportunità' && element.Pratica_Presentata__c == 'Si' && element.hasOwnProperty('Data_Esito_Pratica__c') && (element.hasOwnProperty('Primo_Prodotto__c') && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing') && element.Esito_Pratica__c == 'Approvata'){
                            
                            if(element.hasOwnProperty('Previsione_Avvio_Rapporto__c') && elementYear == n && elementMonth == m && element.Rapporto_Avviato__c == 'Si'){
                                let nbElement = {};
                                nbElement.Id        = element.Ragione_Sociale__c;
                                nbElement.Famiglia  = element.Famiglia_Primo_Prodotto__c;
                                find = false;
                                listNewBusinessMonth.forEach(function (el) {
                                    if(el.Id == nbElement.Id && el.Famiglia == nbElement.Famiglia) find = true;
                                });
                                if(!find) {
                                    listNewBusinessMonth.push(nbElement);							
                                    numAvvio++;
                                    clientiAvviatiTotMonth++;  
                                    chartJS_Data_Clienti.actual[elementMonth]++;
                                    if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
                                        if(elementDate < new Date( new Date().setDate(1)) && elementDate >= impostazione_rolling_dataAvvioRapporto && dataVisitaCommerciale < new Date( new Date().setDate(1)) && dataVisitaCommerciale >= impostazione_rolling_dataVisitaCommerciale){
                                            giorniDifferenzaMagazzino = new Date(element.Data_avvio_rapporto__c) - new Date(element.Data_Visita_Commerciale__c);
                                            diffGiorni += giorniDifferenzaMagazzino / (1000 * 60 * 60 * 24);
                                            dayMagazziono++;  
                                    	} 
                                    }							
                                }
                            }
                            if(element.hasOwnProperty('Previsione_Avvio_Rapporto__c') && elementYear == n && elementMonth < m && element.Rapporto_Avviato__c == 'Si'){
                                let nbElementYear = {};
                                nbElementYear.Id        = element.Ragione_Sociale__c;
                                nbElementYear.Famiglia  = element.Famiglia_Primo_Prodotto__c;
                                find = false;
                                listNewBusinessYear.forEach(function (el) {
                                    if(el.Id == nbElementYear.Id && el.Famiglia == nbElementYear.Famiglia) find = true;
                                });
                                if(!find) {
                                    listNewBusinessYear.push(nbElementYear);
                                    chartJS_Data_Clienti.actual[elementMonth]++;
                                    if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
                                        if(elementDate < new Date( new Date().setDate(1)) && elementDate >= impostazione_rolling_dataAvvioRapporto && dataVisitaCommerciale < new Date( new Date().setDate(1)) && dataVisitaCommerciale >= impostazione_rolling_dataVisitaCommerciale){
                                            giorniDifferenzaMagazzino = new Date(element.Data_avvio_rapporto__c) - new Date(element.Data_Visita_Commerciale__c);
                                            diffGiorni += giorniDifferenzaMagazzino / (1000 * 60 * 60 * 24);
                                        	dayMagazziono++;  
                                    	} 
                                    }
                                }
                            } 
                        }
					}
				}
				

			} else {
				if(filter.userId == element.Operatore_Filo_Diretto__c){
					if(element.Qualifica_Corporate__c = 'New Business'){
                        if(element.Esito_Visita__c == 'Individuata opportunità' && element.Pratica_Presentata__c == 'Si' && element.hasOwnProperty('Data_Esito_Pratica__c') && !element.hasOwnProperty('Primo_Prodotto__c') && element.Esito_Pratica__c == 'Approvata'){
                            if(elementtPrevisioneYear == n && elementPrevisioneMonth == m){
                                let nbPElement = {};
                                nbPElement.Id        = element.Ragione_Sociale__c;
                                nbPElement.Famiglia  = element.Famiglia_Primo_Prodotto__c;
                                find = false;
                                listNewBusinessMonth.forEach(function (el) {
                                    if(el.Id == nbPElement.Id && el.Famiglia == nbPElement.Famiglia) find = true;
                                });
                                if(!find) {
                                    numPrevisione++;
                                }
                            }
                    	}
                    
                    	if(element.Esito_Visita__c == 'Individuata opportunità' && element.Pratica_Presentata__c == 'Si' && element.hasOwnProperty('Data_Esito_Pratica__c') && (element.hasOwnProperty('Primo_Prodotto__c') && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing') && element.Esito_Pratica__c == 'Approvata'){
						
                            if(element.hasOwnProperty('Previsione_Avvio_Rapporto__c') && elementYear == n && elementMonth == m && element.Rapporto_Avviato__c == 'Si'){
                                let nbElement = {};
                                nbElement.Id        = element.Ragione_Sociale__c;
                                nbElement.Famiglia  = element.Famiglia_Primo_Prodotto__c;
                                find = false;
                                listNewBusinessMonth.forEach(function (el) {
                                    if(el.Id == nbElement.Id && el.Famiglia == nbElement.Famiglia) find = true;
                                });
                                if(!find) {
                                    listNewBusinessMonth.push(nbElement);
                                    numAvvio++;
                                    clientiAvviatiTotMonth++; 
                                    chartJS_Data_Clienti.actual[elementMonth]++;
                                    if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
                                        if(elementDate < new Date( new Date().setDate(1)) && elementDate >= impostazione_rolling_dataAvvioRapporto && dataVisitaCommerciale < new Date( new Date().setDate(1)) && dataVisitaCommerciale >= impostazione_rolling_dataVisitaCommerciale){
                                            giorniDifferenzaMagazzino = new Date(element.Data_avvio_rapporto__c) - new Date(element.Data_Visita_Commerciale__c);
                                            diffGiorni += giorniDifferenzaMagazzino / (1000 * 60 * 60 * 24);
                                            dayMagazziono++;  
                                        } 
                                    }
                                }
                            }
                            if(element.hasOwnProperty('Previsione_Avvio_Rapporto__c') && elementYear == n && elementMonth < m && element.Rapporto_Avviato__c == 'Si'){
                                let nbElementYear = {};
                                nbElementYear.Id        = element.Ragione_Sociale__c;
                                nbElementYear.Famiglia  = element.Famiglia_Primo_Prodotto__c;
                                find = false;
                                listNewBusinessYear.forEach(function (el) {
                                    if(el.Id == nbElementYear.Id && el.Famiglia == nbElementYear.Famiglia) find = true;
                                });
                                if(!find) {
                                    listNewBusinessYear.push(nbElementYear);
                                    chartJS_Data_Clienti.actual[elementMonth]++;
                                    if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
                                        if(elementDate < new Date( new Date().setDate(1)) && elementDate >= impostazione_rolling_dataAvvioRapporto && dataVisitaCommerciale < new Date( new Date().setDate(1)) && dataVisitaCommerciale >= impostazione_rolling_dataVisitaCommerciale){
                                            giorniDifferenzaMagazzino = new Date(element.Data_avvio_rapporto__c) - new Date(element.Data_Visita_Commerciale__c);
                                            diffGiorni += giorniDifferenzaMagazzino / (1000 * 60 * 60 * 24);
                                            dayMagazziono++;  
                                        } 
                                    }
                                }
                            } 
                        }
					}
				}
				
			}
			
		});
												   
		component.set('v.clientiAvviatiTot_Month', clientiAvviatiTotMonth);
        console.log('@@@ numPrevisione Tot ' , numPrevisione);
        console.log('@@@ numAvvio Tot ' , numAvvio);
		component.set('v.previsione', numPrevisione); //(numPrevisione - numAvvio) > 0 ? numPrevisione - numAvvio : 0);
		component.set('v.potenziale', ( dayMagazziono > 0 && (diffGiorni / dayMagazziono) > 0 ) ? Math.ceil( (result.data[0].workMonth / (diffGiorni / dayMagazziono) ) * this.calcolaPotenzialiAttuali(component, event, result.data[0].dettaglioVisiteList, usersIdTeam, filter) ) : 0);
        console.log('@@@ potenziale ' , (dayMagazziono > 0 && (diffGiorni / dayMagazziono) > 0 ) ? Math.ceil( (result.data[0].workMonth / (diffGiorni / dayMagazziono) ) * this.calcolaPotenzialiAttuali(component, event, result.data[0].dettaglioVisiteList, usersIdTeam, filter) ) : 0);
        
        	var clientiAvviatiTot_Month_Budget = 0;
        
            result.data[0].budgetList.forEach(function (element) {
                
                if(filter.isAllUser){
                    if (element.Mese__c - 1 <= today.getMonth()){
                    
                    
						//chartJS_Data_Clienti.budget[element.Mese__c - 1] = chartJS_Data_Clienti.budget[element.Mese__c - 1] + element.Clienti_avviati_FD_revisionati__c;
						
					}
					if (element.Mese__c - 1 == today.getMonth()){
						clientiAvviatiTot_Month_Budget = clientiAvviatiTot_Month_Budget + element.Clienti_avviati_FD_revisionati__c;
											
					}
                    
                } else if(filter.teamName != ''){
                    if(usersIdTeam.includes(element.OwnerId)){
                        if (element.Mese__c - 1 <= today.getMonth()){
                    
                    //chartJS_Data_Clienti.budget[element.Mese__c - 1] = chartJS_Data_Clienti.budget[element.Mese__c - 1] + element.Clienti_avviati_FD_revisionati__c;
                    
                }
                if (element.Mese__c - 1 == today.getMonth()){
                    clientiAvviatiTot_Month_Budget = clientiAvviatiTot_Month_Budget + element.Clienti_avviati_FD_revisionati__c;
                    
                }
                    }
                } else {
                    if(filter.userId == element.OwnerId){
                        if (element.Mese__c - 1 <= today.getMonth()){
                    
                    
                    //chartJS_Data_Clienti.budget[element.Mese__c - 1] = element.Clienti_avviati_FD_revisionati__c;
                    
                }
                if (element.Mese__c - 1 == today.getMonth()){
                    clientiAvviatiTot_Month_Budget = clientiAvviatiTot_Month_Budget + element.Clienti_avviati_FD_revisionati__c;
                    
                    
                    
                }
                    }
                }                
            });
            
			component.set('v.clientiAvviatiTot_Month_Budget', clientiAvviatiTot_Month_Budget);
			
			this.generateChart(this.dataChart(chartJS_Data_Clienti, 1, component, event), this.optionsChart(null, 1, component, event), 'bar', 'obiettivo_chart', component, event);

        


	},
	
    generateChart: function (data, chartOptions, type, ctxName, component, event) {

        var itemNode = document.getElementById(ctxName);
        
        if (itemNode != null) {
          itemNode.parentNode.removeChild(itemNode);
		  document.getElementById('container_' + ctxName).innerHTML = '<canvas style="height:25vh" id="' + ctxName + '"' + '></canvas>';
		  
          var myChart = new Chart(ctxName, {
            type: type,
            data: data,
            options: chartOptions
          });
        }
      },
    
      optionsChart: function (step, chart, component, event) {

        var chartOptions = {};

            chartOptions = {
                responsive: true,
                maintainAspectRatio: false,
                //layout: { padding: { top: 0, right: 0, down: 0, lefth: 0 } },
                legend: {
                  display: true,
                  position: "top",
                      labels: {
                          boxWidth: 12
                      }
                },
                tooltips: {
                  enabled: true,
                  // mode: 'x',
                  // callbacks: {
                  //   label: function (tooltipItem, data) {
                  //       console.log('data.datasets[tooltipItem.datasetIndex].label', data.datasets[tooltipItem.datasetIndex].label);
                  //     var corporation = data.datasets[tooltipItem.datasetIndex].label;
                  //     return corporation + ': ' + ((chart == 1) ? (new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(tooltipItem.yLabel)) : (parseFloat(tooltipItem.yLabel).toFixed(2)+"%"));
                  //   }
                  // }
                  mode: 'label'
                },
                scales: {
                  yAxes: [{
                    display: false,
                    ticks: {
                      reverse: false,
                      beginAtZero: true,
                      //suggestedMax: 110,
                               padding: 20,
                    }
                  }],
                  xAxes: [{
                    position: 'bottom',
                    stacked: true,
                    display: true,
                    ticks: {
                      display: true //this will remove only the label
                    },
                    offset: true,
                    gridLines: {
                      display: false,
                      offsetGridLines: true
                    }
                  }],
          
                }
              };
    
        return chartOptions;
      },
    
      dataChart: function (data, chart, component, event) {
    
        console.log('SV dataChart', data, chart);
          data = {
            labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
            datasets: [
            //   {
            //     label: "Budget",
            //     backgroundColor: 'rgba(166, 162, 166, 0.75)',
            //     borderColor: 'rgba(166, 162, 166, 1)',
            //     fill: true,
            //     stack: 'budget',
            //     data: data.budget
			//   }, 
			  {
                label: "Actual",
                backgroundColor: 'rgba(246, 167, 36, 0.75)',
                borderColor: 'rgba(246, 167, 36, 1)',
                fill: true,
                stack: 'actual_previsione',
                data: data.actual
			  }, 
			//   {
            //     label: "Previsione",
            //     backgroundColor: 'rgba(246, 216, 24, 0.75)',
            //     borderColor: 'rgba(246, 216, 24, 1)',
            //     fill: true,
            //     stack: 'actual_previsione',
            //     data: data.previsione
            //   }, {
            //     label: "Potenziale",
            //     backgroundColor: 'rgba(71, 146, 225, 0.75)',
            //     borderColor: 'rgba(71, 146, 225, 1)',
            //     fill: true,
            //     stack: 'potenziale',
            //     data: data.potenziale
            //   }
            ]
          };
        
    
        return data;
	  },
	  
      /*
	  calcolaPotenzialiAttuali: function (component, event, dtVisList, usersIdTeam, filter) {
        
        let potenzialiAttuali = 0;

        //Variabili di appoggio
        //Conteggi
        let visiteDaSviluppare = 0;
        let rsfFirmate = 0;
        let rsfNonFirmate = 0;
        let praticheAbbandonate = 0;
        let praticheInviatePEF = 0;
        let praticheDeclinate = 0;
        let praticheApprovate = 0;
        let praticheDaCompletare = 0;
        let praticheInLavorazione = 0;
        let praticheInValutazione = 0;
        let clientiDaAvviare = 0;
        let clientiNonAvviati = 0;
        let clientiAvviati = 0;
        //Percentuali
        let rsfFirmatePerc = 0;
        let praticheInviatePEFPerc = 0;
        let praticheDaCompletarePerc = 0;
        let praticheInLavorazionePerc = 0;
        let praticheApprovatePerc = 0;
        let clientiDaAvviarePerc = 0;
        let clientiAvviatiPerc = 0;

        dtVisList.forEach(function (element) {
            if(filter.isAllUser){
                if(element.Macro_Esito__c == null) visiteDaSviluppare ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Esito_Visita__c == 'Individuata opportunità' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing') rsfFirmate ++;

                if(element.Macro_Esito__c == 'Negativo') rsfNonFirmate ++;
                
                if(element.Macro_Esito__c == 'Neutro') visiteNeu

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'No') praticheAbbandonate ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Declinata') praticheDeclinate ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata') praticheApprovate ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == null) praticheDaCompletare ++;

                if(element.Macro_Esito__c == 'Positivo' && (element.Pratica_Presentata__c == 'Si' || element.Pratica_Presentata__c == 'WIP')) praticheInviatePEF ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'WIP' && element.Esito_Pratica__c == null) praticheInLavorazione ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == null) praticheInValutazione ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Rapporto_Avviato__c == null) clientiDaAvviare ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Rapporto_Avviato__c == 'No') clientiNonAvviati ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Rapporto_Avviato__c == 'Si') clientiAvviati ++;
            } else if(filter.teamName != ''){
                if(usersIdTeam.includes(element.Operatore_Filo_Diretto__c)){
                    if(element.Macro_Esito__c == null) visiteDaSviluppare ++;

                if(element.Macro_Esito__c == 'Positivo') rsfFirmate ++;

                if(element.Macro_Esito__c == 'Negativo') rsfNonFirmate ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'No') praticheAbbandonate ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Declinata') praticheDeclinate ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata') praticheApprovate ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == null) praticheDaCompletare ++;

                if(element.Macro_Esito__c == 'Positivo' && (element.Pratica_Presentata__c == 'Si' || element.Pratica_Presentata__c == 'WIP')) praticheInviatePEF ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'WIP' && element.Esito_Pratica__c == null) praticheInLavorazione ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == null) praticheInValutazione ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Rapporto_Avviato__c == null) clientiDaAvviare ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Rapporto_Avviato__c == 'No') clientiNonAvviati ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Rapporto_Avviato__c == 'Si') clientiAvviati ++;
                }                
            } else {
                if(filter.userId == element.Operatore_Filo_Diretto__c){
                  if(element.Macro_Esito__c == null) visiteDaSviluppare ++;

                if(element.Macro_Esito__c == 'Positivo') rsfFirmate ++;

                if(element.Macro_Esito__c == 'Negativo') rsfNonFirmate ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'No') praticheAbbandonate ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Declinata') praticheDeclinate ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata') praticheApprovate ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == null) praticheDaCompletare ++;

                if(element.Macro_Esito__c == 'Positivo' && (element.Pratica_Presentata__c == 'Si' || element.Pratica_Presentata__c == 'WIP')) praticheInviatePEF ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'WIP' && element.Esito_Pratica__c == null) praticheInLavorazione ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == null) praticheInValutazione ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Rapporto_Avviato__c == null) clientiDaAvviare ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Rapporto_Avviato__c == 'No') clientiNonAvviati ++;

                if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Rapporto_Avviato__c == 'Si') clientiAvviati ++;  
                }
            }
        });
        
        //rsfFirmatePerc = (visiteDaSviluppare + rsfFirmate + rsfNonFirmate) > 0 ? ( visiteDaSviluppare / (visiteDaSviluppare + rsfFirmate + rsfNonFirmate) ) : 0;
        rsfFirmatePerc = (visiteDaSviluppare + rsfFirmate + rsfNonFirmate) > 0 ? ( rsfFirmate / (visiteDaSviluppare + rsfFirmate + rsfNonFirmate)) : 0;
        praticheInviatePEFPerc = ( praticheInviatePEF + praticheDaCompletare + praticheAbbandonate ) > 0 ? ( praticheInviatePEF / ( praticheInviatePEF + praticheDaCompletare + praticheAbbandonate ) ) : 0;
        
        clientiAvviatiPerc = ( clientiDaAvviare + clientiNonAvviati + clientiAvviati ) > 0 ? ( clientiAvviati / ( clientiDaAvviare + clientiNonAvviati + clientiAvviati ) ) : 0;
        
        praticheApprovatePerc = (praticheApprovate + praticheInLavorazione + praticheInValutazione + praticheDeclinate) > 0 ? ( praticheApprovate / (praticheApprovate + praticheInLavorazione + praticheInValutazione + praticheDeclinate) ) : 0;

        /*potenzialiAttuali = ( visiteDaSviluppare * ( rsfFirmatePerc * praticheInviatePEFPerc * praticheApprovatePerc * clientiAvviatiPerc) ) + 
                            ( praticheInviatePEF * ( praticheApprovatePerc * clientiAvviatiPerc ) ) + 
                            ( clientiDaAvviare * clientiAvviatiPerc );*/
        /*
        potenzialiAttuali = ( visiteDaSviluppare * rsfFirmatePerc ) + 
                            ( praticheInviatePEF * ( praticheApprovatePerc * clientiAvviatiPerc ) ) + 
                            ( clientiDaAvviare * clientiAvviatiPerc );
        
        return potenzialiAttuali;
        
    }
    */
                
    calcolaPotenzialiAttuali: function (component, event, dtVisList, usersIdTeam, filter) {
        
        var potenzialiAttuali = 0;
        //Variabili di appoggio
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
        
        dtVisList.forEach(function (element) {
            if(new Date(element.Data_Visita_Commerciale__c).getFullYear() == new Date().getFullYear()){
                if(filter.isAllUser){
                    if(element.Macro_Esito__c == 'Positivo' && element.Esito_Visita__c == 'Individuata opportunità' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing') visitePositive++;
                    if(element.Macro_Esito__c == 'Neutro') visiteInCorsoDiSviluppo++;
                    if(element.Macro_Esito__c == 'Negativo') visiteRSFNonFirmate++;
                    
                    if(element.Macro_Esito__c == null) visiteDaSviluppare++;
                    
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
                    if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Esito_Visita__c == 'Individuata opportunità' && element.Data_Esito_Pratica__c != null &&  element.Rapporto_Avviato__c == 'No' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing') clientiNonAvviati++;
                } else if(filter.teamName != ''){
                    if(usersIdTeam.includes(element.Operatore_Filo_Diretto__c)){
                        if(element.Macro_Esito__c == 'Positivo' && element.Esito_Visita__c == 'Individuata opportunità' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing') visitePositive++;
                        if(element.Macro_Esito__c == 'Neutro') visiteInCorsoDiSviluppo++;
                        if(element.Macro_Esito__c == 'Negativo') visiteRSFNonFirmate++;
                    
                        if(element.Macro_Esito__c == null) visiteDaSviluppare++;
                        
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
                        if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Esito_Visita__c == 'Individuata opportunità' && element.Data_Esito_Pratica__c != null &&  element.Rapporto_Avviato__c == 'No' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing') clientiNonAvviati++;
                    }                
                } else {
                    if(filter.userId == element.Operatore_Filo_Diretto__c){
                        if(element.Macro_Esito__c == 'Positivo' && element.Esito_Visita__c == 'Individuata opportunità' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing') visitePositive++;
                        if(element.Macro_Esito__c == 'Neutro') visiteInCorsoDiSviluppo++;
                        if(element.Macro_Esito__c == 'Negativo') visiteRSFNonFirmate++;
                    
                        if(element.Macro_Esito__c == null) visiteDaSviluppare++;
                        
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
                        if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Esito_Visita__c == 'Individuata opportunità' && element.Data_Esito_Pratica__c != null &&  element.Rapporto_Avviato__c == 'No' && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing') clientiNonAvviati++;
                    }
                }
        	}
        });
                
        let rsfFirmatePerc = (visitePositive + visiteRSFNonFirmate + visiteInCorsoDiSviluppo + visiteDaSviluppare) > 0 ? parseFloat( ( visitePositive / (visitePositive + visiteRSFNonFirmate + visiteInCorsoDiSviluppo + visiteDaSviluppare)).toFixed(2))  : 0;
        let oppInValutazionePerc = (oppInValutazione + oppSenzaOpp + oppDaCompletare + oppAbbandonate) > 0 ? parseFloat( ( oppInValutazione / (oppInValutazione + oppSenzaOpp + oppDaCompletare + oppAbbandonate)).toFixed(2)) : 0;
        let praticheApprovatePerc = (praticheApprovate + praticheInLavorazione + praticheInValutazione + praticheDeclinate) > 0 ? parseFloat( ( praticheApprovate / (praticheApprovate + praticheInLavorazione + praticheInValutazione + praticheDeclinate)).toFixed(2)) : 0;
        let clientiAvviatiPerc = (clientiAvviati + clientiDaAvviare + clientiNonAvviati) > 0 ? parseFloat( ( clientiAvviati / (clientiAvviati + clientiDaAvviare + clientiNonAvviati)).toFixed(2)) : 0;
        
        /*potenzialiAttuali = ( visiteDaSviluppare * ( rsfFirmatePerc * oppInValutazionePerc * praticheApprovatePerc * clientiAvviatiPerc) ) + 
                            ( oppInValutazione * ( praticheApprovatePerc * clientiAvviatiPerc ) ) + 
                            ( clientiDaAvviare * clientiAvviatiPerc );*/
                
                console.log('visiteDaSviluppare: ' , visiteDaSviluppare);
                console.log('rsfFirmatePerc: ' , rsfFirmatePerc);
                console.log('oppDaCompletare: ' , oppDaCompletare);
                console.log('oppInValutazionePerc: ' , oppInValutazionePerc);
                console.log('praticheInLavorazione: ' , praticheInLavorazione);
                console.log('praticheInValutazione: ' , praticheInValutazione);
                console.log('praticheApprovatePerc: ' , praticheApprovatePerc);
                console.log('clientiDaAvviare: ' , clientiDaAvviare);
                console.log('clientiAvviatiPerc: ' , clientiAvviatiPerc);
        
        potenzialiAttuali = (((((((visiteDaSviluppare * rsfFirmatePerc +
                				oppDaCompletare) * oppInValutazionePerc) +
                				praticheInLavorazione) + praticheInValutazione) * praticheApprovatePerc) + 
                				clientiDaAvviare) * clientiAvviatiPerc);                
                
        return potenzialiAttuali;
    },
})