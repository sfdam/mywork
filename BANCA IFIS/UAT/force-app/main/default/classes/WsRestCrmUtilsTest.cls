@IsTest
private class WsRestCrmUtilsTest {

  public static String VALORE_SF16 = '300';
  public static String VALORE_SF17 = '150';
  public static String VALORE_SF19 = '0007';
  public static String VALORE_DBC = '1234';
  public static String VALORE_DBCSCAG = '5678';

  @testSetup
  static void testSetup() {

    WGC_AllDataFactory.createUtenzaDefault();

    TestUtils.impostaCS();

    // creo azienda e referenti
    Account accountFEG = new Account(
      Name = 'FEG SOCIETA PER AZIONI',
      BillingStreet = 'CORSO RE UMBERTO 1',
      BillingCity = 'TORINO',
      BillingState = 'TO',
      BillingPostalCode = '10121',
      CF__c = '10798070016',
      NDGGruppo__c = '123456'
    );
    insert accountFEG;
    accountFEG.Filiale__c = '5';
    update accountFEG;

    UtenzeDefault__c u = UtenzeDefault__c.getOrgDefaults();
    u.IdGaranteDefaultMutuoControgarantitoMCC__c = accountFEG.Id + ';' + accountFEG.Id;
    Update u;

    Contact referenteMarioBalo = TestUtils.creaReferente(accountFEG, 'BLAMRA80A01F205X', 'Mario', 'Balo', '123123');
    Contact referenteMariaBala = TestUtils.creaReferente(accountFEG, 'BLAMRA80A41F205B', 'Maria', 'Bala', '321321');

    // creo opportunita' e prodotti/linee
    // Opportunity oppFEG = TestUtils.CreaOpportunity(accountFEG, 'opportunitaFEG');

    // prova
    Opportunity oppFEG = WGC_AllDataFactory.createOpportunity2(1).get(0);
    oppFEG.Name = 'opportunitaFEG';
    oppFEG.AccountID = accountFEG.Id;
    oppFEG.Owner = accountFEG.Owner;
    insert oppFEG;

    
    Prodotto__c prodottoPCDFO = TestUtils.creaProdottoPCDFO();
    Prodotto__c prodottoPPIIM = TestUtils.creaProdottoPPIIM();
	Prodotto__c prodottoPCMCC = TestUtils.creaProdottoPCMCC();
	Prodotto__c prodottoPCFFD = TestUtils.creaProdottoPCFFD();
	Prodotto__c prodottoPCFII = TestUtils.creaProdottoPCFII();
	Prodotto__c prodottoPCVSI = TestUtils.creaProdottoPCVSI();
	

    Linea__c lineaPCDFO = new Linea__c(
      Prodotto__c = prodottoPCDFO.Id,
      Opportunity__c = oppFEG.Id,
      DivisaNew__c = '242'
    );
    insert lineaPCDFO;

    Linea__c lineaPCBII = new Linea__c(
      Prodotto__c = prodottoPPIIM.Id,
      Opportunity__c = oppFEG.Id,
      DivisaNew__c = '242'
    );
    insert lineaPCBII;

	Linea__c lineaPCMCC = new Linea__c(
      Prodotto__c = prodottoPCMCC.Id,
      Opportunity__c = oppFEG.Id,
      DivisaNew__c = '242'
    );
    insert lineaPCMCC;

	Linea__c lineaPCFFD = new Linea__c(
      Prodotto__c = prodottoPCFFD.Id,
      Opportunity__c = oppFEG.Id,
      DivisaNew__c = '242'
    );
    insert lineaPCFFD;

	Linea__c lineaPCFII = new Linea__c(
      Prodotto__c = prodottoPCFII.Id,
      Opportunity__c = oppFEG.Id,
      DivisaNew__c = '242'
    );
    insert lineaPCFII;

	Linea__c lineaPCVSI = new Linea__c(
      Prodotto__c = prodottoPCVSI.Id,
      Opportunity__c = oppFEG.Id,
      DivisaNew__c = '242'
    );
    insert lineaPCVSI;

    // creo attori e relazioni
    NDGLinea__c debitore = TestUtils.CreaNDGLineaDebitore(referenteMarioBalo, oppFeg);
    debitore.DivisaNew__c = '242';
    debitore.Fatturato__c = 800000;
    debitore.DiCuiProsoluto__c = 50000;
    debitore.Plafond__c = 400000;
    debitore.DurataNominale__c = 15;
	debitore.Linea__c = lineaPCDFO.Id;
    upsert debitore;

	NDGLinea__c debitoreAdE = TestUtils.CreaNDGLineaDebitore(referenteMarioBalo, oppFeg);
    debitoreAdE.DivisaNew__c = '242';
	debitoreAdE.Linea__c = lineaPCFFD.Id;
    upsert debitoreAdE;

    NDGLinea__c garanteOmnibus = new NDGLinea__c(
      Contact__c = referenteMariaBala.Id,
      Opportunita__c = oppFEG.Id,
      DivisaNew__c = '242',
      Fatturato__c = 20000,
      DiCuiProsoluto__c = 10000,
      Plafond__c = 1000,
      DurataNominale__c = 10
    );
    insert garanteOmnibus;

    NDGLinea__c esecutoreAdeguataVerifica = new NDGLinea__c(
      Opportunita__c = oppFEG.Id,
      Account__c = accountFEG.Id,
      Tipo__c = 'Esecutore adeguata verifica'
    );
    insert esecutoreAdeguataVerifica;

    JoinLineaDebitore__c joinLineaDebitore = new JoinLineaDebitore__c(
      Linea__c = lineaPCDFO.Id,
      Debitore__c = debitore.Id,
      Opportunita__c = oppFEG.Id,
      DebitoreProsoluto__c = true
    );
    insert joinLineaDebitore;

	JoinLineaDebitore__c joinLineaDebitoreFFD = new JoinLineaDebitore__c(
      Linea__c = lineaPCFFD.Id,
      Debitore__c = debitoreAdE.Id,
      Opportunita__c = oppFEG.Id,
      DebitoreProsoluto__c = false
    );
    insert joinLineaDebitoreFFD;

    // creo parametri
	TestUtils.creaParametro(false, 'CDA02_1052', 'Percentuale', 'Condizione conto');
    TestUtils.creaPConfigurato('CDA02_1052', '3.15', '3.15', lineaPCBII.Id, null, 'Condizione conto');

    TestUtils.creaParametro(false, '050', 'Percentuale', null);
    TestUtils.creaPConfigurato('050', '80', '80', lineaPCDFO.Id, null, null);

    TestUtils.creaParametro(false, 'C165', 'Percentuale', 'Condizione economica');
    TestUtils.creaPConfigurato('C165', '65', '65', lineaPCDFO.Id, null, null);

    TestUtils.creaParametro(false, 'SF6', 'Importo', 'Parametro linea');
    TestUtils.creaPConfigurato('SF6', '200000', '0', lineaPCDFO.Id, null, null);

	TestUtils.creaParametro(false, 'SF25', 'Numero', 'Parametro linea');
    TestUtils.creaPConfigurato('SF25', '200000', '0', lineaPCDFO.Id, debitore.Id, null);

	TestUtils.creaParametro(false, 'SF26', 'Numero', 'Parametro linea');
    TestUtils.creaPConfigurato('SF25', '200000', '0', lineaPCDFO.Id, debitore.Id, null);

    TestUtils.creaParametro(false, '008', 'Picklist', 'Parametro nascosto');
    insert WsRestCrmUtils.creaMockParametro008(lineaPCDFO, '60');

    TestUtils.creaParametro(false, 'SF6', 'Importo', 'Parametro linea');
    TestUtils.creaPConfigurato('SF6', '250000', '0', lineaPCFFD.Id, null, null);

    TestUtils.creaParametro(false, 'M2105_8501', 'Percentuale', 'Condizione conto');
    TestUtils.creaPConfigurato('M2105_8501', '9', '0', lineaPCMCC.Id, null, null);

	TestUtils.creaParametro(false, 'M2105_8505', 'Divisa', 'Condizione conto');
    TestUtils.creaPConfigurato('M2105_8505', '500000', '0', lineaPCMCC.Id, null, null);

	TestUtils.creaParametro(false, 'M2105_8509', 'Numero', 'Condizione conto');
    TestUtils.creaPConfigurato('M2105_8509', '96', '0', lineaPCMCC.Id, null, null);

	TestUtils.creaParametro(false, 'SF66', 'Percentuale', 'Condizione economica');
    TestUtils.creaPConfigurato('SF66', '6', '0', lineaPCVSI.Id, null, null);



	//Creazione credito
	Credito__c credito = new Credito__c(
	  WGC_Annualita_imposta__c = '2021',
	  ValoreNominale__c = 250000,
	  WGC_Ruoli_compens__c = 0,
      WGC_Linea__c = lineaPCFFD.Id,
	  Opportunita__c = oppFEG.Id
    );
    insert credito;

	//Creazione ICAR manuali credito
	IcarManuale__c icarmanuale = new IcarManuale__c(
	  Debitore__c = debitore.Id,
      AnnoFatturatoDa__c = Date.today(),
      AnnoFatturatoA__c = Date.today(),
      NumeroFatturaDa__c = '001',
      NumeroFatturaA__c = '100'
    );
    insert icarmanuale;

    // creo garanzie
    Garanzia__c garanzia = new Garanzia__c(
      CodiceGaranzia__c = 'LPI',
      Opportunita__c = oppFEG.Id,
      DivisaNew__c = '242',
      Importo__c = 30000,
      Linea__c = lineaPCDFO.Id,
      Tipo__c = 'Specifica'
    );
    insert garanzia;

    Garanzia__c garanziaOmnibus = new Garanzia__c(
      CodiceGaranzia__c = 'FPQ',
      Opportunita__c = oppFEG.Id,
      DivisaNew__c = '242',
      Importo__c = 30000,
      Tipo__c = 'Omnibus'
    );
    insert garanziaOmnibus;

    JoinGaranteGaranzia__c joinGaranteGaranzia = new JoinGaranteGaranzia__c(
      PercentualeGaranzia__c = 100,
      Garanzia__c = garanzia.Id,
      Garante__c = debitore.Id
    );
    insert joinGaranteGaranzia;

    JoinGaranteGaranzia__c joinGaranteGaranziaOmnibus = new JoinGaranteGaranzia__c(
      PercentualeGaranzia__c = 100,
      Garanzia__c = garanziaOmnibus.Id,
      Garante__c = garanteOmnibus.Id
    );
    insert joinGaranteGaranziaOmnibus;

    // creo adeguata verifica
    AdeguataVerifica__c adeguataVerifica = new AdeguataVerifica__c(
      Opportunita__c = oppFEG.Id,
	  Account__c = accountFEG.Id,
      ScopoFD11__c = false,
      ScopoFD12__c = false,
      ScopoFD13__c = false,
      ScopoFD14__c = false,
      ScopoFD15__c = false,
      ScopoFD16__c = false,
      ScopoFD17__c = false,
      ScopoFD18__c = false,
      ScopoFD19__c = false
    );
    insert adeguataVerifica;

    // creo endpoint
    TestUtils.creaEndpointServizi();

  }

