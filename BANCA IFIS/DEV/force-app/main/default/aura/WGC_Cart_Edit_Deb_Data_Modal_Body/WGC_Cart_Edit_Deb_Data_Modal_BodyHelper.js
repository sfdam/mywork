({
    saveQECDebitore : function(component) {
        var debitore = component.get("v.debitore");
        var newFields = component.get("v.newFields");
        var payload = component.get("v.payload");
        let showProsoluto = component.get("v.showProsoluto");
        // var elements = component.find("checkboxContainer").getElements();

        // console.log(JSON.stringify(debitore));
        for (var prop in debitore)
            if (debitore[prop] === "true" || debitore[prop] === "false")
                debitore[prop] = ( debitore[prop] == "true" ? true : false );
        
        for (var prop in newFields) {
            if (newFields[prop] === "true" || newFields[prop] === "false")
                newFields[prop] = ( newFields[prop] == "true" ? true : false );
            else if (typeof newFields[prop] === "object") {
                var values = [];
                for (var vv in newFields[prop])
                    if (component.find(prop+"_"+vv).get("v.checked") == true) values.push(component.find(prop+"_"+vv).get("v.label"));
                newFields[prop] = values.join(";");
            }
        }

        if (showProsoluto == false)
            debitore.dcp = null;

        var newDebs = payload.debitori.filter(function(d){ return d.account != debitore.account; });
        newDebs.push(debitore);
        payload.debitori = newDebs;
        payload.wizardCompletato = false;
        payload.valutazioniPortafoglio.forEach(vp => {
            for (let key in vp)
                if (vp[key] == "true" || vp[key] == "false")
                    vp[key] = (vp[key] == "true");
        });

        var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.updateDebitori" , "params" : { payload: JSON.stringify(payload), debitoreNewFields: JSON.stringify([newFields]) } });
        appEvent.fire();
        
        component.find('overlayLib').notifyClose();
    },

    setupDebitore : function(component) {
        var debitore = component.get("v.debitore");
        var newFields = component.get("v.newFields");

        if (debitore.maturity)
            debitore.previstaLIR = true;
        
        for (var prop in debitore) {
            if (debitore[prop] === true || debitore[prop] === false)
                debitore[prop] = ( debitore[prop] == true ? "true" : "false" );
        }

        for (var prop in newFields) {
            if (newFields[prop] === true || newFields[prop] === false)
                newFields[prop] = ( newFields[prop] == true ? "true" : "false" );
        }

        if (this.isBlank(debitore.momento))
            debitore.momento = "Cessione";
        
        component.set("v.debitore", debitore);
        component.set("v.newFields", newFields);
        component.set("v.showProsoluto", !this.isBlank(debitore.dcp));
    },

    manageNotificationAndMaturity : function(component, event) {
        var debitore = component.get("v.debitore");

        if (event.getSource().get("v.name") == "maturity") {
            if (event.getSource().get("v.value") === "true") {
                debitore.aNotifica = "true";
                debitore.momento = 'Cessione';
                debitore.proceduraSemplificata = false;
                debitore.previstaLIR = "true";
                // debitore.anticipazione = (debitore.operazioneIAS == "true" ? 'No' : 'Si'); // se VALUE = TRUE allora FALSE, se VALUE = FALSE allora TRUE
            }
        }
        else if (event.getSource().get("v.name") == "notification") {
            if (event.getSource().get("v.value") === "false") {
                debitore.maturity = "false";
                debitore.proceduraSemplificata = false;
                if (debitore.momento == 'Riconoscimento/Certificazione')
                    debitore.momento = '';
            }
        }

        component.set("v.debitore", debitore);
    },

    recalculatePlafond : function(component, event) {
        let debitore = component.get("v.debitore");

        if (debitore.fatturato != null && debitore.durataNominale != null)
            debitore.dcp = debitore.plafond = (Math.round(  ((debitore.fatturato * debitore.durataNominale)/360)/1000  ))*1000;

        component.set("v.debitore", debitore);
    },

    onChangeMomento : function(component, event) {
        let isCessione = event.getSource().get("v.value") == "Cessione";
        let debitore = component.get("v.debitore");

        if (isCessione)
            debitore.prosolutoATD = debitore.anticipazione = "";

        component.set("v.debitore", debitore);
    },

    onChangeProceduraSemplificata : function(component, event) {
        let debitore = component.get("v.debitore");

        debitore.proceduraSemplificata = event.getSource().get("v.checked");

        component.set("v.debitore", debitore);
    },

    onChangeLIR : function(component, event) {
        let debitore = component.get("v.debitore");

        if (event.getSource().get("v.value") == false || event.getSource().get("v.value") == "false")
            debitore.momento = 'Cessione';

        component.set("v.debitore", debitore);
    },

    onChangeIAS : function(component, event) {
        let debitore = component.get("v.debitore");
        let value = event.getSource().get("v.value");

        if ((value == true || value == "true") && debitore.prosolutoATD == "Prosolvendo" && debitore.previstaLIR == "true" && debitore.momento != "Cessione")
            debitore.prosolutoATD = 'Prosoluto';

        // if (debitore.maturity == "true" || debitore.maturity == true)
        //     debitore.anticipazione = (value == "true" ? 'No' : 'Si'); // se VALUE = TRUE allora FALSE, se VALUE = FALSE allora TRUE

        component.set("v.debitore", debitore);
    },

    onChangeAnticipazione : function(component, event) {},

    onChangeProsoluto : function(component, event) {},

    validateQEC : function(component) {
        let isQECValid = false;
        let showProsoluto = component.get("v.showProsoluto");
        let debitore = component.get("v.debitore");
        let newFields = component.get("v.newFields");
        // let pubblico = component.find("tipologiaControparte_pubblico").get("v.checked");
        // let privato = component.find("tipologiaControparte_privato").get("v.checked");
        let beni = component.find("tipologiaFornitura_beni").get("v.checked");
        let servizi = component.find("tipologiaFornitura_servizi").get("v.checked");
        let altro = component.find("tipologiaFornitura_altro").get("v.checked");
        let hideContesto = component.get("v.hideContesto");

        isQECValid = 
            !this.isBlank(debitore.durataNominale) &&
            !this.isBlank(debitore.fatturato) &&
            !this.isBlank(debitore.plafond) &&
            ( showProsoluto ? !this.isBlank(debitore.dcp) : true ) &&
            ( hideContesto ? true : (
                !this.isBlank(newFields.contropartePrivato) &&
                ( beni || servizi || altro )
            ) ) &&
            this.isValidATD(debitore);

        component.set("v.isQECValid", isQECValid);
    },

    isValidATD : function(debitore) {
        return (
            debitore.proceduraSemplificata == true || debitore.proceduraSemplificata == "true" ? true :
                ( debitore.momento == "Cessione" ? !this.isBlank(debitore.operazioneIAS) && !this.isBlank(debitore.previstaLIR) && !this.isBlank(debitore.momento) :
                    ( !this.isBlank(debitore.operazioneIAS) && !this.isBlank(debitore.previstaLIR) && !this.isBlank(debitore.momento) && !this.isBlank(debitore.anticipazione) && !this.isBlank(debitore.prosolutoATD) )
                )
            );
    },

    setReadOnlyRev : function(component){
        let payload = component.get("v.payload");
        let debitore = component.get("v.debitore");
        let joinLineaAttore = component.get("v.joinLineaAttore");

        console.log('@@@ joinLineaAttore ' , joinLineaAttore);
        if(joinLineaAttore.filter(item => { return item.debitore == debitore.id })[0]){
            var jlaLinee = joinLineaAttore.filter(item => { return item.debitore == debitore.id })[0].linee;
            console.log('@@@ jlaLinee ' , jlaLinee);
        }

        console.log('@@@ payload.linee ' , payload.linee);
        if(payload.linee.length > 0){
            var lineeRev = payload.linee.filter(linea => { return linea.isRevisione }).map(linea => { return linea.id});
        }
        
        console.log('@@@ lineeRev ' , lineeRev);
        // console.log('@@@ controllo ' , jlaLinee.filter(lin => { return lineeRev.includes(lin) }));
        if(jlaLinee != undefined && jlaLinee.filter(lin => { return lineeRev.includes(lin) }).length > 0) component.set("v.newReadOnly" , true);

        console.log('@@@ hasATD ' , component.get("v.hasATD"));
        console.log('@@@ reviDeb ' , component.get("v.isReviDeb"));
        console.log('@@@ newReadOnly ' , component.get("v.newReadOnly"));
    },
    
    // setupPicklists : function(component) {
    //     // this.callServer(component,"c.getPicklistValues",function(result){
    //     //     console.log("--setupPicklists");
    //     //     console.log(result);
    //     // },{
    //     //     objectName: "NDGLinea__c",
    //     //     field_apiname: "PerfezionamentoAcquisto__c",
    //     //     nullRequired: true
    //     // });

    //     var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
    //     appEvent.setParams({ "method" : "c.getPicklistValues" , "params" : {
    //             objectName: "NDGLinea__c",
    //             field_apiname: "PerfezionamentoAcquisto__c",
    //             nullRequired: true
    //         }
    //     });
    //     appEvent.fire();
    // }
    
    // MS Factory Aggiunto semaforo
    retrieveAtecoStatus : function(component){
        let debitore = component.get("v.debitore");
        // console.log('DEBITORE: ', JSON.stringify(debitore));
        var action = component.get("c.getAtecoStatus");
        console.log('recordId retrieve ateco status: ',debitore.account);
        action.setParams({recordId: debitore.account});

        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var risposta = response.getReturnValue();
                console.log('status ateco: ',risposta);
                component.set("v.atecoStatus", risposta);
            }
        });

        $A.enqueueAction(action);
    }
})