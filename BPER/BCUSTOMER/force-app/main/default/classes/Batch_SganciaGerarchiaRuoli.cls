/****
 * Name			:	Batch_SganciaGerarchiaRuoli
 * Create Date	:	2020-11-02
 * Author 		:	Ezio Dal Bo @TEN
 ****/
global class Batch_SganciaGerarchiaRuoli implements Database.Batchable<sObject>,Database.stateful,IRunner {
    private static final String COD_CLASSE = 'GR001';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_SganciaGerarchiaRuoli';
    
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global Integer numRecordElab = 0;
    // global Integer numUserUnliked = 0;
    global Integer numUserRoleUnlinked = 0;
    //global Integer numGroupUnlinked = 0;
    global String testoMail = '';
    global Boolean onError = false;
    private List<String> queryFields = new List<String> {
        'Id',
        'IDCed__c',
        'IDCed_Padre__c',
        'Stato__c',
        'Descrizione__c',
        'Da_Elaborare__c',
        'Cambio_Stato__c'
    };
    
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
        Set<String> confSet=SV_Utilities.getSet([SELECT Name,PTF_IdCEDUffPrivate__c, PTF_IdCP__c, PTF_IdCEDDR__c FROM ConfigUffPrivateDR__c], '{PTF_IdCP__c}_{PTF_IdCEDUffPrivate__c}', true, false);
        Set<Id> groupSet= SV_Utilities.getIdSet([SELECT Id FROM Group WHERE DeveloperName IN:confSet], 'Id');
        List<GroupMember> members= [SELECT Id FROM GroupMember WHERE GroupId IN:groupSet];
        if(members.size()>0){
            delete members;
        }
         

        Integer numOfRecords = 0;
        String query = 'SELECT COUNT(Id) num FROM Struttura_Banca__c WHERE Stato__c IN (\'A\',\'D\') AND Da_Elaborare__c=TRUE AND Cambio_Stato__c=TRUE';
        List<AggregateResult> num = Database.query(query);
        for (AggregateResult ar : num) {
            Integer n = (ar.get('num')==null ? 0 : (Integer)ar.get('num'));
            numOfRecords += n;
        }
        query = 'SELECT '+String.escapeSingleQuotes(String.join(queryFields, ','))+' FROM Struttura_Banca__c WHERE Stato__c IN (\'A\',\'D\')';
        if (numOfRecords==0) {
            query += ' AND Da_Elaborare__c=TRUE AND Cambio_Stato__c=TRUE';
        }
        if (Test.isRunningTest()) {
            query += ' LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Struttura_Banca__c> scope) {
        Set<String> idCedRToUnlink = new Set<String>();
        Set<String> idCedUToUnlink = new Set<String>();
        //Set<String> idCedGToUnlink = new Set<String>();
        try {
        	numRecordElab += scope.size();
            if (!onError) {
            	for (Struttura_Banca__c sb : scope) {
                	// idCedRToUnlink.add('RIDCED'+sb.IDCed__c);
                	if ('D'.equals(sb.Stato__c)) {
                    	idCedUToUnlink.add('RIDCED'+sb.IDCed__c);
                    	//idCedGToUnlink.add('GIDCED'+sb.IDCed__c);
                	}
            	}
            
            	List<UserRole> idCedRoleToUnlink = findUserRoleToUnlink(idCedRToUnlink);
                for (UserRole ur : idCedRoleToUnlink) {
                    ur.ParentRoleId = null;
                }
            	/*List<User> userToUnlink = findUserToUnlink(idCedRToUnlink);
            	for (User u : userToUnlink) {
                	u.UserRoleId = null;
            	}*/
            	//List<GroupMember> groupMemeberToUnlink = findGroupMemberToUnlink(idCedGToUnlink);
            
            	if (idCedRoleToUnlink.size()>0) {
                	// update idCedRoleToUnlink;
                    System.enqueueJob(new QueueableJobs(idCedRoleToUnlink, '2'));
                	numUserRoleUnlinked += idCedRoleToUnlink.size(); 
            	}
            	/*if (userToUnlink.size()>0) {
                    OnUserTriggerHandler.skipUpdateMember=true;
                	update userToUnlink;
                	numUserUnliked += userToUnlink.size();
            	}*/
            	/*if (groupMemeberToUnlink.size()>0) {
                	delete groupMemeberToUnlink;
                    numGroupUnlinked += groupMemeberToUnlink.size();
            	}*/
            }
        }
        catch(Exception exc) {
            System.debug(NOME_CLASSE+' - An exception occurred : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
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
        testoMail += 'Numero totale di Record elaborati : '+numRecordElab+'<br/>';
        testoMail += 'Numero totale di Ruolo scollegati : '+numUserRoleUnlinked+'<br/>';
        // testoMail += 'Numero totale di Utenti scollegati : '+numUserUnliked+'<br/>';
        //testoMail += 'Numero totale di Gruppi scollegati : '+numGroupUnlinked+'<br/>';
        
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
     * Create date	:	2020-11-02
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
     * Create date	:	2020-11-02
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
    
    /* private methods */
    
    private List<UserRole> findUserRoleToUnlink(Set<String> devNames) {
        List<UserRole> userRoles = null;
        try {
            userRoles = [
                SELECT	Id,
                		DeveloperName,
                		ParentRoleId
                FROM UserRole
                WHERE DeveloperName IN:devNames
            ];
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return userRoles;
    }
    
    private List<User> findUserToUnlink(Set<String> devNames) {
        List<User> users = null;
        try {
            users = [
                SELECT	Id,
                		UserRoleId,
                		UserRole.DeveloperName
                FROM User
                WHERE UserRole.DeveloperName IN:devNames
            ];
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return users;
    }
    
    /*private List<GroupMember> findGroupMemberToUnlink(Set<String> devNames) {
        List<GroupMember> groupMembers = null;
        try {
            groupMembers = [
                SELECT	Id,
                		GroupId,
                		Group.DeveloperName
                FROM GroupMember
                WHERE Group.DeveloperName IN:devNames
            ];
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return groupMembers;
    }*/
}