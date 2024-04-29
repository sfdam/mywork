({
	salvataggioReferenti : function(component, event, helper, selezionati) {
		var flag = component.get("v.consensi");
		var action = component.get("c.saveReferenti");
		action.setParams({
			relation : JSON.stringify(selezionati),
			flagConsensi : flag
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				var msg = $A.get("e.force:showToast");
				msg.setParams({
					"title" : "SUCCESS",
					"message" : "Salvataggio avvenuto con successo!",
					"type" : "SUCCESS"
				});
				msg.fire();
				//Riporto l'utente alla pagina dell'account
				//this.navigateToAccount(component, event, helper)
			}
			else{
				var msg = $A.get("e.force:showToast");
				msg.setParams({
					"title" : "ERRORE",
					"message" : "Errore durante il salvataggio",
					"type" : "ERROR"
				});
				msg.fire();
			}
		});
		$A.enqueueAction(action);
	},

	validaDati : function(component, event, helper, selezionati){
		var esitoCensimentoContactFull = this.checkCensimentoFullContact(component, event, helper);
		console.log('@@@ esito Check censimento ' , esitoCensimentoContactFull);

		var esitoReferentiSelezionati = this.checkReferentiSelezionati(component, event, helper, selezionati);

		var esitoTitEff_Esec = this.checkTitEffTitEsec(component, event, helper, selezionati);
		console.log('@@@ controllo ' , esitoTitEff_Esec);
		console.log('@@@ controllo totale ' , esitoReferentiSelezionati && esitoCensimentoContactFull && esitoTitEff_Esec);
		if(esitoReferentiSelezionati && esitoCensimentoContactFull && esitoTitEff_Esec){
			console.log('@@@ controllo sbagliato ' );
			var esitoCheckPicklist = this.checkPicklistPopulated(component, event, helper, selezionati);
			
			if(esitoCheckPicklist){
				var esitoCountEsecutori = this.checkCountEsecutori(component, event, helper, selezionati);

				if(esitoCountEsecutori){
					return true;
				}
				else{
					return false;
				}
			}
			else{
				return false;
			}
		}
		else{
			console.log('@@@ false');
			return false;
		}
	},

	checkReferentiSelezionati : function(component, event, helper, selezionati){		
		var countSelezionati = 0;
		selezionati.forEach((item,index) =>{
			if(item.isRelation){
				countSelezionati ++;
			}
		});
		
		if(countSelezionati == 0){
			component.find("notifLib").showNotice({
				"variant": "error",
				"header": "ERRORE!",
				"message": "Selezionare almeno un referente",
				closeCallback: function() {
					//alert('You closed the alert!');
				}
			});
			return false;
		}
		else{
			return true;
		}
	},

	checkPicklistPopulated : function(component, event, helper, selezionati){
		var esitoFinale;
		var listaEsiti = [];

		for(var key in selezionati){
			//console.log('@@@ ruolo w tipologia ' , selezionati[key]);
			if(selezionati[key].Ruolo_Pratica != undefined && selezionati[key].Ruolo_Pratica != null){
				// if((selezionati[key].Ruolo_Pratica.value.toLowerCase() == ('J').toLowerCase() || selezionati[key].Ruolo_Pratica.value.toLowerCase() == ('J;Z1').toLowerCase() || selezionati[key].Ruolo_Pratica.value.toLowerCase() == ('J1;Z1').toLowerCase() 
				// || selezionati[key].Ruolo_Pratica.value.toLowerCase() == ('J1').toLowerCase() || selezionati[key].Ruolo_Pratica.value.toLowerCase() == ('J;J1').toLowerCase()) 
				// 	&& (selezionati[key].WGC_Tipologia_Titolare_Effettivo == '' ||  selezionati[key].WGC_Tipologia_Titolare_Effettivo == null || selezionati[key].WGC_Tipologia_Titolare_Effettivo == undefined)
				// 	&& selezionati[key].isRelation) {
				if(((selezionati[key].Ruolo_Pratica.value.includes('J') || selezionati[key].Ruolo_Pratica.value.includes('J1')) ||
					selezionati[key].Ruolo_Pratica.value.includes(selezionati[key].titolareEffettivo + ';' + selezionati[key].titolareEsecutore)) &&
					selezionati[key].isRelation && 
					(selezionati[key].WGC_Tipologia_Titolare_Effettivo == '') || selezionati[key].WGC_Tipologia_Titolare_Effettivo == null || selezionati[key].WGC_Tipologia_Titolare_Effettivo == undefined){
						console.log('@@@ ruolo w tipologia ' , selezionati[key]);
						component.find("notifLib").showNotice({
							"variant": "error",
							"header": "ERRORE!",
							"message": "Popolare il campo Tipologia titolare effettivo",
							closeCallback: function() {
								//alert('You closed the alert!');
							}
						});
						esitoFinale = false;
						//return false;
				}
				else if((selezionati[key].Ruolo_Pratica.value == null || selezionati[key].Ruolo_Pratica.value == undefined || selezionati[key].Ruolo_Pratica.value == '') && selezionati[key].isRelation){
					component.find("notifLib").showNotice({
						"variant": "error",
						"header": "ERRORE!",
						"message": "Popolare il campo Ruolo",
						closeCallback: function() {
							//alert('You closed the alert!');
						}
					});
					esitoFinale = false;
					//return false;
				}
				else{
					esitoFinale = true;
					//return true;
				}
			}

			listaEsiti.push(esitoFinale);
		}

		if(listaEsiti.includes(false)){
			return false;
		}
		else{
			return true;
		}
	},

	checkCountEsecutori : function(component, event, helper, selezionati){

		var countEsecutori = 0;
		selezionati.forEach((item, index) =>{
			
			if(item.Ruolo_Pratica != undefined && item.Ruolo_Pratica != null){
				// if((item.Ruolo_Pratica.value.toLowerCase() == ('J;Z1').toLowerCase() || 
				// 	item.Ruolo_Pratica.value.toLowerCase() == ('Z1').toLowerCase() ||
				// 	item.Ruolo_Pratica.value.toLowerCase() == ('J1;Z1').toLowerCase() ) 
				// 		&& item.isRelation){
				// 	countEsecutori ++;
				// 	console.log('@@@ countEsecutori ' , countEsecutori);
				// 	console.log('@@@ item ' , item);
				// }

				if(item.Ruolo_Pratica.value.includes(item.titolareEsecutore) && item.isRelation){
					countEsecutori++;
				}
			}
		});

		if(countEsecutori > 1){
			component.find("notifLib").showNotice({
				"variant": "error",
				"header": "ERRORE!",
				"message": "Non è possibile selezionare più titolari esecutori",
				closeCallback: function() {
					//alert('You closed the alert!');
				}
			});
			return false;
		}
		else{
			return true;
		}
	},

	checkCensimentoFull : function(component, event, helper, censimento, isInit){
		/*
		console.log('@@@ censimento ' , censimento);

		if(censimento == 'Completo'){
			return true;
		}
		else if(censimento != 'Completo' && isInit){
			return false;
		}
		else{
			component.find("notifLib").showNotice({
				"variant": "error",
				"header": "ERRORE!",
				"message": "Il referente selezionato non presenta un'anagrafica completa. Ti invitiamo ad eseguire il completamento dei dati nella scheda del referente interessato",
				closeCallback: function() {
					//alert('You closed the alert!');
				}
			});
			return false;
		}
		*/
		if(!censimento){
			component.find("notifLib").showNotice({
				"variant": "error",
				"header": "ERRORE!",
				"message": "Il referente selezionato non presenta un'anagrafica completa. Ti invitiamo ad eseguire il completamento dei dati nella scheda del referente interessato",
				closeCallback: function() {
					//alert('You closed the alert!');
				}
			});
		}
	},

	checkUniqueRole : function(component, event, helper){
		var referenti = component.get("v.contactList");

		// if(referenti != null && referenti != undefined && referenti.length > 0){
		// 	referenti.forEach((item, index) =>{
		// 		if((item.Ruolo_Pratica == null || item.Ruolo_Pratica == undefined) && 
		// 			(item.WGC_Ruolo.value != 'J;Z1' || item.WGC_Ruolo.value != 'J1;Z1' )){
		// 				item.Ruolo_Pratica = {};
		// 				item.Ruolo_Pratica.value = item.WGC_Ruolo.value;
		// 				//item.Ruolo_Pratica.value = item.WGC_Ruolo.value;
		// 		}
		// 		else{
		// 			console.log('@@@ prova ' , JSON.stringify(item.Ruolo_Pratica) + ' - ' + JSON.stringify(item.Name));
		// 		}
		// 	});
		// }

		if(referenti != null && referenti != undefined && referenti.length > 0){
			referenti.forEach((item, index) =>{
				if((item.Ruolo_Pratica == null || item.Ruolo_Pratica == undefined) && 
					(!item.titolareEffettivo && item.titolareEsecutore )){
						item.Ruolo_Pratica = {};
						item.Ruolo_Pratica.value = item.WGC_Ruolo.value;
						//item.Ruolo_Pratica.value = item.WGC_Ruolo.value;
				}
				else{
					console.log('@@@ prova ' , JSON.stringify(item.Ruolo_Pratica) + ' - ' + JSON.stringify(item.Name));
				}
			});
		}


		console.log('@@@ referenti init ' , referenti);
	},

	checkCensimentoFullContact : function(component, event, helper){
		var referenti = component.get("v.contactList");
		console.log('@@@ referenti ' , referenti);

		var check = true;

		for(var key in referenti){
			if(referenti[key].contactFull == false && referenti[key].isRelation){
				check = false;
				break;
			}
		}

		if(!check){
			component.find("notifLib").showNotice({
				"variant": "error",
				"header": "ERRORE!",
				"message": "Referenti selezionati non censiti full",
				closeCallback: function() {
					//alert('You closed the alert!');
				}
			});
		}

		return check;
	},

	checkTitEffTitEsec : function(component, event, helper, referenti){
		var flagConsensi = component.get("v.consensi");
		console.log('@@@ flagConsensi ' , flagConsensi);

		var countEsec = 0;
		var countTitEff = 0;

		referenti.forEach((item, index) =>{
			console.log('@@@ controllo esec ' , item.isRelation && item.Ruolo_Pratica.value.includes(item.titolareEsecutore));
			console.log('@@@ controllo tit eff ' , item.isRelation && item.Ruolo_Pratica.value.includes(item.titolareEffettivo));
			console.log('@@@ controllo titeff esec ' , item.isRelation && item.Ruolo_Pratica.value == item.titolareEffettivo + ';' + item.titolareEsecutore );
            if(item.isRelation && item.Ruolo_Pratica.value == item.titolareEffettivo + ';' + item.titolareEsecutore){
					countTitEff++;
					countEsec++;
        	}
			else if(item.isRelation && item.Ruolo_Pratica.value.includes(item.titolareEsecutore) ){
				countEsec++;
			}
			else if(item.isRelation && item.Ruolo_Pratica.value.includes(item.titolareEffettivo)){
				countTitEff++;
			}
		});

		console.log('@@@ countTitEff ' , countTitEff);
		console.log('@@@ countEsec ' , countEsec);

		if((countEsec == 0 || countTitEff == 0 && !flagConsensi) || (countEsec == 0 && flagConsensi)){
			component.find("notifLib").showNotice({
				"variant": "error",
				"header": "ERRORE!",
				"message": "Non è possibile completare il Modulo di Adeguata Verifica senza aver indicato almeno un Titolare Effettivo ed un Esecutore",
				closeCallback: function() {
					//alert('You closed the alert!');
				}
			});
			return false;
		}
		else{
			return true;
		}
	},

	getRef : function(component, event, helper){
		var accId = component.get("v.accountId");
		var action = component.get("c.getReferenti");
		action.setParams({
			"accountId" : accId
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				//Verifico che il censimento dei contatti sia full
				/*
				risposta.forEach((item,index) =>{
					var checkCensimento = helper.checkCensimentoFull(component, event, helper, item.tipoCensimento, true);
					if(!checkCensimento){
						item.isRelation = false;
					}
				});
				*/
				console.log('@@@ referenti ' , risposta);
				if(risposta == null){
					console.log('@@@ msg ' );
                    var obj = {anagNotCompleted : true};
					component.find("notifLib").showNotice({
						"variant": "warning",
						"header": "ATTENZIONE!",
						"message": "Nessun Referente disponibile per la compilazione MAV",
						closeCallback: function() {
							//alert('You closed the alert!');
							var appEvent = $A.get("e.c:WGC_ModuloAdeguataVerifica_ResolveEvent");
							appEvent.setParams({
								"success" : false,
                                "json" : obj
							});
							appEvent.fire();
						}
					});

					return;
				}

				component.set("v.contactList", risposta);

				helper.checkUniqueRole(component, event, helper);
			}
			else{
				//console.log('errore durante il caricamento dei contatti');
			}
		});

		$A.enqueueAction(action);
	},

	navigateToAccount : function(component, event, helper){
		var navigator = component.find('navService');
		var url = {    
			"type": "standard__recordPage",
			"attributes": {
				"recordId": component.get('v.accountId'),
				"objectApiName": "Account",
				"actionName": "view"
			}
		};
		navigator.navigate(url); 
	},
	//FACTORY SV -- START
	getPicklistValues : function(component,event,helper){
		/*var action = component.get("c.getPicklistValues");
		var arrContact = component.get("v.contactList");
		var tipoRelazione=[];
		action.setCallback(this, function(response) {
			tipoRelazione.push({
                label: "",
                value: ""
            });
			var scopo = response.getReturnValue();
            for(var a in scopo){
                tipoRelazione.push({label: scopo[a], value: a, selected: (a == arrContact[].Scopo_Factoring__c) ? true : false});
            }
			component.set("v.tipoRel", tipoRelazione);
        });
        $A.enqueueAction(action);*/
	}
})