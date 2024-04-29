({
    doInit : function(component, event, helper) {
        setTimeout(function(){
            component.set("v.isLoading", false);
        }, 5000);
    },

    filter : function(component, event, helper){
        component.set("v.isLoading", true);
        setTimeout(function(){
            component.set("v.isLoading", false);
        }, 5000);
    },
})