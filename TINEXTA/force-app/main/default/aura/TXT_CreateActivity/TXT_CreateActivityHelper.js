({
	helperMethod : function() {
		
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

	fetchPickListVal: function (component, fieldName, object, elementId) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": object,
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log("allValues: ",allValues);

                for (var k in allValues) {
                    opts.push({
                        class: "optionClass",
                        label: k,
                        value: allValues[k],
                        selected: false
                    });
				}
				
                component.set("v." + elementId, opts);
            }
        });
        $A.enqueueAction(action);
	},
	
	getDate : function (component, event, elementId){
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = dd + '/' + mm + '/' + yyyy; 
		component.set("v." + elementId, today);
    }
})