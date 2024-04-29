({
    doInit : function(component,event,helper){
        
        var actions = [{}];
        actions = [{ label: 'Delete', name: 'delete' , disabled: false}];
 
        component.set('v.fileRecapColumns', [{label: 'Nome del File', fieldName: 'id', type: 'url', typeAttributes: {label: { fieldName: 'fileName' }, target: '_blank'}} , { type: 'action', typeAttributes: { rowActions: actions }}]);

    },       
    
    handleRecordUpdated : function(component,event,helper){
       
    	var changeType = event.getParams().changeType;
         
		if (changeType === "LOADED") { 
        
            component.set('v.jsonMCIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c'))); 
            if($A.util.isEmpty(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c')))){
                component.set('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c','[]');
            	component.set('v.jsonMCIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c')));  
            } 
            else{
                component.get('v.jsonMCIFileData').forEach(function(record){
                	record.id = '/'+record.id;
                });                                 
            }          
			
            var MCSDocumentValue = component.get('v.workflowRecordCandidato.DOCUMENTO_MCS_JSON__c');

            if(MCSDocumentValue == null || MCSDocumentValue === '[]'){
                
                component.set('v.isMCSRequired', false);
            }
            else {
                
                component.set('v.isMCSRequired', true);
                
            }
            
            if(component.get('v.workflowRecordCandidato.Stato__c') == 'PRE_VALUTAZIONE_CLIENTE'){
      
            
        	}            

            if(component.get('v.workflowRecordCandidato.Stato__c') == 'VISITA_FINALIZZAZIONE_MANDATO'){
       
            
        	}

            if(component.get('v.workflowRecordCandidato.Stato__c') == 'VALUTAZIONE_PRATICA'){
       
            
        	}    

            if(component.get('v.workflowRecordCandidato.Stato__c') == 'ATTIVAZIONE_RAPPORTO' || component.get('v.workflowRecordCandidato.Stato__c') == 'OPPORTUNITA_PERSA'){
        
            
        	}              
  
        }    
        if (changeType === "CHANGED") { 
            
            component.find("flowRecordHandlerWorkflowCandidatoId").reloadRecord(); 
        
        }        
    },
    
    handleUploadMCIFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonMCIFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
          
        component.set('v.jsonMCIFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c', JSON.stringify(newFileTable));      
        
        component.set('v.isMCIRequired',false);
       
    },
    
    handleRowActionMCIFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonMCIFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonMCIFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c', JSON.stringify(newFileTable));  
   
                break;
        }
    },        
    
    
    handleComboPosizioneImpresaChange : function(component,event,helper){

    },

    handleComboEsitoPreValutazioneChange : function(component,event,helper){

    },
    
    handleComboEsitoVisitaChange : function(component,event,helper){
    
    },
    
    handleComboEsitoValutazionePraticaChange : function(component,event,helper){
    
    },
        
	handleGotoAccountClick : function(component,event,helper){
	
		var IDAccount = component.get('v.workflowRecordCandidato.IDAccount__c');

		$A.get("e.force:navigateToURL").setParams({ 
		   "url": "/" + IDAccount
		}).fire();

	},

	handleGotoAcquireAccountClick : function(component,event,helper){
	
		component.set("v.HideSpinner", false);

		var workflowRecord = component.get('v.workflowRecordCandidato');

        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c.censisciAccount");
            action.setParams({
                actualWorkflow: workflowRecord
            });

            action.setCallback( this , function(callbackResult) {
    
                if(callbackResult.getState()=='SUCCESS') {
                    
                    resolve( 
                        callbackResult.getReturnValue()
                        
                    );
    
                    helper.showToast('Associazione Avvenuta','La pratica è stata associata all Account in modo corretto','3000','success');
                                       
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
					helper.showToast('Errore nel censimento','Si è verificato un errore tecnico nella fase di censimento dell Account','5000','error');                        
                }
            });
            
            $A.enqueueAction( action );
            
            $A.get('event.force:refreshView').fire(); 
        }));     
        
		component.set("v.HideSpinner", true);

        return promise; 
	
	},

    handleClickPreValutazione : function(component,event,helper){
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;
     
        // VERIFICA DELLA SEZIONE DATI RELATIVI ALLA PAGINA      
        
        if(!component.find("inputPosizioneImpresaId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("inputPosizioneImpresaId").reportValidity();
            
        }
        
        if(!component.find("inputEsitoPreValutazioneId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("inputEsitoPreValutazioneId").reportValidity();
            
        }
        
        if(!overallValidity){       
            
            return;
            
        }        
        
        var workflowRecordId = component.get('v.recordId');
        var posizioneImpresaSegnalata = component.get('v.workflowRecordCandidato.Posizione_Impresa_Segnalata__c');
        var esitoPreValutazione = component.get('v.workflowRecordCandidato.Esito_PRE_VALUTAZIONE__c');
        
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c.preValutaPraticaDaCRM");
            action.setParams({
                workflowRecordId: workflowRecordId,
                posizioneImpresaSegnalata: posizioneImpresaSegnalata,
                esitoPreValutazione: esitoPreValutazione
            });
    
            action.setCallback( this , function(callbackResult) {
    
                if(callbackResult.getState()=='SUCCESS') {
                    
                    resolve( 
                        callbackResult.getReturnValue()
                        
                    );
    
                    if(callbackResult.getReturnValue()){
                        
                        helper.showToast('Pratica inoltrata allo stato successivo','La pratica ha avanzato di stato ed è ulteriormente lavorabile','3000','success');
                    }
                    else {
                        
                        helper.showToast('Errore nel salvataggio','Si è verificato un errore tecnico nella fase di salvataggio della pratica','5000','error');                        
                        
                    }
                                       
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            
            $A.enqueueAction( action );
            
            $A.get('event.force:refreshView').fire(); 
    
        }));       
        
        return promise;  
        
    },
    
    handleClickVisitaFinalizzazioneMandato : function(component,event,helper){
                                                   
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;
     
        // VERIFICA DELLA SEZIONE DATI RELATIVI ALLA PAGINA      
        
        if(!component.find("inputEsitoVisitaClienteId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("inputEsitoVisitaClienteId").reportValidity();
            
        }       
        
        if(!overallValidity){       
            
            return;
            
        }             

        var workflowRecordId = component.get('v.recordId');
        var esitoVisitaCliente = component.get('v.workflowRecordCandidato.Esito_Visita_Cliente__c');
        var documentiMCI = component.get('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c');
        
        /*
        if(esitoVisitaCliente === 'SI'){
        
            if(documentiMCI == null || documentiMCI === '[]'){
                      
                component.set('v.isMCIRequired',true);
                
                overallValidity = false;
            }
            
            else {
                
                component.set('v.isMCIRequired',false);
                
            }    
            
            if(!component.find("inputAllegatoMandatoSGAId").get("v.validity").valid){
                
                overallValidity = false;
                
                component.find("inputAllegatoMandatoSGAId").setCustomValidity("Il titolare SGA della pratica deve caricare il documento.");
    
                component.find("inputAllegatoMandatoSGAId").reportValidity();
                
            }       
                    
            if(!overallValidity){       
                
                return;
                
            }        
            
        }
        
        */
            
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c.finalizzaPraticaDaCRM");
            action.setParams({
                workflowRecordId: workflowRecordId,
                esitoVisitaCliente: esitoVisitaCliente//,
                //documentiMCI: documentiMCI
            });
    
            action.setCallback( this , function(callbackResult) {
    
                if(callbackResult.getState()=='SUCCESS') {
                    
                    resolve( 
                        callbackResult.getReturnValue()
                        
                    );
    
                    if(callbackResult.getReturnValue()){
                        
                        helper.showToast('Pratica inoltrata allo stato successivo','La pratica ha avanzato di stato ed è ulteriormente lavorabile','3000','success');
                    }
                    else {
                        
                        helper.showToast('Errore nel salvataggio','Si è verificato un errore tecnico nella fase di salvataggio della pratica','5000','error');                        
                        
                    }
                    
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            
            $A.enqueueAction( action );
            
            $A.get('event.force:refreshView').fire(); 
            
        }));     
        
        return promise;  
        
    },
    
    handleClickValutazionePratica : function(component,event,helper){
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;
     
        // VERIFICA DELLA SEZIONE DATI RELATIVI ALLA PAGINA      
        
        if(!component.find("inputEsitoValutazionePaticaId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("inputEsitoValutazionePaticaId").reportValidity();
            
        }
        
        if(!overallValidity){       
            
            return;
            
        }     
        
        var workflowRecordId = component.get('v.recordId');
        var esitoValutazione = component.get('v.workflowRecordCandidato.Esito_VALUTAZIONE__c');  
        
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c.valutaPraticaDaCRM");
            action.setParams({
                workflowRecordId: workflowRecordId,
                esitoValutazione: esitoValutazione
            });
    
            action.setCallback( this , function(callbackResult) {
    
                if(callbackResult.getState()=='SUCCESS') {
                    
                    resolve( 
                        callbackResult.getReturnValue()
                        
                    );
    
                    if(callbackResult.getReturnValue()){
                        
                        helper.showToast('Pratica conclusa con successo','La pratica ha avanzato di stato e ha terminato la sua lavorazione','3000','success');
                    }
                    else {
                        
                        helper.showToast('Errore nel salvataggio','Si è verificato un errore tecnico nella fase di salvataggio della pratica','5000','error');                        
                        
                    }
                    
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            
            $A.enqueueAction( action );

            $A.get('event.force:refreshView').fire();         
            
        }));     
        
        return promise;          
    },

	waiting: function(component, event, helper) {
	  component.set("v.HideSpinner", true);
	 },

	 doneWaiting: function(component, event, helper) {
	  component.set("v.HideSpinner", false);
	 }

})