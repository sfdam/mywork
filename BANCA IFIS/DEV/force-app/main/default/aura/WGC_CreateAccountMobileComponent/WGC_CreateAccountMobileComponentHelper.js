({

    fireEvent: function (response, whatEvent) {
        var B2F = $A.get("e.c:" + whatEvent);
        B2F.setParams({ "json": response });
        B2F.fire();
    },

    resolveAction: function (action, data, cointestazione) {
        this.fireEvent(JSON.stringify({ "action": action, "data": data, "cointestazione": cointestazione }), 'WGC_CreateAccountResolveEvent');
    },

	getRecordsWrapper: function (component) {

        var action = component.get("c.getPositionRecords");

        //Setting the Callback
        action.setCallback(this, function (a) {
            //get the response state
            var state = a.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                var result = a.getReturnValue();
                console.log(result);
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

    validate: function (component, event) {
        var isValid = { step: "", valid: true, msg: "" };

        switch (component.get("v.page")) {
            case 'search':
                var inputObject = component.get('v.inputObject');
                if (inputObject.tipoDiRicerca == 'piva') {
                    var cmpTarget = component.find('search_piva');
                    console.log(inputObject);
                    if (inputObject.pivaOrCf == null || inputObject.pivaOrCf == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        isValid.step = component.get("v.page");
                        isValid.valid = false;
                        isValid.msg = 'Ricerca per partita IVA: inserire i campi obligatori';
                        // msg.push({ "type" : "info" , "text" : "Almeno uno tra Codice Fiscale e Cognome deve essere compilato." });
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        isValid.step = component.get("v.page") ;
                    }
                } else {
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
                    isValid.step = component.get("v.page");

                    for (var key in validAllRS) {
                        if (validAllRS.hasOwnProperty(key) && !validAllRS[key]) {
                            isValid.valid = false;
                            isValid.msg = 'Ricerca per Ragione Sociale: inserire i campi obligatori';
                        }
                    }
                }

                break;
            case 'result':
                var resultSelected = component.get('v.resultSelectedBefor');
                var result = component.get('v.result');
                console.log(resultSelected.Name);
                console.log(resultSelected.REA__c);

                if (resultSelected.Name == null || resultSelected.Name == '') {
                    isValid.step = component.get("v.page");
                    isValid.valid = false;
                    isValid.msg = 'Seleziona un Account';
                    // msg.push({ "type" : "info" , "text" : "Almeno uno tra Codice Fiscale e Cognome deve essere compilato." });
                } else {
                    isValid.step = component.get("v.page") ;
                    this.fetchPickListVal_Comune(component, resultSelected.BillingState, "optionsPicklistComune");
                }
                break;
            case 'submit_submit_end':
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
                // var cmpTarget = component.find('rae');
                // if (!resultSelected.hasOwnProperty('RAE__c') || resultSelected.RAE__c == '') {
                //     $A.util.addClass(cmpTarget, 'slds-has-error');
                //     validAll['rae'] = false;
                // } else {
                //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                //     validAll['rae'] = true;
                // }
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
                if (!resultSelected.hasOwnProperty('Ateco__c') || resultSelected.Ateco__c == '' || resultSelected.Ateco__c == undefined) {
                    // $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['ateco'] = false;
                    component.set('v.atecoError', true);
                } else {
                    // $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['ateco'] = true;
                    component.set('v.atecoError', false);
                }
                var cmpTarget = component.find('rea');
                if (!resultSelected.hasOwnProperty('REA__c') || resultSelected.REA__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['rea'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['rea'] = true;
                }
                var cmpTarget = component.find('provinciaCCIAA');
                if (!resultSelected.hasOwnProperty('ProvinciaCCIAA__c') || resultSelected.ProvinciaCCIAA__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['provinciaCCIAA'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['provinciaCCIAA'] = true;
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
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['civico'] = true;
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
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['civico_shipping'] = true;
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
                        $A.util.addClass(cmpTarget, 'slds-has-error');
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
                    var cmpTarget = component.find('contact_enteEmittente');
                    if (!contactDI.hasOwnProperty('EnteEmitettenteDocumento__c') || contactDI.EnteEmitettenteDocumento__c == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['contact_enteEmittente'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['contact_enteEmittente'] = true;
                    }
                }

                console.log(validAll);
                for (var key in validAll) {
                    if (validAll.hasOwnProperty(key) && !validAll[key]) {
                        isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                        isValid.valid = false;
                        isValid.msg = $A.get("$Label.c.WGC_CreateAccount_ErrorMessage_CensimentoFull");
                    }
                }
                break;
        }

        // this.renderMessages(msg);

        return isValid;
    },

    getInformationAccount: function (component, event) {
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
                            if (element.Origine__c == 'Ribes') {
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
                            if (element.Origine__c == 'Ribes') {
                                component.set('v.addManualmente', true);
                            }
                        });
                    }
                }

                component.set("v.page", 'result');

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


                } else {
                    alert(result.msg);
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

})