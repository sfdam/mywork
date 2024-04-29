({
	handleChange : function(component,event,helper){
        var tipoSegnalazione = component.get('v.workflowRecordCandidato.Tipo_Segnalazione__c');
		if(tipoSegnalazione == 'FACTORING'){
			component.set('v.workflowRecordCandidato.PRD_LEASING_JSON__c',null);
			component.set('v.workflowRecordCandidato.PRD_RENTAL_JSON__c',null);
		} else {
			component.set('v.workflowRecordCandidato.PRD_FACTORING_JSON__c',null);
			component.set('v.workflowRecordCandidato.PRD_MUTUO_JSON__c',null);
		}
        
    },

   handleNavigate: function(component, event , helper) {

		// CONTROLLI DI VALIDITA'
        var overallValidity = true;		
		var abilitaProdottiMultipli = component.get('v.abilitaProdottiMultipli');
		var sceltaProdotto;
		
		if(abilitaProdottiMultipli){
			sceltaProdotto = component.find("flowInputSceltaProdottoLeasingFactoringInputId").get("v.value");

			// VERIFICA DELLA SEZIONE DATI RELATIVI ALLA PAGINA      
			if(!component.find("flowInputSceltaProdottoLeasingFactoringInputId").get("v.validity").valid){
            
				overallValidity = false;
            
				component.find("flowInputSceltaProdottoLeasingFactoringInputId").reportValidity();
            
			}
		} else {
			sceltaProdotto = component.find("flowInputSceltaProdottoFactoringInputId").get("v.value");

			// VERIFICA DELLA SEZIONE DATI RELATIVI ALLA PAGINA
			if(!component.find("flowInputSceltaProdottoFactoringInputId").get("v.validity").valid){
            
				overallValidity = false;
            
				component.find("flowInputSceltaProdottoFactoringInputId").reportValidity();
            
			}
		}

        var navigate = component.get("v.navigateFlow");
		 
        if(!overallValidity){       
            
            return;
            
        }
        else {

			// CREAZIONE DEL PALYLOAD CHE RAPPRERENTA IL PRODOTTO
			if(abilitaProdottiMultipli){
				component.set('v.workflowRecordCandidato.flowInputSceltaProdottoLeasingFactoringInputId', sceltaProdotto);  
			} else {				
				component.set('v.workflowRecordCandidato.flowInputSceltaProdottoFactoringInputId', sceltaProdotto);
			}
            component.find("flowRecordHandlerWorkflowCandidatoId").saveRecord($A.getCallback(function(saveResult) {
                
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    
						navigate(event.getParam("action"));
                   
                } else if (saveResult.state === "INCOMPLETE") {
                    
                    console.log("User is offline, device doesn't support drafts.");
                    
                } else if (saveResult.state === "ERROR") {
                    
                    console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                    
                } else {
                    
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                    
                }
            }));   
        }
    },

	recordUpdated: function(component, event , helper) {
		var changeType = event.getParams().changeType;
		
        if(changeType === "LOADED") {
			var enteSegnalante = component.get('v.workflowRecordCandidato.Ente_segnalante__c');
			var abilitaProdottiMultipli = component.get('v.abilitaProdottiMultipli');
			var chiaveEnte = enteSegnalante.substring(0,3);
			
			if(abilitaProdottiMultipli == undefined){
				var action = component.get("c.ricercaProfiliAbilitati");
				action.setParams({
					chiaveEnte: chiaveEnte
				});
    
				action.setCallback( this , function(callbackResult) {
					if(callbackResult.getState()=='SUCCESS') {
						component.set('v.abilitaProdottiMultipli', callbackResult.getReturnValue());
					}
					if(callbackResult.getState()=='ERROR') {
						console.log('ERROR', callbackResult.getError() ); 
					}
				});
				$A.enqueueAction( action ); 
			}
		}
	}
})