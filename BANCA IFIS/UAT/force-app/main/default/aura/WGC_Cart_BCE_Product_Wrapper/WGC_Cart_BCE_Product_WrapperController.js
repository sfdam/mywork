({
    doInit : function(component, event, helper) {
        helper.setupData(component, event, helper);
    },

    //Metodo per intercettare il cambio dei dati nei campi
    onChangeData : function(component, event, helper){
        helper.fireChangeEvent(component, event, helper);
        helper.reloadData(component, event, helper);
    },

})