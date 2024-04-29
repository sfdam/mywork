({
  getAccounts: function(component,tipo) {
    var action = component.get("c.getAccountList")
    action.setParams({"tipo": tipo});

    action.setCallback(this, function(result) {
      component.set("v.accounts", result.getReturnValue());
    });
    $A.enqueueAction(action)
  },
  resetPriorita: function(component,id,tipo) {

    var action = component.get("c.resetPrioritaAccount")
    action.setParams({"accountId": id, "tipo": tipo });

    action.setCallback(this, function(result) {
      // aggiorno
      this.getAccounts(component,tipo);
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        "title": "Priorità resettata",
        "message": "La priorità dell'account "+result.getReturnValue().Name+" è stata settata a 10",
        "type": "success"
      });
      toastEvent.fire();
    });
    $A.enqueueAction(action)
  },
})