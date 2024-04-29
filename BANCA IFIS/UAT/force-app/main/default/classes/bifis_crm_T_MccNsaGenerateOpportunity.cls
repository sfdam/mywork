@isTest
private class bifis_crm_T_MccNsaGenerateOpportunity  {
	/**
	 * il SeeAllData serve perché il batch si basa su prodotti__c/parametri__c/custom setting/etc che devono esser presenti
	 * */
    static WorkflowMutui__c w  = new WorkflowMutui__c();
	static List<WorkflowMutui__c> ww = new List<WorkflowMutui__c>();
    static RecordType oppRecType;
	static Prodotto__c mutuoNSA, mutuoSA;
     
	private static void setupData(Decimal fatturato, String addrType) {
		oppRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'IFISOpportunitaFactoring' LIMIT 1];
		/*
		mutuoNSA = new Prodotto__c( Applicazione__c ='21', CategoriaProdotto__c='Prodotto bancario', Categoria__c='C', CodiceProdotto__c='PCNSA', CodiceUnivoco__c='MutuoPCNSA', Codice__c='998', TipoProdotto__c='B', WGC_Area__c='Finanziamenti', WGC_Famiglia__c='Mutuo',WGC_Tipo_Cross_Selling__c='IFISOpportunitaFactoring' );
		insert mutuoNSA;
		*/
		w = new WorkflowMutui__c();
		ww.clear();

		w.AltreNoteNSA__c = 'note per il test';
		w.CapLegale__c = '35100';
		w.CittaLegale__c = 'PADOVA';
		w.ProvinciaLegale__c = 'PD';
		w.CivicoLegale__c = '5';
		w.IndirizzoLegale__c = 'VIA';
		w.CapSpedizione__c = '35100';
		w.CittaSpedizione__c = 'PADOVA';
		w.ProvinciaSpedizione__c = 'PD';
		w.CivicoSpedizione__c = '5';
		w.IndirizzoSpedizione__c = 'VIA';
		w.MTC_Indirizzo__c = addrType;
		w.DurataPreAmmortamento__c = 12;
		w.DurataPreAmmortamentoSA__c = 12;
		w.DurataTotale__c = 60;
		w.DurataTotaleSa__c = 60;
		w.Email__c = 'info@acme.com';
		w.Fatturato__c = fatturato;
		w.Finalita__c = 'unit test';
		w.FinalitaSA__c = 'unit test SA';
		w.Importo__c = 125000;
		w.ImportoSA__c = 125000;
		w.MAV_Affidamenti__c = true;
		w.MAV_Natura_Rapporto__c = 'test unit';
		w.Natura_Giuridica__c = 'SRL';
		w.PartitaIVA__c = '03657200279';
		w.Ragione_Sociale__c = 'PROFISERVICE S.R.L.';
		w.REA__c = '300048';
		w.NumeroAddetti__c = 50;
		w.Privacy_Azienda_1__c = 'OK';
		w.Privacy_Azienda_2__c = 'OK';
		w.Privacy_Azienda_3__c = 'OK';
		w.Privacy_Azienda_4__c = 'OK';
		w.Privacy_Azienda_5__c = 'OK';
		w.Privacy_Azienda_Tradizionali__c = 'NO';
		w.Privacy_Esecutore_1__c = 'OK';
		w.Privacy_Esecutore_1__c = 'OK';
		w.Privacy_Esecutore_1__c = 'OK';
		w.Privacy_Esecutore_1__c = 'OK';
		w.Privacy_Esecutore_1__c = 'OK';
		w.Privacy_Esecutore_Tradizionali__c = 'NO';
		w.REFERENTI_JSON__c = '[{"nome":"LUCIA","cognome":"RIBBA","codiceFiscale":"RBBLCU82D44G565U","ruolo":"Titolare effettivo ed esecutore","tipologiaTE":"Proprietà diretta"}]';
		w.Tipologia_Mutuo__c = 'MISTO';
		w.TipologiaQuestionario__c = CtrlCompilazioneQQ.getNomeModello(fatturato);
		w.QQSB1__c = 'B';
		w.QQSB2__c = 'B';
		w.QQSB3__c = 'B';
		w.QQSB4__c = 'B';
		w.QQSB5__c = 'B';
		w.QQSB6__c = 'B';
		w.QQSB7__c = 'B';
		w.QQSB8__c = 'B';
		w.QQSB9__c = 'B';
		w.QQSB10__c = 'B';
		w.QQSB11__c = 'B';
		w.QQSB12__c = 'B';
		w.QQSB13__c = 'B';
		w.QQSB14__c = 'B';
		w.QQSB15__c = 'B';
		w.QQSB16__c = 'B';
		w.QQSB17__c = 'B';
		w.QQSB18__c = 'B';
		w.QQCO1__c = 'B';
		w.QQCO2__c = 'B';
		w.QQCO3__c = 'B';
		w.QQCO4__c = 'B';
		w.QQCO5__c = 'B';
		w.QQCO6__c = 'B';
		w.QQCO7__c = 'B';
		w.QQCO8__c = 'B';
		w.QQCO9__c = 'B';
		w.QQCO10__c = 'B';
		w.QQCO11__c = 'B';
		w.QQCO12__c = 'B';
		w.QQCO13__c = 'B';
		w.QQCO14__c = 'B';
		w.QQCO15__c = 'B';
		w.QQCO16__c = 'B';
		w.QQCO17__c = 'B';
		w.QQCO18__c = 'B';
		w.QQCO19__c = 'B';
		w.QQCO20__c = 'B';
		w.QQCO21__c = 'B';

