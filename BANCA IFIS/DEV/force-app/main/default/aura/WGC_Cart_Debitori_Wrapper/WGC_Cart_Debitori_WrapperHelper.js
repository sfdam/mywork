({
    setupDebitori : function(component) {
        var debitori = component.get("v.payload").debitori;
        let revisionedLinesId = component.get("v.payload").linee.filter(l => {return l.isRevisione;}).map(l => {return l.id});
        let items = component.get("v.items");
        let lockedItems = component.get("v.lockedItems");
        let servizi = component.get("v.servizi");
        let serviziMap = new Map();
        var jla = component.get("v.payload").joinLineaAttore;
        // var valutazionePortafoglio = component.get("v.payload").valutazionePortafoglio;
        var valutazioniPortafoglio = component.get("v.payload").valutazioniPortafoglio;
        // var vpTMP = [];
        servizi.forEach(ss => { serviziMap.set(ss.WGC_Famiglia__c, ss.Label); });                     
        let selectedProducts = items.concat(lockedItems).map(i => {return serviziMap.get(i.name);});
        console.log('@@@ SetUp selectedProducts: ' , selectedProducts);
        // LOOP TO CLONE ARRAY
        // for (var i = 0; i < valutazioniPortafoglio.length; i++)
        //     vpTMP.push(Object.assign({}, valutazioniPortafoglio[i]));
        let codiciCoppia = component.get("v.codiciCoppia");
        // REMOVE AUTO ADD DEBS (AGENZIA DELLE ENTRATE per FACTORING FISCALE)
        debitori = debitori.filter(d => {return !d.isFactFisc;});
        debitori.forEach(d => {
            d.isRevisione = codiciCoppia.map(cc => {return cc.debitore;}).includes(d.id);
        });
    
        if (debitori.length != jla.length) {
            if (jla.length > 0) {
                var mapJla = this.mapArrayBy(jla, "debitore");
                debitori.forEach(d => {
                    if (mapJla[d.id] === undefined || mapJla[d.id] === null)
                        jla.push({ debitore: d.id, servizi: [] });
                });
            }
            else if (debitori.length > 0) {
                var tmpJLA = [];
                debitori.forEach(d => {
                    tmpJLA.push({ debitore: d.id, servizi: [] });
                });
                jla = tmpJLA;
            }
        }

        //let joinLineaAttore = component.get("v.payload").joinLineaAttore;
        /*joinLineaAttore.forEach(j => {
            j.servizi = j.servizi.filter(s => {
                return selectedProducts.includes(s);
            });
        });
        */
		jla.forEach(j => {
            j.servizi = j.servizi.filter(s => {
                return selectedProducts.includes(s);
            });
        });

        // SM-CART-REVI OLD 
        // // component.set("v.joinLineaAttore", jla);
        // component.set("v.joinLineaAttore", joinLineaAttore);
        // // component.set("v.debitori", debitori);
        // component.set("v.debitori", debitori.filter(d => {return !d.isRevisione;}));
        // // component.set("v.emptyDebitori", (debitori.length == 0));
        // component.set("v.emptyDebitori", (debitori.filter(d => {return !d.isRevisione;}).length == 0));
        // // component.set("v.valutazionePortafoglio", valutazionePortafoglio);
        // component.set("v.valutazioniPortafoglio", valutazioniPortafoglio);

        //SM-CART-REVI        
        // component.set("v.joinLineaAttore", jla);
        component.set("v.joinLineaAttore", jla);
        component.set("v.debitori", debitori);
        component.set("v.emptyDebitori", (debitori.length == 0));
        // component.set("v.emptyDebitori", (debitori.filter(d => {return !d.isRevisione;}).length == 0));
        // component.set("v.valutazionePortafoglio", valutazionePortafoglio);
        component.set("v.valutazioniPortafoglio", valutazioniPortafoglio);
    },

    //SM-CART-REVI
    setupItemSection : function(component, event) {
        // var valutazionePortafoglio = component.get("v.payload").valutazionePortafoglio;
        // var valutazioniPortafoglio = component.get("v.payload").valutazioniPortafoglio;
        let valutazioniPortafoglio = component.get("v.valutazioniPortafoglio");
        let valutazioniPortafoglioMap = new Map();
        let servizi = component.get("v.servizi");
        let serviziMap = new Map();
        let subproducts = [];
        let payload = component.get("v.payload");
        let items = component.get("v.selectedItems").concat(component.get("v.lockedItems"));
        
        valutazioniPortafoglio.forEach(vp => { valutazioniPortafoglioMap.set(vp.servizio, vp); });
        servizi.forEach(ss => { serviziMap.set(ss.WGC_Famiglia__c, ss.Label); });

        var activeItem = (event ? event.getParam("item") : items.find(function (i) { return i.isActive == true; }));
        var selectedValPort = (activeItem != undefined ? (valutazioniPortafoglioMap.get(serviziMap.get(activeItem.name)) ? valutazioniPortafoglioMap.get(serviziMap.get(activeItem.name)) : {divisa:"",mercato:"",aNotifica:null,maturity:null,servizio:serviziMap.get(activeItem.name),tipo:"Valutazione portafoglio"}) : null);

        selectedValPort.confirming = selectedValPort.notConfirmingDebitore = false;
        
        if (activeItem && (activeItem.codice == "Confirming" || activeItem.codice == "AtdConProrogaConfirming")) {
            // if (selectedValPort.aNotifica == null) {
                selectedValPort.divisa = "242";
                selectedValPort.mercato = "001";
                selectedValPort.aNotifica = true;
                selectedValPort.maturity = true;
                selectedValPort.servizio = serviziMap.get(activeItem.name);
            // }
            
            selectedValPort.confirming = true;
            selectedValPort.notConfirmingDebitore = activeItem.codice != "Confirming";
        }

        let crossSellingJSON = (component.get("v.crossSellingJSON") ? JSON.parse(component.get("v.crossSellingJSON")) : []);

        // component.set("v.itemSection", (valutazionePortafoglio ? "valport" : "debitori"));
       	// || qualificaUtente == 'Leasing EF' || qualificaUtente == 'Leaasing TR' 
        //SM-CART-REVI Added Leasing
        let itemSection;
        //A.M. Gestione Mutuo Veneto Sviluppo (definizione variabile per sezione nuovo mutuo)
        let itemSubSection;
        
        let valPortHasATD = false;
        let qualificaUtente = component.get("v.qualificaUtente");
        switch (activeItem.area) {
            case 'Factoring - Cedente':
                if (qualificaUtente == "Sviluppo_Commerciale_Filiali" || qualificaUtente == "IFIS_International")
                    itemSection = (activeItem.hasValPort ? "valPort" : "debitori");
                else
                    itemSection = "cselling";
            break;
            case 'Servizi Bancari':
                //SM - Banca Corporate - Aggiunta di una nuova sezione per gestire i prodotti di banca corporate
				//A.M. SDCHG-5654 - Apertura vendita c/c anche per CE
                //if(qualificaUtente == "Crediti Erariali")
                //    itemSection = "cselling";
                //else
                    itemSection = "sbancario";
                    itemSubSection = "sbancario";
                subproducts = payload.pb.filter(pb => {return !pb.tipo.startsWith("Mutuo") && pb.tipo != "Fido";});
            break;
            case 'Factoring - Debitore':
                if(qualificaUtente == "Crediti Erariali")
                    itemSection = "cselling";
                else
                    itemSection = (activeItem.codice == "Confirming" ? "valPort" : "findiretto");
                if (itemSection == "findiretto")
                    subproducts = payload.pfi.filter(pfi => {return pfi.tipo == activeItem.codice;});
            break;
            case 'Factoring - Fiscale':
                itemSection = "factfisc";
            break;
            //SM - TEN: sezione Banca Corporate
            case 'Servizi Bancari Corporate':
                itemSection = 'bcorporate';
            break;
            //SM - TEN: sezione Corporate Estero
            case 'Estero':
                console.log('@@@ isEstero ');
                itemSection = 'estero';
            break;
            //A.M.  -> nuova famiglia Bonus Edilizi
            case 'Bonus Edilizi':
                if (qualificaUtente == "Sviluppo_Commerciale_Filiali")
                    itemSection = "debitori";
                else
                    itemSection = "cselling";
            break;    
            default:
                //A.M. Gestione Mutuo Veneto Sviluppo
                if ((activeItem.name == "Mutuo" || activeItem.name == "Mutuo Veneto Sviluppo") && (qualificaUtente == "Sviluppo_Commerciale_Filiali" || qualificaUtente == "IFIS_International") && qualificaUtente != "Crediti Erariali"){
                    if (activeItem.name == "Mutuo"){
                        itemSection = "sbancario";
                        itemSubSection = "sbancario";
                        subproducts = payload.pb.filter(pb => {return pb.tipo.startsWith("Mutuo");});
                    } else if (activeItem.name == "Mutuo Veneto Sviluppo"){
                        itemSection = "sbancario";
                        itemSubSection = "venetosviluppo";
                        subproducts = payload.pb.filter(pb => {return pb.tipo.startsWith("VenetoSviluppo");});
                    }}
                else {
                    itemSection = "cselling";
                    let cs = crossSellingJSON.find(csJ => { return csJ.product == activeItem.area + "_" + activeItem.name; });
                    component.set("v.crossSelling", (cs ? cs : {}) );	
                }
        }

        if (itemSection == "valPort" && activeItem.name == "Acquisto Titolo Definitivo") {
            valPortHasATD = true;
            if (selectedValPort.divisa == "" && selectedValPort.mercato == "") {
                selectedValPort.maturity = false;
                selectedValPort.operazioneIAS = "true";
                selectedValPort.previstaLIR = "false";
                selectedValPort.momento = "Cessione";
            } else if (typeof selectedValPort.operazioneIAS == "boolean") {
                selectedValPort.operazioneIAS = (selectedValPort.operazioneIAS ? "true" : "false");
                selectedValPort.previstaLIR = (selectedValPort.previstaLIR ? "true" : "false");
            }
        }

        component.set("v.itemSection", itemSection);
        //A.M. Gestione Mutuo Veneto Sviluppo
        component.set("v.itemSubSection", itemSubSection);
        component.set("v.subproducts", subproducts);
        component.set("v.valPortHasATD", valPortHasATD);
        // component.set("v.valutazioniPortafoglio", valPortList);
        component.set("v.selectedValPort", selectedValPort);
        if (event && event.getParam("action") == "valPort") {
            let selectedItems = component.get("v.selectedItems");
            selectedItems.find(function (i) { return i.isActive == true; }).isCompleted = false;
            component.set("v.selectedItems", selectedItems);
            component.set("v.showNext", false);
        }
    },

    setupPicklistOptions : function(component) {
        let divisaOptions = component.get("v.picklistOptions").find(function (po) { return po.field == "NDGLinea__c.DivisaNew__c"; }).options.map(opt => {
            let splitted = opt.split(":");
            return {value: splitted[0], label: splitted[1]};
        });
        let mercatoOptions = component.get("v.picklistOptions").find(function (po) { return po.field == "NDGLinea__c.WGC_Mercato__c"; }).options.map(opt => {
            let splitted = opt.split(":");
            return {value: splitted[0], label: splitted[1]};
        });
        
        component.set("v.divisaOptions", divisaOptions);
        component.set("v.mercatoOptions", mercatoOptions);
    },

    getAttoreLabels : function(component) {
        let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method": "c.getObjectLabels", "params": { objectName: "NDGLinea__c" } });
        appEvent.fire();
    },

    //SM-CART-REVI
    setupSubProductsOptions : function(component, event) {
        
        let serviziBancariOptions = [
            /*
            {type: "text", name: "id", label: "ID", order: 0, visible: false},
            {type: "select", name: "tipo", label: "Tipo", order: 1, options: component.get("v.tipologieMutui")},
            {type: "number", name: "importo", label: "Importo Fido (€)", order: 2},
            {type: "toggle", name: "anatocismo", label: "Addebito Interessi Conto", order: 3, value: false, visible: false},
            {type: "number", name: "durata", label: "Durata (Mesi)", order: 4},
            {type: "text", name: "finalitaMutuo", label: "Finalità Mutuo", order: 5}
            */
            
            // A.M. -> Aggiunta gestione per prodotto 'MutuoDecreto13E'
            {type: "text", name: "id", label: "ID", order: 0, visible: false},
            {type: "select", name: "tipo", label: "Tipo", order: 1, options: component.get("v.tipologieMutui")},
            {type: "toggle", name: "polizzaCPI", label: "Polizza CPI", order: 2, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].tipo == 'Mutuo' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoControgarantitoMCC' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoDecreto13E' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoFundingCDP'", value: false},
            {type: "toggle", name: "fundingBEI", label: "Funding BEI", order: 3, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].tipo == 'Mutuo' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoControgarantitoMCC'", value: false},
            //SM - TEN: CR 212 gestione pre ammortamento
            {type: 'toggle', name: 'preAmmortamento', label: 'Pre-ammortamento', order: 4, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].tipo != undefined && ROWDATA[ROWDATA_INDEX].tipo.includes('Mutuo')", value: false },
            {type: 'number', name: 'durataPreAmmortamento', label: 'Durata Pre-ammortamento (mesi)', order: 5, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].preAmmortamento == true" },
            {type: 'number', name: 'durataAmmortamento', label: 'Durata Ammortamento (mesi)', order: 6, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].preAmmortamento == true" },
            {type: "number", name: "importoOperazione", label: "Importo Operazione (€)", order: 7, visible: false, visibility: "( ROWDATA[ROWDATA_INDEX].tipo == 'Mutuo' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoControgarantitoMCC' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoDecreto13E' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoFundingCDP') && ROWDATA[ROWDATA_INDEX].polizzaCPI == true", value: 0, step: "0.01"},
            {type: "select", name: "numeroAssicurati", label: "Numero Assicurati", order: 8, visible: false, visibility: "( ROWDATA[ROWDATA_INDEX].tipo == 'Mutuo' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoControgarantitoMCC' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoDecreto13E' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoFundingCDP' ) && ROWDATA[ROWDATA_INDEX].polizzaCPI == true", value: 1, options: [{label:1,value:1},{label:2,value:2},{label:3,value:3},{label:4,value:4}]},
            {type: "select", name: "percAssicurazioneSingoli", label: "% assicurazione singoli", order: 9, visible: false, visibility: "( ROWDATA[ROWDATA_INDEX].tipo == 'Mutuo' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoControgarantitoMCC' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoDecreto13E' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoFundingCDP' ) && ROWDATA[ROWDATA_INDEX].polizzaCPI == true", value: null, options: [{label:100,value:100},{label:50,value:50,disabled:true,disabledIf:"ROWDATA[ROWDATA_INDEX].numeroAssicurati != 2"},{label:33,value:33,disabled:true,disabledIf:"ROWDATA[ROWDATA_INDEX].numeroAssicurati != 3"},{label:25,value:25,disabled:true,disabledIf:"ROWDATA[ROWDATA_INDEX].numeroAssicurati != 4"}]},
            {type: "number", name: "durata", label: "Durata (Mesi)", order: 10, value: 0, formulaLabel: "ROWDATA[ROWDATA_INDEX].preAmmortamento == true ? 'Durata totale (Mesi)' : 'Durata (Mesi)'", disabledIf: "ROWDATA[ROWDATA_INDEX].preAmmortamento == true", formula: "ROWDATA[ROWDATA_INDEX].preAmmortamento == true ? parseInt(ROWDATA[ROWDATA_INDEX].durataPreAmmortamento) + parseInt(ROWDATA[ROWDATA_INDEX].durataAmmortamento) : ROWDATA[ROWDATA_INDEX].durata"},
            {type: "number", name: "importoPolizza", label: "Importo Polizza (€)", order: 11, visible: false, disabled: true, visibility: "( ROWDATA[ROWDATA_INDEX].tipo == 'Mutuo' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoControgarantitoMCC' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoDecreto13E' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoFundingCDP' ) && ROWDATA[ROWDATA_INDEX].polizzaCPI == true", value: 0, formula: "ROWDATA[ROWDATA_INDEX].importoOperazione * ROWDATA[ROWDATA_INDEX].durata * ROWDATA[ROWDATA_INDEX].numeroAssicurati * ROWDATA[ROWDATA_INDEX].percAssicurazioneSingoli * 0.00055 * 0.01", step: "0.01"},
            {type: "number", name: "importoPolizzaSuRata", label: "Impatto Polizza su rata (quota capitale) (€)", order: 12, visible: false, visibility: "( ROWDATA[ROWDATA_INDEX].tipo == 'Mutuo' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoControgarantitoMCC' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoDecreto13E' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoFundingCDP' ) && ROWDATA[ROWDATA_INDEX].polizzaCPI == true", value: 0, disabled: true, formula: "ROWDATA[ROWDATA_INDEX].durata > 0 ? ROWDATA[ROWDATA_INDEX].importoOperazione * ROWDATA[ROWDATA_INDEX].numeroAssicurati * ROWDATA[ROWDATA_INDEX].percAssicurazioneSingoli * 0.00055 * 0.01 : 0", step: "0.01"},
            {type: "toggle", name: "fido", label: "Fido", order: 12, value: false, visible: true}, // SV
            // /**/
            {type: "number", name: "importo", label: "Importo Fido (€)", order: 13, disabled: false, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].fido || ROWDATA[ROWDATA_INDEX].tipo != undefined && ROWDATA[ROWDATA_INDEX].tipo.includes('Mutuo')", disabledIf: "( ROWDATA[ROWDATA_INDEX].tipo == 'Mutuo' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoControgarantitoMCC' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoDecreto13E' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoFundingCDP' ) && ROWDATA[ROWDATA_INDEX].polizzaCPI == true", formula: "( ROWDATA[ROWDATA_INDEX].tipo == 'Mutuo' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoControgarantitoMCC' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoDecreto13E' || ROWDATA[ROWDATA_INDEX].tipo == 'MutuoFundingCDP' ) && ROWDATA[ROWDATA_INDEX].polizzaCPI == true ? (parseFloat(ROWDATA[ROWDATA_INDEX].importoOperazione * ROWDATA[ROWDATA_INDEX].durata * ROWDATA[ROWDATA_INDEX].numeroAssicurati * ROWDATA[ROWDATA_INDEX].percAssicurazioneSingoli * 0.00055 * 0.01) + parseFloat(ROWDATA[ROWDATA_INDEX].importoOperazione)).toFixed(2) : ROWDATA[ROWDATA_INDEX].importo", step: "0.01"},
            {type: "toggle", name: "anatocismo", label: "Addebito Interessi Conto", order: 14, value: true, visible: false }, // SV anatocismo come da mockup deve essere passato sempre a true ed eliminato da layout
            {type: "text", name: "finalitaMutuo", label: "Finalità Mutuo", order: 15}
        ];
        
        let plafondOptions = [
            {type: "text", name: "id", label: "ID", order: 0, visible: false},
            {type: "number", name: "importo", label: "Importo Prosolvendo (€)", order: 1},
            {type: "number", name: "quotaProsoluto", label: "Quota Prosoluto (€)", order: 2},
            {type: "number", name: "durataMaxCredito", label: "Durata Max Credito (GG)", order: 3},
            {type: "number", name: "durataDilazione", label: "Durata Dilazione (GG)", order: 4},
            {type: "number", name: "giorniFree", label: "Giorni Free", order: 5}
        ];
        
        //A.M. Gestione Mutuo Veneto Sviluppo
        let VenetoSviluppoOptions = [
            {type: "text", name: "id", label: "ID", order: 0, visible: false},
            {type: "select", name: "tipo", label: "Tipo", order: 1, options: component.get("v.tipologieMutuiVS")},
            {type: "toggle", name: "polizzaCPI", label: "Polizza CPI", order: 2, visible: true, value: false},
            {type: 'toggle', name: 'preAmmortamento', label: 'Pre-ammortamento', order: 3, visible: true, value: false},
            {type: 'number', name: 'durataPreAmmortamento', label: 'Durata Pre-ammortamento (mesi)', order: 4, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].preAmmortamento == true" },
            {type: 'number', name: 'durataAmmortamento', label: 'Durata Ammortamento (mesi)', order: 5, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].preAmmortamento == true" },            
            {type: "number", name: "importoOperazione", label: "Importo Operazione (€)", order: 6, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].polizzaCPI == true", value: 0, step: "0.01"},
            {type: "select", name: "numeroAssicurati", label: "Numero Assicurati", order: 7, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].polizzaCPI == true", value: 1, options: [{label:1,value:1},{label:2,value:2},{label:3,value:3},{label:4,value:4}]},
            {type: "select", name: "percAssicurazioneSingoli", label: "% assicurazione singoli", order: 8, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].polizzaCPI == true", value: null, options: [{label:100,value:100},{label:50,value:50,disabled:true,disabledIf:"ROWDATA[ROWDATA_INDEX].numeroAssicurati != 2"},{label:33,value:33,disabled:true,disabledIf:"ROWDATA[ROWDATA_INDEX].numeroAssicurati != 3"},{label:25,value:25,disabled:true,disabledIf:"ROWDATA[ROWDATA_INDEX].numeroAssicurati != 4"}]},           
            {type: "number", name: "durata", label: "Durata (Mesi)", order: 9, value: 0, formulaLabel: "ROWDATA[ROWDATA_INDEX].preAmmortamento == true ? 'Durata totale (Mesi)' : 'Durata (Mesi)'", disabledIf: "ROWDATA[ROWDATA_INDEX].preAmmortamento == true", formula: "ROWDATA[ROWDATA_INDEX].preAmmortamento == true ? parseInt(ROWDATA[ROWDATA_INDEX].durataPreAmmortamento) + parseInt(ROWDATA[ROWDATA_INDEX].durataAmmortamento) : ROWDATA[ROWDATA_INDEX].durata"},
            {type: "number", name: "importoPolizza", label: "Importo Polizza (€)", order: 10, visible: false, disabled: true, visibility: "ROWDATA[ROWDATA_INDEX].polizzaCPI == true", value: 0, formula: "ROWDATA[ROWDATA_INDEX].importoOperazione * ROWDATA[ROWDATA_INDEX].durata * ROWDATA[ROWDATA_INDEX].numeroAssicurati * ROWDATA[ROWDATA_INDEX].percAssicurazioneSingoli * 0.00055 * 0.01", step: "0.01"},
            {type: "number", name: "importoPolizzaSuRata", label: "Impatto Polizza su rata (quota capitale) (€)", order: 11, visible: false, visibility: "ROWDATA[ROWDATA_INDEX].polizzaCPI == true", value: 0, disabled: true, formula: "ROWDATA[ROWDATA_INDEX].durata > 0 ? ROWDATA[ROWDATA_INDEX].importoOperazione * ROWDATA[ROWDATA_INDEX].numeroAssicurati * ROWDATA[ROWDATA_INDEX].percAssicurazioneSingoli * 0.00055 * 0.01 : 0", step: "0.01"},
            {type: "number", name: "importo", label: "Importo (€)", order: 12, disabled: false, visible: true, disabledIf: "ROWDATA[ROWDATA_INDEX].polizzaCPI == true", formula: "ROWDATA[ROWDATA_INDEX].polizzaCPI == true ? (parseFloat(ROWDATA[ROWDATA_INDEX].importoOperazione * ROWDATA[ROWDATA_INDEX].durata * ROWDATA[ROWDATA_INDEX].numeroAssicurati * ROWDATA[ROWDATA_INDEX].percAssicurazioneSingoli * 0.00055 * 0.01) + parseFloat(ROWDATA[ROWDATA_INDEX].importoOperazione)).toFixed(2) : ROWDATA[ROWDATA_INDEX].importo", step: "0.01"},
            {type: "text", name: "finalitaMutuo", label: "Finalità Mutuo", order: 13}, 
            {type: "toggle", name: "fido", label: "Fido", order: 14, value: false, visible: false}
        ];
        component.set("v.VenetoSviluppoOptions", VenetoSviluppoOptions); 
       
        component.set("v.serviziBancariOptions", serviziBancariOptions);
        component.set("v.plafondOptions", plafondOptions);       
    },

    //SM-CART-REVI
    reloadSubProductsOptions : function(component, event) {
        let activeItem = (event ? event.getParam("item") : component.get("v.selectedItems").find(i => {return i.isActive;}));
        let subProductForm = activeItem.subProductForm;
        let serviziBancariOptions = component.get("v.serviziBancariOptions");
        let plafondOptions = component.get("v.plafondOptions");
        let VenetoSviluppoOptions = component.get("v.VenetoSviluppoOptions");


        console.log('@@@Reload activeItem ' , JSON.stringify(activeItem));
        console.log('@@@Reload subProductForm ' , subProductForm);

        switch (subProductForm) {
            case "ContoCorrente": // IfisImpresa
            serviziBancariOptions.find(sbo => {return sbo.name == "importo";}).label = "Importo Fido (€)";
            serviziBancariOptions.find(sbo => {return sbo.name == "tipo";}).visible = false;
            serviziBancariOptions.find(sbo => {return sbo.name == "anatocismo";}).visible = false;
            serviziBancariOptions.find(sbo => {return sbo.name == "durata";}).visible = false;
            serviziBancariOptions.find(sbo => {return sbo.name == "finalitaMutuo";}).visible = false;
            serviziBancariOptions.find(sbo => {return sbo.name == "fido";}).visible = true;   
            break;
            case "Standard": // Plafond
            plafondOptions.find(po => {return po.name == "durataMaxCredito";}).visible = false;
            plafondOptions.find(po => {return po.name == "durataDilazione";}).visible = false;
            plafondOptions.find(po => {return po.name == "giorniFree";}).visible = false;    
            break;
            //A.M. Gestione Mutuo Veneto Sviluppo
            case "VenetoSviluppo":   
            VenetoSviluppoOptions.find(sbo => {return sbo.name == "tipo";}).visible = true;
            VenetoSviluppoOptions.find(sbo => {return sbo.name == "durata";}).visible = true;
            VenetoSviluppoOptions.find(sbo => {return sbo.name == "finalitaMutuo";}).visible = true;
            if(VenetoSviluppoOptions.find(sbo => {return sbo.name == 'preAmmortamento';}).value != undefined && VenetoSviluppoOptions.find(sbo => {return sbo.name == 'preAmmortamento';}).value == true )
                VenetoSviluppoOptions.find(sbo => {return sbo.name == 'durata';}).label = 'Durata totale (mesi)';
            break;    
            default:   
            serviziBancariOptions.find(sbo => {return sbo.name == "importo";}).label = "Importo (€)";
            // serviziBancariOptions.find(sbo => {return sbo.name == "importo"}).visible = true;
            serviziBancariOptions.find(sbo => {return sbo.name == "anatocismo";}).visible = false;
            serviziBancariOptions.find(sbo => {return sbo.name == "durata";}).visible = true;
            serviziBancariOptions.find(sbo => {return sbo.name == "finalitaMutuo";}).visible = true;
            serviziBancariOptions.find(sbo => {return sbo.name == 'fido';}).visible = false;
            //SM - TEN: CR 212 Gestione pre ammortamento
            if(serviziBancariOptions.find(sbo => {return sbo.name == 'preAmmortamento';}).value != undefined && serviziBancariOptions.find(sbo => {return sbo.name == 'preAmmortamento';}).value == true )
                serviziBancariOptions.find(sbo => {return sbo.name == 'durata';}).label = 'Durata totale (mesi)';
            if (activeItem.nome == "Mutuo" || activeItem.name == "Mutuo")
                serviziBancariOptions.find(sbo => {return sbo.name == "tipo";}).visible = true;  
        }

        component.set("v.serviziBancariOptions", serviziBancariOptions);
        component.set("v.plafondOptions", plafondOptions);
        component.set("v.VenetoSviluppoOptions", VenetoSviluppoOptions);
    },

    //SM - Banca Corporate - Aggiunta la gestione nel caso dei prodotti di banca corporate con un attributo proprio
    setupBCOptions : function(component){
        var cc = component.get("v.CCData");

        let BCOptions = [
            {label: 'id', type: 'text', name: 'id', visible: false, order: 0},
            {label: 'Tipo', type: 'text', name: 'tipo', visible: false, order: 0},
            {label: 'Tipologia', type: 'radio', name: 'tipologiaConto', prodId: 'SBF', visible: false, order: 1, value: 'Conto Unico', required: true, options: [{ label: 'Conto Unico (Addebito interessi su utilizzato)', value: 'Conto Unico' }, { label: 'Conto Doppio (Gestione separata e Addebito interessi su presentato)', value: 'Conto Doppio' }] },
            {label: 'Importo fido Portafoglio Disp Imm', type: 'number', step: '0.01', name: 'importo_SBF', prodId: 'SBF', visible: false, required: true, order: 2},
            {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_SBF', prodId: 'SBF', visible: false, order: 3, required: true, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_SBF', prodId: 'SBF', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_SBF == "Esistente"', order: 4, options: cc },

            {label: 'Importo fido Anticipo Fatture', type: 'number', step: '0.01', name: 'importo', prodId: 'AnticipoFatture', visible: false, required: true, order: 2},
            {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_AnticipoFatture', prodId: 'AnticipoFatture', visible: false, required: true, order: 3, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_AnticipoFatture', prodId: 'AnticipoFatture', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_AnticipoFatture == "Esistente"', order: 4, options: cc },
            
            {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_GestionePTF', prodId: 'GestionePTF', visible: false, required: true, order: 3, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_GestionePTF', prodId: 'GestionePTF', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_GestionePTF == "Esistente"', order: 4, options: cc },
        
        ];

        component.set("v.CorporateOptions", BCOptions);
    },

    reloadBCOptions : function(component, event){
        let activeItem = (event ? event.getParam("item") : component.get("v.selectedItems").find(i => {return i.isActive;}));
        let subProductForm = activeItem.subProductForm;
        let fields = component.get("v.CorporateOptions");
        let utilizzoCC_SBF;
        let utilizzoCC_AnticipoFatture;
        let utilizzoCC_GestionePTF;
        var lines = component.get("v.payload.pbc");

        fields.forEach(element => {
            if(element.prodId == 'AnticipoFatture' && element.name == 'utilizzoCC_AnticipoFatture'){
                // utilizzoCC_AnticipoFatture = element.value;
                utilizzoCC_AnticipoFatture = element.value != undefined ? element.value : lines.find(l => { return l.tipo == 'AnticipoFatture'}) != undefined ? lines.find(l => { return l.tipo == 'AnticipoFatture'}).utilizzoCC : '';
            }  
            
            if(element.prodId == 'SBF' && element.name == 'utilizzoCC_SBF'){
                // utilizzoCC_SBF = element.value;
                utilizzoCC_SBF = element.value != undefined ? element.value : lines.find(l => { return l.tipo == 'SBF'}) != undefined ? lines.find(l => { return l.tipo == 'SBF'}).utilizzoCC : '';
            }  

            if(element.prodId == 'GestionePTF' && element.name == 'utilizzoCC_GestionePTF'){
                utilizzoCC_GestionePTF = element.value != undefined ? element.value : lines.find(l => { return l.tipo == 'GestionePTF'}) != undefined ? lines.find(l => { return l.tipo == 'GestionePTF'}).utilizzoCC : '';
            }  
        });

        switch(subProductForm){
            case "AnticipoFatture":
                fields.forEach(element => {
                    if(element.prodId == 'AnticipoFatture'){
                        if(element.name != 'CCSelezionato_AnticipoFatture'){
                            element.visible = true;
                        } else {
                            if(utilizzoCC_AnticipoFatture == 'Esistente'){
                                element.visible = true;
                            } else {
                                element.visible = false;
                            }
                        }
                    } else {
                        element.visible = false;
                    }                    
                });

                fields.find(f => { return f.name == 'tipo'; }).value = 'AnticipoFatture';
                fields.find(f => { return f.name == 'id'}).value = lines.find(f => { return f.tipo == 'AnticipoFatture'; }) != undefined ? lines.find(f => { return f.tipo == 'AnticipoFatture'; }).id : null;
                fields.find(f => { return f.name == 'importo'}).value = lines.find(f => { return f.tipo == 'AnticipoFatture'; }) != undefined ? lines.find(f => { return f.tipo == 'AnticipoFatture'; }).importo : '';
                fields.find(f => { return f.name == 'utilizzoCC_AnticipoFatture'}).value = lines.find(f => { return f.tipo == 'AnticipoFatture'; }) != undefined ? lines.find(f => { return f.tipo == 'AnticipoFatture'; }).utilizzoCC : '';
                fields.find(f => { return f.name == 'CCSelezionato_AnticipoFatture'}).value = lines.find(f => { return f.tipo == 'AnticipoFatture'; }) != undefined ? lines.find(f => { return f.tipo == 'AnticipoFatture'; }).CCSelezionato : '';
            break;
            case "SBF":
                fields.forEach(element => {
                    if(element.prodId == 'SBF'){
                        if(element.name != 'CCSelezionato_SBF'){
                            element.visible = true;
                        } else {
                            if(utilizzoCC_SBF == 'Esistente'){
                                element.visible = true;
                            } else {
                                element.visible = false;
                            }
                        }
                    } else {
                        element.visible = false;
                    }                    
                });

                fields.find(f => { return f.name == 'tipo'; }).value = 'SBF';
                fields.find(f => { return f.name == 'id'}).value = lines.find(f => { return f.tipo == 'SBF'; }) != undefined ? lines.find(f => { return f.tipo == 'SBF'; }).id : null;
                fields.find(f => { return f.name == 'tipologiaConto'}).value = lines.find(f => { return f.tipo == 'SBF'; }) != undefined ? lines.find(f => { return f.tipo == 'SBF'; }).tipologiaConto : 'Conto Unico';
                fields.find(f => { return f.name == 'importo_SBF'}).value = lines.find(f => { return f.tipo == 'SBF'; }) != undefined ? lines.find(f => { return f.tipo == 'SBF'; }).importo : '';
                fields.find(f => { return f.name == 'utilizzoCC_SBF'}).value = lines.find(f => { return f.tipo == 'SBF'; }) != undefined ? lines.find(f => { return f.tipo == 'SBF'; }).utilizzoCC : '';
                fields.find(f => { return f.name == 'CCSelezionato_SBF'}).value = lines.find(f => { return f.tipo == 'SBF'; }) != undefined ? lines.find(f => { return f.tipo == 'SBF'; }).CCSelezionato : '';

            break;
            case "GestionePTF":
                fields.forEach(element => {
                    if(element.prodId == 'GestionePTF'){
                        if(element.name != 'CCSelezionato_GestionePTF'){
                            element.visible = true;
                        } else {
                            if(utilizzoCC_GestionePTF == 'Esistente'){
                                element.visible = true;
                            } else {
                                element.visible = false;
                            }
                        }
                    } else {
                        element.visible = false;
                    }                    
                });

                fields.find(f => { return f.name == 'tipo'; }).value = 'GestionePTF';
                fields.find(f => { return f.name == 'id'}).value = lines.find(f => { return f.tipo == 'GestionePTF'; }) != undefined ? lines.find(f => { return f.tipo == 'GestionePTF'; }).id : null;
                // fields.find(f => { return f.name == 'importo_GestionePTF'}).value = lines.find(f => { return f.tipo == 'GestionePTF'; }) != undefined ? lines.find(f => { return f.tipo == 'GestionePTF'; }).importo : '';
                fields.find(f => { return f.name == 'utilizzoCC_GestionePTF'}).value = lines.find(f => { return f.tipo == 'GestionePTF'; }) != undefined ? lines.find(f => { return f.tipo == 'GestionePTF'; }).utilizzoCC : '';
                fields.find(f => { return f.name == 'CCSelezionato_GestionePTF'}).value = lines.find(f => { return f.tipo == 'GestionePTF'; }) != undefined ? lines.find(f => { return f.tipo == 'GestionePTF'; }).CCSelezionato : '';

            break;
            default:
            break;
        }

        component.set("v.CorporateOptions", fields);
    },

    setupBCEOptions : function(component){
        var cc = component.get("v.CCData");
        var garanzieOptions = component.get("v.picklistGaranzieEstero");

        var garanzieOptionsMap = garanzieOptions.map(g => { return {label: g, value: g}; });
        console.log('@@@ garanzieOptionsMap ' , garanzieOptionsMap);

        var divise = component.get("v.divisaOptions");

        let BCEOptions = [
            {label: 'id', type: 'text', name: 'id', visible: false},
            {label: 'Tipo', type: 'text', name: 'tipo', visible: false},

            //Anticipo Export
            {label: 'Divisa', type: 'select', name: 'divisa_AnticipoExport', prodId: 'AnticipoExport', visible: false, required: true, options: divise },
            {label: 'Importo fido Anticipo Export', type: 'number', step: '0.01', name: 'importo_AnticipoExport', prodId: 'AnticipoExport', visible: false, required: true},
            {label: 'Durata (gg)', type: 'number', name: 'durataGG_AnticipoExport', prodId: 'AnticipoExport', visible: false, required: true},
            {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_AnticipoExport', prodId: 'AnticipoExport', visible: false, required: true, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_AnticipoExport', prodId: 'AnticipoExport', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_AnticipoExport == "Esistente"', options: cc/*options: [{ label: 'XXX', value: 'xxx' }, { label: 'YYY', value: 'yy'}]*/ },

            //Finanziamento Import
            {label: 'Divisa', type: 'select', name: 'divisa_FinanziamentoImport', prodId: 'FinanziamentoImport', visible: false, required: true, options: divise},
            {label: 'Importo fido Import', type: 'number', step: '0.01', name: 'importo_FinanziamentoImport', prodId: 'FinanziamentoImport', visible: false, required: true},
            {label: 'Durata (gg)', type: 'number', name: 'durataGG_FinanziamentoImport', prodId: 'FinanziamentoImport', visible: false, required: true},
            //{label: 'Finalità', type: 'text', name: 'finalitaExport_FinanziamentoImport', prodId: 'FinanziamentoImport', visible: false, required: true},
            {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_FinanziamentoImport', prodId: 'FinanziamentoImport', visible: false, required: true, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_FinanziamentoImport', prodId: 'FinanziamentoImport', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_FinanziamentoImport == "Esistente"', options: cc},

            //Finanziamento Export
            {label: 'Divisa', type: 'select', name: 'divisa_FinanziamentoExport', prodId: 'FinanziamentoExport', visible: false, required: true, options: divise},
            {label: 'Importo fido Export', type: 'number', step: '0.01', name: 'importo_FinanziamentoExport', prodId: 'FinanziamentoExport', visible: false, required: true},
            {label: 'Durata (gg)', type: 'number', name: 'durataGG_FinanziamentoExport', prodId: 'FinanziamentoExport', visible: false, required: true},
            //{label: 'Finalità', type: 'text', name: 'finalitaExport_FinanziamentoExport', prodId: 'FinanziamentoExport', visible: false, required: true},
            {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_FinanziamentoExport', prodId: 'FinanziamentoExport', visible: false, required: true, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_FinanziamentoExport', prodId: 'FinanziamentoExport', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_FinanziamentoExport == "Esistente"', options: cc},

            //Credito Documentario Export
            {label: 'Divisa', type: 'select', name: 'divisa_CreditoDocumentarioExport', prodId: 'CreditoDocumentarioExport', visible: false, required: true, options: divise},
            {label: 'Importo (€)', type: 'number', step: '0.01', name: 'importo_CreditoDocumentarioExport', prodId: 'CreditoDocumentarioExport', visible: false, required: true},
            {label: 'Durata (gg)', type: 'number', name: 'durataGG_CreditoDocumentarioExport', prodId: 'CreditoDocumentarioExport', visible: false, required: true},
            //{label: 'Finalità', type: 'text', name: 'finalitaExport_CreditoDocumentarioExport', prodId: 'CreditoDocumentarioExport', visible: false, required: true},
            //{label: 'Lista Documenti', type: 'textarea', size: '8', name: 'listaDocumenti_CreditoDocumentarioExport', prodId: 'CreditoDocumentarioExport', visible: false, required: true},
            {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_CreditoDocumentarioExport', prodId: 'CreditoDocumentarioExport', visible: false, required: true, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_CreditoDocumentarioExport', prodId: 'CreditoDocumentarioExport', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_CreditoDocumentarioExport == "Esistente"', options: cc},

            //Credito Documentario Import
            {label: 'Divisa', type: 'select', name: 'divisa_CreditoDocumentarioImport', prodId: 'CreditoDocumentarioImport', visible: false, required: true, options: divise},
            {label: 'Importo fido di emissione lettera di credito (€)', type: 'number', step: '0.01', name: 'importo_CreditoDocumentarioImport', prodId: 'CreditoDocumentarioImport', visible: false, required: true},
            {label: 'Durata (gg)', type: 'number', name: 'durataGG_CreditoDocumentarioImport', prodId: 'CreditoDocumentarioImport', visible: false, required: true},
            //{label: 'Finalità', type: 'text', name: 'finalitaExport_CreditoDocumentarioImport', prodId: 'CreditoDocumentarioImport', visible: false, required: true},
            //{label: 'Lista Documenti', type: 'textarea', size: '8', name: 'listaDocumenti_CreditoDocumentarioImport', prodId: 'CreditoDocumentarioImport', visible: false, required: true},
            {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_CreditoDocumentarioImport', prodId: 'CreditoDocumentarioImport', visible: false, required: true, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_CreditoDocumentarioImport', prodId: 'CreditoDocumentarioImport', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_CreditoDocumentarioImport == "Esistente"', options: cc},

            //Stand By Letter
            {label: 'Divisa', type: 'select', name: 'divisa_StandByLetter', prodId: 'StandByLetter', visible: false, required: true, options: divise},
            {label: 'Importo fido stand by letter (€)', type: 'number', step: '0.01', name: 'importo_StandByLetter', prodId: 'StandByLetter', visible: false, required: true},
            {label: 'Durata (gg)', type: 'number', name: 'durataGG_StandByLetter', prodId: 'StandByLetter', visible: false, required: true},
            //{label: 'Finalità', type: 'text', name: 'finalitaExport_StandByLetter', prodId: 'StandByLetter', visible: false, required: true},
            //{label: 'Lista Documenti', type: 'textarea', size: '8', name: 'listaDocumenti_StandByLetter', prodId: 'StandByLetter', visible: false, required: true},
            {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_StandByLetter', prodId: 'StandByLetter', visible: false, required: true, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_StandByLetter', prodId: 'StandByLetter', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_StandByLetter == "Esistente"', options: cc},

            //Documentate All'incasso
            {label: 'Tipologia', type: 'radio', name: 'tipologiaImpExp_DocumentateIncasso', prodId: 'DocumentateIncasso', visible: false, required: true, options: [{ label: 'Import', value: 'Import'}, { label: 'Export', value: 'Export'}] },
            {label: 'Affidamento', type: 'radio', name: 'affidamento_DocumentateIncasso', prodId: 'DocumentateIncasso', visible: false, required: true, visibility: 'DATA.tipologiaImpExp_DocumentateIncasso == "Import"', options: [{ label: 'Si', value: 'S'}, { label: 'No', value: 'N'}]},
            {label: 'Divisa', type: 'select', name: 'divisa_DocumentateIncasso', prodId: 'DocumentateIncasso', visible: false, visibility: 'DATA.tipologiaImpExp_DocumentateIncasso == "Export" || ( DATA.tipologiaImpExp_DocumentateIncasso == "Import" && ( DATA.affidamento_DocumentateIncasso == "S" || DATA.affidamento_DocumentateIncasso == "N" ) )', required: true, options: divise},
            {label: 'Importo volume d\'affari (€)', formulaLabel: 'DATA.tipologiaImpExp_DocumentateIncasso == "Export" ? "Importo volume d\'affari (€)" : DATA.affidamento_DocumentateIncasso == "S" ? "Importo fido documentate (€)" : DATA.affidamento_DocumentateIncasso == "N" ? "Importo (€)" : "Importo (€)"', type: 'number', step: '0.01', name: 'importo_DocumentateIncasso', prodId: 'DocumentateIncasso', visible: false, required: true, visibility: 'DATA.tipologiaImpExp_DocumentateIncasso == "Export" || ( DATA.tipologiaImpExp_DocumentateIncasso == "Import" && ( DATA.affidamento_DocumentateIncasso == "S" || DATA.affidamento_DocumentateIncasso == "N" ) )'},
            {label: 'Durata (gg)', type: 'number', name: 'durataGG_DocumentateIncasso', prodId: 'DocumentateIncasso', visible: false, visibility: 'DATA.tipologiaImpExp_DocumentateIncasso == "Export" || ( DATA.tipologiaImpExp_DocumentateIncasso == "Import" && ( DATA.affidamento_DocumentateIncasso == "S" || DATA.affidamento_DocumentateIncasso == "N" ) )', required: true},
            //{label: 'Finalità', type: 'text', name: 'finalitaExport_DocumentateIncasso', prodId: 'DocumentateIncasso', visible: false, required: true},
            //{label: 'Lista Documenti', type: 'textarea', size: '8', name: 'listaDocumenti_DocumentateIncasso', prodId: 'DocumentateIncasso', visible: false, required: true},
            {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_DocumentateIncasso', prodId: 'DocumentateIncasso', visible: false, required: true, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_DocumentateIncasso', prodId: 'DocumentateIncasso', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_DocumentateIncasso == "Esistente"', options: cc},
            
            //Garanzie Internazionali
            {label: 'Tipo di garanzia', type: 'select', name: 'tipoGaranzia_GaranziaInternazionale', visible: false, required: true, prodId: 'GaranziaInternazionale', options: garanzieOptionsMap},
            {label: 'Divisa', type: 'select', name: 'divisa_GaranziaInternazionale', prodId: 'GaranziaInternazionale', visible: false, required: true, options: divise},
            {label: 'Importo fido di garanzia (€)', type: 'number', step: '0.01', name: 'importo_GaranziaInternazionale', prodId: 'GaranziaInternazionale', visible: false, required: true},
            {label: 'Durata (gg)', type: 'number', name: 'durataGG_GaranziaInternazionale', prodId: 'GaranziaInternazionale', visible: false, required: true},
            //{label: 'Finalità', type: 'text', name: 'finalitaExport_GaranziaInternazionale', prodId: 'GaranziaInternazionale', visible: false, required: true},
            {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_GaranziaInternazionale', prodId: 'GaranziaInternazionale', visible: false, required: true, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_GaranziaInternazionale', prodId: 'GaranziaInternazionale', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_GaranziaInternazionale == "Esistente"', options: cc },

            //TODO TOGLI
            // {label: 'Utilizzo C/C Ifis Impresa', type: 'select', name: 'utilizzoCC_GestionePTF', prodId: 'GestionePTF', visible: false, required: true, order: 3, options: [{ label: 'Nuovo', value: 'Nuovo' }, { label: 'Esistente', value: 'Esistente'}] },
            // {label: 'Seleziona C/C IFIS Impresa esistente', name: 'CCSelezionato_GestionePTF', prodId: 'GestionePTF', type: 'select', visible: false, required: true, visibility: 'DATA.utilizzoCC_GestionePTF == "Esistente"', options: cc },
        ];

        component.set("v.CorporateEsteroOptions", BCEOptions);
    },

    reloadBCEOptions : function(component, event){
        let activeItem = (event ? event.getParam("item") : component.get("v.selectedItems").find(i => {return i.isActive;}));
        var subProductForm = activeItem.subProductForm;
        let fields = component.get("v.CorporateEsteroOptions");
        var lines = component.get("v.payload.pbce");

        console.log('@@@ lines BCE ' , lines);
        console.log('@@@ subProductForm BCE ' , subProductForm);

        switch(subProductForm){
            case 'AnticipoExport':
                fields.find(f => { return f.name == 'tipo'; }).value = 'AnticipoExport';
                fields.find(f => { return f.name == 'id'}).value = lines.find(f => { return f.tipo == 'AnticipoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'AnticipoExport'; }).id : null;
                fields.find(f => { return f.name == 'divisa_AnticipoExport'}).value = lines.find(f => { return f.tipo == 'AnticipoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'AnticipoExport'; }).divisa : null;
                fields.find(f => { return f.name == 'durataGG_AnticipoExport'}).value = lines.find(f => { return f.tipo == 'AnticipoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'AnticipoExport'; }).durataGG : null;
                fields.find(f => { return f.name == 'importo_AnticipoExport'}).value = lines.find(f => { return f.tipo == 'AnticipoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'AnticipoExport'; }).importo : null;
                fields.find(f => { return f.name == 'utilizzoCC_AnticipoExport'}).value = lines.find(f => { return f.tipo == 'AnticipoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'AnticipoExport'; }).utilizzoCC : '';
                fields.find(f => { return f.name == 'CCSelezionato_AnticipoExport'}).value = lines.find(f => { return f.tipo == 'AnticipoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'AnticipoExport'; }).CCSelezionato : '';

                fields.filter(f => { return f.prodId != 'AnticipoExport'}).forEach(f => { f.visible = false; });
                fields.filter(f => { return f.prodId == 'AnticipoExport'}).forEach(f => { f.visible = true; });

                fields.filter(f => { return f.prodId == 'AnticipoExport' && f.name == 'CCSelezionato_AnticipoExport'})[0].visible = lines.find(f => { return f.tipo == 'AnticipoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'AnticipoExport'; }).utilizzoCC == 'Esistente' : false;
            break;
            case 'FinanziamentoImport':
                fields.find(f => { return f.name == 'tipo'; }).value = 'FinanziamentoImport';
                fields.find(f => { return f.name == 'id'}).value = lines.find(f => { return f.tipo == 'FinanziamentoImport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoImport'; }).id : null;
                fields.find(f => { return f.name == 'divisa_FinanziamentoImport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoImport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoImport'; }).divisa : null;
                fields.find(f => { return f.name == 'importo_FinanziamentoImport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoImport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoImport'; }).importo : null;
                fields.find(f => { return f.name == 'durataGG_FinanziamentoImport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoImport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoImport'; }).durataGG : null;
                //fields.find(f => { return f.name == 'finalitaExport_FinanziamentoImport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoImport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoImport'; }).finalitaExport : null;
                fields.find(f => { return f.name == 'utilizzoCC_FinanziamentoImport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoImport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoImport'; }).utilizzoCC : '';
                fields.find(f => { return f.name == 'CCSelezionato_FinanziamentoImport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoImport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoImport'; }).CCSelezionato : '';

                fields.filter(f => { return f.prodId != 'FinanziamentoImport'}).forEach(f => { f.visible = false; });
                fields.filter(f => { return f.prodId == 'FinanziamentoImport'}).forEach(f => { f.visible = true; });

                fields.filter(f => { return f.prodId == 'FinanziamentoImport' && f.name == 'CCSelezionato_FinanziamentoImport'})[0].visible = lines.find(f => { return f.tipo == 'FinanziamentoImport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoImport'; }).utilizzoCC == 'Esistente' : false;

            break;
            case 'FinanziamentoExport':
                fields.find(f => { return f.name == 'tipo'; }).value = 'FinanziamentoExport';
                fields.find(f => { return f.name == 'id'}).value = lines.find(f => { return f.tipo == 'FinanziamentoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoExport'; }).id : null;
                fields.find(f => { return f.name == 'divisa_FinanziamentoExport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoExport'; }).divisa : null;
                fields.find(f => { return f.name == 'importo_FinanziamentoExport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoExport'; }).importo : null;
                fields.find(f => { return f.name == 'durataGG_FinanziamentoExport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoExport'; }).durataGG : null;
                //fields.find(f => { return f.name == 'finalitaExport_FinanziamentoExport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoExport'; }).finalitaExport : null;
                fields.find(f => { return f.name == 'utilizzoCC_FinanziamentoExport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoExport'; }).utilizzoCC : '';
                fields.find(f => { return f.name == 'CCSelezionato_FinanziamentoExport'}).value = lines.find(f => { return f.tipo == 'FinanziamentoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoExport'; }).CCSelezionato : '';

                fields.filter(f => { return f.prodId != 'FinanziamentoExport'}).forEach(f => { f.visible = false; });
                fields.filter(f => { return f.prodId == 'FinanziamentoExport'}).forEach(f => { f.visible = true; });

                fields.filter(f => { return f.prodId == 'FinanziamentoExport' && f.name == 'CCSelezionato_FinanziamentoExport'})[0].visible = lines.find(f => { return f.tipo == 'FinanziamentoExport'; }) != undefined ? lines.find(f => { return f.tipo == 'FinanziamentoExport'; }).utilizzoCC == 'Esistente' : false;

            break;
            case 'CreditoDocumentarioExport':
                fields.find(f => { return f.name == 'tipo'; }).value = 'CreditoDocumentarioExport';
                fields.find(f => { return f.name == 'id'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }).id : null;
                fields.find(f => { return f.name == 'divisa_CreditoDocumentarioExport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }).divisa : null;
                fields.find(f => { return f.name == 'importo_CreditoDocumentarioExport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }).importo : null;
                fields.find(f => { return f.name == 'durataGG_CreditoDocumentarioExport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }).durataGG : null;
                //fields.find(f => { return f.name == 'listaDocumenti_CreditoDocumentarioExport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }).finalitaExport : null;
                //fields.find(f => { return f.name == 'finalitaExport_CreditoDocumentarioExport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }).finalitaExport : null;
                fields.find(f => { return f.name == 'utilizzoCC_CreditoDocumentarioExport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }).utilizzoCC : '';
                fields.find(f => { return f.name == 'CCSelezionato_CreditoDocumentarioExport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }).CCSelezionato : '';

                fields.filter(f => { return f.prodId != 'CreditoDocumentarioExport'}).forEach(f => { f.visible = false; });
                fields.filter(f => { return f.prodId == 'CreditoDocumentarioExport'}).forEach(f => { f.visible = true; });

                fields.filter(f => { return f.prodId == 'CreditoDocumentarioExport' && f.name == 'CCSelezionato_CreditoDocumentarioExport'})[0].visible = lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioExport'; }).utilizzoCC == 'Esistente' : false;

            break;
            case 'CreditoDocumentarioImport':
                fields.find(f => { return f.name == 'tipo'; }).value = 'CreditoDocumentarioImport';
                fields.find(f => { return f.name == 'id'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }).id : null;
                fields.find(f => { return f.name == 'divisa_CreditoDocumentarioImport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }).divisa : null;
                fields.find(f => { return f.name == 'importo_CreditoDocumentarioImport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }).importo : null;
                fields.find(f => { return f.name == 'durataGG_CreditoDocumentarioImport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }).durataGG : null;
                //fields.find(f => { return f.name == 'listaDocumenti_CreditoDocumentarioImport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }).finalitaExport : null;
                //fields.find(f => { return f.name == 'finalitaExport_CreditoDocumentarioImport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }).finalitaExport : null;
                fields.find(f => { return f.name == 'utilizzoCC_CreditoDocumentarioImport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }).utilizzoCC : '';
                fields.find(f => { return f.name == 'CCSelezionato_CreditoDocumentarioImport'}).value = lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }).CCSelezionato : '';

                fields.filter(f => { return f.prodId != 'CreditoDocumentarioImport'}).forEach(f => { f.visible = false; });
                fields.filter(f => { return f.prodId == 'CreditoDocumentarioImport'}).forEach(f => { f.visible = true; });

                fields.filter(f => { return f.prodId == 'CreditoDocumentarioImport' && f.name == 'CCSelezionato_CreditoDocumentarioImport'})[0].visible = lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }) != undefined ? lines.find(f => { return f.tipo == 'CreditoDocumentarioImport'; }).utilizzoCC == 'Esistente' : false;

            break;
            case 'StandByLetter':
                fields.find(f => { return f.name == 'tipo'; }).value = 'StandByLetter';
                fields.find(f => { return f.name == 'id'}).value = lines.find(f => { return f.tipo == 'StandByLetter'; }) != undefined ? lines.find(f => { return f.tipo == 'StandByLetter'; }).id : null;
                fields.find(f => { return f.name == 'divisa_StandByLetter'}).value = lines.find(f => { return f.tipo == 'StandByLetter'; }) != undefined ? lines.find(f => { return f.tipo == 'StandByLetter'; }).divisa : null;
                fields.find(f => { return f.name == 'importo_StandByLetter'}).value = lines.find(f => { return f.tipo == 'StandByLetter'; }) != undefined ? lines.find(f => { return f.tipo == 'StandByLetter'; }).importo : null;
                fields.find(f => { return f.name == 'durataGG_StandByLetter'}).value = lines.find(f => { return f.tipo == 'StandByLetter'; }) != undefined ? lines.find(f => { return f.tipo == 'StandByLetter'; }).durataGG : null;
                //fields.find(f => { return f.name == 'listaDocumenti_StandByLetter'}).value = lines.find(f => { return f.tipo == 'StandByLetter'; }) != undefined ? lines.find(f => { return f.tipo == 'StandByLetter'; }).finalitaExport : null;
                //fields.find(f => { return f.name == 'finalitaExport_StandByLetter'}).value = lines.find(f => { return f.tipo == 'StandByLetter'; }) != undefined ? lines.find(f => { return f.tipo == 'StandByLetter'; }).finalitaExport : null;
                fields.find(f => { return f.name == 'utilizzoCC_StandByLetter'}).value = lines.find(f => { return f.tipo == 'StandByLetter'; }) != undefined ? lines.find(f => { return f.tipo == 'StandByLetter'; }).utilizzoCC : '';
                fields.find(f => { return f.name == 'CCSelezionato_StandByLetter'}).value = lines.find(f => { return f.tipo == 'StandByLetter'; }) != undefined ? lines.find(f => { return f.tipo == 'StandByLetter'; }).CCSelezionato : '';

                fields.filter(f => { return f.prodId != 'StandByLetter'}).forEach(f => { f.visible = false; });
                fields.filter(f => { return f.prodId == 'StandByLetter'}).forEach(f => { f.visible = true; });

                fields.filter(f => { return f.prodId == 'StandByLetter' && f.name == 'CCSelezionato_StandByLetter'})[0].visible = lines.find(f => { return f.tipo == 'StandByLetter'; }) != undefined ? lines.find(f => { return f.tipo == 'StandByLetter'; }).utilizzoCC == 'Esistente' : false;

            break;
            case 'DocumentateIncasso':
                fields.find(f => { return f.name == 'tipo'; }).value = 'DocumentateIncasso';
                fields.find(f => { return f.name == 'id'}).value = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).id : null;
                fields.find(f => { return f.name == 'tipologiaImpExp_DocumentateIncasso'}).value = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).tipologiaImpExp : null;
                fields.find(f => { return f.name == 'affidamento_DocumentateIncasso'}).value = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).affidamento : null;
                fields.find(f => { return f.name == 'divisa_DocumentateIncasso'}).value = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).divisa : null;
                fields.find(f => { return f.name == 'importo_DocumentateIncasso'}).value = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).importo : null;
                fields.find(f => { return f.name == 'durataGG_DocumentateIncasso'}).value = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).durataGG : null;
                //fields.find(f => { return f.name == 'listaDocumenti_DocumentateIncasso'}).value = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).finalitaExport : null;
                //fields.find(f => { return f.name == 'finalitaExport_DocumentateIncasso'}).value = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).finalitaExport : null;
                fields.find(f => { return f.name == 'utilizzoCC_DocumentateIncasso'}).value = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).utilizzoCC : '';
                fields.find(f => { return f.name == 'CCSelezionato_DocumentateIncasso'}).value = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).CCSelezionato : '';

                //Modifiche Label
                fields.find(f => { return f.name == 'importo_DocumentateIncasso'}).label = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).tipologiaImpExp == 'Export' ? 'Importo volume d\'affari (€)' : lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).affidamento == 'S' ? 'Importo fido documentate (€)' : 'Importo (€)' : 'Importo (€)';

                fields.filter(f => { return f.prodId != 'DocumentateIncasso'}).forEach(f => { f.visible = false; });
                window.DATA = {};
                fields.forEach(f => {
                    window.DATA[f.name] = f.value;
                });
                fields.filter(f => { return f.prodId == 'DocumentateIncasso'}).forEach(f => { if(f.hasOwnProperty('visibility')) f.visible = eval(f.visibility); else f.visible = true; });

                fields.filter(f => { return f.prodId == 'DocumentateIncasso' && f.name == 'CCSelezionato_DocumentateIncasso'})[0].visible = lines.find(f => { return f.tipo == 'DocumentateIncasso'; }) != undefined ? lines.find(f => { return f.tipo == 'DocumentateIncasso'; }).utilizzoCC == 'Esistente' : false;

            break;
            case 'GaranziaInternazionale':
                fields.find(f => { return f.name == 'tipo'; }).value = 'GaranziaInternazionale';//lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }) != undefined ? lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }).durataGG < 180 ? 'GaranziaInternazionaleBT' : 'GaranziaInternazionaleLT' : 'GaranziaInternazionaleLT';
                fields.find(f => { return f.name == 'id'}).value = lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }) != undefined ? lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }).id : null;
                fields.find(f => { return f.name == 'tipoGaranzia_GaranziaInternazionale'}).value = lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }) != undefined ? lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }).tipoGaranzia : null;
                fields.find(f => { return f.name == 'divisa_GaranziaInternazionale'}).value = lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }) != undefined ? lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }).divisa : null;
                fields.find(f => { return f.name == 'importo_GaranziaInternazionale'}).value = lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }) != undefined ? lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }).importo : null;
                fields.find(f => { return f.name == 'durataGG_GaranziaInternazionale'}).value = lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }) != undefined ? lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }).durataGG : null;
                //fields.find(f => { return f.name == 'finalitaExport_GaranziaInternazionale'}).value = lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }) != undefined ? lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }).finalitaExport : null;
                fields.find(f => { return f.name == 'utilizzoCC_GaranziaInternazionale'}).value = lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }) != undefined ? lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }).utilizzoCC : '';
                fields.find(f => { return f.name == 'CCSelezionato_GaranziaInternazionale'}).value = lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }) != undefined ? lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }).CCSelezionato : '';

                fields.filter(f => { return f.prodId != 'GaranziaInternazionale'}).forEach(f => { f.visible = false; });
                fields.filter(f => { return f.prodId == 'GaranziaInternazionale'}).forEach(f => { f.visible = true; });

                fields.filter(f => { return f.prodId == 'GaranziaInternazionale' && f.name == 'CCSelezionato_GaranziaInternazionale'})[0].visible = lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }) != undefined ? lines.find(f => { return f.tipo.includes('GaranziaInternazionale'); }).utilizzoCC == 'Esistente' : false;

            break;
            default:
            break;
        }

        component.set("v.CorporateEsteroOptions", fields);
    },

    reloadDebitori : function(component, event, newFields) {
        var debitori = (newFields ? component.get("v.debitori") : event.getParam("value").debitori);
        var jla = component.get("v.joinLineaAttore");
        let debitoriNewFieldsMap = this.mapArrayBy(component.get("v.debitoriNewFields"), "debitore");
        var debIds = [];
        debitori.forEach(d => { debIds.push(d.id); });
        let joinLineaAttore = jla.filter(j => {return debIds.includes(j.debitore);});
        let codiciCoppia = component.get("v.codiciCoppia");
        // REMOVE AUTO ADD DEBS (AGENZIA DELLE ENTRATE per FACTORING FISCALE)
        debitori = debitori.filter(d => {return !d.isFactFisc;});
        debitori.forEach(d => {
            d.isRevisione = codiciCoppia.map(cc => {return cc.debitore;}).includes(d.id);
        });
    
        // TODO: FIXARE, I NEW FIELDS NON SI AGGIORNANO E LA Q&C NON SI COMPLETA AUTOMATICAMENTE (ATTENZIONE: SIAMO NELL'HANDLER DELL'EVENTO DI MODIFICA DEI DEBITORI)
        debitori.forEach(d => { d.isCompleted = this.isCompleted(joinLineaAttore, d, debitoriNewFieldsMap[d.id]); });

        let serviziSelected = component.get("v.serviziSelected");

        if (serviziSelected.length == 1) { // AUTOADD IF ONLY ONE SERVICE AVAILABLE
            let payload = (newFields ? component.get("v.payload") : event.getParam("value"));
            let newDebs = debitori
                            .filter(d => {return !payload.valutazioniPortafoglio.map(vp => {return vp.id}).includes(d.id);})
                            .filter(d => {return !joinLineaAttore.map(jla => {return jla.debitore;}).includes(d.id);});
            
            //SM - CR 476 - Rimossa auto selezione nuova join con debitore inserito
            if (newDebs.length > 0 && component.get("v.opportunityRecord").Tipologia_Opportunit__c == 'CONC') {
                newDebs.forEach(d => {
                    joinLineaAttore = this.generateJoinLinea(payload, {debId: d.id, servizio: serviziSelected[0].Label});
                });
            }
        }

        //SM-CART-REVI old
        // component.set("v.debitori", debitori);
        // component.set("v.debitori", debitori.filter(d => {return !d.isRevisione;}));
        //  component.set("v.emptyDebitori", (debitori.length == 0));
        // component.set("v.emptyDebitori", (debitori.filter(d => {return !d.isRevisione;}).length == 0));
        
        //SM-CART-REVI NEW
        component.set("v.joinLineaAttore", joinLineaAttore);
        component.set("v.debitori", debitori);
        // component.set("v.emptyDebitori", (debitori.filter(d => {return !d.isRevisione;}).length == 0));
        component.set("v.emptyDebitori", (debitori.length == 0));
    },

    reloadValutazioniPortafoglio : function(component, event) {
        var payload = event.getParam("value");
        // component.set("v.valutazionePortafoglio", payload.valutazionePortafoglio);
        let valutazioniPortafoglio = payload.valutazioniPortafoglio;
        valutazioniPortafoglio.forEach(vp => {
            vp.previstaLIR = (vp.previstaLIR ? "true" : "false");
            vp.operazioneIAS = (vp.operazioneIAS ? "true" : "false");
        });
        component.set("v.valutazioniPortafoglio", valutazioniPortafoglio);

        var items = component.get("v.selectedItems");
        var selectedValPort = component.get("v.selectedValPort");

        if (selectedValPort != undefined && payload.valutazioniPortafoglio.length > 0)
            items.forEach(i => {
                if (i.isActive && i.hasValPort && payload.valutazioniPortafoglio.find(function(vp){ return vp.servizio == i.name || vp.servizio == i.codice; }))
                    i.isCompleted = this.isValPortCompleted(payload.valutazioniPortafoglio.find(function(vp){ return vp.servizio == i.name || vp.servizio == i.codice; }));
            });
        component.set("v.selectedItems", items);
    },

    reloadJoinLineaAttore : function(component) {
        component.set("v.joinLineaAttore", component.get("v.payload").joinLineaAttore); // .filter(j => {return this.isBlank(j.codiceCoppia);})
    },

    navigateSubWizard : function(component, target) {
        var cmpEvent = component.getEvent("navigateSubWizard");
        cmpEvent.setParams({ "target": target });
        cmpEvent.fire();
    },

    filterServices : function(component) {
        let servizi = component.get("v.servizi");
        let selectedItems = component.get("v.selectedItems");
        let lockedItems = component.get("v.lockedItems");
        let allItems = selectedItems.concat(lockedItems);
        let factItems = [];
        // A.M. -> Gestione Servizio "Bonus Edilizi"
        //  factItems = allItems.filter(i => {return i.area == "Factoring - Cedente" && !i.hasValPort;}).map(i => {return i.name;});
        if (allItems) {
            factItems = allItems.filter(i => {return (i.area == "Factoring - Cedente" || i.area == "Bonus Edilizi") && !i.hasValPort;}).map(i => {return i.name;});
        }
        let serviziSelected = (factItems.length > 0 ? servizi.filter(s => {return factItems.includes(s.WGC_Famiglia__c);}) : servizi);

        component.set("v.serviziSelected", serviziSelected);
    },

    //SM-CART-REVI
    configureItems : function(component) {
        // this.showSpinner(component, "");
        var items = component.get("v.items");
        var selectedItems = component.get("v.selectedItems");
        var lockedItems = component.get("v.lockedItems");
        var clones = [];
        var jla = component.get("v.joinLineaAttore");
        var debitoriMap = this.mapArrayBy(component.get("v.debitori"), "id");
        var debitoriNewFieldsMap = this.mapArrayBy(component.get("v.debitoriNewFields"), "debitore");
        // var valutazionePortafoglio = component.get("v.valutazionePortafoglio");
        let valutazioniPortafoglio = component.get("v.valutazioniPortafoglio");
        let valutazioniPortafoglioMap = new Map();
        let servizi = component.get("v.servizi");
        let serviziMap = new Map();
        let crossSellingJSON = (component.get("v.crossSellingJSON") ? JSON.parse(component.get("v.crossSellingJSON")) : []);
        let allRevisione = false;
        let codiciCoppia = component.get("v.codiciCoppia");
        
        valutazioniPortafoglio.forEach(vp => { valutazioniPortafoglioMap.set(vp.servizio, vp); });
        servizi.forEach(ss => { serviziMap.set(ss.WGC_Famiglia__c, ss.Label); });

        let activeItems = [];

        if (items.length == 0 && lockedItems.length > 0) {
            activeItems = lockedItems.map(i => {return i.name;});
            items = lockedItems;
            allRevisione = true;
        }
        else {
            if (lockedItems.length > 0) {
                lockedItems.forEach(i => {i.isRevisione = true;});
                items = lockedItems.concat(items);
            }
            if (items[0].area == "Factoring - Cedente")
                if (valutazioniPortafoglioMap.get(items[0].name))
                    activeItems.push(items[0].name);
                else
                    activeItems = items.filter(i => {return i.area == "Factoring - Cedente";}).map(i => {return i.name;});
            else{
                //Modificato per gestire il reload in caso di CC aggiunto dai prodotti Corporate
                // console.log('@@@')
                activeItems.push(selectedItems.find(i => { return i.isActive} ) != undefined ? selectedItems.find(i => { return i.isActive; }).name : items[0].name )
                // activeItems.push(items[0].name);
            }
        }

        console.log('@@@ activeItems ' , activeItems);

        items.forEach((i, n) => {
            var tmp = JSON.parse(JSON.stringify(i));
            var isJoined = []; // array that will contains the items already joined with a product/service

            jla.forEach(j => {
                j.servizi.forEach(s => {
                    if (codiciCoppia.find(cc => {return cc.debitore == j.debitore && s == serviziMap.get(cc.servizio);}) == undefined) {
                        if (s == serviziMap.get(i.name) && debitoriMap[j.debitore])
                            isJoined.push(this.isCompleted(jla, debitoriMap[j.debitore], debitoriNewFieldsMap[j.debitore]));
                        // else if (j.servizi.length == 0)
                        //     isJoined.push(false);
                    }
                })
            });

            tmp.hasValPort = (i.codice == "Confirming" || i.codice == "AtdConProrogaConfirming" ? true : (valutazioniPortafoglioMap.get(serviziMap.get(i.name)) ? true : false));
            
            tmp.isClickable = true;
            tmp.isSelected = true; // (tmp.CategoriaProdotto__c != "Factoring diretto")
            tmp.isActive = activeItems.includes(tmp.name) && !tmp.hasValPort;
            tmp.isRemovable = false;
            tmp.isCompleted = false;
            tmp.isRevisione = allRevisione ? allRevisione : i.isRevisione;
            tmp.title = tmp.name;
            tmp.subtitle = tmp.area;

            if (isJoined.length > 0)
                tmp.isCompleted = isJoined.reduce(function (start, bool) { return start && bool; }, true);
            else if (valutazioniPortafoglioMap.get(serviziMap.get(i.name)))
                tmp.isCompleted = this.isValPortCompleted(valutazioniPortafoglio.find(function(vp){ return vp.servizio == serviziMap.get(i.name); }));
            else
                tmp.isCompleted = allRevisione;
            
            if (crossSellingJSON.find(csJ => {return (csJ.product == tmp.area + "_" + tmp.name) || (csJ.product.split("_")[0] == "Factoring - Cedente" && tmp.area == csJ.product.split("_")[0]); }) != undefined )
                tmp.isCompleted = true;

            clones.push(tmp);
        });

        // AT LEAST ONE ITEM MUST BE SELECTED
        if (!clones.find(c => {return c.isActive;}))
            clones[0].isActive = true;
        
        component.set("v.selectedItems", clones);
        // h.unlockStateSpinner(component);
        // this.hideSpinner(component);
    },

    //SM-CART-REVI
    refreshItems : function(component, event) {
        // console.log("REFRESH");
        let items = component.get("v.selectedItems");
        let clones = [];
        let jla = component.get("v.joinLineaAttore");
        let debitoriMap = this.mapArrayBy(component.get("v.debitori"), "id");
        let debitoriNewFieldsMap = this.mapArrayBy(component.get("v.debitoriNewFields"), "debitore");
        // let valutazionePortafoglio = component.get("v.valutazionePortafoglio");
        let valutazioniPortafoglio = component.get("v.valutazioniPortafoglio");
        let valutazioniPortafoglioMap = new Map();
        let servizi = component.get("v.servizi");
        let serviziMap = new Map();
        let crossSellingJSON = (component.get("v.crossSellingJSON") ? JSON.parse(component.get("v.crossSellingJSON")) : []);
        let linee = (component.get("v.payload").linee ? component.get("v.payload").linee : []);
        let codiciCoppia = component.get("v.codiciCoppia");
        let factFisc = component.find("factfisc");
        let isCompletedFactFisc = false;
        try{
            isCompletedFactFisc = (factFisc != undefined ? factFisc.get("v.isCompleted") : false);
            console.log("#### factfisc: ", factFisc);
            console.log("#### isCompletedFactFisc: ", isCompletedFactFisc);
        } catch (e){
        }
        
        valutazioniPortafoglio.forEach(vp => { valutazioniPortafoglioMap.set(vp.servizio, vp); });
        servizi.forEach(ss => { serviziMap.set(ss.WGC_Famiglia__c, ss.Label); });

        items.forEach((i, n) => {
            let tmp = JSON.parse(JSON.stringify(i));
            let isJoined = []; // array that will contains the items already joined with a product/service

            jla.forEach(j => {
                j.servizi.forEach(s => {
                    if (codiciCoppia.find(cc => {return cc.debitore == j.debitore && s == serviziMap.get(cc.servizio);}) == undefined) {
                        if (s == serviziMap.get(i.name) && debitoriMap[j.debitore])
                            isJoined.push(this.isCompleted(jla, debitoriMap[j.debitore], debitoriNewFieldsMap[j.debitore]));
                        // else if (j.servizi.length == 0)
                        //     isJoined.push(false);
                    }
                })
            });

            tmp.isCompleted = (isJoined.length > 0 ? isJoined.reduce(function (start, bool) { return start && bool; }, true) : tmp.isRevisione);
            
            // else if (valutazionePortafoglio && valutazioniPortafoglio.length > 0) {
            //     if (valutazioniPortafoglio.find(function(vp){ return vp.servizio == i.Name; }) !== undefined)
            //         tmp.isCompleted = this.isValPortCompleted(valutazioniPortafoglio.find(function(vp){ return vp.servizio == i.Name; }))
            //     else
            //         tmp.isCompleted = false;
            // }
            if (crossSellingJSON.find(csJ => {return (csJ.product == tmp.area + "_" + tmp.name) || (csJ.product.split("_")[0] == "Factoring - Cedente" && tmp.area == csJ.product.split("_")[0]); }) != undefined) // CROSS SELLING PRESENTE IN CAMPO JSON
                tmp.isCompleted = true;

            if (linee.filter(l => { return l.codice.includes(tmp.codice);}).length > 0)
                tmp.isCompleted = true;

            //SM - TEN: Workaround per le linee Garanzia Internazionale Corporate Estero
            if(tmp.codice != undefined && tmp.codice.includes('GaranziaInternazionale') && linee.filter(l => { return l.codice.includes('GaranziaInternazionale')}).length > 0 ){
                tmp.isCompleted = true;
            }

            if (tmp.codice && tmp.codice.startsWith("Mutuo") && linee.find(l => {return l.codice.startsWith("Mutuo");}))
                tmp.isCompleted = true;
         
            //A.M. Gestione Mutuo VEneto Sviluppo
            if (tmp.codice && tmp.codice.startsWith("VenetoSviluppo") && linee.find(l => {return l.codice.startsWith("VenetoSviluppo");}))
                tmp.isCompleted = true;

            if (i.hasValPort && valutazioniPortafoglioMap.get(serviziMap.get(i.name)))
                tmp.isCompleted = this.isValPortCompleted(valutazioniPortafoglioMap.get(serviziMap.get(i.name)));

            if (i.area == "Factoring - Fiscale")
                tmp.isCompleted = isCompletedFactFisc;

            clones.push(tmp);
        });

        component.set("v.selectedItems", clones);
    },

    validateAndSave : function(component) {
        let itemSection = component.get("v.itemSection");
        let payload = component.get("v.payload");
        payload.debitori.forEach(d => { d.piva = d.account; });
        payload.wizardCompletato = false; // CANCELLO IL FLAG DI COMPLETAMENTO PRODOTTI SE VIENE MODIFICATA LA CONFIGURAZIONE PRODOTTI/DEBITORI
        let selectedItem = component.get("v.selectedItems").find(i => { return i.isActive; });                             
        
        switch (itemSection) {
            case "valPort":
                let selectedValPort = component.get("v.selectedValPort");
                let valPort = payload.valutazioniPortafoglio.filter(vp => {return vp.servizio != selectedValPort.servizio; });
                
                payload.joinLineaAttore.forEach(jla => {
                    jla.servizi = jla.servizi.filter(s => {return s != selectedValPort.servizio;});
                });
                payload.joinLineaAttore = payload.joinLineaAttore.filter(jla => {return jla.servizi.length > 0;});
                
                if (selectedValPort.id)
                    payload.joinLineaAttore = this.generateJoinLinea(payload, {debId: selectedValPort.id, servizio: selectedValPort.servizio});
                // payload.linee = [];
                for (let key in selectedValPort)
                    if (selectedValPort[key] == "true" || selectedValPort[key] == "false")
                        selectedValPort[key] = (selectedValPort[key] == "true");

                valPort.push(selectedValPort);
                payload.valutazioniPortafoglio = valPort;

                if (this.isBlank(selectedValPort.divisa) || this.isBlank(selectedValPort.mercato))
                    // this.fireSave(component, "c.saveWizard", payload, "servizi");
                    this.showToast(component, "Attenzione!", "Dati non completi nella Valutazione Portafoglio.", "warning");
                else {
                    let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
                    appEvent.setParams({ "method": "c.updateDebitori", "params": { payload: JSON.stringify(payload) } });
                    appEvent.fire();
                }
                
                payload.wizardCompletato = false;
                
            break;
            case "debitori":
                payload.joinLineaAttore = component.get("v.joinLineaAttore");
                let joins = [];

                let selectedItems = component.get("v.selectedItems");
                let servizi = component.get("v.servizi");
                let serviziMap = new Map();
                servizi.forEach(ss => { serviziMap.set(ss.WGC_Famiglia__c, ss.Label); });
                let valPortServices = selectedItems.filter(i => {return i.hasValPort;}).map(i => {return serviziMap.get(i.title);});
                let codiciCoppia = component.get("v.codiciCoppia");

                payload.joinLineaAttore.filter(j => {return this.isBlank(j.codiceCoppia);}).forEach(j => {j.servizi.forEach(s => {if (!joins.includes(s) && !valPortServices.includes(s)) joins.push(s);});});
                
                if (payload.valutazioniPortafoglio.find(vp => {return joins.includes(vp.servizio);})) {
                    let vpIds = payload.valutazioniPortafoglio.map(vp => {return vp.id;});
                    payload.valutazioniPortafoglio = payload.valutazioniPortafoglio.filter(vp => {return !joins.includes(vp.servizio);});
                    let vp2remove = vpIds.filter(id => {return !payload.valutazioniPortafoglio.map(vp => {return vp.id;}).includes(id);});
                    if (vp2remove.length > 0)
                        //SM-CART-REVI
                        payload.joinLineaAttore = payload.joinLineaAttore.filter(j => {return codiciCoppia.find(cc => {return cc.debitore == j.debitore && j.servizi.includes(serviziMap.get(cc.servizio));}) == undefined;}).filter(jla => {return !vp2remove.includes(jla.debitore);});
                }

                payload.valutazioniPortafoglio.forEach(vp => {
                    for (let key in vp)
                        if (vp[key] == "true" || vp[key] == "false")
                            vp[key] = (vp[key] == "true");
                });
                payload.wizardCompletato = false;
                
                // FIRE SAVE EVENT PASSING PAYLOAD
                // $A.util.removeClass(component.find("WGC_spinner"), "slds-hide");
                // console.log("SHOW SPINNER");

                // if (valutazionePortafoglio == true) {
                //     this.fireSave(component, "debitori");
                // } else {
                //     var items_isValid = this.validateAllItems(component);
                //     var debitori_isValid = this.validateAllDebitori(component);

                //     if (items_isValid && debitori_isValid)
                //         this.fireSave(component, "servizi");
                //     else
                //         if (!items_isValid)
                //             this.showToast(component, "Products Not Completed", "Some products are not completed. Please, complete them correctly before proceed.", "warning");
                //         else if (!debitori_isValid)
                //             this.showToast(component, "Debtors Not Completed", "Some debtors are not completed. Please, complete them correctly before proceed.", "warning");
                // }

                var items_isValid = this.validateAllItems(component);
                var debitori_isValid = this.validateAllDebitori(component);

                if (items_isValid && debitori_isValid) {
                    //SM-CART-REVI OLD 
                    this.fireSave(component, "c.saveWizard", payload, "servizi");

                    //SM-CART-REVI NEW
                    //this.fireCheckLineConsistency(component, payload);
                } else {
                    if (!items_isValid)
                        this.showToast(component, "Prodotti non completi", "Alcuni prodotti non sono completati correttamente. Completali prima di procedere.", "warning");
                    // else if (!debitori_isValid)
                    //     this.showToast(component, "Debitori non completi", "Alcuni prodotti non sono completati correttamente. Completali prima di procedere.", "warning");
                    if (!debitori_isValid)
                        this.showToast(component, "Debitori non completi", "Alcuni debitori non sono completati correttamente. Completali prima di procedere.", "warning");
                    }
            break;
            case "sbancario":
                let serviziBancari = component.get("v.serviziBancari");
                let isRevisione = component.get("v.isRevisione");
                let isMutuo = selectedItem.codice.startsWith("Mutuo");
                // let sbArr = (selectedItem.codice.startsWith("Mutuo") ? payload.pb : payload.pb.filter(pb => {return (pb.tipo != selectedItem.codice);}));
                let sbArr = [];                        
                //A.M. Gestione Mutuo Veneto Sviluppo                      
                let VenetoSviluppo = component.get("v.VenetoSviluppo");
                let isMutuoVS = selectedItem.codice.startsWith("VenetoSviluppo");                                            
 
                if (!isMutuoVS){                       
                serviziBancari.forEach(sb => {
                    let tmp = {};
                    let hasTipo = false;           
   
                    sb.columns.forEach(col => {      
                        if (col.value !== undefined) {                                                          
                            // if (col.name == "tipo")
                            //     sbArr = sbArr.filter(s => {return s.tipo != col.value;});
                            hasTipo = (col.name == "tipo" ? col.value : hasTipo);   
                            tmp[col.name] = col.value;
                            if (col.name == "importo" && (col.value == "" || col.value == "0" || col.value == 0))
                                tmp[col.name] = null;
                        }
                    });
                    if (hasTipo == false)
                        tmp.tipo = sb.tipo;
                    
                    if (sb.id != null && sb.id != undefined)
                        tmp.id = sb.id;
                    sbArr.push(JSON.parse(JSON.stringify(tmp)));
                }); 
                } else {
                VenetoSviluppo.forEach(sb => {
                    let tmp = {};
                    let hasTipo = false;           
   
                    sb.columns.forEach(col => {      
                        if (col.value !== undefined) {                                                                                   
                            hasTipo = (col.name == "tipo" ? col.value : hasTipo);                               
                            tmp[col.name] = col.value;
                            if (col.name == "importo" && (col.value == "" || col.value == "0" || col.value == 0))
                                tmp[col.name] = null;
                        }
                    });
                    if (hasTipo == false)
                        tmp.tipo = sb.tipo;
                    
                    if (sb.id != null && sb.id != undefined)
                        tmp.id = sb.id;
                    sbArr.push(JSON.parse(JSON.stringify(tmp)));
                });
                }
                
                console.log("@@@ sbArr: ", sbArr);
                //A.M. Gestione Mutuo Veneto Sviluppo
                let existingLinesNotFido = payload.pb.filter(pb => {return (pb.tipo.startsWith("Mutuo") != isMutuo || pb.tipo.startsWith("VenetoSviluppo") != isMutuoVS);}).filter(pb => {return pb.tipo != "Fido";});
                payload.pb = existingLinesNotFido.concat(sbArr);
                console.log("@@@ existingLinesNotFido: ", existingLinesNotFido);
                console.log("@@@ payload.pb: ", JSON.stringify(payload.pb));
                // setto il flag "fd" se presenza di prodotti Factoring per evitare la cancellazione delle informazioni già configurate
                payload.fd = component.get("v.selectedItems").concat(component.get("v.lockedItems")).reduce((start, i) => {return start || i.area == "Factoring - Cedente";}, false);
                payload.valutazioniPortafoglio.forEach(vp => {
                    for (let key in vp)
                        if (vp[key] == "true" || vp[key] == "false")
                            vp[key] = (vp[key] == "true");
                });
                payload.wizardCompletato = false;

                let importiValidi = sbArr.filter(sb => {return sb.tipo == "Fido";}).reduce((start, sb) => {return start && sb.importo > 0;}, true);
                //SM - TEN: Controllo se presente fido ed importo per Banca Corporate
                let fidiValidi = sbArr.filter(sb => { console.log('sb ' , sb); return sb.fido && ( sb.importo <= 0 || sb.importo == null); });
                if(fidiValidi.length > 0)
                    this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), 'Completa i campi obbligatori', "warning");
                else if (isRevisione && !importiValidi)
                    this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_ImportiFidoRequiredInRevisione"), "warning");
                else                               
                    this.fireSave(component, "c.saveWizard", payload, "categorie");
            break;                                           
            //SM - BANCA CORPORATE - Aggiunto il tipo di prodotto bcorporate
            case "bcorporate":
                let fields = component.get("v.CorporateOptions");
                let bcArr = [];
                let tmp = {}
                // let activeItem = component.get("v.selectedItems").filter(i => { return i.isActive; });
                fields.forEach(f => {
                    if(f.visible || f.name == 'tipo' || f.name == 'id'){
                        var tmp_index = f.name.split("_")[0];
                        tmp[tmp_index] = f.value;
                    }
                });
                
                bcArr.push(tmp);

                // console.log('@@@ bcArr ' , bcArr);
                // console.log('@@@ payload.pbc ' , payload.pbc);
                var selected = payload.pbc.find(p => { return p.tipo == bcArr[0].tipo; });
                if(selected != undefined){
                    // selected = bcArr[0];
                    payload.pbc = payload.pbc.map(p => {
                        if(p.tipo == bcArr[0].tipo){
                            p = bcArr[0];
                        }

                        return p;
                    });
                } else {
                    payload.pbc.push(bcArr[0]);
                }

                var selectedProds = component.get("v.selectedItems").map(i => { return i.codice});
                payload.pbc = payload.pbc.filter(p => { return selectedProds.includes(p.tipo) });

                console.log('@@@ payload.pbc after ' , JSON.stringify(payload.pbc));
                // payload.pbc = payload.pbc.concat(bcArr);
                // setto il flag "fd" se presenza di prodotti Factoring per evitare la cancellazione delle informazioni già configurate
                payload.fd = component.get("v.selectedItems").concat(component.get("v.lockedItems")).reduce((start, i) => {return start || i.area == "Factoring - Cedente";}, false);
                payload.valutazioniPortafoglio.forEach(vp => {
                    for (let key in vp)
                        if (vp[key] == "true" || vp[key] == "false")
                            vp[key] = (vp[key] == "true");
                });
                payload.wizardCompletato = false;
                
                //Faccio un check sui campi per verificare che siano tutti popolati
                if(fields.filter(f => { return f.visible && ( f.value == undefined || f.value == null || f.value == "" ); }).length > 0)
                    this.showToast(component, "Errore", "Completa correttamente tutti i campi obbligatori per procedere.", "error");
                else {
                    var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
                    appEvent.setParams({ "method": "c.saveCorporateLines", "params": { p: JSON.stringify(payload) } }); // , uid: uid, resolveAction: "manageCheckLines"
                    appEvent.fire();
                }

            break;
            //SM - CORPORATE ESTERO - Aggiunto il salvataggio dei prodotti di tipo Corporate Estero
            case "estero":
                let fieldsBCE = component.get("v.CorporateEsteroOptions");
                let bceArr = [];
                let tmpBCE = {}
                fieldsBCE.forEach(f => {
                    if(f.visible || f.name == 'tipo' || f.name == 'id'){
                        var tmp_index = f.name.split("_")[0];
                        tmpBCE[tmp_index] = f.value;
                    }
                });
                
                bceArr.push(tmpBCE);

                var selectedBCE = payload.pbce.find(p => { return p.tipo == bceArr[0].tipo || p.id == bceArr[0].id; });
                if(selectedBCE != undefined){
                    payload.pbce = payload.pbce.map(p => {
                        if(p.tipo == bceArr[0].tipo || p.id == bceArr[0].id){
                            p = bceArr[0];
                        }

                        return p;
                    });
                } else {
                    payload.pbce.push(bceArr[0]);
                }

                var selectedProdsBCE = component.get("v.selectedItems").map(i => { return i.subProductForm; });
                payload.pbce = payload.pbce.filter(p => { 
                    if(p.tipo.includes('GaranziaInternazionale'))
                        p.tipo = 'GaranziaInternazionale';
                    return selectedProdsBCE.includes(p.tipo)
                });

                console.log('@@@ payload.pbc after ' , JSON.stringify(payload.pbce));
                // setto il flag "fd" se presenza di prodotti Factoring per evitare la cancellazione delle informazioni già configurate
                payload.fd = component.get("v.selectedItems").concat(component.get("v.lockedItems")).reduce((start, i) => {return start || i.area == "Factoring - Cedente";}, false);
                payload.valutazioniPortafoglio.forEach(vp => {
                    for (let key in vp)
                        if (vp[key] == "true" || vp[key] == "false")
                            vp[key] = (vp[key] == "true");
                });
                payload.wizardCompletato = false;
                //SM -  BAMCA CORPORATE - 
                // this.fireSave(component, "c.saveWizard", payload, "categorie");
                
                //Faccio un check sui campi per verificare che siano tutti popolati
                if(payload.pbce.find(f => { return f.tipo == 'GaranziaInternazionale'}) != undefined && payload.pbce.find(f => { return f.tipo == 'GaranziaInternazionale' && f.durataGG > 1800 }) != undefined)
                    this.showToast(component, "Errore", "il campo Durata ha un valore massimo di 1800 Giorni", "error");
                else if(fieldsBCE.filter(f => { return f.visible && ( f.value == undefined || f.value == null || f.value == "" ); }).length > 0)
                    this.showToast(component, "Errore", "Completa correttamente tutti i campi obbligatori per procedere.", "error");
                else {
                    var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
                    appEvent.setParams({ "method": "c.saveCorporateEstero", "params": { payload: JSON.stringify(payload) } }); // , uid: uid, resolveAction: "manageCheckLines"
                    appEvent.fire();
                }
            break;
            case "findiretto":
                let plafonds = component.get("v.plafonds");
                let pfi = payload.pfi.filter(pfi => {return pfi.tipo != selectedItem.codice;});

                plafonds.forEach(plf => {
                    let tmp = {};
                    plf.columns.forEach(col => { tmp[col.name] = col.value; });
                    tmp.tipo = plf.tipo;
                    if (plf.id != null && plf.id != undefined)
                        tmp.id = plf.id;
                    pfi.push(JSON.parse(JSON.stringify(tmp)));
                });
                payload.pfi = pfi;
                // setto il flag "fd" se presenza di prodotti Factoring per evitare la cancellazione delle informazioni già configurate
                payload.fd = component.get("v.selectedItems").concat(component.get("v.lockedItems")).reduce((start, i) => {return start || i.area == "Factoring - Cedente";}, false);
                payload.wizardCompletato = false;
                
                this.fireSave(component, "c.saveWizard", payload, "categorie");
            break;
            case "cselling":
                let crossSellingJSON = (component.get("v.crossSellingJSON") ? JSON.parse(component.get("v.crossSellingJSON")) : []);
                let cs = component.get("v.crossSelling");
                //SM - TEN: 395 Modifiche cross selling
                cs.closeDate = cs.closeDate == undefined ? component.get("v.opportunityRecord").CloseDate : cs.closeDate;
                let validCS = this.getCrossSellingValidity(cs, selectedItem.area);

                if (validCS) {
                    cs.product = selectedItem.area + "_" + selectedItem.name;
                    
                    if (crossSellingJSON.find(csJ => { return csJ.product == cs.product; }) != null)
                        crossSellingJSON = crossSellingJSON.filter(csJ => { return csJ.product != cs.product; });
                    
                    crossSellingJSON.push(cs);
                    
                    let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
                    appEvent.setParams({ "method": "c.saveCrossSellingJSON", "params": { opportunityId: component.get("v.opportunityId"), crossSellingJSON: JSON.stringify(crossSellingJSON) } });
                    appEvent.fire();
                } else {
                    this.showToast(component, "Errore", "Completa correttamente tutti i campi obbligatori per procedere.", "error");
                }
                // this.fireSave(component, "c.saveCrossSellingJSON", {json: crossSellingJSON}, "servizi");
            break;
            case "factfisc":
                let factfisc = component.find("factfisc");
                let ffData = Array.isArray(factfisc) ? factfisc[factfisc.length - 1].confirm() : factfisc.confirm();
                // let uid = this.generateUID();
                // component.set("v.uid", uid);
                var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
                appEvent.setParams({ "method": "c.saveDataFactFisc", "params": { debitore: ffData.attore, opp: ffData.opp } }); // , uid: uid, resolveAction: "manageCheckLines"
                appEvent.fire();
            break;
        }
    },

    getCrossSellingValidity : function(crossSelling, area) {
        if (area == "Leasing")
            return !this.isBlank(crossSelling.amount) && !this.isBlank(crossSelling.tipologia) && !this.isBlank(crossSelling.business) && !this.isBlank(crossSelling.closeDate); // !this.isBlank(crossSelling.referente) && 
        else if (area == "Factoring - Cedente" || area == "Finanziamenti" || area == "Servizi Bancari")
            return !this.isBlank(crossSelling.closeDate); // !this.isBlank(crossSelling.referente) && 
        else if (area == "Corporate Finance")
            return !this.isBlank(crossSelling.amount) && !this.isBlank(crossSelling.closeDate); // !this.isBlank(crossSelling.referente) && 
    },

    //SM-CART-REVI
    validateAllItems : function(component) {
        var items = component.get("v.selectedItems"); console.log("items: ", items);
        var valid = items.reduce(function (validSoFar, item) { // .filter(i => {return !i.isRevisione;})
            return validSoFar && item.isCompleted;
        }, true);

        return valid;
    },

    validateAllDebitori : function(component) {
        //SM-CART-REVI
        var debitori = component.get("v.debitori"); // .filter(d => {return !d.isRevisione;})
        var newFieldsMap = this.mapArrayBy(component.get("v.debitoriNewFields"), "debitore");
        var h = this;
        let joinLineaAttore = component.get("v.joinLineaAttore");
        let codiciCoppia = component.get("v.codiciCoppia");
        let servizi = component.get("v.servizi");
        var valid = debitori.reduce(function (validSoFar, deb) {
            let hideContesto = h.hideContesto(deb, joinLineaAttore, codiciCoppia, servizi);
            return validSoFar && h.isCompleted(joinLineaAttore, deb, newFieldsMap[deb.id], null, hideContesto);
        }, true);

        return valid;
    },

    fireSave : function(component, method, payload, step) {
        var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method": method, "params": { payload: JSON.stringify(payload), step: step } });
        appEvent.fire();
    },

    toggleService : function(component, event) {
        console.log('@@@ parametri toggle ' , JSON.stringify(event.getParams()));
        var action = event.getParam("action");

        if (action == "add") {
            var valid = this.validateSelectionDebitore(component, event);
            if (valid){
                //SM-CART-REVI
                this.toggleJoin(component, event, action);
                //this.validateAndSave(component);
                //this.createJoinRevi(component, event, event.getParams());
                this.fireCheckLineConsistency(component, event.getParams());
            }
        }
        else if (action == "remove") {
            this.toggleJoin(component, event, action);
        }
    },

    validateSelectionDebitore : function(component, event) {
        var debitore = event.getParam("debitore");
        var servizio = event.getParam("servizio");
        var jlaDeb = this.mapArrayBy(component.get("v.joinLineaAttore"), "debitore")[debitore.id];
        let codiciCoppia = component.get("v.codiciCoppia");
        let servizi = component.get("v.servizi");
        let serviziMap = new Map();
        servizi.forEach(ss => { serviziMap.set(ss.WGC_Famiglia__c, ss.Label); });

        console.log('@@@ jlaDeb ' , jlaDeb);
        console.log('@@@ servizi ' , servizi);
        if (jlaDeb !== undefined) {
            var atdRuleExisting = (jlaDeb.servizi.indexOf("Acquisto a titolo definitivo") !== -1 || jlaDeb.servizi.indexOf("ATD - TiAnticipo") !== -1) && jlaDeb.servizi.indexOf("Factoring") !== -1;
            var atdRuleOne = (servizio.Label === 'Acquisto a titolo definitivo' || servizio.Label === 'ATD - TiAnticipo') && jlaDeb.servizi.indexOf("Factoring") !== -1;
            var atdRuleTwo = servizio.Label === 'Factoring' && (jlaDeb.servizi.indexOf("Acquisto a titolo definitivo") !== -1 || jlaDeb.servizi.indexOf("ATD - TiAnticipo") !== -1);

            var pctanRuleExisting = jlaDeb.servizi.indexOf("Acquisto a titolo definitivo") !== -1 && jlaDeb.servizi.indexOf("ATD - TiAnticipo") !== -1;
            var pctanRuleOne = servizio.Label === 'Acquisto a titolo definitivo' && jlaDeb.servizi.indexOf("ATD - TiAnticipo") !== -1;
            var pctanRuleTwo = servizio.Label === 'ATD - TiAnticipo' && jlaDeb.servizi.indexOf("Acquisto a titolo definitivo") !== -1;

            //A.M. Factoring MCC
            var mccRuleone = servizio.Label === 'Factoring' && jlaDeb.servizi.indexOf("Factoring MCC") !== -1;
            var mccRuletwo = servizio.Label === 'Factoring MCC' && jlaDeb.servizi.indexOf("Factoring") !== -1;
            var mccProsMat = (servizio.Label === 'Factoring MCC' || servizio.Label === 'Anticipo Crediti Futuri MCC') && (debitore.prosoluto || debitore.maturity || debitore.mercato !== '001');                    
          
            //A.M. Anticipo Crediti Futuri MCC
            var mccACFRuleone = servizio.Label === 'Anticipo Crediti futuri' && jlaDeb.servizi.indexOf("Anticipo Crediti Futuri MCC") !== -1;
            var mccACFRuletwo = servizio.Label === 'Anticipo Crediti Futuri MCC' && jlaDeb.servizi.indexOf("Anticipo Crediti futuri") !== -1;                             
                               
            var atdRuleIcarM = !(debitore.divisa === '242' && debitore.aNotifica && !debitore.maturity && debitore.mercato === '001' && debitore.dcp === debitore.plafond) && servizio.Label === 'ATD - TiAnticipo'

            let jlaDebServizi = codiciCoppia && codiciCoppia.filter(cc => {return cc.debitore == debitore.id;}).length > 0 ? jlaDeb.servizi.filter(s => {return !codiciCoppia.filter(cc => {return cc.debitore == debitore.id;}).map(cc => {return serviziMap.get(cc.servizio);}).includes(s);}) : jlaDeb.servizi;
            let solaGestioneRuleExisting = jlaDebServizi.includes('Sola Gestione');
            let solaGestioneRuleOne = servizio.Label == 'Sola Gestione' && (
                jlaDebServizi.includes('Factoring') || jlaDebServizi.includes('Acquisto a titolo definitivo') || jlaDebServizi.includes('ATD - TiAnticipo')
            );
            let solaGestioneRuleTwo = jlaDebServizi.includes('Sola Gestione') && (
                servizio.Label == 'Factoring' || servizio.Label == 'Acquisto a titolo definitivo' || servizio.Label == 'ATD - TiAnticipo'
            );

            var valid = true;

            if (atdRuleExisting || atdRuleOne || atdRuleTwo) {
                this.showToast(component, "Errore", "Non puoi associare un ATD insieme a un factoring", "error");
                valid = false;
            }
            if (pctanRuleExisting || pctanRuleOne || pctanRuleTwo) {
                this.showToast(component, "Errore", "Non puoi associare due ATD allo stesso debitore", "error");
                valid = false;
            }
            if (solaGestioneRuleExisting || solaGestioneRuleOne || solaGestioneRuleTwo) {
                this.showToast(component, "Errore", "Non puoi associare Sola Gestione e ATD o Factoring allo stesso debitore", "error");
                valid = false;
            }
            if (atdRuleIcarM) {
                this.showToast(component, "Errore", "Non puoi associare il debitore al prodotto selezionato", "error");
                valid = false;
            }
             //A.M. ticket SDHDFNZ-99947 - Rimosso controllo coesistenza linea factoring e factoring MCC
            //A.M.
            //if (mccRuleone || mccRuletwo) {
            //    this.showToast(component, "Errore", "Non puoi associare un Factoring ed un Factoring MCC allo stesso debitore", "error");
            //    valid = false;
            //} else if (mccACFRuleone || mccACFRuletwo) {
            //    this.showToast(component, "Errore", "Non puoi associare un Anticipo Crediti Futuri ed un Anticipo Crediti Futuri MCC allo stesso debitore", "error");
            //    valid = false;
            //} else 
            if (mccProsMat) {
                this.showToast(component, "Errore", "Non puoi associare un prodotto garantito MCC ad un debitore con prosoluto o maturity o estero", "error");
                valid = false;
            }
            return valid;
        } //A.M.
        else if ((servizio.Label === 'Factoring MCC' || servizio.Label === 'Anticipo Crediti Futuri MCC') && (debitore.prosoluto || debitore.maturity || debitore.mercato !== '001')) {
             this.showToast(component, "Errore", "Non puoi associare un prodotto garantito MCC ad un debitore con prosoluto o maturity o estero", "error");
             return false;
        } 
        return true;
    },

    toggleJoin : function(component, event, action) {
        var debitore = event.getParam("debitore");
        var servizio = event.getParam("servizio");
        var jla = component.get("v.joinLineaAttore");

        var jlaDeb = this.getFirstNodeByFields(jla, [{ field: "debitore", value: debitore.id }]);

        if (jlaDeb === undefined || jlaDeb === null) {
            jlaDeb = { debitore: debitore.id, servizi: [] };
            jla.push(jlaDeb);
        }

        if (action == "add") {
            if (jlaDeb.servizi.indexOf(servizio.Label) < 0) {
                jlaDeb.servizi.push(servizio.Label);
                if (servizio.Label === "ATD - TiAnticipo")
                    this.resetDebitoreATD(component, debitore);
            }
        } else if (action == "remove") {
            if (jlaDeb.servizi.indexOf(servizio.Label) >= 0)
                jlaDeb.servizi.splice(jlaDeb.servizi.indexOf(servizio.Label), 1);
        }

        component.set("v.joinLineaAttore", jla);
        this.toggleItemsCompletion(component);
    },

    resetDebitoreATD : function(component, debitore) {
        debitore.cessioneContinuativa = false;
        debitore.rotativita = false;
        debitore.momento = '';
        debitore.anticipazione = '';
        debitore.prosolutoATD = '';

        component.set("v.debitore", debitore);
    },

    addDebitore : function(component, newDeb) {
        var payload = component.get("v.payload");
        let cedente = component.get("v.accountId");
        let joinLineaAttore = component.get("v.joinLineaAttore");
        var debitoriMap = this.groupArrayBy(payload.debitori, "account");
        let pivaPerDebitore = component.get("v.pivaPerDebitore");
        let selectedItems = component.get("v.selectedItems");
        let servizi = component.get("v.servizi");
        let serviziMap = new Map();
        servizi.forEach(ss => { serviziMap.set(ss.WGC_Famiglia__c, ss.Label); });
        let valPortServices = selectedItems.filter(i => {return i.hasValPort;}).map(i => {return serviziMap.get(i.title);});
console.log("valPortServices: ", valPortServices);
        if (newDeb.Id == cedente)
            this.showToast(component, "Debitore uguale a Cedente", "Il debitore selezionato è il Cedente della pratica.", "warning");
        else if (!debitoriMap[newDeb.Id]) {
            payload.debitori.push({
                account: newDeb.Id,
                piva: newDeb.PIVA__c,
                rsociale: newDeb.Name
            });
            payload.joinLineaAttore = joinLineaAttore.filter(j => {return this.isBlank(j.codiceCoppia);});
            payload.valutazioniPortafoglio = payload.valutazioniPortafoglio.filter(vp => {
                return valPortServices.includes(vp.servizio);
            });
            payload.valutazioniPortafoglio.forEach(vp => {
                for (let key in vp)
                    if (vp[key] == "true" || vp[key] == "false")
                        vp[key] = (vp[key] == "true");
            });
            pivaPerDebitore.set(newDeb.Id, newDeb.PIVA__c);
            console.log("joinLineaAttore: ", joinLineaAttore);
            component.set("v.pivaPerDebitore", pivaPerDebitore);
            // FIRE CART_CALL_SERVER EVENT TO CALL THE ACTION ON THE CONTROLLER
            var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
            appEvent.setParams({ "method": "c.updateDebitori", "params": { payload: JSON.stringify(payload) } });
            appEvent.fire();
        } else
            this.showToast(component, "Debitore già presente", "Il debitore selezionato è già presente. Selezionare un altro debitore.", "warning");
    },

    removeDebitore : function(component, event) {
        var debitori = component.get("v.debitori");
        var payload = component.get("v.payload");
        let joinLineaAttore = component.get("v.joinLineaAttore");
        var deb2remove = event.getParam("debitore");

        // GET ALL DEBITORI EXCEPT THE REMOVING ONE
        var newDebs = debitori.filter(function (d) { return d.account != deb2remove.account; });
        payload.debitori = newDebs;
        payload.joinLineaAttore = joinLineaAttore.filter(j => {return this.isBlank(j.codiceCoppia);});
        console.log("joinLineaAttore: ", joinLineaAttore);

        var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method": "c.updateDebitori", "params": { payload: JSON.stringify(payload) } });
        appEvent.fire();
    },

    toggleItemsCompletion : function(component) {
        //SM-CART-REVI
        var items = component.get("v.selectedItems");
        var jla = component.get("v.joinLineaAttore");
        var debitoriMap = this.mapArrayBy(component.get("v.debitori"), "id"); // .filter(d => {return !d.isRevisione;})
        var debitoriNewFieldsMap = this.mapArrayBy(component.get("v.debitoriNewFields"), "debitore");
        var servizi = component.get("v.servizi");
        var serviziMap = new Map();
        let codiciCoppia = component.get("v.codiciCoppia");
        servizi.forEach(s => {
            serviziMap.set(s.WGC_Famiglia__c, s.Label);
        });
        // let vpIds = component.get("v.payload").valutazioniPortafoglio.map(vp => {return vp.id;});
// console.log("debitoriMap: ", debitoriMap);
        items.filter(function (i) { return i.area == "Factoring - Cedente" && !i.hasValPort; }).forEach(i => {
            var isJoined = [];
            jla.forEach(j => {
                j.servizi.forEach(s => {
                    if (codiciCoppia.find(cc => {return cc.debitore == j.debitore && s == serviziMap.get(cc.servizio);}) == undefined) {
                        if (s == serviziMap.get(i.name) && debitoriMap[j.debitore])
                            isJoined.push(this.isCompleted(jla, debitoriMap[j.debitore], debitoriNewFieldsMap[j.debitore]));
                        // else if (j.servizi.length == 0)
                        //     isJoined.push(false);
                    }
                })
            });
            //if (i.isRevisione != true)
                i.isCompleted = isJoined.length > 0 ? isJoined.reduce(function (start, bool) { return start && bool; }, true) : false;
        });
        component.set("v.selectedItems", items);
    },

    confirmChangeProduct : function(component, event) {
        let joinLineaAttore = component.get("v.joinLineaAttore");
        let payload = component.get("v.payload");
        let hasChangedJoins = false;
        let confirmChange = true;
// console.log("joinLineaAttore.length: ", joinLineaAttore.length);
// console.log("payload.joinLineaAttore.length: ", payload.joinLineaAttore.length);
// console.log("condition: ", joinLineaAttore.length != payload.joinLineaAttore.length);
        if (joinLineaAttore.length != payload.joinLineaAttore.length)
            hasChangedJoins = true;
        else {
            joinLineaAttore.forEach((jla, index) => {
                if (jla.debitore != payload.joinLineaAttore[index].debitore)
                    hasChangedJoins = true;
                else if (jla.servizi.length != payload.joinLineaAttore[index].servizi.length)
                    hasChangedJoins = true;
                else if (jla.servizi.every(s => {return !payload.joinLineaAttore[index].servizi.includes(s);}))
                    hasChangedJoins = true;
            });
        }
        
        if (hasChangedJoins)
            confirmChange = confirm($A.get("$Label.c.WGC_Cart_ConfirmLostChanges"));

        return confirmChange;
    },

    selectItem : function(component, event) {
        let showNext = component.get("v.showNext");
        let leavePage = true;
        let selectedItems = component.get("v.selectedItems");
        let lockedItems = component.get("v.lockedItems");
        let items = selectedItems; // .concat(lockedItems);
        let activeItemsCompleted = items.find(i => {return i.isActive && i.isCompleted;});

        let clicked = event.getParam("item");
        // var valutazionePortafoglio = component.get("v.valutazionePortafoglio");
        var section = "";
        //A.M. Gestione Mutuo Veneto Sviluppo (definizione variabile per sezione nuovo mutuo)
        var subSection = "";
        var valutazioniPortafoglio = component.get("v.valutazioniPortafoglio");
        let valutazioniPortafoglioMap = new Map();
        let serviziSelected = component.get("v.serviziSelected");
        let serviziSelectedMap = new Map();
        
        valutazioniPortafoglio.forEach(vp => { valutazioniPortafoglioMap.set(vp.servizio, vp); });
        serviziSelected.forEach(ss => { serviziSelectedMap.set(ss.WGC_Famiglia__c, ss.Label); });

        var selectedValPort = (
            valutazioniPortafoglioMap.get(serviziSelectedMap.get(clicked.name)) != null ?
            valutazioniPortafoglioMap.get(serviziSelectedMap.get(clicked.name)) :
            {divisa:"",mercato:"",aNotifica:null,maturity:null,servizio:serviziSelectedMap.get(clicked.name),tipo:"Valutazione portafoglio"}
        );
        let crossSellingJSON = (component.get("v.crossSellingJSON") ? JSON.parse(component.get("v.crossSellingJSON")) : []);
        let activeItems = [];

        if (clicked.area == "Factoring - Cedente")
            if (clicked.hasValPort)
                activeItems.push(clicked.name);
            else
                activeItems = items.filter(i => {return i.area == "Factoring - Cedente" && !i.hasValPort;}).map(i => {return i.name;});
        else
            activeItems.push(clicked.name);

        items.forEach(i => {i.isActive = activeItems.includes(i.name);});                 

        switch (clicked.area) {
            case "Factoring - Cedente":
                // section = (valutazionePortafoglio ? "valport" : "debitori");
                section = "debitori";
                break;
            case "Factoring - Debitore":
                section = "findiretto";
                break;
            case "Servizi Bancari":
                section = "sbancario";
                subSection = "sbancario";            
                break;
            default:
                if (clicked.name == "Mutuo" )
                    {section = "sbancario";
                     subSection = "sbancario";}
                else if (clicked.name == "Mutuo Veneto Sviluppo")    
                    {section = "sbancario";
                     subSection = "venetosviluppo";}                  
                else {     
                    section = "cselling";
                    let cs = crossSellingJSON.find(csJ => { return csJ.product == clicked.area + "_" + clicked.name; });
                    component.set("v.crossSelling", (cs ? cs : {}) );
                }
        }

        component.set("v.selectedValPort", selectedValPort);
        component.set("v.selectedItems", items);
        //SM-CART-REVI
        component.set("v.lockedItems", items.filter(i => {return lockedItems.map(li => {return li.codice;}).includes(i.codice);}));
        component.set("v.itemSection", section);
        component.set("v.itemSubSection", subSection);
    },

    manageNotificationAndMaturity: function(component, event) {
        // var valutazioniPortafoglio = component.get("v.valutazioniPortafoglio");
        var selectedValPort = component.get("v.selectedValPort");
        
        if (event.getSource().get("v.name") == "maturity") {
            if (event.getSource().get("v.checked") === true)
                selectedValPort.aNotifica = true;
        }
        else if (event.getSource().get("v.name") == "aNotifica") {
            if (event.getSource().get("v.checked") === false)
                selectedValPort.maturity = false;
        }

        selectedValPort[event.getSource().get("v.name")] = event.getSource().get("v.checked");

        component.set("v.selectedValPort", selectedValPort);
    },

    toggleValPort: function(component, event) { // DEPRECATED
        // var value = event.currentTarget.checked;

        // event.preventDefault();

        // component.set("v.valutazionePortafoglio", value);
        // // component.set("v.itemSection", (value === true ? "valport" : "debitori"));
        // component.set("v.itemSection", "debitori");

        // this.configureItems(component);
    },

    isValPortCompleted : function(valutazionePortafoglio) {
        return  !this.isBlank(valutazionePortafoglio.divisa) &&
                !this.isBlank(valutazionePortafoglio.mercato) &&
                !this.isBlank(valutazionePortafoglio.aNotifica) &&
                !this.isBlank(valutazionePortafoglio.maturity);
        // return valutazionePortafoglio.aNotifica;
    },

    generateJoinLinea : function(payload, joinDetails) {
        let joinLineaAttore = payload.joinLineaAttore;

        if (joinDetails != null && joinDetails != undefined) { // MANAGE AUTOADD IF ONLY ONE SERVICE
            if (joinLineaAttore.find(jla => {return jla.debitore == joinDetails.debId;}) === undefined) {
                let tmpJoin = {debitore:joinDetails.debId, servizi:[joinDetails.servizio]};
                joinLineaAttore.push(tmpJoin);
            }
        } else {
            let vpServices = payload.valutazioniPortafoglio.map(vp => {return vp.servizio;});
            joinLineaAttore.forEach(jla => {
                jla.servizi = jla.servizi.filter(s => {return !vpServices.includes(s);});
            });
            joinLineaAttore = joinLineaAttore.filter(jla => {return jla.servizi.length > 0;});
            payload.valutazioniPortafoglio.forEach(vp => {
                if (joinLineaAttore.find(function(jla){ return jla.debitore == vp.id; }) === undefined)
                    joinLineaAttore.push({debitore:vp.id, servizi:[vp.servizio]});
            });
        }
        
        return joinLineaAttore;
    },

    next : function(component) {
        let readOnly = component.get("v.readOnly");

        if (readOnly) {
            this.navigateSubWizard(component, "configuraProdotto");
        } else {
            var payload = component.get("v.payload");
            var valutazioniPortafoglio = component.get("v.valutazioniPortafoglio");
            var selectedItems = component.get("v.selectedItems");
            // var valPort = payload.valutazioniPortafoglio.find(function(vp){ return vp.servizio == selectedValPort.servizio; });
            let crossSelling = JSON.parse(component.get("v.crossSellingJSON"));
            let servizi = component.get("v.servizi");
            let serviziMap = new Map();
            let selectedNames = selectedItems.map(i => {return i.name;});
            //A.M. Gestione Mutuo Veneto Sviluppo
            let LineeVsOK = true;

            servizi.forEach(ss => { serviziMap.set(ss.Label, ss.WGC_Famiglia__c); });
                                   
            // rimuovo le "Valutazioni Portafoglio" se prodotti non più selezionati
            valutazioniPortafoglio = valutazioniPortafoglio.filter(vp => {return selectedNames.includes(serviziMap.get(vp.servizio));});

            if (valutazioniPortafoglio != null && valutazioniPortafoglio.length > 0) {
                // payload.joinLineaAttore = [];
                // payload.debitori = [];
                valutazioniPortafoglio.forEach(vp => {
                    vp.operazioneIAS = (typeof vp.operazioneIAS == "boolean" ? vp.operazioneIAS : vp.operazioneIAS == "true");
                    vp.previstaLIR = (typeof vp.previstaLIR == "boolean" ? vp.previstaLIR : vp.previstaLIR == "true");
                });
                payload.valutazioniPortafoglio = valutazioniPortafoglio;

                // if (valPort === undefined)
                //     payload.valutazioniPortafoglio.push(selectedValPort);
                // else
                //     Object.assign(valPort, selectedValPort);
            } else {
                payload.joinLineaAttore = component.get("v.joinLineaAttore").filter(j => {return this.isBlank(j.codiceCoppia);});
                payload.debitori.forEach(d => { d.piva = d.account; });
                // payload.valutazioniPortafoglio = false;
                payload.valutazioniPortafoglio = [];
            }

            if (payload.linee.find(l => {return l.codice == "Standard";}))
                payload.wizardCompletato = true;

            if (valutazioniPortafoglio != null && valutazioniPortafoglio.length > 0)
                payload.joinLineaAttore = this.generateJoinLinea(payload);

            if (!this.isBlank(crossSelling))
                payload.crossSelling = crossSelling;

            //SM - Gestione Prodotti Corporate
            var selectedProds = component.get("v.selectedItems").map(i => { return i.codice});
            payload.pbc = payload.pbc.filter(p => { return selectedProds.includes(p.tipo) });

            //SM - Gestione Prodotti Corporate Estero
            // var selectedProds = component.get("v.selectedItems").map(i => { return i.subProductForm });
            // payload.pbce = payload.pbce.filter(p => { return selectedProds.includes(p.tipo) });

            var selectedProdsBCE = component.get("v.selectedItems").map(i => { return i.subProductForm; });

            // console.log('@@@ selectedProdsBCE ' , selectedProdsBCE);
            // console.log('@@@ payload.pbce ' , payload.pbce);
            payload.pbce = payload.pbce.filter(p => { 
                if(p.tipo.includes('GaranziaInternazionale'))
                    p.tipo = 'GaranziaInternazionale';
                return selectedProdsBCE.includes(p.tipo); 
            });
            
             //A.M. Gestione Mutuo Veneto Sviluppo  
            if (payload.linee.find(f => { return f.codice.startsWith("VenetoSviluppo") }))  
             {
               if (!payload.linee.find(f => { return f.codice == 'VenetoSviluppoQuotaVs' }))
               { LineeVsOK = false;
                 this.showToast(component, "Attenzione!", "Quota Veneto Sviluppo Assente", "warning");} 
            
               if (!payload.linee.find(f => { return f.codice == 'VenetoSviluppoQuotaIfis' }))
               { LineeVsOK = false;
                 this.showToast(component, "Attenzione!", "Quota Ifis Assente", "warning")} 
             }                                 
            
            //A.M. Gestione Mutuo Veneto Sviluppo 
            if (LineeVsOK)                                  
            //SM-CART-REVI OLD
            //this.fireSave(component, "c.saveWizard", payload, "categorie");
               this.fireSave(component, "c.saveWizard", payload, "servizi");
            //component.set("v.showNext", false);
            //this.fireCheckLineConsistency(component, payload);
        }
    },

    fireCheckLineConsistency : function(component, parametri) {
        console.log('@@@ parametri ' , JSON.stringify(parametri));
        let uid = this.generateUID();
        component.set("v.uid", uid);
        var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method": "c.checkLinesConsistency", "params": { famigliaProdotto: parametri.servizio.WGC_Famiglia__c, debitore: parametri.debitore.id, optyId: component.get("v.payload").opportunityId, uid: uid, resolveAction: "manageCheckLines" } });
        appEvent.fire();
    },

    // checkRevisionRedirect : function(component) {
    //     let items = component.get("v.items");
    //     let payload = component.get("v.payload");
    //     let codiciCoppia = component.get("v.codiciCoppia");

    //     if (items.filter(i => {return !i.isRevisione;}).length == 0) {
    //         payload.linee = payload.linee.filter(l => {return l.isRevisione;});
    //         payload.debitori = payload.debitori.filter(d => {return codiciCoppia.map(cc => {return cc.debitore;}).includes(d.id);});
    //         payload.joinLineaAttore = [];// payload.joinLineaAttore.filter(jla => {return codiciCoppia.map(cc => {return cc.debitore;}).includes(jla.debitore);});

    //         this.fireSave(component, "c.saveWizard", payload, "servizi");

    //         return false;
    //     }
    //     return true;
    // },

    manageCheckLines : function(component, json) {
        console.log("manageCheckLines: ", json);
        if (this.isBlank(json.response)){
            //SM-CART-REVI Old
            //this.fireSave(component, "c.saveWizard", JSON.parse(json.payload), "servizi");
            //this.fireSave(component, "c.saveWizard", component.get("v.payload"), "debitori");
        } else {
            $A.createComponent("c:WGC_JoinDebLinea_Modal", {payload: component.get("v.payload"), availableJoins: json.response, joinLineaAttore : component.getReference("v.joinLineaAttore"), debitori : component.getReference("v.debitori")},
                function(content, status, error) {
                    if (status === "SUCCESS") {
                        let modalBody = content;
                        component.find('overlayLib').showCustomModal({
                            header: "Associa debitori",
                            body: modalBody,
                            showCloseButton: false,
                            cssClass: ""
                        });
                    }
                    else{
                        console.log('@@@ error ' , error );
                    }
            });
            
            //SM-CART-REVI NEW
            //event.setParams({"action" : "add"});
            //this.toggleService(component, event, json);

            //this.createJoinRevi(component, event, json);
            //return false;
        }
    },

    checkEsclusioneBEI : function(component, event) {
        let esclusioneBEI = component.get("v.esclusioneBEI");

        if (esclusioneBEI && event.getParam("fieldName") == "fundingBEI" && event.getParam("fieldValue") == true)
            this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_EsclusioneBEI"), "warning");
    },

    // CR Lotto 4.2 Id 315
    checkEsclusioneFondo : function(component, event) {
        let esclusionePolizzaCPI = component.get("v.esclusionePolizzaCPI");

        if (esclusionePolizzaCPI && event.getParam("fieldName") == "tipo" && event.getParam("fieldValue") == "Mutuo")
            this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_PolizzaCPI"), "warning");
    },

    reloadReadOnlyForFactFisc : function(component) {
        let readOnly = component.get("v.readOnly");
        let readOnlyConst = component.get("v.readOnlyConst");
        let currentUser = component.get("v.currentUser");
        let activeItem = component.get("v.selectedItems").find(i => {return i.isActive;})
        console.log("READONLY: ", (currentUser.Profile.Name == "IFIS - B/O Valutazione Fast Finance" && activeItem.area != "Factoring - Fiscale") || readOnlyConst);
        //component.set("v.readOnly", readOnly !== true ? (currentUser.Profile.Name == "IFIS - B/O Valutazione Fast Finance" && activeItem.area != "Factoring - Fiscale") : readOnly);
        component.set("v.readOnly", (currentUser.Profile.Name == "IFIS - B/O Valutazione Fast Finance" && activeItem.area != "Factoring - Fiscale") || readOnlyConst);
    },
                                               
    setupReadOnlyConst : function(component){
      component.set("v.readOnlyConst", component.get("v.readOnly"));                                             
	},

    //SM-CART-REVI
    /*
    createJoinRevi : function(component, event, json){
        var payload = component.get("v.payload");

        if( this.checkNeedsJoin(component, event, json, payload)){

            $A.createComponent("c:WGC_JoinDebLinea_Modal", {payload: payload, availableJoins: json},
                function(content, status, error) {
                    if (status === "SUCCESS") {
                        let modalBody = content;
                        component.find('overlayLib').showCustomModal({
                            header: "Associa debitori",
                            body: modalBody,
                            showCloseButton: true,
                            cssClass: ""
                        });
                    } else {
                        console.log('@@@ error ' , JSON.stringify(error));
                    }
            });

        } else { 
            //this.validateAndSave(component);
            var valid = this.validateSelectionDebitore(component, event)
            if(valid){
                this.fireSave(component, "c.saveWizard", payload, "categorie");
            } else {
                this.toggleJoin(component, event, "remove");
            }
        }
    },
    
    checkNeedsJoin : function(component, event, parametri, payload){
        var lockedItems = component.get("v.lockedItems");

        if(!parametri.debitore.isRevisione){
            var corrispondenza = lockedItems.find((item) =>{
                return item.name == parametri.servizio.WGC_Famiglia__c;
            });
            return corrispondenza != undefined;
        } else
            return false;
    },

    */

})