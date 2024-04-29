({
    loadDati : function(component) {
        let elencoLineeNuovaConcessione = [];
        let elencoLineeConsultazione = [];
        let elencoLineeRevisione = [];
        let elencoLinee = [];
        let elencoNote = [];
        let datiCartella = {};
        let datiPEF = component.get("v.datiPEF");
        let factoringProducts = component.get("v.factoringProducts");
        let importi = component.get("v.importi");
        let linee = component.get("v.linee");
        let lineeChiuse = component.get("v.lineeChiuse");
        let opportunity = component.get("v.opportunity");
        let factFiscCodes = ['744','844','534','644','364','464'];
        
        datiPEF.forEach(d => {
            if (d.elencoLineeCredito != undefined && d.elencoLineeCredito != null) {
                d.elencoLineeCredito.forEach(elc => {
                    if (elc.codGestione == "N")
                        elencoLineeNuovaConcessione.push(elc);
                    if (elc.codGestione == "C")
                        elencoLineeConsultazione.push(elc);
                    if (elc.codGestione == "R")
                        elencoLineeRevisione.push(elc);
                });

                if (opportunity.Tipologia_Opportunit__c == "CONC")
                    elencoLinee = elencoLineeNuovaConcessione;
                else if (opportunity.Tipologia_Opportunit__c == "REVI")
                    elencoLinee = elencoLineeNuovaConcessione.concat(elencoLineeRevisione);
                else if (opportunity.Tipologia_Opportunit__c == "RINN")
                    elencoLinee = elencoLineeRevisione;

                elencoLinee.forEach(el => {
                    let isFactoring = (factoringProducts.includes(el.codLineaSistema));
                    let isClosed = (lineeChiuse.map(lc => {return lc.Codice_Linea__c;}).includes(el.numLineaCredito.toString()));

                    el.isFactoring = isFactoring;
                    el.isClosed = isClosed;
                    
                    if ((isFactoring || factFiscCodes.includes(el.codLineaSistema)) && importi.find(l => {return l.Linea__r.Prodotto__r.Codice__c == el.codLineaSistema;}))
                        el.importoProposto = importi.find(l => {return l.Linea__r.Prodotto__r.Codice__c == el.codLineaSistema;}).Valore__c;
                    else
                        el.importoProposto = (linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;}) ? linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;}).Importo__c : 0);
                        // (importi.find(i => {return i.Linea__r.Prodotto__r.Codice__c == el.codLineaSistema;}) ? importi.find(l => {return l.Linea__r.Prodotto__r.Codice__c == el.codLineaSistema;}).Valore__c : linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;}).Importo__c);

                    if (linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;})) {
                        el.stato = linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;}).Stato__c;
                        el.deliberata = linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;}).WGC_Deliberata__c;
                        el.nonDeliberata = linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;}).WGC_Non_Deliberata__c;
                        el.dataDelibera = linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;}).WGC_Data_Delibera__c;
                        el.dataDeclinazione = linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;}).WGC_Data_Declinazione__c;
                        el.dataContrattiPronti = linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;}).WGC_Data_Contratti_Pronti__c;
                        
                        el.isClosed = isClosed || el.nonDeliberata;
                    }

                    if (isClosed) {
                        el.categoriaChiusuraTrattativa = lineeChiuse.find(lc => {return lc.Codice_Linea__c == el.numLineaCredito;}).CategoriaChiusuraTrattativa__c;
                        el.dataChiusuraLinea = lineeChiuse.find(lc => {return lc.Codice_Linea__c == el.numLineaCredito;}).Data_Chiusura_Linea__c;
                        el.faseChiusura = lineeChiuse.find(lc => {return lc.Codice_Linea__c == el.numLineaCredito;}).Fase__c;
                        el.motivoChiusuraTrattativa = lineeChiuse.find(lc => {return lc.Codice_Linea__c == el.numLineaCredito;}).MotivoChiusuraTrattativa__c;
                        el.statoPEF = lineeChiuse.find(lc => {return lc.Codice_Linea__c == el.numLineaCredito;}).Stato_PEF_pre_chiusura__c;
                    }

                    el.elencoCoppie.forEach(ec => {
                        ec.ndgDebitore = ec.ndgDebitore.toString();
                        ec.numCAR = ec.numCAR.toString();
                    });

                    console.log('@@@ coppie ' , el.elencoCoppie);
                    //Filtro i car tecnici
                    el.elencoCoppie = el.elencoCoppie.filter(ec => { console.log('@@@ cod ' , ec); return ec.codTipoCoppia != 'C'; });

                    console.log('@@@ coppie 2 ' , el.elencoCoppie);

                    // MB - TEN: CR 273 - Avanzamento stato singoli prodotti
                    el.wizardItems = this.getWizardItems(component, el, linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;}));
                    el.wizardProgressValue = this.getWizardProgressValue(el.wizardItems);
                    // MB - TEN: CR 273 - Avanzamento stato singoli prodotti
                });
                
                component.set("v.elencoLineeNuovaConcessione", elencoLineeNuovaConcessione);
                component.set("v.elencoLineeConsultazione", elencoLineeConsultazione);
                component.set("v.elencoLineeRevisione", elencoLineeRevisione);
                component.set("v.elencoLinee", elencoLinee);
            }
            if (d.elencoNote != undefined && d.elencoNote != null) {
                d.elencoNote.forEach(en => {
                    let date = new Date(en.datInserimNota);
                    try {
                        en.desTestoNota = atob(en.desTestoNota);
                    } catch (err) {
                        if (typeof en.desTestoNota == "string") en.desTestoNota = en.desTestoNota;
                    }
                    en.dataInserimento = date.getDate() + "/" + (date.getMonth()+1) + "/" + date.getFullYear();
                    elencoNote.push(en);
                });

                component.set("v.elencoNote", elencoNote);
            }
            datiCartella = d;
            component.set("v.datiCartella", datiCartella);
        });
                        
         //SM - TEN: Banca Corporate - Aggiungo Gestione PTF 
        let gestionePTF = linee.find(l => { return l.Prodotto__r.Codice__c == '983'; });
        // let isClosed = (lineeChiuse.map(lc => {return lc.Codice_Linea__c;}).includes(el.numLineaCredito.toString()));
        console.log('@@@ gestionePTF ' , gestionePTF);
        if(gestionePTF != undefined){
            let tmpGestionePTF = {};
            tmpGestionePTF.desLineaSistema = 'GESTIONE PTF DOPO INCASSO';
            // tmpGestionePTF.importoProposto = (linee.find(l => {return l.Prodotto__r.Codice__c == gestionePTF.Prodotto__r.Codice__c;}) ? linee.find(l => {return l.Prodotto__r.Codice__c == gestionePTF.Prodotto__r.Codice__c;}).Importo__c : 0);
            tmpGestionePTF.codLineaSistema = '983';
            tmpGestionePTF.isFactoring = false;
            tmpGestionePTF.isClosed = false; //Da capire come gestire
            // tmpGestionePTF.importoProposto = importi.find(l => {return l.Linea__r.Prodotto__r.Codice__c == gestionePTF.Prodotto__r.Codice__c;}).Valore__c;
            tmpGestionePTF.stato = linee.find(l => {return l.Prodotto__r.Codice__c == gestionePTF.Prodotto__r.Codice__c;}).Stato__c;
            tmpGestionePTF.deliberata = linee.find(l => {return l.Prodotto__r.Codice__c == gestionePTF.Prodotto__r.Codice__c;}).WGC_Deliberata__c;
            tmpGestionePTF.nonDeliberata = linee.find(l => {return l.Prodotto__r.Codice__c == gestionePTF.Prodotto__r.Codice__c;}).WGC_Non_Deliberata__c;
            tmpGestionePTF.dataDelibera = linee.find(l => {return l.Prodotto__r.Codice__c == gestionePTF.Prodotto__r.Codice__c;}).WGC_Data_Delibera__c;
            tmpGestionePTF.dataDeclinazione = linee.find(l => {return l.Prodotto__r.Codice__c == gestionePTF.Prodotto__r.Codice__c;}).WGC_Data_Declinazione__c;
            tmpGestionePTF.dataContrattiPronti = linee.find(l => {return l.Prodotto__r.Codice__c == gestionePTF.Prodotto__r.Codice__c;}).WGC_Data_Contratti_Pronti__c;
            
            tmpGestionePTF.isClosed = tmpGestionePTF.isClosed || tmpGestionePTF.nonDeliberata;

            tmpGestionePTF.elencoCoppie = [];

            tmpGestionePTF.wizardItems = this.getWizardItems(component, tmpGestionePTF, gestionePTF);
            tmpGestionePTF.wizardProgressValue = this.getWizardProgressValue(tmpGestionePTF.wizardItems);

            // if (tmpGestionePTF.isClosed) {
            //     tmpGestionePTF.categoriaChiusuraTrattativa = lineeChiuse.find(lc => {return lc.Codice_Linea__c == el.numLineaCredito;}).CategoriaChiusuraTrattativa__c;
            //     tmpGestionePTF.dataChiusuraLinea = lineeChiuse.find(lc => {return lc.Codice_Linea__c == el.numLineaCredito;}).Data_Chiusura_Linea__c;
            //     tmpGestionePTF.faseChiusura = lineeChiuse.find(lc => {return lc.Codice_Linea__c == el.numLineaCredito;}).Fase__c;
            //     tmpGestionePTF.motivoChiusuraTrattativa = lineeChiuse.find(lc => {return lc.Codice_Linea__c == el.numLineaCredito;}).MotivoChiusuraTrattativa__c;
            //     tmpGestionePTF.statoPEF = lineeChiuse.find(lc => {return lc.Codice_Linea__c == el.numLineaCredito;}).Stato_PEF_pre_chiusura__c;
            // }

            console.log('@@@ tmpGestionePTF ' , tmpGestionePTF);
            elencoLinee.push(tmpGestionePTF);
        }

        component.set("v.elencoLinee", elencoLinee);
        
    },

    initDataTable : function(component) {
        let cols = [
            {label: "Debitore", fieldName: "ragSocDebitore", type: "text"},
            {label: "Stato", fieldName: "desStatoCoppia", type: "text"},
            {label: "Importo Prosolvendo", fieldName: "impAccordatoCoppia", type: "currency"},
            {label: "Importo Prosoluto", fieldName: "impProsolutoCoppia", type: "currency"},
            // {label: "Cod. Tipo Coppia", fieldName: "codTipoCoppia", type: "text"},
            {label: "Cod. Gestione", fieldName: "codGestione", type: "text"},
            // {label: "Inizio Validit&agrave;", fieldName: "dataInizioValidita", type: "date"},
            // {label: "Anno Fattura Da", fieldName: "annoFatturaDa", type: "text"},
            // {label: "Anno Fattura A", fieldName: "annoFatturaA", type: "text"},
            // {label: "Num. Fattura Da", fieldName: "numeroFatturaDa", type: "text"},
            // {label: "Num. Fattura A", fieldName: "numeroFatturaA", type: "text"},
            // {label: "Data Emissione Da", fieldName: "dataEmissioneDa", type: "date"},
            // {label: "Data Emissione A", fieldName: "dataEmissioneA", type: "date"},
            // {label: "CAR", fieldName: "numCAR", type: "text"},
            // {label: "Cod. Rapporto Est.", fieldName: "codRapportoEst", type: "text"}
            // {label: "Cod. Random Coppia", fieldName: "codRandomCoppia", type: "number"}
        ];
        let colsFactFisc = [
            // {label: "Debitore", fieldName: "ragSocDebitore", type: "text"},
            {label: "Stato", fieldName: "desStatoCoppia", type: "text"},
            // {label: "Importo Prosolvendo", fieldName: "impAccordatoCoppia", type: "currency"},
            {label: "Importo Prosoluto", fieldName: "impProsolutoCoppia", type: "currency"},
            // {label: "Cod. Tipo Coppia", fieldName: "codTipoCoppia", type: "text"},
            {label: "Cod. Gestione", fieldName: "codGestione", type: "text"},
            // {label: "Inizio Validit&agrave;", fieldName: "dataInizioValidita", type: "date"},
            {label: "Anno Fattura Da", fieldName: "annoFatturaDa", type: "text"},
            {label: "Anno Fattura A", fieldName: "annoFatturaA", type: "text"},
            {label: "Num. Fattura Da", fieldName: "numeroFatturaDa", type: "text"},
            {label: "Num. Fattura A", fieldName: "numeroFatturaA", type: "text"},
        ];
        component.set("v.coppiaColumns", cols);
        component.set("v.coppiaColumnsFactFisc", colsFactFisc);
    },

    getPEF38 : function(component, event) {
        let numLinea = event.getSource().get("v.name");

        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.pef38" , "params" : {
                numLinea: numLinea,
                accountId: component.get("v.opportunity").AccountId
            }
        });
        appEvent.fire();
    },

    initDTWizardOptions : function(component) {
        let opportunity = component.get("v.opportunity");
        let dtWizardOptions = [{
            title: $A.get("$Label.c.Stato_Opp_1"), //"In Istruttoria",
            phase: "In Istruttoria",
            active: false,
            state: "completed",
            date: opportunity.WGC_Data_out_Fase_In_Istruttoria__c
        },{
            title: $A.get("$Label.c.Stato_Opp_2"),//"In Valutazione",
            phase: "Valutazione Pratica",
            active: true,
            state: "inProgress",
            date: ""
        },
        // SM - TEN CR401 - eliminazione Predisposizione Contratto
        // {
        //     title: "Predisposizione Contratto",
        //     phase: "Predisposizione Contratto",
        //     active: false,
        //     state: "",
        //     date: ""
        // },
        {
            title: $A.get("$Label.c.Stato_Opp_3"), //"Firma Contratti",
            phase: "Perfezionamento Contratto",
            active: false,
            state: "",
            date: ""
        },{
            title: $A.get("$Label.c.Stato_Opp_4"), //"Da Avviare"
            phase: "Attivazione Prodotto",
            active: false,
            state: "",
            date: ""
        }];

        component.set("v.dtWizardOptions", dtWizardOptions);
    },

    loadDTWizardItems : function(component) {
        let datiPEF = component.get("v.datiPEF");
        let linee = component.get("v.linee");
        let elencoLinee = component.get("v.elencoLinee");
        let opportunity = component.get("v.opportunity");
        let dtWizardOptions = component.get("v.dtWizardOptions");

        elencoLinee.forEach(el => {
            let dtWizardItems = dtWizardOptions.slice(0);
            let linea = linee.find(l => {return l.Prodotto__r.Codice__c == el.codLineaSistema;});
            let statoLinea = (linea ? linea.Stato__c : "");

            // if (linea)
            //     dtWizardItems.forEach(wi => {
            //         wi.active = (wi.phase == statoLinea);

            //         if (wi.phase == linea.WGC_FaseDiCaduta__c) {
            //             wi.state = "failed";
            //             wi.date = linea.WGC_DataFaseDiCaduta__c;
            //         }
            //         else if (wi.active)
            //             wi.state = "inProgress";
            //         else if (dtWizardOptions.map(wo => {return wo.phase}).indexOf(wi.phase) < dtWizardOptions.map(wo => {return wo.phase}).indexOf(statoLinea))
            //             wi.state = "completed";
            //     });

            // el.dtWizardItems = dtWizardItems;
        });

        component.set("v.elencoLinee", elencoLinee);
    },

    getWizardProgressValue : function(wizardItems) {
        let prgValue;
        
        wizardItems.forEach((wi, index) => {
            if (wi.active)
                prgValue = (index*33);
        });

        return prgValue;
    },

    getWizardItems : function(component, line, completeLine) {
        let dtWizardOptions = component.get("v.dtWizardOptions");
        let dtWizardItems = JSON.parse(JSON.stringify(dtWizardOptions));
        dtWizardItems.forEach(wi => {
            if (completeLine && wi.phase == completeLine.WGC_FaseDiCaduta__c) {
                wi.state = "failed";
                wi.date = completeLine.WGC_DataFaseDiCaduta__c;
            } else {
                switch (wi.phase) {
                    case "Valutazione Pratica":
                        if (line.nonDeliberata) {
                            wi.state = "failed";
                            wi.date = line.dataDeclinazione;
                            wi.active = false;
                        }
                        else if (line.deliberata) {
                            wi.state = "completed";
                            wi.date = line.dataDelibera;
                            wi.active = false;
                        }
                        break;
                    // SM - TEN - CR401 - eliminazione Predisposizione Contratto 
                    // case "Predisposizione Contratto":
                    //     if (line.deliberata) {
                    //         wi.state = (line.stato == "11" ? "completed" : "inProgress");
                    //         wi.date = line.dataContrattiPronti;
                    //         wi.active = (line.stato == "11" ? false : true);
                    //     }
                    //     break;
                    case "Perfezionamento Contratto":
                        if (line.stato == "11") {
                            wi.state = (completeLine.WGC_Attivata__c ? "completed" : "inProgress");
                            wi.date = completeLine.WGC_Data_Attivazione__c;
                            wi.active = !completeLine.WGC_Attivata__c;
                        }
                        break;
                    case "Attivazione Prodotto":
                        if (completeLine && completeLine.WGC_Attivata__c) {
                            wi.state = "inProgress";
                            // wi.date = completeLine.WGC_Data_Attivazione__c;
                            wi.active = true;
                        }
                        break;
                }
            }
        });

        return dtWizardItems;
    }
})