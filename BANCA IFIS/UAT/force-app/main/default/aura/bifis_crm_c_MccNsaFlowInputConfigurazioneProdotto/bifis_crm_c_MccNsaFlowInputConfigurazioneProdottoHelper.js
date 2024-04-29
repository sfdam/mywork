({

    calculateExpenses : function(component,event){

        var importoMutuo = component.find("flowInputImportoMutuoInputId").get("v.value");

		var lineaProdotto = component.find("flowInputLineaInputId").get("v.value");
        
        if(importoMutuo === undefined || importoMutuo === ""){
            
            component.find("flowInputSpeseIstruttoriaInputId").set("v.value","");
            
            return;
            
        }

		if(lineaProdotto === 'ASSICURATIVO'){
		
			component.find("flowInputSpeseIstruttoriaInputId").set("v.value",0);
            
			return;

		}

		else {

			if(importoMutuo > 0 && importoMutuo <= 50000){
            
				component.find("flowInputSpeseIstruttoriaInputId").set("v.value",1000);
            
				return;
            
			}
        
			if(importoMutuo > 50000 && importoMutuo <= 100000){
            
				component.find("flowInputSpeseIstruttoriaInputId").set("v.value",1200);
            
				return;
            
			}      
        
			if(importoMutuo > 100000 && importoMutuo <= 250000){
            
				component.find("flowInputSpeseIstruttoriaInputId").set("v.value",1550);
            
				return;
            
			}          
        
			if(importoMutuo > 250000){
            
				component.find("flowInputSpeseIstruttoriaInputId").set("v.value",1800);
            
				return;
            
			}       
			
		}      

    }, 

	calculateAmmortamentoStandard : function(component,event){
			
		var durataTotale = component.find("flowInputDurataTotaleMutuoInputId").get("v.value");
	
		var preAmmortamento = component.find("flowInputDurataPreAmmortamentoMutuoInputId").get("v.value");

		var ammortamento;
	
		if((durataTotale == null || durataTotale === '') && (preAmmortamento == null || preAmmortamento === '')){
	
			ammortamento = "";

		}
		else {
	
			ammortamento = durataTotale - preAmmortamento;

		}
	
		component.find("flowInputDurataAmmortamentoMutuoInputId").set("v.value",ammortamento);
	
	}, 

	calculateAmmortamentoAssicurativo : function(component,event){
			
		var durataTotale = component.find("flowInputDurataTotaleMutuoSAInputId").get("v.value");
	
		var preAmmortamento = component.find("flowInputDurataPreAmmortamentoMutuoSAInputId").get("v.value");

		var ammortamento;
	
		if((durataTotale == null || durataTotale === '') && (preAmmortamento == null || preAmmortamento === '')){
	
			ammortamento = "";

		}
		else {
	
			ammortamento = durataTotale - preAmmortamento;

		}
	
		component.find("flowInputDurataAmmortamentoMutuoSAInputId").set("v.value",ammortamento);
	
	}, 

	calculateValuesVisibility : function(component,event){

		var lineaProdotto = component.get('v.workflowRecordCandidato.Tipologia_Mutuo__c');

		// IMPOSTAZIONI VALORI COMUNI

		component.find("flowInputTassoRiferimentoInputId").set("v.value",component.get('v.tassoRiferimentoStandard'));
		component.find("flowInputPeriodoRateInputId").set("v.value", component.get('v.periodicitaRate'));
		component.find("flowInputSpeseIncassoRataInputId").set("v.value", component.get('v.speseIncassoRataStandard'));

		component.set('v.workflowRecordCandidato.SpreadPositivoSA__c', component.get('v.spreadPositivoAssicurativo'));
		component.set('v.workflowRecordCandidato.FloorSA__c', component.get('v.spreadPositivoAssicurativo'));
		component.find("flowInputTassoRiferimentoSAInputId").set("v.value",component.get('v.tassoRiferimentoAssicurativo'));
		component.set('v.workflowRecordCandidato.SpeseIstruttoriaSA__c', component.get('v.speseIstruttoriaAssicurativo'));
		component.find("flowInputPeriodoRateSAInputId").set("v.value", component.get('v.periodicitaRate'));
		component.find("flowInputSpeseIncassoRataSAInputId").set("v.value", component.get('v.speseIncassoRataAssicurativo'));
		component.set('v.workflowRecordCandidato.CostoMediazioneSA__c', component.get('v.costoMediazioneAssicurativo'));

		if(lineaProdotto === 'STANDARD'){
		
			// DATI PRINCIPALI

			// CONDIZIONI ECONOMICHE

		 
		} 
		
		if(lineaProdotto === 'ASSICURATIVO'){
		
			// DATI PRINCIPALI

			// CONDIZIONI ECONOMICHE

		}

		if(lineaProdotto === 'MISTO'){
		 
			// DATI PRINCIPALI

			// CONDIZIONI ECONOMICHE

		 
		}
					
	},

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