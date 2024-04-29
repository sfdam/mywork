({
    doInit : function(component, event, helper) {
        helper.reloadProducts(component);
        // helper.reloadOptions(component);
    },

    reloadProducts : function(component, event, helper) {
        helper.reloadProducts(component);
    },

    confermaProdotti : function(component, event, helper) {
        // helper.navigateSubWizard(component, "inserimentoDebitori");
        helper.confermaProdotti(component, "inserimentoDebitori");
    }
})