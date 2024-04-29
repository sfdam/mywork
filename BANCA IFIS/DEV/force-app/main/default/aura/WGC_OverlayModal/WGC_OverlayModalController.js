({
    doInit : function(component, event, helper) {
        //SE BO Ad Account, altrimenti carrello
        var action = component.get("c.getUserProfile");
        action.setCallback(this, response => {
            console.log('@@@ response ' , response);

            $A.createComponent("c:WGC_AccountFlowGenericContainer", {
                accountId: component.get("v.recordId"),
                flowName : component.get("v.flowName")
            },
            function(content, status) {
                    if (status === "SUCCESS") {
                        component.find('overlayLib').showCustomModal({
                            body: content,
                            showCloseButton: true,
                            cssClass: "mymodal slds-modal_medium",
                            closeCallback: function() {
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": response == 'IFIS - B/O Valutazione Fast Finance' ? component.get("v.recordId") : component.get("v.parentRecordId"),
                                    "slideDevName": "related"
                                });
                                navEvt.fire();
                            }
                        });
                    }
                } 
            );
        });
        $A.enqueueAction(action);
    }
})