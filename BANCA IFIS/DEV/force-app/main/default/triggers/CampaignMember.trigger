/**
* Progetto:         Banca IFIS
* Descrizione:      Trigger su oggetto MembroCampagna
* Sviluppata il:    25/10/2016
* Developer:        Michele Triaca, Francesco Zerbinati
*/

trigger CampaignMember on CampaignMember (after insert, after update, before delete) {
  Funzionalita__c f = Funzionalita__c.getInstance();
  if (f.DisabilitaTriggers__c) return;

  if(TrgCampagna.disableTrigger || BI_COM_ConversioneLead_BTCH.disableTrigger || f.DisabilitaTriggerCampagna__c) return;

  T tu = T.getInstance();

  if(T.isAfterInsert()) {
    TrgCampaignMember.creaTaskContatto(tu);
  }

  if(T.isAfterUpdate()) {
    TrgCampaignMember.creaTaskContatto(tu);
  }

  if(T.isBeforeDelete()) {
  	TrgCampaignMember.eliminaTaskContatto(tu);
  }
}