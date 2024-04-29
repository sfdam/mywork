({
    doInit : function(component,event,helper){
        
		// VERIFICA INTEGRAZIONE DATI 

		var flowValidatorPartitaIvaResult = component.get('v.flowValidatorPartitaIvaResult');

		var flowInputPartitaIva = component.get('v.flowInputPartitaIva');

		var flowActualAccount = component.get('v.flowActualAccount');
        
		try{

			var userId = $A.get( "$SObjectType.CurrentUser.Id" );
			var ricerca = component.get("c.ricercaEnteSegnalante");
			ricerca.setParams({
				ownerId: userId
			});

			ricerca.setCallback( this , function(callbackResult) {
				if(callbackResult.getState()=='SUCCESS') {
					var resultState = callbackResult.getReturnValue();
					//console.log('@@@@ trovato: ' + resultState.esitoGlobale); 
					//console.log('@@@@ trovato: ' + resultState.idAccountCreato);
					//console.log('@@@@ trovato: ' + resultState.nomeAccountCreato);
					
					if(resultState.esitoGlobale){
						component.set('v.flowValidatorCodiceSegnalatore',resultState.idAccountCreato);
						component.set('v.flowValidatorNomeSegnalatore',resultState.nomeAccountCreato);

					} else {
						component.set('v.flowValidatorCodiceSegnalatore','');
						component.set('v.flowValidatorNomeSegnalatore','');
					}
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                }
			});
			$A.enqueueAction( ricerca );
			console.log('flowActualAccount ', flowActualAccount.WGC_Censimento__c);
			if($A.util.isEmpty(flowActualAccount) || flowActualAccount.WGC_Censimento__c != 'Completo'){
			
				// VERIFICA PUNTUALE DEI CAMPI NECESSARI AL CENSIMENTO FULL PER CAPIRE QUALI RICHIEDERE

				if(!$A.util.isEmpty(flowActualAccount)){

					flowActualAccount.PIVA__c = flowInputPartitaIva;

					if(flowActualAccount.NaturaGiuridica__c == null || flowActualAccount.NaturaGiuridica__c != 'DI'){
						flowActualAccount.CF__c = flowInputPartitaIva;
						component.set('v.defSAE', flowActualAccount.SAE__c);
					}

					// SDCHG-5735 -> valore di default del SAE se vuoto per DI
					if (flowActualAccount.NaturaGiuridica__c == 'DI' && $A.util.isEmpty(flowActualAccount.SAE__c))
						flowActualAccount.SAE__c = '615';

					// TRAVASO DI COMODO DEI CAMPI ANALIZZABILI SU VARIABILI PUNTUALI

					component.set('v.localSAE',flowActualAccount.SAE__c);
					//component.set('v.localRAE',flowActualAccount.RAE__c);
					component.set('v.localREA',flowActualAccount.REA__c);
					component.set('v.localAteco',flowActualAccount.Ateco__c);
					component.set('v.localBillingStreetType',flowActualAccount.BillingStreetType__c);
					component.set('v.localBillingStreet',flowActualAccount.BillingStreetName__c);
					component.set('v.localBillingStreetNumber',flowActualAccount.BillingStreetNumber__c);
					component.set('v.localBillingPostalCode',flowActualAccount.BillingPostalCode);
					component.set('v.localBillingCity',flowActualAccount.BillingCity);
					component.set('v.localBillingState',flowActualAccount.BillingState);
					component.set('v.localBillingCountry',flowActualAccount.BillingCountry);
					component.set('v.localProvinciaCCIAA',flowActualAccount.ProvinciaCCIAA__c);
					
                    
                    
					if($A.util.isEmpty(flowActualAccount.Name)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.Name non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.PIVA__c)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.PIVA__c non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.CF__c)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.CF__c non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.SAE__c)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.SAE__c non valorizzato');

					}
					/*if($A.util.isEmpty(flowActualAccount.RAE__c)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.ProvinciaCCIAA__c non valorizzato');
					}*/
					if($A.util.isEmpty(flowActualAccount.REA__c)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.REA__c non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.Ateco__c)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.Ateco__c non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.BillingStreetType__c)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.BillingStreetType__c non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.BillingStreetName__c)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.BillingStreetName__c non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.BillingStreetNumber__c)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.BillingStreetNumber__c non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.BillingPostalCode)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.BillingPostalCode non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.BillingCity)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.BillingCity non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.BillingState)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.BillingState non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.BillingCountry)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.BillingCountry non valorizzato');
					}
					if($A.util.isEmpty(flowActualAccount.ProvinciaCCIAA__c)){
						component.set('v.necessariaIntegrazione',true);
						console.log('flowActualAccount.ProvinciaCCIAA__c non valorizzato');
					}
				}
				else{
					component.set('v.necessariaIntegrazione',true);
					flowActualAccount.PIVA__c = flowInputPartitaIva;
					console.log('flowActualAccount non valorizzato');
				}
			} 
		}
		catch(ex){
			console.error(ex.message);
		}
				

    }, 
    
    handleComboTipoIndirizzoChange : function(component,event,helper){

    }, 
    
    handleComboProvinciaChange : function(component,event,helper){

    }, 

	handleComboNaturaGiuridicaChange : function(component,event,helper){

		var naturaGiuridica = component.get('v.flowActualAccount.NaturaGiuridica__c');

		if(naturaGiuridica == 'DI'){
			component.set('v.flowActualAccount.CF__c',null);
			// SDCHG-5735 -> Per DI valore di default del SAE se vuoto
			var sae = component.get('v.flowActualAccount.SAE__c');
			if (sae == '' || sae == null){
				component.set('v.flowActualAccount.SAE__c','615');
				component.set('v.localSAE','615');
			}
		} else {
			component.set('v.flowActualAccount.CF__c',component.get('v.flowActualAccount.PIVA__c'));
			var sae = component.get('v.defSAE');
			// SDCHG-5735 -> Per DI valore di default del SAE se vuoto
			component.set('v.flowActualAccount.SAE__c',sae);
			component.set('v.localSAE',sae);
		}

    },    
    
    handleRecordUpdated : function(component,event,helper){

    },    
    
    handleNavigate: function(component, event , helper) {
        
		var flowActualAccount = component.get('v.flowActualAccount');

        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;

		if(component.find("flowInputAnagraficaPartitaIvaInputId") && !component.find("flowInputAnagraficaPartitaIvaInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaPartitaIvaInputId").reportValidity();
            
		}

		if(component.find("flowInputAnagraficaCodiceFiscaleInputId") && !component.find("flowInputAnagraficaCodiceFiscaleInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaCodiceFiscaleInputId").reportValidity();
            
		}

		if(component.find("flowInputAnagraficaNaturaGiuridicaInputId") && !component.find("flowInputAnagraficaNaturaGiuridicaInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaNaturaGiuridicaInputId").reportValidity();
            
		}

		if(component.find("flowInputAnagraficaIntestazioneInputId") && !component.find("flowInputAnagraficaIntestazioneInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaIntestazioneInputId").reportValidity();
            
		}
	
		if(component.find("flowInputAnagraficaSaeInputId") && !component.find("flowInputAnagraficaSaeInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaSaeInputId").reportValidity();
            
		}


		/*if(component.find("flowInputAnagraficaRaeInputId") && !component.find("flowInputAnagraficaRaeInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaRaeInputId").reportValidity();
            
		}*/

		if(component.find("flowInputAnagraficaReaInputId") && !component.find("flowInputAnagraficaReaInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaReaInputId").reportValidity();
            
		}

		if(component.find("flowInputAnagraficaAtecoInputId") && !component.find("flowInputAnagraficaAtecoInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaAtecoInputId").reportValidity();
            
		}

		if(component.find("flowInputAnagraficaTipoViaLegaleInputId") && !component.find("flowInputAnagraficaTipoViaLegaleInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaTipoViaLegaleInputId").reportValidity();
            
		}

		if(component.find("flowInputAnagraficaViaLegaleInputId") && !component.find("flowInputAnagraficaViaLegaleInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaViaLegaleInputId").reportValidity();
            
		}
		
		if(component.find("flowInputAnagraficaCivicoLegaleInputId") && !component.find("flowInputAnagraficaCivicoLegaleInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaCivicoLegaleInputId").reportValidity();
            
		}

		if(component.find("flowInputAnagraficaCapLegaleInputId") && !component.find("flowInputAnagraficaCapLegaleInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaCapLegaleInputId").reportValidity();
            
		}

		if(component.find("flowInputAnagraficaCittaLegaleInputId") && !component.find("flowInputAnagraficaCittaLegaleInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaCittaLegaleInputId").reportValidity();
            
		}
  
		if(component.find("flowInputAnagraficaProvinciaLegaleInputId") && !component.find("flowInputAnagraficaProvinciaLegaleInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaProvinciaLegaleInputId").reportValidity();
            
		}

  
		if(component.find("flowInputAnagraficaNazioneLegaleInputId") && !component.find("flowInputAnagraficaNazioneLegaleInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaNazioneLegaleInputId").reportValidity();
            
		}

		if(component.find("flowInputAnagraficaProvinciaCCIAAInputId") && !component.find("flowInputAnagraficaProvinciaCCIAAInputId").get("v.validity").valid){
            
			overallValidity = false;
            
			component.find("flowInputAnagraficaProvinciaCCIAAInputId").reportValidity();
            
		}
		      
        if(!overallValidity){       
            
            return;
            
        }

        else {

			navigate(event.getParam("action"));     
            
        }
    } 

})