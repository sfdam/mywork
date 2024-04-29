public with sharing class QbleCensimentoCointestatari implements Queueable, Database.AllowsCallouts {

  private JoinCointestazione__c coint = new JoinCointestazione__c();
  private List<CtrlCointestazione.ElemObject> elemObjectList;

  public QbleCensimentoCointestatari (List<CtrlCointestazione.ElemObject> elemObjectList) {
    this.elemObjectList = elemObjectList;
  }

  public void execute(QueueableContext context) {

    if (elemObjectList.isEmpty()) return;

    //oggetti valorizzati in caso di necessaria chiamata a cedacri per il censimento
    String currentCodiceIstituto3N = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
    SObject newCaporete;
    SObject newObj;

    CtrlCointestazione.ElemObject elem = elemObjectList.remove(0);

    JoinCointestazione__c coint = new JoinCointestazione__c();
    coint.CollegamentoAttivo__c = elem.collegamentoAttivo;
    coint.CodiceRapporto__c = elem.rapporto;

    //vedo se c'è il caporete su db, altrimenti va chiamato cedacri per censirlo
    List<Account> caporete = [SELECT Id, NDGGruppo__c FROM Account WHERE CI3N_NDGGruppo__c = : currentCodiceIstituto3N + '-' + elem.ndgCaporete];
    if (!caporete.isEmpty()) {
      coint.Cointestazione__c = caporete[0].Id;
    } else {
      WsAnagrafe.DatiAnagraficiCedacri datiAnagrafici = WsAnagrafe.getAnagrafica(elem.ndgCaporete, null).payload;
      WsAnagraficaBeanIn w = new WsAnagraficaBeanIn(datiAnagrafici);
      newCaporete = w.getObj();
    }

    //vedo se c'è l'ndg che sto processando, altrimenti va chiamato cedacri per censirlo (non so se questo ndg appartenga ad un account o ad un contact)
    List<Account> acc = [SELECT Id, NDGGruppo__c FROM Account WHERE CI3N_NDGGruppo__c = : currentCodiceIstituto3N + '-' + elem.ndg];
    List<Contact> con = [SELECT Id, NDGGruppo__c FROM Contact WHERE CI3N_NDGGruppo__c = : currentCodiceIstituto3N + '-' + elem.ndg];
    if (!acc.isEmpty() && con.isEmpty()) {
      coint.CointestatarioPG__c = acc[0].Id;
    } else if (!con.isEmpty() && acc.isEmpty()) {
      coint.CointestatarioPF__c = con[0].Id;
    } else {
      WsAnagrafe.DatiAnagraficiCedacri datiAnagrafici = WsAnagrafe.getAnagrafica(elem.ndg, null).payload;
      WsAnagraficaBeanIn w1 = new WsAnagraficaBeanIn(datiAnagrafici);
      newObj = w1.getObj();
    }

    //---faccio gli eventuali inserimenti dopo le callout, altrimenti errore di salesforce---
    //se il caporete è stato censito dalla callout
    if (newCaporete != null) {
      insert newCaporete;
      coint.Cointestazione__c = (Id) newCaporete.get('Id');
    }
    //se l'ndg che sto processato è stato censito dalla callout
    if (newObj != null) {
      String newObjType = newObj.getSobjectType().getDescribe().getName();
      if (newObjType == 'Contact') {
          Id accountId = newCaporete != null ? (Id) newCaporete.get('Id') : coint.Cointestazione__c;
          newObj.put('AccountId', accountId);
      }
      insert newObj;
      if (newObjType == 'Account') {
        coint.CointestatarioPG__c = newObj.Id;
      } else if (newObjType == 'Contact') {
        coint.CointestatarioPF__c = newObj.Id;
      }
    }

    //creo il record JoinCointestazione__c solo se non esiste già con tutti i campi uguali a quello che sto processando
    List<JoinCointestazione__c> cointEsistente = [SELECT Id
      FROM JoinCointestazione__c
      WHERE Cointestazione__c = :coint.Cointestazione__c
      AND CointestatarioPG__c = :coint.CointestatarioPG__c
      AND CointestatarioPF__c = :coint.CointestatarioPF__c
      AND CodiceRapporto__c = :coint.CodiceRapporto__c
    ];
    if (!cointEsistente.isEmpty()) coint.Id = cointEsistente[0].Id;
    upsert coint;

    //richiamo l'execute sul prossimo elemento della lista di input
    if (!elemObjectList.isEmpty()) {
      QbleCensimentoCointestatari nextJob = new QbleCensimentoCointestatari(elemObjectList);
      System.enqueueJob(nextJob);
    }
  }
}