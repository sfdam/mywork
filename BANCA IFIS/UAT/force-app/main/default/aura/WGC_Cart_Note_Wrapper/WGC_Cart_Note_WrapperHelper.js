({
    initData : function(component) {
        let noteAziendaVal = component.get("v.noteAzienda");
        let noteOpportunitaVal = component.get("v.noteOpportunita");
        let noteCondizioniVal = component.get("v.noteCondizioni");
        let noteConcorrenzaVal = component.get("v.noteConcorrenzaVal");
        
        component.set("v.noteAziendaVal", noteAziendaVal);
        component.set("v.noteOpportunitaVal", noteOpportunitaVal);
        component.set("v.noteCondizioniVal", noteCondizioniVal);
        component.set("v.noteConcorrenzaVal", noteConcorrenzaVal);
        
        component.set("v.noteAziendaCompleted", noteAziendaVal != null);
        component.set("v.noteOpportunitaCompleted", noteOpportunitaVal != null);
        component.set("v.noteCondizioniCompleted", noteCondizioniVal != null);
        component.set("v.noteConcorrenzaCompleted", noteConcorrenzaVal != null);
    },

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

    fireSave : function(component, field, value, objId) {
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        // appEvent.setParams({ "method": "c.updateNote", "params": { field: field , value: value , objectId: objId } });
        appEvent.setParams({ "method": "c.updateField", "params": { field: field , value: value , objectId: objId } });
        appEvent.fire();
    },

    reloadCompletionNoteAzienda : function(component, event) {
        component.set("v.noteAziendaCompleted", event.getParam("value").Account.WGC_Descrizione_dell_azienda__c != null);
    },

    reloadCompletionNoteOpportunita : function(component, event) {
        component.set("v.noteOpportunitaCompleted", event.getParam("value").WGC_Descrizione_Operativit_Proposta__c != null);
    },

    reloadCompletionNoteCondizioni : function(component, event) {
        component.set("v.noteCondizioniCompleted", event.getParam("value").WGC_Note_Condizioni_Economiche__c != null);
    },

    reloadCompletionNoteConcorrenza : function(component, event){
        component.set("v.noteConcorrenzaCompleted", event.getParam("value").WGC_Descrizione_concorrenza__c != null);
    },

    autosizeTA : function(component, event) {
        // console.log("textarea: ", $('textarea'));
        console.log("note: ", jQuery("#extensible-textarea"));
        autosize(jQuery("#extensible-textarea"));
        // if (event) {
        //     // let target = event.target;
        //     // if (target.value.length > 300) {
        //     //     target.value.length % 150
        //     // }
        //     autosize(event.getSource());
        // }
        // let provaRes = component.find("provaResize");
        // autosize(provaRes);
    }
})