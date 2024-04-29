({
	showToast : function(title, message, duration,type) {
        
        var toastEvent = $A.get("event.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration: duration,
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        
        toastEvent.fire();         
		
	},

	aggiornaTimeline : function(component, jsonSource) {
        
		component.set('v.jsonParsedTimelineEvent', JSON.parse(jsonSource));
		component.set('v.jsonParsedTimelineEvent', component.get('v.jsonParsedTimelineEvent').reverse());

		component.get('v.jsonParsedTimelineEvent').forEach(adjustDateTime);

		function adjustDateTime(value) {
			value.momento = $A.localizationService.formatDateTime(value.momento);
		}      
		
	},

	confermaPositivamentePreValutazioneLeasing : function(component, resolve, reject){

		var workflowRecord = component.get('v.workflowRecordCandidato');
		var nuovoStatoSegnalazione = 'PREVALUTAZIONE_OK';
		var descrizioneOperazione = 'Prevalutazione esitata positivamente';
		        
		component.set('v.isInProgressCensus', true);
		component.set('v.message', 'Censimento anagrafica in corso ....');
		
        var action = component.get("c.esitoPrevalutazioneSegnalazione");
        action.setParams({
            workflowRecord: workflowRecord,
            nuovoStatoSegnalazione: nuovoStatoSegnalazione,
			descrizioneOperazione: descrizioneOperazione
        });
    
        action.setCallback( this , function(callbackResult) {
    
            if(callbackResult.getState()=='SUCCESS') {
				workflowRecord.CommentoEsito__c = component.find("commentoEsito").get('v.value');
                var resultState = callbackResult.getReturnValue();
				workflowRecord.AccountCollegato__c = resultState.idAccountCreato;
				//component.set('v.isInProgressCensus', false);

                resolve( callbackResult.getReturnValue() );
            }
            if(callbackResult.getState()=='ERROR') {
                console.log('ERROR', callbackResult.getError() ); 
                reject( callbackResult.getError() );
            }

        });
            
        $A.enqueueAction( action ); 

    },

	completaValutazioneLeasing : function(component, resolve, reject){

		component.set('v.message', 'Apertura opportunità in corso ....');
		var action = component.get("c.completaPrevalutazioneSegnalazione");
		action.setParams({
			actualWorkflow: component.get("v.workflowRecordCandidato"),
			recordOppId : ''
		});
    
        action.setCallback( this , function(callbackResult) {
    
            if(callbackResult.getState()=='SUCCESS') {
				var resultState = callbackResult.getReturnValue();
				if(resultState.esitoGlobale){
					component.set('v.isInProgressCensus', false);
					//component.find("overlayLib").notifyClose();
					console.log('@@@ resultState debug ' , resultState);
					var event = $A.get("e.c:BI_PSE_CuscottoEsitazionePraticaEvent");
					event.setParams({InvioOpp:'PREVALUTAZIONE_OK'});
					event.fire();
				} else{
					helper.showToast('Errore nel salvataggio','Si è verificato un errore tecnico nella fase di salvataggio della segnalazione' + callbackResult.getReturnValue().erroreTecnico,'10000','error');
				}
                resolve( callbackResult.getReturnValue() );
            }
            if(callbackResult.getState()=='ERROR') {
                console.log('ERROR', callbackResult.getError() ); 
                reject( callbackResult.getError() );
            }

        });
            
        $A.enqueueAction( action ); 

    }
    
})