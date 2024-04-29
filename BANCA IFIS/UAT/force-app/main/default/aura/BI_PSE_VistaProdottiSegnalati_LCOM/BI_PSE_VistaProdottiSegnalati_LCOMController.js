({
    
    doInit : function(component,event,helper){

        var actions = [{}];
        actions = [{ label: 'Delete', name: 'delete' , disabled: false}];
 
        component.set('v.fileRecapColumnsReadOnly', [{label: 'Nome del File', fieldName: 'id', type: 'url', typeAttributes: {label: { fieldName: 'fileName' }, target: '_blank'}},{label: 'Tipologia', fieldName: 'fileType', type: 'text'}]);
        component.set('v.fileRecapColumns', [{label: 'Nome del File', fieldName: 'id', type: 'url', typeAttributes: {label: { fieldName: 'fileName' }, target: '_blank'}} , {label: 'Tipologia', fieldName: 'fileType', type: 'text'}, { type: 'action', typeAttributes: { rowActions: actions }}]);

    },       
    
    handleRecordUpdated : function(component,event,helper){
        
    	var changeType = event.getParams().changeType;
        
		if (changeType === "LOADED") { 
			if(component.get('v.workflowRecordCandidato.Tipologia_Segnalazione__c')){
				if(component.get('v.workflowRecordCandidato.Tipologia_Segnalazione__c') == 'FACTORING' || component.get('v.workflowRecordCandidato.Tipologia_Segnalazione__c') == 'MISTO'){

					component.set('v.jsonParsedFactoringProduct', JSON.parse(component.get('v.workflowRecordCandidato.PRD_FACTORING_JSON__c')));
					component.set('v.jsonParsedFactoringProductNote', component.get('v.jsonParsedFactoringProduct').noteFactoring);
                          
				}      
				if(component.get('v.workflowRecordCandidato.Tipologia_Segnalazione__c') == 'MUTUO' || component.get('v.workflowRecordCandidato.Tipologia_Segnalazione__c') == 'MISTO'){

					component.set('v.jsonParsedMutuoProduct', JSON.parse(component.get('v.workflowRecordCandidato.PRD_MUTUO_JSON__c')));
					component.set('v.jsonParsedMutuoProductNote', component.get('v.jsonParsedMutuoProduct').noteMutuo);
                          
				}
				if(component.get('v.workflowRecordCandidato.Tipologia_Segnalazione__c') == 'LEASING' || component.get('v.workflowRecordCandidato.Tipologia_Segnalazione__c') == 'LEASINGRENTAL'){

					component.set('v.jsonParsedLeasingProduct', JSON.parse(component.get('v.workflowRecordCandidato.PRD_LEASING_JSON__c')));
					component.set('v.jsonParsedLeasingProductNote', component.get('v.jsonParsedLeasingProduct').noteLeasing);
                          
				}      
				if(component.get('v.workflowRecordCandidato.Tipologia_Segnalazione__c') == 'RENTAL' || component.get('v.workflowRecordCandidato.Tipologia_Segnalazione__c') == 'LEASINGRENTAL'){

					component.set('v.jsonParsedRentalProduct', JSON.parse(component.get('v.workflowRecordCandidato.PRD_RENTAL_JSON__c')));
					component.set('v.jsonParsedRentalProductNote', component.get('v.jsonParsedRentalProduct').noteRental);
                          
				}    				    
			}
		}
    }
})