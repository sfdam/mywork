({
	calculateFieldVisibility : function(component,event){

		if(component.get('v.workflowRecordCandidato.Stato__c') == 'BOZZA_DATI') {
			var lineaProdotto = component.get('v.workflowRecordCandidato.Tipologia_Segnalazione__c');

			if(lineaProdotto === 'FACTORING'){

				component.set('v.disabilitatoFACTORING',false);
				component.set('v.disabilitatoMUTUO',true);

				var cardP1 = component.find("cardLineaProdottoFactoring");
				$A.util.addClass(cardP1, 'selectedProductLine');

				var cardP2 = component.find("cardLineaProdottoMutuo");
				$A.util.removeClass(cardP2, 'selectedProductLine');
		
			}
		
			if(lineaProdotto === 'MUTUO'){
		
				component.set('v.disabilitatoFACTORING',true);
				component.set('v.disabilitatoMUTUO',false);
		
				var cardP1 = component.find("cardLineaProdottoFactoring");
				$A.util.removeClass(cardP1, 'selectedProductLine');

				var cardP2 = component.find("cardLineaProdottoMutuo");
				$A.util.addClass(cardP2, 'selectedProductLine');

			}

			if(lineaProdotto === 'MISTO'){
		
				component.set('v.disabilitatoFACTORING',false);
				component.set('v.disabilitatoMUTUO',false);
		
				var cardP1 = component.find("cardLineaProdottoFactoring");
				$A.util.addClass(cardP1, 'selectedProductLine');

				var cardP2 = component.find("cardLineaProdottoMutuo");
				$A.util.addClass(cardP2, 'selectedProductLine');

			} 
		} else {
				component.set('v.disabilitatoFACTORING',true);
				component.set('v.disabilitatoMUTUO',true);
		
				var cardP1 = component.find("cardLineaProdottoFactoring");
				$A.util.addClass(cardP1, 'selectedProductLine');

				var cardP2 = component.find("cardLineaProdottoMutuo");
				$A.util.addClass(cardP2, 'selectedProductLine');
		}
		
	},

	calculateLeasingFieldVisibility : function(component,event){

		if(component.get('v.workflowRecordCandidato.Stato__c') == 'BOZZA_DATI') {
			var lineaProdotto = component.get('v.workflowRecordCandidato.Tipologia_Segnalazione__c');

			if(lineaProdotto === 'LEASING'){

				component.set('v.disabilitatoLEASING',false);
				component.set('v.disabilitatoRENTAL',true);

				var cardP1 = component.find("cardLineaProdottoLeasing");
				$A.util.addClass(cardP1, 'selectedProductLine');

				var cardP2 = component.find("cardLineaProdottoRental");
				$A.util.removeClass(cardP2, 'selectedProductLine');
		
			}
		
			if(lineaProdotto === 'RENTAL'){
		
				component.set('v.disabilitatoLEASING',true);
				component.set('v.disabilitatoRENTAL',false);
		
				var cardP1 = component.find("cardLineaProdottoLeasing");
				$A.util.removeClass(cardP1, 'selectedProductLine');

				var cardP2 = component.find("cardLineaProdottoRental");
				$A.util.addClass(cardP2, 'selectedProductLine');

			}

			if(lineaProdotto === 'LEASINGRENTAL'){
		
				component.set('v.disabilitatoLEASING',false);
				component.set('v.disabilitatoRENTAL',false);
		
				var cardP1 = component.find("cardLineaProdottoLeasing");
				$A.util.addClass(cardP1, 'selectedProductLine');

				var cardP2 = component.find("cardLineaProdottoRental");
				$A.util.addClass(cardP2, 'selectedProductLine');

			} 
		} else {
				component.set('v.disabilitatoLEASING',true);
				component.set('v.disabilitatoRENTAL',true);
		
				var cardP1 = component.find("cardLineaProdottoLeasing");
				$A.util.addClass(cardP1, 'selectedProductLine');

				var cardP2 = component.find("cardLineaProdottoRental");
				$A.util.addClass(cardP2, 'selectedProductLine');
		}
		
	},

	getMetadata : function(component,event){
		//var enteSegnalante = component.get('v.workflowRecordCandidato.Ente_segnalante__c');
		var enteSegnalante = component.get('v.enteSegnalante');
		var opzioniBusinessPSE = component.get('v.opzBusiness');
		var chiaveEnte = enteSegnalante.substring(0,3);
		console.log('@@@A.M. chiaveEnte: ', chiaveEnte);
		var biMetadato;
			
		if(opzioniBusinessPSE == undefined){
			var action = component.get("c.getBI_PSE_Profili");
			action.setParams({chiaveEnte: chiaveEnte});
    
			action.setCallback( this , function(callbackResult) {
				if(callbackResult.getState()=='SUCCESS') {
					biMetadato = callbackResult.getReturnValue();
					component.set('v.opzBusiness', biMetadato.Opzioni_Business__c);
					console.log('@@@A.M. v.opzBusiness: ', component.get('v.opzBusiness'));
					
					switch (biMetadato.Opzioni_Business__c){
						case 'GENERALI':
							var opzioniBus = [
								{'label': 'Transportation', 'value': 'TSP'},
                                {'label': 'Strumentale (Medical, Industrial, Agriculture, Tech)', 'value': 'STR'},
							];
							component.set("v.opzioniBusiness", opzioniBus);
						
							var opzioniBusRental = [
								{'label': 'TECH', 'value': 'TECH'}
							];
							component.set("v.opzioniBusinessRental", opzioniBusRental);
							break;

						default:
							var opzioniBus = [
								{'label': 'Agricolo', 'value': 'AGR'},
								{'label': 'Industriale', 'value': 'IND'},
								{'label': 'Medicale', 'value': 'MED'},
								{'label': 'Tech', 'value': 'TECH'},
								{'label': 'Transportation', 'value': 'TSP'}
							];
							component.set("v.opzioniBusiness", opzioniBus);
							component.set("v.opzioniBusinessRental", opzioniBus);
					}
				}
				if(callbackResult.getState()=='ERROR') {
					console.log('ERROR', callbackResult.getError() ); 
				}
			});
			$A.enqueueAction( action ); 
		}     
    }, 

})