({
    doInit : function(component, event, helper) {    

		helper.fetchWorkflowsMCCForHomePage(component,event, '');

    },
    
    openModifyWorkflow: function(component, event, helper) {
        
        var currentTarget = event.currentTarget;   

        component.set("v.isMainFlowOpen", true);
        component.set("v.modifiableWorkflowId", currentTarget.dataset.id);
        
        component.set("v.modalWindowTitle", "MODIFICA PRATICA IN BOZZA");        
        
        var workflowId = component.get("v.modifiableWorkflowId");
        
        var flow = component.find("AcquisizioneMutuo");
        
        var flowInputVariables = [
          {
            name : 'recordIDCandidato',
            type : 'String',
            value : workflowId
          }
        ];        
        
        flow.startFlow("AcquisizioneMutuo",flowInputVariables);
        
    },      
    
    openDeleteWorkflow: function(component, event, helper) {
		var currentTarget = event.currentTarget;   
        component.set("v.isDeleteFlowOpen", true);
        component.set("v.deletableWorkflowId", currentTarget.dataset.id);
        
        component.set("v.modalWindowTitle", "ELIMINA PRATICA IN BOZZA");        
        
    },    
    
    closeDeleteWorkflow: function(component, event, helper) {
        
        component.set("v.deletableWorkflowId", "");
        component.set("v.isDeleteFlowOpen", false);
    },    

    executeDeleteWorkflow: function(component, event, helper) {
        
        component.set("v.isDeleteFlowOpen", false);
        
        var workflowId = component.get("v.deletableWorkflowId");
        
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c.deleteWorkflowMutuiForHomePage");
            
            action.setParams({
                workflowId : workflowId
            });
                    
            action.setCallback( this , function(callbackResult) {

                if(callbackResult.getState()=='SUCCESS') {
                    resolve( 
                        callbackResult.getReturnValue()
                    );

					var resultState = callbackResult.getReturnValue();

                    $A.get('event.force:refreshView').fire();
                    
                    var toastEvent = $A.get("event.force:showToast");

					if(resultState){
						toastEvent.setParams({
							title : 'Pratica IN BOZZA eliminata',
							message: 'La pratica selezionata è stata eliminata con successo.',
							duration:' 5000',
							key: 'info_alt',
							type: 'success',
							mode: 'pester'
						});
					}

					else{
						toastEvent.setParams({
							title : 'Errore Tecnico',
							message: 'Si è verificato un errore nell esecuzione dell operazione.',
							duration:' 5000',
							key: 'info_alt',
							type: 'error',
							mode: 'pester'
						});
					}
                    
                    toastEvent.fire();   
                    
                    component.set("v.deletableWorkflowId", "");
                    
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));    
        
        return promise;
        
    },    
    
    openNewWorkflow: function(component, event, helper) {
    
        component.set("v.isMainFlowOpen", true);
        component.set("v.modalWindowTitle", "CREA NUOVA PRATICA");
        
        var flow = component.find("AcquisizioneMutuo");
        
        var flowInputVariables = [
          {
            name : 'recordIDCandidato',
            type : 'String',
            value : 'NO_RECORD_ID'
          }
        ];        

        flow.startFlow("AcquisizioneMutuo",flowInputVariables);
    },
    
    closeNewAndModifyWorkflow: function(component, event, helper) {

        component.set("v.isMainFlowOpen", false);
        
		$A.get('event.force:refreshView').fire();
        
    }, 
    
    statusChange : function(component, event, helper) {
       
    },
    
    handleChange: function (component, event, helper) {
        
        var valoreFiltroRicerca = component.get('v.valoreFiltroRicerca');

        if (valoreFiltroRicerca.length <= 2){

			helper.fetchWorkflowsMCCForHomePage(component,event, '');
            
        }
        
        if (valoreFiltroRicerca.length > 2){
            
			helper.fetchWorkflowsMCCForHomePage(component,event, valoreFiltroRicerca);
            
        }
        
    }   
})