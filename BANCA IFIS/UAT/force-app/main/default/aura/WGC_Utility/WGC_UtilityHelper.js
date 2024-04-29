({
    // UTILITY FUNCTION FOR APEX CONTROLLER INTERACTIONS
    callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error(errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    // UTILITY FUNCTION FOR PROMISE APEX CONTROLLER INTERACTIONS
    callServerSync : function(component,method,params) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get(method);
            if (params) {
                action.setParams(params);
            }
            
            action.setCallback(this,function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    // h.resolveAction('complete', callbackResult.getReturnValue(), eventName);      
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            
            $A.enqueueAction(action);
        }));
        return p;
    },

    isBlank : function (scope) {
        return (scope === null || scope === "" || scope === undefined) ? true : false;
    },

// HELPER UX FUNCTIONS

    showSpinner : function(component, spinnerMessage) {
        // console.log("SHOWSPINNER");
        var spinner = component.find("spinner");
        var spinnerWrapper = component.find("spinnerWrapper");
        
        if (!$A.util.hasClass(spinner, "cstm-state-lock")) {
            // console.log("showSpinner: ", component.get("v.showSpinner"));
            // component.set("v.showSpinner", true);
            $A.util.removeClass(spinner, "slds-hide");
            $A.util.removeClass(spinnerWrapper, "slds-hide");
        }

        if (spinnerMessage != "" && spinnerMessage != null && spinnerMessage != undefined)
            component.set("v.spinnerMessage", spinnerMessage);
    },

    hideSpinner : function(component) {
        // console.log("HIDESPINNER");
        var spinner = component.find("spinner");
        var spinnerWrapper = component.find("spinnerWrapper");

        if (!$A.util.hasClass(spinner, "cstm-state-lock")) {
            // component.set("v.showSpinner", false);
            $A.util.addClass(spinner, "slds-hide");
            $A.util.addClass(spinnerWrapper, "slds-hide");
        }

        component.set("v.spinnerMessage", "");
    },

    lockStateSpinner : function(component, locker) {
        // console.log("SHOWSPINNER");
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "cstm-state-lock");

        if (locker && !component.get("v.spinnerLocker"))
            component.set("v.spinnerLocker", locker);
    },

    unlockStateSpinner : function(component, locker) {
        let spinnerLocker = component.get("v.spinnerLocker");
        // console.log("HIDESPINNER");
        if (spinnerLocker) {
            if (locker && locker == spinnerLocker) {
                var spinner = component.find("spinner");
                $A.util.removeClass(spinner, "cstm-state-lock");
            }
        } else {
            var spinner = component.find("spinner");
            $A.util.removeClass(spinner, "cstm-state-lock");
        }
    },

    showToast : function(component, ttl, msg, vrnt) { // vrnt: info, success, warning, error
        component.find("notifLib").showToast({
            title: ttl,
            message: msg,
            variant: vrnt
        });
    },

    // UTILITY FUNCTION TO GENERATE A JS MAP OBJECT
    generateMap : function(obj) {
        var map = new Map();

        if (typeof obj == "array")
            obj.forEach((i, e) => {
                map.set(i, e);
            });

        if (typeof obj == "object")
            for (let k in obj)
                map.set(k, obj[k]);

        return map;
    },

