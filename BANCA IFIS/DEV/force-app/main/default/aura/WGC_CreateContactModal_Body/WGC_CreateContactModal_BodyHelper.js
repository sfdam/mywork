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
        if(whoAreYou == 'filoDiretto'){
            this.fireEvent(JSON.stringify({ "action": action, "data": data, "cointestazione": cointestazione, "whoAreYou": whoAreYou }), 'WGC_CreateContactResolveEvent_filoDiretto');
        }{
            this.fireEvent(JSON.stringify({ "action": action, "data": data, "cointestazione": cointestazione, "whoAreYou": whoAreYou }), 'WGC_CreateContactResolveEvent');
        }
    },

    closeAction: function (component, event, target) {
        var cointestazione = component.get("v.cointestazione");
        var obj = {};
        this.resolveAction('cancel', obj, cointestazione, component.get("v.whoAreYou"));
        component.find('overlayLib').notifyClose();

    },

    getRecordsWrapper: function (component) {
        var whoAreYou = component.get("v.whoAreYou");

        var action = component.get("c.getPositionRecords");

        //Setting the Callback
        action.setCallback(this, function (a) {
            //get the response state
            var state = a.getState();
            var result = a.getReturnValue();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");                
                console.log(result);
                result.whoAreYou = whoAreYou;
                if (!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    component.set("v.inputObject", result);
            } else if (state == "ERROR") {
                console.log("ERROR");
                console.log(result);
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
            var result = response.getReturnValue();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                console.log('NEW OBJ:');
                console.log(result);

                component.set('v.accountSelected', result);

            } else if (state == "ERROR") {
                console.log("ERROR");
                console.log(result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },

    getOriginOpportunity: function (oppId, component, event) {
        var action = component.get("c.getOriginOpportunity");
        action.setParams({
            "oppId": oppId
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
                component.set('v.opportunitySelected', result);

            } else if (state == "ERROR") {
                console.log("ERROR");
                console.log(result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },

    getInformationContact: function (json, component, event) {
        this.showSpinner(component);

        var requestFilds = component.get('v.inputObject');
        console.log(requestFilds);

        var jsonParams = JSON.stringify(requestFilds);

        var action = component.get("c.getInformationContact");
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
                    }
                } else {
                    component.set('v.result', result.data);
                    component.set("v.errors", result.msg);
                    if (result.data.length <= 0) {
                        component.set('v.addManualmente', true);
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

    setInformationContact: function (json, component, event) {
        this.showSpinner(component);
        var accountSelect = component.get('v.accountSelected');
        var action = component.get("c.setInformationContact");
        action.setParams({
            "InputObj": component.get("v.resultSelected")
        });
        //Setting the Callback
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();
            var result = response.getReturnValue();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                console.log('NEW OBJ:');
                console.log(result);

                if (result.success) {
                    result.data[0].MailingCountry = 'ITALIA';
                    result.data[0].TAECode__c = '984';
    
                    component.set('v.resultSelected', result.data[0]);
                    this.verifyCensimentoFull(accountSelect, result, component, event);
    
                    component.set("v.page", json.target);
                    this.confirmAction(json.action);
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

    completeRegistration: function (tipoCensimento, component, event) {

        this.showSpinner(component);
        var resultSelected = component.get("v.resultSelected");
        var accId = component.get("v.accountSelected").Id;
        var selectedRoles = component.get("v.mySelectedItems");
        var whoAreYou = component.get("v.whoAreYou");
        var opportunitySelected = component.get("v.opportunitySelected");
        var censimentoLead = component.get("v.censimentoLead");
        var cointestazione = component.get("v.cointestazione");

        console.log('VANESSA whoAreYou: ', whoAreYou);
        console.log('VANESSA opportunitySelected: ', opportunitySelected);

        var action = component.get("c.saveContact");
        action.setParams({
            "objObject": resultSelected,
            "AccountId": accId,
            "selectedRoles": selectedRoles,
            "tipoCensimento": censimentoLead ? 'censimentoLead' : tipoCensimento,
            "whoAreYou" : whoAreYou,
            "opportunitySelected" : opportunitySelected
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
                        "message": "Contatto aggiunto con successo.",
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

    validate: function (json, component, event) {
        var isValid = { step: "", valid: true, msg: "" };

        console.log(component.get("v.page") + '_' + json.action + '_' + json.target);
        switch (component.get("v.page") + '_' + json.action + '_' + json.target) {
            case 'search_next_result':
                var inputObject = component.get('v.inputObject');
                if (inputObject.tipoDiRicerca == 'cFiscale') {
                    var cmpTarget = component.find('search_cFiscale');
                    if (!inputObject.hasOwnProperty('cf') || inputObject.cf == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                        isValid.valid = false;
                        isValid.msg = 'Ricerca per codice fiscale: inserire i campi obligatori';
                        // msg.push({ "type" : "info" , "text" : "Almeno uno tra Codice Fiscale e Cognome deve essere compilato." });
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                    }
                } else {
                    var cmpTarget = component.find('search_lastname');
                    if (!inputObject.hasOwnProperty('lastName') || inputObject.lastName == '') {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                        isValid.valid = false;
                        isValid.msg = 'Ricerca per nome e cognome: inserire i campi obligatori';
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                    }
                }
                console.log(inputObject);
                isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                break;
            case 'result_next_submit':
                var resultSelected = component.get('v.resultSelected');
                var result = component.get('v.result');
                console.log(resultSelected.LastName);

                if (resultSelected.LastName == null || resultSelected.LastName == '') {
                    isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                    isValid.valid = false;
                    isValid.msg = 'Seleziona un Contact';
                    // msg.push({ "type" : "info" , "text" : "Almeno uno tra Codice Fiscale e Cognome deve essere compilato." });
                } else {
                    isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                    this.fetchPickListVal_Comune(component, resultSelected.MailingState, "optionsPicklistComune");

                }
                break;
            case 'submit_submit_end':
                var resultSelected = component.get('v.resultSelected');
                var opportunitySelected = component.get('v.opportunitySelected');
                var whoAreYou = component.get('v.whoAreYou');
                var censimentoLead = component.get('v.censimentoLead');

                var validAll = {};

                if(whoAreYou == 'Opportunity' && opportunitySelected.RecordType.DeveloperName == 'IFISOpportunitaFastFinance'){
                    var cmpTarget = component.find('statoFastFinance');
                    if (cmpTarget.get('v.value') == '' || cmpTarget.get('v.value') == null) {
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['statoFastFinance'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['statoFastFinance'] = true;
                    }
                }

                // var cmpTarget = component.find('recordEditFormAccountId');
                // console.log('cmpTarget: ', cmpTarget);
                // if (cmpTarget.get('v.value') == '' || cmpTarget.get('v.value') == null) {
                //     $A.util.addClass(cmpTarget, 'slds-has-error');
                //     validAll['accountId'] = false;
                // } else {
                //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                //     validAll['accountId'] = true;
                // }

                var accountSelected = component.get('v.accountSelected');
                console.log('VALIDATE: ', accountSelected);
                if (!accountSelected.hasOwnProperty('Id') || accountSelected.Id == '' || accountSelected.Id == undefined) {
                    // $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['accountId'] = false;
                    component.set('v.accountIdError', true);
                } else {
                    // $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['accountId'] = true;
                    component.set('v.accountIdError', false);
                }
                
                // if(whoAreYou != 'Opportunity'){
                //     var selectedRoles = component.get('v.mySelectedItems');

                //     var size = 0, key;
                //     for (key in selectedRoles) {
                //         if (selectedRoles.hasOwnProperty(key)) size++;
                //     }
                //     console.log('SV size: ', size);
                //     console.log('SV roles: ', selectedRoles);
                //     if (size <= 0) {
                //         console.log('IF');
                //         validAll['ruolo'] = false;
                //         component.set('v.roleError', true);
                //     } else {
                //         console.log('ELSE');
                //         validAll['ruolo'] = true;
                //         component.set('v.roleError', false);
                //     }
                // }

                // var selectedRoles = component.get('v.mySelectedItems');
                // console.log('SV roles: ', selectedRoles);
                // if (selectedRoles.size > 0) {
                //    console.log('IF');
                //    validAll['ruolo'] = false;
                //    component.set('v.roleError', false);
                // } else {
                //    console.log('ELSE');
                //    validAll['ruolo'] = true;
                //    component.set('v.roleError', true);
                // }
                // var cmpTarget = component.find('statoFastFinance');
                // if (!resultSelected.hasOwnProperty('StatoFastFinance__c') || resultSelected.StatoFastFinance__c == '') {
                //     $A.util.addClass(cmpTarget, 'slds-has-error');
                //     validAll['statoFastFinance'] = false;
                // } else {
                //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                //     validAll['statoFastFinance'] = true;
                // }

                var cmpTarget = component.find('firstName');
                if (!resultSelected.hasOwnProperty('FirstName') || resultSelected.FirstName == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['firstName'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['firstName'] = true;
                }

                var cmpTarget = component.find('lastName');
                if (!resultSelected.hasOwnProperty('LastName') || resultSelected.LastName == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['lastName'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['lastName'] = true;
                }

                if(!censimentoLead){
                    var cmpTarget = component.find('birthdate');
                if (!resultSelected.hasOwnProperty('Birthdate') || resultSelected.Birthdate == null) {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['birthdate'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['birthdate'] = true;
                }

                var cmpTarget = component.find('sex');
                if (!resultSelected.hasOwnProperty('Sesso__c') || resultSelected.Sesso__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['sex'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['sex'] = true;
                }

                var cmpTarget = component.find('luogoDiNascita');
                if (!resultSelected.hasOwnProperty('LuogoNascita__c') || resultSelected.LuogoNascita__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['luogoDiNascita'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['luogoDiNascita'] = true;
                }

                var cmpTarget = component.find('codFiscale');
                if (!resultSelected.hasOwnProperty('CF__c') || resultSelected.CF__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['codFiscale'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['codFiscale'] = true;
                }

                var cmpTarget = component.find('sae');
                if (!resultSelected.hasOwnProperty('SAE__c') || resultSelected.SAE__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['sae'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['sae'] = true;
                }

                var cmpTarget = component.find('tipoDoc');
                if (!resultSelected.hasOwnProperty('TipoDocumentoId__c') || resultSelected.TipoDocumentoId__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['tipoDoc'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['tipoDoc'] = true;
                }

                var cmpTarget = component.find('numDoc');
                if (!resultSelected.hasOwnProperty('NumeroDoc__c') || resultSelected.NumeroDoc__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['numDoc'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['numDoc'] = true;
                }

                var cmpTarget = component.find('luogoEmissione');
                if (!resultSelected.hasOwnProperty('LuogoEmissioneDoc__c') || resultSelected.LuogoEmissioneDoc__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['luogoEmissione'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['luogoEmissione'] = true;
                }

                var cmpTarget = component.find('dataEmissione');
                if (!resultSelected.hasOwnProperty('DataEmissioneDoc__c') || resultSelected.DataEmissioneDoc__c == null) {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['dataEmissione'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['dataEmissione'] = true;
                }

                var cmpTarget = component.find('dataScadenza');
                if (!resultSelected.hasOwnProperty('DataScadenzaDoc__c') || resultSelected.DataScadenzaDoc__c == null) {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['dataScadenza'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['dataScadenza'] = true;
                }

                // var cmpTarget = component.find('enteEmittente');
                // if (!resultSelected.hasOwnProperty('EnteEmitettenteDocumento__c') || resultSelected.EnteEmitettenteDocumento__c == '') {
                //     $A.util.addClass(cmpTarget, 'slds-has-error');
                //     validAll['enteEmittente'] = false;
                // } else {
                //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                //     validAll['enteEmittente'] = true;
                // }

                // var cmpTarget = component.find('phone');
                // if (!resultSelected.hasOwnProperty('Phone') || resultSelected.Phone == '') {
                //     $A.util.addClass(cmpTarget, 'slds-has-error');
                //     validAll['phone'] = false;
                // } else {
                //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                //     validAll['phone'] = true;
                // }

                // var cmpTarget = component.find('mobilePhone');
                // if (!resultSelected.hasOwnProperty('MobilePhone') || resultSelected.MobilePhone == '') {
                //     $A.util.addClass(cmpTarget, 'slds-has-error');
                //     validAll['mobilePhone'] = false;
                // } else {
                //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                //     validAll['mobilePhone'] = true;
                // }

                // var cmpTarget = component.find('email');
                // if (!resultSelected.hasOwnProperty('Email') || resultSelected.Email == '') {
                //     $A.util.addClass(cmpTarget, 'slds-has-error');
                //     validAll['email'] = false;
                // } else {
                //     $A.util.removeClass(cmpTarget, 'slds-has-error');
                //     validAll['email'] = true;
                // }

                var cmpTarget = component.find('nazione');
                if (!resultSelected.hasOwnProperty('MailingCountry') || resultSelected.MailingCountry == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['nazione'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['nazione'] = true;
                }

                var cmpTarget = component.find('provincia');
                if (!resultSelected.hasOwnProperty('MailingState') || resultSelected.MailingState == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['provincia'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['provincia'] = true;
                }

                var cmpTargetA = component.find('comuneEstero');
                var cmpTargetB = component.find('comune');
                if (!resultSelected.hasOwnProperty('MailingCity') || resultSelected.MailingCity == '') {
                    $A.util.addClass(cmpTargetA, 'slds-has-error');
                    $A.util.addClass(cmpTargetB, 'slds-has-error');
                    validAll['comune'] = false;
                } else {
                    $A.util.removeClass(cmpTargetA, 'slds-has-error');
                    $A.util.removeClass(cmpTargetB, 'slds-has-error');
                    validAll['comune'] = true;
                }

                var cmpTarget = component.find('tipoVia');
                if (!resultSelected.hasOwnProperty('MailingStreetType__c') || resultSelected.MailingStreetType__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['tipoVia'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['tipoVia'] = true;
                }

                var cmpTarget = component.find('street');
                if (!resultSelected.hasOwnProperty('MailingStreetName__c') || resultSelected.MailingStreetName__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['street'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['street'] = true;
                }

                var cmpTarget = component.find('civico');
                if (!resultSelected.hasOwnProperty('MailingStreetNumber__c') || resultSelected.MailingStreetNumber__c == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['civico'] = false;
                } else {
                    if(resultSelected.MailingStreetNumber__c.length > 6){
                        $A.util.addClass(cmpTarget, 'slds-has-error');
                        validAll['civico_dimensione'] = false;
                    } else {
                        $A.util.removeClass(cmpTarget, 'slds-has-error');
                        validAll['civico'] = true;
                    }
                }

                var cmpTarget = component.find('cap');
                if (!resultSelected.hasOwnProperty('MailingPostalCode') || resultSelected.MailingPostalCode == '') {
                    $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['cap'] = false;
                } else {
                    $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['cap'] = true;
                }
                }

                

                console.log(validAll);
                for (var key in validAll) {
                    if (validAll.hasOwnProperty(key) && !validAll[key]) {
                        isValid.step = component.get("v.page") + '_' + json.action + '_' + json.target;
                        isValid.valid = false;
                        if(key == 'civico_dimensione'){
                            isValid.msg = $A.get("$Label.c.WGC_CreateAccount_ErrorMessage_Civico");
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

        var cmpTarget = component.find('birthdate');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var cmpTarget = component.find('luogoDiNascita');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var cmpTarget = component.find('sae');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var cmpTarget = component.find('tipoDoc');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var cmpTarget = component.find('numDoc');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var cmpTarget = component.find('luogoEmissione');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var cmpTarget = component.find('dataEmissione');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var cmpTarget = component.find('dataScadenza');
        $A.util.removeClass(cmpTarget, 'slds-has-error');

        var resultSelected = component.get('v.resultSelected');
        var validAll = {};

        // var cmpTarget = component.find('recordEditFormAccountId');
        // console.log('cmpTarget: ', cmpTarget);
        // if (cmpTarget.get('v.value') == '' || cmpTarget.get('v.value') == null) {
        //     $A.util.addClass(cmpTarget, 'slds-has-error');
        //     validAll['accountId'] = false;
        // } else {
        //     $A.util.removeClass(cmpTarget, 'slds-has-error');
        //     validAll['accountId'] = true;
        // }

        var accountSelected = component.get('v.accountSelected');
        console.log('VALIDATE: ', accountSelected);
                if (!accountSelected.hasOwnProperty('Id') || accountSelected.Id == '' || accountSelected.Id == undefined) {
                    // $A.util.addClass(cmpTarget, 'slds-has-error');
                    validAll['accountId'] = false;
                    component.set('v.accountIdError', true);
                } else {
                    // $A.util.removeClass(cmpTarget, 'slds-has-error');
                    validAll['accountId'] = true;
                    component.set('v.accountIdError', false);
                }

        var cmpTarget = component.find('firstName');
        if (!resultSelected.hasOwnProperty('FirstName') || resultSelected.FirstName == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['firstName'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['firstName'] = true;
        }

        var cmpTarget = component.find('lastName');
        if (!resultSelected.hasOwnProperty('LastName') || resultSelected.LastName == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['lastName'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['lastName'] = true;
        }

        var cmpTarget = component.find('sex');
        if (!resultSelected.hasOwnProperty('Sesso__c') || resultSelected.Sesso__c == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['sex'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['sex'] = true;
        }

        var cmpTarget = component.find('codFiscale');
        if (!resultSelected.hasOwnProperty('CF__c') || resultSelected.CF__c == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['codFiscale'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['codFiscale'] = true;
        }

        var cmpTarget = component.find('nazione');
        if (!resultSelected.hasOwnProperty('MailingCountry') || resultSelected.MailingCountry == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['nazione'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['nazione'] = true;
        }

        var cmpTarget = component.find('provincia');
        if (!resultSelected.hasOwnProperty('MailingState') || resultSelected.MailingState == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['provincia'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['provincia'] = true;
        }

        var cmpTargetA = component.find('comuneEstero');
        var cmpTargetB = component.find('comune');
        if (!resultSelected.hasOwnProperty('MailingCity') || resultSelected.MailingCity == '') {
            $A.util.addClass(cmpTargetA, 'slds-has-error');
            $A.util.addClass(cmpTargetB, 'slds-has-error');
            validAll['comune'] = false;
        } else {
            $A.util.removeClass(cmpTargetA, 'slds-has-error');
            $A.util.removeClass(cmpTargetB, 'slds-has-error');
            validAll['comune'] = true;
        }

        var cmpTarget = component.find('tipoVia');
        if (!resultSelected.hasOwnProperty('MailingStreetType__c') || resultSelected.MailingStreetType__c == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['tipoVia'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['tipoVia'] = true;
        }

        var cmpTarget = component.find('street');
        if (!resultSelected.hasOwnProperty('MailingStreetName__c') || resultSelected.MailingStreetName__c == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['street'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['street'] = true;
        }

        var cmpTarget = component.find('civico');
        if (!resultSelected.hasOwnProperty('MailingStreetNumber__c') || resultSelected.MailingStreetNumber__c == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['civico'] = false;
        } else {
            if(resultSelected.MailingStreetNumber__c.length > 6){
                $A.util.addClass(cmpTarget, 'slds-has-error');
                validAll['civico_dimensione'] = false;
            } else {
                $A.util.removeClass(cmpTarget, 'slds-has-error');
                validAll['civico'] = true;
            }
        }

        var cmpTarget = component.find('cap');
        if (!resultSelected.hasOwnProperty('MailingPostalCode') || resultSelected.MailingPostalCode == '') {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            validAll['cap'] = false;
        } else {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            validAll['cap'] = true;
        }

        console.log(validAll);
        for (var key in validAll) {
            if (validAll.hasOwnProperty(key) && !validAll[key]) {
                isValid.valid = false;
                if(key == 'civico_dimensione'){
                    isValid.msg = $A.get("$Label.c.WGC_CreateAccount_ErrorMessage_Civico");
                } else {
                    isValid.msg = $A.get("$Label.c.WGC_CreateAccount_ErrorMessage_CensimentoLight");
                }
            }
        }
        // this.renderMessages(msg);

        return isValid;
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
                opts.push({
                    class: "",
                    label: "",
                    value: ""
                });

                allValues.forEach(function (element) {
                    opts.push({
                        class: "",
                        label: element.Name,
                        value: element.Name
                    });
                });

                console.log(allValues);

                component.set("v." + fieldName, opts);
            }
        });
        $A.enqueueAction(action);


    },

    fetchPickListVal: function (component, fieldName, elementId) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": (fieldName == 'WGC_Ruolo__c') ? component.get("v.AccountContactRelation") : component.get("v.resultSelected"),
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
                        label: k,
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

    verifyCensimentoFull: function (dataAccount, dataContact, component, event) {
        console.log(dataAccount);
        console.log(dataContact);

        var checkEmptyFields = [

            { key: 'AccountId', value: (dataAccount.hasOwnProperty('Id') && dataAccount.Id != '') ? false : true },
            { key: 'AccountName', value: (dataAccount.hasOwnProperty('Name') && dataAccount.Name != '') ? false : true },
            { key: 'FirstName', value: (dataContact.hasOwnProperty('FirstName') && dataContact.FirstName != '') ? false : true },
            { key: 'LastName', value: (dataContact.hasOwnProperty('LastName') && dataContact.LastName != '') ? false : true },
            { key: 'Birthdate', value: (dataContact.hasOwnProperty('Birthdate') && dataContact.Birthdate != '') ? false : true },
            { key: 'Sesso__c', value: (dataContact.hasOwnProperty('Sesso__c') && dataContact.Sesso__c != '') ? false : true },
            { key: 'LuogoNascita__c', value: (dataContact.hasOwnProperty('LuogoNascita__c') && dataContact.LuogoNascita__c != '') ? false : true },
            { key: 'CF__c', value: (dataContact.hasOwnProperty('CF__c') && dataContact.CF__c != '') ? false : true },
            { key: 'SAE__c', value: (dataContact.hasOwnProperty('SAE__c') && dataContact.SAE__c != '') ? false : true },
            { key: 'LuogoNascita__c', value: (dataContact.hasOwnProperty('LuogoNascita__c') && dataContact.LuogoNascita__c != '') ? false : true },
            { key: 'NumeroDoc__c', value: (dataContact.hasOwnProperty('NumeroDoc__c') && dataContact.NumeroDoc__c != '') ? false : true },
            { key: 'TipoDocumentoId__c', value: (dataContact.hasOwnProperty('TipoDocumentoId__c') && dataContact.TipoDocumentoId__c != '') ? false : true },
            { key: 'LuogoEmissioneDoc__c', value: (dataContact.hasOwnProperty('LuogoEmissioneDoc__c') && dataContact.LuogoEmissioneDoc__c != '') ? false : true },
            // { key: 'EnteEmitettenteDocumento__c', value: (dataContact.hasOwnProperty('LuogoEmissioneDoc__c') && dataContact.LuogoEmissioneDoc__c != '') ? false : true },
            { key: 'DataEmissioneDoc__c', value: (dataContact.hasOwnProperty('DataEmissioneDoc__c') && dataContact.DataEmissioneDoc__c != '') ? false : true },
            { key: 'DataScadenzaDoc__c', value: (dataContact.hasOwnProperty('DataScadenzaDoc__c') && dataContact.DataScadenzaDoc__c != '') ? false : true },
            { key: 'MailingCountry', value: (dataContact.hasOwnProperty('MailingCountry') && dataContact.MailingCountry != '') ? false : true },
            { key: 'MailingState', value: (dataContact.hasOwnProperty('MailingState') && dataContact.MailingState != '') ? false : true },
            { key: 'MailingCity', value: (dataContact.hasOwnProperty('MailingCity') && dataContact.MailingCity != '') ? false : true },
            { key: 'MailingStreetType__c', value: (dataContact.hasOwnProperty('MailingStreetType__c') && dataContact.MailingStreetType__c != '') ? false : true },
            { key: 'MailingStreetName__c', value: (dataContact.hasOwnProperty('MailingStreetName__c') && dataContact.MailingStreetName__c != '') ? false : true },
            { key: 'MailingStreetNumber__c', value: (dataContact.hasOwnProperty('MailingStreetNumber__c') && dataContact.MailingStreetNumber__c != '') ? false : true },
            { key: 'MailingPostalCode', value: (dataContact.hasOwnProperty('MailingPostalCode') && dataContact.MailingPostalCode != '') ? false : true },

        ];

        var findFieldEmpty = false;
        checkEmptyFields.forEach(function (element) {
            if (element.value) {
                findFieldEmpty = true;
            }
        });

        component.set('v.buttonAggiugniECompletaDopo', !findFieldEmpty);
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
            var result = response.getReturnValue();

            //check if result is successfull
            if (state == "SUCCESS") {
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
    			console.log("ERROR");
                console.log(result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },

})