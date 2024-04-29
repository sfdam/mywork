public without sharing class QbleInfoCr implements Queueable, Database.AllowsCallouts {
  public class InfoCrElem {
    public Long ndg;
    public Id objId;
    public InfoCrElem(String ndg, Id objId) {
      this.ndg = Long.valueOf(ndg);
      this.objId = objId;
    }
  }

  InfoCrElem[] ndgs;
  Queueable nextQ;

  public QbleInfoCr(Id oppId, Queueable nextQ) {
    Set<String> ditteIndividualiCFs = new Set<String>();
    Set<String> ditteIndividualiCI3Ns = new Set<String>();
    Map<String, String> cfIdMap = new Map<String, String>();

    this.nextQ = nextQ;
    Opportunity o = [SELECT
      Id,
      Account.CodiceIstituto3N__c,
      Account.NDGGruppo__c,
      Account.NaturaGiuridica__c,
      Account.CF__c,
      Account.Id,
      DataRichiestaCR__c,
      (SELECT Id,
        Account__r.CF__c,
        Account__r.CodiceIstituto3N__c,
        Account__r.NaturaGiuridica__c,
        NDG__c FROM NDG_Linee__r WHERE Tipo__c = 'Debitore' AND NDG__c != NULL AND DataRichiestaCR__c = NULL)
      FROM Opportunity
      WHERE Id = :oppId
    ];

    this.ndgs = new InfoCrElem[]{};

    // Controllo se stiamo parlando di DI oppure no..
    if (o.DataRichiestaCR__c == null) {
      if (o.Account.NaturaGiuridica__c == 'DI') {
        // ..se è una ditta individuale lo aggiungo alla lista dei contatti da recuperare
        if (String.isNotBlank(o.Account.CF__c)) {
          ditteIndividualiCFs.add(o.Account.CF__c);
          ditteIndividualiCI3Ns.add(o.Account.CodiceIstituto3N__c);
          cfIdMap.put(o.Account.CF__c, o.Id);
        }
      } else {
        // ..altrimenti, lo aggiungo alla lista di ndg da processare..
        this.ndgs.add(new InfoCrElem(o.Account.NDGGruppo__c, o.Id));
      }
    }
    // ..stessa logica con i debitori
    for (NDGLinea__c deb : o.NDG_Linee__r) {
      if (deb.Account__r.NaturaGiuridica__c == 'DI') {
        if (String.isNotBlank(deb.Account__r.CF__c)) {
          ditteIndividualiCFs.add(deb.Account__r.CF__c);
          ditteIndividualiCI3Ns.add(deb.Account__r.CodiceIstituto3N__c);
          cfIdMap.put(deb.Account__r.CF__c, deb.Id);
        }
      } else {
        this.ndgs.add(new InfoCrElem(deb.NDG__c, deb.Id));
      }
    }

    if (!ditteIndividualiCFs.isEmpty()) {
      if (ditteIndividualiCI3Ns.size() != 1) {
        // tutte le entità devono far parte della stessa istanza di Cedacri (Codice Istituto 3N)
        throw new Ex.WSException('Le entità coinvolte non fanno parte della stessa istanza di Cedacri');
      } else {
        // Recupero ora l'ndg dei contatti associati alle DI
        Contact[] cList = [SELECT Id,
          NDGGruppo__c,
          CF__c
          FROM Contact
          WHERE CF__c IN :ditteIndividualiCFs
          AND CodiceIstituto3N__c = :U.toList(ditteIndividualiCI3Ns)[0]
        ];
        for (Contact c : cList) {
          if (String.isNotBlank(c.NDGGruppo__c)) {
            this.ndgs.add(new InfoCrElem(c.NDGGruppo__c, cfIdMap.get(c.CF__c)));
          }
        }
      }
    }

  }

  public QbleInfoCr(InfoCrElem[] ndgs, Queueable nextQ) {
    this.ndgs = ndgs;
    this.nextQ = nextQ;
  }

  public void execute(QueueableContext context) {
    if (!this.ndgs.isEmpty()) {
      InfoCrElem ndgToProcess = this.ndgs.remove(0);
      Logger.setTransactionContext(null, ndgToProcess.objId);
      WsRestPefMutui.InfoCrInput input = new WsRestPefMutui.InfoCrInput();
      input.ndg = ndgToProcess.ndg;

      try {
        WsRestPefMutui.InfoCr(input);
        SObject objToUpdate = ndgToProcess.objId.getSobjectType().newSObject(ndgToProcess.objId);
        objToUpdate.put('DataRichiestaCR__c', Datetime.now());
        update objToUpdate;
      } catch (Ex.WsCalloutException e) {
      } catch (DMLException e) {
        Logger.log('PEF_InfoCr', e.getMessage() + '. ' + e.getStackTraceString());
      }
    }

    if (!this.ndgs.isEmpty()) {
      QbleInfoCr nextJob = new QbleInfoCr(this.ndgs, this.nextQ);
      if (!Test.isRunningTest())
        System.enqueueJob(nextJob);
    } else if (nextQ != null) {
      if (!Test.isRunningTest())
        System.enqueueJob(nextQ);
    }
  }
}