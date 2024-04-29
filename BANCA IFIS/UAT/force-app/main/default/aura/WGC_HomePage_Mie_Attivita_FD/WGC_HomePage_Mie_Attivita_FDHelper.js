({

	getDatiFirstChart : function(component, event, helper){
		var isDirezioneFD = component.get("v.isDirezioneFD");
		var action = component.get("c.getDatiGraficoAziende");
		action.setParams({
			"isDirezioneFD" : isDirezioneFD
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();

				if(risposta.success){
					console.log('@@@ risposta obiettivo FD ' , risposta.data);
					component.set("v.pianificatoTask", risposta.data[0].todaysActivity.length);
					component.set("v.obiettivoTask", risposta.data[0].obiettivo);
					component.set("v.eseguitoTask", risposta.data[0].actual);

					//Genero il grafico
					this.generateChart(component, event, helper, 'barChartAziende', 'bar', component.get("v.obiettivoTask"), component.get("v.pianificatoTask"), component.get("v.eseguitoTask"));
				}
				else{
					console.log('@@@ error ' , risposta.message);
				}
			}
			else{
				console.log('@@@ error in server side ' , response.getError());
			}
		});

		$A.enqueueAction(action);
	},

	getDatiSecondChart : function(component, event, helper){
		var isDirezioneFD = component.get("v.isDirezioneFD");
		var action = component.get("c.getDatiGraficoCommerciali");
		console.log('@@@ isDirezioneFD grafico commerciali ' , isDirezioneFD);
		action.setParams({
			"isDirezioneFD" : isDirezioneFD
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();

				if(risposta.success){
					console.log('@@@ risposta obiettivo Grafico Commerciali FD ' , risposta.data);
					component.set("v.pianificatoPromemoria", risposta.data[0].todaysActivity.length);
					//component.set("v.obiettivoPromemoria", risposta.data[0].planned);
					component.set("v.eseguitoPromemoria", risposta.data[0].todaysClosed.length);

					//Genero il grafico
					this.generateChart(component, event, helper, 'barChartCommerciali', 'bar', undefined, undefined, component.get("v.eseguitoPromemoria"));
				}
				else{
					console.log('@@@ error ' , risposta.message);
				}
			}
			else{
				console.log('@@@ error in server side ' , response.getError());
			}
		});

		$A.enqueueAction(action);
	},

	getFilteredData_FirstChart : function(component, event, helper, parametri){
		var action = component.get("c.getDatiGraficoAziende_Filtered");
		action.setParams({
			"userId" : parametri.userId,
			"teamName" : parametri.teamName,
			"isAllUser" : parametri.isAllUser
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				if(risposta.success){
					component.set("v.pianificatoTask", risposta.data[0].todaysActivity.length);
					component.set("v.obiettivoTask", risposta.data[0].obiettivo);
					component.set("v.eseguitoTask", risposta.data[0].actual);

					//Genero il grafico
					this.generateChart(component, event, helper, 'barChartAziende', 'bar', component.get("v.obiettivoTask"), component.get("v.pianificatoTask"), component.get("v.eseguitoTask"));
				} else {
					console.log('@@@ error msg ' , risposta.message);
				}
			} else {
				console.log('@@@ error ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	},

	getFilteredData_SecondChart : function(component, event, helper, parametri){
		var action = component.get("c.getDatiGraficoCommerciali_Filtered");
		action.setParams({
			"userId" : parametri.userId,
			"teamName" : parametri.teamName,
			"isAllUser" : parametri.isAllUser
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				if(risposta.success){
					console.log('@@@ risposta obiettivo Grafico Commerciali FD ' , risposta.data);
					component.set("v.pianificatoPromemoria", risposta.data[0].todaysActivity.length);
					//component.set("v.obiettivoPromemoria", risposta.data[0].planned);
					component.set("v.eseguitoPromemoria", risposta.data[0].todaysClosed.length);

					//Genero il grafico
					this.generateChart(component, event, helper, 'barChartCommerciali', 'bar', undefined, undefined, component.get("v.eseguitoPromemoria"));
				} else {
					console.log('@@@ error msg ' , risposta.message);
				}
			} else {
				console.log('@@@ error ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	},

	generateChart : function(component, event, helper, idChart, chartType, obiettivo, pianificato, actual){
		var el = component.find(idChart).getElement();
		var ctx = el.getContext('2d');

		//Variabile utilizzata per calcolare la differenza e mostrare il riempimento della barra grigia dell'obiettivo
		// var diffObbActual = actual >= obiettivo ? 0 : obiettivo - actual;
		
		var dataSets = pianificato != undefined ? [ { label: $A.get("$Label.c.WGC_Filo_Diretto_Actual"), backgroundColor: "orange", data: [actual] },
													{ label: $A.get("$Label.c.WGC_Filo_Diretto_Obiettivo"), backgroundColor: "grey", data: [obiettivo] } ] : 

													[ { label: $A.get("$Label.c.WGC_Filo_Diretto_Actual"), backgroundColor: "orange", data: [actual] } ];

        new Chart(ctx, {
            type: chartType,
            data: {
                labels: [''],
                datasets: dataSets
			},
			options: {
				responsive: true,
				maintainAspectRatio: false,
				legend: {
                
					position: "top",
					labels: {
						boxWidth: 10,
						fontSize: 10
					}
				},
				scales: {
					xAxes: [{
						barThickness : 10,
						ticks: {
							display : 0
						},
						// stacked: true
					}],
					yAxes: [{
						position : (idChart == 'barChartCommerciali') ? 'right' : 'left',
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

})