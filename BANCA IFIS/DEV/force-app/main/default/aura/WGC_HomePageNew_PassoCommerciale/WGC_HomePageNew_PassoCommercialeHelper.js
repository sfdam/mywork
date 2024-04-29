({
    apexPromise : function(component, methodName) {
        return new Promise($A.getCallback(function(resolve, reject) {
            var action = component.get(methodName);
            action.setCallback(self, function(res) {
                var state = res.getState();
                if(state === 'SUCCESS') {
                    resolve(res.getReturnValue());
                } else if(state === 'ERROR') {
                    reject(action.getError())
                }
            });
            $A.enqueueAction(action);
        }));    
    }
})