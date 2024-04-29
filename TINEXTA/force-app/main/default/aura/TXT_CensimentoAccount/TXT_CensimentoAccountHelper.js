({
    doInit : function(component, event, helper) {
        var action = component.get("c.isOverrideActionAccount");
        action.setCallback(this, response => {
            if(response.getState() === 'SUCCESS'){

                var navigation = component.find("navService");

                var pageReferenceNoOverride = {    
                    type: "standard__objectPage",
                    attributes: {
                        objectApiName: "Account",
                        actionName: "new"
                    },
                    state: {
                        nooverride: 1
                    }
                }

                console.log('@@@ isOverride ' , response.getReturnValue());
                // Se true allora vado in override, se false uso standard
                if(response.getReturnValue()){
                    // Uso l'evento in quanto gli LWC non sono supportarti dal navigation
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:txtCensimentoAccount"
                    });
                    evt.fire();
                } else {
                    var pageRef = {
                        type: "standard__objectPage",
                        attributes: {
                            objectApiName: "Account",
                            actionName: "home"
                        }
                    }
        
                    navigation.navigate(pageRef);

                    // Ritardo il counter per non incappare nella ricorsività
                    window.setTimeout(
                        $A.getCallback(function() {
                            navigation.navigate(pageReferenceNoOverride);
                        }), 500
                    );
                }

                // Chiudo la QuickAction
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();

            } else if(response.getState() === 'ERROR') {
                console.log('@@@ getError ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})