({
    doInit: function (component, event, helper) {

        var opt = component.get("v.options");
        console.log(opt);
        component.set("v.page", component.get("v.options")[0].title);
        component.set("v.whoAreYou", component.get("v.options")[0].whoAreYou);
        if (component.get("v.options")[0].cointestazione == true)
            component.set("v.cointestazione", component.get("v.options")[0].cointestazione);

        helper.getRecordsWrapper(component);
        helper.getCedacriSleepTime(component, event);

        // the function that reads the url parameters
        /*
		var path = decodeURIComponent(window.location.pathname); //You get the whole decoded URL of the page.
		var pathArray = path.split('/');

		console.log(path);
		console.log(pathArray);
        */

        // whoAreYou Opportunity di tipo fastfinace elenco correlato attori

        if (component.get("v.options")[0].whoAreYou == 'Opportunity') {
            helper.apex(component, event, 'getUserInfo', {  })
            .then($A.getCallback(function (result) {
                console.log('Call getUserInfo result: ', result);
                component.set('v.userInfo', result);
                return helper.apex(component, event, 'getOriginOpportunity', { oppId: component.get("v.options")[0].accountId })
            })).then($A.getCallback(function (result) {
                    console.log('SV OPP: ', result);
                    component.set("v.opportunitySelected", result);
                    return helper.apex(component, event, 'getOriginAccount', { accountId: result.Assuntore__c })
            })).then($A.getCallback(function (result) {
                    component.set("v.accountSelected", result);
            })).finally($A.getCallback(function () {

            }));
        } else {
            if (component.get("v.options")[0].accountId) {
                helper.apex(component, event, 'getUserInfo', {  })
                .then($A.getCallback(function (result) {
                    console.log('Call getUserInfo result: ', result);
                    component.set('v.userInfo', result);
                    return helper.apex(component, event, 'getOriginAccount', { accountId: component.get("v.options")[0].accountId })
                })).then($A.getCallback(function (result) {
                    component.set("v.accountSelected", result);
                })).finally($A.getCallback(function () {

                }));
            }
        }

                    helper.fetchPickListVal(component, 'SAE__c', 'InputPicklistSAE');
                    helper.fetchPickListVal(component, 'Sesso__c', 'InputPicklistSex');
                    helper.fetchPickListVal(component, 'TipoDocumentoId__c', 'InputPicklistTipoDoc');

                    helper.fetchPickListVal_Nazione(component, 'Comune__c', 'optionsPicklistNazione');
                    helper.fetchPickListVal_Province(component, 'optionsPicklistProvince');
                    helper.fetchPickListVal(component, 'MailingStreetType__c', 'optionsPicklistAddressType');
                    helper.fetchPickListVal(component, 'StatoFastFinance__c', 'InputPicklistStatoFastFinance');
        			helper.fetchPickListVal(component, 'WGC_Ruolo__c', 'InputPicklistRuolo');

    },

    manageF2B: function (component, event, helper) {
        // manage Footer event
        var json = JSON.parse(event.getParam("json"));

        switch (json.action) {
            case 'next':
                var validObject = helper.validate(json, component, event);
                if (validObject.valid) {
                    helper.closeError(component, event);
                    if (validObject.step == 'search_next_result') {
                        helper.getInformationContact(json, component, event);
                    } else if (validObject.step == 'result_next_submit') {
                        // var acc = component.get("v.accountSelected");
                        // console.log(acc);

                        var selected = component.get("v.resultSelected");
                        var whoAreYou = component.get('v.whoAreYou');
                        var tipoRecord = component.get('v.tipoRecord');
                        var cointestazione = component.get("v.cointestazione");
                        // helper.setInformationContact(json, component, event);

                        if (selected.Origine__c == 'CRM') {
                            if (whoAreYou == 'carrello') {
                                if (selected.WGC_Censimento_MAV__c == 'Completo') {
                                    helper.resolveAction('submit', selected, cointestazione, whoAreYou);
                                    component.find('overlayLib').notifyClose();
                                } else {
                                    component.set('v.buttonAggiugniECompletaDopoNascosto', true);
                                    helper.setInformationContact(json, component, event);
                                }
                            } else if(whoAreYou == 'filoDiretto'){
                                helper.resolveAction('submit', selected, cointestazione, whoAreYou);
                                component.find('overlayLib').notifyClose();
                            }else {

                                helper.setInformationContact(json, component, event);
                            }
                        } else {
                            if (whoAreYou == 'carrello') {
                                component.set('v.buttonAggiugniECompletaDopoNascosto', true);
                            }

                            helper.setInformationContact(json, component, event);

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
                var validObject = helper.validate(json, component, event);
                if (validObject.valid) {
                    helper.closeError(component, event);
                    helper.completeRegistration("full", component, event);
                } else {
                    component.set("v.errors", validObject.msg);
                }
                break;
        }
    },

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
        console.log(resultSelected);

        component.set('v.resultSelected', resultSelected);

        if (!component.get("v.options")[0].accountId && resultSelected.AccountId) {
            helper.getOriginAccount(resultSelected.AccountId, component, event);
        }
    },

    changeSelectedAccount: function (component, event, helper) {
        if (event.getParam('value')[0]) {
            helper.getOriginAccount(event.getParam('value')[0], component, event);
        } else {
            component.set("v.accountSelected", "");
        }
    },

    goToSubmit: function (component, event, helper) {
        component.set("v.isAggiungiManuale", true);
        component.set("v.page", "submit");
        var resultSelected = component.get('v.resultSelected');

        resultSelected.MailingCountry = 'ITALIA';
        resultSelected.TAECode__c = '984';

        component.set('v.resultSelected', resultSelected),
            helper.closeError(component, event);

        helper.fireEvent(JSON.stringify({ "action": "navigate-to", "target": "submit" }), 'ModalBody2FooterEvent');
        /*
        component.set("v.page", json.target);
        this.confirmAction(json.action);
        */

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

    updateComuni: function (component, event, helper) {
        var resultSelected = component.get('v.resultSelected');

        helper.fetchPickListVal_Comune(component, resultSelected.MailingState, "optionsPicklistComune");

    },

    updateProvincia: function (component, event, helper) {
        var resultSelected = component.get('v.resultSelected');

        if (resultSelected.MailingCountry == 'ITALIA') {
            component.set('v.isProvinciaEstera', false);
            if (resultSelected.MailingState == 'EE') {
                component.set('v.resultSelected.MailingState', '');
            }
        } else if (resultSelected.MailingCountry == '' || resultSelected.MailingCountry == null) {
            component.set('v.isProvinciaEstera', false);
            component.set('v.resultSelected.MailingState', '');
            component.set('v.resultSelected.MailingCity', '');
        } else {
            component.set('v.isProvinciaEstera', true);
            component.set('v.resultSelected.MailingState', 'EE');
            component.set('v.resultSelected.MailingCity', '');
        }

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

    verifyAllField: function (component, event, helper) {
        var accountSelect = component.get('v.accountSelected');
        var contactSelect = component.get('v.resultSelected');

        helper.verifyCensimentoFull(accountSelect, contactSelect, component, event);
    },

    //changes filter parameters
    handleSelectChangeEvent: function (component, event, helper) {
        var items = component.get("v.mySelectedItems");
        items = event.getParam("values");
        component.set("v.mySelectedItems", items);
        console.log('EVENT items: ', items);
    }

})