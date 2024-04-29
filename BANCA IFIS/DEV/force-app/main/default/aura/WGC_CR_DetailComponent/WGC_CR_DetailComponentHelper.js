({
  helperMethod: function () {

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

  configureWizard: function (component, event) {
    var wizardItems = [
      {
        title: "Complessivo",
        step: "complessivo",
        active: true,
        disabled: false,
        completed: false,
        icon: ""
      },
      {
        title: "Autoliquidanti",
        step: "autoliquidanti",
        valPerc: 0,
        active: false,
        disabled: false,
        completed: false,
        icon: ""
      },
      {
        title: "Scadenza",
        step: "scadenza",
        valPerc: 0,
        active: false,
        disabled: false,
        completed: false,
        icon: ""
      },
      {
        title: "Revoca",
        step: "revoca",
        valPerc: 0,
        active: false,
        disabled: false,
        completed: true,
        icon: ""
      },
      {
        title: "Firma",
        step: "firma",
        valPerc: 0,
        active: false,
        disabled: false,
        completed: true,
        icon: ""
      }
    ];

    component.set("v.wizardItems", wizardItems);
  },

  selectWizardItem: function (component, step) {
    var wizardItems = component.get("v.wizardItems");
    var wizItem = null;
    var isvalid = true

    this.showSpinner(component);

    for (var wi in wizardItems) {
      if (wizardItems[wi].step == step && wizardItems[wi].disabled == true) {
        isvalid = false;
        break;
      }
      else if (wizardItems[wi].step == step) {
        wizardItems[wi].active = true;
        wizItem = wizardItems[wi];
      }
      else if (wizardItems[wi].active == true) {
        wizardItems[wi].active = false;
        // wizItem = wizardItems[wi];
      }
    }

    switch (step) {
      case 'complessivo': // ACTIONS TO INITIALIZE A WIZITEM
        // this.setWizItemCompleted(wizItem, payload.linee.length > 0);
        this.generateChart(this.dataChart('Complessivo', 1, component, event), this.optionsChart('Complessivo', 1, component, event), 'bar', 'chartJS_1', component, event);
        this.generateChart(this.dataChart('Complessivo', 2, component, event), this.optionsChart('Complessivo', 2, component, event), 'line', 'chartJS_2', component, event);
        this.generateChart(this.dataChart('Complessivo', 3, component, event), this.optionsChart('Complessivo', 3, component, event), 'line', 'chartJS_3', component, event);
        this.generateChart(this.dataChart('Complessivo', 4, component, event), this.optionsChart('Complessivo', 4, component, event), 'line', 'chartJS_4', component, event);

        break;
      case 'autoliquidanti': // ACTIONS TO INITIALIZE A WIZITEM
        // this.setWizItemCompleted(wizItem, payload.linee.length > 0);
        this.generateChart(this.dataChart('Autoliquidanti', 1, component, event), this.optionsChart('Autoliquidanti', 1, component, event), 'bar', 'chartJS_1', component, event);
        this.generateChart(this.dataChart('Autoliquidanti', 2, component, event), this.optionsChart('Autoliquidanti', 2, component, event), 'line', 'chartJS_2', component, event);
        this.generateChart(this.dataChart('Autoliquidanti', 3, component, event), this.optionsChart('Autoliquidanti', 3, component, event), 'line', 'chartJS_3', component, event);
        this.generateChart(this.dataChart('Autoliquidanti', 4, component, event), this.optionsChart('Autoliquidanti', 4, component, event), 'line', 'chartJS_4', component, event);

        break;
      case 'scadenza':
        // var condition = false;
        // this.setWizItemCompleted(wizItem, condition);
        this.generateChart(this.dataChart('Scadenza', 1, component, event), this.optionsChart('Scadenza', 1, component, event), 'bar', 'chartJS_1', component, event);
        this.generateChart(this.dataChart('Scadenza', 2, component, event), this.optionsChart('Scadenza', 2, component, event), 'line', 'chartJS_2', component, event);
        this.generateChart(this.dataChart('Scadenza', 3, component, event), this.optionsChart('Scadenza', 3, component, event), 'line', 'chartJS_3', component, event);
        this.generateChart(this.dataChart('Scadenza', 4, component, event), this.optionsChart('Scadenza', 4, component, event), 'line', 'chartJS_4', component, event);

        break;
      case 'revoca':
        // var condition = false;
        // this.setWizItemCompleted(wizItem, condition);
        this.generateChart(this.dataChart('Revoca', 1, component, event), this.optionsChart('Revoca', 1, component, event), 'bar', 'chartJS_1', component, event);
        this.generateChart(this.dataChart('Revoca', 2, component, event), this.optionsChart('Revoca', 2, component, event), 'line', 'chartJS_2', component, event);
        this.generateChart(this.dataChart('Revoca', 3, component, event), this.optionsChart('Revoca', 3, component, event), 'line', 'chartJS_3', component, event);
        this.generateChart(this.dataChart('Revoca', 4, component, event), this.optionsChart('Revoca', 4, component, event), 'line', 'chartJS_4', component, event);

        break;
      case 'firma':
        // var condition = false;
        // this.setWizItemCompleted(wizItem, condition);
        this.generateChart(this.dataChart('Firma', 1, component, event), this.optionsChart('Firma', 1, component, event), 'bar', 'chartJS_1', component, event);
        this.generateChart(this.dataChart('Firma', 2, component, event), this.optionsChart('Firma', 2, component, event), 'line', 'chartJS_2', component, event);
        this.generateChart(this.dataChart('Firma', 3, component, event), this.optionsChart('Firma', 3, component, event), 'line', 'chartJS_3', component, event);
        this.generateChart(this.dataChart('Firma', 4, component, event), this.optionsChart('Firma', 4, component, event), 'line', 'chartJS_4', component, event);

        break;
    }

    if (isvalid) {
      component.set("v.step", wizItem.step);
      component.set("v.wizardItems", wizardItems);
    }

    this.hideSpinner(component);
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

    var chartOptions = {
      responsive: true,
      maintainAspectRatio: false,
      layout: (chart == 1) ? { padding: { top: 0, right: 0, down: 0, lefth: 0 } } : { padding: { top: 0, right: 30, down: 0, left: 30 } },
      legend: {
        display: false,
      },
      tooltips: {
        enabled: true,
        mode: 'x',
        callbacks: {
          label: function (tooltipItem, data) {
              console.log('data.datasets[tooltipItem.datasetIndex].label', data.datasets[tooltipItem.datasetIndex].label);
            var corporation = data.datasets[tooltipItem.datasetIndex].label;
            return corporation + ': ' + ((chart == 1) ? (new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(tooltipItem.yLabel)) : (parseFloat(tooltipItem.yLabel).toFixed(2)+"%"));
          }
        }
      },
      scales: {
        yAxes: [{
          display: false,
          ticks: {
            reverse: (chart == 1 || chart == 3) ? false : true,
            beginAtZero: true,
            suggestedMax: 110,
          }
        }],
        xAxes: [{
          position: (chart == 1 || chart == 3) ? 'bottom' : 'top',
          stacked: true,
          display: true,
          ticks: {
            display: (chart == 1 || chart == 3) ? true : false //this will remove only the label
          },
          gridLines: {
            offsetGridLines: false
          }
        }],

      }
    };

    return chartOptions;
  },

  dataChart: function (step, chart, component, event) {

    console.log('SV dataChart', step, chart);
    var data = {};
    if (chart == 1){
      data = {
        labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
        datasets: [
          {
            label: "Utilizzato IFIS",
            backgroundColor: 'rgba(73, 144, 226, 0.75)',
            borderColor: 'rgba(73, 144, 226, 1)',
            fill: false,
            stack: 'stackUtilizzatoIfis',
            data: component.get('v.Utilizzato' + step + 'Ifis')
          }, {
            label: "Accordato IFIS",
            backgroundColor: 'rgba(73, 144, 226, 0.75)',
            borderColor: 'rgba(73, 144, 226, 1)',
            fill: false,
            stack: 'stackAccordatoIfis',
            data: component.get('v.Accordato' + step + 'Ifis')
          }, {
            label: "Utilizzato Sistema",
            backgroundColor: 'rgba(187, 187, 187, 0.75)',
            borderColor: 'rgba(187, 187, 187, 1)',
            fill: false,
            stack: 'stackUtilizzatoSistema',
            data: component.get('v.Utilizzato' + step + 'Sistema')
          }, {
            label: "Accordato Sistema",
            backgroundColor: 'rgba(187, 187, 187, 0.75)',
            borderColor: 'rgba(187, 187, 187, 1)',
            fill: false,
            stack: 'stackAccordatoSistema',
            data: component.get('v.Accordato' + step + 'Sistema')
          }, {
            label: "Sconfino IFIS",
            backgroundColor: 'rgba(237, 73, 91, 0.75)',
            borderColor: 'rgba(237, 73, 917, 1)',
            fill: false,
            stack: 'stackUtilizzatoIfis',
            data: component.get('v.Sconfino' + step + 'Ifis')
          }, {
            label: "Sconfino Sistema",
            backgroundColor: 'rgba(237, 73, 91, 0.75)',
            borderColor: 'rgba(237, 73, 91, 1)',
            fill: false,
            stack: 'stackUtilizzatoSistema',
            data: component.get('v.Sconfino' + step + 'Sistema')
          }
        ]
      };
    } else if (chart == 2){
      data = {
        labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
        datasets: [
          {
            label: "IFIS",
            backgroundColor: 'rgba(73, 144, 226, 0.75)',
            borderColor: 'rgba(73, 144, 226, 1)',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(73, 144, 226, 0.75)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: "rgba(73, 144, 226, 0.75)",
            pointHoverBorderColor: "rgba(220,220,220,1)",
            pointHoverBorderWidth: 2,
            pointRadius: 5,
            pointHitRadius: 10,
            fill: false,
            data: component.get('v.' + step + 'Ifis')
          },
          {
            label: "Sistema",
            backgroundColor: 'rgba(187, 187, 187, 0.75)',
            borderColor: 'rgba(187, 187, 187, 1)',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(187, 187, 187, 0.75)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: "rgba(187, 187, 187, 0.75)",
            pointHoverBorderColor: "rgba(220,220,220,1)",
            pointHoverBorderWidth: 2,
            pointRadius: 5,
            pointHitRadius: 10,
            fill: false,
            data: component.get('v.' + step + 'Sistema')
          }
        ]
      };
    } else if (chart == 3){
      data = {
        labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
        datasets: [
          {
            label: "Ut IFIS/ Ut Sistema",
            backgroundColor: 'rgba(73, 144, 226, 0.75)',
            borderColor: 'rgba(73, 144, 226, 1)',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(73, 144, 226, 0.75)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: "rgba(73, 144, 226, 0.75)",
            pointHoverBorderColor: "rgba(220,220,220,1)",
            pointHoverBorderWidth: 2,
            pointRadius: 5,
            pointHitRadius: 10,
            fill: true,
            data: component.get('v.Utilizzato' + step + 'IfisSistema')
          }
        ]
      };
    } else {
      data = {
        labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
        datasets: [
          {
            label: "Acc IFIS/ Acc Sistema",
            backgroundColor: 'rgba(73, 144, 226, 0.75)',
            borderColor: 'rgba(73, 144, 226, 1)',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(73, 144, 226, 0.75)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: "rgba(73, 144, 226, 0.75)",
            pointHoverBorderColor: "rgba(220,220,220,1)",
            pointHoverBorderWidth: 2,
            pointRadius: 5,
            pointHitRadius: 10,
            fill: true,
            data: component.get('v.Accordato' + step + 'IfisSistema')
          }
        ]
      };
    }

    return data;
  },

  showSpinner: function (cmp, event) {
    var spinner = cmp.find("mySpinner");
    $A.util.removeClass(spinner, "slds-hide");
  },

  hideSpinner: function (cmp, event) {
    var spinner = cmp.find("mySpinner");
    $A.util.addClass(spinner, "slds-hide");
  },

  //SM - 19/04/2019
  //Funzione che genera i dati per la tabella
  generateTable : function(component, event, helper){
      let opportunityId = component.get("v.opportunityId");
      var recId = component.get("v.recordId");
      let appEvent = $A.get("e.c:WGC_Cart_ChangeWizardEvent");
      let sbloccoFacile = false;
      console.log('@@@ recId ' , recId);

      this.apex(component, event, 'getSbloccoFacileCR', {}).then((result) =>{
        sbloccoFacile = result;
        return this.apex(component, event, 'getDataCR', { "recordId" : recId, "opportunityId": opportunityId });
      }).then((result) =>{
        let accData;

        if (typeof result.data[0] == "string") {
          let crData = JSON.parse(result.data[0]);

          accData = [crData.account];

          helper.manageCRData(component, crData, appEvent, sbloccoFacile);
          component.set("v.debsData", crData.debsData);
        } else {
          accData = result.data;
          let isEstero = (accData[0].WGC_Area__c == "EE");
          let nonAffidato = accData[0].WGC_Flag_non_affidato__c;
          let dataBKIT = accData[0].WGC_Data_Caricamento_BKIT__c;
          let dataRichiesta = accData[0].WGC_DataRichiestaCR__c;
          let config = {};
          
          if (nonAffidato === true && (dataBKIT >= dataRichiesta || dataRichiesta == null)) { // CASO 4
              config = {
                  msg: $A.get("$Label.c.WGC_Cart_CRMessage_SoggettoNonAffidato"),
                  graph: false,
                  debs: false,
                  dataRilevazione: dataBKIT ? new Date(dataBKIT) : null,
                  dataRichiesta: dataRichiesta ? new Date(dataRichiesta) : null,
                  note: false
              };
          } else if (nonAffidato === true && dataBKIT < dataRichiesta) { // CASO 5
              config = {
                  msg: $A.get("$Label.c.WGC_Cart_CRMessage_ElaborazioneInCorso"),
                  graph: false,
                  debs: false,
                  dataRilevazione: null,
                  dataRichiesta: dataRichiesta ? new Date(dataRichiesta) : null,
                  note: false
              };
          } else { // CASO 3-6
              config = {
                  msg: (isEstero ? $A.get("$Label.c.WGC_Cart_CRMessage_CentraleRischiNonNecessariaEstero") : ""),
                  graph: !isEstero,
                  debs: false,
                  dataRilevazione: null, // new Date(lastCRDate)
                  dataRichiesta: dataRichiesta ? new Date(dataRichiesta) : null,
                  note: false
              };
          }

          //SM - 02/07/2019 - Aggiunto campo Data Richiesta Info CR
          component.set('v.dataRichiestaCR', accData[0].WGC_DataRichiestaCR__c); 
          component.set('v.isEstero', isEstero);
          component.set("v.config", config);
        }


        console.log('@@@ result dati tabella ' , result);

        component.set('v.columnsABIA', [
          {label: 'Indicatore', fieldName: 'desc', type: 'string', initialWidth: 530, cellAttributes:{ class:{ fieldName:"cellClass" } }},
          {label: 'Alert' , fieldName: 'val', type: 'string', cellAttributes:{ class:{ fieldName:"col1" } }}
        ]);

        var results = [];

        var descriptions = ["Presenza di sconfini a revoca (tutti gli ultimi 3 mesi) & Utilizzato>Accordato",
                            "Presenza di sconfini a revoca (tutti gli ultimi 3 mesi)",
                            "Presenza di sconfini a scadenza (tutti gli ultimi 3 mesi) & Utilizzato>Accordato",
                            "Presenza di sconfini a scadenza (tutti gli ultimi 3 mesi)",
                            "Impagato > 50% Utilizzato Autoliquidante (tutti gli ultimi 3 mesi)",
                            "Sofferenze"];
        
        if(accData.length > 0){
          results.push(
              { desc: descriptions[0], val : accData[0].Sconfini_a_revoca_Utilizzato_Accordato__c },
              { desc: descriptions[1], val : accData[0].Sconfini_a_revoca__c },
              { desc: descriptions[2], val : accData[0].Sconfini_a_scadenza_Utilizzato_Accordato__c },
              { desc: descriptions[3], val : accData[0].Sconfini_a_scadenza__c },
              { desc: descriptions[4], val : accData[0].Impagato_50_Utilizzato_Autoliquidante__c },
              { desc: descriptions[5], val : accData[0].Sofferenze__c }
          );

          //results = this.soglie(component, event, results);

          results.forEach((item, index) =>{
            if(item.val == 'SI'){
              item.col1 = ' red-text ';
            }
          });

          component.set('v.dataABIA', results);
            
        }
        else{
            descriptions.forEach((item, index) =>{
              results.push({ desc: item, val: "-" });
            })
            component.set('v.dataABIA', results);
        }
        });
  },

  manageCRData : function(component, crData, appEvent, sbloccoFacile) {
    let hasCRData = crData.hasCRData;
    let lastCRDate = crData.lastCRDate;
    let isValidCR = crData.isValidCR; // CR SCADUTA
    let validCR = (crData.account.WGC_Alert_KPI_Centrale_Rischi__c == false);
    let isEstero = (crData.account.WGC_Area__c == "EE");
    let nonAffidato = crData.account.WGC_Flag_non_affidato__c;
    let dataBKIT = crData.account.WGC_Data_Caricamento_BKIT__c;
    let dataRichiesta = crData.account.WGC_DataRichiestaCR__c;
    let isNSA = crData.opportunity.IsOppNSA__c;
    let presaVisione = crData.opportunity.WGC_Presa_Visione_CR__c;
    let noteCR = crData.opportunity.WGC_NoteCR__c;
    
    let config = {};

    let completed = (isEstero || isNSA || sbloccoFacile ? true : (validCR ? presaVisione == true : noteCR != null));
    let hasError = (!isEstero && !isNSA && !sbloccoFacile ? !validCR && noteCR == null : false);

    if (nonAffidato === true && (dataBKIT >= dataRichiesta || dataRichiesta == null)) { // CASO 4
        completed = true;
        hasError = false;
        config = {
            msg: $A.get("$Label.c.WGC_Cart_CRMessage_SoggettoNonAffidato"),
            graph: false,
            debs: true,
            dataRilevazione: dataBKIT ? new Date(dataBKIT) : null,
            dataRichiesta: dataRichiesta ? new Date(dataRichiesta) : null,
            note: true
        };
    } else if ((!hasCRData && nonAffidato === false && dataRichiesta != null) || (nonAffidato === true && dataBKIT < dataRichiesta)) { // CASO 5
        completed = (isEstero || isNSA || sbloccoFacile);
        hasError = false;
        config = {
            msg: $A.get("$Label.c.WGC_Cart_CRMessage_ElaborazioneInCorso"),
            graph: false,
            debs: true,
            dataRilevazione: null,
            dataRichiesta: dataRichiesta ? new Date(dataRichiesta) : null,
            note: false
        };
    } else { // CASO 3-6
        completed = (validCR && isValidCR) || isEstero;
        config = {
            msg: (isEstero ? $A.get("$Label.c.WGC_Cart_CRMessage_CentraleRischiNonNecessariaEstero") : (isValidCR ? "" : $A.get("$Label.c.WGC_Cart_CRMessage_CentraleRischiScaduta"))),
            graph: isValidCR,
            debs: true,
            dataRilevazione: lastCRDate ? new Date(lastCRDate) : null,
            dataRichiesta: dataRichiesta ? new Date(dataRichiesta) : null,
            note: isValidCR || isEstero
        };
    }

    component.set("v.config", config);
    component.set("v.visibleNote", config.note);
    component.set('v.dataRichiestaCR', config.dataRichiesta);

    appEvent.setParams({ "wizardItem": "analisiCR", "completed":completed, "hasError":hasError});
    appEvent.fire();
  }

})