({
    doInit: function (component, event, helper) {
        var pg = component.get("v.pageReference");
        component.set("v.isDirezioneFD", pg.state.c__isDirezioneFD);

        var choiseObj = component.get('v.choiseObj');
        console.log('SV choiseObj', JSON.stringify(choiseObj));

        helper.apex(component, event, 'getUserInfo', {  })
        .then($A.getCallback(function (result) {
            console.log('Call getUserInfo result: ', result);
            component.set('v.userInfo', result);

            return helper.apex(component, event, 'getAllData', {})
            
            
        })).then($A.getCallback(function (result) {
            console.log('SV result ', result);
            component.set('v.allDataValue', result.data[0]);
                
        })).finally($A.getCallback(function () {
            helper.populateFilialePicklist(component, event, helper);
            helper.fetchPickListVal(component, 'Id', component.get("v.operatore_selected"), 'operatoriList');
            helper.generateChart(helper.dataChart(choiseObj, component.get('v.allDataValue'), component, event), helper.optionsChart(component, event), 'bar', 'chartJS_OppFD', component, event);
            helper.generateTable(choiseObj, component.get('v.allDataValue'), component, event);
                
            
        }));

    },

    navigateToMyComponent: function (component, event, helper) {

        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__namedPage",
            "attributes": {
                "pageName": "home"
            }
        }

        navService.navigate(pageReference);
    },

    navigateToDashboard: function (component, event, helper) {

        var navService = component.find("navService");
        var pageReference = {    
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.idDashboard"),
                "objectApiName": "Dashboard",
                "actionName": "view"
            }
        };

        navService.navigate(pageReference);
    },

    selectPeriodo: function (component, event, helper) {
        var choiseObj = component.get('v.choiseObj');
        choiseObj.filiale = component.get('v.filiale');
        choiseObj.categoria = component.get('v.categoria');
        choiseObj.periodo = component.get('v.status');
        choiseObj.operatore = component.get('v.operatore_selected');
        choiseObj.iniziativa = component.get('v.iniziativa');
        console.log('SV choiseObj', JSON.stringify(choiseObj));

        component.set('v.choiseObj', choiseObj);

        var result = component.get('v.allDataValue');
        console.log('result ', result);
        helper.generateChart(helper.dataChart(choiseObj, result, component, event), helper.optionsChart(component, event), 'bar', 'chartJS_OppFD', component, event);
        helper.generateTable(choiseObj, component.get('v.allDataValue'), component, event);

    },

})