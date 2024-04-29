({
    doInit: function (component, event, helper) {
        helper.getUserEvent(component, event);
    },

    navigateToMyComponent: function (component, event, helper) {

        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": "Event",
                "actionName": "home"
            }
        }

        navService.navigate(pageReference);

        /*
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:Activity_DetailComponent",
            componentAttributes: {
 
            }
        });
        evt.fire();
        */
    },

    createActivity: function (component, event, helper) {

        $A.createComponent("c:WGC_AccountFlowGenericContainer", {
            accountId: component.get("v.recordId"),
            tipo: "taskOrEvent",
            flowName: "Crea_Contatto"
        },
            function (content, status) {
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        header: $A.get("$Label.c.WGC_Account_Header_Crea_Contatto_o_Visita"),
                        body: content,
                        showCloseButton: true,
                        cssClass: "mymodal slds-modal_medium",
                        closeCallback: function () { }
                    });
                }
            });
    },

    goToScadenziario: function (component, event, helper) {
        let tipo = event.getSource().get("v.value");
        var navService = component.find("navService");
        var pageReference = {    
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.idDashboard"),
                "objectApiName": "Dashboard",
                "actionName": "view"
            }
        };

		navService.navigate(pageReference);
    },
})