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
		
	}

})