/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 24-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        : CR 76756  aggiornamento del nuovo tag (campo "PTF_RiportafogliazioneTAG__c") 
 *                      su tutti gli Account lato database salesforce e avvio processo di sinconizzazione 
 *                      salesforce analytics nel metodo finish con la chiamata della queueable :
 *                      AggiornaMassivamenteTagQueueable
**/

global class Batch_AggiornaMassivamenteTag implements Database.Batchable<sObject>, Database.stateful,Database.AllowsCallouts{
	
    
    //public class Batch_AggiornaMassivamenteTagException extends Exception {}

    private static final String NOME_CLASSE = 'Batch_AggiornaMassivamenteTag';
    private static final String COD_CLASSE = 'GR004';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    global String testoMail ='';
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global boolean sendEmailError = false;
    public static Boolean skipAccountTrigger=false;
    private String oldTag;
    private String newTag;

    public Batch_AggiornaMassivamenteTag(String oldTag,String newtag) {
        this.oldTag = oldTag;
        this.newtag = newtag;
    }


    global Database.QueryLocator start(Database.BatchableContext BC) {
        //AD prelevo tutti gli account con il vecchio TAG
        System.debug('AD Batch_AggiornaMassivamenteTag start');
        System.debug('AD Batch_AggiornaMassivamenteTag oldTag : ' +  oldTag );
        System.debug('AD Batch_AggiornaMassivamenteTag newtag : ' +  newtag );
        //AD ATTENZIONE il valore oldTag deve essere popolato 
        String query = 'select id,PTF_RiportafogliazioneTAG__c from Account where PTF_RiportafogliazioneTAG__c =: oldTag ' ;
		System.debug('AD Batch_AggiornaMassivamenteTag query : ' +query);


        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        
        System.debug('AD Batch_AggiornaMassivamenteTag execute');
        List<Account> accountToUpdate = new List<Account>();
        testoMail = '';
        try {


            
            if(scope.size()>0){
                System.debug('AD Batch_AggiornaMassivamenteTag account trovati');
                //throw new Batch_AggiornaMassivamenteTagException('errore');
 
                for(Account acc : scope){
                    acc.PTF_RiportafogliazioneTAG__c=newTag;
                    accountToUpdate.add(acc);
                }
    
                if(accountToUpdate.size()>0){
                    System.debug('AD Batch_AggiornaMassivamenteTag modifico account');
                    skipAccountTrigger=true;
                    update accountToUpdate;
                    
                }
            }else{
                System.debug('AD Batch_AggiornaMassivamenteTag nessun account da modificare');
                //throw new Batch_AggiornaMassivamenteTagException('errore');

            }  
            
        } catch (Exception exc) {
            System.debug('AD Batch_AggiornaMassivamenteTag Exception : ' + exc);
            System.debug('An Execption occurred : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during updateRuoloUtente : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            testoMail = '';
        }
    }   

    global void finish(Database.BatchableContext BC) {

        System.debug('AD Batch_AggiornaMassivamenteTag finish');
    
        try{
            
            //AD al finish della batch chiamo la queueable 'AggiornaMassivamenteTagQueueable'
            //che si occupa di aggiornare i dati di account su salesforce Analytics
            if(!Test.isRunningTest()){
                System.debug('AD chiamo sync analytics');
                System.enqueueJob(new AggiornaMassivamenteTagQueueable());
            }

            if(Test.isRunningTest() && sendEmailError){
                mandaMail('Errore','errore simulato batch');
            }
            
        }catch(Exception e){
            
            System.debug('AD Batch_AggiornaMassivamenteTag call executeConnectorSync error : ' + e);

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
        System.debug('AD generaMail');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //Set<String> testAddress = new Set<String>{'alessandro.dinardo@lutech.it'};//AD email statica per i test 
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
            //mail.setToAddresses(new List<String>(testAddress));//AD email statica per i test
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