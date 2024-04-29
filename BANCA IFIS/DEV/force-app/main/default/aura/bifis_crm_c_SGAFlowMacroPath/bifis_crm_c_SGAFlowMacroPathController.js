({
    doInit : function(component,event,helper){

     var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
        var action = component.get("c.getValoriPicklistStato");

        action.setCallback( this , function(callbackResult) {

            if(callbackResult.getState()=='SUCCESS') {
                
                resolve( 
                    callbackResult.getReturnValue()
                    
                );               
                
                var listedPicklistValues = [];
                var result = callbackResult.getReturnValue();

                for(var key in result){
                    listedPicklistValues.push({value:result[key], key:key});
                }
                
                // RIMUOVO ULTIMO ELEMENTO (OPPORTUNITA' PERSA), NON E' UNA FASE DA VISULIZZARE MA UNO STATO DI CADUTA
                
                listedPicklistValues.splice(-1,1);

                component.set('v.pathValues',listedPicklistValues);
                component.set('v.subPathVisible',true);
      
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