  @isTest
  static void testArrotondaCifreDecimali() {
    Test.startTest();
    String result = WsRestCrmUtils.arrotondaCifreDecimali('15;14;13', 2);
    Test.stopTest();
    System.assertNotEquals(0, result.compareTo('15;14;13'));
    System.assertEquals(0, result.compareTo('15.00;14.00;13.00'));
  }

  @isTest
  static void testCreaAssociazioneNdg() {

    NDGLinea__c racc = [SELECT NDG__c, Tipo__c FROM NDGLinea__c WHERE Tipo__c = 'Esecutore adeguata verifica'];

    Test.startTest();
    WsRestCrm.Associazione associazioneRacc = WsRestCrmUtils.creaAssociazioneNdg(Integer.valueOf(racc.NDG__c), 'RACC');
    Test.stopTest();

    System.assertEquals('RACC', associazioneRacc.codiceRuolo);
    System.assertEquals(Integer.valueOf(racc.NDG__c), associazioneRacc.ndg);
  }

  @isTest
  static void testCreaCondizione() {

    PConfigurato__c pConfigurato = [
      SELECT Id,
        Codice__c,
        Linea__c,
        Linea__r.Prodotto__r.CodiceProdotto__c,
        Valore__c,
        Default__c,
        Tipo__c,
        Attore__c
      FROM PConfigurato__c
      WHERE Tipo__c = 'Condizione conto'
    ];

    Test.startTest();
    WsRestCrm.Condizione condizione = WsRestCrmUtils.creaCondizione(pConfigurato, '9007');
    Test.stopTest();

    System.assertEquals(Long.valueOf(Datetime.now().format('yyyyMMdd')), condizione.dataDecorrenza);
    System.assertEquals('CDA', condizione.linea);
    System.assertEquals('CDA02', condizione.listino);
    System.assertEquals(1052, condizione.datoElementare);
    //System.assertEquals(pConfigurato.Valore__c, condizione.valoreProposto);
  }


