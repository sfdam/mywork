({
    doInit : function(component, event, helper) {
        //let sObj = component.get("v.sObjectName");
        
        
        helper.ottieniDati(component, event);
    },

    handleClone: function(component, event, helper){
        helper.clonaQuote(component,event)
    },


})