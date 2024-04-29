({
	setupData : function(component) {
		let matrice = component.get("v.matriceGaranzie");
		// let listaDivise = component.get("v.listaDivise");
		let tipologie = [{value:"", label:"--seleziona--"}];
		let divise = component.get("v.divise");
		let garanzia = component.get("v.garanzia");

		matrice.forEach(m => {
			tipologie.push({value: m.CodiceKNET__c, label: m.Label});
		});

		// listaDivise.forEach(ld => {
		// 	if (ld.includes(":"))
		// 		divise.push({ value: ld.split(":")[0], label: ld.split(":")[1] });
		// 	else
		// 		divise.push({ value: "", label: ld });
		// });

		// component.set("v.divise", divise);
		component.set("v.tipologie", tipologie);
		component.set("v.garanzia", (garanzia == null ? {tipologia:"",copertura:"",linea:"",importo:null,percentualeImporto:null,divisa:(divise.length > 0 ? divise[0].value : "")} : garanzia));
	},

	validateCopertura : function(component, value) {
		let showLinea = (value != "Omnibus");
		component.set("v.showLinea", showLinea);
	},

	setupCoperture : function(component, value) {
		let matrice = component.get("v.matriceGaranzie");
		let coperture = [];
		let matRec = matrice.find(m => {
			return m.CodiceKNET__c == value;
		})

		if (matRec != undefined) {
			if (matRec.Specifica__c)
				coperture.push("Specifica");
			if (matRec.Omnibus__c)
				coperture.push("Omnibus");
		}

		component.set("v.coperture", coperture);
		component.set("v.copertureDisabled", coperture.length == 0);
	},

	setupTipoGaranzia : function(component, value, type) {
		let matrice = component.get("v.matriceGaranzie");
		let garanzia = component.get("v.garanzia");
		let codiceGaranzia = type == "tipo" ? value : garanzia.tipologia;
		let lineaGaranzia = type == "linea" ? value : garanzia.linea;
		let percGaranzia = type == "perc" ? value : garanzia.percentualeImporto;
		let tipoGaranzia = matrice.find(m => {
			return m.CodiceKNET__c == codiceGaranzia;
		}).Tipo__c;
        
		if (tipoGaranzia == "Percentuale")
			garanzia.importo = this.getImportoLineaPerPercentuale(component, lineaGaranzia, percGaranzia);
		component.set("v.tipoGaranzia", tipoGaranzia);
		component.set("v.garanzia", garanzia);
	},

	saveGaranzia : function(component) {
		let garanzia = component.get("v.garanzia");

		if (garanzia.opportunita == null || garanzia.opportunita == undefined)
			garanzia.opportunita = component.get("v.opportunityId");

		let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method" : "c.saveGaranzia" , "params" : { garanzia: garanzia, isEdit: component.get("v.isEdit") } });
        appEvent.fire();
        
        component.find('overlayLib').notifyClose();
	},

	getImportoLineaPerPercentuale : function(component, linea, percGaranzia) {
		let configurazioneLinee = component.get("v.configurazioneLinee");
		let linee = component.get("v.linee");
		let importo = 0;
		let importoLinea = (linea != null && linea != "" ? (configurazioneLinee.find(cl => {return cl.linea == linea && cl.codice == "SF6";}) ? configurazioneLinee.find(cl => {return cl.linea == linea && cl.codice == "SF6";}).valore : linee.find(l => {return l.id == linea;}).importo) : 0);
		
		if (linea != null && linea != "" && percGaranzia != 0 && percGaranzia != null)
			importo = (importoLinea * ( percGaranzia > 1 ? percGaranzia / 100 : percGaranzia )).toFixed(2);
		
		return importo;
	},

	checkValidGaranzia : function(component) {
        let garanzia = component.get("v.garanzia");
        
        //A.M. Aggiunto controllo sui prodotti di garanzia percentuale garantiti MCC differenziati per prodotti di Mutuo e di Factoring
        //linea.codice = "FactoringOrdinarioMCC" || "NotNotMCC" || "AnticipoCreditiFuturiMCC" -> Garanzia 049
        //linea.codice = "MutuoPCNSA" || "MutuoDecreto13E" || "MutuoControgarantitoMCC" || "MutuoDecretoLiquidita" || "Mutuo" || "MutuoPCNSASA"-> Garanzia 048
        let isValid2 = true
        let isValid3 = true
		//A.M. SDCHG-5167 - Nuova garanzia per MutuoSace (garanzia.tipologia == "078")
		let isValid4 = true
        let linee = component.get("v.linee");
        let lineaG = garanzia.linea;
        let LineaCod = (lineaG != null && lineaG != "" ? linee.find(ln => {return ln.id == lineaG}).codice : "");

        //let isValid = 	(garanzia.tipologia == "GARFD" ? garanzia.percentualeImporto > 0 && garanzia.percentualeImporto < 101 : garanzia.importo > 0) &&
		let isValid1 = 	((garanzia.tipologia == "GARFD" || garanzia.tipologia == "048" || garanzia.tipologia == "049" || garanzia.tipologia == "078") ? garanzia.percentualeImporto > 0 && garanzia.percentualeImporto < 101 : garanzia.importo > 0) &&
						!this.isBlank(garanzia.copertura) &&
						!this.isBlank(garanzia.tipologia) &&
						((garanzia.copertura == "Specifica" && !this.isBlank(garanzia.linea)) || garanzia.copertura == "Omnibus");
        
        if (garanzia.tipologia == "049")
           isValid2 = (LineaCod == "FactoringOrdinarioMCC" || LineaCod == "NotNotMCC" || LineaCod == "MaturityMCC" || LineaCod == "AnticipoCreditiFuturiMCC" || LineaCod == "AcfMCCNotNot" || LineaCod == "AcfNotNotBonusEdiliziMCC");
        
		//A.M. SDCHG-5167 - Nuova garanzia per MutuoSace (garanzia.tipologia == "078")
        if (garanzia.tipologia == "048")
            //A.M. Gestione Mutuo Veneto Sviluppo (garantita solo la quota Ifis) 
           isValid3 = ((LineaCod.includes('Mutuo') && LineaCod != 'MutuoSace') || LineaCod == 'VenetoSviluppoQuotaIfis');

		if (garanzia.tipologia == "078") 
           isValid4 = (LineaCod == 'MutuoSace');

        let isValid = (isValid1 && isValid2 && isValid3 && isValid4);

        component.set("v.isValidGaranzia", isValid);
	}
})