  @isTest
  static void testCreaCondizioneFactoring() {

    PConfigurato__c pConfigurato = [
      SELECT Id,
        Codice__c,
        Linea__c,
        Linea__r.Prodotto__r.CodiceProdotto__c,
        Valore__c,
        Default__c,
        Tipo__c,
        Attore__c
      FROM PConfigurato__c
      WHERE Codice__c = '050'
    ];
    Parametro__c[] parametroList = [
      SELECT Id,
        CodiceUnivoco__c,
        Tipologia__c
      FROM Parametro__c
    ];
    Map<String, Parametro__c[]> parametroMap = U.groupBy(parametroList, 'CodiceUnivoco__c');

    Test.startTest();
    WsRestCrm.CondizioneFactoring condizioneFactoring = WsRestCrmUtils.creaCondizioneFactoring(pConfigurato, VALORE_SF16, VALORE_SF19, parametroMap, VALORE_DBC, VALORE_DBCSCAG);
    Test.stopTest();
    System.assertEquals(pConfigurato.Codice__c, condizioneFactoring.codiceCond);
    System.assertEquals('P', condizioneFactoring.tipoCond);
    System.assertEquals(1, condizioneFactoring.valoriCondFactoring.valoreCondFactoring.size());
    System.assertEquals(Decimal.valueOf(pConfigurato.Valore__c), condizioneFactoring.valoriCondFactoring.valoreCondFactoring[0].valueCond);
  }

