({
    init : function(component, event, helper) {
        helper.getCedacriSleepTime(component, event);
        helper.retrievePageLayout(component, event, helper);
    },

    handleSubmit : function(component, event, helper) {
        helper.manageSubmit(component, event);
    },

    handleSuccess : function(component, event, helper) {
        helper.success(component);
    },
    // VS - 07/11/2022 - GIANOS_MAV_Specifiche_tecniche v_2 - Nuovi controlli su dettaglio referente - INIZIO
	handleOnLoad : function(component, event, helper) {
        helper.onLoad(component,event);
    },

    onchangeValue: function(component, event, helper) {
        helper.onchangeValue(component,event);
    },
    // VS - 07/11/2022 - GIANOS_MAV_Specifiche_tecniche v_2 - Nuovi controlli su dettaglio referente - FINE

    close : function(component, event, helper) {
        let B2F = $A.get("e.c:PageLayoutRecordDisplayEvent");
        B2F.setParams({ json: JSON.stringify({ action: "cancel" }) });
        B2F.fire();
    },

    closeCedacriError: function (component, event) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        var cmpTarget = component.find('errors-container-Cedacri');
        $A.util.addClass(cmpTarget, 'transit');
        component.set("v.CedacriSleepError", null);
    },

    closeError: function (component, event) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        var cmpTarget = component.find('errors-container');
        $A.util.addClass(cmpTarget, 'transit');
        component.set("v.errors", null);
    },

    
})