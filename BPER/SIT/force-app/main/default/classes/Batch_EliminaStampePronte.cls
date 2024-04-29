/**
 * @Name        :   Batch_EliminaStampePronte
 * @CreateDate  :   2023-04-05
 * @Description : 
 * @TestClass   :   Batch_EliminaStampePronteTest 
 */
global with sharing class Batch_EliminaStampePronte implements Schedulable,Database.Batchable<sObject>,Database.stateful,IRunner {

    private static final String COD_CLASSE = 'GR004';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_EliminaStampePronte';

    private Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);

    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    
    private Integer numRecordDeleted = 0;
    private Boolean errorOnDelete = false;
    private Boolean limitDMLError = false;
    private String testoMail      = '';

    global void initRunner(List<ScheduledJob__c> schedules) {
        sj.addAll(schedules);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id from ContentDocument WHERE CreatedDate < TODAY AND Title LIKE \'STAMPA_%\''
            			+ ( Test.isRunningTest() ? ' LIMIT  200' : '' );

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ContentDocument> scope) {
        try {
            if (!errorOnDelete && !limitDMLError) {
                if (Limits.getDmlRows() >= Limits.getLimitDmlRows()) {
                    limitDMLError = true;
                } else {
                    delete scope;
					
                    numRecordDeleted += scope.size();
                }
            }
        } catch(Exception exc) {
            errorOnDelete = true;
            testoMail = NOME_CLASSE + ' - An exception occurred during update records : ' + exc.getMessage() + '<br/>'+  exc.getStackTraceString();
            if(debug.Verbose__c) {
                mandaMail('Errore',testoMail);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        testoMail = '';
        Id idBatch = BC.getJobId();
        String queryAsyncAJ = 'SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email';
        queryAsyncAJ += ' FROM AsyncApexJob WHERE Id = :idBatch';
        AsyncApexJob a = Database.query(queryAsyncAJ);
        testoMail = (this.errorOnDelete ? 
                     '<span style="{color:red;}">Ci sono stati degli errori durante la fase di cancellazione. sono state inviate le mail</span><br/><br/>' : ''
                    );
        testoMail += NOME_CLASSE + ' Apex job ha processato '+ a.TotalJobItems + ' con ' + a.NumberOfErrors + ' errori.<br/>';
        testoMail += 'Totale record cancellati : ' + numRecordDeleted + '<br />'
                     + 'Limite DML raggiunto : ' + limitDMLError;
		
        if(debug.Verbose__c) {
            mandaMail('Recap', testoMail);
        }
    }
    
    global void execute(SchedulableContext SC) {
    	Id batchJobId = Database.executeBatch(new Batch_EliminaStampePronte());
    }

    private void mandaMail(String tipoMail, String mailBody) {
        String subject = (tipoMail=='Errore' ? 'Errore ' : (tipoMail=='Warning' ? 'Warning ' :'Elaborazione '))+NOME_CLASSE;
        Utenti_Speciali__mdt utenteSviluppatore = (Utenti_Speciali__mdt)MetadataUtility.getRecordByName('Utenti_Speciali__mdt', COD_SVILUPPATORI);
        List<Utenti_Speciali__mdt> utentiSpeciali = (List<Utenti_Speciali__mdt>)MetadataUtility.getRecordByPrefix('Utenti_Speciali__mdt', COD_CLASSE);
        Set<Id> idUtentiSpeciali = new Set<Id>();
        Set<String> emails = new Set<String>();
        for(Utenti_Speciali__mdt us : utentiSpeciali) {
            if(!String.isEmpty(us.ID_Utente__c)) {
                idUtentiSpeciali.add(us.ID_Utente__c);
            }
            if(!String.isEmpty(us.Email__c) && debug.Email__c) {
                emails.add(us.Email__c);
            }
        }
        if(utenteSviluppatore!=null) {  
            if(!String.isEmpty(utenteSviluppatore.Email__c) && debug.Email__c) {
                emails.add(utenteSviluppatore.Email__c);
            }
        }
        if(idUtentiSpeciali.size()>0) {
            for(Id idUtente : idUtentiSpeciali) {
            	generaMail(mailBody, subject, idUtente, emails, utenteSviluppatore);
            }
        } else if(emails.size()>0) {
            generaMail(mailBody, subject, null, emails, utenteSviluppatore);
        }
    }

    private void generaMail(String mailBody,String subject,Id idUtente,Set<String> addresses, Utenti_Speciali__mdt utenteSviluppatore) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(idUtente!=null) {
            mail.setTargetObjectId(idUtente);
        }
        mail.setSenderDisplayName('Salesforce');
        if(utenteSviluppatore!=null && !String.isEmpty(utenteSviluppatore.Email__c)) {
            mail.setReplyTo(utenteSviluppatore.Email__c);
        }
        mail.setSubject(subject);
        if(!Test.isRunningTest() && addresses.size()>0) {
            mail.setToAddresses(new List<String>(addresses));
        }
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(mailBody);
        //if(!Test.isRunningTest()) {
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //}
    }
}