/****
 * Name			:	Batch_CancellaGerarchiaRuoli
 * Create Date	:	2020-10-28
 * Author 		:	Ezio Dal Bo @TEN
 ****/
global class Batch_CancellaGerarchiaRuoli implements Database.Batchable<sObject>,Database.stateful,IRunner {
    
    private static final String COD_CLASSE = 'GR001';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_CancellaGerarchiaRuoli';
    
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Boolean onError = false;
    global Map<String,SObject> mRuoli = MetadataUtility.getAllByMetadataName('Gerarchia_Ruolo__mdt');
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global Map<Id,UserRole> mUserRoles = new Map<Id,UserRole>();
    Integer numUserElab = 0;
    Integer numUserUpdated = 0;
    Integer numRoleElab = 0;
    Integer numRoleUpdated = 0;
    Integer numRoleDeleted = 0;
    global String testoMail = '';
    List<String> queryFields = new List<String>{'Id','ParentRoleId','DeveloperName'};
        
    /***
     * IRunner
     ***/
    global void initRunner(List<ScheduledJob__c> schedules) {
        this.sj.addAll(schedules);
    }
    
    /***
     * Batch
     ***/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT '+String.join(queryFields, ',')+' FROM UserRole';      
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<UserRole> scope) {
        List<UserRole> userRoleToDelete = new List<UserRole>();
        Map<Id,UserRole> userRoleToManage = new Map<Id,UserRole>();
        
        try {
            numRoleElab += scope.size();
            for (UserRole ur : scope) {
                if (!mRuoli.containsKey(ur.DeveloperName)) {
                    ur.ParentRoleId = null; 
                    userRoleToManage.put(ur.Id,ur);
                }
            }
            List<User> userToUpdate = findUserByRoleId(userRoleToManage.keySet());
            numUserElab += userToUpdate.size();
            if (userToUpdate.size()>0) {
                for (User u : userToUpdate) {
                    u.UserRoleId = null;
                }
            }
            
            if (!userRoleToManage.isEmpty()) {
            	update userRoleToManage.values();
                numRoleUpdated += userRoleToManage.values().size();
            }
            if (userToUpdate.size()>0) {
            	update userToUpdate;
                numUserUpdated += userToUpdate.size();
            }
            mUserRoles.putAll(userRoleToManage);
            
            Set<Id> userRolesIds = findUserRoleChilds(mUserRoles.keySet());
            for (Id idKey : mUserRoles.keySet()) {
                if (!userRolesIds.contains(idKey)) {
                    userRoleToDelete.add(mUserRoles.get(idKey));
                }
            }
            
            if (userRoleToDelete.size()>0) {
                delete userRoleToDelete;
                numRoleDeleted += userRoleToDelete.size();
                for (UserRole ur :userRoleToDelete) {
                    mUserRoles.remove(ur.Id);
                }
            }
        }
        catch(Exception exc) {
            System.debug(NOME_CLASSE+' - An exception occurred during manage records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during manage records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
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
        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'Numero totale di Ruoli elaborati : '+numRoleElab+'<br/>';
        testoMail += 'Numero totale di Ruoli scollegati : '+numRoleUpdated+'<br/>';
        testoMail += 'Numero totale di Ruoli cancellati : '+numRoleDeleted+'<br/>';
        testoMail += 'Numero totale di Utenti elaborati : '+numUserElab+'<br/>';
        testoMail += 'Numero totale di Utenti scollegati : '+numUserUpdated+'<br/>';
        
        if (debug.Verbose__c) {
        	mandaMail('Recap',testoMail);
        }
        if (sj!=null && sj.size()>0 && !onError) {
            JobRunner.executeNext(sj);
        }
    }
    
    /* prvate methods */
    /***
     * Name			:	findUserRoleChilds
     * Author		:	Ezio Dal Bo @TEN
     * Create date	:	2020-10-28
     ***/
    private Set<Id> findUserRoleChilds(Set<Id> userRoleIds) {
        Set<Id> userRoles = new Set<Id>();
        try {
            List<UserRole> urs = [
                SELECT	Id,
                		ParentRoleId
                FROM UserRole
                WHERE ParentRoleId IN:userRoleIds
            ];
            
            if (urs!=null && urs.size()>0) {
                for (UserRole ur : urs) {
                    userRoles.add(ur.ParentRoleId);
                }
            }
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return userRoles;
    }
    
    /***
     * Name			:	findUserByRoleId
     * Author		:	Ezio Dal Bo @TEN
     * Create date	:	2020-10-28
     ***/
    private List<User> findUserByRoleId(Set<Id> userRoleIds) {
        List<User> users = null;
        try {
            users = [
                SELECT 	Id,
                		UserRoleId
                FROM User
                WHERE UserRoleId IN:userRoleIds
            ];
        }
        catch(Exception exc) {
            throw exc;
        }
        return (users!=null && users.size()>0 ? users : new List<User>());
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
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}