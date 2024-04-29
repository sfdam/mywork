({
	doInit : function(component, event, helper) {
		
		var data = {
			datasets: [
			 /* Outer doughnut data starts*/
			{
				data: [
					300.000,
					190.000,
					110.000,
					0
				],
				backgroundColor: [
					"#0064B5", 
					"#98CAFA", // green
					"#FAD61F", //blue 
					"#0DAC58",
				],
				label: 'Posizione Puntuale'
			},
			/* Outer doughnut data ends*/
			/* Inner doughnut data starts*/
			{
				data: [
					300.000,
					190.000,
					110.000,
					450.000
				],
				backgroundColor: [
					"#0064B5", 
					"#98CAFA", // green
					"#FAD61F", //blue 
					"#0DAC58",
				],
				label: 'Posizione Media'
			}
			/* Inner doughnut data ends*/
			],
			labels: [
				"Factoring",
				"Lending",
				"Leasing",
				"Cassa"
			]
		};
    
    

        var chartOptions = {
					responsive: true,
					maintainAspectRatio: false,
					legend: {
						display:	false,
					},
					title: {
						display: false,
						text: 'Chart.js Doughnut Chart'
					},
					animation: {
						animateScale: true,
						animateRotate: true
					},
					tooltips: {
						callbacks: {
							label: function(item, data) {
							console.log(data.labels, item);
									return data.datasets[item.datasetIndex].label+ ": "+ data.labels[item.index]+ ": "+ data.datasets[item.datasetIndex].data[item.index];
							}
					}
			}
				};
				var myChart = new Chart.Doughnut('doubleDonut', {
					options: chartOptions,
					data: data
				});
		
	}
})