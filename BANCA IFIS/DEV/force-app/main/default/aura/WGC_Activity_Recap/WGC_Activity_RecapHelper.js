({
  initialize: function (component, event, helper) {
    //reading parameters from url
    this.readParametersFromURL(component);
    //Metodo per recuperare le info per i vari tab
    this.getData(component, event, helper);

    //Metodo per recuperare le info dell'utente
    this.getProfile(component, event, helper).then((result) => {
      console.log("@@@ result promise ", result);
      this.setTabs(component, event, helper);
    });

    //this.setTabs(component, event, helper);
  },

  //S read parameters from url AdF
	readParametersFromURL: function(component){
		let sPageURL = decodeURIComponent(window.location.search.substring(1)); //whole URL of the page
    let sURLVariableCouples = sPageURL.split('&');
		if(sURLVariableCouples.length > 0){
			let sParameterCouple;
			sURLVariableCouples.forEach(element => {
				sParameterCouple = element.split('=');
				if(sParameterCouple[0] == 'c__currentUserId'){
					component.set('v.currentUserId', sParameterCouple[1]);
				}else if(sParameterCouple[0] == 'c__currentUserLevel'){
					component.set('v.currentUserLevel', sParameterCouple[1]);
				}else if(sParameterCouple[0] == 'c__filterValue'){
					component.set('v.filterValue', sParameterCouple[1]);
				}else if(sParameterCouple[0] == 'c__tipoFiltro'){
					component.set('v.tipoFiltro', sParameterCouple[1]);
				}
			});
			return true;
		}else{
			return false;
		}
	},
	//E read parameters from url AdF

  //S lightning channel message AdF
	handleMessage: function(component, event){
    if(event != null){
        let currentUserIdFromPayload = (event.getParam("currentUserId") != null) ? event.getParam("currentUserId") : '';
        let currentUserLevelFromPayload = (event.getParam("currentUserLevel") != null) ? event.getParam("currentUserLevel") : '';
        let filterValueFromPayload = (event.getParam("filterValue") != null) ? event.getParam("filterValue") : '';
        let tipoFiltroFromPayload = (event.getParam("tipoFiltro") != null) ? event.getParam("tipoFiltro") : '';
        component.set('v.currentUserId', currentUserIdFromPayload);
        component.set('v.currentUserLevel', currentUserLevelFromPayload);
        component.set('v.filterValue', filterValueFromPayload);
        component.set('v.tipoFiltro', tipoFiltroFromPayload);
    }
  },
  //E lightning channel message AdF

  getData: function (component, event, helper) {
    var action = component.get("c.getHeaderData");

    //S add parameters if inizialized AdF
    if(component.get('v.currentUserId') != null && component.get('v.currentUserLevel') != null && component.get('v.filterValue') != null && component.get('v.tipoFiltro')){
      action.setParams({ 
        currentUserId : component.get('v.currentUserId'), 
        currentUserLevel : component.get('v.currentUserLevel'), 
        filterValue : component.get('v.filterValue'), 
        tipoFiltro : component.get('v.tipoFiltro') 
      });
    }
    //E add parameters if inizialized AdF

    action.setCallback(this, (response) => {
      if (response.getState() == "SUCCESS") {
        var risposta = response.getReturnValue();
        console.log("@@@ risposta ", risposta);
        if (risposta.success) {
          //Recupero i tab ed aggiorno i conteggi
          var tabs = component.get("v.tabs");
          var data = risposta.data[0];
          component.set("v.dati", risposta.data[0]);

          //Aggiorno il conteggio dell'header
          if (tabs.length > 0) {
            tabs.forEach((item, index) => {
              for (var key in data) {
                if (key == item.object) {
                  item.count = data[key].records.length;
                  if (item.object == "event") {
                    var diffId = [];
                    var countDiff = 0;
                    if (data[key].records.length > 0) {
                      data[key].records.forEach(function (element) {
                        if (diffId.indexOf(element.AccountId) == -1) {
                          diffId.push(element.AccountId);
                          countDiff++;
                        }
                      });
                    }
                    item.countAccount = countDiff;
                  }
                }
              }
            });
          }

          component.set("v.tabs", tabs);

          //Formatto i dati per ogni lista
          for (var key in data) {
            component.set("v.objectName", key);
            // this.formatData(component, event, helper, data[key]);
          }
          //Disattivo lo spinner dopo aver caricato i dati
          component.set("v.isLoaded", true);

          //Setto il tab default
          var pg = component.get("v.pageReference");
          console.log("@@@ pg ", pg);

          component.set("v.listaDati", data.task);
          component.set("v.objectName", "task");

          var a = component.find("container");
          //TODO
          console.log("@@@ a ", a);
          //Messo questo if per evitare eccezzione durante il doInit
          if (a != undefined && a.toString() != "undefined") {
            a.forEach((item, index) => {
              if (index == 0) {
                $A.util.addClass(a[index], "active");
              }
            });
          }
        } else {
          console.log("@@@ eccezione ", risposta.message);
        }
      } else {
        console.log("@@@ errore ", JSON.stringify(response.getError())); //AdF
      }
    });

    $A.enqueueAction(action);
  },

  formatData: function (component, event, helper, lista) {
    var columns = [];

    if (
      lista.campiTabella != null &&
      lista.campiTabella != undefined &&
      lista.campiTabella.length > 0
    ) {
      lista.campiTabella.forEach((item, index) => {
        var singleCol = {
          label: item.label,
          fieldName: item.apiName,
          type: item.type
        };
        columns.push(singleCol);
      });

      var type = component.get("v.objectName");

      if (type == "task") {
        var actions = {
          label: "Azione",
          type: "button",
          initialWidth: 150,
          typeAttributes: {
            label: "Seleziona Esito",
            name: "Seleziona Esito",
            title: "Seleziona Esito",
            class: "btn_next"
          },
          class: "btn_next"
        };
        columns.push(actions);
      }

      component.set("v.columns", columns);

      if (
        lista.records.length > 0 &&
        lista.records != null &&
        lista.records != undefined
      ) {
        lista.records.forEach((item, index) => {
          if (columns.length > 0) {
            columns.forEach((col, colInd) => {
              var rec = {};
              if (col.fieldName == undefined) {
                return;
              }
              //Usato quando il campo si trova direttamente nell'oggetto
              if (!col.fieldName.includes(".")) {
                //Metodo per formattare i vari tipi di dato
                // item[col.fieldName] = this.formatField(component, event, helper, item[col.fieldName], col);
                rec[col.fieldName] = item[col.fieldName];
              } else {
                //Usato quando esistono campi di lookup su altri oggetti
                var tmp = col.fieldName.split(".");
                rec[col.fieldName] = item[tmp[0]][tmp[1]];
              }
            });
          }
        });
      }
    }
  },

  setTabs: function (component, event, helper) {
    var tabs = [];
    var labels = [];

    var tipoUtente = component.get("v.userInfo");
    console.log("@@@ tipoUtente ", JSON.stringify(tipoUtente));
    if (
      tipoUtente.Qualifica_Utente__c != null && //AdF
      tipoUtente.Qualifica_Utente__c.toLowerCase() ==
      "Filo Diretto".toLowerCase()
    ) {
      labels = [
        { label: "Aziende da contattare", object: "task" },
        { label: "Aziende da visitare", object: "event" },
        { label: "Opportunità da completare", object: "oppIstruttoria" },
        { label: "Contratti da firmare", object: "oppPerfContratti" },
        { label: "Clienti da attivare", object: "oppAttProdotto" },
        { label: "Commerciali da contattare", object: "promemoria" }
      ];

      labels.forEach((item, index) => {
        if (item.object == "event") {
          var singleTab = {
            count: 0,
            label: item.label,
            object: item.object,
            countAccount: 0
          };
          tabs.push(singleTab);
        } else {
          var singleTab = { count: 0, label: item.label, object: item.object };
          tabs.push(singleTab);
        }
      });
    } else {
      labels = [
        { label: $A.get("$Label.c.WGC_Header_Attivita_TaskDiffAccount"), object: 'task' },
        { label: $A.get("$Label.c.WGC_Header_Attivita_EventDaEsitare"), object: 'event'},
        { label: $A.get("$Label.c.WGC_Header_Attivita_OpportunityDaFinalizzare"), object: 'oppIstruttoria' },
        { label: $A.get("$Label.c.WGC_Header_Attivita_OpportunityDaFarFirmare"), object: 'oppPerfContratti' },
        { label: $A.get("$Label.c.WGC_Header_Attivita_OpportunityDaAttivare"), object: 'oppAttProdotto'},
        //{ label: $A.get("$Label.c.WGC_Activity_Recap_completateTask"), object: "completateTask" }, //AdF
        //{ label: "Visite completate", object: "completateEvent" } //AdF
      ];

      labels.forEach((item, index) => {
        if (item.object == "event") {
          var singleTab = {
            count: 0,
            label: item.label,
            object: item.object,
            countAccount: 0
          };
          tabs.push(singleTab);
        } else {
          var singleTab = { count: 0, label: item.label, object: item.object };
          tabs.push(singleTab);
        }
      });
    }

    component.set("v.tabs", tabs);
  },

  getProfile: function (component, event, helper) {
    return new Promise((resolve, reject) => {
      var uId = $A.get("$SObjectType.CurrentUser.Id");
      var action = component.get("c.getUserType");
      action.setParams({
        userId: uId
      });
      action.setCallback(this, (response) => {
        if (response.getState() == "SUCCESS") {
          var risposta = response.getReturnValue();
          console.log("@@@ risposta utente ", risposta.data[0]);

          component.set("v.userInfo", risposta.data[0]);

          resolve(risposta.data[0]);
        } else {
          console.log("@@@ error ", response.getError());
          reject(response.getError());
        }
      });
      $A.enqueueAction(action);
    });
  }
});