({
    doInit : function(component,event,helper){

    },

    isRefreshed : function(component,event,helper){

    },

    handleComboMotivazioneRifiutoChange : function(component,event,helper){
		var workflowRecord = component.get('v.workflowRecordCandidato');
		workflowRecord.MotivazioneRifiutoPrevalutazione__c = component.find("inputSegnalazioneRifiutoId").get('v.value');

    },

    handleRecordUpdated : function(component,event,helper){

    	var changeType = event.getParams().changeType;

		if (changeType === "LOADED") { 

			helper.aggiornaTimeline(component,component.get('v.workflowRecordCandidato.TIMELINE_JSON__c'));

        }    

        if (changeType === "CHANGED") { 
            
            component.find("flowRecordHandlerWorkflowCandidatoId").reloadRecord(); 
        
        }        

    },

    handleClickSegnalazionePercorribile : function(component,event,helper){



	},

    handleClickConfermaNegativamentePreValutazione : function(component,event,helper){

		var workflowRecord = component.get('v.workflowRecordCandidato');
        var motivazioneRifiutoPrevalutazione = component.get('v.workflowRecordCandidato.MotivazioneRifiutoPrevalutazione__c');
		var nuovoStatoSegnalazione = 'PREVALUTAZIONE_KO';
		var descrizioneOperazione = 'Prevalutazione esitata negativamente';

		workflowRecord.CommentoEsito__c = (component.find("commentoEsito")).get("v.value");
		component.set('v.isInProgressCensus', true);
		component.set('v.message', 'Censimento anagrafica in corso ....');
	
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c.esitoPrevalutazioneSegnalazione");
            action.setParams({
                workflowRecord: workflowRecord,
                motivazioneRifiutoPrevalutazione: motivazioneRifiutoPrevalutazione,
                nuovoStatoSegnalazione: nuovoStatoSegnalazione,
				descrizioneOperazione: descrizioneOperazione
            });
    
            action.setCallback( this , function(callbackResult) {
    
                if(callbackResult.getState()=='SUCCESS') {
                    
					component.set('v.isInProgressCensus', false);

                    resolve( 
                        callbackResult.getReturnValue()
                        
                    );

                    if(callbackResult.getReturnValue().esitoGlobale){

                        helper.showToast('Segnalazione prevalutata con successivo','La segnalazione si è chiusa con prevalutazione negativa','3000','warning');

						helper.aggiornaTimeline(component, callbackResult.getReturnValue().timelineAggiornata);

						component.set('v.workflowRecordCandidato.Stato__c', callbackResult.getReturnValue().statoAggiornato);

						$A.get('e.force:refreshView').fire();

                    }
                    else {
                        
                        helper.showToast('Errore nel salvataggio','Si è verificato un errore tecnico nella fase di salvataggio della segnalazione. ' + callbackResult.getReturnValue().erroreTecnico,'10000','error');                        
                        
                    }
                                       
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }

            });
            
            $A.enqueueAction( action ); 
    
        }));       
        
        return promise;  

    },

    handleClickConfermaPositivamentePreValutazione : function(component,event,helper){

		var workflowRecord = component.get('v.workflowRecordCandidato');
		var nuovoStatoSegnalazione = 'PREVALUTAZIONE_OK';
		var descrizioneOperazione = 'Prevalutazione esitata positivamente';
		        
		component.set('v.isInProgressCensus', true);
		component.set('v.message', 'Censimento anagrafica in corso ....');
		
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
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
					component.set('v.isInProgressCensus', false);

                    resolve( 
                        callbackResult.getReturnValue()
                        
                    );
    
                    if(callbackResult.getReturnValue().esitoGlobale){
		
						$A.createComponent("c:WGC_SegnalatoriFlowGenericContainer", {
							accountId: callbackResult.getReturnValue().idAccountCreato,
							tipo : "opportunit",
							flowName : "Crea_Opportunit_Portale_Segnalatori",
							workflowRecord : workflowRecord
						},
						function(content, status) {
							if (status === "SUCCESS") {
								component.find('overlayLib').showCustomModal({
									header: $A.get("$Label.c.WGC_Account_Header_Crea_Opportunit"),
									body: content,
									showCloseButton: true,
									cssClass: "mymodal slds-modal_medium",
									closeCallback: function() {}
								});
							}
						});
						
						 /*	helper.aggiornaTimeline(component, callbackResult.getReturnValue().timelineAggiornata);*/
                    }
                    else {
                        
                        helper.showToast('Errore nel salvataggio','Si è verificato un errore tecnico nella fase di salvataggio della segnalazione' + callbackResult.getReturnValue().erroreTecnico,'10000','error');                              
                        
                    }
                                       
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }

            });
            
            $A.enqueueAction( action ); 
    
        }));       
        
        return promise;  

    },

	handlePreValutazioneOkLeasing : function(component, event, helper) {
		console.log("ENTRA handlePreValutazioneOkLeasing 1");
        return new Promise($A.getCallback(function(resolve, reject) {
			helper.confermaPositivamentePreValutazioneLeasing(component, resolve, reject);
        }))
		.then(
			$A.getCallback(function (result) {
				console.log("ENTRA handlePreValutazioneOkLeasing 2");
				return new Promise($A.getCallback(function(resolve, reject) {
					helper.completaValutazioneLeasing(component, resolve, reject);
				}));
			}));
    },

	handleCheckOpp : function(component,event,helper){
		component.set('v.workflowRecordCandidato.Stato__c', event.getParam('InvioOpp'));
		$A.get('e.force:refreshView').fire();
		helper.showToast('Segnalazione prevalutata con successivo','La segnalazione si è chiusa con prevalutazione positiva','3000','success');
	},

    handleClickAnnullaPreValutazione : function(component,event,helper){

		var valoreSegnalazionePercorribile = component.get('v.valoreSegnalazionePercorribile');

		if(valoreSegnalazionePercorribile == 'NO'){

			component.find("inputSegnalazionePercorribileId").set("v.value", null);

			component.find("inputSegnalazioneRifiutoId").set("v.value", null);

		}

		if(valoreSegnalazionePercorribile == 'SI'){

			component.find("inputSegnalazionePercorribileId").set("v.value", null);

		}


    }

})