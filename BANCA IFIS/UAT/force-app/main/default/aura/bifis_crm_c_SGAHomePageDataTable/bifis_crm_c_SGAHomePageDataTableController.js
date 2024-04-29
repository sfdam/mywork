({
    doInit : function(component, event, helper) {    

		helper.fetchWorkflowsSGAForHomePage(component,event, '');
        
    },
   
    openModifyWorkflow: function(component, event, helper) {
        
        var currentTarget = event.currentTarget;        

        component.set("v.isMainFlowOpen", true);
        component.set("v.modifiableWorkflowId", currentTarget.dataset.id);
        
        component.set("v.modalWindowTitle", "MODIFICA PRATICA");        
        
        var workflowId = component.get("v.modifiableWorkflowId");
        
        var flow = component.find("AcquisizioneSGA");
        
        var flowInputVariables = [
          {
            name : 'recordIDCandidato',
            type : 'String',
            value : workflowId
          },
          {
            name : 'flowStatoIngresso',
            type : 'String',
            value : currentTarget.dataset.actualstate
          }            
        ];        
        
        flow.startFlow("AcquisizioneSGA",flowInputVariables);
        
    },      

    openDeleteWorkflow: function(component, event, helper) {

        var currentTarget = event.currentTarget;             
        
        component.set("v.isDeleteFlowOpen", true);
        component.set("v.deletableWorkflowId", currentTarget.dataset.id);
        
        component.set("v.modalWindowTitle", "ELIMINA PRATICA");        
        
    },    
    
    closeDeleteWorkflow: function(component, event, helper) {
        
        component.set("v.deletableWorkflowId", "");
        component.set("v.isDeleteFlowOpen", false);
    },    

    executeDeleteWorkflow: function(component, event, helper) {
        
        component.set("v.isDeleteFlowOpen", false);
        
        var workflowId = component.get("v.deletableWorkflowId");
        
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c.deleteWorkflowSGAForHomePage");
            
            action.setParams({
                workflowId : workflowId
            });
                    
            action.setCallback( this , function(callbackResult) {

                if(callbackResult.getState()=='SUCCESS') {
                    resolve( 
                        callbackResult.getReturnValue()
                    );
                    
                    $A.get('event.force:refreshView').fire();
                    
                    var toastEvent = $A.get("event.force:showToast");
                    toastEvent.setParams({
                        title : 'Pratica ELIMINATA',
                        message: 'La pratica selezionata è stata eliminata con successo.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    
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
        
        var flow = component.find("AcquisizioneSGA");
        
        var flowInputVariables = [
          {
            name : 'recordIDCandidato',
            type : 'String',
            value : 'NO_RECORD_ID'
          },
          {
            name : 'flowStatoIngresso',
            type : 'String',
            value : 'SEGNALAZIONE POSIZIONE'
          }   
        ];        

        flow.startFlow("AcquisizioneSGA",flowInputVariables);
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

			helper.fetchWorkflowsSGAForHomePage(component,event, '');
            
        }
        
        if (valoreFiltroRicerca.length > 2){
            
			helper.fetchWorkflowsSGAForHomePage(component,event, valoreFiltroRicerca);
            
        }
        
    }    
})