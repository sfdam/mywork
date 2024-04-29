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
        
        if(!component.find("flowInputImportoInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputImportoInputId").reportValidity();
            
        }        
          
        
        if(!component.find("flowInputCorrispettiviFactoringInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputCorrispettiviFactoringInputId").reportValidity();
            
        }   

        if(!component.find("flowInputImportoMassimoComplessivoFactoringInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputImportoMassimoComplessivoFactoringInputId").reportValidity();
            
        }   
        
        if(!component.find("flowInputScadenzaInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputScadenzaInputId").reportValidity();
            
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