({
    // navigateSubWizard : function(component, target) {
    //     var cmpEvent = component.getEvent("navigateSubWizard");
    //     cmpEvent.setParams({ "target" : target });
    //     cmpEvent.fire();
    // },
    
    confermaProdotti : function(component, target) {
        // var cmpEvent = component.getEvent("navigateSubWizard");
        // cmpEvent.setParams({ "target" : target });
        // cmpEvent.fire();
        var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({
            "method": "c.setProductInOpp",
            "params": {
                "opportunityId": component.get("v.opportunityId"),
                "itemsProduct" : JSON.stringify(component.get("v.items"))
            }
        });
        appEvent.fire();
    },

    reloadProducts : function(component) {
        component.set("v.selectedProductsIsEmpty", component.get("v.items").length == 0 ? true : false);
    },

})