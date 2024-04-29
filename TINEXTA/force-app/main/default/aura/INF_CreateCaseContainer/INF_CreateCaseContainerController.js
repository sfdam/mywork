({
    myAction : function(component, event, helper) {

    },

    closeModal : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
})