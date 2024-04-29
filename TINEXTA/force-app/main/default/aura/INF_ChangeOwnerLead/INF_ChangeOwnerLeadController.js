({    
init : function(component, event, helper) {
    helper.apex(component, event, 'getLead', { "recordId": component.get("v.recordId")})
    .then($A.getCallback(function (result) {
        if(result.success){
            var lead = result.data[0];
            console.log('v.statoTrasf', lead.Stato_Trasferimento__c)
            component.set('v.statoTrasf',lead.Stato_Trasferimento__c);
        }
    }));
},

onclick : function(component, event, helper) {
         helper.apex(component, event, 'saveLead', { "recordId": component.get("v.recordId")})
        .then($A.getCallback(function (result) {
            console.log('result update: ', result);
                       if(result.success){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Owner cambiato correttamente",
                    "type" : "success"
                });
                toastEvent.fire();
                component.set('v.statoTrasf', result.data[0].Stato_Trasferimento__c);
                

                
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Errore!",
                    "message": "Impossibile cambiare owner",
                    "type" : "error"
                });
                toastEvent.fire();
            }
        }))

}
})