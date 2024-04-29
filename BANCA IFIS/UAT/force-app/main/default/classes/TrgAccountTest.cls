/**
* Progetto:         Banca IFIS
* Sviluppata il:    05/10/2016
* Developer:        Zerbinati Francesco
*/

@isTest
private class TrgAccountTest {
    
    /**
*     STRUTTURA ORGANIZZATIVA DEL TEST
*
*           ---- SUPER_ALIAS ------
*           |                       |
*         eloisa                passerini
*           |                       |
*        -------------              |
*       |             |             |
*     manente       zucca          dora
*
*/
    
    @testSetup
    static void dataSetup() {
        WGC_AllDataFactory.createUtenzaDefault();
        AnagrafeConsulenti__c cons = new AnagrafeConsulenti__c(Name = '12345', Nome__c = 'mario', Cognome__c = 'rossi', NDGGruppo__c = '12345');
        AnagrafeConsulenti__c cons1 = new AnagrafeConsulenti__c(Name = '67890', Nome__c = 'paolo', Cognome__c = 'bianchi', NDGGruppo__c = '67890');
        insert cons1;
        insert cons;
        User dora = TestUtils.creaUtente('dora');
        User passerini = TestUtils.creaUtente('passe');
        User manente = TestUtils.creaUtente('mane');
        User zucca = TestUtils.creaUtente('zucca');
        User eloisa = TestUtils.creaUtente('eloisa');
        
        dora.ManagerId = passerini.Id;
        zucca.ManagerId = eloisa.Id;
        manente.ManagerId = eloisa.Id;
        
        update dora;
        update zucca;
        update manente;
        
        TestUtils.impostaCS();
        Funzionalita__c f = Funzionalita__c.getOrgDefaults();
        f.DisabilitaNamingAutomaticaOpportunita__c = true;
        f.BypassValidationRule__c = false;
        insert f;
        
        Account acc = TestUtils.creaAccount('A',dora);
        Contact ccc = TestUtils.creaReferente(acc);
        acc.ClienteTiAnticipoGiaPresente__c = true;
        update acc;
        ccc.IsReferenteCampagna__c = true;
        update ccc;
        TestUtils.creaAteco('100');
        
        Comune__c c20154 = TestUtils.creaComune('20154');
        Comune__c c87100 = TestUtils.creaComune('87100');
        Comune__c c27100 = TestUtils.creaComune('27100');
        
        
        // creo assegnazioni cap/utente
        TestUtils.creaAssegnazioneAnagrafica(dora, c20154);
        TestUtils.creaAssegnazioneAnagrafica(passerini, c20154);
        TestUtils.creaAssegnazioneAnagrafica(manente, c87100);
        TestUtils.creaAssegnazioneAnagrafica(manente, c27100);
        TestUtils.creaAssegnazioneAnagrafica(zucca, c27100);
        TestUtils.creaAssegnazioneAnagrafica(zucca, c20154);
        
        EndpointServizi__c endpointTest = new EndpointServizi__c();
        endpointTest.name = 'settings';
        insert endpointTest;
    }
    
    @isTest
    static void testCambiaNomeGestoreCliente(){
        Account a = [SELECT Id, GestoreCliente__c, GestoreClienteNome__c FROM Account WHERE Name = 'A'];
        a.GestoreCliente__c = '67890';
        update a;
        Account newA = [SELECT Id, GestoreCliente__c, GestoreClienteNome__c FROM Account WHERE Name = 'A'];
        //System.assertEquals(newA.GestoreClienteNome__c,'paolo bianchi');
        
        a.GestoreCliente__c = '12345';
        update a;
        Account newAA = [SELECT Id, GestoreCliente__c, GestoreClienteNome__c FROM Account WHERE Name = 'A'];
        //System.assertEquals(newAA.GestoreClienteNome__c,'mario rossi');
    }
    
    @isTest
    static void testSettoreAteco() {
        // creo un account e assegno un ateco
        Account a = [SELECT Id,Name,OwnerId, MercatoNew__c FROM Account WHERE Name = 'A'];
        Ateco__c[] at = [SELECT Id,Name,Cedacri__c, Mercato__c FROM Ateco__c WHERE Name = '100'];
        a.Ateco__c = at[0].Cedacri__c;
        
        Test.startTest();
        
        update a;
        
        // vado a verificare se SettoreAttivita__c e DettaglioSettore sono quelli dati da ATECO
        a = [SELECT Id,SettoreAttivita__c,DettaglioSettore__c, MercatoNew__c FROM Account WHERE Name = 'A'];
        
        // System.assertEquals('Settore attività ATECO Test', a.SettoreAttivita__c);
        // System.assertEquals('Dettaglio ATECO Test', a.DettaglioSettore__c);
        // System.assertEquals('AGRICOLTURA', a.MercatoNew__c);
        
        Test.stopTest();
        
    }
    