  @isTest
  static void testCreaCondizioneFactoringC165() {

    PConfigurato__c pConfigurato = [SELECT Codice__c, Valore__c FROM PConfigurato__c WHERE Codice__c = 'C165'];

    Parametro__c[] parametroList = [
      SELECT Id,
        CodiceUnivoco__c,
        Tipologia__c
      FROM Parametro__c
    ];
    Map<String, Parametro__c[]> parametroMap = U.groupBy(parametroList, 'CodiceUnivoco__c');

    Test.startTest();
    WsRestCrm.CondizioneFactoring condizioneFactoring = WsRestCrmUtils.creaCondizioneFactoring(pConfigurato, VALORE_SF16, VALORE_SF19, parametroMap, VALORE_DBC, VALORE_DBCSCAG);
    Test.stopTest();
    System.assertEquals(pConfigurato.Codice__c, condizioneFactoring.codiceCond);
    System.assertEquals('P', condizioneFactoring.tipoCond);
    System.assertEquals(1, condizioneFactoring.valoriCondFactoring.valoreCondFactoring.size());
    System.assertEquals(Decimal.valueOf(pConfigurato.Valore__c), condizioneFactoring.valoriCondFactoring.valoreCondFactoring[0].valueCond);
  }

  @isTest
  static void testCreaFidoCoppia() {

    Linea__c linea = [
      SELECT
        LineaProsoluto__c,
        LineaATD__c,
        NumeroDebitoriProsolutoAssociati__c,
        Prodotto__c,
        Prodotto__r.CodiceProdotto__c
      FROM Linea__c
      WHERE Prodotto__r.CodiceProdotto__c = 'PCDFO'
      ];

    JoinLineaDebitore__c joinLineaDebitore = [
      SELECT
        Debitore__r.NDG__c,
        Debitore__r.Id,
        Debitore__r.DivisaNew__c,
        Debitore__r.Fatturato__c,
        Debitore__r.Prosoluto__c,
        Debitore__r.DiCuiProsoluto__c,
        Debitore__r.Plafond__c,
        Debitore__r.DurataNominale__c,
        DebitoreProsoluto__c,
        Linea__c
      FROM JoinLineaDebitore__c
      WHERE Linea__c = :linea.Id
    ];

    Map<String, PConfigurato__c[]> valoreSF10PerAttore = new Map<String, PConfigurato__c[]>();
	Map<String, PConfigurato__c[]> valoreSF256PerAttore = new Map<String, PConfigurato__c[]>();

    NDGLinea__c[] ndgLineaList= [SELECT Prosoluto__c FROM NDGLinea__c];

    Test.startTest();
    WsRestCrm.FidoCoppia fidoCoppia = WsRestCrmUtils.creaFidoCoppia(linea, joinLineaDebitore, valoreSF10PerAttore, valoreSF256PerAttore);
    Test.stopTest();

    System.assertEquals(joinLineaDebitore.Debitore__r.DivisaNew__c, fidoCoppia.codDivisa);
    System.assertEquals(Integer.valueOf(joinLineaDebitore.Debitore__r.NDG__c), fidoCoppia.codNDGDebi);
    System.assertEquals('C', fidoCoppia.codTipoCoppia);
    // TODO: completare
  }

