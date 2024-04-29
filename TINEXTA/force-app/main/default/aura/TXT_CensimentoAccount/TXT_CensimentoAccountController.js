({
    navigateToCensimentoAccount : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },

    handlePageChange : function(component, event, helper) {
        console.log('@@@ pageReference ' , JSON.stringify(component.get("v.pageReference")));

        //TODO: Trova un modo per fare un check migliore per quando si blocca l'override
        // if(window.location.href.includes('lightning/o/Account/new?inContextOfRef=')){
        if(window.location.href.includes('inContextOfRef=')){
            helper.doInit(component, event, helper);
        }
    },
})