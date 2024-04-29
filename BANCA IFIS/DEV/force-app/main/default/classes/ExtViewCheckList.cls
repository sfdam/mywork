global with sharing class ExtViewCheckList {
  public transient Id rpvId {get; private set;}

  public ExtViewCheckList(ApexPages.StandardController ctrl) {
    RelazionePrimaVisita__c[] rpvL = [SELECT Id FROM RelazionePrimaVisita__c WHERE Opportunita__c = :ctrl.getId()];
    if(!rpvL.isEmpty()) rpvId = rpvL[0].Id;
  }

  global class Prodotto {
    public String idProdotto;
    public String codiceStato;
    public String descrizioneStato;
  }

  global class StatoChecklist {

    @AuraEnabled
    public Id rpvId;
    @AuraEnabled
    public Id qqId;

    @AuraEnabled
    public Boolean selezionaReferenti;
    @AuraEnabled
    public Boolean qqOk;
    @AuraEnabled
    public Boolean privacyOkAzienda;
    @AuraEnabled
    public Boolean privacyOkEsecutore;
    @AuraEnabled
    public Boolean rpvOk;
    @AuraEnabled
    public Boolean mavOk;

    @AuraEnabled
    public Boolean mtcOk;
    @AuraEnabled
    public Boolean censimentoOk;
    @AuraEnabled
    public Boolean fatcaOk;
    @AuraEnabled
    public Boolean rsfOk;
    @AuraEnabled
    public Boolean wizardCompletato;

    @AuraEnabled
    public Boolean noteOk;

    @AuraEnabled
    public String statoOpp;
    @AuraEnabled
    public Boolean canRefreshStato; // mi dice se posso fare richiesta per verificare stato PEF

    @AuraEnabled
    public Boolean pdfPrivacyGeneratoAzienda;
    @AuraEnabled
    public Boolean pdfPrivacyGeneratoEsecutore;
    @AuraEnabled
    public Boolean pdfMavGenerato;
    @AuraEnabled
    public Boolean pdfRsfGenerato;
    @AuraEnabled
    public Boolean pdfFatcaGenerato;

    @AuraEnabled
    public Boolean rsfFirmata;
    @AuraEnabled
    public Boolean privacyFirmataAzienda;
    @AuraEnabled
    public Boolean privacyFirmataEsecutore;
    @AuraEnabled
    public Boolean mtcFirmata;
    @AuraEnabled
    public Boolean fatcaFirmata;
    @AuraEnabled
    public Boolean mavFirmata;

    @AuraEnabled
    public Boolean soloPlafondStandard;

    @AuraEnabled
    public Boolean debitoriTuttiImport;

    @AuraEnabled
    public Boolean isTiAnticipo;

    @AuraEnabled
    public Boolean isEsecutorePresente;

    @AuraEnabled
    public List<AggregateResult> conteggioAttori;
  }

  @RemoteAction
  global static StatoCheckList getStatoChecklist(Id oppId) {

    Opportunity o = [
      SELECT Id,
      AccountId,
      StageName,
      DataConvalida__c,
      DataCompilazioneFatca__c,
      IdCartella__c,
      IdCartellaKnet__c,
      ModalitaDiAperturaPEF__c,
      WizardCompletato__c,
      TiAnticipo__c,
      ConsensiPrivacyCompilatiAzienda__c,
      ConsensiPrivacyCompilatiEsecutore__c,
      IsOppNSA__c
      FROM Opportunity WHERE Id = :oppId
    ];

    Account[] accountList = o.AccountId != null ? [
      SELECT Id,
      DataInserimentoConsensi__c,
      ConsensiPrivacyDaCaricare__c,
      StatoCensimento__c,
      USPerson__c,
      LastModifiedDate,
      NDGGruppo__c
      FROM Account
      WHERE Id = :o.AccountId
    ] : new Account[]{};
    Account a = (accountList.size() == 1) ? accountList.get(0) : null;

    AggregateResult[] attori = [
      SELECT COUNT(Id) Conteggio,
      Tipo__c
      FROM NDGLinea__c
      WHERE Opportunita__c = :oppId
      // AND RecordType.DeveloperName != 'Professionista'
      GROUP BY Tipo__c];

    QuestionarioQualitativo__c[] qqL = a != null ? [
      SELECT Id,
      Stato__c
      FROM QuestionarioQualitativo__c
      WHERE Stato__c IN ('Confermato', 'Bozza')
      AND Account__c = :a.Id
    ] : new QuestionarioQualitativo__c[]{};

    RelazionePrimaVisita__c[] rpvL = [
      SELECT Id,
      Completa__c
      FROM RelazionePrimaVisita__c WHERE Opportunita__c = :oppId
    ];

    Linea__c[] lineeOpp = [
      SELECT Id,
      LastModifiedDate,
      Prodotto__r.Name
      FROM Linea__c
      WHERE Opportunity__c = :oppId
      ORDER BY LastModifiedDate DESC
    ];

    Set<String> idGarantiAssociatiAGaranzie = U.getSet([SELECT Garante__c
                                                        FROM JoinGaranteGaranzia__c
                                                        WHERE Garanzia__r.Opportunita__c = :oppId], 'Garante__c');

    NDGLinea__c[] allLinee = [
      SELECT Id,
      Account__c,
      Contact__c,
      Account__r.StatoCensimento__c,
      Account__r.NDGGruppo__c,
      Account__r.ShippingState,
      Account__r.BillingState,
      Account__r.NaturaGiuridica__c,
      Contact__r.StatoCensimento__c,
      Contact__r.MailingState,
      Contact__r.DataInserimentoConsensi__c,
      Contact__r.ConsensiPrivacyDaCaricare__c,
      Contact__r.PEP__c,
      ReferenteFatca__c,
      Mercato__c,
      Tipo__c,
      RealLastModifiedDate__c,
      DataConvalida__c,
      LastModifiedDate
      FROM NDGLinea__c
      WHERE Opportunita__c = :oppId
      AND RecordType.DeveloperName != 'Professionista'
      ORDER BY RealLastModifiedDate__c DESC
    ];

    NDGLinea__c[] debitoriL = new NDGLinea__c[]{};
    NDGLinea__c[] ndglL = new NDGLinea__c[]{};
    NDGLinea__c ndgEsecutore;
    NDGLinea__c[] lineeFatca = new NDGLinea__c[]{};
    for(NDGLinea__c l : allLinee) {
      if(l.Tipo__c == 'Debitore') debitoriL.add(l);
      if(l.ReferenteFatca__c) lineeFatca.add(l);
      if(l.Tipo__c == 'Esecutore adeguata verifica' || l.Tipo__c == 'Titolare effettivo adeguata verifica') ndglL.add(l);
      if(l.Tipo__c == 'Esecutore adeguata verifica') ndgEsecutore = l;
    }

    Boolean debitoriTuttiImport = (debitoriL.size() > 0) ? true : false;
    for (NDGLinea__c deb : debitoriL) {
      if (deb.Mercato__c != '003') debitoriTuttiImport = false;
    }



    Map<String, SObject> allegatiMap = U.keyBy([SELECT Id, Tipo__c, DataUltimaGenerazione__c FROM Allegato__c WHERE Opportunita__c = :oppId], 'Tipo__c');
    AdeguataVerifica__c[] avL = [SELECT Id, OrigineFondiCompilata__c, LastModifiedDate FROM AdeguataVerifica__c WHERE Opportunita__c = :oppId];
    Boolean origineFondiObbligatoria = U.getSet(ndglL, 'Contact__r.PEP__c').contains('true');


    StatoChecklist res = new StatoChecklist();

    res.statoOpp = o.StageName;
    res.wizardCompletato = o.WizardCompletato__c;
    res.selezionaReferenti = !ndglL.isEmpty();
    res.conteggioAttori = attori;

    res.soloPlafondStandard = true;
    res.pdfPrivacyGeneratoAzienda = false;
    res.pdfPrivacyGeneratoEsecutore = false;
    res.pdfMavGenerato = false;
    res.mtcOk = false;
    res.pdfRsfGenerato = false;
    res.rsfFirmata = false;
    res.mavFirmata = false;
    res.privacyFirmataAzienda = false;
    res.privacyFirmataEsecutore = false;
    res.fatcaFirmata = false;
    res.mtcFirmata = false;
    res.pdfFatcaGenerato = false;
    res.debitoriTuttiImport = debitoriTuttiImport;
    res.isTiAnticipo = o.TiAnticipo__c;
    res.isEsecutorePresente = ndgEsecutore != null;

    for(Linea__c l : lineeOpp) {
      if(l.Prodotto__r.Name != 'Standard') res.soloPlafondStandard = false;
    }
    res.qqOk = (!qqL.isEmpty() && qqL[0].Stato__c == 'Confermato') || debitoriTuttiImport;
    if(!qqL.isEmpty() && qqL[0].Stato__c == 'Confermato') res.qqId = qqL[0].Id;

    res.noteOk = o.ModalitaDiAperturaPEF__c == null || o.ModalitaDiAperturaPEF__c == '' ? false : true;


    res.rpvOk = (!rpvL.isEmpty() && rpvL[0].Completa__c) || debitoriTuttiImport || o.IsOppNSA__c;
    if (!rpvL.isEmpty() && rpvL[0].Completa__c) res.rpvId = rpvL[0].Id;

    res.rsfOk = !lineeOpp.isEmpty() || !debitoriL.isEmpty();

    res.privacyOkAzienda = a != null && a.DataInserimentoConsensi__c != null && o.ConsensiPrivacyCompilatiAzienda__c ? true : false;
    res.privacyOkEsecutore = ndgEsecutore != null && ndgEsecutore.Contact__c != null && ndgEsecutore.Contact__r.DataInserimentoConsensi__c != null && o.ConsensiPrivacyCompilatiEsecutore__c ? true : false;
    res.mavOk = !avL.isEmpty() && res.selezionaReferenti && (origineFondiObbligatoria ? avL[0].OrigineFondiCompilata__c : true);
    res.fatcaOk = o.DataCompilazioneFatca__c != null;

    if (
      a != null && a.DataInserimentoConsensi__c != null &&
      allegatiMap.containsKey('Privacy') && !allegatiMap.containsKey('PrivacyPf') &&
      a.DataInserimentoConsensi__c <= (Datetime) allegatiMap.get('Privacy').get('DataUltimaGenerazione__c')
    ) res.pdfPrivacyGeneratoAzienda = true;

    if (
      ndgEsecutore != null &&
      ndgEsecutore.Contact__r.DataInserimentoConsensi__c != null &&
      allegatiMap.containsKey('PrivacyPf') &&
      ndgEsecutore.Contact__r.DataInserimentoConsensi__c <= (Datetime) allegatiMap.get('PrivacyPf').get('DataUltimaGenerazione__c')
    ) res.pdfPrivacyGeneratoEsecutore = true;

    if (res.mavOk && res.selezionaReferenti && allegatiMap.containsKey('MAV')) {
      Datetime dataUltimaModificaMav = ndglL[0].RealLastModifiedDate__c < avL[0].LastModifiedDate ? avL[0].LastModifiedDate : ndglL[0].RealLastModifiedDate__c;
      if(dataUltimaModificaMav <= (Datetime) allegatiMap.get('MAV').get('DataUltimaGenerazione__c')) res.pdfMavGenerato = true;
    }


    if (
      res.mavOk &&
      allegatiMap.containsKey('ModuloTecnicheDiComunicazione') &&
      avL[0].LastModifiedDate <= (Datetime) allegatiMap.get('ModuloTecnicheDiComunicazione').get('DataUltimaGenerazione__c')
    ) res.mtcOk = true;


    if (
      res.rsfOk &&
      allegatiMap.containsKey('RSF') &&
      !lineeOpp.isEmpty() && lineeOpp[0].LastModifiedDate <= (Datetime) allegatiMap.get('RSF').get('DataUltimaGenerazione__c')
    ) res.pdfRsfGenerato = true;

    if (
      a != null && a.LastModifiedDate != null &&
      allegatiMap.containsKey('ModuloFatca') &&
      lineeFatca[0].LastModifiedDate <= (Datetime) allegatiMap.get('ModuloFatca').get('DataUltimaGenerazione__c')
    ) res.pdfFatcaGenerato = true;

    if(allegatiMap.containsKey('RSFFirm')) res.rsfFirmata = true;
    if(allegatiMap.containsKey('MAVFirm')) res.mavFirmata = true;
    if(allegatiMap.containsKey('ModuloFatcaFirm')) res.fatcaFirmata = true;
    if(a!= null && !a.ConsensiPrivacyDaCaricare__c && allegatiMap.containsKey('PrivacyFirm')) res.privacyFirmataAzienda = true;
    if(ndgEsecutore != null && ndgEsecutore.Contact__c != null && !ndgEsecutore.Contact__r.ConsensiPrivacyDaCaricare__c && allegatiMap.containsKey('PrivacyPfFirm')) res.privacyFirmataEsecutore = true;
    if(allegatiMap.containsKey('ModuloTecnicheDiComunicazioneFirm')) res.mtcFirmata = true;


    Boolean censimentoOk = true;
    String statoCensimentoCedente = a != null ? a.StatoCensimento__c : '';
    if ((statoCensimentoCedente != CtrlCensimento.CENSIMENTO_FULL_OK && statoCensimentoCedente != CtrlCensimento.CENSIMENTO_NON_RICHIESTO) || o.DataConvalida__c == null) {
      censimentoOk = false;
    }
    else {
      for(NDGLinea__c ndglinea : allLinee) {
        if(ndgLinea.Tipo__c == 'Garante' && idGarantiAssociatiAGaranzie.contains(ndgLinea.Id)) continue;
        if(ndgLinea.Account__r.NaturaGiuridica__c == 'COIN') continue;
        if(ndgLinea.Account__c == null && ndgLinea.Contact__c == null) continue;
        if(ndgLinea.DataConvalida__c == null) censimentoOk = false;
        if(ndgLinea.Account__c != null && (ndgLinea.Account__r.StatoCensimento__c != CtrlCensimento.CENSIMENTO_FULL_OK && ndgLinea.Account__r.StatoCensimento__c != CtrlCensimento.CENSIMENTO_NON_RICHIESTO)) {
          censimentoOk = false;
        }
        if(ndgLinea.Contact__c != null && (ndgLinea.Contact__r.StatoCensimento__c != CtrlCensimento.CENSIMENTO_FULL_OK && ndgLinea.Contact__r.StatoCensimento__c != CtrlCensimento.CENSIMENTO_NON_RICHIESTO)) {
          censimentoOk = false;
        }
        if(!censimentoOk) break;
      }
    }

    res.censimentoOk = censimentoOk;

    res.canRefreshStato = String.isNotBlank(o.IdCartella__c) && (o.StageName == 'In Valutazione' || o.StageName == '11' || o.StageName == '5');
    return res;
  }

  @RemoteAction
  global static Boolean refreshStatoCartella(Id oppId) {
    Opportunity o = [SELECT IdCartella__c FROM Opportunity WHERE Id = :oppId];
    WsRestCrm.NvInquiryStatoCartellaResponse res = WsRestCrm.nvInquiryStatoCartella(o.IdCartella__c);
    if(!res.isCorrect()) throw new Ex.WSException('Servizi non disponibili');

    Map<String, Prodotto> prodotti = new Map<String, Prodotto>();
    for(WsRestCrm.Prodotto pc: res.payload.prodotti.prodotto) {
      Prodotto p = new Prodotto();
      p.idProdotto = String.valueOf(pc.idProdotto).leftPad(6, '0');
      p.codiceStato = String.valueOf(pc.codiceStato);
      p.descrizioneStato = pc.descrizioneStato;
      prodotti.put(p.idProdotto, p);
    }
    Linea__c[] linee =  [SELECT IdProdotto__c FROM Linea__c WHERE Opportunity__c = :oppId AND IdProdotto__c IN :prodotti.keySet()];
    if(linee.size() < prodotti.keySet().size()) {
      // vuol dire che su sfdc non ci sono le stesse linee che vengono dai servizi
      throw new Ex.WSException('Alcuni prodotti non sono stati trovati. Contatta helpdesk');
    }
    for(Linea__c l : linee) {
      l.Stato__c = prodotti.get(l.IdProdotto__c).codiceStato;
    }
    update linee;
    o.DataInquiryStatoCartella__c = Datetime.now();
    update o;
    return true;
  }

  @RemoteAction
  global static Boolean esistePef(Id oppId) {
    //A.M. Aggiunga campi per verificare PEF su debitore in concordati fallimentari (con Assuntore)
    //Opportunity o = [SELECT Id, Account.NDGGruppo__c, IdCartella__c FROM Opportunity WHERE Id = :oppId];
	Opportunity o = [SELECT Id, Account.NDGGruppo__c, IdCartella__c, WGC_NDG_Debitore__c, WGC_Assuntore__c FROM Opportunity WHERE Id = :oppId];
    WsRestPefMutui.CheckStatoPefInput input = new WsRestPefMutui.CheckStatoPefInput();
	if (o.WGC_Assuntore__c){
	   input.codNdg = Long.valueOf(o.WGC_NDG_Debitore__c);
	} else {	
       input.codNdg = Long.valueOf(o.Account.NDGGruppo__c);
	}
    WsRestPefMutui.CheckStatoPefResponse res = WsRestPefMutui.EsistePef(input);
    if(!res.isCorrect()) throw new Ex.WSException('Errore durante la chiamata al servizio esistePEF: ' + res.getErrors());

    Boolean esistePefAttiva = res.payload.outputRichiesta.flagEsistePefAttiva == 'S' ? true : false;
    return esistePefAttiva;
  }

  @RemoteAction
  global static void cambiaInnescoOpportunita(Boolean innescata, Id oppId) {
    Opportunity opp = new Opportunity(Id = oppId, InnescataNV__c = innescata);
    update opp;
  }

  /**
   * Ritorna true se l'opportunita' e' gia' stata innescata; false altrimenti
   */
  @RemoteAction
  global static Boolean fetchInnescoOpportunita(Id oppId) {
    Opportunity opp = [SELECT InnescataNV__c FROM Opportunity WHERE Id = :oppId];
    return opp.InnescataNV__C;
  }

  @RemoteAction
  global static void aggiornaNSA(Id oppId){
    List<Linea__c> linee = [SELECT Opportunity__c, Opportunity__r.Account.Controparte__c, Opportunity__r.AccountId, Opportunity__r.Account.BillingPostalCode, Opportunity__r.Account.ShippingPostalCode, Prodotto__r.CodiceUnivoco__c,
                                    Opportunity__r.Account.BillingCity,Opportunity__r.Account.ShippingCity,Opportunity__r.Account.BillingState,Opportunity__r.Account.ShippingState, Opportunity__r.Account.OwnerId
                            FROM Linea__c
                            WHERE (Opportunity__c = :oppId AND (Prodotto__r.CodiceUnivoco__c = 'MutuoPCNSA' OR Prodotto__r.CodiceUnivoco__c = 'MutuoPCNSASA'))];
    if(linee.size()!=0){
      Account acc = new Account(
      Id = linee[0].Opportunity__r.AccountId,
      BillingPostalCode = linee[0].Opportunity__r.Account.BillingPostalCode,
      ShippingPostalCode = linee[0].Opportunity__r.Account.ShippingPostalCode,
      BillingCity = linee[0].Opportunity__r.Account.BillingCity,
      ShippingCity = linee[0].Opportunity__r.Account.ShippingCity,
      BillingState = linee[0].Opportunity__r.Account.BillingState,
      ShippingState = linee[0].Opportunity__r.Account.ShippingState,
      OwnerId = linee[0].Opportunity__r.Account.OwnerId,
      Controparte__c = linee[0].Opportunity__r.Account.Controparte__c
      );
      Account[] accs = TrgAccount.assegnazioneAnagraficaOperatoriNSA(new Account[]{acc});
      if (accs != null) {
        UWS.updateObjs(accs, true);
        Account accountToUpdate = accs[0];
        Opportunity opp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :oppId];
        opp.OwnerId = accs[0].OwnerId;
        UWS.updateObjs(new Opportunity[]{opp}, true);
      }
    }
  }

  @RemoteAction
  global static String inviaNuovaVendita(Id oppId) {
    // true = invio in nuova vendita ok, false = qualcosa è fallito
    try {
      //prima di questa chiamata, viene invocato il metodo aggiornaNSA(Opportunity Id) che gestisce gli aggiornamenti dell'account per operatori NSA
      String idCartella = WsRestCrmUtils.nvAggiornamentoInnescaVendita(oppId);
      List<Linea__c> linee = [SELECT Id,
        Prodotto__r.CodiceUnivoco__c,
        Opportunity__r.AccountId,
        Opportunity__r.Account.BillingPostalCode,
        Opportunity__r.Account.ShippingPostalCode,
        Opportunity__r.Account.BillingCity,
        Opportunity__r.Account.ShippingCity,
        Opportunity__r.Account.BillingState,
        Opportunity__r.Account.ShippingState,
        Opportunity__r.Account.OwnerId
        FROM Linea__c
        WHERE Opportunity__c = :oppId];
      U.massSet(linee, 'Stato__c', '1');
      // MB - TEN: MODIFICATO STAGENAME DA 'In valutazione' A 'Valutazione Pratica'
      // update new Opportunity(Id = oppId, StageName = 'In valutazione', IdCartella__c = idCartella);
      update new Opportunity(Id = oppId, StageName = 'Valutazione Pratica', IdCartella__c = idCartella);
      update linee;
      // MB - TEN: COMMENTATO INVIO DOCUMENTI
      // QbleInvioDocumenti q = new QbleInvioDocumenti(new QbleInvioDocumenti.QbleInvioDocumentiInput(oppId, null));
      // System.enqueueJob(q);
      return null;
    } catch (Exception e) {
      update new Opportunity(Id = oppId, InnescataNV__c = false);
      if(!(e instanceof Ex.WsCalloutException)) {
        Logger.log('NV_AggiornamentoInnescaVendita', e.getMessage() + '. ' + e.getStackTraceString());
      }
      return e.getMessage();
    }
  }

  @RemoteAction
  global static Boolean esisteTitolareEffettivo(Id oppId) {
    NDGLinea__c[] ndgLineaList = [SELECT Id
                                  FROM NDGLinea__c
                                  WHERE Opportunita__c = :oppId
                                  AND Tipo__c = 'Titolare effettivo adeguata verifica'];
    if (ndgLineaList.size() == 0) return false;
    return true;
  }

  @RemoteAction
  global static Boolean richiediInfoCR(Id oppId) {
    Opportunity o = [SELECT Id, DataRichiestaCR__c, Account.CI3N_NDGGruppo__c, Account.NaturaGiuridica__c, Account.CF__c FROM Opportunity WHERE Id = :oppId];
    NDGLinea__c[] ndglinea = [SELECT DataRichiestaCr__c FROM NDGLinea__c WHERE Opportunita__c = :oppId AND Tipo__c = 'Debitore'];
    Boolean tuttiCR = o.DataRichiestaCR__c != null;
    for(NDGLinea__c n : ndglinea) {
      if(n.DataRichiestaCr__c == null) tuttiCR = false;
    }
    if (tuttiCR) throw new Ex.WSException('Richiesta InfoCR già fatta per il cedente e per tutti i debitori');

    QbleInfoCr q = new QbleInfoCr(oppId, null);
    System.enqueueJob(q);
    return true;
  }


  @RemoteAction
  global static String generaDocumentazione(Id oppId, String tipo) {
    System.SavePoint sp = Database.setSavePoint();
    try {

      // Generazione pdf in lingua italiana - inglese - rumena

      Opportunity opp = [SELECT Account.Area__c, Account.ShippingCountry FROM Opportunity WHERE Id = :oppId];
      Map<String, PageReference> tipiMap;
      Map<String, String> tipi2TitleMap;

      // italiano
      if (opp.Account.Area__c == 'ITA') {
        tipiMap = new Map<String, PageReference>{
          'Privacy' => Page.PdfPrivacy,
          'PrivacyPf' => Page.PdfPrivacyPf,
          'MAV' => Page.PdfAdeguataVerificaClientela,
          'ModuloTecnicheDiComunicazione' => Page.PdfTecnicheDiComunicazione,
          'RSF' => Page.PdfRichiestaServiziFinanziari,
          'ModuloFatca' => Page.PdfFatca
        };

        tipi2TitleMap = new Map<String, String>{
          'Privacy' => 'AllegatoPrivacy.pdf',
          'PrivacyPf' => 'AllegatoPrivacyEsecutore.pdf',
          'MAV' => 'ModuloAdeguataVerifica.pdf',
          'ModuloTecnicheDiComunicazione' => 'TecnicheDiComunicazione.pdf',
          'RSF' => 'ModuloRichiestaServiziFinanziari.pdf',
          'ModuloFatca' => 'FATCA.pdf'
        };
      }

      // inglese
      if (opp.Account.Area__c == 'EE' && opp.Account.ShippingCountry!= 'ROMANIA') {
        tipiMap = new Map<String, PageReference>{
          'Privacy' => Page.PdfPrivacyEN,
          'PrivacyPf' => Page.PdfPrivacyPfEN,
          'MAV' => Page.PdfAdeguataVerificaClientelaEN,
          'ModuloTecnicheDiComunicazione' => Page.PdfTecnicheDiComunicazioneEN,
          'RSF' => Page.PdfRichiestaServiziFinanziariEN,
          'ModuloFatca' => Page.PdfFatca
        };

        tipi2TitleMap = new Map<String, String>{
          'Privacy' => 'PrivacyAttachment.pdf',
          'PrivacyPf' => 'LegalRepresentativePrivacyAttachment.pdf',
          'MAV' => 'ClientIdentificationForm.pdf',
          'ModuloTecnicheDiComunicazione' => 'MeansOfCommunications.pdf',
          'RSF' => 'FinancialProductsAndServicesRequest.pdf',
          'ModuloFatca' => 'FATCA.pdf'
        };
      }

      // rumeno
      if (opp.Account.Area__c == 'EE' && opp.Account.ShippingCountry == 'ROMANIA') {
        tipiMap = new Map<String, PageReference>{
          'Privacy' => Page.PdfPrivacyRO,
          'PrivacyPf' => Page.PdfPrivacyPfRO,
          'MAV' => Page.PdfAdeguataVerificaClientelaRO,
          'ModuloTecnicheDiComunicazione' => Page.PdfTecnicheDiComunicazioneRO,
          'RSF' => Page.PdfRichiestaServiziFinanziariRO,
          'ModuloFatca' => Page.PdfFatca
        };

        tipi2TitleMap = new Map<String, String>{
          'Privacy' => 'PrivacyAttachment.pdf',
          'PrivacyPf' => 'LegalRepresentativePrivacyAttachment.pdf',
          'MAV' => 'ClientIdentificationForm.pdf',
          'ModuloTecnicheDiComunicazione' => 'MeansOfCommunications.pdf',
          'RSF' => 'FinancialProductsAndServicesRequest.pdf',
          'ModuloFatca' => 'FATCA.pdf'
        };
      }

      if(!tipiMap.containsKey(tipo)) return '';

      Id contentDocumentId;

      // Se è già presente un allegato per l'opportunità di questo tipo recupero dal CDL l'id del ContentDocument già
      // presente (mi servirà per associarlo al ContentVersion)..
      Allegato__c[] allegati = [SELECT Id, Tipo__c FROM Allegato__c WHERE Opportunita__c = :oppId AND Tipo__c = :tipo];
      Allegato__c all = null;
      if(!allegati.isEmpty()) {
        all = allegati[0];
        ContentDocumentLink[] cdL = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :all.Id];
        if(!cdL.isEmpty()) contentDocumentId = cdL[0].ContentDocumentId;
      // ..altrimenti inserisco il nuovo allegato
      } else {
        all = new Allegato__c(Opportunita__c = oppId, Tipo__c = tipo);
      }

      all.DataUltimaGenerazione__c = Datetime.now();
      upsert all;

      // Genero il nuovo Content Version..
      PageReference pr = tipiMap.get(tipo);
      pr.getParameters().put('Id', oppId);
      Blob pdfBlob;
      if(Test.isRunningTest())
        pdfBlob = Blob.valueOf('test');
      else
        pdfBlob = pr.getContent();


      ContentVersion newVersion = new ContentVersion(VersionData = pdfBlob, Title = tipi2TitleMap.get(tipo), PathOnClient = '/' + tipi2TitleMap.get(tipo));
      // ..se è già presente il ContentDocument, ci associo il CV..
      if(String.isNotBlank(contentDocumentId)) {
        newVersion.ContentDocumentId = contentDocumentId;
      }

      insert newVersion;

      // ..se non è già presente il ContentDocument, lo associo ora creando un CDL
      if(String.isBlank(contentDocumentId)) {
        newVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :newVersion.Id];
        insert new ContentDocumentLink(
          ContentDocumentId = newVersion.ContentDocumentId,
          LinkedEntityId = all.Id,
          ShareType = 'I'
        );
      }

      return newVersion.ContentDocumentId;
    } catch(Exception e) {
      Database.rollback(sp);
      throw e;
    }
  }

  @RemoteAction
  global static Opportunity getInformazioniOppChecklist(Id oppId) {
    return [SELECT Account.Area__c, RecordType.DeveloperName FROM Opportunity WHERE Id = :oppId];
  }

  @RemoteAction
  global static Boolean getUpdatedFatturatoAndDipendenti(Id objectId) {
    Account acc = new Account();
    Schema.SObjectType objectType = objectId.getSobjectType();

    if (objectType == Opportunity.sObjectType) {
      Opportunity opp = [SELECT AccountId, Account.DataUltimaModificaFatturato__c, Account.DataUltimaModificaNumDipendenti__c
                        FROM Opportunity
                        WHERE Id = :objectId];
      acc.Id = opp.AccountId;
      acc.DataUltimaModificaFatturato__c = opp.Account.DataUltimaModificaFatturato__c;
      acc.DataUltimaModificaNumDipendenti__c = opp.Account.DataUltimaModificaNumDipendenti__c;
    } else if (objectType == Cessione__c.sObjectType) {
      Cessione__c cess = [SELECT Account__r.Id, Account__r.DataUltimaModificaFatturato__c, Account__r.DataUltimaModificaNumDipendenti__c
                        FROM Cessione__c
                        WHERE Id = :objectId];
      acc.Id = cess.Account__r.Id;
      acc.DataUltimaModificaFatturato__c = cess.Account__r.DataUltimaModificaFatturato__c;
      acc.DataUltimaModificaNumDipendenti__c = cess.Account__r.DataUltimaModificaNumDipendenti__c;
    }

    if(acc.DataUltimaModificaFatturato__c == null ||
      acc.DataUltimaModificaNumDipendenti__c == null ||
      Date.Today().daysBetween(acc.DataUltimaModificaFatturato__c) > 365 ||
      Date.Today().daysBetween(acc.DataUltimaModificaNumDipendenti__c) > 365) {
        WSRestRibesUtils.updateBilancioSintetico(acc.Id);
        return true;
      }
    return false;
  }
}