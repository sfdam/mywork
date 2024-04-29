({

	doInit : function(component, event, helper) { 
		
		helper.hideSpinner(component, event);

        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 

            var action = component.get("c.checkFreezedUsers");
                    
            action.setCallback( this , function(callbackResult) {

                if(callbackResult.getState()=='SUCCESS') {
                    resolve( 
                        callbackResult.getReturnValue()
                    );

					var resultWrapper = callbackResult.getReturnValue();
					
					var resultWrapperObj = JSON.parse(resultWrapper);

					component.set("v.freezedUsers", resultWrapperObj.UTENTI_FREEZATI);
					component.set("v.unfreezedUsers", resultWrapperObj.UTENTI_NON_FREEZATI);

					var buttonFreezeUsers = component.find("buttonFreezeUsers");
					buttonFreezeUsers.set("v.disabled",false);

					var buttonUnfreezeUsers = component.find("buttonUnfreezeUsers");
					buttonUnfreezeUsers.set("v.disabled",false);

                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));    
        
        return promise;

	},

	handleCallUrlClick : function(component,event,helper){

        if(!component.find("flowInputURL").get("v.validity").valid){
            
            component.find("flowInputURL").reportValidity();

			return;
            
        }    

		window.open(component.get("v.varURL"));
	},

	handleCallUnfreezeClick : function(component,event,helper){

        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 

            var action = component.get("c.unfreezeUsers");
                    
            action.setCallback( this , function(callbackResult) {

                if(callbackResult.getState()=='SUCCESS') {
                    resolve( 
                        callbackResult.getReturnValue()
                    );

					var resultWrapper = callbackResult.getReturnValue();

					component.set("v.freezedUsers", component.get("v.freezedUsers") - resultWrapper);
					component.set("v.unfreezedUsers", component.get("v.unfreezedUsers") + resultWrapper);

					var toastEvent = $A.get("event.force:showToast");

					toastEvent.setParams({
						title : 'Esito operazione',
						message: 'Sono stati de freezzati un numero di utenti pari a: ' + resultWrapper,
						duration:' 5000',
						key: 'info_alt',
						type: 'info',
						mode: 'pester'
					});
                    
                    toastEvent.fire();  

                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));    
        
        return promise;

	},

	handleCallFreezeClick : function(component,event,helper){

        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 

            var action = component.get("c.freezeUsers");
                    
            action.setCallback( this , function(callbackResult) {

                if(callbackResult.getState()=='SUCCESS') {
                    resolve( 
                        callbackResult.getReturnValue()
                    );

					var resultWrapper = callbackResult.getReturnValue();

					component.set("v.freezedUsers", component.get("v.freezedUsers") + resultWrapper);
					component.set("v.unfreezedUsers", component.get("v.unfreezedUsers") - resultWrapper);

					var toastEvent = $A.get("event.force:showToast");

					toastEvent.setParams({
						title : 'Esito operazione',
						message: 'Sono stati freezzati un numero di utenti pari a: ' + resultWrapper,
						duration:' 5000',
						key: 'info_alt',
						type: 'info',
						mode: 'pester'
					});
                    
                    toastEvent.fire();  

                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));    
        
        return promise;

	},

	handleCallUpdateFD : function(component,event,helper){
			helper.showSpinner(component, event);
            var action = component.get("c.riassegnaTerritoriFD");
                    
            action.setCallback( this , function(callbackResult) {
				helper.hideSpinner(component, event);
                if(callbackResult.getState()=='SUCCESS') {
                    //resolve( 
                       // callbackResult.getReturnValue()
                    //);

					//var resultWrapper = callbackResult.getReturnValue();

					//component.set("v.freezedUsers", component.get("v.freezedUsers") + resultWrapper);
					//component.set("v.unfreezedUsers", component.get("v.unfreezedUsers") - resultWrapper);

					var toastEvent = $A.get("event.force:showToast");

					toastEvent.setParams({
						title : 'Esito operazione',
						message: 'Assegnazioni anagrafiche aggiornate',
						duration:' 5000',
						key: 'info_alt',
						type: 'info',
						mode: 'pester'
					});
                    
                    toastEvent.fire();  

                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
	}

})