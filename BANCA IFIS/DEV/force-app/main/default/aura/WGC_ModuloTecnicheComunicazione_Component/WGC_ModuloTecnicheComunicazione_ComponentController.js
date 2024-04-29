({
	doInit : function(component, event, helper) {
		var action = component.get('c.getAccountData');
		action.setParams({
			"recordId" : component.get('v.recordId')
		});
		action.setCallback(this, function(response){
			if (response.getState() == "SUCCESS"){
				var rsp = response.getReturnValue();
				component.set("v.acc", rsp);
				//Shipping

				//Creo un array con le parole che formano la via e prendo la prima parola come tipo via e l'ultima come civico
				if(rsp.ShippingAddress != undefined && rsp.ShippingAddress != null && rsp.ShippingAddress.street != null){
					var arrShippingStreet = rsp.ShippingAddress.street.split(/\s+/);
					component.set('v.acc.ShippingStreetType__c', arrShippingStreet[0]);
					//Formatto la street name
					var streetShi = '';
					for(var key in arrShippingStreet){
						
						if(key != 0 && key != (arrShippingStreet.length - 1)){
							streetShi = streetShi + ' ' + arrShippingStreet[key];
						}
					}
					component.set('v.acc.ShippingStreetName__c', streetShi);
					component.set('v.acc.ShippingStreetNumber__c', arrShippingStreet[arrShippingStreet.length-1]);
				}
				
                if(rsp.ShippingAddress != undefined && rsp.ShippingAddress != null){
                    component.set('v.acc.ShippingCountry', rsp.ShippingAddress.country);
                    component.set('v.acc.ShippingState', rsp.ShippingAddress.state);
                    component.set('v.acc.ShippingCity', rsp.ShippingAddress.city);
                    component.set('v.acc.ShippingPostalCode', rsp.ShippingAddress.postalCode);
                }

				//Billing
				//Creo un array con le parole che formano la via e prendo la prima parola come tipo via e l'ultima come civico
				if(rsp.BillingAddress != undefined && rsp.BillingAddress != null && rsp.BillingAddress.street != null){
					var arrBillingStreet = rsp.BillingAddress.street.split(/\s+/);

					console.log('@@@ arrBillingStreet ' , arrBillingStreet);
					component.set('v.acc.BillingStreetType__c', arrBillingStreet[0]);
	
					var street = '';
					for(var key in arrBillingStreet){
						
						if(key != 0 && key != (arrBillingStreet.length - 1)){
							street = street + ' ' + arrBillingStreet[key];
						}
					}
					//rsp.BillingAddress.street
					component.set('v.acc.BillingStreetName__c', street);
					component.set('v.acc.BillingStreetNumber__c', arrBillingStreet[arrBillingStreet.length-1]);
				}
				
                if(rsp.BillingAddress != undefined && rsp.BillingAddress != null){
                    component.set('v.acc.BillingCountry', rsp.BillingAddress.country);
                    component.set('v.acc.BillingState', rsp.BillingAddress.state);
                    component.set('v.acc.BillingCity', rsp.BillingAddress.city);
                    component.set('v.acc.BillingPostalCode', rsp.BillingAddress.postalCode);
                }


				component.set('v.isLoaded', true);
				//altro
				/*component.set('v.modulo.CorrispondenzaCountry__c', rsp.BillingAddress.country);
				component.set('v.modulo.CorrispondenzaState__c', rsp.BillingAddress.state);
				component.set('v.modulo.CorrispondenzaCity__c', rsp.BillingAddress.city);
				component.set('v.modulo.CorrispondenzaStreetName__c', rsp.BillingAddress.street);
				component.set('v.modulo.CorrispondenzaCAP__c', rsp.BillingAddress.postalCode);*/
				console.log('@@@ acc ' , JSON.stringify(component.get('v.acc')));
			}
		});
		$A.enqueueAction(action);

		helper.getMAVData(component, event, helper);
	},

	changeTab : function(component, event, helper){
		var idTab = event.getSource().getLocalId();
		//var idTab = event.target.id;
		//console.log('@@@ id html ' , idTab);

		if(idTab == 'legale'){
			component.set('v.legale', true);
			component.set('v.amministrativa', false);
			component.set('v.altro', false);

			var legale = component.find("legale");
			$A.util.addClass(legale, "btn-active");

			var amministrativa = component.find("amministrativa");
			$A.util.removeClass(amministrativa, "btn-active");

			var altro = component.find("altro");
			$A.util.removeClass(altro, "btn-active");
		}
		else if(idTab == 'amministrativa'){
			component.set('v.legale', false);
			component.set('v.amministrativa', true);
			component.set('v.altro', false);

			var amministrativa = component.find("amministrativa");
			$A.util.addClass(amministrativa, "btn-active");

			console.log('@@@ amministrativa ' , amministrativa);

			var legale = component.find("legale");
			$A.util.removeClass(legale, "btn-active");

			console.log('@@@ legale ' , legale);

			var altro = component.find("altro");
			$A.util.removeClass(altro, "btn-active");
		}
		else if(idTab == 'altro'){
			component.set('v.legale', false);
			component.set('v.amministrativa', false);
			component.set('v.altro', true);

			var altro = component.find("altro");
			$A.util.addClass(altro, "btn-active");

			var legale = component.find("legale");
			$A.util.removeClass(legale, "btn-active");

			var amministrativa = component.find("amministrativa");
			$A.util.removeClass(amministrativa, "btn-active");
		}

		console.log('@@@ idTab ' , idTab);
	},

	changeTabNew : function(component, event, helper){
		var idTab = event.getSource().get("v.value");

		if(idTab == 'legale'){
			component.set('v.legale', true);
			component.set('v.amministrativa', false);
			component.set('v.altro', false);
		}
		else if(idTab == 'amministrativa'){
			component.set('v.legale', false);
			component.set('v.amministrativa', true);
			component.set('v.altro', false);
		}
		else if(idTab == 'altro'){
			component.set('v.legale', false);
			component.set('v.amministrativa', false);
			component.set('v.altro', true);
		}

		console.log('@@@ idTab ' , idTab);
	},

	changeStreetType : function(component, event, helper){
		var streetType = event.getSource().get("v.value");
		var addressType = event.getSource().getLocalId();

		console.log('@@@ change address ' , streetType + ' - ' + addressType);

		if(addressType != 'Corrispondenza'){
			component.set("v.acc."+addressType+'StreetType__c' , streetType);
			console.log('@@@ final ' , component.get("v.acc"));
		}
		else{
			component.set("v.modulo."+addressType+'StreetType__c' , streetType);
			console.log('@@@ final ' , component.get("v.modulo"));
		}

		//console.log('@@@ final ' , component.get("v.acc"));
	},

	saveRecord : function(component, event, helper){
		event.preventDefault();
		component.set('v.isLoaded', false);
		//Metodo per convalidare i dati prima di salvare
		var esito = helper.convalidaDati(component, event, helper);
		console.log('@@@ esito ' , esito);

		var recMod = component.get('v.modulo');
		var recAcc = component.get('v.acc');

		var sd = component.get("v.legale");
        console.log('@@@ sd ' , sd);
        var sa = component.get("v.amministrativa");
        console.log('@@@ sa ' , sa);
        var saltra = component.get("v.altro");
        console.log('@@@ saltra ' , saltra);
		
		if(esito == false){
			component.set("v.isLoaded", true);

			//
			if(sd){
				recAcc.IndirizzoPerInvioCorrispondenza__c = 'Sede legale';
				component.set("v.legale", true);
				component.set("v.amministrativa", false);
				component.set("v.altro", false);

				// var legale = component.find("legale");
				// $A.util.addClass(legale, "btn-active");

				// console.log('@@@ legale ' , legale);

				// var altro = component.find("altro");
				// $A.util.removeClass(altro, "btn-active");

				// var amministrativa = component.find("amministrativa");
				// $A.util.removeClass(amministrativa, "btn-active");

			}
			else if(sa){
				recAcc.IndirizzoPerInvioCorrispondenza__c = 'Sede amministrativa';
				component.set("v.amministrativa", true);
				component.set("v.legale", false);
				component.set("v.altro", false);
	
				// var amministrativa = component.find("amministrativa");
				// $A.util.addClass(amministrativa, "btn-active");

				// console.log('@@@ amministrativa ' , amministrativa);

				// var legale = component.find("legale");
				// $A.util.removeClass(legale, "btn-active");

				// var altro = component.find("altro");
				// $A.util.removeClass(altro, "btn-active");

			}
			else if(saltra){
				recAcc.IndirizzoPerInvioCorrispondenza__c = 'Altro';
				component.set("v.altro", true);
				component.set("v.amministrativa", false);
				component.set("v.legale", false);
	
				// var altro = component.find("altro");
				// $A.util.addClass(altro, "btn-active");

				// var legale = component.find("legale");
				// $A.util.removeClass(legale, "btn-active");
	
				// var amministrativa = component.find("amministrativa");
				// $A.util.removeClass(amministrativa, "btn-active");
			}

			console.log('@@@ sd ' , sd);
			console.log('@@@ sa ' , sa);
			console.log('@@@ saltra ' , saltra);

			return;
		}
        
        console.log('@@@ account.IndirizzoPerInvioCorrispondenza__c ' + recAcc.IndirizzoPerInvioCorrispondenza__c);
        var action = component.get('c.SaveRecord');
        action.setParams({
            "recordId" : component.get('v.recordId'),
			"recordMod" : JSON.stringify(recMod),
			"recordAcc" : JSON.stringify(recAcc)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
				var risposta = response.getReturnValue();
				console.log('@@@ risposta ' , risposta);
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
				}
				else{
					console.log('@@@ risposta ' , risposta);
					var msg = $A.get("e.force:showToast");
					msg.setParams({
						"title" : "Errore!",
						"message" : risposta.message,
						"type" : "error"
					});
					var lib = component.find('overlayLib');
					lib.notifyClose();
					msg.fire();
				}

            }
            if (state == 'ERROR'){
                var msg = $A.get("e.force:showToast");
                msg.setParams({
                    "title" : "Errore!",
                    "message" : "Errore durante il salvataggio",
                    "type" : "error"
				});
                var lib = component.find('overlayLib');
                lib.notifyClose();
                msg.fire();
			}
			component.set("v.isLoaded", true);
        });
		$A.enqueueAction(action);
	},

	close : function (component, event, helper){
		var lib = component.find('overlayLib');
		lib.notifyClose();
	}
})