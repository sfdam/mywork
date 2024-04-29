/****
 * Name			:	Batch_GeneraContatti
 * Create Date	:	2021-02-08
 * Author 		:	Ezio Dal Bo @TEN
 ****/
global class Batch_GeneraContatti implements Database.Batchable<sObject>,Database.stateful,IRunner {
    private static final String COD_CLASSE = 'GR006';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_GeneraContatti';
    
    global DateTime today = DateTime.now();
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Map<String,Struttura_Banca__c> mStruttura = new Map<String,Struttura_Banca__c>();
    global Map<String,SObject> UtenzeBPER = new Map<String,SObject>();
    global Map<String,SObject> ProfiliBPER = new Map<String,SObject>();
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global Map<String,EscludiUtenzaTecnicaLDAP__c> mEscludiUtenzaTecnica = EscludiUtenzaTecnicaLDAP__c.getAll();
    global String testoMail ='';
    global Boolean errorOnCreate = false;
    global Integer recordElab = 0;
    global Integer contattiCreati = 0;
    global Integer contattiUpdatati = 0;
    global Integer cambioFiliale = 0;
    global Integer cambioRuolo = 0;
    global Set<String> sLivello = new Set<String>{'180','190','200'};
    global Set<String> sConsulenteFinanziario = new Set<String>{'990','991'};
    global Map<Id,String> mRoleTypology = new Map<Id,String>();
    global Set<Id> allNewContacts = new Set<Id>();
    global Set<Id> allOldContacts = new Set<Id>();
    global Map<String,String> mContactChanges = new Map<String,String>();
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
        'Da_Elaborare__c'
    };
    global LDAP__c ldapTest = null;
    
    /**
     * IRunner
     **/
    global void initRunner(List<ScheduledJob__c> schedules) {
        this.sj.addAll(schedules);
    }
    
    /**
     * Batch
     **/
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Funzionalita__c fun = Funzionalita__c.getInstance(userinfo.getUserId());
        fun.Disable_ContactTrigger__c = false;
        update fun;
        mStruttura = getStrutturaBanca();
        UtenzeBPER = MetadataUtility.getAllByMetadataName('Utenza_BPER__mdt');
        ProfiliBPER = MetadataUtility.getAllByMetadataName('Profilo_BPER__mdt');
        mRoleTypology = getRoleTypology();
        String query = 'SELECT '+String.join(queryFields, ',')+' FROM LDAP__c WHERE Da_Elaborare__c=TRUE';
        if (Test.isRunningTest()) {
            query += ' LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<LDAP__c> scope) {
        
        Set<String> IDCEDSet= new Set<String>();
        Set<String> ruoloLDAPSet= new Set<String>();
        Set<String> matricolaSet= new Set<String>();
        Map<String,String> ruoloLDAPToRoleTypology = new Map<String,String>();
        Map<String,Contact> matricolaToContact = new Map<String,Contact>();
        Map<String,Account> IDCEDToAccount = new Map<String,Account>();
        Map<String,User> matricolaToUser = new Map<String,User>();
        List<Contact> contactToInsert = new List<Contact>();
        List<Contact> contactToUpdate = new List<Contact>();
        
        try {
            if (Test.isRunningTest() && ldapTest!=null) {
                scope.add(ldapTest);
                ldapTest = null;
            }
            recordElab += scope.size();
            for(LDAP__c ldap: scope){
                if(String.isNotBlank(ldap.IDCed__c) && mStruttura.containsKey(ldap.IDCed__c)){
                    if (!mEscludiUtenzaTecnica.containsKey(ldap.Matricola__c)) {
                        IDCEDSet.add(ldap.IDCed__c);
                        ruoloLDAPSet.add(ldap.Ruolo_LDAP_Calcolato__c);
                        matricolaSet.add(ldap.Matricola__c.replace('U', ''));
                    }
                }
            }
            ruoloLDAPToRoleTypology=findRoleTypology(ruoloLDAPSet);
            matricolaToContact=findContact(matricolaSet);
            IDCEDToAccount=findAccount(IDCEDSet);
            matricolaToUser=findUtenti(matricolaSet,true);
            for(LDAP__c ldap: scope){
                Contact oldContact = null;
                if(String.isNotBlank(ldap.IDCed__c) && mStruttura.containsKey(ldap.IDCed__c)){
                    if (!mEscludiUtenzaTecnica.containsKey(ldap.Matricola__c)) {
                        if(ldap.Attivo__c) {
                            Boolean isNewContact = true;
                            Contact c = new Contact();
                            if(matricolaToContact.containsKey(ldap.Matricola__c.replace('U', ''))) {
                                isNewContact = false;
                                c = matricolaToContact.get(ldap.Matricola__c.replace('U', ''));
                                oldContact = c.clone(true,true,true,true);
                            } 
                            if (!isNewContact) {
                                Boolean newAccountId = false;
                                if (IDCEDToAccount.containsKey(ldap.IDCed__c)) {
                                    newAccountId = (c.AccountId!=IDCEDToAccount.get(ldap.IDCed__c).Id);
                                }
                                if (
                                    newAccountId ||
                                    c.PTF_TipologiaRuolo__c!=ruoloLDAPToRoleTypology.get(ldap.Ruolo_LDAP_Calcolato__c)
                                ) {
                                    if (newAccountId) {
                                        cambioFiliale +=1;
                                        allOldContacts.add(c.Id);
                                    }
                                    else if (c.PTF_TipologiaRuolo__c!=ruoloLDAPToRoleTypology.get(ldap.Ruolo_LDAP_Calcolato__c)) {
                                        cambioRuolo +=1;
                                        allOldContacts.add(c.Id);
                                    }
                                }
                            }
                            c.PTF_TipologiaRuolo__c=ruoloLDAPToRoleTypology.get(ldap.Ruolo_LDAP_Calcolato__c);
                            if (IDCEDToAccount.containsKey(ldap.IDCed__c)) {
                                c.AccountId=IDCEDToAccount.get(ldap.IDCed__c).Id;
                            }
                            if (matricolaToUser.containsKey(ldap.Matricola__c.replace('U', ''))) {
                                c.PTF_User__c = matricolaToUser.get(ldap.Matricola__c.replace('U', '')).Id;
                            }
                            c.FirstName= ldap.Nome__c;
                            c.LastName = (String.isNotBlank(ldap.Cognome__c) ? ldap.Cognome__c : '***');
                            c.CRM_NomeReferente__c = ldap.Nome__c + ' ' + ldap.Cognome__c;
                            c.PTF_CentroPrivate__c = ldap.Team__c;
                            c.PTF_IsVice__c = ldap.Vicario__c;
                            c.PTF_Ruolo__c= ldap.Ruolo_LDAP__c;
                            c.PTF_RegistrationNumber__c=ldap.Matricola__c.replace('U', '');
                            c.PTF_OFS__c=ldap.OFS__c;
                            c.PTF_ProfiloLDAP__c = ldap.Profilo_LDAP__c;
                            Profilo_BPER__mdt p = null;
                            String profilo = null;
                            if (String.isNotBlank(ldap.Profilo_LDAP__c)) {
                                c.PTF_ProfiloLDAP__c = ldap.Profilo_LDAP__c;
                                profilo = ldap.Profilo_LDAP__c.replaceAll('\\.','_');
                                p = (ProfiliBPER.containsKey(profilo) ? (Profilo_BPER__mdt)ProfiliBPER.get(profilo) : null);
                            }
                            else {
                                Utenza_BPER__mdt utenza = null;
                                Struttura_Banca__c sb = mStruttura.get(ldap.IDCed__c);
                                String descrizione = (String.isNotBlank(sb.Descrizione__c) ? sb.Descrizione__c.trim().toUpperCase() : null);
                                String vicario = (String.isNotBlank(ldap.Vicario__c) ? ldap.Vicario__c.trim() : null);
                                if (sConsulenteFinanziario.contains(ldap.Ruolo_LDAP__c) || sLivello.contains(sb.Livello__c) || (String.isNotBlank(descrizione) && descrizione.startsWith('CENTRO IMPRESE')) || String.isNotBlank(vicario)) {
                                    Boolean continua = true;
                                    // casistica vicario
                                    if (String.isNotBlank(vicario)) {
                                        utenza = (Utenza_BPER__mdt)UtenzeBPER.get('Vicario'); 
                                        c.PTF_ProfiloLDAP__c = utenza.Profilo__c;
                                        profilo = c.PTF_ProfiloLDAP__c.replaceAll('\\.','_');
                                        p = (ProfiliBPER.containsKey(profilo) ? (Profilo_BPER__mdt)ProfiliBPER.get(profilo) : null);
                                        continua = false;
                                    }
                                    // casistica non vicario, ma consulente finanziario o livello struttura banca 180,190,200 o Centro Imprese
                                    if (continua && sConsulenteFinanziario.contains(ldap.Ruolo_LDAP__c) || sLivello.contains(sb.Livello__c) || (String.isNotBlank(descrizione) && descrizione.startsWith('CENTRO IMPRESE'))) {
                                        String keyUtenza = (descrizione.startsWith('CENTRO IMPRESE') ? 'CIMP_' : (sLivello.contains(sb.Livello__c) ? 'FIL_' : ''));
                                        keyUtenza = (sConsulenteFinanziario.contains(ldap.Ruolo_LDAP__c) ? 'CF_' : keyUtenza);
                                        keyUtenza += (String.isNotBlank(ldap.Ruolo_LDAP__c) ? ldap.Ruolo_LDAP__c : '');
                                        utenza = (UtenzeBPER.containsKey(keyUtenza) ? (Utenza_BPER__mdt)UtenzeBPER.get(keyUtenza) : null);
                                        if (utenza!=null) {
                                            c.PTF_ProfiloLDAP__c = utenza.Profilo__c;
                                            profilo = c.PTF_ProfiloLDAP__c.replaceAll('\\.','_');
                                            p = (ProfiliBPER.containsKey(profilo) ? (Profilo_BPER__mdt)ProfiliBPER.get(profilo) : null);
                                        }
                                    }
                                }
                            }
                            
                            if (isNewContact) {
                                if (p==null || (p!=null && p.Crea_Contatto__c)) {
                                    contactToInsert.add(c);
                                }
                            }
                            else {
                                if (c!=null && oldContact!=null) {
                                	storicoContatti(mContactChanges,c,oldContact,mRoleTypology,IDCEDToAccount.get(ldap.IDCed__c));
                                }
                                contactToUpdate.add(c);
                            }
                        }
                        else{
                            if(matricolaToContact.containsKey(ldap.Matricola__c.replace('U', ''))){
                                Contact c = matricolaToContact.get(ldap.Matricola__c.replace('U', ''));
                                c.PTF_ProfiloLDAP__c=null;
                                contactToUpdate.add(c);
                            }
                        }
                    }
                }
            }
            system.debug(' bgc contactToUpdate' + contactToUpdate);
            system.debug(' bgc contactToInsert' + contactToInsert);
            
            if (contactToUpdate.size()>0) {
                FollowUp.invokeUpdateDefaultManagers = true;
                FollowUp.invokeFutureGruppi = false;
                update contactToUpdate;
                for (Contact c : contactToUpdate) {
                    allNewContacts.add(c.Id);
                }
                FollowUp.invokeFutureGruppi = true;
                FollowUp.invokeUpdateDefaultManagers = false;
                contattiUpdatati+=contactToUpdate.size();
            }
            
            if (contactToInsert.size()>0) {
                FollowUp.invokeUpdateDefaultManagers = true;
                FollowUp.invokeFutureGruppi = false;
                insert contactToInsert;
                for (Contact c : contactToInsert) {
                    allNewContacts.add(c.Id);
                }
                FollowUp.invokeFutureGruppi = true;
                FollowUp.invokeUpdateDefaultManagers = false;
                contattiCreati+=contactToInsert.size();
            }
            system.debug('bgc allNewContacts' + allNewContacts);

        }
        catch(Exception exc) {
            System.debug(NOME_CLASSE+' - An exception occurred during create/update records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during create/update records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            errorOnCreate = true; 
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        Funzionalita__c fun = Funzionalita__c.getInstance(userinfo.getUserId());
        fun.Disable_ContactTrigger__c = true;
        update fun;
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
        
        if (errorOnCreate) {
            testoMail += '<span style="{color:red;}">Ci sono stati degli errori durante la fase di gestione dei record. sono state inviate le mail</span><br/><br/>';
        }
        
        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' job con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'Numero totale di Record elaborati : '+recordElab+'<br/>';
        testoMail += 'Numero totale di Contatti creati : '+contattiCreati+'<br/>';
        testoMail += 'Numero totale di Contatti aggiornati : '+contattiUpdatati+'<br/>';
        testoMail += 'Numero totale di Contatti aggiornati per cambio filiale : '+cambioFiliale+'<br/>';
        testoMail += 'Numero totale di Contatti aggiornati per cambio ruolo : '+cambioRuolo+'<br/>';
        
        String errorTable = '';
        if (mContactChanges.size()>0) {
            errorTable +='<table border="1">';
            errorTable +='<thead>';
            errorTable +='<tr>';
            errorTable +='<th>Matricola</th>';
            errorTable +='<th>Tipologia di varizione</th>';
            errorTable +='</tr>';
            errorTable +='</thead>';
            errorTable +='<tbody>';
            for (String key : mContactChanges.keySet()) {
                errorTable +='<tr>';
                errorTable +=('<td>'+key+'</td>');
                errorTable +=('<td>'+mContactChanges.get(key)+'</td>');
                errorTable +='</tr>';
            }
            errorTable +='</tbody>';
            errorTable +='</table>';
            testoMail += errorTable;
            testoMail += '<br/>';
        }
        
        if (debug.Verbose__c) {
        	mandaMail('Recap',testoMail);
        }
        
        if (sj!=null && sj.size()>0 && !errorOnCreate) {
            JobRunner.executeNext(sj);
        }
        
        try {
            testoMail = '';
            
            List<Assignment__c> newAss = [
            	SELECT	Id,
            			PTF_EndDate__c,
            			PTF_Gestore_Name__c,
            			PTF_Gestore__c,
            			PTF_MicroWallet__c,
                		PTF_MicroWallet__r.PTF_Pool__c,
            			RecordTypeId 
            	FROM Assignment__c 
            	WHERE CreatedDate >=: today
            	AND PTF_Gestore__c IN:allNewContacts
                AND PTF_MicroWallet__r.PTF_Pool__c = TRUE
                AND PTF_EndDate__c = NULL
        	];
            system.debug('bgc newAss' + newAss); 
            
            List<Assignment__c> oldAss = [
            	SELECT	Id,
            			PTF_EndDate__c,
            			PTF_Gestore_Name__c,
            			PTF_Gestore__c,
            			PTF_MicroWallet__c,
                		PTF_MicroWallet__r.PTF_Pool__c,
            			RecordTypeId 
            	FROM Assignment__c 
            	WHERE LastModifiedDate >=: today
            	AND PTF_Gestore__c IN:allOldContacts
                AND PTF_MicroWallet__r.PTF_Pool__c = TRUE
                AND PTF_EndDate__c != NULL
        	];
            system.debug('bgc oldAss' + oldAss); 
            
            if (newAss!=null && newAss.size()>0) {
                manageAssignment(newAss, 'onInsert');
                system.debug('bgc 344' );
            }
            
            if (oldAss!=null && oldAss.size()>0) {
                 manageAssignment(oldAss, 'onUpdate');
                 system.debug('bgc 344' );
            }
        }
        catch(Exception exc) {
            System.debug('An Execption occurred : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during apply Storico Assignment : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
        }
        
}
    
    /***
     * custom methods
     ***/
    private static Map<String,User> findUtenti(Set<String> matricolaSet,Boolean useIsActive){
        Map<String,User> returnMap = new Map<String,User>();
        List<User> users;
        if (useIsActive) {
            users = [SELECT Id, FederationIdentifier,IsActive,UserRoleId FROM User WHERE FederationIdentifier IN:matricolaSet AND isActive=true];
        }
        else {
            users = [SELECT Id, FederationIdentifier,IsActive,UserRoleId FROM User WHERE FederationIdentifier IN:matricolaSet];
        }
        for(User u: users){
            returnMap.put(u.FederationIdentifier, u);
        }

        return returnMap;
    }
    
    private static Map<String,Account> findAccount(Set<String> IDCEDSet){
        Map<String,Account> returnMap = new Map<String,Account>();
        Set<String> recTypes = new Set<String>{'FilialeDiRelazione','Area','DirezioneRegionale','Banca','AltraUnitaOrganizzativa'};
        List<Account> accounts= [SELECT Id, PTF_IdCED__c,Name,CRM_Nome__c FROM Account WHERE PTF_IdCED__c IN:IDCEDSet AND RecordType.DeveloperName IN:recTypes];

        for(Account a: accounts){
            returnMap.put(a.PTF_IdCED__c, a);
        }

        return returnMap;
    }
    
    public static Map<String,Contact> findContact(Set<String> matricolaSet){
        Map<String,Contact> returnMap = new Map<String,Contact>();

        List<Contact> contacts= [
            SELECT	Id,
            		PTF_RegistrationNumber__c,
            		PTF_TipologiaRuolo__c,
            		PTF_IdCED__c,
            		PTF_CentroPrivate__c,
            		AccountId,
            		Account.Name,
            		Account.CRM_Nome__c,
            		PTF_Ruolo__c,
            		PTF_IsVice__c,
            		PTF_OFS__c,
            		PTF_ProfiloLDAP__c
            FROM Contact 
            WHERE PTF_RegistrationNumber__c IN:matricolaSet 
        ];

        for(Contact c: contacts){
            returnMap.put(c.PTF_RegistrationNumber__c, c);
        }

        return returnMap;
    }
    
    private static Map<String,String> findRoleTypology(Set<String> ruoloLDAPSet){
        Map<String,String> returnMap = new Map<String,String>();

        List<RoleTypology__c> roles= [SELECT Id, PTF_Code__c FROM RoleTypology__c WHERE PTF_Code__c IN:ruoloLDAPSet ];

        for(RoleTypology__c r: roles){
            returnMap.put(r.PTF_Code__c, r.Id);
        }

        return returnMap;
    }
    
    private static Map<Id,String> getRoleTypology() {
		Map<Id,String> mRoleTypology = new Map<Id,String>();
        
        try {
            List<RoleTypology__c> roles= [SELECT Id,Name FROM RoleTypology__c];
            if (roles!=null && roles.size()>0) {
                for(RoleTypology__c r: roles){
            		mRoleTypology.put(r.Id,r.Name);
        		}
            }
        }
        catch(Exception exc) {
            
        }
        
        return mRoleTypology;        
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
    
    public static void storicoContatti(Map<String,String> storico,Contact newContact,Contact oldContact,Map<Id,String> mRoleTypology,Account newAcc) {
        String value = '<ul>';
        try {
        	if (newContact.AccountId!=oldContact.AccountId) {
                value += '<li>Variata la filiale da ';
                try {
                    value += (oldContact.Account.CRM_Nome__c!=null ? oldContact.Account.CRM_Nome__c : 'N/A');
                }
                catch(Exception exc) {
                    value += 'N/A';
                }
                value += ' a ';
                try {
                    value += (newAcc.CRM_Nome__c!=null ? newAcc.CRM_Nome__c : 'N/A');
                }
                catch(Exception exc) {
                    value += 'N/A';
                }
        	}
			if (newContact.PTF_TipologiaRuolo__c!=oldContact.PTF_TipologiaRuolo__c) {	
                value += '<li>Variata la tipologia ruolo da ';
                try {
                    value += (mRoleTypology.containsKey(oldContact.PTF_TipologiaRuolo__c) ? mRoleTypology.get(oldContact.PTF_TipologiaRuolo__c) : 'N/A');
                }
                catch(Exception exc) {
                    value += 'N/A';
                }
                value += ' a ';
                try {
                    value += (mRoleTypology.containsKey(newContact.PTF_TipologiaRuolo__c) ? mRoleTypology.get(newContact.PTF_TipologiaRuolo__c) : 'N/A');
                }
                catch(Exception exc) {
                    value += 'N/A';
                }
        	}
        	if (newContact.PTF_CentroPrivate__c!=oldContact.PTF_CentroPrivate__c) {
                value += '<li>Variato il codice centro private '+(oldContact.PTF_CentroPrivate__c!=null ? oldContact.PTF_CentroPrivate__c : 'N/A')+' a '+(newContact.PTF_CentroPrivate__c!=null ? newContact.PTF_CentroPrivate__c : 'N/A')+'</li>';
        	}
        	if (newContact.PTF_Ruolo__c!=oldContact.PTF_Ruolo__c) {
                value += '<li>Variato il codice ruolo da '+(oldContact.PTF_Ruolo__c!=null ? oldContact.PTF_Ruolo__c : 'N/A')+' a '+(newContact.PTF_Ruolo__c!=null ? newContact.PTF_Ruolo__c : 'N/A')+'</li>';
        	}
        	if (newContact.PTF_OFS__c!=oldContact.PTF_OFS__c) {
                value += '<li>Variato il flag OFS da '+(oldContact.PTF_OFS__c!=null ? (oldContact.PTF_OFS__c ? 'TRUE' : 'FALSE') : 'N/A')+' a '+(newContact.PTF_OFS__c!=null ? (newContact.PTF_OFS__c ? 'TRUE' : 'FALSE') : 'N/A')+'</li>';
            }
        	if (newContact.PTF_ProfiloLDAP__c!=oldContact.PTF_ProfiloLDAP__c) {            	
                value += '<li>Variato il profilo da '+(oldContact.PTF_ProfiloLDAP__c!=null ? oldContact.PTF_ProfiloLDAP__c : 'N/A')+' a '+(newContact.PTF_ProfiloLDAP__c!=null ? newContact.PTF_ProfiloLDAP__c : 'N/A')+'</li>';
        	}
        	if (newContact.PTF_IsVice__c!=oldContact.PTF_IsVice__c) {
            	value += '<li>Variato attributo Vicario da '+(oldContact.PTF_IsVice__c!=null ? oldContact.PTF_IsVice__c : 'N/A')+' a '+(newContact.PTF_IsVice__c!=null ? newContact.PTF_IsVice__c : 'N/A')+'</li>';
        	}
        }
        catch(exception exc) {
            value += 'WARNING : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
        }
        value +='</ul>';
        if (!'<ul></ul>'.equals(value)) {
            storico.put(newContact.PTF_RegistrationNumber__c,value);
        }
    }
    
    private static Map<String,Struttura_Banca__c> getStrutturaBanca() {
        Map<String,Struttura_Banca__c> mStruttura = new Map<String,Struttura_Banca__c>();
        try {
            List<Struttura_Banca__c> sbs =  [
                SELECT	Id,
                		Descrizione__c,
                		Livello__c,
                		IDCed__c,
                		Stato__c,
                		ABI__c
                FROM Struttura_Banca__c
                WHERE Stato__c ='A'
            ];
            if (sbs!=null && sbs.size()>0) {
                for (Struttura_Banca__c sb : sbs) {
                    mStruttura.put(sb.IDCed__c,sb);
                }
            }
        }
        catch(Exception exc) {
            
        }
        
        return mStruttura;
    }
    
    global static void manageAssignment(List<Assignment__c> records, String operation) {

        List<Assignment__c> recordsToManage = new List<Assignment__c>();
        recordsToManage.addAll(records);
        List<Set<Id>> idAssignments = new List<Set<Id>>();
        List<Map<Id,List<Assignment__c>>> lmPTFAssignment = new List<Map<Id,List<Assignment__c>>>();
        do {
            Set<Id> ids = new Set<Id>();
            Map<Id,List<Assignment__c>> mPTFAssignment = new Map<Id,List<Assignment__c>>();
            Integer i=0;
            do {
                Assignment__c ass = recordsToManage.remove(0);
                ids.add(ass.Id);
                List<Assignment__c> lAss = (mPTFAssignment.containsKey(ass.PTF_MicroWallet__c) ? mPTFAssignment.get(ass.PTF_MicroWallet__c) : new List<Assignment__c>());
                lAss.add(ass);
                mPTFAssignment.put(ass.PTF_MicroWallet__c,lAss);
                i++;
            } while(recordsToManage.size()>0 && i<200);
            lmPTFAssignment.add(mPTFAssignment);
            idAssignments.add(ids);
        }while(recordsToManage.size()>0);
        
        if ('onInsert'.equals(operation) && records.size()>0) {
            if (records.size()<=200) {
                system.debug('manageAssignment  row 614 ');
            	onAssignmentTriggerHandler.onAfterInsert(records);
            }
            else {
                for (Map<Id,List<Assignment__c>> o : lmPTFAssignment) {
                   system.debug('manageAssignment  row 619 ');
                   onAssignmentTriggerHandler.invokeBatch(
                        'Batch_OnAssignmentTriggerHandler',
                        new Map<String,Object>{
                            'eventType'=> 'onAfterInsert',
                            'idMicroWalletOver1K'=>o.keySet(),
                            'mPTFAssignment'=>o
                        }
                    ); 
                }
            }
        }
        
        if ('onUpdate'.equals(operation) && records.size()>0) {
            for (Set<Id> ids : idAssignments) {
                system.debug('manageAssignment  row 634 ');
                onAssignmentTriggerHandler.invokeBatch(
                    'Batch_OnAssignmentTriggerHandler',
                    new Map<String,Object>{'eventType'=> 'onAfterUpdate','idAssignment'=>ids}
                );
            }
        }
    }
}