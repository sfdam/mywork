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
                
                component.set('v.flowValidatorAnagrafeErrorsVar', callbackResult.getReturnValue()[0]);                 
                component.set('v.flowValidatorConfProdErrorsVar', callbackResult.getReturnValue()[1]);    
                component.set('v.flowValidatorGaranzieErrorsVar', callbackResult.getReturnValue()[2]);       
                component.set('v.flowValidatorPrivacyErrorsVar', callbackResult.getReturnValue()[3]); 
                component.set('v.flowValidatorMAVErrorsVar', callbackResult.getReturnValue()[4]);      
                component.set('v.flowValidatorTCErrorsVar', callbackResult.getReturnValue()[5]);      
                component.set('v.flowValidatorQQErrorsVar', callbackResult.getReturnValue()[6]);
                component.set('v.flowValidatorNoteErrorsVar', callbackResult.getReturnValue()[7]);                
                component.set('v.flowValidatorDocErrorsVar', callbackResult.getReturnValue()[8]);                        
                component.set('v.flowValidatorFinalResultVar', callbackResult.getReturnValue()[9]);                

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