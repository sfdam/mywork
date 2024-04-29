({
	init : function(component, event , helper) {
	    component.set("v.showError",false); 
    },
    checkCodiceAccordo : function(component, event, helper) {
        var codiceAccordo = component.get('v.numeroAccordo');
        
        if (codiceAccordo === '') {
            component.set("v.showError",true);
            component.set("v.errorMessage",$A.get("$Label.c.CheckRequiredFields"));
        } else {
            component.set("v.showError",false);
            var action = component.get("c.checkAccordo");
			action.setParams({
                numeroAccordo : codiceAccordo
            });
			action.setCallback(this, function(response) {
            	var state = response.getState();
				if (state === "SUCCESS") {
                    var result = JSON.parse(response.getReturnValue());
                    if (result.esito === 'OK') {                    
                    	component.set("v.showError",false);
                    	component.set("v.isAccordato",true);
                        component.set("v.numeroAccordo",result.codiceAccordo);
                        component.set("v.accountId",result.account);
                        if (result.isBanca) {
                            component.set("v.isBanca",true);
                        } else {
                            component.set("v.isBanca",false);
                        }
                    } else {
                        component.set("v.numeroAccordo", "");
                        component.set("v.showError",true);
                        component.set("v.errorMessage",result.message);
                    }                    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set("v.showError",true);
                            component.set("v.errorMessage",errors[0].message);
                        }
                    }
                } else {
                    component.set("v.showError",true);
                    component.set("v.errorMessage",$A.get("$Label.c.UnknownError"));
                }
            });
            $A.enqueueAction(action);
		}
	},
    registerUser : function(component, event, helper) {
        var codiceAccordo = component.get("v.numeroAccordo");
        var nome = component.get("v.nome");
        var cognome = component.get("v.cognome");
        var email = component.get("v.email");
        var cellulare = component.get("v.cellulare");
        var abi = component.get("v.abi");
        var cab = component.get("v.cab");
        var isBanca = component.get("v.isBanca");
        var profileName = component.get("v.profileName");
        var accountId = component.get("v.accountId");
        
        if (nome === '' || cognome === '' || email === '' || cellulare === '' || (isBanca && (abi === '' || cab === ''))) {
            component.set("v.showError",true);
            component.set("v.errorMessage",$A.get("$Label.c.CheckRequiredFields"));            
        } else {
            component.set("v.showError",false);
                        
            var action = component.get("c.registraUtente");
			action.setParams({
                numeroAccordo : codiceAccordo,
                nome : nome,
                cognome : cognome,
                email : email,
                cellulare: cellulare,
                accountId : accountId,
                abi : abi,
                cab : cab,
                nomeProfilo : profileName,
                isBanca : isBanca
            });
			action.setCallback(this, function(response) {
            	var state = response.getState();
				if (state === "SUCCESS") {
                    var result = JSON.parse(response.getReturnValue());
                    if (result.esito === 'OK') {                    
                    	component.set("v.showError",false);
                        component.set("v.showSuccess", true);
                        component.set("v.hasBeenRegistered", true);
                        component.set("v.successMessage",result.message);
                        component.set("v.isAccordato",false);
                        component.set("v.nome", "");
                        component.set("v.cognome", "");
                        component.set("v.email", "");
                        component.set("v.cellulare", "");
                        component.set("v.abi", "");
                        component.set("v.cab", "");
                        component.set("v.nome", "");
                        component.set("v.isBanca", false);
                        component.set("v.accountId", '');  
                        component.set("v.numeroAccordo", '');
                    } else {
                        component.set("v.numeroAccordo", codiceAccordo);
                        component.set("v.showError",true);
                        component.set("v.errorMessage",result.message);
                    }                    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set("v.showError",true);
                            component.set("v.errorMessage",errors[0].message);
                        }
                    }
                } else {
                    component.set("v.showError",true);
                    component.set("v.errorMessage",$A.get("$Label.c.UnknownError"));
                }
            });
            $A.enqueueAction(action);            
        }        
    },
 	// this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
    	// make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   	},    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
   	}    
})