({
	doInit : function(component, event, helper) {
		/*
		console.log('@@@ recordId ' , component.get("v.recordId"));
		console.log('@@@ title ' , component.get("v.title"));
		var action = component.get("c.getRecordData");
		action.setParams({
			recordId : component.get("v.recordId"),
			title : component.get("v.title")
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				console.log('@@@ response l ' , risposta);
				if(risposta.leasing != null){
					component.set("v.listaPosLeasing", risposta.leasing);
				}
			}
			else if(response.getState() == "ERROR"){
				console.log('@@@ error ' , response.getError());
				var msg = $A.get("e.force:showToast");
				msg.setParams({
					"title" : "ERRORE",
					"message" : "Ricarica la pagina"
				});
				msg.fire();
			}
		});
		$A.enqueueAction(action);
		*/
	},

	goToDetail : function(component, event, helper){
		/*
		var itemId = event.target.getAttribute("data-index");

		var pg = {    
			"type": "standard__recordPage",
			"attributes": {
				"recordId": itemId,
				"objectApiName": "WGC_Posizione__c",
				"actionName": "view"
			}
		}

		var nav = component.find("navService");
		nav.navigate(pg);
		*/
	},
})