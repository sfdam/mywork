({
	fetchWorkflowsMCCForHomePage : function(component, event, searchFilter, searchFilterHorizon) {

        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get('c.fetchWorkflowsMCCForHomePage');
										  
            action.setParams({
                searchFilter: searchFilter,
				searchFilterHorizon: searchFilterHorizon
            });            
            
            action.setCallback( this , function(callbackResult) {
                
                if(callbackResult.getState()=='SUCCESS') {
                     
                    resolve( 
                        callbackResult.getReturnValue()
                        
                    );
                    
                    component.set('v.workflows',  callbackResult.getReturnValue());           
                    
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