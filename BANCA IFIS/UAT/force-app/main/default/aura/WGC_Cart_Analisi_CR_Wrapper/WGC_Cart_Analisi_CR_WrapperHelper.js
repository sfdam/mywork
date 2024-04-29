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

    setupDebsDatatable : function(component) {
        let debsColumns = [
            {label: $A.get("$Label.c.WGC_Cart_CRDebsTable_Debitore"), fieldName: "debitore", type: "text"},
            {label: $A.get("$Label.c.WGC_Cart_CRDebsTable_DataUltimaRilevazione"), fieldName: "dataUltimaRilevazione", type: "date"},
            {label: $A.get("$Label.c.WGC_Cart_CRDebsTable_DataRichiestaPrimaInfo"), fieldName: "dataRichiesta", type: "date"}
        ];

        component.set("v.debsColumns", debsColumns);
    }
})