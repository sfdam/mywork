({
    doInit : function(component, event, helper) {
        helper.setupDebitore(component);
        helper.validateQEC(component);
        //SM-CART-REVI
        helper.setReadOnlyRev(component);
        helper.retrieveAtecoStatus(component);        
    },

    saveQECDebitore : function(component, event, helper) {
        helper.saveQECDebitore(component);
    },

    onChangeNotMat : function(component, event, helper) {
        helper.manageNotificationAndMaturity(component, event);
        helper.validateQEC(component);
    },

    recalculatePlafond : function(component, event, helper) {
        helper.recalculatePlafond(component, event);
        helper.validateQEC(component);
    },

    validateQEC : function(component, event, helper) {
        helper.validateQEC(component);
    },

    // onChangeMomento : function(component, event, helper) {
    //     helper.onChangeMomento(component, event);
    // },

    // onToggleProceduraSemplificata : function(component, event, helper) {
    //     helper.onChangeProceduraSemplificata(component, event);
    // },

    // onChangeLIR : function(component, event, helper) {
    //     helper.onChangeLIR(component, event);
    // },

    onChangeATD : function(component, event, helper) {
        let fieldName = event.getSource().get("v.name");

        switch (fieldName) {
            case "proceduraSemplificata":
                helper.onChangeProceduraSemplificata(component, event);
                break;
            case "operazioneIAS":
                helper.onChangeIAS(component, event);
                break;
            case "previstaLIR":
                helper.onChangeLIR(component, event);
                break;
            case "momento":
                helper.onChangeMomento(component, event);
                break;
            case "anticipazione":
                helper.onChangeAnticipazione(component, event);
                break;
            case "prosolutoATD":
                helper.onChangeProsoluto(component, event);
                break;
        }

        helper.validateQEC(component);
    },
})