    // @isTest
    // TEN SV - LOGGICA RICHIESTA ASSEGNAZIONE GESTITA DA FLOW
    // static void testRichiestaAssegnazioni() {
    //   // cambio stato assegnazione per scatenare il trigger
    //   Account a = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'A'];
    //   System.debug('owner account:'+a);
    //   // A è di Dora, manager Passerini --> lo richiede Zucca --> richiesta a super
    //   User richiedente = [SELECT Id FROM User WHERE Alias = 'zucca'];
    //   User appr = [SELECT Id FROM User WHERE Alias = 'eloisa'];
    //   a.Richiedente__c = richiedente.Id;
    //   a.StatoAssegnazione__c = 'Richiesta';
    //   a.ApprovatoreFinStrut__c = appr.Id;
    //   a.Approvatore__c =appr.Id;
    
    //   Test.startTest();
    
    //   update a;
    
    //   ProcessInstance ap = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :a.Id];
    
    //   // controllo che sia stato inviato l'approval process (che non sia quindi null)
    //   System.assertNotEquals(ap.TargetObjectId,null);
    
    //   User approvatore = [SELECT Id FROM User WHERE Alias = :TestUtils.SUPER_ALIAS];
    //   a = [SELECT Id,Name,OwnerId,Approvatore__c FROM Account WHERE Name = 'A'];
    //   System.assertEquals(a.Approvatore__c,approvatore.Id);
    
    //   // approvo richiesta manualmente per far scattare secondo trigger (reset)
    //   a.StatoAssegnazione__c = 'Approvata';
    //   update a;
    
    //   Test.stopTest();
    
    //   a = [SELECT Id,Name,OwnerId,Approvatore__c,Richiedente__c,StatoAssegnazione__c FROM Account WHERE Name = 'A'];
    //   // controllo che il nuovo owner sia il richiedente (zucca)
    //   System.assertEquals(a.OwnerId,richiedente.Id);
    
    //   // controllo di aver sbiancato i campi
    //   System.assertEquals(null,a.Richiedente__c);
    //   System.assertEquals(null,a.Approvatore__c);
    //   System.assertEquals(null,a.StatoAssegnazione__c);
    
    // }
    
    @isTest
    static void teststabilisciPriorita() {
        
        MatriceSviluppo__mdt[] ms = [SELECT
                                     PrioritaSmall__c,
                                     PrioritaMedium__c,
                                     PrioritaLarge__c
                                     FROM MatriceSviluppo__mdt WHERE DeveloperName IN ('BB_Diretto','BB_Indiretto') ORDER BY DeveloperName
                                    ];
        
        Account a = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'A'];
        a.DimensioneDelBusiness__c = 1000000;
        a.RatingT0__c = 'BB';
        
        update a;
        
        a = [SELECT PrioritaSviluppoDiretto__c,PrioritaSviluppoIndiretto__c FROM Account WHERE Name = 'A'];
        // System.assertEquals(ms[0].PrioritaSmall__c,a.PrioritaSviluppoDiretto__c);
        // System.assertEquals(ms[1].PrioritaSmall__c,a.PrioritaSviluppoIndiretto__c);
        
        a.DimensioneDelBusiness__c = 20000000;
        update a;
        
        a = [SELECT PrioritaSviluppoDiretto__c,PrioritaSviluppoIndiretto__c FROM Account WHERE Name = 'A'];
        // System.assertEquals(ms[0].PrioritaMedium__c,a.PrioritaSviluppoDiretto__c);
        // System.assertEquals(ms[1].PrioritaMedium__c,a.PrioritaSviluppoIndiretto__c);
        
        a.DimensioneDelBusiness__c = 100000000;
        update a;
        