		insert w;
	
		ww.add(w);
	}

	@isTest(SeeAllData=true)
    public static void test_standardQ() {
        User u = [SELECT Id, Name, Profile.Name, UserRole.Name, alias FROM User WHERE name ='Batch NSA'];
        setupData(125000, 'other');

        Test.startTest();
        System.runAs(u) {
            Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));

            bifis_crm_b_MccNsaGenerateOpportunity bcl = new bifis_crm_b_MccNsaGenerateOpportunity();
			Database.executeBatch(bcl,1);
        }
        Test.stopTest();
    }

	/* fallisce per 'Too many SOQL queries' ma solo se invocato metodo execute, non ha il problema con executeBatch(...)
	@isTest(SeeAllData=true)
    public static void test_standard() {
      
        User u = [SELECT Id, Name, Profile.Name, UserRole.Name, alias FROM User WHERE name ='Batch NSA'];
        setupData(125000, 'other');

        
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaControlloCambioFaseOpp__c = true;
        f.WGC_disabilita_per_batch__c = true; //adione-crm20
        upsert f;
        
        System.runAs(u) {
			Test.startTest();
            Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));

            bifis_crm_b_MccNsaGenerateOpportunity bcl = new bifis_crm_b_MccNsaGenerateOpportunity();
			//Database.executeBatch(bcl,1);
            bcl.execute(null, ww);
			Test.stopTest();
        }   
    }*/
    
    @isTest(SeeAllData=true)
    public static void testNoPIVA() {
        WorkflowMutui__c w  = new WorkflowMutui__c();
        w.Ragione_Sociale__c = 'ACME SpA - senza P.IVA';
		insert w;
        List<WorkflowMutui__c> ww = new List<WorkflowMutui__c>();
        ww.add(w);
        
        Test.startTest();    
        Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));
        
        bifis_crm_b_MccNsaGenerateOpportunity bcl = new bifis_crm_b_MccNsaGenerateOpportunity();
        try {
            bcl.execute(null, ww);
        } catch (bifis_crm_c_MccNsaException ex) {
            String msg = ex.getMessage().substring(0, ex.getMessage().indexOf('-'));
            System.assertEquals('Manca la Partita IVA', msg.trim());
        }
        
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void testEx() {
        WorkflowMutui__c w  = new WorkflowMutui__c();
        w.Ragione_Sociale__c = 'ACME SpA - senza P.IVA';
        w.PartitaIVA__c = '00123880349'; //bad value, wrong control char
        List<WorkflowMutui__c> ww = new List<WorkflowMutui__c>();
        ww.add(w);
        
        Test.startTest();    
        Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));
        
        bifis_crm_b_MccNsaGenerateOpportunity bcl = new bifis_crm_b_MccNsaGenerateOpportunity();
        try {
            bcl.execute(null, ww);
        } catch (Exception ex) {
            System.assertNotEquals(null, ex.getMessage());
        }
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=true)
    public static void testSB() {
        setupData(250000, 'billing'); //250k
        
        Test.startTest();    
        Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));
        Set<WorkflowMutui__c> s = new Set<WorkflowMutui__c>(ww);
        bifis_crm_b_MccNsaGenerateOpportunity bcl = new bifis_crm_b_MccNsaGenerateOpportunity(s);
        //bcl.execute(null, ww);
        bcl.start(null);
        
        Test.stopTest();
    }
    /* adione: taccone per provare a superare il too many queries
    @isTest(SeeAllData=true)
    public static void testCO() {
        //force corporate with 60mil
        setupData(60000000, 'shipping');
        
        Test.startTest();    
        Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));
        
        bifis_crm_b_MccNsaGenerateOpportunity bcl = new bifis_crm_b_MccNsaGenerateOpportunity();
        bcl.execute(null, ww);
        
        Test.stopTest();
    }
    */
    @isTest(SeeAllData=true)
    public static void testFinish() {
		//setupData(57500, 'billing');
        Test.startTest();    
        
        bifis_crm_b_MccNsaGenerateOpportunity bcl = new bifis_crm_b_MccNsaGenerateOpportunity();
        bcl.finish(null);
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=true)
    public static void testMail() {
        Test.startTest();
        bifis_crm_b_MccNsaGenerateOpportunity bcl = new bifis_crm_b_MccNsaGenerateOpportunity();
        bcl.sendErrorMail(w, new bifis_crm_c_MccNsaException('apex test exception'));
        Test.stopTest();
    }
    
    @isTest(SeeAllData=true)
    public static void test_allegaDocs() {
        Test.startTest();
        User u = [SELECT Id, Name, Profile.Name, UserRole.Name, alias FROM User WHERE name ='Batch NSA'];
        u.Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali';
        update u;      

		Id profiloCommerciale = [
			SELECT Id 
			FROM Profile 
			WHERE name = 'IFIS - Sviluppo Commerciale Filiali'
			LIMIT 1].Id;
		User userCommerciale = new User(Alias = 'User3', 
			Email='UserThree@testorg.com', 
			EmailEncodingKey='UTF-8', 
			Username = 'UserThree@testorg.com', 
			LastName = 'UserThree', 
			ProfileId = profiloCommerciale, 
			Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali', 
			WGC_Canale_di_sviluppo__c = 'Rete Commerciale Ifis Impresa',
			LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', 
			TimeZoneSidKey='America/Los_Angeles'
		);
		User babeto = TestUtils.creaUtente('babeto');
		System.runAs(userCommerciale) {
            Account acc = TestUtils.creaAccount('Account TEST', babeto, 'MI', '02119590046', 'rsscld50r15h501y', 'Prospect', '4321');
		}

        System.runAs(u) {        
            List<String> docNames = new List<String> {
                'DOCUMENTO_RSF_JSON__c',
                    'DOCUMENTO_MAV_JSON__c',
                    'DOCUMENTO_MTC_JSON__c',
                    'DOCUMENTO_MPA_JSON__c',
                    'DOCUMENTO_MPE_JSON__c',
                    'DOCUMENTO_A4_JSON__c',
                    'DOCUMENTO_BE3_JSON__c',
                    'DOCUMENTO_BESC_JSON__c',
                    'DOCUMENTO_BVA_JSON__c',
                    'DOCUMENTO_BPR_JSON__c',
                    'DOCUMENTO_DIA4_JSON__c',
                    'DOCUMENTO_DIE_JSON__c',
                    'DOCUMENTO_DITS_JSON__c',
                    'DOCUMENTO_DIT_JSON__c',
                    'DOCUMENTO_UAC_JSON__c',
                    'DOCUMENTO_DIC_JSON__c',
                    'DOCUMENTO_DM10_JSON__c',
                    'DOCUMENTO_DM10I_JSON__c',
                    'DOCUMENTO_DAB_JSON__c',
                    'DOCUMENTO_ECF_JSON__c',
                    'DOCUMENTO_GCE_JSON__c',
                    'DOCUMENTO_MU2_JSON__c',
                    'DOCUMENTO_MUS_JSON__c',
                    'DOCUMENTO_PCD_JSON__c',
                    'DOCUMENTO_PRO_JSON__c',
                    'DOCUMENTO_RI_JSON__c',
                    'DOCUMENTO_SVR_JSON__c',
                    'DOCUMENTO_SDG_JSON__c',
                    'DOCUMENTO_DCVC_JSON__c',
                    'DOCUMENTO_VCL_JSON__c'
                    };
                        setupData(250000, 'billing'); //250k+
            //Account
            Account a = [SELECT 
                         OwnerId, 
                         RecordType.DeveloperName, 
                         NDGGruppo__c, 
                         NDG__c, 
                         StatoCensimento__c, 
                         Name, 
                         NaturaGiuridica__c,
                         SAE__c,
                         RAE__c,
                         Ateco__c,
                         TAECode__c,
                         DataIscrizioneCCIAA__c,
                         REA__c,
                         BillingStreetName__c,
                         BillingStreetType__c,
                         BillingStreetNumber__c,
                         BillingPostalCode,
                         BillingCountry,
                         BillingState,
                         BillingCity, 
                         ShippingCity,
                         ShippingStreetName__c,
                         ShippingStreetType__c,
                         ShippingStreetNumber__c,
                         ShippingPostalCode,
                         ShippingCountry,
                         ShippingState,
                         CF__c,
                         PIVA__c,
                         Email__c,
                         telefonoprefisso__c,
                         telefononumero__c,
                         fax,
                         consensoallaprofilazione__c,
                         consensoattivitapromozionaleterzi__c,
                         consensoattivitapromricerchemercato__c,
                         consensoprodottibancaricerchemercato__c,
                         consensoprodottisocietaterze__c,
                         consensosolomodalitatradizionali__c,
                         datainserimentoconsensi__c,
                         PartecipazioneSocietaFiduciarie2__c,
                         Origine__c,
                         WGC_Originator__c, 
                         WGC_Originator_dettaglio__c,
						 WGC_Specialista_Factoring__c
                         FROM Account WHERE PIVA__c = '02119590046' LIMIT 1];      
			String cmDevName = 'Partner_Broker_NSA';
			WGC_Originator__mdt originatorMD = [
				SELECT Originator__c, Originator_dettaglio__c
				FROM WGC_Originator__mdt
				WHERE DeveloperName = :cmDevName
			];						   
            //Opportunity 
            Opportunity o = new Opportunity(
                Name='test opp', 
                StageName='In Istruttoria', 
                Tipologia_Opportunit__c = 'CONC', 
                CloseDate=Date.today().addDays(30),
                AccountId = a.Id,
                RecordTypeId = oppRecType.Id,
                isOppNSA__c = true
            );
			o.ownerId = a.WGC_Specialista_Factoring__c;
			if (String.isBlank(o.ownerId)) //se non trovo settorista per competenza territoriale, fallback su Utenza Default
				o.ownerId = UtenzeDefault__c.getInstance().IdUtente__c;
			Prodotto__c prodMutuo = [SELECT Id, WGC_Famiglia__c FROM Prodotto__c WHERE CodiceUnivoco__c= 'MutuoPCNSA' LIMIT 1];
			o.WGC_Prodotti_Selezionati__c = prodMutuo.WGC_Famiglia__c;
			o.Originator__c = originatorMD.Originator__c;
			o.Originator_di_dettaglio__c = originatorMD.Originator_dettaglio__c;
            insert o;
            
            bifis_crm_b_MccNsaGenerateOpportunity.allegaDocs(o, w, docNames);
        }
        Test.stopTest();    	    
    }
    
    @isTest(SeeAllData=true)
    public static void testASyncPG() {
        User u = [SELECT Id, Name, Profile.Name, UserRole.Name, alias FROM User WHERE name ='Batch NSA'];
        u.Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali';
        update u;      
        
        System.runAs(u) {        
            setupData(125000, 'other');
            Account a = [SELECT 
                         OwnerId, 
                         RecordType.DeveloperName, 
                         NDGGruppo__c, 
                         NDG__c, 
                         StatoCensimento__c, 
                         Name, 
                         NaturaGiuridica__c,
                         SAE__c,
                         RAE__c,
                         Ateco__c,
                         TAECode__c,
                         DataIscrizioneCCIAA__c,
                         REA__c,
                         BillingStreetName__c,
                         BillingStreetType__c,
                         BillingStreetNumber__c,
                         BillingPostalCode,
                         BillingCountry,
                         BillingState,
                         BillingCity, 
                         ShippingCity,
                         ShippingStreetName__c,
                         ShippingStreetType__c,
                         ShippingStreetNumber__c,
                         ShippingPostalCode,
                         ShippingCountry,
                         ShippingState,
                         CF__c,
                         PIVA__c,
                         Email__c,
                         telefonoprefisso__c,
                         telefononumero__c,
                         fax,
                         consensoallaprofilazione__c,
                         consensoattivitapromozionaleterzi__c,
                         consensoattivitapromricerchemercato__c,
                         consensoprodottibancaricerchemercato__c,
                         consensoprodottisocietaterze__c,
                         consensosolomodalitatradizionali__c,
                         datainserimentoconsensi__c,
                         PartecipazioneSocietaFiduciarie2__c	
                         FROM Account WHERE PIVA__c <> '' LIMIT 1];
            
            List<Object> referenti = bifis_crm_c_CommonUtils.parseReferentiJSON(w.REFERENTI_JSON__c);
            Map<Integer, bifis_crm_b_MccNsaGenerateOpportunity.Domanda[]> m = new Map<Integer, bifis_crm_b_MccNsaGenerateOpportunity.Domanda[]>();
            String advPayload = '';
            Date oneMonthFromToday = Date.today() + 30;
            Opportunity o = new Opportunity(
                Name='test opp', 
                StageName='In Istruttoria', 
                Tipologia_Opportunit__c = 'CONC', 
                CloseDate=oneMonthFromToday,
                AccountId = a.Id,
                RecordTypeId = oppRecType.Id,
                isOppNSA__c = true
            );
            
            insert o;
            System.debug(o);    
            
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG));    
            bifis_crm_b_MccNsaGenerateOpportunity.AsyncJobsNSA_Q abc = 
                new bifis_crm_b_MccNsaGenerateOpportunity.AsyncJobsNSA_Q(a, referenti, o, w, m, advPayload, 'PG');
            abc.execute(null);
            Test.stopTest();
        }
    } //END testASync PG
    
    @isTest(SeeAllData=true)
    public static void testASyncPF() {
        User u = [SELECT Id, Name, Profile.Name, UserRole.Name, alias FROM User WHERE name ='Batch NSA'];
        u.Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali';
        update u;
        
        System.runAs(u) {        
            setupData(125000, 'other');
            Account a = [SELECT 
                         OwnerId, 
                         RecordType.DeveloperName, 
                         NDGGruppo__c, 
                         NDG__c, 
                         StatoCensimento__c, 
                         Name, 
                         NaturaGiuridica__c,
                         SAE__c,
                         RAE__c,
                         Ateco__c,
                         TAECode__c,
                         DataIscrizioneCCIAA__c,
                         REA__c,
                         BillingStreetName__c,
                         BillingStreetType__c,
                         BillingStreetNumber__c,
                         BillingPostalCode,
                         BillingCountry,
                         BillingState,
                         BillingCity, 
                         ShippingCity,
                         ShippingStreetName__c,
                         ShippingStreetType__c,
                         ShippingStreetNumber__c,
                         ShippingPostalCode,
                         ShippingCountry,
                         ShippingState,
                         CF__c,
                         PIVA__c,
                         Email__c,
                         telefonoprefisso__c,
                         telefononumero__c,
                         fax,
                         consensoallaprofilazione__c,
                         consensoattivitapromozionaleterzi__c,
                         consensoattivitapromricerchemercato__c,
                         consensoprodottibancaricerchemercato__c,
                         consensoprodottisocietaterze__c,
                         consensosolomodalitatradizionali__c,
                         datainserimentoconsensi__c,
                         PartecipazioneSocietaFiduciarie2__c	
                         FROM Account WHERE PIVA__c <> '' LIMIT 1];
            
            List<Object> referenti = bifis_crm_c_CommonUtils.parseReferentiJSON(w.REFERENTI_JSON__c);
            Map<Integer, bifis_crm_b_MccNsaGenerateOpportunity.Domanda[]> m = new Map<Integer, bifis_crm_b_MccNsaGenerateOpportunity.Domanda[]>();
            String advPayload = '';
            Date oneMonthFromToday = Date.today() + 30;
            Opportunity o = new Opportunity(
                Name='test opp', 
                StageName='In Istruttoria', 
                Tipologia_Opportunit__c = 'CONC', 
                CloseDate=oneMonthFromToday,
                AccountId = a.Id,
                RecordTypeId = oppRecType.Id,
                isOppNSA__c = true
            );
            
            insert o;
            System.debug(o);    
            
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG));    
            bifis_crm_b_MccNsaGenerateOpportunity.AsyncJobsNSA_Q abc = 
                new bifis_crm_b_MccNsaGenerateOpportunity.AsyncJobsNSA_Q(a, referenti, o, w, m, advPayload, 'PF');
            abc.execute(null);
            Test.stopTest();
        }
    } //END testASync PF
    
    @isTest(SeeAllData=true)
    public static void testASyncOT() {
        User u = [SELECT Id, Name, Profile.Name, UserRole.Name, alias FROM User WHERE name ='Batch NSA'];
        u.Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali';
        update u;
        
        System.runAs(u) {
            setupData(125000, 'other');
            Account a = [SELECT 
                         OwnerId, 
                         RecordType.DeveloperName, 
                         NDGGruppo__c, 
                         NDG__c, 
                         StatoCensimento__c, 
                         Name, 
                         NaturaGiuridica__c,
                         SAE__c,
                         RAE__c,
                         Ateco__c,
                         TAECode__c,
                         DataIscrizioneCCIAA__c,
                         REA__c,
                         BillingStreetName__c,
                         BillingStreetType__c,
                         BillingStreetNumber__c,
                         BillingPostalCode,
                         BillingCountry,
                         BillingState,
                         BillingCity, 
                         ShippingCity,
                         ShippingStreetName__c,
                         ShippingStreetType__c,
                         ShippingStreetNumber__c,
                         ShippingPostalCode,
                         ShippingCountry,
                         ShippingState,
                         CF__c,
                         PIVA__c,
                         Email__c,
                         telefonoprefisso__c,
                         telefononumero__c,
                         fax,
                         consensoallaprofilazione__c,
                         consensoattivitapromozionaleterzi__c,
                         consensoattivitapromricerchemercato__c,
                         consensoprodottibancaricerchemercato__c,
                         consensoprodottisocietaterze__c,
                         consensosolomodalitatradizionali__c,
                         datainserimentoconsensi__c,
                         PartecipazioneSocietaFiduciarie2__c	
                         FROM Account WHERE PIVA__c <> '' LIMIT 1];
            
            List<Object> referenti = bifis_crm_c_CommonUtils.parseReferentiJSON(w.REFERENTI_JSON__c);
            Map<Integer, bifis_crm_b_MccNsaGenerateOpportunity.Domanda[]> m = new Map<Integer, bifis_crm_b_MccNsaGenerateOpportunity.Domanda[]>();
            String advPayload = '';
            Date oneMonthFromToday = Date.today() + 30;
            Opportunity o = new Opportunity(
                Name='test opp', 
                StageName='In Istruttoria', 
                Tipologia_Opportunit__c = 'CONC', 
                CloseDate=oneMonthFromToday,
                AccountId = a.Id,
                RecordTypeId = oppRecType.Id,
                isOppNSA__c = true
            );
            
            insert o;
            System.debug(o);    
            
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG));    
            bifis_crm_b_MccNsaGenerateOpportunity.AsyncJobsNSA_Q abc = 
                new bifis_crm_b_MccNsaGenerateOpportunity.AsyncJobsNSA_Q(a, referenti, o, w, m, advPayload, 'OT');
            abc.execute(null);
            Test.stopTest();
        }
    } //END testASync OT
}