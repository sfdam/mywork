({
    doInit: function(cmp, event, helper) {
      var opts = [
        {label: "Clienti", value: "clienti", selected: "true" },
        {label: "Prospect campagna", value: "prospect"},
        {label: "Magazzino", value: "magazzino" }
      ];
      cmp.find("sviluppi").set("v.options", opts);
      helper.getAccounts(cmp,'clienti');
    },
    changeSviluppo: function(cmp,event, helper) {
      var tipo = cmp.find("sviluppi").get("v.value");
      helper.getAccounts(cmp,tipo);
    },
    resetPriorita: function(cmp,event, helper) {
      var id = event.target.getAttribute("data-data");
      var tipo = cmp.find("sviluppi").get("v.value");
      helper.resetPriorita(cmp,id,tipo);

   },
    viewRecord : function(cmp, event, helper) {
         var navEvent = $A.get("e.force:navigateToSObject");
         var id = event.target.getAttribute("data-data");
         if(navEvent){
             navEvent.setParams({
                  recordId: id,
                  slideDevName: "detail"
             });
             navEvent.fire();
         }

    }
})