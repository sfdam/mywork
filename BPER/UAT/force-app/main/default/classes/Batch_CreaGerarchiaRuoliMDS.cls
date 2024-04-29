global class Batch_CreaGerarchiaRuoliMDS implements Database.Batchable<sObject>,Database.stateful,IRunner {

    private static final String COD_CLASSE = 'GR007';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_CreaGerarchiaRuoliMDS';
    global Boolean errorOnCreate = false;
    global Integer recordElab=0;
    global Integer recordCreati=0;
    global String testoMail ='';
    
    Set<String> mdsToExclude = new Set<String>{'LARGE CORPORATE','BUSINESS ALTRI','NON PORTAFOGLIATI'};
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    Map<String, ServiceModel__c> servceModelMap {
        get{
            if(servceModelMap != null) return servceModelMap;
            servceModelMap = new Map<String, ServiceModel__c>();
            for(ServiceModel__c serviceModel : [SELECT id, Name, PTF_NameAbbreviation__c FROM ServiceModel__c]){
                
                servceModelMap.put(serviceModel.PTF_NameAbbreviation__c, serviceModel);
            }
            return servceModelMap;
        }set;
    }

    /***
     * IRunner
     ***/
    global void initRunner(List<ScheduledJob__c> schedules) {
        this.sj.addAll(schedules);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id,IDCed__c,IDCed_Padre__c,Stato__c,Descrizione__c,Da_Elaborare__c,Cambio_Stato__c FROM Struttura_Banca__c WHERE Stato__c IN (\'A\',\'D\') AND Nome_Livello__c IN (\'FILIALE\', \'FILIALE CAPOFILA\', \'SPORTELLO DIPENDENTE\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Struttura_Banca__c> scope) {

        try{
            Set<String> groupNames = new Set<String>();
            for(Struttura_Banca__c sb : scope){
                for(String mds: servceModelMap.keySet()){
                    groupNames.add('RIDCED' + sb.IDCed__c + '_' + mds);
                }
            }

            Set<String> existingGroupSet = SV_Utilities.keyBy([SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN: groupNames], 'DeveloperName').keySet();
            List<Group> groupsToInsert = new List<Group>();
            for(Struttura_Banca__c sb : scope){
                for(String mds: servceModelMap.keySet()){

                    if(!existingGroupSet.contains('RIDCED' + sb.IDCed__c + '_' + mds)){
                        groupsToInsert.add(new Group(
                            DeveloperName = 'RIDCED' + sb.IDCed__c + '_' + mds,
                            Name = 'RIDCED' + sb.IDCed__c + '_' +  mds,
                            Type='Regular'
                            ));
                    }
                }
            }
            insert groupsToInsert;
            recordCreati += groupsToInsert.size();
            recordElab += scope.size();
        }catch(Exception exc){
            System.debug(NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            errorOnCreate = true;
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

        if (errorOnCreate) {
            testoMail += '<span style="{color:red;}">Ci sono stati degli errori durante la fase di gestione dei record. sono state inviate le mail</span><br/><br/>';
        }

        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'Numero totale di Record elaborati : '+recordElab+'<br/>';
        testoMail += 'Numero totale di Record di gruppi creati: '+recordCreati+'<br/>';
        if (debug.Verbose__c) {
        	mandaMail('Recap',testoMail);
        }

        if (sj!=null && sj.size()>0 && !errorOnCreate) {
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