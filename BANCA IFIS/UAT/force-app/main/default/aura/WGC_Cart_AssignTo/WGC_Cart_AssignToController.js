({
    onConfermaClick : function(component, event, helper) {
        helper.changeOwner(component);
    },

    onChangeOwner : function(component, event, helper) {
        helper.refreshCustomLookup(component, event);
    }
})