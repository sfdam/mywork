({
	fetchQQType : function(component, event, fatturato) {

		var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
			var action = component.get("c.classificazioneQQ");
			action.setParams({
				fatturato: fatturato
			});

			action.setCallback( this , function(callbackResult) {

				if(callbackResult.getState()=='SUCCESS') {
   
					resolve( 
						callbackResult.getReturnValue()
                    
					);

					component.set('v.tipologiaQuestionarioVar', callbackResult.getReturnValue());
                
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