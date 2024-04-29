({
    configureSelectedProducts : function(component) {
        let selectedProducts = component.get("v.selectedProducts");
        let items = JSON.parse(JSON.stringify(selectedProducts));
        items.forEach(i => {
            i.isClickable = false;
            i.isSelected = true;
            i.isActive = false;
            i.isRemovable = false;
            i.title = i.nome;
            i.subtitle = this.getLineSubtitle(component, i);
            i.icon = i.icona;
        });

        //SM - TEN: Aggiunta condizione per non mostrare linee tecniche corporate
        items = items.filter(l => { return l.codice != 'FIDOSBF' && l.codice != 'ContoAnticipiPTF' && l.codice != 'FidoAnticipoFatture' });
        component.set("v.items", items);
    },

    updatePresaVisione : function(component, field) {
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method": "c.updatePresaVisione", "params": {
            opportunityId: component.get("v.opportunityId"),
            field: field
        }});
        appEvent.fire();
    },

    setupFactFiscInfo : function(component) {
        let opportunity = component.get("v.opportunity");
        let ristruttDebitoOptions = component.get("v.picklistOptions").find(function (po) { return po.field == "Opportunity.WGC_Tipologia_di_ristrutturazione_debito__c"; }).options;

        component.set("v.litiPendenti", (opportunity.WGC_Liti_pendenti__c != null ? opportunity.WGC_Liti_pendenti__c.toString() : "false"));
        component.set("v.litiPendentiDesc", (opportunity.WGC_Descrizione_liti_pendenti__c != null ? opportunity.WGC_Descrizione_liti_pendenti__c : ""));
        component.set("v.ristruttDebito", (opportunity.WGC_Ristrutturazione_del_debito__c != null ? opportunity.WGC_Ristrutturazione_del_debito__c.toString() : "false"));
        component.set("v.ristruttDebitoDesc", (opportunity.WGC_Tipologia_di_ristrutturazione_debito__c != null ? opportunity.WGC_Tipologia_di_ristrutturazione_debito__c : ""));
        component.set("v.ristruttDebitoOptions", ristruttDebitoOptions);
    },

    save : function(component) {
        let opportunity = JSON.parse(JSON.stringify(component.get("v.opportunity")));
        let litiPendenti = component.get("v.litiPendenti");
        let litiPendentiDesc = component.get("v.litiPendentiDesc");
        let ristruttDebito = component.get("v.ristruttDebito");
        let ristruttDebitoDesc = component.get("v.ristruttDebitoDesc");
        
        if ( (litiPendenti == "false" || !this.isBlank(litiPendentiDesc)) && (ristruttDebito == "false" || !this.isBlank(ristruttDebitoDesc)) ) {
            opportunity.WGC_Liti_pendenti__c = litiPendenti == "true";
            opportunity.WGC_Descrizione_liti_pendenti__c = litiPendentiDesc;
            opportunity.WGC_Ristrutturazione_del_debito__c = ristruttDebito == "true";
            opportunity.WGC_Tipologia_di_ristrutturazione_debito__c = ristruttDebitoDesc;

            let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
            appEvent.setParams({ "method" : "c.saveEventiNegativiInfo" , "params" : {
                    opportunity: opportunity
                }
            });
            appEvent.fire();
        } else {
            this.showToast(component, "Errore", "Completa i campi obbligatori per salvare.", "error");
        }
    }
})