trigger Certificazione on Certificazione__c (before insert, after insert, before update, after update, before delete, after delete) {
  if (Funzionalita__c.getInstance().DisabilitaTriggers__c) return;
  T tu = T.getInstance();

  if (T.isBeforeInsert()) {
    TrgCertificazione.validazioneCertificazione(tu);
  }

  if (T.isAfterInsert()) {
    TrgCertificazione.calcolaTotalePreventivo(tu);
    TrgCertificazione.syncDebitori(tu);
    TrgCertificazione.syncParametri(tu);
  }

  if (T.isBeforeUpdate()) {
    TrgCertificazione.validazioneCertificazione(tu);
  }

  if (T.isAfterUpdate()) {
    TrgCertificazione.calcolaTotalePreventivo(tu);
    TrgCertificazione.syncDebitori(tu);
    TrgCertificazione.syncParametri(tu);
  }

  if (T.isBeforeDelete()) {
    TrgCertificazione.eliminaAllegati(tu);
  }

  if (T.isAfterDelete()) {
    TrgCertificazione.calcolaTotalePreventivo(tu);
    TrgCertificazione.syncDebitori(tu);
    TrgCertificazione.syncParametri(tu);
  }
}