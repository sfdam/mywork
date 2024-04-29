({
    navigateSubWizard : function(component, target) {
        var cmpEvent = component.getEvent("navigateSubWizard");
        cmpEvent.setParams({ "target" : target });
        cmpEvent.fire();
    },
    
    configureSelectedLines : function(component) {
        var lines = component.get("v.payload").linee;
        var debitoriPerLinea = component.get("v.debitoriPerLinea");
        var items = [];
        let subLines = [];
        let pfi = component.get("v.payload").pfi;
        let activeItemAlreadySet = false;
        let picklistOptions = component.get("v.picklistOptions");
        let payload = component.get("v.payload");
        let codiciUnivoci = [];
        // console.log("debitoriPerLinea: ", debitoriPerLinea);
        lines.forEach(l => {
            let multiLine = (l.tipo != "" && l.tipo != undefined && l.atdSingola != "S") && l.nome != "ATD Confirming";
            if (multiLine) {
                let alreadyCompleted = l.codice == "SolaGestioneIVA" || l.codice == "NotNotSenzaAnticipazioneIVA";
            	subLines.push({
                    line: l,
                    icon: l.icona,
                    isActive: (l.tipo == "lineaDiAcquisto" && !activeItemAlreadySet),
                    isClickable: true,
                    isRevisione: l.isRevisione,
                    isCompleted: (alreadyCompleted ? true : this.isLineCompleted(component, l.id))
                });
                if (!codiciUnivoci.includes(l.codiceUnivoco)) codiciUnivoci.push(l.codiceUnivoco);
                if (!activeItemAlreadySet && subLines.filter(sl => {return sl.isActive}).length > 0) activeItemAlreadySet = true;
            } else {
                //SM - TEN: Banca Corporate Aggiunta condizione per non mostrare le linee di Tecniche
                if(l.codice != 'FIDOSBF' && l.codice != 'ContoAnticipiPTF' && l.codice != 'FidoAnticipoFatture'){
                    //SM - TEN: Aggiunti Prodotti di Corporate Estero senza parametri
                    let hasNoParams = l.codice == "Fido" || l.codice == "Standard" || l.codice == 'StandByLetter' || l.codice == 'CreditoDocumentarioExport' || l.codice == 'CreditoDocumentarioImport' || l.codice == 'DocumentateIncasso';
                    l.isClickable = !hasNoParams;
                    l.isSelected = true;
                    l.isActive = (hasNoParams ? false : !activeItemAlreadySet);
                    l.isRemovable = false;
                    l.isRevisione = l.isRevisione;
                    l.isCompleted = (hasNoParams ? true : this.isLineCompleted(component, l.id));
                    l.lineId = l.id;
                    l.icon = l.icona;
                    l.title = l.nome;
                    l.subtitle = this.getLineSubtitle(component, l);
                    l.multiLine = false;
                    l.subLines = [];
                    // l.debitori = (debitoriPerLinea.find(dpl => {return dpl.linea == l.id;}) ? debitoriPerLinea.find(dpl => {return dpl.linea == l.id;}).debitori.length : 0);// component.get("v.payload").joinLineaAttore.map(function(v){return v.linee.includes(l.id) ? 1 : 0;}).reduce(function(a,b){return a+b;});
                    items.push(l);

                    if (l.isActive && !activeItemAlreadySet)
                        activeItemAlreadySet = true;
                }
            }
        });
		console.log('@@@ sublines ' , subLines);
		console.log('@@@ codiciUnivoci ' , codiciUnivoci);
        if (subLines.length > 0)
            codiciUnivoci.forEach(cu => {
                let subLines2Add = subLines.filter(sl => {return sl.line.codiceUnivoco == cu;});
                items.push({
                    isClickable: false,
                    isSelected: true,
                    isActive: false,
                    isRemovable: false,
                    isRevisione: subLines2Add[0].isRevisione,
                    isCompleted: subLines2Add.reduce((start, sl) => {return start && sl.isCompleted;}, true),
                    debitori: (
                        debitoriPerLinea.find(dpl => {return subLines2Add.map(sl => {return sl.line.id}).includes(dpl.linea);}) ?
                        debitoriPerLinea.find(dpl => {return subLines2Add.map(sl => {return sl.line.id}).includes(dpl.linea);}).debitori.length : 0),
                    multiLine: true,
                    subLines: subLines2Add.sort(sl => {return sl.line.tipo == "lineaDiAcquisto" ? -1 : 1;}),
                    name: subLines2Add.find(sl => { return sl.line.atdSingola == "N"; }).line.nome,
                    icon: subLines2Add[0].icon,
                    title: subLines2Add.find(sl => { return sl.line.atdSingola == "N"; }).line.nome,
                    subtitle: this.getLineSubtitle(component, subLines2Add)
                });
            });
        
        // var gandg = { CategoriaProdotto__c: '' , Name: 'Garanti e Garanzie' , isClickable: true , isSelected: true, isGandG: true };
        // items.push(gandg);

        component.set("v.items", items);
        component.set("v.showNext", items.reduce(function(start, i) {return start && i.isCompleted;}, true));
    },

    setupDebitori : function(component) {
        // var joinLineaAttore = component.get("v.payload").joinLineaAttore;
        // var debitori = component.get("v.payload").debitori;
        var selectedLineId = (this.getActiveLine(component) ? this.getActiveLine(component).id : null);
        // var debitoriPerLine = [];

        // for (var jla in joinLineaAttore)
        //     if (joinLineaAttore[jla].linee.includes(selectedLineId))
        //         debitoriPerLine.push(this.getFirstNodeByFields(debitori, [{field:"id",value:joinLineaAttore[jla].debitore}]));

        // component.set("v.debitoriPerLine", debitoriPerLine);
        let debitoriPerLinea = component.get("v.debitoriPerLinea");
        component.set("v.isAvailableMultipleConfDebPerLine",
            (debitoriPerLinea.find(dpl => { return dpl.linea == selectedLineId; }) ? (debitoriPerLinea.find(dpl => { return dpl.linea == selectedLineId; }).debitori.length > 1 && (component.get("v.items").find(i => {return i.id == selectedLineId;}) != undefined ? component.get("v.items").find(i => {return i.id == selectedLineId;}).isCompleted : component.get("v.items").find(i => {return i.subLines > 0 && i.subLines.find(sl => {return sl.line.id == selectedLineId;}).isCompleted;})) ) : false));
        // component.set("v.isAvailableMultipleConfDebPerLine", ( component.get("v.debitoriPerLinea").length > 1 && component.get("v.isCompleted") ));
        component.set("v.selectedDeb", "");
    },

    setupParametriPerLineaDebitore : function(component) {
        let parametriPerLineaDebitore = new Map();
        let lines = component.get("v.payload").linee;
        let parametriEConfigurazioniLinee = component.get("v.parametriEConfigurazioniLinee");
        let allDebitori = component.get("v.payload").debitori;
        let debitoriPerLinea = component.get("v.debitoriPerLinea");
        let parametriConfiguratiPerLinea = this.groupArrayBy(component.get("v.payload").configurazioneLinee, "linea");
        
        let sezioni = parametriEConfigurazioniLinee.sezioni;
        component.set("v.sezioni", sezioni);

        lines.forEach(l => {
            let parametri = parametriEConfigurazioniLinee.parametri.filter(p => {return p.linea == l.id});
            let debsPerLine = [];
            debitoriPerLinea.filter(dpl => {
                return dpl.linea == l.id;
            }).forEach(dpl => {
                dpl.debitori.forEach(deb => {
                    debsPerLine.push(deb);
                });
            });

            // recupero tutti i debitori per linea
            let debitori = allDebitori.filter(d => {
                return debsPerLine.includes(d.id);
            });
            // e tutti i debitori "fittizi" cioè le linee con valutazione portafoglio
            component.get("v.payload").valutazioniPortafoglio.forEach(vp => {
                debitori.push(vp.id);
            });

            parametriPerLineaDebitore.set(l.id, this.getParameters(component, JSON.parse(JSON.stringify(parametri)), debitori, null, parametriConfiguratiPerLinea, l.id));

            debitori.forEach(d => {
                parametriPerLineaDebitore.set(l.id + "_" + d.id, this.getParameters(component, JSON.parse(JSON.stringify(parametri.filter(p => {return p.derogaFidoDiCoppia;}))), debitori, d.id, parametriConfiguratiPerLinea, l.id));
            });
        });
        component.set("v.parametriPerLineaDebitore", parametriPerLineaDebitore);
    },

    getParameters : function(component, params, debitori, selectedDeb, parametriConfiguratiPerLinea, selectedLineId) {
        let sectionsMap = this.mapArrayBy(component.get("v.sezioni"), "Label");
        let joinLineaAttore = component.get("v.payload").joinLineaAttore;
        let parametri = [];
        let condizioni = [];
        let paramValue = null;
        let valutazioniDebs = component.get("v.payload").valutazioniPortafoglio.map(vp => {return vp.id;});
        let isValPort = false;

        if (joinLineaAttore.find(j => {return j.linee.includes(selectedLineId);}))
            isValPort = valutazioniDebs.includes(joinLineaAttore.find(j => {return j.linee.includes(selectedLineId);}).debitore);

        for (var p in params) {
            let derogatedParams = [];
            // if (params[p].linea == selectedLineId) {
                // GET PARAMETER VALUE BASED ON SELECTED LINE, PARAMETER CODE AND, IF SELECTED, DEBITORE
                if (params[p].soloDeroga)
                    debitori.forEach(element => {
                        var tmp = {};
                        if (((isValPort && derogatedParams.length == 0) || !isValPort) && params[p].linea == selectedLineId)
                            derogatedParams.push(Object.assign(tmp, params[p], {value:(this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice},{field:"attore",value:element.id}]) ? this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice},{field:"attore",value:element.id}]).valore : null),nomeDebitore:(isValPort ? "Valutazione portafoglio" : element.rsociale), debitore:element.id}));
                    });
                else if (selectedDeb)
                    paramValue = (this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice},{field:"attore",value:selectedDeb}]) ? (this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice},{field:"attore",value:selectedDeb}]).hasOwnProperty("valore") ? this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice},{field:"attore",value:selectedDeb}]).valore : "") : null);
                else
                    paramValue = (this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice}]) ? (this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice}]).hasOwnProperty("valore") ? this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice}]).valore : "") : null);

                if (!params[p].soloDeroga) 
                    params[p].value = paramValue;

                if (!this.isBlank(params[p].defaultval) && !params[p].defaultval.startsWith("$") && params[p].value == null)
                    params[p].value = params[p].defaultval;
                
                params[p].paramId = (this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice}]) ? this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice}]).id : null);

                // CR 359 - VALORIZZO OPZIONE ISFIXEDVALUE
                params[p].isFixedValue = (this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice}]) ? (this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice}]).hasOwnProperty("isFixedValue") ? this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice}]).isFixedValue : false) : false);

                // GENERATE SECTIONS AND SUBSECTIONS WITH PARAMETERS
                if (params[p].sottosezione == undefined || params[p].sottosezione == null) {
                    if (this.getSectionIndex(params[p].sezione, parametri) < 0)
                        parametri = this.arrayPusher({
                            title: sectionsMap[params[p].sezione].NomeSezione__c,
                            code: params[p].sezione,
                            order: sectionsMap[params[p].sezione].Ordine__c,
                            class: (this.isVisibleSection(params[p].sezione) ? "" : "cstm-hidden"),
                            parameters: params[p].soloDeroga ? derogatedParams : [ params[p] ]
                        }, parametri);
                    else {
                        parametri[this.getSectionIndex(params[p].sezione, parametri)].parameters = this.arrayPusher(params[p].soloDeroga ? derogatedParams : params[p], parametri[this.getSectionIndex(params[p].sezione, parametri)].parameters);
                    }
                }
                else {
                    if (params[p].sezione == "CE01") { // TODO: INSERIRE CONDIZIONE CAMPO FORMULA PER IDENTIFICARE PARAMETRI / CONDIZIONI
                        if (this.getSectionIndex(params[p].sottosezione, condizioni) < 0)
                            condizioni = this.arrayPusher({ title: sectionsMap[params[p].sottosezione].NomeSezione__c, code: params[p].sottosezione, order: sectionsMap[params[p].sottosezione].Ordine__c, class: (this.isVisibleSection(params[p].sezione) ? "" : "cstm-hidden"), parameters: [ params[p] ] }, condizioni);
                        else
                            condizioni[this.getSectionIndex(params[p].sottosezione, condizioni)].parameters = this.arrayPusher(params[p], condizioni[this.getSectionIndex(params[p].sottosezione, condizioni)].parameters);
                    }
                    else {
                        if (this.getSectionIndex(params[p].sottosezione, parametri) < 0)
                            parametri = this.arrayPusher({ title: sectionsMap[params[p].sottosezione].NomeSezione__c, code: params[p].sottosezione, order: sectionsMap[params[p].sottosezione].Ordine__c, class: (this.isVisibleSection(params[p].sezione) ? "" : "cstm-hidden"), parameters: [ params[p] ] }, parametri);
                        else
                            parametri[this.getSectionIndex(params[p].sottosezione, parametri)].parameters = this.arrayPusher(params[p], parametri[this.getSectionIndex(params[p].sottosezione, parametri)].parameters);
                    }
                }
            // }
        }
        // FIX PER C/C CON SOLO CONDIZIONI E PARAMETRI NASCOSTI
        if (parametri.filter(p => {return p.code == "PN01";}).length > 0 && parametri.filter(p => {return p.code != "PN01";}).length == 0 && condizioni.length > 0) {
            condizioni.push(parametri.slice(0, 1)[0]);
            parametri = [];
        }
        // INIZIALIZZA PARAMETRI DI PAGINA PER VALORIZZAZIONE E RISOLUZIONE FORUMLE (eval)
        var lineProsolutoATD_flags = this.getLineProsolutoATDFlags(component.get("v.payload.joinLineaAttore"), component.get("v.items"));
        let lineDerogheFields = this.getLineDerogheFields(component);
        this.initializeCreditiVariables(component);
        // console.log("PARAMS ERROR: ", (parametri ? parametri.concat(condizioni) : condizioni));
        this.initializeParamsVariables(parametri ? parametri.concat(condizioni) : condizioni, lineProsolutoATD_flags, lineDerogheFields);
        
        // RISOLVE LA FORMULA PER IL VALORE DI DEFAULT
        this.evalFormulaDefaultValues(parametri);
        this.evalFormulaDefaultValues(condizioni);
        
        // SETTA IL FLAG DI VISIBILITA' DEI PARAMETRI
        this.evalParamsVisibility(parametri, null);
        this.evalParamsVisibility(condizioni, null);
        
        // RIMUOVE PARAMETRI DUPLICATI, LASCIANDO SOLO IL PARAMETRO VISIBILE
        this.removeDuplicatedParameters(parametri);
        this.removeDuplicatedParameters(condizioni);
        
        // GESTISCE L'EDITABILITA' DEI PARAMETRI IN SOLA DEROGA PER FIDI DI COPPIA GIROMONTE
        this.manageSolaDerogaReadonly(parametri, this.getActiveLine(component), component.get("v.codiciCoppia"));
        
        // ORDINA LE SEZIONI, FILTRA I PARAMETRI NON VISIBILI
        parametri = this.sortSections(parametri).filter(function(s) { return s.parameters.filter(function(p){return p.isVisible;}).length > 0; } );
        condizioni = this.sortSections(condizioni).filter(function(s) { return s.parameters.filter(function(p){return p.isVisible;}).length > 0; } );

        // SPOSTAMENTO IN FONDO DEI PARAMETRI "SOLODEROGA"
        parametri.forEach(p => { p.parameters = this.sortParameters(p.parameters); });
        condizioni.forEach(p => { p.parameters = this.sortParameters(p.parameters); });
        
        return {parametri: parametri, condizioni: condizioni};
    },

    setupParameters : function(component) { // , event, useEvent
        // var parametri = [];
        // var condizioni = [];
        // var paramValue = null;
        if (component === null || component === undefined) return;

        var parametriEConfigurazioniLinee = component.get("v.parametriEConfigurazioniLinee");

        if (parametriEConfigurazioniLinee === null || parametriEConfigurazioniLinee === undefined) return;
        // var parametriConfigurati = (useEvent ? event.getParam("value").configurazioneLinee : component.get("v.payload").configurazioneLinee);
        // var parametriConfigurati = component.get("v.payload").configurazioneLinee;
        // var valutazionePortafoglio = component.get("v.payload").valutazionePortafoglio;
        
        var sezioni = parametriEConfigurazioniLinee.sezioni;
        var params = parametriEConfigurazioniLinee.parametri;
        var visibleParams = [];

        // console.log("params: ", params);

        var sectionsMap = this.mapArrayBy(sezioni, "Label");
        var selectedLineId = (this.getActiveLine(component) ? this.getActiveLine(component).id : null);
        let parametriConfiguratiPerLinea = this.groupArrayBy(component.get("v.payload").configurazioneLinee, "linea");

        let scopeParams = component.get("v.parametriPerLineaDebitore");
        // debugger;
        let selectedDeb = component.get("v.selectedDeb");
        // let returnParams = this.getParameters(scopeParams.get(selectedLineId), debitori, selectedDeb, parametriConfiguratiPerLinea, selectedLineId);

        //TENAM-271 venivano esclusi alcuni parametri se si usa la combo linea+debitore
        //let paramKey = (this.isBlank(selectedDeb) ? selectedLineId : selectedLineId + "_" + selectedDeb);
        let paramKey = selectedLineId;
        console.log("paramKey: ", paramKey);
        
        if (scopeParams === null || scopeParams === undefined) return;
        let parametri = scopeParams.get(paramKey).parametri;
        let condizioni = scopeParams.get(paramKey).condizioni;

        // INIZIALIZZA PARAMETRI DI PAGINA PER VALORIZZAZIONE E RISOLUZIONE FORUMLE (eval)
        var lineProsolutoATD_flags = this.getLineProsolutoATDFlags(component.get("v.payload.joinLineaAttore"), component.get("v.items"));
        let lineDerogheFields = this.getLineDerogheFields(component);
        this.initializeParamsVariables(parametri ? parametri.concat(condizioni) : condizioni, lineProsolutoATD_flags, lineDerogheFields);
        // this.initializeCreditiVariables(component);
        
        // RISOLVE LA FORMULA PER IL VALORE DI DEFAULT
        this.evalFormulaDefaultValues(parametri);
        this.evalFormulaDefaultValues(condizioni);
        
        // SETTA IL FLAG DI VISIBILITA' DEI PARAMETRI
        this.evalParamsVisibility(parametri, selectedLineId);
        this.evalParamsVisibility(condizioni, selectedLineId);
        
        // RIMUOVE PARAMETRI DUPLICATI, LASCIANDO SOLO IL PARAMETRO VISIBILE
        this.removeDuplicatedParameters(parametri);
        this.removeDuplicatedParameters(condizioni);
        
        // GESTISCE L'EDITABILITA' DEI PARAMETRI IN SOLA DEROGA PER FIDI DI COPPIA GIROMONTE
        this.manageSolaDerogaReadonly(parametri, this.getActiveLine(component), component.get("v.codiciCoppia"));
        
        // ORDINA LE SEZIONI, FILTRA I PARAMETRI NON VISIBILI
        parametri = this.sortSections(parametri).filter(function(s) { return s.parameters.filter(function(p){return p.isShowing && p.isVisible;}).length > 0; } );
        condizioni = this.sortSections(condizioni).filter(function(s) { return s.parameters.filter(function(p){return p.isShowing && p.isVisible;}).length > 0; } );

        // SPOSTAMENTO IN FONDO DEI PARAMETRI "SOLODEROGA"
        parametri.forEach(p => { p.parameters = this.sortParameters(p.parameters); });
        condizioni.forEach(p => { p.parameters = this.sortParameters(p.parameters); });
        console.log("parametri: ", parametri);
        component.set("v.parametriSezioni", parametri);
        component.set("v.condizioniSezioni", condizioni);
    },

    reloadParametersOnDebitore : function(component, selectedDeb) {
        // let scopeParams = component.get("v.parametriPerLineaDebitore");
        let selectedLineId = (this.getActiveLine(component) ? this.getActiveLine(component).id : null);
        // let allDebitori = component.get("v.payload").debitori;
        // let debitoriPerLinea = component.get("v.debitoriPerLinea");
        // let selectedDeb = (event ? event.getSource().get("v.value") : null);
        let parametriConfiguratiPerLinea = this.groupArrayBy(component.get("v.payload").configurazioneLinee, "linea");
        // let debitori = [];
        // if (debitoriPerLinea.find(dpl => { return dpl.linea == selectedLineId; }) != undefined)
        //     debitori = allDebitori.filter(d => { return debitoriPerLinea.find(dpl => { return dpl.linea == selectedLineId; }).debitori.includes( d.id ); });

        // let returnParams = this.getParameters(component, scopeParams.get(selectedLineId), debitori, selectedDeb, parametriConfiguratiPerLinea, selectedLineId);
        let parametriPerLineaDebitore = component.get("v.parametriPerLineaDebitore");
        let parametri = component.get("v.parametriSezioni");
        let condizioni = component.get("v.condizioniSezioni");

        let defaultValues = new Map();
        parametriConfiguratiPerLinea[selectedLineId].forEach(p => {
            if (p.attore == undefined)
                defaultValues.set(p.codice, p.valore);
            else
                defaultValues.set(p.codice + "_" + p.attore, p.valore);
        });
// console.log("PARAMSSSS: ", defaultValues);
console.log("selectedDeb: ", selectedDeb);
        parametri.forEach(sez => {
            sez.parameters.forEach(p => { console.log("parametersConfiguredByLineAndCode: ", parametriConfiguratiPerLinea[selectedLineId].filter(ppl => {return ppl.codice == p.codice;}));
                if (p.soloDeroga)
                    p.value = defaultValues.get(p.codice + "_" + p.debitore);
                else if (selectedDeb && parametriConfiguratiPerLinea[selectedLineId].filter(ppl => {return ppl.codice == p.codice;}).map(ppl => {return ppl.attore;}).includes(selectedDeb))
                    p.value = parametriConfiguratiPerLinea[selectedLineId].filter(ppl => {return ppl.codice == p.codice;}).find(ppl => {return ppl.attore == selectedDeb;}).valore;
                else
                    p.value = defaultValues.get(p.codice);
            });
        });

        condizioni.forEach(sez => {
            sez.parameters.forEach(p => {
                if (p.soloDeroga)
                    p.value = defaultValues.get(p.codice + "_" + p.debitore);
                else if (selectedDeb && parametriConfiguratiPerLinea[selectedLineId].filter(ppl => {return ppl.codice == p.codice;}).map(ppl => {return ppl.attore;}).includes(selectedDeb))
                    p.value = parametriConfiguratiPerLinea[selectedLineId].filter(ppl => {return ppl.codice == p.codice;}).find(ppl => {return ppl.attore == selectedDeb;}).valore;
                else
                    p.value = defaultValues.get(p.codice);
            });
        });

        // INIZIALIZZA PARAMETRI DI PAGINA PER VALORIZZAZIONE E RISOLUZIONE FORUMLE (eval)
        var lineProsolutoATD_flags = this.getLineProsolutoATDFlags(component.get("v.payload.joinLineaAttore"), component.get("v.items"));
        let lineDerogheFields = this.getLineDerogheFields(component);
        this.initializeParamsVariables(parametri ? parametri.concat(condizioni) : condizioni, lineProsolutoATD_flags, lineDerogheFields);
        // this.initializeCreditiVariables(component);
        
        // RISOLVE LA FORMULA PER IL VALORE DI DEFAULT
        this.evalFormulaDefaultValues(parametri);
        this.evalFormulaDefaultValues(condizioni);
        
        // SETTA IL FLAG DI VISIBILITA' DEI PARAMETRI
        this.evalParamsVisibility(parametri, selectedLineId);
        this.evalParamsVisibility(condizioni, selectedLineId);
        
        // RIMUOVE PARAMETRI DUPLICATI, LASCIANDO SOLO IL PARAMETRO VISIBILE
        this.removeDuplicatedParameters(parametri);
        this.removeDuplicatedParameters(condizioni);
        
        // GESTISCE L'EDITABILITA' DEI PARAMETRI IN SOLA DEROGA PER FIDI DI COPPIA GIROMONTE
        this.manageSolaDerogaReadonly(parametri, this.getActiveLine(component), component.get("v.codiciCoppia"));
        
        // ORDINA LE SEZIONI, FILTRA I PARAMETRI NON VISIBILI
        parametri = this.sortSections(parametri).filter(function(s) { return s.parameters.filter(function(p){return p.isShowing && p.isVisible;}).length > 0; } );
        condizioni = this.sortSections(condizioni).filter(function(s) { return s.parameters.filter(function(p){return p.isShowing && p.isVisible;}).length > 0; } );

        // SPOSTAMENTO IN FONDO DEI PARAMETRI "SOLODEROGA"
        parametri.forEach(p => { p.parameters = this.sortParameters(p.parameters); });
        condizioni.forEach(p => { p.parameters = this.sortParameters(p.parameters); });
        console.log("parametri: ", parametri);
        component.set("v.parametriSezioni", parametri);
        component.set("v.condizioniSezioni", condizioni);
    },

    validateAndSave : function(component, event) {
        // var valid = this.validateAllParams(component);
        // if (valid)
            this.fireSave(component, "configurazionelinee");
    },

    //SM - Spese Istruttoria
    openSpeseIstruttoria : function(component, event){
        let speseIstruttoria = component.get("v.speseIstruttoria");
        let h = this;
        let checkCompletedLines = component.get("v.items").filter((lin) => { return !lin.isCompleted });
        let isReviOpty = component.get("v.tipoOpty") == 'REVI';
        if(speseIstruttoria != null && speseIstruttoria != undefined && checkCompletedLines.length == 0){
            $A.createComponents([
                ["c:WGC_SpeseIstruttoriaModal", { payload : component.getReference("v.payload"), speseIstruttoria : speseIstruttoria, isRevi : isReviOpty } ]
            ],
                function(content, status) {
                    if (status === "SUCCESS") {
                        component.find('overlayLib').showCustomModal({
                            header: "Spese Istruttoria",
                            body: content,
                            showCloseButton: true,
                            cssClass: "",
                            closeCallback : () => {
                                h.saveParametriConfigurati(component, event);
                            }
                        });
                    }
                    else if (status === "ERROR") {
                        var toast = $A.get("e.force:showToast");
                        toast.setParams({
                            "title" : "ERRORE",
                            "message" : "Errore durante il caricamento riprovare"
                        });
                    }
                });
        }
    },

    openCommissione : function(component, event, helper){
        var h = this;
        $A.createComponents([
            ["c:WGC_Commissione_Modal", { opportunityId : component.get("v.opportunityId"), value: component.get("v.commissione"), action: component.getReference("v.modalAction"), readOnly: component.get("v.readOnly") } ]
        ],
            function(content, status) {
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        header: "Comm. Disponibilità Fondi (CDF) Trim.",
                        body: content,
                        showCloseButton: true,
                        cssClass: "",
                        closeCallback : () => {
                            // if(component.get("v.modalAction") == 'salva')
                            //     h.saveCommissione(component, event, helper);
                        }
                    });
                }
                else if (status === "ERROR") {
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        "title" : "ERRORE",
                        "message" : "Errore durante il caricamento riprovare"
                    });
                }
            });
    },

    getParametriBC : function(component, event, helper){
        var activeItem = component.get("v.items").find(l => { return l.isActive; });
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.getCondizioniBC" , "params" : { opportunityId: component.get("v.opportunityId"), codProd: activeItem.codice }, "spinnerMessage" : "Recupero parametri in corso.." });
        appEvent.fire();
    },

    openParametriBC : function(component, event, helper){
        // var h = this;
        var params = component.get("v.metadatoCondizioni");
        var activeItem = component.get("v.items").find(l => { return l.isActive; });
        $A.createComponents([
            ["c:WGC_RedirectParametriBC_Modal", { params: params, payload : component.getReference("v.payload"), codProd : activeItem.codice, lineId: activeItem.id, readOnly: component.get("v.readOnly") } ]
        ],
        function(content, status) {
            if (status === "SUCCESS") {
                component.find('overlayLib').showCustomModal({
                    header: "Spread SBF d.i.",
                    body: content,
                    showCloseButton: true,
                    cssClass: "",
                    closeCallback : () => {
                        // h.unlockStateSpinner(component);
                        // h.hideSpinner(component);
                    }
                });
            }
            else if (status === "ERROR") {
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "title" : "ERRORE",
                    "message" : "Errore durante il caricamento riprovare"
                });
            }
        });
    },
    
    saveCommissione : function(component, event, helper){
        var action = event.getParam("json").action;
        var value = event.getParam("json").value;
        if(action == "salva"){
            let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
            appEvent.setParams({ "method": "c.updateField", "params": {
                field: 'WGC_Comm_Disponibilit_Fondi_CDF_Trim__c',
                value: parseFloat(value),
                objectId: component.get("v.opportunityId")
            }});
            appEvent.fire();
        }
    },

    saveParametriConfigurati : function(component, event){
        let parametri = JSON.stringify(Array.from(component.get("v.payload.configurazioneLinee")));
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method": "c.savePConfigurati", "params": {
            paramsJSON: parametri
        }});
        appEvent.fire();
    },

    validateAllParams : function(component) { // NON UTILIZZATA: NON CI SONO CONTROLLI DI VALIDAZIONE PRE-SALVATAGGIO PARAMETRI
        // var params = component.find("WGC_Parameter");
        let h = this;
        var sections = component.get("v.parametriSezioni").concat(component.get("v.condizioniSezioni"));
        var valid = sections.reduce(function (validSoFar, sec) {
            console.log("validation Section: ", sec);
            console.log("validSoFar: ", validSoFar);
            return validSoFar && sec.parameters.reduce((paramsValidSoFar, param) => {
                console.log("validation Param: ", param);
                console.log("paramsValidSoFar: ", paramsValidSoFar);
                return paramsValidSoFar && ( param.isVisible && param.obbligatorio ? !h.isBlank(param.value) : true );
            }, true);
            // return validSoFar && (param.obbligatorio ? (param.value != null || param.value != "") : true );
        }, true);
        
        return valid;
    },

    fireSave : function(component, step) {
        var allParameters = component.get("v.parametriEConfigurazioniLinee").parametri;
        let items = component.get("v.items");
        let atdivalines = items.filter(i => { return i.name == 'ATD - IVA' || i.name == 'ATD - IVA NotNot' });
        var sections = component.get("v.parametriSezioni").concat(component.get("v.condizioniSezioni"));
        var params = sections.reduce(function(tmpParams, p){
            return tmpParams.concat(p.parameters);
        }, []);
        var payload = component.get("v.payload");
        var configurazioneLinee = payload.configurazioneLinee;
        var selectedDeb = component.get("v.selectedDeb");
        let multipleConfDebPerLine = component.get("v.multipleConfDebPerLine");
        var activeLineId = this.getActiveLine(component).id;
        //SM - Spese Istruttoria
        var speseIstruttoria = component.get("v.speseIstruttoria");
        var setCodiciSpese = new Set();
        //SM - Spese Istruttoria
        let creditiWrapper = component.find("creditiWrapper");
        if (creditiWrapper) console.log("creditiWrapper.confirm(): ", creditiWrapper.confirm());
        speseIstruttoria.forEach((item) => { setCodiciSpese.add(item.DeveloperName) });

        //SM - Parametri Nascosti
        if(atdivalines.length > 0){
            var idLineaCaricoAtdIVA = atdivalines[0].subLines.find(l => { return l.line.tipo == 'lineaDiCarico' }).line.id;
            var idLineaAcquistoAtdIVA = atdivalines[0].subLines.find(l => { return l.line.tipo == 'lineaDiAcquisto' }).line.id;
            if(activeLineId == idLineaCaricoAtdIVA || activeLineId == idLineaAcquistoAtdIVA)
                params = params.concat(allParameters.filter(p => { return p.linea == atdivalines[0].subLines.find(l => { return l.line.tipo == 'lineaDiCarico' }).line.id }));
        }

        // FILTRO PER RIMOZIONE PARAMETRI CONFIGURATI NON PIU' APPARTENENTI ALLA LINEA
        //SM - Spese Istruttoria
        //SM - TEN: Aggiunta condizione per non escludere un parametro sbf che non è presente nella maschera, nello specifo Spread CDA02_1053
        configurazioneLinee = configurazioneLinee.filter(cl => {return cl.linea != activeLineId || params.map(p => {return p.codice;}).includes(cl.codice) || cl.codice == 'CDA02_1053' || setCodiciSpese.has(cl.codice) });
        let newParams = [];
        // iterate over params+conds
        // if soloDeroga OR deroga attiva
        //  --TRUE: upsert valore configurazione per attore, codice e linea
        //  --FALSE: upsert valore configurazione per codice e linea
// console.log("configurazioneLinee: ", configurazioneLinee);
        // params.filter(function(p){return p.isVisible}).forEach(p => {
        //this.initializeParamsVariables(params);
        params.forEach(p => {
            
            // console.log("codice: " + p.codice + " --value: " + p.value + " --typeof: " + typeof p.value);
            // if (p.tipologia == "Flag")
                // console.log("codice: " + p.codice + " --value: " + p.value);
            if (p.tipologia == "Multi-picklist") {
                p.value = (p.value ? (typeof p.value == "string" ? p.value : p.value.join(";")) : null);
                // console.log("join: ", p.value);
            }
            // console.log(p);
            // console.log(p.soloDeroga);
            // console.log(component.get("v.multipleConfDebPerLine"));
            // console.log((p.soloDeroga ? p.debitore : selectedDeb));
            if (p.soloDeroga || (multipleConfDebPerLine && !this.isBlank(selectedDeb))) {
                let confParam = configurazioneLinee.find(cl => {
                    // console.log("cl.codice: "+cl.codice+" --cl.attore: "+cl.attore+" --soloDeroga: "+p.soloDeroga+" --selectedDeb: "+selectedDeb+" --cl.linea: "+cl.linea);
                    // console.log("sameCode: ", cl.codice == p.codice);
                    // console.log("sameLine: ", cl.linea == activeLineId);
                    // console.log("sameDeb: ", cl.attore == (p.soloDeroga ? p.debitore : selectedDeb));
                    return cl.attore == (p.soloDeroga ? p.debitore : selectedDeb) && cl.codice == p.codice && cl.linea == activeLineId;});
                // console.log("param: ", p);
                let paramLineVal = configurazioneLinee.find(cl => {return cl.linea == activeLineId && cl.codice == p.codice && cl.hasOwnProperty("attore") == false;}) ? configurazioneLinee.find(cl => {return cl.linea == activeLineId && cl.codice == p.codice && cl.hasOwnProperty("attore") == false;}).valore : null;
                // console.log("paramLineVal: "+ paramLineVal +" -- codice: "+ p.codice+" --!soloDeroga: "+ !p.soloDeroga);
                if (confParam != null && !this.isBlank(p.value)) {
                // if (this.getFirstNodeByFields(configurazioneLinee,[
                //         {field:"attore",value:(p.soloDeroga ? p.debitore : selectedDeb)},
                //         {field:"codice",value:p.codice},
                //         {field:"linea",value:activeLineId}
                //     ]) != null)

                    if (p.value == paramLineVal && !p.soloDeroga)
                        configurazioneLinee = configurazioneLinee.filter(cl => {return !(cl.linea == p.linea && cl.codice == p.codice && cl.attore == (p.soloDeroga ? p.debitore : selectedDeb));});
                    else
                        confParam.valore = p.value;
                }
                else if (!this.isBlank(p.value)) {
                    if (paramLineVal != p.value || p.soloDeroga){
                        newParams.push({
                            attore: (p.soloDeroga ? p.debitore : selectedDeb),
                            codice: p.codice,
                            // id: p.paramId,
                            linea: activeLineId,
                            valore: p.value
                        });
                    } else
                        configurazioneLinee = configurazioneLinee.filter(cl => {return !(cl.linea == p.linea && cl.codice == p.codice && cl.attore == (p.soloDeroga ? p.debitore : selectedDeb));});
                }
            }
            else {
                //(activeLineId == idLineaAcquistoAtdIVA && idLineaCaricoAtdIVA == p.linea) ? p.linea : activeLineId
				if (this.getFirstNodeByFields(configurazioneLinee,[{field:"codice",value:p.codice},{field:"linea",value:(activeLineId == idLineaAcquistoAtdIVA && idLineaCaricoAtdIVA == p.linea) ? p.linea : activeLineId }]) != null){
                    if(p.linea == activeLineId){
                        this.getFirstNodeByFields(configurazioneLinee,
                        [
                            {field:"codice",value:p.codice},
                            {field:"linea",value:activeLineId}
                        ]).valore = p.value == "" || p.value == null || p.value == undefined ? this.resetDefaultValue(new Array(p)) : p.value ;
                    } else if(p.linea == idLineaCaricoAtdIVA){
                        this.getFirstNodeByFields(configurazioneLinee,
                        [
                            {field:"codice",value:p.codice},
                            {field:"linea",value:idLineaCaricoAtdIVA}
                        ]).valore = p.value == "" || p.value == null || p.value == undefined ? this.resetDefaultValue(new Array(p)) : p.value ;
                    }
                } else if (p.value != null && p.value != undefined){
                    newParams.push({
                        codice: p.codice,
                        // id: p.paramId,
                        linea: activeLineId,
                        valore: p.value
                    });
                }
                //CONDIZIONE SOLO PER PARAMETRI NASCOSTI LINEA DI CARICO ATD IVA / ATD IVA NOT NOT
                // } else if(( p.value == null || p.value == undefined ) && p.linea == idLineaCaricoAtdIVA && !configurazioneLinee.find(c =>{ return c.codice == p.codice && c.linea == p.linea }) ){
                //     console.log('@@@ p 2 ' , p);
                //     newParams.push({
                //         codice: p.codice,
                //         // id: p.paramId,
                //         linea: idLineaCaricoAtdIVA,
                //         valore: p.defaultval
                //     });
                // }
            }
        });

        let icarManuali = component.get("v.icarManualiValues");

        if (icarManuali.length > 0) {
            let selectedLine = component.get("v.items").find(i => {return i.isActive;}).id;
            let icarData = payload.configurazioneIcarManuali.filter(cim => {return cim.linea != selectedLine;});
            let icarManualiMap = [];
            var imdm = "";

            icarManuali.forEach(im => {
                if (im.columns) {
                    let debitore = im.columns.find(c => {return c.name == "debitore";}).value;
                    if (debitore) {
                        imdm = "{";

                        im.columns.forEach(c => {
                            if (c.name != "debitore")
                                if (c.value != null)
                                    if (c.type == "date" && this.isBlank(c.value))
                                        imdm += "\""+c.name+"\":null,";
                                    else
                                        imdm += "\""+c.name+"\":\""+(c.type == "date" ? (this.isBlank(c.value) ? null : new Date(c.value).getTime()) : c.value)+"\",";
                                    // Object.defineProperty(imdm, c.name, {
                                    //     value: c.value
                                    // });
                        });
                        imdm = imdm.slice(0, imdm.length-1) + "}";

                        if (icarManualiMap[debitore])
                            icarManualiMap[debitore].push(JSON.parse(imdm));
                        else
                            icarManualiMap[debitore] = [JSON.parse(imdm)];
                    }
                }
            });

            for (let key in icarManualiMap) {
                icarData.push({
                    debitore: key,
                    icarManuali: icarManualiMap[key],
                    linea: selectedLine
                });
            }

            payload.configurazioneIcarManuali = JSON.parse(JSON.stringify(icarData));
            step = step + ",configurazioneicarmanuali";
        }
        payload.configurazioneLinee = configurazioneLinee.concat(newParams);
        payload = this.fixParametriMutuo(payload);
        //SM - TEN: Fix per eliminare il parametro spread sulle linee veicolate
        payload.configurazioneLinee = this.fixCondizioniSBF(component, payload.configurazioneLinee);
        console.log("payload: ", payload);
        payload.valutazioniPortafoglio.forEach(vp => {
            for (let key in vp)
                if (vp[key] === "true" || vp[key] === "false")
                    vp[key] = (vp[key] == "true");
        });
        // let wizardCompletato = true;
        // items.forEach(i => {
        //     if (i.subLines.length > 0) {
        //         i.subLines.forEach(sl => {
        //             console.log("isSubLineCompleted: ", this.isLineCompleted(component, sl.line.id, configurazioneLinee));
        //             wizardCompletato = wizardCompletato && this.isLineCompleted(component, sl.line.id, configurazioneLinee);    
        //         });
        //     } else {
        //         console.log("isLineCompleted: ", this.isLineCompleted(component, i.id, configurazioneLinee));
        //         wizardCompletato = wizardCompletato && this.isLineCompleted(component, i.id, configurazioneLinee);
        //     }
        // });
        // payload.wizardCompletato = wizardCompletato;
        // FIRE SAVE EVENT PASSING PAYLOAD
        // $A.util.removeClass(component.find("WGC_spinner"), "slds-hide");
        // var cmpEvent = component.getEvent("savePayload");
        // cmpEvent.setParams({ "payload" : payload , "step" : step });
        // cmpEvent.fire();

        //SM CART FF
        // let creditiCmp = component.find("configuraCrediti").salva();
        // console.log('@@@ creditiCmp ' , JSON.stringify(creditiCmp));
        payload.wizardCompletato = false;
        let validPayload = this.validatePayload(payload);
        if (this.isBlank(validPayload)) validPayload = this.validateKNETLimits(params, payload.linee);
        if (this.isBlank(validPayload)) {
            var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
            appEvent.setParams({ "method" : "c.saveWizard" , "params" : { payload: JSON.stringify(this.addPAggiuntivi(payload)), step: step } });
            appEvent.fire();
            // SAVE CREDITI
            if (creditiWrapper) {
                var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
                appEvent.setParams({ "method" : "c.saveCrediti" , "params" : { opportunityId: payload.opportunityId, crediti: creditiWrapper.confirm().crediti } });
                appEvent.fire();
            }
        } else {
            // TODO: ottimizzabile, implementare evento di comunicazione con AccountOpportunity_Detail per gestione centralizzata Toast
            this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), validPayload, "warning");
        }
    },

    validateKNETLimits : function(params, lines) {
        let isOk = params.filter(p => {return !this.isBlank(p.limiteKNET) && !lines.find(l => {return l.id == p.linea;}).isRevisione;})
                         .reduce((start, p) => {return start && p.limiteKNET >= p.value;}, true);
        return isOk ? "" : $A.get("$Label.c.WGC_Cart_KNETLimitsError");
    },

    updateWizardCompletato : function(component, nextStep) {
        let items = component.get("v.items");
        let payload = component.get("v.payload");
        let wizardCompletato = true;
        items.filter(i => {return !i.isDisabledRevLine;}).forEach(i => {
            if (i.subLines.length > 0) {
                i.subLines.forEach(sl => {
                    console.log("isSubLineCompleted: ", sl.isCompleted);
                    // wizardCompletato = wizardCompletato && this.isLineCompleted(component, sl.line.id, payload.configurazioneLinee);    
                    wizardCompletato = wizardCompletato && sl.isCompleted;
                });
            } else {
                console.log("isLineCompleted: ", i.isCompleted);
                // wizardCompletato = wizardCompletato && this.isLineCompleted(component, i.id, payload.configurazioneLinee);
                wizardCompletato = wizardCompletato && i.isCompleted;
            }
        });
        payload.wizardCompletato = wizardCompletato;

        //SM - TEN: Fix Condizioni SBF
        payload.configurazioneLinee = this.fixCondizioniSBF(component, payload.configurazioneLinee);

        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.saveWizard" , "params" : { payload: JSON.stringify(this.addPAggiuntivi(payload)), step: "configurazionelinee", nextStep: nextStep } });
        appEvent.fire();
    },

    validatePayload : function(payload) {
        let errorMessage = "";

        payload.configurazioneIcarManuali.forEach(im => {
            if (this.isBlank(im.debitore) && this.isBlank(errorMessage))
                errorMessage = "La configurazione inserita per i Dati Fattura è incompleta.";
            else if (this.isBlank(errorMessage)) {
                im.icarManuali.forEach(imv => {
                    if (this.isBlank(errorMessage)) {
                        if (this.isBlank(imv.dataEmissioneA) || this.isBlank(imv.dataEmissioneDa)) {
                            if (this.isBlank(imv.annoFatturatoDa) && this.isBlank(imv.annoFatturatoA) && this.isBlank(imv.numeroFatturaDa) && this.isBlank(imv.numeroFatturaA)) {
                                errorMessage = "La configurazione inserita per i Dati Fattura è incompleta.";
                            }
                        }
                        if (this.isBlank(imv.annoFatturatoDa) || this.isBlank(imv.annoFatturatoA) || this.isBlank(imv.numeroFatturaDa) || this.isBlank(imv.numeroFatturaA)) {
                            if (this.isBlank(imv.dataEmissioneA) && this.isBlank(imv.dataEmissioneDa)) {
                                errorMessage = "La configurazione inserita per i Dati Fattura è incompleta.";
                            }
                        }
                    }
                });
            }
        });

        return errorMessage;
    },

    // DEPRECATED
    addPAggiuntivi : function(payload) {
        var pAggiuntivi = [];
        // let mapDebitori = new Map();

        // if (payload.debitori.length > 0)
        //     payload.debitori.forEach(deb => {mapDebitori.set(deb.id, deb);});

        // if (payload.valutazioniPortafoglio.length > 0)
        //     payload.valutazioniPortafoglio.forEach(deb => {mapDebitori.set(deb.id, deb);});

        // if (payload.joinLineaAttore != undefined && payload.linee != undefined) {
        //     payload.configurazioneLinee = payload.configurazioneLinee.filter(cl => { return cl.codice != "008" && cl.codice != "280" && cl.codice != "101";});

        //     if (!payload.valutazionePortafoglio) {
        //         payload.joinLineaAttore.forEach(jla => {
        //             if (jla.hasOwnProperty("debitore") && jla.hasOwnProperty("linee")) {
        //                 var deb = jla.debitore;
        //                 jla.linee.forEach(l => {
        //                     if (!payload.linee.find(pl => {return l == pl.id}).isRevisione && l.codice != "211") // DA NON VALORIZZARE PER ACF
        //                         pAggiuntivi.push({
        //                             codice: "008",
        //                             valore: mapDebitori.get(deb).durataNominale,
        //                             linea: l,
        //                             attore: mapDebitori.get(deb).id,
        //                             tipo: 'Parametro aggiuntivo'
        //                         });
        //                 });
        //             }
        //         });
        //     }
        
        //     payload.linee.forEach(li => {
        //         if (li.atdSingola != null)  pAggiuntivi.push({ codice: "280", valore: li.atdSingola, linea: li.id, attore: null });
        //         if (li.icarAutomaticiATD != null)  pAggiuntivi.push({ codice: "101", valore: li.icarAutomaticiATD, linea: li.id, attore: null });
        //         if (li.docsOperCede != null)  pAggiuntivi.push({ codice: "013", valore: li.docsOperCede, linea: li.id, attore: null });
        //     });

        // }
        
        payload.parametriAggiuntivi = pAggiuntivi;
        return payload;
    },

    getLineProsolutoATDFlags : function(joins, lines) {
        // console.log("getLineProsolutoATDFlags: ");
        // console.log(JSON.parse(JSON.stringify(this.getFirstNodeByFields(lines, [{field:"isActive",value:true}]))));
        let subLines = lines.reduce((start, l) => { if (l.subLines.length > 0) return start.concat(l.subLines); else return start; }, []);
        if(this.getFirstNodeByFields(lines, [{field:"isActive",value:true}]) == undefined && this.getFirstNodeByFields(subLines, [{field:"isActive",value:true}]) == undefined ){
            if(lines[0].subLines.length > 0){
                lines[0].subLines[0].isActive = true;
            } else {
                lines[0].isActive = true;
            }
        }

        // component.set("v.items", lines);

        let activeLineId = (
            this.getFirstNodeByFields(lines, [{field:"isActive",value:true}]) == undefined ?
            this.getFirstNodeByFields(subLines, [{field:"isActive",value:true}]).line.id :
            this.getFirstNodeByFields(lines, [{field:"isActive",value:true}]).id
        );
        let mapLines = new Map();
        lines.forEach(l => {
            mapLines.set(l.id, l);
            if (l.subLines.length > 0){
                l.subLines.forEach(sl => {
                    mapLines.set(sl.line.id, sl.line);
                });
            }
        });
        // let mapLines = this.mapArrayBy(lines, "id");
// MIGLIORABILE: i flag PROSOLUTO e ATD sono boolean dell'oggetto linea, possibile enhancement => passaggio da boolean a multi-picklist

        return {
            PROSOLUTO: mapLines.get(activeLineId).lineaProsoluto,
            ATD: mapLines.get(activeLineId).lineaAtd,
            ATD_SINGOLA: mapLines.get(activeLineId).atdSingola,
            ICAR_AUTO: mapLines.get(activeLineId).icarAutomaticiATD,
            DOCS_OPER_CEDE: mapLines.get(activeLineId).docsOperCede,
            GG_DILAZIONE: mapLines.get(activeLineId).ggDilazione,
            VP: mapLines.get(activeLineId).valutazionePortafoglio,
            //SM-CART-REVI
            ISREVISIONE: mapLines.get(activeLineId).isRevisione
        };
    },

    getLineDerogheFields : function(component) {
        let payload = component.get("v.payload");
        let mapDebitori = new Map();
        let ret = {};
        // let durNomPerDeb = [];
        // let esteroPerDeb = [];
        // let contropartePrivatoPerDeb = [];

        if (payload.debitori.length > 0)
            payload.debitori.forEach(deb => {mapDebitori.set(deb.id, deb);});

        if (payload.valutazioniPortafoglio.length > 0)
            payload.valutazioniPortafoglio.forEach(deb => {mapDebitori.set(deb.id, deb);});

        payload.joinLineaAttore.forEach(jla => {
            // durNomPerDeb.push({
            //     debitore: jla.debitore,
            //     value: mapDebitori.get(jla.debitore).durataNominale
            // });
            
            // esteroPerDeb.push({
            //     debitore: jla.debitore,
            //     value: mapDebitori.get(jla.debitore).estero
            // });
            
            // contropartePrivatoPerDeb.push({
            //     debitore: jla.debitore,
            //     value: mapDebitori.get(jla.debitore).contropartePrivato
            // });
            Object.defineProperty(ret, "D_" + jla.debitore + "_DURATA_NOMINALE", {value: mapDebitori.get(jla.debitore).durataNominale});
            Object.defineProperty(ret, "D_" + jla.debitore + "_ESTERO", {value: mapDebitori.get(jla.debitore).estero});
            Object.defineProperty(ret, "D_" + jla.debitore + "_CONTROPARTE_PRIVATO", {value: mapDebitori.get(jla.debitore).contropartePrivato});
            Object.defineProperty(ret, "D_" + jla.debitore + "_FIDO_DI_COPPIA", {value: mapDebitori.get(jla.debitore).plafond});
            Object.defineProperty(ret, "D_" + jla.debitore + "_DI_CUI_PROSOLUTO", {value: mapDebitori.get(jla.debitore).dcp});
        });

        // return {
        //     DURATA_NOMINALE: durNomPerDeb,
        //     ESTERO: esteroPerDeb, // mapLines.get(activeLineId).estero,
        //     CONTROPARTE_PRIVATO: contropartePrivatoPerDeb // mapLines.get(activeLineId).contropartePrivato,
        // };
        return ret;
    },

    getLineCreditsVariables : function(joins, lines) {
        // console.log("getLineProsolutoATDFlags: ");
        // console.log(JSON.parse(JSON.stringify(this.getFirstNodeByFields(lines, [{field:"isActive",value:true}]))));
        let subLines = lines.reduce((start, l) => { if (l.subLines.length > 0) return start.concat(l.subLines); else return start; }, []);
        let activeLineId = (
            this.getFirstNodeByFields(lines, [{field:"isActive",value:true}]) == undefined ?
            this.getFirstNodeByFields(subLines, [{field:"isActive",value:true}]).line.id :
            this.getFirstNodeByFields(lines, [{field:"isActive",value:true}]).id
        );
        let mapLines = new Map();
        lines.forEach(l => {
            mapLines.set(l.id, l);
            if (l.subLines.length > 0)
                l.subLines.forEach(sl => {
                    mapLines.set(sl.line.id, sl.line);
                });
        });
        // let mapLines = this.mapArrayBy(lines, "id");
// MIGLIORABILE: i flag PROSOLUTO e ATD sono boolean dell'oggetto linea, possibile enhancement => passaggio da boolean a multi-picklist

        return {
            PROSOLUTO: mapLines.get(activeLineId).lineaProsoluto,
            ATD: mapLines.get(activeLineId).lineaAtd,
            ATD_SINGOLA: mapLines.get(activeLineId).atdSingola,
            ICAR_AUTO: mapLines.get(activeLineId).icarAutomaticiATD,
            DOCS_OPER_CEDE: mapLines.get(activeLineId).docsOperCede,
            GG_DILAZIONE: mapLines.get(activeLineId).ggDilazione,
            VP: mapLines.get(activeLineId).valutazionePortafoglio,
            //SM-CART-REVI
            ISREVISIONE: mapLines.get(activeLineId).isRevisione
        };
    },

    // FUNCTION TO INITIALIZE VARIABLES ON "window"
    initializeParamsVariables : function(parameters, lineProsolutoATD_flags, derogaFields) {
        var JSONparams = "{";
        var params;
        var sections = [];
        // console.log("parameters: ", parameters);
        // ITERATE OVER SECTIONS AND PARAMETERS TO POPULATE "sections" AND "params"
        parameters.forEach((s, si) => {
            // var isSectionComplete = true;
            if (s.parameters.length > 0) {
                if (si>0)
                        JSONparams += ',';
                s.parameters.forEach((e, i) => {
                    if (i>0)
                        JSONparams += ',';
                    JSONparams += '"VV_' + e.codice + '":' + (e.value == "true" || e.value == "false" || e.value == "TRUE" || e.value == "FALSE" ? e.value.toLowerCase() : '"' + e.value + '"');
                });
            }
            // params[e.code] = true;
        });
        JSONparams += "}";
        params = JSON.parse(JSONparams);
        // VARIABLES NEEDS TO BE PUSHED IN THE window IN ORDER TO USE THE eval() FUNCTION
        console.log("window.params: ", params);
        window.params = params;
        if (lineProsolutoATD_flags)
            window.lineaFlags = lineProsolutoATD_flags;
        if (derogaFields)
            window.derogaFields = derogaFields;
        console.log("window.derogaFields: ", derogaFields);
    },

    initializeCreditiVariables : function(component, creditiEvent) {
        let creditiWrapper = component.find("creditiWrapper");
        let crediti = (creditiEvent ? creditiEvent : (creditiWrapper ? creditiWrapper.confirm().crediti : 0));
        let creditiSum = (crediti != 0 ? crediti.filter(c => {return c.WGC_Invia_Credito__c;}).reduce((start, c) => {return start += (c.ValoreNominale__c ? parseFloat(c.ValoreNominale__c) : 0);}, 0) : 0);
        //SM - CR FastFinance - Parametro C138
        let creditiC138 = 0;
        let numeratoreC138 = 0;
        let denominatoreC138 = 0;

        if(crediti != 0){
            crediti.filter(c => { return c.WGC_Invia_Credito__c; }).forEach(c => {
                numeratoreC138 += ( c.WGC_Commissione_acquisto__c != undefined && c.WGC_Commissione_acquisto__c != null && c.WGC_Commissione_acquisto__c != "") ? c.WGC_Val_Nom_Esigibile__c * c.WGC_Commissione_acquisto__c : 0;
                denominatoreC138 += c.WGC_Val_Nom_Esigibile__c;
            });

            if(denominatoreC138 > 0)
                creditiC138 = parseFloat((numeratoreC138 / denominatoreC138).toFixed(3));

        }

        window.creditiValues = JSON.parse('{"IMPORTI_CREDITI":' + creditiSum + ', "RAPPORTO_CREDITI":' + creditiC138 + '}');
        // window.creditiC138 = JSON.parse('{ "" : ' + creditiC138 + '}');
        console.log("window.creditiValues: ", window.creditiValues);
    },

    manageSolaDerogaReadonly : function(parameters, activeLine, joinFidiCoppia) {
        let paramCodes = ["008","SF24","SF25","SF26"];
        // let activeLine = ( lines.find(l => {return l.isActive;}) != undefined ? lines.find(l => {return l.isActive;}) : lines.filter(l => {return l.multiLine && l.subLines.length > 0;}).subLines.find(sl => {return sl.isActive;}).line );

        parameters.forEach(s => {
            s.parameters.filter(p => {
                return p.soloDeroga && paramCodes.includes(p.codice) && activeLine && activeLine.isRevisione;
            }).forEach(p => {
                let jla = joinFidiCoppia.find(j => {
                    return j.debitore == p.debitore && j.linea == activeLine.id;
                });

                if (jla)
                    p.readonly = jla.codTipoCar == "G";
            });
        });
    },

    removeDuplicatedParameters : function(parameters) {
        let hiddenParams = [], visibleParams = [];

        parameters.forEach(s => {
            hiddenParams = hiddenParams.concat(s.parameters.filter(p => {return !p.isVisible}).map(p => {return p.codice}));
            visibleParams = visibleParams.concat(s.parameters.filter(p => {return p.isVisible}).map(p => {return p.codice}));
        });

        hiddenParams.forEach(hp => {
            if (visibleParams.includes(hp) && parameters)
                parameters = parameters.forEach(s => {return s.parameters = s.parameters.filter(p => {return p.codice != hp || p.isVisible})});
        });
    },

    // FUNCTION TO EVALUATE THE VISIBILITY OF PARAMETERS BASED ON FIELD "ParametroProdotto__c.FormulaDiControllo__c"
    evalParamsVisibility : function(parameters, selectedLineId) {

        parameters.forEach(s => {
        // for (var p in parameters) {
            var visibleParams = [];

            
            s.parameters.forEach(e => {
            // for (var e in s.parameters) {
                e.isShowing = (selectedLineId != null && selectedLineId != undefined && selectedLineId != '') ? (e.linea == selectedLineId) : true;
                if (e.formulaControllo != null && (e.formulaControllo.includes("VV_") || e.formulaControllo.includes("LL_"))) {
                    var formula = e.formulaControllo.replace(/VV_/g, "params.VV_").replace(/LL_/g, "lineaFlags.").replace(/CC_/g, "creditiValues.");
                    console.log(e.codice + " --val: " + e.value + " -- " + formula + " --eval: " + eval(formula));
                    if (eval(formula))
                        e.isVisible = true;
                    else
                        e.isVisible = false;
                }
                else if (e.formulaControllo == null) {
                    e.isVisible = true;
                }
                else
                    e.isVisible = false;
            });
            // }
            if (visibleParams.length > 0) {
                s.parameters = visibleParams;
                visibleSections.push(s);
            }
        });
        // }
        return parameters;
    },

    // FUNCTION TO EVALUATE THE DEFAULT VALUE OF PARAMETERS BASED ON FIELD "ParametroProdotto__c.Default__c"
    evalFormulaDefaultValues : function(parameters) {
        parameters.forEach(s => {
        // for (var p in parameters) {
            var visibleParams = [];

            s.parameters.forEach(e => {
            // for (var e in s.parameters) {
                if (e.defaultval != null && (e.value == null || e.readonly) && e.defaultval.startsWith("$") && !e.isFixedValue) {
                    var formula = e.defaultval.substring(2, e.defaultval.length-1).replace(/VV_/g, "params.VV_").replace(/LL_/g, "lineaFlags.").replace(/DD_/g, "derogaFields.D_" + e.debitore + "_").replace(/CC_/g, "creditiValues.");
                    console.log(e.codice + " --val: " + e.value + " -- " + formula);
                    console.log(e.codice + " --val: " + e.value + " -- " + formula + " --eval: " + eval(formula));
                    e.value = eval(formula);
                    if ((typeof e.value == "array" || typeof e.value == "object") && e.value != null) {
                        e.value = e.value.find(x => {return x.debitore == e.debitore;}) ? e.value.find(x => {return x.debitore == e.debitore;}).value : null;
                    }
                    if (typeof e.value == "boolean")
                        e.value = e.value.toString();
                }
                else if (e.defaultval == null) {
                    e.isVisible = true;
                }
                else
                    e.isVisible = false;
            });
            // }
            if (visibleParams.length > 0) {
                s.parameters = visibleParams;
                visibleSections.push(s);
            }
        });
        // }
        return parameters;
    },

    resetDefaultValue : function(parameters) {
        parameters.forEach(p => {
            if (p.defaultval != null)
                if (p.defaultval.startsWith("$")) {
                    var formula = p.defaultval.substring(2, p.defaultval.length-1).replace(/VV_/g, "params.VV_").replace(/LL_/g, "lineaFlags.").replace(/DD_/g, "derogaFields.D_" + p.debitore + "_").replace(/CC_/g, "creditiValues.");
                    console.log("resetDefaultValue__" + p.codice + " --val: " + p.value + " -- " + formula + " --eval: " + eval(formula));
                    p.value = eval(formula);
                }
                else {
                    console.log("resetDefaultValue__" + p.codice + " --val: " + p.value);
                    p.value = p.defaultval;
                }
        });
    },

    changeParam : function(component, event) {
        let param = event.getParam("param");
        let codice = param.codice;
        let valore = param.value;
        let sezione = param.sezione;
        let sottosezione = param.sottosezione;
        let debitore = (param.soloDeroga ? param.debitore : null);
        let parametri = component.get("v.parametriSezioni");
        let condizioni = component.get("v.condizioniSezioni");
        let allParams = parametri.concat(condizioni);
        let items = component.get("v.items");
        let selectedLineId;
        let selectedDeb = component.get("v.selectedDeb");
        let hiddenParams = [];
        let creditiWrapper = component.find("creditiWrapper");
// console.log("allParams: ", allParams);
// console.log("codice: ", codice);
// console.log("valore: ", valore);
// console.log("sezione: ", sezione);
// console.log("sottosezione: ", sottosezione);
// console.log("parametri: ", parametri);
        
        // let paramSection = parametri.find(s => {return (s.code == sezione || s.code == sottosezione);});
        let paramSection = parametri.find(s => {return (sottosezione ? s.code == sottosezione : s.code == sezione);});
        // let condSection = condizioni.find(s => {return (s.code == sezione || s.code == sottosezione);});
        let condSection = condizioni.find(s => {return (sottosezione ? s.code == sottosezione : s.code == sezione);});
        
        if (paramSection != undefined) {
            let paramsParams = paramSection.parameters.find(p => {
                if (selectedDeb || param.soloDeroga)
                    return p.codice == codice && p.debitore == (param.soloDeroga ? debitore : selectedDeb);
                else
                    return p.codice == codice;
            });
// console.log("paramSection.parameters: ", paramSection.parameters);
            if (paramsParams != undefined)
                paramsParams.value = valore;
            else
                paramSection.parameters.find(p => {return p.codice == codice;}).value = valore;
        } else {
            let condParams = condSection.parameters.find(p => {
                if (selectedDeb || param.soloDeroga)
                    return p.codice == codice && p.debitore == (param.soloDeroga ? debitore : selectedDeb);
                else
                    return p.codice == codice;
            });

            if (condParams != undefined)
                condParams.value = valore;
            else
                condSection.parameters.find(p => {return p.codice == codice;}).value = valore;
        }
        // console.log("paramSection.parameters: ", paramSection.parameters);
        items.forEach(i => {
            if (i.subLines.length > 0) {
                i.subLines.forEach(sl => {
                    if (sl.isActive) {
                        sl.isCompleted = false;
                        selectedLineId = sl.line.id;
                    }
                });
            } else {
                if (i.isActive) {
                    i.isCompleted = false;
                    selectedLineId = i.lineId;
                }
            }
        });
// console.log("allParams: ", allParams);
        this.initializeParamsVariables(allParams);
        // this.initializeCreditiVariables(component);

        // RISOLVE LA FORMULA PER IL VALORE DI DEFAULT
        this.evalFormulaDefaultValues(parametri);
        this.evalFormulaDefaultValues(condizioni);
        
        // SETTA IL FLAG DI VISIBILITA' DEI PARAMETRI
        this.evalParamsVisibility(parametri, selectedLineId);
        this.evalParamsVisibility(condizioni, selectedLineId);

        // RIMUOVE PARAMETRI DUPLICATI, LASCIANDO SOLO IL PARAMETRO VISIBILE
        this.removeDuplicatedParameters(parametri);
        this.removeDuplicatedParameters(condizioni);
        
        parametri.forEach(s => { hiddenParams = hiddenParams.concat(s.parameters.filter(p => {return p.isShowing && !p.isVisible;}).map(p => {return p.codice;})); });
        condizioni.forEach(s => { hiddenParams = hiddenParams.concat(s.parameters.filter(p => {return p.isShowing && !p.isVisible;}).map(p => {return p.codice;})); });

        // RESETTA IL VALORE DI DEFAULT PER I PARAMETRI NON VISIBILI
        parametri.forEach(s => {
            this.resetDefaultValue(s.parameters.filter(p => {return (p.isShowing && !p.isVisible) || hiddenParams.includes(p.codice);}));
        });
        condizioni.forEach(s => {
            this.resetDefaultValue(s.parameters.filter(p => {return (p.isShowing && !p.isVisible) || hiddenParams.includes(p.codice);}));
        });
        
        // ORDINA LE SEZIONI, FILTRA I PARAMETRI NON VISIBILI
        parametri = this.sortSections(parametri).filter(function(s) { return s.parameters.filter(function(p){return p.isShowing && p.isVisible;}).length > 0; } );
        condizioni = this.sortSections(condizioni).filter(function(s) { return s.parameters.filter(function(p){return p.isShowing && p.isVisible;}).length > 0; } );

        // SPOSTAMENTO IN FONDO DEI PARAMETRI "SOLODEROGA"
        parametri.forEach(p => { p.parameters = this.sortParameters(p.parameters); });
        condizioni.forEach(p => { p.parameters = this.sortParameters(p.parameters); });
        // console.log("parametri: ", parametri);
        component.set("v.parametriSezioni", parametri);
        component.set("v.condizioniSezioni", condizioni);
        component.set("v.showNext", false);
        component.set("v.items", items);
    },

    isLineCompleted : function(component, lineId, configurazioni) {
        let completed = false;
        var configurazioneLinee = (configurazioni ? configurazioni : component.get("v.payload").configurazioneLinee);
        // var parametriEConfigurazioniLinee = component.get("v.parametriEConfigurazioniLinee");
        let parametriPerLineaDebitore = component.get("v.parametriPerLineaDebitore");
        let isRevisione = component.get("v.payload").linee.find(l => {return l.id == lineId;}).isRevisione;
        let codiceLinea = component.get("v.payload").linee.find(l => { return l.id == lineId;}).codice;

        if (parametriPerLineaDebitore) {
            if (parametriPerLineaDebitore.get(lineId) != null && parametriPerLineaDebitore.get(lineId) != undefined) {
                let params = [];

                if (parametriPerLineaDebitore.get(lineId).parametri.length > 0)
                    parametriPerLineaDebitore.get(lineId).parametri.forEach(p => {
                        if (p.parameters.length > 0)
                            params = params.concat(p.parameters);
                    });
                if (parametriPerLineaDebitore.get(lineId).condizioni.length > 0)
                    parametriPerLineaDebitore.get(lineId).condizioni.forEach(c => {
                        if (c.parameters.length > 0)
                            params = params.concat(c.parameters);
                    });

                params = params.filter(function(p){return p.isVisible && p.obbligatorio;});
                console.log("params: ", JSON.stringify(params));
                if (parametriPerLineaDebitore.get(lineId).parametri.length > 0 || parametriPerLineaDebitore.get(lineId).condizioni.length > 0) {
                    completed = params.length > 0;
                    completed = completed && params.reduce(function(start, p) {
                        if (isRevisione && p.codice.startsWith("SF")) return start;
                        let value = (configurazioneLinee.find(cl => {return cl.codice == p.codice && cl.linea == p.linea && (p.soloDeroga ? cl.attore == p.debitore : true);}) ? 
                                     configurazioneLinee.find(cl => {return cl.codice == p.codice && cl.linea == p.linea && (p.soloDeroga ? cl.attore == p.debitore : true);}).valore != null : false);
                        // if (p.codice.startsWith("M")) debugger;
                        return start && value;
                    }, true);

                    if(codiceLinea == 'SBF'){
                        var isCompletedCondizioniBC = this.checkCondizioniBC(component);
                        completed = completed && isCompletedCondizioniBC;
                    }
                }
            }
        }
        console.log("LINEID: ", lineId);
        console.log("COMPLETED: ", completed);
        return completed;
    },

    icarManualiCompleted : function(component, lineId) {
        let debitoriPerLinea = component.get("v.debitoriPerLinea");
        let icarManuali = component.get("v.payload").configurazioneIcarManuali;
        let icarDebs = icarManuali.map(im => {return im.debitore;});
        let items = component.get("v.items");
        let completed = true;
        
        items.forEach(i => {
            if (i.icarManuali == true) {
                if (i.subLines.length > 0) {
                    i.subLines.forEach(sl => {
                        if (lineId == null || sl.line.id == lineId) {
                            completed = completed && (debitoriPerLinea.find(dpl => {return dpl.linea == sl.line.id}) ? debitoriPerLinea.find(dpl => {return dpl.linea == sl.line.id}).debitori.reduce((start, d) => {return start && icarDebs.includes(d) && icarManuali.find(im => {return im.debitore == d && im.linea == sl.line.id}).icarManuali.length > 0;}, completed) : false);
                        }
                    });
                } else {
                    if (lineId == null || i.lineId == lineId) {
                        completed = completed && (debitoriPerLinea.find(dpl => {return dpl.linea == i.lineId}) ? debitoriPerLinea.find(dpl => {return dpl.linea == i.lineId}).debitori.reduce((start, d) => {return start && icarDebs.includes(d) && icarManuali.find(im => {return im.debitore == d && im.linea == i.lineId}).icarManuali.length > 0;}, completed) : false);
                    }
                }
            }
        });

        return completed;
    },

    creditiCompleted : function(component) {
        let creditiWrapper = component.find("creditiWrapper");
        let completed = (creditiWrapper != null && creditiWrapper != undefined ? false : true);
        let simone = creditiWrapper ? creditiWrapper.confirm().isAllCompleted : "NOT_VALUABLE";
        console.log("SIMONE: ", simone);
        let isAllCompleted = (completed ? completed : simone);

        return isAllCompleted; /*
        let creditiWrapper = component.find("creditiWrapper");
        let completed = (creditiWrapper != null && creditiWrapper != undefined ? false : true); // SE creditiWrapper VALORIZZATO, ALLORA completed != TRUE

        return (completed ? completed : creditiWrapper.confirm().isAllCompleted); // SE completed == TRUE, ALLORA TRUE, ALTRIMENTI confirm().isAllCompleted
        */
    },

    refreshItems : function(component) {
        let items = component.get("v.items");
        let debitoriPerLinea = component.get("v.debitoriPerLinea");
        let selectedLineId;
        let pfi = component.get("v.payload").pfi;
        let icarManuali = component.get("v.payload").configurazioneIcarManuali;
        let lineHasIcarManuali, lineHasCrediti, activeLine;
console.log("icarManuali: ", icarManuali);
        items.forEach(i => {
            let hasNoParams = i.codice == "Fido" || i.codice == "Standard" || i.codice == 'StandByLetter' || i.codice == 'CreditoDocumentarioExport' || i.codice == 'CreditoDocumentarioImport' || i.codice == 'DocumentateIncasso';

            if (i.subLines.length > 0) {
                i.subLines.forEach(sl => {
                    let alreadyCompleted = sl.line.codice == "SolaGestioneIVA" || sl.line.codice == "NotNotSenzaAnticipazioneIVA";

                    sl.subtitle = this.getLineSubtitle(component, sl.line);
                    if (sl.isActive) {
                        console.log("alreadyCompleted: ", alreadyCompleted);
                        console.log("isLineCompleted: ", this.isLineCompleted(component, sl.line.id));
                        console.log("icarManualiCompleted: ", this.icarManualiCompleted(component, sl.line.id));
                        console.log("creditiCompleted: ", this.creditiCompleted(component));
                        lineHasCrediti = sl.line.hasCrediti;
                        sl.isCompleted = alreadyCompleted || (this.isLineCompleted(component, sl.line.id) && this.icarManualiCompleted(component, sl.line.id) && this.creditiCompleted(component));
                        selectedLineId = sl.line.id;
                        activeLine = JSON.parse(JSON.stringify(sl.line));
                    }
                });
                i.debitori = (
                    debitoriPerLinea.find(dpl => {return i.subLines.map(sl => {return sl.line.id}).includes(dpl.linea);}) ?
                    debitoriPerLinea.find(dpl => {return i.subLines.map(sl => {return sl.line.id}).includes(dpl.linea);}).debitori.length : 0);
                i.isCompleted = i.subLines.reduce((start, sl) => {return start && sl.isCompleted;}, true);
            }
            else {
                if (!i.isDisabledRevLine && i.isActive) {
                    console.log("isLineCompleted: ", this.isLineCompleted(component, i.lineId));
                    console.log("icarManualiCompleted: ", this.icarManualiCompleted(component, i.lineId));
                    console.log("creditiCompleted: ", this.creditiCompleted(component));
                    i.isCompleted = (hasNoParams ? true : this.isLineCompleted(component, i.lineId) && this.icarManualiCompleted(component, i.lineId)) && this.creditiCompleted(component);

                    //SM - TEN: Banca Corporate - Controllo sulle condizioni economiche veicolate
                    if(i.codice == 'SBF'){
                        var isCompleted = this.checkCondizioniBC(component, i.lineId);
                        i.isCompleted = i.isCompleted && isCompleted;
                    }
                }
                i.debitori = (debitoriPerLinea.find(dpl => {return dpl.linea == i.id;}) ? debitoriPerLinea.find(dpl => {return dpl.linea == i.id;}).debitori.length : 0);
                i.subtitle = this.getLineSubtitle(component, i);
            }

            if (i.isActive) {
                selectedLineId = i.id;
                lineHasIcarManuali = i.icarManuali;
                lineHasCrediti = i.hasCrediti;
                activeLine = JSON.parse(JSON.stringify(i));
            }
        });

        component.set("v.items", items);
        component.set("v.showNext", items.reduce(function(start, i) {return start && i.isCompleted;}, true));
        component.set("v.lineHasIcarManuali", lineHasIcarManuali);
        component.set("v.lineHasCrediti", lineHasCrediti);
        component.set("v.activeLine", activeLine);
        // console.log("isAvailableMultiple: ", (debitoriPerLinea.find(dpl => { return dpl.linea == selectedLineId; }) ? (debitoriPerLinea.find(dpl => { return dpl.linea == selectedLineId; }).debitori.length > 1 && component.get("v.items").find(i => {return i.id == selectedLineId;}).isCompleted ) : false));
        component.set("v.isAvailableMultipleConfDebPerLine",
        (debitoriPerLinea.find(dpl => { return dpl.linea == selectedLineId; }) ? (debitoriPerLinea.find(dpl => { return dpl.linea == selectedLineId; }).debitori.length > 1 && (component.get("v.items").find(i => {return i.id == selectedLineId;}) != undefined ? component.get("v.items").find(i => {return i.id == selectedLineId;}).isCompleted : component.get("v.items").find(i => {return i.subLines > 0 && i.subLines.find(sl => {return sl.line.id == selectedLineId;}).isCompleted;})) ) : false));

    },

    reloadAvailableDebs : function(component) {
        let selectedLineId = component.get("v.items").find(i => {return i.isActive;}).id;
        let allDebitori = component.get("v.payload").debitori;
        let debitoriPerLinea = component.get("v.debitoriPerLinea").find(dpl => {return dpl.linea == selectedLineId}).debitori;
        let availableDebs = allDebitori.filter(d => {return debitoriPerLinea.includes(d.id);});

        component.set("v.availableDebs", availableDebs);
    },

    setupIcarManuali : function(component) {
        let icarManuali = JSON.parse(JSON.stringify(component.get("v.payload").configurazioneIcarManuali));
        // let icarManualiValues = [];
        let selectedLine = (this.getActiveLine(component) ? this.getActiveLine(component).id : null);
        let debitori = component.get("v.payload").debitori;
        let debitoriPerLinea = (component.get("v.debitoriPerLinea").find(dpl => {return dpl.linea == selectedLine;}) ? component.get("v.debitoriPerLinea").find(dpl => {return dpl.linea == selectedLine;}).debitori : []);
        let debitoriOptions = [];

        debitoriPerLinea.forEach(d => {
            if (debitori.find(dd => {return dd.id == d;}))
                debitoriOptions.push({
                    value: d,
                    label: debitori.find(dd => {return dd.id == d;}).rsociale
                });
        });

        let icarManualiOptions = [
            {type: "select", name: "debitore", label: "Debitore", order: 1, options: debitoriOptions},
            {type: "date", name: "dataEmissioneDa", label: "Data emissione da", order: 2, visible: true},
            {type: "date", name: "dataEmissioneA", label: "Data emissione a", order: 3, visible: true},
            {type: "number", name: "numeroFatturaDa", label: "Numero fattura da", order: 4, visible: false},
            {type: "number", name: "numeroFatturaA", label: "Numero fattura a", order: 5, visible: false},
            {type: "number", name: "annoFatturatoDa", label: "Anno fatturato da", order: 6, visible: false},
            {type: "number", name: "annoFatturatoA", label: "Anno fatturato a", order: 7, visible: false}
        ];

        icarManuali = icarManuali.filter(im => {return im.linea == selectedLine && im.icarManuali.length > 0;});
        // icarManuali.forEach(im => {
        //     let debitore = im.debitore;

        //     im.icarManuali.forEach(imv => {
        //         let dataEmissioneDa = (imv.dataEmissioneDa ? new Date(imv.dataEmissioneDa) : null);
        //         let dataEmissioneA = (imv.dataEmissioneA ? new Date(imv.dataEmissioneA) : null);
        //         icarManualiValues.push({
        //             "debitore": debitore,
        //             "dataEmissioneDa": (!this.isBlank(dataEmissioneDa) ? dataEmissioneDa.getFullYear() + "-" + (dataEmissioneDa.getMonth()+1) + "-" + dataEmissioneDa.getDate() : null),
        //             "dataEmissioneA": (!this.isBlank(dataEmissioneA) ? dataEmissioneA.getFullYear() + "-" + (dataEmissioneA.getMonth()+1) + "-" + dataEmissioneA.getDate() : null),
        //             "numeroFatturaDa": imv.numeroFatturaDa,
        //             "numeroFatturaA": imv.numeroFatturaA,
        //             "annoFatturatoDa": imv.annoFatturatoDa,
        //             "annoFatturatoA": imv.annoFatturatoA,
        //         });
        //     });
        // });

        // component.set("v.icarManualiValues", icarManualiValues);
        component.set("v.icarManuali", icarManuali);
        component.set("v.icarManualiOptions", icarManualiOptions);
    },

    checkForRevisionedLine : function(component) {
        let payload = component.get("v.payload");
        if (payload) {
            let lines = payload.linee;
            let selectedLineId = (this.getActiveLine(component) ? this.getActiveLine(component).id : null);
    // console.log("REVI --selectedLine: ", lines.find(l => {return l.id == selectedLineId;}));
            if (selectedLineId && lines.find(l => {return l.id == selectedLineId;})) {
                let hasParameters = payload.configurazioneLinee.filter(cl => {return cl.linea == selectedLineId}).length > 0;
    // console.log("REVI --hasParameters: ", hasParameters);
                if (lines.find(l => {return l.id == selectedLineId;}).isRevisione && !hasParameters) {
                    let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
                    appEvent.setParams({ "method" : "c.getRevisionedParameters" , "params" : { lineId: selectedLineId }, "lockStateSpinner" : true , "spinnerMessage" : "Recupero parametri in corso.." });
                    appEvent.fire();
                }
            }
        }
    },

    setupRevisioneFlag : function(component) {
        let lines = component.get("v.payload").linee;
        let selectedLineId = (this.getActiveLine(component) ? this.getActiveLine(component).id : null);

        component.set("v.isRevisionedLine", lines.find(l => {return l.id == selectedLineId;}).isRevisione);
    },

    fixParametriMutuo : function(payload) {
        payload.configurazioneLinee.forEach(cl => { 
            //A.M. Generalizzata la scrittura del parametro "durata" per i mutui 
            //if (cl.codice == "M06_8509" || cl.codice == "M2105_8509" || cl.codice == "M2104_8509" || cl.codice == "M2106_8509" || cl.codice == "M2110_8509" || cl.codice == "M2112_8509"){
            if (cl.codice.endsWith ("_8509")){
            	let linea = payload.pb.find(l => {return l.id == cl.linea;});
            	cl.valore = linea.preAmmortamento == true ? linea.durataAmmortamento : linea.durata;
        	} 
            //A.M. Generalizzata la scrittura del parametro "importo" per i mutui
            //if (cl.codice == "M06_8505" || cl.codice == "M2105_8505" || cl.codice == "M2104_8505" || cl.codice == "M2106_8505" || cl.codice == "M2110_8505" || cl.codice == "M2112_8505")
            if (cl.codice.endsWith ("_8505"))
                cl.valore = payload.pb.find(l => {return l.id == cl.linea;}).importo;
        });
        return payload;
    },

    refreshLineCompletion : function(component) {
        let items = component.get("v.items");

        items.forEach(i => {
            let hasNoParams = i.codice == "Fido" || i.codice == "Standard";

            if (i.subLines.length > 0) {
                i.subLines.forEach(sl => {
                    let alreadyCompleted = sl.line.codice == "SolaGestioneIVA" || sl.line.codice == "NotNotSenzaAnticipazioneIVA";

                    sl.subtitle = this.getLineSubtitle(component, sl.line);
                    if (sl.isActive) {
                        console.log("alreadyCompleted: ", alreadyCompleted);
                        console.log("isLineCompleted: ", this.isLineCompleted(component, sl.line.id));
                        console.log("icarManualiCompleted: ", this.icarManualiCompleted(component, sl.line.id));
                        console.log("creditiCompleted: ", this.creditiCompleted(component));
                        sl.isCompleted = alreadyCompleted || (this.isLineCompleted(component, sl.line.id) && this.icarManualiCompleted(component, sl.line.id) && this.creditiCompleted(component));
                    }
                });
                i.isCompleted = i.subLines.reduce((start, sl) => {return start && sl.isCompleted;}, true);
            }
            else {
                if (!i.isDisabledRevLine && i.isActive) {
                    console.log("isLineCompleted: ", this.isLineCompleted(component, i.lineId));
                    console.log("icarManualiCompleted: ", this.icarManualiCompleted(component, i.lineId));
                    console.log("creditiCompleted: ", this.creditiCompleted(component));
                    i.isCompleted = (hasNoParams ? true : this.isLineCompleted(component, i.lineId) && this.icarManualiCompleted(component, i.lineId)) && this.creditiCompleted(component);

                    //SM - TEN: Banca Corporate - Controllo sulle condizioni economiche veicolate
                    if(i.codice == 'SBF'){
                        var isCompleted = this.checkCondizioniBC(component, i.lineId);
                        i.isCompleted = i.isCompleted && isCompleted;
                    }
                }
            }
        });

        component.set("v.items", items);
        component.set("v.showNext", items.reduce(function(start, i) {return start && i.isCompleted;}, true));
    },
    
    reloadReadOnlyForFactFisc : function(component) {
        let readOnly = component.get("v.readOnly");
        let readOnlyConst = component.get("v.readOnlyConst");
        let currentUser = component.get("v.currentUser");
        let activeLine = this.getActiveLine(component);
        let factFiscCodes = ["SolaGestioneIVA","NotNotSenzaAnticipazioneIVA","FactoringOrdinarioFiscale","FactoringOrdinarioFiscaleNotNot","ATDFiscale","ATDFiscaleNotNot"];

        console.log('READONLY CONF: ' , (currentUser.Profile.Name == "IFIS - B/O Valutazione Fast Finance" && !factFiscCodes.includes(activeLine.codice) || readOnlyConst));
        component.set("v.readOnly", (currentUser.Profile.Name == "IFIS - B/O Valutazione Fast Finance" && !factFiscCodes.includes(activeLine.codice) ) || readOnlyConst);
	},
    // wizardCompletato : function(component) {
    //     let allItemsCompleted = component.get("v.items").reduce(function(start, i) {return start && i.isCompleted;}, true);
    //     let oppId = component.get("v.payload").opportunityId;
    //     let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
    //     appEvent.setParams({ "method" : "c.updateWizardCompletato" , "params": {"oppId" : oppId , "wizardCompleto" : allItemsCompleted} });
    //     appEvent.fire();
    // }
	
    setupReadOnlyConst : function(component){
    	component.set("v.readOnlyConst",component.get("v.readOnly"));        
    },

    setupBtnCorporate : function(component, event, helper){
        // let pLines = component.get("v.payload.pbc");
        // console.log('@@@ pLines ' , pLines);
        let lines = component.get("v.items");
        let checkSBF = /*checkSBF &&*/ lines.find(l => { return ( l.codice == 'SBF' && l.isActive ); }) != undefined;

        component.set("v.isSBF", checkSBF);

        if(checkSBF)
            helper.getParametriBC(component, event, helper);

        //SM - TEN: Aggiunti prodotti Corporate Estero
        let checkCorporateProds = lines.filter(l => { return (l.codice == 'SBF' /*|| l.codice == 'GestionePTF'*/ || l.codice == 'AnticipoFatture' || 
                                                            l.codice == 'AnticipoExport' || l.codice == 'FinanziamentoExport' || l.codice == 'FinanziamentoImport'); }).length > 0;
        component.set("v.isCorporate", checkCorporateProds);
    },

    checkCondizioniBC : function(component, idLinea){
        var metadatoCondizioni = component.get("v.metadatoCondizioni");
        var lines = component.get("v.payload.linee");
        var parametriLinee = component.get("v.payload.configurazioneLinee");

        var mappaCondizioni = new Map();
        // if(metadatoCondizioni.length > 0){
            metadatoCondizioni.forEach(c => { 
                var linesOut = c.Output__c.split(';');
                linesOut.forEach(lo => {
                    var lineId = lines.find(ll => { return ll.codice == lo; }) != undefined ? lines.find(ll => { return ll.codice == lo; }).id : lines.find(ll => { return ll.codice == 'SBF'}) != undefined ? lines.find(ll => { return ll.codice == 'SBF'}).id : undefined;
                    if(lineId != undefined)
                        mappaCondizioni.set(lineId, c.Codice_Condizione__c);
                });
            });
        // }
        parametriLinee = parametriLinee.filter(p => { return mappaCondizioni.has(p.linea) && mappaCondizioni.get(p.linea) == p.codice });
        //Controllo le condizioni per poter saltare il controllo di completezza nel caso in cui non venga aperta la modale dello spread
        var check = parametriLinee.length > 0 && mappaCondizioni.size > 0;

        if(check != false){
            check = parametriLinee.reduce((start, p) => {
                return start && p.valore != undefined && p.valore != null && p.valore != ''
            }, true);
        }

        return check;
        // parametriLinee.filter()
    },

    //SM - TEN: Funzione per eliminare la condizione spread veicolata sul conto dall'sbf nel caso in cui venga eliminato l'sbf dalla pratica
    fixCondizioniSBF : function(component, parametri){
        var existSBF = component.get("v.payload.linee").find(l => { return l.codice == 'SBF'});
        var sbfLine = component.get("v.payload.pbc").find(l => { return l.tipo == 'SBF'});
        var ccLines = component.get("v.payload.linee").find(l => { return l.codice == 'IfisImpresa' || l.codice == 'IfisImpresaNonAffidato'});
        if(sbfLine == undefined && ccLines != undefined){
            parametri = parametri.filter(p => { return !(p.codice == 'CDA02_1053' && p.linea == ccLines.id); });
        // } else if(sbfLine != undefined && sbfLine.tipologiaConto == 'Conto Unico'){
        //     parametri = parametri.filter(p => { return !(p.codice == 'CDA02_1053' && p.linea == ccLines.id); });
        } else if(sbfLine != undefined && sbfLine.tipologiaConto == 'Conto Doppio' && ccLines != undefined){
            parametri = parametri.filter(p => { return !(p.codice == 'CDA02_1053' && p.linea == ccLines.id); });
        }

        return parametri;
    },
})