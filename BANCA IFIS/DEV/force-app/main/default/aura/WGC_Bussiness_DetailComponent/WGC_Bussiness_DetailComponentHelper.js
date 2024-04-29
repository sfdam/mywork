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
        
        console.log('SV daysInMonth: ', daysInMonth);
        console.log('SV dayOfWeek: ', dayOfWeek);
        
        
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
	
	getWeekOfMonth: function(component, event, date) {
		console.log(date);
        let adjustedDate = date.getDate()+date.getDay();
		let prefixes = ['0', '1', '2', '3', '4', '5'];

		return (parseInt(prefixes[0 | adjustedDate / 7])+1);
	},
    
    getISOWeekInMonth: function(component, event, date) {
      // Copy date so don't affect original
      var d = new Date(+date);
      if (isNaN(d)) return;
      // Move to previous Monday
      d.setDate(d.getDate() - d.getDay() + 1);
      // Week number is ceil date/7

      return Math.floor((d.getDate()/7) + 1);
    },

	generateChart: function (data, chartOptions, type, ctx, component, event) {

		// var itemNode = document.getElementById('chartJS_BP');
		// itemNode.parentNode.removeChild(itemNode);
		// document.getElementById('chart-container').innerHTML = '<canvas aura:id="chartJS_BP" id="chartJS_BP" style="height:60vh" ></canvas>';
		 
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

		return chartOptions;
	},

	dataChart: function (year, result, component, event) {

		var data = {
			labels: [['V    O    C', $A.get("$Label.c.WGC_Gennaio")], ['V    O    C', $A.get("$Label.c.WGC_Febbraio")], ['V    O    C', $A.get("$Label.c.WGC_Marzo")], ['V    O    C', $A.get("$Label.c.WGC_Aprile")], ['V    O    C', $A.get("$Label.c.WGC_Maggio")], ['V    O    C', $A.get("$Label.c.WGC_Giugno")], ['V    O    C', $A.get("$Label.c.WGC_Luglio")], ['V    O    C', $A.get("$Label.c.WGC_Agosto")], ['V    O    C', $A.get("$Label.c.WGC_Settembre")], ['V    O    C', $A.get("$Label.c.WGC_Ottobre")], ['V    O    C', $A.get("$Label.c.WGC_Novembre")], ['V    O    C', $A.get("$Label.c.WGC_Dicembre")]],
			// labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
			datasets: [
				{
					label: "Visite Budget",
					backgroundColor: 'rgba(198, 212, 229, 0.75)',
					borderColor: 'rgba(198, 212, 229, 1)',
					//stack: 'stackOpp',
					data: result.eventi_budget
				}, {
					label: "Visite Actual",
					backgroundColor: '#0064B5',
					borderColor: 'rgba(74, 144, 226, 1)',
					//stack: 'stackOpp',
					data: result.eventi_actual
				}, {
					label: "Opportunità Budget",
					backgroundColor: 'rgba(198, 212, 229, 0.75)',
					borderColor: 'rgba(198, 212, 229, 1)',
					//stack: 'stackOpp',
					data: result.opportunity_budget
				}, {
					label: "Opportunità Actual",
					backgroundColor: '#0064B5',
					borderColor: 'rgba(74, 144, 226, 1)',
					//stack: 'stackOpp',
					data: result.opportunity_actual
				}, {
					label: "Clienti avviati Budget",
					backgroundColor: 'rgba(198, 212, 229, 0.75)',
					borderColor: 'rgba(198, 212, 229, 1)',
					//stack: 'stackOpp',
					data: result.clientiAvviati_budget
				}, {
					label: "Clienti avviati Actual",
					backgroundColor: '#0064B5',
					borderColor: 'rgba(74, 144, 226, 1)',
					//stack: 'stackOpp',
					data: result.clientiAvviati_actual
				}
			]
		};

		return data;
	},
})