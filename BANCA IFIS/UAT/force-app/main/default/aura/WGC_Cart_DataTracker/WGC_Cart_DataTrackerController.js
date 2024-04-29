({
    doInit : function(component, event, helper) {
        helper.initDataTable(component);
        helper.initDTWizardOptions(component);
        helper.loadDati(component);
    },

    reloadDati : function(component, event, helper) {
        // console.log("reloadDati");
        helper.loadDati(component);
        helper.loadDTWizardItems(component);
    },

    getPEF38 : function(component, event, helper) {
        helper.getPEF38(component, event);
    },

    onDeleteLine : function(component, event, helper) {
        let linee = component.get("v.linee");
        let lines = component.get("v.elencoLinee");
        let numLineaCredito = event.getSource().get("v.name");
        
        let appEvent = $A.get("e.c:WGC_ModalManagerEvent");
        appEvent.setParams({
            modalHeader: "Chiudi Linea - " + lines.find(l => {return l.numLineaCredito == numLineaCredito;}).desLineaSistema,
            modalBody: {
                type: "component",
                value: "c:WGC_Cart_CloseLine",
                params: {
                    numLineaCredito: numLineaCredito.toString(),
                    opportunityId: component.get("v.opportunity").Id,
                    statusPEF: lines.find(l => {return l.numLineaCredito == numLineaCredito;}).desStatoLinea,
                    faseLinea: lines.find(l => {return l.numLineaCredito == numLineaCredito;}).wizardItems.find(wi => {return wi.active == true;}).phase,
                    lineId: linee.find(ll => {return lines.find(l => {return l.numLineaCredito == numLineaCredito;}).codLineaSistema == ll.Prodotto__r.Codice__c}).Id,
                }
            },
            modalFooter: null,
            showCloseButton: true,
            cssClass: "",
            preFunction: ""
        });
        appEvent.fire();
    }
})