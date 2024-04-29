({
    generateData: function (result, component, event) {
        var today = new Date();

        var visite_E = 0;
        var visite_P = 0;
        var pratiche_V = 0;
        var pratiche_A = 0;
        var clienti = 0;
        var clientiTot = 0;
        var countAnnoAttuale = 0;
        var countAnnoPrecedente = 0;


        result.dettaglioVisiteList.forEach(function (element) {
			var elementDate = new Date(element.Data_Visita_Commerciale__c);
            var elementYear = elementDate.getFullYear();
            
            var elementDateRapporto = new Date(element.Data_Contatto_Telefonico__c);
            var elementYearRapporto = elementDate.getFullYear();
            
            var elementDateAvvioRapporto = new Date(element.Data_avvio_rapporto__c);
            var elementYearAvvioRapporto = elementDateAvvioRapporto.getFullYear();
   
            /*if (elementYearRapporto == today.getFullYear()) {
                countAnnoAttuale++;
            } else {
                countAnnoPrecedente++;
            }*/

            if (elementYearAvvioRapporto == today.getFullYear() && element.Rapporto_Avviato__c == 'Si' &&
                element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Esito_Visita__c == 'Individuata opportunità' && element.Primo_Prodotto__c != null && 
                 element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c != 'Leasing' && 
                element.Data_Esito_Pratica__c != null && element.Data_avvio_rapporto__c != null && element.Previsione_Avvio_Rapporto__c != null) {
                    
                clientiTot++;
                if(elementYear == today.getFullYear()){
                    countAnnoAttuale++;
                } else if( elementYear == today.getFullYear() - 1 ){
                    countAnnoPrecedente++;
                }
            }

			if (elementYear == today.getFullYear()) {
                if((element.Macro_Esito__c == 'Positivo' || element.Macro_Esito__c == 'Negativo') && element.Primo_Prodotto__c != 'Reverse' && element.Primo_Prodotto__c!= 'Leasing'){
                    visite_E++;
                    if(element.Macro_Esito__c == 'Positivo' && element.Esito_Visita__c == 'Individuata opportunità'){
                        visite_P++;
                        if( (element.Pratica_Presentata__c == 'Si' || element.Pratica_Presentata__c == 'WIP') && element.Esito_Visita__c == 'Individuata opportunità' ) pratiche_V++;

                        if(element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' && element.Esito_Visita__c == 'Individuata opportunità' && element.Data_Esito_Pratica__c != null){
                            //pratiche++;
                            pratiche_A++;
                            if(elementYearAvvioRapporto == today.getFullYear() && element.Rapporto_Avviato__c == 'Si' && element.Data_avvio_rapporto__c != null && element.Previsione_Avvio_Rapporto__c != null && element.Primo_Prodotto__c != null){
                                clienti++;
                            }
                        }
                    }
                }

				/*if(element.Esito_Visita__c == 'Utente in corso di sviluppo') visite_E++;
				if(element.Macro_Esito__c == 'Negativo') visite_E++;*/

				// if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'No') opportunita++;
				// if(element.Macro_Esito__c == 'Positivo' &&  (!element.hasOwnProperty('Esito_Pratica__c') || element.Esito_Pratica__c == '')) opportunita++;

				// if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'WIP' &&  (!element.hasOwnProperty('Esito_Pratica__c') || element.Esito_Pratica__c == '')) pratiche++;
				// if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' &&  (!element.hasOwnProperty('Esito_Pratica__c') || element.Esito_Pratica__c == '')) pratiche++;
				// if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Declinata') pratiche++;                
				// if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' &&   (!element.hasOwnProperty('Rapporto_Avviato__c') || element.Rapporto_Avviato__c == '')) clienti++;
				// if(element.Macro_Esito__c == 'Positivo' && element.Pratica_Presentata__c == 'Si' && element.Esito_Pratica__c == 'Approvata' &&  element.Rapporto_Avviato__c == 'No') clienti++;
            }   

        });

        component.set('v.visite_E', visite_E);
        component.set('v.visite_P', visite_P);
        component.set('v.pratiche_V', pratiche_V);
        component.set('v.pratiche_A', pratiche_A);
        component.set('v.clienti', clienti);

        component.set('v.clientiTot', clientiTot);

        component.set('v.annoAttuale', countAnnoAttuale);
        component.set('v.annoPrecedente', countAnnoPrecedente);
        
    },
     
    apex: function (component, event, apexAction, params) {
		var p = new Promise($A.getCallback(function (resolve, reject) {
			var action = component.get("c." + apexAction + "");
			action.setParams(params);
			action.setCallback(this, function (callbackResult) {
				if (callbackResult.getState() == 'SUCCESS') {
					resolve(callbackResult.getReturnValue());
				}
				if (callbackResult.getState() == 'ERROR') {
					console.log('ERROR', callbackResult.getError());
					reject(callbackResult.getError());
				}
			});
			$A.enqueueAction(action);
		}));
		return p;
	},

    neighbor: function (value) {
        var y= 0;
        if(value >= 15 && value < 30){
            y = 15;
        } else if(value >= 30 && value < 45){
            y = 30;
        } else if(value >= 45 && value < 60){
            y = 45;
        } else if(value >= 60 && value < 75){
            y = 60;
        } else if(value >= 75){
            y = 75;
        }
        return y;
    }
})