public without sharing class TrgAllegato {
  private TrgAllegato() {}

  public static void inseritoAllegato(T tu) {
    Allegato__c[] allegati = tu.triggerNew;
    Map<Id, Opportunity> opps = new Map<Id, Opportunity>();
    for(Allegato__c a : allegati) {
      if(a.Opportunita__c != null) {
        Opportunity opp = changePDFStati(opps, a, true);
        opps.put(opp.Id, opp);
      }
    }
    Opportunity[] letsAvoidLockExceptions = [
      SELECT Id
      FROM Opportunity
      WHERE Id IN :opps.keySet()
      FOR UPDATE
    ];
    update opps.values();
  }

  public static void aggiornatoAllegato(T tu) {
    Allegato__c[] cambi = tu.getChanged(new String[]{'Opportunita__c', 'Tipo__c'});
    SObject[] daPulire = tu.oldMap.values();

    Map<Id, Opportunity> opps = new Map<Id, Opportunity>();
    for(SObject a : daPulire) {
      if(a.get('Opportunita__c') != null) {
        Opportunity opp = changePDFStati(opps, (Allegato__c) a, false);
        opps.put(opp.Id, opp);
      }
    }

    for(Allegato__c a : cambi) {
      if(a.get('Opportunita__c') != null) {
        Opportunity opp = changePDFStati(opps, a, true);
        opps.put(opp.Id, opp);
      }
    }
    Opportunity[] letsAvoidLockExceptions = [
      SELECT Id
      FROM Opportunity
      WHERE Id IN :opps.keySet()
      FOR UPDATE
    ];
    update opps.values();
  }

  public static void eliminatoAllegato(T tu) {
    SObject[] allegati = tu.oldMap.values();
    Map<Id,Opportunity> opps = new Map<Id, Opportunity>();
    for(SObject a : allegati) {
      if(a.get('Opportunita__c') != null) {
        Opportunity opp = changePDFStati(opps, (Allegato__c) a, false);
        opps.put(opp.Id, opp);
      }
    }
    Opportunity[] letsAvoidLockExceptions = [
      SELECT Id
      FROM Opportunity
      WHERE Id IN :opps.keySet()
      FOR UPDATE
    ];
    update opps.values();
  }

  public static Opportunity changePDFStati (Map<Id, Opportunity> opps, Allegato__c a, Boolean stato) {
    Id oppId = a.Opportunita__c;
    Opportunity opp = opps.containsKey(oppId) ? opps.get(oppId) : new Opportunity(Id = oppId);
    if(a.Tipo__c == 'RSFFirm') opp.RSFFirmata__c = stato;
    if(a.Tipo__c == 'MAVFirm') opp.MAVFirmato__c = stato;
    if(a.Tipo__c == 'ModuloTecnicheDiComunicazioneFirm') opp.TDCFirmato__c = stato;
    if(a.Tipo__c == 'ModuloFatcaFirm') opp.FATCAFirmato__c = stato;
    if(a.Tipo__c == 'PrivacyFirm') opp.PrivacyFirmato__c = stato;
    return opp;
  }
}