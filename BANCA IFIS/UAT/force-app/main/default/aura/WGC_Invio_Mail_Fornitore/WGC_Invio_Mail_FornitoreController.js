({
	doInit : function(component, event, helper) {
		var accountId = component.get("v.accountId");
        console.log('accountId ', accountId);
        console.log('recordId: ', component.get("v.recordId"));
        var idPgAccount = component.get("v.recordId");
        console.log('idPgAccount ', idPgAccount);
        var action = component.get("c.updateFlagAccount");
        action.setParams({"accountId":accountId, "recordId":idPgAccount});      
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
    			console.log('@@@ sv response ', response);
                if(response.getReturnValue() == 'KO') {
                    console.log('@@@ errore');
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({"title": "Errore", "message":"Impossibile inviare email","type":"ERROR"});
                    msg.fire();
                } else if(response.getReturnValue() == 'KO Task Aperti') {
                    console.log('@@@ errore task aperti');
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({"title": "Errore", "message":"Esitare i task precedenti associati a questa anagrafica","type":"ERROR"});
                    msg.fire();
                }
             }
            var navigator = component.find("navService");
            var pg = {
                type: "standard__recordPage",
                attributes: {
                    recordId: idPgAccount,
                    objectApiName: "Account",
                    actionName: "view"
                }
            }
            navigator.navigate(pg);
        });
        $A.enqueueAction(action); 
	}
})