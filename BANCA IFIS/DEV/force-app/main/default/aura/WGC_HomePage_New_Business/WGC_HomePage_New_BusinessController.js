({
    doInit: function (component, event, helper) {

        /*
            clienti avviati corrispondono ai clienti attivi
            visite : tutte legate all'utente mese/settimana
            opp    : tutte le opp settimana/mese passate da istruttoria -> valutazione pratica 
            circle contiene clienti avviati / clienti da avviare nel mese allinterno dell'Obj WGC_Budget__c
            togliere storico
        */

        helper.getUserInfo(component, event);

    },

    navigateToMyComponent: function (component, event, helper) {

        // var evt = $A.get("e.force:navigateToComponent");
        // evt.setParams({
        //     componentDef: "c:WGC_Bussiness_DetailComponent",
        //     componentAttributes: {

        //     }
        // });
        // evt.fire();

        var navService = component.find("navService");
        var pageReference = {    
            "type": "standard__component",
            "attributes": {
                "componentName": "c__WGC_Bussiness_DetailComponent"    
            },    
            "state": {

            }
        };

		navService.navigate(pageReference);
        
    },
})