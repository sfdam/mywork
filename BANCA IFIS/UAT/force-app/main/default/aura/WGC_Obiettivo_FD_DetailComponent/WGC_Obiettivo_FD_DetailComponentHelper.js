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

    getISOWeekInMonth: function(component, event, date) {
      // Copy date so don't affect original
      var d = new Date(+date);
      if (isNaN(d)) return;
      // Move to previous Monday
      d.setDate(d.getDate() - d.getDay() + 1);
      // Week number is ceil date/7

      return Math.ceil((d.getDate()/7));
    },

    generateChart: function (data, chartOptions, type, ctxName, component, event) {

        var itemNode = document.getElementById(ctxName);
        
        if (itemNode != null) {
          itemNode.parentNode.removeChild(itemNode);
          document.getElementById('container_' + ctxName).innerHTML = '<canvas id="' + ctxName + '"' + '></canvas>';
          
          
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

        } else {

            chartOptions = {
                responsive: true,
                maintainAspectRatio: true,
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
                        backgroundColor: 'rgba(198, 212, 229, 0.75)',
                        borderColor: 'rgba(198, 212, 229, 1)',
                        //stack: 'stackOpp',
                        data: data.clientiAvviati_budget
                    }, {
                        label: "Clienti avviati Actual",
                        backgroundColor: '#0064B5',
                        borderColor: 'rgba(74, 144, 226, 1)',
                        //stack: 'stackOpp',
                        data: data.clientiAvviati_actual
                    }, {
                        label: "Prodotti Budget",
                        backgroundColor: 'rgba(198, 212, 229, 0.75)',
                        borderColor: 'rgba(198, 212, 229, 1)',
                        //stack: 'stackOpp',
                        data: data.prodotti_budget
                    }, {
                        label: "Prodotti Actual",
                        backgroundColor: '#0064B5',
                        borderColor: 'rgba(74, 144, 226, 1)',
                        //stack: 'stackOpp',
                        data: data.prodotti_actual
                    }
                ]
            };

        }
    
        return data;
      },

      workingDaysBetweenDates: function (d0, d1) {
        /* Two working days and an sunday (not working day) */
        var holidays = ['2019-09-19', '2019-09-19'];
        var startDate = this.parseDate(d0);
        var endDate = this.parseDate(d1);  
      
      // Validate input
        if (endDate < startDate) {
          return 0;
        }
      
      // Calculate days between dates
        var millisecondsPerDay = 86400 * 1000; // Day in milliseconds
        startDate.setHours(0, 0, 0, 1);  // Start just after midnight
        endDate.setHours(23, 59, 59, 999);  // End just before midnight
        var diff = endDate - startDate;  // Milliseconds between datetime objects    
        var days = Math.ceil(diff / millisecondsPerDay);
      
        // Subtract two weekend days for every week in between
        var weeks = Math.floor(days / 7);
        days -= weeks * 2;
      
        // Handle special cases
        var startDay = startDate.getDay();
        var endDay = endDate.getDay();
          
        // Remove weekend not previously removed.   
        if (startDay - endDay > 1) {
          days -= 2;
        }
        // Remove start day if span starts on Sunday but ends before Saturday
        if (startDay == 0 && endDay != 6) {
          days--;  
        }
        // Remove end day if span ends on Saturday but starts after Sunday
        if (endDay == 6 && startDay != 0) {
          days--;
        }
        /* Here is the code */
        holidays.forEach(day => {
          if ((day >= d0) && (day <= d1)) {
            /* If it is not saturday (6) or sunday (0), substract it */
            if ((this.parseDate(day).getDay() % 6) != 0) {
              days--;
            }
          }
        });
        return days;
      },
                 
      parseDate: function(input) {
        // Transform date from text to date
        var parts = input.match(/(\d+)/g);
        // new Date(year, month [, date [, hours[, minutes[, seconds[, ms]]]]])
        return new Date(parts[0], parts[1]-1, parts[2]); // months are 0-based
      }
})