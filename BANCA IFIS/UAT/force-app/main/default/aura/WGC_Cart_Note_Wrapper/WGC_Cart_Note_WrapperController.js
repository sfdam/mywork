({
    doInit : function(component, event, helper) {
        helper.initData(component);
        helper.configureSelectedProducts(component);
    },

    afterRender : function(component, event, helper) {
        autosize(document.querySelectorAll('textarea'));
        // helper.initData(component);
        // component.set("v.noteAziendaVal", component.get("v.noteAzienda"));
    },

    collapseNoteAzienda : function(component, event, helper) {
        component.set("v.noteAziendaOpen", !component.get("v.noteAziendaOpen"));
        // component.set("v.noteAziendaVal", component.get("v.noteAzienda"));
    },

    collapseNoteOpportunita : function(component, event, helper) {
        component.set("v.noteOpportunitaOpen", !component.get("v.noteOpportunitaOpen"));
    },

    collapseNoteCondizioni : function(component, event, helper) {
        component.set("v.noteCondizioniOpen", !component.get("v.noteCondizioniOpen"));
    },

    collapseNoteAutomatiche : function(component, event, helper) {
        component.set("v.noteAutomaticheOpen", !component.get("v.noteAutomaticheOpen"));
    },

    collapseNoteConcorrenza : function(component, event, helper){
        component.set("v.noteConcorrenzaOpen", !component.get("v.noteConcorrenzaOpen"));
    },

    collapseNoteAutomaticheEstero : function(component, event, helper){
        component.set("v.noteAutomaticheEsteroOpen", !component.get("v.noteAutomaticheEsteroOpen"));
    },

    confermaNoteAzienda : function(component, event, helper) {
        let noteAzienda = jQuery("textarea[name='noteAzienda']").val();
        helper.fireSave(component, "WGC_Descrizione_dell_azienda__c", noteAzienda, component.get("v.accountId"));
    },

    confermaNoteOpportunita : function(component, event, helper) {
        let noteOpportunita = jQuery("textarea[name='noteOpportunita']").val();
        helper.fireSave(component, "WGC_Descrizione_Operativit_Proposta__c", noteOpportunita, component.get("v.opportunityId"));
    },

    //SM - TEN: Aggiunta note
    confermaNoteConcorrenza : function(component, event, helper){
        let noteConcorrenza = jQuery("textarea[name='noteConcorrenza']").val();
        helper.fireSave(component, "WGC_Descrizione_concorrenza__c", noteConcorrenza, component.get("v.opportunityId"));
    },

    confermaNoteCondizioni : function(component, event, helper) {
        let noteCondizioni = jQuery("textarea[name='noteCondizioni']").val();
        helper.fireSave(component, "WGC_Note_Condizioni_Economiche__c", noteCondizioni, component.get("v.opportunityId"));
    },

    reloadCompletion : function(component, event, helper) {
        helper.reloadCompletionNoteAzienda(component, event);
        helper.reloadCompletionNoteOpportunita(component, event);
        helper.reloadCompletionNoteCondizioni(component, event);
        helper.reloadCompletionNoteConcorrenza(component, event);
    },
    
})