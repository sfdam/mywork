global class Batch_CalcoloReferenti implements Database.Batchable<sObject>,Database.stateful,IRunner {
    public static Boolean runAssignmentTrigger=false;
    private static final String COD_CLASSE = 'CR001';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_CalcoloReferenti';
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Boolean errorOnCreate = false;
    global Integer recordElab = 0;
    global Integer assignmentUpdated=0;
    global Integer walletUpdated=0;
    global String testoMail ='';
    public List<String> daElaborare =new List<String>();

    global void initRunner(List<ScheduledJob__c> schedules) {
        sj.addAll(schedules);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('Batch_CalcoloReferenti start');

        Set<String> mdsToExclude= new Set<String>{'POE','Family','Controparti Istituzionali','Assente','Residuale'};
		
        for(LDAP__c ldap :[SELECT id,Matricola__c FROM LDAP__c where Da_Elaborare__c =true ]){
            String a=(ldap.Matricola__c.SubStringAfter('U'));    
                daElaborare.add(a);
        }      
        system.debug('daElaborare' +daElaborare);
        String query = 'SELECT Id, CRM_ReferentePortafoglio__r.PTF_Idced__c, CRM_ReferentePortafoglio__r.PTF_TipologiaRuolo__r.PTF_Code__c, CRM_ReferentePortafoglio__r.AccountId, PTF_UffPrivate__r.PTF_IdCEDPadre__c, PTF_UffPrivate__c, PTF_UffPrivate__r.PTF_IdCED__c, PTF_ModelloDiServizio__c, PTF_Filiale__r.PTF_BranchTypology__c, PTF_Filiale__r.PTF_IdCed__c, PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Banca__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Filiale__r.PTF_IdCedUffPrivate__c, ';
        query+= ' (SELECT Id, RecordType.DeveloperName, PTF_Gestore__c, PTF_Gestore__r.PTF_IdCED__c, PTF_Gestore__r.PTF_RegistrationNumber__c, PTF_Gestore__r.PTF_CentroPrivate__c, PTF_Gestore__r.PTF_Ruolo__c, PTF_Gestore__r.PTF_ReferenteElegibile__c, PTF_Gestore__r.Account.Name, PTF_Gestore__r.Account.PTF_IdCed__c, PTF_Gestore__r.Account.PTF_IdCEDPadre__c, PTF_Gestore__r.PTF_TipologiaRuolo__c FROM Backup_Assignments__r WHERE PTF_EndDate__c=null) ';
        query+=' FROM Wallet__c WHERE PTF_Deleted__c = false AND PTF_ModelloDiServizio__c NOT IN:mdsToExclude  AND CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c IN :daElaborare ';

        if(Test.isRunningTest()){
            query+=' LIMIT 1000';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Wallet__c> scope) {
        system.debug('scope:'+scope);
        try{
            //CR 53259 SV Start
            Map<String,String> walToChangeUffPrivate= new Map<String,String>();
            List<Wallet__c> walToChangeUffPrivateList= new List<Wallet__c>();
            List<Wallet__c> walToAssign= new List<Wallet__c>();
            List<Assignment__c> assToStart= new List<Assignment__c>();
            //CR 53259 SV End
            List<Assignment__c> assToEnd= new List<Assignment__c>();
            List<Wallet__c> walToUp= new List<Wallet__c>();
            Set<Wallet__c> walToUpSet= new Set<Wallet__c>();
            Map<String,EscludiUtenzaDaSgancio__c> mEscludiDaSgancio = EscludiUtenzaDaSgancio__c.getAll();
             system.debug('mEscludiDaSgancio'+mEscludiDaSgancio);
            Set<String> role41_42= SV_Utilities.getSet([SELECT Id FROM RoleTypology__c WHERE PTF_Code__c IN ('041','042')], 'Id');
            List<String> eligibleRoles = new List<String>();
            for(RoleMDS__c roleMDS : [SELECT Id, PTF_RoleTypology__c, PTF_ServiceModel__r.Name, PTF_BranchTypology__c
                            FROM RoleMDS__c 
                            WHERE
                            PTF_RoleTypology__c != '' AND
                            PTF_StartDate__c <=: Date.today()
                            AND (PTF_EndDate__c >=: Date.today() OR PTF_EndDate__c=null)]){

                
                
                    
                eligibleRoles.add(roleMDS.PTF_RoleTypology__c+'_'+roleMDS.PTF_ServiceModel__r.Name.toUpperCase()+'_'+roleMDS.PTF_BranchTypology__c);
                
            }
            Map<String,Set<String>> mUffPrivate= new Map<String,Set<String>>();
            Map<String,Set<String>> mSupUffPrivate= new Map<String,Set<String>>();
            for(ConfigUffPrivateDR__c conf: [SELECT PTF_IdCEDDR__c, PTF_IdCEDUffPrivate__c, PTF_IdCP__c FROM ConfigUffPrivateDR__c]){
                if(!mUffPrivate.containsKey(conf.PTF_IdCEDDR__c)){
                    mUffPrivate.put(conf.PTF_IdCEDDR__c,new Set<String>());
                }
                mUffPrivate.get(conf.PTF_IdCEDDR__c).add(conf.PTF_IdCP__c+'_'+conf.PTF_IdCEDUffPrivate__c);
                if(!mSupUffPrivate.containsKey(conf.PTF_IdCEDDR__c)){
                    mSupUffPrivate.put(conf.PTF_IdCEDDR__c,new Set<String>());
                }
                mSupUffPrivate.get(conf.PTF_IdCEDDR__c).add(conf.PTF_IdCEDUffPrivate__c);
            }
            for(Wallet__c w:scope){
                //CR 53259 SV Start
                System.debug('@@@@'+w.Id);
                if(w.PTF_ModelloDiServizio__c=='Private' /*&& w.PTF_Banca__r.FinServ__BankNumber__c == '05387' */&& w.PTF_UffPrivate__r.PTF_IdCED__c!=w.CRM_ReferentePortafoglio__r.PTF_Idced__c && w.CRM_ReferentePortafoglio__r.PTF_TipologiaRuolo__r.PTF_Code__c=='069' && w.PTF_Filiale__r.PTF_IdCedUffPrivate__c.contains(w.CRM_ReferentePortafoglio__r.PTF_Idced__c)) {
                    walToChangeUffPrivate.put(w.Id,w.CRM_ReferentePortafoglio__r.AccountId);
                }
              
                //CR 53259 SV End
                for(Assignment__c ass:w.Backup_Assignments__r){
                    
                    if(ass.PTF_Gestore__r.PTF_Ruolo__c=='029'){
                        system.debug('Batch CR 91');
                        continue;
                    }
                    String key= ass.PTF_Gestore__r.PTF_TipologiaRuolo__c+'_'+w.PTF_ModelloDiServizio__c.toUpperCase()+'_'+w.PTF_Filiale__r.PTF_BranchTypology__c;
                    //Banca
                    if(ass.PTF_Gestore__r.Account.PTF_IdCedPadre__c==w.PTF_Banca__r.PTF_IdCed__c){
                        system.debug('Batch CR 98');
                        /*if(w.PTF_ModelloDiServizio__c=='Private'){
                            if(w.PTF_Banca__r.FinServ__BankNumber__c == '01015'){

                                if(ass.PTF_Gestore__r.PTF_Ruolo__c=='100' 
                                && mSupUffPrivate.containsKey(w.PTF_DirezioneRegionale__r.PTF_IdCed__c) 
                                && mSupUffPrivate.get(w.PTF_DirezioneRegionale__r.PTF_IdCed__c).contains(ass.PTF_Gestore__r.Account.PTF_IdCed__c)
                                && eligibleRoles.contains(key)
                                &&ass.PTF_Gestore__r.PTF_ReferenteElegibile__c){
                                    continue;
    
                                }
                                if(ass.PTF_Gestore__r.PTF_Ruolo__c=='069' 
                                && mUffPrivate.containsKey(w.PTF_DirezioneRegionale__r.PTF_IdCed__c) 
                                && mUffPrivate.get(w.PTF_DirezioneRegionale__r.PTF_IdCed__c).contains(ass.PTF_Gestore__r.PTF_CentroPrivate__c+'_'+ass.PTF_Gestore__r.Account.PTF_IdCed__c)
                                && eligibleRoles.contains(key)
                                && ass.PTF_Gestore__r.PTF_ReferenteElegibile__c){
                                    continue;
    
                                }
    
                                /*if(w.PTF_Banca__r.PTF_IdCed__c=='2517' 
                                && ass.PTF_Gestore__r.Account.PTF_IdCed__c=='5690'
                                && eligibleRoles.contains(key)
                                && ass.PTF_Gestore__r.PTF_ReferenteElegibile__c){
                                    continue;
                                }*/
                            /*}
                        }
                        else */if(eligibleRoles.contains(key) && ass.PTF_Gestore__r.PTF_ReferenteElegibile__c){
                            system.debug('Batch CR 127');
                            continue;
                        }
                    }
                    //Banca

                    //DR
                    if(ass.PTF_Gestore__r.Account.PTF_IdCedPadre__c==w.PTF_DirezioneRegionale__r.PTF_IdCed__c){
                        system.debug('Batch CR 135');
                        if(ass.PTF_Gestore__r.Account.Name.startsWithIgnoreCase('Uff. Sviluppo ') 
                        && ass.PTF_Gestore__r.PTF_Ruolo__c=='100'
                        ){
                            for(String roleKey:role41_42){
                                if(eligibleRoles.contains(roleKey+'_'+w.PTF_ModelloDiServizio__c.toUpperCase()+'_'+w.PTF_Filiale__r.PTF_BranchTypology__c) && ass.PTF_Gestore__r.PTF_ReferenteElegibile__c){
                                    break;
                                }
                            }
                        }
                        else if(eligibleRoles.contains(key) && ass.PTF_Gestore__r.PTF_ReferenteElegibile__c){
                            system.debug('Batch CR 146');
                            continue;
                        }
                    }
                    //DR
                    //Area
                    if(ass.PTF_Gestore__r.Account.PTF_IdCed__c==w.PTF_Area__r.PTF_IdCed__c){
                        if(eligibleRoles.contains(key) && ass.PTF_Gestore__r.PTF_ReferenteElegibile__c){
                            system.debug('Batch CR 154');
                            continue;
                        }
                    }
                    //Area
                    //Filiale
                    if(ass.PTF_Gestore__r.Account.PTF_IdCed__c==w.PTF_Filiale__r.PTF_IdCed__c){
                        if(eligibleRoles.contains(key) && ass.PTF_Gestore__r.PTF_ReferenteElegibile__c){
                            system.debug('Batch CR 162');
                            continue;
                        }
                    }
                    //Filiale

                    //Consulenti Finanziari
                    if(w.PTF_ModelloDiServizio__c=='Consulenti Finanziari'){
                        if(ass.PTF_Gestore__r.Account.PTF_IdCed__c=='7113' && ((ass.PTF_Gestore__r.PTF_Ruolo__c=='990') || (ass.PTF_Gestore__r.PTF_Ruolo__c=='991')) ){
                            system.debug('Batch CR 171');
                            continue;
                        }
                    }
                    //Consulenti Finanziari

                    //NEW UFF PRIVATE
                    if(w.PTF_ModelloDiServizio__c=='Private'/* && w.PTF_Banca__r.FinServ__BankNumber__c == '05387'*/){
                        //CR 53259 SV Start
                        /*if((ass.PTF_Gestore__r.PTF_Ruolo__c=='069' || ass.PTF_Gestore__r.PTF_Ruolo__c=='100') && eligibleRoles.contains(key) && ass.PTF_Gestore__r.Account.PTF_IdCed__c == w.PTF_Filiale__r.PTF_IdCedUffPrivate__c){
                            continue;
                        }*/
                        System.debug('@@@@'+w.Id);
                        if(String.isNotBlank(w.PTF_Filiale__r.PTF_IdCedUffPrivate__c) && w.PTF_Filiale__r.PTF_IdCedUffPrivate__c.contains(ass.PTF_Gestore__r.PTF_Idced__c)){
                            system.debug('Batch CR 184');
                           continue; 
                        }
                        if(String.isNotBlank(w.PTF_UffPrivate__c) && ass.PTF_Gestore__r.PTF_Idced__c==w.PTF_UffPrivate__r.PTF_IdCEDPadre__c){
                            system.debug('Batch CR 188');
                            continue; 
                        }
                        //CR 53259 SV End

                    }
                    //NEW UFF PRIVATE

                    if(!mEscludiDaSgancio.containsKey(ass.PTF_Gestore__r.PTF_RegistrationNumber__c)){
                        System.debug('Batch CR 181');
                        Assignment__c ref= new Assignment__c();
                        ref.PTF_EndDate__c=Date.today();
                        ref.PTF_EndDate_DT__c = Datetime.now();
                        ref.Id=ass.Id;
                        assToEnd.add(ref);
                        if(ass.RecordType.DeveloperName=='Primario'){
                          System.debug('Batch CR 188');
                            Wallet__c wal = new Wallet__c();
                            wal.Id=w.Id;
                            wal.PTF_StatoAssegnazione__c='Non assegnato';
                            walToUpSet.add(wal);
                            if(w.PTF_ModelloDiServizio__c=='Private'/* && w.PTF_Banca__r.FinServ__BankNumber__c == '05387'*/){
                                walToAssign.add(w);
                            }
                        }
                        
                    }
                }
            }
            system.debug('walToAssign' +walToAssign);
            system.debug('walToChangeUffPrivate' +walToChangeUffPrivate);
            
            recordElab+=scope.size();
            if(assToEnd.size()>0){
                runAssignmentTrigger=true;
                update assToEnd;
            }
            assignmentUpdated+=assToEnd.size();
            walToUp=new List<Wallet__c>(walToUpSet);
            if(walToUp.size()>0){
                update walToUp;
            }
            walletUpdated+=walToUp.size();
            //CR 53259 SV Start
            Map<String,String> reAssignMap = getNewGestore(walToAssign);
            for(String wId: reAssignMap.keySet()){
                assToStart.add(new Assignment__c(
                        PTF_MicroWallet__c = wId,
                        PTF_StartDate__c=Date.today(),
                        PTF_StartDate_DT__c = Datetime.now(),
                        PTF_Gestore__c = reAssignMap.get(wId),
                        RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByDeveloperName().get('Primario').getRecordTypeId()
                    ));
            }
            
                
            for(Wallet__c w:scope){
                if(w.PTF_ModelloDiServizio__c=='Private'/* && w.PTF_Banca__r.FinServ__BankNumber__c == '05387'*/){
                    if(walToChangeUffPrivate.containsKey(w.Id)){
                        Wallet__c wal= new Wallet__c();
                        wal.Id=w.Id;
                        wal.PTF_UffPrivate__c=w.CRM_ReferentePortafoglio__r.AccountId;
                        walToChangeUffPrivateList.add(wal);
                    }
                }
            }
            system.debug('assToEnd' +assToEnd);
            system.debug('walToUp' +walToUp);
            system.debug('assToStart' +assToStart);
            system.debug('walToChangeUffPrivateList' +walToChangeUffPrivateList);
            insert assToStart;
            update walToChangeUffPrivateList;
            //CR 53259 SV End
        }
        catch(Exception exc){
            // intercept the error
            // set a boolean variable to true so the process is "blocked"
            System.debug(NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage() +exc.getStackTraceString());
            testoMail = NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
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
        testoMail += 'Numero totale di Assignment updatati: '+assignmentUpdated+'<br/>';
        testoMail += 'Numero totale di Portafogli updatati: '+walletUpdated+'<br/>';

        if (debug.Verbose__c) {
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

    public Map<String,String> getNewGestore(List<Wallet__c> walletList) {
		system.debug('getNewGestore walletList:'+ walletList);
        Map<String,String> returnMap= new Map<String,String>();
        Map<String,SObject> supervisorMap= new Map<String,SObject>();
        Map<String,SObject> executiveMap= new Map<String,SObject>();
        List<String> idCedUffPrivate= new List<String>();
        List<String> idCedUffExecutive= new List<String>();

        for(Wallet__c w:walletList){
            if(String.isNotBlank(w.PTF_UffPrivate__r.PTF_Idced__c)){
                System.debug('Batch CR 373');
                idCedUffPrivate.add(w.PTF_UffPrivate__r.PTF_Idced__c);
            }
            if(String.isNotBlank(w.PTF_UffPrivate__r.PTF_IdCedPadre__c)){
                System.debug('Batch CR 378');
                idCedUffExecutive.add(w.PTF_UffPrivate__r.PTF_IdCedPadre__c);
            }
            
        }
        
        supervisorMap = SV_Utilities.keyBy([SELECT Id, PTF_Idced__c
                                    FROM Contact
                                    WHERE PTF_Idced__c IN:idCedUffPrivate AND PTF_TipologiaRuolo__r.PTF_Code__c='F_140' AND PTF_ProfiloLDAP__c != null AND PTF_Closed_Date_Referente__c = null AND PTF_Closed_Date_Referente__c = null and PTF_User__r.PTF_RegistrationNumber__c NOT IN: daElaborare], 'PTF_Idced__c', false);
        executiveMap = SV_Utilities.keyBy([SELECT Id, PTF_Idced__c
                                    FROM Contact
                                    WHERE PTF_Idced__c IN:idCedUffExecutive AND PTF_TipologiaRuolo__r.PTF_Code__c='F_144'AND PTF_ProfiloLDAP__c != null AND PTF_Closed_Date_Referente__c = null], 'PTF_Idced__c', false);
        
        system.debug('supervisorMap:'+supervisorMap);
        system.debug('executiveMap:'+executiveMap);
        
         //VP - Aggiunte le condizioni per prendere solo referenti attivi AND PTF_ProfiloLDAP__c != null AND PTF_Closed_Date_Referente__c = null                           
        for(Wallet__c w:walletList){
            if(supervisorMap.containsKey(w.PTF_UffPrivate__r.PTF_Idced__c)){
                system.debug('Batch CR 375');
                returnMap.put(w.Id,(String) supervisorMap.get(w.PTF_UffPrivate__r.PTF_Idced__c).get('Id'));
            }
            else if(executiveMap.containsKey(w.PTF_UffPrivate__r.PTF_IdCedPadre__c)){
                system.debug('Batch CR 380');
                returnMap.put(w.Id,(String) executiveMap.get(w.PTF_UffPrivate__r.PTF_IdCedPadre__c).get('Id'));
            }
        }
        system.debug('returnMap:'+ returnMap);
        return returnMap;
        
    }
    
   
}