({
    init: function(component,event){
        var action = component.get("c.getFieldName");

        action.setParams({
            objApiName: component.get("v.oggetto"),
            stato: component.get("v.stato"),
            note: component.get("v.note")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS"){
                var allField = response.getReturnValue();
                component.set("v.fieldNameNote", allField["note"]);
            }
        });
        $A.enqueueAction(action);
    },
    handleSelect : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        component.set("v.selectedOption", stepName);
        
        /*component.find("record").saveRecord($A.getCallback(function(response) {
            if (response.state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }
        }));*/
    },
    handleSave: function(component,event) {
        var apiRequestName = 'salvaEsitazioneAzioniNec'
        var action = component.get("c.updateRecord");
       
        action.setParams({
            recordId: component.get("v.recordId"),
            stato: component.get("v.stato"),
            note: component.get("v.note"),
            selectedOption: component.get("v.selectedOption"),
            noteValue: component.get("v.noteValue"),
            oggetto: component.get("v.oggetto"),
            apiRequestName: apiRequestName,
            certificationName: component.get("v.certificationName"),
            disableLog: component.get("v.disableLog"),
            ruAsUserId: null,
            jsonParam: component.get("v.jsonParam")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var res = response.getReturnValue();

                if(res){
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({"title": "Successo", "message":"Esitazione agggiornata con successo","type":"SUCCESS"});
                    msg.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({"title": "Errore", "message":"Errore durante l'esitazione","type":"ERROR"});
                    msg.fire();
                    $A.get('e.force:refreshView').fire();
                }
            }
        });
        $A.enqueueAction(action);
        
    }
    
})