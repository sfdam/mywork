({
    initialize : function(component, event, helper) {
        var action = component.get("c.getOpportunityCountByStatus");
		action.setCallback(this, response =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				if(risposta.success){
					component.set("v.counter", risposta.data[0]);
				}
			}
			else{
				console.log('@@@ errore ' , response.getError());
			}
		});
		$A.enqueueAction(action);
    },

    redirectReport : function(component, event, helper){
		var reportId = event.currentTarget.dataset.report;
		var navService = component.find("navService");
        var pageReference = {    
			"type": "standard__recordPage",
			"attributes": {
				"recordId": reportId,
				"objectApiName": "Report",
				"actionName": "view"
			}
	 	}

		navService.generateUrl(pageReference).then($A.getCallback(function(url) {
			window.open(url, '_blank');
		}));
        // navService.navigate(pageReference);
    },

    redirectDettaglio : function(component, event, helper){
        var navService = component.find("navService");
        var pageReference = {  
            "type": "standard__navItemPage",
            "attributes": {
                "apiName": "Opportunit"    
            }
        }
        navService.navigate(pageReference);
    },
})