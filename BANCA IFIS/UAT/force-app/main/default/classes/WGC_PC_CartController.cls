public class WGC_PC_CartController {

    private final static Integer MAX_RESULTS = 5;
    public final static String idAdE = UtenzeDefault__c.getOrgDefaults().IdAgenziadelleEntrate__c;
    private final static String boProfileName = 'IFIS - B/O Valutazione Fast Finance';

    /* CART PAYLOAD */

    public class CartPayload{
        @AuraEnabled
        public String opportunityId;
        @AuraEnabled
        public Opportunity opportunityData;
        @AuraEnabled
        public CartServizio servizio;
        @AuraEnabled
        public List<CartLinea> linee;
        @AuraEnabled
        public CartJoinLineaDebitore joinLineaDeb;
        @AuraEnabled
        public List<CartDebitore> debitori;
        @AuraEnabled
        public User userInfo;
    }

    public class CartServizio{
        @AuraEnabled public String nome;
    }

    public class CartLinea{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Boolean storicitaRimborsi;
        @AuraEnabled
        public Boolean aNotifica;
        @AuraEnabled
        public String codice;
        @AuraEnabled
        public List<Credito__c> crediti;
    }

    public class CartJoinLineaDebitore{
        @AuraEnabled
        public String linea;
        @AuraEnabled
        public String attore;
        @AuraEnabled
        public String servizio;
    }

    public class CartDebitore{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String account;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String ndg;
        @AuraEnabled
        public String piva;
        @AuraEnabled
        public String divisa;
        @AuraEnabled
        public Boolean storicitaRimborsi;
    }

    /* CART PAYLOAD */

    /* GET CART DATA */

    @AuraEnabled
    public static CartPayload getPayload(String opportunityId){
        CartPayload p = new CartPayload();
        p.opportunityId = opportunityId;
        p.linee = new List<CartLinea>();
        p.opportunityData = new Opportunity();
        p.joinLineaDeb = new CartJoinLineaDebitore();
        p.debitori = new List<CartDebitore>();

        try{
            Opportunity o = [SELECT Id,
                Name,
                CloseDate,
                Probability,
                StageName,
                RecordTypeId,
                RecordType.DeveloperName,
                Originator__c,
                Originator_di_dettaglio__c,
                CreatedDate,
                WGC_Prodotti_Selezionati__c,
                OwnerId,
                Owner.Name,
                Owner.Qualifica_Utente__c,
                AccountId,
                Account.Name,
                Account.NDGGruppo__c,
                Account.WGC_Descrizione_dell_azienda__c,
                Account.WGC_Alert_KPI_Centrale_Rischi__c,
                Account.Sconfini_a_revoca__c,
                Account.Sconfini_a_revoca_Utilizzato_Accordato__c,
                Account.Sconfini_a_scadenza__c,
                Account.Sconfini_a_scadenza_Utilizzato_Accordato__c,
                Account.WGC_Alert_KPI_Eventi_negativi__c,
                Account.WGC_Semaforo_CLC__c,
                Account.WGC_Semaforo_Gianos__c,
                Account.WGC_Semaforo_CLC_Formula__c,
                Account.WGC_Semaforo_GIANOS_Formula__c,
                Account.WGC_Rating__c,
                Account.RatingT0__c,
                Account.RatingT1__c,
                Account.WGC_DataRichiestaCR__c,
                Account.WGC_Area__c,
                Account.WGC_Flag_non_affidato__c,
                Account.WGC_Data_Caricamento_BKIT__c,
                Account.Ateco__c,
                WizardCompletato__c,
                WGC_Data_Fase_In_Istruttoria__c,
                WGC_Data_out_Fase_In_Istruttoria__c,
                WGC_Data_Fase_Perfezionamento_Contratto__c,
                WGC_Data_out_Perfezionamento_Contratto__c,
                WGC_Data_Fase_Redazione_Contratto__c,
                WGC_Data_out_Fase_Redazione_Contratto__c,
                WGC_Data_Fase_Valutazione_Pratica__c,
                WGC_Data_out_Fase_Valutazione_Pratica__c,
                WGC_Data_Fase_Attivazione_Prodotto__c,
                WGC_Data_out_Fase_Attivazione_Prodotto__c,
                WGC_Data_Fase_Rinnovo__c,
                WGC_Data_Out_Fase_Rinnovo__c,
                WGC_Data_Fase_Valutazione__c,
                WGC_Data_Out_Fase_Valutazione__c,
                WGC_Data_Fase_Chiusa_Persa__c,
                IdCartella__c,
                WGC_NoteBilancio__c,
                WGC_NoteCR__c,
                WGC_NoteEventi__c,
                StatoPEF__c,
                WGC_Codice_Pratica__c,
                FaseDiCaduta__c,
                CategoriaChiusuraTrattativa__c,
                MotivoChiusuraTrattativa__c,
                WGC_Descrizione_Operativit_Proposta__c,
                WGC_Note_Condizioni_Economiche__c,
                WGC_Descrizione_concorrenza__c,
                Tipologia_Opportunit__c,
                // WGC_Prodotti_bloccati__c,
                WGC_Documenti_validi__c,
                WGC_Note_Cliente__c,
                Amount,
                WGC_Configurazione_Prodotti_Completa__c,
                WGC_Note_automatiche__c,
                WGC_Finalita_Finance__c,
                Tribunale__r.Name,
                WGC_Professionista__r.Name,
                WGC_Azienda_Cedente__c,
                Intermediario__c,
                WGC_Data_proposta__c,
                WGC_Data_omologa__c,
                WGC_Data_richiesta_estratto_di_ruolo__c,
                WGC_Data_evasione_di_ruolo__c,
                WGC_Tipologia__c,
                WGC_Data_ricorso__c,
                WGC_Data_ammissione__c,
                WGC_Data_ingresso_in_procedura__c,
                WGC_Multiproprieta__c,
                WGC_Perc_suggerita_di_acquisto__c,
                WGC_Liti_pendenti__c,
                WGC_Descrizione_liti_pendenti__c,
                WGC_Assuntore__c,
                Assuntore__c,
                Assuntore__r.Name,
                WGC_Giudice_delegato__c,
                WGC_Num_Riparti_effettuati__c,
                WGC_Num_Creditori__c,
                WGC_Data_ultimo_riparto__c,
                WGC_Ulteriori_attivi_da_realizzare__c,
                WGC_Data_presunta_decreto_chiusura__c,
                WGC_Consecutivita__c,
                WGC_Tipologia_di_consecutivita__c,
                Account.WGC_Fascia_Rischio__c,
                WGC_Invio_Mail_FF__c,
                WGC_Azienda_Cedente__r.Name,
                WGC_Sospesa__c
                FROM Opportunity WHERE Id =: opportunityId];

        Map<Id, Linea__c> linee = new Map<Id, Linea__c>([SELECT Id, Name, Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Opportunity__c =: opportunityId]);
        List<Credito__c> AllCrediti = new List<Credito__c>([SELECT Id, Name, WGC_Linea__c, WGC_Invia_Credito__c, WGC_Completo_BO__c, WGC_Completo_Commerciale__c FROM Credito__c WHERE WGC_Linea__c IN: linee.keySet()]);
        Map<String, List<Credito__c>> creditiMap = (Map<String, List<Credito__c>>) U.groupBy(allCrediti, 'WGC_Linea__c');

        List<NDGLinea__c> debitori = new List<NDGLinea__c>([SELECT Id, Account__c, Account__r.Name, Account__r.NDGGruppo__c, Account__r.PIVA__c, WGC_Storicita_Rimborsi__c, toLabel(DivisaNew__c) FROM NDGLinea__c WHERE Opportunita__c =: opportunityId AND Tipo__c = 'Debitore']);

        List<CartLinea> cartLinee = new List<CartLinea>();
        for(Linea__c l : linee.values()){
            CartLinea cl = new CartLinea();
            cl.id = l.Id;
            cl.codice = l.Prodotto__r.CodiceUnivoco__c;
            cl.crediti = creditiMap.get(l.Id) != null ? creditiMap.get(l.Id) : new List<Credito__c>();
            cartLinee.add(cl);
        }

        for(NDGLinea__c attore : debitori){
            CartDebitore cd = new CartDebitore();
            cd.id = attore.Id;
            cd.ndg = attore.Account__r.NDGGruppo__c;
            cd.account = attore.Account__c;
            cd.name = attore.Account__r.Name;
            cd.piva = attore.Account__r.PIVA__c;
            cd.divisa = attore.DivisaNew__c;
            cd.storicitaRimborsi = attore.WGC_Storicita_Rimborsi__c;

            p.debitori.add(cd);
        }

        p.userInfo = [ SELECT Id, Name, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        
        //Assegno al payload
        System.debug('@@@ opportunityData ' + o);
        p.opportunityData = o;
        p.linee = cartLinee;

        } catch(Exception e){
            System.debug('@@@ eccezione ' + e.getMessage() + ' -- ' + e.getLineNumber());
        }

        System.debug('@@@ p ' + JSON.serialize(p));
        return p;
    }

    @AuraEnabled
    public static User getUserInfo(){
        return [SELECT Id, Name, ProfileId, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
    }

    @AuraEnabled
    public static WrapperResponse getProducts(){
        WrapperResponse response = new WrapperResponse();

        List<Prodotto__c> products = new List<Prodotto__c>([SELECT Id, Name, WGC_Famiglia__c, WGC_Area__c, CodiceUnivoco__c FROM Prodotto__c WHERE CodiceUnivoco__c = 'ProceduraConcorsuale' OR CodiceUnivoco__c = 'FiscaleBonis']);
        response.data.add(products);

        return response;
    }

    /* GET CART DATA */

    public class WrapperResponse{
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }

    public class WrapperField{
        @AuraEnabled public String apiName;
        @AuraEnabled public Object value;
    }

    @AuraEnabled
    public static WrapperResponse createAttoreAgenzia(String opportunityId){
        WrapperResponse response = new WrapperResponse();

        try{
            // Id IdAnagAgenzia = UtenzeDefault__c.getOrgDefaults().IdAgenziadelleEntrate__c;
            List<NDGLinea__c> agenzia = new List<NDGLinea__c>([SELECT Id, Account__r.Name, Account__r.NDGGruppo__c FROM NDGLinea__c WHERE Opportunita__c =: opportunityId AND Tipo__c = 'Debitore' AND Account__c =: idAdE /*idAnagAgenzia*/]);

            if(agenzia.isEmpty()){
                Id recordTypeDebitoreId = [SELECT Id FROM RecordType WHERE SobjectType = 'NDGLinea__c' AND DeveloperName = 'Debitore' LIMIT 1].Id;
                NDGLinea__c newAgenzia = new NDGLinea__c(Account__c = idAdE, Opportunita__c = opportunityId, DivisaNew__c = '242', Tipo__c = 'Debitore', RecordTypeId = recordTypeDebitoreId);
                Insert newAgenzia;
            }


            response.data.add(getPayload(opportunityId));

        } catch (Exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static WrapperResponse getDatiMascheraPC(String opportunityId){
        WrapperResponse response = new WrapperResponse();

        try{
            MascheraPC mask = new MascheraPC();

            mask.opp = [SELECT Id, RecordType.DeveloperName, WGC_Azienda_Cedente__r.Name, Intermediario__r.Name, WGC_Data_proposta__c, WGC_Data_omologa_assuntore__c, WGC_Data_omologa__c,
            WGC_Data_richiesta_estratto_di_ruolo__c, WGC_Data_evasione_di_ruolo__c, WGC_Tipologia__c, WGC_Data_ricorso__c, WGC_Data_ammissione__c,
            WGC_Data_ingresso_in_procedura__c, WGC_Data_Cessazione_PIVA__c, WGC_Multiproprieta__c, WGC_Perc_suggerita_di_acquisto__c, WGC_Liti_pendenti__c, WGC_Descrizione_liti_pendenti__c, WGC_Assuntore__c,
            Assuntore__r.Name,  WGC_Giudice_delegato__c, WGC_Num_Riparti_effettuati__c, WGC_Num_Creditori__c, WGC_Data_ultimo_riparto__c, WGC_Ulteriori_attivi_da_realizzare__c,
            WGC_Data_presunta_decreto_chiusura__c, WGC_Consecutivita__c, WGC_Tipologia_di_consecutivita__c, WGC_Data_ricorso_consecutivit__c, WGC_AeR_Estratto_di_ruolo__c,
            WGC_AdE_Carichi_pendenti__c, WGC_AdE_Carichi_pendenti__r.Name, WGC_Rischio_Alto__c, WGC_Ristrutturazione_del_debito__c, WGC_Tipologia_di_ristrutturazione_debito__c, WGC_Valutatore__c, WGC_Valutatore__r.Name, WGC_Data_messa_in_Liquidazione__c,
            WGC_Ente_sovraintendente__c, WGC_Ente_sovraintendente__r.Name
            FROM Opportunity WHERE Id =: opportunityId];
            
            // Id IdAnagAgenzia = UtenzeDefault__c.getOrgDefaults().IdAgenziadelleEntrate__c;
            // SM - CR Ottobre 21 - aggiunto campo Linea_Garantita__c
            mask.attore = [SELECT Id, Account__r.Name, Account__r.NDGGruppo__c, Account__r.PIVA__c, DivisaNew__c, ANotifica__c, WGC_Storicita_Rimborsi__c, Linea_Garantita__c FROM NDGLinea__c WHERE Opportunita__c =: opportunityId AND Tipo__c = 'Debitore' AND Account__c =: idAdE /*IdAnagAgenzia*/ LIMIT 1 ];

            response.data.add(mask);

        } catch (exception e){
            System.debug('@@@ error ' + e.getCause() + ' -- ' + e.getLineNumber() + ' -- ' + e.getMessage());
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    public class MascheraPC{
        @AuraEnabled public Opportunity opp;
        @AuraEnabled public NDGLinea__c attore;

        public MascheraPC(){
            this.opp = new Opportunity();
            this.attore = new NDGLinea__c();
        }
    }

    @AuraEnabled
    public static WrapperResponse saveSceltaProdotto(String opportunityId, String fields, String payload){
        System.debug('@@@ fields ' + fields);
        CartPayload p = (CartPayload) JSON.deserialize(payload, CartPayload.Class);
        MascheraPC fieldsWrapper = (MascheraPC) JSON.deserialize(fields, MascheraPC.Class);
        System.debug('@@@ payload ' + JSON.serialize(p));
        System.debug('@@@ maschera ' + JSON.serialize(fieldsWrapper));
        WrapperResponse response = new WrapperResponse();

        try{
            // Update fields.values();

            Update fieldsWrapper.opp;
            Update fieldsWrapper.attore;

            saveJoin(p);

            System.debug('@@@ prova ' + JSON.serialize(getPayload(opportunityId)));
            response.data.add(getPayload(opportunityId));
        } catch (exception e){
            System.debug('@@@ error ' + e.getStackTraceString() + ' -- ' + e.getMessage());
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static void saveJoin(CartPayload p){

        //Mi recupero i crediti associati alla vecchia linea per associarli alla nuova
        List<Credito__c> creditsOldLinea = new List<Credito__c>([SELECT Id, WGC_Linea__c FROM Credito__c WHERE Opportunita__c =: p.opportunityId ]);
        // delete [SELECT Id, WGC_Linea__c FROM Credito__c WHERE Opportunita__c =: p.opportunityId ];
        //Elimino le vecchie linee e Join
        List<JoinLineaDebitore__c> joins = new List<JoinLineaDebitore__c>([SELECT Id FROM JoinLineaDebitore__c WHERE Opportunita__c =: p.opportunityId]);
        List<Linea__c> linee = new List<Linea__c>([SELECT Id, Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Opportunity__c =: p.opportunityId]);

        //Recupero il Prodotto
        List<Prodotto__c> prod = new List<Prodotto__c>([SELECT Id, Name, CodiceUnivoco__c FROM Prodotto__c WHERE CodiceUnivoco__c =: p.joinLineaDeb.servizio ]);
        //Mi genero la nuova linea
        Linea__c l = new Linea__c(
            Opportunity__c = p.opportunityId,
            DivisaNew__c = p.debitori[0].divisa,
            DebitoreTipo__c = 'Debitore',
            Prodotto__c = prod[0].Id
        );

        Insert l;

        System.debug('@@@ lll ' + JSON.serialize(l));
        JoinLineaDebitore__c j = new JoinLineaDebitore__c(Linea__c = l.Id, Debitore__c = p.debitori[0].id, Opportunita__c = p.opportunityId);

        Insert j;

        if(!linee.isEmpty() && linee[0].Prodotto__r.CodiceUnivoco__c == p.joinLineaDeb.servizio){
            for(Credito__c c : creditsOldLinea){
                c.WGC_Linea__c = l.Id;
            }

            Update creditsOldLinea;
        } else {
            delete creditsOldLinea;
        }

        NDGLinea__c agenzia = [SELECT Id, Linea__c FROM NDGLinea__c WHERE Opportunita__c =: p.opportunityId AND Account__c =: idAde];
        agenzia.Linea__c = l.Id;
        update agenzia;

        delete joins;
        delete linee;

            System.debug('@@@ jjj ' + JSON.serialize(l));
        //}

    }

    // @AuraEnabled
    // public static WrapperResponse saveCrediti(String payload){
    //     System.debug('@@@ payload ' + payload);
    //     WrapperResponse response = new WrapperResponse();
    //     try{
    //         CartPayload p = (CartPayload) JSON.deserialize(payload, CartPayload.Class);
    //         System.debug('@@@ serialize ' + JSON.serialize(p));
    //     } catch (exception e){
    //         response.message = e.getMessage();
    //         response.success = false;
    //     }

    //     return response;
    // }

    @AuraEnabled
	public static void openOpportunityFF (String opportunityId) {
		Opportunity opp = [select Id, WGC_Data_Fase_Valutazione_Pratica__c, WGC_Data_out_Fase_In_Istruttoria__c, StageName FROM Opportunity WHERE Id = :opportunityId];
		opp.WGC_Data_Fase_Valutazione_Pratica__c = null;
		opp.WGC_Data_out_Fase_In_Istruttoria__c = null;
		opp.IdCartella__c = null;
		opp.StageName = 'In Lavorazione';

		update opp;
	}

    @AuraEnabled
    public static WrapperResponse saveCrediti(String opportunityId, List<Credito__c> crediti){
        WrapperResponse response = new WrapperResponse();

        try{
            System.debug('@@@ crediti ' + JSON.serialize(crediti));
            for(Credito__c c : crediti){
                c.WGC_Prezzo_acquisto_richiesto__c = c.WGC_Prezzo_di_acquisto__c;
                c.WGC_Offerta_richiesta_perc__c = c.WGC_Offerta_perc__c;
            }
            Upsert crediti;

            noteAutomaticheHTML(opportunityId);

            response.data.add(getPayload(opportunityId));
        } catch (exception e){
            System.debug('@@@ eccez ' + e.getMessage());
            System.debug('@@@ eccez ' + e.getLineNumber());
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static WrapperResponse saveSingleCredito(Credito__c credito){
        WrapperResponse response = new WrapperResponse();

        try{
            Upsert credito;
            response.data.add(credito);
        } catch(exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    public class DatiIRR{
        @AuraEnabled
        public Decimal tassoInteresse; //Tasso_interesse_attivo__c;
        @AuraEnabled
        public Decimal tassoRif;//Tasso_di_riferimento__c;
        @AuraEnabled
        public Decimal spread; //Spread__c;
        @AuraEnabled
        public Decimal costoDenaro; //Costo_denaro__c;
    }

    @AuraEnabled
    public static WrapperResponse getDatiIRR(Id opportunityId){
        WrapperResponse response = new WrapperResponse();

        try{
            // Id pid = [SELECT Id FROM Profile WHERE Name =: boProfileName].Id;
            // WGC_Valori_IRR__c valoriIrr = WGC_Valori_IRR__c.getInstance(pid);

            Opportunity opp = [SELECT Id, Name, RecordType.DeveloperName, WGC_Data_Fase_Valutazione_Pratica__c FROM Opportunity WHERE Id =: opportunityId];
            String type;
            if( opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance'){
                type = 'Procedure';
            } else {
                type = 'InBonis';
            }
            Date Data_Fase_Valutazione_Pratica = (opp.WGC_Data_Fase_Valutazione_Pratica__c != null ? opp.WGC_Data_Fase_Valutazione_Pratica__c : Date.today());
            WGC_Valore_IRR__mdt valoriIrr = [SELECT Id, Costo_Denaro__c, Spread__c, Tasso_di_riferimento__c, Tasso_interesse_attivo__c FROM WGC_Valore_IRR__mdt WHERE Tipo_Credito__c =: type AND Inizio_Validita__c <=: Data_Fase_Valutazione_Pratica AND Fine_Validita__c >=: Data_Fase_Valutazione_Pratica];
            //WGC_Valore_IRR__mdt valoriIrr = [SELECT Id, Costo_Denaro__c, Spread__c, Tasso_di_riferimento__c, Tasso_interesse_attivo__c FROM WGC_Valore_IRR__mdt WHERE DeveloperName =: type LIMIT 1];

            DatiIRR dati = new DatiIrr();
            dati.tassoInteresse = valoriIrr.Tasso_interesse_attivo__c;
            dati.tassoRif = valoriIrr.Tasso_di_riferimento__c;
            dati.spread = valoriIrr.Spread__c;
            dati.costoDenaro = valoriIrr.Costo_denaro__c;

            response.data.add(dati);
            
        } catch(exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled(cacheable=true)
    public static WrapperResponse getDatiCostoNotaio(){
        WrapperResponse response = new WrapperResponse();

        List<WGC_Costo_Notaio__mdt> costoNotaio = new List<WGC_Costo_Notaio__mdt>([SELECT Id, Default_Value__c FROM WGC_Costo_Notaio__mdt WHERE Attivo__c = true]);
        response.data = costoNotaio;

        return response;
    }

    @AuraEnabled
    public static WrapperResponse getCreditiLinea(String opportunityId){
        WrapperResponse response = new WrapperResponse();

        try{
            Map<Id, Linea__c> lines = new Map<Id, Linea__c>([SELECT Id, Name, Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Opportunity__c =: opportunityId]);
            System.debug('@@@ lines ' + JSON.serialize(lines));
            List<Credito__c> creditiLinea = new List<Credito__c>([SELECT Id, Opportunita__c, WGC_Invia_Credito__c, WGC_Linea__c,Imposta__c, WGC_AdE_Territoriale__c, WGC_AdE_Territoriale__r.Name, WGC_Tipologia_Incasso__c, WGC_Origine__c
                                                                        ,WGC_Tipo_Operazione__c, WGC_Data_Notifi_Autoriz_GD__c,WGC_Modalita_di_offerta__c,WGC_Richiesta_all_azienda_dei_Doc_da_AdE__c
                                                                        ,WGC_Data_richiesta__c,WGC_Data_evasione__c,WGC_Esenzione_garanzia__c,WGC_Garante__c,WGC_Garanzia_richiesta_da_AdE__c
                                                                        ,WGC_Data_richiesta_da_AdE__c,WGC_Multiproprieta__c,WGC_Richiesta_Polizza__c,WGC_Data_richiesta_Polizza__c
                                                                        ,WGC_Unita_Locale__c ,WGC_Contratto_unita_locale__c,WGC_Compensi__c,WGC_Compensi_gest_Manuale__c
                                                                        ,ValoreNominale__c,WGC_Ruoli_compens__c,WGC_Val_Nom_Esigibile__c,WGC_Data_Contratto__c,WGC_Data_scadenza_bando__c
                                                                        ,WGC_Commissione_acquisto__c,WGC_Ulteriore_quantificazione_perc__c,WGC_Interessi_maturati__c,WGC_Modalita_contabilizzazione__c
                                                                        ,WGC_Data_presentazione_rimborso__c,WGC_Data_rimb_pres_in_atto_di_cessione__c,WGC_Data_DSO__c,WGC_Modifica_DSO__c
                                                                        ,WGC_Causale_modifica_DSO__c,WGC_Data_rimborso_presunto__c,WGC_Costo_notaio__c,WGC_Costo_contenzioso__c
                                                                        ,WGC_Interessi_stimati__c,WGC_IRR_perc__c,WGC_Data_start_up__c, WGC_Importo_Acconto__c, WGC_Data_Acconto__c, WGC_Importo_Cauzione__c, WGC_Data_Cauzione__c, WGC_Importo_Saldo__c, Status__c, // MS Aggiunto Status__c alla query
                                                                        WGC_Data_Saldo__c, WGC_Note_BO__c, WGC_Annualita_imposta__c, WGC_Anno__c, WGC_Unita_Locale_flag__c, PercentualeSuggerita__c, WGC_Modalita_offerta__c, WGC_Data_Offerta__c,
                                                                        WGC_Data_Scadenza_Offerta__c, WGC_Prezzo_di_acquisto__c, WGC_Offerta_perc__c, WGC_Gg_Maturazione_Interessi__c, WGC_Data_inizio_maturazione_interessi__c, WGC_Data_pagamento_notaio__c, WGC_Tipo_rimborso__c, WGC_Data_richiesta_rimborso__c,
                                                                        WGC_Data_Pagamento_Contenzioso__c, WGC_Completo_Commerciale__c, WGC_Completo_BO__c, WGC_Termini_di_pagamento__c, WGC_Data_cessione_credito__c, WGC_Modifica_Interessi_Stimati__c, WGC_Due_Diligence__c,
                                                                        WGC_Modifica_Costo_Notaio__c, WGC_Escludi_IRR__c
                                                                    FROM Credito__c WHERE wGC_Linea__c IN: lines.keySet() ORDER BY CreatedDate ]);
                                                                    
            System.debug('@@@ creditiLinea ' + JSON.serialize(creditiLinea));
            response.data.add(creditiLinea);

        } catch (exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static void noteAutomaticheHTML(String opportunityId){
        Opportunity opp = [SELECT Id, RecordType.DeveloperName, WGC_Note_Automatiche__c FROM Opportunity WHERE Id=: opportunityId];

        //IN BONIS
        // List<Credito__c> creditiBonis = new List<Credito__c>([SELECT Id, Name, WGC_Ade_Territoriale__r.Name, WGC_Esenzione_Garanzia__c, ValoreNominale__c,
        //                                                         WGC_Data_DSO__c, WGC_Data_Richiesta_Rimborso__c, WGC_Commissione_Acquisto__c, WGC_Offerta_perc__c,
        //                                                         WGC_IRR_Perc__c, WGC_Ruoli_Compens__c, WGC_Val_Nom_Esigibile__c
        //                                                     FROM Credito__c WHERE Opportunita__c =: opportunityId AND WGC_Invia_Credito__c = true ]);
        
        // //Debitore AdE
        // NDGLinea__c agenzia = [SELECT Id, name, ANotifica__c, WGC_Storicita_Rimborsi__c FROM NDGLinea__c WHERE Account__c =: idAdE AND Opportunita__c =: opportunityId ];

        //ProceduraConcorsuale
        List<Credito__c> creditiPC = new List<Credito__c>([SELECT Id, Name, toLabel(Imposta__c), toLabel(WGC_Origine__c), WGC_Ade_Territoriale__r.Name, 
                                                ValoreNominale__c, WGC_Ruoli_Compens__c, WGC_Val_Nom_Esigibile__c, WGC_Prezzo_di_Acquisto__c,
                                                WGC_Offerta_perc__c, WGC_Data_Presentazione_Rimborso__c, WGC_Data_Rimborso_Presunto__c,
                                                WGC_Data_DSO__c, WGC_IRR_Perc__c, WGC_Data_Cessione_Credito__c FROM Credito__c WHERE Opportunita__c =: opportunityId AND WGC_Invia_Credito__c = true ]);

        if(opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance'){
        // String nota = opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' ? creaNotaPC(creditiPC) : creaNotaBonis(creditiBonis, agenzia);
            String nota = creaNotaPC(creditiPC);
            System.debug('@@@ nota ' + nota);
            WizardOpportunityController.updateField('WGC_Note_Automatiche__c', nota, (Id) opportunityId);
        }
    }

    public static String creaNotaPC(List<Credito__c> crediti){
        String nota = '';
        Integer i = 1;
        for(Credito__c c : crediti){
            // nota += '<h3><b>Credito ' + i + '</b></h3>';
            // nota += '<p>';
            // if(c.Imposta__c != null) nota += '<b>Imposta: </b>' + c.Imposta__c + ', ';
            // if(c.WGC_Origine__c != null) nota += '<b>Origine: </b>' + c.WGC_Origine__c + ', ';
            // if(c.WGC_Ade_Territoriale__r.Name != null) nota += '<b>AdE Territoriale: </b>' + c.WGC_Ade_Territoriale__r.Name + ', ';
            // if(c.ValoreNominale__c != null) nota += '<b>Valore Nominale: </b>' + c.ValoreNominale__c.format() + ', ';
            // if(c.WGC_Ruoli_Compens__c != null) nota += '<b>Ruoli Compens: </b>' + c.WGC_Ruoli_Compens__c + ', ';
            // if(c.WGC_Val_Nom_Esigibile__c != null) nota += '<b>Val. Nom. Esigibile: </b>' + c.WGC_Val_Nom_Esigibile__c.format() + ', ';
            // if(c.WGC_Prezzo_di_Acquisto__c != null) nota += '<b>Prezzo di acquisto: </b>' + c.WGC_Prezzo_di_Acquisto__c.format() + ', ';
            // if(c.WGC_Offerta_perc__c != null) nota += '<b>% Offerta: </b>' + c.WGC_Offerta_perc__c + ', ';
            // if(c.WGC_Data_Presentazione_Rimborso__c != null) nota += '<b>Data Presentazione Rimborso: </b>' + c.WGC_Data_Presentazione_Rimborso__c.format() + ', ';
            // if(c.WGC_Data_Rimborso_Presunto__c != null) nota += '<b>Data Rimborso Presunto: </b>' + c.WGC_Data_Rimborso_Presunto__c.format() + ', ';
            // if(c.WGC_Data_DSO__c != null) nota += '<b>Data DSO: </b>' + c.WGC_Data_DSO__c.format() + ', ';
            // if(c.WGC_IRR_Perc__c != null) nota += '<b>% IRR: </b>' + c.WGC_IRR_Perc__c + ', ';
            // if(c.WGC_Data_Cessione_Credito__c != null) nota += '<b>Data Cessione Credito: </b>' + c.WGC_Data_Cessione_Credito__c.format();
            // nota += '</p>';
            nota += 'Credito ' + i + '\n';
            if(c.Imposta__c != null) nota += 'Imposta: ' + c.Imposta__c + ', ';
            if(c.WGC_Origine__c != null) nota += 'Origine: ' + c.WGC_Origine__c + ', ';
            if(c.WGC_Ade_Territoriale__r.Name != null) nota += 'AdE Territoriale: ' + c.WGC_Ade_Territoriale__r.Name + ', ';
            if(c.ValoreNominale__c != null) nota += 'Valore Nominale: ' + c.ValoreNominale__c.format() + ', ';
            if(c.WGC_Ruoli_Compens__c != null) nota += 'Ruoli Compens: ' + c.WGC_Ruoli_Compens__c + ', ';
            if(c.WGC_Val_Nom_Esigibile__c != null) nota += 'Val. Nom. Esigibile: ' + c.WGC_Val_Nom_Esigibile__c.format() + ', ';
            if(c.WGC_Prezzo_di_Acquisto__c != null) nota += 'Prezzo di acquisto: ' + c.WGC_Prezzo_di_Acquisto__c.format() + ', ';
            if(c.WGC_Offerta_perc__c != null) nota += '% Offerta: ' + c.WGC_Offerta_perc__c + ', ';
            if(c.WGC_Data_Presentazione_Rimborso__c != null) nota += 'Data Presentazione Rimborso: ' + c.WGC_Data_Presentazione_Rimborso__c.format() + ', ';
            if(c.WGC_Data_Rimborso_Presunto__c != null) nota += 'Data Rimborso Presunto: ' + c.WGC_Data_Rimborso_Presunto__c.format() + ', ';
            if(c.WGC_Data_DSO__c != null) nota += 'Data DSO: ' + c.WGC_Data_DSO__c.format() + ', ';
            if(c.WGC_IRR_Perc__c != null) nota += '% IRR: ' + c.WGC_IRR_Perc__c + ', ';
            if(c.WGC_Data_Cessione_Credito__c != null) nota += 'Data Cessione Credito: ' + c.WGC_Data_Cessione_Credito__c.format();
            nota += '\n\r';
            //Incremento l'indice per la nomenclatura
            i++;
        }

        return nota;
    }

    public static String creaNotaBonis(List<Credito__c> crediti, NDGLinea__c agenzia){
        String nota = '';
        Integer i = 1;
        // nota += '<h3><b> Agenzia Delle Entrate </b></h3>';
        // nota += '<p>';
        // nota += '<b>A Notifica: </b>' + (agenzia.ANotifica__c == true ? 'SI' : 'NO') + ', ';
        // nota += '<b>Storicità Rimborsi: </b>' + (agenzia.WGC_Storicita_Rimborsi__c == true ? 'SI' : 'NO');
        // nota += '</p>';

        nota += 'A Notifica: ' + (agenzia.ANotifica__c == true ? 'SI' : 'NO') + ', ';
        nota += 'Storicità Rimborsi: ' + (agenzia.WGC_Storicita_Rimborsi__c == true ? 'SI' : 'NO');
        nota += '\n\r';

        for(Credito__c c : crediti){
            // nota += '<h3><b>Credito ' + i + '</b></h3>';
            // nota += '<p>';
            // if(c.WGC_Ade_Territoriale__r.Name != null) nota += '<b>AdE Territoriale: </b>' + c.WGC_Ade_Territoriale__r.Name + ', ';
            // if(c.WGC_Esenzione_Garanzia__c != null) nota += '<b>Esenzione Garanzia: </b>' + c.WGC_Esenzione_Garanzia__c + ', ';
            // if(c.ValoreNominale__c != null) nota += '<b>Valore Nominale: </b>' + c.ValoreNominale__c.format() + ', ';
            // if(c.WGC_Data_DSO__c != null) nota += '<b>Data DSO: </b>' + c.WGC_Data_DSO__c.format() + ', ';
            // if(c.WGC_Data_Richiesta_Rimborso__c != null) nota += '<b>Data Richiesta Rimborso: </b>' + c.WGC_Data_Richiesta_Rimborso__c.format() + ', ';
            // if(c.WGC_Commissione_Acquisto__c != null) nota += '<b>Commissione Acquisto: </b>' + c.WGC_Commissione_Acquisto__c + ', ';
            // if(c.WGC_Offerta_perc__c != null) nota += '<b>% Offerta: </b>' + c.WGC_Offerta_perc__c + ', ';
            // if(c.WGC_IRR_Perc__c != null) nota += '<b>% IRR: </b>' + c.WGC_IRR_Perc__c + ', ';
            // if(c.WGC_Ruoli_Compens__c != null) nota += '<b>Ruoli Compens: </b>' + c.WGC_Ruoli_Compens__c + ', ';
            // if(c.WGC_Val_Nom_Esigibile__c != null) nota += '<b>Val. Nom. Esigibile: </b>' + c.WGC_Val_Nom_Esigibile__c.format() + ', ';
            // nota += '</p>';
            nota += 'Credito ' + i + '\n\r';
            if(c.WGC_Ade_Territoriale__r.Name != null) nota += 'AdE Territoriale: ' + c.WGC_Ade_Territoriale__r.Name + ', ';
            if(c.WGC_Esenzione_Garanzia__c != null) nota += 'Esenzione Garanzia: ' + ( c.WGC_Esenzione_Garanzia__c ? 'Si' : 'No' ) + ', ';
            if(c.ValoreNominale__c != null) nota += 'Valore Nominale: ' + c.ValoreNominale__c.format() + ', ';
            if(c.WGC_Data_DSO__c != null) nota += 'Data DSO: ' + c.WGC_Data_DSO__c.format() + ', ';
            if(c.WGC_Data_Richiesta_Rimborso__c != null) nota += 'Data Richiesta Rimborso: ' + c.WGC_Data_Richiesta_Rimborso__c.format() + ', ';
            if(c.WGC_Commissione_Acquisto__c != null) nota += 'Commissione Acquisto: ' + c.WGC_Commissione_Acquisto__c + ', ';
            if(c.WGC_Offerta_perc__c != null) nota += '% Offerta: ' + c.WGC_Offerta_perc__c + ', ';
            if(c.WGC_IRR_Perc__c != null) nota += '% IRR: ' + c.WGC_IRR_Perc__c + ', ';
            if(c.WGC_Ruoli_Compens__c != null) nota += 'Ruoli Compens: ' + c.WGC_Ruoli_Compens__c + ', ';
            if(c.WGC_Val_Nom_Esigibile__c != null) nota += 'Val. Nom. Esigibile: ' + c.WGC_Val_Nom_Esigibile__c.format() + ', ';
            nota += '\n\r';
            //Incremento l'indice per la nomenclatura
            i++;
        }

        return nota;
    }

    /* CHIAMATE AI SERVIZI - START */

    /* TIME02 - Invio Crediti a TIME pre delibera */

    @AuraEnabled
    public static WrapperResponse callCensimentoTrattativa(String opportunityId, String typeCall){
        WrapperResponse response = new WrapperResponse();

        try{
            WGC_WsRestFF.CensimentoTrattativaResponse serviceResp = WGC_WsRestFF.censimentoTrattativa(opportunityId, typeCall);
            System.debug('@@@ serviceResp ' + JSON.serialize(serviceResp));

            Boolean checkKO = false;
            String errorKO = '';
            //TODO Logica da spostare nella class WGC_WsRestFF
            Map<Id,Credito__c> credits = new Map<Id,Credito__c>([SELECT Id, Name, WGC_Codice_Rapporto__c FROM Credito__c WHERE Opportunita__c =: opportunityId]);
            for(WGC_WsRestFF.Esito esito : serviceResp.payload.esito){
                if(esito.esitoRiga == 'OK' && credits.containsKey(esito.idCrmLinea)){
                    credits.get(esito.idCrmLinea).WGC_Codice_Rapporto__c = esito.pRapporto;
                } else if(esito.esitoRiga != 'OK'){
                    if(!checkKO){
                        checkKO = true;
                        errorKO = esito.esitoRiga;
                    }
                }
            }

            Update credits.values();

            //Se è presente un almeno un KO, non chiamo PEF41
            if(checkKO){
                //throw new DMLException('KO -- ' + errorKO);
                response.success = false;
                response.message = errorKO;
            } else {
                response.data.add(JSON.serialize(serviceResp));
            }

        } catch (exception e) {
            response.success = false;
            response.message = e.getMessage();
        }
        
        System.debug('@@@ response ' + JSON.serialize(response));
        return response;
    }

    @AuraEnabled
    public static WrapperResponse callCensimentoTrattativaSingle(Id opportunityId, Id creditoId, String typeCall){
        WrapperResponse response = new WrapperResponse();

        try{
            WGC_WsRestFF.CensimentoTrattativaResponse serviceResp = WGC_WsRestFF.censimentoTrattativaSingle(opportunityId, creditoId, typeCall);
            System.debug('@@@ serviceResp ' + JSON.serialize(serviceResp));

            Boolean checkKO = false;
            String errorKO = '';
            //TODO Logica da spostare nella class WGC_WsRestFF
            Map<Id,Credito__c> credits = new Map<Id,Credito__c>([SELECT Id, Name, WGC_Codice_Rapporto__c FROM Credito__c WHERE Id =: creditoId]);
            for(WGC_WsRestFF.Esito esito : serviceResp.payload.esito){
                if(esito.esitoRiga == 'OK' && credits.containsKey(esito.idCrmLinea)){
                    credits.get(esito.idCrmLinea).WGC_Codice_Rapporto__c = esito.pRapporto;
                } else if(esito.esitoRiga != 'OK'){
                    if(!checkKO){
                        checkKO = true;
                        errorKO = esito.esitoRiga;
                    }
                }
            }

            Update credits.values();

            //Se è presente un almeno un KO, non chiamo PEF41
            if(checkKO){
                //throw new DMLException('KO -- ' + errorKO);
                response.success = false;
                response.message = errorKO;
            } else {
                response.data.add(JSON.serialize(serviceResp));
            }

        } catch (Exception e) {
            response.success = false;
            response.message = e.getMessage();
        }
        
        System.debug('@@@ response ' + JSON.serialize(response));
        return response;
    }

    /* TIME02 - Invio Crediti a TIME pre delibera */

    // /* PEF39 - Recupero Pratica KNET - START */

    @AuraEnabled
    public static WrapperResponse callPEF39(Id accountId, Id opportunityId){
        WrapperResponse response = new WrapperResponse();

        try{
		    //A.M. Aggiunti capi per apertura PEF su Debitore e non su Assuntore (WGC_Assuntore__c, WGC_NDG_Debitore__c)
            Opportunity opp = [SELECT Id, WGC_Codice_Pratica__c, WGC_Assuntore__c, WGC_NDG_Debitore__c FROM Opportunity WHERE Id =: opportunityId ];
            Account acc = [SELECT Id, Name, NDGGruppo__c, CodiceIstituto3N__c FROM Account WHERE Id =: accountId];
            if (opp.WGC_Codice_Pratica__c == null) {
                response.success = false;
                response.message = 'Codice pratica mancante.';
                return response;
            }

            WGC_WSUtils_Cart.DatiPEFInput input = new WGC_WSUtils_Cart.DatiPEFInput();
			if (opp.WGC_Assuntore__c){
				input.codNdg = Long.valueOf(opp.WGC_NDG_Debitore__c);
			} else {
				input.codNdg = Long.valueOf(acc.NDGGruppo__c);
			}
            input.codiceIstituto3N = Integer.valueOf(acc.CodiceIstituto3N__c);
            input.codPratica = Integer.valueOf(opp.WGC_Codice_Pratica__c);
            System.debug('@@@@ input: ' + input);
            WGC_WSUtils_Cart.DatiPEFResponse serviceResp = WGC_WSUtils_Cart.loadDatiPEF_FF(input);
            System.debug('@@@@ response: ' + serviceResp);
            //SM - CR 482 - Organo Deliberante/Data Delibera
			if (serviceResp.payload.outputRichiesta.datDelibera != null && serviceResp.payload.outputRichiesta.codRuoloDeliberante != null && serviceResp.payload.outputRichiesta.codRuoloDeliberante != ''){
               opp.WGC_Organo_Deliberante__c = serviceResp.payload.outputRichiesta.codRuoloDeliberante;
               opp.WGC_Data_Delibera_PEF__c = DateTime.newInstance(serviceResp.payload.outputRichiesta.datDelibera).date();
               update opp;
			}
            
            aggiornaStatiCreditiPEF(opportunityId, serviceResp);

            Map<String,Object> responseMap = new Map<String,Object>();
            responseMap.put('response', serviceResp);
            //responseMap.put('response', JSON.deserializeUntyped('{"headers" : {"headers" : {"user_header" : {"archUser" : {"userRoles" : [ ],"userGroups" : [ {"description" : "","name" : "utenti.CRM"}, {"description" : "","name" : "Users"}, {"description" : "","name" : "NoLocalLogon"}, {"description" : "","name" : "cbox.ff.uat"}, {"description" : "","name" : "cbox.ff.prd"} ],"institute" : null,"actualUserId" : "ext.crm","userId" : "ext.crm","phoneNumber" : null,"emailAddress" : null,"surname" : "SFDC","name" : "CRM Salesforce"},"id" : "user_header"},"tech_header" : {"clientHostname" : null,"clientIpAddress" : null,"workstationId" : null,"timeStamp" : 1590670709914,"channel" : "B2B","correlationId" : "423d0cff-4581-4868-b575-e9dbd253b336","applicationCode" : "CRM","id" : "tech_header"}}},"payload" : {"outputRichiesta" : {"elencoNote" : null,"elencoLineeCredito" : [ {"elencoCoppie" : null,"impQuotaOneri" : null,"impQuotaNotifica" : null,"impAccordatoLinea" : 12,"desStatoLinea" : "Deliberato","codStatoLinea" : "003","codGestione" : "N","codDivisa" : "EUR","desLineaSistema" : null,"codLineaSistema" : null,"ragSocCedente" : null,"codNdgCedente" : 230510,"codRapportoEst" : "0570015000002444664","numLineaCredito" : 0}, {"elencoCoppie" : null,"impQuotaOneri" : null,"impQuotaNotifica" : null,"impAccordatoLinea" : 14500,"desStatoLinea" : "Deliberato","codStatoLinea" : "003","codGestione" : "N","codDivisa" : "EUR","desLineaSistema" : null,"codLineaSistema" : null,"ragSocCedente" : null,"codNdgCedente" : 230510,"codRapportoEst" : "0570015000002444663","numLineaCredito" : 0} ],"numSospensioni" : null,"numGiorniSospTotale" : null,"numGiorniSospCorrente" : null,"flgPraticaSospesa" : null,"codRuoloDeliberante" : null,"desUtenteDeliberante" : null,"codUtenteDeliberante" : null,"codRuoloAttivo" : null,"desUtenteAttivo" : null,"codUtenteAttivo" : null,"datDelibera" : 1589978938000,"datCreazione" : 1589978938000,"desStatoPratica" : "Approvata","codStatoPratica" : "DEL","desTipoPratica" : null,"codTipoPratica" : null,"ragSocPratica" : null,"codNDG" : 230510,"codPratica" : 9000021,"codiceIstituto3N" : 881},"errorDetails" : null,"resultMessage" : "OK","resultCode" : "0"}}'));
            responseMap.put('crediti', getCreditiInviati(opportunityId));
            response.data.add(JSON.serialize(responseMap));
        } catch(exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    public static void aggiornaStatiCreditiPEF(Id opportunityId, WGC_WsUtils_Cart.DatiPEFResponse response){
        Map<Id, Credito__c> crediti = new Map<Id, Credito__c>();
        List<Credito__c> creditiToUpdate = new List<Credito__c>();
        Map<String, Sobject> creditiMap = U.keyBy(getCreditiInviati(opportunityId), 'WGC_Codice_Rapporto__c');
        Map<String, Sobject> creditiMapFixed = new Map<String, Sobject>();
        //Ciclo for per fixare il codice rapporto
        for(Sobject sobj : creditiMap.values()){
            String codRapp = String.valueOf(sobj.get('WGC_Codice_Rapporto__c'));
            codRapp = '0'+codRapp.substring(0,2)+'00'+codRapp.substring(2,5)+'0000'+codRapp.substring(5);
            // codRapp = '0'+codRapp.substring(0,2)+'00'+codRapp.substring(3,5)+'0000'+codRapp.substring(5);
            creditiMapFixed.put(codRapp, sobj);
        }

        for(WGC_WsUtils_Cart.LineaCredito l : response.payload.outputRichiesta.elencoLineeCredito){
            if(creditiMapFixed.get(l.codRapportoEst) != null){
                if (l.codStatoLinea == WizardOpportunityController.COD_STATO_LINEA_DECLINATA && ((Credito__c) creditiMapFixed.get(l.codRapportoEst)).WGC_Non_Deliberata__c != true) {
                    ((Credito__c) creditiMapFixed.get(l.codRapportoEst)).WGC_Non_Deliberata__c = true;
                    ((Credito__c) creditiMapFixed.get(l.codRapportoEst)).WGC_Data_Declinazione__c = Date.today();
                    ((Credito__c) creditiMapFixed.get(l.codRapportoEst)).WGC_Prezzo_di_Acquisto__c = l.impAccordatoLinea;
                    creditiToUpdate.add((Credito__c) creditiMapFixed.get(l.codRapportoEst));
                } else if (l.codStatoLinea == WizardOpportunityController.COD_STATO_LINEA_DELIBERATA && ((Credito__c) creditiMapFixed.get(l.codRapportoEst)).WGC_Deliberata__c != true) {
                    ((Credito__c) creditiMapFixed.get(l.codRapportoEst)).WGC_Deliberata__c = true;
                    ((Credito__c) creditiMapFixed.get(l.codRapportoEst)).WGC_Data_Delibera__c = Date.today();
                    ((Credito__c) creditiMapFixed.get(l.codRapportoEst)).WGC_Prezzo_di_Acquisto__c = l.impAccordatoLinea;
                    creditiToUpdate.add((Credito__c) creditiMapFixed.get(l.codRapportoEst));
                }
            }
        }

        Update creditiToUpdate;

    }

    public static List<Credito__c> getCreditiInviati(Id opportunityId){
        return [SELECT Id, Name, WGC_Credito_Confermato__c , WGC_Codice_Rapporto__c, Stato__c,
                    WGC_Deliberata__c, WGC_Non_Deliberata__c, WGC_Data_Delibera__c, WGC_Data_Declinazione__c, WGC_Ultima_Nota__c, Opportunita__c, WGC_Invia_Credito__c, WGC_Linea__c,Imposta__c, WGC_AdE_Territoriale__c, WGC_AdE_Territoriale__r.Name, WGC_Tipologia_Incasso__c, WGC_Origine__c
                    ,WGC_Tipo_Operazione__c, WGC_Data_Notifi_Autoriz_GD__c,WGC_Modalita_di_offerta__c,WGC_Richiesta_all_azienda_dei_Doc_da_AdE__c
                    ,WGC_Data_richiesta__c,WGC_Data_evasione__c,WGC_Esenzione_garanzia__c,WGC_Garante__c,WGC_Garanzia_richiesta_da_AdE__c
                    ,WGC_Data_richiesta_da_AdE__c,WGC_Multiproprieta__c,WGC_Richiesta_Polizza__c,WGC_Data_richiesta_Polizza__c
                    ,WGC_Unita_Locale__c ,WGC_Contratto_unita_locale__c,WGC_Compensi__c,WGC_Compensi_gest_Manuale__c
                    ,ValoreNominale__c,WGC_Ruoli_compens__c,WGC_Val_Nom_Esigibile__c,WGC_Data_Contratto__c,WGC_Data_scadenza_bando__c
                    ,WGC_Commissione_acquisto__c,WGC_Ulteriore_quantificazione_perc__c,WGC_Interessi_maturati__c,WGC_Modalita_contabilizzazione__c
                    ,WGC_Data_presentazione_rimborso__c,WGC_Data_rimb_pres_in_atto_di_cessione__c,WGC_Data_DSO__c,WGC_Modifica_DSO__c
                    ,WGC_Causale_modifica_DSO__c,WGC_Data_rimborso_presunto__c,WGC_Costo_notaio__c,WGC_Costo_contenzioso__c
                    ,WGC_Interessi_stimati__c,WGC_IRR_perc__c,WGC_Data_start_up__c, WGC_Importo_Acconto__c, WGC_Data_Acconto__c, WGC_Importo_Cauzione__c, WGC_Data_Cauzione__c, WGC_Importo_Saldo__c,
                    WGC_Data_Saldo__c, WGC_Note_BO__c, WGC_Annualita_imposta__c, WGC_Anno__c, WGC_Unita_Locale_flag__c, PercentualeSuggerita__c, WGC_Modalita_offerta__c, WGC_Data_Offerta__c,
                    WGC_Data_Scadenza_Offerta__c, WGC_Prezzo_di_acquisto__c, WGC_Offerta_perc__c, WGC_Gg_Maturazione_Interessi__c, WGC_Data_inizio_maturazione_interessi__c, WGC_Data_pagamento_notaio__c, WGC_Tipo_rimborso__c, WGC_Data_richiesta_rimborso__c,
                    WGC_Data_Pagamento_Contenzioso__c, WGC_Completo_Commerciale__c, WGC_Completo_BO__c, WGC_Termini_di_pagamento__c, WGC_Data_cessione_credito__c, WGC_Modifica_Interessi_Stimati__c, WGC_Rigo__c, WGC_Commessa__c, WGC_Prezzo_Acquisto_Richiesto__c, WGC_Due_Diligence__c, WGC_Attivata__c, WGC_Data_Attivazione__c, WGC_Modifica_Costo_Notaio__c
                                    FROM Credito__c WHERE Opportunita__c =: opportunityId AND WGC_Codice_Rapporto__c != null AND WGC_Invia_Credito__c = true ORDER BY CreatedDate];
    }

    @AuraEnabled
    public static String getCreditoInviato(Id creditoId){
        Credito__c c = [SELECT Id, Name, WGC_Credito_Confermato__c , WGC_Codice_Rapporto__c, Stato__c,
                    WGC_Deliberata__c, WGC_Non_Deliberata__c, WGC_Data_Delibera__c, WGC_Data_Declinazione__c, WGC_Ultima_Nota__c, Opportunita__c, WGC_Invia_Credito__c, WGC_Linea__c,Imposta__c, WGC_AdE_Territoriale__c, WGC_AdE_Territoriale__r.Name, WGC_Tipologia_Incasso__c, WGC_Origine__c
                    ,WGC_Tipo_Operazione__c, WGC_Data_Notifi_Autoriz_GD__c,WGC_Modalita_di_offerta__c,WGC_Richiesta_all_azienda_dei_Doc_da_AdE__c
                    ,WGC_Data_richiesta__c,WGC_Data_evasione__c,WGC_Esenzione_garanzia__c,WGC_Garante__c,WGC_Garanzia_richiesta_da_AdE__c
                    ,WGC_Data_richiesta_da_AdE__c,WGC_Multiproprieta__c,WGC_Richiesta_Polizza__c,WGC_Data_richiesta_Polizza__c
                    ,WGC_Unita_Locale__c ,WGC_Contratto_unita_locale__c,WGC_Compensi__c,WGC_Compensi_gest_Manuale__c
                    ,ValoreNominale__c,WGC_Ruoli_compens__c,WGC_Val_Nom_Esigibile__c,WGC_Data_Contratto__c,WGC_Data_scadenza_bando__c
                    ,WGC_Commissione_acquisto__c,WGC_Ulteriore_quantificazione_perc__c,WGC_Interessi_maturati__c,WGC_Modalita_contabilizzazione__c
                    ,WGC_Data_presentazione_rimborso__c,WGC_Data_rimb_pres_in_atto_di_cessione__c,WGC_Data_DSO__c,WGC_Modifica_DSO__c
                    ,WGC_Causale_modifica_DSO__c,WGC_Data_rimborso_presunto__c,WGC_Costo_notaio__c,WGC_Costo_contenzioso__c
                    ,WGC_Interessi_stimati__c,WGC_IRR_perc__c,WGC_Data_start_up__c, WGC_Importo_Acconto__c, WGC_Data_Acconto__c, WGC_Importo_Cauzione__c, WGC_Data_Cauzione__c, WGC_Importo_Saldo__c,
                    WGC_Data_Saldo__c, WGC_Note_BO__c, WGC_Annualita_imposta__c, WGC_Anno__c, WGC_Unita_Locale_flag__c, PercentualeSuggerita__c, WGC_Modalita_offerta__c, WGC_Data_Offerta__c,
                    WGC_Data_Scadenza_Offerta__c, WGC_Prezzo_di_acquisto__c, WGC_Offerta_perc__c, WGC_Gg_Maturazione_Interessi__c, WGC_Data_inizio_maturazione_interessi__c, WGC_Data_pagamento_notaio__c, WGC_Tipo_rimborso__c, WGC_Data_richiesta_rimborso__c,
                    WGC_Data_Pagamento_Contenzioso__c, WGC_Completo_Commerciale__c, WGC_Completo_BO__c, WGC_Termini_di_pagamento__c, WGC_Data_cessione_credito__c, WGC_Modifica_Interessi_Stimati__c, WGC_Rigo__c, WGC_Commessa__c, WGC_Prezzo_Acquisto_Richiesto__c, WGC_Offerta_richiesta_perc__c, WGC_Due_Diligence__c,
                    WGC_Modifica_Costo_Notaio__c, WGC_Linea__r.Prodotto__r.CodiceUnivoco__c
                                    FROM Credito__c WHERE Id =: creditoId LIMIT 1];

        return JSON.serialize(c);
    }

    // /* PEF39 - Recupero Pratica KNET - END */

    /* PEF41 - Invio a KNET - START */

    @AuraEnabled
    public static WrapperResponse callPEF41(String opportunityId){
        WrapperResponse response = new WrapperResponse();
        User currentUser = [SELECT Id, NDGGruppo__c, Filiale__c FROM User WHERE Id =: UserInfo.getUserId() ];
        NDGLinea__c agenzia = [SELECT Id, WGC_Codice_Linea_PC__c FROM NDGLinea__c WHERE Opportunita__c =: opportunityId AND Account__c =: idAdE];
		//A.M. Aggiunti capi per apertura PEF su Debitore e non su Assuntore (WGC_Assuntore__c, WGC_NDG_Debitore__c)
        Opportunity opp = [SELECT Id, Name, Account.CodiceIstituto3N__c, Account.NDGGruppo__c, StageName, Tipologia_Opportunit__c,
                            Owner.Name, Account.WGC_Descrizione_dell_azienda__c, WGC_NoteEventi__c, WGC_NoteCR__c, 
                            WGC_NoteBilancio__c, WGC_Descrizione_Operativit_Proposta__c, WGC_Note_Condizioni_Economiche__c, 
                            WGC_Note_Automatiche__c, WGC_Note_Automatiche_Estero__c, WGC_Assuntore__c, WGC_NDG_Debitore__c, 
                            (SELECT Id, Name, WGC_Codice_Rapporto__c, WGC_Progressivo_ICAR__c, WGC_Prezzo_di_acquisto__c FROM Credito__r WHERE WGC_Invia_Credito__c = true) 
                            FROM Opportunity WHERE Id =: opportunityId];

        if(String.isBlank(currentUser.NDGGruppo__c)){
            response.message = Label.WGC_Cart_PEF41UserNDGMissing;
            response.success = false;
            return response;
        }

        try{
            WGC_WSUtils_Cart.PEF41Response responsePEF41 = callPEF41WS(opp, currentUser, agenzia);
            System.debug('@@@A.M. responsePEF41_FF ' + JSON.serialize(responsePEF41));
            //Se il servizio mi restituisce il codice pratica allora aggiorno
            if(responsePEF41.payload.outputRichiesta.codPratica != null){
                // opp.StageName = (opp.Tipologia_Opportunit__c == 'RINN' ? 'Valutazione' : 'Valutazione Pratica');
                // opp.StageName = 'Valutazione Pratica';
                opp.StageName = 'Valutazione Pratica';
                opp.WGC_Codice_Pratica__c = responsePEF41.payload.outputRichiesta.codPratica;
                // opp.StatoPEF__c = '4';
                update opp;
            }

            response.data.add(JSON.serialize(responsePEF41));
        } catch(exception e){
            response.message = e.getMessage();
            response.success = false;
            Insert new Log__c(Source__c = 'Errore PEF41 FF', ErorrMessage__c = e.getMessage() + ' -- ' + e.getStackTraceString());

        }

        return response;
    }

    public static WGC_WSUtils_Cart.PEF41Response callPEF41WS(Opportunity opp, User currentUser, NDGLinea__c agenzia){
        WGC_WSUtils_Cart.InputPayloadPEF41 input = new WGC_WSUtils_Cart.InputPayloadPEF41();

        //Popolo le info generali del payload
        input = fillInfoGenerali(opp, currentUser);
        input.lineeCreditoLCC = fillInfoLineeCredito(opp, agenzia, currentUser);

        System.debug('@@@A.M. input PEF41_FF ' + JSON.serialize(input));
        return (WGC_WSUtils_Cart.PEF41Response) WsRestUtils.callService(
            'WGC_Url_PEF41_FF__c',
            input,
            WGC_WSUtils_Cart.PEF41Response.class
        );
    }

    public static WGC_WSUtils_Cart.InputPayloadPEF41 fillInfoGenerali(Opportunity opp, User currentUser){
        WGC_WSUtils_Cart.InputPayloadPEF41 resp = new WGC_WSUtils_Cart.InputPayloadPEF41();

        resp.IDcarrelloCRM = opp.Id;
        resp.flagConsolidamento = 'N';
        resp.provenienzaPEF = '';
        resp.codiceIstituto3N = Integer.valueOf(opp.Account.CodiceIstituto3N__c);
		//A.M. Apertura PEF su Debitore e non su Assuntore
		if (opp.WGC_Assuntore__c){
		   resp.codNDGSoggetto = Long.valueOf(opp.WGC_NDG_Debitore__c);
		} else {
		   resp.codNDGSoggetto = Long.valueOf(opp.Account.NDGGruppo__c);
		}
        resp.codUserID = currentUser.NDGGruppo__c;
        resp.notaProponente = WGC_WsUtils_Cart.getNotaProponente(EncodingUtil.base64Encode(Blob.valueOf(WsRestCrmUtils.creaNoteIstruttoriaHTML(opp))));
        return resp;
    }

    public static List<WGC_WSUtils_Cart.LineaCreditoLCCPEF41> fillInfoLineeCredito(Opportunity opp, NDGLinea__c agenzia, User currentUser){
        List<WGC_WSUtils_Cart.LineaCreditoLCCPEF41> elencoCrediti = new List<WGC_WSUtils_Cart.LineaCreditoLCCPEF41>();

        for(Credito__c c : opp.Credito__r){
            WGC_WSUtils_Cart.LineaCreditoLCCPEF41 credito = new WGC_WSUtils_Cart.LineaCreditoLCCPEF41();
            // credito.numLineaCredito = Integer.valueOf(c.Name.remove('CRE-'));
            credito.importoRichiesto = c.WGC_Prezzo_di_Acquisto__c;
            credito.codRapportoEsterno = '';
            // credito.codRapportoEsterno = agenzia.WGC_Codice_Linea_PC__c + (currentUser.Filiale__c.length() == 3 ? '00'+currentUser.Filiale__c : currentUser.Filiale__c) + c.WGC_Codice_Rapporto__c;
            // credito.codRappCredErariali = c.WGC_Codice_Rapporto__c;
            credito.codRappCredErariali = '0'+c.WGC_Codice_Rapporto__c.substring(0,2)+'00'+c.WGC_Codice_Rapporto__c.substring(2,5)+'0000'+c.WGC_Codice_Rapporto__c.substring(5); //'0'+c.WGC_Codice_Rapporto__c.substring(0,2)+'00115'+'0000'+c.WGC_Codice_Rapporto__c.substring(5);
            credito.codMercato = '001';
            credito.lineaSistema = agenzia.WGC_Codice_Linea_PC__c;
            credito.codCanAcqLCC = '';
            //Sempre fisso su euro per FF
            credito.codDivisa = '242';
            credito.dataScadenzaFido = null;
            System.debug('@@@ prova credito ' + JSON.serialize(credito));

            elencoCrediti.add(credito);
        }

        return elencoCrediti;
    }

    @AuraEnabled
    public static String checkCensimentoAnag(String accountId){

        String msg;
        Account acc = [SELECT Id, WGC_Censimento__c FROM Account WHERE Id =: accountId];
        if(acc.WGC_Censimento__c == 'Parziale')
            msg = 'ko';

        return msg;
    }

    /* PEF41 - Invio a KNET - END */

    /* TIME03 - Invio Crediti a TIME post delibera */

    @AuraEnabled
    public static WrapperResponse callConfermaTrattativa(String creditoId){
        WrapperResponse response = new WrapperResponse();

        try{
            Id param = (Id) creditoId;
            WGC_WsRestFF.RapportoTrattativaResponse serviceResp = WGC_WsRestFF.confermaTrattativa(param);

            //SM - TEN: Aggiornamento dei campi rigo e commessa FF
            Credito__c c = new Credito__c(Id = creditoId, WGC_Rigo__c = serviceResp.payload.pRigo, WGC_Commessa__c = serviceResp.payload.pCommessa);
            Update c;

            response.data.add(JSON.serialize(serviceResp));
        } catch(exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    /* TIME03 - Invio Crediti a TIME post delibera */

    /* TIME04 - CALCOLO INTERESSI - START */

    @AuraEnabled
    public static WrapperResponse callCalcolaInteressi(String creditoId){
        WrapperResponse response = new WrapperResponse();

        try{
            Id param = (Id) creditoId;
            WGC_WsRestFF.CalcoloInteressiResponse resp = WGC_WsRestFF.calcoloInteressi(param);
            response.success = resp.isCorrect();

        } catch(exception e){
            System.debug('@@@ ecc ' + e.getMessage() + ' -- ' + e.getLineNumber() + ' -- ' + e.getStackTraceString());
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    /* TIME04 - CALCOLO INTERESSI - END */

    /* TIME05 - CALCOLO DIP - START */
    
    @AuraEnabled
    public static WrapperResponse callCalcolaDIP(String creditoId){
        WrapperResponse response = new WrapperResponse();

        try{
            Id param = (Id) creditoId;
            WGC_WsRestFF.CalcoloDipResponse serviceResp = WGC_WsRestFF.calcoloDip(param);
            System.debug('@@@ resp ' + JSON.serialize(serviceResp));
            response.data.add(JSON.serialize(serviceResp));
        } catch(exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    /* TIME05 - CALCOLO DIP - START */

    /* TIME06 - CALCOLO DIP - START */

    @AuraEnabled
    public static WrapperResponse callCalcolaIRR(String creditoId){
        WrapperResponse response = new WrapperResponse();

        try{
            Id param = (Id) creditoId;
            WGC_WsRestFF.CalcoloIrrResponse serviceResp = WGC_WsRestFF.calcoloIrr(param);
            response.data.add(JSON.serialize(serviceResp));
        } catch(exception e){
            System.debug('@@@ e ' + e.getLineNumber() + ' -- ' + e.getStackTraceString());
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    /* TIME06 - CALCOLO DIP - START */

    /* TIME07 - CALCOLO COMPENSI - START */

    @AuraEnabled
    public static WrapperResponse callCalcolaCompensi(String creditoId){
        WrapperResponse response = new WrapperResponse();

        try{
            Id param = (Id) creditoId;
            WGC_WsRestFF.CalcoloCompensiResponse resp = WGC_WsRestFF.calcoloCompensi(param);
            
            response.success = resp.isCorrect();
        } catch(exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    /* TIME07 - CALCOLO COMPENSI - END */

    /* CHIAMATE AI SERVIZI */

    /* UTILITY - START */

    public class WrapperContainerPicklist{
        @AuraEnabled public String fieldName;
        @AuraEnabled public List<WGC_PC_CartController.WrapperPicklist> listaValori;
    }

    public class WrapperPicklist{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    @AuraEnabled
    public static WrapperResponse getPicklists(String sobj, List<String> fieldsApiName){
        WrapperResponse response = new WrapperResponse();

        try{
            if(sobj == 'Opportunity'){
                for(String field : fieldsApiName){
                    WrapperContainerPicklist wcp = new WrapperContainerPicklist();
                    wcp.fieldName = field;

                    Map<String,Schema.SObjectField> mapp = Opportunity.sObjectType.getDescribe().fields.getMap();
                    Schema.SObjectField sobjF = (Schema.SObjectField) mapp.get(field);
                    Schema.DescribeFieldResult F = sobjF.getDescribe();
                    List<Schema.PicklistEntry> P = F.getPicklistValues();

                    List<WrapperPicklist> wpList = new List<WrapperPicklist>();
                    for(Schema.PicklistEntry pe : P){
                        WrapperPicklist wp = new WrapperPicklist();
                        wp.label = pe.getLabel();
                        wp.value = pe.getValue();
                        wpList.add(wp);
                    }

                    wcp.listaValori = wpList;

                    System.debug('@@@ wcp ' + JSON.serialize(wcp));
                    response.data.add(wcp);
                }
            } else if(sobj == 'Credito__c'){
                for(String field : fieldsApiName){
                    WrapperContainerPicklist wcp = new WrapperContainerPicklist();
                    wcp.fieldName = field;

                    Map<String,Schema.SObjectField> mapp = Credito__c.sObjectType.getDescribe().fields.getMap();
                    Schema.SObjectField sobjF = (Schema.SObjectField) mapp.get(field);
                    Schema.DescribeFieldResult F = sobjF.getDescribe();
                    List<Schema.PicklistEntry> P = F.getPicklistValues();

                    List<WrapperPicklist> wpList = new List<WrapperPicklist>();
                    for(Schema.PicklistEntry pe : P){
                        WrapperPicklist wp = new WrapperPicklist();
                        wp.label = pe.getLabel();
                        wp.value = pe.getValue();
                        wpList.add(wp);
                    }

                    wcp.listaValori = wpList;
                    response.data.add(wcp);
                }
            }
        } catch (exception e){
            response.message = e.getMessage();
            response.success = false;
            System.debug('@@@ eccezione ' + e.getMessage() + ' -- ' + e.getLineNumber());
        }

        return response;
    }

    @AuraEnabled
    public static List<LookupSearchResult> search(String searchTerm, String objName, List<String> selectedIds, String whereClause) {
        // Prepare query paramters
        searchTerm += '*';
        // String objName = '';
        // Execute search query
        // List<List<SObject>> searchResults = [
        //     FIND :searchTerm
        //     IN ALL FIELDS
        //     RETURNING
        //         Account(Id, Name, PIVA__c, NDGGruppo__c WHERE id NOT IN :selectedIds),
        //         objName(Id, Name WHERE id NOT IN: selectedIds)
        //     LIMIT :MAX_RESULTS
        // ];

        String sFields = '';

        if(objName == 'Account') sFields = 'Id, Name, PIVA__c, NDGGruppo__c';
        else if(objName == 'WGC_AdE_Territoriale__c') sFields = 'Id, Name, Codice__c, Provincia__c';
        else if(objName == 'User') sFields = 'Id, Name';

        System.debug('@@@ searchTerm ' + searchTerm );
        String sQuery = 'FIND \'' + searchTerm + '\' IN ALL FIELDS RETURNING ' + objName + '(' + sFields + ' ' + whereClause + ') LIMIT 5';

        System.debug('@@@ sQuery ' + sQuery);

        List<List<SObject>> searchResults = Search.query(sQuery);
        // Opportunity(Id, Name, StageName WHERE id NOT IN :selectedIds)

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        if(objName == 'Account'){

            // Extract Accounts & convert them into LookupSearchResult
            String accountIcon = 'standard:account';
            Account[] accounts = ((List<Account>) searchResults[0]);
            for (Account account : accounts) {
                results.add(
                    new LookupSearchResult(
                        account.Id,
                        'Account',
                        accountIcon,
                        account.Name,
                        account.PIVA__c != null ? account.PIVA__c + ' • ' + account.NDGGruppo__c : ''
                    )
                );
            }
        }

        if(objName == 'WGC_AdE_Territoriale__c'){
            //AdE Territoriale
            String AdEIcon = 'custom:custom16';
            WGC_AdE_Territoriale__c[] AdEs = ((List<WGC_AdE_Territoriale__c>) searchResults[0]);
            for (WGC_AdE_Territoriale__c AdE : AdEs) {
                results.add(
                    new LookupSearchResult(
                        AdE.Id,
                        'Account',
                        AdEIcon,
                        AdE.Name,
                        AdE.Codice__c != null && AdE.Provincia__c != null ? AdE.Codice__c + ' • ' + AdE.Provincia__c : ''
                    )
                );
            }
        }

        if(objName == 'User'){
            //AdE Territoriale
            String userIcon = 'standard:user';
            User[] users = ((List<User>) searchResults[0]);
            for (User u : users) {
                results.add(
                    new LookupSearchResult(
                        u.Id,
                        'User',
                        userIcon,
                        u.Name,
                        ''
                    )
                );
            }
        }

        return results;
    }

    /* UTILITY - END */
}