({    invoke : function(component) {

    var workflowRecordId = component.get('v.workflowRecordCandidatoID');

     var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
        var action = component.get("c.submitFinale");
        action.setParams({
            workflowRecordId: workflowRecordId
        });

        action.setCallback( this , function(callbackResult) {

            if(callbackResult.getState()=='SUCCESS') {
                
                resolve( 
                    callbackResult.getReturnValue()
                    
                );               
                
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