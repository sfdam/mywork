public without sharing class WsRestDocumentaleUtils {

  public static void inviaDocumentoSingoloQble(Id allegatoId) {
    QbleInvioDocumenti.QbleInvioDocumentiInput input = new QbleInvioDocumenti.QbleInvioDocumentiInput(null, allegatoId);
    System.enqueueJob(new QbleInvioDocumenti(input));
  }

  @future(callout = true)
  public static void recuperaDocumentiAsync(Id oppId) {
    QbleRecuperoDocumenti qDoc = new QbleRecuperoDocumenti(oppId);
    System.enqueueJob(qDoc);
  }

  public static void getDettaglioDocumento(Id idAllegato) {
    Allegato__c allegato = [SELECT
      IdDocumentale__c
      FROM Allegato__c
      WHERE Id = :idAllegato
    ];

    WsRestDocumentale.SearchDocumentDettaglioOggettoInput input = new WsRestDocumentale.SearchDocumentDettaglioOggettoInput();
    input.datiDocumento = new WsRestDocumentale.DatiDocumento();
    input.datiDocumento.addIndiceSpastico('Id', allegato.IdDocumentale__c, '=');

    WsRestDocumentale.DettaglioOggettoResponse response = WsRestDocumentale.dettaglioOggetto(input);
  }
}