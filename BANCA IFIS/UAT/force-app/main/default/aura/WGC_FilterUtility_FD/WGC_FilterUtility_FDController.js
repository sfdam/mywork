({
    doInit : function(component, event, helper) {
        helper.initialize(component, event, helper);
    },

    changePG : function(component, event, helper){
        helper.getPageRef(component, event, helper);
    },

    changeFilter : function(component, event, helper){
        var value = event.getSource().get("v.value");
        console.log('@@@ value changed ' , value);
        component.set("v.selectedValue", value);
    },

    applyFilter : function(component, event, helper){
        helper.applyFilter(component, event, helper);
    },
})