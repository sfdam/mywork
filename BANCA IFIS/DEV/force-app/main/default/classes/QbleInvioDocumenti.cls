public without sharing class QbleInvioDocumenti implements Queueable, Database.AllowsCallouts {

  public class QbleInvioDocumentiInput {
    public Id oppId;
    public Id allegatoId;

    public QbleInvioDocumentiInput(Id oppId, Id allegatoId) {
      this.oppId = oppId;
      this.allegatoId = allegatoId;
    }
  }

  public class InfoDoc {
    public String nomeFile;
    public String estensione;
    public String tipo;
    public Id docId;
    public String ndg;
    public String ndgName;
    public String idCartella;
    public Id idAllegato;
    public String codiceDocumento;
    public String codiceSottoclasse;
    public String tipoDocumento;

    public InfoDoc(String nomeFile, String estensione, String codiceDocumento, String codiceSottoclasse, Id docId, String ndg, String ndgName, String idCartella, Id idAllegato, String tipoDocumento) {
      this.nomeFile = nomeFile;
      this.estensione = estensione;
      this.codiceDocumento = codiceDocumento;
      this.codiceSottoclasse = codiceSottoclasse;
      this.docId = docId;
      this.ndg = ndg;
      this.ndgName = ndgName;
      this.idCartella = idCartella;
      this.idAllegato = idAllegato;
      this.tipoDocumento = tipoDocumento;
    }

    public Boolean isComplete() {
      return (
        String.isNotBlank(nomeFile)
        && String.isNotBlank(estensione)
        && String.isNotBlank(codiceDocumento)
        && String.isNotBlank(codiceSottoclasse)
        && String.isNotBlank(docId)
        && String.isNotBlank(ndg)
        && String.isNotBlank(ndgName)
        && String.isNotBlank(idCartella)
        && String.isNotBlank(idAllegato)
      );
    }
  }

  InfoDoc[] docs;

  /**
   * Data un'opportunità o un allegato, recupera i Documenti relativi agli allegati dell'opportunità (o all'allegato
   * specificato) non ancora inviati a FileNet (Allegato__c.IdDocumentale__c == null).
   * Se questi son presenti nella MatriceDocumenti recupera le informazioni da essa e nel caso in cui siano complete
   * li aggiunge alla lista dei Documenti da inviare.
   * @param  input
   */
  public QbleInvioDocumenti(QbleInvioDocumentiInput input) {
    docs = new InfoDoc[] {};

    if (String.isNotBlank(input.oppId) || String.isNotBlank(input.allegatoId)) {
      Allegato__c[] allegati = Database.query(QueryBuilder.newInstance('Allegato__c', new String[] {
        'Id',
        'Opportunita__r.Account.NDGGruppo__c',
        'Opportunita__r.Account.Name',
        'Opportunita__r.IdCartella__c',
        'Tipo__c'
      }).beginFilter()
          .beginAnd()
            .add('Opportunita__c', QBOp.QEQUAL, input.oppId)
            .add('Id', QBOp.QEQUAL, input.allegatoId)
            .add('IdDocumentale__c', QBOp.QEQUAL, null, true)
        .endFilter()
        .getQuery());

      Map<String, SObject> matriceDoc = U.keyBy([SELECT
        DeveloperName,
        CodiceDoc__c,
        CodiceSottoclasse__c
        FROM MatriceDocumenti__mdt
      ], 'DeveloperName');

      for (Allegato__c a : allegati) {
        ContentDocumentLink[] docLinks = [SELECT
          Id,
          ContentDocument.LatestPublishedVersionId,
          ContentDocument.FileExtension,
          ContentDocument.Title
          FROM ContentDocumentLink
          WHERE LinkedEntityId = :a.Id
        ];

        for (ContentDocumentLink l : docLinks) {
          if(matriceDoc.containsKey(a.Tipo__c)) {
            InfoDoc newDoc = new InfoDoc(                                     // CAMPI INFODOC
              l.ContentDocument.Title,                                        // nomeFile
              l.ContentDocument.FileExtension,                                // estensione
              (String)matriceDoc.get(a.Tipo__c).get('CodiceDoc__c'),          // codiceDocumento
              (String)matriceDoc.get(a.Tipo__c).get('CodiceSottoclasse__c'),  // codiceSottoclasse
              l.ContentDocument.LatestPublishedVersionId,                     // docId
              a.Opportunita__r.Account.NDGGruppo__c,                          // ndg
              a.Opportunita__r.Account.Name,                                  // ndgName
              a.Opportunita__r.IdCartella__c,                                 // idCartella
              a.Id,                                                           // idAllegato
              (String)matriceDoc.get(a.Tipo__c).get('DeveloperName')          // tipoDocumento
            );
            if (newDoc.isComplete()) {
              docs.add(newDoc);
            } else {
              Logger.log('DOC_InviaDocumento', 'Le informazioni del documento non sono complete e quindi non è stato inviato');
            }
          }
        }
      }
    }
  }

  public QbleInvioDocumenti(InfoDoc[] docs) {
    this.docs = docs;
  }

  public void execute(QueueableContext context) {
    if (this.docs.isEmpty()) return;

    try {
      InfoDoc doc = this.docs.remove(0);
      WsRestDocumentale.AggiungiOggettiInput input = new WsRestDocumentale.AggiungiOggettiInput();
      input.data = new WsRestDocumentale.AggiungiOggettiData();
      input.data.datiDocumento = new WsRestDocumentale.DatiDocumento();
      input.data.datiDocumento = new WsRestDocumentale.DatiDocumento();

      String bodyString = '_START_' + doc.docId + '_END_';
      String mimeType = MIMETypeUtils.getMIMETypeFromExtension(doc.estensione);
      input.data.datiDocumento.addDocument('_NOME_S_' + doc.nomeFile + '_NOME_E_', mimeType, bodyString);

      //indici
      input.data.datiDocumento.addIndice('DATARIF', UDate.getStringDateDDMMYYY(Date.today()));
      input.data.datiDocumento.addIndice('CODICEDOC', doc.codiceDocumento);
      input.data.datiDocumento.addIndice('CODICESOTTOCLASSE', doc.codiceSottoclasse);
      input.data.datiDocumento.addIndice('NDG', doc.ndg);
      input.data.datiDocumento.addIndice('NOMINATIVO', doc.ndgName);
      input.data.datiDocumento.addIndice('CARTELLANV', doc.idCartella);
      input.data.datiDocumento.addIndice('IDLAVORO', 'CRM');
      input.data.datiDocumento.addIndice('ISTITUTO', ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c);

      User u = [SELECT LoginSiebel__c FROM User WHERE Id = :UserInfo.getUserId()];
      input.data.datiDocumento.addIndice('UTENTE', u.LoginSiebel__c);

      if (doc.tipoDocumento == WsRestDocumentale.DOCUMENTO_RSF) {
        input.data.datiDocumento.addIndice('CODICEMODULO', 'CODICE_MODULO_RSF');
      }

      WsRestDocumentale.AggiungiOggettiResponse response = WsRestDocumentale.aggiungiOggetti(input);
      update new Allegato__c(Id = doc.idAllegato, IdDocumentale__c = response.getDocumentId());
    } catch (Ex.WsCalloutException e) {
    } catch (Exception e) {
      Logger.log('DOC_InviaDocumento', e.getMessage());
    }

    if (!this.docs.isEmpty()) {
      QbleInvioDocumenti nextJob = new QbleInvioDocumenti(this.docs);
      System.enqueueJob(nextJob);
    }
  }
}