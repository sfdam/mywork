/**
* Progetto:         Banca IFIS
* Descrizione:      Classe handler del trigger Opportunity.trigger
* Sviluppata il:    08/02/2017
* Developer:        Zerbinati Francesco, riscritto correttamente da Matteo Bazzoni
*/

public with sharing class TrgOpportunity {

  /**
   * Gestione Mutuo MCC NSA: il titolare dell'account diventa il titolare dell'opportunità
   */
  public static void assegnazioneAnagraficaOperatoriNSA(T tu) {
    if (!Funzionalita__c.getInstance().GestioneMutuoMCCNSA__c) return;
    Opportunity[] oppsToProcess = (Opportunity[]) tu.triggerNew;
    Map<Id, Account> accsMap = new Map<Id, Account>([SELECT Id, OwnerId, Owner.IsActive FROM Account WHERE Id IN :U.getIdSet(oppsToProcess, 'AccountId')]);
    for (Opportunity opp : oppsToProcess) {
      opp.IsOppNSA__c = true;
      if (accsMap.containsKey(opp.AccountId) && accsMap.get(opp.AccountId).Owner.IsActive) {
        opp.OwnerId = accsMap.get(opp.AccountId).OwnerId;
      }
    }
  }

  public static void gestioneTeamMutuoMCNSA(T tu) {
    if (!Funzionalita__c.getInstance().GestioneMutuoMCCNSA__c) return;
    Id currentUser = UserInfo.getUserId();
    OpportunityTeamMember[] otms = new OpportunityTeamMember[]{};
    Linea__c[] linee = new Linea__c[]{};
    Id rtMutuoMCNSA = U.getRecordTypes('Linea__c').get('Fido').Id;
    Id idMutuoMCNSA = [SELECT Id FROM Prodotto__c WHERE CodiceUnivoco__c = 'MutuoPCNSA'].Id;
    for (Opportunity opp : (Opportunity[]) tu.triggerNew) {
      otms.add(new OpportunityTeamMember(OpportunityId = opp.Id, UserId = currentUser, TeamMemberRole = 'OperatoreNSA', OpportunityAccessLevel = 'Edit'));
      linee.add(new Linea__c(Opportunity__c = opp.Id, Prodotto__c = idMutuoMCNSA, RecordTypeId = rtMutuoMCNSA));
    }
    UWS.insertObjs(otms, true);
    UWS.insertObjs(linee, true);
  }

  /**
   * forza wizard completato per operatori NSA
   * */
  public static void tempFixWizardTeamMutuoMCNSA(T tu) {
    if (!Funzionalita__c.getInstance().GestioneMutuoMCCNSA__c) return;
    for (Opportunity opp : (Opportunity[]) tu.triggerNew) {
        opp.WizardCompletato__c = true;
    }
  }
    
    // TEN GB [08/03/2019] - Modifiche del renaming delle opportunità 
  public static void rinominaOpp(T tu) {
    Datetime myDate = Datetime.now();
    String formattedMyDate = myDate.format('dd/MM/yyyy');

    Set<Id> accountIds = U.getIdSet(tu.triggerNew, 'AccountId');
    Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Name FROM Account WHERE Id IN :accountIds]);
    for (Opportunity o : (List<Opportunity>) tu.triggerNew) {

      String rtName = '';
      Map<String, SObject> rtMap = U.getRecordTypes('Opportunity');
      //if (o.RecordTypeId == rtMap.get('IFISOpportunitaFactoring').Id) rtName = 'Fact - ';
      if (o.RecordTypeId == rtMap.get('IFISOpportunitaFactoring').Id) rtName = 'CC';
      else if (o.RecordTypeId == rtMap.get('IFIS_Rinnovo').Id) rtName = 'CC';
      //else if (o.RecordTypeId == rtMap.get('IFISOpportunitaCommercialLending').Id) rtName = 'CL - ';
      else if (o.RecordTypeId == rtMap.get('IFISOpportunitaFinanzaStrutturata').Id) rtName = 'FS';
      else if (o.RecordTypeId == rtMap.get('IFISOpportunitaPolonia').Id) rtName = 'IN';
      else if (o.RecordTypeId == rtMap.get('WGC_IFIS_International').Id) rtName = 'IN';
      else if (o.RecordTypeId == rtMap.get('IFISOpportunitaFastFinance').Id) rtName = 'FF';
      else if (o.RecordTypeId == rtMap.get('WGC_IFIS_Leasing').Id) rtName = 'LS';
      else if (o.RecordTypeId == rtMap.get('WGC_IFIS_Finance').Id) rtName = 'IF';
      else if (o.RecordTypeId == rtMap.get('WGC_IFIS_Oppotunita_Crediti_Erariali').Id) rtName = 'CE';

      if (o.StageName == null) {
        switch on rtName { // HARDCODING FASE DI PARTENZA PER FACTORING, LEASING E FINANZA STRUTTURATA
          when 'CC', 'LS' {
            o.StageName = 'In Istruttoria';
          }
          when 'FS' {
            o.StageName = 'Market Intelligence';
          }
        }
      }
      
      String dateOutput = o.CreatedDate != null ? o.CreatedDate.format('dd/MM/yyyy') : formattedMyDate;

      if (String.isNotBlank(o.AccountId)) {
        /*if (o.RecordTypeId == rtMap.get('IFISOpportunitaFastFinance').Id) o.Name = (rtName + accountMap.get(o.AccountId).Name).abbreviate(100);
        else o.Name = (rtName + dateOutput + ' - ' + accountMap.get(o.AccountId).Name).abbreviate(100);*/
        o.Name = (rtName + '_' + dateOutput + '_' + accountMap.get(o.AccountId).Name).abbreviate(100);
      }
    }
  }

  public static void setDataOraChiusura(T tu) {
    for (Opportunity o : (Opportunity[]) tu.filter('IsClosed', true).getChanged('IsClosed')) {
      o.DataOraChiusura__c = Datetime.now();
      o.CloseDate = Date.today();
    }
  }

  public static void allineaStageDaStatoPef(T tu) {
    Map<String, String> mappaStati = new Map<String, String> {
      '11' => '11',
      '5' => '5',
      '1' => 'In Valutazione',
      '2' => 'Persa',
      '3' => 'Vinta'
    };

    for (Opportunity o : (Opportunity[]) tu.filter('RecordTypeId', U.getRecordTypes('Opportunity').get('IFISOpportunitaFactoring').Id, true).filter('StatoPef__c', (String) null, false).getChanged('StatoPef__c')) {
      if (mappaStati.containsKey(o.StatoPEF__c)) {
        o.StageName = mappaStati.get(o.StatoPEF__c);
      }
    }
  }

  public static void allineaCessione(T tu) {
    Opportunity[] changed = tu.filter('StageName', 'Persa').filter('Cessione__c', (String)null, false).filter('RecordTypeId', U.getRecordTypes('Opportunity').get('IFISOpportunitaFactoring').Id, true).getChanged('StageName');
    Set<Id> idCessioni = U.getIdSet(changed, 'Cessione__c');
    if (idCessioni.isEmpty()) return;
    Cessione__c[] toUpdate = [SELECT Id, Stato__c FROM Cessione__c WHERE Id IN :idCessioni];
    U.massSet(toUpdate, 'Stato__c', '5');
    update toUpdate;
  }

  public static void notificaChatterContrattiPronti(T tu) {
    Opportunity[] oppDaNotificare = (Opportunity[]) tu.filter('RecordTypeId', U.getRecordTypes('Opportunity').get('IFISOpportunitaFactoring').Id, true).filter('StageName', '11').getChanged('StageName');
    if (oppDaNotificare.isEmpty()) return;
    Opportunity[] opps = [SELECT Id, OwnerId, Account.Name FROM Opportunity WHERE Id IN :U.getIdSet(oppDaNotificare, 'Id')];
    ConnectApi.FeedItemInput[] feedItemInputs = new List<ConnectApi.FeedItemInput>();
    for (Opportunity o : opps) {
      String messaggio = 'Ciao %menzione% i contratti riferiti a ' + o.Account.Name + ' sono pronti. Puoi procedere a stamparli e a fissare la Visita per Firma Contratti.';
      feedItemInputs.add(ChatterUtils.createPostChatterMenzione(o.Id, o.OwnerId, messaggio));
    }
    ChatterUtils.postToChatterBatch(feedItemInputs);
  }

  /**
   * Invio di mail per le opportunità TiAnticipo
   */
  public static void inviaMail(T tu) {
    if (MailUtils.isMailTiAnticipoDisabilitate) return;
    Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[]{};

    Set<Id> opportunitaConIdCartellaIds = U.getIdSet(tu.filter('IdCartella__c', null, false).filter('TiAnticipo__c', true).filter('RecordTypeId', U.getRecordTypes('Opportunity').get('IFISOpportunitaFactoring').Id, true).getChanged('IdCartella__c'), 'Id');
    if (opportunitaConIdCartellaIds.isEmpty()) return;

    Map<Id, Opportunity> opportunitaMap = new Map<Id, Opportunity>([
      SELECT Id,
      Cessione__r.FirmaDigitale__c
      FROM Opportunity
      WHERE Id IN :opportunitaConIdCartellaIds
    ]);

    Map<String, SObject> emailTemplates = U.keyBy([
      SELECT Id,
      DeveloperName
      FROM EmailTemplate
      WHERE DeveloperName IN ('TiAnticipo2', 'TiAnticipo3', 'TiAnticipo4', 'TiAnticipo18')], 'DeveloperName');

    Map<String, OrgWideEmailAddress[]> senderIds = U.groupBy([
      SELECT Id,
      DisplayName
      FROM OrgWideEmailAddress], 'DisplayName');

    String[] toAddresses;
    String[] ccAddresses;
    for (Id oppId : opportunitaConIdCartellaIds) {
      Boolean isFirmaDigitale = opportunitaMap.get(oppId).Cessione__r.FirmaDigitale__c;

      // Codice notifica 104 ---> 104 A e 104 D
      toAddresses = new String[]{MailUtils.EMAIL_OPERATIONS_NV};
      ccAddresses = new String[]{MailUtils.EMAIL_FILO_DIRETTO};
      if (isFirmaDigitale && emailTemplates.containsKey('TiAnticipo2') && senderIds.containsKey('Segreteria Fidi')) {
          mails.add(MailUtils.creaMailApexHTML(oppId, emailTemplates.get('TiAnticipo2').Id, null, senderIds.get('Segreteria Fidi')[0].Id, null, toAddresses, ccAddresses, null));
      } else if (!isFirmaDigitale && emailTemplates.containsKey('TiAnticipo18') && senderIds.containsKey('Segreteria Fidi')) {
          mails.add(MailUtils.creaMailApexHTML(oppId, emailTemplates.get('TiAnticipo18').Id, null, senderIds.get('Segreteria Fidi')[0].Id, null, toAddresses, ccAddresses, null));
      }
    }

    // Se le mail sono disabilitate o se sono in un test loggo il mancato invio delle mail
    if (!mails.isEmpty()) {
      if (Funzionalita__c.getInstance().DisabilitaInvioEmail__c || Test.isRunningTest()) {
        MailUtils.logNotSentEmail();
      } else {
        Messaging.sendEmail(mails);
      }
    }
  }

  /**
   * Fast Finance: aggiorna il numero delle procedure aperte di tribunali e professionisti
   */
  public static void calcolaProcedureAperte(T tu) {
    TrgOpportunity.calcolaProcedureAperteTribunali(tu);
    TrgOpportunity.calcolaProcedureAperteProfessionisti(tu);
  }

  /**
   * Fast Finance: aggiorna il numero delle procedure aperte di tribunali
   */
  public static void calcolaProcedureAperteTribunali(T tu) {
    Set<Id> idTribunali = new Set<Id>();
    if (T.isAfterInsert() || T.isAfterUpdate()) {
      idTribunali.addAll(U.getIdSet(tu.getChanged('Tribunale__c'), 'Tribunale__c'));
      idTribunali.addAll(U.getIdSet(tu.getOldChanged('Tribunale__c'), 'Tribunale__c'));
      idTribunali.addAll(U.getIdSet(tu.getChanged('IsClosed'), 'Tribunale__c'));
    }

    if (T.isAfterDelete()) {
      idTribunali.addAll(U.getIdSet(tu.oldMap.values(), 'Tribunale__c'));
    }
    TrgAccount.calcolaProcedureAperte(idTribunali);
  }

  /**
   * Fast Finance: aggiorna il numero delle procedure aperte di professionisti
   */
  public static void calcolaProcedureAperteProfessionisti(T tu) {
    Set<Id> oppIds = new Set<Id>();
    if (T.isAfterInsert() || T.isAfterUpdate()) {
      oppIds.addAll(U.getIdSet(tu.getChanged('IsClosed'), 'Id'));
    }
    if (T.isBeforeDelete()) {
      oppIds.addAll(tu.oldMap.keySet());
    }
    if (oppIds.isEmpty()) return;

    Set<Id> professionistiIds = new Set<Id>();

    professionistiIds.addAll(U.getIdSet([
      SELECT Contact__c
      FROM NDGLinea__c
      WHERE RecordTypeId = :U.getRecordTypes('NDGLinea__c').get('Professionista').Id
      AND Tipo__c = 'Professionista'
      AND Opportunita__c IN :oppIds
    ], 'Contact__c'));

    if (professionistiIds.isEmpty()) return;

    Map<Id, Integer> contactsMap = new Map<Id, Integer>();
    Contact[] contacts = new Contact[]{};

    // Calcolo il numero di procedure aperte di professionisti
    AggregateResult[] professionisti = [SELECT COUNT(Id) numero,
      Contact__c
      FROM NDGLinea__c
      WHERE RecordTypeId = :U.getRecordTypes('NDGLinea__c').get('Professionista').Id
      AND Tipo__c = 'Professionista'
      AND Opportunita__r.IsClosed = false
      GROUP BY Contact__c
      HAVING Contact__c IN :professionistiIds];

    for (AggregateResult prof : professionisti) {
      Id conId = (Id) prof.get('Contact__c');
      Integer procedureAperte = contactsMap.containsKey(conId) ? contactsMap.get(conId) : 0;
      procedureAperte += (Integer) prof.get('numero');
      contactsMap.put(conId, procedureAperte);
    }

    // Azzero il numero di procedure aperte per i professionisti non considerati prima
    for (Id conId : U.toIdList(professionistiIds)) {
      if (!contactsMap.containsKey(conId)) contactsMap.put(conId, 0);
    }

    // Aggiorno il DB
    for (Id conId : contactsMap.keySet()) {
      contacts.add(new Contact(Id = conId, ProcedureAperte__c = contactsMap.get(conId)));
    }

    upsert contacts;

  }

  /**
   * Metodo che al variare dell'Account dell'opportunità recupera gli allegati associati ad esso
   * e crea allegati associati all'opportunità
   */
  public static void recuperaConsensiPrivacyAzienda(T tu) {
    // Considero solo le opportunità il cui cedente (Account) è cambiato
    Opportunity[] opps = tu
      .filter('RecordTypeId', U.getRecordTypes('Opportunity').get('IFISOpportunitaFactoring').Id, true)
      .filter('AccountId', null, false)
      .getChanged('AccountId');
    if (opps.isEmpty()) return;

    Set<Id> accountIds = U.getIdSet(opps, 'AccountId');
    Set<Id> oppIds = U.getIdSet(opps, 'Id');

    // Recupero per ogni azienda gli allegati PrivacyFirm legati ad esse e validi ( = con "consensiPrivacyDaCaricare" false)..
    Map<String, SObject> allegatoPrivacyPerAzienda = U.keyBy([SELECT Id,
      Account__c,
      Account__r.ConsensiPrivacyDaCaricare__c
      FROM Allegato__c
      WHERE Account__c IN :accountIds
      AND Opportunita__c = null
      AND Cessione__c = null
      AND Tipo__c = 'PrivacyFirm'
    ], 'Account__c');

    // .. e i relativi ContentDocument..
    Set<Id> allegatiPrivacyEsistenti = U.getIdSet(U.filter(allegatoPrivacyPerAzienda.values(), 'Account__r.ConsensiPrivacyDaCaricare__c', false), 'Id');
    if (allegatiPrivacyEsistenti.isEmpty()) return;
    Map<String, SObject> cdlPerAllegatoPrivacy = U.keyBy([SELECT Id,
      LinkedEntityId,
      ContentDocumentId,
      ContentDocument.LatestPublishedVersion.VersionData,
      ContentDocument.LatestPublishedVersion.Title,
      ContentDocument.LatestPublishedVersion.PathOnClient
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN :allegatiPrivacyEsistenti], 'LinkedEntityId');

    // .. così da avere, se presente, l'ultimo ContentVersion della PrivacyFirm per ogni azienda
    Map<String, SObject> cdlPerAzienda = new Map<String, SObject>();
    for (Id accountId : U.toIdList(accountIds)) {
      if (allegatoPrivacyPerAzienda.containsKey(accountId)) {
        Id allegatoId = (Id) allegatoPrivacyPerAzienda.get(accountId).get('Id');
        if (cdlPerAllegatoPrivacy.containsKey(allegatoId)) {
          cdlPerAzienda.put(accountId, cdlPerAllegatoPrivacy.get(allegatoId));
        }
      }
    }

    // Inserisco gli allegati collegati all'opportunità: per farlo controllo se siano già presenti, in modo da
    // decidere se aggiornare quelli già presenti o crearne di nuovi
    Map<String, Allegato__c[]> allegatoPrivacyPerOpportunita = U.groupBy([SELECT Id,
      Opportunita__c
      FROM Allegato__c
      WHERE Opportunita__c IN :oppIds
      AND Tipo__c = 'PrivacyFirm'], 'Opportunita__c');

    Set<Id> allegatiOppIds = new Set<Id>();
    for (Allegato__c[] allegatiPrivacy : allegatoPrivacyPerOpportunita.values()) {
      allegatiOppIds.add(allegatiPrivacy[0].Id);
    }

    ContentDocumentLink[] cdlsOpp = (allegatiOppIds.isEmpty()) ? new ContentDocumentLink[]{} : [SELECT Id,
      LinkedEntityId,
      ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN :allegatiOppIds];
    Map<String, SObject> cdlPerAllegatoOpp = U.keyBy(cdlsOpp, 'LinkedEntityId');

    Map<String, Allegato__c> allegatiDaInserirePerOpportunita = new Map<String, Allegato__c>();
    Map<String, ContentVersion> cvDaInserirePerOpportunita = new Map<String, ContentVersion>();
    Allegato__c[] allegatiDaInserire = new Allegato__c[]{};
    for (Opportunity opp : opps) {
      if (cdlPerAzienda.containsKey(opp.AccountId)) {
        ContentVersion newCV = new ContentVersion(
          VersionData = ((ContentDocumentLink) cdlPerAzienda.get(opp.AccountId)).ContentDocument.LatestPublishedVersion.VersionData,
          Title = ((ContentDocumentLink) cdlPerAzienda.get(opp.AccountId)).ContentDocument.LatestPublishedVersion.Title,
          PathOnClient = ((ContentDocumentLink) cdlPerAzienda.get(opp.AccountId)).ContentDocument.LatestPublishedVersion.PathOnClient
        );

        if (!allegatoPrivacyPerOpportunita.containsKey(opp.Id) || !cdlPerAllegatoOpp.containsKey(allegatoPrivacyPerOpportunita.get(opp.Id)[0].Id)) {
          allegatiDaInserirePerOpportunita.put(opp.Id, new Allegato__c(
            Opportunita__c = opp.Id,
            Tipo__c = 'PrivacyFirm',
            CodiceDocumentoTiAnticipo__c = 'PrivacyFirm',
            FamigliaDocumento__c = 'Documenti identità'
          ));
        } else {
          newCV.ContentDocumentId = ((ContentDocumentLink) cdlPerAllegatoOpp.get(allegatoPrivacyPerOpportunita.get(opp.Id)[0].Id)).ContentDocumentId;
        }
        cvDaInserirePerOpportunita.put(opp.Id, newCV);
      }
    }

    insert allegatiDaInserirePerOpportunita.values();
    insert cvDaInserirePerOpportunita.values();

    Map<Id, ContentVersion> mapCvs = new Map<Id, ContentVersion>([SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :U.getIdSet(cvDaInserirePerOpportunita.values(), 'Id')]);

    // ..con i CDL collegati al CD dell'azienda
    ContentDocumentLink[] cdls = new ContentDocumentLink[]{};
    for (Opportunity opp : opps) {
      if (cvDaInserirePerOpportunita.containsKey(opp.Id) && allegatiDaInserirePerOpportunita.containsKey(opp.Id)) {
        cdls.add(new ContentDocumentLink(
          ContentDocumentId = mapCvs.get(cvDaInserirePerOpportunita.get(opp.Id).Id).ContentDocumentId,
          LinkedEntityId = allegatiDaInserirePerOpportunita.get(opp.Id).Id,
          Visibility = 'AllUsers',
          ShareType = 'I'
        ));
      }
    }

    upsert cdls;
  }
}