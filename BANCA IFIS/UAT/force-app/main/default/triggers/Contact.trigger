/**
* Progetto:         Banca IFIS
* Descrizione:      Trigger su oggetto Contact
* Sviluppata il:    03/01/2017
* Developer:        Michele Triaca
*/

trigger Contact on Contact (before insert, before update) {
  Funzionalita__c f = Funzionalita__c.getInstance();
  if (f.DisabilitaTriggers__c) return;
  T tu = T.getInstance();

  if(T.isBeforeInsert()) {
    if(f.ControlloCodiceFiscale__c) TrgContact.checkCodiceFiscale(tu);
    TrgContact.associaAccountDiDefault(tu);
    // ricalcolo indirizzo completo
    TrgContact.ricalcolaIndirizzoCompleto(tu);
    TrgContact.truncateFields(tu);
    // inizializzazione e fix di alcuni dati
    TrgContact.inizializzaDati(tu); 
      
    //A.M. -> Start
    TrgContact.AggiornaTeleContact(tu);
    //A.M. -> End  
  }

  if(T.isBeforeUpdate()) {
    if(f.ControlloCodiceFiscale__c) TrgContact.checkCodiceFiscale(tu);
    TrgContact.associaAccountDiDefault(tu);
    // ricalcolo indirizzo completo
    TrgContact.ricalcolaIndirizzoCompleto(tu);
    TrgContact.truncateFields(tu);
    // inizializzazione e fix di alcuni dati
    TrgContact.inizializzaDati(tu);
      
    //A.M. -> Start
    TrgContact.AggiornaTeleContact(tu);
    //A.M. -> End   
  }
}