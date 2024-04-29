({
    initialize : function(component, event, helper) {
        //Concateno sia le linee corporate che quello di servizi bancari
        var lines = component.get("v.payload.pbc");
        lines = lines.concat(component.get("v.payload.pb"));
        var parametriLinee = component.get("v.payload.configurazioneLinee");
        var params = component.get("v.params");
        params.forEach(p => {
            //Nel caso di sbf a conto unico esistente, non ci sarà una linea con cui matchare di conseguenza controlliamo che non sia undefined
            console.log('@@@ sbf ' , lines.find(l => { console.log(l); return l.tipo == 'SBF'}));
            var pconf = parametriLinee.find(pl => { return p.Codice_Condizione__c == pl.codice && pl.linea == ( lines.find(l => { return p.Output__c.includes(l.tipo); }) != undefined ? lines.find(l => { return p.Output__c.includes(l.tipo); }).id : lines.find(l => { return l.tipo == 'SBF'}) != undefined ? lines.find(l => { return l.tipo == 'SBF'}).id : '') });
            console.log('@@@ pconf ' , pconf);
            console.log('@@@ ppp ' , p);
            // if(pconf != undefined && pconf.codice == p.codice && pconf.linea == p.linea){
            p.id = pconf != undefined ? pconf.id : '';
            p.value = pconf != undefined ? pconf.valore : '';
            p.linea = pconf != undefined ? pconf.linea : '';
            // }/*lines.find(l => { return p.Output__c.includes(l.tipo)}) != undefined ? lines.find(l => { return p.Output__c.includes(l.tipo)}).id : '';*/
        });

        console.log('@@@ params ' , params);
        component.set("v.params", params);
    },

    back : function(component, event, helper){
        var params = component.get("v.params");
        params.forEach(p => {
            p.valore = p.value;
        });
        var check = helper.checkCompletness(component, event, helper, params);

        var parametriEvt = $A.get("e.c:WGC_ChangeCondizioneValue");
        parametriEvt.setParam("isCompleted", check);
        parametriEvt.fire();

        component.find('overlayLib').notifyClose();
    },

    confirm : function(component, event, helper){
        var checkLimit = helper.checkLimit(component, event, helper);
        //Funzione per creare i PConfigurati
        var pconfigurati = helper.createPConfigurati(component, event, helper);
        //Funzione per controllare la completezza dei dati
        var check = helper.checkCompletness(component, event, helper, pconfigurati);

        if(check && checkLimit){
            //Funzione per gestire l'inserimento dei nuovi elementi o l'aggiornamento del valore dei vecchi
            helper.updateParametri(component, event, helper, pconfigurati);
            var parametriEvt = $A.get("e.c:WGC_ChangeCondizioneValue");
            parametriEvt.setParam("isCompleted", check);
            parametriEvt.fire();
            component.find('overlayLib').notifyClose();
        } else if(!check){
            helper.updateParametri(component, event, helper, pconfigurati);
            var parametriEvt = $A.get("e.c:WGC_ChangeCondizioneValue");
            parametriEvt.setParam("isCompleted", check);
            parametriEvt.fire();

            component.find('overlayLib').notifyClose();
        } else if(!checkLimit){
            component.find('notifyLib').showNotice({
                "variant": "warning",
                "header": "Attenzione",
                "message": "Parametri non rispettano i limiti massimi",
                closeCallback: function() {
                    // alert('valore parametri oltre il limite massimo');
                }
            });
        }

        //TODO Capire come usare il valore di checkCompletness
    },

    createPConfigurati : function(component, event, helper){
        var pconfigurati = [];
        var lineId = component.get("v.lineId");
        var lines = component.get("v.payload.linee");
        var parametriLinee = component.get("v.payload.configurazioneLinee");
        //Creo i PConfigurati per i parametri nel metadato
        var params = component.get("v.params");
        params.forEach(p => {
            var linesOutput = p.Output__c.split(';');
            var tmpP = {};
            tmpP.id = p.id != undefined ? p.id : '';
            tmpP.codice = p.Codice_Condizione__c;
            tmpP.valore = p.value;
            tmpP.linea = p.linea != undefined && p.linea != "" ? p.linea : lines.find(l => { return p.Output__c.includes(l.codice); }) != undefined ? lines.find(l => { return p.Output__c.includes(l.codice); }).id : lines.find(l => { return l.codice == 'SBF'}).id;/*lines.find(l => { return l.codice == p.Output__c}).id;*/
            pconfigurati.push(tmpP);
        });

        return pconfigurati;
    },
    
    checkCompletness : function(component, event, helper, pconfigurati){
        var check = pconfigurati.reduce((start, p) => {
            return start && p.valore != undefined && p.valore != null && p.valore != '';
        }, true);
        return check;
    },

    checkLimit : function(component, event, helper){
        var limitCheck = component.get("v.params").reduce((start, p) => {
            return start && parseFloat(p.value) <= p.Valore_Limite__c;
        }, true);
        return limitCheck;
    },

    updateParametri : function(component, event, helper, pconfigurati){
        var parametriLinee = component.get("v.payload.configurazioneLinee");
        var mappaPConf = new Map();

        console.log('@@@ pconfigurati ' , pconfigurati);
        parametriLinee.forEach(p => {
            mappaPConf.set(p.linea+'_'+p.codice, p.valore);
        });

        console.log('@@@ mappaPConf ' , mappaPConf);

        pconfigurati.forEach(pc => {
            var key = pc.linea+'_'+pc.codice;
            if(mappaPConf.has(key)){
                parametriLinee.forEach(pl => { 
                    if(key == pl.linea+'_'+pl.codice){
                        console.log('@@@ pc.valore set ' , pc.valore);
                        pl.valore = parseFloat(pc.valore);
                    }
                });
            } else {
                parametriLinee.push(pc);
            }
        });

        console.log('@@@ parametriLinee final ' , parametriLinee);

        component.set("v.payload.configurazioneLinee", parametriLinee);
    },

})