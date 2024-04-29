({
	doInit: function (component, event, helper) {

        const monthNames = [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")];

                var d = new Date();
                var n = d.getFullYear();
                var m = d.getMonth();
        		console.log('SV mese: ', m);
                var weeksList = helper.getWeeksInMonth(component, event, n, m);
        		console.log('SV weeksList: ', weeksList);
                component.set('v.month', monthNames[m]);
                component.set('v.year', n);

        helper.apex(component, event, 'getAllData', {})
            .then(function (result) {
                var today = new Date(Date.now());
                console.log('SV result ', result);
                component.set('v.allDataValue', result);

                var chartJS_Data = { clientiAvviati_actual : [0,0,0,0,0,0,0,0,0,0,0,0], clientiAvviati_budget : [0,0,0,0,0,0,0,0,0,0,0,0], opportunity_actual : [0,0,0,0,0,0,0,0,0,0,0,0], opportunity_budget : [0,0,0,0,0,0,0,0,0,0,0,0], eventi_actual : [0,0,0,0,0,0,0,0,0,0,0,0], eventi_budget : [0,0,0,0,0,0,0,0,0,0,0,0] };

                weeksList.forEach(function (element) {
                    element.clientiAvviati = 0;
                    element.opportunita = 0;
                    element.visite = 0;
                    element.clientiAvviatiBP = 0;
                    element.opportunitaBP = 0;
                    element.visiteBP = 0;
                });

                var clientiAvviatiTotMonth = 0;
                var clientiAvviatiTotYear = 0;
                result.data[0].accountList.forEach(function (element) {
                    var elementDate = new Date(element.Data_New_Business__c);
                    var elementYear = elementDate.getFullYear();
                    var elementMonth = elementDate.getMonth();
                    var elementDay = elementDate.getDate();

                    if(elementYear == n && elementMonth == m){
                        if (true) {
                            let count = 0;
                            weeksList.forEach(function (week) {
                                if(elementDay >= week.start && elementDay <= week.end){
                                    weeksList[count].clientiAvviati++;
                                } 
                                count++;
                            });
                            // var weekOfMonth = helper.getISOWeekInMonth(component, event, elementDate);
                            // weeksList[weekOfMonth - 1].clientiAvviati++; 
                            clientiAvviatiTotMonth++;                            
                        }
                    }
                    if(elementYear == n && elementMonth <= m){
                        clientiAvviatiTotYear++;
                        chartJS_Data.clientiAvviati_actual[elementMonth]++;
                    }
                });

                var accountInOppId_Month = [];
                var accountInOppId_Year = [];
                var opportunitaTotMonth = 0;
                var opportunitaTotYear = 0;
                result.data[0].opportunityList.forEach(function (element) {
                    var elementDate = new Date(element.CreatedDate);
                    var elementYear = elementDate.getFullYear();
                    var elementMonth = elementDate.getMonth();
                    var elementDay = elementDate.getDate();

                    if (!accountInOppId_Month.includes(element.AccountId)) {
                    	if(elementYear == n && elementMonth == m){                        
                            accountInOppId_Month.push(element.AccountId);
                            let count = 0;
                            weeksList.forEach(function (week) {
                                if(elementDay >= week.start && elementDay <= week.end){
                                    weeksList[count].opportunita++;
                                } 
                                count++;
                            });
                            // var weekOfMonth = helper.getISOWeekInMonth(component, event, elementDate);
                            // weeksList[weekOfMonth - 1].opportunita++; 
                            opportunitaTotMonth++;    
                        }                        
                    }
                    if (!accountInOppId_Year.includes(element.AccountId)) {
                    	if(elementYear == n && elementMonth <= m){
                            accountInOppId_Year.push(element.AccountId);
                            opportunitaTotYear++;
                            chartJS_Data.opportunity_actual[elementMonth]++;
                        }
                    }                    
                });

                var accountInVisId_Month = [];
                var accountInVisId_Year = [];
                var visiteTotMonth = 0;
                var visiteTotYear = 0;
                result.data[0].eventList.forEach(function (element) {
                    var elementDate = new Date(element.Data_Inizio__c);
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
                            // var weekOfMonth = helper.getISOWeekInMonth(component, event, elementDate);
                            // weeksList[weekOfMonth - 1].visite++; 
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

                var budgetTotYear_clientiAvviati = 0;
                var budgetTotYear_opportunita = 0;
                var budgetTotYear_visite = 0;
                result.data[0].budgetList.forEach(function (element) {
                    if (element.Mese__c - 1 <= today.getMonth()){
                        chartJS_Data.clientiAvviati_budget[element.Mese__c - 1] = element.Clienti_avviati__c;
                        chartJS_Data.opportunity_budget[element.Mese__c - 1] = element.Pratiche_presentate__c;
                        chartJS_Data.eventi_budget[element.Mese__c - 1] = element.Visite_esitate__c;
                    }
                    if (element.Mese__c - 1 == today.getMonth()){
                        component.set('v.clientiAvviatiTot_Budget',  element.Clienti_avviati__c);
                        component.set('v.opportunitaTot_Budget', element.Pratiche_presentate__c);
                        component.set('v.visiteTot_Budget', element.Visite_esitate__c);

                        component.set('v.clientiAvviatiTot_Obiettivo',  clientiAvviatiTotMonth > 0 ? element.Clienti_avviati__c / clientiAvviatiTotMonth : 0);
                        component.set('v.opportunitaTot_Obiettivo', opportunitaTotMonth > 0 ? element.Pratiche_presentate__c / opportunitaTotMonth : 0);
                        component.set('v.visiteTot_Obiettivo', visiteTotMonth > 0 ? element.Visite_esitate__c / visiteTotMonth : 0);
                    }
                    if(element.Mese__c -1 <= m){
                        budgetTotYear_clientiAvviati = budgetTotYear_clientiAvviati + element.Clienti_avviati__c;
                        budgetTotYear_opportunita = budgetTotYear_opportunita + element.Pratiche_presentate__c;
                        budgetTotYear_visite = budgetTotYear_visite + element.Visite_esitate__c;
                    }     
                });

                var clientiAvviatiBP_Year = 0;
                var clientiAvviatiBP_Year = 0;
                var opportunitaBP_Year = 0;
                var visiteBP_Year = 0;
                result.data[0].bestPracticeList.forEach(function (element) {
                    element.Week__c = parseInt(element.Week__c);
                    if(element.Week__c > 0 && weeksList[element.Week__c - 1]){
                        console.log('SV element.Week__c - 1: ' + element.Week__c - 1);
                        console.log('SV weeksList: ' + weeksList);
                        weeksList[element.Week__c - 1].clientiAvviatiBP = weeksList[element.Week__c - 1].clientiAvviatiBP + element.Clienti_Attivati__c;
                        weeksList[element.Week__c - 1].opportunitaBP = weeksList[element.Week__c - 1].opportunitaBP + element.Opportunita__c;
                        weeksList[element.Week__c - 1].visiteBP = weeksList[element.Week__c - 1].visiteBP + element.Visite__c;
                    } else {
                        clientiAvviatiBP_Year = clientiAvviatiBP_Year + element.Clienti_Attivati__c;
                        opportunitaBP_Year = opportunitaBP_Year + element.Opportunita__c;
                        visiteBP_Year = visiteBP_Year + element.Visite__c;
                    }
                    
                });

                var clientiAvviatiTotBP = 0;
                var opportunitaTotBP = 0;
                var visiteTotBP = 0;
                weeksList.forEach(function (element) {
                    element.clientiAvviatiBP = Math.round(element.clientiAvviatiBP / (result.data[0].bestPracticeList.length / 6));
                    clientiAvviatiTotBP = clientiAvviatiTotBP + element.clientiAvviatiBP;
                    element.opportunitaBP = Math.round(element.opportunitaBP / (result.data[0].bestPracticeList.length / 6));
                    opportunitaTotBP = opportunitaTotBP + element.opportunitaBP;
                    element.visiteBP = Math.round(element.visiteBP / (result.data[0].bestPracticeList.length / 6));
                    visiteTotBP = visiteTotBP + element.visiteBP;
                });

                component.set('v.weeks', weeksList);                
                component.set('v.clientiAvviatiTot', clientiAvviatiTotMonth);
                component.set('v.opportunitaTot', opportunitaTotMonth);
                component.set('v.visiteTot', visiteTotMonth);

                component.set('v.clientiAvviatiTot_Year', Math.round(clientiAvviatiTotYear / (m  + 1)));
                component.set('v.opportunitaTot_Year', Math.round(opportunitaTotYear / (m  + 1)));
                component.set('v.visiteTot_Year', Math.round(visiteTotYear / (m  + 1)));

                component.set('v.clientiAvviatiTot_Budget_Year', Math.round(budgetTotYear_clientiAvviati / (m  + 1)));
                component.set('v.opportunitaTot_Budget_Year', Math.round(budgetTotYear_opportunita / (m  + 1)));
                component.set('v.visiteTot_Budget_Year', Math.round(budgetTotYear_visite / (m  + 1)));

                component.set('v.clientiAvviatiTotBP', clientiAvviatiTotBP);
                component.set('v.opportunitaTotBP', opportunitaTotBP);
                component.set('v.visiteTotBP', visiteTotBP);

                component.set('v.clientiAvviatiBP_Year', Math.round((clientiAvviatiBP_Year / (result.data[0].bestPracticeList.length / 6)) / (m  + 1)));
                component.set('v.opportunitaBP_Year', Math.round((opportunitaBP_Year / (result.data[0].bestPracticeList.length / 6)) / (m  + 1)));
                component.set('v.visiteBP_Year', Math.round((visiteBP_Year / (result.data[0].bestPracticeList.length / 6)) / (m  + 1)));

                helper.generateChart(helper.dataChart('thisYear', chartJS_Data, component, event), helper.optionsChart(component, event), 'bar', 'chartJS_BP', component, event);

            }).finally($A.getCallback(function () {

                
            }));


        // var data = {
        //     labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
        //     datasets: [{
        //             label: "Visite",
        //             backgroundColor: "#d3eeff",
        //             borderColor: "#d3eeff",
        //             borderWidth: 1,
        //             data: [30, 30, 30, 30, 30, 30, 30, 16]
        //         },
        //         {
        //             label: "Opportunità",
        //             backgroundColor: "#78b0e8",
        //             borderColor: "#78b0e8",
        //             borderWidth: 1,
        //             data: [10, 10, 10, 10, 10, 10, 10, 7]
        //         },
        //         {
        //             label: "Clienti",
        //             backgroundColor: "#4d93d6",
        //             borderColor: "#4d93d6",
        //             borderWidth: 1,
        //             data: [3, 3, 3, 3, 3, 3, 3, 2]
        //         }
        //     ]
        // };

        // var chartOptions = {
        //     responsive: true,
        //     maintainAspectRatio: false,
        //     legend: {
        //         position: "top"
        //     },
        //     title: {
        //         display: false,
        //         text: "Chart.js Bar Chart"
        //     },
        //     scales: {
        //         yAxes: [{
        //             ticks: {
        //                 display: false,
        //                 beginAtZero: true
        //             },
        //             gridLines: {
        //                 display: false,
        //                 drawBorder: false,
        //             }
        //         }],
        //         xAxes: [{
        //             ticks: {

        //             },
        //             gridLines: {
        //                 display: false
        //             }
        //         }]
        //     }
        // };

        // Chart.Bar('grafic', {
        //     options: chartOptions,
        //     data: data
        // });
        // console.log('@@@ init newBusiness');
	},

	navigateToMyComponent: function (component, event, helper) {

		var navService = component.find("navService");
		var pageReference = {
			"type": "standard__namedPage",
			"attributes": {
				"pageName": "home"
			}
		}

		navService.navigate(pageReference);
    },
})