  @isTest
  static void testcreaFidoCoppiaFromCredito() {

    Linea__c linea = [
      SELECT
        LineaProsoluto__c,
        LineaATD__c,
        NumeroDebitoriProsolutoAssociati__c,
        Prodotto__c,
        Prodotto__r.CodiceProdotto__c,
		Prodotto__r.Codice__c,
		TipoLinea__c
      FROM Linea__c
      WHERE Prodotto__r.CodiceProdotto__c = 'PCFFD'
      ];

	JoinLineaDebitore__c joinLineaDebitore = [
      SELECT
        Debitore__r.NDG__c,
        Debitore__r.Id,
        Debitore__r.DivisaNew__c,
        Debitore__r.Fatturato__c,
        Debitore__r.Prosoluto__c,
        Debitore__r.DiCuiProsoluto__c,
        Debitore__r.Plafond__c,
        Debitore__r.DurataNominale__c,
        DebitoreProsoluto__c,
        Linea__c
      FROM JoinLineaDebitore__c
      WHERE Linea__c = :linea.Id
    ];

    Credito__c credito = [
	  SELECT Id,
	         ValoreNominale__c,
			 Opportunita__c,
			 WGC_AdE_Territoriale__c,
			 WGC_Linea__c,
			 WGC_Val_Nom_Esigibile__c			           
      FROM Credito__c
      WHERE WGC_Linea__c = :linea.Id
	  LIMIT 1
	];

	PConfigurato__c[] pConfiguratoList = [
	  SELECT Id,
             Codice__c,
             Linea__c,
             Linea__r.Prodotto__r.CodiceProdotto__c,
             Linea__r.Prodotto__r.CodiceUnivoco__c,
             Valore__c,
             Default__c,
             Tipo__c,
             Attore__c
       FROM PConfigurato__c
       WHERE Linea__c = :linea.Id 
   ];

	Decimal sumImportoCrediti = 250000;
    Map<String, PConfigurato__c[]> pConfiguratoCodiceMap = U.groupBy(pConfiguratoList, '{Linea__c}_{Codice__c}', true);

    Test.startTest();
    WsRestCrm.FidoCoppia fidoCoppia = WsRestCrmUtils.creaFidoCoppiaFromCredito(linea, joinLineaDebitore, credito, sumImportoCrediti, pConfiguratoCodiceMap);
	Test.stopTest();

    System.assertEquals(joinLineaDebitore.Debitore__r.DivisaNew__c, fidoCoppia.codDivisa);
    System.assertEquals(Integer.valueOf(joinLineaDebitore.Debitore__r.NDG__c), fidoCoppia.codNDGDebi);
    System.assertEquals('E', fidoCoppia.codTipoCoppia);
    // TODO: completare
  }

  @isTest
  static void testCreaListaGaranzie() {
    MatriceGaranzie__mdt[] matrGaranzieList  =  [SELECT Id,
                                            CodiceKNET__c,
                                            ProQuota__c,
                                            Tipo__c
                                            FROM MatriceGaranzie__mdt
                                            ];
    Opportunity opportunity = [SELECT Id FROM Opportunity];
    Garanzia__c[] garanziaList = [SELECT CodiceGaranzia__c, DivisaNew__c, Importo__c FROM Garanzia__c WHERE Tipo__c = 'Specifica'];
    Garanzia__c garanzia = (garanziaList.size() == 1) ? garanziaList.get(0) : null;
    System.debug('@@@ garanzia ' + garanzia);
    JoinGaranteGaranzia__c[] joinGaranteGaranziaList = [
      SELECT Id,
        Garante__c,
        Garante__r.NDG__c,
        Garante__r.TipoGarante__c,
        Garanzia__c,
        PercentualeGaranzia__c
      FROM JoinGaranteGaranzia__c
      WHERE Garanzia__c IN :garanziaList
    ];
    Map<String, JoinGaranteGaranzia__c[]> joinGaranteGaranziaMap = U.groupBy(joinGaranteGaranziaList, 'Garanzia__c');
    System.debug('garanziaList test : ' + JSON.serialize(garanziaList));
    System.debug('joinGaranteGaranziaMap: '+joinGaranteGaranziaMap);
    System.debug('matrGaranzieList: '+matrGaranzieList);
    Test.startTest();
    WsRestCrm.Garanzia[] result = WsRestCrmUtils.creaListaGaranzie(garanziaList, joinGaranteGaranziaMap, matrGaranzieList);
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals(null, result[0].codTipoGara);
    System.assertEquals(garanzia.CodiceGaranzia__c, result[0].codiceGaranzia);
    System.assertEquals(garanzia.Importo__c, result[0].importo);
    System.assertEquals(garanzia.DivisaNew__c, result[0].divisa);
    System.assertEquals(null, result[0].dataGara);
    System.assertEquals(null, result[0].dataScadGara);
    System.assertEquals(1, result[0].referenti.referente.size());
  }

