/****
 * Name		:	Batch_UpdateGerarchiaTables
 * Author	:	Ezio Dal Bo @TEN
 ****/
global class Batch_UpdateGerarchiaTables implements Database.Batchable<sObject>,Database.stateful,IRunner {
    private static final String COD_CLASSE = 'GTAB001';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_UpdateGerarchiaTables';
    
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Boolean onError = false;
    global String testoMail ='';
    global Integer numRecord = 0;
    global Integer recordUpdated = 0;
    global String sobjectType = '';
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global List<String> sobjectToManage = new List<String>{'Struttura_Banca__c','LDAP__c'};
    private List<String> queryFields = new List<String> {'Id','Da_Elaborare__c'};
        
   	/***
   	* IRunner
	***/
    global void initRunner(List<ScheduledJob__c> schedules) {
        this.sj.addAll(schedules);
    }
    
    /**
     * Batch
	***/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        sobjectType = sobjectToManage.remove(0);
        if ('Struttura_Banca__c'.equals(sobjectType)) {
            queryFields.add('Cambio_Stato__c');
        }
        String query = 'SELECT '+String.join(queryFields, ',')+' FROM '+sobjectType+' WHERE Da_Elaborare__c=TRUE';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        try {
            numRecord += scope.size();
            if (!onError) {
        		for (sObject so : scope) {
            		so.put('Da_Elaborare__c',false);
                    if ('Struttura_Banca__c'.equals(sobjectType)) {
                        so.put('Cambio_Stato__c',false);
                    }
        		}
                update scope;
                recordUpdated += scope.size();
            }
        }
        catch(Exception exc) {
            System.debug(NOME_CLASSE+' - An exception occurred during update records : '+exc.getMessage());
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
            testoMail += '<span style="{color:red;}">Ci sono stati degli errori durante la fase di gestione dei record. sono state inviate le mail</span><br/><br/>';
        }
        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' job con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'Tabella : '+sobjectType+'<br/>';
        testoMail += 'Numero totale di Record elaborati : '+numRecord+'<br/>';
        testoMail += 'Numero totale di Record updatati : '+recordUpdated+'<br/>';
        
        if (debug.Verbose__c) {
        	mandaMail('Recap',testoMail);
        }
        if (sobjectToManage.size()>0 && !Test.isRunningTest()) {
            Batch_UpdateGerarchiaTables b = new Batch_UpdateGerarchiaTables();
            b.sobjectToManage = sobjectToManage;
            Database.executeBatch(b,200);
        }
        else if (sj!=null && sj.size()>0 && !onError) {
            JobRunner.executeNext(sj);
        }
    }
    
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