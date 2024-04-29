/**
* Progetto:         Banca IFIS
* Descrizione:      Classe handler del trigger Task.trigger e Event.Trigger
* Sviluppata il:    12/12/2016
* Ampiamente modificata il: 31/01/2017
* Developer:        Zerbinati Francesco, Michele Triaca
*/

public with sharing class TrgActivity {
  public static Boolean disabilitaCheckDataRicontatto = false;
  public static Boolean disabilitaCheckVisita = false;
  public static boolean contestoTrgAccountCambiaOwnerAttivita = false;
  public static final String ID_COVISIAN = Impostazioni__c.getInstance().Id_Covisian__c;

  /** In base alla matrice di condizioni MatriceEsiti svolgo delle azioni **/
  public static void azioneEsitazioneActivity(T tu) {

    SObject[] listaActivity = tu.getChanged(new List<String>{
      'RecordTypeId',
      'EsitoLivello1__c',
      'EsitoLivello2__c',
      'EsitoLivello3__c',
      'EsitoLivello4__c',
      'EsitoLivello5__c',
      'DataRicontatto__c'
    });

    if(listaActivity.isEmpty()) return;

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

    Map <String, SObject[]> mappaAzioni = new Map<String,SObject[]>();

    for(SObject t : listaActivity) {
      List<String> arrayEsiti = new List<String> {
        (String) t.get('EsitoLivello1__c'),
        (String) t.get('EsitoLivello2__c'),
        (String) t.get('EsitoLivello3__c'),
        (String) t.get('EsitoLivello4__c'),
        (String) t.get('EsitoLivello5__c')
      };
      String hash = t.get('RecordTypeDevName__c') + '-' + String.join(arrayEsiti, '_' );

      String azione;
      if(me.containsKey(hash)) {
        azione = (String) me.get(hash).get('Azione__c');
        if(!mappaAzioni.containsKey(azione)) mappaAzioni.put(azione, new List<SObject>());
        mappaAzioni.get(azione).add(t);
      }

    }

    for(String azione : mappaAzioni.keySet()) {
      List<SObject> daProcessare = mappaAzioni.get(azione);

      System.debug('Eseguo azione: ' + azione);

      if (azione == 'Invio email') MailUtils.inviaMaildaTaskEventi(daProcessare,'ContattoTelefonicoKO');
      if (azione == 'Invio segnalazione a BU NPL')  MailUtils.inviaMaildaTaskEventi(daProcessare,'SegnalazioneNPL');
      if (azione == 'Invio segnalazione a Rendimax')  MailUtils.inviaMaildaTaskEventi(daProcessare,'SegnalazioneRendimax');

      if (azione == 'FINE') settaFuoriMagazzino(daProcessare, true);
      if (azione == 'WIP') settaFuoriMagazzino(daProcessare, false);
      if (azione == 'Contatto telefonico' && !disabilitaCheckDataRicontatto) controllaDataRicontatto(daProcessare);
      if (azione.containsIgnoreCase('Visita') && !disabilitaCheckVisita) bloccaEsitoSeFiloDiretto(daProcessare);
    }
  }

  //SDHDFNZ-130947 Nel Before Update - allinea Data_Inizio__c e Data_Fine__c su Activity con StartDateTime e EndDateTime su Event
  public static void allineaDataInizioFine(T tu) {

	Event[] listaActivityStart = tu.getChanged('StartDateTime');
	Event[] listaActivityEnd = tu.getChanged('EndDateTime');

    if(!listaActivityStart.isEmpty()){
		for(Event t : listaActivityStart) {
			t.Data_Inizio__c = t.StartDateTime;
		}
	}

	if(!listaActivityEnd.isEmpty()){
		for(Event t : listaActivityEnd) {
			t.Data_Fine__c = t.EndDateTime;
		}
	}
  }

  //SDHDFNZ-132648 Nel Before Update - allinea Data_Inizio__c e Data_Fine__c su Activity in caso di modifica di ActivityDate (denominata Scadenza su Task)
  public static void allineaDataInizioTask(T tu) {

	Task[] listaActivityScadenza = tu.getChanged('ActivityDate');
	Task[] listaActivityInizio = tu.getChanged('Data_Inizio__c');

    if(!listaActivityScadenza.isEmpty()){
		for(Task t : listaActivityScadenza) {
			t.Data_Inizio__c = Datetime.newinstance(t.ActivityDate.year(), t.ActivityDate.month(), t.ActivityDate.day());
			t.Data_Fine__c = t.Data_Inizio__c.addMinutes(15);			
		}
	}

	if(!listaActivityInizio.isEmpty()){
		for(Task t : listaActivityInizio) {
			t.Data_Fine__c = t.Data_Inizio__c.addMinutes(15);
            t.ActivityDate = Date.newinstance(t.Data_Inizio__c.year(), t.Data_Inizio__c.month(), t.Data_Inizio__c.day());			
		}
	}
  }

  /**
  * Prende una lista di task in input e crea nuovi task con data DataRicontatto__c
  **/
  public static void creaTaskRicontatto(T tu) {

    SObject[] listaActivity = tu.getChanged('DataRicontatto__c');

    SObject[] nuovi = new SObject[]{};
    for(SObject v : listaActivity) {
      if(v.get('DataRicontatto__c') != null) {
        nuovi.add(new Task(
          WhoId = (Id) v.get('WhoId'),
          WhatId = (Id) v.get('WhatId'),
          OwnerId = (Id) v.get('OwnerId'),
          Status = 'Aperto',
          Campagna__c = (Id) v.get('Campagna__c'),
          Description = (String) v.get('Description'),
          Subject = Label.RicontattoTelefonico,
          RicontattoTelefonico__c = true,
          ActivityDate = (Date) v.get('DataRicontatto__c'),
          RecordTypeId = (Id) v.get('RecordTypeId'),
          // SM TEN 17042019 - Aggiunta mappatura campi per ricontatto
          Data_Fine__c = (Date) v.get('DataRicontatto__c'),
          Data_Inizio__c = (Date) v.get('DataRicontatto__c'),
		  //  A.M. SDCHG-5892
		  IFISIdUnicoForm__c = (String) v.get('IFISIdUnicoForm__c')
        ));
      }
    }

    insert nuovi;
  }


  /**
   * Chiude il task/evento se è stato esitato. Se si tratta di task, forza lo status a closed e l'activity date alla data
   * di chiusura
  **/
  public static void chiudiActivityEsitata(T tu) {

    SObject[] trgNew = tu.triggerNew;
    Map<Id, SObject> oldMap = tu.oldMap;
    SObject[] listaActivity = new SObject[]{};
    for (SObject obj : trgNew) {
      Id objId = (Id) obj.get('Id');
      if (Trigger.isInsert) {
        if (obj.get('EsitoLivello1__c') != null || obj.get('Il_rapporto_sara_avviato_nei_prossimi_3__c') != null) {
          listaActivity.add(obj);
        }
      } else if (Trigger.isUpdate) {
        if ((obj.get('EsitoLivello1__c') != null && oldMap.get(objId).get('EsitoLivello1__c') == null) ||
          (obj.get('Il_rapporto_sara_avviato_nei_prossimi_3__c') != null && oldMap.get(objId).get('Il_rapporto_sara_avviato_nei_prossimi_3__c') == null)) {
            listaActivity.add(obj);
        }
      }
    }

    for(SObject t : listaActivity) {
      t.put('DataOraEsitazione__c', Datetime.now());
      if(t.getSObjectType() == Task.SObjectType) {
      	t.put('Status', 'Chiuso');
        String assegnatario = String.valueOf(t.get('OwnerId'));  
        //if(t.get('OwnerId') != ID_COVISIAN) { //Se owner = Covisian non modifico la data scadenza
        if(assegnatario != null && !ID_COVISIAN.contains(assegnatario)) {
        	t.put('ActivityDate', Date.today());
        }
      }
    }
  }

  /** Chiude di default tutte le segnalazioni **/
  public static void chiudiSegnalazione(T tu) {
    Task[] listaSegnalazioni = tu.filter('RecordTypeId',  U.getRecordTypes('Task').get('Segnalazione').Id).triggerNew;
    for(Task t : listaSegnalazioni) {
      t.Status = 'Chiuso';
      t.ActivityDate = Date.today();
    }
  }

  /** Rinomina l'oggetto dell'evento in  Tipo Attività - Nome Correlato **/
  public static void rinominaEvento(T tu) {
    Event[] listaActivity = tu
      .filter('WhatId', (String) null, false)
      //.filter('TipoAttivita__c', (String) null, false)
      .triggerNew;

    Map<String, String> options = new Map<String, String>();
    List<Schema.Picklistentry> fieldResult = Event.TipoAttivita__c.getDescribe().getPicklistValues();
    for(Schema.PicklistEntry f : fieldResult) {
      options.put(f.getValue(), f.getLabel());
    }

    Map<Id, SObject> whatMap = getWhatMap(listaActivity, false);
    for(Event e : listaActivity) {
      //e.Subject = (options.get(e.TipoAttivita__c) + ' - ' + (String) whatMap.get(e.WhatId).get('Name')).abbreviate(255);
      e.Subject = 'Visita Commerciale - ' + String.valueOf(WhatMap.get(e.WhatId).get('Name')).abbreviate(255);
    }
  }

  public static void rinominaTask(T tu) {
    for(Task t : (Task[]) tu
      .filter('Debitore__c', (String) null, false)
      .filter('RecordTypeId', U.getRecordTypes('Task').get('Segnalazione').Id)
      .triggerNew
    ) {
      t.Subject = (Label.SegnalazioneDebitore + ' ' + t.NomeDebitore__c).abbreviate(255);
    }

	//SDCHG-6053 CHANGE PROMEMORIA
	for(Task t : (Task[]) tu
      .filter('BI_Tipo_Promemoria__c', (String) null, false)
      .filter('RecordTypeId', U.getRecordTypes('Task').get('Promemoria').Id)
      .triggerNew
    ) {
		if (t.BI_Tipo_Promemoria__c != '-')
			t.Subject = ('Promemoria ' + t.BI_Tipo_Promemoria__c).abbreviate(255);
    }
  }

  //SDCHG-6053 CHANGE PROMEMORIA
   /** Chiude di default il promemoria se è valorizzato il cmapo CommentiEsito__c **/
  public static void chiudiPromemoria(T tu) {
	Task[] listaPromemoria = tu.filter('RecordTypeId',  U.getRecordTypes('Task').get('Promemoria').Id).triggerNew;
    for(Task t : listaPromemoria) {
		if (t.CommentiEsito__c != null){
			t.Status = 'Chiuso';
		}
    }
  }


  /** Su inserimento Eventi
  * In creazione controlla campo "Tipo Attività".
  * Visita Commerciale o Visita Firma Contratto possibili solo dal titolare e solo su account Prospect o Cliente non attivo.
  * Visita relazione su clienti attivi e anche da non titolari
  **/


  
// Metodo che non viene chiamato nei triggere che gestiscono Event e Task
  /*public static void bloccaVisiteNonPossibili(T tu, Boolean skipCheckTitolare) {
    
      // Gli utenti Filo Diretto possono creare visite senza restrizioni.

      // Visita "commerciale" o per "firma contratto" è possibile se tutte le seguenti condizioni sono soddisfatte:
      // 1) l'owner evento è nell'account team

      // Visita "relazionale" è possibile se tutte le seguenti condizioni sono soddisfatte:
      // 1) l'account non è prospect
      // 2) l'account è attivo
      // Questo tipo di visita può essere creata inoltre da commerciali/responsabili Leasing, Lending e Finanza Strutturata senza restrizioni
    
    if (CU.isFiloDiretto()) return;
    Event[] eventi = tu.filter('WhatId', (String) null, false).filter('TipoAttivita__c', (String) null, false).triggerNew;
    if (eventi.isEmpty()) return;

    Map<Id,Account> coinvolti = new Map<Id,Account>([SELECT
      Id,
      OwnerId,
      RecordTypeId,
      StatoAnagrafica__c,
      Controparte__c
      FROM Account
      WHERE Id IN :U.getIdSet(eventi, 'WhatId')
    ]);

    Map<String, AccountTeamMember[]> coinvoltiAccountTeam = U.groupBy([
      SELECT UserId,
      AccountId
      FROM AccountTeamMember
      WHERE AccountId IN :coinvolti.keySet()
      ], 'AccountId');

    Id rtCliente = U.getRecordTypes('Account').get('Cliente').Id;
    Id rtProspect = U.getRecordTypes('Account').get('Prospect').Id;

    for (Event e : eventi) {
      
      //    - Prospect o Cliente non attivo. Visite possibili: Commerciale / Firma
      //    - Cliente attivo con campo Controparte=Debitore o Cedente o Cedente Debitore. Visite possibili: tutte e 3, ovver Commerciale / Firma / Relazionale
      
      Boolean ownerUgualeOInAccountTeam = e.OwnerId != coinvolti.get(e.WhatId).OwnerId;
      if (e.WhatId.getSobjectType() == Account.SObjectType) ownerUgualeOInAccountTeam = ownerUgualeOInAccountTeam || U.getSet(coinvoltiAccountTeam.get(e.WhatId), 'UserId').contains(e.OwnerId);

      Boolean clienteDebitore = coinvolti.get(e.WhatId).RecordTypeId == rtCliente && coinvolti.get(e.WhatId).Controparte__c == 'Debitore';
      Boolean clienteAttivo = coinvolti.get(e.WhatId).RecordTypeId == rtCliente && String.isNotBlank(coinvolti.get(e.WhatId).Controparte__c);
      Boolean clienteCedente = !clienteDebitore && clienteAttivo;

      Boolean visitaCommercialeOppureFirma = e.TipoAttivita__c.containsIgnoreCase('Commerciale') || e.TipoAttivita__c.containsIgnoreCase('Firma');
      Boolean visitaRelazionale = e.TipoAttivita__c.containsIgnoreCase('Relazionale');

      if (visitaCommercialeOppureFirma && !ownerUgualeOInAccountTeam && !skipCheckTitolare) e.addError(Label.ERR_visitaTitolare);
      if (!CU.isLeasing(e.OwnerId) && !CU.isLending(e.OwnerId) && !CU.isFinanzaStrutturata(e.OwnerId)) {
        if (visitaRelazionale && !clienteAttivo) e.addError(Label.ERR_visitaRelazionale);
      }
    }
  }*/


  /**
  * Metodo che impedisce di cancellare un task o un evento, se è già stato chiuso o se l'utente è un commerciale
  * o un gestore debitori e l'attività non è assegnata a lui.
  **/
  public static void controlloCancellazioneActivity(T tu) {

    SObject[] daCancellare = tu.oldMap.values();

    for(SObject t : daCancellare) {

      //impedisci di cancellare task già chiuso
      if( t.getSobjectType() == Task.getSObjectType() && t.get('Status') == 'Chiuso') {
        t.addError(Label.ERR_cancellaTask);
      }

      //impedisci di cancellare evento già chiuso (considero chiuso se è presente un esito di livello 1)
      if( t.getSobjectType() == Event.getSObjectType() && t.get('EsitoLivello1__c') != null) {
        t.addError(Label.ERR_cancellaEvento);
      }

      //se l'activity non è mia e sono un commerciale o un gestore debitori, non la posso cancellare
      if(t.get('OwnerId') != UserInfo.getUserId() && (CU.isCommerciale() || CU.isGestoreDebitori())) {
        t.addError(Label.ERR_cancellaAttivita);
      }

      //se l'activity non è stata creata da me e sono un commerciale, non la posso cancellare
      // skippo per utente integrazione
      UtenzeDefault__c u = UtenzeDefault__c.getInstance((Id) t.get('CreatedById'));
      if(t.get('CreatedById') != UserInfo.getUserId() && !u.AssegnatarioDiDefault__c && CU.isCommerciale()) {
        t.addError(Label.ERR_cancellaAttivitaCreata);
      }

    }
  }


  /*
  * Cambio ownership per operatori Filo Diretto
  * Esitazione di un task non mio di tipo contatto telefonico DIRETTO con associato un account
  * il task apparteneva ad un altro operatore di filo diretto
  */
  public static void gestisciOwnershipTaskFiloDiretto(T tu) {

    if (!CU.isFiloDiretto()) return;
	Map<Id, SObject> oldMap = tu.oldMap;
    //prendo i task da controllare e i corrispondenti owners (inclusi i loro ruoli)
    List<Task> daControllare = (List<Task>) tu
      .filter('RecordTypeId', U.getRecordTypes('Task').get('ContattoTelefonicoDiretto').Id)
      .triggerNew;

    Set<Id> ownersId = U.getIdSet(daControllare, 'OwnerId');
    Map<Id, User> prevOwnersDiFD = new Map<Id, User>([SELECT Id
      FROM User
      WHERE UserRole.DeveloperName LIKE '%FiloDiretto%'
      AND Id IN :ownersId]);

    for(Task t : daControllare) {
	  Id objId = (Id) t.get('Id');
	  // se il precedente owner era di filo diretto e lo stato è chiuso (ovvero è esitato) ma la modifica non è su un task chiuso in precedenza
      if(prevOwnersDiFD.containsKey(t.OwnerId) && t.Status == 'Chiuso' && oldMap.get(objId).get('Status') != 'Chiuso') {
        t.OwnerId = UserInfo.getUserId();
      }
    }

  }

  /**
  * Cambio owner dell'account collegato al task secondo le condizioni:
  * Se GestoreDebitori o International crea un task di tipo Segnalazione legato ad un account, lui diventa il presentatore di quell’account
  * La Segnalazione genera un Task CT assegnato ad un operatore FD (in base CAP) o a un operatore International e associato ad una campagna
  **/
  public static void gestisciSegnalazione(T tu) {
    // scremo solo per le segnalazioni
    if(!(CU.isGestoreDebitori() || CU.isInternational())) return;
    Task[] listaSegnalazioni = tu.filter('RecordTypeId',  U.getRecordTypes('Task').get('Segnalazione').Id).triggerNew;
    if(listaSegnalazioni.isEmpty()) return;

    // ok, sono segnalazioni
    // procedo con cambio ownership dell'account (TODO check se anche altri oggetti)
    Map<Id, Account> accs = new Map<Id, Account>([SELECT
      Id,
      ShippingPostalCode,
      ShippingState,
      ShippingCity,
      BillingPostalCode,
      BillingState,
      BillingCity
      FROM Account
      WHERE Id IN :U.getIdSet(listaSegnalazioni, 'WhatId')
    ]);

    for(Account a : accs.values()) {
      a.Presentatore__c = UserInfo.getUserId();
    }
    update accs.values();

    Map<String, Id> cap2owner;
    if (CU.isGestoreDebitori()) {
      Set<String> caps = U.getSet(accs.values(), 'ShippingPostalCode');
      Set<String> comuni = U.getSet(accs.values(), 'ShippingCity');
      Set<String> provincie = U.getSet(accs.values(), 'ShippingState');
      caps.addAll(U.getSet(accs.values(), 'BillingPostalCode'));
      comuni.addAll(U.getSet(accs.values(), 'BillingCity'));
      provincie.addAll(U.getSet(accs.values(), 'BillingState'));

      cap2owner = UtilAnagrafiche.getOwners(caps, comuni, provincie, true);
    }

    // ora genero il ContattoTelefonico
    SObject[] nuovi = new SObject[]{};
    for(Task t : listaSegnalazioni) {
      Id ownerId;
      // Se il gestore che ha creato la segnalazione è un operatore di Filo Diretto, assegno il task Contatto Telefonico ad un operatore FiloDiretto in base CAP..
      if (CU.isGestoreDebitori()) {
        ownerId = cap2owner.get('0000');
        if(String.isNotBlank(t.WhatId) && accs.containsKey(t.WhatId)) {
          Account a = accs.get(t.WhatId);
          // Considero i campi nell'array "fields" nell'ordine in cui sono inseriti: al primo match prendo l'owner
          String[] fields = new String[]{'BillingPostalCode', 'ShippingPostalCode', 'BillingCity', 'ShippingCity', 'BillingState', 'ShippingState'};
          for (String field : fields) {
            String fieldValue = (String) a.get(field);
            if (String.isNotBlank(fieldValue) && cap2owner.containsKey(fieldValue)) {
              String ownerValue = cap2owner.get(fieldValue);
              if (String.isNotBlank(ownerValue)) {
                ownerId = ownerValue;
                break;
              }
            }
          }
        }
      // ..altrimenti, se il gestore che ha creato la segnalazione è un International, assegno il task a un utente International di default
      } else if (CU.isInternational()) {
        ownerId = Impostazioni__c.getInstance().IdOwnerCampagnaSviluppoDebInternational__c;
      }

      // il task sarà a sua volta associato alla campagna default di filo diretto o di international
      nuovi.add(new Task(
        WhatId = t.WhatId, // account della segnalazione
        Status = 'Aperto',
        OwnerId = ownerId,
        Campagna__c = CU.isGestoreDebitori() ? Impostazioni__c.getInstance().IdCampagnaSviluppoDebitori__c : Impostazioni__c.getInstance().IdCampagnaSviluppoDebitoriInternational__c, // campagna default
        Subject = 'Contatto telefonico',
        RicontattoTelefonico__c = false,
        ActivityDate = Date.today(),
        RecordTypeId = U.getRecordTypes('Task').get('ContattoTelefonicoDiretto').Id
      ));
    }
    insert nuovi;

  }

  public static Map<Id, SObject> getWhatMap(SObject[] activities, Boolean onlyWhatWithOwner) {
    Map<Id, SObject> res = new Map<Id, SObject>();
    Map<String, SObject> eventOrTaskMap = U.keyBy(activities, 'WhatId');

    Map<SObjectType, Set<Id>> whatMap = new Map<SObjectType, Set<Id>>();
    for(SObject o : U.filter(activities, 'WhatId', (String) null, false)) {
      SObjectType objType = ((Id) o.get('WhatId')).getSObjectType();
      if(!whatMap.containsKey(objType)) whatMap.put(objType, new Set<Id>());
      whatMap.get(objType).add((Id) o.get('WhatId'));
    }

    //QUERY NEL FOR!!! MA LE CHIAVI DELLA MAPPA SARANNO 2 O 3 AL MASSIMO. BY MT
    for(SObjectType objType : whatMap.keySet()) {
      Schema.DescribeSObjectResult dsor = objType.getDescribe();
      String[] fields = new String[]{'Id', 'Name'};
      if(dsor.fields.getMap().containsKey('OwnerId')) fields.add('OwnerId');
      else if(onlyWhatWithOwner) continue;

      String q = QueryBuilder.newInstance(dsor.getName(), fields)
        .beginFilter()
          .add('Id', QBOp.QIN, whatMap.get(objType))
        .endFilter()
        .getQuery();

      SObject[] objL = Database.query(q);
      res.putAll(objL);
    }

    return res;
  }

  /**
   * Blocca l'inserimento/update/cancellazione di un task/evento se questo è collegato ad un oggetto il cui owner non è l'utente stesso.
   * Il controllo non viene fatto per utenze che non siano commerciali factoring o che siano responsabili filiale
   * Il controllo non viene fatto per task/eventi di tipo "Visita debitore", "Visita Relazionale", e nel caso di
   * international per il contatto telefonico creato da una segnalazione debitori da parte di un operatore international
   **/


// Metodo che non viene chiamato nei triggere che gestiscono Event e Task
/*  public static void bloccaAzioniActivityNonOwner(T tu) {
    if(!CU.isCommerciale() || CU.isResponsabileFiliale()) return;

    SObject[] tuList = tu.triggerNew;
    if(tu.mode == T.TMode.xDELETE) tuList = tu.oldMap.values();
    // non faccio il controllo per quelle che sono visita debitori (requisito GPD)
    tuList = U.filter(tuList, 'TipoAttivita__c', 'Visita debitore', false);
    // non lo faccio neanche per Visita Relazionale
    tuList = U.filter(tuList, 'TipoAttivita__c', 'Visita Relazionale', false);
    // INTERNATIONAL: non faccio il controllo il contatto telefonico creato da una segnalazione debitori da parte di un operatore international
    if(CU.isInternational()) {
      tuList = U.filter(tuList, 'Campagna__c', Impostazioni__c.getInstance().IdCampagnaSviluppoDebitoriInternational__c, false);
      tuList = U.filter(tuList, 'RecordTypeDevName__c', 'Segnalazione', false);
    }

    tuList = U.filter(tuList, 'TipoAttivita__c', (String) null, false);

    tuList = U.filter(tuList, 'WhatId', (String) null, false);

    Map<Id, SObject> whatMap = getWhatMap(tuList, true);

    Map<String, AccountTeamMember[]> coinvoltiAccountTeam = U.groupBy([
      SELECT UserId,
      AccountId
      FROM AccountTeamMember
      WHERE AccountId IN :U.getSet(tuList, 'WhatId')
      ], 'AccountId');

    Boolean isUpdate = tu.mode == T.TMode.xUPDATE;
    for(SObject activity : tuList) {
      Id whatId = (Id) activity.get('WhatId');
      if (whatMap.containsKey(whatId)) {
        // whatId = Account: se l'owner dell'activity non è nè nell'Account Team nè è l'owner del whatId lancio errore
        if (whatMap.get(whatId).getSobjectType() == Account.SObjectType) {
          if(!trgActivity.contestoTrgAccountCambiaOwnerAttivita && isUpdate && activity.getSObjectType().getDescribe().getName() == 'Task' && UserInfo.getUserId() != activity.get('OwnerId')){
            activity.addError(Label.ERR_modificaTaskProprietario);
          }
          if((!U.getSet(coinvoltiAccountTeam.get(whatId), 'UserId').contains(String.valueOf(activity.get('OwnerId'))) && whatMap.get(whatId).get('OwnerId') != activity.get('OwnerId'))){
            activity.addError(Label.ERR_richiediAssegnazioneAnagrafica);
          }
        // whatId != Account: se l'owner dell'activity non è l'owner del whatId lancio errore
        } else {
          if(whatMap.get(whatId).get('OwnerId') != activity.get('OwnerId')) {
              activity.addError(Label.ERR_richiediAssegnazioneAnagrafica);
          }
        }
      }
    }
  }*/

  /**
   * Leasing.
   * Alla chiusura di un'attività di tipo "Visita.." o "Contatto Telefonico", se l'attività è associata a un Account e
   * l'owner dell'attività è un commercialeEF o TR di quell'Account, aggiorno la corrispettiva data di ultimo contatto.
   */
  public static void popolaDataUltimoContatto(T tu) {
    SObject[] activities = tu.filter('EsitoLivello1__c', null, false).getChanged('EsitoLivello1__c');
    Map<Id,Account> accsToUpdate = new Map<Id,Account>();
    /*Map<Id,Account> accountCoinvolti = new Map<Id,Account>([
      SELECT Id,
      CommercialeEF__c,
      CommercialeTR__c,
      UltimoContattoEF__c,
      UltimoContattoTR__c
      FROM Account
      WHERE Id IN :U.getIdSet(activities, 'WhatId')
    ]);*/
      
    Map<Id,Account> accountCoinvolti = new Map<Id,Account>([
      SELECT Id,
      WGC_Specialista_Leasing__c,
      WGC_Specialista_Leasing_TR__c,
      UltimoContattoEF__c,
      UltimoContattoTR__c
      FROM Account
      WHERE Id IN :U.getIdSet(activities, 'WhatId')
    ]);

    for(SObject activity : activities) {
      //String tipoAttivita = (String) activity.get('TipoAttivita__c');
      Id whatId = (Id) activity.get('WhatId');
      Id ownerId = (Id) activity.get('OwnerId');
      Date activityDate = (Date) activity.get('ActivityDate');
      //if ((tipoAttivita.containsIgnoreCase('Contatto Telefonico') || tipoAttivita.containsIgnoreCase('Visita')) && whatId != null && whatId.getSobjectType() == Account.SObjectType) {
      if (whatId != null && whatId.getSobjectType() == Account.SObjectType) {
        Account a = accsToUpdate.containsKey(whatId) ? accsToUpdate.get(whatId) : accountCoinvolti.get(whatId);
        if (ownerId == a.WGC_Specialista_Leasing__c && (activityDate >= a.UltimoContattoEF__c || a.UltimoContattoEF__c == null)) a.UltimoContattoEF__c = activityDate;
        if (ownerId == a.WGC_Specialista_Leasing_TR__c && (activityDate >= a.UltimoContattoTR__c || a.UltimoContattoTR__c == null)) a.UltimoContattoTR__c = activityDate;
        accsToUpdate.put(whatId, a);
      }
    }
    update accsToUpdate.values();
  }

  /**
  * Se un utente filo diretto esita un task senza flag "gia cliente" e senza "non sovrascrivere"
  * l'utente FiloDiretto diventa owner e presentatore (e diventa anche OpFiloDiretto__c dell'account via trigger)
  */
  public static void gestisciOwnershipAccountFiloDiretto(T tu) {
    // TEN - 24/05 - Modificata Logica Presentatore ed Owner
      /*if (!CU.isFiloDiretto()) return;

    // filtro task per non gia cliente, escludendo i promemoria
    List<Task> task = tu.filter('GiaCliente__c', true, false).filter('NonSovrascrivere__c', true, false).filter('Status', 'Chiuso').filter('RecordTypeId', U.getRecordTypes('Task').get('Promemoria').Id, false).getChanged(new String[]{'Status'});

    Set<Id> accountIds = U.getIdSet(task, 'WhatId');

    Account[] accs = new Account[]{};
    for(Id aId : accountIds) {
      accs.add(new Account(
        Id = aId,
        OwnerId = UserInfo.getUserId(),
        Presentatore__c = UserInfo.getUserId()
      ));
    }

    update accs;*/
  }

  /*************************************************
  * Metodi privati di appoggio
  *************************************************/

  /**
  * Metodo che controlla che ci siano tutte le date di ricontatto quando servono
  */
  private static void controllaDataRicontatto(SObject[] lista) {
    for(SObject dp: lista) {
      if(dp.get('DataRicontatto__c') == null) dp.addError(Label.ERR_esitoTaskRecall);
    }
  }


  /**
  * Metodo che blocca l'esitazione se il task è di filo diretto ed è una visita (necessita dunque di creazione evento)
  **/
  @TestVisible
  private static void bloccaEsitoSeFiloDiretto(SObject[] lista) {
    for(SObject dp : lista) {
      if(dp.get('DiFiloDiretto__c') == true && dp.getSObjectType() == Task.SObjectType && !Funzionalita__c.getInstance().EditTaskFD__c) dp.addError(Label.ERR_esitoTaskFD);
    }
  }

  /**
  * Metodo che setta FuoriMagazzino a true per gli account id passati ( o per i task)
  **/
  public static void settaFuoriMagazzino(List<SObject> lista, Boolean fuori) {
    Set<Id> accsIds = U.getIdSet(lista, 'WhatId');
    settaFuoriMagazzino(accsIds, fuori);
  }

  public static void settaFuoriMagazzino(Set<Id> accsIds, Boolean fuori) {

    Account[] accs = new Account[]{};
    for(Id aId : accsIds) {
      accs.add(new Account(Id = aId, FuoriMagazzino__c = fuori));
    }

    update accs;
  }
  
  /**
   * ricopia il valore inserito nel commento nella descrizione
   **/
  public static void copiaCommentoSeFinance(T tu) {
	if (!CU.isFinance()) return;
      
    SObject[] tuList = tu.triggerNew;
    for(SObject activity : tuList) {
      if(activity.getSObjectType() == Task.SObjectType) {
        activity.put('Description', activity.get('CommentiEsito__c'));
      }
    }
  }  

}