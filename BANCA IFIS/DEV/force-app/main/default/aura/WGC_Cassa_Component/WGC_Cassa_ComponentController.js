({
	doInit : function(component, event, helper) {
		/*
		console.log('@@@ recordId ' , component.get("v.recordId"));
		var action = component.get("c.getRecordData");
		action.setParams({
			recordId : component.get("v.recordId"),
			title : component.get("v.title")
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				console.log('@@@ response cassa' , risposta);
				if(risposta != null){
					component.set("v.listaPosAltro", risposta.altro);
				}
			}
			else if(response.getState() == "ERROR"){
				var msg = $A.get("e.force:showToast");
				msg.setParams({
					"title" : "ERROR",
					"message" : response.getError()
				});
				msg.fire();
			}
		});
		$A.enqueueAction(action);
		*/
	},

	goToDetail : function(component, event, helper){
		/*
		var itemId = event.currentTarget.getAttribute("data-index");

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