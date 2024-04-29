({
	helperMethod : function() {
		
	},

	apex: function (component, event, apexAction, params) {
        var p = new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get("c." + apexAction + "");
            action.setParams(params);
            action.setCallback(this, function (callbackResult) {
                // if (callbackResult.getState() == 'SUCCESS') {
                //     resolve(callbackResult.getReturnValue());
                // }
                // if (callbackResult.getState() == 'ERROR') {
                //     reject(callbackResult.getError());
				// }
				resolve(callbackResult.getReturnValue());
            });
            $A.enqueueAction(action);
        }));
        return p;
	},
	
    showSpinner: function (cmp, event) {
		console.log('CAVVVVVV');
		var spinner = cmp.find("mySpinner");
		console.log('spinner', spinner);
        $A.util.removeClass(spinner, "slds-hide");

    },

    hideSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");

    },
})