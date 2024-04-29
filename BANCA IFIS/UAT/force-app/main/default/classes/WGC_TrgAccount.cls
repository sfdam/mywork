public class WGC_TrgAccount {

    public static void manageBillingAndShippingAddress(List<Account> accounts) {
        // variables initialization
        System.debug('SV manageBillingAndShippingAddress: ' + accounts);
        for (Account a : accounts) {

        }
        
    }

    public static void setupOriginator(List<Account> accounts) {
        // variables initialization
        System.debug('SV setupOriginator: ' + accounts);

        User usr = [ SELECT Id, WGC_Canale_di_sviluppo__c FROM User WHERE Id =: UserInfo.getUserId() ];
        List<WGC_Originator__mdt> mdt_originator = [ SELECT Originator__c, Originator_dettaglio__c FROM WGC_Originator__mdt WHERE Canale_di_sviluppo__c =: usr.WGC_Canale_di_sviluppo__c ];
        System.debug('SV usr: ' + usr);
        System.debug('SV mdt_originator: ' + mdt_originator);

        for (Account a : accounts) {

            // TEN - SV ORIGINATOR E ORIGINATOR DETTAGLIO
            // TEN - SV MAPPO L'ORIGINATOR E IL DETTAGLIO SOLO SE VUOTI 
            if((a.WGC_Originator_dettaglio__c == null || a.WGC_Originator_dettaglio__c == '') && (a.WGC_Originator__c == null || a.WGC_Originator__c == '')){
                if(usr.WGC_Canale_di_sviluppo__c != null && usr.WGC_Canale_di_sviluppo__c != '' && mdt_originator.size() > 0) {
                    System.debug('SV ORIGINATOR FROM USER');
                    a.WGC_Originator_dettaglio__c = mdt_originator[0].Originator_dettaglio__c;
                    a.WGC_Originator__c = mdt_originator[0].Originator__c;
                } else {
                    System.debug('SV ORIGINATOR STANDARD');
                    a.WGC_Originator_dettaglio__c = 'Rete Commerciale Italia';
                    a.WGC_Originator__c = 'Diretto';
                }
            }

        }
        
    }

    // public static final String FILO_DIRETTO = 'Filo Diretto';
    // public static final String SVILUPPO_COMMERCIALE_FILIALI = 'Sviluppo_Commerciale_Filiali';
    // public static final String CREDITI_ERARIALI = 'Crediti Erariali';
    public static void manageAccountUsers(List<Account> accounts) {
        // variables initialization
        // A.M. -> START
        String CAP;
        Set<String> accountComuni = U.getSet(accounts, 'BillingCity');
        Set<String> accountProvincia = U.getSet(accounts, 'BillingState');
        // A.M. -> END      
        Set<String> accountCaps = U.getSet(accounts, 'BillingPostalCode');
        Id utenzaDefault = UtenzeDefault__c.getInstance().IdUtente__c;
        Map<String, Set<Id>> specialistiFiloDiretto = new Map<String, Set<Id>>();
        //Aggiunta per form web
        Map<String, Set<Id>> specialistiFiloDirettoWeb = new Map<String, Set<Id>>();
        Map<String, Set<Id>> specialistiSviluppoCommerciale = new Map<String, Set<Id>>();
        Map<String, String> accsErrors = new Map<String, String>();
        Map<String, Set<Id>> managersFiloDiretto = new Map<String, Set<Id>>();
        //Aggiunta per form web
        Map<String, Set<Id>> managersFiloDirettoWeb = new Map<String, Set<Id>>();
        Map<String, Set<Id>> managersSviluppoCommerciale = new Map<String, Set<Id>>();

        // PALUMBO 10/02/2020
        Map<String, Set<Id>> specialistiCreditiErariali = new Map<String, Set<Id>>();
        Map<String, Set<Id>> managersCreditiErariali = new Map<String, Set<Id>>();

        // SV Metadato Canale di sviluppo
        Map<String, SObject> canaleDiSviluppoMap = U.keyBy([
            SELECT Id, DeveloperName, MasterLabel, NamespacePrefix, Label, 
                   QualifiedApiName, Originator__c, Originator_dettaglio__c, 
                   Forzatura__c, Canale_di_sviluppo__c, Qualifica_Utente__c 
            FROM WGC_Originator__mdt ], 'Qualifica_Utente__c');
        System.debug('SV canaleDiSviluppoMap: ' + canaleDiSviluppoMap);

        // querys
        User u = [SELECT Id, Qualifica_Utente__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        List<AssegnazioneAnagrafica__c> assegnazioni = [
            SELECT  Id,
                    IdUtente__c,
                    Filiale__c,
                    FiloDiretto__c,
                    RefPrincipale__c,
                    SviluppoDiretto__c,
                    ProvinciaComune__c,
                    CAP__c,
                    SviluppoIndiretto__c,
                    Web__c,
                    Comune__r.Cap__c,
                    Comune__r.Cin__c,
                    Comune__r.CodiceCatastale__c,
                    Comune__r.Name,
                    Utente__c,
                    Utente__r.Qualifica_Utente__c,
                    Utente__r.Profile.Name,
                    Utente__r.ManagerId,
                    WGC_Filo_Diretto_Web__c
            FROM AssegnazioneAnagrafica__c
           // A.M. -> START
           //WHERE CAP__c IN :accountCaps 
           WHERE Comune__r.Name IN :accountComuni
             AND ProvinciaComune__c IN :accountProvincia
           // A.M. -> END
             AND (Utente__r.Qualifica_Utente__c = 'Filo Diretto' OR Utente__r.Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali' OR Utente__r.Qualifica_Utente__c = 'Crediti Erariali')];
        System.debug('@@@@ user: ' + u);
        System.debug('@@@@ assegnazioni: ' + assegnazioni);
        // support maps population
        for (AssegnazioneAnagrafica__c aa : assegnazioni) {
            if (aa.Utente__r.Qualifica_Utente__c == 'Filo Diretto') {
                if (specialistiFiloDiretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
                    specialistiFiloDiretto.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id>());
                specialistiFiloDiretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.IdUtente__c);

                if (aa.Utente__r.ManagerId != null) {
                    if (managersFiloDiretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
                        managersFiloDiretto.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id>());
                    managersFiloDiretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.Utente__r.ManagerId);
                }
            }
                // if (specialistiFiloDiretto.get(aa.CAP__c) == null)
                //     specialistiFiloDiretto.put(aa.CAP__c, aa.IdUtente__c);
                // else
                //     if (specialistiFiloDiretto.get(aa.CAP__c) != aa.IdUtente__c)
                //         accsErrors.put(aa.CAP__c, 'Multiple users \'IFIS - Filo Diretto\' for CAP: ' + aa.CAP__c);

            if (aa.Utente__r.Qualifica_Utente__c == 'Sviluppo_Commerciale_Filiali') {
                if (specialistiSviluppoCommerciale.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
                    specialistiSviluppoCommerciale.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id>());
                specialistiSviluppoCommerciale.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.IdUtente__c);
                
                if (aa.Utente__r.ManagerId != null) {
                    if (managersSviluppoCommerciale.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
                        managersSviluppoCommerciale.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id>());
                    managersSviluppoCommerciale.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.Utente__r.ManagerId);
                }
            }
                // if (specialistiSviluppoCommerciale.get(aa.CAP__c) == null)
                //     specialistiSviluppoCommerciale.put(aa.CAP__c, aa.IdUtente__c);
                // else
                //     if (specialistiFiloDiretto.get(aa.CAP__c) != aa.IdUtente__c)
                //         accsErrors.put(aa.CAP__c, 'Multiple users \'IFIS - Sviluppo Diretto\' for CAP: ' + aa.CAP__c);

            // MODIFICA PALUMBO 10/02/2020
            if (aa.Utente__r.Qualifica_Utente__c.equals('Crediti Erariali')){
                if (!specialistiCreditiErariali.containsKey(aa.Comune__r.Cap__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c)){
                    specialistiCreditiErariali.put(aa.Comune__r.Cap__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id>());
                    specialistiCreditiErariali.get(aa.Comune__r.Cap__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.IdUtente__c);
                }else {
                    specialistiCreditiErariali.get(aa.Comune__r.Cap__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.IdUtente__c);
                }

                if (aa.Utente__r.ManagerId != null) {
                    if (!managersCreditiErariali.containsKey(aa.Comune__r.Cap__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c)) {
                        managersCreditiErariali.put(aa.Comune__r.Cap__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id>());
                        managersCreditiErariali.get(aa.Comune__r.Cap__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.Utente__r.ManagerId);
                    }else {
                        managersCreditiErariali.get(aa.Comune__r.Cap__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.Utente__r.ManagerId);
                    }
                }
            }
        }

        System.debug('specialistiCreditiErariali: '+specialistiCreditiErariali);
        System.debug('managersCreditiErariali: '+managersCreditiErariali);
// System.debug('@@@@ managersFiloDiretto: ' + managersFiloDiretto);
// System.debug('@@@@ managersSviluppoCommerciale: ' + managersSviluppoCommerciale);
// System.debug('@@@@ specialistiFiloDiretto: ' + specialistiFiloDiretto);
// System.debug('@@@@ specialistiSviluppoCommerciale: ' + specialistiSviluppoCommerciale);
        // specialists' assignament & Canale di sviluppo
        // A.M. -> aggiunto profilo 'IFIS - Api-Only' per gestione lead
        if ((u.Profile.Name == 'System Administrator' || u.Profile.Name == 'Amministratore del sistema' || u.Profile.Name == 'IFIS - Direzione Commerciale' || u.Profile.Name == 'IFIS - Api-Only') && !Test.isRunningTest()) { // if user sysAdmin => owner: default, specFD: territory, specF: territory
            System.debug('@@@@ System Admin');
            for (Account a : accounts) {
                if (accountHasError(a, accsErrors) == false) {
                    // System.debug('@@@@ System Admin --no ERROR');
                    a.OwnerId = utenzaDefault;
                    // A.M. ->START
                    CAP = a.BillingPostalCode;
                    if (!String.isEmpty(CAP) && CAP.length()==5){
                        List<Comune__c> AComuni = [SELECT  Id, Name, Cap__c FROM Comune__c WHERE Cap__c = :CAP AND FlagStorico__C = false];
                        if (AComuni.isEmpty()){    
                            string CAP3 = CAP.substring(0, 3);
                            CAP = CAP3.rightPad(5, '0');
                        }
                    }
                    // A.M. ->END
// System.debug('@@@@ getSpecialista --CAP: ' + a.BillingPostalCode + '_' + a.BillingCity + ' --Specialista: ' + getSpecialista(a.BillingPostalCode + '_' + a.BillingCity, specialistiFiloDiretto, managersFiloDiretto));
                    if (a.WGC_Specialista_Filo_Diretto__c == null){
                        // A.M. -> START
                        //a.WGC_Specialista_Filo_Diretto__c = getSpecialista(a.BillingPostalCode + '_' + a.BillingCity + '_' + a.BillingState, specialistiFiloDiretto, managersFiloDiretto);//specialistiFiloDiretto.get(a.BillingPostalCode);
                        a.WGC_Specialista_Filo_Diretto__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiFiloDiretto, managersFiloDiretto, a.WGC_Specialista_Filo_Diretto__c);//specialistiFiloDiretto.get(a.BillingPostalCode);
                        // A.M. -> END
                    }

// System.debug('@@@@ getSpecialista --CAP: ' + a.BillingPostalCode + '_' + a.BillingCity + ' --Specialista: ' + getSpecialista(a.BillingPostalCode + '_' + a.BillingCity, specialistiSviluppoCommerciale, managersSviluppoCommerciale));
                    if (a.WGC_Specialista_Factoring__c == null)
                        // A.M. -> START
                        //a.WGC_Specialista_Factoring__c = getSpecialista(a.BillingPostalCode + '_' + a.BillingCity + '_' + a.BillingState, specialistiSviluppoCommerciale, managersSviluppoCommerciale);
                        a.WGC_Specialista_Factoring__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiSviluppoCommerciale, managersSviluppoCommerciale, a.WGC_Specialista_Factoring__c);
						// A.M. -> END

                    // SV Add canale di sviluppo
                    if(a.RecordType.DeveloperName != 'WGC_Tribunale'){
                        a.WGC_Canale_di_sviluppo__c = ((WGC_Originator__mdt) canaleDiSviluppoMap.get('Sviluppo_Commerciale_Filiali')).Canale_di_sviluppo__c;

                        //PALUMBO 10/02/2020
                        a.WGC_Specialista_Crediti_Erariali__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiCreditiErariali, managersCreditiErariali,a.WGC_Specialista_Crediti_Erariali__c);
                    }
                }

                a.Presentatore__c = a.WGC_Specialista_Factoring__c;

            }
        }
        else {
            switch on u.Qualifica_Utente__c {
                when 'Filo Diretto' { // if user FD => owner: currentUser, specFD: currentUser, specF: territory
                    System.debug('@@@@ Filo Diretto');
                    for (Account a : accounts) {
                        if (accountHasError(a, accsErrors) == false) {
                            System.debug('@@@@ Filo Diretto --no ERROR');
                            a.OwnerId = UserInfo.getUserId();
                            a.WGC_Specialista_Filo_Diretto__c = UserInfo.getUserId();                        
                            // A.M. ->START
                            CAP = a.BillingPostalCode;
                            if (!String.isEmpty(CAP) && CAP.length()==5){
                                List<Comune__c> AComuni = [SELECT  Id, Name, Cap__c FROM Comune__c WHERE Cap__c = :CAP AND FlagStorico__C = false];
                                if (AComuni.isEmpty()){ 
                                    string CAP3 = CAP.substring(0, 3);
                                    CAP = CAP3.rightPad(5, '0');
                                }
                            }
                            // a.WGC_Specialista_Factoring__c = getSpecialista(a.BillingPostalCode + '_' + a.BillingCity + '_' + a.BillingState, specialistiSviluppoCommerciale, managersSviluppoCommerciale);
                            a.WGC_Specialista_Factoring__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiSviluppoCommerciale, managersSviluppoCommerciale, a.WGC_Specialista_Factoring__c);
						    // A.M. -> END
                        }

                        // SV Add canale di sviluppo
                        if(a.RecordType.DeveloperName != 'WGC_Tribunale'){
                            a.WGC_Canale_di_sviluppo__c = ((WGC_Originator__mdt) canaleDiSviluppoMap.get(u.Qualifica_Utente__c)).Canale_di_sviluppo__c;

                            //PALUMBO 10/02/2020
                            a.WGC_Specialista_Crediti_Erariali__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiCreditiErariali, managersCreditiErariali, a.WGC_Specialista_Crediti_Erariali__c);
                        }

                        a.Presentatore__c = a.WGC_Specialista_Factoring__c;
                    }
                }
                when 'Sviluppo_Commerciale_Filiali' { // if user F => owner: currentUser, specFD: territory, specF: currentUser
                    System.debug('@@@@ Sviluppo Commerciale Filiali');
                    for (Account a : accounts) {
                        if (accountHasError(a, accsErrors) == false) {
                            System.debug('@@@@ Sviluppo Commerciale Filiali --no ERROR');
                            a.OwnerId = UserInfo.getUserId();
                            // A.M. ->START
                             CAP = a.BillingPostalCode;
                             if (!String.isEmpty(CAP) && CAP.length()==5){
                                 List<Comune__c> AComuni = [SELECT  Id, Name, Cap__c FROM Comune__c WHERE Cap__c = :CAP AND FlagStorico__C = false];
                                 if (AComuni.isEmpty()){    
                                     string CAP3 = CAP.substring(0, 3);
                                     CAP = CAP3.rightPad(5, '0');
                                }
                             }
                            //a.WGC_Specialista_Filo_Diretto__c = getSpecialista(a.BillingPostalCode + '_' + a.BillingCity + '_' + a.BillingState, specialistiFiloDiretto, managersFiloDiretto);//specialistiFiloDiretto.get(a.BillingPostalCode + '_' + a.BillingCity);
                            a.WGC_Specialista_Filo_Diretto__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiFiloDiretto, managersFiloDiretto, a.WGC_Specialista_Filo_Diretto__c);
                            // A.M. -> END
                            a.WGC_Specialista_Factoring__c = UserInfo.getUserId();
                        }

                        // SV Add canale di sviluppo
                        if(a.RecordType.DeveloperName != 'WGC_Tribunale'){
                            a.WGC_Canale_di_sviluppo__c = ((WGC_Originator__mdt) canaleDiSviluppoMap.get(u.Qualifica_Utente__c)).Canale_di_sviluppo__c;

                            //PALUMBO 10/02/2020
                            a.WGC_Specialista_Crediti_Erariali__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiCreditiErariali, managersCreditiErariali, a.WGC_Specialista_Crediti_Erariali__c);
                        }

                        a.Presentatore__c = a.WGC_Specialista_Factoring__c;
                    }
                }
                when 'Crediti Erariali' { // if user CE => owner: currentUser, specFD: territory, specF: territory, specCE: currentUser
                    System.debug('@@@@ Crediti Erariali');
                    for (Account a : accounts) {
                        if (accountHasError(a, accsErrors) == false) {
                            System.debug('@@@@ Crediti Erariali --no ERROR');
                            a.OwnerId = UserInfo.getUserId();
                            // A.M. ->START
                             CAP = a.BillingPostalCode;
                             if (!String.isEmpty(CAP) && CAP.length()==5){
                                 List<Comune__c> AComuni = [SELECT  Id, Name, Cap__c FROM Comune__c WHERE Cap__c = :CAP AND FlagStorico__C = false];
                                 if (AComuni.isEmpty()){   
                                    string CAP3 = CAP.substring(0, 3);
                                    CAP = CAP3.rightPad(5, '0');
                                 }
                             }
                            //a.WGC_Specialista_Filo_Diretto__c = getSpecialista(a.BillingPostalCode + '_' + a.BillingCity + '_' + a.BillingState, specialistiFiloDiretto, managersFiloDiretto);//specialistiFiloDiretto.get(a.BillingPostalCode + '_' + a.BillingCity);
                            //a.WGC_Specialista_Factoring__c = getSpecialista(a.BillingPostalCode + '_' + a.BillingCity + '_' + a.BillingState, specialistiSviluppoCommerciale, managersSviluppoCommerciale);//specialistiSviluppoCommerciale.get(a.BillingPostalCode);
                            a.WGC_Specialista_Filo_Diretto__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiFiloDiretto, managersFiloDiretto, a.WGC_Specialista_Filo_Diretto__c);
                            a.WGC_Specialista_Factoring__c = getSpecialista(CAP+ '_' + a.BillingCity + '_' + a.BillingState, specialistiSviluppoCommerciale, managersSviluppoCommerciale, a.WGC_Specialista_Factoring__c);
                            // A.M. -> END 
                            a.WGC_Specialista_Crediti_Erariali__c = UserInfo.getUserId();
                        }

                        // SV Add canale di sviluppo
                        if(a.RecordType.DeveloperName != 'WGC_Tribunale'){
                            a.WGC_Canale_di_sviluppo__c = ((WGC_Originator__mdt) canaleDiSviluppoMap.get(u.Qualifica_Utente__c)).Canale_di_sviluppo__c;                        
                        }

                        a.Presentatore__c = a.WGC_Specialista_Factoring__c;
                    }
                }
                // A.M. -> START
                when 'Leasing EF' { // if user EF => owner: currentUser, specFD: territory, specF: territory, specEF: currentUser
                    System.debug('@@@@ Leasing EF');
                    for (Account a : accounts) {
                        if (accountHasError(a, accsErrors) == false) {
                            System.debug('@@@@ Leasing EF --no ERROR');
                            CAP = a.BillingPostalCode;
                            if (!String.isEmpty(CAP) && CAP.length()==5){
                                List<Comune__c> AComuni = [SELECT  Id, Name, Cap__c FROM Comune__c WHERE Cap__c = :CAP AND FlagStorico__C = false];
                                if (AComuni.isEmpty()){ 
                                   string CAP3 = CAP.substring(0, 3);
                                   CAP = CAP3.rightPad(5, '0');
                                }
                            }
                        
                            a.OwnerId = UserInfo.getUserId();
                            a.WGC_Specialista_Filo_Diretto__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiFiloDiretto, managersFiloDiretto, a.WGC_Specialista_Filo_Diretto__c);
                            a.WGC_Specialista_Factoring__c = getSpecialista(CAP+ '_' + a.BillingCity + '_' + a.BillingState, specialistiSviluppoCommerciale, managersSviluppoCommerciale, a.WGC_Specialista_Factoring__c);
                            //a.WGC_Specialista_Leasing__c = UserInfo.getUserId();
                        }

                        // SV Add canale di sviluppo
                        if(a.RecordType.DeveloperName != 'WGC_Tribunale'){
                            a.WGC_Canale_di_sviluppo__c = ((WGC_Originator__mdt) canaleDiSviluppoMap.get(u.Qualifica_Utente__c)).Canale_di_sviluppo__c;

                            //PALUMBO 10/02/2020
                            a.WGC_Specialista_Crediti_Erariali__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiCreditiErariali, managersCreditiErariali, a.WGC_Specialista_Crediti_Erariali__c);
                        }

                        a.Presentatore__c = a.WGC_Specialista_Factoring__c;
                    }
                }
                when 'Leasing TR' { // if user TR => owner: currentUser, specFD: territory, specF: territory, specTR: currentUser
                    System.debug('@@@@ Leasing TR');
                    for (Account a : accounts) {
                        if (accountHasError(a, accsErrors) == false) {
                            System.debug('@@@@ Leasing TR --no ERROR');
                            CAP = a.BillingPostalCode;
                            if (!String.isEmpty(CAP) && CAP.length()==5){
                                List<Comune__c> AComuni = [SELECT  Id, Name, Cap__c FROM Comune__c WHERE Cap__c = :CAP AND FlagStorico__C = false];
                                if (AComuni.isEmpty()){ 
                                   string CAP3 = CAP.substring(0, 3);
                                   CAP = CAP3.rightPad(5, '0');
                                }
                            }
                        
                            a.OwnerId = UserInfo.getUserId();
                            a.WGC_Specialista_Filo_Diretto__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiFiloDiretto, managersFiloDiretto, a.WGC_Specialista_Filo_Diretto__c);
                            a.WGC_Specialista_Factoring__c = getSpecialista(CAP+ '_' + a.BillingCity + '_' + a.BillingState, specialistiSviluppoCommerciale, managersSviluppoCommerciale, a.WGC_Specialista_Factoring__c);
                            //a.WGC_Specialista_Leasing_TR__c = UserInfo.getUserId();
                        }

                        // SV Add canale di sviluppo
                        if(a.RecordType.DeveloperName != 'WGC_Tribunale'){
                            a.WGC_Canale_di_sviluppo__c = ((WGC_Originator__mdt) canaleDiSviluppoMap.get(u.Qualifica_Utente__c)).Canale_di_sviluppo__c;

                            //PALUMBO 10/02/2020
                            a.WGC_Specialista_Crediti_Erariali__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiCreditiErariali, managersCreditiErariali, a.WGC_Specialista_Crediti_Erariali__c);
                        }

                        a.Presentatore__c = a.WGC_Specialista_Factoring__c;
                    }
                }
                when 'IFIS_International' { // if user IFI => owner: currentUser, specFD: territory, specF: territory, specIFI: currentUser
                    System.debug('@@@@ IFIS_International');
                    for (Account a : accounts) {
                        if (accountHasError(a, accsErrors) == false) {
                            System.debug('@@@@ FIFIS_International --no ERROR');
                            CAP = a.BillingPostalCode;
                            if (!String.isEmpty(CAP) && CAP.length()==5){
                                List<Comune__c> AComuni = [SELECT  Id, Name, Cap__c FROM Comune__c WHERE Cap__c = :CAP AND FlagStorico__C = false];
                                if (AComuni.isEmpty()){     
                                   string CAP3 = CAP.substring(0, 3);
                                   CAP = CAP3.rightPad(5, '0');
                                }
                            }
                        
                            a.OwnerId = UserInfo.getUserId();
                            a.WGC_Specialista_Filo_Diretto__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiFiloDiretto, managersFiloDiretto, a.WGC_Specialista_Filo_Diretto__c);
                            a.WGC_Specialista_Factoring__c = getSpecialista(CAP+ '_' + a.BillingCity + '_' + a.BillingState, specialistiSviluppoCommerciale, managersSviluppoCommerciale,  a.WGC_Specialista_Factoring__c);
                            a.WGC_Specialista_IFIS_International__c = UserInfo.getUserId();
                        }

                        // SV Add canale di sviluppo
                        if(a.RecordType.DeveloperName != 'WGC_Tribunale'){
                            a.WGC_Canale_di_sviluppo__c = ((WGC_Originator__mdt) canaleDiSviluppoMap.get(u.Qualifica_Utente__c)).Canale_di_sviluppo__c;

                            //PALUMBO 10/02/2020
                            a.WGC_Specialista_Crediti_Erariali__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiCreditiErariali, managersCreditiErariali, a.WGC_Specialista_Crediti_Erariali__c);
                        }

                        a.Presentatore__c = a.WGC_Specialista_Factoring__c;
                    }
                }
                when 'Finanza Strutturata' { // if user FS => owner: currentUser, specFD: territory, specF: territory, specFS: currentUser
                    System.debug('@@@@ Finanza Strutturata');
                    for (Account a : accounts) {
                        if (accountHasError(a, accsErrors) == false) {
                            System.debug('@@@@ Finanza Strutturata --no ERROR');
                            CAP = a.BillingPostalCode;
                            if (!String.isEmpty(CAP) && CAP.length()==5){
                                List<Comune__c> AComuni = [SELECT  Id, Name, Cap__c FROM Comune__c WHERE Cap__c = :CAP AND FlagStorico__C = false];
                                if (AComuni.isEmpty()){     
                                   string CAP3 = CAP.substring(0, 3);
                                   CAP = CAP3.rightPad(5, '0');
                                }
                            }
                        
                            a.OwnerId = UserInfo.getUserId();
                            a.WGC_Specialista_Filo_Diretto__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiFiloDiretto, managersFiloDiretto, a.WGC_Specialista_Filo_Diretto__c);
                            a.WGC_Specialista_Factoring__c = getSpecialista(CAP+ '_' + a.BillingCity + '_' + a.BillingState, specialistiSviluppoCommerciale, managersSviluppoCommerciale, a.WGC_Specialista_Factoring__c);
                            a.WGC_Specialista_Finanza_Strutturata__c = UserInfo.getUserId();
                        }

                        // SV Add canale di sviluppo
                        if(a.RecordType.DeveloperName != 'WGC_Tribunale'){
                            a.WGC_Canale_di_sviluppo__c = ((WGC_Originator__mdt) canaleDiSviluppoMap.get(u.Qualifica_Utente__c)).Canale_di_sviluppo__c;
                            //PALUMBO 10/02/2020
                            a.WGC_Specialista_Crediti_Erariali__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiCreditiErariali, managersCreditiErariali, a.WGC_Specialista_Crediti_Erariali__c);
                        }

                        a.Presentatore__c = a.WGC_Specialista_Factoring__c;
                    }
                }
                // A.M. -> END
                when else {       // default block, optional
                    // SV Add canale di sviluppo
                    for (Account a : accounts) {
                        if (accountHasError(a, accsErrors) == false) {
                            if(a.RecordType.DeveloperName != 'WGC_Tribunale'){
                                a.WGC_Canale_di_sviluppo__c = ((WGC_Originator__mdt) canaleDiSviluppoMap.get(u.Qualifica_Utente__c)) != null ? ((WGC_Originator__mdt) canaleDiSviluppoMap.get(u.Qualifica_Utente__c)).Canale_di_sviluppo__c : '';

                                //PALUMBO 10/02/2020
                                a.WGC_Specialista_Crediti_Erariali__c = getSpecialista(CAP + '_' + a.BillingCity + '_' + a.BillingState, specialistiCreditiErariali, managersCreditiErariali, a.WGC_Specialista_Crediti_Erariali__c);
                            }
                        }
                    }
                }
            }
        }
    }

    private static Boolean accountHasError(Account acc, Map<String, String> errors) {

        if (errors.get(acc.BillingPostalCode) != null) {
            acc.addError(errors.get(acc.BillingPostalCode));
            return true;
        }

        return false;
    }

    public static Id getSpecialista(String CAPKey, Map<String, Set<Id>> specialisti, Map<String, Set<Id>> managers, Id specialista) {
        if (specialisti.get(CAPKey) != null) {
            if (specialisti.get(CAPKey).size() > 1) { // if multiple specialisti found for CAPKey..
                if (managers.get(CAPKey) != null) {
                    if (managers.get(CAPKey).size() == 1) // ..check for specialisti's managers and if only one found..
                        return (new list<Id>(managers.get(CAPKey)))[0]; // ..assign him as referent.
                }
            } else if (specialisti.get(CAPKey).size() == 1) // ..if only one specialista found..
                return (new list<Id>(specialisti.get(CAPKey)))[0]; // ..assign him as referent.
        }

        return specialista; // ..otherwise nobody will be assigned as referent. //M.N inserisco Id specialista perchè se già popolato non deve sbiancare il campo
    }

    @InvocableMethod(label='SbloccaAnagrafica' description='Sblocca Anagrafica')
    public static List<String> unlockBlockedAccount(List<String> accountsId){
        //System.debug('@@@ accounts to unlock ' + JSON.serialize(accountsId));
        List<Approval.UnlockResult> results = new List<Approval.UnlockResult>();

        Map<Id,Boolean> isLockedMap = new Map<Id,Boolean>();

        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN: accountsId]);
        isLockedMap = Approval.isLocked(accounts.values());

        System.debug('@@@ isLockedMap ' + JSON.serialize(isLockedMap));
        System.debug('@@@ actual user ' + UserInfo.getUserId());

        List<Id> idsToUnlock = new List<Id>();

        for(Id accId : isLockedMap.keySet()){
            if(isLockedMap.get(accId))
                idsToUnlock.add(accId);
        }

        // List<ProcessInstance> processi = [ SELECT Id, TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId IN: idsToUnlock];

        // for(ProcessInstance proc : processi){
        //     proc.status = 'Approved';
        // }

        // Update processi;

        results = Approval.unlock(idsToUnlock);

        System.debug('@@@ results ' + Approval.isLocked(accounts.values()));

        return new List<String>();
    }

    //Metodo che aggiorna il campo settorista e filiale, al cambio del referente factoring sull'anagrafica modificata
    public static void updateSettoristaFilialeDT(Map<Id,Account> accounts){

        Set<Id> specialistiIds = new Set<Id>();
        List<WGC_Dettaglio_Visite__c> dtListToUpd = new List<WGC_Dettaglio_Visite__c>();
        Map<Id,WGC_Dettaglio_Visite__c> accIdsXDT = new Map<Id,WGC_Dettaglio_Visite__c>();

        for(Account a : accounts.values()){
            specialistiIds.add(a.WGC_Specialista_Factoring__c);
        }
        
        List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>([SELECT Id, Name, Settorista__c, Filiale__c, Ragione_Sociale__c, toLabel(Ragione_Sociale__r.Filiale__c), Data_di_Creazione__c FROM WGC_Dettaglio_Visite__c WHERE Ragione_Sociale__c IN : accounts.keySet() ORDER BY Data_di_Creazione__c DESC]);
        //List<User> uList = new List<User>([SELECT Id, Name, Filiale__c FROM User WHERE Id IN : specialistiIds]);

        if(!dtList.isEmpty()){
            for(Id accId : accounts.keySet()){
                for(WGC_Dettaglio_Visite__c dt : dtList){
                    if(dt.Ragione_Sociale__c == accId){
                        accIdsXDT.put(accId,dt);
                    } 
                }
            }
        }

        if(!dtList.isEmpty()){
            for(Id accId : accounts.keySet()){
                for(WGC_Dettaglio_Visite__c dt : accIdsXDT.values()){
                    if(dt.Ragione_Sociale__c == accId){
                        dt.Settorista__c = accounts.get(accId).WGC_Specialista_Factoring__c;
                        dt.Filiale__c = dt.Ragione_Sociale__r.Filiale__c != null ? dt.Ragione_Sociale__r.Filiale__c.toUpperCase() : '';

                        dtListToUpd.add(dt);
                    }
                }
            }
        }

        if(!dtListToUpd.isEmpty()){
            Update dtListToUpd;
        }
    }

}