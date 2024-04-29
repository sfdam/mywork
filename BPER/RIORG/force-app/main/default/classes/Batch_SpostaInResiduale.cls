/****
 * Name			:	Batch_SpostaInResiduale
 * Create Date	:	2021-03-11
 * Author 		:	Giorgio Bonifazi @TEN
 ****/

/****
  * Auhtor		:	Alessandro Lumaca
  * Label       :   CR NEC #57552
  * Modify Date	:	2022-12-05
  * Modify		:  	PORTAFOGLIO RESIDUALE - INTEGRAZIONE CR NEC 
***/
global class Batch_SpostaInResiduale implements Database.Batchable<sObject>,Database.stateful,IRunner,Database.AllowsCallouts {

    private static final String COD_CLASSE = 'SR001';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_SpostaInResiduale';
    
    

    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global String testoMail = '';
    
    List<WorkOrder> accountWithIter = new  List<WorkOrder>();
    
    global void initRunner(List<ScheduledJob__c> schedules) {
        sj.addAll(schedules);
    }

    global static Boolean fireTrigger = false; 


    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Date tmpDate = Date.today().addDays(-90);
        Date dt = Date.today();

        // CR NEC #57552
        //String query = 'SELECT PTF_Filiale__c, Id, PTF_StatoCRM__c, PTF_DaysSinceDeactivation__c, PTF_DeactivationDate__c, PTF_Portafoglio__c  FROM Account WHERE PTF_Portafoglio__c !=null and ModelloDiServizio__c !=\'Residuale\' and  RecordType.DeveloperName IN (\'PersonAccount\',\'IndustriesBusiness\',\'Cointestazione\') and PTF_DeactivationDate__c <= :tmpDate  and (PTF_StatoCRM__c =\'NATT\' OR PTF_StatoCRM__c =\'EST\')';
        String query = 'SELECT PTF_Filiale__c, Id, PTF_StatoCRM__c, PTF_DaysSinceDeactivation__c, PTF_DeactivationDate__c,'
        +'  PTF_Portafoglio__c, PTF_Portafogliato__c  FROM Account' 
        + ' WHERE PTF_Portafogliato__c = true and ModelloDiServizio__c NOT IN (\'Residuale\', \'Assente\')'
        + ' AND RecordType.DeveloperName IN (\'PersonAccount\',\'IndustriesBusiness\',\'Cointestazione\') AND ' 
        + ( (dt.month() == 12 && dt.day() == 31) ?
        ' PTF_DeactivationDate__c = THIS_YEAR' : ' PTF_DeactivationDate__c = LAST_YEAR')
        + ' AND (PTF_StatoCRM__c =\'NATT\' OR PTF_StatoCRM__c =\'EST\')';
        // CR NEC #57552 -- Fine

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        Set<String> filiali = new Set<String>();
        Set<String> accountsIds = new Set<String>();
        Map<String,String> mapFilialeWallet = new Map<String,String>();
        list<Account> accountToUpdate = new list<Account>();
       
        System.debug('SCOPE**'+scope);

            for(Account acc : scope){

                filiali.add(acc.PTF_Filiale__c);
                accountsIds.add(acc.Id);
            }
            accountWithIter = [SELECT Id FROM WorkOrder WHERE AccountId in :accountsIds and Status = 'Pending'] ;


            List<Wallet__c> listWallet = [SELECT id , PTF_Filiale__c FROM Wallet__c WHERE PTF_ModelloDiServizio__c = 'Residuale' AND PTF_Filiale__c IN :filiali];

                for(Wallet__c w : listWallet){

                    mapFilialeWallet.put(w.PTF_Filiale__c,w.Id);
                }

                for(Account acc : scope){

                    if(mapFilialeWallet.containsKey(acc.PTF_Filiale__c)){

                        acc.PTF_Portafoglio__c = mapFilialeWallet.get(acc.PTF_Filiale__c);
                    
                        accountToUpdate.add(acc);
                    }
                }
                try{
                 
                fireTrigger = true ;
                update accountToUpdate;
                 

                }catch(Exception exc) {
                    System.debug(NOME_CLASSE+' - An exception occurred during update records : '+exc.getMessage());
                    testoMail = NOME_CLASSE+' - An exception occurred during update records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
                    if (debug.Verbose__c) {
                    mandaMail('Errore',testoMail);
                    }
                    
                }     
    }

    global void finish(Database.BatchableContext BC) {

        List<String> listIdAccountWithIter = new List<String>();
        Map<String,Object> response = new Map<String,Object>();
        testoMail = '';
        
        if (sj!=null && sj.size()>0) {
            JobRunner.executeNext(sj);
        }
        System.debug('accountWithIter SIZE '+accountWithIter.size());
        if(accountWithIter.size()>0)
        {
            for(WorkOrder i:accountWithIter){
                listIdAccountWithIter.add(i.id);
            }
            if (!Test.isRunningTest()) {
                response = AnnullaIterController.closeIterFromResiduale(listIdAccountWithIter);
            }else{
                response.put('errorMessage','test');
            }
            
                if(response.containsKey('errorMessage')){
                    System.debug('Errore elaborazione iter pending: '+response);
                    testoMail = testoMail + NOME_CLASSE + ' : nel processo di chiusura degli iter pending , si é verificato il seguente errore di elaborazione: ' +response+ '<br/>';
                    if (debug.Verbose__c) {
                        mandaMail('Errore chiusura Iter Pending',testoMail);
                    }  
                }
            
            
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