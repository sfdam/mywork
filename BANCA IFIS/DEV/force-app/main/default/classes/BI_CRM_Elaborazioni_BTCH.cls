global class BI_CRM_Elaborazioni_BTCH implements Database.Batchable<Elaborazioni__c>, Database.AllowsCallouts, Database.Stateful {

    public List<Elaborazioni__c> scope;

    global List<Elaborazioni__c> start(Database.BatchableContext bc) {
        this.scope = [select Id, Name, Processo__c, Stato__c, Esito__c FROM Elaborazioni__c WHERE Stato__c = 'Da elaborare' AND Processo__c = 'Completa anagrafica'];
        return this.scope;
    }

    global void execute(Database.BatchableContext bc, List<Elaborazioni__c> scope) {
        if (scope.size() > 0) {
            //call out jobs
            System.enqueueJob(new AsyncJobs_Q(scope));
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Email list to notify
        try {
            AsyncApexJob aaj = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CompletedDate FROM AsyncApexJob WHERE Id = :BC.getJobId()];

            Parametri_Schedulazioni__c schedulazioniParameters = Parametri_Schedulazioni__c.getInstance();
            String destinationMail = schedulazioniParameters.Mail_Gestori_Schedulazioni__c;

            OrgWideEmailAddress owa = [SELECT id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'CRM Multicanalità' limit 1];

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] { destinationMail };
            mail.setOrgWideEmailAddressId(owa.Id);
            mail.setToAddresses(toAddresses);
            mail.setSubject('Batch Completa anagrafica ' + + aaj.Status);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setPlainTextBody('The apex job processed ' + aaj.TotalJobItems + ' Batches with ' + aaj.NumberOfErrors + ' failures');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }

        catch(Exception ex) {
            System.debug('Eccezione in fase di invio mail batch Completa anagrafica');
        }
    }

    @TestVisible
    public class AsyncJobs_Q implements Queueable, Database.AllowsCallouts {

        List<Elaborazioni__c> elab;

        public AsyncJobs_Q(List<Elaborazioni__c> elab) {
            this.elab = elab;
        }

        public void execute(QueueableContext context) {
            for (Elaborazioni__c record : elab) {
                try {
                    System.debug('Chiamata all\'infoprovider per: ' + record.Id);
                    CreateAccount.WrapperResponse responseValorizza = BI_CRM_AggiornaAnagrafica_CTRL.valorizzaAccount(record.Name);
                    System.debug('responseValorizza: ' + responseValorizza);
                    if (responseValorizza.success == true) {
                        System.debug('responseValorizza = true: ' + responseValorizza.data.get(0));
                        CreateAccount.WrapperResponse responseAggiorna = BI_CRM_AggiornaAnagrafica_CTRL.aggiornaAccount(responseValorizza.data.get(0));
                        if (responseAggiorna.success == true)
                        record.Stato__c = 'Elaborato';
                        else {
                            record.Stato__c = 'Non elaborato';
                            record.Esito__c = 'NDG ' + responseValorizza.data[0].NDGGruppo__c + ' - ' + responseAggiorna.msg;
                        }
                    } else {
                        record.Stato__c = 'Non elaborato';
                        record.Esito__c = 'NDG ' + responseValorizza.data[0].NDGGruppo__c + ' - ' + responseValorizza.msg;
                    }
                    update elab;
                } catch(exception e) {
                    record.Stato__c = 'Non elaborato';
                    record.Esito__c = 'Errore durante l\'elaborazione';
                    System.debug('Errore durante l\'elaborazione: ' + e.getMessage());
                    update elab;
                }
            }
        }
    }
}