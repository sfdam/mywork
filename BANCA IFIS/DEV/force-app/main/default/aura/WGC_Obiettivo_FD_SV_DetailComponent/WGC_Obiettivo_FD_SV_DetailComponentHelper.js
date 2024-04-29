({
	helperMethod : function() {
		
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

    getWeeksInMonth: function (component, event, year, month) {

      const weeks = [];
      var firstDay = new Date(year, month, 1);
      var lastDay = new Date(year, month + 1, 0);
      var daysInMonth = lastDay.getDate();
      let dayOfWeek = firstDay.getDay();
      let start;
      let end;

      for (let i = 1; i < daysInMonth + 1; i++) {

          if (dayOfWeek === 0 || i === 1) {
              start = i;
          }

          if (dayOfWeek === 6 || i === daysInMonth) {

              end = i;

              

                  weeks.push({
                      start: start,
                      end: end
                  });
              
          }

          dayOfWeek = new Date(year, month, i).getDay();
      }

      return weeks;
    },
    
    reloadData: function (component, event, filter, data) {
        
        const monthNames = [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")];
		
		var today = new Date(Date.now());
        var d = new Date();
        var n = d.getFullYear();
        var m = d.getMonth();
        console.log(m);
        
        var chartJS_Data = { clientiAvviati_actual : [0,0,0,0,0,0,0,0,0,0,0,0], clientiAvviati_budget : [0,0,0,0,0,0,0,0,0,0,0,0], prodotti_actual : [0,0,0,0,0,0,0,0,0,0,0,0], prodotti_budget : [0,0,0,0,0,0,0,0,0,0,0,0], eventi_actual : [0,0,0,0,0,0,0,0,0,0,0,0], eventi_budget : [0,0,0,0,0,0,0,0,0,0,0,0] };
		var chartJS_Data_Clienti = { actual : [0,0,0,0,0,0,0,0,0,0,0,0], budget : [0,0,0,0,0,0,0,0,0,0,0,0], potenziale : [0,0,0,0,0,0,0,0,0,0,0,0], previsione : [0,0,0,0,0,0,0,0,0,0,0,0] };
		var chartJS_Data_Prodotti = { actual : [0,0,0,0,0,0,0,0,0,0,0,0], budget : [0,0,0,0,0,0,0,0,0,0,0,0], potenziale : [0,0,0,0,0,0,0,0,0,0,0,0], previsione : [0,0,0,0,0,0,0,0,0,0,0,0] };

		var weeksList = this.getWeeksInMonth(component, event, n, m);
		console.log(weeksList);
        
        weeksList.forEach(function (element) {
            element.clientiAvviati = 0;
            element.visite = 0;
            element.prodotti = 0;           
		});

		component.set('v.month', monthNames[m]);
        component.set('v.year', n);
        
        var result = data;
        
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
            var clientiAvviatiTotYear = 0;
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
                
                if(filter.isAllUser){
                    
                    if(element.Qualifica_Corporate__c = 'New Business'){
                        
                        if(element.Esito_Visita__c == 'Individuata opportunità' && element.Pratica_Presentata__c == 'Si' && element.hasOwnProperty('Data_Esito_Pratica__c') && (element.hasOwnProperty('Primo_Prodotto__c') && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing') && element.Esito_Pratica__c == 'Approvata'){
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
                                    
                            if(element.hasOwnProperty('Previsione_Avvio_Rapporto__c') && elementYear == n && elementMonth == m && element.Rapporto_Avviato__c == 'Si'){
                                //console.log('ELEMENT', element);
                                //if(element.Id == 'a1h25000001QsXgAAK') console.log('SIIIIIIIIIII', element);

                                let nbElement = {};
                                nbElement.Id        = element.Ragione_Sociale__c;
                                nbElement.Famiglia  = element.Famiglia_Primo_Prodotto__c;
                                find = false;
                                listNewBusinessMonth.forEach(function (el) {
                                    if(el.Id == nbElement.Id && el.Famiglia == nbElement.Famiglia) find = true;
                                });
                                if(!find) {
                                    listNewBusinessMonth.push(nbElement);
                                    
                                    let count = 0;
                                    weeksList.forEach(function (week) {
                                        if(elementDay >= week.start && elementDay <= week.end){
                                            
                                            weeksList[count].clientiAvviati++;
                                        } 
                                        count++;
                                    });
                                    
                                    numAvvio++;
                                    clientiAvviatiTotMonth++;  
                                    clientiAvviatiTotYear++;
                                    chartJS_Data_Clienti.actual[elementMonth]++;
                                    chartJS_Data.clientiAvviati_actual[elementMonth]++;
                                    if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
                                        giorniDifferenzaMagazzino = new Date(element.Data_avvio_rapporto__c) - new Date(element.Data_Visita_Commerciale__c);
                                        diffGiorni += giorniDifferenzaMagazzino / (1000 * 60 * 60 * 24);
                                        dayMagazziono++;  
                                    }              
                                }
                            }
                            if(element.hasOwnProperty('Previsione_Avvio_Rapporto__c') && elementYear == n && elementMonth < m && element.Rapporto_Avviato__c == 'Si'){
                                //console.log('ELEMENT YEAR', element);
                                //if(element.Id == 'a1h25000001QsXgAAK') console.log('SIIIIIIIIIII', element);
                                let nbElementYear = {};
                                nbElementYear.Id        = element.Ragione_Sociale__c;
                                nbElementYear.Famiglia  = element.Famiglia_Primo_Prodotto__c;
                                find = false;
                                listNewBusinessYear.forEach(function (el) {
                                    if(el.Id == nbElementYear.Id && el.Famiglia == nbElementYear.Famiglia) find = true;
                                });
                                if(!find) {
                                    listNewBusinessYear.push(nbElementYear);
                                    clientiAvviatiTotYear++;
                                    chartJS_Data_Clienti.actual[elementMonth]++;
                                    chartJS_Data.clientiAvviati_actual[elementMonth]++;
                                    if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
                                        giorniDifferenzaMagazzino = new Date(element.Data_avvio_rapporto__c) - new Date(element.Data_Visita_Commerciale__c);
                                        diffGiorni += giorniDifferenzaMagazzino / (1000 * 60 * 60 * 24);
                                        dayMagazziono++;  
                                    } 
    
                                }
                            }
                        }                        
                        
                    }
                    
                } else if(filter.teamName != ''){
                    if(usersIdTeam.includes(element.Operatore_Filo_Diretto__c)){
                        if(element.Qualifica_Corporate__c = 'New Business'){
                            
                            if(element.Esito_Visita__c == 'Individuata opportunità' && element.Pratica_Presentata__c == 'Si' && element.hasOwnProperty('Data_Esito_Pratica__c') && (element.hasOwnProperty('Primo_Prodotto__c') && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing') && element.Esito_Pratica__c == 'Approvata'){
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
                                        
                                        let count = 0;
                                        weeksList.forEach(function (week) {
                                            if(elementDay >= week.start && elementDay <= week.end){
                                                
                                                weeksList[count].clientiAvviati++;
                                            } 
                                            count++;
                                        });
                                        
                                        numAvvio++;
                                        clientiAvviatiTotMonth++;  
                                        clientiAvviatiTotYear++;
                                        chartJS_Data_Clienti.actual[elementMonth]++;
                                        chartJS_Data.clientiAvviati_actual[elementMonth]++;
                                        if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
                                            giorniDifferenzaMagazzino = new Date(element.Data_avvio_rapporto__c) - new Date(element.Data_Visita_Commerciale__c);
                                            diffGiorni += giorniDifferenzaMagazzino / (1000 * 60 * 60 * 24);
                                            dayMagazziono++;  
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
                                        clientiAvviatiTotYear++;
                                        chartJS_Data_Clienti.actual[elementMonth]++;
                                        chartJS_Data.clientiAvviati_actual[elementMonth]++;
                                        if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
                                            giorniDifferenzaMagazzino = new Date(element.Data_avvio_rapporto__c) - new Date(element.Data_Visita_Commerciale__c);
                                            diffGiorni += giorniDifferenzaMagazzino / (1000 * 60 * 60 * 24);
                                            dayMagazziono++;  
                                    	}
        
                                    }
                                }
                            }                        
                        
                        }
                    }
                    

                } else {
                    if(filter.userId == element.Operatore_Filo_Diretto__c){
                        if(element.Qualifica_Corporate__c = 'New Business'){
                            
                            
                            if(element.Esito_Visita__c == 'Individuata opportunità' && element.Pratica_Presentata__c == 'Si' && element.hasOwnProperty('Data_Esito_Pratica__c') && (element.hasOwnProperty('Primo_Prodotto__c') && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing') && element.Esito_Pratica__c == 'Approvata'){
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
                                        
                                        let count = 0;
                                        weeksList.forEach(function (week) {
                                            if(elementDay >= week.start && elementDay <= week.end){
                                                
                                                weeksList[count].clientiAvviati++;
                                            } 
                                            count++;
                                        });
                                        
                                        numAvvio++;
                                        clientiAvviatiTotMonth++;  
                                        clientiAvviatiTotYear++;
                                        chartJS_Data_Clienti.actual[elementMonth]++;
                                        chartJS_Data.clientiAvviati_actual[elementMonth]++;
                                        if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
                                            giorniDifferenzaMagazzino = new Date(element.Data_avvio_rapporto__c) - new Date(element.Data_Visita_Commerciale__c);
                                            diffGiorni += giorniDifferenzaMagazzino / (1000 * 60 * 60 * 24);
                                            dayMagazziono++;  
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
                                        clientiAvviatiTotYear++;
                                        chartJS_Data_Clienti.actual[elementMonth]++;
                                        chartJS_Data.clientiAvviati_actual[elementMonth]++;
                                        if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Visita_Commerciale__c') && element.Data_avvio_rapporto__c >= element.Data_Visita_Commerciale__c){
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
                
            });
                                                       
            component.set('v.clientiAvviatiTot_Month', clientiAvviatiTotMonth);
			component.set('v.clientiAvviatiTot_Year', clientiAvviatiTotYear);
        
        console.log('workmonth', result.data[0].workMonth);
        console.log('dayMagazziono ', dayMagazziono);
        console.log('diffGiorni ', diffGiorni);
                        
        	chartJS_Data_Clienti.previsione[m] = (numPrevisione - numAvvio) > 0 ? numPrevisione - numAvvio : 0;
        //component.set('v.potenziale', ( dayMagazziono > 0 && (diffGiorni / dayMagazziono) > 0 ) ? Math.ceil( (result.data[0].workMonth / (diffGiorni / dayMagazziono) ) * this.calcolaPotenzialiAttuali(component, event, result.data[0].dettaglioVisiteList, usersIdTeam, filter) ) : 0);
        chartJS_Data_Clienti.potenziale[m] = ( dayMagazziono > 0 && (diffGiorni / dayMagazziono) > 0 ) ? Math.ceil( (result.data[0].workMonth / (diffGiorni / dayMagazziono) ) * this.calcolaPotenzialiAttuali(component, event, result.data[0].dettaglioVisiteList, usersIdTeam, filter) ) : 0;
            
        	var prodottiTotMonth = 0;
            var prodottiTotYear = 0;
            var listPortafoglioMonth = [];
            var listPortafoglioYear = [];
        
            result.data[0].ProdottodettaglioVisiteList.forEach(function (element) {
                var elementDate = new Date(element.Data_ultima_cessione__c);
                var elementYear = elementDate.getFullYear();
                var elementMonth = elementDate.getMonth();
                var elementDay = elementDate.getDate();
                
                if(filter.isAllUser){
                    
                    if(element.Dettaglio_Visite__r.Qualifica_Corporate__c == 'New Business'){
                        if(elementYear == n && elementMonth == m){
                            let nbElement = {};                        
                            nbElement.Id        = element.Dettaglio_Visite__c;
                            nbElement.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listNewBusinessMonth.forEach(function (el) {
                                if(el.Id == nbElement.Id && el.Famiglia == nbElement.Famiglia) find = true;
                            });
                            if(!find) {
                                listNewBusinessMonth.push(nbElement);
                                
                                let count = 0;
                                weeksList.forEach(function (week) {
                                    if(elementDay >= week.start && elementDay <= week.end){
                                        
                                        weeksList[count].prodotti++;
                                    } 
                                    count++;
                                });
                                
                                prodottiTotMonth++; 
                                prodottiTotYear++; 
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                        		chartJS_Data.prodotti_actual[elementMonth]++;
                            }
                        }
                        if(elementYear == n && elementMonth < m){
                            let nbElementYear = {};
                            nbElementYear.Id        = element.Dettaglio_Visite__c;
                            nbElementYear.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listNewBusinessYear.forEach(function (el) {
                                if(el.Id == nbElementYear.Id && el.Famiglia == nbElementYear.Famiglia) find = true;
                            });
                            if(!find) {
                                listNewBusinessYear.push(nbElementYear);
                                prodottiTotYear++;  
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                        		chartJS_Data.prodotti_actual[elementMonth]++;
                            }
                        }
                    } else {
                        if(elementYear == n && elementMonth == m){                       
                            let nbElement = {};                        
                            nbElement.Id        = element.Dettaglio_Visite__c;
                            nbElement.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listPortafoglioMonth.forEach(function (el) {
                                if(el.Id == nbElement.Id && el.Famiglia == nbElement.Famiglia) find = true;
                            });
                            if(!find) {
                                listPortafoglioMonth.push(nbElement);
                                let count = 0;
                                weeksList.forEach(function (week) {
                                    if(elementDay >= week.start && elementDay <= week.end){
                                        
                                        weeksList[count].prodotti++;
                                    } 
                                    count++;
                                });
                                
                                prodottiTotMonth++;  
                                prodottiTotYear++; 
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                        		chartJS_Data.prodotti_actual[elementMonth]++;
                            }
                            
                        }
                        if(elementYear == n && elementMonth < m){                        
                            let nbElementYear = {};
                            nbElementYear.Id        = element.Dettaglio_Visite__c;
                            nbElementYear.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listPortafoglioYear.forEach(function (el) {
                                if(el.Id == nbElementYear.Id && el.Famiglia == nbElementYear.Famiglia) find = true;
                            });
                            if(!find) {
                                listPortafoglioYear.push(nbElementYear);
                                prodottiTotYear++; 
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                        		chartJS_Data.prodotti_actual[elementMonth]++;
                            }
                        }
                    }
                    
                }else if(filter.teamName != ''){
                    if(usersIdTeam.includes(element.Dettaglio_Visite__r.Operatore_Filo_Diretto__c)){
                        if(element.Dettaglio_Visite__r.Qualifica_Corporate__c == 'New Business'){
                        if(elementYear == n && elementMonth == m){
                            let nbElement = {};                        
                            nbElement.Id        = element.Dettaglio_Visite__c;
                            nbElement.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listNewBusinessMonth.forEach(function (el) {
                                if(el.Id == nbElement.Id && el.Famiglia == nbElement.Famiglia) find = true;
                            });
                            if(!find) {
                                listNewBusinessMonth.push(nbElement);
                                
                                let count = 0;
                                weeksList.forEach(function (week) {
                                    if(elementDay >= week.start && elementDay <= week.end){
                                        
                                        weeksList[count].prodotti++;
                                    } 
                                    count++;
                                });
                                
                                prodottiTotMonth++; 
                                prodottiTotYear++; 
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                        		chartJS_Data.prodotti_actual[elementMonth]++;
                            }
                        }
                        if(elementYear == n && elementMonth < m){
                            let nbElementYear = {};
                            nbElementYear.Id        = element.Dettaglio_Visite__c;
                            nbElementYear.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listNewBusinessYear.forEach(function (el) {
                                if(el.Id == nbElementYear.Id && el.Famiglia == nbElementYear.Famiglia) find = true;
                            });
                            if(!find) {
                                listNewBusinessYear.push(nbElementYear);
                                prodottiTotYear++;
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                        		chartJS_Data.prodotti_actual[elementMonth]++;
                            }
                        }
                    } else {
                        if(elementYear == n && elementMonth == m){                       
                            let nbElement = {};                        
                            nbElement.Id        = element.Dettaglio_Visite__c;
                            nbElement.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listPortafoglioMonth.forEach(function (el) {
                                if(el.Id == nbElement.Id && el.Famiglia == nbElement.Famiglia) find = true;
                            });
                            if(!find) {
                                listPortafoglioMonth.push(nbElement);
                                
                                let count = 0;
                                weeksList.forEach(function (week) {
                                    if(elementDay >= week.start && elementDay <= week.end){
                                        
                                        weeksList[count].prodotti++;
                                    } 
                                    count++;
                                });
                                
                                prodottiTotMonth++;
                                prodottiTotYear++; 
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                        		chartJS_Data.prodotti_actual[elementMonth]++;
                            }
                            
                        }
                        if(elementYear == n && elementMonth < m){                        
                            let nbElementYear = {};
                            nbElementYear.Id        = element.Dettaglio_Visite__c;
                            nbElementYear.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listPortafoglioYear.forEach(function (el) {
                                if(el.Id == nbElementYear.Id && el.Famiglia == nbElementYear.Famiglia) find = true;
                            });
                            if(!find) {
                                listPortafoglioYear.push(nbElementYear);
                                prodottiTotYear++; 
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                        		chartJS_Data.prodotti_actual[elementMonth]++;
                            }
                        }
                    }
                    }
                }else{
                    if(filter.userId == element.Dettaglio_Visite__r.Operatore_Filo_Diretto__c){
                        if(element.Dettaglio_Visite__r.Qualifica_Corporate__c == 'New Business'){
                        if(elementYear == n && elementMonth == m){
                            let nbElement = {};                        
                            nbElement.Id        = element.Dettaglio_Visite__c;
                            nbElement.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listNewBusinessMonth.forEach(function (el) {
                                if(el.Id == nbElement.Id && el.Famiglia == nbElement.Famiglia) find = true;
                            });
                            if(!find) {
                                
                                listNewBusinessMonth.push(nbElement);
                                
                                let count = 0;
                                weeksList.forEach(function (week) {
                                    if(elementDay >= week.start && elementDay <= week.end){
                                        
                                        weeksList[count].prodotti++;
                                    } 
                                    count++;
                                });
                                prodottiTotMonth++;
								prodottiTotYear++; 
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                        		chartJS_Data.prodotti_actual[elementMonth]++;
                            }
                        }
                        if(elementYear == n && elementMonth < m){
                            let nbElementYear = {};
                            nbElementYear.Id        = element.Dettaglio_Visite__c;
                            nbElementYear.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listNewBusinessYear.forEach(function (el) {
                                if(el.Id == nbElementYear.Id && el.Famiglia == nbElementYear.Famiglia) find = true;
                            });
                            if(!find) {
                                listNewBusinessYear.push(nbElementYear);
                                prodottiTotYear++;  
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                        		chartJS_Data.prodotti_actual[elementMonth]++;
                            }
                        }
                    } else {
                        if(elementYear == n && elementMonth == m){                       
                            let nbElement = {};                        
                            nbElement.Id        = element.Dettaglio_Visite__c;
                            nbElement.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listPortafoglioMonth.forEach(function (el) {
                                if(el.Id == nbElement.Id && el.Famiglia == nbElement.Famiglia) find = true;
                            });
                            if(!find) {
                                listPortafoglioMonth.push(nbElement);
                                
                                let count = 0;
                                weeksList.forEach(function (week) {
                                    if(elementDay >= week.start && elementDay <= week.end){
                                        
                                        weeksList[count].prodotti++;
                                    } 
                                    count++;
                                });
                                
                                prodottiTotMonth++;  
                                prodottiTotYear++; 
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                            }
                            
                        }
                        if(elementYear == n && elementMonth < m){                        
                            let nbElementYear = {};
                            nbElementYear.Id        = element.Dettaglio_Visite__c;
                            nbElementYear.Famiglia  = element.Famiglia_Prodotto__c;
                            
                            find = false;
                            listPortafoglioYear.forEach(function (el) {
                                if(el.Id == nbElementYear.Id && el.Famiglia == nbElementYear.Famiglia) find = true;
                            });
                            if(!find) {
                                listPortafoglioYear.push(nbElementYear);
                                prodottiTotYear++;  
                        		chartJS_Data_Prodotti.actual[elementMonth]++;
                        		chartJS_Data.prodotti_actual[elementMonth]++;
                            }
                        }
                    }
                    }
                }
                
            });
            
            component.set('v.prodottiTot_Month', prodottiTotMonth);  
            // media component.set('v.prodottiTot_Year', Math.round(prodottiTotYear / (m  + 1)));
            component.set('v.prodottiTot_Year', prodottiTotYear);
            
            var accountInVisId_Month = [];
            var accountInVisId_Year = [];
            var visiteTotMonth = 0;
            var visiteTotYear = 0;
            result.data[0].eventList.forEach(function (element) {
                var elementDate = new Date(element.WGC_Data_Creazione__c);
                var elementYear = elementDate.getFullYear();
                var elementMonth = elementDate.getMonth();
                var elementDay = elementDate.getDate();
                
                if(filter.isAllUser){
                    
                    if (!accountInVisId_Month.includes(element.AccountId)) {
                        if(today.getMonth() === elementDate.getMonth()){
                            
                            let count = 0;
                            weeksList.forEach(function (week) {
                                if(elementDay >= week.start && elementDay <= week.end){
                                    weeksList[count].visite++;
                                } 
                                count++;
                            });
                            
                            visiteTotMonth++;         
                            accountInVisId_Month.push(element.AccountId);
                        }
                    }
                    if (!accountInVisId_Year.includes(element.AccountId)) {
                        if(elementYear == n && elementMonth <= m){
                            
                            accountInVisId_Year.push(element.AccountId);
                            visiteTotYear++;
                            chartJS_Data.eventi_actual[elementMonth]++;
                        }
                    }
                    
                }else if(filter.teamName != ''){
                    if(usersIdTeam.includes(element.CreatedById)){
                        if (!accountInVisId_Month.includes(element.AccountId)) {
                        if(today.getMonth() === elementDate.getMonth()){
                            
                            let count = 0;
                            weeksList.forEach(function (week) {
                                if(elementDay >= week.start && elementDay <= week.end){
                                    weeksList[count].visite++;
                                } 
                                count++;
                            });
                            
                            visiteTotMonth++;         
                            accountInVisId_Month.push(element.AccountId);
                        }
                    }
                    if (!accountInVisId_Year.includes(element.AccountId)) {
                        if(elementYear == n && elementMonth <= m){
                            
                            accountInVisId_Year.push(element.AccountId);
                            visiteTotYear++;
                            chartJS_Data.eventi_actual[elementMonth]++;
                        }
                    }
                    }
                }else {
                    if(filter.userId == element.CreatedById){
                        if (!accountInVisId_Month.includes(element.AccountId)) {
                        if(today.getMonth() === elementDate.getMonth()){
                            
                            let count = 0;
                            weeksList.forEach(function (week) {
                                if(elementDay >= week.start && elementDay <= week.end){
                                    weeksList[count].visite++;
                                } 
                                count++;
                            });
                            
                            visiteTotMonth++;         
                            accountInVisId_Month.push(element.AccountId);
                        }
                    }
                    if (!accountInVisId_Year.includes(element.AccountId)) {
                        if(elementYear == n && elementMonth <= m){
                            
                            accountInVisId_Year.push(element.AccountId);
                            visiteTotYear++;
                            chartJS_Data.eventi_actual[elementMonth]++;
                        }
                    }
                    }
                }

                                    
            });

            component.set('v.visiteTot_Month', visiteTotMonth);  
			component.set('v.visiteTot_Year', visiteTotYear);
            
            var budgetTotYear_clientiAvviati = 0;
            var budgetTotYear_prodotti = 0;
            var budgetTotYear_visite = 0;
        
        	var clientiAvviatiTot_Month_Budget = 0;
        	var prodottiTot_Month_Budget = 0;
        	var visiteTot_Month_Budget = 0;
        
        	var clientiAvviatiTot_Month_Obiettivo = 0;
        	var prodottiTot_Month_Obiettivo = 0;
        	var visiteTot_Month_Obiettivo = 0;
        
        	var Clienti_avviati_FD_revisionati = 0;
            var Prodotti_venduti_FD_revisionati = 0;
            var Visite_FD_revisionate = 0;
        
            result.data[0].budgetList.forEach(function (element) {
                
                if(filter.isAllUser){
                    if (element.Mese__c - 1 <= today.getMonth()){
                    
                    chartJS_Data.clientiAvviati_budget[element.Mese__c - 1] = chartJS_Data.clientiAvviati_budget[element.Mese__c - 1] + element.Clienti_avviati_FD_revisionati__c;
                    chartJS_Data.prodotti_budget[element.Mese__c - 1] = chartJS_Data.prodotti_budget[element.Mese__c - 1] + element.Prodotti_venduti_FD_revisionati__c;
                    chartJS_Data.eventi_budget[element.Mese__c - 1] = chartJS_Data.eventi_budget[element.Mese__c - 1] + element.Visite_FD_revisionate__c;
                    
                    chartJS_Data_Clienti.budget[element.Mese__c - 1] = chartJS_Data_Clienti.budget[element.Mese__c - 1] + element.Clienti_avviati_FD_revisionati__c;
                    
                    chartJS_Data_Prodotti.budget[element.Mese__c - 1] = chartJS_Data_Prodotti.budget[element.Mese__c - 1] + element.Prodotti_venduti_FD_revisionati__c;
                }
                if (element.Mese__c - 1 == today.getMonth()){
                    clientiAvviatiTot_Month_Budget = clientiAvviatiTot_Month_Budget + element.Clienti_avviati_FD_revisionati__c;
                    prodottiTot_Month_Budget = prodottiTot_Month_Budget + element.Prodotti_venduti_FD_revisionati__c;
                    visiteTot_Month_Budget = visiteTot_Month_Budget + element.Visite_FD_revisionate__c;
                    
                    Clienti_avviati_FD_revisionati = Clienti_avviati_FD_revisionati + element.Clienti_avviati_FD_revisionati__c;
                    Prodotti_venduti_FD_revisionati = Prodotti_venduti_FD_revisionati + element.Prodotti_venduti_FD_revisionati__c;
                    Visite_FD_revisionate = Visite_FD_revisionate + element.Visite_FD_revisionate__c;
                    
                    
                }
                if(element.Mese__c -1 <= m){
                    budgetTotYear_clientiAvviati = budgetTotYear_clientiAvviati + element.Clienti_avviati_FD_revisionati__c;
                    budgetTotYear_prodotti = budgetTotYear_prodotti + element.Prodotti_venduti_FD_revisionati__c;
                    budgetTotYear_visite = budgetTotYear_visite + element.Visite_FD_revisionate__c;
                }
                    
                } else if(filter.teamName != ''){
                    if(usersIdTeam.includes(element.OwnerId)){
                        if (element.Mese__c - 1 <= today.getMonth()){
                    
                    chartJS_Data.clientiAvviati_budget[element.Mese__c - 1] = chartJS_Data.clientiAvviati_budget[element.Mese__c - 1] + element.Clienti_avviati_FD_revisionati__c;
                    chartJS_Data.prodotti_budget[element.Mese__c - 1] = chartJS_Data.prodotti_budget[element.Mese__c - 1] + element.Prodotti_venduti_FD_revisionati__c;
                    chartJS_Data.eventi_budget[element.Mese__c - 1] = chartJS_Data.eventi_budget[element.Mese__c - 1] + element.Visite_FD_revisionate__c;
                    
                    chartJS_Data_Clienti.budget[element.Mese__c - 1] = chartJS_Data_Clienti.budget[element.Mese__c - 1] + element.Clienti_avviati_FD_revisionati__c;
                    
                    chartJS_Data_Prodotti.budget[element.Mese__c - 1] = chartJS_Data_Prodotti.budget[element.Mese__c - 1] + element.Prodotti_venduti_FD_revisionati__c;
                }
                if (element.Mese__c - 1 == today.getMonth()){
                    clientiAvviatiTot_Month_Budget = clientiAvviatiTot_Month_Budget + element.Clienti_avviati_FD_revisionati__c;
                    prodottiTot_Month_Budget = prodottiTot_Month_Budget + element.Prodotti_venduti_FD_revisionati__c;
                    visiteTot_Month_Budget = visiteTot_Month_Budget + element.Visite_FD_revisionate__c;
                    
                    
                    Clienti_avviati_FD_revisionati = Clienti_avviati_FD_revisionati + element.Clienti_avviati_FD_revisionati__c;
                    Prodotti_venduti_FD_revisionati = Prodotti_venduti_FD_revisionati + element.Prodotti_venduti_FD_revisionati__c;
                    Visite_FD_revisionate = Visite_FD_revisionate + element.Visite_FD_revisionate__c;
                }
                if(element.Mese__c -1 <= m){
                    budgetTotYear_clientiAvviati = budgetTotYear_clientiAvviati + element.Clienti_avviati_FD_revisionati__c;
                    budgetTotYear_prodotti = budgetTotYear_prodotti + element.Prodotti_venduti_FD_revisionati__c;
                    budgetTotYear_visite = budgetTotYear_visite + element.Visite_FD_revisionate__c;
                }
                    }
                } else {
                    if(filter.userId == element.OwnerId){
                        if (element.Mese__c - 1 <= today.getMonth()){
                    
                    chartJS_Data.clientiAvviati_budget[element.Mese__c - 1] = element.Clienti_avviati_FD_revisionati__c;
                    chartJS_Data.prodotti_budget[element.Mese__c - 1] = element.Prodotti_venduti_FD_revisionati__c;
                    chartJS_Data.eventi_budget[element.Mese__c - 1] = element.Visite_FD_revisionate__c;
                    
                    chartJS_Data_Clienti.budget[element.Mese__c - 1] = element.Clienti_avviati_FD_revisionati__c;
                    
                    chartJS_Data_Prodotti.budget[element.Mese__c - 1] = element.Prodotti_venduti_FD_revisionati__c;
                }
                if (element.Mese__c - 1 == today.getMonth()){
                    clientiAvviatiTot_Month_Budget = clientiAvviatiTot_Month_Budget + element.Clienti_avviati_FD_revisionati__c;
                    prodottiTot_Month_Budget = prodottiTot_Month_Budget + element.Prodotti_venduti_FD_revisionati__c;
                    visiteTot_Month_Budget = visiteTot_Month_Budget + element.Visite_FD_revisionate__c;
                    
                    
                    Clienti_avviati_FD_revisionati = Clienti_avviati_FD_revisionati + element.Clienti_avviati_FD_revisionati__c;
                    Prodotti_venduti_FD_revisionati = Prodotti_venduti_FD_revisionati + element.Prodotti_venduti_FD_revisionati__c;
                    Visite_FD_revisionate = Visite_FD_revisionate + element.Visite_FD_revisionate__c;
                }
                if(element.Mese__c -1 <= m){
                    budgetTotYear_clientiAvviati = budgetTotYear_clientiAvviati + element.Clienti_avviati_FD_revisionati__c;
                    budgetTotYear_prodotti = budgetTotYear_prodotti + element.Prodotti_venduti_FD_revisionati__c;
                    budgetTotYear_visite = budgetTotYear_visite + element.Visite_FD_revisionate__c;
                }
                    }
                }                
            });
            
            component.set('v.clientiAvviatiTot_Budget_Year', Math.round(budgetTotYear_clientiAvviati / (m  + 1)));
            component.set('v.prodottiTot_Budget_Year', Math.round(budgetTotYear_prodotti / (m  + 1)));
            component.set('v.visiteTot_Budget_Year', Math.round(budgetTotYear_visite / (m  + 1)));
        
        	
        	component.set('v.clientiAvviatiTot_Month_Budget', clientiAvviatiTot_Month_Budget);
            component.set('v.prodottiTot_Month_Budget', prodottiTot_Month_Budget);
            component.set('v.visiteTot_Month_Budget', visiteTot_Month_Budget);
     
        component.set('v.clientiAvviatiTot_Month_Obiettivo', (Clienti_avviati_FD_revisionati > 0 ? (clientiAvviatiTotMonth / Clienti_avviati_FD_revisionati) > 1 ? 1: (clientiAvviatiTotMonth / Clienti_avviati_FD_revisionati) : 0));
        component.set('v.prodottiTot_Month_Obiettivo', (Prodotti_venduti_FD_revisionati > 0 ? (prodottiTotMonth / Prodotti_venduti_FD_revisionati) > 1 ? 1 : (prodottiTotMonth / Prodotti_venduti_FD_revisionati) : 0));
        component.set('v.visiteTot_Month_Obiettivo', (Visite_FD_revisionate > 0 ? (visiteTotMonth / Visite_FD_revisionate) > 1 ? 1 : (visiteTotMonth / Visite_FD_revisionate) : 0));
            

            
            component.set('v.weeks', weeksList);
        
        	this.generateChart(this.dataChart(chartJS_Data_Clienti, 1, component, event), this.optionsChart(null, 1, component, event), 'bar', 'chartJS_Clienti', component, event);
            this.generateChart(this.dataChart(chartJS_Data_Prodotti, 2, component, event), this.optionsChart(null, 2, component, event), 'bar', 'chartJS_Prodotti', component, event);
            this.generateChart(this.dataChart(chartJS_Data, 3, component, event), this.optionsChart(null, 3, component, event), 'bar', 'chartJS_BP', component, event);
        
    },
    
    generateChart: function (data, chartOptions, type, ctxName, component, event) {

        var itemNode = document.getElementById(ctxName);
        
        if (itemNode != null) {
          itemNode.parentNode.removeChild(itemNode);
          if(ctxName == 'chartJS_BP') document.getElementById('container_' + ctxName).innerHTML = '<canvas style="height:60vh" id="' + ctxName + '"' + '></canvas>';
          else document.getElementById('container_' + ctxName).innerHTML = '<canvas style="height:35vh" id="' + ctxName + '"' + '></canvas>';
          
          var myChart = new Chart(ctxName, {
            type: type,
            data: data,
            options: chartOptions
          });
        }
      },
    
      optionsChart: function (step, chart, component, event) {

        var chartOptions = {};

        if(chart == 1 || chart == 2){
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
                  mode: 'x',
                  callbacks: {
                    label: function (tooltipItem, data) {
                        console.log('data.datasets[tooltipItem.datasetIndex].label', data.datasets[tooltipItem.datasetIndex].label);
                      var corporation = data.datasets[tooltipItem.datasetIndex].label;
                      //return corporation + ': ' + ((chart == 1) ? (new Intl.NumberFormat('it-IT').format(tooltipItem.yLabel)) : (parseFloat(tooltipItem.yLabel).toFixed(2)+"%"));
                      return corporation + ': ' + (new Intl.NumberFormat('it-IT').format(tooltipItem.yLabel));
                    }
                  },
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

        } else {

            chartOptions = {
                responsive: true,
                maintainAspectRatio: false,
                // layout: { padding: { top: 0, right: 0, down: 0, lefth: 0 } },
                legend: {
                    display: false,
                },
                tooltips: {
                    enabled: true,
                    mode: 'label',
                    callbacks: {
                        title: function() {}
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
                        display: true,
                        ticks: {
                            reverse: false,
                            beginAtZero: true,
                        }
                    }],
                    xAxes: [{
                        // categoryPercentage: 1.0,
                        ticks: {
                            display: true,
                            min: 0,
                            // autoSkip: false
                        },
    
                        // stacked: true,
                        // gridLines: {
                        // 	offsetGridLines: false
                        // }
                    }],
    
                }
            };

        }
    
        
    
        return chartOptions;
      },
    
      dataChart: function (data, chart, component, event) {
    
        console.log('SV dataChart', data, chart);
        if (chart == 1){
          data = {
            labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
            datasets: [
              {
                label: "Budget",
                backgroundColor: 'rgba(166, 162, 166, 0.75)',
                borderColor: 'rgba(166, 162, 166, 1)',
                fill: true,
                stack: 'budget',
                data: data.budget
              }, {
                label: "Actual",
                backgroundColor: 'rgba(246, 167, 36, 0.75)',
                borderColor: 'rgba(246, 167, 36, 1)',
                fill: true,
                stack: 'actual_previsione',
                data: data.actual
              }, {
                label: "Previsione",
                backgroundColor: 'rgba(246, 216, 24, 0.75)',
                borderColor: 'rgba(246, 216, 24, 1)',
                fill: true,
                stack: 'actual_previsione',
                data: data.previsione
              }, {
                label: "Potenziale",
                backgroundColor: 'rgba(71, 146, 225, 0.75)',
                borderColor: 'rgba(71, 146, 225, 1)',
                fill: true,
                stack: 'potenziale',
                data: data.potenziale
              }
            ]
          };
        } else if (chart == 2){
          data = {
            labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
            datasets: [
                {
                  label: "Budget",
                  backgroundColor: 'rgba(166, 162, 166, 0.75)',
                  borderColor: 'rgba(166, 162, 166, 1)',
                  fill: false,
                  stack: 'budget',
                  data: data.budget
                }, {
                  label: "Actual",
                  backgroundColor: 'rgba(246, 167, 36, 0.75)',
                  borderColor: 'rgba(246, 167, 36, 1)',
                  fill: false,
                  stack: 'actual',
                  data: data.actual
                }
              ]
          };
        } else {
            data = {
                labels: [['V    C    P', $A.get("$Label.c.WGC_Gennaio")], ['V    C    P', $A.get("$Label.c.WGC_Febbraio")], ['V    C    P', $A.get("$Label.c.WGC_Marzo")], ['V    C    P', $A.get("$Label.c.WGC_Aprile")], ['V    C    P', $A.get("$Label.c.WGC_Maggio")], ['V    C    P', $A.get("$Label.c.WGC_Giugno")], ['V    C    P', $A.get("$Label.c.WGC_Luglio")], ['V    C    P', $A.get("$Label.c.WGC_Agosto")], ['V    C    P', $A.get("$Label.c.WGC_Settembre")], ['V    C    P', $A.get("$Label.c.WGC_Ottobre")], ['V    C    P', $A.get("$Label.c.WGC_Novembre")], ['V    C    P', $A.get("$Label.c.WGC_Dicembre")]],
                // labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
                datasets: [
                    {
                        label: "Visite Budget",
                        backgroundColor: 'rgba(198, 212, 229, 0.75)',
                        borderColor: 'rgba(198, 212, 229, 1)',
                        //stack: 'stackOpp',
                        data: data.eventi_budget
                    }, {
                        label: "Visite Actual",
                        backgroundColor: '#0064B5',
                        borderColor: 'rgba(74, 144, 226, 1)',
                        //stack: 'stackOpp',
                        data: data.eventi_actual
                    }, {
                        label: "Clienti avviati Budget",
                        backgroundColor: 'rgba(170, 239, 173, 0.75)',
                        borderColor: 'rgba(170, 239, 173, 1)',
                        //stack: 'stackOpp',
                        data: data.clientiAvviati_budget
                    }, {
                        label: "Clienti avviati Actual",
                        backgroundColor: 'rgba(44, 198, 41, 0.75)',
                        borderColor: 'rgba(44, 198, 41, 1)',
                        //stack: 'stackOpp',
                        data: data.clientiAvviati_actual
                    }, {
                        label: "Prodotti Budget",
                        backgroundColor: 'rgba(249, 172, 233, 0.75)',
                        borderColor: 'rgba(249, 172, 233, 1)',
                        //stack: 'stackOpp',
                        data: data.prodotti_budget
                    }, {
                        label: "Prodotti Actual",
                        backgroundColor: 'rgba(255, 127, 197, 0.75)',
                        borderColor: 'rgba(255, 127, 197, 1)',
                        //stack: 'stackOpp',
                        data: data.prodotti_actual
                    }
                ]
            };

        }
    
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
        
        rsfFirmatePerc = (visiteDaSviluppare + rsfFirmate + rsfNonFirmate) > 0 ? ( visiteDaSviluppare / (visiteDaSviluppare + rsfFirmate + rsfNonFirmate) ) : 0;
        praticheInviatePEFPerc = ( praticheInviatePEF + praticheDaCompletare + praticheAbbandonate ) > 0 ? ( praticheInviatePEF / ( praticheInviatePEF + praticheDaCompletare + praticheAbbandonate ) ) : 0;
        
        clientiAvviatiPerc = ( clientiDaAvviare + clientiNonAvviati + clientiAvviati ) > 0 ? ( clientiAvviati / ( clientiDaAvviare + clientiNonAvviati + clientiAvviati ) ) : 0;
        
        praticheApprovatePerc = (praticheApprovate + praticheInLavorazione + praticheInValutazione + praticheDeclinate) > 0 ? ( praticheApprovate / (praticheApprovate + praticheInLavorazione + praticheInValutazione + praticheDeclinate) ) : 0;

        potenzialiAttuali = ( visiteDaSviluppare * ( rsfFirmatePerc * praticheInviatePEFPerc * praticheApprovatePerc * clientiAvviatiPerc) ) + 
                            ( praticheInviatePEF * ( praticheApprovatePerc * clientiAvviatiPerc ) ) + 
                            ( clientiDaAvviare * clientiAvviatiPerc );
        console.table('potenzialiAttuali', potenzialiAttuali);
        return potenzialiAttuali;
        
    },*/
    
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
        });
                
        let rsfFirmatePerc = (visitePositive + visiteRSFNonFirmate + visiteInCorsoDiSviluppo + visiteDaSviluppare) > 0 ? parseFloat( ( visitePositive / (visitePositive + visiteRSFNonFirmate + visiteInCorsoDiSviluppo + visiteDaSviluppare)).toFixed(2))  : 0;
        let oppInValutazionePerc = (oppInValutazione + oppSenzaOpp + oppDaCompletare + oppAbbandonate) > 0 ? parseFloat( ( oppInValutazione / (oppInValutazione + oppSenzaOpp + oppDaCompletare + oppAbbandonate)).toFixed(2)) : 0;
        let praticheApprovatePerc = (praticheApprovate + praticheInLavorazione + praticheInValutazione + praticheDeclinate) > 0 ? parseFloat( ( praticheApprovate / (praticheApprovate + praticheInLavorazione + praticheInValutazione + praticheDeclinate)).toFixed(2)) : 0;
        let clientiAvviatiPerc = (clientiAvviati + clientiDaAvviare + clientiNonAvviati) > 0 ? parseFloat( ( clientiAvviati / (clientiAvviati + clientiDaAvviare + clientiNonAvviati)).toFixed(2)) : 0;
        
        /*potenzialiAttuali = ( visiteDaSviluppare * ( rsfFirmatePerc * oppInValutazionePerc * praticheApprovatePerc * clientiAvviatiPerc) ) + 
                            ( oppInValutazione * ( praticheApprovatePerc * clientiAvviatiPerc ) ) + 
                            ( clientiDaAvviare * clientiAvviatiPerc );*/
        
        potenzialiAttuali = (((((((visiteDaSviluppare * rsfFirmatePerc +
                				oppDaCompletare) * oppInValutazionePerc) +
                				praticheInLavorazione) + praticheInValutazione) * praticheApprovatePerc) + 
                				clientiDaAvviare) * clientiAvviatiPerc);
        
        return potenzialiAttuali;
    },
    
    showSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");

    },

    hideSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");

    },
})