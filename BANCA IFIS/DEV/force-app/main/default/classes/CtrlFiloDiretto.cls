/**
* Progetto:         Banca IFIS
* Sviluppata il:    18/12/2016
* Developer:        Zerbinati Francesco, Michele Triaca
*/

public with sharing class CtrlFiloDiretto {
  @TestVisible private static final String CANALE_WEB = '5';
  public static String[] taskFields = new String[]{
    'Id',
    'Subject',
    'ActivityDate',
    'Who.Name',
    'Account.Name',
    'Who.Id',
    'Account.PrioritaSviluppoDiretto__c',
    'Account.PrioritaSviluppoIndiretto__c',
    'What.Name',
    'What.Id',
    'GiaCliente__c',
    'NonSovrascrivere__c',
    'Campagna__c',
    'Campagna__r.Name',
    'OwnerId',
    'Owner.Name',
    'DataRicontatto__c',
    'RecordTypeId',
    'RecordTypeDevName__c',
    'Description',
    'EsitoLivello1__c',
    'EsitoLivello2__c',
    'EsitoLivello3__c',
    'EsitoLivello4__c',
    'EsitoLivello5__c'
  };

  @RemoteAction
  public static Task[] fetchTasks(String filterAzienda, Boolean hideScaduti, Boolean mieiTask, String ncampaignId) {
    Set<Id> accFilter = new Set<Id>();
    Set<Id> cFilter = new Set<Id>();
    Set<Id> tFilter = new Set<Id>();

    if(String.isNotBlank(filterAzienda)) {
      String fa = filterAzienda.replace('*', '') + '*';
      List<SObject[]> res = [FIND :fa IN ALL Fields RETURNING Account, Contact, Task];
      accFilter = U.getIdSet(res[0], 'Id');
      cFilter = U.getIdSet(res[1], 'Id');
      tFilter = U.getIdSet(res[2], 'Id');
    }

    return (Task[]) Database.query(QueryBuilder.newInstance('Task', taskFields).beginFilter()
        .add('Status', QBOp.QNOT_EQUAL, 'Chiuso')
        .add('RecordTypeId', QBOp.QEQUAL, U.getRecordTypes('Task').get('ContattoTelefonicoDiretto').Id)
        .beginOr()
          .add('WhatId', QBOp.QIN, accFilter, !accFilter.isEmpty())
          .add('AccountId', QBOp.QIN, accFilter, !accFilter.isEmpty())
          .add('WhoId', QBOp.QIN, cFilter, !cFilter.isEmpty())
          .add('Id', QBOp.QIN, tFilter, !tFilter.isEmpty())
        .end()
        .beginOr()
          .add('WhoId', QBOp.QNOT_EQUAL, null, true)
          .add('WhatId', QBOp.QNOT_EQUAL, null, true)
        .end()
        .beginOr()
          .add('NonContattareFinoA__c', QBOp.QEQUAL, null, true)
          .add('NonContattareFinoA__c', QBOp.QLTE, Datetime.now())
          .add('OwnerId', QBOp.QEQUAL, UserInfo.getUserId())
        .end()
        .add('DiFiloDiretto__c', QBOp.QEQUAL, true)
        .add('Campagna__c', QBOp.QEQUAL, ncampaignId)
        .add('OwnerId', QBOp.QEQUAL, UserInfo.getUserId(), mieiTask)
        .add('ActivityDate', QBOp.QGTE, Date.today(), hideScaduti)
      .endFilter()
      .setLimit(1000)
      .orderBy(new String[]{'ActivityDate ASC'})
      .getQuery());
  }

  @RemoteAction
  @AuraEnabled
  public static Task createTask(String whoId) {
    Contact c = [SELECT Id, AccountId FROM Contact WHERE Id = :whoId];
    Task t = new Task(
      WhoId = c.Id,
      WhatId = c.AccountId,
      OwnerId = UserInfo.getUserId(),
      Status = 'Aperto',
      Subject = 'Chiamata inbound',
      ActivityDate = Date.today(),
      RecordTypeId = U.getRecordTypes('Task').get('ContattoTelefonicoDiretto').Id
    );

    try {
      insert t;
      return (Task) Database.query(QueryBuilder.newInstance('Task', taskFields)
        .beginFilter()
          .add('Id', QBOp.QEQUAL, t.Id)
        .endFilter()
        .getQuery());
    } catch(DmlException err) {
      throw new Ex.WSException('Errore inserimento task: ' + err.getDmlMessage(0), err);
    }
  }

  @RemoteAction
  @AuraEnabled
  public static Id assignTask(Task t) {
    try {
      Task check = [SELECT NonContattareFinoA__c, OwnerId FROM Task WHERE Id = :t.Id];
      if (check.NonContattareFinoA__c > Datetime.now() && check.OwnerId != UserInfo.getUserId()) throw new Ex.WSException('Task già assegnato ad un altro operatore');
      if(!UtenzeDefault__c.getInstance(UserInfo.getUserId()).AssegnatarioDiDefault__c) {
        t.OwnerId = UserInfo.getUserId();
        t.NonContattareFinoA__c = Datetime.now().addMinutes(5);
      }
      update t;
      return t.OwnerId;
    } catch(DmlException err) {
      throw new Ex.WSException('Errore assegnamento task: ' + err.getDmlMessage(0), err);
    }
  }

  @RemoteAction
  public static Event[] fetchEvents(String dateString, List<Id> users) {
    Date ddate = Date.parse(dateString);
    Datetime d = Datetime.newInstance(ddate, Time.newInstance(0, 0, 0, 0));
    Datetime d1 = d.addDays(1);
    return [SELECT
      Id,
      Subject,
      StartDateTime,
      EndDateTime,
      DurationInMinutes,
      RecordType.Name,
      Owner.Name,
      RecordTypeDevName__c FROM Event
      WHERE ((EndDateTime < :d1 AND EndDateTime > :d) OR (StartDateTime > :d AND StartDateTime < :d1))
      AND OwnerId IN :users
    ];
    // Due date, contact, account, campaign, Subject
  }

  @RemoteAction
  public static Contact fetchContact(Id contactId) {
    return [SELECT
      Id,
      FirstName,
      LastName,
      Ruolo__c,
      Email,
      Phone,
      MobilePhone,
      Account.Name,
      Account.NDGGruppo__c,
      Account.ShippingStreet,
      Account.ShippingCity,
      Account.ShippingState,
      Account.ShippingPostalCode,
      Account.ShippingCountry,
      Account.Fatturato__c,
      toLabel(Account.NaturaGiuridica__c),
      Account.PIVA__c
      FROM Contact
      WHERE Id = :contactId
      LIMIT 1
    ];
    // Due date, contact, account, campaign, Subject
  }

  @RemoteAction
  public static Account fetchAccount(Id accountId) {
    return [SELECT
      Id,
      Name,
      Email__c,
      Phone,
      NDGGruppo__c,
      ShippingStreet,
      ShippingCity,
      ShippingState,
      ShippingPostalCode,
      ShippingCountry,
      Fatturato__c,
      toLabel(NaturaGiuridica__c),
      PIVA__c
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ];
  }

  @RemoteAction
  public static List<MatriceEsiti__mdt> getMatriceEsiti() {
    return [SELECT
      RecordType__c,
      EsitiLivello1__c,
      EsitiLivello2__c,
      EsitiLivello3__c,
      EsitiLivello4__c,
      EsitiLivello5__c,
      Azione__c
      FROM MatriceEsiti__mdt
    ];
  }

  @RemoteAction
  @AuraEnabled
  public static String esitaTask(Task t) {
    try {

      // setto il boolean sul trigger in modo che non giri la validazione per l'obbligo della data ricontatto
      TrgActivity.disabilitaCheckDataRicontatto = true;
      TrgActivity.disabilitaCheckVisita = true;
      // chiudo il task
      t.Status = 'Chiuso';
      if (t.GiaCliente__c) t.EsitoLivello1__c = 'Cliente già sviluppato';
      update t;

      if(t.GiaCliente__c) return 'ok';

      Map<String, SObject> me = U.keyBy([SELECT
            RecordType__c,
            EsitiLivello1__c,
            EsitiLivello2__c,
            EsitiLivello3__c,
            EsitiLivello4__c,
            EsitiLivello5__c,
            Azione__c
            FROM MatriceEsiti__mdt
      ],'{RecordType__c}-{EsitiLivello1__c}_{EsitiLivello2__c}_{EsitiLivello3__c}_{EsitiLivello4__c}_{EsitiLivello5__c}', true, true);

      List<String> arrayEsiti = new List<String> {
        (String) t.get('EsitoLivello1__c'),
        (String) t.get('EsitoLivello2__c'),
        (String) t.get('EsitoLivello3__c'),
        (String) t.get('EsitoLivello4__c'),
        (String) t.get('EsitoLivello5__c')
      };
      String hash = t.get('RecordTypeDevName__c') + '-' + String.join(arrayEsiti, '_' );
      System.debug(hash);
      if(me.containsKey(hash)) {
        String azione = (String) me.get(hash).get('Azione__c');
        return azione;
      } else return 'NOAZIONE';

    } catch(DmlException err) {
      throw new Ex.WSException('Update del task non riuscito: ' + err.getDmlMessage(0), err);
    }
  }

  @RemoteAction
  public static Map<String,User[]> ownersEvento(Id accountId, String comune) {

    Map<String,User[]> owners = new Map<String,User[]>();
    if(String.isBlank(comune)) return owners;
    // titolare dell'account
    Account a = [SELECT
      OwnerId,
      Owner.FirstName,
      Owner.LastName,
      RecordTypeId,
      ShippingPostalCode FROM Account WHERE Id = :accountId
    ];
    owners.put('Titolari', new List<User>{a.Owner});

    // assegnazione territoriale in base al CAP

    List<AssegnazioneAnagrafica__c> assegnazioni = [SELECT
      Utente__c,
      Utente__r.FirstName,
      Utente__r.LastName,
      CAP__c
      FROM AssegnazioneAnagrafica__c
      WHERE Comune__r.Name = :comune
      AND FiloDiretto__c = false
    ];

    Set<User> atSet = new Set<User>();
    for(AssegnazioneAnagrafica__c aa : assegnazioni) {
      atSet.add(aa.Utente__r);
    }
    List<User> atList = new List<User>();
    atList.addAll(atSet);
    if(atList.size() > 0) owners.put('Assegnazione territoriale', atList);


    return owners;
  }

  @RemoteAction
  @AuraEnabled
  public static Boolean creaEvento(Event e) {
//  TEN - 23/05/2019 - Commentato per gestione del presentatore diversa 

    /*System.SavePoint sp = Database.setSavePoint();
    try {
      e.TipoAttivita__c = 'Visita Commerciale';
      e.Campagna__c = Impostazioni__c.getInstance().IdCampagnaWeb__c;
      // sistemo l'account collegato: Owner = a quello dell'evento
      // operatore filo diretto attuale
      // se il presentatore non è un Gestione Debitori lo metto all'owner dell'evento
      Account collegato = [SELECT Id, Presentatore__c FROM Account WHERE Id = :e.WhatId];
      collegato.OwnerId = e.OwnerId;

      if(String.isBlank(collegato.Presentatore__c) || !CU.isGestoreDebitori(collegato.Presentatore__c)) {
        collegato.Presentatore__c = e.OwnerId;
      }

      update collegato;
      insert e;

      inviaMail(e);
      return true;
    } catch(DmlException err) {
      Database.rollback(sp);
      throw new Ex.WSException('Inserimento evento visita non riuscito: ' + err.getDmlMessage(0), err);
    }*/
    return null;
  }

  @RemoteAction
  @AuraEnabled
  public static Boolean riprogrammaTask(Task t) {
    try {
      update new Task(Id = t.Id, DataRicontatto__c = t.DataRicontatto__c);
      return true;
    } catch(DmlException err) {
      throw new Ex.WSException('Riprogrammazione task non riuscita: ' + err.getDmlMessage(0), err);
    }
  }

  private static void inviaMail(Event e) {

    User u = [SELECT Id, Name, Email, ManagerId, Manager.Email FROM User WHERE Id = :e.OwnerId];
    List<String> to = new String[]{};
    to.add(u.Email);

    // se è solo un commerciale (e non un responsabile, metto in cc il suo manager)
    List<String> cc = new String[]{};
    if(CU.isCommerciale(u.Id) && !CU.isResponsabileFiliale(u.Id) && String.isNotBlank(u.Manager.Email)) {
      cc.add(u.Manager.Email);
    }
    if(String.isNotBlank(Impostazioni__c.getInstance().MailFiloDiretto__c)) {
      cc.add(Impostazioni__c.getInstance().MailFiloDiretto__c);
    }

    //Persone in ccn
    List<String> ccn = new String[]{};
    if(String.isNotBlank(Impostazioni__c.getInstance().MailCCNFiloDiretto__c)) {
      ccn.add(Impostazioni__c.getInstance().MailCCNFiloDiretto__c);
    }

    Map<String,String> sostituzioni = new Map<String,String>();
    Event ev = [SELECT CreatedBy.Name, What.Name, ActivityDate, Location, Description FROM Event WHERE Id = :e.Id];
    sostituzioni.put('$$CREATEDBY$$', ev.CreatedBy.Name);
    sostituzioni.put('$$WHAT$$', ev.What.Name);
    sostituzioni.put('$$ACTIVITYDATE$$', ev.ActivityDate.format());
    sostituzioni.put('$$LOCATION$$', ev.Location);
    sostituzioni.put('$$DESCRIPTION$$', ev.Description);
    sostituzioni.put('$$USERNAME$$', u.Name);

    MailUtils.inviaMailApexHTML('MailNotificaVisitaCommerciale', ' VISITA COMMERCIALE PIANIFICATA DA FILO DIRETTO', to, cc, ccn, sostituzioni);
  }
}