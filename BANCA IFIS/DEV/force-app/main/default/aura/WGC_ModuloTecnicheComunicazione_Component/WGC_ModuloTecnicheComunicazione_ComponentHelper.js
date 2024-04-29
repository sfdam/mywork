({
	getMAVData : function(component, event, helper){
		var recId = component.get("v.recordId");
		var action = component.get("c.getMAV");
		action.setParams({
			"recordId" : recId
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == 'SUCCESS'){
				var risposta = response.getReturnValue();

				console.log('@@@ risposta mav mtc ' , risposta);
				if(risposta != null && risposta != undefined){
					component.set("v.modulo.Id", risposta.Id);
					component.set('v.modulo.CorrispondenzaCountry__c', risposta.CorrispondenzaCountry__c);
					component.set('v.modulo.CorrispondenzaState__c', risposta.CorrispondenzaState__c);
					component.set('v.modulo.CorrispondenzaCity__c', risposta.CorrispondenzaCity__c);
					component.set('v.modulo.CorrispondenzaStreetType__c', risposta.CorrispondenzaStreetType__c)
					component.set('v.modulo.CorrispondenzaStreetName__c', risposta.CorrispondenzaStreetName__c);
					component.set('v.modulo.CorrispondenzaStreetNumber__c', risposta.CorrispondenzaStreetNumber__c);
					component.set('v.modulo.CorrispondenzaCAP__c', risposta.CorrispondenzaCAP__c);
				}
			}
			else{
				console.log('@@@ error mav ' + response.getError());
			}
		});

		$A.enqueueAction(action);
	},
	
	convalidaDati: function (component, event, helper) {
		var doc = component.get('v.modulo');
		var account = component.get('v.acc');

		console.log('@@@ doc ', doc);
        console.log('@@@ account ', account.EmailPEC__c);

		var datiDiContattoValidi = false;

		var statusPec = true;
		if ((account.EmailPEC__c == null || account.EmailPEC__c == "" || account.EmailPEC__c == undefined) &&
            (account.Email__c == null || account.Email__c == "" || account.Email__c == undefined) &&
           	(account.EmailPECFatturaElettronica__c == null || account.EmailPECFatturaElettronica__c == "" || account.EmailPECFatturaElettronica__c == undefined) &&
            (account.CodiceDestinatario__c == null || account.CodiceDestinatario__c == "" || account.CodiceDestinatario__c == undefined) &&
           	(account.Phone == null || account.Phone == "" || account.Phone == undefined) &&
           	(account.Fax == null || account.Fax == "" || account.Fax == undefined)) {
			//component.set('v.datiDiContatto', true);
			statusPec = false;
		}
		else if(account.EmailPEC__c != null && account.EmailPEC__c != "" && account.EmailPEC__c != undefined){
			var validazioneEmailPEC = this.validateEmail(component, event, helper, account.EmailPEC__c);
			if (!validazioneEmailPEC) {
				component.set('v.datiDiContatto', true);
				return false;
			} else {
				component.set('v.datiDiContatto', false);
				datiDiContattoValidi = true;
			}
		}
		/*
		var statusN = true;
		if (account.Email__c == null || account.Email__c == "") {
			//component.set('v.datiDiContatto', true);
			statusN = false;
		}
		else {
			var validazioneEmail = this.validateEmail(component, event, helper, account.Email__c);
			if (!validazioneEmail) {
				component.set('v.datiDiContatto', true);
				return false;
			} else {
				component.set('v.datiDiContatto', false);
				datiDiContattoValidi = true;
			}
		}

		console.log('@@@ statusN ' , statusN);
        */
		console.log('@@@ statusPec ' , statusPec);

		//if (statusPec && statusN) {
        if (statusPec) {
			var indirizzoLegaleTab = component.get('v.legale');
            console.log('@@@ indirizzoLegaleTab ' , indirizzoLegaleTab);
			if (indirizzoLegaleTab) {
				console.log('@@@ analizzo Billing ');
				console.log('@@@ account.BillingStreetName__c ', account.BillingStreetName__c);
				if ((account.BillingState == null || account.BillingState == '') ||
					(account.BillingAddress.city == null || account.BillingAddress.city == '') ||
					//(account.BillingStreetType__c == null || account.BillingStreetType__c == '') ||
					(account.BillingStreetName__c == null || account.BillingStreetName__c == '') ||
					(account.BillingStreetNumber__c == null || account.BillingStreetNumber__c == '')) {
                    //(account.BillingAddress.postalCode == null || account.BillingAddress.postalCode == '')
					//(account.BillingAddress.country == null || account.BillingAddress.country == '') ||
					account.IndirizzoPerInvioCorrispondenza__c = 'Sede legale';
					//Mostro messaggio di errore
					component.set('v.indirizzi', true);
					return false;
				}
				else{
					account.IndirizzoPerInvioCorrispondenza__c = 'Sede legale';
					return true;
				}
			}

			var indirizzoAmministrativoTab = component.get('v.amministrativa');

			if (indirizzoAmministrativoTab) {
				console.log('@@@ analizzo Shipping ');
				console.log('@@@ account.ShippingStreetName__c ', account.ShippingStreetName__c);
                //(account.ShippingAddress.country == null || account.ShippingAddress.country == '') ||
				if ((account.ShippingState == null || account.ShippingState == '') ||
					//(account.ShippingAddress.city == null || account.ShippingAddress.city == '') ||
					//(account.ShippingStreetType__c == null || account.ShippingStreetType__c == '') ||
					(account.ShippingStreetName__c == null || account.ShippingStreetName__c == '') ||
					(account.ShippingStreetNumber__c == null || account.ShippingStreetNumber__c == '')) {
					//account.ShippingAddress.postalCode == null || account.ShippingAddress.postalCode == '')
					account.IndirizzoPerInvioCorrispondenza__c = 'Sede amministrativa';
					//Mostro messaggio di errore
					component.set('v.indirizzi', true);
					return false;
				}
				else{
					account.IndirizzoPerInvioCorrispondenza__c = 'Sede amministrativa';
					return true;
				}
			}

			var indirizzoAltroTab = component.get('v.altro');

			if (indirizzoAltroTab) {
				console.log('@@@ account.BillingStreetName__c ', account.BillingStreetName__c);
				console.log('@@@ doc ' , JSON.stringify(doc));
				console.log('@@@ condizione2 ' + doc.CorrispondenzaCountry__c == '' || doc.CorrispondenzaState__c == '' || 
				doc.CorrispondenzaCity__c == '' || doc.CorrispondenzaStreetName__c == '' || doc.CorrispodenzaCAP__c == '');

				if (doc.CorrispondenzaCountry__c == '' || doc.CorrispondenzaState__c == '' || 
					doc.CorrispondenzaCity__c == '' || doc.CorrispondenzaStreetName__c == '' || 
                    doc.CorrispodenzaCAP__c == '' || doc.CorrispondenzaStreetType__c == '') {

					account.IndirizzoPerInvioCorrispondenza__c = 'Altro';
					//Mostro messaggio di errore
					component.set('v.indirizzi', true);

					console.log('@@@ prova ' , account.IndirizzoPerInvioCorrispondenza__c);
					return false;
				}
				else{
					console.log('@@@ prova');
					account.IndirizzoPerInvioCorrispondenza__c = 'Altro';
					return true;
				}
			}
			

		}
        else{
            component.set("v.datiDiContatto", true);
            return false;
        }
			
		return true;
	},

	validateEmail : function(component, event, helper, email){
		var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
		console.log('@@@ re ' , re.test(String(email).toLowerCase()));
		return re.test(String(email).toLowerCase());
	},
})