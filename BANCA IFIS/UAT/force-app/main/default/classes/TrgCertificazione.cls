public without sharing class TrgCertificazione {
	static STRING STAGE_NAME = 'In Istruttoria';

  //AFTER INSERT - AFTER UPDATE - AFTER DELETE
  public static void calcolaTotalePreventivo(T tu) {
    Certificazione__c[] certificazioni = new Certificazione__c[]{};
    if (T.isAfterDelete()) {
      certificazioni = tu.oldMap.values();
    } else {
      certificazioni = tu.getChanged(new String[] {'Debitore__c', 'DataPagamento__c', 'ImportoCertificato__c', 'ImportoCertificatoRivisto__c', 'CertificazioneValida__c', 'CertificazioneBocciata__c'});
    }
    if (certificazioni.isEmpty()) return;
    QueueItemPreventivo__c[] queueItemsPreventivo = new QueueItemPreventivo__c[]{};
    for (Id cessioneId : U.getIdSet(certificazioni, 'Cessione__c')) {
      queueItemsPreventivo.add(new QueueItemPreventivo__c(Cessione__c = cessioneId));
    }
    insert queueItemsPreventivo;
  }

  //BEFORE INSERT - BEFORE UPDATE
  public static void validazioneCertificazione(T tu) {
	ParametriTiAnticipo__c parametriTA = ParametriTiAnticipo__c.getInstance();
    Certificazione__c[] certificazioni = (Certificazione__c[]) tu.getChanged(new String[] {'PartitaIvaDebitore__c', 'Debitore__c', 'DataPagamento__c'});

    Set<Id> idDebitori = U.getIdSet(certificazioni, 'Debitore__c');
    Map<Id, Account> debitoriMap = new Map<Id, Account>(
      [SELECT Id, PrevalutazioneFactoring__c, SegmentoRischio__c FROM Account WHERE Id IN :idDebitori]
    );

    for (Certificazione__c c : certificazioni) {
      String[] errori = new String[] {};

      Account debitore = debitoriMap.get(c.Debitore__c);

      if (debitore == null) {
        errori.add(String.isBlank(c.PartitaIvaDebitore__c) ? 'È necessario inserire il codice fiscale del debitore.' : 'L\'Ente inserito non è stato trovato. Contatta il Servizio Clienti al numero 800 712 433 per ricevere maggiori informazioni.');
      } else if (String.isBlank(debitore.SegmentoRischio__c) || debitore.SegmentoRischio__c == '6') {
        errori.add('L\'Ente inserito non è stato trovato. Contatta il Servizio Clienti al numero 800 712 433 per ricevere maggiori informazioni.');
      }

      if (c.DataPagamento__c != null) {
        Date dateCessione = c.CreatedDate != null ? c.CreatedDate.date() : Date.today();
        Integer deltaGiorni = dateCessione.daysBetween(c.DataPagamento__c);
        if (deltaGiorni < parametriTA.Soglia_giorni_scadenza_fattura__c) {
          errori.add('La data di pagamento deve essere superiore a '+parametriTA.Soglia_giorni_scadenza_fattura__c+' giorni a partire dalla data di creazione della pratica.');
        }
      }

      if (errori.size() > 0) {
        //errori.add('La certificazione non verrà presa in considerazione.');
        c.CertificazioneValida__c = false;
        c.Errore__c = String.join(errori, '. ');
      } else {
        c.CertificazioneValida__c = true;
        c.Errore__c = null;
      }
    }
  }

  /**
   * Allineamento Certificazione -> Debitori per TiAnticipo:
   * Dai debitori delle certificazioni vengono creati gli Attori "Debitore" e i JoinLineaDebitore
   * @param  certificazioni
   */
  public static void syncDebitori(T tu) {

    Id recordTypeDebitore = U.getRecordTypes('NDGLinea__c').get('Debitore').Id;

    Set<Id> cessioniSet = U.getIdSet(tu.triggerNew, 'Cessione__c');
    if (tu.oldMap != null) cessioniSet.addAll(U.getIdSet(tu.oldMap.values(), 'Cessione__c'));

    Certificazione__c[] certificazioni = [SELECT Cessione__c,
                                          Debitore__c,
                                          ImportoCertificatoCalcolo__c,
                                          TerminiPagamento__c
                                          FROM Certificazione__c
                                          WHERE Cessione__c IN :cessioniSet
                                          AND CertificazioneBocciata__c = false];
    Map<String, Certificazione__c[]> certificazioniPerCessioneDebitore = U.groupBy(certificazioni, '{Cessione__c}_{Debitore__c}', true);

    Map<String, Opportunity[]> oppsPerCessione = U.groupBy([SELECT Id,
        Cessione__c,
        StageName
        FROM Opportunity
        WHERE Cessione__c IN :cessioniSet], 'Cessione__c');

    Set<String> cessioniDebitoriInCertificazioni = U.getSet(certificazioni, '{Cessione__c}_{Debitore__c}', true, false);

    // Nel caso in cui non esistano più tra i debitori nelle certificazioni (non bocciate)
    // cancello i debitori (di conseguenza i joinLineaDebitore e i pConfigurati a loro associati)
    Certificazione__c[] certificazioniOld = new Certificazione__c[] {};
    if (T.isAfterDelete()) {
      for (Certificazione__c c : (Certificazione__c[]) tu.oldMap.values()) 
		if (c.Debitore__c != null && oppsPerCessione.get(c.Cessione__c)[0].StageName == STAGE_NAME) certificazioniOld.add(c);
    }
    if (T.isAfterUpdate()) {
      for (Certificazione__c c : (Certificazione__c[]) tu.getOldChanged(new String[] {'Cessione__c', 'Debitore__c', 'CertificazioneBocciata__c'})) 
		if (c.Debitore__c != null && oppsPerCessione.get(c.Cessione__c)[0].StageName == STAGE_NAME) certificazioniOld.add(c);
    }
    // cessioneDebitoreOld è il set di cessioni-debitori che, se non più presenti tra le certificazioni (non bocciate), vanno rimossi dagli attori
    Set<String> cessioneDebitoreOld = U.getSet(certificazioniOld, '{Cessione__c}_{Debitore__c}', true, false);

    Map<String, NDGLinea__c[]> attoriPerCessioneDebitore = U.groupBy(
		[SELECT Id,
			Opportunita__r.Cessione__c,
			Account__c
			FROM NDGLinea__c
			WHERE RecordTypeId = :recordTypeDebitore
			  AND Opportunita__r.Cessione__c IN :cessioniSet
		], '{Opportunita__r.Cessione__c}_{Account__c}', true);

    NDGLinea__c[] attoriToDelete = new NDGLinea__c[] {};

    for (String cessioneDebitore : U.toList(cessioneDebitoreOld)) {
      if (!cessioniDebitoriInCertificazioni.contains(cessioneDebitore) && attoriPerCessioneDebitore.containsKey(cessioneDebitore))
		attoriToDelete.addAll(attoriPerCessioneDebitore.get(cessioneDebitore));
    }
    delete attoriToDelete;

    NDGLinea__c[] attori = [SELECT Id,
                            Opportunita__r.Cessione__c,
                            Cessione__c,
                            Account__c
                            FROM NDGLinea__c
                            WHERE RecordTypeId = :recordTypeDebitore
                              AND Opportunita__r.Cessione__c IN :cessioniSet
                              AND Opportunita__r.StageName = :STAGE_NAME
                           ];
    attoriPerCessioneDebitore = U.groupBy(attori, '{Opportunita__r.Cessione__c}_{Account__c}', true);

    // aggiungo ora i debitori nuovi
    Certificazione__c[] certificazioniNew = new Certificazione__c[] {};
    if (T.isAfterInsert()) {
      for (Certificazione__c c : (Certificazione__c[]) tu.triggerNew) {
        if (c.Debitore__c != null && !c.CertificazioneBocciata__c && !attoriPerCessioneDebitore.containsKey(c.Cessione__c + '_' + c.Debitore__c) && oppsPerCessione.get(c.Cessione__c)[0].StageName == STAGE_NAME)
          certificazioniNew.add(c);
      }
    }
    if (T.isAfterUpdate()) {
      for (Certificazione__c c : (Certificazione__c[]) tu.getChanged(new String[] {'Cessione__c', 'Debitore__c', 'CertificazioneBocciata__c'}))
        if (c.Debitore__c != null && !c.CertificazioneBocciata__c && !attoriPerCessioneDebitore.containsKey(c.Cessione__c + '_' + c.Debitore__c)  && oppsPerCessione.get(c.Cessione__c)[0].StageName == STAGE_NAME)
          certificazioniNew.add(c);
    }


    // cessioneDebitoreNew è il set di cessioni-debitori che vanno aggiunti agli attori
    Set<String> cessioneDebitoreNew = U.getSet(certificazioniNew, '{Cessione__c}_{Debitore__c}', true, false);

    NDGLinea__c[] attoriToUpdate = new NDGLinea__c[] {};
    NDGLinea__c[] attoriToInsert = new NDGLinea__c[] {};

    for (NDGLinea__c att : attori) {
      attoriToUpdate.add(aggiornaDebitore(att, certificazioniPerCessioneDebitore));
    }

    for (String cessioneDebitore : U.toList(cessioneDebitoreNew)) {
      String[] cessioneDebitoreSplit = cessioneDebitore.split('_');
      NDGLinea__c att = new NDGLinea__c(
        Account__c = cessioneDebitoreSplit[1],
        Opportunita__c = oppsPerCessione.get(cessioneDebitoreSplit[0])[0].Id,
        Cessione__c = cessioneDebitoreSplit[0],
        PlafondDeliberato__c = 0,
        DivisaNew__c = '242',
        ANotifica__c = true,
        Maturity__c = false,
        Tipo__c = 'Debitore',
        FakeId__c = U.generateRandomString(50),
        RecordTypeId = recordTypeDebitore
      );
      attoriToInsert.add(aggiornaDebitore(att, certificazioniPerCessioneDebitore));
    }

    update attoriToUpdate;
    insert attoriToInsert;

    // inserisco ora i JoinLineaDebitore per i debitori inseriti
    Map<String, Linea__c[]> lineePerCessione = U.groupBy(
		[SELECT Id,
			Opportunity__r.Cessione__c
			FROM Linea__c
			WHERE Opportunity__r.Cessione__c IN :cessioniSet
		], 'Opportunity__r.Cessione__c');

    JoinLineaDebitore__c[] jldToInsert = new JoinLineaDebitore__c[] {};
    for (NDGLinea__c attore : attoriToInsert) {
      jldToInsert.add(
        new JoinLineaDebitore__c (
          Debitore__c = attore.Id,
          Opportunita__c = attore.Opportunita__c,
          Linea__c = lineePerCessione.get(attore.Cessione__c)[0].Id
        )
      );
    }
    insert jldToInsert;
  }

  /**
   * Aggiorna i dati relativi al debitore, dipendenti dalle certificazioni
   * @param  attore                            debitore da aggiornare
   * @param  certificazioniPerCessioneDebitore mappa "{idCessione}_{idAccountDebitore}" -> "certificazioni"
   * @return                                   debitore aggiornato
   */
  private static NDGLinea__c aggiornaDebitore(NDGLinea__c attore, Map<String, Certificazione__c[]> certificazioniPerCessioneDebitore) {

    // recupero informazioni dalle certificazioni
    Double sommaImportoCertificazioni = 0;
    for (Certificazione__c c : certificazioniPerCessioneDebitore.get(attore.Cessione__c + '_' + attore.Account__c))
		sommaImportoCertificazioni += c.ImportoCertificatoCalcolo__c;

    Decimal durataNominale = certificazioniPerCessioneDebitore.get(attore.Cessione__c + '_' + attore.Account__c)[0].TerminiPagamento__c;
    Double plafond = sommaImportoCertificazioni;
    attore.Plafond__c = plafond;
    attore.DiCuiProsoluto__c = plafond;
    // fix: per garantire l'upload di più certificazioni
    if (durataNominale != null) {
      attore.DurataNominale__c = durataNominale;
      attore.Fatturato__c = ((360 / durataNominale) * plafond).setScale(2);
    }
    return attore;
  }

  /**
   * Allineamento Certificazione -> PConfigurati per TiAnticipo:
   * Dai debitori delle certificazioni vengono creati i PConfigurati associati a loro.
   * SOLO SE l'opportunità è in stato "In Istruttoria"
   * @param  certificazioni
   */
  public static void syncParametri(T tu) {
    Id recordTypeDebitore = U.getRecordTypes('NDGLinea__c').get('Debitore').Id;

    Set<Id> cessioniSet = U.getIdSet(tu.triggerNew, 'Cessione__c');
    if (tu.oldMap != null) cessioniSet.addAll(U.getIdSet(tu.oldMap.values(), 'Cessione__c'));

    // per ricalcolare i valori dei pConfigurati, mi servono tutte le cessioni del debitore
    Map<String, Certificazione__c[]> certificazioniPerDebitoreMap = U.groupBy([
      SELECT Cessione__c,
      Debitore__c,
      DeltaGiorni__c,
      ImportoCertificatoCalcolo__c,
      DataPagamento__c,
      DataCessioneIpotetica__c,
      ImportoCertificato__c,
      CertificazioneBocciata__c,
      CommissioneC138Debitore__c,
      CertificazioneValida__c
      FROM Certificazione__c
      WHERE Cessione__c IN :cessioniSet], '{Cessione__c}_{Debitore__c}', true);

    Map<String, Linea__c[]> lineePerCessione = U.groupBy([
      SELECT Id,
      Opportunity__r.Cessione__c
      FROM Linea__c
      WHERE Opportunity__r.Cessione__c IN :cessioniSet
      AND Opportunity__r.StageName = :STAGE_NAME], 'Opportunity__r.Cessione__c');

    NDGLinea__c[] debitori = [
      SELECT Id,
      Account__c,
      Account__r.SegmentoRischio__c,
      Opportunita__r.Cessione__c,
      Opportunita__r.Cessione__r.CostoComplessivoC138__c,
      DurataNominale__c
      FROM NDGLinea__c
      WHERE Opportunita__r.Cessione__c IN :cessioniSet
      AND Opportunita__r.StageName = :STAGE_NAME
      AND RecordTypeId = :recordTypeDebitore];

    PConfigurato__c[] pConfigurati = [
      SELECT Id,
      Codice__c,
      Valore__c,
      Attore__c,
      Linea__r.Opportunity__r.Cessione__c
      FROM PConfigurato__c
      WHERE Linea__r.Opportunity__r.Cessione__c IN :cessioniSet
      AND Linea__r.Opportunity__r.StageName = :STAGE_NAME];
    Map<String, PConfigurato__c[]> pConfiguratiMap = U.groupBy(pConfigurati, '{Linea__r.Opportunity__r.Cessione__c}_{Codice__c}_{Attore__c}', true);

    CommissioneATD__mdt[] commissioniAtd = [
      SELECT Id,
      CommissioneATDMese__c,
      SegmentoRischio__c,
      EstremoInferiore__c,
      EstremoSuperiore__c
      FROM CommissioneATD__mdt];

    PConfigurato__c[] pConfiguratiLineaToUpsert = new PConfigurato__c[]{};
    PConfigurato__c[] pConfiguratiToUpsert = new PConfigurato__c[] {};
    for (NDGLinea__c debitore : debitori) {
      Certificazione__c[] certificazioniPerDebitore = certificazioniPerDebitoreMap.get(debitore.Opportunita__r.Cessione__c + '_' + debitore.Account__c);
      // aggiorno SF12
      {
        String codice = 'SF12';
        PConfigurato__c p;
        if (pConfiguratiMap.containsKey(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + debitore.Id)) {
          p = pConfiguratiMap.get(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + debitore.Id)[0];
        } else p = new PConfigurato__c(
            Codice__c = codice,
            Attore__c = debitore.Id,
            Linea__c = lineePerCessione.get(debitore.Opportunita__r.Cessione__c)[0].Id,
            Tipo__c = 'Parametro linea'
          );

        Double valore = 0;
        for (Certificazione__c cert : certificazioniPerDebitore) {
          if (!cert.CertificazioneBocciata__c) valore += cert.ImportoCertificatoCalcolo__c;
        }
        p.Valore__c = String.valueOf(valore);
        pConfiguratiToUpsert.add(p);
      }

      // aggiorno C138
      {
        // C138 legati ai debitori
        String codice = 'C138';
        PConfigurato__c p;
        if (pConfiguratiMap.containsKey(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + debitore.Id)) {
          p = pConfiguratiMap.get(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + debitore.Id)[0];
        } else p = new PConfigurato__c(
            Codice__c = codice,
            Attore__c = debitore.Id,
            Default__c = '1',
            Linea__c = lineePerCessione.get(debitore.Opportunita__r.Cessione__c)[0].Id,
            Tipo__c = 'Condizione economica'
          );
        for (Certificazione__c cert : certificazioniPerDebitore) {
          if (cert.CertificazioneValida__c) {
            p.Valore__c = String.valueOf(cert.CommissioneC138Debitore__c);
            break;
          }
        }
        pConfiguratiToUpsert.add(p);

        // C138 legato alla linea
        PConfigurato__c pL;
        if (pConfiguratiMap.containsKey(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + null)) {
          pL = pConfiguratiMap.get(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + null)[0];
        } else {
          pL = new PConfigurato__c(
            Codice__c = codice,
            Attore__c = null,
            Default__c = '1',
            Linea__c = lineePerCessione.get(debitore.Opportunita__r.Cessione__c)[0].Id,
            Tipo__c = 'Condizione economica'
          );
        }
        pL.Valore__c = String.valueOf(debitore.Opportunita__r.Cessione__r.CostoComplessivoC138__c);
        pConfiguratiLineaToUpsert.add(pL);
      }

      // aggiorno 135 (col valore di una certificazione)
      {
        String codice = '135';
        PConfigurato__c p;
        if (pConfiguratiMap.containsKey(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + debitore.Id)) {
          p = pConfiguratiMap.get(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + debitore.Id)[0];
        } else p = new PConfigurato__c(
            Codice__c = codice,
            Attore__c = debitore.Id,
            Default__c = '0',
            Linea__c = lineePerCessione.get(debitore.Opportunita__r.Cessione__c)[0].Id,
            Tipo__c = 'Parametro linea'
          );

        Certificazione__c cert;
        for (Certificazione__c c : certificazioniPerDebitore) {
          if (!c.CertificazioneBocciata__c) {
            cert = c;
            break;
          }
        }
        Integer valore = cert.DataCessioneIpotetica__c.daysBetween(cert.DataPagamento__c);
        p.Valore__c = String.valueOf(valore);
        pConfiguratiToUpsert.add(p);
      }

      // MOCK
      {
        String codice = '009';
        PConfigurato__c p;
        if (pConfiguratiMap.containsKey(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + debitore.Id)) {
          p = pConfiguratiMap.get(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + debitore.Id)[0];
        } else p = new PConfigurato__c(
            Codice__c = codice,
            Attore__c = debitore.Id,
            Default__c = 'RD',
            Linea__c = lineePerCessione.get(debitore.Opportunita__r.Cessione__c)[0].Id,
            Tipo__c = 'Parametro linea'
          );
        p.Valore__c = 'RD';
        pConfiguratiToUpsert.add(p);
      }

      {
        String codice = '008';
        PConfigurato__c p;
        if (pConfiguratiMap.containsKey(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + debitore.Id)) {
          p = pConfiguratiMap.get(debitore.Opportunita__r.Cessione__c + '_' + codice + '_' + debitore.Id)[0];
        } else p = new PConfigurato__c(
            Codice__c = codice,
            Attore__c = debitore.Id,
            Linea__c = lineePerCessione.get(debitore.Opportunita__r.Cessione__c)[0].Id,
            Tipo__c = 'Parametro aggiuntivo'
          );
        p.Valore__c = String.valueOf(debitore.DurataNominale__c);
        pConfiguratiToUpsert.add(p);
      }

    }
    upsert pConfiguratiToUpsert;

    PConfigurato__c[] pList = new PConfigurato__c[]{};
    pList.addAll((PConfigurato__c[]) U.keyBy(pConfiguratiLineaToUpsert, 'Id').values());
    upsert pList;
  }

  //AFTER INSERT - AFTER UPDATE
  //public static void calcolaTerminiDiPagamento(T tu) {
  //  Certificazione__c[] certificazioni = tu.filter('TerminiPagamentoUnici__c', true).getChanged(new String[] {'TerminiPagamento__c', 'TerminiPagamentoUnici__c'});

  //  Fattura__c[] toUpdate = [SELECT Id,
  //                           DataFattura__c,
  //                           CertificazioneParent__r.TerminiPagamento__c
  //                           FROM Fattura__c
  //                           WHERE CertificazioneParent__c IN :certificazioni
  //                           AND DataFattura__c != null];

  //  for (Fattura__c f : toUpdate) {
  //    f.ScadenzaFattura__c = f.DataFattura__c + Integer.valueOf(f.CertificazioneParent__r.TerminiPagamento__c);
  //  }
  //  update toUpdate;
  //}

  //BEFORE DELETE
  public static void eliminaAllegati(T tu) {
    Set<Id> idAllegati = U.getIdSet([SELECT Id
                                     FROM Allegato__c
                                     WHERE Certificazione__c IN :tu.oldMap.keySet()],
                                    'Id'
                                   );

    if (!idAllegati.isEmpty()) {
      ContentDocumentLink[] links = [SELECT Id, ContentDocumentId
                                     FROM ContentDocumentLink
                                     WHERE LinkedEntityId IN :idAllegati];

      ContentDocument[] docToDel = new ContentDocument[] {};
      for (ContentDocumentLink l : links) {
        docToDel.add(new ContentDocument(Id = l.ContentDocumentId));
      }
      //l'eliminazione di Allegato__c viene scatenata nel trigger di ContentDocument
      delete docToDel;
    }
  }
}