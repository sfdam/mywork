({
	doInit : function(component, event, helper) {        
        helper.apex(component, event, 'getUserInfo', { })
        .then($A.getCallback(function (result) {
            console.log('result getUserInfo', result);
            component.set('v.userInfo',result);
        }));
    },

            
    onclick : function(component, event, helper) {   
        var selected = component.get("v.selectedUser");
        var recordId = component.get("v.recordId");
        console.log('recId: ',recordId);

        console.log('selected: ',selected.Id);

		helper.apex(component, event, 'changeActor', {"actorId": selected.Id ,"recordId": recordId })
        .then($A.getCallback(function (result) {
            if(result==true){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message":  $A.get("$Label.c.TXT_OpportunityApprovalComponent_Success") ,
                    "type" : "success"
                });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": $A.get("$Label.c.TXT_OpportunityApprovalComponent_Error"),
                    "type" : "error"
                });
                toastEvent.fire();
            }           
        }));
    }
})