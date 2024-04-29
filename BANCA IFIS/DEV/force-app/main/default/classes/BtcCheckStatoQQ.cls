/**
* Progetto:         Banca IFIS
* Developer:        Michele Triaca
* Description:      Batch che mette in stato scaduto i questionari qualitativi con data fine validità superata
*/
global class BtcCheckStatoQQ implements Database.Batchable<sObject> {

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator('SELECT Id FROM QuestionarioQualitativo__c WHERE FineValidita__c <= TODAY AND Stato__c = \'Confermato\'');
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    U.massSet(scope, 'Stato__c', 'Scaduto');
    update scope;
  }

  global void finish(Database.BatchableContext BC) {}
}