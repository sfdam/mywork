public class WGC_BilancioController {

    /*
    @AuraEnabled
    public static Boolean hasNDG(String accountId){
        Account a = [SELECT Id, Name, NDGGruppo__c FROM Account WHERE Id=:accountId];

        if(a.NDGGruppo__c == '' || a.NDGGruppo__c == null){
            return false;
        }
        else{
            return true;
        }
    }
    */

    //Metodo di callout per le chiamate al bilancio consolidato o controllante in base a tipoBilancio
    @AuraEnabled
    public static WGC_Account_Utility_Controller.ResponseBilancio callBilancioSpecial(String accountId, String tipoBilancio){
        System.debug('@@@ tipoBilancio ' + tipoBilancio);

        WGC_Account_Utility_Controller.ResponseBilancio response = WGC_Account_Utility_Controller.getBilancioRibes(accountId, tipoBilancio);
        System.debug('@@@ response Special Bilancio ' + response);

        return response;
    }

    @AuraEnabled
    public static WrapperResponse getAllDatiBilancio(String accountId, String tipoBilancio){

        System.debug('@@@ tipoBilancio ' + tipoBilancio);
        //prendo il valore dell'anno attuale e dell'anno precedente
        Integer annoAttuale = Date.today().year();
        Integer annoPrecedente = Date.today().addYears(-1).year();
        Integer annoPrecedente2 = Date.today().addYears(-2).year();

        WrapperResponse wr = new WrapperResponse();
        System.debug('@@@ wr ' + wr);

        //Stato Patrimoniale Attivo
        //Anno Corrente
        List<WGC_Bilancio__c> PA1 = [SELECT Id, Name,
                    DataFatturato__c,
                    ImmobilizzazioniMateriali__c,
                    Di_cui_terrenifabbricati__c,
                    ImmobilizzazioniImmateriali__c,
                    Altre_attivita__c,
                    Di_cui_attivita_finanziarie__c,
                    Attivita_Fisse__c,
                    Disponibilita__c,
                    Di_cui_scortemagazzino__c,
                    Liquidita_differite__c,
                    Di_cui_crediticommerciali__c,
                    Altri_crediti_bt__c,
                    Liquidita_immediate__c,
                    Attivita_Correnti__c,
                    TotaleAttivo__c,
                    // 
                    IMMOB_MATERIALI_IT_perc__c,
                    di_cui_terreni_e_fabbricati_perc__c,
                    IMMOB_IMMATERIALI_IM_perc__c,
                    ALTRE_ATTIVITA_IMMOBIL_IF_perc__c,
                    Di_cui_attivita_finanziarie_perc__c,
                    ATTIVITA_FISSE_AF_perc__c,
                    DISPONIBILITA_DI_perc__c,
                    di_cui_scorte_di_magazzino_perc__c,
                    LIQUIDITA_DIFFERITE_LD_perc__c,
                    di_cui_crediti_commerciali_perc__c,
                    altri_crediti_a_bt_perc__c,
                    LIQUIDITA_IMMEDIATE_LI_perc__c,
                    ATTIVITA_CORRENTI_AC_perc__c,
                    TOT_ATTIVO_NETTO_CI_perc__c
                    FROM WGC_Bilancio__c
                    WHERE Account__c =: accountId 
                    AND RecordType.DeveloperName =: tipoBilancio ORDER BY DataFatturato__c DESC LIMIT 3];

        TabellaBilancio tbPA = new TabellaBilancio();
        tbPA.bilancioCorrente = PA1.isEmpty() ? new WGC_Bilancio__c() : PA1.get(0);
        tbPA.bilancioPrecedente =  PA1.size() <= 1 ? new WGC_Bilancio__c() : PA1.get(1);
        tbPA.bilancioPrecedente2 =  PA1.size() <= 2 ? new WGC_Bilancio__c() : PA1.get(2);

        wr.PatrimonialeAttivo = tbPA;


        //Stato Patrimoniale Passivo
        //Anno Corrente
        List<WGC_Bilancio__c> PP1 = [SELECT Id, Name,
                    DataFatturato__c,
                    Capitale_sociale_versato_CS__c,
                    CreditiVersoSociPerVersDovuti__c,
                    Riserve__c,
                    RisultatoDiEsercizio__c,
                    Di_cui_dividendi_deliberati__c,
                    PatrimonioNetto__c,
                    FondoTrattamentoAFineRapporto__c,
                    FondiPerRischiEOneri__c,
                    Debiti_verso_soci_azionisti_mlt__c,
                    Debiti_finanz_banche_altri_mlt__c,
                    Debiti_diversi_a_mlt__c,
                    Passivit_differite__c,
                    Debiti_finanz_vs_banche_e_altri_bt_PFB__c,
                    Debiti_commerciali_a_bt__c,
                    Debiti_diversi_bt__c,
                    PassivoCorrente__c,
                    Mezzi_terzi__c,
                    TotalePassivo__c,
                    // 
                    Capitale_sociale_versato_CS_perc__c,
                    Crediti_vs_soci_perc__c,
                    Riserve_perc__c,
                    RisultatoDiEsercizio_perc__c,
                    di_cui_dividendi_deliberati_perc__c,
                    PATRIMONIO_NETTO_PN_perc__c,
                    Fondi_TFR_perc__c,
                    Fondo_rischi_e_oneri_futuri_perc__c,
                    Debiti_verso_soci_azionisti_mlt_perc__c,
                    Debiti_finanz_vs_banche_e_altri_mlt_perc__c,
                    Debiti_diversi_mlt_perc__c,
                    PASSIVITA_DIFFERITE_PD_perc__c,
                    Debiti_finanz_vs_banche_e_altri_bt_perc__c,
                    Debiti_commerciali_perc__c,
                    Debiti_diversi_bt_perc__c,
                    PASSIVITA_CORRENTI_PC_perc__c,
                    MEZZI_DI_TERZI_D_perc__c,
                    TOT_PASSIVO_E_NETTO_perc__c
                    FROM WGC_Bilancio__c 
                    WHERE Account__c =: accountId AND RecordType.DeveloperName =: tipoBilancio ORDER BY DataFatturato__c DESC LIMIT 3];

        TabellaBilancio tbPP = new TabellaBilancio();

        tbPP.bilancioCorrente = PP1.isEmpty() ? new WGC_Bilancio__c() : PP1.get(0);
        tbPP.bilancioPrecedente = PP1.size() <= 1 ? new WGC_Bilancio__c() : PP1.get(1);
        tbPP.bilancioPrecedente2 = PP1.size() <= 2 ? new WGC_Bilancio__c() : PP1.get(2);

        wr.PatrimonialePassivo = tbPP;

        //Conto Economico
        //Anno Attuale
        List<WGC_Bilancio__c> CE1 = [SELECT Id, Name, 
                        DataFatturato__c,
                        RicaviNetti__c,
                        VariazioneSemilavoratiEProdotti__c,
                        VarLavoriInCorsoSuOrdinazione__c,
                        IncrementiImmobilizPerLavoriInterni__c,
                        Prodotto_di_esercizio__c,
                        Acquisti_materiali_e_prodotti__c,
                        Var_magazzino_materie_prime__c,
                        Consumi__c,
                        CostiPerServizi__c,
                        Costi_godimenti_beni_di_terzi__c,
                        di_cui_canoni_di_leasing__c,
                        Totale_costi_da_servizi__c,
                        ValoreAggiunto__c,
                        Costi_per_salari_e_stipendi__c,
                        RisultatoOperativoLordo__c,
                        AmmortamentoImmobilizMateriali__c,
                        AccantonamentiPerRischiEOneriDiversi__c,
                        RisultatoOperativo__c,
                        Saldo_proventi_oneri_diversi__c,
                        ProventiFinanziari__c,
                        Capitalizz_attiv_immateriali__c,
                        RisultatoOperativoTotale__c,
                        InteressiEAltriOneriFinanziari__c,
                        UTILE_CORRENTE_UC__c,
                        Saldo_proventi_oneri_straordinari__c,
                        RisultatoPrimaDelleImposte__c,
                        Imposte_e_tasse__c,
                        RISULTATO_NETTO_RN__c,
                        Incremento_riduzione_patrim_netto__c,
                        RISULTATO_BILANCIO__c,
                        NumberOfEmployees__c,
                        //Percentuale
                        Ricavi_netti_di_esercizio_perc__c,
                        Var_magazzino_semilav_prod_finiti_perc__c,
                        Var_lavori_in_corso_perc__c,
                        Capitalizzaz_immobil_materiali_perc__c,
                        PRODOTTO_DI_ESERCIZIO_perc__c,
                        Acquisti_materiali_e_prodotti_perc__c,
                        Var_magazzino_materie_prime_perc__c,
                        Consumi_perc__c,
                        Costi_per_servizi_perc__c,
                        Costi_godimenti_beni_di_terzi_perc__c,
                        di_cui_canoni_di_leasing_perc__c,
                        Totale_costi_da_servizi_perc__c,
                        VALORE_AGGIUNTO_VA_perc__c,
                        Costi_per_salari_e_stipendi_perc__c,
                        RisultatoOperativoLordo_perc__c,
                        Ammortam_immob_materiali_perc__c,
                        Accanton_rischi_e_oneri_perc__c,
                        RisultatoOperativo_perc__c,
                        Saldo_proventi_oneri_diversi_perc__c,
                        di_cui_proventi_finanziari_perc__c,
                        Capitalizz_attiv_immateriali_perc__c,
                        RisultatoOperativoTotale_perc__c,
                        Oneri_finanziari_OF_perc__c,
                        UTILE_CORRENTE_UC_perc__c,
                        Saldo_proventi_oneri_straordinari_perc__c,
                        RisultatoPrimaDelleImposte_perc__c,
                        Imposte_e_tasse_perc__c,
                        RISULTATO_NETTO_RN_perc__c,
                        Incremento_riduzione_patrim_netto_perc__c,
                        RISULTATO_BILANCIO_perc__c
                        FROM WGC_Bilancio__c 
                        WHERE Account__c =: accountId AND RecordType.DeveloperName =: tipoBilancio ORDER BY DataFatturato__c DESC LIMIT 3];

        TabellaBilancio tbCE = new TabellaBilancio();
        tbCE.bilancioCorrente = CE1.isEmpty() ? new WGC_Bilancio__c() : CE1.get(0);
        tbCE.bilancioPrecedente = CE1.size() <= 1 ? new WGC_Bilancio__c() : CE1.get(1);
        tbCE.bilancioPrecedente2 = CE1.size() <= 2 ? new WGC_Bilancio__c() : CE1.get(2);

        wr.ContoEconomico = tbCE;

        //Indicatori

        //Anno Attuale

        List<WGC_Bilancio__c> Indicatori1 = [SELECT Id, Name,
                        DataFatturato__c,
                        PatrimonioNetto__c,
                        Fatturato__c,
                        EBITDA_Fatturato__c,
                        PFN_EBITDA__c,
                        PFN_Patrimonio_Netto__c,
                        Totale_passivo_Fatturato__c,
                        EBITDA_Oneri_Finanziari__c,
                        gg_Rotazione_del_cred_vs_Clienti__c,
                        gg_Rotazione_del_deb_vs_Fornitori__c,
                        gg_Rotazione_Rimanenze__c,
                        EBITDA__c,
                        Passivo_corrente_Fatturato__c,
                        Account__r.Fascia_MCC__c,
                        //Soglie
                        //KPI Finanziamenti
                        KPI_F_EBITDA_Fatturato__c,
                        KPI_F_Fascia_MCC__c,
                        KPI_F_Fatturato__c,
                        KPI_F_PFN_EBITDA__c,
                        KPI_F_PFN_Patrimonio_netto__c,
                        KPI_F_Totale_passivo_Fatturato__c,
                        //KPI Factoring Cedente
                        KPI_FC_EBITDA_Fatturato__c,
                        KPI_FC_Fatturato__c,
                        KPI_FC_GG_credito_Clienti__c,
                        KPI_FC_GG_credito_Fornitori__c,
                        KPI_FC_GG_rotazione_magazzino__c,
                        KPI_FC_Oneri_finanziari_EBITDA__c,
                        KPI_FC_Patrimonio_netto__c,
                        KPI_FC_PFN_EBITDA__c,
                        KPI_FC_PFN_Patrimonio_netto__c,
                        KPI_FC_Totale_passivo_Fatturato__c,
                        //KPI Factoring Debitore
                        KPI_FD_EBITDA__c,
                        KPI_FD_GG_credito_Clienti__c,
                        KPI_FD_GG_credito_Fornitori__c,
                        KPI_FD_GG_rotazione_magazzino__c,
                        KPI_FD_Passivo_corrente_Fatturato__c,
                        KPI_FD_Patrimonio_netto__c,
                        KPI_FD_Patrimonio_netto_Plafond__c,
                        KPI_FD_PFN_EBITDA__c,
                        KPI_FD_PFN_Patrimonio_netto__c
                        //Check
                        // KPI_Factoring_Cedente__c,
                        // KPI_Factoring_Debitore__c,
                        // KPI_Finanziamenti__c

                        FROM WGC_Bilancio__c 
                        WHERE Account__c =: accountId AND RecordType.DeveloperName =: tipoBilancio ORDER BY DataFatturato__c DESC LIMIT 3];

        TabellaBilancio tbI = new TabellaBilancio();
        tbI.bilancioCorrente = Indicatori1.isEmpty() ? new WGC_Bilancio__c() : Indicatori1.get(0);
        tbI.bilancioPrecedente = Indicatori1.size() <= 1 ? new WGC_Bilancio__c() : Indicatori1.get(1);
        tbI.bilancioPrecedente2 = Indicatori1.size() <= 2 ? new WGC_Bilancio__c() : Indicatori1.get(2);
        
        wr.Indicatori = tbI;

        //Fuori Bilancio
        List<WGC_Bilancio__c> FuoriBilancio1 = 
                        [SELECT Id, NumberOfEmployees__c,
                        DataFatturato__c   /*,TotaleGaranziePrestiti__c*/
                        FROM WGC_Bilancio__c 
                        WHERE Account__c =: accountId AND RecordType.DeveloperName =: tipoBilancio ORDER BY DataFatturato__c DESC LIMIT 3];

        // List<WGC_Bilancio__c> FuoriBilancio2 = 
        //                 [SELECT Id, NumberOfEmployees__c /*,TotaleGaranziePrestiti__c*/
        //                 FROM WGC_Bilancio__c 
        //                 WHERE Account__c =: accountId AND RecordType.DeveloperName =: tipoBilancio ORDER BY DataFatturato__c DESC LIMIT 3];

        // List<WGC_Bilancio__c> FuoriBilancio3 = 
        //                 [SELECT Id, NumberOfEmployees__c /*,TotaleGaranziePrestiti__c*/
        //                 FROM WGC_Bilancio__c 
        //                 WHERE Account__c =: accountId AND RecordType.DeveloperName =: tipoBilancio ORDER BY DataFatturato__c DESC LIMIT 3];

        TabellaBilancio tbFB = new TabellaBilancio();
        tbFB.bilancioCorrente = FuoriBilancio1.isEmpty() ? new WGC_Bilancio__c() : FuoriBilancio1.get(0);
        tbFB.bilancioPrecedente = FuoriBilancio1.size() <= 1 ? new WGC_Bilancio__c() : FuoriBilancio1.get(1);
        tbFB.bilancioPrecedente2 = FuoriBilancio1.size() <= 2 ? new WGC_Bilancio__c() : FuoriBilancio1.get(2);

        wr.FuoriBilancio = tbFB;

        //TestataBilancio
        List<WGC_Bilancio__c> testataBilancio1 = [SELECT Id, 
                                DataFatturato__c,
                                Durata_Operativa__c, Tipo_Bilancio__c
                                FROM WGC_Bilancio__c
                                WHERE Account__c =: accountId AND RecordType.DeveloperName =: tipoBilancio ORDER BY DataFatturato__c DESC LIMIT 3];

        // List<WGC_Bilancio__c> testataBilancio2 = [SELECT Id, Durata_Operativa__c, Tipo_Bilancio__c
        //                         FROM WGC_Bilancio__c
        //                         WHERE Account__c =: accountId AND RecordType.DeveloperName =: tipoBilancio ORDER BY DataFatturato__c DESC LIMIT 1];
        
        // List<WGC_Bilancio__c> testataBilancio3 = [SELECT Id, Durata_Operativa__c, Tipo_Bilancio__c
        //                         FROM WGC_Bilancio__c
        //                         WHERE Account__c =: accountId AND RecordType.DeveloperName =: tipoBilancio ORDER BY DataFatturato__c DESC LIMIT 1];
        
        TabellaBilancio testataBilancio = new TabellaBilancio();
        testataBilancio.bilancioCorrente = testataBilancio1.isEmpty() ? new WGC_Bilancio__c() : testataBilancio1.get(0);
        testataBilancio.bilancioPrecedente = testataBilancio1.size() <= 1 ? new WGC_Bilancio__c() : testataBilancio1.get(1);
        testataBilancio.bilancioPrecedente2 = testataBilancio1.size() <= 2 ? new WGC_Bilancio__c() : testataBilancio1.get(2);

        wr.TestataBilancio = testataBilancio;
        
        System.debug('@@@ Wrapper Final ' + JSON.serialize(wr));

        return wr;
    }

    @AuraEnabled
    public static Account getDataFromAccount(String ndgGruppo){
        System.debug('@@@ getDataFromAccount ' + ndgGruppo);

        Account acc = [SELECT Id, Name, NDGGruppo__c, 
                              WGC_Max_Anno_Bilancio__c, WGC_Flag_dimensionale_KPI_Bilancio__c,
                              WGC_Codice_classe_KPI_Bilancio__c, WGC_Codice_fascia_MCC_Bilancio__c, WGC_Valore_PD_Bilancio__c,
                              WGC_Codice_classe_valore_MCC__c, WGC_Codice_fascia_MCC_CR__c, WGC_Codice_classe_KPI_CR__c,
                              WGC_Motivo_flag_Ateco_non_presente__c, WGC_Motivo_flag_Ateco_non_valutabile__c, WGC_Numero_Bilanci__c, 
                              WGC_Motivo_flag_CR__c, WGC_Motivo_flag_estero__c, WGC_Motivo_flag_fatturato__c, 
                              WGC_Motivo_flag_natura_giuridica__c, WGC_Motivo_flag_numero_esercizi__c,
                              WGC_Motivo_flag_SP14_SP23__c, WGC_Motivo_flag_SP16_CE25__c, Fascia_MCC__c, WGC_Valore_PD_CR__c, WGC_Valore_KPI_CR__c
                    FROM Account
                    WHERE NDGGruppo__c =: ndgGruppo 
                    LIMIT 1];


        return acc;
    }

    public class WrapperResponse{
        @AuraEnabled
        public TabellaBilancio PatrimonialePassivo;
        @AuraEnabled
        public TabellaBilancio PatrimonialeAttivo;
        @AuraEnabled
        public TabellaBilancio ContoEconomico;
        @AuraEnabled
        public TabellaBilancio Indicatori;
        @AuraEnabled
        public TabellaBilancio FuoriBilancio;
        @AuraEnabled
        public TabellaBilancio TestataBilancio;

        @AuraEnabled
        public String msg;

        @AuraEnabled
        public Boolean success;

        public WrapperResponse(){
            this.PatrimonialeAttivo = PatrimonialeAttivo;
            this.PatrimonialePassivo = PatrimonialePassivo;
            this.ContoEconomico = ContoEconomico;
            this.Indicatori = Indicatori;
            this.FuoriBilancio = FuoriBilancio;
            this.TestataBilancio = TestataBilancio;
            this.msg = msg;
            this.success = true;
        }
    }

    public class TabellaBilancio{
        @AuraEnabled
        public WGC_Bilancio__c bilancioCorrente;
        @AuraEnabled
        public WGC_Bilancio__c bilancioPrecedente;
        @AuraEnabled
        public WGC_Bilancio__c bilancioPrecedente2;

        public TabellaBilancio(){
            this.bilancioCorrente = bilancioCorrente;
            this.bilancioPrecedente = bilancioPrecedente;
            this.bilancioPrecedente2 = bilancioPrecedente2;
        }
    }
}