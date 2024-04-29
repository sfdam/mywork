global class Batch_DeleteCaseUnblu implements Database.Batchable<sObject>, Database.stateful, Schedulable {
    private static final String COD_CLASSE = 'GR004';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_DeleteCaseUnblu';

    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);

    public void execute(SchedulableContext sc) {
        Batch_DeleteCaseUnblu batch = new Batch_DeleteCaseUnblu();
        Database.executeBatch(batch, 200);
    }
    
    /**
     * Batch
	***/
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        String query = 'SELECT Id FROM Case WHERE UnbluChatStatus__c = \'abandoned\'';
        if (Test.isRunningTest()) {
            query += ' LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {

        try {
            
            delete scope;
        } catch (Exception exc) {
            System.debug('An Execption occurred : '+exc.getMessage());
            String testoMail = NOME_CLASSE+' - An exception occurred during create user : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
        }
    }   

    global void finish(Database.BatchableContext BC) {}

    public void mandaMail(String tipoMail, String mailBody) {
        String subject = (tipoMail=='Errore' ? 'Errore ' : (tipoMail=='Warning' ? 'Warning ' :'Elaborazione '))+NOME_CLASSE;
        Utenti_Speciali__mdt utenteSviluppatore = (Utenti_Speciali__mdt)MetadataUtility.getRecordByName('Utenti_Speciali__mdt', COD_SVILUPPATORI);
        List<Utenti_Speciali__mdt> utentiSpeciali = (List<Utenti_Speciali__mdt>)MetadataUtility.getRecordByPrefix('Utenti_Speciali__mdt', COD_CLASSE);
        Set<Id> idUtentiSpeciali = new Set<Id>();
        Set<String> emails = new Set<String>();
        for (Utenti_Speciali__mdt us : utentiSpeciali) {
            if (!String.isEmpty(us.ID_Utente__c)) {
                idUtentiSpeciali.add(us.ID_Utente__c);
            }
            if (!String.isEmpty(us.Email__c) && debug.Email__c) {
                emails.add(us.Email__c);
            }
        }
        if (utenteSviluppatore!=null) {
            if (!String.isEmpty(utenteSviluppatore.ID_Utente__c)) {
                idUtentiSpeciali.add(utenteSviluppatore.ID_Utente__c);
            }
            if (!String.isEmpty(utenteSviluppatore.Email__c) && debug.Email__c) {
                emails.add(utenteSviluppatore.Email__c);
            }
        }
        if (idUtentiSpeciali.size()>0) {
            for (Id idUtente : idUtentiSpeciali) {
                generaMail(mailBody,subject,idUtente,emails, utenteSviluppatore);
            }
        }
        else if (emails.size()>0) {
            generaMail(mailBody,subject,null,emails, utenteSviluppatore);
        }
    }
    
    public void generaMail(String mailBody,String subject,Id idUtente,Set<String> addresses, Utenti_Speciali__mdt utenteSviluppatore) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (idUtente!=null) {
            mail.setTargetObjectId(idUtente);
        }
        mail.setSenderDisplayName('Salesforce');
        if (utenteSviluppatore!=null && !String.isEmpty(utenteSviluppatore.Email__c)) {
            mail.setReplyTo(utenteSviluppatore.Email__c);
        }
        mail.setSubject(subject);
        if (!Test.isRunningTest() && addresses.size()>0) {
            mail.setToAddresses(new List<String>(addresses));
        }
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(mailBody);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}