/**
* Progetto:         Banca IFIS
* Descrizione:      Trigger su oggetto Opportunità
* Sviluppata il:    08/02/2017
* Developer:        Zerbinati Francesco, Michele Triaca
*/

trigger Opportunity on Opportunity (before insert, before update, before delete, after insert, after update, after delete) {
  Funzionalita__c f = Funzionalita__c.getInstance();
  if (f.DisabilitaTriggers__c) return;
  T tu = T.getInstance();

  if (T.isBeforeInsert()) {
    // rinomina le opportunità con created date - nome account
    if (!f.DisabilitaNamingAutomaticaOpportunita__c) TrgOpportunity.rinominaOpp(tu);
    TrgOpportunity.assegnazioneAnagraficaOperatoriNSA(tu);
    TrgOpportunity.setDataOraChiusura(tu);
    // TrgOpportunity.allineaStageDaStatoPef(tu);

    // MB - TEN: METODO DI VALORIZZAZIONE NUOVI PARAMETRI PER "INVIO NV"
    WGC_TrgOpportunity.setupNewOpportunityFlags(Trigger.new);

    // SV - TEN: ORIGINATOR
    WGC_TrgOpportunity.setupOriginator(Trigger.new);
  }

  if (T.isBeforeUpdate()) {
    if (!f.DisabilitaNamingAutomaticaOpportunita__c) TrgOpportunity.rinominaOpp(tu);
    TrgOpportunity.setDataOraChiusura(tu);
    // TrgOpportunity.aggiornamentoInnescaVendita(tu);
    // TrgOpportunity.allineaStageDaStatoPef(tu);
    TrgOpportunity.notificaChatterContrattiPronti(tu);
    TrgOpportunity.tempFixWizardTeamMutuoMCNSA(tu);
    // GB - TEN: ORIGINATOR
    for(Id ids : trigger.newmap.keyset())
    {
        if(trigger.oldmap.get(ids).get('StageName') == 'Da Lavorare') {
            WGC_TrgOpportunity.setupOriginator(Trigger.new);
        }  
    }
  }

  if (T.isBeforeDelete()) {
    TrgOpportunity.calcolaProcedureAperte(tu);
  }

  if (T.isAfterInsert()) {
    TrgOpportunity.recuperaConsensiPrivacyAzienda(tu);
    TrgOpportunity.calcolaProcedureAperte(tu);
    TrgOpportunity.gestioneTeamMutuoMCNSA(tu);
  }

  if (T.isAfterUpdate()) {
    TrgOpportunity.allineaCessione(tu);
    TrgOpportunity.calcolaProcedureAperte(tu);

    TrgOpportunity.inviaMail(tu);
    TrgOpportunity.recuperaConsensiPrivacyAzienda(tu);
  }

  if (T.isAfterDelete()) {
    TrgOpportunity.calcolaProcedureAperte(tu);
  }
}