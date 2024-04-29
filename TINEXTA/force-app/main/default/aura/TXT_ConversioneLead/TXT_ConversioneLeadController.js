({
    navigateToConversioneLead : function(component, event, helper) {

        var action = component.get("c.isCommunity");
        action.setCallback(this, response => {
            if(response.getState() === 'SUCCESS'){
                console.log('@@@ response ' , response.getReturnValue());
                var isComm = response.getReturnValue();
                component.set("v.isCommunity", isComm);
                if(!isComm){
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        // componentDef : "c:txtConversioneLead",
                        // componentAttributes: { recordId : component.get("v.recordId") }

                        // SM - Aggiunto un componente aura per gestire la chiusura dei tab nelle app console
                        componentDef : "c:txtConversioneLeadContainer",
                        componentAttributes: { recordId : component.get("v.recordId") }
                    });
                    evt.fire();
                }
            } else {
                console.log('@@@ errore community ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },

})