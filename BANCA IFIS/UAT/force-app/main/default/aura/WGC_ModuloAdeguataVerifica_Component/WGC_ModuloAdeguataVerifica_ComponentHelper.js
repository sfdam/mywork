({
	convalidaDati : function(component, event, helper) {
		var modulo = component.get('v.modulo');
		var tipologiaMAV = component.get("v.tipologiaMav");

		//SM - TEN CR 425
		let infoMAV = component.get("v.infoMav");
		let linesEstero = component.get("v.linesEstero");

		console.log('@@@ linesEstero ' , linesEstero);

		// if(linesEstero && (infoMAV.PaeseRelazioni1__c == undefined || infoMAV.PaeseRelazioni1__c == '' || infoMAV.PaeseRelazioni1__c == null) && (infoMAV.PaeseRelazioni2__c == undefined || infoMAV.PaeseRelazioni2__c == '' || infoMAV.PaeseRelazioni2__c == null) && ( infoMAV.PaeseRelazioni3__c == undefined || infoMAV.PaeseRelazioni3__c == '' || infoMAV.PaeseRelazioni3__c == null)){
		// 	//ERRORE
		// 	component.find('notifLib').showNotice({
		// 		"variant": "error",
		// 		"header": "ERRORE",
		// 		"message": "Popolare almeno un campo Paese relazione",
		// 		closeCallback: function() {}
		// 	});  
		// 	return false;
		// }

		if(infoMAV.PaeseRelazioni1__c == undefined || infoMAV.PaeseRelazioni1__c == null || infoMAV.PaeseRelazioni1__c == ''){
			component.find('notifLib').showNotice({
				"variant": "error",
				"header": "ERRORE",
				// "message": "Popolare il campo Paese relazione 1",
				"message": $A.get("$Label.c.WGC_Err_PaeseRelazioni_MAV"),
				closeCallback: function() {}
			});  
			return false;
		}

		if ((component.get('v.profilo') != 'IFIS - Crediti Erariali' && tipologiaMAV == 'standard') || tipologiaMAV == 'CC') {
			if ((modulo.Natura_Factoring__c && (modulo.Scopo_Factoring__c == undefined || modulo.Scopo_Factoring__c == '' )) ||
				(modulo.Natura_Finanziamenti__c && (modulo.Scopo_Finanziamenti__c == undefined || modulo.Scopo_Finanziamenti__c == '' )) ||
				(modulo.Natura_Servizi_Bancari__c && (modulo.Scopo_Servizi_Bancari__c == undefined || modulo.Scopo_Servizi_Bancari__c == '' ))) {
					component.set('v.errorSezione1', true);
					component.set('v.errorScopo', 'Compilare la selezione corrispondente alla sezione');
					return false;
			} else if (!modulo.Natura_Factoring__c && !modulo.Natura_Finanziamenti__c && !modulo.Natura_Servizi_Bancari__c) {
				component.set('v.errorSezione1', true);
				component.set('v.errorScopo', 'Compilare almeno una campo di questa sezione');
				return false;
			} else {
				component.set('v.errorSezione1', false);
			}
		}  else if (tipologiaMAV == 'CE' || tipologiaMAV == 'standard' && profilo == 'IFIS - Crediti Erariali') {
			if (modulo.Natura_Crediti_Erariali__c == 'Altro' && (modulo.Altro_Crediti_Erariali__c == '' || modulo.Altro_Crediti_Erariali__c == undefined)) {
				component.set('v.errorCreditiErariali', true);
				component.set('v.errorScopo', 'Compilare il campo \'Altro\'');
				return false;
			} else {
				component.set('v.errorCreditiErariali', false);
			}
		}

		if((modulo.OrigineFondi1__c == false && modulo.OrigineFondi2__c == false && modulo.OrigineFondi3__c == false && modulo.OrigineFondi4__c == false) ||
				modulo.OrigineFondi4__c == true && (modulo.OrigineFondiAltro__c == null || modulo.OrigineFondiAltro__c == undefined || modulo.OrigineFondiAltro__c == '')){
				component.set('v.errorSezione2', true);
				return false;
		} else {
				component.set('v.errorSezione2', false);
			}
		//Controllo che lo scopo sia popolato
		/*if(modulo.NaturaRapportoContinuativoFD__c == null ||
			modulo.NaturaRapportoContinuativoFD__c == undefined ||
			modulo.NaturaRapportoContinuativoFD__c == ""){
				component.set('v.errorScopo', true);
				//component.find('scopo').focus();  -- non funziona dopo il primo giro di errore
				console.log('@@@ modulo.NaturaRapportoContinuativoFD__c ' , modulo.NaturaRapportoContinuativoFD__c);
				console.log('@@@ v.errorScopo ' , component.get('v.errorScopo'));
				return false;
		}
		else{
			component.set('v.errorScopo', false);
		}

		//Controllo che almeno un campo per sezione sia compilato
		if((modulo.ScopoFD11__c != null || modulo.ScopoFD11__c != undefined) ||
			(modulo.ScopoFD12__c != null || modulo.ScopoFD12__c != undefined) ||
			(modulo.ScopoFD13__c != null || modulo.ScopoFD13__c != undefined) ||
			(modulo.ScopoFD14__c != null || modulo.ScopoFD14__c != undefined) ||
			(modulo.ScopoFD15__c != null || modulo.ScopoFD15__c != undefined) ||
			(modulo.ScopoFD16__c != null || modulo.ScopoFD16__c != undefined) ||
			(modulo.ScopoFD17__c != null || modulo.ScopoFD17__c != undefined) ||
			(modulo.ScopoFD18__c != null || modulo.ScopoFD18__c != undefined) ||
			(modulo.ScopoFD19__c != null || modulo.ScopoFD19__c != undefined) ){
				component.set('v.errorSezione1', false);
		}
		else{
			component.set('v.errorSezione1', true);
			//component.find('sezione1').focus();  -- non funziona dopo il primo giro di errore
			console.log('@@@ v.errorSezione1 ' , component.get('v.errorSezione1'));
			return false;
		}

		//Controllo che almeno un campo della seconda sezione sia compilato
		if((modulo.OrigineFondi1__c != null || modulo.OrigineFondi1__c != undefined) ||
			(modulo.OrigineFondi2__c != null || modulo.OrigineFondi2__c != undefined) ||
			(modulo.OrigineFondi3__c != null || modulo.OrigineFondi3__c != undefined) ||
			(modulo.OrigineFondi4__c != null || modulo.OrigineFondi4__c != undefined) ){
				component.set('v.errorSezione2', false);
		}
		else{
			component.set('v.errorSezione2', true);
			//component.find('sezione2').focus();  -- non funziona dopo il primo giro di errore
			console.log('@@@ v.errorSezione2 ' , component.get('v.errorSezione2'));
			return false;
		}*/

		//Controllo campo Paese Casa Madre
		var mav = component.get('v.infoMav');
		if (mav.WGC_Gruppo_frm__c == true) {
			if (mav.PaeseCasaMadre__c != null && mav.PaeseCasaMadre__c != undefined && mav.PaeseCasaMadre__c != '') {
				component.set('v.errorPaeseCasaMadre', false);
			} else {
				console.log('@@@ v.errorPaeseCasaMadre ' , component.get('v.errorPaeseCasaMadre'));
				component.set('v.errorPaeseCasaMadre', true);
				return false;
			}
		} else {
			component.set('v.errorPaeseCasaMadre', false);
		}
		//Controllo campo Paese svolgimento attività prevalente
		if (mav.PaeseSvolgimentoAttivitaPrevalente__c != null && mav.PaeseSvolgimentoAttivitaPrevalente__c != undefined && mav.PaeseSvolgimentoAttivitaPrevalente__c != '') {
			component.set('v.errorPaeseSvolgimentoAttivitaPrevalente', false);
		} else {
			console.log('@@@ v.errorPaeseSvolgimentoAttivitaPrevalente ' , component.get('v.errorPaeseSvolgimentoAttivitaPrevalente'));
			component.set('v.errorPaeseSvolgimentoAttivitaPrevalente', true);
			return false;
		}
		//Controllo campo Provincia svolgimento attività
		if (mav.ProvinciaSvolgimentoAttivitaPrevalente__c != null && mav.ProvinciaSvolgimentoAttivitaPrevalente__c != undefined && mav.ProvinciaSvolgimentoAttivitaPrevalente__c != '') {
			component.set('v.errorProvinciaSvolgimentoAttivitaPrevalente', false);
		} else {
			console.log('@@@ v.errorProvinciaSvolgimentoAttivitaPrevalente ' , component.get('v.errorProvinciaSvolgimentoAttivitaPrevalente'));
			component.set('v.errorProvinciaSvolgimentoAttivitaPrevalente', true);
			return false;
		}

		// if(!component.get("v.VisitaLocaliAzienda")){
		// 	component.find('notifLib').showNotice({
		// 		"variant": "error",
		// 		"header": "ERRORE",
		// 		// "message": "Popolare il campo Paese relazione 1",
		// 		"message": "è necessario confermare di aver fatto visita presso i locali dell'azienda",
		// 		closeCallback: function() {}
		// 	});  
		// 	return false;
		// }

		console.log('@@@ altro ' , modulo.OrigineFondi4__c + ' ' + modulo.OrigineFondiAltro__c);
		//Ritorno true solo se passo tutte le validazioni
		return true;
	},

	salvaModulo : function(component, event, helper, titolari){

        //Convalida dati
        var esito = false;
		esito = helper.convalidaDati(component, event, helper);
		console.log('@@@ esito ', esito);
        if(esito == false){
			component.set("v.saveReferenti", false);
			component.set("v.isLoaded", true);
            return false;
        }

        var rec = component.get('v.modulo');
        
        /*if((rec.OrigineFondi1__c == false && rec.OrigineFondi2__c == false && rec.OrigineFondi3__c == false && rec.OrigineFondi4__c == false) ||
			rec.OrigineFondi4__c == true && (rec.OrigineFondiAltro__c == null || rec.OrigineFondiAltro__c == undefined || rec.OrigineFondiAltro__c == '')){
			component.set("v.saveReferenti", false);
            component.set("v.isLoaded", true);
            return false;
        }*/

        //Azione da gestire al ritorno dell'evento dal componente dei titolari esecutori
        var action = component.get('c.SaveRecord');
        action.setParams({
            "recordId" : component.get('v.recordId'),
			"recordMAV" : JSON.stringify(rec),
			"recordAccountContact" : JSON.stringify(titolari.relation),
			"flagConsensi" : titolari.flagConsensi,
			"informazioniMav" : component.get('v.infoMav'),
			"tipologiaMav" : component.get("v.tipologiaMav"),
			visitaLocaliAzienda : component.get("v.VisitaLocaliAzienda")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
				console.log('@@@ response salvataggio ' , response.getReturnValue());

				var risposta = response.getReturnValue();
				if(risposta.success){
					var lib = component.find('overlayLib');
					lib.notifyClose();
					var msg = $A.get("e.force:showToast");
					msg.setParams({
						"title" : "Successo!",
						"message" : "Salvataggio avvenuto con successo",
						"type" : "success"
					});
					msg.fire();

					var up = $A.get('e.c:WGC_ChangeMavInfo');
					up.fire();
					
					//Inserire evento per update mav
					component.set("v.isLoaded", true);
				}
				else{
					var msg = $A.get("e.force:showToast");
					msg.setParams({
						"title" : "Errore!",
						"message" : risposta.message,
						"type" : "ERROR"
					});
					var lib = component.find('overlayLib');
					lib.notifyClose();
					msg.fire();

					component.set("v.isLoaded", true);
				}
            }
            if (state == 'ERROR'){

				console.log('@@@@ error ' , response.getError());
                var msg = $A.get("e.force:showToast");
                msg.setParams({
                    "title" : "Errore!",
                    "message" : "Errore durante il salvataggio",
                    "type" : "ERROR"
                });
                var lib = component.find('overlayLib');
                lib.notifyClose();
                msg.fire();

				component.set("v.isLoaded", true);
            }
        });
        $A.enqueueAction(action);
	},

	caricaNazioni: function(component, event, helper) {
        var action = component.get("c.getselectOptions_Nazione");
		action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
				var allValues = response.getReturnValue();

				var opts = [];
				var optsBis = [];
                opts.push({
                    label: "",
                    value: ""
                });
				optsBis.push({
                    label: "",
                    value: ""
                });

                for (var k in allValues) {
                    opts.push({
                        label: k,
                        value: k
                    });

					if (k != 'ITALIA') {
						optsBis.push({
                        label: k,
                        value: k
						});
					}
                }
                component.set("v.nazioni", opts);
				component.set("v.nazioniSenzaItalia", optsBis);

			}
			 if (state == 'ERROR'){
				console.log('ERROR', response.getError() ); 
                reject( response.getError() );
			}
		});
		$A.enqueueAction(action);
    },

	caricaProvince: function(component, event, helper) {
        var action = component.get("c.getselectOptions_Province");
		action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
				var allProvince = response.getReturnValue();

				var prv = [];
                prv.push({
                    label: "",
                    value: ""
				});
				
                for (var k in allProvince) {
                    prv.push({
                        label: allProvince[k],
                        value: k
                    });
                }
                component.set('v.province', prv);

			}
			 if (state == 'ERROR'){
				console.log('ERROR', response.getError() ); 
                reject( response.getError() );
			}
		});
		$A.enqueueAction(action);
    },

	caricaScopiRapporto : function(component, event, helper) {
        var actionFactoring = component.get("c.getScopoFactoring");
		var actionFinanziamenti = component.get("c.getScopoFinanziamenti");
		var actionServiziBancari = component.get("c.getScopoServiziBancari");
		var actionNaturaCreditiErariali = component.get("c.getNaturaCreditiErariali");
        var optsScopoFactoring=[];
		var modulo = component.get('v.modulo');
		
        actionFactoring.setCallback(this, function(response) {
			optsScopoFactoring.push({
                label: "",
                value: ""
            });
			var scopo = response.getReturnValue();
            for(var a in scopo){
                optsScopoFactoring.push({label: scopo[a], value: a, selected: (a == modulo.Scopo_Factoring__c) ? true : false});
            }
			component.set("v.scopoFactoring", optsScopoFactoring);
        });
        $A.enqueueAction(actionFactoring); 
		
        var optsScopoFinanziamenti=[];
        actionFinanziamenti.setCallback(this, function(response) {
			optsScopoFinanziamenti.push({
                label: "",
                value: ""
            });
            var scopo = response.getReturnValue();
            for(var a in scopo){
                optsScopoFinanziamenti.push({label: scopo[a], value: a, selected: (a == modulo.Scopo_Finanziamenti__c) ? true : false});
			}
			component.set("v.scopoFinanziamenti", optsScopoFinanziamenti);
        });
        $A.enqueueAction(actionFinanziamenti); 

		var optsScopoServiziBancari=[];
        actionServiziBancari.setCallback(this, function(response) {
			optsScopoServiziBancari.push({
                label: "",
                value: ""
            });
            var scopo = response.getReturnValue();
            for(var a in scopo){
                optsScopoServiziBancari.push({label: scopo[a], value: a, selected: (a == modulo.Scopo_Servizi_Bancari__c) ? true : false});
			}
			component.set("v.scopoServiziBancari", optsScopoServiziBancari);
        });
        $A.enqueueAction(actionServiziBancari); 
    },

	caricaNaturaCreditiErariali : function(component, event, helper) {
		var actionNaturaCreditiErariali = component.get("c.getNaturaCreditiErariali");
		var modulo = component.get('v.modulo');

		var optsNaturaCreditiErariali=[];
        actionNaturaCreditiErariali.setCallback(this, function(response) {
            var scopo = response.getReturnValue();
            for(var a in scopo){
                optsNaturaCreditiErariali.push({label: scopo[a], value: a, selected: (a == modulo.Scopo_Factoring__c) ? true : false});
			}
			component.set("v.naturaCreditiErariali", optsNaturaCreditiErariali);
			if (modulo.Natura_Crediti_Erariali__c == '') {
				component.set('v.modulo.Natura_Crediti_Erariali__c', 'Cessione di crediti fiscali');
				}
        });
        $A.enqueueAction(actionNaturaCreditiErariali); 
	},

	getProfilo : function(component, event, helper) {
		var action = component.get('c.getProfilo');
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue();
                if(risposta != null || risposta != undefined){
                    component.set('v.profilo', risposta);
                }
            }
        });
        $A.enqueueAction(action);
	},
})