  @isTest
  static void testCreaNoteIstruttoriaHTML() {
    // TODO: completare

    Opportunity opportunity = [
      SELECT Id,
        Name,
        NoteOperazioneProposte__c,
        NoteStoricheAziendaeAttivitaSvolte__c,
        ComposizioneDelCapitaleSociale__c,
        NoteSuEsponentiManagementESoci__c,
        ProgrammiEProspettiveFuture__c,
        AnalisiDiBilancio__c,
        RapportiBancariECR__c,
        Approfondimenti__c,
        DescrizioneOperazioneProposta__c,
        Garanzie__c,
        Owner.Name,
        Account.WGC_Descrizione_dell_azienda__c,
        WGC_NoteEventi__c,
        WGC_NoteCR__c,
        WGC_NoteBilancio__c,
        WGC_Descrizione_Operativit_Proposta__c,
        WGC_Note_Condizioni_Economiche__c,
        WGC_Note_automatiche__c,
        WGC_Note_Automatiche_Estero__c
      FROM Opportunity
    ];

    Test.startTest();
    WsRestCrmUtils.creaNoteIstruttoriaHTML(Opportunity);
    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testCreaParametriFidoCoppiaIcarManuali() {
    Test.startTest();
    Account a = [SELECT Id FROM Account LIMIT 1];
    insert new Prodotto__c(CodiceUnivoco__c = 'ATDTiAnticipo');
    Cessione__c cessione = new Cessione__c(Account__c = a.Id);
    insert cessione;
    Certificazione__c cert = new Certificazione__c(Cessione__c = cessione.Id, TerminiPagamento__c = 30);
    insert cert;


	//Icar Manuali
	IcarManuale__c[] icarManualiList = [
	  SELECT Id,
           Debitore__c,
           AnnoFatturatoDa__c,
           AnnoFatturatoA__c,
           DataEmissioneDa__c,
           DataEmissioneA__c,
           NumeroFatturaDa__c,
           NumeroFatturaA__c,
           WGC_Credito__c
      FROM IcarManuale__c
      ];

    
    WsRestCrmUtils.creaParametriFidoCoppiaIcarManuali(icarManualiList, new Certificazione__c[]{cert});
    Test.stopTest();
    // todo test: sistemare
  }

  @isTest
  static void testCreaParametriFidoCoppiaLista() {
    // TODO: completare

    PConfigurato__c[] pConfiguratoList = [
      SELECT Id,
        Codice__c,
        Linea__c,
        Valore__c,
        Default__c,
        Tipo__c,
        Attore__c
      FROM PConfigurato__c
    ];

    Parametro__c[] parametroList = [
      SELECT Id,
        CodiceUnivoco__c,
        Tipologia__c
      FROM Parametro__c
    ];
    Map<String, Parametro__c[]> parametroMap = U.groupBy(parametroList, 'CodiceUnivoco__c');


    Test.startTest();
    WsRestCrmUtils.creaParametriFidoCoppiaLista(pConfiguratoList, parametroMap);
    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testCreaParametriFidoCoppiaObbligatori() {

    Linea__c linea = [SELECT Id, LineaProsoluto__c, NumeroDebitoriProsolutoAssociati__c, Prodotto__c, Prodotto__r.CodiceProdotto__c FROM Linea__c WHERE Prodotto__r.CodiceProdotto__c = 'PCDFO'];

    NDGLinea__c ndgLinea = [SELECT NDG__c FROM NDGLinea__c WHERE Tipo__c = 'Debitore' AND Linea__c = :linea.Id];

    JoinLineaDebitore__c joinLineaDebitore = [SELECT Debitore__r.NDG__c,
      Debitore__r.Id,
      Debitore__r.DivisaNew__c,
      Debitore__r.Fatturato__c,
      Debitore__r.Prosoluto__c,
      Debitore__r.DiCuiProsoluto__c,
      Debitore__r.Plafond__c,
      Debitore__r.DurataNominale__c,
      Linea__c
    FROM JoinLineaDebitore__c
    WHERE Debitore__r.NDG__c = :ndgLinea.NDG__c
	  AND Linea__c = :linea.Id];

    Map<String, PConfigurato__c[]> valoreSF10PerAttore = new Map<String, PConfigurato__c[]>();

    Test.startTest();
    List<WsRestCrm.Parametro> parametroList = WsRestCrmUtils.creaParametriFidoCoppiaObbligatori(linea, joinLineaDebitore, valoreSF10PerAttore);
    Test.stopTest();

    System.assertEquals(3, parametroList.size());
  }
  
  
  @isTest
  static void testcreaParametriFidoCoppiaObbligatoriFromCredito() {

    Linea__c linea = [SELECT Id, LineaProsoluto__c, NumeroDebitoriProsolutoAssociati__c, Prodotto__c, Prodotto__r.CodiceProdotto__c, Prodotto__r.Codice__c FROM Linea__c WHERE Prodotto__r.CodiceProdotto__c = 'PCFFD'];

    NDGLinea__c ndgLinea = [SELECT NDG__c FROM NDGLinea__c WHERE Tipo__c = 'Debitore' AND Linea__c = :linea.Id];

    JoinLineaDebitore__c joinLineaDebitore = [SELECT Debitore__r.NDG__c,
      Debitore__r.Id,
      Debitore__r.DivisaNew__c,
      Debitore__r.Fatturato__c,
      Debitore__r.Prosoluto__c,
      Debitore__r.DiCuiProsoluto__c,
      Debitore__r.Plafond__c,
      Debitore__r.DurataNominale__c,
      Linea__c
    FROM JoinLineaDebitore__c
    WHERE Debitore__r.NDG__c = :ndgLinea.NDG__c
	  AND Linea__c = :linea.Id];

    Credito__c credito = [
	  SELECT Id,
	         ValoreNominale__c,
			 Opportunita__c,
			 WGC_AdE_Territoriale__c,
			 WGC_Linea__c,
			 WGC_Val_Nom_Esigibile__c			           
      FROM Credito__c
      WHERE WGC_Linea__c = :linea.Id
	  LIMIT 1
	];

    Test.startTest();
    List<WsRestCrm.Parametro> parametroList = WsRestCrmUtils.creaParametriFidoCoppiaObbligatoriFromCredito(linea, joinLineaDebitore, credito);
	Test.stopTest();

    System.assertEquals(3, parametroList.size());
  }


  @isTest
  static void testCreaParametro() {
    // TODO: completare
    Test.startTest();

    Test.stopTest();
    System.assert(true);
  }


  @isTest
  static void testCreaValoreCondFactoring() {
    // TODO: completare
    Test.startTest();

    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testDoMapping() {
    // TODO: completare
    Test.startTest();

    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testMappaCodTipoPara() {
    // TODO: completare
    Test.startTest();

    Test.stopTest();
    System.assert(true);
  }

  //@isTest
  //static void testMappaScopoAccensione() {

    //AdeguataVerifica__c[] adeguataVerificaList = [SELECT Id,
      //ScopoFD11__c,
      //ScopoFD12__c,
      //ScopoFD13__c,
      //ScopoFD14__c,
      //ScopoFD15__c,
      //ScopoFD16__c,
      //ScopoFD17__c,
      //ScopoFD18__c,
      //ScopoFD19__c
    //FROM AdeguataVerifica__c
    //LIMIT 1];
    //AdeguataVerifica__c adeguataVerifica = (adeguataVerificaList.size() == 1) ? adeguataVerificaList.get(0) : null;

    //Test.startTest();
    //String result = WsRestCrmUtils.mappaScopoAccensione(adeguataVerifica);
    //Test.stopTest();

    //System.assertEquals('14', result);
  //}

  @isTest
  static void testMappingAssociazioneGaranziaOmnibus() {
    // TODO: completare
    Test.startTest();

    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testMappingAssociazioneGaranzie() {
    // TODO: completare
    Test.startTest();

    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testMappingAssociazioneNdgRuoli() {
    // TODO: completare
    Test.startTest();

    Test.stopTest();
    System.assert(true);
  }


  @isTest
  static void testMappingCondizioni() {

    Linea__c linea = [SELECT Id FROM Linea__c WHERE Prodotto__r.CodiceProdotto__c = 'PPIIM'];

    PConfigurato__c[] pConfiguratoList = [
      SELECT Id,
        Codice__c,
        Linea__c,
        Linea__r.Prodotto__r.CodiceProdotto__c,
        Valore__c,
        Default__c,
        Tipo__c,
        Attore__c
      FROM PConfigurato__c
    ];
    Map<String, PConfigurato__c[]> pConfiguratoMap = U.groupBy(pConfiguratoList, 'Linea__c');

    PConfigurato__c[] condizioniList = new List<PConfigurato__c>();

    if (pConfiguratoMap.containsKey(linea.Id)) {
      for (PConfigurato__c p : pConfiguratoMap.get(linea.Id)) {
        if (p.Valore__c != p.Default__c && p.Codice__c != 'CONV') {
          condizioniList.add(p);
        }
      }
    }

    Test.startTest();
    WsRestCrm.Condizioni condizioni = WsRestCrmUtils.mappingCondizioni(condizioniList);
    Test.stopTest();

    //TODO: completare
    System.assert(true);
  }

  @isTest
  static void testMappingCondizioniFactoring() {

    Linea__c lineaFactoring = [SELECT Id, Prodotto__r.Codice__c FROM Linea__c WHERE Prodotto__r.CodiceProdotto__c = 'PCDFO'];

    Parametro__c[] parametroList = [
      SELECT Id,
        CodiceUnivoco__c,
        Tipologia__c
      FROM Parametro__c
    ];
    Map<String, Parametro__c[]> parametroMap = U.groupBy(parametroList, 'CodiceUnivoco__c');

    PConfigurato__c[] pConfiguratoList = [
      SELECT Id,
        Codice__c,
        Linea__c,
        Valore__c,
        Default__c,
        Tipo__c,
        Attore__c
      FROM PConfigurato__c
    ];
    Map<String, PConfigurato__c[]> pConfiguratoMap = U.groupBy(pConfiguratoList, 'Linea__c');
    PConfigurato__c[] condizioniFactoringList = new List<PConfigurato__c>();
    if (pConfiguratoMap.containsKey(lineaFactoring.Id))
      for (PConfigurato__c p : pConfiguratoMap.get(lineaFactoring.Id))
        if (p.Attore__c == null)
          if (p.Codice__c.startsWith('C') || p.Codice__c.startsWith('D'))
            condizioniFactoringList.add(p);

    ParametroProdotto__c[] parametroProdottoList = [SELECT Parametro__r.CodiceUnivoco__c,
                           Prodotto__r.Codice__c,
                           DBC__c,
                           DBCScag__c
                           FROM ParametroProdotto__c];
    Map<String, ParametroProdotto__c[]> parametroProdottoMap = U.groupBy(parametroProdottoList, '{Prodotto__r.Codice__c}_{Parametro__r.CodiceUnivoco__c}', true);

    Test.startTest();
    WsRestCrm.CondizioniFactoring condizioniFactoring = WsRestCrmUtils.mappingCondizioniFactoring(condizioniFactoringList, VALORE_SF16, VALORE_SF17, VALORE_SF19, parametroMap, lineaFactoring, parametroProdottoMap);
    Test.stopTest();

    System.assertEquals(2, condizioniFactoring.condizioneFactoring.size());
  }

  @isTest
  static void testMappingDatiTecnici() {
    // TODO: completare
    Test.startTest();
    // WsRestCrmUtils.mappingDatiTecnici();
    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testMappingFidiCoppia() {
    // TODO: completare
    Test.startTest();

    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testMappingParametriAggiuntivi() {
    // TODO: completare
    Test.startTest();

    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testNvAggiornamentoInnescaVendita() {

    Opportunity opportunity = [SELECT Id FROM Opportunity];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_NV_AGGIORNAMENTO_INNESCA_VENDITA));
    WsRestCrmUtils.nvAggiornamentoInnescaVendita(opportunity.Id);
    Test.stopTest();

    System.assert(true);
  }

}