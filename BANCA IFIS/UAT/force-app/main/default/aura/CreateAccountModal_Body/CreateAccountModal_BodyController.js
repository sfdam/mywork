({
    doInit: function (component, event, helper) {
        helper.showSpinner(component);
        helper.apex(component, event, 'getUserInfo', {  })
        .then($A.getCallback(function (result) {
            console.log('Call getUserInfo result: ', result);
            component.set('v.userInfo', result);
            if(result.Qualifica_Utente__c == 'IFIS Finance'){
                component.set('v.ifisFinance', true);
                
            } else {

                component.set('v.ifisFinance', false);

            }
        })).finally($A.getCallback(function () {
            console.log('ifisFinance', component.get('v.ifisFinance'));
            helper.getRecordsWrapper(component);
            helper.getCedacriSleepTime(component, event);

            var options = component.get("v.options");
            console.log(options);
            component.set("v.page", component.get("v.options")[0].title);
            component.set("v.whoAreYou", component.get("v.options")[0].whoAreYou);
            if (component.get("v.options")[0].cointestazione)
                component.set("v.cointestazione", component.get("v.options")[0].cointestazione);

            // the function that reads the url parameters
            /*
            var path = decodeURIComponent(window.location.pathname); //You get the whole decoded URL of the page.
            var pathArray = path.split('/');

            console.log(path);
            console.log(pathArray);
            */

            if (options[0].accountId != '') {
                helper.getOriginAccount(component.get("v.options")[0].accountId, component, event);
            }

            if (options[0].tipoRecord != '') {
                component.set("v.tipoRecord", options[0].tipoRecord);
            }

            helper.fetchPickListVal_Nazione(component, 'Comune__c', 'optionsPicklistNazione');
            helper.fetchPickListVal_Province(component, 'optionsPicklistProvince');

            //helper.fetchPickListVal_RecordType(component, 'Account', 'InputRecordTypeOptions');
            helper.fetchPickListVal(component, 'NaturaGiuridica__c', component.get("v.resultSelected"), 'InputPicklistNaturaGiuridica');
            // helper.fetchPickListVal(component, 'SAE__c', 'InputPicklistSAE');
            // helper.fetchPickListVal(component, 'RAE__c', component.get("v.resultSelected"), 'InputPicklistRAE_all');

            helper.fetchPickListVal(component, 'BillingStreetType__c', component.get("v.resultSelected"), 'optionsPicklistAddressType');
            
            // helper.fetchPickListVal(component, 'WGC_Ente_segnalante__c', component.get("v.resultSelected"), 'InputPicklistEnteSegnalante');

            helper.fetchPickListVal(component, 'TAECode__c', component.get("v.contactDI"), 'InputPicklistTAE');
            helper.fetchPickListVal(component, 'Sesso__c', component.get("v.contactDI"), 'InputPicklistSex');
            helper.fetchPickListVal(component, 'TipoDocumentoId__c', component.get("v.contactDI"), 'InputPicklistTipoDoc');

            // helper.getAllAteco(component, event);
            helper.hideSpinner(component);
        }));
        
    },

    manageF2B: function (component, event, helper) {
        // manage Footer event
        var json = JSON.parse(event.getParam("json"));
        console.log('@@@manageF2B-json ', json);

        switch (json.action) {
            case 'next':
                var validObject = helper.validate(json, component, event);
                console.log('QUESTO: ', validObject);
                if (validObject.valid) {
                    helper.closeError(component, event);
                    if (validObject.step == 'search_next_result') {
                        helper.getInformationAccount(json, component, event);
                    } else if (validObject.step == 'result_next_submit') {
                        var selected = component.get('v.resultSelectedBefor');
                        var whoAreYou = component.get('v.whoAreYou');
                        var tipoRecord = component.get('v.tipoRecord');
                        var cointestazione = component.get("v.cointestazione");

						//A.M. Gestione anagrafiche estere o PA
						if (selected.BillingState == 'EE' || selected.NaturaGiuridica__c == 'ENTP' || selected.NaturaGiuridica__c == 'AP')
						   {var NoREA = true;
						    component.set('v.AccountNoREA', NoREA);}

                        console.log('tipoRecord: ', tipoRecord);
                        if (selected.Origine__c == 'CRM') {
                            if (whoAreYou == 'censimentoAnagrafica') {
                                if (tipoRecord == 'Fornitore' || tipoRecord == 'Cliente' || tipoRecord == 'Referral') {
                                    helper.saveSoggettiCollegati(component, event);
                                    helper.resolveAction('submit', selected, cointestazione, whoAreYou);
                                    component.find('overlayLib').notifyClose();
                                } else {
                                    helper.resolveAction('submit', selected, cointestazione, whoAreYou);
                                    component.find('overlayLib').notifyClose();
                                }
                            } else if (whoAreYou == 'carrello') {
                                console.log('WGC_Censimento__c: ', selected.WGC_Censimento__c);
                                if (selected.WGC_Censimento__c == 'Completo') {
                                    helper.resolveAction('submit', selected, cointestazione, whoAreYou);
                                    component.find('overlayLib').notifyClose();
                                } else {
                                    component.set('v.buttonAggiugniECompletaDopoNascosto', true);
                                    helper.setInformationAccount(json, component, event);

                                }
                            } else {
                                helper.apex(component, event, 'setInformationAccount', { InputObj: resultSelected })
                                    .then(function (result) {
                                        console.log('Call setInformationAccount result: ', result);
                                        var requestFilds = component.get('v.inputObject');
                                        console.log('@@@requestFilds: ', requestFilds);

                                        if (result.success) {
										    //A.M. aggiunta condizione !selected.BillingState == 'EE' per gestione esteri non di ifis finance
                                            if (!requestFilds.estero && !selected.BillingState == 'EE') {
                                                result.data[0].BillingCountry = 'ITALIA';
                                                result.data[0].ShippingCountry = 'ITALIA';
                                            } else {
                                                component.set('v.isProvinciaEsteraBilling', true);
                                                component.set('v.resultSelected.BillingState', 'EE');
                                                component.set('v.resultSelected.BillingCity', '');
    
                                                if (resultSelected.ShippingCountry != 'ITALIA') {
                                                    component.set('v.isProvinciaEsteraShipping', true);
                                                    component.set('v.resultSelected.ShippingState', 'EE');
                                                    component.set('v.resultSelected.ShippingCity', '');
                                                }
                                            }
                                            if (resultSelected.hasOwnProperty('BillingCity') && resultSelected.BillingCity != '') {
                                                result.data[0].BillingCity = result.data[0].BillingCity.toUpperCase();
                                            }
                                            if (resultSelected.hasOwnProperty('ShippingCity') && resultSelected.ShippingCity != '') {
                                                result.data[0].ShippingCity = result.data[0].ShippingCity.toUpperCase();
                                            }
                                            component.set('v.resultSelected', result.data[0]);                    
                                        } else {
										    //A.M. aggiunta condizione !selected.BillingState == 'EE' per gestione esteri non di ifis finance
                                            if (!requestFilds.estero && !selected.BillingState == 'EE') {
                                                resultSelected.BillingCountry = 'ITALIA';
                                                resultSelected.ShippingCountry = 'ITALIA';
                                            }
                                            component.set('v.resultSelected',resultSelected);
                                            component.set("v.errors", result.msg);
                                        }
                                    }).finally($A.getCallback(function () {
                                        var resultSelected = component.get("v.resultSelected");
                                        helper.verifyCensimentoFull(resultSelected, component, event);
                                        component.set("v.page", json.target);
                                        helper.hideSpinner(component);
                                        helper.confirmAction(json.action);
                                    }));
                            }
                        } else {
                            if (whoAreYou == 'carrello') {
                                component.set('v.buttonAggiugniECompletaDopoNascosto', true);
                            }
							var resultSelected = component.get("v.resultSelectedBefor");
							console.log('@@@ resultSelected: ', resultSelected);
                            helper.showSpinner(component);
                            helper.apex(component, event, 'setInformationAccount', { InputObj: resultSelected })
                                .then(function (result) {
                                    console.log('@@@ Call setInformationAccount result: ', result);
                                    var requestFilds = component.get('v.inputObject');

                                    if (result.success) {
                                        //A.M. aggiunta condizione !resultSelected.BillingState == 'EE' per gestione esteri non di ifis finance
                                        if (!requestFilds.estero && !resultSelected.BillingState == 'EE') {
                                            result.data[0].BillingCountry = 'ITALIA';
                                            result.data[0].ShippingCountry = 'ITALIA';
                                        } else {
                                            component.set('v.isProvinciaEsteraBilling', true);
                                            component.set('v.resultSelected.BillingState', 'EE');
                                            component.set('v.resultSelected.BillingCity', '');

                                            if (!resultSelected.ShippingCountry != 'ITALIA') {
                                                component.set('v.isProvinciaEsteraShipping', true);
                                                component.set('v.resultSelected.ShippingState', 'EE');
                                                component.set('v.resultSelected.ShippingCity', '');
                                            }

                                        }
                                        if (resultSelected.hasOwnProperty('BillingCity') && resultSelected.BillingCity != '') {
                                            result.data[0].BillingCity = result.data[0].BillingCity.toUpperCase();
                                        }
                                        if (resultSelected.hasOwnProperty('ShippingCity') && resultSelected.ShippingCity != '') {
                                            result.data[0].ShippingCity = result.data[0].ShippingCity.toUpperCase();
                                        }
                                        component.set('v.resultSelected', result.data[0]);
                                        
                                        return helper.apex(component, event, 'getAtecoElement', { atecoCod: result.data[0].Ateco__c });             
                                    } else {
									    //A.M. aggiunta condizione !resultSelected.BillingState == 'EE' per gestione esteri non di ifis finance 
                                        if (!requestFilds.estero && !resultSelected.BillingState == 'EE') {
                                            resultSelected.BillingCountry = 'ITALIA';
                                            resultSelected.ShippingCountry = 'ITALIA';
                                        }
                                        component.set('v.resultSelected',resultSelected);
                                        component.set("v.errors", result.msg);
                                    }


                                    // if (!requestFilds.estero) {
                                    //     result.BillingCountry = 'ITALIA';
                                    //     result.ShippingCountry = 'ITALIA';
                                    // } else {
                                    //     console.log('DENTROOOOOO: ', requestFilds);
                                    //     component.set('v.isProvinciaEsteraBilling', true);
                                    //     component.set('v.resultSelected.BillingState', 'EE');
                                    //     component.set('v.resultSelected.BillingCity', '');

                                    //     if (!resultSelected.ShippingCountry != 'ITALIA') {
                                    //         component.set('v.isProvinciaEsteraShipping', true);
                                    //         component.set('v.resultSelected.ShippingState', 'EE');
                                    //         component.set('v.resultSelected.ShippingCity', '');
                                    //     }

                                    // }
                                    // if (resultSelected.hasOwnProperty('BillingCity') && resultSelected.BillingCity != '') {
                                    //     result.BillingCity = result.BillingCity.toUpperCase();
                                    // }
                                    // if (resultSelected.hasOwnProperty('ShippingCity') && resultSelected.ShippingCity != '') {
                                    //     result.ShippingCity = result.ShippingCity.toUpperCase();
                                    // }
                                    // component.set('v.resultSelected', result);
                                    
                                    // return helper.apex(component, event, 'getAtecoElement', { atecoCod: result.Ateco__c });
                                }).then(function (result) {
                                    console.log('@@@1 Call getAtecoElement result: ', result);
                                    if(result != undefined){
                                        component.set('v.atecoSelected', result[0]);
                                    }
                                }).finally($A.getCallback(function () {
                                    var resultSelected = component.get("v.resultSelected");
                                    // helper.getAtecoObj(resultSelected.Ateco__c, component, event);
                                    helper.verifyCensimentoFull(resultSelected, component, event);
                                    component.set("v.page", json.target);
                                    helper.hideSpinner(component);
                                    helper.confirmAction(json.action);
                                }));
                        }
                    }
                } else {
                    component.set("v.errors", validObject.msg);
                }
                break;
            case 'back':
                component.set("v.page", json.target);
                component.set("v.result", []);
                component.set("v.addManualmente", false);
                helper.closeError(component, event);
                helper.confirmAction(json.action);
                break;
            case 'cancel':
                helper.closeAction(component, event, json.action);
                break;
            case 'submit':
				//adione - CR 211
				console.log('@@@--> v.resultSelected.BillingState: '+component.get('v.resultSelected.BillingState') );
				var isEstero = component.get('v.resultSelected.BillingState') == 'EE';
				console.log('@@@--> isEstero: '+isEstero);
				var newSAE = component.get('v.resultSelected.SAE__c');
				console.log('@@@--> newSAE: '+newSAE);
				var natGiuridica = component.get('v.resultSelected.NaturaGiuridica__c');
				console.log('@@@--> natGiuridica: '+natGiuridica);
				var action = component.get("c.getCCIAA_ATECO_Conf");
				//String naturaGiuridica, String sae, String recordId, String objType
				action.setParams({
					"naturaGiuridica": natGiuridica,
					"sae": newSAE,
					"recordId": null,
					"objType": "Account"
				});

				//Setting the Callback
				action.setCallback(this, function (a) {
					//get the response state
					var state = a.getState();

					//check if result is successfull
					if (state == "SUCCESS") {
						var atecoObb = JSON.parse(a.getReturnValue());
						console.log('@@@ --> atecoObb: '+atecoObb);
						//-------------------------------------------
				        var validObject = helper.validate(json, component, event, atecoObb);
						if (validObject.valid) {
							helper.closeError(component, event);
							helper.completeRegistration("full", component, event);
						} else {
							component.set("v.errors", validObject.msg);
						}
						//break;
						//----------------------------------------------
					} else if (state == "ERROR") {
						alert('Error in calling server side action');
					}
				});

				//adds the server-side action to the queue        
				$A.enqueueAction(action);
        }
    },

	//imposta il tipo ricerca: p.iva/rag.soc./ndg
    SetRequestType: function (component, event, helper) {

        if (!$A.util.isEmpty(component.get('v.inputObject'))) {
            var requestType = event.getSource().get("v.id");
            var requestFilds = component.get('v.inputObject');
            requestFilds.tipoDiRicerca = requestType;
            component.set('v.requestType', requestType);
            console.log(requestFilds);
        }

    },

    handleRowSelection: function (component, event, helper) {

        /*
        var selectedRows = event.getParam('selectedRows');
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            console.log(selectedRows[i]);
            component.set("v.resultSelected", selectedRows[i]);
        }
        */

        var selected = event.currentTarget.id;
        var selectedSplit = selected.split("_");
        console.log(selectedSplit);

        var result = component.get('v.result');
        console.log(result.length);

        for (var i = 0; i < result.length; i++) {
            var element = document.getElementById(selectedSplit[0] + '_' + i);
            element.classList.remove("selected");
        }

        var element = document.getElementById(selected);
        element.classList.add("selected");

        var resultSelected = result[selectedSplit[1]];
        if (resultSelected.hasOwnProperty('BillingCity') && resultSelected.BillingCity != '') {
            resultSelected.BillingCity = resultSelected.BillingCity.toUpperCase();
        }
        console.log('@@@handleRowSelection-resultSelectedBefor: ', resultSelected);

        component.set('v.resultSelectedBefor', resultSelected);
    },

    updateComuni: function (component, event, helper) {
        var resultSelected = component.get('v.resultSelected');
        console.log("resultSelected.BillingState: ", resultSelected.BillingState);
        helper.fetchPickListVal_Comune(component, resultSelected.BillingState, "optionsPicklistComune");

    },

    updateComuniShipping: function (component, event, helper) {
        var resultSelected = component.get('v.resultSelected');
        console.log("resultSelected.ShippingState: ", resultSelected.ShippingState);
        helper.fetchPickListVal_Comune(component, resultSelected.ShippingState, "optionsPicklistComuneShipping");

    },


    updateProvincia: function (component, event, helper) {
        var resultSelected = component.get('v.resultSelected');
        var estero = component.get('v.inputObject.estero');

        console.log('SV PROVINCE: ' + estero);

        if (resultSelected.BillingCountry == 'ITALIA') {
            component.set('v.isProvinciaEsteraBilling', false);
            if (resultSelected.BillingState == 'EE') {
                component.set('v.resultSelected.BillingState', '');
            }
        } else if ((resultSelected.BillingCountry == '' || resultSelected.BillingCountry == null) && !estero) {
            component.set('v.isProvinciaEsteraBilling', false);
            component.set('v.resultSelected.BillingState', '');
            component.set('v.resultSelected.BillingCity', '');
        } else {
            component.set('v.isProvinciaEsteraBilling', true);
            component.set('v.resultSelected.BillingState', 'EE');
            component.set('v.resultSelected.BillingCity', '');
        }

    },

    updateProvinciaShipping: function (component, event, helper) {
        var resultSelected = component.get('v.resultSelected');

        if (resultSelected.ShippingCountry == 'ITALIA') {
            component.set('v.isProvinciaEsteraShipping', false);
            if (resultSelected.ShippingState == 'EE') {
                component.set('v.resultSelected.ShippingState', '');
            }
        } else {
            component.set('v.isProvinciaEsteraShipping', true);
            component.set('v.resultSelected.ShippingState', 'EE');
            component.set('v.resultSelected.ShippingCity', '');
        }

    },

    partialRegistration: function (component, event, helper) {
        var validObject = helper.validatePartial(component, event);
        if (validObject.valid) {
            helper.closeError(component, event);
            helper.completeRegistration("light", component, event);
        } else {
            component.set("v.errors", validObject.msg);
        }

    },

    searchInRibes: function (component, event, helper) {
        helper.getInformationAccountFromRibes(component, event);
    },

    goToSubmit: function (component, event, helper) {
        component.set("v.page", "submit");
        var requestFilds = component.get('v.inputObject');
        var addManualmente = component.get('v.addManualmente');
        var resultSelected = component.get('v.resultSelected');
		//A.M. aggiunta condizione !resultSelected.BillingState == 'EE' per gestione esteri non di ifis finance
        if (!requestFilds.estero && addManualmente && !resultSelected.BillingState == 'EE') {
            resultSelected.BillingCountry = 'ITALIA';
        }

        resultSelected.NaturaGiuridica__c = 'none';

        component.set('v.resultSelected', resultSelected),
            helper.fireEvent(JSON.stringify({ "action": "navigate-to", "target": "submit" }), 'ModalBody2FooterEvent');
        /*
        component.set("v.page", json.target);
        this.confirmAction(json.action);
        */

    },

    closeError: function (component, event) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"

        var cmpTarget = component.find('errors-container');
        $A.util.addClass(cmpTarget, 'transit');
        component.set("v.errors", null);
    },

    closeCedacriError: function (component, event) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"

        var cmpTarget = component.find('errors-container-Cedacri');
        $A.util.addClass(cmpTarget, 'transit');
        component.set("v.CedacriSleepError", null);
    },

    accountSelectedNaturaGiuridica: function (component, event, helper) {
        var addManuale = component.get('v.addManualmente');
        var accountSelect = component.get('v.resultSelected');
        var oldValue = event.getParam("oldValue");

        console.log('OLD VALUE: ', oldValue);
        if(oldValue == undefined){
            oldValue = { NaturaGiuridica__c: 'none'};
        }

        if (oldValue.NaturaGiuridica__c != 'DI' && accountSelect.hasOwnProperty('NaturaGiuridica__c') && accountSelect.NaturaGiuridica__c == 'DI') {
            var validAll = {};

            var cmpTarget = component.find('ragioneSociale');
            if (!accountSelect.hasOwnProperty('Name') || accountSelect.Name == '') {
                $A.util.addClass(cmpTarget, 'slds-has-error');
                validAll['ragioneSociale'] = false;
            } else {
                $A.util.removeClass(cmpTarget, 'slds-has-error');
                validAll['ragioneSociale'] = true;
            }
            var cmpTarget = component.find('piva');
            if (!accountSelect.hasOwnProperty('PIVA__c') || accountSelect.PIVA__c == '') {
                $A.util.addClass(cmpTarget, 'slds-has-error');
                validAll['piva'] = false;
            } else {
                $A.util.removeClass(cmpTarget, 'slds-has-error');
                validAll['piva'] = true;
            }
            var cmpTarget = component.find('codFisc');
            if (!accountSelect.hasOwnProperty('CF__c') || accountSelect.CF__c == '') {
                $A.util.addClass(cmpTarget, 'slds-has-error');
                validAll['codFisc'] = false;
            } else {
                $A.util.removeClass(cmpTarget, 'slds-has-error');
                validAll['codFisc'] = true;
            }

            var dittaIndividuale = true;
            for (var key in validAll) {
                if (validAll.hasOwnProperty(key) && !validAll[key]) {
                    dittaIndividuale = false;
                    break;
                }
            }

            if (dittaIndividuale) {
                component.set('v.contactFromDI', true);
                helper.getContactDI(component, event);
                helper.fetchPickListVal_SAE(component, accountSelect, 'InputPicklistSAE');
                helper.closeError(component, event);

            } else {
                component.set('v.resultSelected.NaturaGiuridica__c', "");
                component.set("v.errors", $A.get("$Label.c.WGC_CreateAccount_Modal_Body_ContactDI_Error"));
            }

        } else {
            component.set('v.contactFromDI', false);
            helper.fetchPickListVal_SAE(component, accountSelect, 'InputPicklistSAE');
            helper.closeError(component, event);
        }


    },

    accountSelectedSAE: function (component, event, helper) {
        var accountSelect = component.get('v.resultSelected');
        // helper.fetchPickListVal_Ateco(component, accountSelect, 'InputPicklistSAE');
        helper.fetchPickListVal_RAE(component, accountSelect, 'InputPicklistRAE');
    },

    accountSelectedRAE: function (component, event, helper) {
        var accountSelect = component.get('v.resultSelected');
        helper.fetchPickListVal_Ateco(component, accountSelect, 'InputPicklistAteco');
    },

    verifyAllField: function (component, event, helper) {
        var accountSelect = component.get('v.resultSelected');
        helper.verifyCensimentoFull(accountSelect, component, event);
    },

    updateAteco: function (component, event, helper) {
        var atecoObj = component.get('v.atecoSelected');
        console.log('@@@ atecoObj: ', atecoObj);
        if(atecoObj != undefined){
            component.set('v.resultSelected.Ateco__c', atecoObj.Cedacri__c);
        }
    },

})