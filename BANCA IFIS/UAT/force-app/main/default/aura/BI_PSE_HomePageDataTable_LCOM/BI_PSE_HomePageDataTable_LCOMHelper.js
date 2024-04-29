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
					console.log('@@@A.M. workflow:', workflow);
					workflow.forEach(w => {
						if(w.OpportunitaCollegata__r != null && w.OpportunitaCollegata__r.StageName != null) {
							w.Stato__c = w.OpportunitaCollegata__r.StageName.toUpperCase();
							
							//SDCHG-5371 Ricerca prodotti configurati nell'opportunità
							if (w.OpportunitaCollegata__r.WGC_Prodotti_Selezionati__c != null && w.OpportunitaCollegata__r.WGC_Prodotti_Selezionati__c != undefined && w.OpportunitaCollegata__r.StageName != 'In Istruttoria'){
														
								console.log('@@@A.M. PartitaIVA__c: ', w.PartitaIVA__c);
								console.log('@@@A.M. WGC_Prodotti_Selezionati__c: ', w.OpportunitaCollegata__r.WGC_Prodotti_Selezionati__c);
								var isFactoring = 'false';
								var isMutuo = 'false';
								var isLeasing = 'false';
								var listProdotti =  w.OpportunitaCollegata__r.WGC_Prodotti_Selezionati__c.split(";");

								listProdotti.forEach(p => {
									console.log('@@@A.M. listProdotti-for: ', p);
									switch (p) {
										case "Factoring":
										case "Factoring MCC":
										case "Acquisto Titolo Definitivo":
										case "Anticipo Crediti Futuri":
										case "Anticipo Crediti Futuri MCC":
										case "Sola Gestione":
											isFactoring = 'true';
											break;

										case "Mutuo":
											isMutuo = 'true';
											break;

										case "Leasing":
											isLeasing = 'true';
											break;
									}
								});
								console.log('@@@A.M. isFactoring: ', isFactoring);
								console.log('@@@A.M. isMutuo: ', isMutuo);
								console.log('@@@A.M. isLeasing: ', isLeasing);
								
								if (isFactoring == 'true'){
									if (isMutuo == 'true'){
										w.Prodotti_Avviati__c = 'FACTORING + MUTUO';
									} else {
										w.Prodotti_Avviati__c = 'FACTORING';
									}
								} else if (isMutuo == 'true'){
									w.Prodotti_Avviati__c = 'MUTUO';
								}

								if (isLeasing == 'true'){
									w.Prodotti_Avviati__c = 'LEASING';
								}
								console.log('@@@A.M. Prodotti_Avviati__c: ', w.Prodotti_Avviati__c);
							} //fine prodotti avviati

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