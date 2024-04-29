({
    doInit : function(component, event, helper) {
        let readOnly = component.get("v.readOnly");
        
        if (!readOnly) helper.updatePresaVisione(component, "WGC_Presa_Visione_Eventi__c");
        helper.configureSelectedProducts(component);
        helper.setupFactFiscInfo(component);
    },

    save : function(component, event, helper) {
        helper.save(component);
    }
})