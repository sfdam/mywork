/**
* Progetto:         Banca IFIS
* Descrizione:      Classe handler del trigger NDGLinea.trigger
* Sviluppata il:    13/10/2019
* Developer:        Dario Mapelli
*/
public without sharing class TrgAttore {

  /*
   * Cancella i pConfigurati associati agli attori coinvolti.
   */
  public static void deletePConfigurati(T tu) {
    PConfigurato__c[] pConfiguratiToDelete = [SELECT Id
                                              FROM PConfigurato__c
                                              WHERE Attore__c IN :tu.oldMap.values()];
    delete pConfiguratiToDelete;
  }

  /*
   * AFTER INSERT - AFTER UPDATE
   * TiAnticipo: associa gli allegati di attori TA alla cessione e opportunità
   */
  public static void allineaAllegatiTa(T tu) {
    NDGLinea__c[] attori = (NDGLinea__c[]) tu.filter('Cessione__c', null, false).filter('Contact__c', null, false).triggerNew;
    Map<String, SObject> attoreByContact = U.keyBy(attori, 'Contact__c');
    Allegato__c[] allegatiToUpdate = new Allegato__c[]{};
    Map<String, Allegato__c[]> allegatiByContact = U.groupBy([
      SELECT Contact__c,
      Opportunita__c,
      Cessione__c
      FROM Allegato__c
      WHERE Contact__c IN :U.getIdSet(attori, 'Contact__c')
      AND FamigliaDocumento__c = 'Documenti identità'
    ], 'Contact__c');
    for(String contactId : U.toList(allegatiByContact.keySet())) {
      NDGLinea__c attore = (NDGLinea__c) attoreByContact.get(contactId);
      for (Allegato__c allegato : allegatiByContact.get(contactId)) {
        if (attore.Cessione__c != null) allegato.Opportunita__c = attore.Opportunita__c;
        if (attore.Cessione__c != null) allegato.Cessione__c = attore.Cessione__c;
        allegatiToUpdate.add(allegato);
      }
    }
    update allegatiToUpdate;
  }

  /**
   * Fast Finance: aggiorna il numero delle procedure aperte degli attori Professionista
   */
  public static void calcolaProcedureAperte(T tu) {
    Set<Id> idProfessionisti = new Set<Id>();
    if (T.isAfterInsert() || T.isAfterUpdate()) {
      idProfessionisti.addAll(U.getIdSet(tu.filter('Tipo__c', 'Professionista').getChanged('Tipo__c'), 'Contact__c'));
      idProfessionisti.addAll(U.getIdSet(tu.filter('Tipo__c', 'Professionista').getOldChanged('Tipo__c'), 'Contact__c'));
      idProfessionisti.addAll(U.getIdSet(tu.filter('Tipo__c', 'Professionista').getChanged('Contact__c'), 'Contact__c'));
      idProfessionisti.addAll(U.getIdSet(tu.filter('Tipo__c', 'Professionista').getOldChanged('Contact__c'), 'Contact__c'));
    }

    if (T.isAfterDelete()) {
      idProfessionisti.addAll(U.getIdSet(tu.filter('Tipo__c', 'Professionista').oldMap.values(), 'Contact__c'));
    }

    if (idProfessionisti.isEmpty()) return;

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
      HAVING Contact__c IN :idProfessionisti];

    for (AggregateResult prof : professionisti) {
      Id conId = (Id) prof.get('Contact__c');
      Integer procedureAperte = contactsMap.containsKey(conId) ? contactsMap.get(conId) : 0;
      procedureAperte += (Integer) prof.get('numero');
      contactsMap.put(conId, procedureAperte);
    }

    // Azzero il numero di procedure aperte per i professionisti non considerati prima
    for (Id conId : U.toIdList(idProfessionisti)) {
      if (!contactsMap.containsKey(conId)) contactsMap.put(conId, 0);
    }

    // Aggiorno il DB
    for (Id conId : contactsMap.keySet()) {
      contacts.add(new Contact(Id = conId, ProcedureAperte__c = contactsMap.get(conId)));
    }

    upsert contacts;
  }

  /**
   * Metodo che al variare degli Esecutori Adeguata Verifica recupera gli allegati associati al Referente
   * e crea allegati associati all'opportunità
   */
  public static void recuperaConsensiPrivacyEsecutore(T tu) {
    // Considero solo gli attori diventati esecutori o gli esecutori il cui contatto / opportunità è cambiato
    T esecutoriT = tu
      .filter('Opportunita__c', null, false)
      .filter('Contact__c', null, false)
      .filter('Tipo__c', 'Esecutore Adeguata Verifica', true);

    Set<NDGLinea__c> esecutoriSet = new Set<NDGLinea__c>();
    NDGLinea__c[] esecutori = new NDGLinea__c[]{};
    esecutoriSet.addAll((NDGLinea__c[]) esecutoriT.getChanged('Opportunita__c'));
    esecutoriSet.addAll((NDGLinea__c[]) esecutoriT.getChanged('Contact__c'));
    esecutoriSet.addAll((NDGLinea__c[]) esecutoriT.getChanged('Tipo__c'));
    if (esecutoriSet.isEmpty()) return;
    esecutori.addAll(esecutoriSet);
    Set<Id> contattiIds = U.getIdSet(esecutori, 'Contact__c');
    Set<Id> oppIds = U.getIdSet(esecutori, 'Opportunita__c');

    // Recupero gli allegati PrivacyPfFirm legati agli esecutori e validi ( = con "consensiPrivacyDaCaricare" false)..
    Map<String, SObject> allegatoPrivacyPerContatto = U.keyBy([SELECT Id,
      Contact__c,
      Contact__r.ConsensiPrivacyDaCaricare__c
      FROM Allegato__c
      WHERE Contact__c IN :contattiIds
      AND Opportunita__c = null
      AND Cessione__c = null
      AND Tipo__c = 'PrivacyPfFirm'
    ], 'Contact__c');

    // .. e i relativi ContentDocument..
    Set<Id> allegatiPrivacyEsistenti = U.getIdSet(U.filter(allegatoPrivacyPerContatto.values(), 'Contact__r.ConsensiPrivacyDaCaricare__c', false), 'Id');
    if (allegatiPrivacyEsistenti.isEmpty()) return;
    Map<String, SObject> cdlPerAllegatoPrivacy = U.keyBy([SELECT Id,
      LinkedEntityId,
      ContentDocumentId,
      ContentDocument.LatestPublishedVersion.VersionData,
      ContentDocument.LatestPublishedVersion.Title,
      ContentDocument.LatestPublishedVersion.PathOnClient
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN :allegatiPrivacyEsistenti], 'LinkedEntityId');

  // .. così da avere, se presente, l'ultimo ContentVersion della PrivacyPfFirm per ogni contatto
    Map<String, SObject> cdlPerContatto = new Map<String, SObject>();
    for (Id contattoId : U.toIdList(contattiIds)) {
      if (allegatoPrivacyPerContatto.containsKey(contattoId)) {
        Id allegatoId = (Id) allegatoPrivacyPerContatto.get(contattoId).get('Id');
        if (cdlPerAllegatoPrivacy.containsKey(allegatoId)) {
          cdlPerContatto.put(contattoId, cdlPerAllegatoPrivacy.get(allegatoId));
        }
      }
    }

    // Inserisco gli allegati collegati all'esecutore: per farlo controllo se siano già presenti, in modo da
    // decidere se aggiornare quelli già presenti o crearne di nuovi
    Map<String, Allegato__c[]> allegatoPrivacyPerOpportunita = U.groupBy([SELECT Id,
      Contact__c
      FROM Allegato__c
      WHERE Opportunita__c IN :oppIds
      AND Tipo__c = 'PrivacyPfFirm'], 'Opportunita__c');

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

    Map<String, Allegato__c> allegatiDaInserirePerEsecutore = new Map<String, Allegato__c>();
    Map<String, ContentVersion> cvDaInserirePerEsecutore = new Map<String, ContentVersion>();
    Allegato__c[] allegatiDaInserire = new Allegato__c[]{};
    for (NDGLinea__c esecutore : esecutori) {
      if (cdlPerContatto.containsKey(esecutore.Contact__c)) {
        ContentVersion newCV = new ContentVersion(
          VersionData = ((ContentDocumentLink) cdlPerContatto.get(esecutore.Contact__c)).ContentDocument.LatestPublishedVersion.VersionData,
          Title = ((ContentDocumentLink) cdlPerContatto.get(esecutore.Contact__c)).ContentDocument.LatestPublishedVersion.Title,
          PathOnClient = ((ContentDocumentLink) cdlPerContatto.get(esecutore.Contact__c)).ContentDocument.LatestPublishedVersion.PathOnClient
        );

        if (!allegatoPrivacyPerOpportunita.containsKey(esecutore.Opportunita__c) || !cdlPerAllegatoOpp.containsKey(allegatoPrivacyPerOpportunita.get(esecutore.Opportunita__c)[0].Id)) {
          allegatiDaInserirePerEsecutore.put(esecutore.Id, new Allegato__c(
            Opportunita__c = esecutore.Opportunita__c,
            Tipo__c = 'PrivacyPfFirm',
            CodiceDocumentoTiAnticipo__c = 'PrivacyPfFirm',
            FamigliaDocumento__c = 'Documenti identità'
          ));
        } else {
          newCV.ContentDocumentId = ((ContentDocumentLink) cdlPerAllegatoOpp.get(allegatoPrivacyPerOpportunita.get(esecutore.Opportunita__c)[0].Id)).ContentDocumentId;
        }
        cvDaInserirePerEsecutore.put(esecutore.Id, newCV);
      }
    }

    insert allegatiDaInserirePerEsecutore.values();
    insert cvDaInserirePerEsecutore.values();

    Map<Id, ContentVersion> mapCvs = new Map<Id, ContentVersion>([SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :U.getIdSet(cvDaInserirePerEsecutore.values(), 'Id')]);

    // ..con i CDL collegati al CD del contatto
    ContentDocumentLink[] cdls = new ContentDocumentLink[]{};
    for (NDGLinea__c esecutore : esecutori) {
      if (cvDaInserirePerEsecutore.containsKey(esecutore.Id) && allegatiDaInserirePerEsecutore.containsKey(esecutore.Id)) {
        cdls.add(new ContentDocumentLink(
          ContentDocumentId = mapCvs.get(cvDaInserirePerEsecutore.get(esecutore.Id).Id).ContentDocumentId,
          LinkedEntityId = allegatiDaInserirePerEsecutore.get(esecutore.Id).Id,
          Visibility = 'AllUsers',
          ShareType = 'I'
        ));
      }
    }

    upsert cdls;
  }
}