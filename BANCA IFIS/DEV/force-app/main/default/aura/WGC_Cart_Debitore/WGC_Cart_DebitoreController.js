({
    doInit : function(component, event, helper) {
        helper.setupServiziAttore(component);
    },

    editDebData : function(component, event, helper) {
        // var modalBody;
        helper.openDebEditModal(component);
    },

    onRemoveDebitore : function(component, event, helper) {
        // var appEvent = $A.get("e.c:WGC_ModalManagerEvent");
        // appEvent.setParams({
        //     modalHeader: component.get("v.debitore").rsociale,
        //     modalBody: {
        //         type: "text",
        //         value: "Sei sicuro di voler eliminare questo debitore?",
        //         params: null
        //     },
        //     modalFooter: {
        //         type: "component",
        //         value: "lightning:button",
        //         params: {
        //             label: "Conferma",
        //             onclick: component.get("c.confirmRemoveDebitore"),
        //             variant: "destructive"
        //         }
        //     },
        //     showCloseButton: true,
        //     cssClass: ""
        // });
        // appEvent.fire();

        // $A.createComponent("lightning:button", {
        //     label: "Conferma",
        //     onclick: component.getReference("c.confirmRemoveDebitore"),
        //     variant: "destructive"
        // },
        // function(content, status) {
        //     if (status === "SUCCESS") {
        //         component.find('overlayLib2').showCustomModal({
        //             header: component.get("v.debitore").rsociale,
        //             body: "Sei sicuro di voler eliminare questo debitore?",
        //             footer: content,
        //             showCloseButton: true,
        //             cssClass: ""
        //         });
        //     }
        // });

        $A.createComponent("c:WGC_CartRemoveDebitore_Footer", {
            debitore: component.get("v.debitore")
        },
        function(content, status) {
            if (status === "SUCCESS") {
                component.find('overlayLib2').showCustomModal({
                    header: component.get("v.debitore").rsociale,
                    body: "Sei sicuro di voler eliminare questo debitore?",
                    footer: content,
                    showCloseButton: true,
                    cssClass: ""
                });
            }
        });
    },

    confirmRemoveDebitore : function(component, event, helper) {
        console.log("overlay: ", component.find('overlayLib2').notifyClose());
        component.find('overlayLib2').notifyClose();
        // helper.fireCloseModal(component);
        // helper.fireRemoveDebitore(component);
    },

    reloadDebitore : function(component, event, helper) {
        helper.setupServiziAttore(component);
    }

})