public without sharing class QbleRecuperoDocumenti implements Queueable, Database.AllowsCallouts {

  public class InfoDoc {
    public String fileName;
    public String link;
    public String idDocumento;
    public String idCartella;
    public String matriceDocDeveloperName;

    public InfoDoc(
      String fileName,
      String link,
      String idDocumento,
      String idCartella,
      String matriceDocDeveloperName
    ) {
      this.fileName = fileName;
      this.link = link;
      this.idDocumento = idDocumento;
      this.idCartella = idCartella;
      this.matriceDocDeveloperName = matriceDocDeveloperName;
    }
  }

  InfoDoc[] docs;
  Id oppId;

  public QbleRecuperoDocumenti(InfoDoc[] docs) {
    this.docs = docs;
  }

  //TODO: per fare bene spostare la callout nell'execute se possibile. Per ora va bene così
  public QbleRecuperoDocumenti(Id idOpp) {
    oppId = idOpp;
    Logger.setTransactionContext(idOpp, null);
    docs = new InfoDoc[] {};

    String errorMessage;
    Map<String, SObject> matriceDoc = U.keyBy([SELECT
      DeveloperName,
      CodiceDoc__c,
      CodiceSottoclasse__c,
      RecuperareDaFilenet__c
      FROM MatriceDocumenti__mdt
    ], 'CodiceDoc__c');

    Opportunity opp = [SELECT
      IdCartella__c
      FROM Opportunity
      WHERE Id = :idOpp
    ];

    WsRestDocumentale.SearchDocumentDettaglioOggettoInput input = new WsRestDocumentale.SearchDocumentDettaglioOggettoInput();
    input.datiDocumento = new WsRestDocumentale.DatiDocumento();
    input.datiDocumento.setPaginaStd();
    input.datiDocumento.ordine = 'ISTITUTO';
    input.datiDocumento.righeMassime = '15';
    input.datiDocumento.addIndice('CARTELLANV', opp.IdCartella__c, '=');
    //cerco solo contratti
    //TODO: si può fare meglio, per ora facciamo così
    input.datiDocumento.addIndice('CODICESOTTOCLASSE', 'EX0020002', '=');

    WsRestDocumentale.SearchDocumentResponse response = WsRestDocumentale.searchDocument(input);

    String urlFileNet = EndpointServizi__c.getInstance('settings').UrlFileNet__c;

    for (WsRestDocumentale.Elemento e : response.getResults()) {
      MatriceDocumenti__mdt doc = (MatriceDocumenti__mdt) matriceDoc.get(e.getCodiceDoc());
      if (doc != null && doc.RecuperareDaFilenet__c) {
        docs.add(new InfoDoc(
          e.getDocumentName(),
          urlFileNet + e.link,
          e.id,
          opp.IdCartella__c,
          doc.DeveloperName
        ));
      }
    }
  }

  public void execute(QueueableContext context) {
    Logger.setTransactionContext(oppId, null);

    if (this.docs.isEmpty()) return;
    InfoDoc doc = this.docs.remove(0);

    try {
      WsRestDocumentale.getDocumentThroughTalend(doc.fileName, doc.link, doc.idDocumento, doc.idCartella);
    } catch(Exception e) {}

    if (!this.docs.isEmpty()) {
      QbleRecuperoDocumenti nextJob = new QbleRecuperoDocumenti(this.docs);
      System.enqueueJob(nextJob);
    }
  }
}