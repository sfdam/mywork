({
    doInit : function(component,event,helper){
         
    },  
    
    handleRecordUpdated : function(component,event,helper){
        
    },    
    
    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;
        
        // VERIFICA DELLA SEZIONE DATI RELATIVI ALLA PAGINA      
        
        if(!component.find("flowInputFatturatoInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputFatturatoInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputFatturatoAnnoPrecedenteInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputFatturatoAnnoPrecedenteInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputEbitdaInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputEbitdaInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputOneriFinanziariInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputOneriFinanziariInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputPFNInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputPFNInputId").reportValidity();
            
        }
           
        if(!component.find("flowInputPFInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputPFInputId").reportValidity();
            
        }        
           
        if(!component.find("flowInputPassivitaTotaliInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputPassivitaTotaliInputId").reportValidity();
            
        }     
           
        if(!component.find("flowInputPassivitaCorrentiInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputPassivitaCorrentiInputId").reportValidity();
            
        }  
           
        if(!component.find("flowInputDebitiComplessiviInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputDebitiComplessiviInputId").reportValidity();
            
        }  
           
        if(!component.find("flowInputDSOInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputDSOInputId").reportValidity();
            
        } 
           
        if(!component.find("flowInputDIOHInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputDIOHInputId").reportValidity();
            
        } 
           
        if(!component.find("flowInputLiquiditaImmediateInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputLiquiditaImmediateInputId").reportValidity();
            
        } 
           
        if(!component.find("flowInputLiquiditaDifferiteInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputLiquiditaDifferiteInputId").reportValidity();
            
        } 
        
        if(!overallValidity){       
            
            return;
            
        }
        else {     
            
            if(!component.get('v.componenteSolaLettura')){
            
                component.find("flowRecordHandlerWorkflowCandidatoId").saveRecord($A.getCallback(function(saveResult) {
                    
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        
                        try{
                            navigate(event.getParam("action"));
                        }
                        catch(error){
                            console.log("Error navigating to the next step: " + error);    
                        }
                        
                    } else if (saveResult.state === "INCOMPLETE") {
                        
                        console.log("User is offline, device doesn't support drafts.");
                        
                    } else if (saveResult.state === "ERROR") {
                        
                        console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                        
                    } else {
                        
                        console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                        
                    }
                }));       
            }
            else {
						navigate(event.getParam("action"));                
            }
            
        }
    }
    
})