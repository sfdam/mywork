({
    doInit : function(component,event,helper){
        
        var actions = [{ label: 'Rimuovi', name: 'delete' }];
        
        component.set('v.fileRecapColumns', [{label: 'Nome', fieldName: 'nome', type: 'text'}, {label: 'Cognome', fieldName: 'cognome', type: 'text'}, {label: 'Codice Fiscale', fieldName: 'codiceFiscale', type: 'text'}, {label: 'Ruolo', fieldName: 'ruolo', type: 'text'}, {label: 'Tipologia Titolare Effettivo', fieldName: 'tipologiaTE', type: 'text'}, { type: 'action', typeAttributes: { rowActions: actions } }]);
    },  
	
    handleComboRuoloChange : function(component,event,helper){

		var aggiuntaRuolo = component.get("v.aggiuntaRuolo");
	
		if(aggiuntaRuolo.includes('Titolare')){
		
			component.find("flowInputTipologiaTitolareEffettivoInputId").set("v.disabled", false);

		}
		else {

			component.set("v.aggiuntaTipologiaTitolareEffettivo", "");

			component.find("flowInputTipologiaTitolareEffettivoInputId").set("v.disabled", true);
		}

    }, 
    
    handleComboTipologiaTEChange : function(component,event,helper){


    }, 	    
    
	handleAddUserClick : function(component,event,helper){

		var inputNome = component.find("flowInputNomeSoggettoInputId");
		var inputCognome = component.find("flowInputCognomeSoggettoInputId");
		var inputCF = component.find("flowInputCFSoggettoInputId");
		var inputRuolo = component.find("flowInputRuoloInputId");
		var inputTE = component.find("flowInputTipologiaTitolareEffettivoInputId");

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

		if($A.util.isEmpty(inputCF.get("v.value"))){
		
			inputCF.setCustomValidity("Dato del Referente richiesto");
			inputCF.reportValidity();

			overallValidity = false;

		}

		if($A.util.isEmpty(inputRuolo.get("v.value"))){
	
			inputRuolo.setCustomValidity("Dato del Referente richiesto");
			inputRuolo.reportValidity();

			overallValidity = false;

		}

		if($A.util.isEmpty(inputTE.get("v.value")) && !inputTE.get("v.disabled")){
	
			inputTE.setCustomValidity("Dato del Referente richiesto");
			inputTE.reportValidity();

			overallValidity = false;

		}
	
		if(!overallValidity){
		
			return;

		}

        var referentiTable = component.get('v.jsonREFERENTIData');

		var payload = '[{"nome": "' + inputNome.get("v.value") + '", "cognome": "' + inputCognome.get("v.value") + '", "codiceFiscale": "' + inputCF.get("v.value") + '", "ruolo": "' + inputRuolo.get("v.value") + '", "tipologiaTE": "' + inputTE.get("v.value") + '"}]';

        var newReferentiTable = referentiTable.concat(JSON.parse(payload));        
         
        component.set('v.jsonREFERENTIData', newReferentiTable);       

        component.set('v.workflowRecordCandidato.REFERENTI_JSON__c', JSON.stringify(newReferentiTable));   

		inputNome.set("v.value",'');
		inputCognome.set("v.value",'');
		inputCF.set("v.value",'');
		inputRuolo.set("v.value",'');
		inputTE.set("v.value",'');


    }, 	    

    handleRowActionREFERENTI: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newReferentiTable = component.get('v.jsonREFERENTIData');
                var rowIndex = newReferentiTable.indexOf(row);
                newReferentiTable.splice(rowIndex, 1);
                component.set('v.jsonREFERENTIData', newReferentiTable);
                
                component.set('v.workflowRecordCandidato.REFERENTI_JSON__c', JSON.stringify(newReferentiTable));  
                
                break;
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

	handleCFSoggettoBlur: function(component,event,helper){

		var inputNome = component.find("flowInputCFSoggettoInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	 

	handleRuoloBlur: function(component,event,helper){

		var inputNome = component.find("flowInputRuoloInputId")

		inputNome.setCustomValidity("");
		inputNome.reportValidity();

    }, 	

	handleTipologiaTEBlur: function(component,event,helper){

		var inputTipologiaTE = component.find("flowInputTipologiaTitolareEffettivoInputId")

		inputTipologiaTE.setCustomValidity("");
		inputTipologiaTE.reportValidity();

    }, 	

    handleRecordUpdated : function(component,event,helper){
	
    	var changeType = event.getParams().changeType;

		if (changeType === "LOADED") { 
            
            component.set('v.jsonREFERENTIData', JSON.parse(component.get('v.workflowRecordCandidato.REFERENTI_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.REFERENTI_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.REFERENTI_JSON__c','[]');
            	component.set('v.jsonREFERENTIData', JSON.parse(component.get('v.workflowRecordCandidato.REFERENTI_JSON__c')));  
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