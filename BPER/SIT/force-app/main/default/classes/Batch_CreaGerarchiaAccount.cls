global class Batch_CreaGerarchiaAccount implements Database.Batchable<sObject>,Database.stateful,IRunner{
    private static final String COD_CLASSE = 'GA001';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_CreaGerarchiaAccount';

    global Map<String,SObject> livelloToRecordType = MetadataUtility.getAllByMetadataName('LivelloToRecordType__mdt');
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global Map<String,Account> mAccount = new Map<String,Account>();
    global Map<String,String> mStrutturaIdCedToIdCedPadre = new Map<String,String>();
    global Set<String> livelloSkipSettingIdCedPadre= new Set<String>{'20','117','150', '142', '180','190','200'};
    global Map<String,List<Account>> mAccountNoLinked = new Map<String,List<Account>>();
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();

    global Integer recordElab = 0;
    global Integer accountCreated=0;
    global Boolean errorOnCreate = false;
    global String testoMail ='';
    private List<String> queryFields = new List<String> {
        'Id',
        'IDCed__c',
        'IDCed_Padre__c',
        'IDCed_UffPrivate__c',
        'Stato__c',
        'Descrizione__c',
        'Livello__c',
        'Tipo_Sportello__c',
        'Dimensione__c',
        'ABI__c',
        'Codice_Filiale__c',
        'Filiera__c',
        'Macro_Filiera__c',
        'isPTF__c',
        'isCRM__c',
        'CRM_Email__c'
    };

    public Map<String, String> collegamentoUfficioMap {
        get{

            if(collegamentoUfficioMap != null){

                return collegamentoUfficioMap;
            }
            collegamentoUfficioMap = new Map<String, String>();
            for(ConfigUffPrivateDR__c collegamentoUfficio : [SELECT ID, IdCed__c, IdCedPadre__c FROM ConfigUffPrivateDR__c WHERE IdCed__c != '' AND IdCedPadre__c != '']){
                collegamentoUfficioMap.put(collegamentoUfficio.IdCed__c, collegamentoUfficio.IdCedPadre__c);
            }
            return collegamentoUfficioMap;
        }set;
    }
    /***
     * IRunner
     ***/
    global void initRunner(List<ScheduledJob__c> schedules) {
        this.sj.addAll(schedules);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        Map<String, SObject> strutturaActive = SV_Utilities.keyBy([SELECT IDCed__c, IDCed_Padre__c, Livello__c FROM Struttura_Banca__c WHERE Stato__c='A'], 'IDCed__c') ;
        Map <String, Struttura_Banca__c> mapIdCedToPadre = new Map<String, Struttura_Banca__c>();

        for(String IdCed: strutturaActive.keySet()){
            Struttura_Banca__c sb= (Struttura_Banca__c) strutturaActive.get(IdCed);
            if(String.isNotBlank(sb.IDCed_Padre__c)){
                if(strutturaActive.containsKey(sb.IDCed_Padre__c)) mapIdCedToPadre.put(sb.IDCed__c,(Struttura_Banca__c) strutturaActive.get(sb.IDCed_Padre__c));  
            }
        }

        for(String IdCed: strutturaActive.keySet()){
            Boolean stop=false;
            Struttura_Banca__c sb = (Struttura_Banca__c) strutturaActive.get(IdCed);
            Struttura_Banca__c recordToCheck= sb;
            Struttura_Banca__c foundParent= new Struttura_Banca__c();
            
            if(collegamentoUfficioMap.containsKey(IdCed)){
                System.debug('DK: ' + IdCed + '=>' +  collegamentoUfficioMap.get(IdCed));
                mStrutturaIdCedToIdCedPadre.put(sb.IDCed__c, collegamentoUfficioMap.get(IdCed));
            }else if(!livelloSkipSettingIdCedPadre.contains(sb.Livello__c)){
                do{
                    if(mapIdCedToPadre.containsKey(recordToCheck.IDCed__c)){
                        Struttura_Banca__c padre= mapIdCedToPadre.get(recordToCheck.IDCed__c);
                        if(livelloSkipSettingIdCedPadre.contains(padre.Livello__c)){
                            foundParent= padre;
                            stop=true;
                        }
                        else{
                            recordToCheck=padre;
                        }
                    }
                    else{
                        stop=true;
                    }  
                }
                while(!stop);
                if(foundParent!=null){
                    mStrutturaIdCedToIdCedPadre.put(sb.IDCed__c, foundParent.IDCed__c);
                }
            }
        }


        String query = 'SELECT '+String.join(queryFields, ',')+' FROM Struttura_Banca__c ORDER BY IDCed_Padre__c ASC';
        if (Test.isRunningTest()) {
            query += ' LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }

    
    global void execute(Database.BatchableContext BC, List<Struttura_Banca__c> scope) {

        
        Set<String> sIDCedFather = new Set<String>();
        Set<String> idCedToManage = new Set<String>();
        List<Account> accountToInsert= new List<Account>();
        List<Account> accountToUpdate= new List<Account>();
        Map<String,Struttura_Banca__c> mStrutturaBanca = new Map<String,Struttura_Banca__c>();
        Set<String> StrutturaBancaNotActive = new Set<String>();
        Map<String,Account> mAccountToDeactivate = new Map<String,Account>();
        try {
            Batch_AccountLink.skipAccountTrigger=true;
            recordElab += scope.size();
            if (!errorOnCreate) {
               
                for (Struttura_Banca__c sb : scope) {
                    
                    if ('D'.equals(sb.Stato__c)) {
                        StrutturaBancaNotActive.add(sb.IDCed__c);
                    }
                    else if ('A'.equals(sb.Stato__c)) {
                        mStrutturaBanca.put(sb.IDCed__c,sb);
                        if (!String.isEmpty(sb.IDCed_Padre__c)) {
                            sIDCedFather.add(sb.IDCed_Padre__c);
                        }
                    }
                }
                if (sIDCedFather.size()>0) {
                    mAccount.putAll(findAccountByIdCed(sIDCedFather,false));
                }
                
                if (StrutturaBancaNotActive.size()>0) {
                    mAccountToDeactivate.putAll(findAccountByIdCed(StrutturaBancaNotActive,true));
                }

                if (!mStrutturaBanca.isEmpty()) {
                    Map<String,Account> mTempAccounts = findAccountByIdCed(mStrutturaBanca.keySet(),false);
                    if(!mTempAccounts.isEmpty()){
                        mAccount.putAll(mTempAccounts);
                        for (String key : mStrutturaBanca.keySet()){
                            if(!mAccount.containsKey(key)){
                                idCedToManage.add(key);
                            }
                            else if(!String.isEmpty(mStrutturaBanca.get(key).IDCed_Padre__c)){
                                String key2 = mStrutturaBanca.get(key).IDCed_Padre__c;
                                if(!mAccountNoLinked.containskey(key2)){
                                    mAccountNoLinked.put(key2, new List<Account>());
                                }
                                Account acc = createAccount(mStrutturaBanca.get(key), livelloToRecordType);
                                // acc.IdCedExecutive__c = collegamentoUfficioMap.containsKey(acc.PTF_IDCed__c) ? collegamentoUfficioMap.get(acc.PTF_IDCed__c) : '';
                                acc.Id=mAccount.get(key).Id;
                                mAccountNoLinked.get(key2).add(acc);
                            }
                            else{
                                Account acc = createAccount(mStrutturaBanca.get(key), livelloToRecordType);
                                // acc.IdCedExecutive__c = collegamentoUfficioMap.containsKey(acc.PTF_IDCed__c) ? collegamentoUfficioMap.get(acc.PTF_IDCed__c) : '';
                                acc.Id=mAccount.get(key).Id;
                                accountToUpdate.add(acc);
                            }
                        }
                    }
                    else {
                        idCedToManage.addAll(mStrutturaBanca.keySet()); 
                    }
                    if (idCedToManage.size()>0){
                        for (String key : idCedToManage){
                            Account acc = createAccount(mStrutturaBanca.get(key),livelloToRecordType);
                            // acc.IdCedExecutive__c = collegamentoUfficioMap.containsKey(acc.PTF_IDCed__c) ? collegamentoUfficioMap.get(acc.PTF_IDCed__c) : '';
                            accountToInsert.add(acc);
                        }
                    }
                    if(accountToInsert.size()>0){
                        insert accountToInsert;
                    }
                   
                    accountCreated+=accountToInsert.size();

                    for(Account acc: accountToInsert){
                        mAccount.put(acc.PTF_IdCED__c,acc);
                        Struttura_Banca__c sb = mStrutturaBanca.get(acc.PTF_IdCED__c);
                        if (!String.isEmpty(sb.IDCed_Padre__c)){
                            if(mAccount.containsKey(sb.IDCed_Padre__c)){
                                acc.ParentId=mAccount.get(sb.IDCed_Padre__c).Id;
                                if(mStrutturaIdCedToIdCedPadre.containsKey(sb.IDCed__c)) acc.PTF_IdCEDPadre__c=mStrutturaIdCedToIdCedPadre.get(sb.IDCed__c);
                                accountToUpdate.add(acc);
                            }
                            else{
                                List<Account> accs = (mAccountNoLinked.containsKey(sb.IDCed_Padre__c) ? mAccountNoLinked.get(sb.IDCed_Padre__c) : new List<Account>());
                                accs.add(acc);
                                mAccountNoLinked.put(sb.IDCed_Padre__c,accs);
                            }
                        }
                        
                    }
                }
            }
        }
        catch(Exception exc){
            // intercept the error
            // set a boolean variable to true so the process is "blocked"
            System.debug(NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            errorOnCreate = true;
        }

        for (String key : mAccount.keySet()) {
            if (mAccountNoLinked.containsKey(key)) {
                Account padre = mAccount.get(key);
                List<Account> figli = mAccountNoLinked.get(key);
                for (Account acc : figli) {
                    acc.ParentId = padre.Id;
                    if(mStrutturaIdCedToIdCedPadre.containsKey(acc.PTF_IdCED__c)) acc.PTF_IdCEDPadre__c=mStrutturaIdCedToIdCedPadre.get(acc.PTF_IdCED__c);
                    accountToUpdate.add(acc);
                }
                mAccountNoLinked.remove(key);
            }
        }

        try {
            if (!mAccountToDeactivate.isEmpty()) {
                for (String key : mAccountToDeactivate.keySet()) {
                    Account acc = mAccountToDeactivate.get(key);
                    acc.PTF_DataChiusura__c = DateTime.now();
                    mAccountToDeactivate.put(key,acc);
                }
            }
            if (accountToUpdate.size()>0) {
                for (Account acc : accountToUpdate) {
                    if (mAccountToDeactivate.containsKey(acc.PTF_IdCED__c)) {
                        acc.PTF_DataChiusura__c = dateTime.now();
                    }
                    mAccountToDeactivate.put(acc.PTF_IdCED__c,acc);
                }
            }
            
            if (!mAccountToDeactivate.isEmpty()) {
                update mAccountToDeactivate.values();
            }
        }
        catch(Exception exc) {
            System.debug(NOME_CLASSE+' - An exception occurred during update records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during update records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            errorOnCreate = true;
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
        
        testoMail = '';
        if (errorOnCreate) {
            testoMail += '<span style="{color:red;}">Ci sono stati degli errori durante la fase di gestione dei record. sono state inviate le mail</span><br/><br/>';
        }
        
        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'Numero totale di Record elaborati : '+recordElab+'<br/>';
        testoMail += 'Numero totale di Account creati: '+accountCreated+'<br/>';

        if (debug.Verbose__c) {
            mandaMail('Recap',testoMail);
        }
        if (sj!=null && sj.size()>0 && !errorOnCreate) {
            JobRunner.executeNext(sj);
        }
        //System.enqueueJob(new AccountQueueableJob());
        /*if (!Test.isRunningTest()) {
            Database.executeBatch(new Batch_AccountLink());
        }*/
    }

    private static Account createAccount(Struttura_Banca__c sb, Map<String,SObject> livelloToRecordType) {
        Account acc = new Account();
        if(livelloToRecordType.containsKey('X'+sb.Livello__c)){
            String rtDevName = (String) livelloToRecordType.get('X'+sb.Livello__c).get('RTDevName__c');
            acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        }
        
        else{
            acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AltraUnitaOrganizzativa').getRecordTypeId();
        }
        if(sb.Livello__c=='180' || sb.Livello__c=='190' || sb.Livello__c=='200'){
            if(!sb.Descrizione__c.startsWithIgnoreCase('CENTRO IMPRESE')){
                acc.PTF_IdCEDFiliale__c=sb.Codice_Filiale__c;
                acc.Name=acc.PTF_IdCEDFiliale__c +' - '+ sb.Descrizione__c.left(80);
                acc.PTF_BranchTypology__c=sb.Tipo_Sportello__c;
            }
            else{
                acc.PTF_IdCEDFiliale__c=sb.Codice_Filiale__c;
                acc.Name=acc.PTF_IdCEDFiliale__c +' - '+ sb.Descrizione__c.left(80);
                acc.PTF_BranchTypology__c='F';
            }
        }
        else{
            acc.Name= sb.Descrizione__c.left(80);
            acc.PTF_BranchTypology__c=sb.Tipo_Sportello__c;
        }
        acc.CRM_Nome__c=acc.Name;
        acc.PTF_Livello__c=sb.Livello__c;
        acc.PTF_Dimensione__c=sb.Dimensione__c;
        acc.PTF_IdCED__c=sb.IDCed__c;
        //NEW UFF PRIVATE
        acc.PTF_IDCEDUffPrivate__c=sb.IDCed_UffPrivate__c;
        //NEW UFF PRIVATE
        acc.FinServ__BankNumber__c=sb.ABI__c;
        acc.PTF_Division__c=sb.Filiera__c;
        acc.PTF_MacroDivision__c=sb.Macro_Filiera__c;
        acc.PTF_DataApertura__c = DateTime.now();
        acc.PTF_DataChiusura__c = null;
        acc.IsPTF__c = sb.IsPTF__c;
        acc.IsCRM__c = sb.IsCRM__c;
        acc.CRM_EmailSB__c = sb.CRM_Email__c;
        System.debug('@@@ account: '+acc);
        return acc;
    }

    private static Map<String,Account> findAccountByIdCed(Set<String> IdCeds,Boolean checkDataChiusura) {
        Map<String,Account> mAccount = new Map<String,Account>();
        Set<String> recTypes = new Set<String>{'FilialeDiRelazione','Area','DirezioneRegionale','Banca','AltraUnitaOrganizzativa'};
        try {
            String query = 'SELECT Id,ParentId,PTF_IdCED__c,PTF_DataApertura__c,PTF_DataChiusura__c,Name,IsPTF__c,IsCRM__c,CRM_EmailSB__c ';
            query += 'FROM account WHERE PTF_IdCed__c IN:IdCeds AND RecordType.DeveloperName IN:recTypes';
            if (checkDataChiusura) {
                query += ' AND PTF_DataChiusura__c=NULL';
            }
            List<Account> accounts  = Database.query(query);
            System.debug('AAA '+accounts);
            /*List<Account> accounts = [
                SELECT  Id,
                        ParentId,
                        PTF_IdCED__c,
                        PTF_DataApertura__c,
                        PTF_DataChiusura__c,
                        Name
                FROM Account
                WHERE PTF_IdCED__c IN:IdCeds
            ];*/
            
            if (accounts!=null && accounts.size()>=0) {
                for (Account acc : accounts) {
                    mAccount.put(acc.PTF_IdCED__c,acc);
                }
            }
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return mAccount;
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
     * Name         :   generaMail
     * Author       :   Ezio Dal Bo @TEN
     * Create date  :   2020-10-28
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