public with sharing class CtrlCensimento {
  public final static String CENSIMENTO_OK = 'Cliente censito';
  public final static String CENSIMENTO_FULL_OK = 'Cliente censito full';
  public final static String CENSIMENTO_TMP = 'Censimento in corso';
  public final static String CENSIMENTO_KO = 'Errore durante censimento';
  public final static String CENSIMENTO_NON_RICHIESTO = 'Non richiesto';

  public final static String INFOPROVIDER_TODO = 'Richiesta da inviare';
  public final static String INFOPROVIDER_OK = 'Richiesta evasa';
  public final static String INFOPROVIDER_KO = 'Richiesta in errore';
  public final static String INFOPROVIDER_TMP = 'Richiesta in corso';

  public CtrlCensimento(ApexPages.StandardController ctrl) {}
  public CtrlCensimento() {}

  /**
   * Recupero gli attori da censire e l'Account associati a una opportunità.
   * Non vengono considerati i Garanti nè gli Account COIN.
   * Se il campo PaeseSvolgimentoAttivitaPrevalente non è popolato nell'Account cedente, lo popolo con lo ShippingCountry
   * @param  oppId
   * @return
   */
  @RemoteAction
  public static NDGLinea__c[] getAziendeDaCensire(Id oppId) {
    Map<String, NDGLinea__c> res = new Map<String, NDGLinea__c>();
    String[] ndgLineaFields = new String[]{'Account__c', 'Contact__c', 'Tipo__c', 'NDG__c', 'DataConvalida__c', 'TipoGarante__c', 'Account__r.Area__c'};
    for(String f : WsAnagraficaBean.REQUIRED_ACCOUNT_FIELDS) ndgLineaFields.add('Account__r.' + f);
    for(String f : WsAnagraficaBean.REQUIRED_CONTACT_FIELDS) ndgLineaFields.add('Contact__r.' + f);

    Set<String> idGarantiAssociatiAGaranzie = U.getSet([SELECT
      Garante__c
      FROM JoinGaranteGaranzia__c
      WHERE Garanzia__r.Opportunita__c = :oppId
    ], 'Garante__c');

    String ndgLineaQuery = QueryBuilder.newInstance('NDGLinea__c', ndgLineaFields)
      .beginFilter()
        .beginOr()
          .addUntyped('Account__c != NULL')
          .addUntyped('Contact__c != NULL')
        .end()
        // .add('RecordType.DeveloperName', QBOp.QNOT_EQUAL, 'Professionista')
        .add('Account__r.NaturaGiuridica__c', QBOp.QNOT_EQUAL, 'COIN')
        .add('Opportunita__c', QBOp.QEQUAL, oppId)
        .beginOr()
          .add('Tipo__c', QBOp.QNOT_EQUAL, 'Garante')
          .add('Id', QBOp.QIN, idGarantiAssociatiAGaranzie)
        .end()
      .endFilter()
      .getQuery();

    NDGLinea__c[] linee = (NDGLinea__c[]) Database.query(ndgLineaQuery);

    for (NDGLinea__c attore : linee) {
      if (attore.Account__c != null) U.setIfEmpty(attore.Account__r, 'PaeseSvolgimentoAttivitaPrevalente__c', attore.Account__r.ShippingCountry);
      res.put(attore.Account__c != null ? attore.Account__c : attore.Contact__c, attore);
    }

    String[] oppFields = new String[]{'AccountId', 'DataConvalida__c'};
    for(String f : WsAnagraficaBean.REQUIRED_ACCOUNT_FIELDS) oppFields.add('Account.' + f);
    Opportunity o = (Opportunity) Database.query(QueryBuilder.newInstance('Opportunity', oppFields).withId(oppId).getQuery());
    if (String.isNotBlank(o.AccountId)) {
      U.setIfEmpty(o.Account, 'PaeseSvolgimentoAttivitaPrevalente__c', o.Account.ShippingCountry);
      res.put(o.AccountId, new NDGLinea__c(
        Account__c = o.AccountId,
        Account__r = o.Account,
        Tipo__c = 'Cedente',
        DataConvalida__c = o.DataConvalida__c
      ));
    }

    NDGLinea__c[] lineeDi = (NDGLinea__c[]) U.filter(res.values(), 'Account__r.NaturaGiuridica__c', 'DI');
    if(!lineeDi.isEmpty()) {
      Set<Id> diIds = U.getIdSet(lineeDi, 'Account__c');
      Set<String> cfL = U.getSet(lineeDi, 'Account__r.CF__c');
      Map<String, SObject> contattiAssociati = U.keyBy(
        Database.query(QueryBuilder.newInstance('Contact', WsAnagraficaBean.REQUIRED_CONTACT_FIELDS, new String[]{'AccountId'})
          .beginFilter()
            .beginCrossFilter('AccountContactRelation', 'Id', 'ContactId')
              .add('AccountId', QBOp.QIN, diIds, true)
            .endCrossFilter(true)
            .add('CF__c', QBOp.QIN, cfL)
          .endFilter()
          .getQuery()
        ),
        'AccountId'
      );

      for (NDGLinea__c attore : lineeDi) {
        if(contattiAssociati.containsKey(attore.Account__c)) {
          attore.Contact__r = (Contact) contattiAssociati.get(attore.Account__c);
          attore.Contact__c = contattiAssociati.get(attore.Account__c).Id;
        }
      }
    }

    return res.values();
  }

  /**
   * Aggiorna le "entities" (contatti e account): ai contatti è assegnata la NaturaGiuridica PF.
   * Annulla inoltre la data di convalida dell'opportunità e degli attori legati all'opportunità e alle entità
   * @param  entities      contatti e/o account
   * @param  opportunityId id dell'opportunità
   * @return               true, se l'operazione ha successo
   */
  @RemoteAction
  public static Boolean updateEntities(Account[] accounts, Contact[] contacts, Id opportunityId) {

    List<Account> aL = accounts != null ? accounts : new List<Account>();
    List<Contact> cL = contacts != null ? contacts : new List<Contact>();
    // Workaround serializzazione campo "int"
    for (Account acc : aL) {
      acc.NumberOfEmployees = acc.NumberOfEmployees;
    }

    U.massSet(cL, 'NaturaGiuridica__c', 'PF');
    Set<Id> accIds = U.getIdSet(aL, 'Id');
    Set<Id> conIds = U.getIdSet(cL, 'Id');

    NDGLinea__c[] lL = [SELECT
      Id,
      DataConvalida__c
      FROM NDGLinea__c
      WHERE Opportunita__c = :opportunityId
      AND (Account__c IN :accIds OR Contact__c IN :conIds)
    ];

    U.massSet(lL, 'DataConvalida__c', null);

    update lL;
    update new Opportunity(Id = opportunityId, DataConvalida__c = null);
    update cL;
    update aL;
    return true;
  }

  /**
   * Recupera informazioni riguardo all'account/contatto "objId" su CRM e Cedacri.
   * @param  objId         account/contatto
   * @param  opportunityId opportunità (richiesto per dettagli Log)
   * @return               true
   */
  @RemoteAction
  public static Boolean precheckCedacri(Id objId, Id opportunityId) {
    Logger.setTransactionContext(opportunityId, objId);
    SObject o = WsAnagraficaBean.getEntity(objId);
    String ndg = (String) o.get('NDGGruppo__c');
    if(String.isNotBlank(ndg)) return true;

    o = WsAnagrafeUtils.mergeWithCedacri(o);
    ndg = (String) o.get('NDGGruppo__c');
    if(String.isNotBlank(ndg)) update o;
    return true;
  }

  @RemoteAction
  public static Boolean richiediRibes(Id objId, Id opportunityId) {
    Logger.setTransactionContext(opportunityId, objId);
    try {
      Account a = (Account) WsAnagraficaBean.getEntity(objId);
      if ((a.StatoCensimento__c == INFOPROVIDER_TODO || a.StatoCensimento__c == INFOPROVIDER_KO) && a.Area__c != 'EE') {
        WsRestRibesUtils ribesUtils = new WsRestRibesUtils();
        String rea = a.REA__c;
        String pcciaa = a.ProvinciaCCIAA__c;

        if(String.isBlank(rea) || String.isBlank(pcciaa)) {
          WsRestRibes.GetListaAziendeResponse res2 = WsRestRibes.getListaAziende(null, a.CF__c, a.BillingState);
          if(res2.getAziende(a.BillingState).size() == 1) {
            pcciaa = res2.getAziende()[0].cciaa;
            rea = res2.getAziende()[0].nRea;
          }
        }

        System.debug('REA!! ' + rea);
        System.debug('CIA!! ' + pcciaa);

        Account ribesAcc = ribesUtils.updateDatiAnagraficiRibesPg(new Account(
          Id = a.Id,
          REA__c = rea,
          ProvinciaCCIAA__c = pcciaa
        ));
        U.setIfEmpty(ribesAcc, 'Fatturato__c', 0);
        U.setIfEmpty(ribesAcc, 'DataFatturato__c', Date.newInstance(Date.today().year() - 1, 1, 1));
        U.setIfEmpty(ribesAcc, 'BU__c', '1001');
        update ribesAcc;

        //TODO: recupero referenti da ribes. Potrebbe essere upsert?
        //Contact[] referenti = ribesUtils.getContacts(a.Id);
        //insert referenti; //NON QUI OVVIAMENTE

      } else if (a.Area__c == 'EE') {
        // Per le anagrafiche estere non sono invocati i servizi di Ribes. Imposto la richiesta come evasa in modo che
        // possa procedere a Cedacri
        a.StatoCensimento__c = CENSIMENTO_NON_RICHIESTO;
        update a;
      }
    } catch (Exception e) {
      if(e instanceof Ex.WsCalloutException) throw e;
      Logger.log('RIBES_InformazioniPG', e.getMessage());
      update new Account(Id = objId, StatoCensimento__c = INFOPROVIDER_KO, DettaglioCensimento__c = e.getMessage());
    }

    return true;
  }

  @RemoteAction
  public static Boolean richiediCensimento(Id objId, Id opportunityId) {
    Logger.setTransactionContext(opportunityId, objId);
    Boolean isAccount = objId.getSobjectType() == Account.SObjectType;
    SObject a = WsAnagraficaBean.getEntity(objId);

    try {
      //Effettuo il censimento per le anagrafiche che non hanno NDG e effettuo una
      //variazione per anagrafiche che invece ce l'hanno
      String statoCensimento = (String) a.get('StatoCensimento__c');
      if(
        statoCensimento == CENSIMENTO_KO ||
        statoCensimento == CENSIMENTO_OK ||
        statoCensimento == CENSIMENTO_FULL_OK ||
        statoCensimento == CENSIMENTO_NON_RICHIESTO ||
        statoCensimento == INFOPROVIDER_OK ||
        statoCensimento == INFOPROVIDER_KO || // Se ribes fallisce, ci proviamo lo stesso!
        (!isAccount && String.isBlank(statoCensimento))
      ) {
        WsAnagraficaBean b = new WsAnagraficaBean();
        b.fillFrom(a.Id);
        b.validate(true);

        System.debug('NDG DI GRUPPO!! ' + a.get('NDGGruppo__c'));
        if ((a.get('CF__c') != null && ((String) a.get('CF__c')).contains('99999')) || (isAccount && a.get('PIVA__c') != null && ((String) a.get('PIVA__c')).contains('99999'))) throw new Ex.WSException('Codice fiscale e/o Partita IVA non corretti, contattare l\'ufficio Anagrafe per sanare la posizione');
        if(String.isBlank((String) a.get('NDGGruppo__c'))) {
          WsAnagrafeUtils.censimentoFull(a.Id);
        } else {
          WsAnagrafeUtils.variazione(a.Id);
        }

        SObject a2 = a.getSObjectType().newSObject(a.Id);

        if ((isAccount && a.get('Area__c') == 'EE') || (!isAccount && a.get('MailingState') == 'EE'))
          a2.put('StatoCensimento__c', CENSIMENTO_NON_RICHIESTO);
        else a2.put('StatoCensimento__c', CENSIMENTO_FULL_OK);

        a2.put('DettaglioCensimento__c', '');
        if(isAccount) a2.put('RecordTypeId', U.getRecordTypes('Account').get('Cliente').Id);
        NDGLinea__c[] lL = [SELECT
          Id
          FROM NDGLinea__c
          WHERE (Contact__c = :a2.Id OR Account__c = :a2.Id)
          AND Opportunita__c = :opportunityId
        ];
        if(!lL.isEmpty()) {
          U.massSet(lL, 'DataConvalida__c', Datetime.now());
          update lL;
        } else {
          update new Opportunity(Id = opportunityId, DataConvalida__c = Datetime.now());
        }
        update a2;

        // Inserisco un log per le anagrafiche estere, poichè il servizio non è invocato
        if ((((isAccount && a.get('Area__c') == 'EE') || (!isAccount && a.get('MailingState') == 'EE'))) && a2.get('StatoCensimento__c') == CENSIMENTO_NON_RICHIESTO) {
          Boolean isVariazione = String.isNotBlank((String) a.get('NDGGruppo__c'));
          Logger.log(isVariazione ? 'ANAG_Variazione' : 'ANAG_CensimentoFull', 'Success: censimento non richiesto per anagrafiche estere.');
        }
      }

      return true;
    } catch (Ex.WsCalloutException e) {
      Boolean isVariazione = String.isNotBlank((String) a.get('NDGGruppo__c'));
      a.put('StatoCensimento__c', CENSIMENTO_KO);
      a.put('DettaglioCensimento__c', 'Errore ' + (isVariazione ? 'variazione' : 'censimento') + ':' + e.getMessage());
      update a;
      return false;
    } catch (Exception e) {
      Boolean isVariazione = String.isNotBlank((String) a.get('NDGGruppo__c'));
      Logger.log(isVariazione ? 'ANAG_Variazione' : 'ANAG_CensimentoFull', e.getMessage() + ' - ' + e.getStackTraceString());
      a.put('StatoCensimento__c', CENSIMENTO_KO);
      a.put('DettaglioCensimento__c', 'Errore ' + (isVariazione ? 'variazione' : 'censimento') + ':' + e.getMessage());
      update a;
      return false;
    }
  }

  @RemoteAction
  public static Boolean forzaControaggiornamentoKNET(Id objId, Id opportunityId) {
    Logger.setTransactionContext(opportunityId, objId);
    Boolean isAccount = objId.getSobjectType() == Account.SObjectType;
    String errorMessage = '';
    SObject a = WsAnagraficaBean.getEntity(objId);
    //try {
      //Chiamo aggiornamento KNET
      if(a.get('StatoCensimento__c') == CENSIMENTO_FULL_OK || a.get('StatoCensimento__c') == CENSIMENTO_NON_RICHIESTO) {
        //TODO -> FIXARE APPENA KNET RISOLVERA' LE ISSUES!!!!
        /*
        WsRestPefMutui.AllineaKnetResponse resKnet = WsRestPefMutui.allineaKnet(l.Account__r.NDGGruppo__c);
        if(resKnet.isCorrect()) {
          a.DettaglioCensimento__c = '';
          a.RecordTypeId = U.getRecordTypes('Account').get('Cliente').Id;
          if(l.Id != null) {
            l.DataConvalida__c = Datetime.now();
            update l;
          } else {
            update new Opportunity(Id = opportunityId, DataConvalida__c = Datetime.now());
          }
          update a;
        } else throw new Ex.AnagrafeDiGruppoException('Errore durante chiamata servizio contro aggiornamento KNET: ' + resKnet.getErrors());
      }

      return res;
      */

        /* INIZIO MODIFICA */
        try {
          WsRestPefMutui.allineaKnet((String) a.get('NDGGruppo__c'));
          a.put('DettaglioCensimento__c', '');
          if(isAccount) a.put('RecordTypeId', U.getRecordTypes('Account').get('Cliente').Id);
          update a;
        } catch(Ex.WsCalloutException e) {
        } catch(DMLException e) {
          Logger.log('PEF_AllineaKnet', e.getDmlMessage(0));
        }
        /* FINE MODIFICA */
      }

      if(!Test.isRunningTest() && isAccount) {
        Opportunity o = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId];
        if(o.AccountId == objId || (
            String.isNotBlank(((Account) a).NDGGruppo__c) &&
            String.isNotBlank(((Account) a).Owner.NDGGruppo__c)
          )
        ) {
          WsAnagrafeUtils.setRetiAnagraficheIfisAsync(a.Id);
        }
      }

      return true;

/*
    } catch (Ex.AnagrafeDiGruppoException e) {
      shouldLog = true;
      errorMessage = e.getMessage();
    } catch (Exception e) {
      shouldLog = true;
      errorMessage = e.getMessage();
    }
*/
    if (String.isNotBlank(errorMessage)) {
      a.getSObjectType().newSObject(a.Id);
      a.put('StatoCensimento__c', CENSIMENTO_KO);
      a.put('DettaglioCensimento__c', 'Errore servizi: ' + errorMessage);
      update a;
    }

    return true;
  }

  public class OutputAssociaPfPg {
    public Boolean success;
    public String message;
  }

  @RemoteAction
  public static OutputAssociaPfPg associaPfPg(Id contactId, Id opportunityId) {
    Logger.setTransactionContext(opportunityId, contactId);
    OutputAssociaPfPg output = new OutputAssociaPfPg();

    NDGLinea__c[] lL = [SELECT
      NDG__c,
      Tipo__c
      FROM NDGLinea__c
      WHERE Contact__c = :contactId
      AND Opportunita__c = :opportunityId
      AND Tipo__c IN ('Titolare effettivo adeguata verifica', 'Esecutore adeguata verifica')
    ];

    if(lL.isEmpty()) {
      output.success = true;
      return output;
    }

    Opportunity opp = [SELECT
      AccountId,
      Account.NDGGruppo__c,
      Account.NaturaGiuridica__c
      FROM Opportunity
      WHERE Id = :opportunityId
    ];

    NaturaGiuridicaTipoRete__mdt dettaglioNg;

    if (!U.filter(lL, 'Tipo__c', 'Esecutore adeguata verifica').isEmpty()) {
      dettaglioNg = [SELECT
        TipoRete__c,
        CedenteCapoRete__c
        FROM NaturaGiuridicaTipoRete__mdt
        WHERE Label = :opp.Account.NaturaGiuridica__c
      ];
    }

    for (NDGLinea__c l : lL) {
      // I professionisti Fast Finance non sono considerati per le reti anagrafiche in Cedacri
      if (l.Tipo__c == 'Professionista') continue;
      String tipoRete;
      Boolean cedenteCapoRete = false;
      if (l.Tipo__c == 'Titolare effettivo adeguata verifica') {
        tipoRete = 'TITEF';
        cedenteCapoRete = true;
      } else if (l.Tipo__c == 'Esecutore adeguata verifica') {
        if(String.isBlank(dettaglioNg.TipoRete__c)) {
          throw new Ex.AnagrafeDiGruppoException('Tipo rete non gestito per ' +
            opp.Account.NaturaGiuridica__c + '. Contattare l\'assistenza'
          );
        }
        tipoRete = dettaglioNg.TipoRete__c;
        cedenteCapoRete = dettaglioNg.CedenteCapoRete__c;
      }
      try {
        WsAnagrafe.associaPfPgCollNdg(
          opp.Account.NDGGruppo__c,
          l.NDG__c,
          tipoRete,
          cedenteCapoRete
        );
      } catch(Exception e) {
        String anomalia = 'Anomalia nella chiamata. ';
        String error = e.getMessage();
        if (error.contains('SITUAZIONE ANOMALA') || error.contains('STATUS valorizzato') || error.contains('CAPORETE IN RETE DI STESSO TIPO'))
          output.message = anomalia.difference(error);
      }
    }
    output.success = true;
    return output;
  }

  @RemoteAction
  public static Ateco__c[] fetchAteco() {
    return CtrlWizardAccount.fetchAteco();
  }

  @RemoteAction
  public static AnagrafeConsulenti__c[] fetchAnagrafeConsulenti() {
    return [SELECT
      Nome__c,
      Cognome__c,
      NDGGruppo__c,
      SGEGestoreCliente__c,
      SRDGestoreDebitore__c,
      SSUPresentatore__c
      FROM AnagrafeConsulenti__c
      WHERE NDGGruppo__c != null
    ];
  }

  @RemoteAction
  public static NaturaGiuridicaSAE__mdt[] fetchRelazioneNgSae() {
    return CtrlWizardAccount.fetchRelazioneNgSae();
  }

  @RemoteAction
  public static Boolean isPolandSearch() {
    return CtrlWizardAccount.isPolandSearch();
  }
}