({
	fireEvent: function (response, eventApplication) {
        var B2FtoUse = "e.c:" + eventApplication;
        var B2F = $A.get(B2FtoUse);
        B2F.setParams({ "json": response });
        B2F.fire();
    },
                                                                                                                                                                                                                           
    resolveAction: function (action, data, eventApplication) {
        this.fireEvent(JSON.stringify({ "action": action, "response": data }), eventApplication);
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
})