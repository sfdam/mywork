({
    doInit : function(component, event, helper) {
        helper.setupData(component);
    },

    conferma : function(component, event, helper) {
        helper.saveJoin(component);
    }
})