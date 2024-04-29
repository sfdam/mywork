({
    doInit : function(component,event,helper){
        // abbiamo ID (workflowRecordCandidatoID) dobbiamo andare a backend a prenderci ente segnalante
        // select Id, Ente_segnalante__c from WorkflowSegnalatori__c WHERE Id = workflowRecordCandidatoID
        // salvare il risultato in una variabile
    }, 

    // MS - Nascondi i campi polaris ID e codice BG se l'ente segnalante non è GNL
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        var workflowRecordCandidato = component.get("v.workflowRecordCandidato");
        console.log('sv eventParams.changeType: ', eventParams.changeType);
        if(eventParams.changeType === "LOADED" && workflowRecordCandidato) {
            //console.log("Record is loaded successfully.");
            console.log('sv callbackResult: ', workflowRecordCandidato.Ente_segnalante__c);
            if (workflowRecordCandidato.Ente_segnalante__c.substring(0, 3) != "GNL"){   
                component.set("v.showFields", false);
            }else{
                component.set("v.showFields", true);
            }
            console.log('DK showFields', component.get("v.showFields"));
        }
    },

    handleReferenteMeClick : function(component,event,helper){
	
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c.datiUtenteLoggato");
    
            action.setCallback( this , function(callbackResult) {
    
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( 
                        callbackResult.getReturnValue()
                        
                    );

                    var flusso = component.get("v.workflowRecordCandidatoID");   
        console.log('sv workflowRecordCandidatoID: ', flusso );

        var workflowRecordCandidato = component.get("v.workflowRecordCandidato");   
        console.log('sv workflowRecordCandidato: ', workflowRecordCandidato );

        var workflowRecordCandidatoNEXT = component.get("v.workflowRecordCandidatoNEXT");   
        console.log('sv workflowRecordCandidatoNEXT: ', workflowRecordCandidatoNEXT );

                    //console.log('sv callbackResult: ', opp.Ente_segnalante__c );
                    //console.log('sv callbackResult: ', callbackResult.getReturnValue());
                    //console.log('sv callbackResult: ', callbackResult.getReturnValue().ID_Polaris__c);
                    //console.log('sv callbackResult: ', callbackResult.getReturnValue().Codice_referente_BG__c);
                    //console.log('sv callbackResult: ', component.get("v.workflowRecordCandidato").Ente_segnalante__c);

					component.find("flowInputReferenteNomeInputId").set("v.value",callbackResult.getReturnValue().FirstName);
					component.find("flowInputReferenteCognomeInputId").set("v.value",callbackResult.getReturnValue().LastName);
					component.find("flowInputReferenteTelefonoInputId").set("v.value",callbackResult.getReturnValue().Phone);
					component.find("flowInputReferenteEmailInputId").set("v.value",callbackResult.getReturnValue().Email);
					component.find("flowInputReferentePolarisInputId").set("v.value",callbackResult.getReturnValue().ID_Polaris__c);
					component.find("flowInputReferenteCodiceBGInputId").set("v.value",callbackResult.getReturnValue().Codice_referente_BG__c);
                                       
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }

            });
            
            $A.enqueueAction( action ); 

        }));  

    }, 

    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;    
        
        
        if(!overallValidity){       
            
            return;
            
        }
        else {
  
            component.find("flowRecordHandlerWorkflowCandidatoId").saveRecord($A.getCallback(function(saveResult) {
         
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    
						navigate(event.getParam("action"));
                   
                } else if (saveResult.state === "INCOMPLETE") {
                    
                    console.log("User is offline, device doesn't support drafts.");
                    
                } else if (saveResult.state === "ERROR") {
                    
                    console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                    
                } else {
                    
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                    
                }
            }));   
        }
        
    } 

})