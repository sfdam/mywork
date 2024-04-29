({
    setupItems: function(component) {
        let selectedProducts = component.get("v.selectedProducts");
        let items = [];
        // let divise = [];

        selectedProducts.forEach(i => {
            i.isActive = false;
            i.isSelected = true;
            i.isCompleted = false;
            i.debitori = null;
            i.icon = i.icona;
            i.title = i.nome;
            i.subtitle = this.getLineSubtitle(component, i);
            //SM - TEN: Aggiunta condizione per non mostrare linee tecniche corporate
            if(i.codice != 'FIDOSBF' && i.codice != 'ContoAnticipiPTF' && i.codice != 'FidoAnticipoFatture')
                items.push(i);
        });

        component.set("v.items", items);
        // if (component.get("v.divise").length == 0)
        //     component.set("v.divise", divise);
    },

    reloadJoinGaranziaGarante : function(component) {
        let joinGaranziaGarante = component.get("v.payload").joinGaranziaGarante;
        component.set("v.joinGaranziaGarante", joinGaranziaGarante);
    },

    navigateSubWizard : function(component, target) {
        let cmpEvent = component.getEvent("navigateSubWizard");
        cmpEvent.setParams({ "target": target });
        cmpEvent.fire();
    },

    addGaranzia : function(component) {
        let items = component.get("v.items");
        let appEvent = $A.get("e.c:WGC_ModalManagerEvent");
        appEvent.setParams({
            modalHeader: "Nuova Garanzia",
            modalBody: {
                type: "component",
                value: "c:WGC_Cart_NuovaGaranziaModal_Body",
                params: {
                    linee: items.filter(i => {return !i.codice.includes("IfisImpresa");}),
                    opportunityId: component.get("v.opportunityId"),
                    matriceGaranzie: component.get("v.matriceGaranzie"),
                    divise: component.get("v.garanzieDivise"),
                    isRevisione: component.get("v.isRevisione"),
                    configurazioneLinee: component.get("v.payload").configurazioneLinee
                }
            },
            modalFooter: null,
            showCloseButton: true,
            cssClass: "mymodal",
            preFunction: "" // metodo controller per recupero info metadati (omnibus etc.)
        });
        appEvent.fire();
    },

    editGaranzia : function(component) {
        let items = component.get("v.items");
        let appEvent = $A.get("e.c:WGC_ModalManagerEvent");
        let selectedGaranzia = component.get("v.selectedGaranzia");
        let garanzie = component.get("v.garanzie");
        appEvent.setParams({
            modalHeader: "Modifica Garanzia",
            modalBody: {
                type: "component",
                value: "c:WGC_Cart_NuovaGaranziaModal_Body",
                params: {
                    linee: items.filter(i => {return !i.codice.includes("IfisImpresa");}),
                    opportunityId: component.get("v.opportunityId"),
                    matriceGaranzie: component.get("v.matriceGaranzie"),
                    divise: component.get("v.garanzieDivise"),
                    isRevisione: component.get("v.isRevisione"),
                    configurazioneLinee: component.get("v.payload").configurazioneLinee,
                    garanzia: this.mapGaranzia(garanzie.find(g => {return g.IdEsterno__c == selectedGaranzia;})),
                    isEdit: true
                }
            },
            modalFooter: null,
            showCloseButton: true,
            cssClass: "mymodal",
            preFunction: "" // metodo controller per recupero info metadati (omnibus etc.)
        });
        appEvent.fire();
    },

    addNewPF : function(component, cointestazione) {
        let appEvent = $A.get("e.c:WGC_ModalManagerEvent");
        let options = [ { 'title': 'search', 'buttons': [{ 'type': 'next', 'requireValidation': true }], 'tipoRecord': "Cliente", "whoAreYou": "carrello", "cointestazione": cointestazione } , 
                        { 'title': 'result', 'buttons': [{ 'type': 'next', 'visible': false }] } , 
                        { 'title': 'submit', 'buttons': [{ 'type': 'back', 'visible': false }] } ];
        
        appEvent.setParams({
            modalHeader: "Inserisci Persona Fisica",
            modalBody: {
                type: "component",
                value: "c:WGC_CreateContactModal_Body",
                params: {options:options}
            },
            modalFooter: {
                type: "component",
                value: "c:WGC_CreateContactModal_Footer",
                params: {options:options}
            },
            showCloseButton: true,
            cssClass: "mymodal slds-modal_medium",
            preFunction: ""
        });
        appEvent.fire();
    },

    addNewPG : function(component, cointestazione) {
        let appEvent = $A.get("e.c:WGC_ModalManagerEvent");
        var options = [ { 'title': 'search', 'buttons': [{ 'type': 'next', 'requireValidation': true }] , 'accountId': component.get("v.accountId"), 'tipoRecord': "Cliente", "whoAreYou": "carrello", "cointestazione": cointestazione } , 
                        { 'title': 'result', 'buttons': [{ 'type': 'next', 'visible': false }] } , 
                        { 'title': 'submit', 'buttons': [{ 'type': 'back', 'visible': false }] } ];

        appEvent.setParams({
            modalHeader: "Inserisci Persona Giuridica",
            modalBody: {
                type: "component",
                value: "c:CreateAccountModal_Body",
                params: {options:options}
            },
            modalFooter: {
                type: "component",
                value: "c:CreateAccountModal_Footer",
                params: {options:options}
            },
            showCloseButton: true,
            cssClass: "mymodal slds-modal_medium",
            preFunction: ""
        });
        appEvent.fire();
    },

    addGarante : function(component, data) {
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.saveGarante" , "params": {
                garanteId: data.Id,
                opportunityId: component.get("v.opportunityId"),
                garanzia: component.get("v.selectedGaranzia")
            }
        });
        appEvent.fire();
    },

    addGaranti : function(component, data) {
        data.capoRete.attributes = {"type":"Account"};
        data.cointestatari.forEach(c => {
            c.attributes = {"type": (c.Id.startsWith("001") ? "Account" : "Contact")};
        });
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.saveGaranti" , "params": {
                cointestazione: JSON.stringify(data),
                oppId: component.get("v.opportunityId"),
                garanzia: component.get("v.selectedGaranzia")
            }
        });
        appEvent.fire();
    },

    gestisciCointestazione : function(component, data) {
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.gestisciCointestazione" , "params": {
                sObjectId: data.Id
            }
        });
        appEvent.fire();
    },

    refreshGaranzie : function(component, event) {
        let oldValue = event.getParam("oldValue");
        let newValue = event.getParam("value");

        let newGaranzia = newValue.find(nv => { return oldValue.map(ov => {return ov.IdEsterno__c;}).includes(nv.IdEsterno__c); });

        component.set("v.selectedGaranzia", (newGaranzia != undefined && newGaranzia != null ? newGaranzia.IdEsterno__c : null));
    },

    selectGaranzia : function(component, json) {
        let garanzia = json.garanzia.IdEsterno__c;
        let garanti = component.get("v.garanti");
        let joinGaranziaGarante = component.get("v.joinGaranziaGarante");
        // let selectedGarante;
        let selectedGaranti = [];
        let matriceGaranzie = component.get("v.matriceGaranzie");

        if (joinGaranziaGarante.filter(j => {return j.garanzia == garanzia;}).length > 0)
            selectedGaranti = garanti.filter(g => {return joinGaranziaGarante.filter(j => {return j.garanzia == garanzia;}).map(j => {return j.garante;}).includes(g.Id);});

        // if (selectedGarante != undefined)
        //     if (garanti.find(g => {return g.Id == selectedGarante;}) != null && garanti.find(g => {return g.Id == selectedGarante;}) != undefined)
        //         selectedGaranti.push(garanti.find(g => {return g.Id == selectedGarante;}));

        garanti.forEach(g => {
            g.isSelected = selectedGaranti.map(sg => {return sg.Id;}).includes(g.Id);
            g.percentualeGaranzia = (joinGaranziaGarante.find(j => {return j.garante == g.Id;}) ? joinGaranziaGarante.find(j => {return j.garante == g.Id;}).percentualeGaranzia : 0);
        });

        component.set("v.selectedGaranziaNeedCointestazione", matriceGaranzie.find(mg => {return mg.CodiceKNET__c == json.garanzia.CodiceGaranzia__c;}).ProQuota__c);
        component.set("v.selectedGaranzia", garanzia);
        component.set("v.selectedGaranti", selectedGaranti);
        component.set("v.garanti", garanti);
    },

    reloadGaranti : function(component, event) {
        let garanzia = component.get("v.selectedGaranzia");
        let garanti = component.get("v.garanti");
        let joinGaranziaGarante = (event.getParam("value").joinGaranziaGarante ? event.getParam("value").joinGaranziaGarante : component.get("v.joinGaranziaGarante"));

        // let selectedGarante;
        let selectedGaranti = [];
        
        if (joinGaranziaGarante.filter(j => {return j.garanzia == garanzia;}).length > 0){
            selectedGaranti = garanti.filter(g => {return joinGaranziaGarante.filter(j => {return j.garanzia == garanzia;}).map(j => {return j.garante;}).includes(g.Id);});
        }
        // if (selectedGarante != undefined)
        //     if (garanti.find(g => {return g.Id == selectedGarante;}) != null && garanti.find(g => {return g.Id == selectedGarante;}) != undefined)
        //         selectedGaranti.push(garanti.find(g => {return g.Id == selectedGarante;}));

        garanti.forEach(g => {
            g.isSelected = selectedGaranti.map(sg => {return sg.Id;}).includes(g.Id);
            g.percentualeGaranzia = (joinGaranziaGarante.find(j => {return j.garante == g.Id;}) ? joinGaranziaGarante.find(j => {return j.garante == g.Id;}).percentualeGaranzia : 0);
        });
        
        component.set("v.selectedGaranti", selectedGaranti);
        component.set("v.garanti", garanti);
    },

    removeGaranzia : function(component, garanzia) {
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.removeGaranzia" , "params": {
                garanziaId: garanzia.IdEsterno__c
            }
        });
        appEvent.fire();
    },

    removeGarante : function(component, garante) {
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.removeGarante" , "params": {
                garanteId: garante.Id
            }
        });
        appEvent.fire();
    },

    removeGaranti : function(component, idsGarantiToDelete){
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.removeGaranti" , "params": {
                garantiIds: idsGarantiToDelete
            }
        });
        appEvent.fire();
    },

    saveGarantiEGaranzie : function(component, garante) {
        let payload = component.get("v.payload");
        let joinGaranziaGarante = component.get("v.joinGaranziaGarante");
        let garanti = component.get("v.garanti");
        console.log('@@@ garanti ' , garanti);
        let garanzie = component.get("v.garanzie");
        let matriceGaranzie = component.get("v.matriceGaranzie");
        let prdGaranDef = matriceGaranzie.filter(mg => {return mg.Tipo__c == "Percentuale";}).map(mg => {return mg.ProdottiGaranteDefault__c}).reduce((start, str) => {return start.concat(str.split(";"));}, []);
        let lineeMutui = payload.linee.filter(l => {return prdGaranDef.includes(l.codice);});

        let allMutuiHaveGaranzie = lineeMutui.reduce((start, l) => {
            return start && garanzie.filter(g => {return g.Linea__c == l.id;}).length > 0;
        }, true);

        let lineaControgarantito = payload.linee.filter((l) => { return l.codice == 'MutuoControgarantitoMCC' });
		if(lineaControgarantito.length > 0){
            var setGaranzieControgarantito = new Set();
            garanzie.forEach((g) => { if(lineaControgarantito[0].id == g.Linea__c) setGaranzieControgarantito.add(g.IdEsterno__c); });
            var existingJoins = joinGaranziaGarante.filter((jgg) => { return setGaranzieControgarantito.has(jgg.garanzia) } );
		}

        if (!allMutuiHaveGaranzie) {
            this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_GaranzieMissingPerMutui"), "warning");
        } else if (garanzie.filter(g => {return !joinGaranziaGarante.map(j => {return j.garanzia;}).includes(g.IdEsterno__c);}).length > 0)
            this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_GaranzieNonAssociate"), "warning");
        else if(payload.linee.filter((l) => { return l.codice == 'MutuoControgarantitoMCC'}).length > 0 && existingJoins.length < 2){
            //let lineaControgarantito = payload.linee.filter((l) => { return l.codice == 'MutuoControgarantitoMCC' });
            //let setGaranzieControgarantito = new Set();
            //garanzie.forEach((g) => { if(lineaControgarantito[0].id == g.Linea__c) setGaranzieControgarantito.add(g.IdEsterno__c); });
            //let existingJoins = joinGaranziaGarante.filter((jgg) => { return setGaranzieControgarantito.has(jgg.garanzia) } );
            if(existingJoins.length == 1 && garanti.filter((g) => { return g.Id == existingJoins[0].garante })[0].NDG__c != $A.get("$Label.c.WGC_Cart_NdgFondoGaranzia")){
                this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_Alert_FondoGaranzia"), "warning");
            } else if(existingJoins.length == 1){
                this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_Alert_Confidi"), "warning");
            } else if(existingJoins.length < 2)
                this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_GaranzieMissingPerMutui"), "warning");
        }
        else {
            joinGaranziaGarante.forEach(j => { // update percentuali
                if (garanti.find(g => {return g.Id == j.garante;}))
                    j.percentualeGaranzia = garanti.find(g => {return g.Id == j.garante;}).percentualeGaranzia;
            });
// console.log("garanzie: ", garanzie);
            let percGaranzieOk = garanzie.reduce((allOk, gz) => {
                return allOk && (
                    joinGaranziaGarante.filter(j => {return j.garanzia == gz.IdEsterno__c;}).length > 1 ?
                    joinGaranziaGarante.filter(j => {return j.garanzia == gz.IdEsterno__c;}).reduce((start, j) => {return start + parseInt(j.percentualeGaranzia);}, 0) == 200 :
                    joinGaranziaGarante.filter(j => {return j.garanzia == gz.IdEsterno__c;}).reduce((start, j) => {return start + parseInt(j.percentualeGaranzia);}, 0) == 100
                );
            }, true);

            if (percGaranzieOk) {

                payload.joinGaranziaGarante = joinGaranziaGarante;

                let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
                appEvent.setParams({ "method" : "c.saveWizard" , "params": {
                        payload: JSON.stringify(payload),
                        step: "garanzie"
                    }
                });
                appEvent.fire();
            } else {
                this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_GaranziePercentualiNon100"), "warning");
            }
        }
    },

    mapGaranzia : function(garanzia) {
        return {
            idEsterno: garanzia.IdEsterno__c,
            tipologia: garanzia.CodiceGaranzia__c,
            copertura: garanzia.Tipo__c,
            linea: garanzia.Linea__c,
            percentualeImporto: garanzia.PercentualeGaranziaImporto__c,
            importo: garanzia.Importo__c,
            divisa: garanzia.DivisaNew__c
        };
    },

    handleModalMutuoControgarantito : function(component, event, helper, garanti){
        console.log('@@@ garanti ' , garanti);
        garanti = garanti.filter((g) => { return g.NDG__c != $A.get("$Label.c.WGC_Cart_NdgFondoGaranzia") });
        $A.createComponent("c:WGC_Cart_SelezionaGarante", { garanti : garanti, selectedGarante : component.getReference("v.selectedGarante")},
            function(content, status) {
                if (status === "SUCCESS") {
                    var modalBody = content;
                    component.find('overlayLib').showCustomModal({
                        header: "Seleziona Garante",
                        body: modalBody,
                        showCloseButton: false,
                        cssClass: "slds-p-around--medium",
                        closeCallback: (() => {
                            helper.setGaranteDefaultControgarantiti(component, event, helper, garanti);
                        })
                    });
                }
        });
    },

    firstDeleteGarantiControgarantito : function(component, event, helper){
        var garanti = component.get("v.garanti");
        var setIdGaranti = new Set();

        var newJoin = event.getParam("value");

        newJoin.forEach((item) => {
            setIdGaranti.add(item.garante);
        });

        garanti = garanti.filter((g) => { return !setIdGaranti.has(g.Id) || g.NDG__c == $A.get("$Label.c.WGC_Cart_NdgFondoGaranzia") } );
        component.set("v.garanti" , garanti);
    },

    setGaranteDefaultControgarantiti : function(component, event, helper, garantiControgarantito){
        var garanteSelezionatoId = component.get("v.selectedGarante");
        var allGaranti = component.get("v.garanti");

        var garanteSelected = garantiControgarantito.find((g) => { return g.Id == garanteSelezionatoId });
        allGaranti.push(garanteSelected);

        var setGarantiControgarantito = new Set();
        var idsGarantiToDelete = [];
        garantiControgarantito.forEach((item) => { 
            setGarantiControgarantito.add(item.Id); 
            if(item.Id != garanteSelezionatoId) idsGarantiToDelete.push(item.Id); 
        });

        //var join = component.get("v.joinGaranziaGarante");
        var join = component.get("v.payload.joinGaranziaGarante");
        var selectedJoin = join.filter((j) => { return j.garante == garanteSelezionatoId || !setGarantiControgarantito.has(j.garante) });

        helper.removeGaranti(component, idsGarantiToDelete);

        component.set("v.garanti", allGaranti);
        component.set("v.joinGaranziaGarante", selectedJoin);
        component.set("v.payload.joinGaranziaGarante", selectedJoin)
    },

})