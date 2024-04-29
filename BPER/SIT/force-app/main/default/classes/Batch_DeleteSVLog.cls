/****
 * Name			:	Batch_DeleteSVLog
 * Author		:	Ezio Dal Bo @TEN
 * Create Date	:	2020-12-11
 * Description	:	Cancella tutti i record dell'oggetto SV_LOG
 ****/
global class Batch_DeleteSVLog implements Database.Batchable<sObject>,Database.stateful,IRunner {
    
    private static final String COD_CLASSE = 'SVL001';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_DeleteSVLog';
    
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>(); 
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global Numeri_Tecnici__mdt numeriTecnici = (Numeri_Tecnici__mdt)MetadataUtility.getRecordByName('Numeri_Tecnici__mdt', 'DelSVLogMonths');
    global String testoMail = '';
    global Integer numRecordElab = 0;
    global Integer numRecordDeleted = 0;
    global Boolean onError = false;
    List<String> queryFields = new List<String>{'Id','CreatedDate'};
    
    /***
     * IRunner
     ***/
    global void initRunner(List<ScheduledJob__c> schedules) {
        sj.addAll(schedules);
    }
    
    /***
     * Batch
     ***/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer months = Integer.valueOf(numeriTecnici.Valori__c);
        Date today = Date.today();
        today = today.addMonths(-months);
        DateTime periodo_calcolato = DateTime.newInstanceGmt(today.year(), today.month(), 1, 0, 0, 0);
        String query = 'SELECT '+String.join(queryFields, ',')+' FROM SV_Log__c WHERE CreatedDate<:periodo_calcolato';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SV_Log__c> scope) {
        try {
            numRecordElab += scope.size();
            if (!onError) {
                delete scope;
                numRecordDeleted += scope.size();
            }
        }
        catch(Exception exc) {
            System.debug(NOME_CLASSE+' - An exception occurred during delete records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during delete records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            onError = true;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
            SELECT	Id,
            		Status,
            		NumberOfErrors,
            		JobItemsProcessed,
            		TotalJobItems,
            		CreatedBy.Email
            		FROM AsyncApexJob 
            		WHERE Id = :BC.getJobId()
        	];
        
        testoMail = '';
        if (onError) {
            testoMail += '<span style="{color:red;}">Ci sono stati degli errori durante la fase di cancellazione dei record. sono state inviate le mail</span><br/><br/>';
        } 
        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'Numero totale di record elaborati : '+numRecordElab+'<br/>';
        testoMail += 'Numero totale di record eliminati : '+numRecordDeleted+'<br/>';
       
        
        if (debug.Verbose__c) {
        	mandaMail('Recap',testoMail);
        }
        if (sj!=null && sj.size()>0 && !onError) {
            JobRunner.executeNext(sj);
        }
    }
    
    /* public methods */
    /***
     * Name			:	mandaMail
     * Author		:	Ezio Dal Bo @TEN
     * Create date	:	2020-10-28
     ***/
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
    
    /***
     * Name			:	generaMail
     * Author		:	Ezio Dal Bo @TEN
     * Create date	:	2020-10-28
     ***/
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