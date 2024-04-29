global class Batch_Disattivazione_User implements Database.Batchable<sObject>,Database.stateful,IRunner {
    private static final String COD_CLASSE = 'GR004';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_Disattivazione_User';
    
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    
    global Set<Id>  usersToDeactivate   = new Set<Id>(); //lista totale
    global List<Id> usersToElaborate    = new List<Id>(); //lista degli user rimasti da elaborare
    global List<Id> usersToElaborateTot = new List<Id>(); //lista totale degli users da lavorare

    global String  testoMail        ='';
    global Integer recordElab       =0;
    global Integer errorRecords     =0;
    global Integer ctmEliminati     =0;
    global Integer usersDisattivati =0;
    global Integer usersInErrore    =0;
    global Integer recordTotali     =0;
    global Integer erroriTotali     =0;
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
        if(usersToElaborateTot.isEmpty()){
            List<User> userlist = [SELECT Id FROM User WHERE Da_Disattivare_Batch__c = true];
            List<Id> idList = new List<Id>();
            for(User u : userList){
                usersToElaborateTot.add(u.Id);
            }
            usersToElaborate.addAll(usersToElaborateTot);
        }
        String idUser = !usersToElaborate.isEmpty() ? usersToElaborate.get(0) : null;
        //String query = 'Select id, MemberId from CaseTeamMember where MemberId IN: idList';
        String query = 'Select id, MemberId from CaseTeamMember where MemberId = \''+idUser+'\'';
        if (Test.isRunningTest()) {
            query += ' LIMIT 200';
        }
        System.debug('*** Batch_Disattivazione_User - start - query: '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CaseTeamMember> scope) {
        System.debug('*** Batch_Disattivazione_User - start - scope: '+scope.size());
        if(!scope.isEmpty()){
            usersToDeactivate.add(scope.get(0).MemberId);
            System.debug('*** Batch_Disattivazione_User - start - scope: '+scope.size());

            try{
                List<Database.DeleteResult> saveResults = Database.delete(scope,false);
                for(Integer index = 0, size = saveResults.size(); index < size; index++) {
                    Database.DeleteResult sr = saveResults[index];
                    if (sr.isSuccess()) {
                        ctmEliminati +=1;
                    }
                    else {
                        List<Database.Error> errors = sr.getErrors();
                        Database.Error error = errors[0];
                        System.debug('*** Batch_Disattivazione_User - update Error: '+error.getMessage());
                        errorRecords +=1;
                    }
                }

                recordElab+=scope.size();
            }catch(Exception e){
                System.debug('*** Batch_Disattivazione_User - catch Error: '+e.getStackTraceString());
            }

        }
    }

    global void finish(Database.BatchableContext BC) {


        AsyncApexJob a = [
            SELECT  Id,Status,NumberOfErrors,JobItemsProcessed,TotalJobItems,CreatedBy.Email FROM AsyncApexJob  WHERE Id = :BC.getJobId()];

        recordTotali += a.TotalJobItems;
        erroriTotali += a.NumberOfErrors;

        usersToElaborate.remove(0);
        if(!usersToElaborate.isEmpty()){
            

            Batch_Disattivazione_User recursiveBatch = new Batch_Disattivazione_User();
            recursiveBatch.usersToElaborate = usersToElaborate;
            recursiveBatch.usersToElaborateTot = usersToElaborateTot;
            recursiveBatch.sj = sj;
            recursiveBatch.recordElab = recordElab;
            recursiveBatch.errorRecords = errorRecords;
            recursiveBatch.ctmEliminati = ctmEliminati;
            recursiveBatch.recordTotali = recordTotali;
            recursiveBatch.erroriTotali = erroriTotali;

            List<ScheduledJob__c> schList = [SELECT Id, Name, Batch_Size__c FROM ScheduledJob__c WHERE Name =:NOME_CLASSE];
            Integer size = schList.isEmpty() ? 200 : Integer.valueOf(schList.get(0).Batch_Size__c);

            if(!Test.isRunningTest()) Database.executeBatch(recursiveBatch,size);
    
    
        }else{
            deactivateUsers();

            testoMail = '';
        
            testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+recordTotali+' con '+erroriTotali+' errori.<br/>';
            testoMail += 'Numero totale di CaseTeamMembers elaborati : '+recordElab+'<br/>';
            testoMail += 'Numero totale di CaseTeamMembers cancellati con successo : '+ctmEliminati+'<br/>';
            testoMail += 'Numero totale di cancellazioni CaseTeamMembers andate in errore : '+errorRecords+'<br/>';
            testoMail += 'Numero totale di Users elaborati : '+usersToElaborateTot+'<br/>';
            testoMail += 'Numero totale di User disattivati con successo : '+usersDisattivati+'<br/>';
            testoMail += 'Numero totale di disattivazioni User andate in errore : '+usersInErrore+'<br/>';
    
    
    
            if (debug != null && debug.Verbose__c) { mandaMail('Recap',testoMail); }
    
            if (sj!=null && sj.size()>0) { if(!Test.isRunningTest()) JobRunner.executeNext(sj); }
        }

    }

    public void deactivateUsers(){

        List<User> userList = [SELECT Id, Da_Disattivare_Batch__c, ProfileId,FederationIdentifier,IsActive,UserRoleId,Profilo__c,idced__c, CRM_Polo__c, CRM_Team__c, Ruolo_nel_Contact_Center__c, PTF_RuoloLDAP__c, CRM_PermissionSet__c FROM User WHERE ID IN:usersToElaborateTot];

        for(User currentUser : userList){
            currentUser.isActive = false;
            currentUser.Da_Disattivare_Batch__c = false;
            currentUser.CRM_Polo__c = null;
            currentUser.CRM_Team__c = null;
            currentUser.Ruolo_nel_Contact_Center__c = null;
        }
        OnUserTriggerHandler.skipUpdateMember = true;
        List<Database.saveResult> saveResults = Database.update(userList,false);
        for(Integer index = 0, size = saveResults.size(); index < size; index++) {
            Database.saveResult sr = saveResults[index];
            //User u = toDeactivate[index];
            if (sr.isSuccess()) {
                usersDisattivati +=1;
            }
            else {
                List<Database.Error> errors = sr.getErrors();
                Database.Error error = errors[0];
                System.debug('*** Batch_Disattivazione_User - deactivateUsers Error: '+error.getMessage());
                usersInErrore +=1;
            }
        }
        OnUserTriggerHandler.skipUpdateMember = false;

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