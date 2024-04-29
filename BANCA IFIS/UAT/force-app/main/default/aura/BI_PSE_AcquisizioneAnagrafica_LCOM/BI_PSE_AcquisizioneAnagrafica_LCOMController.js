({
    doInit : function(component,event,helper){
		
    },

    handleComboNaturaGiuridicaChange : function(component,event,helper){


    }, 
    
    handleComboTipoIndirizzoChange : function(component,event,helper){


    }, 

    handleComboProvinciaCCIAAChange : function(component,event,helper){


    }, 

    handleRecordUpdated : function(component,event,helper){
		
    },     
        
    handleNavigate: function(component, event , helper) {

        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;
        
        // VERIFICA DELLA SEZIONE DATI PRINCIPALI        
        
        if(!component.find("flowInputAnagraficaRagioneSocialeInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaRagioneSocialeInputId").reportValidity();
            
        }

		/*
        
        if(!component.find("flowInputAnagraficaCCIAAInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaCCIAAInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputAnagraficaREAInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaREAInputId").reportValidity();
            
        }

        if(!component.find("flowInputAnagraficaSaeInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaSaeInputId").reportValidity();
            
        }

        if(!component.find("flowInputAnagraficaRaeInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaRaeInputId").reportValidity();
            
        }

        if(!component.find("flowInputAnagraficaAtecoInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaAtecoInputId").reportValidity();
            
        }
        
        // VERIFICA DELLA SEZIONE INDIRIZZI
               
        if(!component.find("flowInputAnagraficaViaLegaleInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaViaLegaleInputId").reportValidity();
            
        }  

        if(!component.find("flowInputAnagraficaCivicoLegaleInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaCivicoLegaleInputId").reportValidity();
            
        }  

        if(!component.find("flowInputAnagraficaCittaLegaleInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaCittaLegaleInputId").reportValidity();
            
        }  

        if(!component.find("flowInputAnagraficaCapLegaleInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaCapLegaleInputId").reportValidity();
            
        }  

        if(!component.find("flowInputAnagraficaProvinciaLegaleInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputAnagraficaProvinciaLegaleInputId").reportValidity();
            
        }  

		*/
            
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