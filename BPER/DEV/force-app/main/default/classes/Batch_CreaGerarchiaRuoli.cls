/****
 * Name			:	Batch_CreaGerarchiaRuoli
 * Create Date	:	2020-10-28
 * Author 		:	Ezio Dal Bo @TEN
 ****/
global class Batch_CreaGerarchiaRuoli implements Database.Batchable<sObject>,Database.stateful,IRunner {
    private static final String COD_CLASSE = 'GR003';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_CreaGerarchiaRuoli';
    
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Map<String,UserRole> mUserRole = new Map<String,UserRole>();
    global Map<String,List<UserRole>> mUserRoleNoLinked = new Map<String,List<UserRole>>();
    global Integer userRoleCreated = 0;
    global Integer groupCreated = 0;
    global Integer recordElab = 0;
    global Boolean errorOnCreate = false;
    global String testoMail ='';
    global Map<String,Set<String>> mConfPrivate = findConfigPrivateBankig();
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
        Integer numOfRecords = 0;
        String query = 'SELECT COUNT(Id) num FROM Struttura_Banca__c WHERE Stato__c IN (\'A\',\'D\') AND Da_Elaborare__c=TRUE AND Cambio_Stato__c=TRUE';
        List<AggregateResult> num = Database.query(query);
        for (AggregateResult ar : num) {
            Integer n = (ar.get('num')==null ? 0 : (Integer)ar.get('num'));
            numOfRecords += n;
        }
        query = 'SELECT '+String.escapeSingleQuotes(String.join(queryFields, ','))+' FROM Struttura_Banca__c WHERE Stato__c=\'A\' ORDER BY IDCed_Padre__c ASC';
        if (numOfRecords==0) {
            query = 'SELECT '+String.escapeSingleQuotes(String.join(queryFields, ','))+' FROM Struttura_Banca__c WHERE Stato__c IN (\'A\',\'D\') AND Da_Elaborare__c=TRUE AND Cambio_Stato__c=TRUE';
        }
        if (Test.isRunningTest()) {
            query += ' LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Struttura_Banca__c> scope) {   
        Set<String> sIDCedFather = new Set<String>();
        Set<String> idCedToManage = new Set<String>();
        List<UserRole> userRoleToInsert = new List<UserRole>();
        List<UserRole> userRoleToUpdate = new List<UserRole>();
        Map<String,Struttura_Banca__c> mStrutturaBanca = new Map<String,Struttura_Banca__c>();
        //Map<String, String> mGroupNameToRoleName = new Map<String, String>();
        try {
            recordElab += scope.size();
            if (!errorOnCreate) {
                // create a Map<RIDCED,Struttura_Banca__c>
                // create a set of idced father and idce child to manage
                for (Struttura_Banca__c sb : scope) {
                    //sStrutturaBancaToManage.add('R'+sb.IDCed__c);
                    mStrutturaBanca.put('RIDCED'+sb.IDCed__c,sb);
                    //mGroupNameToRoleName.put('GIDCED'+sb.IDCed__c,'RIDCED'+sb.IDCed__c);
                    if (!String.isEmpty(sb.IDCed_Padre__c)) {
                        sIDCedFather.add('RIDCED'+sb.IDCed_Padre__c);
                    }
                }
                // retrive all father idced roles
                if (sIDCedFather.size()>0) {
                    mUserRole.putAll(findUserRoleByDevName(sIDCedFather));
                }
                // retrive all idced role child if exist
                // exlude it if icded exists
                if (!mStrutturaBanca.isEmpty()) {
                    Map<String,UserRole> mRoles = findUserRoleByDevName(mStrutturaBanca.keySet());
                    if (!mRoles.isEmpty()) {
                        mUserRole.putAll(mRoles);
                        for (String key : mStrutturaBanca.keySet()) {
                            if (!mUserRole.containsKey(key)) {
                                idCedToManage.add(key);
                            }
                            else if(!String.isEmpty(mStrutturaBanca.get(key).IDCed_Padre__c)){
                                String key2 = mStrutturaBanca.get(key).IDCed_Padre__c;
                                if(!mUserRoleNoLinked.containskey('RIDCED'+key2)){
                                    mUserRoleNoLinked.put('RIDCED'+key2, new List<UserRole>());
                                }
                                mUserRoleNoLinked.get('RIDCED'+key2).add(mUserRole.get(key));
                            }
                        }
                    }
                    else {
                        idCedToManage.addAll(mStrutturaBanca.keySet()); 
                    }
                    if (Test.isRunningTest()) {
                        Struttura_Banca__c sbTest = new Struttura_Banca__c(
                            IDCed__c='Test',
                            Descrizione__c ='Test'
                        );
                        mStrutturaBanca.put('Test',sbTest);
                        idCedToManage.add('Test');
                    }
                    // check if there are idced to create
                    if (idCedToManage.size()>0) {
                        //create userRole record based on idced
                        for (String key : idCedToManage) {
                            UserRole ur = createUserRole(mStrutturaBanca.get(key));
                            userRoleToInsert.add(ur);
                        }
                    
                        // insert userRole Records
                        insert userRoleToInsert;
                        userRoleCreated += userRoleToInsert.size();
                        // loop on record to link new record to father
                        // if not is possible link it, the record is insert for a future update
                        for (UserRole ur : userRoleToInsert) {
                            mUserRole.put(ur.DeveloperName,ur);
                            Struttura_Banca__c sb = mStrutturaBanca.get(ur.DeveloperName);
                            if (!String.isEmpty(sb.IDCed_Padre__c)) {
                                if (mUserRole.containsKey('RIDCED'+sb.IDCed_Padre__c)) {
                                    ur.ParentRoleId = mUserRole.get('RIDCED'+sb.IDCed_Padre__c).Id;
                                    userRoleToUpdate.add(ur);
                                }
                                else {
                                    List<UserRole> urs = (mUserRoleNoLinked.containsKey('RIDCED'+sb.IDCed_Padre__c) ? mUserRoleNoLinked.get('RIDCED'+sb.IDCed_Padre__c) : new List<UserRole>());
                                    urs.add(ur);
                                    mUserRoleNoLinked.put('RIDCED'+sb.IDCed_Padre__c,urs);
                                }
                            }
                        }
                    }
                }
            }
        }
        catch(Exception exc) {
            // intercept the error
            // set a boolean variable to true so the process is "blocked"
            System.debug(NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            errorOnCreate = true;
        }
        // loop on role map to find if there are user role records to link to father
        for (String key : mUserRole.keySet()) {
            if (mUserRoleNoLinked.containsKey(key)) {
                UserRole fur = mUserRole.get(key);
                List<UserRole> urs = mUserRoleNoLinked.get(key);
                for (UserRole ur : urs) {
                    ur.ParentRoleId = fur.Id;
                    userRoleToUpdate.add(ur);
                }
                mUserRoleNoLinked.remove(key);
            }
        }
        // update records
        try {
            if (userRoleToUpdate.size()>0) {
                update userRoleToUpdate;
            }
        }
        catch(Exception exc) {
            System.debug(NOME_CLASSE+' - An exception occurred during update records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during update records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            errorOnCreate = true;
        }
        
        try{
            groupCreated+=createGroup(userRoleToInsert, mConfPrivate);
        }
        catch(Exception exc){
            System.debug(NOME_CLASSE+' - An exception occurred during update records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during update records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
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
        
        testoMail = '';
        if (errorOnCreate) {
            testoMail += '<span style="{color:red;}">Ci sono stati degli errori durante la fase di gestione dei record. sono state inviate le mail</span><br/><br/>';
        }
        
        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'Numero totale di Record elaborati : '+recordElab+'<br/>';
        testoMail += 'Numero totale di Ruoli creati: '+userRoleCreated+'<br/>';
        testoMail += 'Numero totale di Gruppi creati: '+groupCreated+'<br/>';
        if (debug.Verbose__c) {
        	mandaMail('Recap',testoMail);
        }
        if (sj!=null && sj.size()>0 && !errorOnCreate) {
            JobRunner.executeNext(sj);
        }
    }
    
    /* prvate methods */
    /***
     * Name			:	createUserRole
     * Author		:	Ezio Dal Bo @TEN
     * Create date	:	2020-10-28
     ***/
    private static UserRole createUserRole(Struttura_Banca__c sb) {
        UserRole ur = new UserRole();
        ur.DeveloperName = 'RIDCED'+sb.IDCed__c;
        String descrizione = (sb.Descrizione__c.length()>80 ? sb.Descrizione__c.substring(0,80): sb.Descrizione__c);
        String nome = sb.Descrizione__c+'_'+sb.IDCed__c;
        if (nome.length()>80) {
            Integer lIdCed = ('_'+sb.IDCed__c).length();
            Integer lDesc = descrizione.length();
            nome = descrizione.substring(0,lDesc-lIdCed)+'_'+sb.IDCed__c;
        }
        ur.Name = nome;
        return ur;
    }
    
    /***
     * Name			:	findUserRoleByDevName
     * Author		:	Ezio Dal Bo @TEN
     * Create date	:	2020-10-28
     ***/
    public static Map<String,UserRole> findUserRoleByDevName(Set<String> devNames) {
        Map<String,UserRole> mUserRole = new Map<String,UserRole>();
        
        try {
            List<UserRole> usrRoles = [
                SELECT  Id,
                        DeveloperName,
                        Name
                FROM UserRole
                WHERE DeveloperName IN:devNames
            ];
            
            if (usrRoles!=null && usrRoles.size()>=0) {
                for (UserRole ur : usrRoles) {
                    mUserRole.put(ur.DeveloperName,ur);
                }
            }
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return mUserRole;
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
        if (!Test.isRunningTest()) {
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    /*private static Integer createGroup(Map<String,String> mGroupNameToRoleName, Set<String> roleNames){
        List<Group> groupList = [SELECT DeveloperName FROM Group WHERE DeveloperName IN:mGroupNameToRoleName.keySet()];
        List<String> groupNames = new List<String>();
        for(Group g: groupList){
            groupNames.add(g.DeveloperName);
        }
        Map<String, UserRole> mRoleNameToRole= findUserRoleByDevName(roleNames);

        List<Group> groupToInsert = new List<Group>();
        
        for(String groupName: mGroupNameToRoleName.keySet()){
            if(!groupNames.contains(groupName)){
                Group g= new Group();
                g.Name=groupName;
                g.DeveloperName=groupName;
                g.Type='Regular';
                groupToInsert.add(g);
            }
        }

        insert groupToInsert;

        

        List<Group> roleGroups = [SELECT Id, DeveloperName FROM Group WHERE Type='Role' AND DeveloperName IN:roleNames];

        Map<String,String> groupDevNameToId= new Map<String,String>();

        for(Group g:roleGroups){
            groupDevNameToId.put(g.DeveloperName, g.Id);
        }

        List<GroupMember> memeberToInsert = new List<GroupMember>();
        for(Group g: groupToInsert){
            GroupMember member= new GroupMember();
            member.GroupId= g.Id;
            member.UserOrGroupId=groupDevNameToId.get(mGroupNameToRoleName.get(g.DeveloperName));
            memeberToInsert.add(member);
        }
        
        insert memeberToInsert;

        return groupToInsert.size();
        
    }*/
    
    public static Integer createGroup(List<UserRole>userRoleToInsert, Map<String,Set<String>> mConfPrivate){
        Set<String> groupToCreate = new Set<String>();
        List<Group> groupToInsert = new List<Group>();
        for (UserRole ur : userRoleToInsert) {
            String rIDCed = ur.DeveloperName;
            String value = rIDCed.substring(6);
            if (mConfPrivate.containsKey(value)) {
                Set<String> cps = mConfPrivate.get(value);
                for (String cp : cps) {
                    groupToCreate.add(cp+'_'+value);
                }
            }
        }
        
        if (groupToCreate.size()>0) {
            List<Group> groupList = [SELECT DeveloperName FROM Group WHERE DeveloperName IN:groupToCreate];
            for (Group gr : groupList) {
                groupToCreate.remove(gr.DeveloperName);
            }
        }
        
        for (String gr : groupToCreate) {
            Group g= new Group();
            g.Name=gr;
            g.DeveloperName=gr;
            g.Type='Regular';
            groupToInsert.add(g);
        }
        
        if (groupToInsert.size()>0) {
            insert groupToInsert;
        }
        
        return groupToInsert.size();
    }
    
    private static Map<String,Set<String>> findConfigPrivateBankig() {
        Map<String,Set<String>> mPrivateBanking = new Map<String,Set<String>>();
        
        try {
            List<ConfigUffPrivateDR__c> conf = [
                SELECT	Id,
                		PTF_IdCP__c,
                		PTF_IdCEDUffPrivate__c
                FROM ConfigUffPrivateDR__c
            ];
            
            if (conf!=null && conf.size()>0) {
                for (ConfigUffPrivateDR__c c : conf) {
                    Set<String> sCodici = (mPrivateBanking.containsKey(c.PTF_IdCEDUffPrivate__c) ? mPrivateBanking.get(c.PTF_IdCEDUffPrivate__c) : new Set<String>());
                    sCodici.add(c.PTF_IdCP__c);
                    mPrivateBanking.put(c.PTF_IdCEDUffPrivate__c,sCodici);
                }
            }
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return mPrivateBanking;
    }
}