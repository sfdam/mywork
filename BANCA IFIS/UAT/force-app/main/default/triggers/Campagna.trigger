/**
* Progetto:         Banca IFIS
* Descrizione:      Trigger su oggetto Campagna
* Sviluppata il:    21/10/2016
* Developer:        Zerbinati Francesco
*/

trigger Campagna on Campaign (after insert, after update) {
  Funzionalita__c f = Funzionalita__c.getInstance();
  if (f.DisabilitaTriggers__c) return;

  if(TrgCampagna.disableTrigger || f.DisabilitaTriggerCampagna__c) return;

    T tu = T.getInstance();

    if(T.isAfterInsert()){
      //Aggiorno la global picklist delle campagne
      WGC_TrgCampagna.updateCampaignPicklist();
    }

    if(T.isAfterUpdate()) {
      // creo il task sul contatto legato agli account coinvolti nella campagna
      TrgCampagna.creaTaskContatto(tu);
    }
}