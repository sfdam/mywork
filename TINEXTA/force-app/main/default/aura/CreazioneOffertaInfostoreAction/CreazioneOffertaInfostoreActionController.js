({
  doInit: function (component, event, helper) {
    var action=component.get("c.CreazioneOffertaInfostore");
    action.setParams({
        recordId: component.get("v.recordId")
    });
    action.setCallback(this, response => {
        if(response.getState() === "SUCCESS"){
            console.log('@@@ response ' , response.getReturnValue());
            component.set("v.success", response.getReturnValue() == 'OK');
            if(response.getReturnValue() != 'OK'){
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    title: "ERRORE!",
                    message: "Errore dell'invio dell'offerta ad infostore",
                    type: "error"
                });
                toast.fire();
                console.log('@@@ errore');

                component.set("v.responseStr", 'Errore nella creazione, riprovare! ' + response.getReturnValue());
            } else {
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    title: "SUCCESSO!",
                    message: "Invio offerta andato a buon fine!",
                    type: "success"
                });
                toast.fire();
                component.set("v.responseStr", "Invio offerta andato a buon fine!");
            }

            $A.get('e.force:refreshView').fire();

        } else {
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                title: "ERRORE!",
                message: "Errore dell'invio dell'offerta ad infostore",
                variant: "error"
            });
            toast.fire();
            console.log('@@@ errore');
            component.set("v.responseStr", 'Errore nella creazione, riprovare!');
        }

        $A.util.toggleClass(component.find("loader"), 'slds-hide');
        $A.util.toggleClass(component.find("loader2"), 'slds-hide');
        $A.util.toggleClass(component.find("response"), 'slds-hide');
    });
    $A.enqueueAction(action);
  },

  close : function(component, event, helper){
    $A.get("e.force:closeQuickAction").fire();
  },
});