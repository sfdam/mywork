/****
 * Name			:	Batch_CheckStatusFinancialAccount
 * Author		:	Ezio Dal Bo @TEN
 * Create Date	:	2020-12-10
 * Description	:	Impostare i campi FinServ__Active__c  = FALSE e FinServ__EndDate__c alla data di chiusura del record correlato, per tutti i record Financial Account Role
 * 					dove il campo del record padre è FinServ__Status__c = 'ESTINTO'
 ****/
global class Batch_CheckStatusFinancialAccount implements Database.Batchable<sObject>,Database.stateful,IRunner {
    
    private static final String COD_CLASSE = 'FAR001';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_CheckStatusFinancialAccount';
    
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>(); 
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global String testoMail = '';
    global Integer numRecordElab = 0;
    global Integer numRecordUpdated = 0;
    global Boolean onError = false;
    List<String> queryFields = new List<String>{'Id','FinServ__FinancialAccount__c','FinServ__EndDate__c','FinServ__Active__c','FinServ__FinancialAccount__r.FinServ__CloseDate__c','FinServ__FinancialAccount__r.FinServ__Status__c'};
        
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
        String query = 'SELECT '+String.join(queryFields, ',')+' FROM FinServ__FinancialAccountRole__c WHERE FinServ__EndDate__c = NULL AND FinServ__FinancialAccount__r.FinServ__Status__c=\'ESTINTO\' AND FinServ__FinancialAccount__r.FinServ__CloseDate__c!=NULL';   
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<FinServ__FinancialAccountRole__c> scope) {
        
        try {
            numRecordElab += scope.size();
            if (!onError) {
            	for (FinServ__FinancialAccountRole__c far : scope) {
                    far.FinServ__Active__c = false;
                    far.FinServ__EndDate__c = far.FinServ__FinancialAccount__r.FinServ__CloseDate__c;
            	}
            
            	update scope;
            	numRecordUpdated += scope.size();
            }
        }
        catch(Exception exc) {
            System.debug(NOME_CLASSE+' - An exception occurred during udpate records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during update records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
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
            testoMail += '<span style="{color:red;}">Ci sono stati degli errori durante la fase di aggiornamento dei record. sono state inviate le mail</span><br/><br/>';
        } 
        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'Numero totale di record elaborati : '+numRecordElab+'<br/>';
        testoMail += 'Numero totale di record aggiornati : '+numRecordUpdated+'<br/>';
       
        
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