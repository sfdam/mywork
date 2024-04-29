public with sharing class UtilAnagrafiche {

  private static Map<String, Comune__c> cabComuneMap = new Map<String, Comune__c>();

  public static Map<String, Id> getOwners(Set<String> caps, Set<String> comuni, Set<String> provincie, Boolean filoDiretto) {
    Set<String> chiavi = new Set<String>();
    chiavi.addAll(caps);
    chiavi.add('0000');

    Map<String, AggregateResult[]> assegnazioniMap = U.groupBy([SELECT
      COUNT(Id),
      CAP__c,
      Utente__c,
      Utente__r.ManagerId manager
      FROM AssegnazioneAnagrafica__c
      WHERE CAP__c IN :caps
      AND FiloDiretto__c = :filoDiretto
      GROUP BY CAP__c, Utente__c, Utente__r.ManagerId
    ], 'Cap__c');

    if(!caps.isEmpty() && !comuni.isEmpty()) {
      Map<String, AggregateResult[]> assegnazioniCapComuneMap = U.groupBy([SELECT
        COUNT(Id),
        CAP__c,
        Comune__r.Name comune,
        Utente__c,
        Utente__r.ManagerId manager
        FROM AssegnazioneAnagrafica__c
        WHERE Comune__r.Name IN :comuni
        AND FiloDiretto__c = :filoDiretto
        GROUP BY CAP__c, Comune__r.Name, Utente__c, Utente__r.ManagerId
      ], '{Cap__c}_{comune}', true);

      assegnazioniMap.putAll(assegnazioniCapComuneMap);
      chiavi.addAll(assegnazioniCapComuneMap.keySet());
    }

    if(!comuni.isEmpty()) {
      Map<String, AggregateResult[]> assegnazioniComuniMap = U.groupBy([SELECT
        COUNT(Id),
        Comune__r.Name comune,
        Utente__c,
        Utente__r.ManagerId manager
        FROM AssegnazioneAnagrafica__c
        WHERE Comune__r.Name IN :comuni
        AND FiloDiretto__c = :filoDiretto
        GROUP BY Comune__r.Name, Utente__c, Utente__r.ManagerId
      ], 'comune');

      assegnazioniMap.putAll(assegnazioniComuniMap);
      chiavi.addAll(comuni);
    }

    if(!provincie.isEmpty()) {
      Map<String, AggregateResult[]> assegnazioniProvincieMap = U.groupBy([SELECT
        COUNT(Id),
        Comune__r.Provincia__c provincia,
        Utente__c,
        Utente__r.ManagerId manager
        FROM AssegnazioneAnagrafica__c
        WHERE Comune__r.Provincia__c IN :provincie
        AND FiloDiretto__c = :filoDiretto
        GROUP BY Comune__r.Provincia__c, Utente__c, Utente__r.ManagerId
      ], 'provincia');
      assegnazioniMap.putAll(assegnazioniProvincieMap);
      chiavi.addAll(provincie);
    }

    Map<String, Id> res = new Map<String, Id>();
    Id utenteDefault = (Id) UtenzeDefault__c.getInstance().get(filoDiretto ? 'IdUtenteDefaultFD__c' : 'IdUtenteDefaultS__c');
    for(String chiave : chiavi) {
      AggregateResult[] assegnazioni = assegnazioniMap.get(chiave);
      //Se il cap del cliente non è assegnato a nessun sviluppatore, assegno a utente default
      if(chiave == '0000') res.put(chiave, utenteDefault);
      else if(assegnazioni == null) continue; //res.put(chiave, utenteDefault);
      //Se il cap/comune/provincia del cliente è assegnato a un solo sviluppatore, assegno a lui
      else if(assegnazioni.size() == 1) res.put(chiave, (Id) assegnazioni[0].get('Utente__c'));
      //Se c'è più di uno sviluppatore assegnato al cap/comune/provincia, ma nella lista degli sviluppatori c'è il current user, questo
      //viene usato come preferenziale
      else if(U.getIdSet(assegnazioni, 'Utente__c').contains(UserInfo.getUserId())) res.put(chiave, UserInfo.getUserId());
      //Se c'è più di uno sviluppatore ma hanno tutti lo stesso manager, assegno al manager
      else if(U.getIdSet(assegnazioni, 'manager').size() == 1) res.put(chiave, (Id) assegnazioni[0].get('manager'));
      //In tutti gli altri casi assegno all'utente di default
      else continue; //res.put(chiave, utenteDefault);
    }

    return res;
  }

  public static Map<Id, Contact> getReferenteCampagna(Set<Id> accIds) {
    Map<String, SObject> accId2contact = U.keyBy([SELECT
      Id,
      AccountId
      FROM Contact
      WHERE IsReferenteCampagna__c = TRUE
      AND AccountId IN :accIds
    ], 'AccountId');

    return new Map<Id,Contact>((List<Contact>) accId2contact.values());
  }

  public static String[] getCampiMancanti(SObject a, CampoAnagrafe__mdt[] campiObbligatori) {
    String[] campiMancanti = new String[] {};
    String[] campiMancantiLabel = new String[] {};
    for (CampoAnagrafe__mdt c : campiObbligatori) {
      Object x = a.get(c.Label);
      if (x == null || (x instanceof String && String.isBlank((String) x))) {
        campiMancanti.add(c.Label);
      }
      if (c.Label == 'Ateco' && x == '0') { // || c.Label == 'Fatturato__c' && x == 0) {
        campiMancanti.add(c.Label);
      }
    }

    if (!campiMancanti.isEmpty()) {
      Map<String, Schema.SObjectField> fieldMap = a.getSObjectType().getDescribe().fields.getMap();
      for (String c : campiMancanti) {
        campiMancantiLabel.add(fieldMap.get(c).getDescribe().getLabel());
      }
    }
    return campiMancantiLabel;
  }

  public static String getProvinciaFromCodCat(String cCat) {
    Comune__c c = getComune(cCat);
    return c != null ? c.Provincia__c : null;
  }

  public static String getNomeComuneFromCodCat(String cCat) {
    Comune__c c = getComune(cCat);
    return c != null ? c.Name : null;
  }

  public static Comune__c getComune(String cCat) {
    if (!cabComuneMap.containsKey(cCat) && String.isNotBlank(cCat)) {
      Comune__c[] cL = [SELECT
        Name,
        Cab__c,
        CabCin__c,
        CodiceCatastale__c,
        Provincia__c,
        ProvinciaEstesa__c,
        StatoEstero__c
        FROM Comune__c
        WHERE CodiceCatastale__c = :cCat
        ORDER BY FlagStorico__c
      ];

      if (!cl.isEmpty()) {
        cabComuneMap.put(cL[0].CodiceCatastale__c, cl[0]);
      }
    }
    return cabComuneMap.get(cCat);
  }

  public static String truncateString(String value, Integer len) {
    if (String.isBlank(value)) return null;
    return value.abbreviate(len);
  }

  public static void truncateInSObject(SObject o, String[] fields, Integer length) {
    for(String f : fields) {
      o.put(f, truncateString((String) o.get(f), length));
    }
  }

  public static String getIndirizzoCompleto(String tipo, String nome, String numero) {
    return ((String.isBlank(tipo) ? '' : tipo)
     + ' ' + (String.isBlank(nome) ? '' : nome)
     + ' ' + (String.isBlank(numero) ? '' : numero))
    .trim();
  }

  //madre perdoname por mi vida loca
  public static Boolean isOK(Object value) {
    if (value instanceof String) return String.isNotBlank((String)value);
    return value != null;
  }
}