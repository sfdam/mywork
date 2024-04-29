({
	fetchWorkflowsSegnalazioniForHomePage : function(component, event, searchFilter) {

        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get('c.fetchWorkflowsSegnalazioniForHomePage');
										  
            action.setParams({
                searchFilter: searchFilter
            });            
            
            action.setCallback( this , function(callbackResult) {
                
                if(callbackResult.getState()=='SUCCESS') {
                     
                    resolve( 
                        callbackResult.getReturnValue()
                        
                    );
                    var workflow = callbackResult.getReturnValue();
					
					workflow.forEach(w => {
						if(w.OpportunitaCollegata__r != null && w.OpportunitaCollegata__r.StageName != null) {
							w.Stato__c = w.OpportunitaCollegata__r.StageName.toUpperCase();
							if(w.OpportunitaCollegata__r.StageName == 'Persa')
								w.MotivazioneRifiutoPrevalutazione__c = w.OpportunitaCollegata__r.CategoriaChiusuraTrattativa__c;
						}
						if(w.OpportunitaCollegata__r != null && w.Tipo_Segnalazione__c != undefined && w.Tipo_Segnalazione__c == 'LEASING'){
							w.OpportunitaCollegata__r.Owner.Name = w.OpportunitaCollegata__r.Commerciale_Cross_Selling__c;
							w.OpportunitaCollegata__r.Owner.Phone = w.OpportunitaCollegata__r.Telefono_Commerciale_Cross_Selling__c;
						}
					});
                    component.set('v.workflows', workflow);           
                    
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