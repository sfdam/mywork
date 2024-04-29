({
	doInit : function(component, event, helper) {
        var pg = component.get("v.pageReference");
        console.log('@@@ pg ' , JSON.stringify(pg));
        component.set("v.isDirezioneFD", pg.state.c__isDirezioneFD);

        if(pg.state.c__isDirezioneFD){
            component.set("v.title", "L'OBIETTIVO");
        }
        //var num = helper.workingDaysBetweenDates('2019-09-01', '2019-09-30');
        //console.log('SV NUM', num);

		const monthNames = [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")];
		
		var today = new Date(Date.now());
        var d = new Date();
        var n = d.getFullYear();
        var m = d.getMonth();
        console.log(m);
		var weeksList = helper.getWeeksInMonth(component, event, n, m);

		console.log(weeksList);

		component.set('v.month', monthNames[m]);
        component.set('v.year', n);
			
		var chartJS_Data = { clientiAvviati_actual : [0,0,0,0,0,0,0,0,0,0,0,0], clientiAvviati_budget : [0,0,0,0,0,0,0,0,0,0,0,0], prodotti_actual : [0,0,0,0,0,0,0,0,0,0,0,0], prodotti_budget : [0,0,0,0,0,0,0,0,0,0,0,0], eventi_actual : [0,0,0,0,0,0,0,0,0,0,0,0], eventi_budget : [0,0,0,0,0,0,0,0,0,0,0,0] };
		var chartJS_Data_Clienti = { actual : [0,0,0,0,0,0,0,0,0,0,0,0], budget : [0,0,0,0,0,0,0,0,0,0,0,0], potenziale : [0,0,0,0,0,0,0,0,0,0,0,0], previsione : [0,0,0,0,0,0,0,0,0,0,0,0] };
		var chartJS_Data_Prodotti = { actual : [0,0,0,0,0,0,0,0,0,0,0,0], budget : [0,0,0,0,0,0,0,0,0,0,0,0], potenziale : [0,0,0,0,0,0,0,0,0,0,0,0], previsione : [0,0,0,0,0,0,0,0,0,0,0,0] };

        weeksList.forEach(function (element) {
            element.clientiAvviati = 0;
            element.clientiAvviatiBP = 0;
            element.visite = 0;
            element.visiteBP = 0;
            element.prodotti = 0;
            element.prodottiBP = 0;            
		});

		helper.apex(component, event, 'getAllData', {})
		.then($A.getCallback(function (result) {
			console.log('Call getAllData result: ', result);
            component.set('v.allDataValue', result);

                       
            var dayMagazziono = 0;
            var numPrevisione = 0;
            var numAvvio = 0;
            result.data[0].dettaglioVisiteList.forEach(function (element) {
                var elementDate = new Date(element.Data_Visita_Commerciale__c);
                var elementYear = elementDate.getFullYear();
                var elementMonth = elementDate.getMonth();

                var elementPrevisioneDate = new Date(element.Previsione_Avvio_Rapporto__c);
                var elementtPrevisioneYear = elementPrevisioneDate.getFullYear();
                var elementPrevisioneMonth = elementPrevisioneDate.getMonth();

                var elementAvvioDate = new Date(element.Data_avvio_rapporto__c);
                var elementAvvioYear = elementAvvioDate.getFullYear();
                var elementAvvioMonth = elementAvvioDate.getMonth();

                if(elementYear == n && elementMonth == m){
                    if(element.hasOwnProperty('Data_avvio_rapporto__c') && element.hasOwnProperty('Data_Contatto_Telefonico__c') && element.Data_avvio_rapporto__c >= element.Data_Contatto_Telefonico__c) dayMagazziono++;
                }

                if(elementtPrevisioneYear == n && elementPrevisioneMonth == m){
                    numPrevisione++;
                }

                if(elementAvvioYear == n && elementAvvioMonth == m){
                    numAvvio++;
                }
            });  
            
			var clientiAvviatiTotMonth = 0;
            var clientiAvviatiTotYear = 0;
            var clientiAvviatiMap = new Map();;
            result.data[0].accountList.forEach(function (element) {
                var elementDate = new Date(element.Data_New_Business__c);
                var elementYear = elementDate.getFullYear();
                var elementMonth = elementDate.getMonth();
                var elementDay = elementDate.getDate();
                if(elementYear == n && elementMonth == m){
                    
                    let count = 0;
                    weeksList.forEach(function (week) {
                        if(elementDay >= week.start && elementDay <= week.end){
                            weeksList[count].clientiAvviati++;
                        } 
                        count++;
                    });

                    clientiAvviatiTotMonth++;  
                                             
                }
                if(elementYear == n && elementMonth <= m){
                    clientiAvviatiTotYear++;
                    chartJS_Data.clientiAvviati_actual[elementMonth]++;
                    chartJS_Data_Clienti.actual[elementMonth]++;
                }

                clientiAvviatiMap.set(element.Anagrafica__r.Id, element);
            });
            
            console.log('MAP', clientiAvviatiMap);

			component.set('v.clientiAvviatiTot_Month', clientiAvviatiTotMonth);
			component.set('v.clientiAvviatiTot_Year', Math.round(clientiAvviatiTotYear / (m  + 1)));


			var accountInVisId_Month = [];
            var accountInVisId_Year = [];
            var visiteTotMonth = 0;
            var visiteTotYear = 0;
            result.data[0].eventList.forEach(function (element) {
                var elementDate = new Date(element.CreatedDate);
                var elementYear = elementDate.getFullYear();
                var elementMonth = elementDate.getMonth();
                var elementDay = elementDate.getDate();

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
            });

            component.set('v.visiteTot_Month', visiteTotMonth);  
			component.set('v.visiteTot_Year', Math.round(visiteTotYear / (m  + 1)));
            
            var accountInProdId_Month = [];
            var accountInProdId_Year = [];
            var prodottiTotMonth = 0;
            var prodottiTotYear = 0;
            result.data[0].productList.forEach(function (element) {
                var elementDate = new Date(element.Data_attivazione_linea__c);
                var elementYear = elementDate.getFullYear();
                var elementMonth = elementDate.getMonth();
                var elementDay = elementDate.getDate();

                var el = clientiAvviatiMap.get(element.Anagrafica__c);
                //console.log('TROVATO', el);

                if ((el == undefined || new Date(el.Data_New_Business__c) > new Date(element.Data_ultima_cessione__c)) && !accountInProdId_Year.includes(element.Anagrafica__c)) {
                 	if(elementYear == n && elementMonth <= m){

                        if(elementMonth == m){

                            let count = 0;
                            weeksList.forEach(function (week) {
                                if(elementDay >= week.start && elementDay <= week.end){
                                    weeksList[count].prodotti++;
                                } 
                                count++;
                            });
    
                            prodottiTotMonth++;         
                            accountInProdId_Month.push(element.Anagrafica__c);
                        }
                        
                        accountInProdId_Year.push(element.Anagrafica__c);
                        prodottiTotYear++;
                        chartJS_Data.prodotti_actual[elementMonth]++;
                        chartJS_Data_Prodotti.actual[elementMonth]++;
                    }
                }                    
			});
			
			component.set('v.prodottiTot_Month', prodottiTotMonth);  
            component.set('v.prodottiTot_YEar', Math.round(prodottiTotYear / (m  + 1)));

			var budgetTotYear_clientiAvviati = 0;
            var budgetTotYear_prodotti = 0;
            var budgetTotYear_visite = 0;
            result.data[0].budgetList.forEach(function (element) {
                if (element.Mese__c - 1 <= today.getMonth()){
                    chartJS_Data.clientiAvviati_budget[element.Mese__c - 1] = element.Clienti_avviati_FD_revisionati__c;
                    chartJS_Data.prodotti_budget[element.Mese__c - 1] = element.Prodotti_venduti_FD_revisionati__c;
                    chartJS_Data.eventi_budget[element.Mese__c - 1] = element.Visite_FD_revisionate__c;

                    chartJS_Data_Clienti.budget[element.Mese__c - 1] = element.Clienti_avviati_FD_revisionati__c;

                    chartJS_Data_Prodotti.budget[element.Mese__c - 1] = element.Prodotti_venduti_FD_revisionati__c;
                }
                if (element.Mese__c - 1 == today.getMonth()){
                    component.set('v.clientiAvviatiTot_Month_Budget',  element.Clienti_avviati_FD_revisionati__c);
                    component.set('v.prodottiTot_Month_Budget', element.Prodotti_venduti_FD_revisionati__c);
                    component.set('v.visiteTot_Month_Budget', element.Visite_FD_revisionate__c);

					component.set('v.clientiAvviatiTot_Month_Obiettivo',  element.Clienti_avviati_FD_revisionati__c > 0 ?  clientiAvviatiTotMonth / element.Clienti_avviati_FD_revisionati__c : 0);
                    component.set('v.prodottiTot_Month_Obiettivo', element.Prodotti_venduti_FD_revisionati__c > 0 ? prodottiTotMonth / element.Prodotti_venduti_FD_revisionati__c : 0);
                    component.set('v.visiteTot_Month_Obiettivo', element.Visite_FD_revisionate__c > 0 ? visiteTotMonth / element.Visite_FD_revisionate__c : 0);
                }
                if(element.Mese__c -1 <= m){
                    budgetTotYear_clientiAvviati = budgetTotYear_clientiAvviati + element.Clienti_avviati_FD_revisionati__c;
                    budgetTotYear_prodotti = budgetTotYear_prodotti + element.Prodotti_venduti_FD_revisionati__c;
                    budgetTotYear_visite = budgetTotYear_visite + element.Visite_FD_revisionate__c;
                }     
            });

            var clientiAvviatiBP_Year = 0;
            var prodottiBP_Year = 0;
            var visiteBP_Year = 0;
            result.data[0].bestPracticeList.forEach(function (element) {
                if(element.Week__c > 0){
                    weeksList[element.Week__c - 1].clientiAvviatiBP = weeksList[element.Week__c - 1].clientiAvviatiBP + element.Clienti_Attivati__c;
                    weeksList[element.Week__c - 1].prodottiBP = weeksList[element.Week__c - 1].prodottiBP + element.Prodotti_venduti__c;
                    weeksList[element.Week__c - 1].visiteBP = weeksList[element.Week__c - 1].visiteBP + element.Visite__c;
                } else {
                    clientiAvviatiBP_Year = clientiAvviatiBP_Year + element.Clienti_Attivati__c;
                    prodottiBP_Year = prodottiBP_Year + element.Prodotti_venduti__c;
                    visiteBP_Year = visiteBP_Year + element.Visite__c;
                }
                  
            });

            var clientiAvviatiTotBP = 0;
            var prodottiTotBP = 0;
            var visiteTotBP = 0;
            weeksList.forEach(function (element) {
                element.clientiAvviatiBP = Math.round(element.clientiAvviatiBP / (result.data[0].bestPracticeList.length / 6));
                clientiAvviatiTotBP = clientiAvviatiTotBP + element.clientiAvviatiBP;
                element.prodottiBP = Math.round(element.prodottiBP / (result.data[0].bestPracticeList.length / 6));
                prodottiTotBP = prodottiTotBP + element.prodottiBP;
                element.visiteBP = Math.round(element.visiteBP / (result.data[0].bestPracticeList.length / 6));
                visiteTotBP = visiteTotBP + element.visiteBP;
            });

            component.set('v.clientiAvviatiTot_BP_Month', clientiAvviatiTotBP);
            component.set('v.prodottiTot_BP_Month', prodottiTotBP);
            component.set('v.visiteTot_BP_Month', visiteTotBP);

            component.set('v.clientiAvviatiTot_BP_Year', Math.round((clientiAvviatiBP_Year / (result.data[0].bestPracticeList.length / 6)) / (m  + 1)));
            component.set('v.prodottiTot_BP_Year', Math.round((prodottiBP_Year / (result.data[0].bestPracticeList.length / 6)) / (m  + 1)));
            component.set('v.visiteTot_BP_Year', Math.round((visiteBP_Year / (result.data[0].bestPracticeList.length / 6)) / (m  + 1)));

            component.set('v.clientiAvviatiTot_Budget_Year', Math.round(budgetTotYear_clientiAvviati / (m  + 1)));
            component.set('v.prodottiTot_Budget_Year', Math.round(budgetTotYear_prodotti / (m  + 1)));
            component.set('v.visiteTot_Budget_Year', Math.round(budgetTotYear_visite / (m  + 1)));

            component.set('v.weeks', weeksList);

            chartJS_Data_Clienti.potenziale[m] = dayMagazziono > 0 ? (result.data[0].workMonth / dayMagazziono) * result.data[0].potenziale : 0;
            chartJS_Data_Clienti.previsione[m] = (numPrevisione - numAvvio) > 0 ? numPrevisione - numAvvio : 0;
			

		})).finally($A.getCallback(function () {
            helper.generateChart(helper.dataChart(chartJS_Data, 3, component, event), helper.optionsChart(null, 3, component, event), 'bar', 'chartJS_BP', component, event);
            helper.generateChart(helper.dataChart(chartJS_Data_Clienti, 1, component, event), helper.optionsChart(null, 1, component, event), 'bar', 'chartJS_Clienti', component, event);
            helper.generateChart(helper.dataChart(chartJS_Data_Prodotti, 2, component, event), helper.optionsChart(null, 2, component, event), 'bar', 'chartJS_Prodotti', component, event);
		}));

	},

	navigateToMyComponent : function(component, event, helper){
		var navigator = component.find("navService");

		var pg = {
			type: 'standard__namedPage',
			attributes: {
				pageName: 'home'
			}
		};

		navigator.navigate(pg);
	},

})