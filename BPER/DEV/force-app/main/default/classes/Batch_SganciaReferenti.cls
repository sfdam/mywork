global class Batch_SganciaReferenti implements Database.Batchable<sObject>,Database.stateful,IRunner {

    private static final String COD_CLASSE = 'GR004';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_SganciaReferenti';
    global Boolean errorOnCreate = false;
    global Integer recordElab=0;
    global Integer recordCreati=0;
    global String testoMail ='';

    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();

    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global Set<String> updatedMatricole = new Set<String>();
    global List<User> allUserList = new List<User>();


    /***
     * IRunner
     ***/
    global void initRunner(List<ScheduledJob__c> schedules) {
        this.sj.addAll(schedules);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id, FederationIdentifier, ReferenteDaSganciare__c FROM User WHERE ReferenteDaSganciare__c = true OR Da_Disattivare_Batch__c = true';
        if (Test.isRunningTest()) {
            query += ' LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User> scope){
        Set<String> userIdSet = new Set<String>();
        allUserList.addAll(scope);
        System.debug('pz Batch_SganciaReferenti -allUserList '+ allUserList);
        for(User user : scope){
            userIdSet.add(user.Id);
        }
        System.debug('pz Batch_SganciaReferenti -userIdSet '+ userIdSet);
        if(!userIdSet.isEmpty()){

            System.debug('STAT dropRefs');
            List<CampaignMember> cmList = [SELECT Id, CRM_Assegnatario__c, CRM_Assegnatario__r.FederationIdentifier FROM CampaignMember WHERE CRM_Assegnatario__c IN: userIdSet];
            for(CampaignMember cm : cmList){
                cm.CRM_Assegnatario__c = null;
                updatedMatricole.add('U' + cm.CRM_Assegnatario__r.FederationIdentifier);
            }
            System.debug('DK cmList: ' + JSON.serialize(cmList));
            update cmList;
            
        }
    }

    global void finish(Database.BatchableContext BC) {

        System.debug('DK updatedMatricole: ' + JSON.serialize(updatedMatricole));
        try {
            
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
    
            for(user user: allUserList){
                user.ReferenteDaSganciare__c = false;
            }
    
            Map<String, SObject> userMap = SV_Utilities.keyBy(allUserList, 'Id');
    
            Map<String, String> usersWithErrors = new Map<String, String>();
    
            Database.SaveResult[] srList = Database.update(allUserList, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    usersWithErrors.put('U' + (String)userMap.get(sr.getId()).get('FederationIdentifier'), sr.getErrors()[0].getMessage());
                }
            }
    
            testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' con '+a.NumberOfErrors+' errori.<br/>';
            if(!updatedMatricole.isEmpty()){
                testoMail += 'Referenti sganciati:<br/>';
                String table = '';
                table +='<table border="1">';
                table +='<thead>';
                table +='<tr>';
                table +='<th>Matricola</th>';
                table +='</tr>';
                table +='</thead>';
                table +='<tbody>';
                for(String matricola : updatedMatricole){
                    table +='<tr>';
                    table +=('<td>'+matricola+'</td>');
                    table +='</tr>';
                }
                table +='</tbody>';
                table +='</table>';
                testoMail += table + '<br/><br/>';
            }
    
            if(!usersWithErrors.isEmpty()){
                testoMail += 'User con errori in fase di aggiornamento:<br/>';
                String table = '';
                table +='<table border="1">';
                table +='<thead>';
                table +='<tr>';
                table +='<th>Matricola</th>';
                table +='<th>Errore</th>';
                table +='</tr>';
                table +='</thead>';
                table +='<tbody>';
                for(String matricola : usersWithErrors.keySet()){
                    table +='<tr>';
                    table +=('<td>'+matricola+'</td>');
                    table +=('<td>'+usersWithErrors.get(matricola)+'</td>');
                    table +='</tr>';
                }
                table +='</tbody>';
                table +='</table>';
                testoMail += table;
            }
            if (debug.Verbose__c) {
                mandaMail('Recap',testoMail);
            }
    
            if (sj!=null && sj.size()>0 && !errorOnCreate) {
                JobRunner.executeNext(sj);
            }
        } catch (Exception ex) {
            System.debug('Error:' + ex.getMessage() + ' at: ' + ex.getStackTraceString());
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