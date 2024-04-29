trigger Attore on NDGLinea__c (after insert, after update, before delete, after delete) {
  if (Funzionalita__c.getInstance().DisabilitaTriggers__c) return;
  T tu = T.getInstance();

  if (T.isBeforeDelete()) {
      TrgAttore.deletePConfigurati(tu);
  }

  if (T.isAfterInsert() || T.isAfterUpdate()) {
      TrgAttore.allineaAllegatiTa(tu);
      TrgAttore.calcolaProcedureAperte(tu);
      TrgAttore.recuperaConsensiPrivacyEsecutore(tu);
  }
  if (T.isAfterDelete()) {
      TrgAttore.calcolaProcedureAperte(tu);
  }
}