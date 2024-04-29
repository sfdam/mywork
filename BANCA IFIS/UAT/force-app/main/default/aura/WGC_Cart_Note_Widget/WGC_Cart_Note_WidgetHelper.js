({
    setupData : function(component) {
        component.set("v.textarea", component.get("v.text"));
    },

    saveText : function(component) {
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.upsertNote" , "params" : {
                field_apiname: component.get("v.field"),
                value: component.get("v.textarea"),
                opportunityId: component.get("v.opportunityId")
            }
        });
        appEvent.fire();
    }
})