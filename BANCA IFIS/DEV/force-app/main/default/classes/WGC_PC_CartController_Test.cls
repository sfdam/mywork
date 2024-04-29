@isTest
public class WGC_PC_CartController_Test {

		@TestSetup
		public static void setupDatiTest(){
      List<Account> ade = WGC_AllDataFactory.createAccount(1);
      ade[0].NDGGruppo__c = String.valueOf(Math.random()).substring(2,8);
      ade[0].NDGGruppoGiuridico__c = String.valueOf(Math.random()).substring(2,8);
      ade[0].WGC_NDG_controllante__c = String.valueOf(Math.random()).substring(2,8);
      insert ade;

      // WGC_AllDataFactory.createUtenzaDefault();
      UtenzeDefault__c utenza= new UtenzeDefault__c();
      utenza.IdUtente__c = UserInfo.getUserId();
      utenza.IdAgenziadelleEntrate__c = ade[0].Id;
      insert utenza;

			TestUtils.creaEndpointServizi();
			EndpointServizi__c es = EndpointServizi__c.getOrgDefaults();
			System.debug('@@@ es ' + JSON.serialize(es));
			//WGC_AllDataFactory.createLagKey();

			List<Opportunity> oppList = WGC_AllDataFactory.createOpportunity2(1);
			Insert oppList;
			List<Prodotto__c> prodsProc = WGC_AllDataFactory.createProdotti(1, false);
			prodsProc[0].CodiceUnivoco__c = 'ProceduraConcorsuale';
			Insert prodsProc;
			Linea__c lin = new Linea__c(Opportunity__c = oppList[0].Id, Prodotto__c = prodsProc[0].Id);
			Insert lin;
			List<Credito__c> crediti = WGC_AllDataFactory.createCrediti(1, oppList[0].Id, lin.Id);
			Insert crediti;
			List<NDGLinea__c> attList = WGC_AllDataFactory.createAttori2(1, false);
			attList[0].Account__c = WGC_PC_CartController.idAde;
			attList[0].Opportunita__c = oppList[0].Id;
			Insert attList;
		}

    @isTest
    public static void Test_Method1(){

        Test.startTest();
        WGC_PC_CartController.getUserInfo();
        WGC_PC_CartController.getProducts();
        Test.stopTest();
    }

