/**
* Progetto:         Banca IFIS
* Descrizione:      Trigger su oggetto MembroCampagna
* Sviluppata il:    25/10/2016
* Developer:        Michele Triaca
*/

public without sharing class TrgCampaignMember {
  /**
  * Metodo che crea un task sul contatto dell'account quando viene aggiunto un campaign member ad una campagna attiva
  **/
  public static void creaTaskContatto(T tu) {
    System.debug('SV creaTaskContatto: ' + tu);
    System.debug('SV creaTaskContatto: ' + tu.filter('IsActiveCampagna__c', true).getChanged('DataUltimaImportazioneDaWeb__c'));
    TrgCampagna.creaTaskDaCampaignMember(tu.filter('IsActiveCampagna__c', true).getChanged('DataUltimaImportazioneDaWeb__c'));
  }


  public static void eliminaTaskContatto(T tu) {
    // TrgCampagna.eliminaTaskDaCampaignMember((Map<Id,CampaignMember>)tu.filter('IsActiveCampagna__c', true).oldMap);
  }
}