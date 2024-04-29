({
	loadTables : function(component, event, helper) {
		this.getAllBilancio(component, event, helper);
	},

	getAllBilancio : function(component, event, helper){
		var action = component.get('c.getAllDatiBilancio');
        action.setParams({
			accountId : component.get('v.recordId'),
			tipoBilancio : component.get('v.tipoBilancio')
        });
        action.setCallback(this, response => {
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue();
                console.log('@@@ risposta wrapper ' , risposta);

                this.loadPA(component, event, risposta.PatrimonialeAttivo);
                this.loadPP(component, event, risposta.PatrimonialePassivo);
                this.loadTB(component, event, risposta.TestataBilancio);
                this.loadFB(component, event, risposta.FuoriBilancio);
                this.loadCE(component, event, risposta.ContoEconomico);
                this.loadABIA(component, event, helper, risposta.Indicatori);
            }
            else{
                console.log('@@@ error wrapper ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    callBilancioSpecial : function(component, event, helper){
        var action = component.get("c.callBilancioSpecial");
        action.setParams({
            accountId : component.get("v.recordId"),
            tipoBilancio : component.get("v.tipoBilancio")
        });
        action.setCallback(this, (response) => {
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue();
                console.log('@@@ response from bilancio special ' , risposta);
                if(risposta.success){

                }
                else{
                    console.log('@@@ risposta error ' , risposta);
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({
                        "title" : "Attenzione",
                        "message" : risposta.message,
                        "type" : "Warning"
                    });
                    msg.fire();
                }
            }
            else{
                console.log('@@@ error call bilancio special ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },

	formatCurrency : function(number) {
        return (number != undefined && number != null ? new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(number) : '-');
    },

    formatPercentage : function(number) {
        number = (number != undefined && number != null ? number.toString() + "%" : "-");
        return number;
	},
	
	isBlank : function (scope) {
        return ( scope == null || scope == "" ) ? true : false;
    },


    formatString : function(number){
        return (number != undefined && number != null ? number.toString() : '-');
    },

	loadPA : function(component, event, PA){

        var lastyear = PA.bilancioCorrente.hasOwnProperty('DataFatturato__c') ? new Date(PA.bilancioCorrente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear();
        var prevyear = PA.bilancioPrecedente.hasOwnProperty('DataFatturato__c') ? new Date(PA.bilancioPrecedente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 1;
        var prevyear2 = PA.bilancioPrecedente2.hasOwnProperty('DataFatturato__c') ? new Date(PA.bilancioPrecedente2.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 2;

        component.set('v.columnsAP', [
            {label: 'Descrizione', fieldName: 'desc', type: 'text', initialWidth: 220, cellAttributes: { class: { fieldName:"cellClass" } }},
            {label: 'Bilancio ' + lastyear, fieldName: 'val1', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col1" } } },
            {label: '%', fieldName: 'perc1', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col2" } }},
            {label: 'Bilancio ' + prevyear, fieldName: 'val2', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col3" } }},
            {label: '%', fieldName: 'perc2', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col4" } }},
            {label: 'Bilancio ' + prevyear2, fieldName: 'val3', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col5" } }}
        ]);

        var results = [];

        var descriptions = [$A.get("$Label.c.WGC_IMMOB_MATERIALI_IT"),$A.get("$Label.c.WGC_di_cui_terreni_e_fabbricati"),$A.get("$Label.c.IMMOB_MATERIALI_IM"),
                            $A.get("$Label.c.WGC_ALTRE_ATTIVITA"),$A.get("$Label.c.WGC_di_cui_attivit_finanziarie"),$A.get("$Label.c.WGC_ATTIVITA_FISSE_AF"),
                            $A.get("$Label.c.WGC_DISPONIBILITA"),$A.get("$Label.c.WGC_di_cui_scorte_di_magazzino"),$A.get("$Label.c.WGC_LIQUIDITA_DIFFERITE_LD"),
                            $A.get("$Label.c.WGC_di_cui_crediti_commerciali"),$A.get("$Label.c.WGC_altri_crediti_a_b_t"),$A.get("$Label.c.WGC_LIQUIDIT_IMMEDIATE_LI"),
                            $A.get("$Label.c.WGC_ATTIVIT_CORRENTI_AC"),$A.get("$Label.c.WGC_TOT_ATTIVO_NETTO_CI")];
        
        var boldDescriptions = [$A.get("$Label.c.WGC_IMMOB_MATERIALI_IT"),$A.get("$Label.c.IMMOB_MATERIALI_IM"),$A.get("$Label.c.WGC_ALTRE_ATTIVITA"),
                                $A.get("$Label.c.WGC_ATTIVITA_FISSE_AF"),$A.get("$Label.c.WGC_DISPONIBILITA"),$A.get("$Label.c.WGC_LIQUIDITA_DIFFERITE_LD"),
                                $A.get("$Label.c.WGC_LIQUIDIT_IMMEDIATE_LI"),$A.get("$Label.c.WGC_ATTIVIT_CORRENTI_AC"),$A.get("$Label.c.WGC_TOT_ATTIVO_NETTO_CI")];
        console.log('@@@ PA ' , PA);
        if(Object.keys(PA).length != 0){

            results.push(
                { desc: descriptions[0], val1 : this.formatCurrency(PA.bilancioCorrente.ImmobilizzazioniMateriali__c) , perc1 : this.formatPercentage(PA.bilancioCorrente.IMMOB_MATERIALI_IT_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.ImmobilizzazioniMateriali__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.IMMOB_MATERIALI_IT_perc__c) , val3 : this.formatCurrency(PA.bilancioPrecedente2.ImmobilizzazioniMateriali__c) },
                { desc: descriptions[1], val1 : this.formatCurrency(PA.bilancioCorrente.Di_cui_terrenifabbricati__c) , perc1 :  this.formatPercentage(PA.bilancioCorrente.di_cui_terreni_e_fabbricati_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.Di_cui_terrenifabbricati__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.di_cui_terreni_e_fabbricati_perc__c) , val3 : this.formatCurrency(PA.bilancioPrecedente2.Di_cui_terrenifabbricati__c)},
                { desc: descriptions[2], val1 : this.formatCurrency(PA.bilancioCorrente.ImmobilizzazioniImmateriali__c)  , perc1 : this.formatPercentage(PA.bilancioCorrente.IMMOB_IMMATERIALI_IM_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.ImmobilizzazioniImmateriali__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.IMMOB_IMMATERIALI_IM_perc__c) , val3 : this.formatCurrency(PA.bilancioPrecedente2.ImmobilizzazioniImmateriali__c)},
                { desc: descriptions[3], val1 : this.formatCurrency(PA.bilancioCorrente.Altre_attivita__c) , perc1 : this.formatPercentage(PA.bilancioCorrente.ALTRE_ATTIVITA_IMMOBIL_IF_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.Altre_attivita__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.ALTRE_ATTIVITA_IMMOBIL_IF_perc__c) , val3 : this.formatCurrency(PA.bilancioPrecedente2.Altre_attivita__c)},
                { desc: descriptions[4], val1 : this.formatCurrency(PA.bilancioCorrente.Di_cui_attivita_finanziarie__c) , perc1 : this.formatPercentage(PA.bilancioCorrente.di_cui_attivita_finanziarie_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.Di_cui_attivita_finanziarie__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.di_cui_attivita_finanziarie_perc__c) , val3 : this.formatCurrency(PA.bilancioPrecedente2.Di_cui_attivita_finanziarie__c) },
                { desc: descriptions[5], val1 : this.formatCurrency(PA.bilancioCorrente.Attivita_Fisse__c) , perc1 :  this.formatPercentage(PA.bilancioCorrente.ATTIVITA_FISSE_AF_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.Attivita_Fisse__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.ATTIVITA_FISSE_AF_perc__c), val3 : this.formatCurrency(PA.bilancioPrecedente2.Attivita_Fisse__c)},
                { desc: descriptions[6], val1 : this.formatCurrency(PA.bilancioCorrente.Disponibilita__c) , perc1 : this.formatPercentage(PA.bilancioCorrente.DISPONIBILITA_DI_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.Disponibilita__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.DISPONIBILITA_DI_perc__c), val3 : this.formatCurrency(PA.bilancioPrecedente2.Disponibilita__c)},
                { desc: descriptions[7], val1 : this.formatCurrency(PA.bilancioCorrente.Di_cui_scortemagazzino__c)  , perc1 : this.formatPercentage(PA.bilancioCorrente.di_cui_scorte_di_magazzino_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.Di_cui_scortemagazzino__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.di_cui_scorte_di_magazzino_perc__c) , val3 : this.formatCurrency(PA.bilancioPrecedente2.Di_cui_scortemagazzino__c)},
                { desc: descriptions[8], val1 : this.formatCurrency(PA.bilancioCorrente.Liquidita_differite__c)  , perc1 : this.formatPercentage(PA.bilancioCorrente.LIQUIDITA_DIFFERITE_LD_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.Liquidita_differite__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.LIQUIDITA_DIFFERITE_LD_perc__c), val3 : this.formatCurrency(PA.bilancioPrecedente2.Liquidita_differite__c) },
                { desc: descriptions[9], val1 : this.formatCurrency(PA.bilancioCorrente.Di_cui_crediticommerciali__c)  , perc1 : this.formatPercentage(PA.bilancioCorrente.di_cui_crediti_commerciali_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.Di_cui_crediticommerciali__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.di_cui_crediti_commerciali_perc__c) , val3 : this.formatCurrency(PA.bilancioPrecedente2.Di_cui_crediticommerciali__c)},
                { desc: descriptions[10], val1 : this.formatCurrency(PA.bilancioCorrente.Altri_crediti_bt__c)  , perc1 :  this.formatPercentage(PA.bilancioCorrente.altri_crediti_a_bt_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.Altri_crediti_bt__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.altri_crediti_a_bt_perc__c) , val3 : this.formatCurrency(PA.bilancioPrecedente2.Altri_crediti_bt__c)},
                { desc: descriptions[11], val1 : this.formatCurrency(PA.bilancioCorrente.Liquidita_immediate__c)  , perc1 :  this.formatPercentage(PA.bilancioCorrente.Liquidita_immediate__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.Liquidita_immediate__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.Liquidita_immediate__c) , val3 : this.formatCurrency(PA.bilancioPrecedente2.Liquidita_immediate__c) },
                { desc: descriptions[12], val1 : this.formatCurrency(PA.bilancioCorrente.Attivita_Correnti__c)  , perc1 :  this.formatPercentage(PA.bilancioCorrente.ATTIVITA_CORRENTI_AC_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.Attivita_Correnti__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.ATTIVITA_CORRENTI_AC_perc__c)  , val3 : this.formatCurrency(PA.bilancioPrecedente2.Attivita_Correnti__c)},
                { desc: descriptions[13], val1 : this.formatCurrency(PA.bilancioCorrente.TotaleAttivo__c)  , perc1 : this.formatPercentage(PA.bilancioCorrente.TOT_ATTIVO_NETTO_CI_perc__c) , val2 : this.formatCurrency(PA.bilancioPrecedente.TotaleAttivo__c) , perc2: this.formatPercentage(PA.bilancioPrecedente.TOT_ATTIVO_NETTO_CI_perc__c)  , val3 : this.formatCurrency(PA.bilancioPrecedente2.TotaleAttivo__c)}
            );
            
            component.set('v.dataAP', results);
        }
        else{
            descriptions.forEach(function(item, index) {
                results.push({ desc: item, val1 : '0', perc1 : '-', val2 : '0', perc2 : '-', val3 : '0', cellClass: ( item.startsWith("di cui") || item == "Crediti vs soci" ? "desc-padding" : "" ) });
            });
    
            component.set('v.dataAP', results);
        }

        results = this.boldify(component, event, results, boldDescriptions);
        console.log('@@@ prova ap ');

        component.set("v.dataAP", results);
	},

	loadPP : function(component, event, PP){

        var lastyear = PP.bilancioCorrente.hasOwnProperty('DataFatturato__c') ? new Date(PP.bilancioCorrente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear();
        var prevyear = PP.bilancioPrecedente.hasOwnProperty('DataFatturato__c') ? new Date(PP.bilancioPrecedente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 1;
        var prevyear2 = PP.bilancioPrecedente2.hasOwnProperty('DataFatturato__c') ? new Date(PP.bilancioPrecedente2.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 2;

        component.set('v.columnsPP', [
            {label: 'Descrizione', fieldName: 'desc', type: 'text', initialWidth: 220, cellAttributes: { class: { fieldName:"cellClass" } }},
            {label: 'Bilancio ' + lastyear, fieldName: 'val1', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col1" } }},
            {label: '%', fieldName: 'perc1', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col2" } }},
            {label: 'Bilancio ' + prevyear, fieldName: 'val2', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col3" } }},
            {label: '%', fieldName: 'perc2', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col4" } }},
            {label: 'Bilancio ' + prevyear2, fieldName: 'val3', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col5" } }}
        ]);

        var results = [];
        var descriptions = [$A.get("$Label.c.WGC_Capitale_sociale_versato_CS"),$A.get("$Label.c.WGC_Crediti_vs_soci"),
                            $A.get("$Label.c.WGC_Riserve"),$A.get("$Label.c.WGC_Utile_perdita_d_esercizio_UT"),
                            $A.get("$Label.c.WGC_di_cui_dividendi_deliberati"),$A.get("$Label.c.WGC_PATRIMONIO_NETTO_PN"),
                            $A.get("$Label.c.WGC_Fondi_T_F_R"),$A.get("$Label.c.WGC_Fondo_rischi_e_oneri_futuri"),
                            $A.get("$Label.c.WGC_Debiti_verso_soci_azionisti_mlt"),$A.get("$Label.c.WGC_Debiti_finanz_vs_banche_e_altri_mlt"),
                            $A.get("$Label.c.WGC_Debiti_diversi_bt"),$A.get("$Label.c.WGC_PASSIVITA_DIFFERITE_PD"),
                            $A.get("$Label.c.WGC_Debiti_finanziari_a_bt"),$A.get("$Label.c.WGC_Debiti_commerciali_a_bt"),
                            $A.get("$Label.c.WGC_Debiti_diversi_a_bt"),$A.get("$Label.c.WGC_PASSIVITA_CORRENTI_PC"),
                            $A.get("$Label.c.WGC_MEZZI_DI_TERZI_D"),$A.get("$Label.c.WGC_TOT_PASSIVO_E_NETTO")];
        
        var boldDescriptions = [$A.get("$Label.c.WGC_PATRIMONIO_NETTO_PN"), 
                                $A.get("$Label.c.WGC_PASSIVITA_DIFFERITE_PD"), 
                                $A.get("$Label.c.WGC_PASSIVITA_CORRENTI_PC")];
        
        if(Object.keys(PP).length != 0){
            results.push(
                { desc: descriptions[0], val1 : this.formatCurrency(PP.bilancioCorrente.Capitale_sociale_versato_CS__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.Capitale_sociale_versato_CS_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.Capitale_sociale_versato_CS__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.Capitale_sociale_versato_CS_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.Capitale_sociale_versato_CS__c) },
                { desc: descriptions[1], val1 : this.formatCurrency(PP.bilancioCorrente.CreditiVersoSociPerVersDovuti__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.Crediti_vs_soci_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.CreditiVersoSociPerVersDovuti__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.Crediti_vs_soci_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.CreditiVersoSociPerVersDovuti__c)},
                { desc: descriptions[2], val1 : this.formatCurrency(PP.bilancioCorrente.Riserve__c), perc1 : this.formatPercentage(PP.bilancioCorrente.Riserve_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.Riserve__c), perc2: this.formatPercentage(PP.bilancioPrecedente.Riserve_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.Riserve__c) },
                { desc: descriptions[3], val1 : this.formatCurrency(PP.bilancioCorrente.RisultatoDiEsercizio__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.RisultatoDiEsercizio_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.RisultatoDiEsercizio__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.RisultatoDiEsercizio_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.RisultatoDiEsercizio__c) },
                { desc: descriptions[4], val1 : this.formatCurrency(PP.bilancioCorrente.Di_cui_dividendi_deliberati__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.di_cui_dividendi_deliberati_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.Di_cui_dividendi_deliberati__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.di_cui_dividendi_deliberati_perc__c), val3 : this.formatCurrency(PP.bilancioPrecedente2.Di_cui_dividendi_deliberati__c)},
                { desc: descriptions[5], val1 : this.formatCurrency(PP.bilancioCorrente.PatrimonioNetto__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.PATRIMONIO_NETTO_PN_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.PatrimonioNetto__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.PATRIMONIO_NETTO_PN_perc__c), val3 : this.formatCurrency(PP.bilancioPrecedente2.PatrimonioNetto__c)},
                { desc: descriptions[6], val1 : this.formatCurrency(PP.bilancioCorrente.FondoTrattamentoAFineRapporto__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.Fondi_TFR_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.FondoTrattamentoAFineRapporto__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.Fondi_TFR_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.FondoTrattamentoAFineRapporto__c)},
                { desc: descriptions[7], val1 : this.formatCurrency(PP.bilancioCorrente.FondiPerRischiEOneri__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.Fondo_rischi_e_oneri_futuri_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.FondiPerRischiEOneri__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.Fondo_rischi_e_oneri_futuri_perc__c), val3 : this.formatCurrency(PP.bilancioPrecedente2.FondiPerRischiEOneri__c)},
                { desc: descriptions[8], val1 : this.formatCurrency(PP.bilancioCorrente.Debiti_verso_soci_azionisti_mlt__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.Debiti_verso_soci_azionisti_mlt_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.Debiti_verso_soci_azionisti_mlt__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.Debiti_verso_soci_azionisti_mlt_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.Debiti_verso_soci_azionisti_mlt__c)},
                { desc: descriptions[9], val1 : this.formatCurrency(PP.bilancioCorrente.Debiti_finanz_banche_altri_mlt__c), perc1 : this.formatPercentage(PP.bilancioCorrente.Debiti_finanz_vs_banche_e_altri_mlt_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.Debiti_finanz_banche_altri_mlt__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.Debiti_finanz_vs_banche_e_altri_mlt_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.Debiti_finanz_banche_altri_mlt__c) },
                { desc: descriptions[10], val1 : this.formatCurrency(PP.bilancioCorrente.Debiti_diversi_a_mlt__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.Debiti_diversi_mlt_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.Debiti_diversi_a_mlt__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.Debiti_diversi_mlt_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.Debiti_diversi_a_mlt__c) },
                { desc: descriptions[11], val1 : this.formatCurrency(PP.bilancioCorrente.Passivit_differite__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.PASSIVITA_DIFFERITE_PD_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.Passivit_differite__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.PASSIVITA_DIFFERITE_PD_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.Passivit_differite__c) },
                { desc: descriptions[12], val1 : this.formatCurrency(PP.bilancioCorrente.Debiti_finanz_vs_banche_e_altri_bt_PFB__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.Debiti_finanz_vs_banche_e_altri_bt_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.Debiti_finanz_vs_banche_e_altri_bt_PFB__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.Debiti_finanz_vs_banche_e_altri_bt_perc__c), val3 : this.formatCurrency(PP.bilancioPrecedente2.Debiti_finanz_vs_banche_e_altri_bt_PFB__c) },
                { desc: descriptions[13], val1 : this.formatCurrency(PP.bilancioCorrente.Debiti_commerciali_a_bt__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.Debiti_commerciali_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.Debiti_commerciali_a_bt__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.Debiti_commerciali_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.Debiti_commerciali_a_bt__c)},
                { desc: descriptions[14], val1 : this.formatCurrency(PP.bilancioCorrente.Debiti_diversi_bt__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.Debiti_diversi_bt_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.Debiti_diversi_bt__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.Debiti_diversi_bt_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.Debiti_diversi_bt__c) },
                { desc: descriptions[15], val1 : this.formatCurrency(PP.bilancioCorrente.PassivoCorrente__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.PASSIVITA_CORRENTI_PC_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.PassivoCorrente__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.PASSIVITA_CORRENTI_PC_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.PassivoCorrente__c) },
                { desc: descriptions[16], val1 : this.formatCurrency(PP.bilancioCorrente.Mezzi_terzi__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.MEZZI_DI_TERZI_D_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.Mezzi_terzi__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.MEZZI_DI_TERZI_D_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.Mezzi_terzi__c) },
                { desc: descriptions[17], val1 : this.formatCurrency(PP.bilancioCorrente.TotalePassivo__c) , perc1 : this.formatPercentage(PP.bilancioCorrente.TOT_PASSIVO_E_NETTO_perc__c) , val2 : this.formatCurrency(PP.bilancioPrecedente.TotalePassivo__c) , perc2: this.formatPercentage(PP.bilancioPrecedente.TOT_PASSIVO_E_NETTO_perc__c) , val3 : this.formatCurrency(PP.bilancioPrecedente2.TotalePassivo__c) }
            );

            component.set('v.dataPP', results);
        }
        else{
            descriptions.forEach(function(item, index) {
                results.push({ desc: item, val1 : 0.00, perc1 : '-', val2 : 0.00, perc2 : '-', val3 : 0.00, cellClass: ( item.startsWith("di cui") || item == "Crediti vs soci" ? "desc-padding" : "" ) });
            });
    
            component.set('v.dataPP', results);
        }

        results = this.boldify(component, event, results, boldDescriptions);

        component.set("v.dataPP", results);
    },
    
    loadFB : function(component, event, FB){

        var lastyear = FB.bilancioCorrente.hasOwnProperty('DataFatturato__c') ? new Date(FB.bilancioCorrente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear();
        var prevyear = FB.bilancioPrecedente.hasOwnProperty('DataFatturato__c') ? new Date(FB.bilancioPrecedente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 1;
        var prevyear2 = FB.bilancioPrecedente2.hasOwnProperty('DataFatturato__c') ? new Date(FB.bilancioPrecedente2.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 2;

        component.set('v.columnsFB', [
            {label: 'Descrizione', fieldName: 'desc', type: 'string', initialWidth: 320, cellAttributes: { class: { fieldName:"cellClass" } }},
            {label: 'Bilancio ' + lastyear, fieldName: 'val1', type: 'number', cellAttributes : { alignment: 'right', class : { fieldName : "col1" } }},
            {label: '%', fieldName: 'perc1', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col2" } }},
            {label: 'Bilancio ' + prevyear, fieldName: 'val2', type: 'number', cellAttributes : { alignment: 'right', class : { fieldName : "col3" } }},
            {label: '%', fieldName: 'perc2', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col4" } }},
            {label: 'Bilancio ' + prevyear2, fieldName: 'val3', type: 'number', cellAttributes : { alignment: 'right', class : { fieldName : "col5" } }}
        ]);

        var results = [];
        var descriptions = [$A.get("$Label.c.WGC_Numero_Dipendenti"),$A.get("$Label.c.WGC_Totale_Garanzie_Personali_Prestate")];

        if(Object.keys(FB).length != 0){
            results.push(
                { desc: descriptions[0], val1: FB.bilancioCorrente.hasOwnProperty('NumberOfEmployees__c') ? FB.bilancioCorrente.NumberOfEmployees__c : '0.00' , perc1 : FB.bilancioCorrente.hasOwnProperty('NumberOfEmployees__c') ? FB.bilancioCorrente.NumberOfEmployees__c + '%' : '-', val2 : FB.bilancioPrecedente.hasOwnProperty('NumberOfEmployees__c') ? FB.bilancioPrecedente.NumberOfEmployees__c : '0.00', perc2: FB.bilancioPrecedente.hasOwnProperty('NumberOfEmployees__c') ? FB.bilancioPrecedente.NumberOfEmployees__c + '%' : '-', val3 : FB.bilancioPrecedente2.hasOwnProperty('NumberOfEmployees__c') ? FB.bilancioPrecedente2.NumberOfEmployees__c : '0.00'},
                { desc: descriptions[1], val1 : 0.00, perc1: '-', val2: 0.00, perc2: '-' , val3 : 0.00}
            );

            component.set('v.dataFB', results);
        }
        else{
            descriptions.forEach(function(item, index) {
                results.push({ desc: item, val1 : 0.00, perc1 : '-', val2 : 0.00, perc2 : '-', val3 : 0.00, cellClass: ( item.startsWith("di cui") || item == "Crediti vs soci" ? "desc-padding" : "" ) });
            });
    
            component.set('v.dataFB', results);
        }
    },
    
    loadTB : function(component, event, TB){

        var lastyear = TB.bilancioCorrente.hasOwnProperty('DataFatturato__c') ? new Date(TB.bilancioCorrente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear();
        var prevyear = TB.bilancioPrecedente.hasOwnProperty('DataFatturato__c') ? new Date(TB.bilancioPrecedente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 1;
        var prevyear2 = TB.bilancioPrecedente2.hasOwnProperty('DataFatturato__c') ? new Date(TB.bilancioPrecedente2.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 2;

        var anno = TB.bilancioCorrente.hasOwnProperty('DataFatturato__c') ? new Date(TB.bilancioCorrente.DataFatturato__c).toLocaleDateString('it-IT', { year: 'numeric', month: '2-digit', day: '2-digit' }) : '-';
        var anno2 = TB.bilancioCorrente.hasOwnProperty('DataFatturato__c') ? new Date(TB.bilancioPrecedente.DataFatturato__c).toLocaleDateString('it-IT', { year: 'numeric', month: '2-digit', day: '2-digit' }) : '-';
        var anno3 = TB.bilancioCorrente.hasOwnProperty('DataFatturato__c') ? new Date(TB.bilancioPrecedente2.DataFatturato__c).toLocaleDateString('it-IT', { year: 'numeric', month: '2-digit', day: '2-digit' }) : '-';

        component.set('v.columnsTB', [
            {label: 'Bilancio al', fieldName: 'desc', type: 'string', initialWidth: 320, cellAttributes: { class: { fieldName:"cellClass" } }},
            {label: anno, fieldName: 'val1', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col1" } }},
            {label: anno2, fieldName: 'val2', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col2" } }},
            {label: anno3, fieldName: 'val3', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col3" } }}
        ]);

        var results = [];
        var descriptions = [$A.get("$Label.c.WGC_Tipo_Bilancio"),$A.get("$Label.c.WGC_Durata_Operativa")];

        if(Object.keys(TB).length != 0){
            console.log('@@@ TB ' , TB);
            results.push(
                { desc: descriptions[0], val1: TB.bilancioCorrente.hasOwnProperty('Tipo_Bilancio__c') ? TB.bilancioCorrente.Tipo_Bilancio__c : '-' , val2 : TB.bilancioPrecedente.hasOwnProperty('Tipo_Bilancio__c') ? TB.bilancioPrecedente.Tipo_Bilancio__c : '-', val3 : TB.bilancioPrecedente2.hasOwnProperty('Tipo_Bilancio__c') ? TB.bilancioPrecedente2.Tipo_Bilancio__c : '-'},
                { desc: descriptions[1], val1: TB.bilancioCorrente.hasOwnProperty('Durata_Operativa__c') ? TB.bilancioCorrente.Durata_Operativa__c.toString() : '-' , val2 : TB.bilancioPrecedente.hasOwnProperty('Durata_Operativa__c') ? TB.bilancioPrecedente.Durata_Operativa__c.toString() : '-', val3 : TB.bilancioPrecedente2.hasOwnProperty('Durata_Operativa__c') ? TB.bilancioPrecedente2.Durata_Operativa__c.toString() : '-'}
            );
            component.set('v.dataTB', results);
        }
        else{
            descriptions.forEach(function(item, index) {
                results.push({ desc: item, val1 : '-', val2 : '-', val3 : '-'});
            });
    
            component.set('v.dataTB', results);
        }
	},

	loadCE : function(component, event, CE){
        var lastyear = CE.bilancioCorrente.hasOwnProperty('DataFatturato__c') ? new Date(CE.bilancioCorrente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear();
        var prevyear = CE.bilancioPrecedente.hasOwnProperty('DataFatturato__c') ? new Date(CE.bilancioPrecedente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 1;
        var prevyear2 = CE.bilancioPrecedente2.hasOwnProperty('DataFatturato__c') ? new Date(CE.bilancioPrecedente2.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 2;

        component.set('v.columnsCE', [
            {label: 'Descrizione', fieldName: 'desc', type: 'text', initialWidth: 220, cellAttributes: { class: { fieldName:"cellClass" } }},
            {label: 'Bilancio ' + lastyear, fieldName: 'lastYear', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col1" } }},
            {label: '%', fieldName: 'lastYear_perc', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col1" } }},
            {label: 'Bilancio ' + prevyear, fieldName: 'prevYear', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col2" } }},
            {label: '%', fieldName: 'prevYear_perc', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col2" } }},
            {label: 'Bilancio ' + prevyear2, fieldName: 'variation', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col3" } }},
            {label: '%', fieldName: 'variation_perc', type: 'string', cellAttributes : { alignment: 'right', class : { fieldName : "col3" } }}

        ]);

        var results = [];
        // $A.get("$Label.c.WGC_Valore_Della_Produzione"), [6]
        var descriptions = [$A.get("$Label.c.WGC_Conto_Economico"),$A.get("$Label.c.WGC_Ricavi_netti_di_esercizio"),
                            $A.get("$Label.c.WGC_Variazione_Semilavorati_Prodotti"),$A.get("$Label.c.WGC_Var_Lavori_In_Corso_Su_Ordinazione"),
                            $A.get("$Label.c.WGC_Incrementi_Immobiliz_Per_Lavori_Interni"),$A.get("$Label.c.WGC_Altri_Ricavi_Proventi"),
                            $A.get("$Label.c.WGC_Materie_Prime_Sussidiarie_Di_Consumo"),
                            $A.get("$Label.c.WGC_Var_Rim_Mat_Prime_Sussid_Consumo_Merci"),$A.get("$Label.c.WGC_Consumi"),
                            $A.get("$Label.c.WGC_Costi_Per_Servizi"),
                            $A.get("$Label.c.WGC_Costi_godimento_beni_di_terzi"),$A.get("$Label.c.WGC_Di_cui_canoni_di_Leasing"),
                            $A.get("$Label.c.WGC_Totale_costi_da_servizi"),$A.get("$Label.c.WGC_Valore_Aggiunto"),
                            $A.get("$Label.c.WGC_Costi_Del_Personale"),$A.get("$Label.c.WGC_Margine_Operativo_Lordo"),
                            $A.get("$Label.c.WGC_Ammortamento_Immobiliz_Materiali"),$A.get("$Label.c.WGC_Accantonamenti_Per_Rischi_Oneri_Diversi"),
                            $A.get("$Label.c.WGC_Margine_Operativo_Netto"),$A.get("$Label.c.WGC_Saldo_Proventi_Oneri_Diversi"),
                            $A.get("$Label.c.WGC_di_cui_Proventi_Finanziari"),$A.get("$Label.c.WGC_Capitalizz_Attiv_Immater"),
                            $A.get("$Label.c.WGC_Margine_Operativo_Totale"),$A.get("$Label.c.WGC_Interessi_E_Altri_Oneri_Finanziari"),
                            $A.get("$Label.c.WGC_Utile_Corrente"),$A.get("$Label.c.WGC_Saldo_Proventi_Oneri_Straordinari"),
                            $A.get("$Label.c.WGC_Risultato_Prima_Delle_Imposte"),$A.get("$Label.c.WGC_Imposte_e_Tasse"),
                            $A.get("$Label.c.WGC_Reddito_Netto"),$A.get("$Label.c.WGC_Variazione_Patrimonio_Netto"),
                            $A.get("$Label.c.WGC_Risultato_Di_Bilancio")];

        var boldDescriptions = [$A.get("$Label.c.WGC_Ricavi_netti_di_esercizio"), $A.get("$Label.c.WGC_Valore_Della_Produzione"),
                                $A.get("$Label.c.WGC_Valore_Aggiunto"),$A.get("$Label.c.WGC_Margine_Operativo_Lordo"),
                                $A.get("$Label.c.WGC_Margine_Operativo_Netto"),$A.get("$Label.c.WGC_Margine_Operativo_Totale"),
                                $A.get("$Label.c.WGC_Risultato_Prima_Delle_Imposte"),$A.get("$Label.c.WGC_Utile_Corrente"),
                                $A.get("$Label.c.WGC_Reddito_Netto"),$A.get("$Label.c.WGC_Risultato_Di_Bilancio")];

        console.log('@@@ CE ' , CE);        
        if(Object.keys(CE).length != 0){
            results.push(
                { desc: descriptions[0], lastYear : "", lastYear_perc: "", prevYear : "", prevYear_perc : "", variation : "", variation_perc : "" },
                { desc: descriptions[1], lastYear : this.formatCurrency(CE.bilancioCorrente.RicaviNetti__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Ricavi_netti_di_esercizio_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.RicaviNetti__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Ricavi_netti_di_esercizio_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.RicaviNetti__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Ricavi_netti_di_esercizio_perc__c) },
                { desc: descriptions[2], lastYear : this.formatCurrency(CE.bilancioCorrente.VariazioneSemilavoratiEProdotti__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Var_magazzino_semilav_prod_finiti_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.VariazioneSemilavoratiEProdotti__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Var_magazzino_semilav_prod_finiti_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.VariazioneSemilavoratiEProdotti__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Var_magazzino_semilav_prod_finiti_perc__c) },
                { desc: descriptions[3], lastYear : this.formatCurrency(CE.bilancioCorrente.VarLavoriInCorsoSuOrdinazione__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Var_lavori_in_corso_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.VarLavoriInCorsoSuOrdinazione__c) , prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Var_lavori_in_corso_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.VarLavoriInCorsoSuOrdinazione__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Var_lavori_in_corso_perc__c) },
                { desc: descriptions[4], lastYear : this.formatCurrency(CE.bilancioCorrente.IncrementiImmobilizPerLavoriInterni__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Capitalizzaz_immobil_materiali_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.IncrementiImmobilizPerLavoriInterni__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Capitalizzaz_immobil_materiali_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.IncrementiImmobilizPerLavoriInterni__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Capitalizzaz_immobil_materiali_perc__c) },
                { desc: descriptions[5], lastYear : this.formatCurrency(CE.bilancioCorrente.Prodotto_di_esercizio__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.PRODOTTO_DI_ESERCIZIO_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Prodotto_di_esercizio__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.PRODOTTO_DI_ESERCIZIO_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Prodotto_di_esercizio__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.PRODOTTO_DI_ESERCIZIO_perc__c) },
                //{ desc: descriptions[6], lastYear : this.formatCurrency(CE.bilancioCorrente.Prodotto_di_esercizio__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Acquisti_materiali_e_prodotti_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Acquisti_materiali_e_prodotti__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Acquisti_materiali_e_prodotti_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Acquisti_materiali_e_prodotti__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Acquisti_materiali_e_prodotti_perc__c) },
                { desc: descriptions[6], lastYear : this.formatCurrency(CE.bilancioCorrente.Acquisti_materiali_e_prodotti__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Acquisti_materiali_e_prodotti_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Acquisti_materiali_e_prodotti__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Acquisti_materiali_e_prodotti_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Acquisti_materiali_e_prodotti__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Acquisti_materiali_e_prodotti_perc__c) },
                { desc: descriptions[7], lastYear : this.formatCurrency(CE.bilancioCorrente.Var_magazzino_materie_prime__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Var_magazzino_materie_prime_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Var_magazzino_materie_prime__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Var_magazzino_materie_prime_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Var_magazzino_materie_prime__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Var_magazzino_materie_prime_perc__c)},
                { desc: descriptions[8], lastYear : this.formatCurrency(CE.bilancioCorrente.Consumi__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Consumi_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Consumi__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Consumi_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Consumi__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Consumi_perc__c)},
                { desc: descriptions[9], lastYear : this.formatCurrency(CE.bilancioCorrente.CostiPerServizi__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Costi_per_servizi_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.CostiPerServizi__c) , prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Costi_per_servizi_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.CostiPerServizi__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Costi_per_servizi_perc__c) },
                { desc: descriptions[10], lastYear : this.formatCurrency(CE.bilancioCorrente.Costi_godimenti_beni_di_terzi__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Costi_godimenti_beni_di_terzi_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Costi_godimenti_beni_di_terzi__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Costi_godimenti_beni_di_terzi_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Costi_godimenti_beni_di_terzi__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Costi_godimenti_beni_di_terzi_perc__c) },
                { desc: descriptions[11], lastYear : this.formatCurrency(CE.bilancioCorrente.di_cui_canoni_di_leasing__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.di_cui_canoni_di_leasing_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.di_cui_canoni_di_leasing__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.di_cui_canoni_di_leasing_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.di_cui_canoni_di_leasing__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.di_cui_canoni_di_leasing_perc__c) },
                { desc: descriptions[12], lastYear : this.formatCurrency(CE.bilancioCorrente.Totale_costi_da_servizi__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Totale_costi_da_servizi_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Totale_costi_da_servizi__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Totale_costi_da_servizi_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Totale_costi_da_servizi__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Totale_costi_da_servizi_perc__c) },
                { desc: descriptions[13], lastYear : this.formatCurrency(CE.bilancioCorrente.ValoreAggiunto__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.VALORE_AGGIUNTO_VA_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.ValoreAggiunto__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.VALORE_AGGIUNTO_VA_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.ValoreAggiunto__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.VALORE_AGGIUNTO_VA_perc__c) },
                { desc: descriptions[14], lastYear : this.formatCurrency(CE.bilancioCorrente.Costi_per_salari_e_stipendi__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Costi_per_salari_e_stipendi_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Costi_per_salari_e_stipendi__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Costi_per_salari_e_stipendi_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Costi_per_salari_e_stipendi__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Costi_per_salari_e_stipendi_perc__c) },
                { desc: descriptions[15], lastYear : this.formatCurrency(CE.bilancioCorrente.RisultatoOperativoLordo__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.RisultatoOperativoLordo_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.RisultatoOperativoLordo__c) , prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.RisultatoOperativoLordo_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.RisultatoOperativoLordo__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.RisultatoOperativoLordo_perc__c) },
                { desc: descriptions[16], lastYear : this.formatCurrency(CE.bilancioCorrente.AmmortamentoImmobilizMateriali__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Ammortam_immob_materiali_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.AmmortamentoImmobilizMateriali__c) , prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Ammortam_immob_materiali_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.AmmortamentoImmobilizMateriali__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Ammortam_immob_materiali_perc__c) },
                { desc: descriptions[17], lastYear : this.formatCurrency(CE.bilancioCorrente.AccantonamentiPerRischiEOneriDiversi__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Accanton_rischi_e_oneri_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.AccantonamentiPerRischiEOneriDiversi__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Accanton_rischi_e_oneri_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.AccantonamentiPerRischiEOneriDiversi__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Accanton_rischi_e_oneri_perc__c) },
                { desc: descriptions[18], lastYear : this.formatCurrency(CE.bilancioCorrente.RisultatoOperativo__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.RisultatoOperativo_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.RisultatoOperativo__c) , prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.RisultatoOperativo_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.RisultatoOperativo__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.RisultatoOperativo_perc__c) },
                { desc: descriptions[19], lastYear : this.formatCurrency(CE.bilancioCorrente.Saldo_proventi_oneri_diversi__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Saldo_proventi_oneri_diversi_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Saldo_proventi_oneri_diversi__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Saldo_proventi_oneri_diversi_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Saldo_proventi_oneri_diversi__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Saldo_proventi_oneri_diversi_perc__c) },
                { desc: descriptions[20], lastYear : this.formatCurrency(CE.bilancioCorrente.ProventiFinanziari__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.di_cui_proventi_finanziari_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.ProventiFinanziari__c) , prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.di_cui_proventi_finanziari_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.ProventiFinanziari__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.di_cui_proventi_finanziari_perc__c) },
                { desc: descriptions[21], lastYear : this.formatCurrency(CE.bilancioCorrente.Capitalizz_attiv_immateriali__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Capitalizz_attiv_immateriali_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Capitalizz_attiv_immateriali__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Capitalizz_attiv_immateriali_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Capitalizz_attiv_immateriali__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Capitalizz_attiv_immateriali_perc__c) },
                { desc: descriptions[22], lastYear : this.formatCurrency(CE.bilancioCorrente.RisultatoOperativoTotale__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.RisultatoOperativoTotale_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.RisultatoOperativoTotale__c) , prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.RisultatoOperativoTotale_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.RisultatoOperativoTotale__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.RisultatoOperativoTotale_perc__c) },
                { desc: descriptions[23], lastYear : this.formatCurrency(CE.bilancioCorrente.InteressiEAltriOneriFinanziari__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Oneri_finanziari_OF_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.InteressiEAltriOneriFinanziari__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Oneri_finanziari_OF_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.InteressiEAltriOneriFinanziari__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Oneri_finanziari_OF_perc__c) },
                { desc: descriptions[24], lastYear : this.formatCurrency(CE.bilancioCorrente.UTILE_CORRENTE_UC__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.UTILE_CORRENTE_UC_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.UTILE_CORRENTE_UC__c) , prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.UTILE_CORRENTE_UC_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.UTILE_CORRENTE_UC__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.UTILE_CORRENTE_UC_perc__c) },
                { desc: descriptions[25], lastYear : this.formatCurrency(CE.bilancioCorrente.Saldo_proventi_oneri_straordinari__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Saldo_proventi_oneri_straordinari_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Saldo_proventi_oneri_straordinari__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Saldo_proventi_oneri_straordinari_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Saldo_proventi_oneri_straordinari__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Saldo_proventi_oneri_straordinari_perc__c) },
                { desc: descriptions[26], lastYear : this.formatCurrency(CE.bilancioCorrente.RisultatoPrimaDelleImposte__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.RisultatoPrimaDelleImposte_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.RisultatoPrimaDelleImposte__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.RisultatoPrimaDelleImposte_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.RisultatoPrimaDelleImposte__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.RisultatoPrimaDelleImposte_perc__c) },
                { desc: descriptions[27], lastYear : this.formatCurrency(CE.bilancioCorrente.Imposte_e_tasse__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Imposte_e_tasse_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Imposte_e_tasse__c) , prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Imposte_e_tasse_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Imposte_e_tasse__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Imposte_e_tasse_perc__c) },
                { desc: descriptions[28], lastYear : this.formatCurrency(CE.bilancioCorrente.RISULTATO_NETTO_RN__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.RISULTATO_NETTO_RN_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.RISULTATO_NETTO_RN__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.RISULTATO_NETTO_RN_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.RISULTATO_NETTO_RN__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.RISULTATO_NETTO_RN_perc__c) },
                { desc: descriptions[29], lastYear : this.formatCurrency(CE.bilancioCorrente.Incremento_riduzione_patrim_netto__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.Incremento_riduzione_patrim_netto_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.Incremento_riduzione_patrim_netto__c) , prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.Incremento_riduzione_patrim_netto_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.Incremento_riduzione_patrim_netto__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.Incremento_riduzione_patrim_netto_perc__c) },
                { desc: descriptions[30], lastYear : this.formatCurrency(CE.bilancioCorrente.RISULTATO_BILANCIO__c), lastYear_perc : this.formatPercentage(CE.bilancioCorrente.RISULTATO_BILANCIO_perc__c), prevYear : this.formatCurrency(CE.bilancioPrecedente.RISULTATO_BILANCIO__c), prevYear_perc : this.formatPercentage(CE.bilancioPrecedente.RISULTATO_BILANCIO_perc__c), variation : this.formatCurrency(CE.bilancioPrecedente2.RISULTATO_BILANCIO__c), variation_perc : this.formatPercentage(CE.bilancioPrecedente2.RISULTATO_BILANCIO_perc__c) }
            );

            component.set('v.dataCE', results);
        }
        else{
            descriptions.forEach(function(item, index) {
                results.push({ desc: item, lastYear : '-', prevYear : '-', variation : '-'});
            });
    
            component.set('v.dataCE', results);
        }

        results = this.boldify(component, event, results, boldDescriptions);

        component.set("v.dataCE", results);
	},

	loadABIA : function(component, event, helper, indicatori){
        var lastyear = indicatori.bilancioCorrente.hasOwnProperty('DataFatturato__c') ? new Date(indicatori.bilancioCorrente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear();
        var prevyear = indicatori.bilancioPrecedente.hasOwnProperty('DataFatturato__c') ? new Date(indicatori.bilancioPrecedente.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 1;
        var prevyear2 = indicatori.bilancioPrecedente2.hasOwnProperty('DataFatturato__c') ? new Date(indicatori.bilancioPrecedente2.DataFatturato__c).getFullYear() : '-';//.getFullYear();//initialDate.getFullYear() - 2;

        component.set('v.columnsABIA', [
            {label: 'Descrizione', fieldName: 'desc', type: 'string', initialWidth: 330, cellAttributes:{ class:{ fieldName:"cellClass" } }},
            {label: 'Bilancio ' + lastyear, fieldName: 'lastYear', type: 'string', cellAttributes:{ alignment: 'right', class:{ fieldName:"col1" } }},
            {label: 'Bilancio ' + prevyear, fieldName: 'prevYear', type: 'string', cellAttributes: { alignment: 'right', class:{ fieldName:"col2" } }},
            {label: 'Bilancio ' + prevyear2, fieldName: 'variation', type: 'string', cellAttributes: { alignment: 'right', class:{ fieldName: 'col3' } }}
        ]);

        var results = [];
        



        var descriptions = [$A.get("$Label.c.WGC_KPI_Factoring_Cedente"),$A.get("$Label.c.WGC_EBITDA_Fatturato"),
                            $A.get("$Label.c.WGC_Fatturato"),$A.get("$Label.c.WGC_GG_credito_Clienti"),
                            $A.get("$Label.c.WGC_GG_credito_Fornitori"),$A.get("$Label.c.WGC_GG_rotazione_magazzino"),
                            $A.get("$Label.c.WGC_Oneri_finanziari_EBITDA"),$A.get("$Label.c.WGC_Patrimonio_netto"),
                            $A.get("$Label.c.WGC_PFN_EBITDA"),$A.get("$Label.c.WGC_PFN_Patrimonio_netto"),
                            $A.get("$Label.c.WGC_Totale_passivo_Fatturato"),$A.get("$Label.c.WGC_KPI_Factoring_Debitore"),
                            $A.get("$Label.c.WGC_EBITDA"),$A.get("$Label.c.WGC_GG_credito_Clienti"),
                            $A.get("$Label.c.WGC_GG_credito_Fornitori"),$A.get("$Label.c.WGC_GG_rotazione_magazzino"),
                            $A.get("$Label.c.WGC_Passivo_corrente_Fatturato"),$A.get("$Label.c.WGC_Patrimonio_netto"),
                            $A.get("$Label.c.WGC_Patrimonio_netto_Plafond"),$A.get("$Label.c.WGC_PFN_EBITDA"),
                            $A.get("$Label.c.WGC_PFN_Patrimonio_netto"),$A.get("$Label.c.WGC_KPI_Finanziamenti"),
                            $A.get("$Label.c.WGC_EBITDA_Fatturato"),/*$A.get("$Label.c.WGC_Fascia_MCC"),*/$A.get("$Label.c.WGC_Fatturato"),
                            $A.get("$Label.c.WGC_PFN_EBITDA"),$A.get("$Label.c.WGC_PFN_Patrimonio_netto"),$A.get("$Label.c.WGC_Totale_passivo_Fatturato")];
        
        console.log('@@@ indicatori ' , indicatori);
        console.log('@@@ indicatori ' , indicatori.bilancioPrecedente);

        if(Object.keys(indicatori).length != 0){
            results.push(
                { desc: descriptions[0], lastYear : "", prevYear : "", variation : "" },
                { desc: descriptions[1], lastYear : this.formatString(indicatori.bilancioCorrente.EBITDA_Fatturato__c), prevYear : this.formatString(indicatori.bilancioPrecedente.EBITDA_Fatturato__c) , variation : this.formatString(indicatori.bilancioPrecedente2.EBITDA_Fatturato__c) },
                { desc: descriptions[2], lastYear : this.formatCurrency(indicatori.bilancioCorrente.Fatturato__c), prevYear : this.formatCurrency(indicatori.bilancioPrecedente.Fatturato__c) , variation : this.formatCurrency(indicatori.bilancioPrecedente2.Fatturato__c) },
                { desc: descriptions[3], lastYear : this.formatString(indicatori.bilancioCorrente.gg_Rotazione_del_cred_vs_Clienti__c), prevYear : this.formatString(indicatori.bilancioPrecedente.gg_Rotazione_del_cred_vs_Clienti__c) , variation : this.formatString(indicatori.bilancioPrecedente2.gg_Rotazione_del_cred_vs_Clienti__c) },
                { desc: descriptions[4], lastYear : this.formatString(indicatori.bilancioCorrente.gg_Rotazione_del_deb_vs_Fornitori__c), prevYear : this.formatString(indicatori.bilancioPrecedente.gg_Rotazione_del_deb_vs_Fornitori__c) , variation : this.formatString(indicatori.bilancioPrecedente2.gg_Rotazione_del_deb_vs_Fornitori__c) },
                { desc: descriptions[5], lastYear : this.formatString(indicatori.bilancioCorrente.gg_Rotazione_Rimanenze__c), prevYear : this.formatString(indicatori.bilancioPrecedente.gg_Rotazione_Rimanenze__c) , variation : this.formatString(indicatori.bilancioPrecedente2.gg_Rotazione_Rimanenze__c) },
                { desc: descriptions[6], lastYear : this.formatString(indicatori.bilancioCorrente.EBITDA_Oneri_Finanziari__c), prevYear : this.formatString(indicatori.bilancioPrecedente.EBITDA_Oneri_Finanziari__c) , variation : this.formatString(indicatori.bilancioPrecedente2.EBITDA_Oneri_Finanziari__c) },
                { desc: descriptions[7], lastYear : this.formatCurrency(indicatori.bilancioCorrente.PatrimonioNetto__c), prevYear : this.formatCurrency(indicatori.bilancioPrecedente.PatrimonioNetto__c), variation : this.formatCurrency(indicatori.bilancioPrecedente2.PatrimonioNetto__c) },
                { desc: descriptions[8], lastYear : this.formatString(indicatori.bilancioCorrente.PFN_EBITDA__c), prevYear : this.formatString(indicatori.bilancioPrecedente.PFN_EBITDA__c) , variation : this.formatString(indicatori.bilancioPrecedente2.PFN_EBITDA__c) },
                { desc: descriptions[9], lastYear : this.formatString(indicatori.bilancioCorrente.PFN_Patrimonio_Netto__c), prevYear : this.formatString(indicatori.bilancioPrecedente.PFN_Patrimonio_Netto__c) , variation : this.formatString(indicatori.bilancioPrecedente2.PFN_Patrimonio_Netto__c) },
                { desc: descriptions[10], lastYear : this.formatString(indicatori.bilancioCorrente.Totale_passivo_Fatturato__c), prevYear : this.formatString(indicatori.bilancioPrecedente.Totale_passivo_Fatturato__c) , variation : this.formatString(indicatori.bilancioPrecedente2.Totale_passivo_Fatturato__c) },
                { desc: '' , lastYear : "", prevYear : "", variation : ""},
                { desc: descriptions[11] , lastYear : "", prevYear : "", variation : ""},
                { desc: descriptions[12], lastYear : this.formatCurrency(indicatori.bilancioCorrente.EBITDA__c), prevYear : this.formatCurrency(indicatori.bilancioPrecedente.EBITDA__c) , variation : this.formatCurrency(indicatori.bilancioPrecedente2.EBITDA__c) },
                { desc: descriptions[13], lastYear : this.formatString(indicatori.bilancioCorrente.gg_Rotazione_del_cred_vs_Clienti__c), prevYear : this.formatString(indicatori.bilancioPrecedente.gg_Rotazione_del_cred_vs_Clienti__c) , variation : this.formatString(indicatori.bilancioPrecedente2.gg_Rotazione_del_cred_vs_Clienti__c) },
                { desc: descriptions[14], lastYear : this.formatString(indicatori.bilancioCorrente.gg_Rotazione_del_deb_vs_Fornitori__c), prevYear : this.formatString(indicatori.bilancioPrecedente.gg_Rotazione_del_deb_vs_Fornitori__c) , variation : this.formatString(indicatori.bilancioPrecedente2.gg_Rotazione_del_deb_vs_Fornitori__c) },
                { desc: descriptions[15], lastYear : this.formatString(indicatori.bilancioCorrente.gg_Rotazione_Rimanenze__c), prevYear : this.formatString(indicatori.bilancioPrecedente.gg_Rotazione_Rimanenze__c) , variation : this.formatString(indicatori.bilancioPrecedente2.gg_Rotazione_Rimanenze__c) },
                { desc: descriptions[16], lastYear : this.formatString(indicatori.bilancioCorrente.Passivo_corrente_Fatturato__c), prevYear : this.formatString(indicatori.bilancioPrecedente.Passivo_corrente_Fatturato__c) , variation : this.formatString(indicatori.bilancioPrecedente2.Passivo_corrente_Fatturato__c) },
                { desc: descriptions[17], lastYear : this.formatCurrency(indicatori.bilancioCorrente.PatrimonioNetto__c), prevYear : this.formatCurrency(indicatori.bilancioPrecedente.PatrimonioNetto__c) , variation : this.formatCurrency(indicatori.bilancioPrecedente2.PatrimonioNetto__c) },
                { desc: descriptions[18], lastYear : this.formatString(indicatori.bilancioCorrente.PatrimonioNetto_Plafond__c), prevYear : this.formatString(indicatori.bilancioPrecedente.PatrimonioNetto_Plafond__c) , variation : this.formatString(indicatori.bilancioPrecedente2.PatrimonioNetto_Plafond__c) },
                { desc: descriptions[19], lastYear : this.formatString(indicatori.bilancioCorrente.PFN_EBITDA__c), prevYear : this.formatString(indicatori.bilancioPrecedente.PFN_EBITDA__c) , variation : this.formatString(indicatori.bilancioPrecedente2.PFN_EBITDA__c) },
                { desc: descriptions[20], lastYear : this.formatString(indicatori.bilancioCorrente.PFN_Patrimonio_Netto__c), prevYear : this.formatString(indicatori.bilancioPrecedente.PFN_Patrimonio_Netto__c) , variation : this.formatString(indicatori.bilancioPrecedente2.PFN_Patrimonio_Netto__c) },
                { desc: '' , lastYear : "", prevYear : "", variation : ""},
                { desc: descriptions[21], lastYear : "", prevYear : "", variation : "" },
                { desc: descriptions[22], lastYear : this.formatString(indicatori.bilancioCorrente.EBITDA_Fatturato__c), prevYear : this.formatString(indicatori.bilancioPrecedente.EBITDA_Fatturato__c) , variation : this.formatString(indicatori.bilancioPrecedente2.EBITDA_Fatturato__c) },
                //{ desc: descriptions[23], lastYear : (indicatori.bilancioCorrente.Account__r != undefined ? this.formatString(indicatori.bilancioPrecedente.Account__r.Fascia_MCC__c) : '-' ), prevYear : (indicatori.bilancioPrecedente.Account__r != undefined ? this.formatString(indicatori.bilancioPrecedente.Account__r.Fascia_MCC__c) : '-' ) , variation : (indicatori.bilancioPrecedente.Account__r != undefined ? this.formatString(indicatori.bilancioPrecedente.Account__r.Fascia_MCC__c) : '-' ) },
                //{ desc: descriptions[23], lastYear : (indicatori.bilancioCorrente.Account__r != undefined ? this.formatString(indicatori.bilancioCorrente.Account__r.Fascia_MCC__c) : '-' ), prevYear : '-' , variation : '-' },
                { desc: descriptions[23], lastYear : this.formatCurrency(indicatori.bilancioCorrente.Fatturato__c), prevYear : this.formatCurrency(indicatori.bilancioPrecedente.Fatturato__c) , variation : this.formatCurrency(indicatori.bilancioPrecedente2.Fatturato__c) },
                { desc: descriptions[24], lastYear : this.formatString(indicatori.bilancioCorrente.PFN_EBITDA__c), prevYear : this.formatString(indicatori.bilancioPrecedente.PFN_EBITDA__c) , variation : this.formatString(indicatori.bilancioPrecedente2.PFN_EBITDA__c) },
                { desc: descriptions[25], lastYear : this.formatString(indicatori.bilancioCorrente.PFN_Patrimonio_Netto__c), prevYear : this.formatString(indicatori.bilancioPrecedente.PFN_Patrimonio_Netto__c) , variation : this.formatString(indicatori.bilancioPrecedente2.PFN_Patrimonio_Netto__c) },
                { desc: descriptions[26], lastYear : this.formatString(indicatori.bilancioCorrente.Totale_passivo_Fatturato__c), prevYear : this.formatString(indicatori.bilancioPrecedente.Totale_passivo_Fatturato__c) , variation : this.formatString(indicatori.bilancioPrecedente2.Totale_passivo_Fatturato__c)}
                //{ desc : '', lastYear : '', prevYear : '', variation : ''},
                //{ desc: descriptions[23], lastYear : '', prevYear : (indicatori.bilancioCorrente.Account__r != undefined ? this.formatString(indicatori.bilancioCorrente.Account__r.Fascia_MCC__c) : '-' ) , variation : '' }
            );

            component.set('v.dataABIA', results);


            //KPI Factoring Cedente
            results[1].col1 = indicatori.bilancioCorrente.KPI_FC_EBITDA_Fatturato__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[2].col1 = indicatori.bilancioCorrente.KPI_FC_Fatturato__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[3].col1 = indicatori.bilancioCorrente.KPI_FC_GG_credito_Clienti__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[4].col1 = indicatori.bilancioCorrente.KPI_FC_GG_credito_Fornitori__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[5].col1 = indicatori.bilancioCorrente.KPI_FC_GG_rotazione_magazzino__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[6].col1 = indicatori.bilancioCorrente.KPI_FC_Oneri_finanziari_EBITDA__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[7].col1 = indicatori.bilancioCorrente.KPI_FC_Patrimonio_netto__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[8].col1 = indicatori.bilancioCorrente.KPI_FC_PFN_EBITDA__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[9].col1 = indicatori.bilancioCorrente.KPI_FC_PFN_Patrimonio_netto__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[10].col1 = indicatori.bilancioCorrente.KPI_FC_Totale_passivo_Fatturato__c == 'V' ? 'green bold-desc bck-grey' : 'red bold-desc bck-grey';
            results[10].col2 = 'bck-grey';
            results[10].col3 = 'bck-grey';
            results[10].cellClass = 'bck-grey';
            //KPI Factoring Debitore
            results[13].col1 = indicatori.bilancioCorrente.KPI_FD_EBITDA__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[14].col1 = indicatori.bilancioCorrente.KPI_FD_GG_credito_Clienti__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[15].col1 = indicatori.bilancioCorrente.KPI_FD_GG_credito_Fornitori__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[16].col1 = indicatori.bilancioCorrente.KPI_FD_GG_rotazione_magazzino__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[17].col1 = indicatori.bilancioCorrente.KPI_FD_Passivo_corrente_Fatturato__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[18].col1 = indicatori.bilancioCorrente.KPI_FD_Patrimonio_netto__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[19].col1 = indicatori.bilancioCorrente.KPI_FD_Patrimonio_netto_Plafond__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[20].col1 = indicatori.bilancioCorrente.KPI_FD_PFN_EBITDA__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[21].col1 = indicatori.bilancioCorrente.KPI_FD_PFN_Patrimonio_netto__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            //KPI Finanziamenti
            results[23].col1 = indicatori.bilancioCorrente.KPI_F_EBITDA_Fatturato__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[24].col1 = indicatori.bilancioCorrente.KPI_F_Fascia_MCC__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[25].col1 = indicatori.bilancioCorrente.KPI_F_Fatturato__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[26].col1 = indicatori.bilancioCorrente.KPI_F_PFN_EBITDA__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[27].col1 = indicatori.bilancioCorrente.KPI_F_PFN_Patrimonio_netto__c == 'V' ? 'green bold-desc' : 'red bold-desc';
            results[28].col1 = indicatori.bilancioCorrente.KPI_F_Totale_passivo_Fatturato__c == 'V' ? 'green bold-desc bck-grey' : 'red bold-desc bck-grey';
            results[28].col2 = 'bck-grey';
            results[28].col3 = 'bck-grey';
            results[28].cellClass = 'bck-grey';

            //DESCRIZIONE SEZIONI BOLD
            results[0].cellClass = 'bold-desc';
            results[12].cellClass = 'bold-desc';
            results[23].cellClass = 'bold-desc';
            console.log('@@@ result 12 ' , results[12]);
            console.log('@@@ result 23 ' , results[23]);
            //Riga di separazione
            // results[29].cellClass = 'separator';
            // results[29].col1 = 'separator';
            // results[29].col2 = 'separator';
            // results[29].col3 = 'separator';
            //Fascia MCC
            // results[30].cellClass = 'bold-desc';
            // results[30].col2 = 'bold-desc';
        }
        else{
            descriptions.forEach((item, index) =>{
                if(item == 'KPI Factoring Cedente' || item == 'KPI Factoring Debitore' || item == 'KPI Finanziamenti'){
                    results.push({ desc : item, lastYear: '', prevYear: '', variation: '' });
                    results.forEach((item, index) =>{
                        if(item.lastYear == '' || item.prevYear == '' || item.variation == ''){
                            item.cellClass = 'inline-header';
                        }
                    });
                }
                else{
                    results.push({desc: item, lastYear: "-", prevYear:"-", variation: "-"});
                }
            })
            component.set('v.dataABIA', results);
        }

        //Apro di default la sezione indicatori
        component.set("v.IsCollapsed", false);
    },
    
    boldify : function(component, event, elementi, descToCheck){

        elementi.forEach(function(item, index) {
            if(descToCheck.includes(item.desc)){
                item.cellClass = ' bold-desc ';
                item.col1 = 'bold-desc';
                item.col2 = 'bold-desc';
                item.col3 = 'bold-desc';
                item.col4 = 'bold-desc';
                item.col5 = 'bold-desc';
            }
            
            console.log('@@@ prova');
            console.log('@@@ item.desc ' , item.desc);
            console.log('@@@ condizione grey ' , item.desc.toLowerCase().includes('totale') || item.desc.toLowerCase().includes('tot.'));
            if(item.desc.toLowerCase().includes('totale') || item.desc.toLowerCase().includes('tot.')){
                item.cellClass = item.cellClass+' bck-grey';
                item.col1 = item.col1+' bck-grey';
                item.col2 = item.col2+' bck-grey';
                item.col3 = item.col3+' bck-grey';
                item.col4 = item.col4+' bck-grey';
                item.col5 = item.col5+' bck-grey';

                console.log('@@@ css ' , item);
            }
        });

        return elementi;
    },

    apex: function (component, event, apexAction, params) {
        var p = new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get("c." + apexAction + "");
            action.setParams(params);
            action.setCallback(this, function (callbackResult) {
                if (callbackResult.getState() == 'SUCCESS') {
                    resolve(callbackResult.getReturnValue());
                }
                if (callbackResult.getState() == 'ERROR') {
                    console.log('ERROR', callbackResult.getError());
                    reject(callbackResult.getError());
                }
            });
            $A.enqueueAction(action);
        }));
        return p;
    },
})