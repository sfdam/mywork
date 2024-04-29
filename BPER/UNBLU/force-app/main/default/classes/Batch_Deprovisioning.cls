global class Batch_Deprovisioning implements Database.Batchable<sObject>,Database.stateful,IRunner {
    private static final String COD_CLASSE = 'GR004';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_Deprovisioning';
    
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);

    // DK RIMOZIONEDAQUEUE
    global List<User> userUpdateQueues = new List<User>();
    // DK RIMOZIONEDAQUEUE
    
    global String testoMail ='';
    global Integer recordElab=0;
    global Integer errorRecords=0;
    global Integer utentiAggiornati=0;
    global List<String> idErrore=new List<String>();
    global List<String> idAggiornati=new List<String>();
    private List<String> queryFields = new List<String> {
        'Id',
        'Matricola__c',
        'IDCed__c',
        'Attivo__c',
        'Cognome__c',
        'Nome__c',
        'Ruolo_LDAP__c',
        'Team__c',
        'OFS__c',
        'Ruolo_LDAP_Calcolato__c',
        'Profilo_LDAP__c',
        'Vicario__c',
        'Email__c',
        'Da_Elaborare__c',
        'CRM_PermissionSet__c',
        'IdCedFittizia__c'
    };
    global LDAP__c ldapTest = null;
    
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
        
        String query = 'SELECT '+String.join(queryFields, ',')+' FROM LDAP__c WHERE Da_Elaborare__c = TRUE AND (Profilo_LDAP__c = null OR Attivo__c = FALSE)';
        if (Test.isRunningTest()) {
            query += ' LIMIT 200';
        }
        System.debug('*** Batch_Deprovisioning - start - query: '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<LDAP__c> scope) {
        System.debug('*** Batch_Deprovisioning - start - scope: '+scope.size());
        Map<String,LDAP__c> mappaMatricole = new Map<String,LDAP__c>();
        for(LDAP__c ldap : scope){
            mappaMatricole.put(ldap.Matricola__c.replace('U', ''),ldap);
        }
        System.debug('*** Batch_Deprovisioning - start - scope: '+scope.size());
        System.debug('*** Batch_Deprovisioning - start - mappaMatricole: '+mappaMatricole);

        if(!mappaMatricole.isEmpty()){
            List<User> userToUpdate = new List<User>();
            List<User> userList = [SELECT Id, ProfileId,FederationIdentifier,IsActive,UserRoleId,Profilo__c,idced__c, CRM_Polo__c, CRM_Team__c, Ruolo_nel_Contact_Center__c, PTF_RuoloLDAP__c, CRM_PermissionSet__c FROM User WHERE FederationIdentifier IN:mappaMatricole.keyset() AND isActive=true];
            System.debug('*** Batch_Deprovisioning - start - userList: '+userList);
            System.debug('*** Batch_Deprovisioning - start - userList size: '+userList.size());

            LDAP__c currentLdap;
            for(User u : userList){
                currentLdap = mappaMatricole.get(u.FederationIdentifier);
                System.debug('*** Batch_Deprovisioning - start - currentLdap: '+currentLdap);


                /*if(currentLdap != null && ('NEC_CC'.equalsIgnoreCase(u.Profilo__c) || 'NEC_CCSV'.equalsIgnoreCase(u.Profilo__c)) && u.Profilo__c != currentLdap.Profilo_LDAP__c  ){
                    // u.Da_Disattivare_Batch__c = true;
                    u.isActive = false;
                    userToUpdate.add(u);
                }*/
                //if(currentLdap != null && !'NEC_SYSADMIN'.equalsIgnoreCase(u.Profilo__c)  && u.Profilo__c != currentLdap.Profilo_LDAP__c ){
                if(currentLdap != null && !'NEC_SYSADMIN'.equalsIgnoreCase(u.Profilo__c) /*&& !'NEC_CC'.equalsIgnoreCase(u.Profilo__c) && !'NEC_CCSV'.equalsIgnoreCase(u.Profilo__c)*/ && (u.Profilo__c != currentLdap.Profilo_LDAP__c || currentLdap.Attivo__c==false )) {
                    u.isActive = false;
                    /*u.CRM_Polo__c = null;
                    u.CRM_Team__c = null;
                    u.Ruolo_nel_Contact_Center__c = null;*/
                    userToUpdate.add(u);

                    // DK RIMOZIONEDAQUEUE
                    userUpdateQueues.add(u);
                    // DK RIMOZIONEDAQUEUE
                } 
            }

            if(!userToUpdate.isEmpty()){
                OnUserTriggerHandler.skipUpdateMember = true;
                 List<Database.SaveResult> saveResults = Database.update(userToUpdate,false);
                 for(Integer index = 0, size = saveResults.size(); index < size; index++) {
                    Database.SaveResult sr = saveResults[index];
                    User u = userToUpdate[index];
                    u.Id = sr.getId();
                    if (sr.isSuccess()) {
                        utentiAggiornati +=1;
                        idAggiornati.add(u.Id);
                    }
                    else {
                        List<Database.Error> errors = sr.getErrors();
                        Database.Error error = errors[0];
                        System.debug('*** Batch_Deprovisioning - update Error: '+error.getMessage());
                        errorRecords +=1;
                        idErrore.add(u.Id);
                    }
                }

            }
            recordElab+=scope.size();
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

        // DK RIMOZIONEDAQUEUE
        if(!userUpdateQueues.isEmpty()){
            onUserTriggerHandler.updateQueues(userUpdateQueues);
        }
        // DK RIMOZIONEDAQUEUE
        
        testoMail = '';
        
        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'Numero totale di Record elaborati : '+recordElab+'<br/>';
        testoMail += 'Numero totale di update effettuati con successo : '+utentiAggiornati+'<br/>';
        testoMail += 'Lista id utenti aggiornati con successo : '+idAggiornati+'<br/>';
        testoMail += 'Numero totale di update andati in errore : '+errorRecords+'<br/>';
        testoMail += 'Lista id utenti andati in errore : '+idErrore+'<br/>';

        if (debug != null && debug.Verbose__c) {
            mandaMail('Recap',testoMail);
        }

        if (sj!=null && sj.size()>0) {
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
            if (!String.isEmpty(us.Email__c) && debug != null && debug.Email__c) {
                emails.add(us.Email__c);
            }
        }
        if (utenteSviluppatore!=null) {
            if (!String.isEmpty(utenteSviluppatore.ID_Utente__c)) {
                idUtentiSpeciali.add(utenteSviluppatore.ID_Utente__c);
            }
            if (!String.isEmpty(utenteSviluppatore.Email__c) && debug != null && debug.Email__c) {
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