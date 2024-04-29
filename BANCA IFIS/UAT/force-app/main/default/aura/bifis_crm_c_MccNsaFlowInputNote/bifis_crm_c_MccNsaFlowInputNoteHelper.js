({
	calculateFieldVisibility : function(component,event){

		var lineaProdotto = component.get('v.workflowRecordCandidato.Tipologia_Mutuo__c');

		if(lineaProdotto === 'STANDARD'){

			component.set('v.disabilitatoSTANDARD',false);
			component.set('v.disabilitatoASSICURATIVO',true);

			var cardP1 = component.find("cardLineaProdottoMccNsa");
			$A.util.addClass(cardP1, 'selectedProductLine');

			var cardP2 = component.find("cardLineaProdottoMccNsaSA");
			$A.util.removeClass(cardP2, 'selectedProductLine');
		
		}
		
		if(lineaProdotto === 'ASSICURATIVO'){
		
			component.set('v.disabilitatoSTANDARD',true);
			component.set('v.disabilitatoASSICURATIVO',false);
		
			var cardP1 = component.find("cardLineaProdottoMccNsa");
			$A.util.removeClass(cardP1, 'selectedProductLine');

			var cardP2 = component.find("cardLineaProdottoMccNsaSA");
			$A.util.addClass(cardP2, 'selectedProductLine');

		}

		if(lineaProdotto === 'MISTO'){
		
			component.set('v.disabilitatoSTANDARD',false);
			component.set('v.disabilitatoASSICURATIVO',false);
		
			var cardP1 = component.find("cardLineaProdottoMccNsa");
			$A.util.addClass(cardP1, 'selectedProductLine');

			var cardP2 = component.find("cardLineaProdottoMccNsaSA");
			$A.util.addClass(cardP2, 'selectedProductLine');

		}
		
	}
})