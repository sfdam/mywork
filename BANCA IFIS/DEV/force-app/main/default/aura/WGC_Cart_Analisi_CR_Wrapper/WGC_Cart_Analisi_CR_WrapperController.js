({
    doInit : function(component, event, helper) {
        let readOnly = component.get("v.readOnly");
        
        if (!readOnly) helper.updatePresaVisione(component, "WGC_Presa_Visione_CR__c");
        helper.configureSelectedProducts(component);
        helper.setupDebsDatatable(component);
    }
})