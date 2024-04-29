({
    doInit : function(component,event,helper){
        

    }, 

    handleReferenteMeClick : function(component,event,helper){
	
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c.datiUtenteLoggato");
    
            action.setCallback( this , function(callbackResult) {
    
                if(callbackResult.getState()=='SUCCESS') {

                    resolve( 
                        callbackResult.getReturnValue()
                        
                    );

					component.find("flowInputReferenteNomeInputId").set("v.value",callbackResult.getReturnValue().FirstName);
					component.find("flowInputReferenteCognomeInputId").set("v.value",callbackResult.getReturnValue().LastName);
					component.find("flowInputReferenteTelefonoInputId").set("v.value",callbackResult.getReturnValue().Phone);
					component.find("flowInputReferenteEmailInputId").set("v.value",callbackResult.getReturnValue().Email);
                                       
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