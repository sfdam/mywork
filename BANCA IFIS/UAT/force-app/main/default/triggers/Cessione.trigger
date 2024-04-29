trigger Cessione on Cessione__c (before insert, after insert, before update, after update, before delete) {
  if (Funzionalita__c.getInstance().DisabilitaTriggers__c) return;
  T tu = T.getInstance();

  if (T.isBeforeInsert()) {

    TrgCessione.popolaDataUltimoAccesso(tu);

    TrgCessione.rinominaCessione(tu);

    TrgCessione.assegnaCoda(tu);
  }

  if (T.isAfterInsert()) {
    TrgCessione.upsertOpportunity(tu);

    TrgCessione.calcolaSpeseIstruttoria(tu);

    TrgCessione.setAttoriDefault(tu);

  }

  if (T.isBeforeUpdate()) {
    TrgCessione.popolaTimestamp(tu);
  }

  if (T.isAfterUpdate()) {

    // solo per le opportunità "in lavorazione"
    TrgCessione.upsertOpportunity(tu);

    TrgCessione.calcolaSpeseIstruttoria(tu);

    TrgCessione.aggiornaStatoOpty(tu);

    TrgCessione.aggiornaScopoRapporto(tu);

    TrgCessione.inviaMail(tu);
  }

  if (T.isBeforeDelete()) {
    // solo per le opportunità "in lavorazione"
    TrgCessione.deleteOpportunity(tu);
  }
}