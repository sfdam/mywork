({
    doInit : function(component, event, helper) {
		var recordId = component.get("v.Id");
        console.log('recordId ', recordId);
        var accountId = component.get("v.AccountId");
        console.log('accountId ', accountId);
        var action = component.get("c.updateFlagDoppiPresidi");
        action.setParams({"recordId":recordId, "accountId": accountId});      
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
    			console.log('@@@ sv response ', response);
                if(response.getReturnValue()) {
                    console.log('@@@ success');
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({"title": "Successo", "message":"Doppio Presidio eliminato","type":"SUCCESS"});
                    msg.fire();
                }
             }
             else if(response.getState()==="ERROR" && response.getError()[0].message==='Non è possibile eliminare un Doppio Presidio creato automaticamente'){
                var msg = $A.get("e.force:showToast");
                msg.setParams({"title": "Errore", "message": response.getError()[0].message,"type":"ERROR"});
                msg.fire();
                }
             else {
                    console.log('@@@ error');
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({"title": "Errore", "message":"Non è stato possibile eliminare il Doppio Presidio","type":"ERROR"});
                    msg.fire();
                }
             
            
        });
        $A.enqueueAction(action);
        var navigator = component.find("navService");
            var pg = {
                type: "standard__recordPage",
                attributes: {
                    recordId: accountId,
                    objectApiName: "Account",
                    actionName: "view"
                }
            }
            navigator.navigate(pg); 
	}
})