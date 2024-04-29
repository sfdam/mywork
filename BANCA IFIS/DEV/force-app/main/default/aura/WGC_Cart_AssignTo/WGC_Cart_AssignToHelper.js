({
    changeOwner : function(component) {
        let owner = component.get("v.owner");
        let opportunityId = component.get("v.opportunityId");

        if (!this.isEmpty(owner)) {
            let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
            appEvent.setParams({ "method" : "c.changeOwner" , "params" : {
                    opportunityId: opportunityId,
                    owner: owner
                }
            });
            appEvent.fire();
        } else {
            component.set("v.hasError", true);
        }
    },

    refreshCustomLookup : function(component, event) {
        component.set("v.hasError", this.isEmpty(event.getParam("value")));
    },

    isEmpty : function(obj) {
        
        for(var key in obj) {
            if(obj.hasOwnProperty(key))
                return false;
        }
        return true;

    }
})