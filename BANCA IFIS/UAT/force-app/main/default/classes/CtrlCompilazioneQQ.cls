/**
* Progetto:         Banca IFIS
* Sviluppata il:    22/12/2016
* Developer:        Zerbinati Francesco, Triaca Michele
*/

public with sharing class CtrlCompilazioneQQ {
  private PageReference backPr;
  public QuestionarioQualitativo__c qq {get; private set;}

  public CtrlCompilazioneQQ(ApexPages.StandardController ctrl) {
    if(!Test.isRunningTest())
      ctrl.addFields(new String[]{'Account__c', 'Opportunita__c'});
    backPr = ctrl.cancel();
    Id oppId = (Id) ctrl.getRecord().get('Opportunita__c');
    Id accId = (Id) ctrl.getRecord().get('Account__c');
    Map<String, String> pageParams = ApexPages.currentPage().getParameters();
    if(String.isNotBlank(pageParams.get('oppId'))) oppId = pageParams.get('oppId');
    if(String.isNotBlank(pageParams.get('accId'))) accId = pageParams.get('accId');
    if(String.isNotBlank(oppId)) {
      Opportunity o = [SELECT Id, AccountId FROM Opportunity WHERE Id = :oppId];
      accId = o.AccountId;
    } else if(String.isBlank(accId)) {
      accId = '';
    }

    if(String.isNotBlank(accId)) {
      qq = new QuestionarioQualitativo__c(Id = ctrl.getId(), Opportunita__c = oppId, Account__c = accId);

      QuestionarioQualitativo__c[] qqL = [SELECT
        Account__c,
        Account__r.Fatturato__c,
        NomeModello__c,
        Opportunita__c
        FROM QuestionarioQualitativo__c
        WHERE Account__c = :accId
        AND Stato__c = 'Bozza'
        LIMIT 1
      ];

      if(qqL.isEmpty()) return;
      String tipoAttuale = getNomeModello(qql[0].Account__r.Fatturato__c);
      if(qqL[0].NomeModello__c == tipoAttuale) qq = qqL[0];
    }
  }

  public PageReference backAndRefresh() {
    backPr.setRedirect(true);
    return backPr;
  }

  @RemoteAction
  public static List<QuestionarioQualitativo__c> fetchAltriQQ(InputObj input) {
    Account acc = [SELECT Fatturato__c FROM Account WHERE Id = :input.accountId];
    String modelloName = getNomeModello(acc.Fatturato__c);

    return [SELECT
      Name,
      DataCompilazione__c
      FROM QuestionarioQualitativo__c
      WHERE Account__c = :input.accountId
      AND NomeModello__c = :modelloName
      AND Id != :input.qqId
      ORDER BY DataCompilazione__c DESC
      LIMIT 20
    ];
  }

  @RemoteAction
  public static OutputObj fetchQQ(InputObj input) {
    // se ho l'id, allora esiste già e lo recupero
    OutputObj o = new OutputObj();

    Account acc = [SELECT Fatturato__c, NDGGruppo__c FROM Account WHERE Id = :input.accountId];
    String nomeModello = getNomeModello(acc.Fatturato__c);

    String nomeSR = nomeModello == 'Small Business' ? 'ModelliQQ_SMALL' : 'ModelliQQ_CO';
    StaticResource sr = [SELECT
      Body
      FROM StaticResource
      WHERE Name = :nomeSR
      LIMIT 1
    ];

    String jsonQQ = sr.Body.toString();
    o = (OutputObj) JSON.deserialize(jsonQQ, OutputObj.class);
    o.qq.Account__c = input.accountId;
    o.qq.NomeModello__c = nomeModello;

    if(String.isNotBlank(input.qqId)) {
      QuestionarioQualitativo__c sfdcQQ = [SELECT
        Id,
        Stato__c,
        Account__c,
        Payload__c,
        Risposta1__c,
        Risposta2__c,
        Risposta3__c,
        Risposta4__c,
        Risposta5__c,
        Risposta6__c,
        Risposta7__c,
        Risposta8__c,
        Risposta9__c,
        Risposta10__c,
        Risposta11__c,
        Risposta12__c,
        Risposta13__c,
        Risposta14__c,
        Risposta15__c,
        Risposta16__c,
        Risposta17__c,
        Risposta18__c,
        Risposta19__c,
        Risposta20__c,
        Risposta21__c,
        NomeModello__c
        FROM QuestionarioQualitativo__c WHERE
        Id = :input.qqId
      ];

      o.qq.Stato__c = sfdcQQ.Stato__c;
      o.qq.Id = sfdcQQ.Id;
      Domanda[] domande = null;
      if(String.isNotBlank(sfdcQQ.Payload__c)) {
        domande = (Domanda[]) JSON.deserialize(sfdcQQ.Payload__c, Domanda[].class);
      } else {
        domande = recuperaQQ(acc.NDGGruppo__c, nomeModello);
      }

      // sovrascrivo le risposte con quelle nel CRM
      Map<Integer, String> mappaDm = getMappaParametriDataModel(nomeModello);
      for(Domanda d : domande) {
        d.value = sfdcQQ.get(mappaDm.get(d.codiceDatoDomanda)) != null ? (String) sfdcQQ.get(mappaDm.get(d.codiceDatoDomanda)) : '';
      }

      o.domande = domande;
    } else {
      o.domande = recuperaQQ(acc.NDGGruppo__c, nomeModello);
      o.qq.NomeModello__c = nomeModello;
      o.qq.Stato__c = 'Bozza';
    }

    return o;
  }

  @RemoteAction
  public static Id salvaQQ(Map<Integer,Domanda[]> domande, QuestionarioQualitativo__c qq) {

    Account a = [SELECT Id, NDGGruppo__c, Fatturato__c FROM Account WHERE Id = :qq.Account__c];
    aggiornaQQServizi(a.NDGGruppo__c, qq.NomeModello__c, domande);

    System.Savepoint sp = Database.setSavePoint();
    try {
      if(String.isBlank(a.NDGGruppo__c) && qq.Stato__c == 'Confermato') throw new Ex.WSException('Non è possibile confermare un questionario qualitativo senza aver effettuato la convalida. Salvare il questionario come bozza e riprovare dopo aver effettuato il censimento');

      QuestionarioQualitativo__c[] qqL = [SELECT
        Id,
        Account__c,
        Account__r.Fatturato__c,
        Account__r.NDGGruppo__c,
        NomeModello__c,
        Opportunita__c
        FROM QuestionarioQualitativo__c WHERE Account__c = :qq.Account__c AND Stato__c = 'Bozza' LIMIT 1
      ];

      String tipoAttuale = getNomeModello(a.Fatturato__c);
      if(!qqL.isEmpty() && qqL[0].NomeModello__c != tipoAttuale) {
        delete qqL;
      }

      if(qq.Stato__c == 'Confermato') {
        // instanzio una mappa di nome-stato in modo che faccia le varie operazioni sui qq nei servizi mule
        Map<String,String> nomistati = new Map<String,String>();

        List<QuestionarioQualitativo__c> daArchiviare = [SELECT Id, Name, IdSiebel__c, Stato__c
          FROM QuestionarioQualitativo__c
          WHERE Account__c = :qq.Account__c
          AND Stato__c IN ('Scaduto','Confermato')
        ];

        for(QuestionarioQualitativo__c qda : daArchiviare) {
          if(String.isNotBlank(qda.IdSiebel__c)) nomistati.put(qda.IdSiebel__c, 'archiviamigrato');
          else nomistati.put(qda.Name, 'archivia');
          qda.Stato__c = 'Archiviato';
        }

        // aggiorno quelli da archiviare
        update daArchiviare;

        // solo se il qq è in stato confermato metto la data di compilazione
        qq.DataCompilazione__c = Date.today();
      }

      Map<Integer, String> mappaDm = getMappaParametriDataModel(tipoAttuale);

      for(Domanda[] lista : domande.values()) {
        for(Domanda d : lista) {
          System.debug('domanda: ' + d.codiceDatoDomanda + '---> ' + d.value);
          qq.put(mappaDm.get(d.codiceDatoDomanda), d.value);
        }
      }

      Domanda[] payload = new List<Domanda>();
      for(Domanda[] sez : domande.values()) {
        payload.addAll(sez);
      }
      qq.Payload__c = JSON.serialize(payload);

      upsert qq;

      return qq.Id;

    } catch(DmlException err) {
      Database.rollback(sp);
      System.debug(err);
      throw new Ex.WSException('Errore aggiornamento questionario qualitativo: ' + err.getDmlMessage(0), err);
    }
  }


  // tipoOperazione: A=variazione AM=aggiornamento data modulo BDII D=cancellazione  I=inserimento  R=lettura
  public static void aggiornaQQServizi(String ndg, String tipoModulo, Map<Integer, Domanda[]> mappaCodiciValori) {
    WsAnagrafe.ModificaDatiAggiuntiviQQInput input = new WsAnagrafe.ModificaDatiAggiuntiviQQInput();
    input.ndg = Long.valueOf(ndg);

    //WsAnagrafe.RequestDato requestDatoEl1 = new WsAnagrafe.RequestDato();
    WsAnagrafe.RequestDato[] rdlist = new List<WsAnagrafe.RequestDato>();
    for(Integer codMod : mappaCodiciValori.keySet()) {
      // primo parametro è il codice modulo
      rdlist.clear();
      WsAnagrafe.RequestDato rdCodiceModulo = new WsAnagrafe.RequestDato();
      rdCodiceModulo.codice = codMod;
      rdlist.add(rdCodiceModulo);

      for(Domanda d: mappaCodiciValori.get(codMod)) {
        WsAnagrafe.RequestDato rd = new WsAnagrafe.RequestDato();
        rd.codice = d.codiceDatoDomanda;
        rd.valore = d.value;
        rdlist.add(rd);
      }

      WsAnagrafe.RequestDati requestDati = new WsAnagrafe.RequestDati();
      requestDati.requestDato = rdlist;

      input.requestDati = requestDati;

      WsAnagrafe.modificaDatiAggiuntiviQQ(input);
    }
  }

  public static Domanda[] recuperaQQ(String ndg, String tipoModulo) {

    System.debug('Recupero dai servizi');

    Integer[] listaSezioni = getListaSezioni(tipoModulo);

    Domanda[] domande = new List<Domanda>();
    for(Integer codMod : listaSezioni) {
      WsAnagrafe.DatiBilancioInput input = new WsAnagrafe.DatiBilancioInput();
      if(ndg != null) {
        input.ndg = Long.valueOf(ndg);
      } else {
        throw new Ex.WSException('Manca NDG del cliente');
      }
      input.codiceModulo = codMod;
      WsAnagrafe.DatiBilancioResponse res = WsAnagrafe.datiBilancio(input);

      WsAnagrafe.Domanda[] datiDomande = res.payload.datiDomande.domanda;

      for(WsAnagrafe.Domanda dd : datiDomande) {
        Domanda d = new Domanda();
        d.codiceDatoDomanda = dd.codiceDatoDomanda;
        d.value = dd.risposta != null ? dd.risposta : '';
        d.domanda = dd.domanda;
        d.codiceModulo = codMod;
        WsAnagrafe.Layout[] layouts = dd.datiLayout.layout;
        DominioRisposta[] dominio = new List<DominioRisposta>();
        for(WsAnagrafe.Layout l : layouts) {
          DominioRisposta dr = new DominioRisposta();
          dr.label = l.risposta;
          dr.value = l.valoreRisposta;
          dominio.add(dr);
        }
        d.dominio = dominio;
        domande.add(d);
      }
    }
    return domande;
  }

  /** STUB  PER JSON VUE **/


  public class InputObj {
    private String accountId;
    private String qqId;

    public InputObj(String accountId, String qqid) {
      this.accountId = accountId;
      this.qqId = qqid;
    }
  }

  public class OutputObj {
    public QuestionarioQualitativo__c qq;
    public Domanda[] domande;
  }

  public Class Domanda {
    public Integer codiceDatoDomanda;
    public String value;
    public String domanda;
    public Integer codiceModulo;
    public DominioRisposta[] dominio;
  }

  @TestVisible
  private Class DominioRisposta {
    public String value;
    public String label;
  }

  /** METODI DI MAPPATURA **/

  // lista delle sezioni del modulo
  public static Integer[] getListaSezioni (String tipoModulo) {
    Integer [] listaSB = new Integer[]{2801, 2802, 2803, 2804, 2805, 2806};
    Integer [] listaCO = new Integer[]{2901, 2902, 2903, 2904, 2905, 2906};
    return tipoModulo == 'Small Business' ? listaSB : listaCO;
  }

  // lista dei parametri disponibili per un modulo
  public static Integer[] getListaParametri (String tipoModulo) {
    Integer[] listaParSB = new Integer[]{66000, 66001, 66002, 66003, 66004, 66005, 66006, 66007, 66008, 66013, 66015, 66016, 66019, 66020, 66021, 66022, 66023, 66024};
    Integer[] listaParCO = new Integer[]{66000, 66001, 66002, 66004, 66005, 66006, 66007, 66008, 66009, 66010, 66011, 66012, 66013, 66014, 66016, 66017, 66018, 66020, 66021, 66023, 66024};
    return tipoModulo == 'Small Business' ? listaParSB : listaParCO;
  }

  // restituisce una mappa sezione1 => {par1, par2, par3}, sezione2 => {par4, par5, par6} .... */
  public static Map<Integer, Integer[]> getModelloModulo(String tipoModulo) {

    Integer[] listaSezioni = getListaSezioni(tipoModulo);
    Integer[] listaPar = getListaParametri(tipoModulo);

    Map<Integer, List<Integer>> mappaSezioni = new Map<Integer, Integer[]>();

    for(Integer sez : listaSezioni) {
      List<Integer> parametriSezione = new List<Integer>();
      for(Integer par : listaPar) {
        if(sez == 2801 && par >= 66000 && par <= 66007) parametriSezione.add(par);
        if(sez == 2802 && par >= 66008 && par <= 66012) parametriSezione.add(par);
        if(sez == 2803 && par >= 66013 && par <= 66015) parametriSezione.add(par);
        if(sez == 2804 && par >= 66016 && par <= 66019) parametriSezione.add(par);
        if(sez == 2805 && par >= 66020 && par <= 66023) parametriSezione.add(par);
        if(sez == 2806 && par == 66024) parametriSezione.add(par);
      }
      mappaSezioni.put(sez, parametriSezione);
    }

    return mappaSezioni;
  }

  /* mappa le risposte nel data model sfdc con i codici parametro dei servizi */
  public static Map<Integer, String> getMappaParametriDataModel(String tipoModulo) {
    Map<Integer, String> m = new Map<Integer,String>();
    Integer[] listaPar = getListaParametri(tipoModulo);
    Integer counter = 1;
    for(Integer codPar : listaPar) {
      m.put(codPar, 'Risposta' + counter + '__c');
      counter++;
    }
    return m;
  }

  public static String getNomeModello(Decimal fatturato) {
    Impostazioni__c i = Impostazioni__c.getInstance();
    return fatturato != null && fatturato >= i.SogliaFatturatoSBCO__c ? 'Corporate' : 'Small Business';
  }
}