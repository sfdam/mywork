({
	getUserEvent: function (component, hasParameters) {
        //Setting the Callback
        var action = component.get("c.getActivityUser");
		//AdF
		if(hasParameters == true){
			action.setParams({ 
				currentUserId : component.get('v.currentUserId'), 
				currentUserLevel : component.get('v.currentUserLevel'), 
				filterValue : component.get('v.filterValue'), 
				tipoFiltro : component.get('v.tipoFiltro') 
			});
		}

        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
				var oggi = new Date();

				var taskScaduti = 0;
				var visiteScadute = 0;

                var result = response.getReturnValue();
                console.log(result);
				
				var diffAccountTask = [];
				result.data[0].taskList.forEach(function (element) { 
                    if(element.RecordType.DeveloperName != 'Promemoria' && diffAccountTask.indexOf(element.AccountId) == -1){
						diffAccountTask.push(element.AccountId);
						
					}
					if(new Date(element.ActivityDate) < oggi){
						taskScaduti ++;
					}
				});
				component.set('v.aziendeDaContattare', diffAccountTask.length);
				component.set('v.taskScaduti', taskScaduti);

				var diffEsitoEvent = [];
				result.data[0].eventList.forEach(function (element) {
                    if(!element.hasOwnProperty('EsitoLivello1__c') && diffEsitoEvent.indexOf(element.AccountId) == -1){
						diffEsitoEvent.push(element.AccountId);
						if(new Date(element.Data_Fine__c) < oggi){
							visiteScadute ++;
						}
					}
				});
				component.set('v.visiteDaEsitare', diffEsitoEvent.length);
				component.set('v.visiteScadute', visiteScadute);

				var countInLavorazione = 0;
				var countRedazioneContratto = 0;
				var countPerfezionamentoContratto = 0;

				var optyScadute = 0;
				var optyScaduteContratto = 0;
				var optyScadutePerf = 0;
				
				
				result.data[0].opportunityList.forEach(function (element) {
					if(element.StageName == 'In Istruttoria'){
						countInLavorazione ++;
						if(new Date(element.CloseDate) < oggi){
							optyScadute ++;
						}
					} else if(element.StageName == 'Perfezionamento Contratto'){
						countRedazioneContratto ++;
						if(new Date(element.CloseDate) < new Date(oggi)){
							optyScaduteContratto ++;
						}
					} else if(element.StageName == 'Attivazione'){
						countPerfezionamentoContratto ++;
						if(new Date(element.CloseDate) < new Date(oggi)){
							optyScadutePerf ++;
						}
					}
				});

				//console.log('optyScadute: ' + optyScadute);
				//console.log('optyScaduteContratto: ' + optyScaduteContratto);
				//console.log('optyScadutePerf: ' + optyScadutePerf);
				//console.log('countInLavorazione: ' + countInLavorazione);
				//console.log('countRedazioneContratto: ' + countRedazioneContratto);
				//console.log('countPerfezionamentoContratto: ' + countPerfezionamentoContratto);
				component.set('v.optyScadute' , optyScadute);
				component.set('v.optyScaduteContratto', optyScaduteContratto);
				component.set('v.optyScadutePerf', optyScadutePerf);
				component.set('v.opportunitaDaFinalizzare', countInLavorazione);
				component.set('v.contrattiDaFarFirmare', countRedazioneContratto);
				component.set('v.clientiDaAttivare', countPerfezionamentoContratto);
                

            } else if (state == "ERROR") {
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },

	//S lightning channel message AdF
	handleMessage : function(component, event){
        if(event != null){
            let currentUserIdFromPayload = (event.getParam("currentUserId") != null) ? event.getParam("currentUserId") : '';
            let currentUserLevelFromPayload = (event.getParam("currentUserLevel") != null) ? event.getParam("currentUserLevel") : '';
            let filterValueFromPayload = (event.getParam("filterValue") != null) ? event.getParam("filterValue") : '';
            let tipoFiltroFromPayload = (event.getParam("tipoFiltro") != null) ? event.getParam("tipoFiltro") : '';
            component.set('v.currentUserId', currentUserIdFromPayload);
            component.set('v.currentUserLevel', currentUserLevelFromPayload);
            component.set('v.filterValue', filterValueFromPayload);
            component.set('v.tipoFiltro', tipoFiltroFromPayload);

            let pageReference = component.get("v.pageReference");
            pageReference.state.c__currentUserId = currentUserIdFromPayload;
            pageReference.state.c__currentUserLevel = currentUserLevelFromPayload;
            pageReference.state.c__filterValue = filterValueFromPayload;
            pageReference.state.c__tipoFiltro = tipoFiltroFromPayload;
            component.set("v.pageReference", pageReference);
        }
    },
	//E lightning channel message AdF

	//S read parameters from url AdF
	readParameters : function(component){
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
})