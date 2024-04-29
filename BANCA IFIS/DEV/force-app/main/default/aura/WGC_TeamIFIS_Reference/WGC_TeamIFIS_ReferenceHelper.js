({
	getUserReferent : function(component, event) {
        var action = component.get("c.getUserReferenceFromAccount");
        action.setParams({
            "accId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();
            var result = response.getReturnValue();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                
                console.log('@@@ utente ' , result);
                component.set('v.personalReferences', result);
                
            } else if(state == "ERROR"){
                console.log("ERROR");
                console.log(result);
                //alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
    
    apex: function (component, event, apexAction, params) {
        var p = new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get("c." + apexAction + "");
            action.setParams(params);
            action.setCallback(this, function (callbackResult) {
                if (callbackResult.getState() == 'SUCCESS') {
                    resolve(callbackResult.getReturnValue());
                }
                if (callbackResult.getState() == 'ERROR') {
                    console.log('ERROR', callbackResult.getError());
                    reject(callbackResult.getError());
                }
            });
            $A.enqueueAction(action);
        }));
        return p;
    },

    setUserIsSpecialista : function(component) {
        let accId = component.get("v.recordId");

		this.apex(component, event, "userIsSpecialista", { accId: accId })
		.then($A.getCallback(function (result) {
			component.set("v.userIsSpecialista", result);
		})).finally($A.getCallback(function () {
			// DO NOTHING
		}));
    },
})