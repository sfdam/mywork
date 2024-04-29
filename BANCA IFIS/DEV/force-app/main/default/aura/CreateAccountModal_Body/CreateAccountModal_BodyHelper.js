({
    fireEvent: function (response, whatEvent) {
        var B2F = $A.get("e.c:" + whatEvent);
        B2F.setParams({ "json": response });
        B2F.fire();
    },

    confirmAction: function (target) {
        this.fireEvent(JSON.stringify({ "action": "confirm-action", "target": target }), 'ModalBody2FooterEvent');
    },

    resolveAction: function (action, data, cointestazione, whoAreYou) {
        this.fireEvent(JSON.stringify({ "action": action, "data": data, "cointestazione": cointestazione, "whoAreYou": whoAreYou }), 'WGC_CreateAccountResolveEvent');
    },

    closeAction: function (component, event, target) {
        var cointestazione = component.get("v.cointestazione");
        var obj = {};
        this.resolveAction('cancel', obj, cointestazione, component.get("v.whoAreYou"));
        component.find('overlayLib').notifyClose();
    },

    fetchPickListVal: function (component, fieldName, object, elementId) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": object,
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log(allValues);

                opts.push({
                    class: "optionClass",
                    label: "",
                    value: ""
                });

                for (var k in allValues) {
                    opts.push({
                        class: "optionClass",
                        label: (fieldName == 'SAE__c' || fieldName == 'RAE__c') ? allValues[k] + ' - ' + k : k,
                        value: allValues[k]
                    });
                }
                /*
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                */
                component.set("v." + elementId, opts);
            }
        });
        $A.enqueueAction(action);
    },

    fetchPickListVal_RecordType: function (component, objectName, fieldName) {
        var action = component.get("c.getselectOptions_recordType");
        action.setParams({
            "objObject": objectName
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();

                /*
                opts.push({
                    class: "",
                    label: "",
                    value: ""
				});
				*/

                for (var k in allValues) {
                    opts.push({
                        class: "",
                        label: k,
                        value: allValues[k]
                    });
                }

                component.set("v.InputRecordTypeOptions", opts);
            }
        });
        $A.enqueueAction(action);
    },

    fetchPickListVal_Ateco: function (component, objSelected, elementId) {
        var action = component.get("c.getselectOptions_Ateco");
        action.setParams({
            "rae": objSelected.RAE__c
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
                        label: k + ' - ' + allValues[k],
                        value: k,
                        selected: (k == objSelected.Ateco__c) ? true : false
                    });
                }

                component.set("v." + elementId, opts);
            }
        });
        $A.enqueueAction(action);
    },

    fetchPickListVal_RAE: function (component, objSelected, elementId) {
        var action = component.get("c.getselectOptions_Rae");
        action.setParams({
            "naturaGiuridica": objSelected.NaturaGiuridica__c,
            "sae": objSelected.SAE__c
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var bol = response.getReturnValue();
                if (bol) {
                    var allValues = component.get('v.InputPicklistRAE_all');

                    for (var k in allValues) {
                        opts.push({
                            class: "",
                            label: allValues[k].label,
                            value: allValues[k].value,
                            selected: (allValues[k].value == objSelected.RAE__c) ? true : false
                        });
                    }

                } else {
                    opts.push({
                        class: "",
                        label: "",
                        value: ""
                    });

                    opts.push({
                        class: "",
                        label: 0 + ' - NON ASSEGNATO',
                        value: 0,
                        selected: true
                    });
                }

                component.set("v." + elementId, opts);
            }
        });
        $A.enqueueAction(action);
    },

    fetchPickListVal_SAE: function (component, objSelected, elementId) {
        var action = component.get("c.getselectOptions_Sae");
        action.setParams({
            "naturaGiuridica": objSelected.NaturaGiuridica__c
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
                        label: allValues[k] + ' - ' + k,
                        value: allValues[k],
                        selected: (allValues[k] == objSelected.SAE__c) ? true : false
                    });
                }

                console.log(allValues.size);

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

    fetchPickListVal_Comune: function (component, provincia, fieldName) {
        var action = component.get("c.getselectOptions_ComuniFromProvincia");
        action.setParams({
            "objectName": "Comune__c",
            "provincia": provincia
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();

                component.set('v.resultComuniProvince', allValues);
                console.log('getselectOptions_ComuniFromProvincia');

                opts.push({
                    class: "optionClass",
                    label: "",
                    value: ""
                });

                allValues.forEach(function (element) {
                    // console.log("element.Name: ", element.Name);
                    // console.log("objSelected.BillingCity: ", objSelected.BillingCity);
                    opts.push({
                        class: "",
                        label: element.Name,
                        value: element.Name,
                        selected: (component.get('v.resultSelected').BillingCity == element.Name)
                    });
                });

                console.log(allValues);

                component.set("v." + fieldName, opts);
            }
        });
        $A.enqueueAction(action);


    },

    getRecordsWrapper: function (component) {

        var ifisFinance = component.get('v.ifisFinance');
        var action = component.get("c.getPositionRecords");

        //Setting the Callback
        action.setCallback(this, function (a) {
            //get the response state
            var state = a.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                var result = a.getReturnValue();
                console.log('@@@ result ', result);
                if(ifisFinance){
                    result.estero = true;
                }
                if (!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    component.set("v.inputObject", result);
            } else if (state == "ERROR") {
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });

        //adds the server-side action to the queue        
        $A.enqueueAction(action);
    },

    validate: function (json, component, event, atecoRichiesto) {
        var isValid = { step: "", valid: true, msg: "" };

        switch (component.get("v.page") + '_' + json.action + '_' + json.target) {
            case 'search_next_result':
                var inputObject = component.get('v.inputObject');
                if (inputObject.tipoDiRicerca == 'piva') { //ricerca per p.iva
                    var cmpTarget = component.find('search_piva');
                    if (this.isBlank(inputObject.pivaOrCf)) {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                        isValid.valid = false;
                        isValid.msg = $A.get("$Label.c.WGC_CreateAccount_Modal_Body_Ricerca_per_partita_IVA_inserire_i_campi_obbligato");
                        // msg.push({ "type" : "info" , "text" : "Almeno uno tra Codice Fiscale e Cognome deve essere compilato." });
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                    }
				//ricerca per p.iva END
                } else if (inputObject.tipoDiRicerca == 'ndg') { //ricerca per ndg 
					var cmpTarget = component.find('search_ndg');
                    if (this.isBlank(inputObject.ndg)) {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                        isValid.valid = false;
                        isValid.msg = $A.get("$Label.c.WGC_CreateAccount_Modal_Body_Ricerca_per_partita_IVA_inserire_i_campi_obbligato");
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                    }
				//ricerca per ndg END 
				} else { //ricerca per rag. soc.
                    var validAllRS = {};
                    var cmpTarget = component.find('search_ragioneSociale');
                    if (!inputObject.hasOwnProperty('ragioneSociale') || inputObject.ragioneSociale == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAllRS['search_ragioneSociale'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAllRS['search_ragioneSociale'] = true;
                    }
                    if(!inputObject.estero){
                        var cmpTarget = component.find('search_provincia');
                        if (!inputObject.hasOwnProperty('provincia') || inputObject.provincia == '') {
                            $A.util.addClass(cmpTarget, 'slds-has-error');
                            validAllRS['search_provincia'] = false;
                        } else {
                            $A.util.removeClass(cmpTarget, 'slds-has-error');
                            validAllRS['search_provincia'] = true;
                        }
                    }                    
                    console.log(validAllRS);
                    isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;

                    for (var key in validAllRS) {
                        if (validAllRS.hasOwnProperty(key) && !validAllRS[key]) {
                            isValid.valid = false;
                            isValid.msg = $A.get("$Label.c.WGC_CreateAccount_Modal_Body_Ricerca_per_Ragione_Sociale_inserire_i_campi_obbli");
                        }
                    }
                } //ricerca per rag. soc. END

                break;
            case 'result_next_submit':
                var resultSelected = component.get('v.resultSelectedBefor');
                var result = component.get('v.result');
                console.log(resultSelected.Name);
                console.log(resultSelected.REA__c);

                if (resultSelected.Name == null || resultSelected.Name == '') {
                    isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                    isValid.valid = false;
                    isValid.msg = $A.get("$Label.c.WGC_CreateAccount_Modal_Body_Seleziona_un_Account");
                    // msg.push({ "type" : "info" , "text" : "Almeno uno tra Codice Fiscale e Cognome deve essere compilato." });
                } else {
                    isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                    this.fetchPickListVal_Comune(component, resultSelected.BillingState, "optionsPicklistComune");
                }
                break;
            case 'submit_submit_end':
                var ifisFinance = component.get('v.ifisFinance');
                var resultSelected = component.get('v.resultSelected');
                var validAll = {};
				//A.M. Flag per gestione anagrafiche estere e PA
				var NoREA = component.get('v.AccountNoREA');
				console.log('@@@NoREA-submit_submit_end: ', NoREA);

                var cmpTarget = component.find('ragioneSociale');
                if (!resultSelected.hasOwnProperty('Name') || resultSelected.Name == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['ragioneSociale'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['ragioneSociale'] = true;
                }
                var cmpTarget = component.find('piva');
                if (!resultSelected.hasOwnProperty('PIVA__c') || resultSelected.PIVA__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['piva'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['piva'] = true;
                }
                var cmpTarget = component.find('codFisc');
                if (!resultSelected.hasOwnProperty('CF__c') || resultSelected.CF__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['codFisc'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['codFisc'] = true;
                }
                // var cmpTarget = component.find('rae');
                // if (!resultSelected.hasOwnProperty('RAE__c') || resultSelected.RAE__c == '') {
                //     $A.util.addClass(cmpTarget, 'slds-has-error');
                //     validAll['rae'] = false;
                // } else {
                //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                //     validAll['rae'] = true;
                // }

                if(!ifisFinance){
                    var cmpTarget = component.find('sae');
                    if (!resultSelected.hasOwnProperty('SAE__c') || resultSelected.SAE__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['sae'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['sae'] = true;
                    }
                    var cmpTarget = component.find('naturaGiuridica');
                    if (!resultSelected.hasOwnProperty('NaturaGiuridica__c') || resultSelected.NaturaGiuridica__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['naturaGiuridica'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['naturaGiuridica'] = true;
                    }
                    // var cmpTarget = component.find('ateco');
                    console.log('VALIDATE: ', resultSelected);
					console.log('------> atecoRichiesto: '+atecoRichiesto);
					//----------------------------------------
					if (atecoRichiesto) {
						if (!resultSelected.hasOwnProperty('Ateco__c') || resultSelected.Ateco__c == '' || resultSelected.Ateco__c == undefined) {
							// $A.util.addClass(cmpTarget, 'slds-has-error');
							validAll['ateco'] = false;
							component.set('v.atecoError', true);
						} else {
							// $A.util.removeClass(cmpTarget, 'slds-has-error');
							validAll['ateco'] = true;
							component.set('v.atecoError', false);
						}
					
						//adione - CR 211
						//TO-DO non siamo polonia ma dobbiamo cmq controllare se Account estero o PA
						//A.M. gestione esteri e PA
						if (!NoREA){
						   var cmpTarget = component.find('rea');
						   if (!resultSelected.hasOwnProperty('REA__c') || resultSelected.REA__c == '') {
						    	$A.util.addClass(cmpTarget, 'slds-has-error');
							   validAll['rea'] = false;
						   } else {
							   $A.util.removeClass(cmpTarget, 'slds-has-error');
							  validAll['rea'] = true;
						    }
						}
						//adione - CR 211
						//TO-DO non siamo polonia ma dobbiamo cmq controllare se Account estero o PA
						//A.M. gestione esteri e PA
						if (!NoREA){
						   var cmpTarget = component.find('provinciaCCIAA');
						   if (!resultSelected.hasOwnProperty('ProvinciaCCIAA__c') || resultSelected.ProvinciaCCIAA__c == '') {
						    	$A.util.addClass(cmpTarget, 'slds-has-error');
						    	validAll['provinciaCCIAA'] = false;
						   } else {
						    	$A.util.removeClass(cmpTarget, 'slds-has-error');
							    validAll['provinciaCCIAA'] = true;
						   }
						}
					}
					//----------------------------------------
                }
               
                // var cmpTarget = component.find('prefisso');
                // if (!resultSelected.hasOwnProperty('TelefonoPrefisso__c') || resultSelected.TelefonoPrefisso__c == '') {
                //     $A.util.addClass(cmpTarget, 'slds-has-error');
                //     validAll['prefisso'] = false;
                // } else {
                //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                //     validAll['prefisso'] = true;
                // }
                // var cmpTarget = component.find('telefono');
                // if (!resultSelected.hasOwnProperty('TelefonoNumero__c') || resultSelected.TelefonoNumero__c == '') {
                //     $A.util.addClass(cmpTarget, 'slds-has-error');
                //     validAll['telefono'] = false;
                // } else {
                //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                //     validAll['telefono'] = true;
                // }
                // var cmpTarget = component.find('email');
                // if (!resultSelected.hasOwnProperty('Email__c') || resultSelected.Email__c == '') {
                //     $A.util.addClass(cmpTarget, 'slds-has-error');
                //     validAll['email'] = false;
                // } else {
                //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                //     validAll['email'] = true;
                // }
                var cmpTarget = component.find('nazione');
                if (!resultSelected.hasOwnProperty('BillingCountry') || resultSelected.BillingCountry == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['nazione'] = false;

                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['nazione'] = true;
                }
                var cmpTarget = component.find('provincia');
                if (!resultSelected.hasOwnProperty('BillingState') || resultSelected.BillingState == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['provincia'] = false;

                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['provincia'] = true;
                }

                if(!ifisFinance){ // SE NON RISULTO UTETNTE IFIS FINANCE
                    if (resultSelected.BillingState == 'EE') {
                        var cmpTarget = component.find('comuneEstero');
                        if (!resultSelected.hasOwnProperty('BillingCity') || resultSelected.BillingCity == '') {
                            $A.util.addClass(cmpTarget, 'slds-has-error');
                            validAll['comuneEstero'] = false;
                        } else {
                            $A.util.removeClass(cmpTarget, 'slds-has-error');
                            validAll['comuneEstero'] = true;
                        }
                    } else {
                        var cmpTarget = component.find('comune');
                        if (!resultSelected.hasOwnProperty('BillingCity') || resultSelected.BillingCity == '') {
                            $A.util.addClass(cmpTarget, 'slds-has-error');
                            validAll['comune'] = false;
                        } else {
                            $A.util.removeClass(cmpTarget, 'slds-has-error');
                            validAll['comune'] = true;
                        }
                    }

                    var cmpTarget = component.find('streetType');
                    if (!resultSelected.hasOwnProperty('BillingStreetType__c') || resultSelected.BillingStreetType__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['streetType'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['streetType'] = true;
                    }
                }
                
                var cmpTarget = component.find('street');
                if (!resultSelected.hasOwnProperty('BillingStreetName__c') || resultSelected.BillingStreetName__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['street'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['street'] = true;
                }
                var cmpTarget = component.find('civico');
                if (!resultSelected.hasOwnProperty('BillingStreetNumber__c') || resultSelected.BillingStreetNumber__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['civico'] = false;
                } else {
                    if(resultSelected.BillingStreetNumber__c.length > 6){
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['civico_dimensione'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['civico'] = true;
                    }
                }
                var cmpTarget = component.find('cap');
                if (!resultSelected.hasOwnProperty('BillingPostalCode') || resultSelected.BillingPostalCode == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['cap'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['cap'] = true;

                }


                var sedeOperativa = component.get("v.sedeOperativa");
                if (sedeOperativa) {
                    var cmpTarget = component.find('nazione_shipping');
                    if (!resultSelected.hasOwnProperty('ShippingCountry') || resultSelected.ShippingCountry == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['nazione_shipping'] = false;

                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['nazione_shipping'] = true;
                    }
                    var cmpTarget = component.find('provincia_shipping');
                    if (!resultSelected.hasOwnProperty('ShippingState') || resultSelected.ShippingState == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['provincia_shipping'] = false;

                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['provincia_shipping'] = true;
                    }
                    if(!ifisFinance){ // SE NON RISULTO UTETNTE IFIS FINANCE
                        if (resultSelected.ShippingState == 'EE') {
                            var cmpTarget = component.find('comuneEstero_shipping');
                            if (!resultSelected.hasOwnProperty('ShippingCity') || resultSelected.ShippingCity == '') {
                                $A.util.addClass(cmpTarget, 'slds-has-error');
                                validAll['comuneEstero_shipping'] = false;
                            } else {
                                $A.util.removeClass(cmpTarget, 'slds-has-error');
                                validAll['comuneEstero_shipping'] = true;
                            }
                        } else {
                            var cmpTarget = component.find('comune_shipping');
                            if (!resultSelected.hasOwnProperty('ShippingCity') || resultSelected.ShippingCity == '') {
                                $A.util.addClass(cmpTarget, 'slds-has-error');
                                validAll['comune_shipping'] = false;
                            } else {
                                $A.util.removeClass(cmpTarget, 'slds-has-error');
                                validAll['comune_shipping'] = true;
                            }
                        }
                        var cmpTarget = component.find('tipoVia_shipping');
                        if (!resultSelected.hasOwnProperty('ShippingStreetType__c') || resultSelected.ShippingStreetType__c == '') {
                            $A.util.addClass(cmpTarget, 'slds-has-error');
                            validAll['tipoVia_shipping'] = false;
                        } else {
                            $A.util.removeClass(cmpTarget, 'slds-has-error');
                            validAll['tipoVia_shipping'] = true;
                        }
                    }
                    var cmpTarget = component.find('street_shipping');
                    if (!resultSelected.hasOwnProperty('ShippingStreetName__c') || resultSelected.ShippingStreetName__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['street_shipping'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['street_shipping'] = true;
                    }
                    var cmpTarget = component.find('civico_shipping');
                    if (!resultSelected.hasOwnProperty('ShippingStreetNumber__c') || resultSelected.ShippingStreetNumber__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['civico_shipping'] = false;
                    } else {
                        if(resultSelected.BillingStreetNumber__c.length > 6){
                            $A.util.addClass(cmpTarget, 'slds-has-error');
                            validAll['civico_shipping_dimensione'] = false;
                        } else {
                            $A.util.removeClass(cmpTarget, 'slds-has-error');
                            validAll['civico_shipping'] = true;
                        }
                    }
                    var cmpTarget = component.find('cap_shipping');
                    if (!resultSelected.hasOwnProperty('ShippingPostalCode') || resultSelected.ShippingPostalCode == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['cap_shipping'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['cap_shipping'] = true;
                    }
                }

                var contactFromDI = component.get('v.contactFromDI');
                console.log('validate contactFromDI: ', contactFromDI);
                if (contactFromDI) {
                    // toDO
                    var contactDI = component.get('v.contactDI');

                    var cmpTarget = component.find('contact_firstName');
                    if (!contactDI.hasOwnProperty('FirstName') || contactDI.FirstName == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_firstName'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_firstName'] = true;
                    }
                    var cmpTarget = component.find('contact_lastName');
                    if (!contactDI.hasOwnProperty('LastName') || contactDI.LastName == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_lastName'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_lastName'] = true;
                    }
                    var cmpTarget = component.find('contact_birthdate');
                    if (!contactDI.hasOwnProperty('Birthdate') || contactDI.Birthdate == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_birthdate'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_birthdate'] = true;
                    }
                    var cmpTarget = component.find('contact_sex');
                    if (!contactDI.hasOwnProperty('Sesso__c') || contactDI.Sesso__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_sex'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_sex'] = true;
                    }
                    var cmpTarget = component.find('contact_luogoDiNascita');
                    if (!contactDI.hasOwnProperty('LuogoNascita__c') || contactDI.LuogoNascita__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_luogoDiNascita'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_luogoDiNascita'] = true;
                    }
                    var cmpTarget = component.find('contact_codFiscale');
                    if (!contactDI.hasOwnProperty('CF__c') || contactDI.CF__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_codFiscale'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_codFiscale'] = true;
                    }

                    var cmpTarget = component.find('contact_tipoDoc');
                    if (!contactDI.hasOwnProperty('TipoDocumentoId__c') || contactDI.TipoDocumentoId__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_tipoDoc'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_tipoDoc'] = true;
                    }
                    var cmpTarget = component.find('contact_numDoc');
                    if (!contactDI.hasOwnProperty('NumeroDoc__c') || contactDI.NumeroDoc__c == '') {
                        validAll['contact_numDoc'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_numDoc'] = true;
                    }
                    var cmpTarget = component.find('contact_luogoEmissione');
                    if (!contactDI.hasOwnProperty('LuogoEmissioneDoc__c') || contactDI.LuogoEmissioneDoc__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_luogoEmissione'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_luogoEmissione'] = true;
                    }
                    var cmpTarget = component.find('contact_dataEmissione');
                    if (!contactDI.hasOwnProperty('DataEmissioneDoc__c') || contactDI.DataEmissioneDoc__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_dataEmissione'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_dataEmissione'] = true;
                    }
                    var cmpTarget = component.find('contact_dataScadenza');
                    if (!contactDI.hasOwnProperty('DataScadenzaDoc__c') || contactDI.DataScadenzaDoc__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_dataScadenza'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_dataScadenza'] = true;
                    }
                    // var cmpTarget = component.find('contact_enteEmittente');
                    // if (!contactDI.hasOwnProperty('EnteEmitettenteDocumento__c') || contactDI.EnteEmitettenteDocumento__c == '') {
                    //     $A.util.addClass(cmpTarget, 'slds-has-error');
                    //     validAll['contact_enteEmittente'] = false;
                    // } else {
                    //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                    //     validAll['contact_enteEmittente'] = true;
                    // }

                    var cmpTarget = component.find('contact_sae');
                    if (!contactDI.hasOwnProperty('SAE__c') || contactDI.SAE__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_sae'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_sae'] = true;
                    }
					//A.M.
					if (contactDI.hasOwnProperty('CF__c') && contactDI.CF__c != '' && resultSelected.hasOwnProperty('CF__c') && resultSelected.CF__c != '') {
                       if (contactDI.CF__c != resultSelected.CF__c){
			              $A.util.addClass(component.find('contact_codFiscale'), 'slds-has-error');
				          $A.util.addClass(component.find('codFisc'), 'slds-has-error');
                         validAll['DI_codFiscale'] = false;
                       } 
		            }
                }

                console.log('validAll', validAll);
                for (var key in validAll) {
                    if (validAll.hasOwnProperty(key) && !validAll[key]) {
                        isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                        isValid.valid = false;
                        if(key == 'civico_dimensione'){
                            isValid.msg = $A.get("$Label.c.WGC_CreateAccount_ErrorMessage_Civico");
                        } else if (key == 'DI_codFiscale'){
                            isValid.msg = $A.get("$Label.c.BI_CFDiverso");
                        } else {
                            isValid.msg = $A.get("$Label.c.WGC_CreateAccount_ErrorMessage_CensimentoFull");
                        }
                    }
                }
                break;
        }

        // this.renderMessages(msg);

        return isValid;
    },

    validatePartial: function (component, event) {
        var isValid = { step: "", valid: true, msg: "" };

        var cmpTarget = component.find('rae');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var cmpTarget = component.find('sae');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var cmpTarget = component.find('ateco');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var cmpTarget = component.find('rea');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var cmpTarget = component.find('provinciaCCIAA');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var resultSelected = component.get('v.resultSelected');
        var validAll = {};

        var cmpTarget = component.find('ragioneSociale');
        if (!resultSelected.hasOwnProperty('Name') || resultSelected.Name == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['ragioneSociale'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['ragioneSociale'] = true;
        }
        var cmpTarget = component.find('piva');
        if (!resultSelected.hasOwnProperty('PIVA__c') || resultSelected.PIVA__c == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['piva'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['piva'] = true;
        }
        var cmpTarget = component.find('codFisc');
        if (!resultSelected.hasOwnProperty('CF__c') || resultSelected.CF__c == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['codFisc'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['codFisc'] = true;
        }
        var cmpTarget = component.find('naturaGiuridica');
        if (!resultSelected.hasOwnProperty('NaturaGiuridica__c') || resultSelected.NaturaGiuridica__c == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['naturaGiuridica'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['naturaGiuridica'] = true;
        }

        var cmpTarget = component.find('nazione');
        if (!resultSelected.hasOwnProperty('BillingCountry') || resultSelected.BillingCountry == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['nazione'] = false;

        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['nazione'] = true;
        }
        var cmpTarget = component.find('provincia');
        if (!resultSelected.hasOwnProperty('BillingState') || resultSelected.BillingState == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['provincia'] = false;

        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['provincia'] = true;
        }
        if (resultSelected.BillingState == 'EE') {
            var cmpTarget = component.find('comuneEstero');
            if (!resultSelected.hasOwnProperty('BillingCity') || resultSelected.BillingCity == '') {
                $A.util.addClass(cmpTarget, 'slds-has-error');
                validAll['comuneEstero'] = false;
            } else {
                $A.util.removeClass(cmpTarget, 'slds-has-error');
                validAll['comuneEstero'] = true;
            }
        } else {
            var cmpTarget = component.find('comune');
            if (!resultSelected.hasOwnProperty('BillingCity') || resultSelected.BillingCity == '') {
                $A.util.addClass(cmpTarget, 'slds-has-error');
                validAll['comune'] = false;
            } else {
                $A.util.removeClass(cmpTarget, 'slds-has-error');
                validAll['comune'] = true;
            }
        }
        var cmpTarget = component.find('streetType');
        if (!resultSelected.hasOwnProperty('BillingStreetType__c') || resultSelected.BillingStreetType__c == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['streetType'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['streetType'] = true;
        }
        var cmpTarget = component.find('street');
        if (!resultSelected.hasOwnProperty('BillingStreetName__c') || resultSelected.BillingStreetName__c == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['street'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['street'] = true;
        }
        var cmpTarget = component.find('civico');
        if (!resultSelected.hasOwnProperty('BillingStreetNumber__c') || resultSelected.BillingStreetNumber__c == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['civico'] = false;
        } else {
            if(resultSelected.BillingStreetNumber__c.length > 6){
                $A.util.addClass(cmpTarget, 'slds-has-error');
                validAll['civico_dimensione'] = false;
            } else {
                $A.util.removeClass(cmpTarget, 'slds-has-error');
                validAll['civico'] = true;
            }
        }
        var cmpTarget = component.find('cap');
        if (!resultSelected.hasOwnProperty('BillingPostalCode') || resultSelected.BillingPostalCode == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['cap'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['cap'] = true;

        }

		//A.M. Verifica dati per DI
		var contactFromDI = component.get('v.contactFromDI');
        console.log('@@@ validate contactFromDI: ', contactFromDI);
        if (contactFromDI) {
           var contactDI = component.get('v.contactDI');
		   
		   var cmpTarget = component.find('contact_firstName');
           if (!contactDI.hasOwnProperty('FirstName') || contactDI.FirstName == '') {
               $A.util.addClass(cmpTarget, 'slds-has-error');
               validAll['contact_firstName'] = false;
           } else {
               $A.util.removeClass(cmpTarget, 'slds-has-error');
               validAll['contact_firstName'] = true;
           }
           var cmpTarget = component.find('contact_lastName');
           if (!contactDI.hasOwnProperty('LastName') || contactDI.LastName == '') {
               $A.util.addClass(cmpTarget, 'slds-has-error');
               validAll['contact_lastName'] = false;
           } else {
               $A.util.removeClass(cmpTarget, 'slds-has-error');
               validAll['contact_lastName'] = true;
           }
           var cmpTarget = component.find('contact_birthdate');
           if (!contactDI.hasOwnProperty('Birthdate') || contactDI.Birthdate == '') {
               $A.util.addClass(cmpTarget, 'slds-has-error');
               validAll['contact_birthdate'] = false;
           } else {
               $A.util.removeClass(cmpTarget, 'slds-has-error');
               validAll['contact_birthdate'] = true;
           }
           var cmpTarget = component.find('contact_sex');
           if (!contactDI.hasOwnProperty('Sesso__c') || contactDI.Sesso__c == '') {
               $A.util.addClass(cmpTarget, 'slds-has-error');
               validAll['contact_sex'] = false;
           } else {
               $A.util.removeClass(cmpTarget, 'slds-has-error');
               validAll['contact_sex'] = true;
           }
           var cmpTarget = component.find('contact_luogoDiNascita');
           if (!contactDI.hasOwnProperty('LuogoNascita__c') || contactDI.LuogoNascita__c == '') {
               $A.util.addClass(cmpTarget, 'slds-has-error');
               validAll['contact_luogoDiNascita'] = false;
           } else {
               $A.util.removeClass(cmpTarget, 'slds-has-error');
               validAll['contact_luogoDiNascita'] = true;
           }
           var cmpTarget = component.find('contact_codFiscale');
           if (!contactDI.hasOwnProperty('CF__c') || contactDI.CF__c == '') {
               $A.util.addClass(cmpTarget, 'slds-has-error');
               validAll['contact_codFiscale'] = false;
           } else {
               $A.util.removeClass(cmpTarget, 'slds-has-error');
               validAll['contact_codFiscale'] = true;
           }
		   var cmpTarget = component.find('contact_sae');
           if (!contactDI.hasOwnProperty('SAE__c') || contactDI.SAE__c == '') {
               $A.util.addClass(cmpTarget, 'slds-has-error');
               validAll['contact_sae'] = false;
           } else {
               $A.util.removeClass(cmpTarget, 'slds-has-error');
               validAll['contact_sae'] = true;
           }

           if (contactDI.hasOwnProperty('CF__c') && contactDI.CF__c != '' && resultSelected.hasOwnProperty('CF__c') && resultSelected.CF__c != '') {
               if (contactDI.CF__c != resultSelected.CF__c){
			       $A.util.addClass(component.find('contact_codFiscale'), 'slds-has-error');
				   $A.util.addClass(component.find('codFisc'), 'slds-has-error');
                   validAll['DI_codFiscale'] = false;
               } 
		   }
        }
		
		console.log(validAll);
        for (var key in validAll) {
            if (validAll.hasOwnProperty(key) && !validAll[key]) {
                isValid.valid = false;
                if(key == 'civico_dimensione'){
                    isValid.msg = $A.get("$Label.c.WGC_CreateAccount_ErrorMessage_Civico");
                } else if (key == 'DI_codFiscale'){
                    isValid.msg = $A.get("$Label.c.BI_CFDiverso");
                } else {
                    isValid.msg = $A.get("$Label.c.WGC_CreateAccount_ErrorMessage_CensimentoLight");
                }				
            }
        }
        // this.renderMessages(msg);


        return isValid;
    },

    isBlank: function (scope) {
        return (scope == null || scope == "") ? true : false;
    },

    getOriginAccount: function (accountId, component, event) {

        var action = component.get("c.getOriginAccount");
        action.setParams({
            "accountId": accountId
        });
        //Setting the Callback
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                var result = response.getReturnValue();
                console.log('NEW OBJ:');
                console.log(result);

                component.set('v.accountSelected', result);
            } else if (state == "ERROR") {
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },

    getInformationAccount: function (json, component, event) {
        this.showSpinner(component);

        var requestFilds = component.get('v.inputObject');
        console.log(requestFilds);

        var jsonParams = JSON.stringify(requestFilds);

        var action = component.get("c.getInformationAccount");
        action.setParams({
            "InputObjString": jsonParams
        });
        //Setting the Callback
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();
            var result = response.getReturnValue();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                console.log(result);
                if (result.success) {
                    component.set('v.result', result.data);
                    if (result.data.length <= 0) {
                        component.set('v.addManualmente', true);
                    } else {
                        result.data.forEach(function (element) {
                            if (element.Origine__c == 'Cerved') {
                                component.set('v.addManualmente', true);
                            }
                        });
                    }
                } else {
                    component.set('v.result', result.data);
                    component.set("v.errors", result.msg);
                    if (result.data.length <= 0) {
                        component.set('v.addManualmente', true);
                    } else {
                        result.data.forEach(function (element) {
                            if (element.Origine__c == 'Cerved') {
                                component.set('v.addManualmente', true);
                            }
                        });
                    }
                }

                component.set("v.page", json.target);
                this.confirmAction(json.action);

                if (!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    this.hideSpinner(component);

            } else if (state == "ERROR") {
                console.log("ERROR");
                console.log(result);
                // alert('Error in calling server side action');
                this.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    getInformationAccountFromRibes: function (component, event) {
        this.showSpinner(component);

        var requestFilds = component.get('v.inputObject');
        console.log(requestFilds);
        var jsonParams = JSON.stringify(requestFilds);

        var accountList = component.get('v.result');
        console.log(accountList);
        var jsonAccountList = JSON.stringify(accountList);

        var action = component.get("c.getInformationAccountFromRibes");
        action.setParams({
            "InputObjString": jsonParams,
            "AccountListString": jsonAccountList
        });
        //Setting the Callback
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();
            var result = response.getReturnValue();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                console.log(result);
                if (result.success) {
                    component.set('v.result', result.data);
                    component.set('v.addManualmente', true);
                    var cmpTarget = component.find('searchInRibes');
                    $A.util.addClass(cmpTarget, 'notShow');

                    // DATATABLE
                    /*
                    component.set('v.columns', [
                        { label: 'Name', fieldName: 'Name', type: 'text',  cellAttributes: { class: { fieldName:"Origine__c" } } },
                        { label: 'P.IVA', fieldName: 'PIVA__c', type: 'text', fixedWidth:160,  cellAttributes: { class: { fieldName:"Origine__c" } }  },
                    ]);
                    */


                } else {
                    component.set("v.errors", result.msg);
                }

                if (!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    this.hideSpinner(component);

            } else if (state == "ERROR") {
                console.log("ERROR");
                console.log(result);
                // alert('Error in calling server side action');
                this.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);

    },

    setInformationAccount: function (json, component, event) {
        this.showSpinner(component);
        var resultSelected = component.get("v.resultSelectedBefor");

        var action = component.get("c.setInformationAccount");
        action.setParams({
            "InputObj": resultSelected
        });
        //Setting the Callback
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();
            var result = response.getReturnValue();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                console.log('NEW OBJ setInformationAccount:');
                console.log(result);
				console.log('@@@resultSelected :', resultSelected);

                if (result.success) {

                    var requestFilds = component.get('v.inputObject');
					//A.M. aggiunta condizione BillingState == 'EE' per gestione esteri non di ifis finance
                    if (!requestFilds.estero && !resultSelected.BillingState =='EE') {
                        result.data[0].BillingCountry = 'ITALIA';
                        result.data[0].ShippingCountry = 'ITALIA';
                    }
                    if (resultSelected.hasOwnProperty('BillingCity') && resultSelected.BillingCity != '') {
                        result.data[0].BillingCity = result.data[0].BillingCity.toUpperCase();
                    }
                    if (resultSelected.hasOwnProperty('ShippingCity') && resultSelected.ShippingCity != '') {
                        result.data[0].ShippingCity = result.data[0].ShippingCity.toUpperCase();
                    }
                    component.set('v.resultSelected', result.data[0]);
                    if (result.data[0].NaturaGiuridica__c == 'DI') {
                        component.set('v.contactFromDI', true);
                        this.getContactDI(component, event).then(function (result) {
                            console.log('Call getContactDI result: ', result.data[0]);
                            //helper.resolveAction('complete', result, 'WGC_Account_Utility_EventiNegativi_ResolveEvent');
                            this.verifyCensimentoFull(result.data[0], component, event);
                        });

                    } else {this.verifyCensimentoFull(result, component, event);}

                    component.set("v.page", json.target);
                    this.confirmAction(json.action);
                    

                } else {
                    component.set("v.errors", result.msg);
                }

                if (!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    this.hideSpinner(component);
            } else if (state == "ERROR") {
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
                this.hideSpinner(component);

            }
        });
        $A.enqueueAction(action);
    },

    completeRegistration: function (tipoCensimento, component, event) {
        this.showSpinner(component);
        var h = this;
        var sedeOperativa = component.get("v.sedeOperativa");
        var resultSelected = component.get("v.resultSelected");
        var cntDI = component.get("v.contactDI");
        var originAccount = component.get("v.accountSelected");
        var tipoRecord = component.get("v.tipoRecord");
        var cointestazione = component.get("v.cointestazione");      
        
        console.log('cntDI', cntDI);

        resultSelected.Phone = resultSelected.TelefonoPrefisso__c + resultSelected.TelefonoNumero__c;

        // if (!sedeOperativa) {
        //     resultSelected.ShippingCountry = resultSelected.BillingCountry;
        //     resultSelected.ShippingState = resultSelected.BillingState;
        //     resultSelected.ShippingCity = resultSelected.BillingCity;
        //     resultSelected.ShippingStreetType__c = resultSelected.BillingStreetType__c;
        //     resultSelected.ShippingStreetName__c = resultSelected.BillingStreetName__c;
        //     resultSelected.ShippingStreetNumber__c = resultSelected.BillingStreetNumber__c;
        //     resultSelected.ShippingPostalCode = resultSelected.BillingPostalCode;

        // }
        var action = component.get("c.saveAccount");
        action.setParams({
            "objObject": resultSelected,
            "originAccount": (typeof (originAccount.Id) == "undefined") ? '' : originAccount.Id,
            "tipoRecord": tipoRecord,
            "tipoCensimento": tipoCensimento,
            "contactDI": cntDI
        });
        var opts = [];
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();
            var result = response.getReturnValue();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                if (result.success) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": $A.get("$Label.c.WGC_CreateAccount_Modal_Body_Anagrafica_aggiunta_con_successo"),
                        "type": "success"
                    });
                    toastEvent.fire();
                    this.resolveAction('submit', result.data[0], cointestazione, component.get("v.whoAreYou"));
                    component.find('overlayLib').notifyClose();

                } else {
                    component.set("v.errors", result.msg);
                }

                if (!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    this.hideSpinner(component);

            } else if (state == "ERROR") {
                console.log("ERROR");
                console.log(result);
                // alert('Error in calling server side action');
                this.hideSpinner(component);

            }
        });
        $A.enqueueAction(action);
    },

    showSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");

    },

    hideSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");

    },

    closeError: function (component, event) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"

        var cmpTarget = component.find('errors-container');
        $A.util.addClass(cmpTarget, 'transit');
        component.set("v.errors", null);
    },

    verifyCensimentoFull: function (data, component, event) {
        var contactFromDI = component.get('v.contactFromDI');
        console.log('contactFromDI ', contactFromDI);
        var checkEmptyFields = [
            { key: 'Name', value: (data.hasOwnProperty('Name') && data.Name != '') ? false : true },
            { key: 'PIVA__c', value: (data.hasOwnProperty('PIVA__c') && data.PIVA__c != '') ? false : true },
            { key: 'CF__c', value: (data.hasOwnProperty('CF__c') && data.CF__c != '') ? false : true },
            { key: 'NaturaGiuridica__c', value: (data.hasOwnProperty('NaturaGiuridica__c') && data.NaturaGiuridica__c != '') ? false : true },
            { key: 'SAE__c', value: (data.hasOwnProperty('SAE__c') && data.SAE__c != '') ? false : true },
            // { key: 'RAE__c', value: (data.hasOwnProperty('RAE__c') && data.RAE__c != '') ? false : true },
            { key: 'Ateco__c', value: (data.hasOwnProperty('Ateco__c') && data.Ateco__c != '') ? false : true },
            { key: 'REA__c', value: (data.hasOwnProperty('REA__c') && data.REA__c != '') ? false : true },
            { key: 'ProvinciaCCIAA__c', value: (data.hasOwnProperty('ProvinciaCCIAA__c') && data.ProvinciaCCIAA__c != '') ? false : true },
            // { key: 'CCIAA__c', value: (data.hasOwnProperty('CCIAA__c') && data.CCIAA__c != '') ? false : true },
            // { key: 'TelefonoPrefisso__c', value: (data.hasOwnProperty('TelefonoPrefisso__c') && data.TelefonoPrefisso__c != '') ? false : true },
            // { key: 'TelefonoNumero__c', value: (data.hasOwnProperty('TelefonoNumero__c') && data.TelefonoNumero__c != '') ? false : true },
            // { key: 'Email__c', value: (data.hasOwnProperty('Email__c') && data.Email__c != '') ? false : true },
            { key: 'BillingCountry', value: (data.hasOwnProperty('BillingCountry') && data.BillingCountry != '') ? false : true },
            { key: 'BillingState', value: (data.hasOwnProperty('BillingState') && data.BillingState != '') ? false : true },
            { key: 'BillingCity', value: (data.hasOwnProperty('BillingCity') && data.BillingCity != '') ? false : true },
            { key: 'BillingStreetType__c', value: (data.hasOwnProperty('BillingStreetType__c') && data.BillingStreetType__c != '') ? false : true },
            { key: 'BillingStreetName__c', value: (data.hasOwnProperty('BillingStreetName__c') && data.BillingStreetName__c != '') ? false : true },
            { key: 'BillingStreetNumber__c', value: (data.hasOwnProperty('BillingStreetNumber__c') && data.BillingStreetNumber__c != '') ? false : true },
            { key: 'BillingPostalCode', value: (data.hasOwnProperty('BillingPostalCode') && data.BillingPostalCode != '') ? false : true },
        ];

        var sedeOperativa = component.get('v.sedeOperativa');
        if (sedeOperativa) {
            var checkEmptySedeFields = [
                { key: 'ShippingCountry', value: (data.hasOwnProperty('ShippingCountry') && data.ShippingCountry != '') ? false : true },
                { key: 'ShippingState', value: (data.hasOwnProperty('ShippingState') && data.ShippingState != '') ? false : true },
                { key: 'ShippingCity', value: (data.hasOwnProperty('ShippingCity') && data.ShippingCity != '') ? false : true },
                { key: 'ShippingStreetType__c', value: (data.hasOwnProperty('ShippingStreetType__c') && data.ShippingStreetType__c != '') ? false : true },
                { key: 'ShippingStreetName__c', value: (data.hasOwnProperty('ShippingStreetName__c') && data.ShippingStreetName__c != '') ? false : true },
                { key: 'ShippingStreetNumber__c', value: (data.hasOwnProperty('ShippingStreetNumber__c') && data.ShippingStreetNumber__c != '') ? false : true },
                { key: 'ShippingPostalCode', value: (data.hasOwnProperty('ShippingPostalCode') && data.ShippingPostalCode != '') ? false : true },
            ];

            var checkEmptyFields = checkEmptyFields.concat(checkEmptySedeFields);
        }

        if (contactFromDI) {
            // toDO
            var contactDI = component.get('v.contactDI');
            console.log('contactDI ', contactDI);
            var checkEmptySedeFields = [
                { key: 'cdiFirstName', value: (contactDI.hasOwnProperty('FirstName') && contactDI.FirstName != '') ? false : true },
                { key: 'cdiLastName', value: (contactDI.hasOwnProperty('LastName') && contactDI.LastName != '') ? false : true },
                { key: 'cdiBirthdate', value: (contactDI.hasOwnProperty('Birthdate') && contactDI.Birthdate != '') ? false : true },
                { key: 'cdiSesso__c', value: (contactDI.hasOwnProperty('Sesso__c') && contactDI.Sesso__c != '') ? false : true },
                { key: 'cdiLuogoNascita__c', value: (contactDI.hasOwnProperty('LuogoNascita__c') && contactDI.LuogoNascita__c != '') ? false : true },
                { key: 'cdiCF__c', value: (contactDI.hasOwnProperty('CF__c') && contactDI.CF__c != '') ? false : true },
                { key: 'cdiTipoDocumentoId__c', value: (contactDI.hasOwnProperty('TipoDocumentoId__c') && contactDI.TipoDocumentoId__c != '') ? false : true },
                { key: 'cdiNumeroDoc__c', value: (contactDI.hasOwnProperty('NumeroDoc__c') && contactDI.NumeroDoc__c != '') ? false : true },
                { key: 'cdiLuogoEmissioneDoc__c', value: (contactDI.hasOwnProperty('LuogoEmissioneDoc__c') && contactDI.LuogoEmissioneDoc__c != '') ? false : true },
                { key: 'cdiDataEmissioneDoc__c', value: (contactDI.hasOwnProperty('DataEmissioneDoc__c') && contactDI.DataEmissioneDoc__c != '') ? false : true },
                { key: 'cdiDataScadenzaDoc__c', value: (contactDI.hasOwnProperty('DataScadenzaDoc__c') && contactDI.DataScadenzaDoc__c != '') ? false : true },
                // { key: 'cdiEnteEmitettenteDocumento__c', value: (contactDI.hasOwnProperty('EnteEmitettenteDocumento__c') && contactDI.EnteEmitettenteDocumento__c != '') ? false : true },
                { key: 'cdiSAE__c', value: (contactDI.hasOwnProperty('SAE__c') && contactDI.SAE__c != '') ? false : true },
            ];

            var checkEmptyFields = checkEmptyFields.concat(checkEmptySedeFields);
        }

        var findFieldEmpty = false;
        checkEmptyFields.forEach(function (element) {
            if (element.value) {
                findFieldEmpty = true;
            }
        });

        console.log('@@@ findFieldEmpty ', findFieldEmpty);
        console.log('@@@checkEmptyFields ', checkEmptyFields);


        component.set('v.buttonAggiugniECompletaDopo', !findFieldEmpty);
    },

    getContactDI: function (component, event) {

        var acc = component.get('v.resultSelected');
        var action = component.get("c.getContactFromDI");
        action.setParams({
            "InputObj": acc
        });
        //Setting the Callback
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                var result = response.getReturnValue();
                console.log('NEW OBJ:');
                console.log(result);
                result.TAECode__c = '984';
                result.SAE__c = '600';
                var myobj =  acc.hasOwnProperty("WGC_Contact_Information__c") ? JSON.parse(component.get("v.resultSelected").WGC_Contact_Information__c) : {"numero":null,"ente":null,"descrizioneTipo":null,"data":null,"codiceTipo":null,"dataScadenza":null};
                
                console.log('myobj', myobj);
                result.NumeroDoc__c = myobj.numero;
                result.LuogoEmissioneDoc__c = myobj.ente;
                if(myobj.data){
                    var dataEmissione = new Date(myobj.data);
                    result.DataEmissioneDoc__c = dataEmissione.getFullYear() + '-' + ("0" + (dataEmissione.getMonth() + 1)).slice(-2) + '-' + ("0" + dataEmissione.getDate()).slice(-2);    
                }
                if(myobj.dataScadenza != null){
                    var dataScadenza = new Date(myobj.dataScadenza);
                    result.DataScadenzaDoc__c = dataScadenza.getFullYear() + '-' + ("0" + (dataScadenza.getMonth() + 1)).slice(-2) + '-' + ("0" + dataScadenza.getDate()).slice(-2);
                }
                // CMPDGI59T26A757I
                result.TipoDocumentoId__c = myobj.codiceTipo;

                component.set('v.contactDI', result);
            } else if (state == "ERROR") {
                console.log("ERROR");
                console.log(result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },

    saveSoggettiCollegati: function (component, event) {
        console.log('saveSoggettiCollegati');

        var resultSelected = component.get("v.resultSelectedBefor");
        var originAccount = component.get("v.accountSelected");
        var tipoRecord = component.get("v.tipoRecord");

        console.log(resultSelected);
        console.log(originAccount);
        console.log(tipoRecord);

        var action = component.get("c.saveSoggettiCollegati");
        // String accountId, String originAccount, String tipoRecord
        action.setParams({
            "accountId": resultSelected.Id,
            "originAccount": (typeof (originAccount.Id) == "undefined") ? '' : originAccount.Id,
            "tipoRecord": tipoRecord
        });
        //Setting the Callback
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                var result = response.getReturnValue();

                console.log(result);

            } else if (state == "ERROR") {
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
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

    event: function (component, event, whatEvent, params) {
        var p = new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get("c." + apexAction + "");
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

    getAtecoObj: function (ateco, component, event) {
        var action = component.get("c.getAtecoElement");
        action.setParams({
            "atecoCod": ateco
        });
        //Setting the Callback
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('ATECO: ', result[0]);
                component.set('v.atecoSelected', result[0]);
            } else if (state == "ERROR") {
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
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

})