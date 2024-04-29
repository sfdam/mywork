({
    fireEvent: function (response, eventApplication) {
        var B2FtoUse = "e.c:" + eventApplication;
        var B2F = $A.get(B2FtoUse);
        B2F.setParams({ "json": response });
        B2F.fire();
    },
                                                                                                                                                                                                                           
    resolveAction: function (action, data, eventApplication) {
        this.fireEvent(JSON.stringify({ "action": action, "response": data }), eventApplication);
    },
    
    showSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
		$A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    apex : function(component, helper, apexAction, params, execute, eventName) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            if(execute){
                var action = component.get("c."+apexAction+"");
                action.setParams( params );
                action.setCallback( this , function(callbackResult) {
                    if(callbackResult.getState()=='SUCCESS') {
                        helper.resolveAction('complete', callbackResult.getReturnValue(), eventName);      
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
    
    callBilancioRibes : function(component, event, helper){
        var action = component.get('c.getBilancioRibes');
        action.setParams({
            accountId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue();
                console.log('@@@ response status bilancio ribes ' , risposta);
                if(risposta.success == false){
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({
                        "title" : "Errore",
                        "message" : risposta.message,
                        "type" : "WARNING"
                    });
                    msg.fire();
                }
                else{
                    var evt = $A.get('e.c:WGC_Account_Utility_Bilancio_ResolveEvent');
                    evt.setParams({
                        json : JSON.stringify(risposta)
                    });
                    evt.fire();
                }
            }
            else{
                //ERROR
            }
        });
        $A.enqueueAction(action);
    }
})