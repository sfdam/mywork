global class Batch_EliminaVisibilitaGerarchia implements Database.Batchable<sObject>,Database.stateful,IRunner {
    private static final String COD_CLASSE = 'GR002';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_EliminaVisibilitaGerarchia';
    
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global List<String> sObjectToManage = new List<String>{'Wallet__Share','UserRoleAndGroups'};
    global String operationType = null;
    global Boolean onErrorInit = false;
    global Boolean onError = false;
    global Set<Id> idGroupsToDelete = new Set<Id>();
    global String testoMail = '';
    global Integer numWalletRecord = 0;
    global Integer numGroupRecord = 0;
    global Integer numRoleRecord = 0;
    global Integer numSBRecord = 0;
    global Integer numDMLDelete = 0;
    
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
        operationType = sObjectToManage.remove(0);
        String query = '';
        if ('Wallet__Share'.equals(operationType)) {
            try {
                idGroupsToDelete = findGroups();
                if (idGroupsToDelete.size()>0) {
            		query = 'SELECT Id, UserOrGroupId FROM Wallet__Share WHERE RowCause=\'Manual\'';    
                }
                else {
                   operationType = sObjectToManage.remove(0); 
                }
            }
            catch(Exception exc) {
                onErrorInit = true;
            }
        }
        if (onErrorInit) {
            operationType = 'Error';
            query = 'SELECT Id FROM Struttura_Banca__c WHERE Stato__c=NULL LIMIT 1';
        }
        if ('UserRoleAndGroups'.equals(operationType) &&  !onErrorInit ) {
            query = 'SELECT Id, IDCed__c,Da_Elaborare__c,Stato__c,Cambio_Stato__c FROM Struttura_Banca__c WHERE Stato__c =\'D\' AND Da_Elaborare__c=TRUE AND Cambio_Stato__c=TRUE';
            if (Test.isRunningTest()) {
                query += ' LIMIT 200';
            }
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<String> codRolesToDelete = new Set<String>();
        //Set<String> codGroupsToDelete = new Set<String>();
        List<Wallet__Share> WalletsToDelete = new List<Wallet__Share>();
        List<UserRole> rolesToDelete = new List<UserRole>();
        try {
            if (!onError) {
            	if ('Wallet__Share'.equals(operationType)) {
                    if (numDMLDelete<8500) {
                    	for (sObject o : scope) {
                        	Wallet__Share ws = (Wallet__Share)o;
                        	if (idGroupsToDelete.contains(ws.UserOrGroupId)) {
                            	WalletsToDelete.add(ws);
                        	}
                    	}
                        if (WalletsToDelete.size()>0) {
                			delete WalletsToDelete;
                        }
                		numWalletRecord += WalletsToDelete.size();
                    	numDMLDelete += WalletsToDelete.size();
                    }
            	}
            	else if ('UserRoleAndGroups'.equals(operationType)) {
                	numSBRecord += scope.size();
                	for (sObject o : scope) {
                    	Struttura_Banca__c sb = (Struttura_Banca__c)o;
                    	codRolesToDelete.add('RIDCED'+sb.IDCed__c);
                    	//codGroupsToDelete.add('GIDCED'+sb.IDCed__c);
                	}
                
                	if (codRolesToDelete.size()>0) {
                    	rolesToDelete = findRoleByDevName(codRolesToDelete);
                	}
                    
                	/*if (codGroupsToDelete.size()>0) {
                    	groupsToDelete = findGroupByDevName(codGroupsToDelete);
                	}*/
                
                	if (rolesToDelete.size()>0) {
                        if (numDMLDelete<8500) {
                    		delete rolesToDelete;
                    		numRoleRecord += rolesToDelete.size();
                            numDMLDelete += rolesToDelete.size();
                        }
                	}
                
                	/*if (groupsToDelete.size()>0) {
                        if (numDMLDelete<8500) {
                    		delete groupsToDelete;
                    		numGroupRecord += groupsToDelete.size();
                            numDMLDelete += groupsToDelete.size();
                        }
                	}*/
            	}
            }
        }
        catch(Exception exc) {
            System.debug(NOME_CLASSE+' - An exception occurred : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
        	mandaMail('Error',testoMail);
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
        testoMail += 'Numero totale di record portafoglio da Share eliminiati : '+numWalletRecord+'<br/>';
        testoMail += 'Numero totale di Ruoli eliminati : '+numRoleRecord+'<br/>';
        testoMail += 'Numero totale di Gruppi eliminati : '+numGroupRecord+'<br/>';
        testoMail += 'DML delte limit raggiunto : '+(numDMLDelete>=8500)+'<br/>';
        
        if (debug.Verbose__c) {
        	mandaMail('Recap',testoMail);
        }
        
        if (numDMLDelete>=8500 && !Test.isRunningTest()) {
            Batch_EliminaVisibilitaGerarchia batch = new Batch_EliminaVisibilitaGerarchia();
            batch.sObjectToManage = ('Wallet__Share'.equals(operationType) ? new List<String>{'Wallet__Share','UserRoleAndGroups'} : new List<String>{'UserRoleAndGroups'});
            batch.numWalletRecord = numWalletRecord;
            batch.initRunner(sj);
            Database.executeBatch(batch);
        }
        else if (sObjectToManage.size()>0 && !onError && !onErrorInit && !Test.isRunningTest()) {
            Batch_EliminaVisibilitaGerarchia batch = new Batch_EliminaVisibilitaGerarchia();
            batch.sObjectToManage = sObjectToManage;
            batch.numWalletRecord = numWalletRecord;
            batch.initRunner(sj);
            Database.executeBatch(batch);
        }
        else if (sj!=null && sj.size()>0 && !onError && !onErrorInit) {
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
    /*private List<Group> findGroupByDevName(Set<String> codGroups) {
        List<Group> groups = null;
        try {
            groups = [
                SELECT	Id,
                		DeveloperName
                FROM Group
                WHERE DeveloperName IN:codGroups
            ];
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return (groups!=null && groups.size()>0 ? groups : new List<Group>());
    }*/
    private List<UserRole> findRoleByDevName(Set<String> codRoles) {
        List<UserRole> roles = null;
        try {
            roles = [
                SELECT	Id,
                		DeveloperName
                FROM UserRole
                WHERE DeveloperName IN:codRoles
            ];
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return (roles!=null && roles.size()>0 ? roles : new List<UserRole>());
    }  
    
    private Set<Id> findGroups() {
        Set<Id> idGroups = new Set<Id>();
        try {
            List<Struttura_Banca__c> sbs = [
                SELECT	Id,
                		IdCed__c,
                		Stato__c,
                		Cambio_Stato__c,
                		Da_Elaborare__c
                FROM Struttura_Banca__c
                WHERE Stato__c = 'D'
                AND Da_Elaborare__c = TRUE 
                AND Cambio_Stato__c = TRUE
            ];
            if (sbs!=null && sbs.size()>0) {
                Set<String> idCeds = new Set<String>();
                for (Struttura_Banca__c sb :sbs) {
                    idCeds.add('RIDCED'+sb.IDCed__c);
                }
                if (idCeds.size()>0) {
                	List<Group> groups = [
                    	SELECT	Id,
                    			DeveloperName
                    	FROM Group
                    	WHERE DeveloperName IN:idCeds
                	];
                    if (groups!=null && groups.size()>0) {
                        for (Group g : groups) {
                            idGroups.add(g.Id);
                        }
                    }
                }
            }
        }
        catch (Exception exc) {
            throw exc;
        }
        return idGroups;
    }
}