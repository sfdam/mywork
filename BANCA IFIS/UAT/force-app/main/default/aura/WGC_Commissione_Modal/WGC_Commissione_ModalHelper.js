({
    back : function(component, event, helper){
        component.set("v.action", "annulla");

        var evt = $A.get("e.c:WGC_GenericEvent");
        evt.setParam("json", { action: component.get("v.action") });
        evt.fire();

        component.find('overlayLib').notifyClose();
    },

    confirm : function(component, event, helper) {
        component.set("v.action", "salva");
        var evt = $A.get("e.c:WGC_GenericEvent");
        evt.setParam("json", { value: component.get("v.value"), action: component.get("v.action") });
        evt.fire();
        component.find('overlayLib').notifyClose();
    },
})