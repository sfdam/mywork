({
	getPrivacyText : function(component, event, helper) {
		var action = component.get('c.getText');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var risposta = response.getReturnValue();
				console.log('@@@ risposta ' , risposta);
				component.set('v.Sezione1', risposta.Sezione_1__c);
				component.set('v.Sezione2', risposta.Sezione_2__c);
				component.set('v.Sezione3', risposta.Sezione_3__c);
				component.set('v.Sezione4', risposta.Sezione_4__c);
				component.set('v.Sezione5', risposta.Sezione_5__c);
				component.set('v.Sezione6', risposta.Sezione_6__c);
			}
			else{
				console.log('@@@ error retrieving text ' );
			}
		});
		$A.enqueueAction(action);
	},

	getEsecutori : function(component, event, helper){
		var accId = component.get("v.recordId");
		var action = component.get("c.getReferentiEsecutori");
		action.setParams({
			"accountId" : accId
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				if(risposta.success){
					var lista = [];
					risposta.data.forEach((item, index) =>{
						lista.push(item);
					});
					console.log('@@@ listaEsecutori ' , lista);

					component.set("v.listaEsecutori", lista);
				}
				else{
					console.log('@@@ risposta.message ' , risposta.message);
				}
			}
			else{
				console.log('@@@ error ' , response.getError());
			}
		});

		$A.enqueueAction(action);
	},

	savePrivacyEsecutore : function(component, event, helper){
		event.preventDefault();
		component.set('v.isLoaded', false);
		var rec = component.get('v.rec');
		var esec = component.get("v.esecutore");
		var accId = component.get("v.recordId");
		var action = component.get("c.saveAccountPrivacy");
		action.setParams({
			"accountId" : accId,
			"record" : JSON.stringify(rec),
			"esecutore" : esec
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				var risposta = response.getReturnValue();
				console.log('@@@ ppg ' , risposta);
				var lib = component.find('overlayLib');

				//Evento per aggiornare la info di account
				var updtAcc = $A.get("e.c:WGC_RefreshPrivacy");
				updtAcc.fire();

				lib.notifyClose();

				if(risposta.success){
					var msg = $A.get("e.force:showToast");
					msg.setParams({
						"title" : "Successo!",
						"message" : "Salvataggio avvenuto con successo",
						"type" : "success"
					});
					msg.fire();
				}
				else{
					var msg = $A.get("e.force:showToast");
					msg.setParams({
						"title" : "Errore!",
						"message" : risposta.message,
						"type" : "error"
					});
					msg.fire();
				}
			}
			else{
				console.log('@@@ error ' , response.getError());
			}
		});

		$A.enqueueAction(action);
	},

})