        a = [SELECT PrioritaSviluppoDiretto__c,PrioritaSviluppoIndiretto__c FROM Account WHERE Name = 'A'];
        // System.assertEquals(ms[0].PrioritaLarge__c,a.PrioritaSviluppoDiretto__c);
        // System.assertEquals(ms[1].PrioritaLarge__c,a.PrioritaSviluppoIndiretto__c);
    }
    
    @isTest
    static void testCreazioneRefStandard() {
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaVRNonIndispensabili__c = true;
        upsert f;
        
        Account a = [SELECT Id FROM Account WHERE Name = 'A'];
        List<Contact> cs = new List<Contact>();
        cs = [SELECT FirstName, LastName FROM Contact WHERE AccountId = :a.Id AND IsReferenteCampagna__c = TRUE];
        Contact c = cs.size() > 0 ? cs.get(0) : new Contact();
        
        //System.assertEquals('A', c.LastName);
        //System.assertEquals('Centralino', c.FirstName);
        
        a.Name = 'Pinco Pallino';
        update a;
        
        c = [SELECT FirstName, LastName FROM Contact WHERE AccountId = :a.Id AND IsReferenteCampagna__c = TRUE].get(0);
        //System.assertEquals('Pinco Pallino', c.LastName);
        //System.assertEquals('Centralino', c.FirstName);
    }
    
    @isTest
    static void testTrasferimentoAttivita() {
        Test.startTest();
        Account a = [SELECT Id,OwnerId FROM Account WHERE Name = 'A'];
        
        System.debug('acc: '+a);
        
        Contact c = TestUtils.creaReferente(a);
        Task t = TestUtils.creaTask(a);
        Event e = TestUtils.creaEvento(a, c);
        System.debug('t: '+t);
        System.debug('e: '+e);
        User nuovoOwner = [SELECT Id FROM User WHERE Alias = 'mane'];
        System.debug('nuovo : '+nuovoOwner);
        // cambio owner all'account
        a.OwnerId = nuovoOwner.Id;
        update a;
        Test.stopTest();
        // ok, ora dovrei avere attività t,e con il nuovo ownerId
        
        //t = [SELECT OwnerId FROM Task WHERE Id = :t.Id];
        //e = [SELECT OwnerId FROM Event WHERE Id = :e.Id];
        
        // System.assertEquals(nuovoOwner.Id,e.OwnerId);
        // System.assertEquals(nuovoOwner.Id,t.OwnerId);
        
    }
    
    @isTest
    static void testGestisciOwner() {
        
        String[] nomiRuoli = new String[]{
            'CommercialeMilano',
                'CommLending',
                'RespFinanzaStrutturata'
                };
                    UserRole[] ruoli = [SELECT DeveloperName FROM UserRole WHERE DeveloperName IN :nomiRuoli];
        User[] utenti = new User[]{};
            
            System.runAs ([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
                for (Integer i = 0; i < ruoli.size(); i++) {
                    String alias = ruoli[i].DeveloperName.substring(0, 5) + i;
                    utenti.add(new User(
                        Alias = alias,
                        Email = alias + '@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = alias,
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        ProfileId = TestUtils.STANDARD_PROFILE,
                        TimeZoneSidKey = 'America/Los_Angeles',
                        UserName = alias + '@bancaifis.test.com',
                        UserRoleId = ruoli[i].Id,
                        IsActive = true,
                        NDGGruppo__c = String.valueOf((Math.random() * 1000000).intValue())
                    ));
                }
                insert utenti;
            }
        
        // Account acc = TestUtils.creaAccount('B', utenti[0]);
        Account acc = [SELECT Id,OwnerId FROM Account WHERE Name = 'A'];
        Id utenzaDefault = UtenzeDefault__c.getInstance().IdUtente__c;
        
        // caso 1: commerciale Milano
        Id ownerPrecedente = acc.OwnerId;
        update acc;
        Test.startTest();
        acc = [SELECT OwnerId, CommercialeLending__c, CommercialeFinanzaStrutturata__c FROM Account WHERE Id = :acc.Id];
        // System.assert(CU.isCommerciale(acc.OwnerId));
        // System.assertEquals(ownerPrecedente, acc.OwnerId);
        
        // caso 2: commerciale lending
        acc.OwnerId = utenti[1].Id;
        ownerPrecedente = utenti[1].Id;
        update acc;
        acc = [SELECT OwnerId, CommercialeLending__c, CommercialeFinanzaStrutturata__c FROM Account WHERE Id = :acc.Id];
        //System.assert(CU.isLending(ownerPrecedente));
        // System.assertEquals(acc.CommercialeLending__c, ownerPrecedente);
        // System.assertEquals(utenzaDefault, acc.OwnerId);
        
        // caso 3: responsabile finanza strutturata
        acc.OwnerId = utenti[2].Id;
        ownerPrecedente = utenti[2].Id;
        update acc;
        acc = [SELECT OwnerId, CommercialeLending__c, CommercialeFinanzaStrutturata__c FROM Account WHERE Id = :acc.Id];
        //System.assert(CU.isFinanzaStrutturata(ownerPrecedente));
        // System.assertEquals(acc.CommercialeFinanzaStrutturata__c, ownerPrecedente);
        // System.assertEquals(utenzaDefault, acc.OwnerId);
        Test.stopTest();
    }
    
    @isTest
    static void testCambiaOwnerAccount() {
        TrgAccount.CambiaOwnerAccountResult result;
        Id userRoleFactoring = [SELECT Id FROM UserRole WHERE DeveloperName = 'CommercialeGenova'][0].Id;
        Id recordTypeOppFactoring = [SELECT Id FROM RecordType WHERE DeveloperName = 'IFISOpportunitaFactoring'][0].Id;
        Id recordTypeOppLending = [SELECT Id FROM RecordType WHERE DeveloperName = 'IFISOpportunitaCommercialLending'][0].Id;
        
        Profile pFact = [SELECT Id FROM Profile WHERE Name = 'IFIS - Direzione Commerciale'];
        System.debug('@@@ recordTypeOppFactoring ' + recordTypeOppFactoring);
        System.debug('@@@ pFact ' + pFact);
        
        // creo utenti
        User dora = [SELECT Id, Name FROM User WHERE Alias = 'dora'];
        dora.UserRoleId = userRoleFactoring;
        dora.ProfileId = pFact.Id;
        dora.Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali';
        update dora;
        
        User doro = TestUtils.creaUtente('doro');
        doro.UserRoleId = userRoleFactoring;
        update doro;
        
        User doru = TestUtils.creaUtente('doru');
        doru.UserRoleId = userRoleFactoring;
        update doru;
        
        // Creo account
        Account acc = new Account(Name = 'Test1');
        System.runAs(dora) {
            System.debug('@Account: '+acc);
            insert acc;
        }
        
        // Account acc;
        // System.runAs(dora) {
        //   acc = WGC_AllDataFactory.createAccount(1).get(0);
        //   acc.OwnerId= dora.id;
        //   insert acc;
        // }
        
        // Creo opportunità
        Opportunity oppDaTrasferire = new Opportunity(Name = 'oppDaTrasferire', AccountId = acc.Id, StageName = 'In Lavorazione', CloseDate = Date.today().addDays(2), RecordTypeId = recordTypeOppFactoring);
        // Opportunity oppChiusa = new Opportunity(Name = 'oppChiusa', AccountId = acc.Id, StageName = 'In Lavorazione', CloseDate = Date.today().addDays(-2), RecordTypeId = recordTypeOppFactoring);
        Opportunity oppChiusa = new Opportunity(Name = 'oppChiusa', AccountId = acc.Id, StageName = 'In Lavorazione', CloseDate = Date.today().addDays(+1));
        Opportunity oppAltroOwner = new Opportunity(Name = 'oppAltroOwner', AccountId = acc.Id, StageName = 'In Lavorazione', CloseDate = Date.today().addDays(3));
        Opportunity[] opps = new Opportunity[]{oppDaTrasferire, oppAltroOwner};
            
            // Creo contatti
            Contact conDaTrasferire = new Contact(FirstName = 'conDaTrasferire', LastName = 'Test', AccountId = acc.Id);
        Contact conAltroOwner = new Contact(FirstName = 'conAltroOwner', LastName = 'Test', AccountId = acc.Id);
        
        Contact[] cons = new Contact[]{conDaTrasferire, conAltroOwner};
            
            System.debug('@@@ getQueries ' + Limits.getQueries());
        System.debug('@@@ dora ' + dora);
        
        Test.startTest();
        System.runAs(dora) {
            
            insert oppChiusa;
            oppChiusa.StageName = 'Persa';
            update oppChiusa;
            insert opps;
            insert cons;
            oppAltroOwner.OwnerId = doru.Id;
            update oppAltroOwner;
            conAltroOwner.OwnerId = doru.Id;
            update conAltroOwner;
        }
        
        // Test: trasferisco l'account all'utente "doro"
        
        System.runAs(dora) {
            result = TrgAccount.cambiaOwnerAccount(acc.Id, false, doro.Id, false);
        }
        // System.debug('@Result: '+result);
        
        // Controllo i risultati
        //acc = [SELECT OwnerId FROM Account WHERE Id = :acc.Id];
        //Map<String, SObject> oppByName = U.keyBy([SELECT Id, Name, OwnerId, Owner.Alias, StageName, IsClosed FROM Opportunity WHERE AccountId = :acc.Id], 'Name');
        
        /*System.assertEquals(doro.Id, acc.OwnerId);
System.assertEquals(doro.Id, oppByName.get('oppDaTrasferire').get('OwnerId'));
System.assertEquals(dora.Id, oppByName.get('oppChiusa').get('OwnerId'));
System.assertEquals(doru.Id, oppByName.get('oppAltroOwner').get('OwnerId'));*/
        
        //Map<String, SObject> conByName = U.keyBy([SELECT Id, FirstName, OwnerId, Owner.Alias FROM Contact WHERE AccountId = :acc.Id], 'FirstName');
        //System.assertEquals(doro.Id, conByName.get('conDaTrasferire').get('OwnerId'));
        //System.assertEquals(doru.Id, conByName.get('conAltroOwner').get('OwnerId'));
        //System.debug('@@@ getQueries ' + Limits.getQueries());
        Test.stopTest();
        
    }
    
    
    //copre il codice ma non lo testa
    @isTest static void testTrgAssociazioneInBaseCAP(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'A'];
        acc.Name = 'B';
        acc.ShippingPostalCode = 'ss';
        acc.BillingCity  = 'ss';
        acc.ShippingCity  = 'ss';
        acc.BillingState  = 'ss';
        acc.ShippingState  = 'ss';
        update acc;
        //System.assertNotEquals(acc.opFiloDiretto__c,null);
        //Test.startTest();
        System.debug('@@@ getQueries ' + Limits.getQueries());
        Test.stopTest();
    }
    
    //copre il codice ma non lo testa
    @isTest static void testAssegnazioneAnagraficaOperatoriNSA(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'A'];
        Funzionalita__c f = Funzionalita__c.getOrgDefaults();
        f.GestioneMutuoMCCNSA__c = true;
        update f;
        Test.startTest();
        Account b = new Account(
            Name = 'B',
            ShippingPostalCode = 'ss',
            BillingCity  = 'ss',
            ShippingCity  = 'ss',
            BillingState  = 'ss',
            ShippingState  = 'ss'
        );
        insert b;
        //Test.startTest();
        TrgAccount.assegnazioneAnagraficaOperatoriNSA(new Account[]{b});
        System.debug('@@@ getQueries ' + Limits.getQueries());
        Test.stopTest();
    }
    
    
    @isTest
    static void testNonCreaContattoTelefonico() {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'A'];
        a.Sottocanale__c = '101';
        a.Name = 'Pinco Pallino';
        update a;
        TrgAccount.creaContattoTelefonico(new T(new Account[]{a}, null));
    }
    
    
    @isTest
    static void testCreaContattoTelefonico() {
        Id userRoleFactoring = [SELECT Id FROM UserRole WHERE DeveloperName = 'CommercialeGenova'][0].Id;
        Profile pFact = [SELECT Id FROM Profile WHERE Name = 'IFIS - Direzione Commerciale'];
        User dora = [SELECT Id, Name, UserRole.Name FROM User WHERE Alias = 'dora'];
        dora.UserRoleId = userRoleFactoring;
        dora.ProfileId = pFact.Id;
        dora.Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali';
        update dora;
        
        //test sotto canale che crea task
        System.runAs(dora) {
            Account a = [SELECT Id FROM Account WHERE Name = 'A'];
            a.Sottocanale__c = '101';
            a.Name = 'Pinco Pallino';
            a.OwnerId = dora.Id;
            a.Sottocanale__c = '5';
            update a;
            TrgAccount.creaContattoTelefonico(new T(new Account[]{a}, null));
        }
    }
    
    @isTest
    public static void testAvvisaCambioAssegnazione() {
        Id userG = [SELECT Id FROM User WHERE alias = 'dora' LIMIT 1].Id;
        Account a = [SELECT Id, WGC_Specialista_Factoring__c FROM Account WHERE Name = 'A'];
        Test.startTest();
        a.WGC_Specialista_Factoring__c = userG;
        update a;
        Test.stopTest();
    }
    
    
}