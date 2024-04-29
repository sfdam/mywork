({
  generateChart: function (data, chartOptions, type, ctxName, component, event) {

    // var itemNode = document.getElementById(ctxName);
    // itemNode.parentNode.removeChild(itemNode);
    // document.getElementById('chart-container').innerHTML = '<canvas id="' + ctxName + 'aura:id="' + ctxName + '"' + '></canvas>';

    console.log('SV Final ctxName: ', ctxName);
    console.log('SV Final data: ', data);
    console.log('SV Final chartOptions: ', chartOptions);

    var myChart = new Chart(ctxName, {
      type: type,
      data: data,
      options: chartOptions
    });
  },

  optionsChart: function (component, event) {

    var chartOptions = {
      responsive: true,
      maintainAspectRatio: false,
      layout: { padding: { top: 0, right: 0, down: 0, lefth: 0 } },
      legend: {
        display: false,
      },
      tooltips: {
        enabled: true,
        mode: 'x',
        callbacks: {
          label: function (tooltipItem, data) {
            var corporation = data.datasets[tooltipItem.datasetIndex].label;
            return corporation + ': ' + parseFloat(tooltipItem.yLabel).toFixed(2);
          }
        }
      },
      scales: {
        yAxes: [{
          display: false,
          ticks: {
            reverse: false,
            beginAtZero: true,
          }
        }],
        xAxes: [{
          position: 'bottom',
          stacked: true,
          display: true,
          ticks: {
            display: true //this will remove only the label
          },
          gridLines: {
            offsetGridLines: false
          }
        }],

      }
    };

    return chartOptions;
  },

  dataChart: function (dataList, component, event) {
    const data = [];
    const budget = [];
    const soglia = [];
    dataList.forEach(function (element) {
      if (element.Valore__c) {
        data.push(element.Valore__c);
      } else {
        data.push(null);
      }

      budget.push(element.Valore_budget__c);
      soglia.push(element.Valore_soglia__c);
    });

    const colours = data.map((value) => value < soglia[0] ? 'red' : 'green');

    var dataResult = {};
    dataResult = {
      labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
      datasets: [
        {
          label: "Valore",
          backgroundColor: 'rgba(73, 144, 226, 0.75)',
          borderColor: 'rgba(73, 144, 226, 1)',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "rgba(73, 144, 226, 0.75)",
          pointBackgroundColor: colours,
          pointBorderWidth: 1,
          pointHoverRadius: 5,
          pointHoverBackgroundColor: "rgba(73, 144, 226, 0.75)",
          pointHoverBorderColor: "rgba(220,220,220,1)",
          pointHoverBorderWidth: 2,
          pointRadius: 5,
          pointHitRadius: 10,
          fill: false,
          data: data
        },
        {
          label: "Budget",
          backgroundColor: 'rgba(187, 187, 187, 0.75)',
          borderColor: 'rgba(187, 187, 187, 1)',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointHitRadius: 0,
          pointRadius: 0,
          fill: false,
          data: budget
        },
        {
          label: "Soglia",
          backgroundColor: 'rgba(237, 73, 91, 0.75)',
          borderColor: 'rgba(237, 73, 91, 1)',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointHitRadius: 0,
          pointRadius: 0,
          fill: false,
          data: soglia
        },
      ]
    };

    console.log('SV dataResult: ', dataResult);

    return dataResult;
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


})