/**
* Progetto:         Banca IFIS
* Descrizione:      Trigger su oggetto Account
* Sviluppata il:    14/09/2016
* Developer:        Zerbinati Francesco, Michele Triaca
*/

trigger Account on Account (before insert, before update, after update, after insert) {
  Funzionalita__c f = Funzionalita__c.getInstance();
  if (f.DisabilitaTriggers__c) return;
  T tu = T.getInstance();

  if (T.isBeforeInsert()) {
    // TEN - Disabilita per caricamenti batch DWH
    if (f.WGC_disabilita_per_batch__c != true) {
      // all'inserimento popola settore dato codice ateco
      TrgAccount.popolaSettoreDaATECO(tu);
      // gestione Mutuo MCC
      TrgAccount.trgAssociazioneInBaseCAP(tu);
      // ottiene il cab del comune a partire dal nome
      TrgAccount.getCabComune(tu);
      //Modificato da Ten il 30/01/2019, commentata chiamata a metodo settaProprieta
      // setto presentatore e fd
      //TrgAccount.settaProprieta(tu);
      // inizializzazione e fix di alcuni dati
      TrgAccount.inizializzaDati(tu);

      // ricalcolo indirizzo completo
      TrgAccount.ricalcolaIndirizzoCompleto(tu);
    }
    // un utente leasing superuser non può essere owner di un account
    // TrgAccount.gestisciOwner(tu);

    // TEN - inserimento utenti: Owner, Spec.Factoring, Spec.FiloDiretto, Spec.Erariale
    WGC_TrgAccount.manageAccountUsers(Trigger.new);

    // SV TEN - inserimento originator e originator dettaglio
    WGC_TrgAccount.setupOriginator(Trigger.new);

    //se cambia il campo GestoreCliente__c, deve cambiare anche il GestoreClienteNome__c
    TrgAccount.cambiaNomeGestoreCliente(tu);
      
    //A.M. -> Start
    TrgAccount.AggiornaTelefono(tu);
    //A.M. -> End  
  }

  if (T.isBeforeUpdate()) {
    // TEN - Disabilita per caricamenti batch DWH
    if (f.WGC_disabilita_per_batch__c != true) {
      //TEN - Metodo per sbloccare gli account bloccati
      //WGC_TrgAccount.unlockBlockedAccount(Trigger.New);
      // aggiorna il settore dato un nuovo codice ateco
      TrgAccount.popolaSettoreDaATECO(tu);
      // controlla se si ha una richiesta di assegnazione (tremite campo StatoAssegnazione__c == 'Richiesta')
      // TEN SV - LOGGICA RICHIESTA ASSEGNAZIONE GESTITA DA FLOW
      //TrgAccount.preparaProcessoAssegnazione(tu);
      // resetta lo stato di assegnazione se è approvata/rifiutata
      // TEN SV - LOGGICA RICHIESTA ASSEGNAZIONE GESTITA DA FLOW
      //TrgAccount.resettaStatoAssegnazione(tu);
      // stabilisce priorità dalla matrice
      TrgAccount.stabilisciPriorita(tu);
      // ottiene il cab del comune a partire dal nome
      TrgAccount.getCabComune(tu);
      //Modificato da Ten il 30/01/2019, commentata chiamata a metodo settaProprieta
      // setto presentatore e fd
      //TrgAccount.settaProprieta(tu);
      // inizializzazione e fix di alcuni dati
      TrgAccount.inizializzaDati(tu);
      // ricalcolo indirizzo completo
      TrgAccount.ricalcolaIndirizzoCompleto(tu);
    }
    // Associazioni in base CAP per TiAnticipo
    TrgAccount.trgAssociazioneInBaseCAP(tu);
    // un utente leasing superuser non può essere owner di un account
    // TrgAccount.gestisciOwner(tu);
    //se cambia il campo GestoreCliente__c, deve cambiare anche il GestoreClienteNome__c
    TrgAccount.cambiaNomeGestoreCliente(tu);
    //adione - avvisa specialista factoring precedente del cambio assegnazione
	TrgAccount.avvisaCambioAssegnazione(tu);     
    //A.M. -> Start
    TrgAccount.AggiornaTelefono(tu);
    //A.M. -> End  
  }

  if (T.isAfterUpdate()) {
    // TEN - Disabilita per caricamenti batch DWH
    if (f.WGC_disabilita_per_batch__c != true) {
      //TEN - Metodo per sbloccare gli account bloccati
      //WGC_TrgAccount.unlockBlockedAccount(Trigger.New);
      // se è cambiato il nome, aggiorna il nome del referente campagna
      TrgAccount.allineaReferenteCampagna(tu);
      TrgAccount.cambiaOwnerAttivita(tu);
      // cambia filiale
      TrgAccount.cambiaFiliale(tu);
      //Se è stato richiesto un cambio di assegnatario, questo metodo fa partire il processo approvativo
      // TEN SV - LOGGICA RICHIESTA ASSEGNAZIONE GESTITA DA FLOW
      // TrgAccount.avviaProcessoAssegnazione(tu);

      TrgAccount.gestisciAccountTeam(tu);

      //CR - Filo Diretto
      //Metodo che aggiorna il record di dettaglio visite con il settorista e la sua filiale di compotenza recuperata dall'utente
      WGC_TrgAccount.updateSettoristaFilialeDT(Trigger.NewMap);
    }
  }

  if (T.isAfterInsert()) {
    // TEN - Disabilita per caricamenti batch DWH
    if (f.WGC_disabilita_per_batch__c != true) {
      // creo un contatto telefonico per l'owner dell'account (solo se è un commerciale o un filo diretto)
      //TEN - SM 29/03/2019 Commentato per requisiti
      //if (!f.DisabilitaCreazioneCTDopoInsertAcc__c && !TrgAccount.disabilitaCreazioneCTDopoInsertAccount) TrgAccount.creaContattoTelefonico(tu);
      //Quando si crea un nuovo prospect o cambia il titolare si deve aggiornare il campo filiale sull'account
      //con la filiale dello sviluppatore
      TrgAccount.cambiaFiliale(tu);

      TrgAccount.gestisciAccountTeam(tu);
    }
    
    //Creo un contact "referente campagna" associato all'account
    TrgAccount.creaReferenteStandard(tu);
  }
}