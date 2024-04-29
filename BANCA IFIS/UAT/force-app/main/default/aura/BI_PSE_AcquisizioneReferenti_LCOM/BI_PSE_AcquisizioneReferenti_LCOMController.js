({
    doInit : function(component,event,helper){
        

    },  
	  
    
	handleAddUserClick : function(component,event,helper){
		var inputNome = component.find("flowInputNomeSoggettoInputId");
		var inputCognome = component.find("flowInputCognomeSoggettoInputId");
		var inputRuolo = component.find("flowInputRuoloSoggettoInputId");
		var inputTelefono = component.find("flowInputTelefonoSoggettoInputId");
		var inputMail = component.find("flowInputMailSoggettoInputId");

		var overallValidity = true;  

		if($A.util.isEmpty(inputNome.get("v.value"))){
		
			inputNome.setCustomValidity("Dato del Referente richiesto");
			inputNome.reportValidity();

			overallValidity = false;

		}

		if($A.util.isEmpty(inputCognome.get("v.value"))){
		
			inputCognome.setCustomValidity("Dato del Referente richiesto");
			inputCognome.reportValidity();

			overallValidity = false;

		}

		if($A.util.isEmpty(inputTelefono.get("v.value"))){
	
			inputTelefono.setCustomValidity("Dato del Referente richiesto");
			inputTelefono.reportValidity();

			overallValidity = false;

		}

		// CONTROLLI AGGIUNTIVI IN CASO DI DITTA INDIVIDUALE

		if(component.get("v.workflowRecordCandidato.Natura_Giuridica__c") == "DI"){
		
			var inputDataNascita = component.find("flowInputDataNascitaSoggettoInputId");
			var inputLuogoNascita = component.find("flowInputLuogoNascitaSoggettoInputId");
			var inputNazioneNascita = component.find("flowInputNazioneNascitaSoggettoInputId");
			var inputSesso = component.find("flowInputSessoSoggettoInputId");
			var inputCodiceFiscale = component.find("flowInputCodiceFiscaleSoggettoInputId");
			var inputSae = component.find("flowInputSaeSoggettoInputId");
			var inputTae = component.find("flowInputTaeSoggettoInputId");
			var inputTipoDocumento = component.find("flowInputTipoDocumentoSoggettoInputId");
			var inputNumeroDocumento = component.find("flowInputNumeroDocumentoSoggettoInputId");
			var inputLuogoEmissioneDocumento = component.find("flowInputLuogoEmissioneDocumentoSoggettoInputId");
			var inputDataEmissioneDocumento = component.find("flowInputDataEmissioneDocumentoSoggettoInputId");
			var inputDataScadenzaDocumento = component.find("flowInputDataScadenzaDocumentoSoggettoInputId");

			if($A.util.isEmpty(inputDataNascita.get("v.value"))){
	
				inputDataNascita.setCustomValidity("Dato del Referente richiesto");
				inputDataNascita.reportValidity();

				overallValidity = false;

			}

			if($A.util.isEmpty(inputLuogoNascita.get("v.value"))){
	
				inputLuogoNascita.setCustomValidity("Dato del Referente richiesto");
				inputLuogoNascita.reportValidity();

				overallValidity = false;

			}

			if($A.util.isEmpty(inputNazioneNascita.get("v.value"))){
	
				inputNazioneNascita.setCustomValidity("Dato del Referente richiesto");
				inputNazioneNascita.reportValidity();

				overallValidity = false;

			}

			if($A.util.isEmpty(inputSesso.get("v.value"))){
	
				inputSesso.setCustomValidity("Dato del Referente richiesto");
				inputSesso.reportValidity();

				overallValidity = false;

			}

			if($A.util.isEmpty(inputCodiceFiscale.get("v.value"))){
	
				inputCodiceFiscale.setCustomValidity("Dato del Referente richiesto");
				inputCodiceFiscale.reportValidity();

				overallValidity = false;

			}

			if($A.util.isEmpty(inputSae.get("v.value"))){
	
				inputSae.setCustomValidity("Dato del Referente richiesto");
				inputSae.reportValidity();

				overallValidity = false;

			}

			if($A.util.isEmpty(inputTae.get("v.value"))){
	
				inputTae.setCustomValidity("Dato del Referente richiesto");
				inputTae.reportValidity();

				overallValidity = false;

			}

			if($A.util.isEmpty(inputTipoDocumento.get("v.value"))){
	
				inputTipoDocumento.setCustomValidity("Dato del Referente richiesto");
				inputTipoDocumento.reportValidity();

				overallValidity = false;

			}

			if($A.util.isEmpty(inputNumeroDocumento.get("v.value"))){
	
				inputNumeroDocumento.setCustomValidity("Dato del Referente richiesto");
				inputNumeroDocumento.reportValidity();

				overallValidity = false;

			}

			if($A.util.isEmpty(inputLuogoEmissioneDocumento.get("v.value"))){
	
				inputLuogoEmissioneDocumento.setCustomValidity("Dato del Referente richiesto");
				inputLuogoEmissioneDocumento.reportValidity();

				overallValidity = false;

			}

			if($A.util.isEmpty(inputDataEmissioneDocumento.get("v.value"))){
	
				inputDataEmissioneDocumento.setCustomValidity("Dato del Referente richiesto");
				inputDataEmissioneDocumento.reportValidity();

				overallValidity = false;

			}

			if($A.util.isEmpty(inputDataScadenzaDocumento.get("v.value"))){
	
				inputDataScadenzaDocumento.setCustomValidity("Dato del Referente richiesto");
				inputDataScadenzaDocumento.reportValidity();

				overallValidity = false;

			}
		}

		if(!overallValidity){
		
			return;

		}

        var referentiTable = component.get('v.jsonREFERENTIData');

		var payload;
		
		if(component.get("v.workflowRecordCandidato.Natura_Giuridica__c") == "DI"){

			// IL PAYLOAD PER LE DITTE INDIVIDUALI CONTIENE PIU' DATI

			payload  = '[{"nome": "' + inputNome.get("v.value") + '", "cognome": "' + inputCognome.get("v.value") + '", "ruolo": "' + inputRuolo.get("v.value") + '", "telefono": "' + inputTelefono.get("v.value") + '", "mail": "' + inputMail.get("v.value") + '", "dataNascita": "' + inputDataNascita.get("v.value") + '", "luogoNascita": "' + inputLuogoNascita.get("v.value") + '", "nazioneNascita": "' + inputNazioneNascita.get("v.value") + '", "sesso": "' + inputSesso.get("v.value") + '", "codiceFiscale": "' + inputCodiceFiscale.get("v.value") + '", "sae": "' + inputSae.get("v.value") + '", "tae": "' + inputTae.get("v.value") + '", "nazioneNascita": "' + inputNazioneNascita.get("v.value") + '", "tipoDocumento": "' + inputTipoDocumento.get("v.value") + '", "numeroDocumento": "' + inputNumeroDocumento.get("v.value") + '", "luogoEmissioneDocumento": "' + inputLuogoEmissioneDocumento.get("v.value") + '", "dataEmissioneDocumento": "' + inputDataEmissioneDocumento.get("v.value") + '", "dataScadenzaDocumento": "' + inputDataScadenzaDocumento.get("v.value") + '"}]';

			var newReferentiTable = referentiTable.concat(JSON.parse(payload));        
         
			component.set('v.jsonREFERENTIData', newReferentiTable);       

			component.set('v.workflowRecordCandidato.REFERENTI_JSON__c', JSON.stringify(newReferentiTable));   

			console.log ('@@@A.M. v.workflowRecordCandidato.REFERENTI_JSON__c: ', component.get('v.workflowRecordCandidato.REFERENTI_JSON__c'));
			

			inputNome.set("v.value",'');
			inputCognome.set("v.value",'');
			inputTelefono.set("v.value",'');
			inputMail.set("v.value",'');
			inputDataNascita.set("v.value",'');
			inputLuogoNascita.set("v.value",'');
			inputNazioneNascita.set("v.value",'');
			inputSesso.set("v.value",'');
			inputCodiceFiscale.set("v.value",'');
			inputSae.set("v.value",'600');
			inputTae.set("v.value",'984');
			inputTipoDocumento.set("v.value",'');
			inputNumeroDocumento.set("v.value",'');
			inputLuogoEmissioneDocumento.set("v.value",'');
			inputDataEmissioneDocumento.set("v.value",'');
			inputDataScadenzaDocumento.set("v.value",'');

		}

		else {

			payload  = '[{"nome": "' + inputNome.get("v.value") + '", "cognome": "' + inputCognome.get("v.value") + '", "ruolo": "' + inputRuolo.get("v.value") + '", "telefono": "' + inputTelefono.get("v.value") + '", "mail": "' + inputMail.get("v.value") + '"}]';
		
			var newReferentiTable = referentiTable.concat(JSON.parse(payload));        
         
			component.set('v.jsonREFERENTIData', newReferentiTable);       

			component.set('v.workflowRecordCandidato.REFERENTI_JSON__c', JSON.stringify(newReferentiTable));   

			inputNome.set("v.value",'');
			inputCognome.set("v.value",'');
			inputRuolo.set("v.value",'');
			inputTelefono.set("v.value",'');
			inputMail.set("v.value",'');

		}

    }, 	    

    handleRowActionREFERENTI: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
		if(component.get("v.workflowRecordCandidato.Stato__c") == "BOZZA_DATI"){
			switch (action.name) {
				case 'delete':
					var newReferentiTable = component.get('v.jsonREFERENTIData');
					var rowIndex = newReferentiTable.indexOf(row);
					newReferentiTable.splice(rowIndex, 1);
					component.set('v.jsonREFERENTIData', newReferentiTable);
                
					component.set('v.workflowRecordCandidato.REFERENTI_JSON__c', JSON.stringify(newReferentiTable));  
                
					break;
			}
		}
    },   

	handleNomeSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputNomeSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	 

	handleCognomeSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputCognomeSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	 

	handleRuoloSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputRuoloSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	 

	handleTelefonoSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputTelefonoSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	

	handleMailSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputMailSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	

	handleDataNascitaSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputDataNascitaSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	

	handleLuogoNascitaSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputLuogoNascitaSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	

	handleNazioneNascitaSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputNazioneNascitaSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	

	handleSessoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputSessoSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	

	handleCodiceFiscaleSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputCodiceFiscaleSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	

	handleSaeSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputSaeSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	

	handleTaeSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputTaeSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	

	handleTipoDocumentoSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputTipoDocumentoSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 

	handleNumeroDocumentoSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputNumeroDocumentoSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 

	handleLuogoEmissioneDocumentoSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputLuogoEmissioneDocumentoSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 

	handleDataEmissioneDocumentoSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputDataEmissioneDocumentoSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 

	handleDataScadenzaDocumentoSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputDataScadenzaDocumentoSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 

    handleRecordUpdated : function(component,event,helper){
	
    	var changeType = event.getParams().changeType;

			if (changeType === "LOADED") { 

			var actions = [{ label: 'Rimuovi', name: 'delete' }];

			if(component.get("v.workflowRecordCandidato.Natura_Giuridica__c") == "DI"){
        
				component.set('v.fileRecapColumns', [{label: 'Nome', fieldName: 'nome', type: 'text'}, {label: 'Cognome', fieldName: 'cognome', type: 'text'}, {label: 'CF', fieldName: 'codiceFiscale', type: 'text'}, {label: 'Ruolo Ricoperto', fieldName: 'ruolo', type: 'text'}, {label: 'Contatto Telefonico', fieldName: 'telefono', type: 'text'}, {label: 'Indirizzo Mail', fieldName: 'mail', type: 'text'}, { type: 'action', typeAttributes: { rowActions: actions } }]);

			}

			else {
		
				component.set('v.fileRecapColumns', [{label: 'Nome', fieldName: 'nome', type: 'text'}, {label: 'Cognome', fieldName: 'cognome', type: 'text'}, {label: 'Ruolo Ricoperto', fieldName: 'ruolo', type: 'text'}, {label: 'Contatto Telefonico', fieldName: 'telefono', type: 'text'}, {label: 'Indirizzo Mail', fieldName: 'mail', type: 'text'}, { type: 'action', typeAttributes: { rowActions: actions } }]);

			}
            
            component.set('v.jsonREFERENTIData', JSON.parse(component.get('v.workflowRecordCandidato.REFERENTI_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.REFERENTI_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.REFERENTI_JSON__c','[]');
            	component.set('v.jsonREFERENTIData', JSON.parse(component.get('v.workflowRecordCandidato.REFERENTI_JSON__c')));  
            }

			if(component.get("v.workflowRecordCandidato.Natura_Giuridica__c") == "DI"){
			
				var inputRuolo = component.find("flowInputRuoloSoggettoInputId");
				inputRuolo.set("v.value","Titolare");
				inputRuolo.set("v.disabled", true);

			
			}

		}

	},

    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;    
        
        
        if(!overallValidity){       
            
            return;
            
        }
        else {
  
            component.find("flowRecordHandlerWorkflowCandidatoId").saveRecord($A.getCallback(function(saveResult) {
         
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    
						navigate(event.getParam("action"));
                   
                } else if (saveResult.state === "INCOMPLETE") {
                    
                    console.log("User is offline, device doesn't support drafts.");
                    
                } else if (saveResult.state === "ERROR") {
                    
                    console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                    
                } else {
                    
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                    
                }
            }));   
        }
        
    } 

})