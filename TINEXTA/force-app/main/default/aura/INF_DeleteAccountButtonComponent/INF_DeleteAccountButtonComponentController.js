({
    doInit : function(component, event, helper) {
        component.set('v.loading', true);
        helper.apex(component, event, 'deleteRecord', { "recordId": component.get("v.recordId")})
        .then($A.getCallback(function (result) {
            console.log('result delete: ', result);
            if(result.success){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Account eliminato correttamente",
                    "type" : "success"
                });
                toastEvent.fire();
                
               var navService = component.find("navService");
                var pageReference = {
                    type: "standard__objectPage",
                   attributes: {
                        "objectApiName": "Account",
                       "actionName": "list"
                   },
                   state: {
                        "filterName": "Recent"
                    }
                };
                
                component.set('v.loading', false);
                navService.navigate(pageReference);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Errore!",
                    "message": "Impossibile eliminare l'account. ",
                    "type" : "error"
                });
                toastEvent.fire();
            }
        }))
        
        
        
    }
})