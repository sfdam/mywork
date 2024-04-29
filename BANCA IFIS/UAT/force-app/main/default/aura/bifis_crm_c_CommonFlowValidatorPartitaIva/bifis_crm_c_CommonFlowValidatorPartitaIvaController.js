({    invoke : function(component) {
    
    var partitaIva = component.get('v.flowValidatorPartitaIvaPartitaIvaVar');
    var risultatoControlloPartitaIva = 'KO';
    var messaggioPartitaIva = '';
    var anagrafica;
    var sorgenteAnagrafica = '';

    var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
        var action = component.get("c.checkPartitaIva");
        action.setParams({
            partitaIva: partitaIva
        });
        
        action.setCallback( this , function(callbackResult) {
            
            if(callbackResult.getState()=='SUCCESS') {
               
                resolve( 
                    callbackResult.getReturnValue()
                    
                );
                
                risultatoControlloPartitaIva = callbackResult.getReturnValue()[0];
                messaggioPartitaIva = callbackResult.getReturnValue()[1];
                anagrafica = callbackResult.getReturnValue()[2];
                sorgenteAnagrafica = callbackResult.getReturnValue()[3];

                console.log('anagrafica ', anagrafica);
                console.log('sorgenteAnagrafica ', sorgenteAnagrafica);
                
                component.set('v.flowValidatorPartitaIvaResultVar', risultatoControlloPartitaIva);
                component.set('v.flowValidatorPartitaIvaMessageVar', messaggioPartitaIva);
                component.set('v.flowValidatorPartitaIvaAnagraficaVar', anagrafica);    
                component.set('v.flowValidatorAnagraficaSourceVar', sorgenteAnagrafica);

				var d = new Date();

				component.set('v.flowValidatorPartitaIvaResultTimeMS', d.getTime());
                
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