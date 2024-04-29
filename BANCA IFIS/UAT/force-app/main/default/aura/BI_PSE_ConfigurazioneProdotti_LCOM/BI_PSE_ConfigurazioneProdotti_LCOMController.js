({
    doInit : function(component,event,helper){ 
		// SDCHG-5538 Lettura Metadato per particolarizzazioni per Ente Segnalante
		helper.getMetadata(component,event); 	
    },  
	 
    handleRadioGroupLineaChange : function(component,event,helper){
	
		helper.calculateFieldVisibility(component,event);

    },

	handleRadioGroupLineaLeasingChange : function(component,event,helper){
	
		helper.calculateLeasingFieldVisibility(component,event);

    },
 
    handleRadioGroupLineaChange : function(component,event,helper){
	
		helper.calculateFieldVisibility(component,event);

    },

	handleRadioGroupLineaLeasingChange : function(component,event,helper){
	
		helper.calculateLeasingFieldVisibility(component,event);

    },
     
    handleRecordUpdated : function(component,event,helper){

        var eventParams = event.getParams();
		var tipoSegnalazione = component.get('v.workflowRecordCandidato.Tipo_Segnalazione__c');

        if(eventParams.changeType === "LOADED") {
			
			if(tipoSegnalazione == 'FACTORING'){

				helper.calculateFieldVisibility(component,event);
				
				if(JSON.parse(component.get('v.workflowRecordCandidato.PRD_FACTORING_JSON__c')) === null){
					component.set('v.workflowRecordCandidato.PRD_FACTORING_JSON__c','[]');
				}
				else{
			
					var jsonObject = JSON.parse(component.get('v.workflowRecordCandidato.PRD_FACTORING_JSON__c'));

					// ASSEGNAZIONI

					component.set("v.aggiuntaStimaFabbisognoFinanziarioFactoring", jsonObject.fabbisognoFinanziarioFactoring);
					component.set("v.aggiuntaNaturaClientiFactoring", jsonObject.naturaClientiFactoring);
					component.set("v.aggiuntaNazionalitaClientiFactoring", jsonObject.nazionalitaClientiFactoring);
					component.set("v.aggiuntaNoteFactoring", jsonObject.noteFactoring);
				 
				}

				if(JSON.parse(component.get('v.workflowRecordCandidato.PRD_MUTUO_JSON__c')) === null){
					component.set('v.workflowRecordCandidato.PRD_MUTUO_JSON__c','[]');
				} else {
			
					var jsonObject = JSON.parse(component.get('v.workflowRecordCandidato.PRD_MUTUO_JSON__c'));

					// ASSEGNAZIONI

					component.set("v.aggiuntaImportoMutuo", jsonObject.importoMutuo);
					component.set("v.aggiuntaDurataAmmortamentoMutuo", jsonObject.durataAmmortamentoMutuo);
					component.set("v.aggiuntaDurataPreammortamentoMutuo", jsonObject.durataPreammortamentoMutuo);
					component.set("v.aggiuntaFinalitaMutuo", jsonObject.finalitaMutuo);
					component.set("v.aggiuntaNoteMutuo", jsonObject.noteMutuo);
				 
				}
			} else {
			
				helper.calculateLeasingFieldVisibility(component,event);
				
				if(JSON.parse(component.get('v.workflowRecordCandidato.PRD_LEASING_JSON__c')) === null){
					component.set('v.workflowRecordCandidato.PRD_LEASING_JSON__c','[]');
				} else {
			
					var jsonObject = JSON.parse(component.get('v.workflowRecordCandidato.PRD_LEASING_JSON__c'));

					// ASSEGNAZIONI

					component.set("v.aggiuntaImportoLeasing", jsonObject.importoLeasing);
					component.set("v.aggiuntaBusinessLeasing", jsonObject.businessLeasing);
					component.set("v.aggiuntaNoteLeasing", jsonObject.noteLeasing);
				 
				}

				if(JSON.parse(component.get('v.workflowRecordCandidato.PRD_RENTAL_JSON__c')) === null){
					component.set('v.workflowRecordCandidato.PRD_RENTAL_JSON__c','[]');
				} else {
			
					var jsonObject = JSON.parse(component.get('v.workflowRecordCandidato.PRD_RENTAL_JSON__c'));

					// ASSEGNAZIONI

					component.set("v.aggiuntaImportoRental", jsonObject.importoRental);
					component.set("v.aggiuntaBusinessRental", jsonObject.businessRental);
					component.set("v.aggiuntaNoteRental", jsonObject.noteRental);
				 
				}

			}

		}	
    },     
    
    handleNavigate: function(component, event , helper) {

		var overallValidity = true;
		var tipoSegnalazione = component.get('v.workflowRecordCandidato.Tipo_Segnalazione__c');
		var opzBusiness = component.get('v.opzBusiness');

		if(tipoSegnalazione == 'FACTORING'){
			var inputFabbisognoFinanziarioFactoring = component.find("flowInputFabbisognoFinanziarioFactoringInputId").get("v.value");
			if(!inputFabbisognoFinanziarioFactoring) inputFabbisognoFinanziarioFactoring = '';

			var inputNaturaClientiFactoring = component.find("flowInputNaturaClientiFactoringInputId").get("v.value");
			if(!inputNaturaClientiFactoring) inputNaturaClientiFactoring = '';

			var inputNazionalitaClientiFactoring = component.find("flowInputNazionalitaClientiFactoringInputId").get("v.value");
			if(!inputNazionalitaClientiFactoring) inputNazionalitaClientiFactoring = '';

			var InputNoteFactoring = component.find("flowInputNoteFactoringInputId").get("v.value");
			if(!InputNoteFactoring) InputNoteFactoring = '';

			var inputImportoMutuo = component.find("flowInputImportoMutuoInputId").get("v.value");
			if(!inputImportoMutuo) inputImportoMutuo = '';

			var inputDurataAmmortamentoMutuo = component.find("flowInputDurataAmmortamentoMutuoInputId").get("v.value");
			if(!inputDurataAmmortamentoMutuo) inputDurataAmmortamentoMutuo = '';

			var inputDurataPreammortamentoMutuo = component.find("flowInputDurataPreammortamentoMutuoInputId").get("v.value");
			if(!inputDurataPreammortamentoMutuo) inputDurataPreammortamentoMutuo = '';

			var inputFinalitaMutuo = component.find("flowInputFinalitaMutuoInputId").get("v.value");
			if(!inputFinalitaMutuo) inputFinalitaMutuo = '';

			var inputNoteMutuo = component.find("flowInputNoteMutuoInputId").get("v.value");
			if(!inputNoteMutuo) inputNoteMutuo = '';

			// VERIFICA DELLA SEZIONE DATI RELATIVI ALLA PAGINA           
			if(!component.find("flowInputFabbisognoFinanziarioFactoringInputId").get("v.validity").valid){
				overallValidity = false;
            	component.find("flowInputFabbisognoFinanziarioFactoringInputId").reportValidity();
            }

			if(!component.find("flowInputImportoMutuoInputId").get("v.validity").valid){
				overallValidity = false;
            	component.find("flowInputImportoMutuoInputId").reportValidity();
            }

			if(!component.find("flowInputDurataAmmortamentoMutuoInputId").get("v.validity").valid){
            	overallValidity = false;
            	component.find("flowInputDurataAmmortamentoMutuoInputId").reportValidity();
            }

			if(!component.find("flowInputDurataPreammortamentoMutuoInputId").get("v.validity").valid){
            	overallValidity = false;
            	component.find("flowInputDurataPreammortamentoMutuoInputId").reportValidity();
            }
		} else {

			//campi Leasing
			var inputImportoLeasing = component.find("flowInputImportoLeasingInputId").get("v.value");
			if(!inputImportoLeasing) inputImportoLeasing = '';
			
			var inputBusinessLeasing = component.find("flowInputBusinessLeasingInputId").get("v.value");
			if(!inputBusinessLeasing) inputBusinessLeasing = '';
			
			var inputNoteLeasing = component.find("flowInputNoteLeasingInputId").get("v.value");
			if(!inputNoteLeasing) inputNoteLeasing = '';
			
			var inputImportoRental = component.find("flowInputImportoRentalInputId").get("v.value");
			if(!inputImportoRental) inputImportoRental = '';
			
			var inputBusinessRental = component.find("flowInputBusinessRentalInputId").get("v.value");
			if(!inputBusinessRental) inputBusinessRental = '';
			
			var inputNoteRental = component.find("flowInputNoteRentalInputId").get("v.value");
			if(!inputNoteRental) inputNoteRental = '';

			// VERIFICA DELLA SEZIONE DATI RELATIVI ALLA PAGINA
			if(!component.find("flowInputImportoLeasingInputId").get("v.validity").valid){
            	overallValidity = false;
            	component.find("flowInputImportoLeasingInputId").reportValidity();
            }


			if(!component.find("flowInputBusinessLeasingInputId").get("v.validity").valid){
            	overallValidity = false;
            	component.find("flowInputBusinessLeasingInputId").reportValidity();
            }

			if(!component.find("flowInputImportoRentalInputId").get("v.validity").valid){
            	overallValidity = false;
				component.find("flowInputImportoRentalInputId").reportValidity();
            }

			if(!component.find("flowInputBusinessRentalInputId").get("v.validity").valid){
            	overallValidity = false;
            	component.find("flowInputBusinessRentalInputId").reportValidity();
            }
		}

        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'    
		 
        if(!overallValidity){       
			return;  
        } else {
			// CREAZIONE DEL PALYLOAD CHE RAPPRERENTA IL PRODOTTO
			
			if(tipoSegnalazione == 'FACTORING'){

				var payloadProdottoFactoring;
				payloadProdottoFactoring  = '{"fabbisognoFinanziarioFactoring": "' + inputFabbisognoFinanziarioFactoring + '", "naturaClientiFactoring": "' + inputNaturaClientiFactoring + '", "nazionalitaClientiFactoring": "' + inputNazionalitaClientiFactoring + '", "noteFactoring": "' + InputNoteFactoring.replace(/[\n\r]/g, ' ') + '"}';

				component.set('v.workflowRecordCandidato.PRD_FACTORING_JSON__c', payloadProdottoFactoring);   
				//SDCHG-5739 - Nuovo campo "importo segnalato factoring" reportizzabile
				component.set('v.workflowRecordCandidato.Importo_Segnalato_Factoring__c', inputFabbisognoFinanziarioFactoring);

				var payloadProdottoMutuo;
				payloadProdottoMutuo  = '{"importoMutuo": "' + inputImportoMutuo + '", "durataAmmortamentoMutuo": "' + inputDurataAmmortamentoMutuo + '", "durataPreammortamentoMutuo": "' + inputDurataPreammortamentoMutuo + '", "finalitaMutuo": "' + inputFinalitaMutuo + '", "noteMutuo": "' + inputNoteMutuo.replace(/[\n\r]/g, ' ') + '"}';

				component.set('v.workflowRecordCandidato.PRD_MUTUO_JSON__c', payloadProdottoMutuo);
				//SDCHG-5739 - Nuovo campo "importo segnalato mutuo" reportizzabile
				component.set('v.workflowRecordCandidato.Importo_Segnalato_Mutuo__c', inputImportoMutuo);
				
			} else {
				
				var payloadProdottoLeasing;
				payloadProdottoLeasing  = '{"importoLeasing": "' + inputImportoLeasing + '", "businessLeasing": "' + inputBusinessLeasing + '", "noteLeasing": "' + inputNoteLeasing.replace(/[\n\r]/g, ' ') + '"}';

				component.set('v.workflowRecordCandidato.PRD_LEASING_JSON__c', payloadProdottoLeasing);   

				var payloadProdottoRental;
				payloadProdottoRental  = '{"importoRental": "' + inputImportoRental + '", "businessRental": "' + inputBusinessRental + '", "noteRental": "' + inputNoteRental.replace(/[\n\r]/g, ' ') + '"}';

				component.set('v.workflowRecordCandidato.PRD_RENTAL_JSON__c', payloadProdottoRental);   
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
        
        
    }    
})