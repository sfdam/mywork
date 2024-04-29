({

    doInit : function(component,event, helper) {
        helper.getData(component,event,helper);
    },

    tooltipOn : function(component, event, helper) {
        component.set("v.tooltip",true);
    },

    tooltipOff : function(component,event,helper) {
        component.set("v.tooltip", false);
    },

    tooltipOn1 : function(component, event, helper) {
        component.set("v.tooltip1",true);
    },

    tooltipOff1 : function(component,event,helper) {
        component.set("v.tooltip1", false);
    },

    tooltipOn2 : function(component, event, helper) {
        component.set("v.tooltip2",true);
    },

    tooltipOff2 : function(component,event,helper) {
        component.set("v.tooltip2", false);
    },

    tooltipOn3 : function(component, event, helper) {
        component.set("v.tooltip3",true);
    },

    tooltipOff3 : function(component,event,helper) {
        component.set("v.tooltip3", false);
    },

    tooltipOn4 : function(component, event, helper) {
        component.set("v.tooltip4",true);
    },

    tooltipOff4 : function(component,event,helper) {
        component.set("v.tooltip4", false);
    }
})