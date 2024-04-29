public without sharing class WsRestCrmUtils {

  public static final Set<String> condizioniFactoringIndiceBaseCondMockato = new Set<String>{'C307'};
  public static final Set<String> condizioniFactoringIndiceBaseCond = new Set<String>{'C301' ,'C305', 'C314', 'C315', 'D312', 'D313', 'D314', 'D323', 'D324'};
  public static final Set<String> factFiscCodes = new Set<String>{'364','464','534','644','744','844'};
  //SM - TEN - CR 449 invio CDF su prodotti estero
  public static Boolean checkPrimoProdottoEstero = false;

  /**
   * Invoca Cedacri (NvAggiornamentoInnescaVendita) per innescare il processo di Nuova Vendita in ambiente Cedacri, gestendo il mapping tra i valori salvati in Cedacri e Salesforce
   */
  // @future(callout = true) - da checklist è sincrono
  public static String nvAggiornamentoInnescaVendita(Id opportunitaId) {
    Logger.setTransactionContext(opportunitaId, null);
    Opportunity opportunita = [SELECT Id, Account.NDGGruppo__c FROM Opportunity WHERE Id = :opportunitaId];
    if(String.isBlank(opportunita.Account.NDGGruppo__c)) throw new Ex.WSException('Ci sono attori senza NDG');
    if(![SELECT Id FROM NDGLinea__c WHERE NDG__c = null AND Tipo__c != 'Valutazione portafoglio' AND Opportunita__c = :opportunitaId].isEmpty()) throw new Ex.WSException('Ci sono attori senza NDG');

    WsRestCrm.NvAggiornamentoInnescaVenditaResponse response = WsRestCrm.NvAggiornamentoInnescaVendita(doMapping(opportunitaId), opportunitaId);
    return response.payload.idCartella;
  }

  /**
   * Metodo helper utilizzato per costruire il payload di input per il servizio Cedacri (NvAggiornamentoInnescaVendita)
   * @param  oppId id dell'opportunita
   * @return       payload di input per il servizio
   */
  public static WsRestCrm.NvAggiornamentoInnescaVenditaInput doMapping(Id oppId) {return doMapping(oppId, false);}
  public static WsRestCrm.NvAggiornamentoInnescaVenditaInput doMapping(Id oppId, Boolean isPef41) {
    /*
    // PER VISUALIZZARE IL PAYLOAD, LANCIARE DA ANONYMOUS
    Id opportunityId = '';
    System.debug(new WsRestInput(WsRestCrmUtils.doMapping(opportunityId)).toJSONString());
    */

    // PREPARO I DATI
    // MB - TEN: AGGIUNTA NUOVO CAMPO "WGC_Rinnovo__c"
    // MB - TEN: AGGIUNTA NUOVI CAMPI NOTE
    Opportunity opp = [SELECT Id,
                       Name,
                       Account.Filiale__c,
                       Account.NDGGruppo__c,
                       Account.BillingState,
                       NoteOperazioneProposte__c,
                       NoteStoricheAziendaeAttivitaSvolte__c,
                       ComposizioneDelCapitaleSociale__c,
                       NoteSuEsponentiManagementESoci__c,
                       ProgrammiEProspettiveFuture__c,
                       AnalisiDiBilancio__c,
                       RapportiBancariECR__c,
                       Approfondimenti__c,
                       DescrizioneOperazioneProposta__c,
                       Garanzie__c,
                       TiAnticipo__c,
                       Cessione__c,
                       WGC_Rinnovo__c,
                       WGC_NoteBilancio__c,
                       WGC_NoteCR__c,
                       WGC_NoteEventi__c,
                       Account.WGC_Descrizione_dell_azienda__c,
                       WGC_Descrizione_Operativit_Proposta__c,
                       WGC_Note_Condizioni_Economiche__c,
                       Account.PartecipazioneSocietaFiduciarie2__c,
                       Tipologia_Opportunit__c,
                       Owner.Name,
                       Account.WGC_Specialista_Factoring__r.Filiale__c,
                       WGC_Note_Automatiche__c,
                       WGC_Note_Automatiche_Estero__c, //SM - TEN: Note Automatiche Estero
                       RecordType.DeveloperName, //SM - TEN - CR 469
                       Owner.Filiale__c //SM - TEN - CR 469
                       FROM Opportunity
                       WHERE Id = :oppId];

    String ndgCedente = opp.Account.NDGGruppo__c;
    AdeguataVerifica__c[] adeguataVerificaList = [SELECT Id, Scopo_Factoring__c, Scopo_Finanziamenti__c, Scopo_Servizi_Bancari__c
													FROM AdeguataVerifica__c
												   WHERE Account__r.NDGGruppo__c = :ndgCedente
												ORDER BY LastModifiedDate desc 
												   LIMIT 1];
    AdeguataVerifica__c adeguataVerifica = (adeguataVerificaList.size() == 1) ? adeguataVerificaList.get(0) : null;

    Linea__c[] lineaList = [SELECT Id,
                            Prodotto__r.Codice__c,
                            Prodotto__r.Name,
                            Prodotto__r.TipoProdotto__c,
                            Prodotto__r.Categoria__c,
                            Prodotto__r.IsFactoring__c,
                            Prodotto__r.Applicazione__c,
                            Prodotto__r.CodiceProdotto__c,
                            Prodotto__r.CodiceUnivoco__c,
                            Opportunity__r.ModalitaDiAperturaPEF__c,
                            IdProdotto__c,
                            Importo__c,
                            QuotaProSoluto__c,
                            DivisaNew__c,
                            Mercato__c,
                            Durata__c,
                            LineaProsoluto__c,
                            LineaATD__c,
                            TipoLinea__c,
                            ICAR__c,
                            WGC_Numero_Linea_Credito__c,
                            HasCrediti__c,
                            RecordType.DeveloperName, //SM - TEN: Aggiunto campo DeveloperName per gestione DatiTecnici Prodotti Corporate
                            WGC_Pre_Ammortamento__c,
                            WGC_Durata_Ammortamento__c,
                            Opportunity__r.WGC_Comm_Disponibilit_Fondi_CDF_Trim__c
                            FROM Linea__c
                            WHERE Opportunity__c = :oppId
                            //SM - TEN: Aggiunta condizione per escludere i prodotti di estero per cui viene mandata la mail
                            AND Prodotto__r.CodiceUnivoco__c != 'DocumentateIncasso'
                            AND Prodotto__r.CodiceUnivoco__c != 'CreditoDocumentarioExport'];
    Set<String> prodottoSet = U.getSet(lineaList, 'Prodotto__r.Codice__c');

    //SM - TEN: Set aggiunto per escludere i PConfigurati delle linee corporate estero
    Set<Id> lineeCorporateEstero = new Set<Id>();
    for(Linea__c l : lineaList){
      if(l.RecordType.DeveloperName == 'WGC_Corporate_Estero'){
        lineeCorporateEstero.add(l.Id);
      }
    }

    JoinLineaDebitore__c[] joinLineaDebitoreList = [SELECT
                           Debitore__r.Account__c,
                           Debitore__r.Account__r.Name,
                           Debitore__r.NDG__c,
                           Debitore__r.Id,
                           Debitore__r.DivisaNew__c,
                           Debitore__r.Fatturato__c,
                           Debitore__r.Prosoluto__c,
                           Debitore__r.DiCuiProsoluto__c,
                           Debitore__r.Plafond__c,
                           Debitore__r.DurataNominale__c,
                           Linea__c
                           FROM JoinLineaDebitore__c
                           WHERE Opportunita__c = :oppId
                           AND (Fake__c = false OR Linea__r.Prodotto__r.Codice__c = '364' OR Linea__r.Prodotto__r.Codice__c = '464')
                           AND Debitore__r.Tipo__c != 'Valutazione portafoglio'];
    Map<String, JoinLineaDebitore__c[]> joinLineaDebitoreMap = U.groupBy(joinLineaDebitoreList, 'Linea__c');

    NDGLinea__c[] ndgLineaList = [SELECT Id,
                                  Linea__c,
                                  NDG__c,
                                  Tipo__c,
                                  Fatturato__c,
                                  Plafond__c,
                                  DurataNominale__c,
                                  DivisaNew__c
                                  FROM NDGLinea__c
                                  WHERE Opportunita__c = :oppId
                                  AND Tipo__c != 'Valutazione portafoglio'];
    Set<Id> debitoriIdSet = U.getIdSet(U.filter(ndgLineaList, 'Tipo__c', 'Debitore'), 'Id');

    NDGLinea__c richiedenteAccensioneRapporto;
    if (opp.Tipologia_Opportunit__c != 'RINN' && !isPef41) {
      for (NDGLinea__c ndgLinea : ndgLineaList) {
        if (ndgLinea.Tipo__c == 'Esecutore adeguata verifica') {
          richiedenteAccensioneRapporto = ndgLinea;
          break;
        }
      }

      if(richiedenteAccensioneRapporto == null) throw new Ex.WSException('Esecutore adeguata verifica non specificato');
    }

    // lista dei codici dei dati tecnici
    String[] datiTecniciCodiciTempList = new List<String>(Schema.getGlobalDescribe().get('MatriceDatiTecnici__mdt').getDescribe().fields.getMap().keySet());
    String[] datiTecniciCodiciList = new List<String>();
    for (String dtc : datiTecniciCodiciTempList) {
      if (dtc.endsWith('__c') && dtc != 'Codice__c') {
        datiTecniciCodiciList.add(dtc.toUpperCase(UserInfo.getLocale()).remove('__C'));
      }
    }

    // check: si puo ottimizzare con una 'where codice__c in prodottoset'
    //SM - TEN: Aggiunti nuovi campi per gestione dati tecnici Banca Corporate - MAV__c, RIBA__c, SDD__c
    //A.M. Modifica per nuovi campi tecnici "Codici circuiti" SBF - MAVCOD__c, RIBACOD__c, SDDCOD__c
    MatriceDatiTecnici__mdt[] datiTecniciList = [SELECT Codice__c,
                              CAT__c,
                              CATEV__c,
                              CATFA__c,
                              DILAZ__c,
                              FORMA__c,
                              FTEC__c,
                              LINEA__c,
                              SOTEV__c,
                              SOTFA__c,
                              SOTCOD__c,
                              MAV__c,
                              RIBA__c,
                              SDD__c,
                              MAVCOD__c,
                              RIBACOD__c,
                              SDDCOD__c
                              FROM MatriceDatiTecnici__mdt];
    Map<String, MatriceDatiTecnici__mdt[]> datiTecniciMap = U.groupBy(datiTecniciList, 'Codice__c');

    //SM - TEN: Aggiunta condizioni per escludere i PConfigurati di Corporate Estero
    PConfigurato__c[] pConfiguratoList = [SELECT Id,
                                          Codice__c,
                                          Linea__c,
                                          Linea__r.Prodotto__r.CodiceProdotto__c,
                                          Linea__r.Prodotto__r.CodiceUnivoco__c,
                                          Valore__c,
                                          Default__c,
                                          Tipo__c,
                                          Attore__c
                                          FROM PConfigurato__c
                                          WHERE Linea__c IN :lineaList AND
                                                Linea__c NOT IN :lineeCorporateEstero AND //SM - TEN: Condizione Corporate Estero
                                                (WGC_Parametro_revisionato__c = :isPef41
												OR Codice__c IN ('SF10', 'SF25', 'SF26'))];//A.M. Gestione parametri da passare in revisione [5/11/21] aggiunti i parametri SF25 e SF26
    Map<String, PConfigurato__c[]> pConfiguratoMap = U.groupBy(pConfiguratoList, 'Linea__c');
    Map<String, PConfigurato__c[]> pConfiguratoCodiceMap = U.groupBy(pConfiguratoList, '{Linea__c}_{Codice__c}', true);

    // MB - TEN: FIX ISSUE TENAM-34 *** START
    if (isPef41 == true) lineaList = U.filter(lineaList, 'Id', pConfiguratoMap.keySet());
    System.debug('@@@@ lineaList: ' + JSON.serialize(lineaList));
    // MB - TEN: FIX ISSUE TENAM-34 *** END

    ParametroProdotto__c[] parametroProdottoList = [SELECT Parametro__r.CodiceUnivoco__c,
                           Prodotto__r.Codice__c,
                           DBC__c,
                           DBCScag__c,
                           CheckDefault__c
                           FROM ParametroProdotto__c
                           WHERE Prodotto__r.Codice__c IN :prodottoSet];
    Map<String, ParametroProdotto__c[]> parametroProdottoMap = U.groupBy(parametroProdottoList, '{Prodotto__r.Codice__c}_{Parametro__r.CodiceUnivoco__c}', true);

    Parametro__c[] parametroList = [SELECT Id,
                                    CodiceUnivoco__c,
                                    Tipologia__c
                                    FROM Parametro__c];
    Map<String, Parametro__c[]> parametroMap = U.groupBy(parametroList, 'CodiceUnivoco__c');


    // per garanzia omnibus (Linea__c == null) e garanzie (Linea__c != null)
    //SM - TEN: Aggiunto Filtro sulle garanzie per non inviare la controgaranzia dei mutui controgarantiti
    Garanzia__c[] garanziaList = [SELECT Id,
                                  CodiceGaranzia__c,
                                  DivisaNew__c,
                                  Importo__c,
                                  Linea__c,
                                  PercentualeGaranziaImporto__c,
                                  Linea__r.Prodotto__r.CodiceUnivoco__c,
                                  Tipo__c
                                  FROM Garanzia__c
                                  WHERE Opportunita__c = :oppId];
    Map<String, Garanzia__c[]> garanziaMap = U.groupBy(garanziaList, 'Linea__c');

    //vedo se le garanzie sono PRO QUOTA o meno (informazione presente nella MatriceGaranzia__mdt, campo booleano ProQuota__c)
    //A.M. -> Aggiunto tipo garanzia
    MatriceGaranzie__mdt[] matrGaranzieList  =  [SELECT Id,
                                            CodiceKNET__c,
                                            ProQuota__c,
                                            Tipo__c     
                                            FROM MatriceGaranzie__mdt
                                            ];


    // per i referenti associati alle garanzie
    JoinGaranteGaranzia__c[] joinGaranteGaranziaList = [SELECT Id,
                                                        Garante__c,
                                                        Garante__r.NDG__c,
                                                        Garante__r.TipoGarante__c,
                                                        Garante__r.Account__c,
                                                        Garanzia__c,
                                                        PercentualeGaranzia__c
                                                        FROM JoinGaranteGaranzia__c
                                                        WHERE Garanzia__c IN :garanziaList];
    Map<String, JoinGaranteGaranzia__c[]> joinGaranteGaranziaMap = U.groupBy(joinGaranteGaranziaList, 'Garanzia__c');


    // MB - TEN: per i prodotti di FactoringFiscale
    Credito__c[] creditiList = [SELECT Id,
                                WGC_Anno__c,
                                WGC_Tipo_rimborso__c,
                                WGC_Progressivo_ICAR__c,
                                WGC_UniqueCode__c,
                                WGC_Val_Nom_Esigibile__c,
                                WGC_Linea__c,
                                WGC_Data_Richiesta_Rimborso__c
                                FROM Credito__c
                                WHERE WGC_Invia_Credito__c = true AND WGC_Linea__c IN :lineaList];
    // Map<String, Credito__c[]> creditiMap = U.groupBy(creditiList, 'WGC_Linea__c');

    // cerco l'idProdotto dell'eventuale PPIIM (mi servira' per collegarlo al fido) e se e' presente un fido, in modo da sapere se creare un PPIIM o PPBII
    //SM - TEN: Aggiunti Prodotti PSPTF e PPANT Banca Corporate
    Integer idProdottoPPIIM;
    Integer idProdottoPPINA;
    Integer idProdottoPSPTF;
    Integer idProdottoPPANT;
    Boolean trovatoPPIIM = false;
    Boolean trovatoPPINA = false;
    Boolean trovatoPCFII = false;
    Boolean trovatoPSPTF = false;
    Boolean trovatoPPANT = false;
    for (Linea__c linea : lineaList) {
      if (linea.Prodotto__r.CodiceProdotto__c == 'PCFII') {
        trovatoPCFII = true;
      }
      if (linea.Prodotto__r.CodiceProdotto__c == 'PPIIM') {
        idProdottoPPIIM = Integer.valueOf(linea.IdProdotto__c);
        trovatoPPIIM = true;
      }
      if (linea.Prodotto__r.CodiceProdotto__c == 'PPINA') {
        idProdottoPPINA = Integer.valueOf(linea.IdProdotto__c);
        trovatoPPINA = true;
      }
      if(linea.Prodotto__r.CodiceProdotto__c == 'PSPTF'){
        idProdottoPSPTF = Integer.valueOf(linea.IdProdotto__c);
        trovatoPSPTF = true;
      }
      if(linea.Prodotto__r.CodiceProdotto__c == 'PPANT'){
        idProdottoPPANT = Integer.valueOf(linea.IdProdotto__c);
        trovatoPPANT = true;
      }
      if ((trovatoPPIIM || trovatoPPINA) && trovatoPCFII && trovatoPSPTF && trovatoPPANT)
        break;
    }

    // recupero gli icar manuali e le certificazioni TiAnticipo (TODO: spostare questo metodo in un posto unico)
    IcarManuale__c[] icarManualiList = [SELECT Id,
                                    Debitore__c,
                                    AnnoFatturatoDa__c,
                                    AnnoFatturatoA__c,
                                    DataEmissioneDa__c,
                                    DataEmissioneA__c,
                                    NumeroFatturaDa__c,
                                    NumeroFatturaA__c,
                                    WGC_Credito__c
                                    FROM IcarManuale__c
                                    WHERE Debitore__c IN :debitoriIdSet OR WGC_Credito__c IN :creditiList];
    Map<String, IcarManuale__c[]> icarManualiMap = U.groupBy(U.filter(icarManualiList, 'WGC_Credito__c', (Object) null), 'Debitore__c');
    Map<String, IcarManuale__c[]> icarManualiCreditiMap = U.groupBy(U.filter(icarManualiList, 'WGC_Credito__c', (Object) null, false), 'WGC_Credito__c');

    Map<String, Certificazione__c[]> certificazioniMap = new Map<String, Certificazione__c[]>();
    if (opp.TiAnticipo__c)
      certificazioniMap = U.groupBy([SELECT
        Id,
        Debitore__c,
        DataFatturaMinima__c,
        DataFatturaMassima__c
        FROM Certificazione__c
        WHERE Cessione__c = :opp.Cessione__c
        AND Debitore__c IN :U.getSet(joinLineaDebitoreList, 'Debitore__r.Account__c')
        AND CertificazioneBocciata__c = false
      ], 'Debitore__c');

    // INIZIO IL PAYLOAD
    WsRestCrm.NvAggiornamentoInnescaVenditaInput input = new WsRestCrm.NvAggiornamentoInnescaVenditaInput();
    // input.userIdOperatore = 'YHC0050'; // TODO: check se sara' sempre questo
    input.ndgOperatore = 0; // TODO: in futuro non sara' questo
    // input.ruoloOperatore = 'U000'; // TODO: check se sara' sempre questo
    // MB - TEN: modifica alla gestione della filiale (il campo da cui attingere non sarà più il campo filiale dell'Account ma quello dello User)
    // if (opp.Account.Filiale__c == null || opp.Account.Filiale__c == '0') throw new Ex.WSException('Occorre popolare il campo filiale sulla scheda account prima di inoltrare il carrello a Nuova Vendita');
    
    //START - PRE CR 469
    // User u = [SELECT Filiale__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    // if (u.Profile.Name != 'Amministratore del Sistema' && u.Profile.Name != 'System Administrator')
    //   if (opp.Account.WGC_Specialista_Factoring__r.Filiale__c == null || opp.Account.WGC_Specialista_Factoring__r.Filiale__c == '000') { // ..VERIFICO CHE ANCHE LO SPECIALISTA ABBIA FILIALE NON VALIDA..
    //     throw new Ex.WSException('Occorre popolare il campo filiale sul dettaglio utente prima di inoltrare il carrello a Nuova Vendita');
    //   } else {
    //     //adione SDHDFNZ-94928 - gestione filiale "multipla", p.e. resp. di più filiali --> usiamo filiale dell'anagrafica, se manca su anag --> KO
    //     if (opp.Account.WGC_Specialista_Factoring__r.Filiale__c == 'Multipla')
    //       if (String.isBlank(opp.Account.Filiale__c))
    //         throw new Ex.WSException('Occorre popolare il campo filiale sul dettaglio utente e sull\'anagrafica prima di inoltrare il carrello a Nuova Vendita');              
    //       else
		// 		    input.filiale = Integer.valueOf(opp.Account.Filiale__c);
    //     else 
    //     //usiamo filiale dello specialista 
    //     input.filiale = Integer.valueOf(opp.Account.WGC_Specialista_Factoring__r.Filiale__c);
    //   }
    //END - PRE CR 469

    // SM - TEN - CR 469 
    //START - CR 469
    User u = [SELECT Filiale__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    //VALORIZZO DI DEFAULT LA FILIALE IN BASE ALLA FILIALE DELL'UTENTE CORRENTE
	//A.M. modifica provvisoria per consentire a FF di aprire rapporti su filiale '000', in attesa di abilitazione della 115
	Boolean IsCreditiErariali = false;
    input.filiale = Integer.valueOf(u.Filiale__c != null ? u.Filiale__c : '000'); //adione SDHDFNZ-78768
    if( opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' || opp.RecordType.DeveloperName == 'WGC_IFIS_Oppotunita_Crediti_Erariali' ){
      if(input.filiale == Integer.valueOf('000') || input.filiale == null){
        input.filiale = Integer.valueOf(opp.Owner.Filiale__c);
	    IsCreditiErariali = true;
      }

      if((input.filiale == Integer.valueOf('000') || input.filiale == null) && !IsCreditiErariali)
        throw new Ex.WSException('Occorre popolare il campo filiale sul dettaglio utente prima di inoltrare il carrello a Nuova Vendita');
    } else {
      // VERIFICO CHE CURRENT USER SIA DIVERSO DA ADMIN O CHE ABBIA FILIALE NON VALIDA..
      if (u.Profile.Name != 'Amministratore del Sistema' && u.Profile.Name != 'System Administrator')
        if ((u.Filiale__c == null || u.Filiale__c == '000') && !IsCreditiErariali ) //adione SDHDFNZ-78768
          if (opp.Account.WGC_Specialista_Factoring__r.Filiale__c == null || opp.Account.WGC_Specialista_Factoring__r.Filiale__c == '000') { // ..VERIFICO CHE ANCHE LO SPECIALISTA ABBIA FILIALE NON VALIDA..
            throw new Ex.WSException('Occorre popolare il campo filiale sul dettaglio utente prima di inoltrare il carrello a Nuova Vendita');
          } else {
            input.filiale = Integer.valueOf(opp.Account.WGC_Specialista_Factoring__r.Filiale__c);
          }
    }
    // END - CR469

    // input.filiale = Integer.valueOf(opp.Account.Filiale__c);

    input.intestatario = Integer.valueOf(opp.Account.NDGGruppo__c);
    input.noteIstruttoria = EncodingUtil.base64Encode(Blob.valueOf(creaNoteIstruttoriaHTML(opp)));

    // ASSOCIAZIONE GARANZIA OMNIBUS
    if (garanziaMap.containsKey('null')) {
      input.associazioneGaranziaOmnibus = mappingAssociazioneGaranziaOmnibus(garanziaMap.get('null'), joinGaranteGaranziaMap, matrGaranzieList);
    }

    // PRODOTTI
    input.prodotti = new WsRestCrm.Prodotti();
    input.prodotti.prodotto = new List<WsRestCrm.Prodotto>();

    for (Linea__c linea : lineaList) {
      // skippo i prodotti da non inviare a NV (provvisorio)
      if (((linea.Prodotto__r.Codice__c == null && !(linea.Prodotto__r.CodiceProdotto__c == 'PCFII' || linea.Prodotto__r.CodiceProdotto__c == 'PCPLD')) || linea.WGC_Numero_Linea_Credito__c != null) && !isPef41)
        continue;

      WsRestCrm.Prodotto prodotto = new WsRestCrm.Prodotto();

      PConfigurato__c[] condizioniFactoringList = new List<PConfigurato__c>();
      PConfigurato__c[] parametriAggiuntiviList = new List<PConfigurato__c>();
      Map<String, PConfigurato__c[]> parametriFidoCoppiaList = new Map<String, PConfigurato__c[]>();
      Map<String, PConfigurato__c[]> valoreSF10PerAttore = new Map<String, PConfigurato__c[]>();
	  //A.M. Gestione parametri SF25 e SF26
	  Map<String, PConfigurato__c[]> valoreSF256PerAttore = new Map<String, PConfigurato__c[]>();
      String valoreSF16 = '0'; //TODO: <-- smockare
      String valoreSF17 = '0'; //TODO: <-- smockare
      String valoreSF19 = null;
      PConfigurato__c[] condizioniList = new List<PConfigurato__c>();
        
        
      if (linea.Prodotto__r.IsFactoring__c) {
        if (linea.Prodotto__r.CodiceUnivoco__c != 'ATDTiAnticipo') parametriAggiuntiviList.add(creaMockParametro008(linea, '60'));
        if (linea.Prodotto__r.CodiceUnivoco__c == 'ATDTiAnticipo') parametriAggiuntiviList.add(creaMockParametro008(linea, '90'));
        //TODO: pulire codice
        if (pConfiguratoMap.containsKey(linea.Id)) {
          for (PConfigurato__c p : pConfiguratoMap.get(linea.Id)) {
            if (p.Attore__c == null) {
              if (p.Codice__c.startsWith('C') || p.Codice__c.startsWith('D')) {
                condizioniFactoringList.add(p);
              } else if (p.Codice__c.startsWith('S')) {
                if (p.Codice__c == 'SF16') {
                  valoreSF16 = p.Valore__c;
                } else if (p.Codice__c == 'SF17') {
                  valoreSF17 = p.Valore__c;
                } else if (p.Codice__c == 'SF19' && p.Valore__c != '999') { // per le linee cinesi SF19 è il valore fittizio 999. non devo considerarlo
                  valoreSF19 = p.Valore__c;
                }
                continue;
              } else {
                parametriAggiuntiviList.add(p);
              }
			  //A.M. Gestione parametri da passare in revisione (!p.Codice__c.startsWith('S') || p.Codice__c == 'SF25' || p.Codice__c == 'SF26')
            } else if (!p.Codice__c.startsWith('C') && !p.Codice__c.startsWith('D') && !p.Codice__c.startsWith('S')) {
              // note: per PCDFO i parametri obbligatori da inviare a KNET senza default sono 008, 046, 265
              //       per PCMAT i parametri obbligatori da inviare a KNET senza default sono 008, 046, 091, 104, 224, 265
              if (parametriFidoCoppiaList.containsKey(p.Attore__c)) {
                parametriFidoCoppiaList.get(p.Attore__c).add(p);
              } else {
                parametriFidoCoppiaList.put(p.Attore__c, new List<PConfigurato__c>{p});
              }
              //SM-CART-REVI
              //Aggiunti parametri SF24, SF25, SF26
              //p.Codice__c == 'SF24' || p.Codice__c == 'SF25' || p.Codice__c == 'SF26'
            } else if (p.Attore__c != null && p.Codice__c == 'SF10' ) { // TODO: refactor, usare U.addToGMap
              if (valoreSF10PerAttore.containsKey(p.Attore__c)) {
                valoreSF10PerAttore.get(p.Attore__c).add(p);
              } else {
                valoreSF10PerAttore.put(p.Attore__c, new List<PConfigurato__c>{p});
              }
            } else if (p.Attore__c != null && (p.Codice__c == 'SF25' || p.Codice__c == 'SF26') ) { 
              if (valoreSF256PerAttore.containsKey(p.Attore__c)) {
                valoreSF256PerAttore.get(p.Attore__c).add(p);
              } else {
                valoreSF256PerAttore.put(p.Attore__c, new List<PConfigurato__c>{p});
              }
            }
          }
        }
      } else {
        if (pConfiguratoMap.containsKey(linea.Id)) {
          for (PConfigurato__c p : pConfiguratoMap.get(linea.Id)) {
            String key = linea.Prodotto__r.Codice__c + '_' + p.Codice__c;
            if (p.Codice__c.contains('_')) {
              if ((parametroProdottoMap.containsKey(key) && !parametroProdottoMap.get(key)[0].CheckDefault__c)
                  || p.Valore__c != p.Default__c)
              // Aggiungo alla lista "condizioniList" i pconfigurati con "_" di cui non devo controllare il default
              // oppure quelli con valore != da default
                condizioniList.add(p);
              
              //SM - TEN: Aggiunto controllo per parametro spread sbf
              /*
              System.debug('@@@ p.Linea ' + p.Linea__r.Prodotto__r.CodiceUnivoco__c);
              System.debug('@@@ p.Codice__c ' + p.Codice__c);
              if(p.Codice__c == 'CDA02_1053' && p.Linea__r.Prodotto__r.CodiceUnivoco__c != 'AnticipoFatture'){
                  condizioniList.add(p);
              }*/
            }
            else if (factFiscCodes.contains(linea.Prodotto__r.Codice__c) && (p.Codice__c.startsWith('C') || p.Codice__c.startsWith('D'))) condizioniFactoringList.add(p);
            else if (!p.Codice__c.contains('_') && p.Codice__c != 'CONV' && !p.Codice__c.startsWith('SF')) parametriAggiuntiviList.add(p);
              
            if (p.Codice__c == 'SF16') {
              valoreSF16 = p.Valore__c;
            } else if (p.Codice__c == 'SF17') {
              valoreSF17 = p.Valore__c;
            }
          }
        }
      }

      System.debug('@@@ parametriFidoCoppiaList ' + JSON.serialize(parametriFidoCoppiaList));
      // INFO PRODOTTO

      //if(prodotto.CodiceUnivoco__c == )
      prodotto.idProdotto = Integer.valueOf(linea.IdProdotto__c);
      prodotto.codiceApplicazione = linea.Prodotto__r.Applicazione__c;
      prodotto.codiceProdotto = linea.Prodotto__r.CodiceProdotto__c;

      prodotto.descrizioneProdotto = linea.Prodotto__r.Name;
      prodotto.tipologia = linea.Prodotto__r.TipoProdotto__c;
      prodotto.categoria = linea.Prodotto__r.Categoria__c;

      // ASSOCIAZIONE PRODOTTI: sembra che al momento gestiamo solo prodotti base, quindi non e' necessario
      // prodotto.associazioneProdotti = mappingAssociazioneProdotti();

      // DATI TECNICI
      //SM - TEN: Aggiunta gestione dell'associazione prodotti tramite switch per gestire più prodotti, in seguito a Banca Corporate
      // Integer idProdottoLineaAssociata = (idProdottoPPIIM != null ? idProdottoPPIIM : (idProdottoPPINA != null ? idProdottoPPINA : (linea.Prodotto__r.CodiceProdotto__c == 'PCPOR' ? idProdottoPSPTF : linea.Prodotto__r.CodiceProdotto__c == 'PCAFT' ? idProdottoPPANT : null )));
      Integer idProdottoAssociato = null;

      switch on linea.Prodotto__r.CodiceProdotto__c{
        when 'PCFII'{
          idProdottoAssociato = (idProdottoPPIIM != null ? idProdottoPPIIM : (idProdottoPPINA != null ? idProdottoPPINA : null));
        }
        // when 'PCFII'{
        //   idProdottoAssociato = (idProdottoPPIIM != null ? idProdottoPPIIM : (idProdottoPPINA != null ? idProdottoPPINA : null));
        // }
        when 'PCPOR'{
          idProdottoAssociato = idProdottoPSPTF;
        }
        when 'PCAFT'{
          idProdottoAssociato = idProdottoPPANT;
        }
      }

      prodotto.datiTecnici = mappingDatiTecnici(datiTecniciCodiciList, datiTecniciMap, linea, pConfiguratoCodiceMap, idProdottoAssociato, adeguataVerifica, opp.Account.BillingState);

      // MB - TEN: AGGIUNTA DATO TECNICO "FRINN" PER INDICAZIONE OPPORTUNITA' DI RINNOVO
      WsRestCrm.DatoTecnico dt1 = new WsRestCrm.DatoTecnico();
        dt1.codice = 'FRIN';
        // dt1.valore = (opp.WGC_Rinnovo__c == true ? 'S' : 'N');
        dt1.valore = (WizardOpportunityController.getParametriModificati(lineaList) == true ? 'S' : 'N');
      prodotto.datiTecnici.datoTecnico.add(dt1);
      // MB - TEN: END

      // CONDIZIONI FACTORING / CONDIZIONI: Condizioni economiche per CC in base al fatturato, l'account è in un segmento. small, medium, large
      if (linea.Prodotto__r.IsFactoring__c || factFiscCodes.contains(linea.Prodotto__r.Codice__c)) {
        prodotto.condizioniFactoring = mappingCondizioniFactoring(condizioniFactoringList, valoreSF16, valoreSF17, valoreSF19, parametroMap, linea, parametroProdottoMap);
      } else {
        // come gestire le condizioni fido / conto?
        //SM - TEN - CR 449 CDF
        // if((linea.Prodotto__r.CodiceProdotto__c == 'PPANT' || linea.Prodotto__r.CodiceProdotto__c == 'PSPTF' || linea.Prodotto__r.CodiceProdotto__c == 'PCQ01' || linea.Prodotto__r.CodiceProdotto__c == 'PCQ07' || linea.Prodotto__r.CodiceProdotto__c == 'PCH05') && !checkPrimoProdottoEstero){
        //   prodotto.condizioni = new WsRestCrm.Condizioni();
        //   prodotto.condizioni.condizione = new List<WsRestCrm.Condizione>();
        //   prodotto.condizioni.condizione.add(creaCondizione((new PConfigurato__c(Codice__c = 'FIDI2_8001', Valore__c = String.valueOf(linea.Opportunity__r.WGC_Comm_Disponibilit_Fondi_CDF_Trim__c))), null));
        //   checkPrimoProdottoEstero = true;
        // } else {
        //   prodotto.condizioni = mappingCondizioni(condizioniList);
        // }
        prodotto.condizioni = mappingCondizioni(condizioniList);
      }

      // FIDI COPPIA
      if (factFiscCodes.contains(linea.Prodotto__r.Codice__c)) {
        prodotto.fidiCoppia = mappingFidiCoppiaFromCrediti(linea, joinLineaDebitoreMap, creditiList, pConfiguratoCodiceMap);
      } else if (linea.Prodotto__r.IsFactoring__c) {
        //A.M. Modificata firma per recuperare i parametri nei fidi coppia (aggiunto valoreSF256PerAttore)  
        prodotto.fidiCoppia = mappingFidiCoppia(linea, joinLineaDebitoreMap, parametriFidoCoppiaList, parametroMap, valoreSF10PerAttore, icarManualiMap, certificazioniMap, valoreSF256PerAttore);
      }

      // ASSOCIAZIONE NDG RUOLI
      prodotto.associazioneNdgRuoli = mappingAssociazioneNdgRuoli(opp, linea, ndgLineaList, joinLineaDebitoreMap, richiedenteAccensioneRapporto, isPef41);

      // PARAMETRI AGGIUNTIVI
      if (parametriAggiuntiviList != null && parametriAggiuntiviList.size() > 0)
        prodotto.parametriAggiuntivi = mappingParametriAggiuntivi(parametriAggiuntiviList, parametroMap);

      // ASSOCIAZIONE GARANZIE
      if (garanziaMap.containsKey(linea.Id)) {
        prodotto.associazioneGaranzie = mappingAssociazioneGaranzie(garanziaMap.get(linea.Id), joinGaranteGaranziaMap, matrGaranzieList);
      }

      System.debug('@@@ prodotto ' + JSON.serialize(prodotto));
      input.prodotti.prodotto.add(prodotto);
    }

    return input;
  }

  public static String creaNoteIstruttoriaHTML(Opportunity opp) {
    String noteIstruttoria;
    if (opp != null) {
      // MB - TEN: MODIFICATA LA COMPOSIZIONE DEL FILE CON ELENCO NOTE
      // noteIstruttoria = '<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><title>Note istruttoria</title></head><body>';
      // noteIstruttoria += creaTitoloHTML('Descrizione azienda');
      // noteIstruttoria += creaParagrafoHTML(opp.NoteStoricheAziendaeAttivitaSvolte__c);
      // noteIstruttoria += creaParagrafoHTML(opp.ComposizioneDelCapitaleSociale__c);
      // noteIstruttoria += creaParagrafoHTML(opp.NoteSuEsponentiManagementESoci__c);
      // noteIstruttoria += creaParagrafoHTML(opp.ProgrammiEProspettiveFuture__c);
      // noteIstruttoria += creaTitoloHTML('Situazione economico / finanziaria');
      // noteIstruttoria += creaParagrafoHTML(opp.AnalisiDiBilancio__c);
      // noteIstruttoria += creaParagrafoHTML(opp.RapportiBancariECR__c);
      // noteIstruttoria += creaParagrafoHTML(opp.Approfondimenti__c);
      // noteIstruttoria += creaTitoloHTML('Operatività proposta'.escapeHtml4());
      // noteIstruttoria += creaParagrafoHTML(opp.DescrizioneOperazioneProposta__c);
      // noteIstruttoria += creaParagrafoHTML(opp.Garanzie__c);
      // noteIstruttoria += '</body></html>';
      noteIstruttoria = '<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><title>Note istruttoria</title></head><body>';
      noteIstruttoria += creaParagrafoHTML('Richiesta di: ' + opp.Owner.Name);
      noteIstruttoria += creaTitoloHTML('Descrizione dell\'azienda'.escapeHtml4());
      noteIstruttoria += creaParagrafoHTML(opp.Account.WGC_Descrizione_dell_azienda__c);
      noteIstruttoria += creaTitoloHTML('Note Eventi');
      noteIstruttoria += creaParagrafoHTML(opp.WGC_NoteEventi__c);
      noteIstruttoria += creaTitoloHTML('Note CR');
      noteIstruttoria += creaParagrafoHTML(opp.WGC_NoteCR__c);
      noteIstruttoria += creaTitoloHTML('Note Bilancio');
      noteIstruttoria += creaParagrafoHTML(opp.WGC_NoteBilancio__c);
      noteIstruttoria += creaTitoloHTML('Operatività proposta'.escapeHtml4());
      noteIstruttoria += creaParagrafoHTML(opp.WGC_Descrizione_Operativit_Proposta__c);
      noteIstruttoria += creaTitoloHTML('Deroghe condizioni sui fidi di coppia');
      noteIstruttoria += creaParagrafoHTML(opp.WGC_Note_Condizioni_Economiche__c);
      noteIstruttoria += creaTitoloHTML('Note automatiche');
      noteIstruttoria += creaParagrafoHTML(opp.WGC_Note_Automatiche__c);
      //SM - TEN: Note Automatiche Estero
      noteIstruttoria += creaTitoloHTML('Note automatiche estero');
      noteIstruttoria += creaParagrafoHTML(opp.WGC_Note_Automatiche_Estero__c);
      noteIstruttoria += '</body></html>';
    }
    return noteIstruttoria;
  }

  public static String creaTitoloHTML(String titolo) {
    return '<h1>' + titolo + '</h1>';
  }

  public static String creaParagrafoHTML(String paragrafo) {
    if (paragrafo == null) return null;
    // pulizia dei caratteri non stampabili e codifica in html
    String paragrafoPulito = Pattern.compile('[^\\x0A\\x0D\\x20-\\x7e€°£àáèéìíòóùú]').matcher(paragrafo).replaceAll(' ');
    return '<p>' + paragrafoPulito.escapeHtml4().replaceAll('\\n', '<br>') + '</p>';
  }

  @TestVisible
  private static WsRestCrm.AssociazioneGaranziaOmnibus mappingAssociazioneGaranziaOmnibus(Garanzia__c[] garanziaList, Map<String, JoinGaranteGaranzia__c[]> joinGaranteGaranziaMap, MatriceGaranzie__mdt[] matrGaranzieList) {
    if (garanziaList.size() > 0) {
      WsRestCrm.AssociazioneGaranziaOmnibus associazioneGaranziaOmnibus = new WsRestCrm.AssociazioneGaranziaOmnibus();
      associazioneGaranziaOmnibus.garanzia = creaListaGaranzie(garanziaList, joinGaranteGaranziaMap, matrGaranzieList);
      return associazioneGaranziaOmnibus;
    }
    return null;
  }

  @TestVisible
  private static WsRestCrm.AssociazioneGaranzie mappingAssociazioneGaranzie(Garanzia__c[] garanziaList, Map<String, JoinGaranteGaranzia__c[]> joinGaranteGaranziaMap, MatriceGaranzie__mdt[] matrGaranzieList) {
    if (garanziaList.size() > 0) {
      WsRestCrm.AssociazioneGaranzie associazioneGaranzie = new WsRestCrm.AssociazioneGaranzie();
      associazioneGaranzie.garanzia = creaListaGaranzie(garanziaList, joinGaranteGaranziaMap, matrGaranzieList);
      return associazioneGaranzie;
    }
    return null;
  }

  /**
   * Metodo helper che mappa una lista di garanzie nel formato da inviare a NV
   * @param  garanziaList           lista di garanzie
   * @param  joinGaranteGaranziaMap lista di garanti per ogni garanzia
   * @return                        la lista di garanzie nel formato per NV
   */
  @TestVisible
  private static List<WsRestCrm.Garanzia> creaListaGaranzie(Garanzia__c[] garanziaList, Map<String, JoinGaranteGaranzia__c[]> joinGaranteGaranziaMap, MatriceGaranzie__mdt[] matrGaranzieList) {

    Map<String,MatriceGaranzie__mdt[]> mapMatriceGaranzie = U.groupBy(matrGaranzieList, 'CodiceKNET__c');
    List<WsRestCrm.Garanzia> garanziaListNV = new List<WsRestCrm.Garanzia>();
    List<String> idControgaranti = UtenzeDefault__c.getOrgDefaults().IdGaranteDefaultMutuoControgarantitoMCC__c.split(';');
    for (Garanzia__c gara : garanziaList) {
        if(joinGaranteGaranziaMap.containsKey(gara.Id)){
            Set<String> garantiId = (Set<String>)U.getSet(joinGaranteGaranziaMap.get(gara.Id), 'Garante__r.Account__c'); 
            Boolean checkControgaranti = false;
            for(String s : idControgaranti){
                if(garantiId.contains(s)){
                    checkControgaranti = true;
                    break;
                }
            }
            if(checkControgaranti)
            	continue;
        }
        WsRestCrm.Garanzia garanzia = new WsRestCrm.Garanzia();
        garanzia.flagProQuota = mapMatriceGaranzie.get(gara.CodiceGaranzia__c)[0].ProQuota__c ? 'S' : 'N';
        garanzia.codiceGaranzia = gara.CodiceGaranzia__c;
        // todo: generalizzare codice, accedere alla matrice garanzie e controllare tipologia "importo/percentuale"
        //A.M. -> Inizio gestione generalizzato delle garanzie
        String TipoGara = mapMatriceGaranzie.get(gara.CodiceGaranzia__c)[0].Tipo__c;
        System.debug('### TipoGara ' + TipoGara);
        System.debug('### CodiceGaranzia ' + garanzia.codiceGaranzia);
        // if (gara.CodiceGaranzia__c != 'GARFD') {
        if (TipoGara != 'Percentuale') {
          garanzia.divisa = gara.DivisaNew__c;
          garanzia.importo = gara.Importo__c;
        } else {
          garanzia.divisa = '';
          garanzia.importo = 0;
          garanzia.prcGaranzia = gara.PercentualeGaranziaImporto__c;
        }
        // garanzia.dataGara = ;
        // garanzia.dataScadGara = ;
        garanzia.referenti = new WsRestCrm.Referenti();
        garanzia.referenti.referente = new List<WsRestCrm.Referente>();
        if(joinGaranteGaranziaMap.containsKey(gara.Id)) {
          for (JoinGaranteGaranzia__c jgg : joinGaranteGaranziaMap.get(gara.Id)) {
            WsRestCrm.Referente referente = new WsRestCrm.Referente();
            referente.codTipoGarante = jgg.Garante__r.TipoGarante__c;
            referente.importoGarante = gara.Importo__c * jgg.PercentualeGaranzia__c / 100; // TODO valutare se inserire campo "importo" in joingarantegaranzia
            referente.ndg = Integer.valueOf(jgg.Garante__r.NDG__c);
            referente.percentuale = jgg.PercentualeGaranzia__c;
            garanzia.referenti.referente.add(referente);
          }
        }
        garanziaListNV.add(garanzia);
      }
    return garanziaListNV;
    return null;
  }

  // ASSOCIAZIONE PRODOTTI  // TODO check: sembra che al momento gestiamo solo prodotti base, quindi non e' necessario
  // @TestVisible
  // private static WsRestCrm.AssociazioneProdotti mappingAssociazioneProdotti() {
  //   WsRestCrm.AssociazioneProdotti associazioneProdotti = new WsRestCrm.AssociazioneProdotti();
  //   associazioneProdotti.prodottoBase = new List<WsRestCrm.ProdottoBase>();
  //   // for ... TODO: inserire i prodotti base
  //     WsRestCrm.ProdottoBase prodottoBase = new WsRestCrm.ProdottoBase();
  //     prodottoBase.idProdotto = ;
  //     associazioneProdotti.prodottoBase.add(prodottoBase);
  //   return associazioneProdotti;
  // }

  @TestVisible
  private static WsRestCrm.DatiTecnici mappingDatiTecnici(String[] datiTecniciCodiciList, Map<String, MatriceDatiTecnici__mdt[]> datiTecniciMap, Linea__c linea, Map<String, PConfigurato__c[]> pConfiguratoCodiceMap, Integer idProdottoColl, AdeguataVerifica__c adeguataVerifica, String provinciaDestinazioneInvestimento) {
    WsRestCrm.DatiTecnici datiTecnici = new WsRestCrm.DatiTecnici();
    WsRestCrm.DatoTecnico[] datoTecnicoList = new List<WsRestCrm.DatoTecnico>();
    String datoTTemp;
    // inserisco i dati tecnici presenti nella matrice (i loro valori son fissi in base al Prodotto__c)..
    // TODO: aggiungere un campo alla matricedatitecnici col codice prodotto, chiave mappa datiTecniciMap (in modo da poter inserire anche PCFII)

    if (datiTecniciMap.containsKey(linea.Prodotto__r.Codice__c)) {
      for (String datoT : datiTecniciCodiciList) {
        datoTTemp = (String) datiTecniciMap.get(linea.Prodotto__r.Codice__c)[0].get(datoT + '__c');
        if (datoTTemp != null) {
          WsRestCrm.DatoTecnico dt = new WsRestCrm.DatoTecnico();
          dt.codice = datoT;
          dt.valore = datoTTemp;
          datoTecnicoList.add(dt);
        }
      }
    }
    // @nonni modifica valorizzazione scopo
    if(adeguataVerifica!=null) {
        //A.M. Remedy HOST00007681447 - Cedacri non gestisce lo SCOPO per i plafond (61)
        //if (linea.Prodotto__r.Applicazione__c == '61' || linea.Prodotto__r.Applicazione__c == '31') {
        if (linea.Prodotto__r.Applicazione__c == '31') {
            WsRestCrm.DatoTecnico dt = new WsRestCrm.DatoTecnico();
            dt.codice = 'SCOPO';
            dt.valore = adeguataVerifica.Scopo_Factoring__c;
            datoTecnicoList.add(dt);
        } else if (linea.Prodotto__r.Applicazione__c == '21C') {
            WsRestCrm.DatoTecnico dt = new WsRestCrm.DatoTecnico();
            dt.codice = 'SCOPO';
            dt.valore = adeguataVerifica.Scopo_Finanziamenti__c;
            datoTecnicoList.add(dt);    
        } else if (linea.Prodotto__r.Applicazione__c == '09F' || linea.Prodotto__r.Applicazione__c == '01') {
            WsRestCrm.DatoTecnico dt = new WsRestCrm.DatoTecnico();
            dt.codice = 'SCOPO';
            dt.valore = adeguataVerifica.Scopo_Servizi_Bancari__c;
            datoTecnicoList.add(dt);
        }
    }
    // ..inserisco i dati tecnici i cui valori dipendono dalla linea..
    if (linea.Prodotto__r.CodiceProdotto__c == 'PPIIM' || linea.Prodotto__r.CodiceProdotto__c == 'PPBII' || linea.Prodotto__r.CodiceProdotto__c == 'PPINA' || linea.Prodotto__r.CodiceProdotto__c == 'PPINR') {
      WsRestCrm.DatoTecnico dt = new WsRestCrm.DatoTecnico();
      dt.codice = 'CONV';
      dt.valore = (pConfiguratoCodiceMap.containsKey(linea.Id + '_' + dt.codice)) ? pConfiguratoCodiceMap.get(linea.Id + '_' + dt.codice)[0].Valore__c : 'NOCON';
      datoTecnicoList.add(dt);
      /* @nonni modifica valorizzazione scopo
      WsRestCrm.DatoTecnico dt2 = new WsRestCrm.DatoTecnico();
      dt2.codice = 'SCOPO';
      dt2.valore = (adeguataVerifica!=null)? adeguataVerifica.Scopo_Servizi_Bancari__c : '14'; //mappaScopoAccensione(adeguataVerifica);
      datoTecnicoList.add(dt2);*/
    } else if (linea.Prodotto__r.CodiceProdotto__c == 'PCFII') {
      WsRestCrm.DatoTecnico dt1 = new WsRestCrm.DatoTecnico();
      dt1.codice = 'FORMA';
      dt1.valore = '1';
      datoTecnicoList.add(dt1);
      WsRestCrm.DatoTecnico dt2 = new WsRestCrm.DatoTecnico();
      dt2.codice = 'SOTCOD';
      dt2.valore = '01';
      datoTecnicoList.add(dt2);
      WsRestCrm.DatoTecnico dt3 = new WsRestCrm.DatoTecnico();
      dt3.codice = 'IMP';
      dt3.valore = String.valueOf(linea.Importo__c);
      datoTecnicoList.add(dt3);
      WsRestCrm.DatoTecnico dt4 = new WsRestCrm.DatoTecnico();
      dt4.codice = 'RCOLL';
      dt4.valore = String.valueOf(idProdottoColl);
      datoTecnicoList.add(dt4);
//      WsRestCrm.DatoTecnico dt5 = new WsRestCrm.DatoTecnico();
//      dt5.codice = 'TIPO';
//      dt5.valore = ''; // TODO: dominio?
//      datoTecnicoList.add(dt5);
//      WsRestCrm.DatoTecnico dt6 = new WsRestCrm.DatoTecnico();
//      dt6.codice = 'DRIC';
//      dt6.valore = Datetime.now().format('yymmdd');
//      datoTecnicoList.add(dt6);
//      WsRestCrm.DatoTecnico dt7 = new WsRestCrm.DatoTecnico();
//      dt7.codice = 'DSCAD';
//      dt7.valore = ''; //TODO: .format('yymmdd')
//      datoTecnicoList.add(dt7);

    } else if (linea.RecordType.DeveloperName == 'WGC_Corporate_Estero'){
      if(linea.Prodotto__r.CodiceProdotto__c != 'PCQ01'){
        WsRestCrm.DatoTecnico dtDataScad = new WsRestCrm.DatoTecnico();
        dtDataScad.codice = 'DSCAD';
        DateTime dscad = System.Now().addDays(Integer.valueOf(linea.Durata__c));
        dtDataScad.valore = dscad.format('yyMMdd');
        datoTecnicoList.add(dtDataScad);
      }
      WsRestCrm.DatoTecnico dtImporto = new WsRestCrm.DatoTecnico();
      dtImporto.codice = 'IMP';
      dtImporto.valore = String.valueOf(linea.Importo__c);
      datoTecnicoList.add(dtImporto);
      //SM - TEN: CR Aggiunto dato tecnico CODDIVISA per linee corporate estero
      WsRestCrm.DatoTecnico dtDivisa = new WsRestCrm.DatoTecnico();
      dtDivisa.codice = 'CODDIVISA';
      dtDivisa.valore = String.valueOf(linea.DivisaNew__c);//linea.IdProdotto__c;
      datoTecnicoList.add(dtDivisa);
//     A.M. Gestione Dati tecnici per nuovo prodotto PCMDL e PC13E
//  -> A.M. - 21/09/2020 - Nuovo prodotto PCSAC: Gestione Dati tecnici per tipologia di prodotto (tutti i mutui hanno codice 21C)
//    } else if (linea.Prodotto__r.CodiceProdotto__c == 'PCMCC' || linea.Prodotto__r.CodiceProdotto__c == 'PCMPR' || linea.Prodotto__r.CodiceProdotto__c == 'PCNSA' || linea.Prodotto__r.CodiceProdotto__c == 'PCASS' || linea.Prodotto__r.CodiceProdotto__c == 'PCMDL' || linea.Prodotto__r.CodiceProdotto__c == 'PC13E' || linea.Prodotto__r.CodiceProdotto__c == 'PCSAC') {
    } else if (linea.Prodotto__r.Applicazione__c == '21C') {    
      WsRestCrm.DatoTecnico dt1 = new WsRestCrm.DatoTecnico();
      dt1.codice = 'CONV';
      dt1.valore = (pConfiguratoCodiceMap.containsKey(linea.Id + '_' + dt1.codice)) ? pConfiguratoCodiceMap.get(linea.Id + '_' + dt1.codice)[0].Valore__c : 'NOCON';
      datoTecnicoList.add(dt1);
      WsRestCrm.DatoTecnico dt2 = new WsRestCrm.DatoTecnico();
      dt2.codice = 'IMP';
      dt2.valore = (linea.Importo__c != null) ? String.valueOf(linea.Importo__c) : '0';
      datoTecnicoList.add(dt2);
      WsRestCrm.DatoTecnico dt3 = new WsRestCrm.DatoTecnico();
      dt3.codice = 'DURA';
      dt3.valore = (linea.Durata__c != null) ? (linea.WGC_Pre_ammortamento__c ? String.valueOf(linea.WGC_Durata_Ammortamento__c) : String.valueOf(linea.Durata__c)) : '0';
      datoTecnicoList.add(dt3);
      WsRestCrm.DatoTecnico dt4 = new WsRestCrm.DatoTecnico();
      dt4.codice = 'PRIN';
      dt4.valore = (provinciaDestinazioneInvestimento != null) ? provinciaDestinazioneInvestimento : '';
      datoTecnicoList.add(dt4);
      WsRestCrm.DatoTecnico dt5 = new WsRestCrm.DatoTecnico();
      dt5.codice = 'RDI';
      // dt5.valore = '01'; // TODO: da smockare
      // MB - TEN: Modifica del parametro approvata da Luca Bigatti (vedi mail: venerdì 17 maggio 2019 11.34)
      dt5.valore = '13';
      datoTecnicoList.add(dt5);      
// 	  A.M. Gestione Mutuo Veneto Sviluppo (Servizio 06C)
      } else if (linea.Prodotto__r.Applicazione__c == '06C') {    
        WsRestCrm.DatoTecnico dt1 = new WsRestCrm.DatoTecnico();
        dt1.codice = 'SPRE';
        dt1.valore = (pConfiguratoCodiceMap.containsKey(linea.Id + '_' + 'SF66')) ? pConfiguratoCodiceMap.get(linea.Id + '_' + 'SF66')[0].Valore__c : '0';
        datoTecnicoList.add(dt1);
        WsRestCrm.DatoTecnico dt2 = new WsRestCrm.DatoTecnico();
        dt2.codice = 'CTAS';
        dt2.valore = 'A60';
        datoTecnicoList.add(dt2);
        WsRestCrm.DatoTecnico dt3 = new WsRestCrm.DatoTecnico();
        dt3.codice = 'IMP';
        dt3.valore = (linea.Importo__c != null) ? String.valueOf(linea.Importo__c) : '0';
        datoTecnicoList.add(dt3);  
        WsRestCrm.DatoTecnico dt4 = new WsRestCrm.DatoTecnico();
        dt4.codice = 'DURA';
        dt4.valore = (linea.Durata__c != null) ? (linea.WGC_Pre_ammortamento__c ? String.valueOf(linea.WGC_Durata_Ammortamento__c) : String.valueOf(linea.Durata__c)) : '0';
        datoTecnicoList.add(dt4);
        WsRestCrm.DatoTecnico dt5 = new WsRestCrm.DatoTecnico();
        dt5.codice = 'PRIN';
        dt5.valore = (provinciaDestinazioneInvestimento != null) ? provinciaDestinazioneInvestimento : '';
        datoTecnicoList.add(dt5);
        WsRestCrm.DatoTecnico dt6 = new WsRestCrm.DatoTecnico();
        dt6.codice = 'RDI';
        dt6.valore = '13';
        datoTecnicoList.add(dt6);   
    } else if (linea.Prodotto__r.CodiceProdotto__c == 'PCPLD') {
      WsRestCrm.DatoTecnico dt1 = new WsRestCrm.DatoTecnico();
      dt1.codice = 'ENDO';
      dt1.valore = String.valueOf(linea.Importo__c).replace('.', ',');
      datoTecnicoList.add(dt1);
      WsRestCrm.DatoTecnico dt2 = new WsRestCrm.DatoTecnico();
      dt2.codice = 'UTO';
      dt2.valore = String.valueOf(linea.QuotaProSoluto__c != null ? linea.QuotaProSoluto__c : 0).replace('.', ',');
      datoTecnicoList.add(dt2);
    } else if(linea.Prodotto__r.CodiceProdotto__c == 'PPANT'){ //SM - TEN: Aggiunta condizione per Anticipo Fatture 
      WsRestCrm.DatoTecnico dt1 = new WsRestCrm.DatoTecnico();
      dt1.codice = 'CONV';
      dt1.valore = (pConfiguratoCodiceMap.containsKey(linea.Id + '_' + dt1.codice)) ? pConfiguratoCodiceMap.get(linea.Id + '_' + dt1.codice)[0].Valore__c : '05901'; //dt1.valore = '05901';
      datoTecnicoList.add(dt1);
    } else if(linea.Prodotto__r.CodiceProdotto__c == 'PPFRA'){ //SM - TEN: Aggiunta condizione ContoCedenti SBF
      WsRestCrm.DatoTecnico dt1 = new WsRestCrm.DatoTecnico();
      dt1.codice = 'CONV';
      dt1.valore = '02100';
      datoTecnicoList.add(dt1);
    } else if(linea.Prodotto__r.CodiceProdotto__c == 'PCAFT'){ //SM - TEN: Aggiunta condizione per Fido Anticipo Fatture RCOLL --> Associato a PPANT
      WsRestCrm.DatoTecnico dt1 = new WsRestCrm.DatoTecnico();
      dt1.codice = 'RCOLL';
      System.debug('@@@ idProdottoColl ' + idProdottoColl);
      dt1.valore = String.valueOf(idProdottoColl);//linea.IdProdotto__c;
      datoTecnicoList.add(dt1);
      WsRestCrm.DatoTecnico dt2 = new WsRestCrm.DatoTecnico();
      dt2.codice = 'IMP';
      dt2.valore = String.valueOf(linea.Importo__c);
      datoTecnicoList.add(dt2);
    } else if(linea.Prodotto__r.CodiceProdotto__c == 'PCPOR'){ //SM - TEN: Aggiunta condizione per Fido SBF RCOLL --> Associato A PSPTF
      WsRestCrm.DatoTecnico dt1 = new WsRestCrm.DatoTecnico();
      dt1.codice = 'RCOLL';
      dt1.valore = String.valueOf(idProdottoColl);//linea.IdProdotto__c;
      datoTecnicoList.add(dt1);
      WsRestCrm.DatoTecnico dt2 = new WsRestCrm.DatoTecnico();
      dt2.codice = 'IMP';
      dt2.valore = String.valueOf(linea.Importo__c);
      datoTecnicoList.add(dt2);
    } else if(linea.RecordType.DeveloperName != 'Corporate' && linea.RecordType.DeveloperName != 'WGC_Corporate_Estero'){ //SM - TEN: Aggiunta condizione per escludere i prodotti di corporate // ora rimangono solo i factoring e Corporate Estero
      WsRestCrm.DatoTecnico dt1 = new WsRestCrm.DatoTecnico();
      dt1.codice = 'DIVIS';
      dt1.valore = String.isNotBlank(linea.DivisaNew__c) ? linea.DivisaNew__c : '242';
      datoTecnicoList.add(dt1);
      WsRestCrm.DatoTecnico dt2 = new WsRestCrm.DatoTecnico();
      dt2.codice = 'MERCA';
      dt2.valore = (linea.Mercato__c != null) ? linea.Mercato__c : '001';
      datoTecnicoList.add(dt2);
      WsRestCrm.DatoTecnico dt3 = new WsRestCrm.DatoTecnico();
      dt3.codice = 'PROS';
      dt3.valore = (linea.LineaProsoluto__c) ? 'C' : 'E';
      datoTecnicoList.add(dt3);
      if (linea.Prodotto__r.CodiceProdotto__c == 'PCGSN') { // per il Not Not senza anticipazione cablo l'importo a 0...
        WsRestCrm.DatoTecnico dt5 = new WsRestCrm.DatoTecnico();
        dt5.codice = 'IMPOR';
        dt5.valore = '0';
        datoTecnicoList.add(dt5);
      } else if (pConfiguratoCodiceMap.containsKey(linea.Id + '_' + 'SF6')) { // ..per gli altri uso il pConfigurato SF6
        WsRestCrm.DatoTecnico dt5 = new WsRestCrm.DatoTecnico();
        dt5.codice = 'IMPOR';
        dt5.valore = (linea.Prodotto__r.Codice__c == '364' || linea.Prodotto__r.Codice__c == '464' ? '0' : pConfiguratoCodiceMap.get(linea.Id + '_' + 'SF6')[0].Valore__c);
        datoTecnicoList.add(dt5);
      } else {
        // throw new Ex.WSException('Importo della linea ' + linea.Prodotto__r.CodiceProdotto__c + ' mancante');
      }
    }
    // ..e per tutti i prodotti:
    WsRestCrm.DatoTecnico dt1 = new WsRestCrm.DatoTecnico();
      dt1.codice = 'FCONS';
      dt1.valore = 'N'; //TODO: SMOCKARE // (linea.Opportunity__r.ModalitaDiAperturaPEF__c == null || linea.Opportunity__r.ModalitaDiAperturaPEF__c == 'Pre-consolidata') ? 'N' : 'S';
      datoTecnicoList.add(dt1);
    datiTecnici.datoTecnico = datoTecnicoList;
    return datiTecnici;
  }

  //@TestVisible
  //private static String mappaScopoAccensione(AdeguataVerifica__c av) {
    //// nota: importante seguire l'ordine, inviare il valore associato al primo true
    //if (av != null) {
      //if (av.ScopoFD11__c) // Gestione tesorerie aziendali
        //return '13';
      //if (av.ScopoFD12__c) // Affidamenti Concessi
        //return '14';
      //if (av.ScopoFD13__c) // Attività di investimento
        //return '15';
      //if (av.ScopoFD14__c) // Gestione inc/pag. az. - cc su basi attive
        //return '16';
      //if (av.ScopoFD15__c) // Smobilizzo crediti commerciali Italia
        //return '18';
      //if (av.ScopoFD16__c) // Gestione stipendi dei dipendenti
        //return '19';
      //if (av.ScopoFD17__c) // Gestione fornitori
        //return '20';
      //if (av.ScopoFD18__c) // Smobilizzo crediti commerciali estero
        //return '21';
      //if (av.ScopoFD19__c) // Regolamento transazioni da e per estero
        //return '22';
    //}
    //return '14';           // default = valore che invio con 'Affidamenti Concessi'
  //}

  @TestVisible
  private static WsRestCrm.CondizioniFactoring mappingCondizioniFactoring(PConfigurato__c[] condizioniFactoringList, String valoreSF16, String valoreSF17, String valoreSF19, Map<String, Parametro__c[]> parametroMap, Linea__c linea, Map<String, ParametroProdotto__c[]> parametroProdottoMap) {
    if (condizioniFactoringList.size() > 0) {
      WsRestCrm.CondizioniFactoring condizioniFactoring = new WsRestCrm.CondizioniFactoring();
      condizioniFactoring.condizioneFactoring = new List<WsRestCrm.CondizioneFactoring>();
      for (PConfigurato__c p : condizioniFactoringList) {
        String codDBC = null;
        String codDBCscag = null;
        codDBC = (parametroProdottoMap.containsKey(linea.Prodotto__r.Codice__c + '_' + p.Codice__c)) ? parametroProdottoMap.get(linea.Prodotto__r.Codice__c + '_' + p.Codice__c)[0].DBC__c : null;
        codDBCscag = (parametroProdottoMap.containsKey(linea.Prodotto__r.Codice__c + '_' + p.Codice__c)) ? parametroProdottoMap.get(linea.Prodotto__r.Codice__c + '_' + p.Codice__c)[0].DBCScag__c : null;
        if (p.Codice__c == 'C165' || p.Codice__c == 'D165') {
          Decimal scaglionamento;
          if (p.Codice__c == 'C165')
            scaglionamento = Decimal.valueOf(valoreSF16).setScale(4);//.setScale(2);
          if (p.Codice__c == 'D165')
            scaglionamento = Decimal.valueOf(valoreSF17).setScale(4);//.setScale(2);
          WsRestCrm.CondizioneFactoring cf = creaCondizioneFactoringC165(p, valoreSF16, parametroMap, codDBC, codDBCscag);
          cf.valoriCondFactoring.valoreCondFactoring.add(creaValoreCondFactoring(0.00, 0.00, scaglionamento, 1, null));
          condizioniFactoring.condizioneFactoring.add(cf);
          WsRestCrm.CondizioneFactoring cf2 = creaCondizioneFactoringC165(p, valoreSF16, parametroMap, codDBC, codDBCscag);
          cf2.valoriCondFactoring.valoreCondFactoring.add(creaValoreCondFactoring(Decimal.valueOf(p.Valore__c), scaglionamento+1, 999999999999999.99, 2, null));
          condizioniFactoring.condizioneFactoring.add(cf2);
        } else {
          if (String.isNotBlank(p.Valore__c)) condizioniFactoring.condizioneFactoring.add(creaCondizioneFactoring(p, valoreSF16, valoreSF19, parametroMap, codDBC, codDBCscag));
        }
      }
      return condizioniFactoring;
    }
    return null;
  }

  @TestVisible
  private static WsRestCrm.CondizioneFactoring creaCondizioneFactoring(PConfigurato__c pConfigurato, String valoreSF16, String valoreSF19, Map<String, Parametro__c[]> parametroMap, String codDBC, String codDBCscag) {

    String[] pConfiguratoValori = pConfigurato.Valore__c.split(';');

    if (parametroMap.get(pConfigurato.Codice__c) == null) return null;

    String tipoCond = mappaCodTipoPara(parametroMap.get(pConfigurato.Codice__c)[0], pConfigurato);

    WsRestCrm.CondizioneFactoring condizioneFactoring = new WsRestCrm.CondizioneFactoring();
    condizioneFactoring.codDBC = codDBC;
    condizioneFactoring.codDBCscag = codDBCscag;
    condizioneFactoring.codiceCond = pConfigurato.Codice__c;
    // condizioneFactoring.periodicita = ;
    condizioneFactoring.tipoCond = tipoCond;
    // condizioneFactoring.tipoGiorni = ;
    // condizioneFactoring.tipoRangeScagl = ;
    condizioneFactoring.valoriCondFactoring = new WsRestCrm.ValoriCondFactoring();
    condizioneFactoring.valoriCondFactoring.valoreCondFactoring = new List<WsRestCrm.ValoreCondFactoring>();

    for (String pConfiguratoValore : pConfiguratoValori) {
      String indiceBaseCond = null;
      if (condizioniFactoringIndiceBaseCondMockato.contains(pConfigurato.Codice__c) && pConfigurato.Linea__r.Prodotto__r.CodiceUnivoco__c != 'ATDTiAnticipo') indiceBaseCond = '0107'; // TODO: <- smockare
      if (condizioniFactoringIndiceBaseCond.contains(pConfigurato.Codice__c) && valoreSF19 != null) indiceBaseCond = valoreSF19;
      condizioneFactoring.valoriCondFactoring.valoreCondFactoring.add(creaValoreCondFactoring(Decimal.valueOf(pConfigurato.Valore__c), null, null, null, indiceBaseCond));
    }
    return condizioneFactoring;
  }

  @TestVisible
private static WsRestCrm.CondizioneFactoring creaCondizioneFactoringC165(PConfigurato__c pConfigurato, String valoreSF16, Map<String, Parametro__c[]> parametroMap, String codDBC, String codDBCscag) {

    if (parametroMap.get(pConfigurato.Codice__c) == null) return null;

    String tipoCond = mappaCodTipoPara(parametroMap.get(pConfigurato.Codice__c)[0], pConfigurato);
    WsRestCrm.CondizioneFactoring condizioneFactoring = new WsRestCrm.CondizioneFactoring();
    condizioneFactoring.codDBC = codDBC;
    condizioneFactoring.codDBCscag = codDBCscag;
    condizioneFactoring.codiceCond = pConfigurato.Codice__c;
    // condizioneFactoring.periodicita = ;
    condizioneFactoring.tipoCond = tipoCond;
    // condizioneFactoring.tipoGiorni = ;
    condizioneFactoring.tipoRangeScagl = 'N';
    condizioneFactoring.valoriCondFactoring = new WsRestCrm.ValoriCondFactoring();
    condizioneFactoring.valoriCondFactoring.valoreCondFactoring = new List<WsRestCrm.ValoreCondFactoring>();
    return condizioneFactoring;
  }

  @TestVisible
  private static WsRestCrm.ValoreCondFactoring creaValoreCondFactoring(Decimal valueCond, Decimal minScag, Decimal maxScag, Integer prgScagCond, String indiceBaseCond) {
    WsRestCrm.ValoreCondFactoring valoreCondFactoring = new WsRestCrm.ValoreCondFactoring();
    valoreCondFactoring.minScag = (minScag != null) ? minScag : null;
    valoreCondFactoring.maxScag = (maxScag != null) ? maxScag : null;
    valoreCondFactoring.indiceBaseCond = indiceBaseCond;
    valoreCondFactoring.prgScagCond = (prgScagCond != null) ? prgScagCond : null;
    valoreCondFactoring.valueCond = valueCond;
    return valoreCondFactoring;
  }

  @TestVisible
  private static WsRestCrm.Condizioni mappingCondizioni(PConfigurato__c[] condizioniList) {
    if (condizioniList.size() > 0) {
      WsRestCrm.Condizioni condizioni = new WsRestCrm.Condizioni();
      // condizioni.note = ;
      condizioni.condizione = new List<WsRestCrm.Condizione>();
      for (PConfigurato__c p : condizioniList) {
        // assegno un valore all'indice solo nel caso in cui la linea sia un conto..
        String indice;
        //SM - TEN: Aggiunti codici prodotto per Banca Corporate
        if (p.Linea__r.Prodotto__r.CodiceProdotto__c == 'PPIIM' || p.Linea__r.Prodotto__r.CodiceProdotto__c == 'PPBII' || p.Linea__r.Prodotto__r.CodiceProdotto__c == 'PPINR' || p.Linea__r.Prodotto__r.CodiceProdotto__c == 'PPINA' || p.Linea__r.Prodotto__r.CodiceProdotto__c == 'PPANT' || p.Linea__r.Prodotto__r.CodiceProdotto__c == 'PSPTF' || p.Linea__r.Prodotto__r.CodiceProdotto__c == 'PPFRA') {
            //A.M. Gestione indice solo per le condizioni che lo richiedono
            if (p.Codice__c == 'CDA02_1050' || p.Codice__c == 'CDA02_1051' || p.Codice__c == 'CDA02_1052' || p.Codice__c == 'CDA02_1053'){
              indice = '9107'; // TODO: <- smockare  //'9107' -> produzione, '9007'-> addestramento    
            }
            //A.M. -> Fine 
        }
        // .. e creo una condizione per ogni parametro configurato, gestendo i casi particolari
        //SM - TEN: Escludo la condizione sull sbf poichè la inserisco nelle note automatiche
        if(p.Linea__r.Prodotto__r.CodiceProdotto__c == 'PSPTF' && p.Codice__c == 'CDA02_1053'){
          continue;
        } else {
          condizioni.condizione.add(creaCondizione(p, indice));
        }
        //SM - TEN: commentato perchè la condizione 1050, viene ora gestita con i parametri configurati solo per i C/C Residenti, mentre per i C/C Non Residente segue la seguente logica
        if(p.Codice__c.split('_')[1] == '1052' && ( p.Linea__r.Prodotto__r.CodiceProdotto__c == 'PPINR' || p.Linea__r.Prodotto__r.CodiceProdotto__c == 'PPINA' ) ) {
          condizioni.condizione.add(creaCondizione(new PConfigurato__c(Codice__c = 'CDA02_1050', Valore__c = String.valueOf(Decimal.valueOf(p.Valore__c)+3)), indice));
        }
      }
      return condizioni;
    }
    return null;
  }

  @TestVisible
  private static WsRestCrm.Condizione creaCondizione(PConfigurato__c pCondizione, String indice) {
    if (pCondizione != null) {
      String[] informazioniCondizione = pCondizione.Codice__c.split('_');
      WsRestCrm.Condizione condizione = new WsRestCrm.Condizione();
      condizione.dataDecorrenza = Long.valueOf(Datetime.now().format('yyyyMMdd')); // TODO: smockare
      // condizione.dataRevoca = ;
      // condizione.costante = ;
      condizione.datoElementare = Integer.valueOf(informazioniCondizione[1]);
      condizione.indice = indice;
      // A.M. -> Gestione Condizioni Indicizzate
      if (indice != null){
          String Target = '.';
          String Replace = ',';
          string Valore = pCondizione.Valore__c;
          condizione.costante = Valore.replace(Target, Replace);
          condizione.natura = 'REL';
          condizione.operatore = '+';
      } else {
          condizione.valoreProposto = pCondizione.Valore__c;
      }
      // A.M. -> Fine
      condizione.linea = informazioniCondizione[0].substring(0,3);
      condizione.listino = informazioniCondizione[0];
      // condizione.operatore = ;
      return condizione;
    }
    return null;
  }

  @TestVisible
  private static WsRestCrm.AssociazioneNdgRuoli mappingAssociazioneNdgRuoli(Opportunity opp, Linea__c linea, NDGLinea__c[] ndgLineaList, Map<String, JoinLineaDebitore__c[]> joinLineaDebitoreMap, NDGLinea__c richiedenteAccensioneRapporto, Boolean isPef41) {
    WsRestCrm.AssociazioneNdgRuoli associazioneNdgRuoli = new WsRestCrm.AssociazioneNdgRuoli();
    WsRestCrm.Associazione[] associazioneList = new List<WsRestCrm.Associazione>();

    if (linea.Prodotto__r.IsFactoring__c) {
      // FACTORING = cedente, debitori e racc
      if (joinLineaDebitoreMap.containsKey(linea.Id)) {
        for (JoinLineaDebitore__c joinLineaDebitore : joinLineaDebitoreMap.get(linea.Id)) {
          if (joinLineaDebitore.Debitore__r.NDG__c != null)
            associazioneList.add(creaAssociazioneNdg(Integer.valueOf(joinLineaDebitore.Debitore__r.NDG__c), 'DEB'));
        }
      }
      if (opp.Account.NDGGruppo__c != null)
        associazioneList.add(creaAssociazioneNdg(Integer.valueOf(opp.Account.NDGGruppo__c), 'CED'));
      if (opp.Tipologia_Opportunit__c != 'RINN' && !isPef41)
        if (richiedenteAccensioneRapporto.NDG__c != null) {
          associazioneList.add(creaAssociazioneNdg(Integer.valueOf(richiedenteAccensioneRapporto.NDG__c), 'RACC'));
          associazioneList.add(creaAssociazioneNdg(Integer.valueOf(richiedenteAccensioneRapporto.NDG__c), 'DELG'));
        }

    } else if (linea.Prodotto__r.CodiceProdotto__c == 'PCPLD') {
      // STANDARD e CON PROROGA (plafond debitore) = cedente
      if (opp.Account.NDGGruppo__c != null)
        associazioneList.add(creaAssociazioneNdg(Integer.valueOf(opp.Account.NDGGruppo__c), 'CED'));

    } else if (linea.Prodotto__r.CodiceProdotto__c == 'PPIIM' || linea.Prodotto__r.CodiceProdotto__c == 'PPBII' || linea.Prodotto__r.CodiceProdotto__c == 'PPINR' || linea.Prodotto__r.CodiceProdotto__c == 'PPINA') {
      // CONTI = titolari, racc e delg
      if (opp.Account.NDGGruppo__c != null)
        associazioneList.add(creaAssociazioneNdg(Integer.valueOf(opp.Account.NDGGruppo__c), 'TIT'));
      if (opp.Tipologia_Opportunit__c != 'RINN' && !isPef41)
        if (richiedenteAccensioneRapporto.NDG__c != null) {
          associazioneList.add(creaAssociazioneNdg(Integer.valueOf(richiedenteAccensioneRapporto.NDG__c), 'RACC'));
          associazioneList.add(creaAssociazioneNdg(Integer.valueOf(richiedenteAccensioneRapporto.NDG__c), 'DELG'));
        }

    } else if (factFiscCodes.contains(linea.Prodotto__r.Codice__c)) {
      // FACTORING FISCALE
      if (joinLineaDebitoreMap.containsKey(linea.Id)) {
        for (JoinLineaDebitore__c joinLineaDebitore : joinLineaDebitoreMap.get(linea.Id)) {
          if (joinLineaDebitore.Debitore__r.NDG__c != null && linea.Prodotto__r.Codice__c != '744' && linea.Prodotto__r.Codice__c != '844')
            associazioneList.add(creaAssociazioneNdg(Integer.valueOf(joinLineaDebitore.Debitore__r.NDG__c), 'DEB'));
        }
      }
      if (opp.Account.NDGGruppo__c != null)
        associazioneList.add(creaAssociazioneNdg(Integer.valueOf(opp.Account.NDGGruppo__c), 'CED'));
      if (richiedenteAccensioneRapporto.NDG__c != null) {
        associazioneList.add(creaAssociazioneNdg(Integer.valueOf(richiedenteAccensioneRapporto.NDG__c), 'RACC'));
        associazioneList.add(creaAssociazioneNdg(Integer.valueOf(richiedenteAccensioneRapporto.NDG__c), 'DELG'));
      }
    } else {
      // MUTUI = titolari e racc
      if (opp.Account.NDGGruppo__c != null)
        associazioneList.add(creaAssociazioneNdg(Integer.valueOf(opp.Account.NDGGruppo__c), 'TIT'));
      if (opp.Tipologia_Opportunit__c != 'RINN' && !isPef41)
        if (richiedenteAccensioneRapporto.NDG__c != null) {
          associazioneList.add(creaAssociazioneNdg(Integer.valueOf(richiedenteAccensioneRapporto.NDG__c), 'RACC'));
        }
    }
    
    associazioneNdgRuoli.associazione = associazioneList;
    return associazioneNdgRuoli;
  }

  @TestVisible
  private static WsRestCrm.Associazione creaAssociazioneNdg(Integer ndgAttore, String codiceRuolo) {
    WsRestCrm.Associazione associazioneRacc = new WsRestCrm.Associazione();
    associazioneRacc.ndg = ndgAttore;
    associazioneRacc.codiceRuolo = codiceRuolo;
    return associazioneRacc;
  }

  @TestVisible
  private static WsRestCrm.ParametriAggiuntivi mappingParametriAggiuntivi(PConfigurato__c[] parametriPerTutti, Map<String, Parametro__c[]> parametroMap) {
    WsRestCrm.ParametriAggiuntivi parametriAggiuntivi = new WsRestCrm.ParametriAggiuntivi();
    WsRestCrm.Parametro[] parametroList = new List<WsRestCrm.Parametro>();

    for(PConfigurato__c p : parametriPerTutti) {
      if (p.Valore__c != null && parametroMap.get(p.Codice__c) != null) {
        String codTipoPara = mappaCodTipoPara(parametroMap.get(p.Codice__c)[0], p);
        parametroList.add(creaParametro(p.Codice__c, codTipoPara, p.Valore__c));
      }
    }
    parametriAggiuntivi.parametro = parametroList;
    return parametriAggiuntivi;
  }

  @TestVisible
  private static WsRestCrm.FidiCoppia mappingFidiCoppia(Linea__c linea, Map<String, JoinLineaDebitore__c[]> joinLineaDebitoreMap, Map<String, PConfigurato__c[]> parametriFidoCoppiaList, Map<String, Parametro__c[]> parametroMap, Map<String, PConfigurato__c[]> valoreSF10PerAttore, Map<String, IcarManuale__c[]> icarManualiMap, Map<String, Certificazione__c[]> certificazioniMap, Map<String, PConfigurato__c[]> valoreSF256PerAttore) {
    if (joinLineaDebitoreMap.containsKey(linea.Id)) {
      WsRestCrm.FidiCoppia fidiCoppia = new WsRestCrm.FidiCoppia();
      WsRestCrm.FidoCoppia[] fidoCoppiaList = new List<WsRestCrm.FidoCoppia>();

      for (JoinLineaDebitore__c joinLineaDebitore : joinLineaDebitoreMap.get(linea.Id)) {
	     System.debug('@@@A.M. valoreSF256PerAttore: ' + JSON.serialize(valoreSF256PerAttore));
        //A.M. -> Nuovo prodotto PCAMC (ACF MCC)  & ACF Bonus Edilizi (PCANE)
        if (parametriFidoCoppiaList.containsKey(joinLineaDebitore.Debitore__c) || valoreSF256PerAttore.containsKey(joinLineaDebitore.Debitore__c) || linea.Prodotto__r.CodiceProdotto__c == 'PCACF' || linea.Prodotto__r.CodiceProdotto__c == 'PCAMC' || linea.Prodotto__r.CodiceProdotto__c == 'PCANE' || linea.Prodotto__r.CodiceProdotto__c == 'PCANM' || linea.Prodotto__r.CodiceProdotto__c == 'PCBEM') {
          //A.M. Modificata firma (aggiunto valoreSF256PerAttore) per gestire i valori Prosoluto e Prosolvendo 
          WsRestCrm.FidoCoppia fidoCoppia = creaFidoCoppia(linea, joinLineaDebitore, valoreSF10PerAttore, valoreSF256PerAttore);
          fidoCoppia.parametriFidoCoppia.parametro = creaParametriFidoCoppiaObbligatori(linea, joinLineaDebitore, valoreSF10PerAttore);
          
		  if (parametriFidoCoppiaList.containsKey(joinLineaDebitore.Debitore__c) || linea.Prodotto__r.CodiceProdotto__c == 'PCACF' || linea.Prodotto__r.CodiceProdotto__c == 'PCAMC' || linea.Prodotto__r.CodiceProdotto__c == 'PCANE' || linea.Prodotto__r.CodiceProdotto__c == 'PCANM' || linea.Prodotto__r.CodiceProdotto__c == 'PCBEM') {
            // TODO ICAR: al momento inviamo gli icar solo per il prodotto PCTAN
            // if (linea.Prodotto__r.CodiceUnivoco__c == 'ATDTiAnticipo' || linea.Prodotto__r.Codice__c == '742') {
            // MB - TENAM-9: GESTIONE ICAR MANUALI DA MATRICE ATD
            if (WizardOpportunityController.hasIcarManuali(linea)) {
              if (!icarManualiMap.containsKey(joinLineaDebitore.Debitore__c) && !certificazioniMap.containsKey(joinLineaDebitore.Debitore__r.Account__c)) throw new Ex.WSException('Nessun Icar manuale configurato per il debitore ' + joinLineaDebitore.Debitore__r.Account__r.Name);
              IcarManuale__c[] icars = icarManualiMap.containsKey(joinLineaDebitore.Debitore__c) ? icarManualiMap.get(joinLineaDebitore.Debitore__c) : null;
              Certificazione__c[] certs = certificazioniMap.containsKey(joinLineaDebitore.Debitore__r.Account__c) ? certificazioniMap.get(joinLineaDebitore.Debitore__r.Account__c) : null;
              fidoCoppia.parametriFidoCoppia.parametro.addAll(creaParametriFidoCoppiaIcarManuali(icars, certs));
            }
            if (parametriFidoCoppiaList.get(joinLineaDebitore.Debitore__c) != null) fidoCoppia.parametriFidoCoppia.parametro.addAll(creaParametriFidoCoppiaLista(parametriFidoCoppiaList.get(joinLineaDebitore.Debitore__c), parametroMap));
          }
		  fidoCoppiaList.add(fidoCoppia);
        }
      }
      fidiCoppia.fidoCoppia = fidoCoppiaList;
      return fidiCoppia;
    }
    return null;

  }

  // Come determinare se un fido coppia è CAR o ICAR?
  // se la linea è prosolvendo -> si può avere solo un fido coppia CAR (in questo caso CAR = "E")
  // se la linea è prosoluto   -> bisogna avere almeno 1 CAR oppure 1 ICAR. C'è la possibilità di inserire + ICAR. (in questo caso CAR = "C", ICAR = "I")
  // Al momento non ci sono questi controlli sul numero dei fido coppia.
  @TestVisible
  private static WsRestCrm.FidoCoppia creaFidoCoppia(Linea__c linea, JoinLineaDebitore__c joinLineaDebitore, Map<String, PConfigurato__c[]> valoreSF10PerAttore, Map<String, PConfigurato__c[]> valoreSF256PerAttore) {
    WsRestCrm.FidoCoppia fidoCoppia = new WsRestCrm.FidoCoppia();
    fidoCoppia.codDivisa = joinLineaDebitore.Debitore__r.DivisaNew__c;
    fidoCoppia.codNDGDebi = (joinLineaDebitore.Debitore__r.NDG__c != null) ? Integer.valueOf(joinLineaDebitore.Debitore__r.NDG__c) : null;
    fidoCoppia.codTipoCoppia = (linea.LineaProsoluto__c ? (linea.LineaATD__c && String.isNotBlank(linea.ICAR__c) && linea.ICAR__c.contains('ICAR') ? 'I' : 'C') : 'E');
    System.debug ('@@@A.M. valoreSF10PerAttore: ' + JSON.serialize(valoreSF10PerAttore));
	//A.M. -> Nuovo prodotto PCAMC (ACF MCC)  & ACF Bonus Edilizi (PCANE)
    if ((linea.Prodotto__r.CodiceProdotto__c == 'PCACF' || linea.Prodotto__r.CodiceProdotto__c == 'PCACN' || linea.Prodotto__r.CodiceProdotto__c == 'PCAMC' || linea.Prodotto__r.CodiceProdotto__c == 'PCANE' || linea.Prodotto__r.CodiceProdotto__c == 'PCANM' || linea.Prodotto__r.CodiceProdotto__c == 'PCBEM') && !valoreSF10PerAttore.containsKey(joinLineaDebitore.Debitore__c)) throw new Ex.WSException('Importo contratto non definito per il debitore: Ndg ' + joinLineaDebitore.Debitore__r.NDG__c);
    //SM-CART-REVI
    // Decimal ValoreSF25;
    // Decimal ValoreSF26;
    // for(PConfigurato__c pconf : valoreSF10PerAttore.get(joinLineaDebitore.Debitore__c)) { 
    //   if(linea.Prodotto__r.CodiceProdotto__c == 'PCACF' || linea.Prodotto__r.CodiceProdotto__c == 'PCACN'){
    //     if(pconf.Codice__c == 'SF25'){ 
    //       ValoreSF25 = pconf.Valore__c;
    //       //break;
    //     } else if( pconf.Codice__c == 'SF26'){
    //       ValoreSF26 = pconf.Valore__c;
    //     }

    //     if(ValoreSF25 != null && ValoreSF26 != null){
    //       break;
    //     }
    //   }
    // }
     
    //A.M. -> 05/2021 INIZIO Modifica per gestione Endo e Uto con i parametri SF25 e SF26 invece che con i deti del debitore in Q&C se presenti
    if (linea.Prodotto__r.CodiceProdotto__c == 'PCACF' || linea.Prodotto__r.CodiceProdotto__c == 'PCACN' || linea.Prodotto__r.CodiceProdotto__c == 'PCAMC' || linea.Prodotto__r.CodiceProdotto__c == 'PCANE' || linea.Prodotto__r.CodiceProdotto__c == 'PCANM' || linea.Prodotto__r.CodiceProdotto__c == 'PCBEM')
    {   fidoCoppia.importoRichiestoEndo = Decimal.valueOf(valoreSF10PerAttore.get(joinLineaDebitore.Debitore__c)[0].Valore__c);
		// I prodotti di ACF non hanno prosoluto
		//fidoCoppia.importoRichiestoUto =  null; 
	} else {	
		//A.M. Modificata condizione di accesso (09/06/2021)
		//if (valoreSF256PerAttore.size() > 0) {	
		if (valoreSF256PerAttore.containsKey(joinLineaDebitore.Debitore__c)){	 
		   for(PConfigurato__c pconf : valoreSF256PerAttore.get(joinLineaDebitore.Debitore__c)) { 
              if(pconf.Codice__c == 'SF25'){ 
                   String importoEndo = pconf.Valore__c;
			       fidoCoppia.importoRichiestoEndo = (importoEndo != '0' ? Decimal.valueOf(importoEndo.trim()) : 0);
              } else if( pconf.Codice__c == 'SF26'){
                   String importoUto = pconf.Valore__c;
				   fidoCoppia.importoRichiestoUto = (importoUto != '0' ? Decimal.valueOf(importoUto.trim()) : 0);
            }
		   }
	    } else {
		   fidoCoppia.importoRichiestoEndo = joinLineaDebitore.Debitore__r.Plafond__c;
           fidoCoppia.importoRichiestoUto = (!joinLineaDebitore.Debitore__r.Prosoluto__c) ? null : joinLineaDebitore.Debitore__r.DiCuiProsoluto__c;
		}

	}
    //A.M. -> Per i due prodotti di ATD Bonus Edilizi il valore del fido di coppia viene sovrascritto utilizzando il parametro "Prosoluto" salvato
    //if (linea.Prodotto__r.CodiceProdotto__c == 'PCANB' || linea.Prodotto__r.CodiceProdotto__c == 'PCATS'){
	//    for(PConfigurato__c pconf : valoreSF256PerAttore.get(joinLineaDebitore.Debitore__c)) { 
    //      if(pconf.Codice__c == 'SF25'){ 
    //         String importoEndo = pconf.Valore__c;
	//         fidoCoppia.importoRichiestoEndo = (importoEndo != '0' ? Integer.valueOf(importoEndo.trim()) : 0);
    //      } else if( pconf.Codice__c == 'SF26'){
    //         String importoUto = pconf.Valore__c;
	//	     fidoCoppia.importoRichiestoUto = (importoUto != '0' ? Integer.valueOf(importoUto.trim()) : 0);
    //      }
	//	}
    //} else  { 
        //A.M. -> Nuovo prodotto PCAMC (ACF MCC) & ACF Bonus Edilizi (PCANE) non hanno prosoluto     
    //    fidoCoppia.importoRichiestoEndo = (linea.Prodotto__r.CodiceProdotto__c == 'PCACF' || linea.Prodotto__r.CodiceProdotto__c == 'PCACN' || linea.Prodotto__r.CodiceProdotto__c == 'PCAMC' || linea.Prodotto__r.CodiceProdotto__c == 'PCANE' || linea.Prodotto__r.CodiceProdotto__c == 'PCANM' || linea.Prodotto__r.CodiceProdotto__c == 'PCBEM') ? Decimal.valueOf(valoreSF10PerAttore.get(joinLineaDebitore.Debitore__c)[0].Valore__c) : joinLineaDebitore.Debitore__r.Plafond__c;
    //    fidoCoppia.importoRichiestoUto = (linea.Prodotto__r.CodiceProdotto__c == 'PCACF' || linea.Prodotto__r.CodiceProdotto__c == 'PCACN' || linea.Prodotto__r.CodiceProdotto__c == 'PCAMC' || linea.Prodotto__r.CodiceProdotto__c == 'PCANE' || linea.Prodotto__r.CodiceProdotto__c == 'PCANM' || linea.Prodotto__r.CodiceProdotto__c == 'PCBEM' || !joinLineaDebitore.Debitore__r.Prosoluto__c) ? null : joinLineaDebitore.Debitore__r.DiCuiProsoluto__c;
	//}
	//A.M. -> 05/2021 FINE Modifica per gestione Endo e Uto con i parametri SF25 e SF26 invece che con i deti del debitore in Q&C

    // fidoCoppia.dataInizioValidita = ;
    fidoCoppia.parametriFidoCoppia = new WsRestCrm.ParametriFidoCoppia();
    fidoCoppia.parametriFidoCoppia.parametro = new List<WsRestCrm.Parametro>();

    return fidoCoppia;
  }

  @TestVisible
  private static List<WsRestCrm.Parametro> creaParametriFidoCoppiaObbligatori(Linea__c linea, JoinLineaDebitore__c joinLineaDebitore, Map<String, PConfigurato__c[]> valoreSF10PerAttore) {
    List<WsRestCrm.Parametro> parametroList = new List<WsRestCrm.Parametro>();
    parametroList.add(creaParametro('FAS', 'T1', String.valueOf(joinLineaDebitore.Debitore__r.Fatturato__c.setScale(2))));
    //A.M. -> Nuovo prodotto PCAMC (ACF MCC)  & ACF Bonus Edilizi (PCANE) 
    if ((linea.Prodotto__r.CodiceProdotto__c == 'PCACF' || linea.Prodotto__r.CodiceProdotto__c == 'PCACN' || linea.Prodotto__r.CodiceProdotto__c == 'PCAMC' || linea.Prodotto__r.CodiceProdotto__c == 'PCANE' || linea.Prodotto__r.CodiceProdotto__c == 'PCANM' || linea.Prodotto__r.CodiceProdotto__c == 'PCBEM') && !valoreSF10PerAttore.containsKey(joinLineaDebitore.Debitore__c)) throw new Ex.WSException('Importo contratto non definito per il debitore: Ndg ' + joinLineaDebitore.Debitore__r.NDG__c);
    String pla = (linea.Prodotto__r.CodiceProdotto__c == 'PCACF' || linea.Prodotto__r.CodiceProdotto__c == 'PCACN' || linea.Prodotto__r.CodiceProdotto__c == 'PCAMC' || linea.Prodotto__r.CodiceProdotto__c == 'PCANE' || linea.Prodotto__r.CodiceProdotto__c == 'PCANM' || linea.Prodotto__r.CodiceProdotto__c == 'PCBEM') ? valoreSF10PerAttore.get(joinLineaDebitore.Debitore__c)[0].Valore__c : String.valueOf(joinLineaDebitore.Debitore__r.Plafond__c.setScale(2));
    parametroList.add(creaParametro('PLA', 'T1', pla));
    parametroList.add(creaParametro('DUR', 'T1', String.valueOf(joinLineaDebitore.Debitore__r.DurataNominale__c)));
    return parametroList;
  }

  @TestVisible
  private static List<WsRestCrm.Parametro> creaParametriFidoCoppiaIcarManuali(IcarManuale__c[] icarManuali, Certificazione__c[] certificazioni) {
    List<WsRestCrm.Parametro> parametroList = new List<WsRestCrm.Parametro>();
    if (icarManuali != null) {
      for (IcarManuale__c im : icarManuali) {
        if (im.DataEmissioneDa__c != null && im.DataEmissioneA__c != null) {
          parametroList.add(creaParametro('DED', 'T1', UDate.formatDate(im.DataEmissioneDa__c, 'yyyy-MM-dd')));
          parametroList.add(creaParametro('DEA', 'T1', UDate.formatDate(im.DataEmissioneA__c, 'yyyy-MM-dd')));
          continue;
        }
        else if (im.NumeroFatturaDa__c != null && im.NumeroFatturaA__c != null && im.AnnoFatturatoDa__c != null && im.AnnoFatturatoA__c != null) {
          parametroList.add(creaParametro('NFD', 'T1', im.NumeroFatturaDa__c));
          parametroList.add(creaParametro('NFA', 'T1', im.NumeroFatturaA__c));
          parametroList.add(creaParametro('AFD', 'T1', UDate.formatDate(im.AnnoFatturatoDa__c, 'yyyy-MM-dd')));
          parametroList.add(creaParametro('AFA', 'T1', UDate.formatDate(im.AnnoFatturatoA__c, 'yyyy-MM-dd')));
          continue;
        }
        throw new Ex.WSException('Dati fattura non configurati correttamente');
      }
    }
    if (certificazioni != null) {
      for (Certificazione__c cert : certificazioni) {
        if (cert.DataFatturaMinima__c != null && cert.DataFatturaMassima__c != null) {
          parametroList.add(creaParametro('DED', 'T1', UDate.formatDate(cert.DataFatturaMinima__c, 'yyyy-MM-dd')));
          parametroList.add(creaParametro('DEA', 'T1', UDate.formatDate(cert.DataFatturaMassima__c, 'yyyy-MM-dd')));
          continue;
        }
      }
    }
    return parametroList;
  }

  /* MB - TEN: METODO PER GESTIONE ICAR E CREDITI IN FACTORING FISCALE */
  @TestVisible
  private static WsRestCrm.FidiCoppia mappingFidiCoppiaFromCrediti(Linea__c linea, Map<String, JoinLineaDebitore__c[]> joinLineaDebitoreMap, Credito__c[] crediti, Map<String, PConfigurato__c[]> pConfiguratoCodiceMap) {
    if (linea.LineaATD__c && linea.TipoLinea__c == 'lineaDiAcquisto') return null;

    Decimal sumImportoCrediti = U.sumBy(crediti, 'WGC_Val_Nom_Esigibile__c');
    
    if (crediti.size() > 0) {
      WsRestCrm.FidiCoppia fidiCoppia = new WsRestCrm.FidiCoppia();
      WsRestCrm.FidoCoppia[] fidoCoppiaList = new List<WsRestCrm.FidoCoppia>();
      // Credito__c[] creditiLinea = creditiMap.get(linea.Id);
      Boolean isFirstCredit = true;

      for (Credito__c credito : crediti) {
        if (!linea.LineaATD__c && !isFirstCredit) continue;
        JoinLineaDebitore__c joinLineaDebitore = joinLineaDebitoreMap.get(linea.Id)[0];
        //if (parametriFidoCoppiaList.containsKey(joinLineaDebitore.Debitore__c) || linea.Prodotto__r.CodiceProdotto__c == 'PCACF') {
          WsRestCrm.FidoCoppia fidoCoppia = creaFidoCoppiaFromCredito(linea, joinLineaDebitore, credito, (isFirstCredit ? sumImportoCrediti : 0), pConfiguratoCodiceMap);
          fidoCoppia.parametriFidoCoppia.parametro = creaParametriFidoCoppiaObbligatoriFromCredito(linea, joinLineaDebitore, credito);
          fidoCoppiaList.add(fidoCoppia);
          isFirstCredit = false;
        //}
      }
      fidiCoppia.fidoCoppia = fidoCoppiaList;
      return fidiCoppia;
    }
    return null;
  }

  @TestVisible
  private static WsRestCrm.FidoCoppia creaFidoCoppiaFromCredito(Linea__c linea, JoinLineaDebitore__c joinLineaDebitore, Credito__c credito, Decimal sumImportoCrediti, Map<String, PConfigurato__c[]> pConfiguratoCodiceMap) {
    WsRestCrm.FidoCoppia fidoCoppia = new WsRestCrm.FidoCoppia();
    fidoCoppia.codDivisa = joinLineaDebitore.Debitore__r.DivisaNew__c;
    fidoCoppia.codNDGDebi = (joinLineaDebitore.Debitore__r.NDG__c != null) ? Integer.valueOf(joinLineaDebitore.Debitore__r.NDG__c) : null;
    fidoCoppia.codTipoCoppia = (linea.Prodotto__r.Codice__c == '534' || linea.Prodotto__r.Codice__c == '644' ? 'E' : 'I');
    System.debug('@@@@ MB - TEN: credito -- ' + credito);
    System.debug('@@@@ MB - TEN: sumImportoCrediti -- ' + sumImportoCrediti);
    if (credito == null) throw new Ex.WSException('Errore nella generazione dei dati dei crediti.'); //  || sumImportoCrediti == 0
    if (linea.Prodotto__r.Codice__c == '534' || linea.Prodotto__r.Codice__c == '644') { // DFO - IVA
      String importo = (pConfiguratoCodiceMap.containsKey(linea.Id + '_' + 'SF6') ? pConfiguratoCodiceMap.get(linea.Id + '_' + 'SF6')[0].Valore__c : '0');
      fidoCoppia.importoRichiestoEndo = (importo != '0' ? Integer.valueOf(importo.trim()) : 0);
      fidoCoppia.importoRichiestoUto = 0;
    } else {
      fidoCoppia.importoRichiestoEndo = sumImportoCrediti;
      fidoCoppia.importoRichiestoUto = credito.WGC_Val_Nom_Esigibile__c;
    }
    // fidoCoppia.dataInizioValidita = ;
    fidoCoppia.parametriFidoCoppia = new WsRestCrm.ParametriFidoCoppia();
    fidoCoppia.parametriFidoCoppia.parametro = new List<WsRestCrm.Parametro>();
    return fidoCoppia;
  }
  
  @TestVisible
  private static List<WsRestCrm.Parametro> creaParametriFidoCoppiaObbligatoriFromCredito(Linea__c linea, JoinLineaDebitore__c joinLineaDebitore, Credito__c credito) {
    List<WsRestCrm.Parametro> parametroList = new List<WsRestCrm.Parametro>();
    parametroList.add(creaParametro('FAS', 'T1', '0'));
    parametroList.add(creaParametro('PLA', 'T1', '0'));
    parametroList.add(creaParametro('DUR', 'T1', '0'));
    if (linea.Prodotto__r.Codice__c != '534' && linea.Prodotto__r.Codice__c != '644') { // DFO - IVA
      parametroList.add(creaParametro('NFD', 'T1', credito.WGC_UniqueCode__c));
      parametroList.add(creaParametro('NFA', 'T1', credito.WGC_UniqueCode__c));
      parametroList.add(creaParametro('AFD', 'T1', UDate.formatDate(Date.newInstance(credito.WGC_Data_Richiesta_Rimborso__c.year(), 1, 1), 'yyyy-MM-dd')));
      parametroList.add(creaParametro('AFA', 'T1', UDate.formatDate(Date.newInstance(credito.WGC_Data_Richiesta_Rimborso__c.year(), 12, 31), 'yyyy-MM-dd')));
    }
    return parametroList;
  }

  /* end - MB - TEN: METODO PER GESTIONE ICAR E CREDITI IN FACTORING FISCALE */

  /**
   * Crea una lista di parametri fido coppia
   * @param  pConfiguratoList lista dei parametri da mappare
   * @param  parametroMap     mappa 'codiceUnivoco' -> 'parametro'
   * @return                  lista dei parametri
   */
  @TestVisible
  private static List<WsRestCrm.Parametro> creaParametriFidoCoppiaLista(PConfigurato__c[] pConfiguratoList, Map<String, Parametro__c[]> parametroMap) {
    PConfigurato__c[] parametriDaUsare = pConfiguratoList.clone();
    List<WsRestCrm.Parametro> parametroList = new List<WsRestCrm.Parametro>();
    for(PConfigurato__c p : parametriDaUsare) {
      if (p.Valore__c != null && parametroMap.get(p.Codice__c) != null) {
        String codTipoPara = mappaCodTipoPara(parametroMap.get(p.Codice__c)[0], p);
        parametroList.add(creaParametro(p.Codice__c, codTipoPara, p.Valore__c));
      }
    }
    return parametroList;
  }

  /**
   * Popola i parametri dei fidi coppia e parametri aggiuntivi
   * @param  codice       codice del parametro
   * @param  codTipoPara  codice tipo parametro
   * @param  valoriString valori del parametro, separati da ';'
   * @return              parametro
   */
  @TestVisible
  private static WsRestCrm.Parametro creaParametro(String codice, String codTipoPara, String valoriString) {
    String[] valori = valoriString.split(';');
    WsRestCrm.Parametro parametro = new WsRestCrm.Parametro();
    parametro.codice = codice;
    parametro.codTipoPara = codTipoPara;
    WsRestCrm.ValoriParametro valoriParametro = new WsRestCrm.ValoriParametro();
    WsRestCrm.ValoreParametro[] valoreParametroList = new List<WsRestCrm.ValoreParametro>();
    for (Integer i = 0; i < valori.size(); i++) {
      WsRestCrm.ValoreParametro valoreParametro = new WsRestCrm.ValoreParametro();
      valoreParametro.progressivo = i+1;
      valoreParametro.valore = valori[i];
      valoreParametroList.add(valoreParametro);
    }
    valoriParametro.valoreParametro = valoreParametroList;
    parametro.valoriParametro = valoriParametro;
    return parametro;
  }

  /**
   * Mappa il codice del tipo parametro. Converte inoltre il valore del pConfigurato in base al suo tipo.
   * @param  parametro    da mappare, in base alla sua tipologia verra' convertito il valore del pConfigurato
   * @param  pConfigurato da mappare, contiene il valore che eventualmente viene convertito nel formato adatto
   * @return              codice del tipo parametro
   */
  @TestVisible
  private static String mappaCodTipoPara(Parametro__c parametro, PConfigurato__c pConfigurato) {
    // Integer cifreDecimali = 2;
    Integer cifreDecimali = 4;
    if (parametro.Tipologia__c == 'Multi-picklist' || parametro.Tipologia__c == 'Picklist') {
      String codTipoPara = 'C';
      if (pConfigurato.Valore__c != null) {
          try{
              Decimal.valueOf(pConfigurato.Valore__c);
              codTipoPara = 'N';
          }
          catch(TypeException e){
            codTipoPara = 'C';
          }
        // UPDATE TA: questi parametri, con default = '01' (o simili) vengon convertiti in numero '1' (o simili) lato KNET se passati con N
        if (pConfigurato.Codice__c == '071' || pConfigurato.Codice__c == '124' || pConfigurato.Codice__c == '044' || pConfigurato.Codice__c == '067' || pConfigurato.Codice__c == '150') codTipoPara = 'C';
      }
      return codTipoPara;
    } else if (parametro.Tipologia__c == 'Numero') {
      return 'N';
    } else if (parametro.Tipologia__c == 'Percentuale') {
      if (pConfigurato.Codice__c == 'C138' && pConfigurato.Linea__r.Prodotto__r.CodiceUnivoco__c == 'ATDTiAnticipo') cifreDecimali = 99;
      if (pConfigurato.Codice__c == 'C163') cifreDecimali = 3;
      pConfigurato.Valore__c = arrotondaCifreDecimali(pConfigurato.Valore__c, cifreDecimali);
      return 'P';
    } else if (parametro.Tipologia__c == 'Importo' || parametro.Tipologia__c == 'Divisa') {
      pConfigurato.Valore__c = arrotondaCifreDecimali(pConfigurato.Valore__c, cifreDecimali);
      return 'I';
    } else if (parametro.Tipologia__c == 'Flag') {
      return 'C';
    } else return null;
  }

  /**
   * Arrotonda la lista di valori a decimali con due cifre di precisione
   * @param  valoriList lista di valori numerici separati da ';'
   * @return            lista di valori decimali a due cifre di precisione separati da ';'
   */
  @TestVisible
  private static String arrotondaCifreDecimali(String valoriList, Integer cifreDecimali) {
    String[] valori = valoriList.split(';');
    String[] valoriArrotondati = new List<String>();
    for (String valore : valori) {
      if (valore.contains('$')) {
        valoriArrotondati.add('0.00');
      } else {
        if (cifreDecimali == 99) valoriArrotondati.add(valore);
        else valoriArrotondati.add(String.valueOf(Decimal.valueOf(valore).setScale(cifreDecimali)));
      }
    }
    return String.join(valoriArrotondati, ';');
  }

  /**
   * Metodo provvisorio, mocka il parametro '008'. Da eliminare
   * UPDATE 25/10/2017: per TiAnticipo è necessario inviare 008 con valore 90 per poter procedere in KNET
   * (non viene comunque considerato lato business)
   * @param  linea linea a cui associare il parametro
   * @return       mock del parametro
   */
  @TestVisible
  private static PConfigurato__c creaMockParametro008(Linea__c linea, String valore) {
    return new PConfigurato__c(Codice__c = '008', Linea__c = linea.Id, Valore__c = valore);
  }

}