    @isTest
    public static void test_creaAttore(){

				List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Name, StageName FROM Opportunity]);
        WGC_PC_CartController.CartPayload p = new WGC_PC_CartController.CartPayload();
        p.opportunityId = oppList[0].Id;
        p.joinLineaDeb = new WGC_PC_CartController.CartJoinLineaDebitore();
        p.joinLineaDeb.servizio = 'ProceduraConcorsuale';
        p.debitori = new List<WGC_PC_CartController.CartDebitore>();
        WGC_PC_CartController.CartDebitore d = new WGC_PC_CartController.CartDebitore();
        p.debitori.add(d);
        WGC_PC_CartController.MascheraPC fields = new WGC_PC_CartController.MascheraPC();
        fields.opp = oppList[0];

				Test.startTest();
        WGC_PC_CartController.createAttoreAgenzia(oppList[0].Id);
        // NDGLinea__c att = [SELECT Id, Account__c FROM NDGLinea__c WHERE Opportunita__c =: p.opportunityId AND Account__c =: WGC_PC_CartController.idAdE].get(0);
        delete [SELECT Id, Account__c FROM NDGLinea__c WHERE Opportunita__c =: p.opportunityId AND Account__c =: WGC_PC_CartController.idAdE].get(0);
        NDGLinea__c att = [SELECT Id, Account__c FROM NDGLinea__c WHERE Opportunita__c =: p.opportunityId AND Account__c =: WGC_PC_CartController.idAdE].get(0);
        System.debug('@@@ att2 ' + JSON.serialize([SELECT Id, Account__c, Account__r.Name FROM NDGLinea__c WHERE Opportunita__c =: p.opportunityId AND Account__c =: WGC_PC_CartController.idAdE]));
        // System.debug('@@@ att ' + JSON.serialize(att));
        fields.attore = att;
        p.debitori[0].id = att.Id;
        WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.saveSceltaProdotto(oppList[0].Id, JSON.serialize(fields), JSON.serialize(p));
        response = WGC_PC_CartController.getDatiMascheraPC(p.opportunityId);
        Test.stopTest();
    }

    @isTest
    public static void test_crediti(){				
				List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Name, StageName FROM Opportunity]);
				List<NDGLinea__c> attList = new List<NDGLinea__c>([SELECT id, Name, ANotifica__c, WGC_Storicita_Rimborsi__c FROM NDGLinea__c WHERE Account__c=:WGC_PC_CartController.idAde AND Opportunita__c =: oppList[0].Id]);
				List<Credito__c> crediti = new List<Credito__c>([SELECT Id, Name, WGC_Invia_Credito__c, toLabel(Imposta__c), toLabel(WGC_Origine__c), WGC_Ade_Territoriale__r.Name, 
																												ValoreNominale__c, WGC_Ruoli_Compens__c, WGC_Val_Nom_Esigibile__c, WGC_Prezzo_di_Acquisto__c,
																												WGC_Offerta_perc__c, WGC_Data_Presentazione_Rimborso__c, WGC_Data_Rimborso_Presunto__c,
																												WGC_Data_DSO__c, WGC_IRR_Perc__c, WGC_Data_Cessione_Credito__c, WGC_Esenzione_garanzia__c, WGC_Data_Richiesta_Rimborso__c,
																												WGC_Commissione_Acquisto__c
																												FROM Credito__c WHERE Opportunita__c =: oppList[0].Id ]);

        Test.startTest();
        WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.saveCrediti(oppList[0].Id, crediti);
        response = WGC_PC_CartController.saveSingleCredito(crediti[0]);
        response = WGC_PC_CartController.getCreditiLinea(oppList[0].Id);
        String rsp = WGC_PC_CartController.creaNotaPC(crediti);
        String rsp2 = WGC_PC_CartController.creaNotaBonis(crediti, attList[0]);
        WGC_PC_CartController.getCreditoInviato(crediti[0].Id);
        Test.stopTest();
    }

    @isTest
    public static void test_compensi(){
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());
				
				List<Credito__c> crediti = new List<Credito__c>([SELECT Id, Name FROM Credito__c]);

        Test.startTest();
        WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.callCalcolaCompensi(crediti[0].Id);
        Test.stopTest();
    }

    @isTest
    public static void test_dip(){
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());				
				List<Credito__c> crediti = new List<Credito__c>([SELECT Id, Name FROM Credito__c]);

        Test.startTest();
        WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.callCalcolaDIP(crediti[0].Id);
        Test.stopTest();
    }

    @isTest
    public static void test_Irr(){
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());				
				List<Credito__c> crediti = new List<Credito__c>([SELECT Id, Name FROM Credito__c]);

        Test.startTest();
        WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.callCalcolaIRR(crediti[0].Id);
        Test.stopTest();
    }

    @isTest
    public static void test_Interessi(){
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());
				List<Credito__c> crediti = new List<Credito__c>([SELECT Id, Name FROM Credito__c]);

        Test.startTest();
        WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.callCalcolaInteressi(crediti[0].Id);
        Test.stopTest();
    }

    @isTest
    public static void test_confermaTrattativa(){
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());
				List<Credito__c> crediti = new List<Credito__c>([SELECT Id, Name FROM Credito__c]);

        Test.startTest();
        WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.callConfermaTrattativa(crediti[0].Id);
        Test.stopTest();
    }

    @isTest
    public static void test_censimentoTrattativaPre(){
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());
				List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Name, StageName FROM Opportunity]);

        Test.startTest();
        WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.callCensimentoTrattativa(oppList[0].Id, 'pre');
        response = WGC_PC_CartController.callCensimentoTrattativa(oppList[0].Id, 'post');
        Test.stopTest();
    }

    @isTest
    public static void test_censimentoTrattativaPost(){
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());				
				List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Name, StageName FROM Opportunity]);

        Test.startTest();
        WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.callCensimentoTrattativa(oppList[0].Id, 'post');
        Test.stopTest();
    }

    @isTest
    public static void test_pef39FF(){
			Account acc = [SELECT Id, Name FROM Account LIMIT 1];
			Opportunity opp = [SELECT Id, Name, Tipologia_Opportunit__c FROM Opportunity LIMIT 1];
			opp.Tipologia_Opportunit__c = 'CONC';
			opp.WGC_Codice_Pratica__c = 2000;
			Update opp;

			// EndpointServizi__c es = EndpointServizi__c.getOrgDefaults();
			// es.WGC_Url_Dati_PEF_FF__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/clonedatipef';
			// Update es;
			// System.debug('@@@ es ' + JSON.serialize(es));

			Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
      Test.startTest();
      List<Credito__c> crediti = WGC_PC_CartController.getCreditiInviati(opp.Id);
      WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.callPEF39(acc.Id, opp.Id);
			Test.stopTest();
		}

		@isTest
    public static void test_pef41FF(){
      Account acc = [SELECT Id, Name, CodiceIstituto3N__c, NDGGruppo__c FROM Account LIMIT 1];
			Opportunity opp = [SELECT Id, Name, Tipologia_Opportunit__c, Account.CodiceIstituto3N__c, Account.NDGGruppo__c  FROM Opportunity LIMIT 1];
			opp.Tipologia_Opportunit__c = 'CONC';
      opp.WGC_Codice_Pratica__c = 2000;
      opp.AccountId = acc.Id;
      Update opp;
			// EndpointServizi__c es = EndpointServizi__c.getOrgDefaults();
			// es.WGC_Url_PEF41_FF__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/clonerinnovopef';
			// Update es;

			// EndpointServizi__c es = EndpointServizi__c.getOrgDefaults();
			// System.debug('@@@ es ' + JSON.serialize(es));

			Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
      User u = [SELECT Id, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
      u.NDGGruppo__c = '10000';
      update u;
			Test.startTest();
			WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.callPEF41(opp.Id);
			Test.stopTest();

      u.NDGGruppo__c = null;
      update u;
		}

    @isTest
    public static void test_HeaderCarrello(){
				List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Name, StageName FROM Opportunity]);

        Test.startTest();
        WGC_PC_CartController.openOpportunityFF(oppList[0].Id);
        WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.getDatiIRR(oppList[0].Id);
        response = WGC_PC_CartController.getDatiCostoNotaio();
        Test.stopTest();
    }

    @isTest
    public static void test_utilityMethod(){				
        Insert new WGC_AdE_Territoriale__c(Name = 'TestAdE');
        Test.startTest();
        //Lookup Method
        List<LookupSearchResult> searchRes1 = WGC_PC_CartController.search('Test', 'Account', new String[]{}, 'WHERE RecordType.DeveloperName != \'WGC_Tribunale\'');
        List<LookupSearchResult> searchRes2 = WGC_PC_CartController.search('TestAdE', 'WGC_AdE_Territoriale__c', new String[]{'Name'}, '');
        List<LookupSearchResult> searchRes3 = WGC_PC_CartController.search('Admin', 'User', new String[]{'Name'}, '');
        //Picklist Method
        WGC_PC_CartController.WrapperResponse response = WGC_PC_CartController.getPicklists('Opportunity', new String[]{'StageName'});
        response = WGC_PC_CartController.getPicklists('Credito__c', new String[]{'Imposta__c'});
        Test.stopTest();
    }

    @isTest
    static void dummyOrExceptionTest(){

      // Account acc = [SELECT Id FROM Account LIMIT 1];
      Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity;
      Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByDeveloperName();
      Schema.RecordTypeInfo rtByName =  rtMapByName.get('IFISOpportunitaFastFinance');

      // Opportunity opp1 = new Opportunity(AccountId = acc.Id, StageName = 'In Istruttoria', RecordTypeId = rtByName.getRecordTypeId());
      // insert opp1;

      List<Account> accounts = WGC_AllDataFactory.createAccount(1);
      for(Account a : accounts){
        a.NaturaGiuridica__c = 'AAA';
        a.Ateco__c = 'TestAteco';
        a.SAE__c = '100';
        a.REA__c = '123';
        a.BillingCity__c = 'Milano';
        a.BillingCountry__c = 'Italia';
        a.BillingPostalCode__c = '20142';
        a.BillingStreetNumber__c = '12';
        a.BillingState__c = 'Lombardia';
        a.BillingStreetName__c = 'Vittorio Emanuele';
        a.BillingStreetType__c = 'VIA';
        a.NDGGruppo__c = '255783';
        a.NDGGruppoGiuridico__c = '3239032';
        a.WGC_NDG_controllante__c = '893574';
      }

      insert accounts;
    
      List<Opportunity> oppList = WGC_AllDataFactory.createOpportunity2(1);
      oppList[0].RecordTypeId = rtByName.getRecordTypeId();
      oppList[0].AccountId = accounts[0].Id;
      insert oppList;

      Test.startTest();
        WGC_PC_CartController.getDatiMascheraPC(null);
        WGC_PC_CartController.createAttoreAgenzia(null);
        WGC_PC_CartController.saveSceltaProdotto(null, JSON.serialize(new WGC_PC_CartController.MascheraPC()), JSON.serialize(new WGC_PC_CartController.CartPayload()));
        WGC_PC_CartController.saveCrediti(null, null);
        WGC_PC_CartController.saveSingleCredito(null);
        WGC_PC_CartController.getDatiIRR(null);
        WGC_PC_CartController.getCreditiLinea(null);
        WGC_PC_CartController.callPEF39(null, null);
        WGC_PC_CartController.noteAutomaticheHTML(oppList[0].Id);
        WGC_PC_CartController.getPicklists(null, null);
        WGC_PC_CartController.callCalcolaCompensi(null);
        WGC_PC_CartController.callCalcolaIRR(null);
        WGC_PC_CartController.callCalcolaDIP(null);
        WGC_PC_CartController.callCalcolaInteressi(null);
        WGC_PC_CartController.callConfermaTrattativa(null);
      Test.stopTest();
    }
}