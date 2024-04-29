public class CtrlCointestazione {

  public CtrlCointestazione(ApexPages.StandardController ctrl) {}

  public Set<JoinCointestazione__c> joinCointestazioneList = new Set<JoinCointestazione__c>();

  public class ElemObject{
    @AuraEnabled
    public String ndg;
    @AuraEnabled
    public String capoRete;
    @AuraEnabled
    public String ndgCaporete;
    @AuraEnabled
    public Boolean collegamentoAttivo;
    @AuraEnabled
    public String rapporto;
  }

  public class ResponseObject {
    @AuraEnabled
    public String status;
    @AuraEnabled
    public Cointestazione[] cointestazioni;

    public ResponseObject() {
      cointestazioni = new Cointestazione[]{};
    }
  }

  public class Cointestazione {
    @AuraEnabled
    public String codiceRapporto;
    @AuraEnabled
    public Account capoRete;
    @AuraEnabled
    public SObject[] cointestatari;

    public Cointestazione () {
      cointestatari = new SObject[]{};
    }
  }

  public static List<ElemObject> ordinaResponse(WsAnagrafe.GestioneCollNdgResponse res){
    List<ElemObject> elemObjList = new List<ElemObject>();
    List<ElemObject> capiRete = new List<ElemObject>();
    for(WsAnagrafe.ElementoNdg elem : res.payload.elementi){
      if(elem.tipo=='COINN'){
        ElemObject elemObj = new ElemObject();
        elemObj.ndg = String.valueOf(elem.ndg);
        elemObj.caporete = elem.capoRete;
        elemObj.collegamentoAttivo = elem.collegamentoAttivo == 'S' ? true : false;
        elemObj.rapporto = String.valueOf(elem.rapporto.servizio) + String.valueOf(elem.rapporto.filiale) + String.valueOf(elem.rapporto.conto);
        if(elem.caporete != 'S') elemObjList.add(elemObj);
        else capirete.add(elemObj);
      }
    }
    for(ElemObject elem : elemObjList){
      for(ElemObject capo : capirete){
        if(elem.rapporto == capo.rapporto) elem.ndgCaporete = capo.ndg;
      }
    }
    return elemObjList;
  }

  /**
   * A partire da un Account/Contact invoca "gestioneCollNdg" per trovare le reti collegate all'anagrafica.
   * Chiama poi la coda "QbleCensimentoCointestatari", passando i cointestatari/cointestazioni trovate.
   * @param sObjectId id dell'Account/Contact per cui cercare le cointestazioni in cui compare
   * return           id della coda
   */
  public static String gestisciCointestazione(Id sObjectId) {
    String sObjectType = sObjectId.getSObjectType().getDescribe().getName();
    SObject sObj = Database.query('SELECT Id, NDGGruppo__c FROM ' + sObjectType + ' WHERE Id = \'' + sObjectId + '\'');
    WsAnagrafe.GestioneCollNdgResponse response = WsAnagrafe.gestioneCollNdg((String) sObj.get('NDGGruppo__c'));
    ElemObject[] elemObjList = ordinaResponse(response);
    return System.enqueueJob(new QbleCensimentoCointestatari(elemObjList));
  }

  /**
   * Recupera lo stato di esecuzione del processo asincrono. Se è terminato recupera anche le cointestazioni associate all'anagrafica
   * @param processId id del processo asincrono
   * @param sObjectId id dell'account/contact
   * @return          stato di esecuzione del processo e cointetazioni associate a sObjectId
   */
  public static ResponseObject recuperaCointestazioni(String processId, Boolean riepilogoCointestazioni, Id sObjectId) {
    ResponseObject response = new ResponseObject();
    if(String.isNotBlank(processId))
      response.status = [SELECT Status
        FROM AsyncApexJob
        WHERE ApexClass.Name = 'QbleCensimentoCointestatari'
        AND CreatedById = :UserInfo.getUserId()
        ORDER BY CreatedDate DESC
        LIMIT 1
      ][0].Status;
    if (response.status == 'Completed' || riepilogoCointestazioni) {
      // Stato coda completato: recupero le anagrafiche associate a "sObjectId"
      String sObjectType = sObjectId.getSObjectType().getDescribe().getName();
      String queryJC = 'SELECT CodiceRapporto__c FROM JoinCointestazione__c WHERE ';
      if (sObjectType == 'Account') {
        queryJC += '(Cointestazione__c = \'' + sObjectId + '\' OR CointestatarioPG__c = \'' + sObjectId + '\')';
      } else {
        queryJC += 'CointestatarioPF__c = \'' + sObjectId + '\'';
      }
      queryJC += ' AND CollegamentoAttivo__c = true';
      Set<String> codiceRapportoSet = U.getSet(Database.query(queryJC), 'CodiceRapporto__c');

      JoinCointestazione__c[] jcList = [SELECT Id,
        Cointestazione__c,
        Cointestazione__r.Name,
        Cointestazione__r.NDGGruppo__c,
        CointestatarioPG__c,
        CointestatarioPG__r.CF__c,
        CointestatarioPG__r.Name,
        CointestatarioPG__r.NaturaGiuridica__c,
        CointestatarioPG__r.NDGGruppo__c,
        CointestatarioPG__r.PIVA__c,
        CointestatarioPF__c,
        CointestatarioPF__r.CF__c,
        CointestatarioPF__r.FirstName,
        CointestatarioPF__r.LastName,
        CointestatarioPF__r.NaturaGiuridica__c,
        CointestatarioPF__r.NDGGruppo__c,
        CodiceRapporto__c
        FROM JoinCointestazione__c
        WHERE CodiceRapporto__c IN :codiceRapportoSet
        AND CollegamentoAttivo__C = true
      ];

      Map<String, JoinCointestazione__c[]> jcPerCodiceRapporto = U.groupBy(jcList, 'CodiceRapporto__c');
      for (String cRapporto : U.toList(jcPerCodiceRapporto.keySet())) {
        // Itero sulle cointestazioni, ognuna identificata dal codice rapporto "cRapporto"
        Cointestazione cointestazione = new Cointestazione();
        cointestazione.codiceRapporto = cRapporto;
        for (JoinCointestazione__c jc : jcPerCodiceRapporto.get(cRapporto)) {
          if (jc.CointestatarioPF__c != null) cointestazione.cointestatari.add(new Contact(
              Id = jc.CointestatarioPF__c,
              CF__c = jc.CointestatarioPF__r.CF__c,
              FirstName = jc.CointestatarioPF__r.FirstName,
              LastName = jc.CointestatarioPF__r.LastName,
              NaturaGiuridica__c = jc.CointestatarioPF__r.NaturaGiuridica__c,
              NDGGruppo__c = jc.CointestatarioPF__r.NDGGruppo__c
            ));
          if (jc.CointestatarioPG__c != null) cointestazione.cointestatari.add(new Account(
              Id = jc.CointestatarioPG__c,
              CF__c = jc.CointestatarioPG__r.CF__c,
              Name = jc.CointestatarioPG__r.Name,
              NaturaGiuridica__c = jc.CointestatarioPG__r.NaturaGiuridica__c,
              NDGGruppo__c = jc.CointestatarioPG__r.NDGGruppo__c,
              PIVA__c = jc.CointestatarioPG__r.PIVA__c
            ));
          if (cointestazione.capoRete == null) cointestazione.capoRete = new Account(
              Id = jc.Cointestazione__c,
              Name = jc.Cointestazione__r.Name,
              NDGGruppo__c = jc.Cointestazione__r.NDGGruppo__c
            );
        }
        response.cointestazioni.add(cointestazione);
      }
    }
    return response;
  }
}