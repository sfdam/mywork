({
    doInit : function(component, event, helper) {
        // component.set("v.readOnly", true);
        // component.set("v.valuecmp" , component.get("v.value"));
    },

    back : function(component, event, helper){
        helper.back(component, event, helper);
    },

    confirm : function(component, event, helper) {
        helper.confirm(component, event, helper);
    },
})