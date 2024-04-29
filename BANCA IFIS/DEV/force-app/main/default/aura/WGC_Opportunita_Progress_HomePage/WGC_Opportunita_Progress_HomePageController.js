({
    doInit : function(component, event, helper) {
        helper.initialize(component, event, helper);
    },

    collapse : function(component, event, helper){
        component.set("v.IsCollapsed", !component.get("v.IsCollapsed"));
    },

    redirectReport : function(component, event, helper){
        helper.redirectReport(component, event, helper);
    },

    redirectDettaglio : function(component, event, helper){
        helper.redirectDettaglio(component, event, helper);
    },
})