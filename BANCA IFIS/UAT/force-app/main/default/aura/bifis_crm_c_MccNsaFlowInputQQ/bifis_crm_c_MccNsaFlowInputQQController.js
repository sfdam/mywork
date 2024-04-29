({
    doInit : function(component,event,helper){
        
    },     
    
    handleRecordUpdated : function(component,event,helper){
        
    	var changeType = event.getParams().changeType;
		 
		if (changeType === "LOADED") { 
        
			var fatturato = component.get('v.workflowRecordCandidato.Fatturato__c');

			if(!component.find("flowInputAnagraficaFatturatoInputId").get("v.validity").valid || fatturato == null || fatturato == ''){
				
				fatturato = null;

				component.set('v.tipologiaQuestionarioVar', null);
		
			} 
		
			else{

				helper.fetchQQType(component, event, fatturato);

			}

			component.set('v.workflowRecordCandidato.TipologiaQuestionario__c',component.get('v.tipologiaQuestionarioVar'));
        
        }        
        
    },     

    handleChange: function (component, event, helper) {

		var fatturato = component.get('v.workflowRecordCandidato.Fatturato__c');

			if(!component.find("flowInputAnagraficaFatturatoInputId").get("v.validity").valid || fatturato == null || fatturato == ''){

			fatturato = null;

			component.set('v.tipologiaQuestionarioVar', null);
		
		} 
		
		else{

			helper.fetchQQType(component, event, fatturato);

		}

		component.set('v.workflowRecordCandidato.TipologiaQuestionario__c',component.get('v.tipologiaQuestionarioVar'));

	},
    
    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;
        
        // VERIFICA DELLA SEZIONE DATI PRINCIPALI        
        
        if(!component.find("flowInputAnagraficaFatturatoInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaFatturatoInputId").reportValidity();
            
        }   
        
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