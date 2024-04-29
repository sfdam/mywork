({
    doInit : function(component, event, helper) {
        helper.reloadAvailableProducts(component, event);
    },

    reloadProducts : function(component, event, helper) {
        helper.reloadAvailableProducts(component, event);
    },

    handleProductClick : function(component, event, helper) {
        var action = event.getParam("action");
        var item = event.getParam("item");
        switch (action) {
            case 'click':
                if (item.fakeProduct === undefined)
                    helper.selectProduct(component, event);
                break;
            case 'remove':
                helper.deselectProduct(component, event);
                break;
        }
        helper.reloadAvailableProducts(component, event);
    },

    confermaProdotti : function(component, event, helper) {
        helper.navigateSubWizard(component, "inserimentoDebitori");
    }
})