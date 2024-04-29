/**
* Progetto:         Banca IFIS
* Descrizione:      Trigger su oggetto Evento
* Sviluppata il:    31/10/2016
* Developer:        Zerbinati Francesco
*/

trigger Event on Event (after insert, after update, before delete, before insert, before update) {
      Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.DisabilitaTriggers__c) return;
    T tu = T.getInstance();

    if(f.DisabilitaTriggerActivities__c) {
      if(T.isBeforeInsert() || T.isBeforeUpdate()) {
        TrgActivity.chiudiActivityEsitata(tu);
      }
      return;
    }

    if(T.isBeforeInsert()) {
      //TEN - Simone Martinello 14/03/2019
      //Metodo che blocca l'inserimento di un task associato ad una anagrafica se esiste un task ancora aperto associato alla medesima anagrafica
      WGC_TrgActivity.checkEventiAperti(Trigger.New);

      TrgActivity.chiudiActivityEsitata(tu);
      //TrgActivity.bloccaVisiteNonPossibili(tu, f.DisabilitaCheckTitolareEventi__c);
      //TrgActivity.bloccaAzioniActivityNonOwner(tu);
      TrgActivity.azioneEsitazioneActivity(tu);
      TrgActivity.rinominaEvento(tu);

      // SV - TEN: ORIGINATOR
      WGC_TrgActivity.setupOriginator(Trigger.new);
    }

    if(T.isBeforeUpdate()) {
      TrgActivity.chiudiActivityEsitata(tu);
      //TrgActivity.bloccaAzioniActivityNonOwner(tu);
    }

    if(T.isAfterInsert()) {
      TrgActivity.popolaDataUltimoContatto(tu);

      //Se la visita è la prima ad essere creata per l'anagrafica ed è creata da filo diretto, creo il record di dettaglio visita legato all'anagrafica
      // WGC_TrgActivity_FD.primaVisitaCommerciale(Trigger.NewMap);
      
      //CR - FILO DIRETTO -- metodo per gestire l'update del record andamentale
      WGC_TrgActivity_FD.update_VC_Actual(Trigger.New);

    }

    if(T.isAfterUpdate()) {
        TrgActivity.azioneEsitazioneActivity(tu);
        TrgActivity.popolaDataUltimoContatto(tu);

        //CR -- FILO DIRETTO
        //Metodo per aggiornare esito livello 1 && 2 sul record dettaglio visite
        WGC_TrgActivity_FD.updateEsitoVisitaDT(Trigger.NewMap);
    }

    if(T.isBeforeDelete()) {
      TrgActivity.controlloCancellazioneActivity(tu);
      //TrgActivity.bloccaAzioniActivityNonOwner(tu);
    }

}