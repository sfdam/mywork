({
	initialize : function(component, event, helper) {
		
	},

	apex : function(component, helper, apexAction, params, execute, eventName) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            if(execute){
                var action = component.get("c."+apexAction+"");
                action.setParams( params );
                action.setCallback( this , function(callbackResult) {
                    if(callbackResult.getState()=='SUCCESS') {
                        //helper.resolveAction('complete', callbackResult.getReturnValue(), eventName);      
                        resolve( callbackResult.getReturnValue() );
                    }
                    if(callbackResult.getState()=='ERROR') {
                        console.log('ERROR', callbackResult.getError() ); 
                        reject( callbackResult.getError() );
                    }
                });
                $A.enqueueAction( action );
            } else {
                resolve( 'non richiesto' );
            }
        }));      
        return p;
    },

    showSpinner: function (cmp, event) {
		var spinner = cmp.find("mySpinner");
		console.log('spinner', spinner);
        $A.util.removeClass(spinner, "slds-hide");

    },

    hideSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");

    },
})