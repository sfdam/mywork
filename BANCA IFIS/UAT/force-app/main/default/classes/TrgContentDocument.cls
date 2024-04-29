public with sharing class TrgContentDocument {

  public static Boolean skipCancellaAllegati = false;

  /**
   * Cancella gli allegati relativi ai documenti passati come parametro
   */
  public static void cancellaAllegati(ContentDocument[] contentDocuments) {
    if (skipCancellaAllegati) return;

    Set<Id> contentDocumentIds = U.getIdSet(contentDocuments, 'Id');

    ContentDocumentLink[] contentDocumentLinkList = [
          SELECT LinkedEntityId,
          ContentDocumentId
          FROM ContentDocumentLink
          WHERE ContentDocumentId IN :contentDocumentIds
        ];

    Allegato__c[] allegatiDaRimuovere = new List<Allegato__c>();
    Set<Id> idAllegatiDaRimuovere = new Set<Id>();
    for (ContentDocumentLink cdl : contentDocumentLinkList) {
      if (String.valueOf(cdl.LinkedEntityId).substring(0, 3) == 'a02')
        idAllegatiDaRimuovere.add(cdl.LinkedEntityId);
    }

    for (Id idAllegato : idAllegatiDaRimuovere) {
      allegatiDaRimuovere.add(new Allegato__c(Id = idAllegato));
    }

    delete allegatiDaRimuovere;
  }
}