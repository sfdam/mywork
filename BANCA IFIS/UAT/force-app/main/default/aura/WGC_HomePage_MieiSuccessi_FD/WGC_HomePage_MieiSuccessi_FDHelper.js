({

	initialize : function(component, event, helper){
		this.getAllData(component, event, helper);
	},

	getAllData : function(component, event, helper){
		var isDirezioneFD = component.get("v.isDirezioneFD");
		var action = component.get("c.getData");
		action.setParams({
			"isDirezioneFD" : isDirezioneFD
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();

				if(risposta.success){
					console.log('@@@ risposta miei successi ' , risposta.data);
					//Setto i dati
					component.set("v.performer", risposta.data[0].performer);
					component.set("v.team", risposta.data[0].team);
					component.set("v.obiettivoTotal", risposta.data[0].obiettivo);
					component.set("v.segnalazioni", risposta.data[0].segnalazioni);
					
					var allUsers = event.getParam("isAllUser");
					if((allUsers == undefined || allUsers) && isDirezioneFD) component.set("v.team.nomeMyTeam", 'All');
					// Setto i due attributi di appoggio
					// component.set("v.totalProg", risposta.data[0].team.visiteMyTeam);
					// component.set("v.actualProg", risposta.data[0].performer.myVisite);

					//Una volta recuperati i dati genero il chart
					var labels = helper.generateLabels(component, event, helper, risposta.data[0].grafico);
					console.log('@@@ labels ' , labels);

					var datasets = helper.generateDataSets(component, event, helper, labels, risposta.data[0].grafico);
					console.log('@@@ datasets ' , datasets);

					helper.generateChart(component, event, helper, datasets, labels);
				}
				else{
					console.log('@@@ error message miei successi FD ' , risposta.message);
				}
			}
			else{
				console.log('@@@ error in calling server side ' , response.getError());
			}
		});

		$A.enqueueAction(action);
	},

	getDataFiltered : function(component, event, helper, parametri){
		var action = component.get("c.getDataFiltered");
		action.setParams({
			"userId" : parametri.userId,
			"teamName" : parametri.teamName,
			"isAllUser" : parametri.isAllUser
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				console.log('@@@ risposta ' , risposta);
				if(risposta.success){
					console.log('@@@ risposta miei successi filtered ' , risposta.data);
					//Setto i dati
					if(risposta.data.length > 0){
						component.set("v.performer", risposta.data[0].performer);
						component.set("v.team", risposta.data[0].team);
						component.set("v.obiettivoTotal", risposta.data[0].obiettivo);
						component.set("v.segnalazioni", risposta.data[0].segnalazioni);

						//Una volta recuperati i dati genero il chart
						var labels = helper.generateLabels(component, event, helper, risposta.data[0].grafico);
						console.log('@@@ labels ' , labels);

						var datasets = helper.generateDataSets(component, event, helper, labels, risposta.data[0].grafico);
						console.log('@@@ datasets ' , datasets);

						helper.generateChart(component, event, helper, datasets, labels);
					}
				} else {
					console.log('@@@ error msg ', risposta.message);
				}
			} else {
				console.log('@@@ error ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	},

	generateChart : function(component, event, helper, datasets, labels) {
		var el = component.find('barChart').getElement();
		var ctx = el.getContext('2d');

		var newLabels = [];

		labels.forEach((item, index) =>{
			newLabels.push('');
		});
        
        new Chart(ctx, {
            type: 'bar',
            data: {
				labels: newLabels,
				datasets : datasets		
			},
			options: {
				legend: {
					display: false
					// position: "top",
					// labels: {
					// 	filter: function(item, chart) {
					// 		console.log ('prova label ' , item);
					// 		// Logic to remove a particular legend item goes here
					// 		return !item.text.includes('label to remove');
					// 	},
					// 	boxWidth: 10,
					// 	fontSize: 10
					// }
				},
				responsive: true,
				maintainAspectRatio: false,
				scales: {
					xAxes: [{
						barThickness : 6,
						ticks: {
							display : true
						},
						// stacked: true
					}],
					yAxes: [{
						position : 'right',
						ticks: {
							display: true,
							beginAtZero : true,
							userCallback: function(label, index, labels) {
								// when the floored value is the same as the value we have a whole number
								if (Math.floor(label) === label) {
									return label;
								}
		   
							},
						},
						// stacked: true
					}]
				}
			}
        });
	},

	generateLabels : function(component, event, helper, dati){
		var labels = [];
		dati.forEach((item, index) =>{
			if(!item.isUser){
				labels.push(item.nomeTeam);
			}
		});

		return labels;
	},

	generateDataSets : function(component, event, helper, labels, dati){
		console.log('@@@ dati ' , dati);
		console.log('@@@ labels ' , labels);

		var dts = [];

		// labels.push('');
		labels.push('Io');
		// labels.push('Obiettivo Totale');

		labels.forEach((item, index) =>{
			console.log('@@@ item ' , item);
			if(item != 'Obiettivo Totale'){
				var dataA = { label : 'Actual ' + item, data : [] , backgroundColor : ''};
				var dataO = { label : 'Obiettivo ' + item, data : [], backgroundColor : '' };
				dati.forEach((itemD, indexD) =>{

					if(item == itemD.nomeTeam && !itemD.isUser){
						dataA.backgroundColor = itemD.coloreTeam;
						dataO.backgroundColor = 'lightgray';
						dataA.data.push(itemD.actual);
						dataO.data.push(itemD.obiettivo);
					}
					else if(item == 'Io' && itemD.isUser){
						dataA.label = 'Actual Io';
						dataO.label = 'Obiettivo Io';
						dataA.backgroundColor = itemD.coloreTeam;
						dataO.backgroundColor = 'lightgray';
						dataA.data.push(itemD.actual);
						dataO.data.push(itemD.obiettivo);
					}
					else{
						dataA.data.push(0);
						dataO.data.push(0);
					}
				});

				dts.push(dataA);
				dts.push(dataO);
			}
		});

		var dataTotOb = { data : [0,0,0] };
		var dataTotAct = { data : [0,0,0] };

		dataTotOb.label = 'Obiettivo Totale';
		dataTotOb.backgroundColor = 'grey';

		dataTotAct.label = 'Actual Totale';
		dataTotAct.backgroundColor = '#0064B5';
		
		var countObTot = 0;
		var countActTot = 0;

		dati.forEach((item, index) =>{
			countObTot += item.obiettivo;
			countActTot += item.actual;
		}),

		dataTotAct.data.push(countActTot);
		dataTotOb.data.push(countObTot);

		dts.push(dataTotAct);
		dts.push(dataTotOb);

		return dts;
	},
})