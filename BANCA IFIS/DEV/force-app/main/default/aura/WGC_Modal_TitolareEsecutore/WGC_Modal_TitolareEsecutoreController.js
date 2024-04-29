({
	doInit : function(component, event, helper) {
		//Funzione per recuperare tutti i contatti legati all'account per mostrarli nella tabella
		var accId = component.get("v.accountId");

		var action2 = component.get("c.getConsensi");
		action2.setParams({
			"accountId" : accId
		});
		action2.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				console.log('@@@ risposta consensi ' , risposta);
				component.set("v.consensi", risposta.PartecipazioneSocietaFiduciarie2__c);
				component.set("v.mavCompleto" , risposta.WGC_MAV_Completo__c);
				helper.getPicklistValues(component, event,helper);
				//ora i dati relativi al MAV Account sono presenti ed inseribili
				/*if(!risposta.WGC_MAV_Completo__c){
					var obj = {anagNotCompleted : true};
					component.find("notifLib").showNotice({
						"variant": "warning",
						"header": "ATTENZIONE!",
						"message": "Per continuare è necessario compilare i campi obbligatori presenti nella sezione “Informazioni Modulo Adeguata Verifica” presenti nella schermata di modifica del “Profilo - Anagrafica” dell’Azienda",
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
				else{*/
					helper.getRef(component, event, helper);
				//}
			}
			else{
				console.log('@@@ response.getError() ' , response.getError());
			}
		});
		$A.enqueueAction(action2);
	},
	//Prendo il valore del toggle seleziona e cambio il valore disabled delle picklist
	flagSeleziona : function(component, event, helper){
		var newValue = event.getSource().get("v.value");
		var name = event.getSource().get("v.name");
		var arrContact = component.get("v.contactList");

		//Funzione helper per verificare che il referente selezionato sia censito full
		if(newValue){
			helper.checkCensimentoFull(component, event, helper, arrContact[name].contactFull, false);
		}

		arrContact[name].isRelation = newValue;
		component.set("v.contactList", arrContact);
	},

	changeRole : function(component, event, helper){
		var newValue = event.getSource().get("v.value");
		console.log('@@@ newValue role ' , newValue);
		var name = event.getSource().get("v.name");
		var arrContact = component.get("v.contactList");
		//arrContact[name].WGC_Ruolo.value = newValue;
		arrContact[name].Ruolo_Pratica.value = newValue;
		console.log('@@@ wgc ruolo after ' , arrContact[name].WGC_Ruolo.value );
		console.log('@@@ ruolo pratica after ' , arrContact[name].Ruolo_Pratica.value );
		component.set("v.contactList", arrContact);

		console.log('@@@ aaa ' , JSON.stringify(arrContact[name]));
	},

	changeTitolare : function(component, event, helper){
		var newValue = event.getSource().get("v.value");
		var name = event.getSource().get("v.name");
		var arrContact = component.get("v.contactList");
		arrContact[name].WGC_Tipologia_Titolare_Effettivo = newValue;
		component.set("v.contactList", arrContact);
	},

	changeComportamento : function(component, event, helper){
		var newValue = event.getSource().get("v.value");
		var name = event.getSource().get("v.name");
		var arrContact = component.get("v.contactList");
		arrContact[name].comportamentoCliente = newValue;
		component.set("v.contactList", arrContact);
	},
	//FACTORY SV -- START
	onChangePickValue : function(component,event,helper){
		var newValue = event.getSource().get("v.value");
		var name = event.getSource().get("v.name");
		var arrContact = component.get("v.contactList");
		arrContact[name].relazioneClienteEsecutore = newValue;
		component.set("v.contactList",arrContact);
	},

	//FACTORY SV -- END

	changeConsensi : function(component, event, helper){
		// console.log('@@@ consensi prima ' + component.get("v.consensi"));
		// var newValue = event.getSource().get("v.value");
		// console.log('@@@ consensi dopo ' , newValue);
		// component.set("v.consensi", newValue);
	},

	execute : function(component, event, helper){
		//Prendo il flag che mi indica il salvataggio del form
		var toBeSaved = component.get("v.toBeSaved");
		if(toBeSaved){
			var listaReferenti = component.get("v.contactList");
			console.log('@@@ listaReferenti da salvare ' , listaReferenti);
			if(listaReferenti != null && listaReferenti != undefined && listaReferenti.length > 0){
				//Valido i dati inseriti prima di salvare a database
				var esitoValidazione = helper.validaDati(component, event, helper, listaReferenti);
				//Se validazione dati è corretta allora salvo a database
				console.log('@@@ esitoValidazione ' , esitoValidazione);
				if(esitoValidazione){
					//helper.salvataggioReferenti(component, event, helper, listaReferenti);
					var obj = {relation: component.get("v.contactList"), flagConsensi : component.get("v.consensi")};
					var appEvent = $A.get("e.c:WGC_ModuloAdeguataVerifica_ResolveEvent");
					appEvent.setParams({
						"success" : true,
						"json" : obj
					});
					appEvent.fire();

					
				}
				else{
					//Validazione non corretta, non posso salvare
					//Lancio l'evento per non permettere il salvataggio del documento
					var obj = {relation: null, flagConsensi : null};
					var appEvent = $A.get("e.c:WGC_ModuloAdeguataVerifica_ResolveEvent");
					appEvent.setParams({
						"success" : false,
                        "json" : obj
					});
					console.log('@@@ appEvent ' , appEvent);
					appEvent.fire();

					
					return;
				}
			}
			else{
				component.find("notifLib").showNotice({
					"variant": "error",
					"header": "ERRORE!",
					"message": "Popolare la lista referenti prima di salvare il modulo adeguata verifica",
					closeCallback: function() {
						//alert('You closed the alert!');
					}
				});

				
			}
		}
	},

	cancel : function(component, event, helper){
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
})