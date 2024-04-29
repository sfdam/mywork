({
	countProdGroupByStato : function(component, risposta){
		//Linea Prodotto divise per RT grouped by Stato__c

		var factCedAttiva = 0;
		var factCedBloccata = 0;
		var factCedEstinta = 0;

		var factDebAttiva = 0;
		var factDebBloccata = 0;
		var factDebEstinta = 0;


		var finanziamentiAttiva = 0;
		var finanziamentiBloccata = 0;
		var finanziamentiEstinta = 0;

		var leasingAttiva = 0;
		var leasingBloccata = 0;
		var leasingEstinta = 0;

		var altroAttiva = 0;
		var altroBloccata = 0;
		var altroEstinta = 0;

		var esteroAttiva = 0;
		var esteroBloccata = 0;
		var esteroEstinta = 0;


		if(risposta.factoringCedente != null && risposta.factoringCedente.length > 0){
			risposta.factoringCedente.forEach((item, index) =>{
				if(item.prodotto.Stato__c){
					if(item.prodotto.Stato__c.toLowerCase() == ('Attiva').toLowerCase() || 
						item.prodotto.Stato__c.toLowerCase() == ('Attivo').toLowerCase() ||
						item.prodotto.Stato__c.toLowerCase() == ('ACTIVE').toLowerCase()){
						factCedAttiva++;
					}
					else if(item.prodotto.Stato__c.toLowerCase() == ('Bloccata').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Bloccato').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('BLOCKED').toLowerCase()){
						factCedBloccata++;
					}
					else if(item.prodotto.Stato__c.toLowerCase() == ('Estinta').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Estinto').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('CLOSED').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('Revocata').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Revocato').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('REVOKED').toLowerCase()){
						factCedEstinta++;
					}
				}
			});

			component.set('v.wizardItems[0].dots.countAttiva', factCedAttiva);
			component.set('v.wizardItems[0].dots.countBloccata', factCedBloccata);
			component.set('v.wizardItems[0].dots.countEstinta', factCedEstinta);

		} else {
			var isActive = component.get('v.wizardItems[0].active');
			component.set('v.wizardItems[0].disabled', true);
			if(isActive){
				component.set('v.wizardItems[0].active', false);
			}
		}

		if(risposta.factoringDebitore != null && risposta.factoringDebitore.length > 0){
			risposta.factoringDebitore.forEach((item, index) =>{

				if(item.prodotto.Stato__c){
					if(item.prodotto.Stato__c.toLowerCase() == ('Attiva').toLowerCase() || 
					item.prodotto.Stato__c.toLowerCase() == ('Attivo').toLowerCase() ||
					item.prodotto.Stato__c.toLowerCase() == ('ACTIVE').toLowerCase()){
					factDebAttiva++;
				}
				else if(item.prodotto.Stato__c.toLowerCase() == ('Bloccata').toLowerCase() || 
						item.prodotto.Stato__c.toLowerCase() == ('Bloccato').toLowerCase() ||
						item.prodotto.Stato__c.toLowerCase() == ('BLOCKED').toLowerCase()){
					factDebBloccata++;
				}
				else if(item.prodotto.Stato__c.toLowerCase() == ('Estinta').toLowerCase() || 
						item.prodotto.Stato__c.toLowerCase() == ('Estinto').toLowerCase() ||
						item.prodotto.Stato__c.toLowerCase() == ('CLOSED').toLowerCase() ||
						item.prodotto.Stato__c.toLowerCase() == ('Revocata').toLowerCase() || 
						item.prodotto.Stato__c.toLowerCase() == ('Revocato').toLowerCase() ||
						item.prodotto.Stato__c.toLowerCase() == ('REVOKED').toLowerCase()){
					factDebEstinta++;
				}
				}
				
			});
			
			console.log('@@@ factDebEstinta ' , factDebEstinta);
			
			component.set('v.wizardItems[1].dots.countAttiva', factDebAttiva);
			component.set('v.wizardItems[1].dots.countBloccata', factDebBloccata);
			component.set('v.wizardItems[1].dots.countEstinta', factDebEstinta);

		} else {
			component.set('v.wizardItems[1].disabled', true);
		}

		if(risposta.finanziamenti != null && risposta.finanziamenti.length > 0){
			risposta.finanziamenti.forEach((item, index) =>{

				if(item.prodotto.Stato__c){
					if(item.prodotto.Stato__c.toLowerCase() == ('Attiva').toLowerCase() || 
						item.prodotto.Stato__c.toLowerCase() == ('Attivo').toLowerCase() ||
						item.prodotto.Stato__c.toLowerCase() == ('ACTIVE').toLowerCase()){
						finanziamentiAttiva++;
					}
					else if(item.prodotto.Stato__c.toLowerCase() == ('Bloccata').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Bloccato').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('BLOCKED').toLowerCase()){
						finanziamentiBloccata++;
					}
					else if(item.prodotto.Stato__c.toLowerCase() == ('Estinta').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Estinto').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('CLOSED').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('Revocata').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Revocato').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('REVOKED').toLowerCase()){
						finanziamentiEstinta++;
					}
				}
			});
			
			component.set('v.wizardItems[2].dots.countAttiva', finanziamentiAttiva);
			component.set('v.wizardItems[2].dots.countBloccata', finanziamentiBloccata);
			component.set('v.wizardItems[2].dots.countEstinta', finanziamentiEstinta);

		} else {
			component.set('v.wizardItems[2].disabled', true);
		}

		if(risposta.leasing != null && risposta.leasing.length > 0){
			risposta.leasing.forEach((item, index) =>{

				if(item.prodotto.Stato__c){
					if(item.prodotto.Stato__c.toLowerCase() == ('Attiva').toLowerCase() || 
						item.prodotto.Stato__c.toLowerCase() == ('Attivo').toLowerCase() ||
						item.prodotto.Stato__c.toLowerCase() == ('ACTIVE').toLowerCase()){
						leasingAttiva++;
					}
					else if(item.prodotto.Stato__c.toLowerCase() == ('Bloccata').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Bloccato').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('BLOCKED').toLowerCase()){
						leasingBloccata++;
					}
					else if(item.prodotto.Stato__c.toLowerCase() == ('Estinta').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Estinto').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('CLOSED').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('Revocata').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Revocato').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('REVOKED').toLowerCase()){
						leasingEstinta++;
					}
				}
				
			});
			
			component.set('v.wizardItems[3].dots.countAttiva', leasingAttiva);
			component.set('v.wizardItems[3].dots.countBloccata', leasingBloccata);
			component.set('v.wizardItems[3].dots.countEstinta', leasingEstinta);

			if(leasingAttiva <= 0 && leasingBloccata <= 0 && leasingEstinta <= 0){
				component.set('v.wizardItems[3].disabled', true);
			}
		} else {
			component.set('v.wizardItems[3].disabled', true);
		}

		if(risposta.altro != null && risposta.altro.length > 0){
			risposta.altro.forEach((item, index) =>{

				if(item.prodotto.Stato__c){
					if(item.prodotto.Stato__c.toLowerCase() == ('Attiva').toLowerCase() || 
						item.prodotto.Stato__c.toLowerCase() == ('Attivo').toLowerCase() ||
						item.prodotto.Stato__c.toLowerCase() == ('ACTIVE').toLowerCase()){
						altroAttiva++;
					}
					else if(item.prodotto.Stato__c.toLowerCase() == ('Bloccata').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Bloccato').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('BLOCKED').toLowerCase()){
						altroBloccata++;
					}
					else if(item.prodotto.Stato__c.toLowerCase() == ('Estinta').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Estinto').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('CLOSED').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('Revocata').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Revocato').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('REVOKED').toLowerCase()){
						altroEstinta++;
					}
				}

				
			});
			
			component.set('v.wizardItems[4].dots.countAttiva', altroAttiva);
			component.set('v.wizardItems[4].dots.countBloccata', altroBloccata);
			component.set('v.wizardItems[4].dots.countEstinta', altroEstinta);

		} else {
			component.set('v.wizardItems[4].disabled', true);
		}

		if(risposta.corporateEstero != null && risposta.corporateEstero.length > 0){
			risposta.corporateEstero.forEach((item, index) =>{

				if(item.prodotto.Stato__c){
					if(item.prodotto.Stato__c.toLowerCase() == ('Attiva').toLowerCase() || 
						item.prodotto.Stato__c.toLowerCase() == ('Attivo').toLowerCase() ||
						item.prodotto.Stato__c.toLowerCase() == ('ACTIVE').toLowerCase()){
						esteroAttiva++;
					}
					else if(item.prodotto.Stato__c.toLowerCase() == ('Bloccata').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Bloccato').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('BLOCKED').toLowerCase()){
						esteroBloccata++;
					}
					else if(item.prodotto.Stato__c.toLowerCase() == ('Estinta').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Estinto').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('CLOSED').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('Revocata').toLowerCase() || 
							item.prodotto.Stato__c.toLowerCase() == ('Revocato').toLowerCase() ||
							item.prodotto.Stato__c.toLowerCase() == ('REVOKED').toLowerCase()){
						esteroEstinta++;
					}
				}

				
			});
			
			component.set('v.wizardItems[5].dots.countAttiva', esteroAttiva);
			component.set('v.wizardItems[5].dots.countBloccata', esteroBloccata);
			component.set('v.wizardItems[5].dots.countEstinta', esteroEstinta);

		} else {
			component.set('v.wizardItems[5].disabled', true);
		}

		if(component.get('v.wizardItems[0].disabled') && component.get('v.wizardItems[1].disabled') && component.get('v.wizardItems[2].disabled') && 
		component.get('v.wizardItems[3].disabled') && component.get('v.wizardItems[4].disabled') && component.get('v.wizardItems[5].disabled')){
			component.set('v.stepPage', 'none');
		}
	},

	sectorByRT : function(component, listaAltro){
		var listaServiziBancari = [];
		var listaGaranzie = [];
		var listaCreditiProblematici = [];
		var listaCreditiDiFirma = [];
		var listaNPL = [];
		var listaCreditiErariali = [];
		
		listaAltro.forEach((item, index) =>{
			if(item.prodotto.RecordType.DeveloperName == "SERVIZIBANCARI"){
				listaServiziBancari.push(item);
			}
			else if(item.prodotto.RecordType.DeveloperName == "GARANZIE"){
				listaGaranzie.push(item);
			}
			else if(item.prodotto.RecordType.DeveloperName == "CREDITIPROBLEMATICI"){
				listaCreditiProblematici.push(item);
			}
			else if(item.prodotto.RecordType.DeveloperName == "CREDITIDIFIRMA"){
				listaCreditiDiFirma.push(item);
			}
			else if(item.prodotto.RecordType.DeveloperName == "NPL"){
				listaNPL.push(item);
			}else if(item.prodotto.RecordType.DeveloperName == "CREDITIERARIALI"){
				listaCreditiErariali.push(item);
			}else if(item.prodotto.RecordType.DeveloperName == "Portafoglio_Commerciale"){
				listaServiziBancari.push(item);
			}else if(item.prodotto.RecordType.DeveloperName == "Anticipo_Fatture"){
				listaServiziBancari.push(item);
			}
		});

		component.set("v.listaProdServiziBancari", listaServiziBancari);
		component.set("v.listaProdGaranzie", listaGaranzie);
		component.set("v.listaProdCreditiProblematici", listaCreditiProblematici);
		component.set("v.listaProdCreditiDiFirma", listaCreditiDiFirma);
		component.set("v.listaProdNPL", listaNPL);
		component.set("v.listaProdErariali",listaCreditiErariali);
	},

	configureWizard : function(component, event) {
        var wizardItems = [
            {
                title: "FACTORING CEDENTE",
				step: "factoringCedente",
                active: true,
                disabled: false,
                completed: false,
				icon: "",
				dots: {countAttiva : 0, countBloccata: 0, countEstinta: 0}
            },
            {
                title: "FACTORING DEBITORE",
				step: "factoringDebitore",
                active: false,
                disabled: false,
                completed: false,
				icon: "",
				dots: {countAttiva : 0, countBloccata: 0, countEstinta: 0}

            },
            {
                title: "FINANZIAMENTI",
				step: "finanziamenti",
                active: false,
                disabled: false,
                completed: true,
				icon: "",
				dots: {countAttiva : 0, countBloccata: 0, countEstinta: 0}

            },
            {
                title: "LEASING",
				step: "leasing",
                active: false,
                disabled: false,
                completed: true,
				icon: "",
				dots: {countAttiva : 0, countBloccata: 0, countEstinta: 0}

            },
            {
                title: "ALTRO",
				step: "altro",
                active: false,
                disabled: false,
                completed: true,
				icon: "",
				dots: {countAttiva : 0, countBloccata: 0, countEstinta: 0}

            },
            {
                title: "ESTERO",
				step: "estero",
                active: false,
                disabled: false,
                completed: true,
				icon: "",
				dots: {countAttiva : 0, countBloccata: 0, countEstinta: 0}

            }
        ];

        component.set("v.wizardItems", wizardItems);
	},

	selectWizardItem : function(component, step) {
        var wizardItems = component.get("v.wizardItems");
        var wizItem = null;
        var isvalid = true

        // this.showSpinner(component);

        for (var wi in wizardItems) {
            if (wizardItems[wi].step == step && wizardItems[wi].disabled == true) {
                isvalid = false;
                break;
            }
            else if (wizardItems[wi].step == step) {
                wizardItems[wi].active = true;
                wizItem = wizardItems[wi];
            }
            else if (wizardItems[wi].active == true) {
                wizardItems[wi].active = false;
                // wizItem = wizardItems[wi];
            }
		}

		if (isvalid == true) {
            component.set('v.stepPage', step);
			component.set('v.wizardItems', wizardItems);
        }

        switch (step) {
            case 'factoringCedente': // ACTIONS TO INITIALIZE A WIZITEM
                // this.setWizItemCompleted(wizItem, payload.linee.length > 0);
                break;
            case 'factoringDebitore':
                // var condition = false;
                // this.setWizItemCompleted(wizItem, condition);
                break;
            case 'finanziamenti':
                // var condition = false;
                // this.setWizItemCompleted(wizItem, condition);
                break;
            case 'leasing':
                // var condition = false;
                // this.setWizItemCompleted(wizItem, condition);

                
				break;
			case 'altro':
                // var condition = false;
                // this.setWizItemCompleted(wizItem, condition);
                break;
        }
    },

	apex: function (component, event, apexAction, params) {
        var p = new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get("c." + apexAction + "");
            action.setParams(params);
            action.setCallback(this, function (callbackResult) {
                // if (callbackResult.getState() == 'SUCCESS') {
                //     resolve(callbackResult.getReturnValue());
                // }
                // if (callbackResult.getState() == 'ERROR') {
                //     reject(callbackResult.getError());
				// }
				resolve(callbackResult.getReturnValue());
            });
            $A.enqueueAction(action);
        }));
        return p;
	},
	
	showSpinner: function (cmp, event) {
		console.log('CAVVVVVV');
		var spinner = cmp.find("mySpinner");
		console.log('spinner', spinner);
        $A.util.removeClass(spinner, "slds-hide");

    },

    hideSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");

    },
})