({
	doInit : function(component, event, helper) {

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
        helper.getRecordsWrapper(component);

        helper.fetchPickListVal_Nazione(component, 'Comune__c', 'optionsPicklistNazione');
        helper.fetchPickListVal_Province(component, 'optionsPicklistProvince');

        //helper.fetchPickListVal_RecordType(component, 'Account', 'InputRecordTypeOptions');
        helper.fetchPickListVal(component, 'NaturaGiuridica__c', component.get("v.resultSelected"), 'InputPicklistNaturaGiuridica');
        // helper.fetchPickListVal(component, 'SAE__c', 'InputPicklistSAE');
        // helper.fetchPickListVal(component, 'RAE__c', component.get("v.resultSelected"), 'InputPicklistRAE_all');

        helper.fetchPickListVal(component, 'BillingStreetType__c', component.get("v.resultSelected"), 'optionsPicklistAddressType');
        
        helper.fetchPickListVal(component, 'WGC_Ente_segnalante__c', component.get("v.resultSelected"), 'InputPicklistEnteSegnalante');

        helper.fetchPickListVal(component, 'TAECode__c', component.get("v.contactDI"), 'InputPicklistTAE');
        helper.fetchPickListVal(component, 'Sesso__c', component.get("v.contactDI"), 'InputPicklistSex');
        helper.fetchPickListVal(component, 'TipoDocumentoId__c', component.get("v.contactDI"), 'InputPicklistTipoDoc');
		
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

    manageF2B: function (component, event, helper) {
        // manage Footer

        var page = component.get('v.page');
        var buttonName = event.getSource().get("v.name");
        console.log('PAGE', page);
        console.log('buttonName', buttonName);

        if(page == 'search'){
            if(buttonName == 'next'){
                var validObject = helper.validate(component, event);
                console.log(validObject);
                if (validObject.valid) {
                    helper.getInformationAccount(component, event);
                } else {
                    component.set("v.errors", validObject.msg);
                }
            }
        } else if(page == 'result'){
            if(buttonName == 'next'){
                var validObject = helper.validate(component, event);
                console.log(validObject);
                if (validObject.valid) {
                    var selected = component.get('v.resultSelectedBefor');
                    var whoAreYou = component.get('v.whoAreYou');
                    var tipoRecord = component.get('v.tipoRecord');
                    var cointestazione = component.get("v.cointestazione");
                    console.log('tipoRecord: ', tipoRecord);
                    
                        


                } else {
                    component.set("v.errors", validObject.msg);
                }
            }
        }
    },

    closeError: function (component, event) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"

        var cmpTarget = component.find('errors-container');
        $A.util.addClass(cmpTarget, 'transit');
        component.set("v.errors", null);
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
        console.log(resultSelected);

        component.set('v.resultSelectedBefor', resultSelected);
    },

    searchInRibes: function (component, event, helper) {
        helper.getInformationAccountFromRibes(component, event);
    },

    
})