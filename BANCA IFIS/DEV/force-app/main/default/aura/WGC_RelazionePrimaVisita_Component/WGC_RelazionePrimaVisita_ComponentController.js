({
    doInit: function(component, event, helper){
        console.log('@@@ recordid ' , component.get('v.recordId'));
        var action = component.get('c.getRPV');
        action.setParams({
            accountId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue();
                console.log('@@@ risposta ' , risposta);
                if(risposta.rpv != null || risposta.rpv != undefined){
                    var value = [{ 
                        type: 'Account', 
                        id: risposta.rpv.Account__c, 
                        label: risposta.rpv.Account__r.Name, 
                        }];

                    component.find("lookup").get("v.body")[0].set("v.values", value);

                    component.set('v.relazione', risposta.rpv);
                }
                else if(risposta.acc != null || risposta.acc != undefined){
                    //Prepopolo il campo di lookup dell'account, WorkAround
                    var value = [{ 
                        type: 'Account', 
                        id: risposta.acc.Id, 
                        label: risposta.acc.Name, 
                        }];

                    component.find("lookup").get("v.body")[0].set("v.values", value);
                }
            }
            else{
                console.log('@@@ error ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    close : function(component, event, helper){
        var lib = component.find('overlayLib');
        lib.notifyClose();
    },

    saveRecord : function(component, event, helper){
        event.preventDefault();
        //Prima di salvare il record, controllo la validità dei dati inseriti
        var res = helper.convalidaDati(component, event, helper);
        //Se è falso fermo il salvataggio
        if(res == false){
            return;
        }

        var rec = component.get('v.relazione');
        console.log('@@@ record ' , JSON.stringify(rec));
        console.log('@@@ type record ' , typeof rec);
        var action = component.get('c.SaveRecord');
        action.setParams({
            "record" : rec
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('@@@ state ' , state);
            if(state == 'SUCCESS'){
                var lib = component.find('overlayLib');
                lib.notifyClose();
                //var obj = response.getReturnValue();
                //console.log('@@@ return ' , obj);
                var msg = $A.get("e.force:showToast");
                msg.setParams({
                    "title" : "Successo!",
                    "message" : "Salvataggio avvenuto con successo",
                    "type" : "success"
                });
                msg.fire();
            }
            if (state == 'ERROR'){
                console.log('@@@ response error ' , response.getError());
                var lib = component.find('overlayLib');
                lib.notifyClose();
                var msg = $A.get("e.force:showToast");
                msg.setParams({
                    "title" : "Errore!",
                    "message" : "Errore durante il salvataggio",
                    "type" : "error"
                });
                msg.fire();
            }
        });
        $A.enqueueAction(action);
    },

})