public without sharing class QbleArricchimentoError implements Queueable, Database.AllowsCallouts {
    
    public List<Id> accountIds;

    public QbleArricchimentoError() {
        Map<Id,Account> accounts = new Map<Id,Account>([SELECT Id FROM Account WHERE Errore_Monitoraggio__c = true]);
        this.accountIds = new List<Id>(accounts.keySet());
    }

    public QbleArricchimentoError(List<Id> accountIds) {
        this.accountIds = accountIds;
    }

    public void execute(QueueableContext ctx) {
        if(this.accountIds.isEmpty()) {
            return;
        }

        Id accountId = this.accountIds.remove(0);
        Map<String,Object> response = TXT_CalloutHandler.arricchimentoAction(accountId);
        System.debug('@@@ response ' + response);

        if(!this.accountIds.isEmpty() && !Test.isRunningTest()) {
           System.enqueueJob(new QbleArricchimentoError(this.accountIds)); 
        }
    }
}