// HELPER ARRAY FUNCTIONS

    // RETURN A MAP WITH "key" FIELD AS THE KEY OF EVERY NODE
    mapArrayBy : function(array, key) { // WARNING: KEY MUST BE UNIQUE
        var newArr = [];
        for (var a in array)
            newArr[array[a][key]] = array[a];
        return newArr;
    },

    // RETURN A MAP WITH A NEW ARRAY FOR EVERY DISTINCT VALUE OF "grouper"
    groupArrayBy : function(array, grouper) {
        var newArr = [], keys = [];
        for (var a in array) {
            if (keys.includes(array[a][grouper]))
                newArr[array[a][grouper]].push(array[a]);
            else
                newArr[array[a][grouper]] = [array[a]];
            keys.push(array[a][grouper]);
        }
        return newArr;
    },

    // RETURN THE FIRST NODE OF THE "array" THAT MATCH THE "fieldsAndValues" PARAMETERS
    getFirstNodeByFields : function(array, fieldsAndValues) { // fieldsAndValues => [ { field: "fieldName" , value: "fieldValue" } ]
        var node = null;
        if (fieldsAndValues.length != 0) {
            for (var a in array) {
                if (node != null)
                    break;
                else if (array[a][fieldsAndValues[0].field] == fieldsAndValues[0].value) {
                    // console.log("__SINGLE__ array.val: "+array[a][fieldsAndValues[0].field]+" -- val: "+fieldsAndValues[0].value);
                    if (fieldsAndValues.length > 1) {
                        for (var fav in fieldsAndValues) {
                            // console.log("__MULTI__ array.val: "+array[a][fieldsAndValues[fav].field]+" -- val: "+fieldsAndValues[fav].value);
                            if (array[a][fieldsAndValues[fav].field] != fieldsAndValues[fav].value)
                                break;
                            else if (fav == fieldsAndValues.length-1)
                                node = array[a];
                        }
                    }
                    else
                        node = array[a];
                }
            }
        }
        
        return node;
    },

    // RETURN THE NUMBER OF NODES OF THE "array" THAT MATCH THE "fieldsAndValues" PARAMETERS
    countNodesByFields : function(array, fieldsAndValues) { // fieldsAndValues => [ { field: "fieldName" , value: "fieldValue" } ]
        var count = 0;
        if (fieldsAndValues.length != 0) {
            for (var a in array)
                if (array[a][fieldsAndValues[0].field] == fieldsAndValues[0].value)
                    if (fieldsAndValues.length > 1) {
                        for (var fav in fieldsAndValues)
                            if (array[a][fieldsAndValues[fav].field] != fieldsAndValues[fav].value)
                                break;
                            else if (fav == fieldsAndValues.length-1)
                                count++;
                    }
                    else
                        count++;
        }
        
        return count;
    },

    // RETURN AN ARRAY OF NODES OF THE "array" THAT MATCH THE "fieldsAndValues" PARAMETERS
    getNodesByFields : function(array, fieldsAndValues) { // fieldsAndValues => [ { field: "fieldName" , value: "fieldValue" } ]
        var nodes = [];
        if (fieldsAndValues.length != 0) {
            for (var a in array) {
                if (array[a][fieldsAndValues[0].field] == fieldsAndValues[0].value) {
                    if (fieldsAndValues.length > 1) {
                        for (var fav in fieldsAndValues) {
                            if (array[a][fieldsAndValues[fav].field] != fieldsAndValues[fav].value)
                                break;
                            else if (fav == fieldsAndValues.length-1)
                                nodes.push(array[a]);
                        }
                    }
                    else
                        nodes.push(array[a]);
                }
            }
        }
        
        return nodes;
    },

    // PUSH "item" INTO "array", CONCAT THEM IF "item" IS ARRAY TYPE
    arrayPusher : function(item, array) {
        if (Array.isArray(item))
            return array.concat(item);
        else
            array.push(item);
        return array;
        // if (Array.isArray(item)) console.log("array: ", array);
    },

    // RETURN INDEX OF "section" IN "array" (SPECIFIC ON FIELD "code" OF ARRAY)
    getSectionIndex : function(section, array) {
        var index = -1;
        array.forEach((elem, i) => {
            if (section == elem.code)
                index = i;
        });
        return index;
    },

    // RETURN ACTIVE LINE (FULL OBJECT)
    getActiveLine : function(component) {
        var lines = component.get("v.items");
        var activeLine = null;
        lines.forEach(l => {
            if (l.subLines.length > 0) {
                l.subLines.forEach(sl => {
                    if (sl.isActive == true)
                        activeLine = sl.line;
                });
            } else {
                if (l.isActive == true)
                    activeLine = l;
            }
        });
        return activeLine;
    },

    // FUNCTION TO GENERATE LINE SUBTITLE
    getLineSubtitle : function(component, lineInfo) {
        let subtitle = "-";
        let payload = component.get("v.payload");
        let mercati = component.get("v.picklistOptions").find(po => {return po.field == "NDGLinea__c.WGC_Mercato__c";}).options.map(o => {
            let tmp = o.split(":");
            return {value:tmp[0], label:tmp[1]};
        });
        let divise = component.get("v.diviseOptions");
        let debitoriPerLinea = component.get("v.debitoriPerLinea");
        let debitoriValPort = payload.valutazioniPortafoglio.map(vp => {return vp.id});
        let lineeValPort = (debitoriValPort ? (
            payload.joinLineaAttore.find(jla => {return debitoriValPort.includes(jla.debitore);}) ?
            payload.joinLineaAttore.find(jla => {return debitoriValPort.includes(jla.debitore);}).linee :
            null) : null);
        
        if (lineInfo.length !== undefined) { // sublines
                let subLines = lineInfo;
                
            	console.log('@@@ subtitle ' , JSON.stringify(subLines));
            	console.log('@@@ debitoriPerLinea ' , JSON.stringify(debitoriPerLinea));
            
                subtitle = "Debitori associati: " + (debitoriPerLinea.find(dpl => {return subLines.map(sl => {return sl.line.id}).includes(dpl.linea);}) ?
                debitoriPerLinea.find(dpl => {return subLines.map(sl => {return sl.line.id}).includes(dpl.linea);}).debitori.length : 0)
                
                
        } else {
            console.log('@@@ debitoriPerLinea ' , debitoriPerLinea);
            console.log('@@@ lineInfo.id ' , lineInfo.id);
            if (debitoriPerLinea.find(dpl => {return dpl.linea == lineInfo.id;}) === undefined) {
                if (lineeValPort && lineeValPort.includes(lineInfo.id))
                    subtitle = "Valutazione portafoglio - " + mercati.find(m => {return m.value == lineInfo.mercato;}).label + " (" + divise.find(d => {return d.Codice_Divisa__c == lineInfo.divisa;}).Simbolo__c + ")";
                else
                    subtitle = "Nessun debitore associato";
            }
            else if (debitoriPerLinea.find(dpl => {return dpl.linea == lineInfo.id;}).debitori.length > 0) {
                if (lineeValPort && lineeValPort.includes(lineInfo.id))
                    subtitle = "Valutazione portafoglio - " + mercati.find(m => {return m.value == lineInfo.mercato;}).label + " (" + divise.find(d => {return d.Codice_Divisa__c == lineInfo.divisa;}).Simbolo__c + ")";
                else
                    subtitle = "Debitori associati: " + debitoriPerLinea.find(dpl => {return dpl.linea == lineInfo.id;}).debitori.length + " - " + mercati.find(m => {return m.value == lineInfo.mercato;}).label + " (" + divise.find(d => {return d.Codice_Divisa__c == lineInfo.divisa;}).Simbolo__c + ")";
            }
        }
        
        return subtitle;
    },

    // RETURN TRUE IF SECTION IS VISIBLE, FALSE OTHERWISE
    isVisibleSection : function(sezione) {
        // ADD CUSTOM LOGIC TO HIDE SECTIONS
        return !sezione.startsWith("PN");
        // return true;
    },

    // RETURN "array" SORTED ALPHABETICALLY
    sortSections : function(array) {
        return array.sort(
            function(a, b) {
                return a.order - b.order;
            }
        );
    },

    // FUNCTION TO SORT CART PARAMETERS, PUSHING "SOLODEROGA" AT LAST
    sortParameters : function(array) {
        return array.sort(
            function(a, b) {
                return (a.soloDeroga ? 1 : (b.soloDeroga ? -1 : 0));
            }
        );
    },

    // GET SET
    getSet : function(array, field) {
        var result = [];
        array.forEach(e => {
            if (!result.includes(e[field]))
                result.push(e);
        });
        return result;
    },

    // FUNCTION TO CHECK IF DEBITORE HAS ATD
    hasATD : function(joinLineaAttore, debitore) {
        return (joinLineaAttore.length > 0 && this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id] ? this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id].servizi.includes("Acquisto a titolo definitivo") : false);
    },

    //A.M. -> Inizio
    // FUNCTION TO CHECK IF DEBITORE HAS Factoring MCC
    hasFactMCC : function(joinLineaAttore, debitore) {
        return (joinLineaAttore.length > 0 && this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id] ? this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id].servizi.includes("Factoring MCC") : false);
    },
    //A.M. -> Fine
    
    //A.M. -> Inizio
    // FUNCTION TO CHECK IF DEBITORE HAS Anticipo Crediti Futuri MCC
    hasACFMCC : function(joinLineaAttore, debitore) {
        return (joinLineaAttore.length > 0 && this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id] ? this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id].servizi.includes("Anticipo Crediti Futuri MCC") : false);
    },
    //A.M. -> Fine    
    
    //A.M. -> Inizio
    // FUNCTION TO CHECK IF DEBITORE HAS Prodotto Famiglia "Bonus Edilizi"
    hasBonusEdil : function(joinLineaAttore, debitore) {
        return  ((joinLineaAttore.length > 0 && this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id] ? this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id].servizi.includes("ACF NOT NOT - Bonus Edilizi") : false) || 
		         (joinLineaAttore.length > 0 && this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id] ? this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id].servizi.includes("ACF Not Not MCC - Bonus Edilizi") : false) || 
                 (joinLineaAttore.length > 0 && this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id] ? this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id].servizi.includes("ATD - Superbonus") : false) || 
                 (joinLineaAttore.length > 0 && this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id] ? this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id].servizi.includes("ATD - Altri Bonus") : false));
    },
    //A.M. -> Fine    
    
    // FUNCTION TO CHECK IF ITEM/PRODUCT IS COMPLETED
    isCompleted : function(joinLineaAttore, debitore, debitoriNewFields, valutazionePortafoglio, hideContesto) {
        var hasATD = this.hasATD(joinLineaAttore, debitore);
        //A.M. -> Debitore completo per Famiglia "Bonus Edilizi"
        var hasBonusEdil = this.hasBonusEdil(joinLineaAttore, debitore);

        // var tipologiaControparteBool = this.checkMulti(debitoriNewFields !== undefined ? debitoriNewFields.tipologiaControparte : null);
        var tipologiaFornituraBool = this.checkMulti(debitoriNewFields !== undefined ? debitoriNewFields.tipologiaFornitura : null);
        
        if (valutazionePortafoglio === true)
            return false;
        //A.M. -> Inizio Aggiunta IF per debitore completo in caso di Famiglia "Bonus Edilizi"
        else if (hasBonusEdil) {
                return  !this.isBlank(debitore.piva) &&
                !this.isBlank(debitore.divisa) &&
                !this.isBlank(debitore.aNotifica) &&
                !this.isBlank(debitore.maturity);
             } 
        //A.M. -> fine
        else
            return  !this.isBlank(debitore.piva) &&
                !this.isBlank(debitore.durataNominale) &&
                !this.isBlank(debitore.divisa) &&
                !this.isBlank(debitore.fatturato) &&
                !this.isBlank(debitore.plafond) &&
                // !this.isBlank(debitore.dcp) &&
                !this.isBlank(debitore.aNotifica) &&
                !this.isBlank(debitore.maturity) &&
                
                ( hideContesto ? true : 
                    // tipologiaControparteBool &&
                    !this.isBlank(debitoriNewFields !== undefined ? debitoriNewFields.contropartePrivato : null) &&
                    tipologiaFornituraBool &&
                    !this.isBlank(debitoriNewFields !== undefined ? debitoriNewFields.commessa : null) &&
                    !this.isBlank(debitoriNewFields !== undefined ? debitoriNewFields.appalto : null)
                ) &&

                ( hasATD && !hideContesto ? 
                    (debitore.proceduraSemplificata ? true : (
                        debitore.momento == "Cessione" ? (
                            !this.isBlank(debitore.operazioneIAS) && !this.isBlank(debitore.previstaLIR) && !this.isBlank(debitore.momento)
                        ) : (
                            !this.isBlank(debitore.operazioneIAS) && !this.isBlank(debitore.previstaLIR) && !this.isBlank(debitore.momento) && !this.isBlank(debitore.anticipazione) && !this.isBlank(debitore.prosolutoATD)
                        )
                    )
                ) : true )

                // ( hasATD ?  !this.isBlank(debitore.cessioneContinuativa) &&
                //             !this.isBlank(debitore.rotativita) &&
                //             !this.isBlank(debitore.momento) : true );
                            // !this.isBlank(debitore.anticipazione) &&
                            // !this.isBlank(debitore.prosoluto) : true );
    },

    checkMulti : function(obj) {
        var bool = false
        for (var prop in obj)
            if (obj[prop] == true)
                bool = true;
        return bool;
    },

    getPivaPerDebitore : function(debitori) {
        let pivaMap = new Map();

        debitori.forEach(d => {
            pivaMap.set(d.id, d.piva);
        });

        return pivaMap;
    },

    hideContesto : function(debitore, jla, codiciCoppia, servizi) {

        if (!jla.find(j => {return j.debitore == debitore.id;}))
            return false;

        return jla.find(j => {return j.debitore == debitore.id;}).servizi.reduce((start, serv) => {
            if (!servizi.find(s => {return s.Label == serv;}))
                return false;
            
            let servFamily = servizi.find(s => {return s.Label == serv;}).WGC_Famiglia__c;
            return start && codiciCoppia.find(cc => {return cc.debitore == debitore.id && cc.servizio == servFamily;}) ? codiciCoppia.find(cc => {return cc.debitore == debitore.id && cc.servizio == servFamily;}) != null && codiciCoppia.find(cc => {return cc.debitore == debitore.id && cc.servizio == servFamily;}) != undefined : false;

        }, true);

        // if (jla.filter(j => {return j.debitore == debitore.id;}).length == 0)
        //     return true;
        // else {
        //     let jlaDeb = jla.filter(j => {return j.debitore == debitore.id;});

        //     return jlaDeb.reduce((start, j) => {
        //         return start || codiciCoppia.find(cc => {return cc.debitore == debitore.id;}) ? j.servizi.includes(servizi.find(s => {return s.WGC_Famiglia__c == codiciCoppia.find(cc => {return cc.debitore == debitore.id;}).servizio;}).Label) : false;
        //     }, false);
        // }
    },

    // GESTIONE EVENTI PER RISOLVERE CHIAMATA SERVER DEL COMPONENT PARENT

    validateResolveServer : function(component, uidFromEvent) {
        let uidInPage = component.get("v.uid");

        return uidInPage == uidFromEvent;
    },

    resolveServerAction : function(component, json) {
        this[json.action](component, json);
    },

    generateUID : function() {
        let result           = '';
        let characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let charactersLength = 15;
        let length = 15;
        for ( let i = 0; i < length; i++ ) {
            result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }
        return result;
    }
    
})