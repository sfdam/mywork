({
    doInit: function(component, event, helper) {
        helper.setupItems(component);
        helper.reloadJoinGaranziaGarante(component);
    },

    handleGaranEvent: function(component, event, helper) {
        let json = JSON.parse(event.getParam("json"));

        switch (json.action) {
            case "addGaranzia":
                helper.addGaranzia(component);
                break;
            case "editGaranzia":
                helper.editGaranzia(component);
                break;
            case "addNewPF":
                helper.addNewPF(component, false);
                break;
            case "addNewPG":
                helper.addNewPG(component, false);
                break;
            case "addNewCointPF":
                helper.addNewPF(component, true);
                break;
            case "addNewCointPG":
                helper.addNewPG(component, true);
                break;
            case "selectGaranzia":
                helper.selectGaranzia(component, json);
                break;
            case "removeItem":
                if (json.type == "garanzia")
                    helper.removeGaranzia(component, json.item);
                if (json.type == "garante")
                    helper.removeGarante(component, json.item);
                break;
        }
    },

    onGaranteResolveEvent: function(component, event, helper) {
        var json = JSON.parse(event.getParam("json"));
        console.log("onGaranteResolveEvent: ", json);
        if (json.whoAreYou == "carrello") {
            if (json.action == "submit") {
                if (json.cointestazione)
                    helper.gestisciCointestazione(component, json.data);
                else
                    helper.addGarante(component, json.data);
            }
        }
    },

    onCointestazioneResolveEvent: function(component, event, helper) {
        var json = JSON.parse(event.getParam("json"));

        if (json.action == "submit") {
            helper.addGaranti(component, json.data);
        }
    },

    onChangeGaranzie: function(component, event, helper) {
        let oldValue = event.getParam("oldValue");
        let newValue = event.getParam("value");

        if (oldValue.length != newValue.length)
            helper.refreshGaranzie(component, event);
    },

    onChangeJoin: function(component, event, helper) {
        var lControgarantito = component.get("v.payload.linee").filter((l) => { return l.codice == 'MutuoControgarantitoMCC'});
        
        if(lControgarantito.length > 0){
            var setGControgarantito = new Set();
            var gControgarantito = component.get("v.garanzie").forEach((gz) => { if(gz.Linea__c == lControgarantito[0].id) setGControgarantito.add(gz.IdEsterno__c) });
            var gUnicredit = component.get("v.garanti").filter((g) => { return g.NDG__c == $A.get("$Label.c.WGC_Cart_NdgFondoGaranzia")})
            var checkJoinGaranzie = component.get("v.joinGaranziaGarante").filter((gz) => { return setGControgarantito.has(gz.garanzia) && gUnicredit.length > 0 && gUnicredit[0].Id != gz.garante });
			var oldCheckJoinGaranzie = component.get("v.payload.joinGaranziaGarante").filter((gz) => { return setGControgarantito.has(gz.garanzia) && gUnicredit.length > 0 && gUnicredit[0].Id != gz.garante });

            if(event.getParam("value") && !event.getParam("value").hasOwnProperty("joinGaranziaGarante") && oldCheckJoinGaranzie.length >= 3 && checkJoinGaranzie.length >= 0) {
                var garanti = component.get("v.garanti");
                helper.firstDeleteGarantiControgarantito(component, event, helper);
                helper.handleModalMutuoControgarantito(component, event, helper, garanti);
            } 
            else {
                helper.reloadJoinGaranziaGarante(component);
            	helper.reloadGaranti(component, event);
            }
            
        } else {
            helper.reloadJoinGaranziaGarante(component);
            helper.reloadGaranti(component, event);
        }
    },

    conferma: function(component, event, helper) {
        helper.saveGarantiEGaranzie(component);
        // helper.navigateSubWizard(component, "analisiBilancio");
    },

    back: function(component, event, helper) {
        helper.navigateSubWizard(component, "configuraProdotto");
    },

    next: function(component, event, helper) {
        helper.navigateSubWizard(component, "analisiBilancio");
    },
})