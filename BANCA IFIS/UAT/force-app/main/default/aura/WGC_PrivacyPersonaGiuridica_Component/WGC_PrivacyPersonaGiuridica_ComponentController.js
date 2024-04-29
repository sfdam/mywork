({
	doInit : function(component, event, helper) {
		var accId = component.get("v.recordId");
		//component.set('v.rec', accId);
        console.log('@@@ accountId ' , accId);

        //recupero i dati già salvati
        var action = component.get('c.getDefaultData');
        action.setParams({
            "recordId" : accId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set("v.rec", response.getReturnValue());
                console.log('@@@ account data ', component.get("v.rec"));

                if(response.getReturnValue().NaturaGiuridica__c == "PF"){
                    component.set("v.tipo", "Privacy Persona Fisica");
                }
                else if(response.getReturnValue().WGC_Esecutore_Firmatario_Privacy__c != null && 
                        response.getReturnValue().WGC_Esecutore_Firmatario_Privacy__c != undefined){
                    //Imposto di default l'esecutore selezionato
                    component.set("v.esecutore", response.getReturnValue().WGC_Esecutore_Firmatario_Privacy__c);
                }
                //Recupero i testi della privacy
                helper.getPrivacyText(component, event, helper);
                component.set('v.isLoaded', true);
            } 
        });
        $A.enqueueAction(action);

        var isAccount = component.get("v.isAccount");
        if(isAccount){
            helper.getEsecutori(component, event, helper);
        }
	},

	close : function(component, event, helper){
        var lib = component.find('overlayLib');
        lib.notifyClose();
	},

	onGroup : function(component, event, helper){
		var selected = event.getSource().get("v.label");
		var nm = event.getSource().get("v.name");
        console.log('@@@ selected ' , selected);
        if(selected == 'Acconsento'){
            selected = true;
        }
        if(selected == 'Non Acconsento'){
            selected = false;
        }
        if(selected == 'Si'){
            selected = true;
        }
        if(selected == 'No'){
            selected = false;
        }
        console.log('@@@ nm ' , nm);
        console.log('@@@ selected ' , selected);
		component.set('v.'+nm, selected);
		var md = component.get('v.rec');
		console.log('@@@ risposta ' , md);
	},	
	
	saveRecord : function(component, event, helper){
        event.preventDefault();
        component.set('v.isLoaded', false);
		var rec = component.get('v.rec');
        var action = component.get('c.SaveRecord');
        action.setParams({
            "recordId" : component.get('v.recordId'),
            "record" : JSON.stringify(rec)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('@@@ state ' , state);
            if(state == 'SUCCESS'){
                    var risposta = response.getReturnValue();
                    console.log('@@@ ppg ' , risposta);
                    var lib = component.find('overlayLib');

                    //Evento per aggiornare la info di account
                    var updtAcc = $A.get("e.c:WGC_RefreshContactResolveEvent");
                	console.log('@@@ evento ' , updtAcc);
                	/*
                	updtAcc.setParams({
                        "json" : {}
               		});
                    */
                    updtAcc.fire();
                
                	if(risposta.success){
						component.set("v.modalBodyAttributeName", "SALVA");
                    } else {
                        component.set("v.modalBodyAttributeName", "ERRORE");
                    }
                
                    lib.notifyClose();

                    if(risposta.success){
                        var msg = $A.get("e.force:showToast");
                        msg.setParams({
                            "title" : "Successo!",
                            "message" : "Salvataggio avvenuto con successo",
                            "type" : "success"
                        });
                        msg.fire();
                        
                        //component.set("v.modalBodyAttributeName", "SALVA");
                    }
                    else{
                        var msg = $A.get("e.force:showToast");
                        msg.setParams({
                            "title" : "Errore!",
                            "message" : risposta.message,
                            "type" : "error"
                        });
                        msg.fire();
                        
                        //component.set("v.modalBodyAttributeName", "ERRORE");
                    }
            }
            else{
                var msg = $A.get("e.force:showToast");
                msg.setParams({
                    "title" : "Errore!",
                    "message" : "Errore durante il salvataggio",
                    "type" : "error"
                });
                var lib = component.find('overlayLib');
                console.log('@@@ lib ' , lib);
                lib.notifyClose();
                msg.fire();
                
                //component.set("v.modalBodyAttributeName", "ERRORE");
            }
        });
		$A.enqueueAction(action);
    },

    saveRecordWithEsecutore : function(component, event, helper){
        helper.savePrivacyEsecutore(component, event, helper);
    },
    
    changeEsecutore : function(component, event, helper){
        var newValue = event.getSource().get("v.value");
        console.log('@@@ newValue ' , newValue);

        component.set("v.esecutore", newValue);
    },
})