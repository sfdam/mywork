global class Batch_ReassignUserRole implements Database.Batchable<sObject>, Database.stateful {

    private static final String COD_CLASSE = 'GR004';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_ReassignUserRole';
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global Boolean errorOnCreate = false;
    global String testoMail ='';
    global Integer userAggiornati = 0;

    Set<String> profilesSet = new Set<String>();
    Set<String> matricolaUserSet = new Set<String>();
    map<String,Id> mRuoliSalesforce = new Map<String,Id>();
    Map<String,SObject> mProfiliBPER = new Map<String,SObject>();
    Map<String,EscludiUtenzaTecnicaLDAP__c> mEscludiUtenzaTecnica = EscludiUtenzaTecnicaLDAP__c.getAll();
    Map<String,UserRole> IdCedToRole= new Map<String,UserRole>();
    Set<String> RIDCEDSet= new Set<String>();
    List<String> queryFields = new List<String> {
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
        // NEW DK PERMISSIONSET
        'CRM_PermissionSet__c',
        // NEW DK PERMISSIONSET
        // CR 52803
        'IdCedFittizia__c'
        // CR 52803
    };
    public Batch_ReassignUserRole() {}

    public Batch_ReassignUserRole(Set<String> profilesSet) {
        this.profilesSet = profilesSet;
    }

    /**
     * Batch
	***/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        mProfiliBPER = MetadataUtility.getAllByMetadataName('Profilo_BPER__mdt');
        mRuoliSalesforce = getRuoliSalesforce(mProfiliBPER);
        for(User u : Database.query('SELECT Id, FederationIdentifier FROM User WHERE UserRoleId = NULL AND IsActive = true' + (!profilesSet.isEmpty() ? ' AND Profilo__c LIKE: profilesSet' : ''))){
            matricolaUserSet.add('U' + u.FederationIdentifier);
        }
        String query = 'SELECT '+String.join(queryFields, ',')+' FROM LDAP__c WHERE  Profilo_LDAP__c != null AND Matricola__c IN: matricolaUserSet ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<LDAP__c> scope) {
        Set<String> matricolaSet = new Set<String>();
        List<User> usersToUpdate = new List<User>();
        for(LDAP__c ldap: scope){
            if(String.isNotBlank(ldap.IDCed__c) && !mEscludiUtenzaTecnica.containsKey(ldap.Matricola__c)){
                matricolaSet.add(ldap.Matricola__c.replace('U', ''));
                RIDCEDSet.add('RIDCED'+ldap.IDCed__c);
            }
        }
        IdCedToRole=findRole(RIDCEDSet);
        Map<String,User> matricolaToUser=findUtenti(matricolaSet,false);
        for(LDAP__c ldap: scope){
            if(String.isNotBlank(ldap.IDCed__c) && !mEscludiUtenzaTecnica.containsKey(ldap.Matricola__c)){
                if(matricolaToUser.containsKey(ldap.Matricola__c.replace('U', ''))){
                    User u= matricolaToUser.get(ldap.Matricola__c.replace('U', ''));
                    if(ldap.Attivo__c){
                        User uc = u.clone(true,true,false,false);
                        Boolean toUpdate = false;
                        String profilo = ldap.Profilo_LDAP__c.replaceAll('\\.','_');
                        Profilo_BPER__mdt profiloBper = (Profilo_BPER__mdt)mProfiliBPER.get(profilo);
                        if (profiloBper!=null) {
                            if (!String.isBlank(profiloBper.Ruolo_Saleforce__c)) {
                                u.UserRoleId = (mRuoliSalesforce.containsKey(profiloBper.Ruolo_Saleforce__c) ? mRuoliSalesforce.get(profiloBper.Ruolo_Saleforce__c) : null);
                                usersToUpdate.add(u);
                            }else{
                                if(IdCedToRole.containsKey('RIDCED'+ldap.IDCed__c)) {
                                    UserRole userRoleByIdCed = IdCedToRole.get('RIDCED'+ldap.IDCed__c);
                                    u.idced__c = ldap.IDCed__c;
                                    if (uc.idced__c!=u.idced__c || u.UserRoleId != userRoleByIdCed.Id) {
                                        toUpdate = true;
                                        u.UserRoleId= userRoleByIdCed.Id;
                                        usersToUpdate.add(u);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        System.debug('DK usersToUpdate: ' + JSON.serialize(usersToUpdate));
        userAggiornati += usersToUpdate.size();
        update usersToUpdate;
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
        
        testoMail = NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' job con '+a.NumberOfErrors+' errori.<br/>';
        testoMail +=' Utenti aggiornati: '+ userAggiornati +' .<br/>';

        
        if (debug.Verbose__c) {
        	mandaMail('Recap',testoMail);
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

    private static Map<String,Id> getRuoliSalesforce(Map<String,sObject> profiliBPER) {
        Set<String> ruoli = new Set<String>();
        Map<String,Id> mRuoli = new Map<String,Id>();
        for (String key : profiliBPER.keySet()) {
            Profilo_BPER__mdt p = (Profilo_BPER__mdt)profiliBPER.get(key);
            if (!String.isBlank(p.Ruolo_Saleforce__c)) {
                ruoli.add(p.Ruolo_Saleforce__c);
            }
        }
        if (ruoli.size()>0) {
            List<UserRole> roles = [
                SELECT	Id,
                        DeveloperName
                FROM UserRole
                WHERE DeveloperName =:ruoli
            ];
            for (UserRole ur : roles) {
                mRuoli.put(ur.DeveloperName,ur.Id);
            }
        }
        
        return mRuoli;
    }
    
    private static Map<String,User> findUtenti(Set<String> matricolaSet,Boolean useIsActive){
        Map<String,User> returnMap = new Map<String,User>();
        List<User> users;
        if (useIsActive) {
            users = [SELECT Id, ProfileId,FederationIdentifier,IsActive,UserRoleId,Profilo__c,idced__c, abi__c, PTF_DivisionUO__c, PTF_MacroDivisionUO__c, PTF_RuoloLDAP__c, CRM_PermissionSet__c 
                        FROM User 
                        WHERE FederationIdentifier IN:matricolaSet AND isActive=true];
        }
        else {
            users = [SELECT Id, ProfileId,FederationIdentifier,IsActive,UserRoleId,Profilo__c,idced__c, abi__c, PTF_DivisionUO__c, PTF_MacroDivisionUO__c, PTF_RuoloLDAP__c, CRM_PermissionSet__c 
                        FROM User 
                        WHERE FederationIdentifier IN:matricolaSet];
        }
        for(User u: users){
            returnMap.put(u.FederationIdentifier, u);
        }
        
        return returnMap;
    }
    
    private static Map<String,UserRole> findRole(Set<String> RIDCEDSet){
        Map<String,UserRole> returnMap = new Map<String,UserRole>();
        
        List<UserRole> roles= [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName IN:RIDCEDSet ];
        
        for(UserRole r: roles){
            returnMap.put(r.DeveloperName, r);
        }
        
        return returnMap;
    }
}