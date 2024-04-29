({
    doInit : function(component, event, helper) {
        helper.setupOptions(component, event);
    },

    onFilterChange : function(component, event, helper) {
        helper.filter(component, event);
    },

    clickBtn : function(component, event, helper) {
        console.log(component.get("v.opportunity"));
        console.log(component.get("v.product"));
    },

    compareParams : function(component, event, helper) {
        helper.compareParams(component);
    }
})