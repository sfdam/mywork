({
    setupData : function(component, event, helper) {
        var speseIstruttoria = component.get("v.speseIstruttoria");
        var parametriConfigurati = component.get("v.payload.configurazioneLinee");
        var linee = component.get("v.payload.linee");
        window.fidoRichiesto = 0;

        var lineaXProdotto = new Map();
        linee.forEach((lin) => { lineaXProdotto.set(lin.id, lin.codice) });

        parametriConfigurati.forEach((item, index) =>{
            if(lineaXProdotto.has(item.linea)){
                if((lineaXProdotto.get(item.linea) == "AnticipoCreditiFuturi" || lineaXProdotto.get(item.linea) == "AcfNotNot") && item.codice == "SF10"){
                    window.fidoRichiesto += parseFloat(item.valore);
                } else if(lineaXProdotto.get(item.linea) != "AnticipoCreditiFuturi" && lineaXProdotto.get(item.linea) != "AcfNotNot" && item.codice == "SF6")
                    window.fidoRichiesto += parseFloat(item.valore);
            }
        });

        var speseIstruttoriaEvaluated = [];
        speseIstruttoria.forEach((item,index) =>{
            var prodottiConsiderati = item.Prodotti_Coinvolti__c.split(';');
            var evaluated = eval(item.Default_Value__c);
            let spesaIstr = {};
            spesaIstr.codiceParametro = item.DeveloperName;
            spesaIstr.label = item.Label__c;
            spesaIstr.defaultValue = evaluated;

            var newValue = evaluated;
            parametriConfigurati.forEach((pconf, index) =>{
                if(pconf.codice == item.DeveloperName && pconf.hasOwnProperty('valorePEF38') ){ 
                    newValue = parseFloat(pconf.valorePEF38);
                } else if(pconf.codice == item.DeveloperName){
                    newValue = parseFloat(pconf.valore);
                }
            });

            linee.forEach((lin) =>{
                if(prodottiConsiderati.includes(lin.codice)){
                    var newParam = {};
                    newParam.valore = newValue;
                    newParam.linea = lin.id;
                    newParam.codice = item.DeveloperName;
                    newParam.valorePEF38 = '';

                    var check = parametriConfigurati.filter((pconf) => { return pconf.codice == newParam.codice && newParam.linea == pconf.linea });
                    if(check.length == 0)
                        parametriConfigurati.push(newParam);
                    else{
                        parametriConfigurati.filter((pconf) => { return pconf.codice == newParam.codice }).forEach((pconfFilter) => {
                            pconfFilter.valore = newValue;
                            pconfFilter.valorePEF38 = newValue.toFixed(3);
                        });
                    }
                }
            });

            spesaIstr.value = newValue;
            speseIstruttoriaEvaluated.push(spesaIstr);
        });

        component.set("v.speseIstruttoria", speseIstruttoria);
        component.set("v.speseIstruttoriaEvaluated", speseIstruttoriaEvaluated);
        component.set("v.payload.configurazioneLinee", parametriConfigurati);
    },

    updateParametriSpese : function(component, event, helper){
        var newSpeseIstruttoria = component.get("v.speseIstruttoriaEvaluated");
        var parametriConf = component.get("v.payload.configurazioneLinee");
        var mappaParametri = new Map();

        newSpeseIstruttoria.forEach((item, index) =>{
            mappaParametri.set(item.codiceParametro, item.value);
        });
        
        parametriConf.forEach((item) =>{
            if(mappaParametri.get(item.codice) != undefined)
            	item.valore = mappaParametri.get(item.codice);           
        });
		
        component.set("v.payload.configurazioneLinee", parametriConf);
        component.find('overlayLib').notifyClose();
    },
})