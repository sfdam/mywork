({
    onToggleBtn : function(component, event, helper) {
        let servizio = component.get("v.servizio");
        let readOnly = component.get("v.readOnly");

        if (servizio.disabled === false && readOnly === false) {
            let cmpEvent = component.getEvent("toggleService");
            cmpEvent.setParams({
                "debitore" : component.get("v.debitore"),
                "servizio" : servizio.serv,
                "action": ( servizio.selected ? "remove" : "add" )
            });
            cmpEvent.fire();
        }
    }
})