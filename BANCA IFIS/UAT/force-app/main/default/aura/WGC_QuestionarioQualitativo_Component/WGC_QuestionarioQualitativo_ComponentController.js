({
	doInit : function(component, event, helper) {
		//chiamo i servizi per impostare le domande e le possibili risposte
		var action = component.get('c.getData');
		action.setParams({
			"recordId" : component.get("v.recordId")
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				var res = response.getReturnValue();
				//console.log('@@@ JSON response ' , JSON.parse(res));
				var risp = JSON.parse(res);
				var arrayIstruzioni = [];
				
				//costruisco la lista di istruzioni da inserire nell'help text
				var regex = /\d+/g;

				for (var key in risp.qq) {
					if (risp.qq.hasOwnProperty(key)) {
						if(key.includes("Istruzione")){
							var matches = key.match(regex);
							var ind = parseInt(matches) - 1;
							console.log('@@@ match ' , ind);
							arrayIstruzioni[ind] = risp.qq[key];
						}
					}
				}
				//console.log('@@@ array istruzioni ' , arrayIstruzioni);
				component.set("v.istruzioni", arrayIstruzioni);

				component.set("v.isLoaded" , true);
				console.log('@@@ lunghezza risp ' , risp.domande.length);
				/*if(prova.domande.length > 18){
					prova.domande.splice(18, prova.domande.length - 18);
				}
				if(prova.domande.length > 21){
					prova.domande.splice(21, prova.domande.length - 21);
				}*/
				console.log('@@@ risp dopo delete ' , risp);
				component.set("v.qa", risp);
				component.set("v.domande", risp.domande);
			}
			else{
				alert('error');
				console.log('@@@ error ' , response.getError());
                /*let lstError = response.getError()[0];
                console.log('@@@ lstError ' , lstError);
                console.log('@@@ lstError ' , lstError.fieldErrors[0]);
                let msgErr;
                if(lstError.fieldErrors[0] != null || lstError.fieldErrors[0] != undefined){
                    msgErr = lstError.fieldErrors[0].message;
                }
                else if(lstError.pageErrors[0] != null || lstError.pageErrors[0] != undefined){
                    msgErr = lstError.pageErrors[0].message;
                }
				var lib = component.find('overlayLib');
				lib.notifyClose();
				var msg = $A.get("e.force:showToast");
				msg.setParams({
                    "title" : "Errore!",
                    "message" : msgErr,
                    "type" : "error"
				});
				msg.fire();*/
			}
		});
		$A.enqueueAction(action);
	},

	handleChange : function(component, event, helper){
		var selectCmp = component.find("stat");
		component.set('v.stato', selectCmp.get("v.value"));
		var qq = component.get("v.qa.qq");
		qq.Stato__c = component.get("v.stato");
	},

	saveRecord : function(component, event, helper){
		component.set('v.isLoaded', false);
		console.log('@@@ isLoaded', component.get('v.isLoaded'));
		var statoRecord = component.get('v.stato');
		var action = component.get('c.salvaQQ');
		action.setParams({
			"domande" : JSON.stringify(component.get("v.domande")),
			"qq" : JSON.stringify(component.get("v.qa.qq"))
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
                    "title" : "Successo!",
                    "message" : "Salvataggio avvenuto con successo",
                    "type" : "success"
				});
				var lib = component.find('overlayLib');
				lib.notifyClose();
				toastEvent.fire();
			}
			else{
				var msg = $A.get("e.force:showToast");
				msg.setParams({
                    "title" : "Errore!",
                    "message" : "Errore durante il salvataggio, ricontrolla i campi",
                    "type" : "error"
				});
				var cls = component.find('overlayLib');
				cls.notifyClose();
				msg.fire();
			}
		});
		$A.enqueueAction(action);
	},

	close : function(component, event, helper){
		var lib = component.find('overlayLib');
		lib.notifyClose();
	},

	selectAnswer : function(component, event, helper){
		var selezione = event.getSource().get("v.value");
		var dv = selezione.split(';');
		var domandaSelezionata = dv[0];
		var rispostaSelezionata = dv[1];
		var domande = component.get("v.domande");
		for(var key in domande){
			if(domande[key].domanda == domandaSelezionata){
				domande[key].value = rispostaSelezionata;
			}
		}
	}
})