({
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
})