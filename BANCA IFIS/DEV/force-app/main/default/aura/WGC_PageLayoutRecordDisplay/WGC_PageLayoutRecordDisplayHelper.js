({
    retrievePageLayout : function(component, event, helper) {
        let h = this;
        
        helper.fetchPickListVal_Nazione(component, 'Comune__c', 'optionsPicklistNazione');
        helper.fetchPickListVal_Province(component, 'optionsPicklistProvince');
        //adione - CR 323 - posso caricare ATECO solo dopo caricamento layout e sovrascrittura campi picklist
        helper.fetchPickListVal_ATECO(component, 'optionsPicklistATECO');
		
		helper.apex(component, event, "getAccountLayoutNameAssigned", { typeObject : component.get("v.sObjectName"), objectId : component.get("v.recordId") })
		.then($A.getCallback(function(result){
            let json = JSON.parse(result);
			console.log(json);
			component.set("v.layoutName", json.records[0].Layout.Name);
			if (json.records.length == 1) {
				let layoutName = json.records[0].Layout.Name;
				console.log(layoutName);
				
				return helper.apex(component, event, "getPageLayoutMetadata", { pageLayoutName : component.get("v.sObjectName") + "-" + layoutName});
			}
			// component.set("v.pageLayout", json.records[0].Layout.Name);
            else
				helper.showToast(component, "ERRORE", "Nessun layout associato all'utente corrente", "error");
			return 'none';

        })).then($A.getCallback(function(pageLayout){
            //popola valori degli oggetti convertiti da testo a picklist
            component.set("v.PageLayout", pageLayout);
			//adione CRM ID 207 - posso caricare i valori compatibili del SAE solo adesso perché mi serve il record account caricato per leggere la natura giuridica
			helper.fetchPickListVal_SAE(component, 'optionsPicklistSAE');
            return helper.apex(component, event, "getOverrideFieldValue", { typeObject : component.get("v.sObjectName"), idObject : component.get("v.recordId"), elementOverrideList : component.get('v.fieldsOverrideList')});
            
		})).then($A.getCallback(function(fieldsValue){
            // rimozione degli spazi vuoti
            console.log(fieldsValue);
            component.set("v.fieldsValue", fieldsValue);
		})).finally($A.getCallback(function () {
            var pageLayout = component.get("v.PageLayout");
            pageLayout = h.removeBlankSpaces(pageLayout);
            console.log('pageLayout', pageLayout);
            pageLayout = h.overrideFields(component, event, helper, pageLayout);
			component.set("v.loaded", true);
		}));
	},


    // VS - 07/11/2022 - GIANOS_MAV_Specifiche_tecniche v_2 - Nuovi controlli su dettaglio referente - INIZIO
    onLoad : function(component,event) {
        var checkOBJ= component.get("v.sObjectName");
        if(checkOBJ=="Contact"){
            let record = event.getParams();
            let fieldsValue = record.recordUi.record.fields;
            let prof= fieldsValue.Professione__c.value;
            let pageLayout = component.get("v.PageLayout");
            // let sections = component.get("v.PageLayout").Sections;
            if(prof!="00153"){
                pageLayout.Sections.forEach(s => {
                    s.Columns.forEach(c => {
                        c.Fields.forEach(f => {
                            if(f.APIName== "Forma_Giuridica_Societ_di_appartenenza__c"){
                                f.Behavior="Readonly";
                            }
                            
                        });
                    });
                });
            
            }else{

                pageLayout.Sections.forEach(s => {
                    s.Columns.forEach(c => {
                        c.Fields.forEach(f => {
                            if(f.APIName== "Forma_Giuridica_Societ_di_appartenenza__c"){
                                f.Required=true;
                            }
                            
                        });
                    });
                });
            }
            component.set("v.PageLayout",pageLayout);
        }
        

        
        
    },

    onchangeValue : function(component,event) {
        
        let value =event.getSource().get("v.value");
        let pageLayout = component.get("v.PageLayout");
        if(value !="00153"){
            pageLayout.Sections.forEach(s => {
                s.Columns.forEach(c => {
                    c.Fields.forEach(f => {
                        if(f.APIName== "Forma_Giuridica_Societ_di_appartenenza__c"){
                            f.Required=false;
                        }
                        if(f.APIName== "Forma_Giuridica_Societ_di_appartenenza__c"){
                            f.Behavior="Readonly";
                        }
                        
                    });
                });
            });
        }else{
            pageLayout.Sections.forEach(s => {
                s.Columns.forEach(c => {
                    c.Fields.forEach(f => {
                        if(f.APIName== "Forma_Giuridica_Societ_di_appartenenza__c"){
                            f.Required=true;
                        }
                        if(f.APIName== "Forma_Giuridica_Societ_di_appartenenza__c"){
                            f.Behavior="Edit";
                        }
                        
                    });
                });
            });
        }
        component.set("v.PageLayout",pageLayout);
    },

    // VS - 07/11/2022 - GIANOS_MAV_Specifiche_tecniche v_2 - Nuovi controlli su dettaglio referente - FINE
	
	manageSubmit : function(component, event) {
		event.preventDefault(); // stop the form from submitting
		let fields = event.getParam('fields');
		let layout = component.get("v.PageLayout");
		$A.util.removeClass(component.find("spinner"), "slds-hide");

		var updateOnlyCRM = component.get('v.updateOnlyCRM');

		if(updateOnlyCRM) {
				let B2F = $A.get("e.c:PageLayoutRecordDisplayEvent");
				B2F.setParams({ json: JSON.stringify({ action: "submit-updateOnlyCRM", data : fields }) });
				B2F.fire();

		} else {
			//adione - CR 211
			//salviamoci il riferimento a questo helper
			var that = this;
			var objSelected = component.get("v.currentObj");
			var recordId = component.get("v.recordId");
			var objType = component.get("v.sObjectName");

			//chiamata al controller apex per recuperare la conf basata su natura giuridica e SAE dell'account corrente
			this.apex(component, event, "getCCIAA_ATECO_Conf", { naturaGiuridica: objSelected.NaturaGiuridica__c, sae: objSelected.SAE__c, recordId: recordId, objType: objType })
			.then($A.getCallback( function(result) {
				let atecoObb = JSON.parse(result); //boolean che ci dice se per quella combinazione di natura giuridica e SAE servono i dati ATECO e CCIAA
				let valid = that.validateAllFields(component, event, layout, fields, atecoObb); //essendo dentro la callback dove usare il rif. all'helper salvatomi prima
				console.log("Layout: ", layout);
				if (valid) {
					// acc: JSON.stringify(fields)
					let B2F = $A.get("e.c:PageLayoutRecordDisplayEvent");
					B2F.setParams({ json: JSON.stringify({ action: "submit", data : fields }) });
					B2F.fire();

				} else {
					$A.util.addClass(component.find("spinner"), "slds-hide");
					component.set("v.PageLayout", layout);
					component.set("v.hasError", !valid);
				}

			}))			

		}
    },
    
    manageOnLoad : function(component, event) {
		let record = event.getParams();
        let fieldsValue = record.recordUi.record.fields;
        let fieldsOverrideList = component.get('v.fieldsOverrideList');
        let elementOverride = [];        

        console.log(fieldsOverrideList);

        fieldsOverrideList.forEach(element => {
            let elementX = {};
            if(fieldsValue.hasOwnProperty(element)){
                elementX.name = element;
                elementX.value = fieldsValue[element].value;
                elementOverride.push(elementX);
            }
        });

        console.log(elementOverride);
        component.set('v.elementOverride', elementOverride);
	},

	success : function(component) {
		$A.util.addClass(component.find("spinner"), "slds-hide");
		
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Successo",
			"message": "Anagrafica aggiornata con successo.",
			"type": "success"
		});
		toastEvent.fire();

        let B2F = $A.get("e.c:PageLayoutRecordDisplayEvent");
        B2F.setParams({ json: JSON.stringify({ action: "submit" , data: [{Id: component.get("v.recordId")}] }) });
        B2F.fire();
	},

	validateAllFields : function(component, event, layout, fields, atecoRichiesto) {
		let sections = this.removeBlankSpaces(layout).Sections;
		let valid = true;
		let errors = [];
			sections.forEach(s => {
				s.Columns.forEach(c => {
					c.Fields.forEach(f => {

						if (f.APIName == "Fatturato__c") {
							fields['Fatturato__c'] = parseFloat(fields['Fatturato__c']);
						}

						if (fields[f.APIName] == undefined && f.APIName == "Name") {
							if((fields['FirstName'] != null || fields['FirstName'] != "") && (fields['LastName'] != null || fields['LastName'] != "")) {
								fields[f.APIName] = (fields['Salutation'] != null ? fields['Salutation'] + " " : "") + fields['FirstName'] + " " + fields['LastName'];
							}
						}

						//campi non obbligatori per PA/onlus/esteri: ATECO e CCIAA
						//adione CR 211
						if (f.APIName == "Ateco__c" || f.APIName == "REA__c" || f.APIName == "CCIAA__c" || f.APIName == "DataIscrizioneCCIAA__c" || f.APIName == "ProvinciaCCIAA__c" || f.APIName == "ProvinciaCerved__c" || f.APIName == "DataIscrizioneCerved__c") {
							if (f.Behavior == "Required" && atecoRichiesto) { //campo marcato obbligatorio e natura giuridica che lo richiede: se manca è errore
								if (fields[f.APIName] == null || fields[f.APIName] == "") { //campo non valorizzato
									valid = false;
									f.hasError = true;
									if(!errors.includes($A.get("$Label.c.WGC_PageLayoutRecordDisplay_RequiredFields")))
										errors.push($A.get("$Label.c.WGC_PageLayoutRecordDisplay_RequiredFields"));
								}
							}

						//controlla se i campi obbligatori sono compilati;
						//per i campi sostituiti, p.e. provincia, va a recuperare l'elemento aura relativo per decorarlo (p.e. la picklist invece che textbox)
						} else if (f.Behavior == "Required" && (fields[f.APIName] == null || fields[f.APIName] == "")) {
							//gestione campi sostituiti
							let cmpTarget = component.find("override_select"); //recupera elemento aura del componente
							cmpTarget.forEach(function (element) {
								if(element.get("v.name").replace("override_", "") == f.APIName) { 
									$A.util.addClass(element, 'slds-has-error');
								}
							});

							valid = false;
							f.hasError = true;
							if(!errors.includes($A.get("$Label.c.WGC_PageLayoutRecordDisplay_RequiredFields")))
								errors.push($A.get("$Label.c.WGC_PageLayoutRecordDisplay_RequiredFields"));

						} else if ((f.APIName == "MailingState__c" && fields['MailingState__c'].length > 2) || (f.APIName == "ProvinciaNascita__c" && fields['ProvinciaNascita__c'].length > 2) || (f.APIName == "ProvinciaCCIAA__c" && fields['ProvinciaCCIAA__c'].length > 2) || (f.APIName == "BillingState__c" && fields['BillingState__c'].length > 2)) {
							//TO-DO adione: mancano alcuni campi che salvano la provincia ma serve ancora questo controllo visto che son stati convertiti a picklist?
							valid = false;
							f.hasError = true;
							if(!errors.includes($A.get("$Label.c.WGC_PageLayoutRecordDisplay_Provincia2Plus")))
								errors.push($A.get("$Label.c.WGC_PageLayoutRecordDisplay_Provincia2Plus"));
						} else if (f.APIName == "Name" && fields['Name'].length > 40) { //SDHDFNZ-93461
							valid = false;
							f.hasError = true;
							if(!errors.includes($A.get("$Label.c.WGC_PageLayoutRecordDisplay_NameTooLong")))
								errors.push($A.get("$Label.c.WGC_PageLayoutRecordDisplay_NameTooLong"));
                            
						} else if ((f.APIName == "BillingStreetNumber__c" && fields['BillingStreetNumber__c'] && fields['BillingStreetNumber__c'].length > 6)
                                   || (f.APIName == "ShippingStreetNumber__c" && fields['ShippingStreetNumber__c'] && fields['ShippingStreetNumber__c'].length > 6) ) { //SDHDFNZ-93461
							valid = false;
							f.hasError = true;
							if(!errors.includes($A.get("$Label.c.WGC_PageLayoutRecordDisplay_StreetNumberTooLong")))
								errors.push($A.get("$Label.c.WGC_PageLayoutRecordDisplay_StreetNumberTooLong"));
                            
						} else if ((f.APIName == "BillingStreetName__c" && fields['BillingStreetName__c'] && fields['BillingStreetName__c'].length > 24)
                                  || (f.APIName == "ShippingStreetName__c" && fields['ShippingStreetName__c'] && fields['ShippingStreetName__c'].length > 24)) { //SDHDFNZ-93461
							valid = false;
							f.hasError = true;
							if(!errors.includes($A.get("$Label.c.WGC_PageLayoutRecordDisplay_StreetNameTooLong")))
								errors.push($A.get("$Label.c.WGC_PageLayoutRecordDisplay_StreetNameTooLong"));

						} else {
							let cmpTarget = component.find("override_select");
							cmpTarget.forEach(function (element) {
								if(element.get("v.name").replace("override_", "") == f.APIName) {
									$A.util.removeClass(element, 'slds-has-error');
								}
							});
							f.hasError = false;
						}

						component.set("v.errors", errors);
					});
				});
			});

			layout.Sections = sections;

			return valid;
	}, 

	apex: function (component, event, apexAction, params) {
        var p = new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get("c." + apexAction + "");
            action.setParams(params);
            action.setCallback(this, function (callbackResult) {
                if (callbackResult.getState() == 'SUCCESS') {
                    resolve(callbackResult.getReturnValue());
                }
                if (callbackResult.getState() == 'ERROR') {
                    console.log('ERROR', callbackResult.getError());
                    reject(callbackResult.getError());
                }
            });
            $A.enqueueAction(action);
        }));
        return p;
	},
	
	getCedacriSleepTime: function (component, event) {
        var action = component.get("c.getCS_CedacriSleepTime");
        action.setParams({
        });
        //Setting the Callback
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('SLEEP CEDACRI: ', result);

                var today = new Date();
                var cedacriHourStart = result.Cedacri_Inizio_Indisponibilita__c.split(':');
                var cedacriHourEnd = result.Cedacri_Fine_Indisponibilita__c.split(':');
                var timeStringCedacri_Inizio = new Date(today.getFullYear(), today.getMonth(), today.getDate(), cedacriHourStart[0], cedacriHourStart[1]);
                var timeStringCedacri_Fine =  new Date(today.getFullYear(), today.getMonth(), today.getDate(), cedacriHourEnd[0], cedacriHourEnd[1]);
                
                
                var x = [];
                if(today >= timeStringCedacri_Inizio && today <= timeStringCedacri_Fine){
                    x.push($A.get("$Label.c.WGC_CreateAccount_ErrorMessage_Cedacri") + ' dalle ' + result.Cedacri_Inizio_Indisponibilita__c + ' alle ' + result.Cedacri_Fine_Indisponibilita__c);
                    component.set('v.CedacriSleepError', x);
                }

            } else if (state == "ERROR") {
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
	},
	
	removeBlankSpaces : function(layout) {
		let sections = layout.Sections;

		sections.forEach(s => {
			s.Columns.forEach(c => {
				c.Fields = c.Fields.filter(f => {
					return f.hasOwnProperty("APIName");
				});
			});
			s.Columns = s.Columns.filter(c => {return c.Fields.length > 0;});
		});

		layout.Sections = sections.filter(s => {return s.Columns.length > 0});

		return layout;
    },
    
    overrideFields : function(component, event, helper, layout) {
		//prende i campi standard da layout e li cambia, p.e. il campo nazione da testo libero diventa picklist
		let sections = layout.Sections;
        let fieldsOverrideList = component.get('v.fieldsOverrideList');
        let fieldsOverrideWithList = component.get('v.fieldsOverrideWithList');
        let fieldsValue = component.get("v.fieldsValue");

        if(fieldsOverrideList.length > 0) {
            sections.forEach(s => {
                s.Columns.forEach(c => {
                    c.Fields.forEach(f => {
                        if(fieldsOverrideList.includes(f['APIName'])) {
                            f['Override'] = true;
                            f['Value'] = fieldsValue[f['APIName']].value;
                            f['Label'] = fieldsValue[f['APIName']].label;
                            f['SetOfPicklist'] = component.get('v.' + fieldsOverrideWithList[fieldsOverrideList.indexOf(f['APIName'])]);
                        }
                    });
                });
            });
        }
		
		return layout;
    },

	//adione CRM ID 207 
	fetchPickListVal_SAE: function (component, elementId) {
		//recupero elemento picklist
        var action = component.get("c.getselectOptions_SAE");
		var objectType = component.get("v.sObjectName");
		var objSelected = component.get("v.currentObj");

        action.setParams({
            "objectType": objectType
        });
		
        var opts = [];
		//una volta completato il metodo apex viene eseguita la callback
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
				//aggiungo voce selezione vuota
                opts.push({
                    class: "",
                    label: "",
                    value: ""
                });
				//prefisso con valore e descrizione, p.e. 430 - IMPRESE PRODUTTIVE
                for (var k in allValues) {
                    opts.push({
                        class: "",
                        label: allValues[k] + ' - ' + k,
                        value: allValues[k],
                        selected: (allValues[k] == objSelected.SAE__c) ? true : false
                    });
                }
				//imposto elenco voci nella picklist
                component.set("v." + elementId, opts);
            }
        });
        $A.enqueueAction(action);
	},

	//adione - CR 323
    fetchPickListVal_ATECO: function (component, elementId) {
		var objectType = component.get("v.sObjectName");
        
        if (objectType !== 'Account') {
            return;
        }

		//recupero funzione APEX del controller
        var action = component.get("c.getselectOptions_ATECO");
        var opts = [];
		//una volta completato il metodo apex viene eseguita la callback
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
				//prefisso con valore e descrizione, p.e. 0 - Non Assegnato
                for (var k in allValues) {
                    opts.push({
                        class: "",
                        label: k,
                        value: allValues[k]
                    });
                }
				//imposto elenco voci nella picklist
                component.set("v." + elementId, opts);
            }
        });
        $A.enqueueAction(action);
	},
                
    fetchPickListVal_Nazione: function (component, objectName, fieldName) {
        var action = component.get("c.getselectOptions_Nazione");
        action.setParams({
            "objectName": objectName,
            "params": "",
            "condition": ""
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();

                opts.push({
                    class: "",
                    label: "",
                    value: ""
                });

                for (var k in allValues) {
                    opts.push({
                        class: "",
                        label: k,
                        value: allValues[k]
                    });
                }

                component.set("v." + fieldName, opts);
            }
        });

        $A.enqueueAction(action);
    },

	fetchPickListVal_Province: function (component, fieldName) {
        var allProvince = [
            { value: null, label: "", selected: true },
            { value: 'AG', label: 'Agrigento' },
            { value: 'AL', label: 'Alessandria' },
            { value: 'AN', label: 'Ancona' },
            { value: 'AO', label: 'Aosta' },
            { value: 'AR', label: 'Arezzo' },
            { value: 'AP', label: 'Ascoli Piceno' },
            { value: 'AT', label: 'Asti' },
            { value: 'AV', label: 'Avellino' },
            { value: 'BA', label: 'Bari' },
            { value: 'BT', label: 'Barletta-Andria-Trani' },
            { value: 'BL', label: 'Belluno' },
            { value: 'BN', label: 'Benevento' },
            { value: 'BG', label: 'Bergamo' },
            { value: 'BI', label: 'Biella' },
            { value: 'BO', label: 'Bologna' },
            { value: 'BZ', label: 'Bolzano' },
            { value: 'BS', label: 'Brescia' },
            { value: 'BR', label: 'Brindisi' },
            { value: 'CA', label: 'Cagliari' },
            { value: 'CL', label: 'Caltanissetta' },
            { value: 'CB', label: 'Campobasso' },
            { value: 'CI', label: 'Carbonia-Iglesias' },
            { value: 'CE', label: 'Caserta' },
            { value: 'CT', label: 'Catania' },
            { value: 'CZ', label: 'Catanzaro' },
            { value: 'CH', label: 'Chieti' },
            { value: 'CO', label: 'Como' },
            { value: 'CS', label: 'Cosenza' },
            { value: 'CR', label: 'Cremona' },
            { value: 'KR', label: 'Crotone' },
            { value: 'CN', label: 'Cuneo' },
            { value: 'EN', label: 'Enna' },
            { value: 'FM', label: 'Fermo' },
            { value: 'FE', label: 'Ferrara' },
            { value: 'FI', label: 'Firenze' },
            { value: 'FG', label: 'Foggia' },
            { value: 'FC', label: 'Forlì-Cesena' },
            { value: 'FR', label: 'Frosinone' },
            { value: 'GE', label: 'Genova' },
            { value: 'GO', label: 'Gorizia' },
            { value: 'GR', label: 'Grosseto' },
            { value: 'IM', label: 'Imperia' },
            { value: 'IS', label: 'Isernia' },
            { value: 'SP', label: 'La Spezia' },
            { value: 'AQ', label: 'L\'Aquila' },
            { value: 'LT', label: 'Latina' },
            { value: 'LE', label: 'Lecce' },
            { value: 'LC', label: 'Lecco' },
            { value: 'LI', label: 'Livorno' },
            { value: 'LO', label: 'Lodi' },
            { value: 'LU', label: 'Lucca' },
            { value: 'MC', label: 'Macerata' },
            { value: 'MN', label: 'Mantova' },
            { value: 'MS', label: 'Massa-Carrara' },
            { value: 'MT', label: 'Matera' },
            { value: 'ME', label: 'Messina' },
            { value: 'MI', label: 'Milano' },
            { value: 'MO', label: 'Modena' },
            { value: 'MB', label: 'Monza e della Brianza' },
            { value: 'NA', label: 'Napoli' },
            { value: 'NO', label: 'Novara' },
            { value: 'NU', label: 'Nuoro' },
            { value: 'OT', label: 'Olbia-Tempio' },
            { value: 'OR', label: 'Oristano' },
            { value: 'PD', label: 'Padova' },
            { value: 'PA', label: 'Palermo' },
            { value: 'PR', label: 'Parma' },
            { value: 'PV', label: 'Pavia' },
            { value: 'PG', label: 'Perugia' },
            { value: 'PU', label: 'Pesaro e Urbino' },
            { value: 'PE', label: 'Pescara' },
            { value: 'PC', label: 'Piacenza' },
            { value: 'PI', label: 'Pisa' },
            { value: 'PT', label: 'Pistoia' },
            { value: 'PN', label: 'Pordenone' },
            { value: 'PZ', label: 'Potenza' },
            { value: 'PO', label: 'Prato' },
            { value: 'RG', label: 'Ragusa' },
            { value: 'RA', label: 'Ravenna' },
            { value: 'RC', label: 'Reggio Calabria' },
            { value: 'RE', label: 'Reggio Emilia' },
            { value: 'RI', label: 'Rieti' },
            { value: 'RN', label: 'Rimini' },
            { value: 'RM', label: 'Roma' },
            { value: 'RO', label: 'Rovigo' },
            { value: 'SA', label: 'Salerno' },
            { value: 'VS', label: 'Medio Campidano' },
            { value: 'SS', label: 'Sassari' },
            { value: 'SV', label: 'Savona' },
            { value: 'SI', label: 'Siena' },
            { value: 'SR', label: 'Siracusa' },
            { value: 'SO', label: 'Sondrio' },
            { value: 'SU', label: 'Sud Sardegna' },
            { value: 'TA', label: 'Taranto' },
            { value: 'TE', label: 'Teramo' },
            { value: 'TR', label: 'Terni' },
            { value: 'TO', label: 'Torino' },
            { value: 'OG', label: 'Ogliastra' },
            { value: 'TP', label: 'Trapani' },
            { value: 'TN', label: 'Trento' },
            { value: 'TV', label: 'Treviso' },
            { value: 'TS', label: 'Trieste' },
            { value: 'UD', label: 'Udine' },
            { value: 'VA', label: 'Varese' },
            { value: 'VE', label: 'Venezia' },
            { value: 'VB', label: 'Verbano-Cusio-Ossola' },
            { value: 'VC', label: 'Vercelli' },
            { value: 'VR', label: 'Verona' },
            { value: 'VV', label: 'Vibo Valentia' },
            { value: 'VI', label: 'Vicenza' },
            { value: 'VT', label: 'Viterbo' },
            { value: 'EE', label: 'Estera' }
        ];

        component.set('v.optionsPicklistProvince', allProvince);
    },
})