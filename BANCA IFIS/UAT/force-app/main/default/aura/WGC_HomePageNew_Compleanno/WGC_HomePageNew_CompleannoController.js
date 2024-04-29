({
    doInit : function(component, event, helper) {
		//Setting the Callback
        var action = component.get("c.countCompleanni");

        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('SV countCompleanni: ', result);

                component.set('v.numCompleanno', result);

            } else if (state == "ERROR") {
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
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
			window.open(url, '_self');
		}));
        // navService.navigate(pageReference);
    },
})