({
	initialize : function(component, event, helper){
		//component.set("v.isLoaded", false);
		var pg = component.get("v.pageReference");
        console.log('@@@ pg ' , JSON.stringify(pg));
		component.set("v.isDirezioneFD", pg.state.c__isDirezioneFD);
		component.set("v.dashboardId" , pg.state.c__dashboardId);
		
		console.log('@@@ init ' + component.get("v.value"));
		console.log('@@@ init month ' , component.get("v.selectedMonth"));
		console.log('@@@ init month ' , typeof component.get("v.selectedMonth"));
		var mese = parseInt(component.get("v.selectedMonth"));
		var filtro = component.get("v.value");


		var action = component.get("c.getAllData");
		action.setParams({
			"mese" : mese + 1,
			"anno" : filtro
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				console.log('@@@ risposta sfida ' , risposta);

				if(risposta.success){
					//Mi costruisco l'array di date per mostrarle nel grafico
					var arrayD = [];
					var date = risposta.data[0].dates;
					//Inverto l'ordine
					date.reverse();

					for(var i = 0; i < date.length; i++){
						arrayD.push(date[i]);
					}

					console.log('@@@ arrayD before ' , arrayD);
					var graphDates = [];
					//if(filtro == 'month' || filtro == '' || filtro == null || filtro == undefined){
						graphDates = arrayD.map(item => { return new Date(item).toLocaleDateString('it-IT', { month: '2-digit', day: '2-digit' }) });
					//} else {
						//graphDates = arrayD.map(item => { return new Date(item).toLocaleDateString('it-IT', { month: '2-digit' }) });
					//}
					graphDates.reverse();

					component.set("v.results", risposta.data[0]);

					this.reloadChart('barChartSfida', 'canvas-container');
					this.reloadChart('barChartSfidaSuccess', 'canvas-container-success');

					var dt = helper.generateDataSetsTeamBar(component, event, helper, arrayD, risposta.data[0].grafico);
					helper.generateChart(component, event, helper, 'barChartSfida', 'bar', graphDates, dt);
					
					var ddd = risposta.data[0].graficoSuccesso;
					var aaa = ddd.concat(risposta.data[0].graficoSuccessoTot);
					var dtLine = helper.generateDataSetsTeamLine(component, event, helper, arrayD, aaa);
					helper.generateChart(component, event, helper, 'barChartSfidaSuccess', 'line', graphDates, dtLine);

					//component.set("v.isLoaded", true);
					
				}
				else{
					console.log('@@@ error msg ' , risposta.message);
				}
			}
			else{
				console.log('@@@ error ' , response.getError());
			}
		});

		$A.enqueueAction(action);
	},

	generateChart : function(component, event, helper, canvasId, chartType, dates, graphData) {
		// this.getLastFiveDays();
		var allDatasets = graphData;
        
        new Chart(canvasId, {
			type: chartType,
            data: {
				labels: dates,
				datasets: allDatasets
			},
			options: {
				legend: {
					position: "top",
					labels: {
						boxWidth: 10,
						fontSize: 10
					}
				},
				responsive: true,
				maintainAspectRatio: false,
				scales: {
					xAxes: [{
						// stacked: true,
						barThickness : 10,
					}]
					// ,
					// yAxes: [{
					// 	stacked: true
					// }]
				}
			}
        });
	},

	generateDataSetsTeamBar : function(component, event, helper, dates, graphData){
		var newData = graphData.filter( (item,index) => { 
			return dates.includes(item.data);
		});

		var teamNames = new Set();

		newData.forEach((item, index) =>{
			teamNames.add(item.nomeTeam);
		});

		//Aggiungo il mio nome come se fossi un team
		teamNames.add($A.get("$Label.c.WGC_HomePage_MieiSuccessi_Io"));

		teamNames = Array.from(teamNames).reverse();

		var dataSets = [];

		teamNames.forEach((item, index) =>{
			var bg = 'green';

			var wrapTeam = { "label" : item, "data" : [], "backgroundColor" : bg };
			newData.forEach((itemD, indexD) =>{
				console.log('@@@ single data rec ' , itemD );
				if(item == 'Io' && itemD.nomeTeam == component.get("v.results.utente.nomeTeam")){
					wrapTeam.label = $A.get("$Label.c.WGC_HomePage_MieiSuccessi_Io");
					wrapTeam.backgroundColor = 'orange';
					wrapTeam.borderColor = 'orange';
					wrapTeam.stack = component.get("v.results.utente.nomeTeam");
					wrapTeam.data.push(itemD.myVisiteFissate);
				}
				else if(itemD.nomeTeam == component.get("v.results.utente.nomeTeam") && itemD.nomeTeam == item){
					wrapTeam.stack = item;
					wrapTeam.backgroundColor = itemD.colore;
					wrapTeam.borderColor = itemD.colore;
					itemD.hasOwnProperty('myVisiteFissate') ? wrapTeam.data.push(itemD.visiteFissate - itemD.myVisiteFissate) : wrapTeam.data.push(itemD.visiteFissate);
				}
				else if(itemD.nomeTeam == item){
					wrapTeam.stack = item;
					wrapTeam.backgroundColor = itemD.colore;
					wrapTeam.borderColor = itemD.colore;
					wrapTeam.data.push(itemD.visiteFissate);
				}

			});

			dataSets.push(wrapTeam);
		});

		console.log('@@@ dataSets ' , dataSets);

		return dataSets;
	},

	generateDataSetsTeamLine : function(component, event, helper, dates, graphData){

		console.log('@@@ graph data line ' , graphData);

		var newData = graphData.filter( (item,index) => { 
			return dates.includes(item.data);
		});

		var teamNames = new Set();

		newData.forEach((item, index) =>{
			teamNames.add(item.nomeTeam + ' %');
		});

		teamNames = Array.from(teamNames).reverse();

		var dataSets = [];

		teamNames.forEach((item, index) =>{
			var bg = 'green';

			var wrapTeam = { "label" : item, "data" : [], "backgroundColor" : bg, fill : false };
			newData.forEach((itemD, indexD) =>{
				console.log('@@@ successo ' , itemD );
				// if(itemD.nomeTeam == component.get("v.results.utente.nomeTeam") && itemD.nomeTeam == item){
				// 	wrapTeam.stack = item;
				// 	wrapTeam.backgroundColor = itemD.colore;
				// 	wrapTeam.borderColor = itemD.colore;
				// 	itemD.hasOwnProperty('myVisiteFissate') ? wrapTeam.data.push(itemD.visiteFissate - itemD.myVisiteFissate) : wrapTeam.data.push(itemD.visiteFissate);
				// }
				if(item.includes(itemD.nomeTeam)){
					wrapTeam.stack = item;
					wrapTeam.backgroundColor = itemD.colore;
					wrapTeam.borderColor = itemD.colore;
					wrapTeam.data.push(itemD.successo);
				}

			});

			dataSets.push(wrapTeam);
		});

		console.log('@@@ dataSets ' , dataSets);

		return dataSets;
	},

	initializeTable : function(component, event, helper){
		var columnsToday = [{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_Data") , fieldName : 'Data__c', type : 'date', typeAttributes : { "day" : "2-digit", "month" : "2-digit", "year" : "2-digit"} },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_Team") , fieldName : 'Team__c', type : 'text' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_Operatore") , fieldName : 'Operatore__c', type : 'url', typeAttributes : { label : { fieldName : "nomeOperatore" }, target: '_self' }},
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_OreBudget") , fieldName : 'Budget__c', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_CTBudget") , fieldName : 'CT_Budget__c', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_vc_budget") , fieldName : 'VC_Budget__c', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_ore_actual") , fieldName : 'Ore_Actual__c', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_ct_actual") , fieldName : 'CT_Actual__c', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_vc_actual") , fieldName : 'VC_Actual__c', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_motivo") , fieldName : 'Motivo_Actual__c', type : 'text' }];

		component.set("v.columnsToday", columnsToday);

		var columnsTomorrow = [	{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_OreBudget") , fieldName : 'Budget__c', type : 'number' },
							{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_CTBudget") , fieldName : 'CT_Budget__c', type : 'number' },
							{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_vc_budget") , fieldName : 'VC_Budget__c', type : 'number' },
							{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_motivo") , fieldName : 'Motivo_Budget__c', type : 'text' }];

		component.set("v.columnsTomorrow", columnsTomorrow);

		//Sezione Team
		var columnsTodayTeam = [{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_Data") , fieldName : 'Data', type : 'date', typeAttributes : { "day" : "2-digit", "month" : "2-digit", "year" : "2-digit"} },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_Team") , fieldName : 'Team', type : 'text' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_OreBudget") , fieldName : 'Budget', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_CTBudget") , fieldName : 'CT_Budget', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_vc_budget") , fieldName : 'VC_Budget', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_ore_actual") , fieldName : 'Ore_Actual', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_ct_actual") , fieldName : 'CT_Actual', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_vc_actual") , fieldName : 'VC_Actual', type : 'number' }];

		component.set("v.columnsTodayTeam", columnsTodayTeam);

		var columnsTomorrowTeam = [	{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_OreBudget") , fieldName : 'Budget', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_CTBudget") , fieldName : 'CT_Budget', type : 'number' },
						{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_vc_budget") , fieldName : 'VC_Budget', type : 'number' }];

		component.set("v.columnsTomorrowTeam", columnsTomorrowTeam);
		
		//Sezione totale
		//Sezione Team
		var columnsTodayTotale = [{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_Data") , fieldName : 'Data', type : 'date', typeAttributes : { "day" : "2-digit", "month" : "2-digit", "year" : "2-digit"} },
								{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_Team") , fieldName : 'Team', type : 'text' },
								{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_OreBudget") , fieldName : 'Budget', type : 'number' },
								{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_CTBudget") , fieldName : 'CT_Budget', type : 'number' },
								{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_vc_budget") , fieldName : 'VC_Budget', type : 'number' },
								{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_ore_actual") , fieldName : 'Ore_Actual', type : 'number' },
								{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_ct_actual") , fieldName : 'CT_Actual', type : 'number' },
								{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_vc_actual") , fieldName : 'VC_Actual', type : 'number' }];

		component.set("v.columnsTodayTotale", columnsTodayTotale);

		var columnsTomorrowTotale = [{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_OreBudget") , fieldName : 'Budget', type : 'number' },
									{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_CTBudget") , fieldName : 'CT_Budget', type : 'number' },
									{ label : $A.get("$Label.c.WGC_Sfida_Dettaglio_vc_budget") , fieldName : 'VC_Budget', type : 'number' }];

		component.set("v.columnsTomorrowTotale", columnsTomorrowTotale);
	},

	initializeTableData : function(component, event, helper){
		var action = component.get("c.getTablesData");
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();

				if(risposta.success){
					console.log('@@@ risposta tables data ' , risposta.data);

					risposta.data.forEach((item, index) =>{
						if(index == 0 || index == 1){
							item.forEach((itemL, indexL) =>{
								itemL.nomeOperatore = itemL.Operatore__r.Name;
								var operatore = itemL.Operatore__c;
								itemL.Operatore__c = '/'+operatore;
							});
						}
					});

					component.set("v.dataToday", risposta.data[0]);
					component.set("v.dataTomorrow", risposta.data[1]);
					component.set("v.dataTodayTeam", risposta.data[2]);
					component.set("v.dataTomorrowTeam", risposta.data[3]);
					component.set("v.dataTodayTotale", risposta.data[4]);
					component.set("v.dataTomorrowTotale", risposta.data[5]);
				}
				else{
					console.log('@@@ error msg ' , risposta.message);
				}
			}
			else{
				console.log('@@@ errore dati tabella ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	},

	reloadChart : function(chartId, containerId){
		var itemNode = document.getElementById(chartId);
		itemNode.parentNode.removeChild(itemNode);
		document.getElementById(containerId).innerHTML = '<canvas aura:id="'+chartId+'" id="'+chartId+'" style="height:50vh" ></canvas>';
	},

	initFilter : function(component, event, helper){
		//{ 'label' : $A.get("$Label.c.WGC_Sfida_Dettaglio_Mese_In_Corso"), 'value' : 'month' },
		var btns = [{ 'label' : $A.get("$Label.c.WGC_Sfida_Dettaglio_Anno_In_Corso") , 'value' : 'year' }, 
					{ 'label' : $A.get("$Label.c.WGC_Sfida_Dettaglio_Anno_Precedente") , 'value' : 'lastyear'  } ];
		component.set("v.options", btns);

		var months = [{ 'label' : 'Gennaio', 'value' : 0}, 
						{ 'label' : 'Febbraio', 'value' : 1}, 
						{ 'label' : 'Marzo', 'value' : 2}, 
						{ 'label' : 'Aprile', 'value' : 3}, 
						{ 'label' : 'Maggio', 'value' : 4},
						{ 'label' : 'Giugno', 'value' : 5},
						{ 'label' : 'Luglio', 'value' : 6},
						{ 'label' : 'Agosto', 'value' : 7},
						{ 'label' : 'Settembre', 'value' : 8},
						{ 'label' : 'Ottobre', 'value' : 9},
						{ 'label' : 'Novembre', 'value' : 10},
						{ 'label' : 'Dicembre', 'value' : 11}];

		component.set("v.months", months);

		var newDate = new Date().getMonth();
		console.log('@@@ new Date ' , newDate);

		var selectedMonth = component.get("v.selectedMonth");
		console.log('@@@ selectedMonth ' , selectedMonth);

		if(selectedMonth == null || selectedMonth == undefined || selectedMonth == ''){
			component.set("v.selectedMonth", parseInt(newDate));
			console.log('@@@ prova null ' , component.get("v.selectedMonth"));
		} else {
			component.set("v.selectedMonth", parseInt(selectedMonth));
			console.log('@@@ prova null ' , component.get("v.selectedMonth"));
		}
						
	},

})