/**
* Progetto:         Banca IFIS
* Descrizione:      Classe handler del trigger Account.trigger
* Sviluppata il:    14/09/2016
* Ampiamente modificata il: 31/01/2017
* Developer:        Zerbinati Francesco, Michele Triaca
*/

public without sharing class TrgAccount {
  public static Boolean disabilitaCreazioneCTDopoInsertAccount = false;
  public static Boolean abilitaControlloVariazione = false;
  // Filiali da assegnare al responsabile nel caso di gestione Mutuo MCC NSA: UserRole.DeveloperName => codice filiale
  private static Map<String, String> filialiResp = new Map<String, String>{
    'Milano' => '2',
    'Roma' => '4',
    'Napoli' => '6',
    'Torino1' => '20',
    'Salerno' => '24',
    'Vicenza' => '26'
  };

  /**
  * Metodo che aggiorna il settore e il dettaglio settore dato il codice ATECO
  **/
  public static void popolaSettoreDaATECO(T tu) {
    List<Account> updated = (List<Account>) tu.getChanged('Ateco__c', Funzionalita__c.getInstance().ForzaRicalcoloAteco__c);

    // seleziono informazioni di tutti gli ateco
    Set<String> atecoNames = U.getSet(updated, 'Ateco__c');
    Map<String,SObject> mappaAteco = U.keyBy([SELECT
      Cedacri__c,
      RAE__c,
      Descrizione__c,
      SettoreAttivita__c,
      Dettaglio__c,
      Mercato__c
      FROM Ateco__c
      WHERE Cedacri__c IN :atecoNames
    ], 'Cedacri__c');

    // per ogni account popolo le informazioni di ateco
    for(Account acc : updated) {
      if(mappaAteco.containsKey(acc.Ateco__c)) {
        Ateco__c temp = (Ateco__c) mappaAteco.get(acc.Ateco__c);
        acc.SettoreAttivita__c = temp.SettoreAttivita__c;
        acc.DettaglioSettore__c = temp.Dettaglio__c;
        acc.RAE__c = temp.RAE__c;
        acc.MercatoNew__c = temp.Mercato__c;
      } else {
        // nel caso non ci sia ateco ricercato sbianco i campi
        acc.Industry = '';
        acc.DettaglioSettore__c = '';
        if(!String.isEmpty(acc.Ateco__c)) {
          acc.Ateco__c = '0';
          //acc.addError('Codice ateco specificato non trovato');
        }
      }
    }
  }

  public static void trgAssociazioneInBaseCAP(T tu) {
    // Gestione mutuo MCC NSA
    if (Trigger.isInsert && Funzionalita__c.getInstance().GestioneMutuoMCCNSA__c) {
      TrgAccount.assegnazioneAnagraficaOperatoriNSA((Account[]) tu.triggerNew);
    } else if (Trigger.isUpdate) {
    // Assegnazioni anagrafiche TiAnticipo
      // filtro gli account registratisi nel tiAnticipo e quelli con Cessioni aperte
      Account[] accs = (Account[]) tu.getChanged(new String[] {
        'BillingPostalCode',
        'ShippingPostalCode',
        'BillingCity',
        'ShippingCity',
        'BillingState',
        'ShippingState'
      });
      if (accs.isEmpty()) return;
      Account[] filteredAccs = new Account[]{};
      for (Account acc : (Account[]) tu.triggerNew) {
        if ((!tu.isChanged(acc, 'ClienteTiAnticipoGiaPresente__c') && acc.ClienteTiAnticipoGiaPresente__c) || acc.ClienteTiAnticipo__c ) {
          filteredAccs.add(acc);
        }
      }
      if (filteredAccs.isEmpty()) return;
      // Assegno il titolare factoring in base CAP, e operatore Filo Diretto
      Set<String> caps = U.getSet(filteredAccs, 'ShippingPostalCode');
      caps.addAll(U.getSet(filteredAccs, 'BillingPostalCode'));
      Set<String> comuni = U.getSet(filteredAccs, 'ShippingCity');
      comuni.addAll(U.getSet(filteredAccs, 'BillingCity'));
      Set<String> provincie = U.getSet(filteredAccs, 'ShippingState');
      provincie.addAll(U.getSet(filteredAccs, 'BillingState'));
      Map<String, Id> cap2owner = UtilAnagrafiche.getOwners(caps, comuni, provincie, false);
      ParametriTiAnticipo__c parametriTA = ParametriTiAnticipo__c.getInstance();
      UtenzeDefault__c utenzeDefault = UtenzeDefault__c.getInstance();
      for (Account a : filteredAccs) {
        Id ownerId = null;
        // Considero i campi nell'array "fields" nell'ordine in cui sono inseriti: al primo match prendo l'owner
        String[] fields = new String[]{'BillingPostalCode_BillingCity', 'ShippingPostalCode_ShippingCity','BillingPostalCode', 'ShippingPostalCode', 'BillingCity', 'ShippingCity', 'BillingState', 'ShippingState'};
        for (String field : fields) {
          if (String.isBlank(field)) continue;
          String[] fieldList = field.split('_');
          String[] valueList = new String[]{};
          Boolean isOk = true;
          for (String f : fieldList) {
            String fValue = (String) a.get(f);
            if (String.isBlank(fValue)) {
              isOk = false;
            } else {
              valueList.add(fValue);
            }
          }
          String value = String.join(valueList, '_');
          if (isOk && cap2owner.containsKey(value)) {
            String ownerValue = cap2owner.get(value);
            if (String.isNotBlank(ownerValue)) {
              ownerId = ownerValue;
              break;
            }
          }
        }
        if (String.isNotBlank(ownerId) &&
          (a.ClienteTiAnticipo__c || a.OwnerId == utenzeDefault.IdUtente__c || a.OwnerId == parametriTA.IDTitolareFactoring__c)) {
          a.OwnerId = ownerId;
        }
        if (String.isBlank(a.OpFiloDiretto__c)) {
          a.OpFiloDiretto__c = parametriTA.IDOperatoreFiloDiretto__c;
        }
      }
      // Assegno il Gestore Cliente in base alla filiale del titolare factoring
      Set<Id> owners = U.getIdSet(filteredAccs, 'OwnerId');
      Map<Id, User> users = new Map<Id, User>([SELECT Id,
        UserRole.Name
        FROM User
        WHERE Id IN :owners
      ]);
      Map<String, AnagrafeConsulenti__c[]> gestoreClienteByFiliale = (Map<String, AnagrafeConsulenti__c[]>) U.groupBy([
        SELECT NDGGruppo__c,
        FilialeGestoreClienteTA__c
        FROM AnagrafeConsulenti__c
      ], 'FilialeGestoreClienteTA__c');
      Set<String> gestoreClienteFiliali = gestoreClienteByFiliale.keySet();

      for (Account a : filteredAccs) {
        if (users.containsKey(a.OwnerId) && (String.isBlank(a.GestoreCliente__c) || a.ClienteTiAnticipo__c)) {
          String nomeRuolo = users.get(a.OwnerId).UserRole.Name;
          if (String.isNotBlank(nomeRuolo)) {
            String[] lista = nomeRuolo.split(' ');
              do {
                nomeRuolo = String.join(lista, ' ');
                if (!nomeRuolo.isNumeric()) {
                  if (gestoreClienteFiliali.contains(nomeRuolo)) {
                    a.GestoreCliente__c = gestoreClienteByFiliale.get(nomeRuolo)[0].NDGGruppo__c;
                    break;
                  }
                }
              lista.remove(0);
            } while (lista.size() > 0);
          }
        }
      }
    }
  }

  /**
   * ID 216: gestione mutuo MCC NSA
   * - Assegnazione anagrafica:
   *   - filiale < su base CAP
   *   - titolare factoring < su base CAP oppure (se filiale in "filialiDaAssegnareAlResponsabile") è il responsabile filiale
   *   - opFiloDiretto < su base CAP
   * - CanaleSviluppo < 'broker'
   * - Sottocanale < 'NSA'
   *
   * @return Accounts aggiornati o null, nel caso non sia necessaria alcuna modifica
   */
  public static Account[] assegnazioneAnagraficaOperatoriNSA(Account[] accs) {

    Boolean isInBaseCAP = Funzionalita__c.getInstance().GestioneMutuoMCCNSA__c;
    if (!isInBaseCAP) return null;
    //le associazioni non vanno effettuate per account con Controparte = Cedente oppure Cedente Debitore
    accs = U.filter(accs,'Controparte__c',new Set<String>{'Cedente','Cedente Debitore'},false);
    if (!accs.isEmpty()) {
      Set<String> caps = U.getSet(accs, 'ShippingPostalCode');
      Set<String> comuni = U.getSet(accs, 'ShippingCity');
      Set<String> provincie = U.getSet(accs, 'ShippingState');
      Map<String, Id> cap2owner = UtilAnagrafiche.getOwners(caps, comuni, provincie, false);
      Id utenzaDefault = UtenzeDefault__c.getInstance().IdUtente__c;
      for(Account a : accs) {
        a.CanaleSviluppo__c = '1'; // Broker
        a.Sottocanale__c = '998'; // NSA
        // Gestione owner 1/2: assegno l'anagrafica in base CAP
        Id ownerId = null;
        // Considero i campi nell'array "fields" nell'ordine in cui sono inseriti: al primo match prendo l'owner
        String[] fields = new String[]{'BillingPostalCode_BillingCity', 'ShippingPostalCode_ShippingCity','BillingPostalCode', 'ShippingPostalCode', 'BillingCity', 'ShippingCity', 'BillingState', 'ShippingState'};
        for (String field : fields) {
          if (String.isBlank(field)) continue;
          String[] fieldList = field.split('_');
          String[] valueList = new String[]{};
          Boolean isOk = true;
          for (String f : fieldList) {
            String fValue = (String) a.get(f);
            if (String.isBlank(fValue)) {
              isOk = false;
            } else {
              valueList.add(fValue);
            }
          }
          String value = String.join(valueList, '_');
          if (isOk && cap2owner.containsKey(value)) {
            String ownerValue = cap2owner.get(value);
            if (String.isNotBlank(ownerValue)) {
              ownerId = ownerValue;
              break;
            }
          }
        }
        a.OwnerId = (String.isNotBlank(ownerId)) ? ownerId : utenzaDefault;
      }

      // Gestione owner 2/2: se il CAP è nel set "filialiDaAssegnareAlResponsabile" assegno l'anagrafica al responsabile filiale
      Set<Id> owners = U.getIdSet(accs, 'OwnerId');
      Map<Id, User> users = new Map<Id, User>([SELECT Id,
        Filiale__c,
        UserRole.DeveloperName
        FROM User
        WHERE Id IN :owners
        OR (
          IsActive = true
          AND UserRole.DeveloperName LIKE 'ResponsabileFiliale%'
        )
      ]);
      Map<String, Id> responsabiliFiliale = new Map<String, Id>();
      Set<String> codiciFilialiRespSet = U.toSet(filialiResp.values());
      for (User utente : users.values()) {
        String codiceFilialeUtente = utente.Filiale__c;
        if (codiciFilialiRespSet.contains(codiceFilialeUtente) && utente.UserRole.DeveloperName.containsIgnoreCase('ResponsabileFiliale')) {
          responsabiliFiliale.put(codiceFilialeUtente, utente.Id);
        }
        if (codiceFilialeUtente == 'Multipla') {
          for (String filiale : U.toList(filialiResp.keySet())) {
            if (utente.UserRole.DeveloperName.contains(filiale) && utente.UserRole.DeveloperName.containsIgnoreCase('ResponsabileFiliale')) {
              responsabiliFiliale.put(filiale, utente.Id);
            }
          }
        }
      }

      for (Account a : accs) {
        String codiceFilialeUtente = users.get(a.OwnerId).Filiale__c;
        if (codiciFilialiRespSet.contains(codiceFilialeUtente)) {
          a.OwnerId = responsabiliFiliale.get(codiceFilialeUtente);
        }
      }
      return accs;
    }
    return null;
  }

  /**
  * Metodo che prepara l'approval process una volta che il campo StatoAssegnazione__c è settato a "Richiedi approvazione"
  **/
  // TEN SV - LOGGICA RICHIESTA ASSEGNAZIONE GESTITA DA FLOWs
  // public static void preparaProcessoAssegnazione(T tu) {


  //   // lista account su cui lavorare
  //   Account[] accs = tu
  //     .filter('StatoAssegnazione__c', 'Richiesta')
  //     .getChanged('StatoAssegnazione__c');
  //   if (accs == null || accs.isEmpty()) return;

  //   System.debug('Trigger richiesta processo assegnazione avviato');

  //   // lista utenti richiedenti, proprietari e commercialiFinanzaStrutturata (per recuperare i manager)
  //   Set<Id> idUsers = U.getIdSet(accs, 'Richiedente__c');
  //   idUsers.addAll(U.getIdSet(accs, 'OwnerId'));
  //   idUsers.addAll(U.getIdSet(accs, 'CommercialeFinanzaStrutturata__c'));

  //   Map<Id, User> manUsers = new Map<Id, User>([
  //     SELECT Id, ManagerId
  //     FROM User
  //     WHERE (Id IN :idUsers OR Id = :UserInfo.getUserId())
  //   ]);

  //   for (Account acc : accs) {
  //     // controllo che richiedente__c sia nullo e che richiedente e owner siano diversi (altrimenti non ha senso)
  //     if(acc.Richiedente__c == null) acc.Richiedente__c = UserInfo.getUserId();
  //     Id m1 = manUsers.get(acc.Richiedente__c).ManagerId;

  //     // setto l'approvatore..
  //     if (CU.isFinance(acc.Richiedente__c) || CU.isLeasing(acc.Richiedente__c) || CU.isLending(acc.Richiedente__c) || CU.isFinanzaStrutturata(acc.Richiedente__c) || CU.isFastFinance(acc.Richiedente__c)) {
  //       acc.Approvatore__c = m1;
  //     } else {
  //       Id m2 = manUsers.get(acc.OwnerId).ManagerId;

  //       // di default l'approvatore è il manager dell'attuale owner
  //       acc.Approvatore__c = m2;

  //       // se i manager di richiedente e approvatore sono diversi oppure sono vuoti, vado su quello di default
  //       if(m1 == null || m2 == null || m1 != m2) acc.Approvatore__c = UtenzeDefault__c.getInstance().IdUtenteDefaultS__c;

  //       // se il proprietario è il manager
  //       if(m1 == acc.OwnerId) acc.Approvatore__c = m1;
  //     }

  //     // ..e nel caso in cui l'account sia già assegnato a un commerciale Finanza Strutturata setto l'approvatore FinStrut
  //     if (acc.CommercialeFinanzaStrutturata__c != null && manUsers.get(acc.CommercialeFinanzaStrutturata__c).ManagerId != manUsers.get(acc.Richiedente__c).ManagerId) {
  //       acc.ApprovatoreFinStrut__c = manUsers.get(acc.CommercialeFinanzaStrutturata__c).ManagerId;
  //     }
  //   }
  // }

  /**
   * Metodo che avvia l'approval process (va fatto in after)
   */
  // TEN SV - LOGGICA RICHIESTA ASSEGNAZIONE GESTITA DA FLOWs
  // public static void avviaProcessoAssegnazione(T tu) {
  //   Account[] accs = tu
  //     .filter('StatoAssegnazione__c', 'Richiesta')
  //     .getChanged('StatoAssegnazione__c');
  //   if (accs == null || accs.isEmpty()) return;

  //   // solo se c'è qualcuno che necessita procedo
  //   Approval.ProcessSubmitRequest[] requests = new Approval.ProcessSubmitRequest[]{};
  //   for(Account a : accs) {
  //     System.debug('Richiesta assegnazione per anagrafica '+a.Id+' presa in carico');

  //     // crea approval request
  //     Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
  //     req.setComments(Label.RichiestaApprovazioneAssegazioneAccount);
  //     req.setObjectId(a.Id);

  //     // invio per conto del richiedente
  //     req.setSubmitterId(a.Richiedente__c);

  //     // setto nome dell'approval process e chiedo di skippare i criteri di entrata
  //     if (a.ApprovatoreFinStrut__c != null) req.setProcessDefinitionNameOrId('RichiesteDiAssegnazioneFinStrut');
  //     else req.setProcessDefinitionNameOrId('RichiesteDiAssegnazione');
  //     req.setSkipEntryCriteria(true);

  //     requests.add(req);

  //   }
  //   // invio l'approval process
  //   Approval.ProcessResult[] result = new Approval.ProcessResult[]{};
  //   result = Approval.process(requests);

  //   // Sblocco tutti i record. Questo tipo di approval process non richiede un lock
  //   Approval.unlock(U.toIdList(U.getIdSet(accs, 'Id')));

  //   // nella maggior parte dei casi la richiesta di assegnazione sarà solo 1 - se massivo questo non scatta
  //   // il post su chatter consuma 1 dml
  //   if(requests.size() == 1) {
  //     String msg = Impostazioni__c.getInstance().MessaggioRichiestaAssegnazione__c;
  //     if (msg != null && CU.isFactoring(accs[0].Richiedente__c)) ChatterUtils.postToChatter(accs[0].Id, accs[0].OwnerId, msg);
  //     else System.debug('Devi impostare il messaggio di richiesta assegnazione nei CS');
  //   }
  // }

  /**
   * Metodo che resetta la picklist "StatoAssegnazione" in modo che pulisca il campo e il richiedente.
   **/
  // TEN SV - LOGGICA RICHIESTA ASSEGNAZIONE GESTITA DA FLOWs
  // public static void resettaStatoAssegnazione(T tu) {
  //   Account[] accsDiCuiCreareCt = new Account[]{};
  //   Account[] accs = (Account[]) tu.filterByOld('StatoAssegnazione__c', 'Richiesta').getChanged('StatoAssegnazione__c');
  //   Map<String, SObject> commercialeTipoPerUtente = (Map<String, SObject>) U.keyBy([SELECT Id, RuoloLeasing__c FROM User WHERE Id IN :U.getSet(accs, 'Richiedente__c')], 'Id');

  //   for(Account a : accs) {
  //     if (a.StatoAssegnazione__c == 'Approvata') {
  //       if (CU.isLeasing(a.Richiedente__c)) {
  //         if (commercialeTipoPerUtente.get(a.Richiedente__c).get('RuoloLeasing__c') == 'CommercialeEF') a.CommercialeEF__c = a.Richiedente__c;
  //         if (commercialeTipoPerUtente.get(a.Richiedente__c).get('RuoloLeasing__c') == 'CommercialeTR') a.CommercialeTR__c = a.Richiedente__c;
  //       }
  //       else if (CU.isFinance(a.Richiedente__c)) a.CommercialeFinance__c = a.Richiedente__c;
  //       else if (CU.isLending(a.Richiedente__c)) a.CommercialeLending__c = a.Richiedente__c;
  //       else if (CU.isFastFinance(a.Richiedente__c)) a.CommercialeFastFinance__c = a.Richiedente__c;
  //       else if (CU.isFinanzaStrutturata(a.Richiedente__c)) a.CommercialeFinanzaStrutturata__c = a.Richiedente__c;
  //       else {
  //         a.OwnerId = a.Richiedente__c;
  //         if (String.isBlank(a.Presentatore__c)) a.Presentatore__c = a.Richiedente__c;
  //         accsDiCuiCreareCt.add(a);
  //       }
  //     }
  //     // resetto il campo picklist e il campo richiedente
  //     a.StatoAssegnazione__c = null;
  //     a.Richiedente__c = null;
  //     a.Approvatore__c = null;
  //     a.ApprovatoreFinStrut__c = null;
  //   }

  //   if(!accsDiCuiCreareCt.isEmpty()) {
  //     TrgAccount.creaContattoTelefonico(new T(accsDiCuiCreareCt, tu.oldMap));
  //   }
  // }

  /**
   * Metodo che setta presentatore/operatore su un account
   * L'owner dell'account diventa presentatore se tutte le seguenti condizioni sono soddisfatte:
   * 1. L'owner è un commerciale oppure gestore debitori
   * 2. (Non c'è già un presentatore) oppure (è cambiato l'owner e il vecchio presentatore non è un gestione debitori/international)
   * Inoltre, nel caso in cui l'owner sia filo diretto, diventa "operatore filo diretto" dell'account.
   **/
  public static void settaProprieta(T tu) {
    Boolean isUpdate = tu.mode == T.TMode.xUPDATE;
    Set<Id> ownerIds = U.getIdSet(tu.triggerNew, 'OwnerId');
    if(isUpdate) ownerIds.addAll(U.getIdSet(tu.oldMap.values(), 'Presentatore__c'));
    CU.addToCache(ownerIds);

    for(Account a : (Account[]) tu.triggerNew) {
      if (CU.isCommerciale(a.OwnerId) || CU.isGestoreDebitori(a.OwnerId)) {
        Boolean oldPresentatoreIsGestioneDebitori = isUpdate && CU.isGestoreDebitori((String) tu.oldMap.get(a.Id).get('Presentatore__c'));
        Boolean oldPresentatoreIsInternational = isUpdate && CU.isInternational((String) tu.oldMap.get(a.Id).get('Presentatore__c'));
        if(String.isBlank(a.Presentatore__c) || (tu.isChanged(a, 'OwnerId') && !(oldPresentatoreIsGestioneDebitori || oldPresentatoreIsInternational))) {
          a.Presentatore__c = a.OwnerId;
        }
      }

      if(CU.isFiloDiretto(a.OwnerId) && !(a.ClienteTiAnticipoGiaPresente__c || a.ClienteTiAnticipo__c)) {
        a.OpFiloDiretto__c = a.OwnerId;
      }
    }
  }

  /**
   * Metodo che inserisce, alla creazione di un'account, un contatto telefonico assegnato all'owner dell'account. Questo
   * va fatto solo nel caso in cui il cliente non abbia provenienza web/numero verde (sottocanale = 101).
   * In quel caso infatti il task è creato in automatico dalla console filo diretto.
   * Nel caso di gestori mutuo MCC NSA  il contatto non viene creato
  **/
  public static void creaContattoTelefonico(T tu) {
    if (Funzionalita__c.getInstance().GestioneMutuoMCCNSA__c) return;
    Set<Id> accIds = U.getIdSet(tu.triggerNew, 'Id');
    Set<Id> ownerIds = U.getIdSet(tu.triggerNew, 'OwnerId');
    CU.addToCache(ownerIds);

    Map<Id, Contact> accId2contact = UtilAnagrafiche.getReferenteCampagna(accIds);

    Task[] nuovi = new Task[]{};
    for(Account a : (Account[]) tu.filter('Sottocanale__c', '101', false).triggerNew) {
      if(CU.isCommerciale(a.OwnerId) || CU.isFiloDiretto(a.OwnerId)) {
        nuovi.add(new Task(
          WhatId = a.Id,
          WhoId = accId2contact.containsKey(a.Id) ? accId2contact.get(a.Id).Id : null,
          OwnerId = a.OwnerId,
          Status = 'Aperto',
          Subject = 'Contatto telefonico',
          ActivityDate = Date.today(),
          RecordTypeId = U.getRecordTypes('Task').get('ContattoTelefonicoDiretto').Id
        ));
      }
    }

    insert nuovi;
  }

  /**
   * Metodo che stabilisce le priorità di sviluppo diretto e indiretto
   */
  public static void stabilisciPriorita(T tu) {

    // sviluppo diretto, rating controparte: rating t0 cedente
    Account[] acc = (List<Account>) tu.getChanged(new String[]{'RatingT0__c','DimensioneDelBusiness__c'});
    if (acc == null || acc.isEmpty()) return;

    // matrice sviluppo
    Map<String, SObject> md = U.keyBy([SELECT
          Label,
          PrioritaSmall__c,
          PrioritaMedium__c,
          PrioritaLarge__c,
          Tipo__c
          FROM MatriceSviluppo__mdt
    ],'{Tipo__c}_{Label}', true);

    System.debug('Set account per stabilire priorità: '+acc);

    for(Account a : acc) {
      if(a.RatingT0__c != null && a.DimensioneDelBusiness__c != null) {
        // a seconda della dimensione del business aggiusto le priorità diretto/indiretto
        MatriceSviluppo__mdt mdDir = (MatriceSviluppo__mdt) md.get('Diretto'+ '_' + a.RatingT0__c);
        MatriceSviluppo__mdt mdIndir = (MatriceSviluppo__mdt) md.get('Indiretto'+ '_' + a.RatingT0__c);
        System.debug('diretto:'+ a.RatingT0__c+ '_' + 'Diretto');
        System.debug('indiretto:'+ mdIndir);
        // le due matrici devono esistere
        if(mdDir != null && mdIndir != null) {
          if(a.DimensioneDelBusiness__c < 10000000) {
            a.PrioritaSviluppoDiretto__c = mdDir.PrioritaSmall__c;
            a.PrioritaSviluppoIndiretto__c = mdIndir.PrioritaSmall__c;
          }
          else if(a.DimensioneDelBusiness__c > 50000000) {
            a.PrioritaSviluppoDiretto__c = mdDir.PrioritaLarge__c;
            a.PrioritaSviluppoIndiretto__c = mdIndir.PrioritaLarge__c;
          }
          else {
            a.PrioritaSviluppoDiretto__c = mdDir.PrioritaMedium__c;
            a.PrioritaSviluppoIndiretto__c = mdIndir.PrioritaMedium__c;
          }
        }
      }
    }

  }


  /**
   * Metodo che crea un ref. standard alla creazione di un account
   */
  public static void creaReferenteStandard(T tu) {
	//questo metodo viene eseguito 1 sola volta tramite trigger afterInsert
	//in questo frangente abbiamo il campo popolato dai dati della form web oppure inseriti da Lightning oppure che arrivano da infoprovider
	//per cui dobbiamo controllare sia il campo phone che i campi spezzati
	//può capitare che i dettagli infoprovider non hanno il telefono ma la form sì, in questo caso sembra un errore...
    Account[] accs = tu.triggerNew;
    Contact[] conts = new List<Contact>();

    for(Account a  : accs) {        
      Contact c = new Contact(
        FirstName = 'Centralino',
        LastName = a.Name.abbreviate(25),
        AccountId = a.Id,
        OwnerId = a.OwnerId,
        IsReferenteCampagna__c = true,
        //adione SDHDFNZ-81466 salviamo il numero nel nuovo campo, poi il trigger lo riporta sul campo phone
        //altrimenti il trigger lo andrebbe a sbiancare in creazione
        TelefonoNumero__c = (String.isNotBlank(a.Phone)) ? a.Phone : a.TelefonoNumero__c,
        TelefonoPrefisso__c =  (String.isNotBlank(a.Phone)) ? '' : a.TelefonoPrefisso__c,
        //adione SDHDFNZ-77918 il num. inserito nella web-form va mantenuto
        OtherPhone =  (String.isNotBlank(a.Phone)) ? a.Phone : a.TelefonoNumero__c,
        Email = a.Email__c
      );
      conts.add(c);

    }
    insert conts;
  }

  //A.M. -> CR342 Start
  //Gestione Phone come campo concatenato di prefisso e numero (Before Insert e Update)
    public static void AggiornaTelefono(T tu) {
      Account[] accsChangedTel = new List<Account> ((Account[]) tu.getChanged(new String[]{'TelefonoPrefisso__c', 'TelefonoNumero__c', 'TelefonoSecPrefisso__c', 'TelefonoSecNumero__c'}));
      if(accsChangedTel.isEmpty()) return;    
       
      for(Account a : accsChangedTel){
        If (a.TelefonoPrefisso__c == null) {
            a.TelefonoPrefisso__c = ' ';
        } 
        If (a.TelefonoNumero__c == null) {
              a.TelefonoNumero__c = ' ';
        }
        a.Phone = a.TelefonoPrefisso__c + a.TelefonoNumero__c;
          
        If (a.TelefonoSecPrefisso__c == null) {
            a.TelefonoSecPrefisso__c = ' ';
        } 
        If (a.TelefonoSecNumero__c == null) {
              a.TelefonoSecNumero__c = ' ';
        }
        a.TelefonoSec__c = a.TelefonoSecPrefisso__c + a.TelefonoSecNumero__c;
      }
    }
  //A.M. -> End     
     
    
  public static void allineaReferenteCampagna(T tu) {
    //A.M. -> Modifica per evitare allineamento tra Account e "Centralino" in quanto FD aggiorna i campi su quest'ultimo mentre l'account, essendo collegato a Cedacri e soggetto ad
    //        allineamento notturno e quindi sovrascrittura dei dati di contatto salvati sul Referente "Centralino" 
    //        Aggiunta anche la verifica che effettivamente si tratti di "Cenralino" prima di sovrascrivere il cognome (potrebbero esserci casi di Referenti Campagna <> "Centralino") 
    //Map<Id, Account> accsChangedName = new Map<Id, Account>((Account[]) tu.getChanged(new String[]{'Name', 'Phone', 'Email__c'}));
    Map<Id, Account> accsChangedName = new Map<Id, Account>((Account[]) tu.getChanged(new String[]{'Name'}));
    if(accsChangedName.isEmpty()) return;

    Contact[] cL = [SELECT
      Id,
      FirstName,
      LastName,
      Phone,
      Email,
      AccountId
      FROM Contact
      WHERE AccountId IN :accsChangedName.keySet()
      AND IsReferenteCampagna__c = TRUE
    ];

    for(Contact c : cL) {
      if (c.FirstName == 'Centralino'){  
         Account a = accsChangedName.get(c.AccountId);
         c.LastName = a.Name.abbreviate(80);
         //c.Phone = a.Phone;
         //c.Email = a.Email__c;
      }
    }

    update cL;
  }

  /**
  * Quando si crea un nuovo prospect o cambia il titolare deve aggiornare/sovrascivere
  * il campo Account.Filiale__c con il campo Account.Owner.Filiale__c
  * Questo non vale nel momento in cui viene inserito un nuovo Account da portale TiAnticipo
  * Se sei commerciale e non hai filiale (vuol dire che se assegnato a più di una Filiale)
  * allora non copia niente sull account e crea un promemoria per quel account assegnato al nuovo owner con
  * subject= "Attribuire Filiale - Account.Name", data oggi, stato aperto.
  */
  public static void cambiaFiliale(T tu) {
    // seleziono i nuovi oppure cambio owner
    Account[] accs = tu.getChanged('OwnerId');
    Account[] filteredAccs = new Account[]{};
    for(Account a : accs) {
      if(CU.isCommerciale(a.OwnerId) && (tu.mode == T.TMode.xUPDATE) || a.RecordTypeId == U.getRecordTypes('Account').get('Prospect').Id) {
        if (!(Trigger.isInsert && a.ClienteTiAnticipo__c)) {
          filteredAccs.add(a);
        }
      }
    }

    if(filteredAccs.isEmpty()) return;
    List<Task> attribuzioni = new List<Task>();
    Set<Id> ownerSet = U.getIdSet(filteredAccs, 'OwnerId');
    CU.addToCache(ownerSet);

    Map<Id,User> owners = new Map<Id,User>([SELECT Id, Filiale__c FROM User WHERE Id IN :ownerSet]);
    List<Account> nuoviAccount = new List<Account>();
    Set<String> accountCaps = U.getSet(filteredAccs, 'BillingPostalCode');
    Map<String, SObject> capFiliale = U.keyBy([SELECT Id, CAP__c, Filiale__c FROM AssegnazioneAnagrafica__c WHERE CAP__c in :accountCaps], 'CAP__c');


    for(Account a : filteredAccs) {
      Account n = new Account(Id = a.Id);

      if (CU.isFiloDiretto(a.OwnerId)){
        if(capFiliale.containsKey(a.BillingPostalCode))
          n.Filiale__c = (String) capFiliale.get(a.BillingPostalCode).get('Filiale__c');
        else
          n.Filiale__c = null;
      }
      else if(owners.get(a.OwnerId).Filiale__c != 'Multipla') {
        n.Filiale__c = owners.get(a.OwnerId).Filiale__c;
      } else {
        // ho più filiali
        n.Filiale__c = null;
        Task t = new Task(
          Subject = 'Attribuire Filiale - ' + a.Name, OwnerId = a.OwnerId,
          ActivityDate = Date.today(),
          Status = 'Aperto',
          WhatId = a.Id,
          RecordTypeId = U.getRecordTypes('Task').get('Promemoria').Id
        );
        attribuzioni.add(t);
      }
      nuoviAccount.add(n);
    }

    insert attribuzioni;
    update nuoviAccount;
  }

  /**
   * Metodo che cambia owner alle open activities se cambia l'owner dell'account proprietario
   */
  public static void cambiaOwnerAttivita(T tu) {
    trgActivity.contestoTrgAccountCambiaOwnerAttivita = true;
    Account[] accs = tu.getChanged('OwnerId');
    if(accs.isEmpty()) return;

    Map<Id, Account> newMap = new Map<Id, Account>(accs);
    Map<Id, Account> oldAccs = (Map<Id, Account>) tu.oldMap;

    //Costruisco filtro per la selezione dei task/eventi modificati
    String[] filters = new String[]{};
    String[] fields = new String[]{'Id', 'OwnerId', 'AccountId', 'WhatId'};
    QueryBuilder.FilterBuilder qb1 = QueryBuilder.newInstance('Task', fields).beginFilter().add('IsClosed', QBOp.QEQUAL, false);
    QueryBuilder.FilterBuilder qb2 = QueryBuilder.newInstance('Event', fields).beginFilter().addUntyped('EsitoLivello1__c = NULL');

    for(Account a : accs) {
      qb1.beginAnd()
        .add('OwnerId', QBOp.QEQUAL, oldAccs.get(a.Id).OwnerId)
        .beginOr()
          .add('AccountId', QBOp.QEQUAL, a.Id)
          .add('WhatId', QBOp.QEQUAL, a.Id)
        .end()
      .end();

      qb2.beginAnd()
        .add('OwnerId', QBOp.QEQUAL, oldAccs.get(a.Id).OwnerId)
        .beginOr()
          .add('AccountId', QBOp.QEQUAL, a.Id)
          .add('WhatId', QBOp.QEQUAL, a.Id)
        .end()
      .end();
    }

    String q1 = qb1.endFilter().getQuery();
    String q2 = qb2.endFilter().getQuery();
    System.debug('Q1! ' + q1);
    System.debug('Q2! ' + q2);

    Task[] tasks = (Task[]) Database.query(q1);
    for(Task t : tasks) {
      Id accId = t.AccountId != null ? t.AccountId : t.WhatId;
      t.OwnerId = newMap.get(accId).OwnerId;
    }

    Event[] events = (Event[]) Database.query(q2);
    for(Event e : events) {
      Id accId = e.AccountId != null ? e.AccountId : e.WhatId;
      e.OwnerId = newMap.get(accId).OwnerId;
    }

    update tasks;
    update events;
    trgActivity.contestoTrgAccountCambiaOwnerAttivita = false;
  }

  /**
   *  Preimposta alcuni campi con dei default e risolve alcune strane anomalie dei ws
   *  Quando: before insert, before update
   *  Owner: Telnext
   *  Developer: Michele Triaca
   */
  public static void inizializzaDati(T tu) {
    // Se un'anagrafica assume canale sviluppo = web o indiretto, non deve più cambiarlo per nessuna ragione
    // (salvo le anagrafiche scese da web)
    final String CANALE_WEB = '5';
    final String CANALE_INDIRETTO = '4';
    Funzionalita__c f = Funzionalita__c.getInstance();

    if (!f.ForzaModificaCanaleSviluppo__c) {
      Account[] accsWithCanaleWeb = tu.filterByOld('CanaleSviluppo__c', new Set<String>{CANALE_WEB, CANALE_INDIRETTO}).getChanged('CanaleSviluppo__c');
      for (Account a : accsWithCanaleWeb) {
        // Le anagrafiche scese da web mantengono il canale sviluppo = web
        if (!tu.isChanged(a, 'DataUltimaImportazioneDaWeb__c')) a.CanaleSviluppo__c = (String) tu.getOldValue(a, 'CanaleSviluppo__c');
      }
    }

    // A.M. -> START Righe cancellate in quanto la filiale deve essere sempre di 3 cifre.  
    //Ogni tanto accountIN ritorna filiali uguali, ad esempio, a 00 o 06 invece di 0 o 6. In questi casi rimuovo lo 0 iniziale
    //for(Account a : (Account[]) tu.triggerNew) {
    //  if(String.isNotBlank(a.Filiale__c) && a.Filiale__c.length() > 1 && a.Filiale__c.startsWith('0')) {
    //    a.Filiale__c = Decimal.valueOf(a.Filiale__c).intValue() + '';
    //  }
    //}
    // A.M. -> END

    //Se un account è stato mai associato ad una sede != dalla sede centrale di Mestre, non va più reimpostata sede di mestre
    Account[] accsWithFilialeDefault = (Account[]) tu.filter('Filiale__c', '0').filterByOld('Filiale__c', (String) null, false).triggerNew;
    for(Account a : accsWithFilialeDefault) {
      a.Filiale__c = (String) tu.getOldValue(a, 'Filiale__c');
    }

    // Se sottocanale = 'Skype, Wapp, Chat, twitter, nverde, radio, fb' popolo DataUltimaImportazioneWeb col timestamp corrente
    Set<String> valoriSottoCanale = new Set<String>{'101', '102', '103', '104', '105', '106', '999'};
    for (Account a : (Account[]) tu.filter('SottoCanale__c', valoriSottoCanale).getChanged('SottoCanale__c')) {
      a.DataUltimaImportazioneDaWeb__c = Datetime.now();
      if (a.DataPrimaImportazioneDaWeb__c == null) a.DataPrimaImportazioneDaWeb__c = a.DataUltimaImportazioneDaWeb__c;
    }

    //Se viene passata una data ultima importazione da web e la data prima importazione da web è vuota, la inizializzo
    for(Account a : (Account[]) tu.filter('DataPrimaImportazioneDaWeb__c', (Datetime) null).getChanged('DataUltimaImportazioneDaWeb__c')) {
      a.DataPrimaImportazioneDaWeb__c = a.DataUltimaImportazioneDaWeb__c;
    }

   /*
    * Aggiorno le chiavi univoche e i campi a supporto dell'oggetto Account:
    * PIVACF__c <------------ popolato con:
    *                         se PIVA != CF:      concatenazione di "PIVA__c" "_" e "CF__c"
    *                         se PIVA == CF:      "PIVA__c"
    *                         se PIVA e CF vuote: null
    * CodiceIstituto3N__c <-- popolato tramite apposito campo nei custom setting, se vuoto
    * CI3N_PIVA_CF__c <------ popolato con la concatenazione di "CodiceIstituto3N__c" "-" e "PIVACF__c"
    * CI3N_NDGGruppo__c <---- popolato con la concatenazione di "CodiceIstituto3N__c" "-" e "NDGGruppo__c"
    */
    
    for (Account a : (Account[]) tu.triggerNew) {
      a.PIVACF__c = TrgAccount.getPIVACF(a.PIVA__c, a.CF__c);
      System.debug('SV CodiceIstituto3N__c: ' + a.get('CodiceIstituto3N__c'));
      System.debug('SV CodiceIstituto3N__c: ' + a.CodiceIstituto3N__c);
       a.CodiceIstituto3N__c = (String.isBlank((String)a.get('CodiceIstituto3N__c')) ? ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c : (String) a.get('CodiceIstituto3N__c'));
      // a.CodiceIstituto3N__c = (tu.oldMap == null || String.isBlank((String) tu.oldMap.get(a.Id).get('CodiceIstituto3N__c'))) ? ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c : (String) tu.oldMap.get(a.Id).get('CodiceIstituto3N__c');
      a.CI3N_PIVA_CF__c = TrgAccount.getCI3N_PIVA_CF(a.CodiceIstituto3N__c, a.PIVACF__c);
      if ((String.isNotBlank(a.NDGGruppo__c))) a.CI3N_NDGGruppo__c = TrgAccount.getCI3N_NDGGruppo(a.CodiceIstituto3N__c, a.NDGGruppo__c);
      
    }
  }

  public static String getPIVACF(Account a) {
    return getPIVACF(a.PIVA__c, a.CF__c);
  }

  public static String getCI3N_PIVA_CF(Account a) {
    return getCI3N_PIVA_CF(a.CodiceIstituto3N__c, a.PIVACF__c);
  }

  public static String getCI3N_NDGGruppo(Account a) {
    return getCI3N_NDGGruppo(a.CodiceIstituto3N__c, a.NDGGruppo__c);
  }

  public static String getPIVACF(String piva, String cf) {
      String[] pivacfTokens = new String[]{};
      if (String.isNotBlank(piva)) pivacfTokens.add(piva);
      if (String.isNotBlank(cf) && cf != piva) pivacfTokens.add(cf);
      return pivacfTokens.isEmpty() ? '' : String.join(pivacfTokens, '_');
  }

  public static String getCI3N_PIVA_CF(String codiceIstituto3N, String pivaCF) {
    if (String.isNotBlank(codiceIstituto3N) && String.isNotBlank(pivaCF)) return codiceIstituto3N + '-' + pivaCF;
    return null;
  }

  public static String getCI3N_NDGGruppo(String codiceIstituto3N, String ndgGruppo) {
    if (String.isNotBlank(codiceIstituto3N) && String.isNotBlank(ndgGruppo)) return codiceIstituto3N + '-' + ndgGruppo;
    return null;
  }

  public static void getCabComune(T tu) {
    Account[] accs = new Account[]{};
    Set<String> nomiComuni = new Set<String>();

    for(Account a : (Account[]) tu.triggerNew) {
      if(tu.isChanged(a, 'BillingCity') || (String.isNotBlank(a.BillingCity)) && String.isBlank(a.CabComune__c)) {
        accs.add(a);
        nomiComuni.add(a.BillingCity);
      }
    }

    Map<String, SObject> comuniMap = U.keyBy([SELECT Id, Name, CabCin__c FROM Comune__c WHERE Name IN :nomiComuni], 'Name');
    for(Account a : accs) {
      if(String.isNotBlank(a.BillingCity) && comuniMap.containsKey(a.BillingCity)) {
        a.CabComune__c = String.valueOf(comuniMap.get(a.BillingCity).get('CabCin__c'));
      } else {
        a.CabComune__c = null;
      }
    }
  }

  public static void ricalcolaIndirizzoCompleto(T tu) {
    for (Account a : (Account[]) tu.getChanged(new String[] {
      'BillingStreetName__c',
      'BillingStreetNumber__c',
      'BillingStreetType__c',
      'ShippingStreetName__c',
      'ShippingStreetNumber__c',
      'ShippingStreetType__c'
    })) {
      a.BillingStreet = UtilAnagrafiche.getIndirizzoCompleto(
        a.BillingStreetType__c,
        a.BillingStreetName__c,
        a.BillingStreetNumber__c
      );
      a.ShippingStreet = UtilAnagrafiche.getIndirizzoCompleto(
        a.ShippingStreetType__c,
        a.ShippingStreetName__c,
        a.ShippingStreetNumber__c
      );
    }
  }

  /**
   * Gestione degli utenti presenti nell'account team
   */
  public static void gestisciAccountTeam(T tu) {
      //per i nuovi clienti che si registrano da portale TiAnticipo
      //lo running user è un'utenza con licenza 'Guest User License'
      //che non ha accesso al account team member
      if ('tianticipo' == UserInfo.getFirstName()) {
          return;
      }
      
    //A.M. Ripristinato il TeamAccount: sostituiti ed ampliati i vecchi "commerciali" con attuale Team IFIS (per gestione reportistica) ma disabilitato post chatter
	//Account[] accs = (Account[]) tu.getChanged(new String[]{'OwnerId', 'CommercialeEF__c', 'CommercialeTR__c', 'CommercialeLending__c', 'CommercialeFinanzaStrutturata__c', 'CommercialeFastFinance__c', 'CommercialeFinance__c'});
	Account[] accs = (Account[]) tu.getChanged(new String[]{'WGC_Specialista_Factoring__c','WGC_Specialista_Filo_Diretto__c' , 'WGC_Specialista_Crediti_Erariali__c', 'WGC_Specialista_Leasing__c',  'WGC_Gestore_Debitore__c', 'Presentatore__c', 'WGC_Gestore_Cliente__c', 'WGC_Specialista_IFIS_Finance__c', 'WGC_Specialista_Finanza_Strutturata__c', 'WGC_Specialista_Pharma__c', 'WGC_Specialista_IFIS_International__c'});
    Boolean disabilitaPostChatterAccount = Funzionalita__c.getInstance().DisabilitaPostChatterAccount__c;
    Map<Id,User> utenti = new Map<Id,User>([SELECT Id, IsActive FROM User WHERE
        Id IN :U.getIdSet(accs, 'WGC_Specialista_Factoring__c') OR
        Id IN :U.getIdSet(accs, 'WGC_Specialista_Filo_Diretto__c') OR
        Id IN :U.getIdSet(accs, 'WGC_Specialista_Crediti_Erariali__c') OR
        Id IN :U.getIdSet(accs, 'WGC_Specialista_Leasing__c') OR
        Id IN :U.getIdSet(accs, 'WGC_Specialista_IFIS_Finance__c') OR
        Id IN :U.getIdSet(accs, 'WGC_Specialista_Finanza_Strutturata__c') OR
		Id IN :U.getIdSet(accs, 'WGC_Specialista_Pharma__c') OR
        Id IN :U.getIdSet(accs, 'WGC_Specialista_IFIS_International__c') OR
		Id IN :U.getIdSet(accs, 'WGC_Gestore_Cliente__c') OR
		Id IN :U.getIdSet(accs, 'WGC_Gestore_Debitore__c') OR
		Id IN :U.getIdSet(accs, 'Presentatore__c') ]);
    AccountTeamMember[] atmsExisting = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE AccountId in :U.getIdSet(accs, 'Id')];
    Map<String, AccountTeamMember[]> atmsExistingPerAccount = U.groupBy(atmsExisting, 'AccountId');

    AccountTeamMember[] atms = new AccountTeamMember[]{};
    ConnectApi.FeedItemInput[] feedItemInputs = new List<ConnectApi.FeedItemInput>();

    for (Account a : accs) {
      Set<Id> usersNew = new Set<Id>();
      if (a.WGC_Specialista_Factoring__c != null && utenti.containsKey(a.WGC_Specialista_Factoring__c) && utenti.get(a.WGC_Specialista_Factoring__c).IsActive) {
        atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.WGC_Specialista_Factoring__c, TeamMemberRole = 'ReferenteCreditiCommerciali'));
       	usersNew.add(a.WGC_Specialista_Factoring__c);
      }
      if (a.WGC_Specialista_Filo_Diretto__c != null && utenti.containsKey(a.WGC_Specialista_Filo_Diretto__c) && utenti.get(a.WGC_Specialista_Filo_Diretto__c).IsActive) {
        atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.WGC_Specialista_Filo_Diretto__c, TeamMemberRole = 'ReferenteFiloDirettoFactoring'));
        usersNew.add(a.WGC_Specialista_Filo_Diretto__c);
      }
      if (a.WGC_Specialista_Crediti_Erariali__c != null && utenti.containsKey(a.WGC_Specialista_Crediti_Erariali__c) && utenti.get(a.WGC_Specialista_Crediti_Erariali__c).IsActive) {
        atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.WGC_Specialista_Crediti_Erariali__c, TeamMemberRole = 'ReferenteCreditiErariali'));
        usersNew.add(a.WGC_Specialista_Crediti_Erariali__c);
      }
      if (a.WGC_Specialista_Leasing__c != null && utenti.containsKey(a.WGC_Specialista_Leasing__c) && utenti.get(a.WGC_Specialista_Leasing__c).IsActive) {
        atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.WGC_Specialista_Leasing__c, TeamMemberRole = 'ReferenteLeasing'));
        usersNew.add(a.WGC_Specialista_Leasing__c);
      }
      if (a.WGC_Specialista_IFIS_Finance__c != null && utenti.containsKey(a.WGC_Specialista_IFIS_Finance__c) && utenti.get(a.WGC_Specialista_IFIS_Finance__c).IsActive) {
        atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.WGC_Specialista_IFIS_Finance__c, TeamMemberRole = 'ReferenteIfisFinance'));
        usersNew.add(a.WGC_Specialista_IFIS_Finance__c);
      }
      if (a.WGC_Specialista_Finanza_Strutturata__c != null && utenti.containsKey(a.WGC_Specialista_Finanza_Strutturata__c) && utenti.get(a.WGC_Specialista_Finanza_Strutturata__c).IsActive) {
        atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.WGC_Specialista_Finanza_Strutturata__c, TeamMemberRole = 'ReferenteFinanzaStrutturata'));
        usersNew.add(a.WGC_Specialista_Finanza_Strutturata__c);
      }
      if (a.WGC_Specialista_Pharma__c != null && utenti.containsKey(a.WGC_Specialista_Pharma__c) && utenti.get(a.WGC_Specialista_Pharma__c).IsActive) {
        atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.WGC_Specialista_Pharma__c, TeamMemberRole = 'ReferentePharma'));
        usersNew.add(a.WGC_Specialista_Pharma__c);
      }
	  if (a.WGC_Specialista_IFIS_International__c != null && utenti.containsKey(a.WGC_Specialista_IFIS_International__c) && utenti.get(a.WGC_Specialista_IFIS_International__c).IsActive) {
        atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.WGC_Specialista_IFIS_International__c, TeamMemberRole = 'ReferenteIfisInternational'));
        usersNew.add(a.WGC_Specialista_IFIS_International__c);
      }
	  if (a.WGC_Gestore_Cliente__c != null && utenti.containsKey(a.WGC_Gestore_Cliente__c) && utenti.get(a.WGC_Gestore_Cliente__c).IsActive) {
        atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.WGC_Gestore_Cliente__c, TeamMemberRole = 'GestoreCliente'));
        usersNew.add(a.WGC_Gestore_Cliente__c);
      }
	  if (a.WGC_Gestore_Debitore__c != null && utenti.containsKey(a.WGC_Gestore_Debitore__c) && utenti.get(a.WGC_Gestore_Debitore__c).IsActive) {
        atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.WGC_Gestore_Debitore__c, TeamMemberRole = 'GestoreDebitore'));
        usersNew.add(a.WGC_Gestore_Debitore__c);
      }
	  if (a.Presentatore__c != null && utenti.containsKey(a.Presentatore__c) && utenti.get(a.Presentatore__c).IsActive) {
        atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.Presentatore__c, TeamMemberRole = 'Presentatore'));
        usersNew.add(a.Presentatore__c);
      }
      System.debug('@@@@ TEN - atmsExistingPerAccount: ' + atmsExistingPerAccount);
      // post su chatter per i nuovi entrati
      Set<Id> usersAlreadyInTeam = (atmsExistingPerAccount.containsKey(a.Id)) ? U.getIdSet(atmsExistingPerAccount.get(a.Id), 'UserId') : new Set<Id>{};
      //for (Id u : U.toIdList(usersNew)) {
      //  if (!usersAlreadyInTeam.contains(u) && !Test.isRunningTest() && !disabilitaPostChatterAccount) {
      //    feedItemInputs.add(ChatterUtils.createPostChatter(a.Id, u, Label.JoinTeamAccount.replace('%%', a.Name)));
      //  }
      //}			   
    }
    System.debug('@@@@ TEN - feedItemInputs: ' + feedItemInputs);
    //if (!feedItemInputs.isEmpty()) {
    //  try {System.debug('@@@@ TEN - start');
    //    ChatterUtils.postToChatterBatch(feedItemInputs);System.debug('@@@@ TEN - end');
    //  } catch (ConnectApi.ConnectApiException e) {}
    //}

    delete atmsExisting;
    insert atms;
  }

  public static void gestisciOwner(T tu) {
    Id utenzaDefault = UtenzeDefault__c.getInstance().IdUtente__c;
    gestisciOwner((Account[]) tu.getChanged('OwnerId'));
  }

  /**
   * Un utente Leasing, Lending o Finanza Strutturata non può essere owner di un Account,
   * in questo caso l'utente default diventa owner dell'Account.
   */
  public static Account[] gestisciOwner(Account[] accs) {
    Id utenzaDefault = UtenzeDefault__c.getInstance().IdUtente__c;
    for (Account a : accs) {
      if (CU.isLeasing(a.OwnerId)) {
        a.OwnerId = utenzaDefault;
      } else if (CU.isLending(a.OwnerId)) {
        a.CommercialeLending__c = a.OwnerId;
        a.OwnerId = utenzaDefault;
        a.StatoCommercialLending__c = 'Prospect';
      } else if (CU.isFinance(a.OwnerId)) {
        a.CommercialeFinance__c = a.OwnerId;
        a.OwnerId = utenzaDefault;
      } else if (CU.isFinanzaStrutturata(a.OwnerId)) {
        // in fase di inserimento Account, se proviene da Cedacri o Ribes non popolo il campo CommercialeFinanzaStrutturata__c
        if (!(a.Id == null && (a.Origine__c == WsAnagrafe.CEDACRI || a.Origine__c == WsRestRibes.RIBES)))
          a.CommercialeFinanzaStrutturata__c = a.OwnerId;
        a.OwnerId = utenzaDefault;
        a.StatoFinanzaStrutturata__c = 'Prospect';
      } else if (CU.isFastFinance(a.OwnerId)) {
        a.CommercialeFastFinance__c = a.OwnerId;
        a.OwnerId = utenzaDefault;
      }
    }
    return accs;
  }

  public static Account gestisciOwner(Account acc) {
    return gestisciOwner(new Account[]{acc})[0];
  }

  /**
   * Fast Finance: aggiorna il numero delle procedure aperte di una lista di Account
   */
  public static void calcolaProcedureAperte(Set<Id> accountIds) {
    if (accountIds == null || accountIds.isEmpty()) return;

    Map<Id, Integer> accountsMap = new Map<Id, Integer>();
    Account[] accounts = new Account[]{};

    // Calcolo il numero di procedure aperte di tribunali
    AggregateResult[] opps = [SELECT COUNT(Id) numero,
      Tribunale__c
      FROM Opportunity
      WHERE IsClosed = false
      GROUP BY Tribunale__c
      HAVING Tribunale__c IN :accountIds];

    for (AggregateResult opp : opps) {
      if (String.isNotBlank((String) opp.get('Tribunale__c')))
        accountsMap.put((String) opp.get('Tribunale__c'), (Integer) opp.get('numero'));
    }

    // Azzero il numero di procedure aperte per gli account non considerati prima
    for (Id accId : U.toIdList(accountIds)) {
      if (!accountsMap.containsKey(accId)) accountsMap.put(accId, 0);
    }

    // Aggiorno il DB
    for (Id accId : accountsMap.keySet()) {
      accounts.add(new Account(Id = accId, ProcedureAperte__c = accountsMap.get(accId)));
    }

    upsert accounts;
  }

  public static void cambiaNomeGestoreCliente(T tu){
    List<Account> updated = (List<Account>)tu.getChanged('GestoreCliente__c');
    if(updated.isEmpty()) return;
    for(Account a : updated){
      if(String.isNotBlank(a.GestoreCliente__c) && AnagrafeConsulenti__c.getValues(a.GestoreCliente__c) != null){
        a.GestoreClienteNome__c = AnagrafeConsulenti__c.getValues(a.GestoreCliente__c).Nome__c + ' ' + AnagrafeConsulenti__c.getValues(a.GestoreCliente__c).Cognome__c;
      }
      else a.GestoreClienteNome__c = '';
    }
  }

  @RemoteAction
  public static Account getInformazioniCambiaOwnerAccount(String accountId) {
    return [SELECT Name, Owner.Name FROM Account Where Id = :accountId];
  }

  /**
   *
   * @param  accountId                     id dell'account di cui modificare l'owner
   * @param  inviaMessaggioNotifica        se true, invia una notifica chatter al nuovo owner
   * @param  nuovoTitolareId               id dell'user che diventa owner dell'account
   * @param  trasferisciOpportunitaAperte  se true, passano al nuovo owner tutte le opportunità aperte legate all'account;
   *                                       se false, passano al nuovo owner solo le opportunità aperte legate all'account di proprietà del vecchio owner
   * @return                               account modificato ed eventuale messaggio
   */
  @RemoteAction
  public static CambiaOwnerAccountResult cambiaOwnerAccount(String accountId, Boolean inviaMessaggioNotifica, String nuovoTitolareId, Boolean trasferisciOpportunitaAperte) {
    Boolean disabilitaPostChatterAccount = Funzionalita__c.getInstance().DisabilitaPostChatterAccount__c;
    Account acc = [SELECT Name, OwnerId, Owner.UserRoleId FROM Account WHERE Id = :accountId];
    Id currentUserId = UserInfo.getUserId();
    Id currentUserRole = UserInfo.getUserRoleId();
    // Errore nel caso in cui l'utente che tenta di eseguire la modifica non sia l'owner o un amministratore o non abbia un ruolo superiore a quello dell'owner dell'account

    if (acc.OwnerId != currentUserId &&
      !U.getIdSet([SELECT Id FROM User WHERE Profile.Name IN ('System Administrator', 'Amministratore del sistema')], 'Id').contains(currentUserId) &&
      !CU.getUserParentsRoleHierarchy(acc.Owner.UserRoleId).contains(currentUserRole)
    )
      return new CambiaOwnerAccountResult(null, Label.ERR_permessi_owner, false);
    // Errore nel caso in cui si tenta di trasferire l'account ad un utente di un'altra BU
    if (!CU.isFactoring(nuovoTitolareId)) return new CambiaOwnerAccountResult(null, Label.ERR_trasferireAccount, false);

    // Trasferisco l'account
    Funzionalita__c f = Funzionalita__c.getOrgDefaults();

    User nuovoTitolare = [SELECT Name FROM User WHERE Id = :nuovoTitolareId];
    Id vecchioTitolareId = acc.OwnerId;
    acc.OwnerId = nuovoTitolareId;
    update acc;

    // Trasferisco le opportunità factoring aperte (solo dell'attuale titolare o meno, in base al flag)
    String query = 'SELECT Id, OwnerId FROM Opportunity WHERE ';
    String[] conditions = new String[] {
      'AccountId = \'' + accountId + '\'',
      'IsClosed = false',
      'RecordType.DeveloperName = \'IFISOpportunitaFactoring\''
    };
    if (!trasferisciOpportunitaAperte) conditions.add('OwnerId = \'' + vecchioTitolareId + '\'');
    Opportunity[] oppsDaTrasferire = Database.query(query + String.join(conditions, ' AND ') + ' FOR UPDATE');
    f.BypassValidationRule__c = true;
    update f;
    update U.massSet(oppsDaTrasferire, 'OwnerId', nuovoTitolareId);
    f.BypassValidationRule__c = false;
    update f;

    /*
    // Trasferisco i contratti in bozza o in stato di approvazione
    Contract[] contrattiDaTrasferire = [SELECT Id, OwnerId
    FROM Contract
    WHERE AccountId = :accountId
    AND Status IN ('Draft', 'In Approval Process')];
    update U.massSet(contrattiDaTrasferire, 'OwnerId', nuovoTitolareId);
    */

    /*
    // Trasferisco le bozze di ordini dei contratti autonomi e trasferiti
    // TODO: sistemare
    Order[] ordiniDaTrasferire = [SELECT Id, OwnerId
    FROM Order
    WHERE AccountId = :accountId
    AND Status = 'Draft'];
    update U.massSet(ordiniDaTrasferire, 'OwnerId', nuovoTitolareId);
    */

    // Trasferisco i referenti
    Contact[] contattiDaTrasferire = [SELECT Id, OwnerId
    FROM Contact
    WHERE AccountId = :accountId
    AND OwnerId = :vecchioTitolareId];
    update U.massSet(contattiDaTrasferire, 'OwnerId', nuovoTitolareId);

    // Trasferisco le note e gli allegati
    Note[] noteDaTrasferire = [SELECT Id, OwnerId
    FROM Note
    WHERE ParentId = :accountId
    AND OwnerId = :vecchioTitolareId];
    update U.massSet(noteDaTrasferire, 'OwnerId', nuovoTitolareId);

    Attachment[] allegatiDaTrasferire = [SELECT Id, OwnerId
    FROM Attachment
    WHERE ParentId = :accountId
    AND OwnerId = :vecchioTitolareId];
    update U.massSet(allegatiDaTrasferire, 'OwnerId', nuovoTitolareId);

    // Trasferisco le attività aperte
    Task[] taskDaTrasferire = [SELECT Id, OwnerId
    FROM Task
    WHERE (AccountId = :accountId OR WhatId = :accountId)
    AND IsClosed = false
    AND OwnerId = :vecchioTitolareId];
    update U.massSet(taskDaTrasferire, 'OwnerId', nuovoTitolareId);

    // Invio i messaggi di notifica
    if (inviaMessaggioNotifica && !Test.isRunningTest() && !disabilitaPostChatterAccount) ChatterUtils.postToChatter(acc.Id, nuovoTitolareId, + Label.CambiaOwnerAccountChatter + ' ' + acc.Name);
    return new CambiaOwnerAccountResult(acc, nuovoTitolare.Name + ' ' + Label.CambiaOwnerAccount + ' ' + acc.Name.toUpperCase() + '.', true);
  }

  /**
   * Classe contenente il risultato dell'operazione "cambia account": l'account modificato, un eventuale messaggio e un flag
   * che indica se l'aggiornamento è andato a buon fine
   */
  public class CambiaOwnerAccountResult {
    @AuraEnabled public Account account;
    @AuraEnabled public String messaggio;
    @AuraEnabled public Boolean success;

    public CambiaOwnerAccountResult(Account account, String messaggio, Boolean success) {
      this.account = account;
      this.messaggio = messaggio;
      this.success = success;
    }
  }

    
  /**
   * Manda un avviso tramite email allo specialista factoring precedente durante un cambio assegnazione
   */
  public static void avvisaCambioAssegnazione(T tu) {

	Id currentUserId = UserInfo.getUserId();
	
	//Inserisco il Chatter solo se la modifica no viene eseguita da un amministratore
    if (!U.getIdSet([SELECT Id FROM User WHERE Profile.Name IN ('System Administrator', 'Amministratore del sistema')], 'Id').contains(currentUserId)) {
	
		List<Account> updated = (List<Account>) tu.getChanged('WGC_Specialista_Factoring__c');
	
		for (Account newAcc : updated) {
			Account oldAcc = (Account) tu.oldMap.get(newAcc.Id);

			//CHATTER #2
			if (oldAcc.Stato_Assegnazione__c == 'Richiesta approvata') { //c'era una richiesta in approvazione
				ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
				ConnectApi.MentionSegmentInput mentionSegmentOld = new ConnectApi.MentionSegmentInput();
				ConnectApi.MentionSegmentInput mentionSegmentNew = new ConnectApi.MentionSegmentInput();
				ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
				ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

				messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

				textSegmentInput.text = 'L\'anagrafica '+ oldAcc.Name +' - NDG '+oldAcc.NDGGruppo__c+', è stata riassegnata.';
				messageBodyInput.messageSegments.add(textSegmentInput);

				// Mention previous specialista
				if (String.isNotBlank(oldAcc.WGC_Specialista_Factoring__c)) {
					mentionSegmentOld.id = oldAcc.WGC_Specialista_Factoring__c;
					messageBodyInput.messageSegments.add(mentionSegmentOld);
				}
            
				// Mention new specialista
				mentionSegmentNew.id = newAcc.WGC_Specialista_Factoring__c;
				messageBodyInput.messageSegments.add(mentionSegmentNew);

				feedItemInput.body = messageBodyInput;
				feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;

				// Account record ID
				feedItemInput.subjectId = oldAcc.Id;
				//post
				ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
			}
		}
	}
  } //avvisaCambioAssegnazione END


}