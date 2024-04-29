/**
* Progetto:         Banca IFIS
* Descrizione:      Trigger su oggetto Task
* Sviluppata il:    31/10/2016
* Ampiamente modificata il: 31/01/2017
* Developer:        Zerbinati Francesco
*/

trigger Task on Task (after insert, after update, before insert, before update, before delete) {
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.DisabilitaTriggers__c) return;
    T tu = T.getInstance();

    if(f.DisabilitaTriggerActivities__c) {
      if(T.isBeforeInsert() || T.isBeforeUpdate()) {
        // chiude subito il task se è esitato
        TrgActivity.chiudiActivityEsitata(tu);
      }
	  
      return;
    }

    if(T.isBeforeInsert()) {
      //TEN - Simone Martinello 14/03/2019
      //Metodo che blocca l'inserimento di un task associato ad una anagrafica se esiste un task ancora aperto associato alla medesima anagrafica
      WGC_TrgActivity.checkTaskAperti(Trigger.New);
      // SV - TEN: ORIGINATOR
      WGC_TrgActivity.setupOriginator(Trigger.new);
      // GB - SET Data Fine
      WGC_TrgActivity.setDataFine(Trigger.new);

      // chiude subito il task se è esitato
      TrgActivity.chiudiActivityEsitata(tu);
      // chiude subito tutte le segnalazioni
      TrgActivity.chiudiSegnalazione(tu);
      // un utente non può inserire attività per un account non suo
      //TrgActivity.bloccaAzioniActivityNonOwner(tu);
      // rinomina i task di tipo segnalazione secondo una naming convention
      TrgActivity.rinominaTask(tu);

      TrgActivity.copiaCommentoSeFinance(tu);

      //CR -- Filo Diretto
      //WGC_TrgActivity_FD.popolaCampiSegnalazione(Trigger.New);
    }

    if(T.isBeforeUpdate()) {
      // chiude il task se esitato
      TrgActivity.chiudiActivityEsitata(tu);
      // gestisce l'ownerId dei task per gli utenti di filo diretto
      TrgActivity.gestisciOwnershipTaskFiloDiretto(tu);
      // un utente non può inserire attività per un account non suo
      //TrgActivity.bloccaAzioniActivityNonOwner(tu);
      // rinomina i task di tipo segnalazione secondo una naming convention
      TrgActivity.rinominaTask(tu);
	  TrgActivity.copiaCommentoSeFinance(tu);

      //Metodo per aggiornate il valore i records di andamentale FD //TODO TEST
	  //A.M. SDHDFNZ-113701 - Apportando una modifica ad un Task già Chiso si conteggia erroneamente +1 nell'andamentale dei contatti Filo Diretto. 
      //WGC_TrgActivity_FD.update_CT_Actual(Trigger.New);
	  WGC_TrgActivity_FD.update_CT_Actual(tu);

	  //SDCHG-6053 CHANGE PROMEMORIA
	  TrgActivity.chiudiPromemoria(tu);

      //CR -- Filo Diretto
      //WGC_TrgActivity_FD.popolaCampiSegnalazione(Trigger.New);

	   //SDHDFNZ-132648 allinea Data_Inizio__c e Data_Fine__c su Activity con StartDateTime e EndDateTime su Task
	  TrgActivity.allineaDataInizioTask(tu);

    }

    if(T.isAfterUpdate()) {
      // esegue un azione specificata nella matrice esiti in base ai livelli esito
      TrgActivity.azioneEsitazioneActivity(tu);
      // crea un task di ricontatto se cè una data di ricontatto (DataRicontatto__c)
      TrgActivity.creaTaskRicontatto(tu);
      // viene sistemato OperatoreFiloDiretto_c se il task viene esitato come "Gia cliente" o "gia contattato"
      TrgActivity.gestisciOwnershipAccountFiloDiretto(tu);

      TrgActivity.popolaDataUltimoContatto(tu);

      //CR -- Filo Diretto //TODO Test
      //WGC_TrgActivity_FD.update_CT_Actual(Trigger.New);

      //CR -- Filo Diretto
      WGC_TrgActivity_FD.updatePrevAvvRapportoDT(Trigger.newMap);

      //CR -- Filo Diretto
      WGC_TrgActivity_FD.updateSegnalazioneDT(Trigger.NewMap);
    }

    if(T.isAfterInsert()) {
      // esegue un azione specificata nella matrice esiti in base ai livelli esito
      TrgActivity.azioneEsitazioneActivity(tu);
      // crea un task di ricontatto se cè una data di ricontatto (DataRicontatto__c)
      TrgActivity.creaTaskRicontatto(tu);

      // gestisce il task con record type "Segnalazione" (presentatore e assegnazione di un CT a Filo Diretto)
      TrgActivity.gestisciSegnalazione(tu);
      // viene sistemato OperatoreFiloDiretto_c se il task viene esitato come "Gia cliente" o "gia contattato"
      TrgActivity.gestisciOwnershipAccountFiloDiretto(tu);

      TrgActivity.popolaDataUltimoContatto(tu);

      //CR -- Filo Diretto
      WGC_TrgActivity_FD.insertSegnalazioneDT(Trigger.NewMap);
    }

    if(T.isBeforeDelete()) {
      // impedisce di cancellare un task se chiuso oppure l'attività non è dell'utente
      TrgActivity.controlloCancellazioneActivity(tu);
      //TrgActivity.bloccaAzioniActivityNonOwner(tu);
    }

}