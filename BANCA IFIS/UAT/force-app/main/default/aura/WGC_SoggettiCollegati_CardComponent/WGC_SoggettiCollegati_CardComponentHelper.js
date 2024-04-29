({
	getSogettiCollegati : function(accountId, component, event) {
		var tipo = component.get("v.type");
		//Setting the Callback
        var action = component.get("c.getSogettiCollegati");
        action.setParams({ 
			"accountId" : accountId,     
			"type" : tipo
        });

        //Setting the Callback
        action.setCallback(this,function(response){
            //get the response state
            var state = response.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                console.log('result sog: ',result);
                component.set('v.numVal', result.data);
                if(result.data <= 0){
                    component.set('v.disabledButton', true);
                }
                this.hideSpinner(component);
                
            } else if(state == "ERROR"){
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
                this.hideSpinner(component);
            }
        });
		$A.enqueueAction(action);
    },
    
    showSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
		$A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})