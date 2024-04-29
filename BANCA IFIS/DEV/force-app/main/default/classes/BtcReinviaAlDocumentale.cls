/**
* Progetto:         Banca IFIS
* Developer:        Michele Triaca
* Description:      Batch che prova a reinviare al documentale i documenti andati in errore. Necessario in quanto
*                   il servizio che scrive su filenet fallisce una volta su 2
*/
global class BtcReinviaAlDocumentale implements Database.Batchable<sObject>, Database.AllowsCallouts {

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator('SELECT ID, Opportunita__c FROM Allegato__c WHERE IdDocumentale__c = NULL AND Opportunita__r.IdCartella__c != NULL');
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    Allegato__c a = (Allegato__c) scope[0];
    QbleInvioDocumenti q = new QbleInvioDocumenti(
      new QbleInvioDocumenti.QbleInvioDocumentiInput(a.Opportunita__c, a.Id)
    );
    q.execute(null);
  }

  global void finish(Database.BatchableContext BC) {}
}