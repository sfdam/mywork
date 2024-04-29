({
    doInit : function(component, event, helper) {
		var recordId = component.get("v.Id");
        console.log('recordId ', recordId);
        var accountId = component.get("v.CampaignId");
        console.log('accountId ', accountId);
        var action = component.get("c.setRollback");
        action.setParams({"recordIdCM":recordId}); 
        var reload = false;     
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('stato: '+state);
            if (state === "SUCCESS") {
    			console.log('@@@ response ', response);
                if(response.getReturnValue()) {
                    console.log('@@@ success OK');
                    //$A.get('e.force:refreshView').fire();
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({"title": "Successo", "message":"Cliente ripristinato","type":"SUCCESS"});
                    msg.fire();
                    
                    

                    console.log('redirect');
                    
                }
             }
            else if(response.getState()==="ERROR" && response.getError()[0].message==='Non è stato possibile ripristinare il cliente in campagna'){
                var msg = $A.get("e.force:showToast");
                msg.setParams({"title": "Errore", "message": response.getError()[0].message,"type":"ERROR"});
                msg.fire();
                }
            else if(response.getState()==="ERROR" && response.getError()[0].message==='Non è possibile ripristinare il cliente in campagna - Campagna non più affinabile'){
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({"title": "Errore", "message": response.getError()[0].message,"type":"ERROR"});
                    msg.fire();
                    }
            else {
                    console.log('@@@ error');
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({"title": "Errore", "message":"Non è stato possibile ripristinare il cliente in campagna","type":"ERROR"});
                    msg.fire();
                }
             
            
        });
        $A.enqueueAction(action);
        
        /*if(reload){
            console.log('reload: '+reload);
            $A.get('e.force:refreshView').fire();
        }*/
       var navigator = component.find("navService");
            var pg = {
                type: "standard__recordPage",
                attributes: {
                    recordId: accountId,
                    objectApiName: "Campaign",
                    actionName: "view"
                }
            }
            navigator.navigate(pg);
           // window.location.reload();
	},

    /*isRefreshed: function(component, event, helper) {
        location.reload();
    }*/

    
})