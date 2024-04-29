({
	initialize : function(component, event, helper){
		var action = component.get("c.getAllData");
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
					
					var graphDates = arrayD.map(item => { return new Date(item).toLocaleDateString('it-IT', { month: '2-digit', day: '2-digit' }) });
					graphDates.reverse();

					component.set("v.results", risposta.data[0]);

					var dt = helper.generateDataSetsTeam(component, event, helper, arrayD, risposta.data[0].grafico);
					// var dtTot = helper.generateDataSetsTotal(component, event, helper, risposta.data[0].successoGrafico);

					// var allDt = dt.concat(dtTot);
					// var allDt = dtTot.concat(dt);
					helper.generateChart(component, event, helper, graphDates, dt);
				}
				else{
					console.log('@@@ error msg ' , risposta.message);
				}
			}
			else{
				alert('error in calling server side');
			}
		});

		$A.enqueueAction(action);
	},

	generateChart : function(component, event, helper, dates, graphData) {
		// this.getLastFiveDays();

		var el = component.find('barChartAziende').getElement();
		var ctx = el.getContext('2d');

		var allDatasets = graphData;
        
        new Chart(ctx, {
			type: 'line',
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
					,
					yAxes: [{
						// stacked: true
						beginAtZero : true,
						userCallback: function(label, index, labels) {
							// when the floored value is the same as the value we have a whole number
							if (Math.floor(label) === label) {
								return label;
							}
	   
						}
					}]
				}
			}
        });
	},

	generateDataSetsTeam : function(component, event, helper, dates, graphData){
		console.log('@@@ graphData ' , graphData);

		var dataSets = [];

		// graphData.forEach((item, index) =>{
		// 	console.log('@@@ item graph data ' , item);
		// 	var dt = { data : [] };
		// 	dt.label = item.

		// });

		var newData = graphData.filter( (item,index) => { 
			return dates.includes(item.data);
		});

		var teamNames = new Set();

		newData.forEach((item, index) =>{
			teamNames.add(item.nomeTeam + ' %');
		});

		// //Aggiungo il mio nome come se fossi un team
		// teamNames.add('Io');

		teamNames = Array.from(teamNames).reverse();

		var dataSets = [];

		teamNames.forEach((item, index) =>{
			var bg = 'green';

			var wrapTeam = { "label" : item, "data" : [], "backgroundColor" : bg, fill : false };
			newData.forEach((itemD, indexD) =>{
				console.log('@@@ single data rec ' , itemD );
				console.log('@@@ prova ' , itemD.nomeTeam.includes(item));
				if(item.includes(itemD.nomeTeam)){
					wrapTeam.backgroundColor = itemD.colore;
					wrapTeam.borderColor = itemD.colore;
					wrapTeam.data.push(itemD.successoMedio);
				}

			});

			dataSets.push(wrapTeam);
		});

		console.log('@@@ dataSets ' , dataSets);

		return dataSets;
	},

})