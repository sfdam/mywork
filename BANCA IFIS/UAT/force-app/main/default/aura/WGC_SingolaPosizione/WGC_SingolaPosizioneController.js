({
	doInit : function(component, event, helper) {
		var action = component.get("c.getP");
		action.setParams({
			accountId : component.get("v.recordId")
		});
		action.setCallback(this, response =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				component.set("v.recordList" , risposta.data[0].factoringCedente);
			}
			else{
				console.log('@@@ errore ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	},

	goToDetail : function(component, event, helper){
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
	},
})