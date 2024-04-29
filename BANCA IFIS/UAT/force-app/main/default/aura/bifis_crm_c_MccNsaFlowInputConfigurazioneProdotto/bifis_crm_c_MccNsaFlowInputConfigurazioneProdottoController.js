({
    doInit : function(component,event,helper){
        
   
        
    },  
	 
    handleRadioGroupLineaChange : function(component,event,helper){
	
		helper.calculateFieldVisibility(component,event);
		 
		helper.calculateValuesVisibility(component,event);

		helper.calculateAmmortamentoStandard(component,event);
		helper.calculateAmmortamentoAssicurativo(component,event);


    },
    
    copyToFloorStandard : function(component,event,helper){

		component.find("flowInputFloorInputId").set("v.value",component.find("flowInputSpreadPositivoInputId").get("v.value"));

    },  

    copyToFloorAssicurativo : function(component,event,helper){

		component.find("flowInputFloorSAInputId").set("v.value",component.find("flowInputSpreadPositivoSAInputId").get("v.value"));

    },  
    
    calculateAmmortamentoStandard : function(component,event,helper){
			
		helper.calculateAmmortamentoStandard(component,event);
	
	},

    calculateAmmortamentoAssicurativo : function(component,event,helper){
			
		helper.calculateAmmortamentoAssicurativo(component,event);
	
	},

    calculateExpenses : function(component,event,helper){

		helper.calculateExpenses(component,event);  

    }, 

    handleRecordUpdated : function(component,event,helper){

        var eventParams = event.getParams();

        if(eventParams.changeType === "LOADED") {

			helper.calculateFieldVisibility(component,event);

			helper.calculateValuesVisibility(component,event);
		
			helper.calculateAmmortamentoStandard(component,event);
			helper.calculateAmmortamentoAssicurativo(component,event); 

        } 


    },     
    
    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;
        
        // VERIFICA DELLA SEZIONE DATI RELATIVI ALLA PAGINA      
        
        if(!component.find("flowInputImportoMutuoInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputImportoMutuoInputId").reportValidity();
            
        }

        if(!component.find("flowInputImportoMutuoSAInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputImportoMutuoSAInputId").reportValidity();
            
        }
          
          
        if(!component.find("flowInputDurataPreAmmortamentoMutuoInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputDurataPreAmmortamentoMutuoInputId").reportValidity();
            
        }

        if(!component.find("flowInputDurataPreAmmortamentoMutuoSAInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputDurataPreAmmortamentoMutuoSAInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputDurataTotaleMutuoInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputDurataTotaleMutuoInputId").reportValidity();
            
        }

        if(!component.find("flowInputDurataTotaleMutuoSAInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputDurataTotaleMutuoSAInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputFinalitaMutuoInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputFinalitaMutuoInputId").reportValidity();
            
        }

        if(!component.find("flowInputFinalitaMutuoSAInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputFinalitaMutuoSAInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputSpreadPositivoInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputSpreadPositivoInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputTassoRiferimentoInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputTassoRiferimentoInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputFloorInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputFloorInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputSpeseIstruttoriaInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputSpeseIstruttoriaInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputSpeseCommissioneInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputSpeseCommissioneInputId").reportValidity();
            
        }
        
        if(!component.find("flowInputSpeseCommissioneSAInputId").get("v.validity").valid){
            
            overallValidity = false;
            
            component.find("flowInputSpeseCommissioneSAInputId").reportValidity();
            
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