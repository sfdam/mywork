({
	doInit : function(component, event, helper) {   
		helper.showSpinner(component, event);
		var id = component.get('v.recordId');        
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
			component.set('v.output','Richiesta dati a Infoprovider in corso ...');
            var action = component.get("c.valorizzaAccount");
            action.setParams({
                id : id
            });
            action.setCallback( this , function(callbackResult) {
			helper.hideSpinner(component, event);
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( 
                        callbackResult.getReturnValue()
                    );
					var resultState = callbackResult.getReturnValue();
					if(resultState.success){
						component.set('v.esito','SUCCESS');
                        component.set('v.output', resultState.msg);
						component.set('v.account', resultState.data[0]);
						
						var button = component.find("OkButton");
						button.set('v.disabled',false);
					} else{						
						var toastEvent = $A.get("event.force:showToast");
						toastEvent.setParams({
						title : 'Attenzione!',
						message: resultState.msg,
						duration:' 5000',
						key: 'info_alt',
						type: 'warning',
						mode: 'pester'
					});
					toastEvent.fire();
					$A.get("e.force:closeQuickAction").fire();
					}
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));    
    },

	clickOk : function(component, event, helper) {
		var account = component.get('v.account');   
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
				
		if(component.get('v.esito')=='SUCCESS') {
			var button = component.find("OkButton");
			button.set('v.disabled',true);

			helper.showSpinner(component, event);
			
			var action = component.get("c.aggiornaAccount");
			action.setParams({
				a : account
			});
			action.setCallback( this , function(callbackResult) {
			
			helper.hideSpinner(component, event);
			
			if(callbackResult.getState()=='SUCCESS') {
				resolve( 
					callbackResult.getReturnValue()
				);
				var resultState = callbackResult.getReturnValue();
				if(resultState.success) $A.get('event.force:refreshView').fire();

				var toastEvent = $A.get("event.force:showToast");
				if(resultState.success){
					toastEvent.setParams({
						title : 'Success!',
						message : resultState.msg,
						duration:' 5000',
						key: 'info_alt',
						type: 'success',
						mode: 'pester'
					});
				} else{
					toastEvent.setParams({
						title : 'Errore Tecnico',
						message: resultState.msg,
						duration:' 5000',
						key: 'info_alt',
						type: 'error',
						mode: 'pester'
					});
				}
				toastEvent.fire();
				$A.get("e.force:closeQuickAction").fire();
			}
			if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
			});
		}
		$A.enqueueAction( action );
		}));    
		return promise;
    },
})