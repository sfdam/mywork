public class WGC_AllDataFactory {

    public static List<User> createUser(Integer numberOfUser , Boolean toInsert){
        List<User> userToInsert = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Gestore Cliente']; 

        
        for(Integer i = 0; i < numberOfUser; i ++){
            Double randNumber = Math.Random();
            User u;
            if(i == 1){
                u = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', Username = 'user'+randNumber+'@test.com', Qualifica_Utente__c= 'Filo Diretto');
            }
            else{
                u = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', Username = 'user'+randNumber+'@test.com', Qualifica_Utente__c= 'Sviluppo_Commerciale_Filiali');
            }
               System.debug('@Utente: '+u); 
             userToInsert.add(u);
        }
        if(toInsert){
            insert userToInsert;
        }
        return userToInsert;
    }

    public static List<Account> createAccount(Integer numberOfAccount , Boolean toInsert){
        List<Account> accountToInsert = new List<Account>();
        //createUtenzaDefault();
        List<User> listUSer = createUser(3,true);
        
        for(Integer i = 0; i < numberOfAccount; i ++){
            Double randNumber = Math.Random();
            Account a = new Account();
            a.OwnerId = listUSer.get(0).id;
            a.Name = 'Account'+randNumber;
            a.Email__c ='email@test.it';
            a.WGC_Specialista_Leasing__c = listUSer.get(0).id;
            a.REA__c='34122';
            a.Ateco__c='';
            String cf = 'RSSMRA80A01H501U';
            a.CF__c= generateRandomString(16, false);
            String piva = 'PIVA'+randNumber;
            a.RAE__c = '3';
            a.NaturaGiuridica__c= 'AAA';
            a.PIVA__c= piva.subString(0,10);
            a.CCIAA__c= '2188';
            a.ProvinciaCCIAA__c='MI';
            a.EventiNegativiIdTicket__c = '111';
            a.EventiNegativiGlobale__c = 'R';
            a.EventiNegativiProtesti__c = 'V'; 
            a.EventiNegativiPregiudizievoli__c = 'V';
            a.EventiNegativiProcedureConcorsuali__c = 'V';
            a.EventiNegativiCIGS__c = 'G';
            a.WGC_Qualifica_Corporate__c = Math.mod(i, 2) == 0 ? 'Cliente Attivo' : '';
            a.EventiNegativiAllarmiQuote__c = 'V';
            a.WGC_UltimaRichiestaEventiNegativi__c = Date.newInstance(2019,01,01);
            a.codiceIstituto3N__c =  Math.mod(i, 2) == 0 ? '881' : '889';
            a.NDGGruppo__c = Math.mod(i, 2) == 0 ? '107499' : '107400';
            a.NDGGruppoGiuridico__c = Math.mod(i, 2) == 0 ? '4116991' : '4001182';
            a.WGC_NDG_controllante__c = Math.mod(i, 2) == 0 ? '4116986' : '133637';
            a.WGC_Specialista_Filo_Diretto__c = listUSer.get(0).id;
            a.WGC_Specialista_Factoring__c = listUSer.get(2).id;
            //a.WGC_Gruppo__c= Math.mod(i, 2) == 0 ? true : false;
            a.IndirizzoPerInvioCorrispondenza__c = Math.mod(i, 2) == 0 ? 'Sede legale' : 'Sede amministrativa';
            a.WGC_Semaforo_Gianos__c = 'ROSSO';
            a.Fatturato__c = Math.mod(i, 2) == 0 ? 10001 : 9999;
            a.WGC_Data_ultima_attivita_SvilCommFiliali__c = System.Today();
            a.WGC_DataRichiestaCR__c=DateTime.now();
            a.DataInserimentoConsensi__c = System.Today();
            a.BillingState = 'TS';
            a.Ateco__c = '';
            
            accountToInsert.add(a);
        }
        if(toInsert){
            insert accountToInsert;
        }
        return accountToInsert;
    }

     public static List<Account> createAccount(Integer numberOfAccount){
        List<Account> accountToInsert = new List<Account>();
        //createUtenzaDefault();
        // List<User> listUSer = createUser(3,true);
        
        for(Integer i = 0; i < numberOfAccount; i ++){
            Double randNumber = Math.Random();
            Account a = new Account();
            // a.OwnerId = listUSer.get(0).id;
            a.Name = 'Account'+randNumber;
            a.Email__c ='email@test.it';
            // a.WGC_Specialista_Leasing__c = listUSer.get(0).id;
            a.REA__c='34122';
            a.Ateco__c='';
            String cf = 'RSSMRA80A01H501U';
            a.CF__c= generateRandomString(16, false);
            String piva = 'PIVA'+randNumber;
            a.RAE__c = '3';
            a.NaturaGiuridica__c= null;
            a.PIVA__c= piva.subString(0,10);
            a.CCIAA__c= '2188';
            a.ProvinciaCCIAA__c='MI';
            a.EventiNegativiIdTicket__c = '222';
            a.EventiNegativiGlobale__c = 'R';
            a.EventiNegativiProtesti__c = 'V'; 
            a.EventiNegativiPregiudizievoli__c = 'V';
            a.EventiNegativiProcedureConcorsuali__c = 'V';
            a.EventiNegativiCIGS__c = 'G';
            a.WGC_Qualifica_Corporate__c = Math.mod(i, 2) == 0 ? 'Cliente Attivo' : '';
            a.EventiNegativiAllarmiQuote__c = 'V';
            a.WGC_UltimaRichiestaEventiNegativi__c = Date.newInstance(2019,01,01);
            a.codiceIstituto3N__c =  Math.mod(i, 2) == 0 ? '881' : '889';
            a.NDGGruppo__c = Math.mod(i, 2) == 0 ? '107499' : '107400';
            a.NDGGruppoGiuridico__c = Math.mod(i, 2) == 0 ? '4116991' : '4001182';
            a.WGC_NDG_controllante__c = Math.mod(i, 2) == 0 ? '4116986' : '133637';
            // a.WGC_Specialista_Filo_Diretto__c = listUSer.get(0).id;
            // a.WGC_Specialista_Factoring__c = listUSer.get(2).id;
            //a.WGC_Gruppo__c= Math.mod(i, 2) == 0 ? true : false;
            a.IndirizzoPerInvioCorrispondenza__c = Math.mod(i, 2) == 0 ? 'Sede legale' : 'Sede amministrativa';
            a.WGC_Semaforo_Gianos__c = 'ROSSO';
            a.Fatturato__c = Math.mod(i, 2) == 0 ? 10001 : 9999;
            a.WGC_Data_ultima_attivita_SvilCommFiliali__c = System.Today();
            a.WGC_DataRichiestaCR__c=DateTime.now();
            a.DataInserimentoConsensi__c = System.Today();
            a.BillingState = 'TS';
            a.Filiale__c = 'Milano';
            
            accountToInsert.add(a);
        }
        
        return accountToInsert;
    }
    
    public static void createUtenzaDefault(){
        UtenzeDefault__c utenza= new UtenzeDefault__c();
        utenza.IdUtente__c = UserInfo.getUserId();
        insert utenza;
    }
    public static void createLagKey(){
        String sandboxUrl = System.Url.getSalesforceBaseURL().getHost();
        String[] sandboxUrlSections = sandboxUrl.split('\\.');
        String sandboxName = sandboxUrlSections[0].substringAfter('--');
        EndpointServizi__c lagKey = new EndpointServizi__c( Name='settings',
                                                            WGC_Url_Dati_PEF__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/datipef',
                                                            WGC_Url_PEF41__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/rinnovopef',
                                                            WGC_Url_PEF40__c ='https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/canale',
                                                            URLGetEventiNegativiRibes__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/eventinegativicompositeservice/eventinegativi',
                                                            LAGKeyHeroku__c = 'B3DAF392-AF8C-4687-8387-48261E9A63FD',
                                                            LAGKey__c = 'B3DAF392-AF8C-4687-8387-48261E9A63FD',
                                                            URL_Aggiorna_Campi_Prodotti_Posizione__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/posizione',
                                                            URLAllineaKnet__c = 'https://uatservicbancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositrvice/setdatianagraficiifis',
                                                            URLModificaDatiAggiuntiviQQ__c = 'https://uatservicbancaifis.it/arch/lag/proxy/anagrafica/modificadatiaggiuntiviqqcompositrvice/modificadatiaggiuntiviqq',
                                                            // URLDatiBilancio__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositeservice/datibilancio',
                                                            UrlAggiornamentoStatoCartella__c = 'https://uatservicbancaifis.it/arch/lag/proxy/pratica/nvaggiornamentostatocartellacompositrvice/nvaggiornamentostatocartella',
                                                            UrlCancellaOggetti__c = 'https://uatservicbancaifis.it/arch/lag/proxy/documentmanager/filenetaggiornamento/cancellaoggetti',
                                                            UrlCheckStatoPef__c = 'https://uatservicbancaifis.it/arch/lag/proxy/pratica/checkstatopefcompositrvice/checkstatopef',
                                                            UrlDatiBilancio__c = 'https://uatservicbancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositrvice/datibilancio',
                                                            UrlDettaglioOggetto__c = 'https://uatservicbancaifis.it/arch/lag/proxy/documentmanager/dettagliooggettocompositrvice/dettagliooggetto',
                                                            UrlEsistePef__c = 'https://uatservicbancaifis.it/arch/lag/proxy/pratica/checkstenzapefcompositrvice/checkstenzapef',
                                                            UrlFileNet__c = 'http://filenetp8.collaudo.ced.it',
                                                            UrlGetDatiAnagraficiCedacri__c = 'https://uatservicbancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositrvice/getdatianagraficicedacri',
                                                            UrlInfoCr__c = 'https://uatservicbancaifis.it/arch/lag/proxy/posizionerischio/primainformazionecrcompositrvice/primainformazionecr',
                                                            UrlInterrogazioneBilanci__c = 'https://uatservicbancaifis.it/arch/lag/proxy/pratica/bilanci/interrogazionebilanci',
                                                            UrlNvInquiryStatoCartella__c = 'https://uatservicbancaifis.it/arch/lag/proxy/pratica/nvinquirystatocartellacompositrvice/nvinquirystatocartella',
                                                            UrlRenderPdf__c = 'https://uatservicbancaifis.it/arch/lag/proxy/pratica/adobecompositrvice/renderpdf',
                                                            UrlRicercaAnagraficaCedacri__c = 'https://uatservicbancaifis.it/arch/lag/proxy/anagrafica/ricercaanagraficacedacricompositrvice/ricercaanagraficacedacri',
                                                            UrlSearchDocument__c = 'https://uatservicbancaifis.it/arch/lag/proxy/documentmanager/ricercadocumenti/searchdocument',
                                                            UrlSetAnagraficaCedacri__c = 'https://uatservicbancaifis.it/arch/lag/proxy/anagrafica/setanagraficacedacricompositrvice/setanagraficacedacri',
                                                            UrlSetAnagraficaLight__c = 'https://uatservicbancaifis.it/arch/lag/proxy/anagrafica/setanagraficalightcompositrvice/setanagraficalight',
                                                            UrlSetAnagraficaVariazione__c = 'https://uatservicbancaifis.it/arch/lag/proxy/anagrafica/anagrafevariazionecompositrvice/setanagraficavariazione',
                                                            UrlSetRetianagraficheIfis__c = 'https://uatservicbancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositrvice/setretianagraficheifis',
                                                            UrlCalcoloC138Debitore__c = 'https://uatservicbancaifis.it/arch/lag/proxy/pratica/knt/calcolocommissioneeffettiva',
                                                            WGC_Url_Dati_Bilancio__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/multibilanciosintetico/retrieve',
                                                            URLGetListaAziendeRibes__c= 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/getlistaaziendecompositeservice/getlistaaziende',
                                                            UserIdOverride__c = 'ext.crm',
                                                            UrlNvAggiornamentoInnescaVendita__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/nvaggiornamentoinnescavenditacompositeservice/nvaggiornamentoinnescavendita',
                                                            UrlLogger__c = 'https://' + sandboxUrl,
                                                            URLGetInformazioniPGRibes__c ='https://uatservices.bancaifis.it/arch/lag/proxy/pratica/getprodottopgcompositeservice/getprodottopg',
                                                            WGC_Url_Ricerca_multipla_documenti__c= 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/ricercadocumenti/multisearchdocument',
                                                            WGC_Url_ANAG70__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/posizionerischio/relazioni/inserimento',
                                                            WGC_Url_Doc08__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/ricercadocumenti/ottienidocumentipdf',
                                                            WGC_Url_Doc10__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/checklistdocuments/retrieve',
                                                            WGC_Url_PEF38__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/parametricondizioni',
                                                            UrlGestioneCollNdg__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/gestionecollndgcompositeservice/gestionecollndg',
                                                            UrlCertificazioneParser__c = 'https://pdf-ifis-t-' + sandboxName + '.herokuapp.com/tianticipo',
                                                            UrlDocumentiTaStatici__c = 'https://pdf-ifis-t-' + sandboxName + '.herokuapp.com');
                                                            

        insert lagKey;
    }

    public static void disattivaTrigger(){
        Funzionalita__c dtrg = new Funzionalita__c();
        dtrg.DisabilitaTriggers__c = true;
        insert dtrg;
    }

    public static void createImpostazioni(){
        Impostazioni__c i = new Impostazioni__c();
        i.IdCampagnaWeb__c='7011x0000004ps4';
        i.SogliaFatturatoSBCO__c =10000;
        insert i;
    }

    public static void disattivaCreaCTDopoInsertAcc(){
        Funzionalita__c a = new Funzionalita__c();
        a.DisabilitaCreazioneCTDopoInsertAcc__c = true;
        insert a;
    }    

    public static void creaImpServ(){
        ImpostazioniServizi__c impServ = new ImpostazioniServizi__c(SetupOwnerId=UserInfo.getOrganizationId(), CodiceIstituto3N__c = '881');
        insert impServ;
    }
    public static void creaImpServPol(){
        ImpostazioniServizi__c impServ = new ImpostazioniServizi__c(SetupOwnerId=UserInfo.getOrganizationId(), CodiceIstituto3N__c = '889');
        insert impServ;
    }


    public static List<Contact> createContact(Integer numberOfContact , Boolean toInsert){
        List<Contact> contactToInsert = new List<Contact>();
        List<Account> parentAcc = createAccount(1, true);

        for(Integer i = 0; i < numberOfContact; i ++){
            Double randNumber = Math.Random();
            Contact c = new Contact();
            c.AccountId = parentAcc.get(0).Id;
            c.FirstName = 'Contact'+randNumber+i;
            c.LastName = 'Contact'+randNumber+i;
            c.NDGGruppo__c = String.valueOf(i);
            C.CF__c ='AAABBB0'+i+'A11B123C';
            c.ProvinciaNascita__c ='RM';
            c.IsReferenteCampagna__c = Math.mod(i, 2) == 0 ? false : true;
            //c.AccountId = accList.get(0).Id;
            c.DataInserimentoConsensi__c = Date.TODAY();
            c.Birthdate = Date.TODAY();
            c.DataEmissioneDoc__c = Date.TODAY();
            c.DataScadenzaDoc__c = Date.TODAY();
            c.EnteEmitettenteDocumento__c ='Comune';  
            c.LuogoEmissioneDoc__c = 'Roma';
            c.LuogoNascita__c  = 'Roma';
            c.MailingCity  = 'Roma';
            c.MailingCountry  = 'Roma';
            c.MailingPostalCode = '00100';
            c.MailingState  = 'Roma';
            c.MailingStreetName__c  = 'Roma';
            c.MailingStreetNumber__c  = '10';
            c.MailingStreetType__c = 'Via';
            c.NumeroDoc__c ='ab12345'+i;
            c.Sesso__c ='M';
            c.TipoDocumentoId__c ='1';
            c.StatoFastFinance__c = 'Professionista';

            System.debug('@@@ contact to create ' + c);
            ContactToInsert.add(c);
        }
        //System.debug('ContactToInsert '+ContactToInsert);
        if(toInsert){
            insert ContactToInsert;
        }
        return ContactToInsert;
    }


    public static List<Contact> createContact(Integer numberOfContact){
        List<Contact> contactToInsert = new List<Contact>();
        for(Integer i = 0; i < numberOfContact; i ++){
            Double randNumber = Math.Random();
            Contact c = new Contact();
            c.FirstName = 'Contact'+randNumber+i;
            c.LastName = 'Contact'+randNumber+i;
            C.CF__c ='AAABBB0'+i+'A11B123C';
            c.ProvinciaNascita__c ='RM';
            c.IsReferenteCampagna__c = Math.mod(i, 2) == 0 ? false : true;
            //c.AccountId = accList.get(0).Id;
            c.DataInserimentoConsensi__c = Date.TODAY();
            c.Birthdate = Date.TODAY();
            c.DataEmissioneDoc__c = Date.TODAY();
            c.DataScadenzaDoc__c = Date.TODAY();
            c.EnteEmitettenteDocumento__c ='Comune';  
            c.LuogoEmissioneDoc__c = 'Roma';
            c.LuogoNascita__c  = 'Roma';
            c.MailingCity  = 'Roma';
            c.MailingCountry  = 'Roma';
            c.MailingPostalCode = '00100';
            c.MailingState  = 'Roma';
            c.MailingStreetName__c  = 'Roma';
            c.MailingStreetNumber__c  = '10';
            c.MailingStreetType__c = 'Via';
            c.NumeroDoc__c ='ab12345'+i;
            c.Sesso__c ='M';
            c.TipoDocumentoId__c ='1';
            c.StatoFastFinance__c = 'Professionista';

            System.debug('@@@ contact to create ' + c);
            ContactToInsert.add(c);
        }
        return ContactToInsert;
    }

    public static List<Opportunity> createOpportunity(Integer numberOfOpty , Boolean toInsert){
        List<Opportunity> optyToInsert = new List<Opportunity>();
        List<Account> accList = createAccount(1, true);
        for(Integer i = 0; i < numberOfOpty; i ++){
            Double randNumber = Math.Random();
            Opportunity o = new Opportunity();
            o.Name = 'Opportunity'+randNumber;
            o.StageName = 'In Istruttoria';
            o.AccountId = accList.get(0).Id;
            o.Owner = accList.get(0).Owner;
            o.Data_Inizio__c = Date.today();
            o.CloseDate = Date.today().addMonths(2);
            
            /*o.IsClosed = Math.mod(i, 2) == 0 ? true : false;
            o.IsWon = Math.mod(i, 3) == 0 ? true : false;*/
            o.Amount = randNumber;
            o.Probability=5;
            //(NOT (IsClosed = true AND IsWon = false))];
            
            optyToInsert.add(o);
        }
        if(toInsert){
            upsert optyToInsert;
        }
        return optyToInsert;
    }

    public static List<Opportunity> createOpportunity2(Integer numberOfOpty){
        List<Opportunity> optyToInsert = new List<Opportunity>();
       
        for(Integer i = 0; i < numberOfOpty; i ++){
            Double randNumber = Math.Random();
            Opportunity o = new Opportunity();
            o.Name = 'Opportunity'+randNumber;
            o.StageName = 'In Istruttoria';
            o.Data_Inizio__c = Date.today();
            o.CloseDate = Date.newInstance(2020,1,1);
            o.Amount = randNumber;
            o.Probability=5;
            optyToInsert.add(o);
        }
        return optyToInsert;
    }

    public static NDGLinea__c CreaNDGLineaDebitore(Account a, Opportunity o) {
        NDGLinea__c ndg = new NDGLinea__c(Account__c = a.id, Opportunita__c = o.id, Tipo__c = 'Debitore', RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Debitore').Id);
        insert ndg;
        return ndg;
    }

    public static List<Task> createTask(Integer numberOfTask , Boolean toInsert){
        List<Task> taskToInsert = new List<Task>();
        List<User> userList = createUser(1, true);
        List<Contact> contactList = createContact(1,true);
        //List<Account> accList = createAccount(1, true);
        Id recordTypeID1 = [SELECT Id FROM RecordType WHERE DeveloperName = 'ContattoTelefonicoDiretto'].Id;
        for(Integer i = 0; i < numberOfTask; i ++){
            Double randNumber = Math.Random();
            Task t = new Task();
            t.Status='Aperto';
            t.RecordTypeId = recordTypeID1;
            t.Subject = 'Task'+randNumber;
            t.OwnerId = userList.get(0).Id;
            t.WhatId = contactList.get(0).AccountId;
            t.WhoId =contactList.get(0).Id;
            t.ActivityDate = System.Today();
            t.Data_Inizio__c = System.Today();
            t.Data_Fine__c = System.Today();
            taskToInsert.add(t);
        }
        if(toInsert){
            insert taskToInsert;
        }
        return taskToInsert;
    }

    public static List<Task> createTask(Integer numberOfTask){
        List<Task> taskToInsert = new List<Task>();
        List<User> userList = createUser(1, true);
        //List<Account> accList = createAccount(1, true);
        Id recordTypeID1 = [SELECT Id FROM RecordType WHERE DeveloperName = 'ContattoTelefonicoDiretto'].Id;
        for(Integer i = 0; i < numberOfTask; i ++){
            Double randNumber = Math.Random();
            Task t = new Task();
            t.Status='Aperto';
            t.RecordTypeId = recordTypeID1;
            t.Subject = 'Task'+randNumber;
            t.OwnerId = userList.get(0).Id;
            t.ActivityDate = System.Today();
            t.Data_Inizio__c = System.Today();
            t.Data_Fine__c = System.Today();
            // t.WhatId = contactList.get(0).AccountId;
            // t.WhoId =contactList.get(0).Id;
            taskToInsert.add(t);
        }
        
        return taskToInsert;
    }

    public static List<Event> createEvent(Integer numberOfEvent , Boolean toInsert){
        List<Event> eventToInsert = new List<Event>();
        //List<Account> listAcc = WGC_AllDataFactory.createAccount(1,true);
        User u = createUser(1,true).get(0);
        List<Contact> contactList = createContact(3,true);
        for(Integer i = 0; i < numberOfEvent; i ++){
            Double randNumber = Math.Random();
            Event e = new Event(
            Subject = 'Event'+randNumber, 
            CreatedById = u.Id,
            LastModifiedById = u.Id,
            ActivityDateTime = DateTime.now().addDays(2),
            WhoId = contactList.get(1).Id,
            WhatId = contactList.get(0).AccountId,
            DurationInMinutes=100,
            // StartDateTime =DateTime.now().addDays(2),
            // EndDateTime = DateTime.now().addDays(4),
            EsitoLivello1__c=null);
            
            eventToInsert.add(e);
        }

        System.debug('eventToInsert '+eventToInsert);
        if(toInsert){
            insert eventToInsert;
        }
        return eventToInsert;
    }
    public static List<Event> createEvent(Integer numberOfEvent){
        List<Event> eventToInsert = new List<Event>();
        User u = createUser(1,true).get(0);
       
        for(Integer i = 0; i < numberOfEvent; i ++){
            Double randNumber = Math.Random();
            Event e = new Event(
            Subject = 'Event'+randNumber, 
            CreatedById = u.Id,
            LastModifiedById = u.Id,
            ActivityDateTime = DateTime.now().addDays(2),
            DurationInMinutes=100,
            EsitoLivello1__c=null);
            
            eventToInsert.add(e);
        }
        return eventToInsert;
    }

    public static List<WGC_Posizione__c> createPosizioni(Integer numberOfPosizioni , Boolean toInsert){
        List<WGC_Posizione__c> posizioniToInsert = new List<WGC_Posizione__c>();
        List<Account> accList = createAccount(1, true);
        for(Integer i = 0; i < numberOfPosizioni; i ++){
            WGC_Posizione__c p = new WGC_Posizione__c();
            p.Anagrafica__c = accList.get(0).Id;
            posizioniToInsert.add(p);
        }
        if(toInsert){
            insert posizioniToInsert;
        }
        return posizioniToInsert;
    }

    public static List<WGC_Linea_Prodotto__c> createLineaProdotti(Integer numberOfProdotti , Boolean toInsert){
        List<WGC_Linea_Prodotto__c> prodottiToInsert = new List<WGC_Linea_Prodotto__c>();
        List<WGC_Posizione__c> posList = createPosizioni(numberOfProdotti, true);
        List<Account> accList = [SELECT Id, Name FROM Account];
        for(Integer i = 0; i < numberOfProdotti; i ++){
            
            Double randNumber = Math.Random();
            WGC_Linea_Prodotto__c lp = new WGC_Linea_Prodotto__c();
            lp.Name = 'LineaProd'+randNumber;
            lp.Anagrafica__c = accList.get(0).Id;
            lp.Posizione__c = posList.get(i).Id;
            lP.Data_Scadenza__c= Date.today().addDays(5);
            lP.Accordato__c=1000;
            prodottiToInsert.add(lp);
        }
        if(toInsert){
            insert prodottiToInsert;
        }
        return prodottiToInsert;
    }

    public static List<WGC_Linea_Prodotto__c> createLineaProdotti2(Integer numberOfProdotti , Boolean toInsert){
        List<WGC_Linea_Prodotto__c> prodottiToInsert = new List<WGC_Linea_Prodotto__c>();
        List<WGC_Posizione__c> posList = createPosizioni(numberOfProdotti, true);
        List<Account> accList = [SELECT Id, Name FROM Account];
        for(Integer i = 0; i < numberOfProdotti; i ++){
            Double randNumber = Math.Random();
            WGC_Linea_Prodotto__c lp = new WGC_Linea_Prodotto__c();
            lp.Name = 'LineaProd'+randNumber;
            lp.Anagrafica__c = accList.get(0).Id;
            lp.Posizione__c = posList.get(i).Id;
            lp.Qualifica_Prodotto__c = 'Cliente attivo';
            lp.Codice_Linea_Sistema__c='123';
            prodottiToInsert.add(lp);
        }
        if(toInsert){
            insert prodottiToInsert;
        }
        return prodottiToInsert;
    }

    public static List<ContentVersion> createContentVersion(Integer numberOfContentVersion , Boolean toInsert){
        
        List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
        for(Integer i = 0; i < numberOfContentVersion; i ++){
            Double randNumber = Math.Random();
            ContentVersion c = new ContentVersion();
            c.Title='Title'+ randNumber; 
            c.VersionData= Blob.valueOf('Body' + randNumber);
            c.PathOnClient='Title'+ randNumber;
            contentVersionToInsert.add(c);
        }
        if(toInsert){
            insert contentVersionToInsert;
        }
        return contentVersionToInsert;
    }



//Profile
    public static Profile createProfile(){
        Profile p = new Profile();
        return p;
    }

    public static List<CampaignMember> createCampaignMember(Integer numberOfCM , Boolean toInsert){
        List<CampaignMember> CMToInsert = new List<CampaignMember>();
        Contact c = createContact(1,true).get(0);
        for(Integer i = 0; i < numberOfCM; i ++){
            Double randNumber = Math.Random();
            CampaignMember cm = new CampaignMember();
            cm.ContactId = c.Id;
            CMToInsert.add(cm);
        }
        
        System.debug('CMToInsert '+CMToInsert);

        if(toInsert){
            insert CMToInsert;
        }
        return CMToInsert;
    }
    public static List<CampaignMember> createCampaignMember(Integer numberOfCM , Contact c, Boolean toInsert){
        List<CampaignMember> CMToInsert = new List<CampaignMember>();
        
        for(Integer i = 0; i < numberOfCM; i ++){
            Double randNumber = Math.Random();
            CampaignMember cm = new CampaignMember();
            cm.ContactId = c.Id;
            CMToInsert.add(cm);
        }
        
        System.debug('CMToInsert '+CMToInsert);

        if(toInsert){
            insert CMToInsert;
        }
        return CMToInsert;
    }

    public static List<Campaign> createCampaign(Integer numberOfCampaign, Boolean toInsert){
        List<Campaign> CampaignToInsert = new List<Campaign>();
        //CampaignMember cm =createCampaignMember(1,true).get(0);
        for(Integer i = 0; i < numberOfCampaign; i ++){
            Double randNumber = Math.Random();
            Campaign campaign = new Campaign();
            campaign.Name = 'Campaign'+randNumber;
            campaign.Status = 'In Progress';
            campaign.IsActive = Math.mod(i, 2) == 0 ? true : false;
            //campaign.ParentId = cm.Id;
            CampaignToInsert.add(campaign);
        }
        if(toInsert){
            insert CampaignToInsert;
        }
        return CampaignToInsert;
    }

    public static List<WGC_Bilancio__c> createBilancio(Integer numberOfBilancio , Boolean toInsert){
        List<WGC_Bilancio__c> bilancioToInsert = new List<WGC_Bilancio__c>();
        for(Integer i = 0; i < numberOfBilancio; i ++){
            Double randNumber = Math.Random();
            WGC_Bilancio__c bil = new WGC_Bilancio__c();
            bilancioToInsert.add(bil);
        }
        if(toInsert){
            insert bilancioToInsert;
        }
        return bilancioToInsert;
    }

    //WGC_Link_Legal_Entity__c
    public static List<WGC_Link_Legal_Entity__c> createLinkLegalEntity(Integer numberOfLLE , Boolean toInsert){
        List<WGC_Link_Legal_Entity__c> linkLegalEntityToInsert = new List<WGC_Link_Legal_Entity__c>();
        for(Integer i = 0; i < numberOfLLE; i ++){
            Double randNumber = Math.Random();
            WGC_Link_Legal_Entity__c lle = new WGC_Link_Legal_Entity__c();
            //lle.NDG_collegato__c
            linkLegalEntityToInsert.add(lle);
        }
        if(toInsert){
            insert linkLegalEntityToInsert;
        }
        return linkLegalEntityToInsert;
    }

    public static List<WGC_Centrale_Rischi__c> createCentraleRischi(Integer numberOfCR, Boolean toInsert){
        List<WGC_Centrale_Rischi__c> centraleRischiToInsert = new List<WGC_Centrale_Rischi__c>();
        Account a = createAccount(1,true).get(0);
        Date d = Date.TODAY();
        for(Integer i = 0; i< numberOfCR; i++){
            Double randNumber = Math.Random();
            WGC_Centrale_Rischi__c cr = new WGC_Centrale_Rischi__c();
            cr.Anagrafica__c = a.id;
            cr.KEY_ETL__c= 'a'+randNumber;
            cr.Anno__c=''+d.year();
            centraleRischiToInsert.add(cr);
        }

        if(toInsert)
            insert centraleRischiToInsert;
        
        return centraleRischiToInsert;
    }

    public static List<WGC_Centrale_Rischi__c> createCentraleRischi(Integer numberOfCR){
        List<WGC_Centrale_Rischi__c> centraleRischiToInsert = new List<WGC_Centrale_Rischi__c>();
        Date d = Date.TODAY();
        for(Integer i = 0; i< numberOfCR; i++){
            Double randNumber = Math.Random();
            WGC_Centrale_Rischi__c cr = new WGC_Centrale_Rischi__c();
            cr.KEY_ETL__c= 'a'+randNumber;
            cr.Anno__c=''+d.year();
            centraleRischiToInsert.add(cr);
        }
        return centraleRischiToInsert;
    }

    
//AdeguataVerifica__c
    public static List<AdeguataVerifica__c> createAdeguataVerifica(Integer numberOfAV, Boolean toInsert){
        List<AdeguataVerifica__c> adeguataVerToInsert = new List<AdeguataVerifica__c>();
        Account a = createAccount(1,toInsert).get(0);
        for(Integer i = 0; i< numberOfAV; i++){
            Double randNumber = Math.Random();
            AdeguataVerifica__c av = new AdeguataVerifica__c( 
                CreatedDate = DateTime.now().addDays(-i),
                Account__c = a.Id);
            adeguataVerToInsert.add(av);
        }
        if(toInsert)
            insert adeguataVerToInsert;
        
        return adeguataVerToInsert;
    }
    public static List<AdeguataVerifica__c> createAdeguataVerifica2(Integer numberOfAV, Boolean toInsert, String accId){
        List<AdeguataVerifica__c> adeguataVerToInsert = new List<AdeguataVerifica__c>();
        for(Integer i = 0; i< numberOfAV; i++){
            Double randNumber = Math.Random();
            AdeguataVerifica__c av = new AdeguataVerifica__c( 
                CreatedDate = DateTime.now().addDays(-i),
                Account__c = accId,
                WGC_Data_Compilazione__c = System.Today()
                );
            adeguataVerToInsert.add(av);
        }
        if(toInsert)
            insert adeguataVerToInsert;
        
        return adeguataVerToInsert;
    }

    public static Comune__c createComune(String nome, String provincia, String cap) {
        Comune__c comune = new Comune__c(
        Name = nome,
        Provincia__c = provincia,
        CAP__c = cap
        );

        insert comune;
        return comune;
    }

    public static List<WGC_Budget__c> createBudget(Integer n, Boolean toInsert){
        List<WGC_Budget__c> lista = new List<WGC_Budget__c>();
        List<User> listUser = createUser(1,true);
        Double randNumber = Math.Random();
        Date d = Date.today();
        for(Integer i = 0; i<n; i++){
            WGC_Budget__c budget = new WGC_Budget__c();
            budget.Name = 'TestBudget'+randNumber;
            budget.CreatedById =listUSer.get(0).Id;
            budget.Anno__c=String.valueOf(d.year());
            budget.Mese__c=String.valueOf(d.month());
            budget.Pratiche_presentate__c = Math.floor(randNumber);
            lista.add(budget);
        }
        if(toInsert)
            insert lista;
        return lista;
    }
    
    public static List<WGC_Best_Practice__c> createBestPractice(Integer n, Boolean toInsert){
        List<WGC_Best_Practice__c> lista = new List<WGC_Best_Practice__c>();

        Double d = Math.Random();

        for(Integer i=0; i<n; i++){
            WGC_Best_Practice__c bp = new WGC_Best_Practice__c(OwnerId = UserInfo.getUserId(), Week__c=''+i);
            lista.add(bp);
        }

        if(toInsert)
            insert lista;
        return lista;

    }

    public static List<WGC_New_Business__c> createNewBusiness(Integer n, Boolean toInsert){
        List<WGC_New_Business__c> lista = new List<WGC_New_Business__c>();

        Double d = Math.Random();

        for(Integer i=0; i<n; i++){
            WGC_New_Business__c bp = new WGC_New_Business__c(OwnerId = UserInfo.getUserId(), NDG_Settorista__c = UserInfo.getUserId(), Data_New_Business__c = System.Today());
            lista.add(bp);
        }

        if(toInsert)
            insert lista;
        return lista;

    }

    public static List<QuestionarioQualitativo__c> createQuestionarioQualitativo(Integer n, Boolean toInsert){
        List<Account> accList = createAccount(1, true);
        List<QuestionarioQualitativo__c> lista = new List<QuestionarioQualitativo__c>();

        Double d = Math.Random();

        for(Integer i=0; i<n; i++){
            QuestionarioQualitativo__c bp = new QuestionarioQualitativo__c(Account__c=accList.get(0).Id, NomeModello__c ='Corporate', Stato__c = 'CONFERMATO', DataCompilazione__c = System.Today());
            lista.add(bp);
        }

        if(toInsert)
            insert lista;
        return lista;

    }

    public static List<NDGLinea__c> createAttori(Integer n, Boolean toInsert){
        List<NDGLinea__c> lista = new List<NDGLinea__c>();
        List<Opportunity> opty = createOpportunity(1,true);
        Contact c = createContact(1,true).get(0);
        Double d = Math.Random();

        for(Integer i=0; i<n; i++){
            NDGLinea__c attori = new NDGLinea__c(Commessa__c= Math.mod(i, 2) == 0 ? true : false,
                                            Appalto_d_opera__c= false,
                                            Opportunita__c=opty.get(0).Id,
                                            Contact__c = c.Id,
                                            Tipo__c='Garante');
            lista.add(attori);
        }

        if(toInsert)
            insert lista;
        return lista;

    }

    public static List<NDGLinea__c> createAttori2(Integer n, Boolean toInsert){
        List<NDGLinea__c> lista = new List<NDGLinea__c>();
        
        Contact c = createContact(1,true).get(0);
        List<Opportunity> opty = createOpportunity2(1);
        Account a = [SELECT Id, OwnerId FROM Account LIMIT 1];
        opty.get(0).AccountId = a.Id;
        opty.get(0).OwnerId = a.OwnerId;
        insert opty;
        Double d = Math.Random();

        for(Integer i=0; i<n; i++){
            NDGLinea__c attori;
            if(i != 1){
                attori = new NDGLinea__c(Commessa__c= Math.mod(i, 2) == 0 ? true : false,
                                                Appalto_d_opera__c= false,
                                                Opportunita__c=opty.get(0).Id,
                                                Contact__c = c.Id,
                                                Tipo__c='Garante');
            }
            else{
                attori = new NDGLinea__c(Commessa__c= Math.mod(i, 2) == 0 ? true : false,
                                Appalto_d_opera__c= false,
                                Opportunita__c=opty.get(0).Id,
                                Account__c = a.Id,
                                Tipo__c='Garante');
            }
            lista.add(attori);
        }

        if(toInsert)
            insert lista;
        return lista;

    }


    public static List<Ateco__c> createAteco(Integer n, Boolean toInsert){
        List<Ateco__c> lista = new List<Ateco__c>();
      
        Double d = Math.Random();

        for(Integer i=0; i<n; i++){
            Ateco__c ateco = new Ateco__c();
            ateco.Cedacri__c = String.ValueOf(d);
            ateco.Descrizione__c = 'Descrizione ' + i;
            ateco.RAE__c = '11';
            lista.add(ateco);
        }

        if(toInsert)
            insert lista;
        return lista;

    }
    
    public static List<Linea__c> createLinee(Integer n, Boolean toInsert){
        List<Linea__c> lista = new List<Linea__c>();
        createAttori2(1,true);
        List<Prodotto__c> listaProd = createProdotti(1,true);
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
    
        for(Integer i=0; i<n; i++){
            Linea__c linea = new Linea__c(Opportunity__c = o.Id, Prodotto__c=listaProd.get(0).Id);
            lista.add(linea);
        }

        if(toInsert)
            insert lista;
        return lista;
    
    }

    public static List<Linea__c> createLinee2(Integer n, Boolean toInsert){
        List<Linea__c> lista = new List<Linea__c>();
        createAttori2(3,true);
        List<Prodotto__c> listaProd = createProdotti(1,true);
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
    
        for(Integer i=0; i<n; i++){
            Linea__c linea = new Linea__c(Opportunity__c = o.Id, Prodotto__c=listaProd.get(0).Id);
            lista.add(linea);
        }

        if(toInsert)
            insert lista;
        return lista;
    
    }

    public static List<Prodotto__c > createProdotti(Integer n, Boolean toInsert){
        List<Prodotto__c > lista = new List<Prodotto__c >();
        for(Integer i=0; i<n; i++){
            Prodotto__c  prod = new Prodotto__c (CodiceProdotto__c = 'PCMCC', 
                                                WGC_Area__c = 'Finanziamenti',
                                                WGC_Famiglia__c='Mutuo',
                                                CodiceUnivoco__c='Fido', 
                                                Codice__c='000');
            lista.add(prod);
        }
        if(toInsert)
            insert lista;
        return lista;
    }

    public static void createItemMapping(){
        createLinee(1,true);
        // createProdotti(1,true);
        List<Opportunity> o = [SELECT Id, TiAnticipo__c FROM Opportunity];
        o.get(0).TiAnticipo__c=true;
        update o;
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        NDGLinea__c attore = [SELECT Id,Tipo__c FROM NDGLinea__c LIMIT 1];
        attore.Tipo__c = 'Esecutore adeguata verifica';
        update attore;
        List<Prodotto__c> p = [SELECT Id,CodiceProdotto__c, Codice__c, WGC_Area__c FROM Prodotto__c];
        // p.get(1).CodiceProdotto__c = 'PCFII';
        p.get(0).Codice__c='521';
        // p.get(1).Codice__c='521';
        
        //p.get(0).CodiceUnivoco__c = 'ATDTiAnticipo';
        p.get(0).CodiceProdotto__c = 'PCFII';
        update p;
        createAdeguataVerifica2(1,true,a.id);
    }

    public static List<WGC_Nota_Documento__c> createNotaDocumento(Integer n, Boolean toInsert){
        List<WGC_Nota_Documento__c> lista = new List<WGC_Nota_Documento__c>();

        for(Integer i=0;i<n; i++){
            WGC_Nota_Documento__c nota = new WGC_Nota_Documento__c();
            lista.add(nota);

        }
        if(toInsert){
            insert lista;
        }
        return lista;
    }

    public static List<WGC_Fido_di_Coppia__c> createFidoCoppia(Integer n, Boolean toInsert){
        List<WGC_Fido_di_Coppia__c> lista = new List<WGC_Fido_di_Coppia__c>();

        for(Integer i=0;i<n; i++){
            WGC_Fido_di_Coppia__c fidocoppia = new WGC_Fido_di_Coppia__c();
            fidocoppia.Codice_famiglia_coppia__c = 'I';
            lista.add(fidocoppia);

        }
        if(toInsert){
            insert lista;
        }
        return lista;
    }

    public static List<Comune__c> createComune(Integer n, Boolean toInsert){
        List<Comune__c> lista = new List<Comune__c>();

        for(Integer i=0;i<n; i++){
            Comune__c comune = new Comune__c();
            comune.Name = 'Comune' + i;
            comune.GruppoSAE__c = 'SAE' + i;
            comune.FlagStorico__c = FALSE;
            lista.add(comune);

        }
        if(toInsert){
            insert lista;
        }
        return lista;
    }

    public static String generateRandomString(Integer len, Boolean onlyNumber) {
        final String chars = onlyNumber ? '0123456789' : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String randStr = '';
        while (randStr.length() < len) {
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    public static List<WGC_Andamentale__c> createAndamentale(Integer n, User u){
        List<WGC_Andamentale__c> andamentale = new List<WGC_Andamentale__c>();

        for(Integer i = 0; i < n; i++){
            WGC_Andamentale__c andamentaleSingle = new WGC_Andamentale__c(Operatore__c = u.Id, Team__c = u.WGC_Team_Filo_Diretto__c, Data__c = System.Today().addDays(i), CT_Actual__c = Integer.valueOf(Math.Random()), VC_Actual__c = Integer.valueOf(Math.Random()));
            andamentale.add(andamentaleSingle);
        }

        return andamentale;
    }

    public static List<WGC_Dettaglio_Visite__c> createDettaglioVisite(Integer n, User uFD, User uComm){
        List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>();

        List<Account> accList = WGC_AllDataFactory.createAccount(1);
        accList[0].Filiale__c = 'ROMA';
        Insert accList;

        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='WGC_Dettaglio_Visite__c' AND DeveloperName='Dettaglio_Visita'];

        for(Integer i = 0; i < n; i++){
            WGC_Dettaglio_Visite__c dt = new WGC_Dettaglio_Visite__c(Ragione_Sociale__c = accList[0].Id, Operatore_Filo_Diretto__c = uFD.Id, Data_Visita_Commerciale__c = System.Today(), Settorista__c = uComm.Id, RecordTypeId = rt.Id, Filiale__c = 'ROMA');
            dtList.add(dt);
        }

        return dtList;
    }

    public static List<Credito__c> createCrediti(Integer n, Id opportunityId, Id lineaId){

        List<Credito__c> crediti = new List<Credito__c>();
        for(Integer i = 0; i < n; i++){
            Credito__c c = new Credito__c(WGC_Linea__c = lineaId, Opportunita__c = opportunityId, Imposta__c = '36', WGC_Invia_Credito__c = true, WGC_Codice_Rapporto__c = '0000000000000', ValoreNominale__c = 1,
                                            /*WGC_Val_Nom_Esigibile__c = 2,*/ WGC_Ruoli_Compens__c = 3, WGC_Commissione_Acquisto__c = 2, WGC_Data_Cessione_Credito__c = System.Today(), WGC_Non_Deliberata__c = true, WGC_Deliberata__c = false);
            crediti.add(c);
        }

        return crediti;
    }
}