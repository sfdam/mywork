({    invoke : function(component) {

    var workflowRecordId = component.get('v.workflowRecordCandidatoID');    
    
    var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
        var action = component.get("c.controlliFinali");
        action.setParams({
            workflowRecordId: workflowRecordId
        });

        action.setCallback( this , function(callbackResult) {

            if(callbackResult.getState()=='SUCCESS') {
                
                resolve( 
                    callbackResult.getReturnValue()
                    
                );
  
                component.set('v.flowValidatorQualiQuantiErrorsVar', callbackResult.getReturnValue()[0]);                 
                component.set('v.flowValidatorConfSegnalErrorsVar', callbackResult.getReturnValue()[1]);              
                component.set('v.flowValidatorDocErrorsVar', callbackResult.getReturnValue()[2]);                        
                component.set('v.flowValidatorFinalResultVar', callbackResult.getReturnValue()[3]);                

            }
            if(callbackResult.getState()=='ERROR') {
                console.log('ERROR', callbackResult.getError() ); 
                reject( callbackResult.getError() );
            }
        });
        $A.enqueueAction( action );
    }));     
    
    return promise;     
    
	}
  
 })