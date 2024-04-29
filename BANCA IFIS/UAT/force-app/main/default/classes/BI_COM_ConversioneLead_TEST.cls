/**
* Progetto:         Revisione componenti core per CRM 2.0.
* Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
* Descrizione:      Classe di test per BI_COM_ConversioneLead_CODE
*
*/

@isTest 
private class BI_COM_ConversioneLead_TEST {

  @testSetup
  public static void BI_COM_ConversioneLead_TEST_setupDati() {

    Campaign campagna = TestUtils.creaCampagna();
    TestUtils.CreaImpostazioni(campagna);
    User dora = TestUtils.creaUtente('dora');
    dora.LoginSiebel__c = 'ls';
    update dora;
    TestUtils.impostaCS();

    insert BI_COM_UtilitiesSupportoTest_CODE.getCustomSettingEndpointServizi();

	insert BI_COM_UtilitiesSupportoTest_CODE.getLead_FormWeb();
  }

  @isTest
  public static void testConvertLeadTriggered() {

    // BATCH IN ESECUZIONE CLASSICA, CON PARTENZA MEDIANTE IL TRIGGER 'TRGLEAD'

    Test.startTest();
		
		Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE)); 
    
		//insert BI_COM_UtilitiesSupportoTest_CODE.getLead_FormWeb();

	Test.stopTest();

    Lead l = [SELECT Status, ConversionMessage__c, AccountCollegato__c, RagioneSociale__c, Phone, Email, PIVA__c, TipoAccount__c, State, PostalCode, Tag__c, IFISForm__c, IFISIdUnicoForm__c
              FROM Lead
              ];

  }

  @isTest
  public static void testConvertLead() {
    // Se in futuro il 'TrgLead' verra' rimosso, questo metodo testa comunque l'execute del batch.
    WGC_AllDataFactory.createUtenzaDefault();
    WGC_AllDataFactory.createLagKey();
    WGC_AllDataFactory.creaImpServ();

 		//insert BI_COM_UtilitiesSupportoTest_CODE.getLead_FormWeb();
   TestUtils.creaAccount('nomeAccount', 'MI', '02168580120', null);

    Set<Id> leads = U.getIdSet([SELECT Id FROM Lead], 'Id');
   
    Test.startTest();
    BI_COM_ConversioneLead_BTCH bcl = new BI_COM_ConversioneLead_BTCH(leads);
    // Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));//TODO remove?
    Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
    bcl.execute(null, [SELECT Id,
                              IFISIdUnicoForm__c,
                              FirstName,
                              LastName,
                              RagioneSociale__c,
                              Phone,
                              MobilePhone, 
                              Email,
                              PIVA__c,
                              TipoAccount__c,
                              State,
                              PostalCode,
                              Tag__c,
                              CodiceOwner__c,
                              IFISForm__c,
                              Messaggio__c,
                              NumeroTentativiConversione__c,
                              PrivacyMarketing__c,
							  BI_StackTrace__c,
							  Street,
							  City,
							  WGC_Tipo_Via__c,WGC_Codice_Fiscale__c,WGC_Sesso__c,BI_Tipologia_Inserimento__c
                       FROM lead]);
    Test.stopTest();

  }

 @isTest
  public static void testConvertLeadPiuRecord() {
    // Se in futuro il 'TrgLead' verra' rimosso, questo metodo testa comunque l'execute del batch.
    WGC_AllDataFactory.createUtenzaDefault();
    WGC_AllDataFactory.createLagKey();
    WGC_AllDataFactory.creaImpServ();

	// DOPPIO INSERIMENTO

    insert BI_COM_UtilitiesSupportoTest_CODE.getLead_FormWeb();

    TestUtils.creaAccount('nomeAccount', 'MI', '02168580120', null);

    Set<Id> leads = U.getIdSet([SELECT Id FROM Lead], 'Id');
   
    Test.startTest();
    BI_COM_ConversioneLead_BTCH bcl = new BI_COM_ConversioneLead_BTCH(leads);
    // Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));//TODO remove?
    Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
    bcl.execute(null, [SELECT Id,
                              IFISIdUnicoForm__c,
                              FirstName,
                              LastName,
                              RagioneSociale__c,
                              Phone,
                              MobilePhone, 
                              Email,
                              PIVA__c,
                              TipoAccount__c,
                              State,
                              PostalCode,
                              Tag__c,
                              CodiceOwner__c,
                              IFISForm__c,
                              Messaggio__c,
                              NumeroTentativiConversione__c,
                              PrivacyMarketing__c,
							  BI_StackTrace__c,
							  Street,
							  City,
							  WGC_Tipo_Via__c,WGC_Codice_Fiscale__c,WGC_Sesso__c,BI_Tipologia_Inserimento__c
                       FROM lead]);
    Test.stopTest();

  }

 @isTest
  public static void testConvertLeadTRADIZIONALE() {
    // Se in futuro il 'TrgLead' verra' rimosso, questo metodo testa comunque l'execute del batch.
    WGC_AllDataFactory.createUtenzaDefault();
    WGC_AllDataFactory.createLagKey();
    WGC_AllDataFactory.creaImpServ();

	// insert BI_COM_UtilitiesSupportoTest_CODE.getLead_FormWeb();

    TestUtils.creaAccount('nomeAccount', 'MI', '02168580120', null);

    Set<Id> leads = U.getIdSet([SELECT Id FROM Lead], 'Id');
   
    Test.startTest();
    BI_COM_ConversioneLead_BTCH bcl = new BI_COM_ConversioneLead_BTCH(leads);
    // Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));//TODO remove?
    Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
    bcl.execute(null, [SELECT Id,
                              IFISIdUnicoForm__c,
                              FirstName,
                              LastName,
                              RagioneSociale__c,
                              Phone,
                              MobilePhone, 
                              Email,
                              PIVA__c,
                              TipoAccount__c,
                              State,
                              PostalCode,
                              Tag__c,
                              CodiceOwner__c,
                              IFISForm__c,
                              Messaggio__c,
                              NumeroTentativiConversione__c,
                              PrivacyMarketing__c,
							  BI_StackTrace__c,
							  Street,
							  City,
							  WGC_Tipo_Via__c,WGC_Codice_Fiscale__c,WGC_Sesso__c,BI_Tipologia_Inserimento__c
                       FROM lead]);
    Test.stopTest();

  }


  @isTest
  public static void testConvertLead_leadPrivacytrue() {
    // Se in futuro il 'TrgLead' verra' rimosso, questo metodo testa comunque l'execute del batch.
    WGC_AllDataFactory.createUtenzaDefault();
    WGC_AllDataFactory.createLagKey();
    WGC_AllDataFactory.creaImpServ();

 	//insert BI_COM_UtilitiesSupportoTest_CODE.getLead_FormWeb();

     TestUtils.creaAccount('nomeAccount', 'MI', '02168580120', null);

    Set<Id> leads = U.getIdSet([SELECT Id FROM Lead], 'Id');
    List<Lead> lstlead = [SELECT Id,IFISIdUnicoForm__c,FirstName,LastName,RagioneSociale__c,Phone,Email,PIVA__c,TipoAccount__c,State,PostalCode,Tag__c,CodiceOwner__c,IFISForm__c,Messaggio__c,NumeroTentativiConversione__c,PrivacyMarketing__c
                       FROM lead];

    lstlead.get(0).PrivacyMarketing__c='true';
    update lstlead;
    Test.startTest();
    BI_COM_ConversioneLead_BTCH bcl = new BI_COM_ConversioneLead_BTCH(leads);
    // Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));//TODO remove?
    Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
    bcl.execute(null, [SELECT Id,
                              IFISIdUnicoForm__c,
                              FirstName,
                              LastName,
                              RagioneSociale__c,
                              Phone,
                       		  MobilePhone,
                              Email,
                              PIVA__c,
                              TipoAccount__c,
                              State,
                              PostalCode,
                              Tag__c,
                              CodiceOwner__c,
                              IFISForm__c,
                              Messaggio__c,
                              NumeroTentativiConversione__c,
                              PrivacyMarketing__c,
							  BI_StackTrace__c,
							  Street,
							  City,
							  WGC_Tipo_Via__c,WGC_Codice_Fiscale__c,WGC_Sesso__c,BI_Tipologia_Inserimento__c
                       FROM lead]);
    Test.stopTest();
   
  }

  @isTest
  public static void testConvertLead_leadPrivacyfalse() {
    // Se in futuro il 'TrgLead' verra' rimosso, questo metodo testa comunque l'execute del batch.
    WGC_AllDataFactory.createUtenzaDefault();
    WGC_AllDataFactory.createLagKey();
    WGC_AllDataFactory.creaImpServ();

 	//insert BI_COM_UtilitiesSupportoTest_CODE.getLead_FormWeb();

    TestUtils.creaAccount('nomeAccount', 'MI', '02168580120', null);

    Set<Id> leads = U.getIdSet([SELECT Id FROM Lead], 'Id');
    List<Lead> lstlead = [SELECT Id,IFISIdUnicoForm__c,FirstName,LastName,RagioneSociale__c,Phone,Email,PIVA__c,TipoAccount__c,State,PostalCode,Tag__c,CodiceOwner__c,IFISForm__c,Messaggio__c,NumeroTentativiConversione__c,PrivacyMarketing__c
                       FROM lead];

    lstlead.get(0).PrivacyMarketing__c='false';
    update lstlead;
    Test.startTest();
    BI_COM_ConversioneLead_BTCH bcl = new BI_COM_ConversioneLead_BTCH(leads);
    // Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));//TODO remove?
    Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
    bcl.execute(null, [SELECT Id,
                              IFISIdUnicoForm__c,
                              FirstName,
                              LastName,
                              RagioneSociale__c,
                              Phone,
                       		  MobilePhone, 
                              Email,
                              PIVA__c,
                              TipoAccount__c,
                              State,
                              PostalCode,
                              Tag__c,
                              CodiceOwner__c,
                              IFISForm__c,
                              Messaggio__c,
                              NumeroTentativiConversione__c,
                              PrivacyMarketing__c,
							  BI_StackTrace__c,
							  Street,
							  City,
							  WGC_Tipo_Via__c,WGC_Codice_Fiscale__c,WGC_Sesso__c,BI_Tipologia_Inserimento__c
                       FROM lead]);
    Test.stopTest();
   
  }
  @isTest
  public static void testConvertLead_senzaAccountInserito() {
    // Se in futuro il 'TrgLead' verra' rimosso, questo metodo testa comunque l'execute del batch.
    WGC_AllDataFactory.createUtenzaDefault();
    WGC_AllDataFactory.createLagKey();
    WGC_AllDataFactory.creaImpServ();
	
	//insert BI_COM_UtilitiesSupportoTest_CODE.getLead_FormWeb();
    // TestUtils.creaAccount('nomeAccount', 'MI', '02168580120', null);
    // Account a = WGC_AllDataFactory.createAccount(1,false).get(0);
    // a.ProvinciaCCIAA__c='PD';
    Set<Id> leads = U.getIdSet([SELECT Id FROM Lead], 'Id');
    List<Lead> lstlead = [SELECT Id,IFISIdUnicoForm__c,FirstName,LastName,RagioneSociale__c,Phone,Email,PIVA__c,TipoAccount__c,State,PostalCode,Tag__c,CodiceOwner__c,IFISForm__c,Messaggio__c,NumeroTentativiConversione__c,PrivacyMarketing__c
                       FROM lead];

    lstlead.get(0).PrivacyMarketing__c='false';
    update lstlead;
    Test.startTest();
    BI_COM_ConversioneLead_BTCH bcl = new BI_COM_ConversioneLead_BTCH(leads);
    // Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));//TODO remove?
    Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
    bcl.execute(null, [SELECT Id,
                              IFISIdUnicoForm__c,
                              FirstName,
                              LastName,
                              RagioneSociale__c,
                              Phone,
                       		  MobilePhone, 
                              Email,
                              PIVA__c,
                              TipoAccount__c,
                              State,
                              PostalCode,
                              Tag__c,
                              CodiceOwner__c,
                              IFISForm__c,
                              Messaggio__c,
                              NumeroTentativiConversione__c,
                              PrivacyMarketing__c,
							  BI_StackTrace__c,
							  Street,
							  City,
							  WGC_Tipo_Via__c,WGC_Codice_Fiscale__c,WGC_Sesso__c,BI_Tipologia_Inserimento__c
                       FROM lead]);
    Test.stopTest();

    Lead l = [SELECT Status, ConversionMessage__c, AccountCollegato__c, RagioneSociale__c, Phone, Email, PIVA__c, TipoAccount__c, State, PostalCode, Tag__c, IFISForm__c, IFISIdUnicoForm__c
              FROM Lead
              ];

    System.debug('@Lead --> '+l);
   
  }

}