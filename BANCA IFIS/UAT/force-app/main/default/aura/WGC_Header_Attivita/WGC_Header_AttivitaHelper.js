({
	getUserEvent: function (component, event) {
        //Setting the Callback
        var action = component.get("c.getActivityUser");

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
})