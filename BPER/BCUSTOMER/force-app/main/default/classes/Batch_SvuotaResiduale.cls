/****
 * Name         :   Batch_SvuotaResiduale
 * Create Date  :   2022-12-05
 * Author       :   Alessandro LUMACA @TEN
 ****/

global with sharing class Batch_SvuotaResiduale implements Database.Batchable<sObject>,Database.stateful,IRunner,Database.AllowsCallouts  {

    private static final String COD_CLASSE = 'GR004';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_SvuotaResiduale';
    global Boolean errorOnCreate = false;
    private static Integer numAccount = 0;
    

    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Debug__mdt debug = (Debug__mdt) MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global String testoMail = '';
        
    List<WorkOrder> accountWithIter = new  List<WorkOrder>();
    
    global void initRunner(List<ScheduledJob__c> schedules) {
        sj.addAll(schedules);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Date dt = Date.today();
        
        String query = 'SELECT Id, PTF_DeactivationDate__c, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_Filiale__c'
                        + ' FROM Account'
                        + ' WHERE PTF_DeactivationDate__c != null '
                        + ' AND RecordType.DeveloperName IN (\'PersonAccount\',\'IndustriesBusiness\',\'Cointestazione\')' 
                        + ' AND ModelloDiServizio__c = \'Residuale\' AND ' 
                        + ( (dt.month() == 12 && dt.day() == 31) ?
                        ' PTF_DeactivationDate__c = THIS_YEAR' : ' PTF_DeactivationDate__c = LAST_YEAR')
                        + ( Test.isRunningTest() ? ' LIMIT 200' : '');
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        try{

            numAccount += scope.size();
    
            for(Account account : scope) {
                account.ModelloDiServizio__c = 'Non Portafogliati';
                account.PTF_DeletionDate__c  = Date.today();
                account.PTF_Portafoglio__c   = null;
                account.PTF_Filiale__c = null;
            }
    
            update scope;
        }catch(Exception exc){
            // intercept the error
            // set a boolean variable to true so the process is "blocked"
            System.debug(NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            errorOnCreate = true;
        }
    }

    global void finish(Database.BatchableContext BC) {

        AsyncApexJob a = [
                SELECT  Id,
                        Status,
                        NumberOfErrors,
                        JobItemsProcessed,
                        TotalJobItems,
                        CreatedBy.Email
                        FROM AsyncApexJob 
                        WHERE Id = :BC.getJobId()
                ];
        testoMail = '';
        if (errorOnCreate) {
            testoMail += '<span style="{color:red;}">Ci sono stati degli errori durante la fase di gestione dei record. sono state inviate le mail</span><br/><br/>';
        }

        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'NDG tolti dal residuale: ' + numAccount;

        if (debug.Verbose__c) {
            mandaMail('Recap',testoMail);
        }

        if (sj!=null && sj.size()>0 && !errorOnCreate && !Test.isRunningTest()) {
            JobRunner.executeNext(sj);
        }
    }

    public void mandaMail(String tipoMail, String mailBody) {
        String subject = (tipoMail=='Errore' ? 'Errore ' : (tipoMail=='Warning' ? 'Warning ' :'Elaborazione ')) + NOME_CLASSE;
        Utenti_Speciali__mdt utenteSviluppatore = (Utenti_Speciali__mdt) MetadataUtility.getRecordByName('Utenti_Speciali__mdt', COD_SVILUPPATORI);
        List<Utenti_Speciali__mdt> utentiSpeciali = (List<Utenti_Speciali__mdt>) MetadataUtility.getRecordByPrefix('Utenti_Speciali__mdt', COD_CLASSE);
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
        if(utenteSviluppatore != null) { 
            if(!String.isEmpty(utenteSviluppatore.Email__c) && debug.Email__c) {
                emails.add(utenteSviluppatore.Email__c);
            }
        }
        if(idUtentiSpeciali.size() > 0) {
            for (Id idUtente : idUtentiSpeciali) {
                generaMail(mailBody,subject,idUtente,emails, utenteSviluppatore);
            }
        } else if(emails.size() > 0) {
            generaMail(mailBody, subject, null, emails, utenteSviluppatore);
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