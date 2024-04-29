/**
* Progetto:         Banca IFIS
* Sviluppata il:    22/12/2016
* Developer:        Zerbinati Francesco
*/

global with sharing class CtrlGestioneAllegati {
  private PageReference backPr;
  public String oppId {get; private set;}

  global class InputObj {
    private String oppId;
    private String attId;
    private String tipo;
    private String famigliaDocumento;

    public InputObj(String oppId, String attId, String tipo, String famigliaDocumento) {
      this.oppId = oppId;
      this.attId = attId;
      this.tipo = tipo;
      this.famigliaDocumento = famigliaDocumento;
    }
  }

  @TestVisible
  private static Set<String> getInputObjField(InputObj[] inputObjs, String field) {
    Set<String> result = new Set<String>();
    for(InputObj o : inputObjs) {
      if (field.compareTo('oppId') == 0) result.add(o.oppId);
      if (field.compareTo('attId') == 0) result.add(o.attId);
      if (field.compareTo('tipo') == 0) result.add(o.tipo);
      if (field.compareTo('famigliaDocumento') == 0) result.add(o.famigliaDocumento);
    }
    return result;
  }

  public CtrlGestioneAllegati() {}
  public CtrlGestioneAllegati(ApexPages.StandardController ctrl) {}

  @RemoteAction
  global static List<Allegato__c> fetchAllegati(InputObj input) {
    System.debug('oppid ' + input.oppId);
    return [SELECT Id, Name, toLabel(Tipo__c), OwnerId, CreatedDate, IdDocumentale__c FROM Allegato__c WHERE Opportunita__c = :input.oppId];
  }

  @RemoteAction
  global static ContentDocumentLink fetchPDF(InputObj input) {
    return [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId = :input.attId];
  }

  @RemoteAction
  global static Boolean salvaAllegato(InputObj input) {
    // Inserisco l'Allegato e lo collego al nuovo Content Document
    Allegato__c all = new Allegato__c(Opportunita__c = input.oppId, Tipo__c = input.tipo, FamigliaDocumento__c = input.famigliaDocumento);
    insert all;

    ContentVersion v = [SELECT ContentDocumentId,
      VersionData,
      Title,
      PathOnClient
      FROM ContentVersion
      WHERE Id = :input.attId
      AND IsLatest = true];

    ContentDocumentLink cl = new ContentDocumentLink(
      ContentDocumentId = v.ContentDocumentId,
      LinkedEntityId = all.Id,
      ShareType = 'I'
    );
    if (input.tipo == 'PrivacyPfFirm' || input.tipo == 'PrivacyFirm' || input.famigliaDocumento == 'Documenti identità') cl.Visibility = 'AllUsers';
    insert cl;

    // Se il documento caricato è la privacy firmata, aggiorno l'Allegato associato all'account / esecutore
    // e segnalo che i consensi privacy sull'account / esecutore non sono più modificati
    Allegato__c allPrincipale;
    if (input.tipo == 'PrivacyFirm') {
      Opportunity opp = [SELECT Id,
        AccountId,
        Account.ConsensiPrivacyModificati__c
        FROM Opportunity
        WHERE Id = :input.oppId
      ];
      if (opp.Account.ConsensiPrivacyModificati__c) update new Account(Id = opp.AccountId, ConsensiPrivacyModificati__c = false);

      Allegato__c[] allList = [SELECT Id
        FROM Allegato__c
        WHERE Account__c = :opp.AccountId
        AND Opportunita__c = null
        AND Cessione__c = null
        AND Tipo__c = :input.tipo
      ];
      if (allList.size() == 1) {
        allPrincipale = allList[0];
      } else {
        allPrincipale = new Allegato__c(
          Account__c = opp.AccountId,
          Tipo__c = input.tipo,
          FamigliaDocumento__c = input.famigliaDocumento
        );
        insert allPrincipale;
      }
    }

    if (input.tipo == 'PrivacyPfFirm') {
      NDGLinea__c esecutore = [SELECT Id,
      Contact__c,
      Contact__r.ConsensiPrivacyModificati__c
      FROM NDGLinea__c
      WHERE Opportunita__c = :input.oppId
      AND Tipo__c = 'Esecutore Adeguata Verifica'];
      if (esecutore.Contact__r.ConsensiPrivacyModificati__c) update new Contact(Id = esecutore.Contact__c, ConsensiPrivacyModificati__c = false);

      Allegato__c[] allList = [SELECT Id
        FROM Allegato__c
        WHERE Contact__c = :esecutore.Contact__c
        AND Opportunita__c = null
        AND Cessione__c = null
        AND Tipo__c = :input.tipo
      ];

      if (allList.size() == 1) {
        allPrincipale = allList[0];
      } else {
        allPrincipale = new Allegato__c(
          Contact__c = esecutore.Contact__c,
          Tipo__c = input.tipo,
          FamigliaDocumento__c = input.famigliaDocumento
        );
        insert allPrincipale;
      }
    }

    if (input.tipo == 'PrivacyFirm' || input.tipo == 'PrivacyPfFirm') {
      ContentDocumentLink[] cdls = [SELECT ContentDocumentId,
        LinkedEntityId,
        ShareType
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :allPrincipale.Id];

      ContentVersion cv = new ContentVersion(VersionData = v.VersionData, Title = v.Title, PathOnClient = v.PathOnClient);

      if (cdls.size() == 1) {
        cv.ContentDocumentId = cdls[0].ContentDocumentId;
      }

      insert cv;

      if (cdls.isEmpty()) {
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        insert new ContentDocumentLink(
          LinkedEntityId = allPrincipale.Id,
          ContentDocumentId = cv.ContentDocumentId,
          ShareType = 'I',
          Visibility = 'AllUsers'
        );
      }
    }

    // Invio documento
    Opportunity opp = [SELECT Id,
      IsClosed,
      IdCartella__c
      FROM Opportunity
      WHERE Id = :input.oppId];
    if (!opp.IsClosed && String.isNotBlank(opp.IdCartella__c)) {
      WsRestDocumentaleUtils.inviaDocumentoSingoloQble(all.Id);
    }

    return true;
  }


  /**
   * Metodo che recupera il ContentDocumentId di un allegato associato all'opportunità, se presente
   */
  @RemoteAction
  global static Id getContentDocumentId(Id oppId, String tipo) {
    Allegato__c[] allList = [SELECT Id
      FROM Allegato__c
      WHERE Opportunita__c = :oppId
      AND Tipo__c = :tipo
    ];
    if (allList.size() == 1) {
      ContentDocumentLink[] cdL = [SELECT ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :allList[0].Id
      ];
      if (cdL.size() == 1) return cdL[0].ContentDocumentId;
    }
    return null;
  }

}