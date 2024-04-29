({
	doInit : function(component, event, helper) {
		var resp;
		var action = component.get("c.GetAccountDataEN");
		action.setParams({
			"recordId" : component.get("v.recordId")
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				resp = response.getReturnValue();
				
				for(var key in resp){
					if(resp[key] == "V"){
						resp[key] = true;
					}
					else if(resp[key] == "F"){
						resp[key] == false
					}
				}

				var results = [];
				results.push({ labelCampo: 'Variazione forma giuridica societaria', Si : resp.EventiNegativiAllarmiQuote__c, No : !resp.EventiNegativiAllarmiQuote__c});
				results.push({ labelCampo: 'Pregiudizievoli / Protesti', Si : resp.EventiNegativiCIGS__c, No : !resp.EventiNegativiCIGS__c});
				results.push({ labelCampo: 'Variaizione compagine societaria', Si : resp.EventiNegativiGlobale__c, No : !resp.EventiNegativiGlobale__c});
				results.push({ labelCampo: 'Operazioni straordinarie (affitto, compravendita)', Si : resp.EventiNegativiPregiudizievoli__c, No : !resp.EventiNegativiPregiudizievoli__c});
				results.push({ labelCampo: 'Titolare effettivo in corso di validità', Si : resp.EventiNegativiProcedureConcorsuali__c, No : !resp.EventiNegativiProcedureConcorsuali__c});
				component.set("v.data", results);
			}
			else if(response.getState() == "ERROR"){

			}
		});
		$A.enqueueAction(action);

		//setto i parametri della tabella
		component.set('v.columns', [
			{label: '', fieldName: 'labelCampo', type: 'text'},
			{label: 'Si', fieldName: 'Si', type: 'boolean'},
			{label: 'No', fieldName: 'No', type: 'boolean'}
		]);

		
	},

	collapse : function (component, event, helper){
		var clps = component.get("v.IsCollapsed");
		console.log('@@@ initial ' , clps);
		if(clps == true){
			component.set("v.IsCollapsed", false);
			console.log('@@@ if true ' , clps);
		}
		else if(clps == false){
			component.set("v.IsCollapsed", true);
			console.log('@@@ if false ' , clps);
		}
	},
	
})