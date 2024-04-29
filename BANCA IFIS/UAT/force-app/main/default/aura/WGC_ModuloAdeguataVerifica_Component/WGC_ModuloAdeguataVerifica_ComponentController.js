({
	doInit : function(component, event, helper) {
        var action = component.get('c.getMAV');
        action.setParams({
            accountId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue();
                console.log('@@@ risposta ' , risposta);
                if(risposta != null || risposta != undefined){
                    component.set('v.modulo', risposta);
					// component.set("v.VisitaLocaliAzienda", risposta.Account__r.WGC_Visita_Locali_Azienda__c);
                }
                
                component.set('v.isLoaded', true);
            }
        });
        $A.enqueueAction(action);

		helper.caricaNazioni(component, event, helper);
		helper.caricaProvince(component, event, helper);
		helper.getProfilo(component, event, helper);

		var recuperaDatiMavAccount = component.get('c.getDatiMavAccount');
        recuperaDatiMavAccount.setParams({
            accountId : component.get('v.recordId')
        });
        recuperaDatiMavAccount.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue();
                console.log('@@@ recuperaDatiMavAccount ' , risposta);
                if(risposta != null || risposta != undefined){
					component.set('v.infoMav', risposta);
                }
            }
			var profilo = component.get('v.profilo');
			// inserisco qua la chiamata altrimenti non ho disponibile l'aura id dell'oggetto - carico le picklist in base al profilo
			// if (profilo != 'IFIS - Crediti Erariali')
			// 			// 	helper.caricaScopiRapporto(component, event, helper);
			// 			// else
			// 			// 	helper.caricaNaturaCreditiErariali(component, event, helper);

			//PALUMBO 05/02/2020 - inserita logica per tipologia di MAV
			var tipologiaMAV = component.get("v.tipologiaMav");
			if ((tipologiaMAV == 'standard' && profilo != 'IFIS - Crediti Erariali') || tipologiaMAV == 'CC'){
				helper.caricaScopiRapporto(component, event, helper);
			}else if (tipologiaMAV == 'CE' || tipologiaMAV == 'standard' && profilo == 'IFIS - Crediti Erariali') {
				helper.caricaNaturaCreditiErariali(component, event, helper);
			}
        });
        $A.enqueueAction(recuperaDatiMavAccount);
	},

	onGroup : function(component, event, helper){
		var selected = event.getSource().get("v.label");
		var nm = event.getSource().get("v.name");
		if(selected == "Si"){
			selected = true;
		}
		if(selected == "No"){
			selected = false;
		}
		('OrigineFondi1__c' == nm && selected) ? component.set('v.modulo.OrigineFondi1__c', true) : component.set('v.modulo.OrigineFondi1__c', false);
		('OrigineFondi2__c' == nm && selected) ? component.set('v.modulo.OrigineFondi2__c', true) : component.set('v.modulo.OrigineFondi2__c', false);
		('OrigineFondi3__c' == nm && selected) ? component.set('v.modulo.OrigineFondi3__c', true) : component.set('v.modulo.OrigineFondi3__c', false);
		('OrigineFondi4__c' == nm && selected) ? component.set('v.modulo.OrigineFondi4__c', true) : component.set('v.modulo.OrigineFondi4__c', false);
		if ('OrigineFondi4__c' != nm)
			component.set('v.modulo.OrigineFondiAltro__c', '');
	},	
	//FACTORY SV START
	onGroupEconomic : function(component, event){
		var selected = event.getSource().get("v.label");
		var nm = event.getSource().get("v.name");

		if(selected == "Si"){
			selected = true;
		}
		if(selected == "No"){
			selected = false;
		}
		('WGC_Rapporto_Profilo_economico__c' == nm && selected) ? component.set('v.modulo.WGC_Rapporto_Profilo_economico__c', true) : component.set('v.modulo.WGC_Rapporto_Profilo_economico__c', false);
	},

	onChangeWGC_Emissioni_di_Azioni_al_Portatore_PNF__c : function(component,event){
		var selected = event.getSource().get("v.label");
		var datiMav = component.get("v.infoMav");

		if(selected == "Si"){
			datiMav.WGC_Emissioni_di_Azioni_al_Portatore_PNF__c = true;
		}
		if(selected == "No"){
			datiMav.WGC_Emissioni_di_Azioni_al_Portatore_PNF__c = false;
		}
		component.set("v.infoMav",datiMav);
	},
	onChangeWGC_Soggetti_Partecipanti__c : function(component,event){
		var selected = event.getSource().get("v.label");
		var datiMav = component.get("v.infoMav");

		if(selected == "Si"){
			datiMav.WGC_Soggetti_Partecipanti__c = true;
		}
		if(selected == "No"){
			datiMav.WGC_Emissioni_di_Azioni_al_Portatore_PNF__c = false;
		}
		component.set("v.infoMav",datiMav);
	},
	onChangeWGC_Assetti_Attivita_Svolta__c : function(component,event){
		var selected = event.getSource().get("v.label");
		var datiMav = component.get("v.infoMav");

		if(selected == "Si"){
			datiMav.WGC_Assetti_Attivita_Svolta__c = true;
		}
		if(selected == "No"){
			datiMav.WGC_Assetti_Attivita_Svolta__c = false;
		}
		component.set("v.infoMav",datiMav);
	},

	changePartecipata : function(component,event){
		var selected = event.getSource().get("v.value");
		console.log('SV selected partecipata: ',selected);
		var datiMav = component.get("v.infoMav");
		datiMav.WGC_Partecipazione_societa_fiduciarie__c = selected
		component.set("v.infoMav",datiMav);

		if(selected != "00"){
			component.set("v.hideTipoSede", false);
		}else{
			component.set("v.hideTipoSede",true);
		}

	},
	//FACTORY SV END
	close : function(component, event, helper){
		var lib = component.find('overlayLib');
		lib.notifyClose();
	},

	saveRecord : function(component, event, helper){
        //Setto il flag per eseguire il salvataggio sul componente dei titolari esecutori
        component.set("v.saveReferenti", true);
        //component.set("v.isLoaded", false);
    },
    
    handleSaveTitolareEffettivo : function(component, event, helper){
        var parametriTitolareEsecutivo = event.getParams();
        console.log('@@@ parametri ' , JSON.stringify(parametriTitolareEsecutivo));
        
        if(parametriTitolareEsecutivo.success){
            //component.set("v.saveReferenti", true);
            component.set("v.saveReferenti", false);
            component.set("v.isLoaded", false);
            helper.salvaModulo(component, event, helper, parametriTitolareEsecutivo.json);
        }
        else if(!parametriTitolareEsecutivo.success && parametriTitolareEsecutivo.json.anagNotCompleted){
            component.set("v.saveReferenti", false);
            component.find('overlayLib').notifyClose();
        }
        else if(!parametriTitolareEsecutivo.success && parametriTitolareEsecutivo.json.relation == null && parametriTitolareEsecutivo.json.flagConsensi == null){
            component.set("v.saveReferenti", false);
            //component.find('overlayLib').notifyClose();
        }
        else{
            component.set("v.saveReferenti", false);

            component.set("v.isLoaded", true);
        }
    },

	onChangePaeseCasaMadre : function(component, event, helper){
		var paeseCasaMadre = event.getSource().get("v.value");
		var datiMav = component.get('v.infoMav');

		datiMav.PaeseCasaMadre__c = paeseCasaMadre;
		component.set("v.infoMav", datiMav);
	},

	onChangePaeseSvolgimentoAttivitaPrevalente : function(component, event, helper){
		var PaeseSvolgimentoAttivitaPrevalente = event.getSource().get("v.value");
		var datiMav = component.get('v.infoMav');

		datiMav.PaeseSvolgimentoAttivitaPrevalente__c = PaeseSvolgimentoAttivitaPrevalente;
		component.set("v.infoMav", datiMav);
	},

	onChangeProvinciaSvolgimentoAttivitaPrevalente : function(component, event, helper){
		var ProvinciaSvolgimentoAttivitaPrevalente = event.getSource().get("v.value");
		var datiMav = component.get('v.infoMav');

		datiMav.ProvinciaSvolgimentoAttivitaPrevalente__c = ProvinciaSvolgimentoAttivitaPrevalente;
		component.set("v.infoMav", datiMav);
	},

	onChangeToggle : function(component, event, helper){
		var value = event.getSource().get("v.checked");
		var name = event.getSource().get("v.name");
		
		component.set('v.modulo.'+name, value);
		if (!value) 
			component.set('v.modulo.Scopo' + name.substring(6,name.length), '');
	},

	onChangeToggleVisita : function(component, event, helper){
		var value = event.getSource().get("v.checked");	
		component.set('v.VisitaLocaliAzienda', value);
	},

	onChangePicklist : function(component, event, helper){
		var value = event.getSource().get("v.value");
		var name = event.getSource().getLocalId();

		component.set('v.modulo.'+name, value);
	},

	onChangeNaturaCreditiErariali : function(component, event, helper){
		var value = event.getSource().get("v.value");
		var name = event.getSource().getLocalId();

		component.set('v.modulo.'+name, value);
		if (value != 'Altro') {
			component.set('v.modulo.Altro_Crediti_Erariali__c', '');
		}
	},

	onChangeTextNaturaCreditiErariali : function(component, event, helper){
		var value = event.getSource().get("v.value");
		var name = event.getSource().getLocalId();

		component.set('v.modulo.'+name, value);
	}

})