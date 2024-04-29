@isTest
private class WsAnagrafeTest {

  private static String VIA_TIPO = 'Corso';
  private static String VIA_NOME = 'Garibaldi';
  private static String VIA_NUMERO = '71';

  private static Integer TEL_PREFISSO = 2;
  private static Integer TEL_NUMERO = 123456789;



  @testSetup
  static void testSetup() {
    // TestUtils.creaReferente('BRVPMR54R11A290O', 'Paolo', 'Brivio', '2548031');
    WGC_AllDataFactory.createUtenzaDefault();
    Contact c = WGC_AllDataFactory.createContact(1,false).get(0);
    c.FirstName = 'Paolo'; 
    c.LastName = 'Brivio'; 
    c.CF__c = 'BRVPMR54R11A290O'; 
    // c.NDGGruppo__c = '2548031';
    insert c; 
    TestUtils.creaEndpointServizi();
    TestUtils.impostaCS();
  }

  @isTest
  static void testStub() {
    WsAnagrafe.Via v1 = new WsAnagrafe.Via();
    v1.tipo = VIA_TIPO;
    v1.nome = VIA_NOME;
    v1.numeroDomicilio = VIA_NUMERO;
    System.assert(v1.getViaCompleta() == VIA_TIPO + ' ' + VIA_NOME + ' ' + VIA_NUMERO);

    WsAnagrafe.Via2 v2 = new WsAnagrafe.Via2();
    v2.tipo = VIA_TIPO;
    v2.nome = VIA_NOME;
    v2.numero = VIA_NUMERO;
    System.assert(v2.getViaCompleta() == VIA_TIPO + ' ' + VIA_NOME + ' ' + VIA_NUMERO);

    WsAnagrafe.Telefono t1 = new WsAnagrafe.Telefono();
    t1.prefisso = TEL_PREFISSO;
    t1.numero = TEL_NUMERO;
    System.assert(t1.getNumeroCompleto() == TEL_PREFISSO + '' + TEL_NUMERO);

    WsAnagrafe.Telefono2 t2 = new WsAnagrafe.Telefono2();
    t2.prefisso = '' + TEL_PREFISSO;
    t2.numero = '' + TEL_NUMERO;
    System.assert(t2.getNumeroCompleto() == TEL_PREFISSO + '' + TEL_NUMERO);

    WsAnagrafe.ElencoRapportiResponse r1 = new WsAnagrafe.ElencoRapportiResponse();
    System.assert(!r1.isCorrect());
    r1.payload = new WsAnagrafe.ElencoRapporti();
    System.assert(r1.isCorrect());

    WsAnagrafe.SearchAnagraficaRes r2 = new WsAnagrafe.SearchAnagraficaRes();
    System.assert(!r2.isCorrect());
    r2.payload = new WsAnagrafe.Anagrafiche();
    r2.payload.anagrafica = new WsAnagrafe.Anagrafica[] {};
    System.assert(r2.isCorrect());

    WsAnagrafe.GetAnagraficaRes r3 = new WsAnagrafe.GetAnagraficaRes();
    System.assert(!r3.isCorrect());
    r3.payload = new WsAnagrafe.DatiAnagraficiCedacri();
    System.assert(r3.isCorrect());

    WsAnagrafe.CensimentoLightRes r4 = new WsAnagrafe.CensimentoLightRes();
    System.assert(!r4.isCorrect());
    r4.payload = new WsAnagrafe.DatiAnagraficiCedacri2();
    r4.payload.ndg = 123;
    System.assert(r4.isCorrect());

    WsAnagrafe.GestioneCollNdgResponse r5 = new WsAnagrafe.GestioneCollNdgResponse();
    System.assert(!r5.isCorrect());
    r5.payload = new WsAnagrafe.GestioneCollNdg();
    System.assert(r5.isCorrect());

    WsAnagrafe.CensimentoFullRes r6 = new WsAnagrafe.CensimentoFullRes();
    System.assert(!r6.isCorrect());
    r6.payload = new WsAnagrafe.DatiAnagraficiCedacri3();
    //System.assert(r6.isCorrect());

    WsAnagrafe.VariazioneRes r7 = new WsAnagrafe.VariazioneRes();
    System.assert(!r7.isCorrect());
    r7.payload = new WsAnagrafe.DatiAnagraficiIntegrazione();
    r7.payload.esitoGenerale = new WsAnagrafe.Esito();
    r7.payload.esitoGenerale.esito = 'OK';
    System.assert(r7.isCorrect());

    WsAnagrafe.DatiBilancioResponse r8 = new WsAnagrafe.DatiBilancioResponse();
    System.assert(!r8.isCorrect());
    r8.payload = new WsAnagrafe.DatiBilancio();
    System.assert(r8.isCorrect());

    WsAnagrafe.ModificaDatiAggiuntiviQQResponse r9 = new WsAnagrafe.ModificaDatiAggiuntiviQQResponse();
    System.assert(!r9.isCorrect());
    r9.payload = new WsAnagrafe.ModificaDatiAggiuntiviQQ();
    System.assert(r9.isCorrect());

    WsAnagrafe.DomiciliazioneAmministrativa da = new WsAnagrafe.DomiciliazioneAmministrativa();
    da = new WsAnagrafe.DomiciliazioneAmministrativa('Garibaldi', '71', 'VIA', '20121', 'Milano', 'MI');


  }

  @isTest
  static void testErrors() {
    WsAnagrafe.ElencoRapportiResponse r1 = new WsAnagrafe.ElencoRapportiResponse();
    System.assert(!r1.isCorrect());

    r1.headers = new WsRestInput.HeaderWrapper();
    r1.headers.headers = new WsRestInput.Headers();
    r1.headers.headers.error_header = new WsRestInput.ErrorHeader();
    WsRestInput.Error e1 = new WsRestInput.Error();
    e1.code = 'test';
    e1.description = 'test';
    r1.headers.headers.error_header.archErrorList = new WsRestInput.Error[] {e1};
    String errors = r1.getErrors();
    System.assert(String.isNotBlank(errors));

    WsAnagrafe.VariazioneRes vr = new WsAnagrafe.VariazioneRes();
    vr.headers = new WsRestInput.HeaderWrapper();
    vr.headers.headers = new WsRestInput.Headers();
    vr.headers.headers.error_header = new WsRestInput.ErrorHeader();
    vr.headers.headers.error_header.archErrorList = new WsRestInput.Error[] {e1};
    String errors2 = vr.getErrors();
    System.assert(String.isNotBlank(errors2));
  }

  @isTest
  static void testRicercaAnagraficaCedacri() {
    Contact c = [SELECT FirstName, LastName FROM Contact WHERE FirstName = 'Paolo'];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PF));
    WsAnagrafe.SearchAnagraficaRes response = WsAnagrafe.searchAnagrafica(null, null, c.LastName, c.FirstName);
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testDatiAnagraficiCedacri() {
    Contact c = [SELECT NDGGruppo__c FROM Contact WHERE FirstName = 'Paolo'];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_GET_DATI_ANAGRAFICI_CEDACRI_PF));
    WsAnagrafe.GetAnagraficaRes response = WsAnagrafe.getAnagrafica(c.NDGGruppo__c, null);
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testSetAnagraficaLight() {
    Contact c = [SELECT FirstName, LastName, CF__c, NDGGruppo__c FROM Contact WHERE FirstName = 'Paolo'];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_LIGHT_PF));
    WsAnagraficaBean b = new WsAnagraficaBean();
    b.fillFrom(c.Id);
    WsAnagrafe.CensimentoLightRes response = WsAnagrafe.censimentoLight(b);
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testSetAnagraficaCedacri() {
    Contact c = [SELECT FirstName, LastName, CF__c, NDGGruppo__c FROM Contact WHERE FirstName = 'Paolo'];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_CEDACRI_PF));
    WsAnagraficaBean b = new WsAnagraficaBean();
    b.fillFrom(c.Id);
    WsAnagrafe.CensimentoFullRes response = WsAnagrafe.censimentoFull(b);
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testSetAnagraficaVariazione() {
    Contact c = [SELECT FirstName, LastName, CF__c, NDGGruppo__c FROM Contact WHERE FirstName = 'Paolo'];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_VARIAZIONE_PF));
    WsAnagraficaBean b = new WsAnagraficaBean();
    b.fillFrom(c.Id);
    WsAnagrafe.VariazioneRes response = WsAnagrafe.variazione(b);
    Test.stopTest();
    System.assert(response.isCorrect());
    System.assertEquals('', response.getErrors());
  }

  @isTest
  static void testGestioneCollNdg() {
    Contact c = [SELECT NDGGruppo__c FROM Contact WHERE FirstName = 'Paolo'];
    Test.startTest();
    try {
      WsAnagrafe.gestioneCollNdg(null);
    } catch (Exception e) {
      System.assert(e.getMessage().contains('gestioneCollNdg input vuoto'));
    }
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_GESTIONE_COLL_NDG_PF));
    WsAnagrafe.GestioneCollNdgResponse response = WsAnagrafe.gestioneCollNdg(c.NDGGruppo__c);
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testSetRetiAnagraficheIfis() {
    Test.startTest();
    try {
      WsAnagrafe.setRetiAnagraficheIfis(null, null, null, null, null);
    } catch (Exception e) {
      System.assert(e.getMessage().contains('setRetiAnagraficheIfis: gli NDG di Cliente e Settorista sono obbligatori'));
    }
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_RETI_ANAGRAFICHE));
    WsAnagrafe.SetRetiAnagraficheIfisResponse response = WsAnagrafe.setRetiAnagraficheIfis('1', '2', '3', '4', '5');
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testAssociaPfPgCollNdg() {
    Contact c = [SELECT NDGGruppo__c FROM Contact WHERE FirstName = 'Paolo'];
    Test.startTest();
    try {
      WsAnagrafe.associaPfPgCollNdg(null, null, null, null);
    } catch (Exception e) {
      System.assert(e.getMessage().contains('associaPfPgCollNdg input vuoto'));
    }
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_GESTIONE_COLL_NDG_PF));
    WsAnagrafe.GestioneCollNdgResponse response = WsAnagrafe.associaPfPgCollNdg('1234', c.NDGGruppo__c, 'R', false);
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testDatiBilancio() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_DATI_BILANCIO));
    WsAnagrafe.DatiBilancioResponse response = WsAnagrafe.DatiBilancio(new WsAnagrafe.DatiBilancioInput());
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testModificaDatiAggiuntiviQQ() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_MODIFICA_DATI_AGGIUNTIVI_QQ));
    WsAnagrafe.ModificaDatiAggiuntiviQQResponse response = WsAnagrafe.ModificaDatiAggiuntiviQQ(new WsAnagrafe.ModificaDatiAggiuntiviQQInput());
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testCreaCointestazioneCollNdg() {
    Test.startTest();
    try {
      WsAnagrafe.creaCointestazioneCollNdg(null);
    } catch (Exception e) {
      System.assert(e.getMessage().contains('creaCointestazioneCollNdg input vuoto'));
    }
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_GESTIONE_COLL_NDG_PF));
    WsAnagrafe.GestioneCollNdgResponse response = WsAnagrafe.CreaCointestazioneCollNdg(new String[]{'1234'});
    WsAnagrafe.ElementoNdg[] cointestazioneList = response.payload.getCointestazioneList();
    String cointestazioneCapoReteNdg = response.payload.getCointestazioneCapoReteNdg();
    Test.stopTest();
    System.assert(response.isCorrect());
    System.assertEquals(2, cointestazioneList.size());
    System.assertEquals('1553425', cointestazioneCapoReteNdg);
  }

  @isTest
  static void testAttivitaEcononica() {
    Test.startTest();
    WsAnagrafe.AttivitaEcononica attivitaEcononica = new WsAnagrafe.AttivitaEcononica('1', null, '2');
    Test.stopTest();
    System.assertEquals(1, attivitaEcononica.sae);
    System.assertEquals(null, attivitaEcononica.rae);
    System.assertEquals(2, attivitaEcononica.cae);
  }

  @isTest
  static void testNaturaGiuridica() {
    Test.startTest();
    WsAnagrafe.NaturaGiuridica naturaGiuridica = new WsAnagrafe.NaturaGiuridica('nome', 'codice', 'descrizione');
    Test.stopTest();
    System.assertEquals('nome', naturaGiuridica.nome);
    System.assertEquals('codice', naturaGiuridica.codice);
    System.assertEquals('descrizione', naturaGiuridica.descrizione);
  }

  @isTest
  static void testIntestazioneDati() {
    Test.startTest();
    WsAnagrafe.IntestazioneDati intestazioneDati = new WsAnagrafe.IntestazioneDati('attivita', 'nome', 'cognome');
    Test.stopTest();
    System.assertEquals('attivita', intestazioneDati.attivita);
    System.assertEquals('nome', intestazioneDati.nome);
    System.assertEquals('cognome', intestazioneDati.cognome);
  }

  @isTest
  static void testPrivacy() {
    Account a = TestUtils.creaAccount('TestAccount');
    a.DataInserimentoConsensi__c = DateTime.now();
    a.ConsensoAllaProfilazione__c = true;
    a.ConsensoAttivitaPromRicercheMercato__c = false;
    a.ConsensoAttivitaPromozionaleTerzi__c = false;
    a.ConsensoProdottiBancaRicercheMercato__c = false;
    a.ConsensoProdottiSocietaTerze__c = false;
    a.ConsensoSoloModalitaTradizionali__c = false;
    update a;

    Test.startTest();
    WsAnagrafe.TabellaPrivacy tabellaPrivacy = new WsAnagrafe.TabellaPrivacy(a);
    Test.stopTest();

    System.assertEquals(6, tabellaPrivacy.elementoPrivacy.size());
    System.assertEquals(Integer.valueOf(K.CONSENSO_PROFILAZIONE), tabellaPrivacy.elementoPrivacy[0].codiceDato);
    System.assertEquals('S', tabellaPrivacy.elementoPrivacy[0].consenso);
    System.assertEquals(Integer.valueOf(K.CONSENSO_PROD_MKT), tabellaPrivacy.elementoPrivacy[1].codiceDato);
    System.assertEquals('N', tabellaPrivacy.elementoPrivacy[1].consenso);
    System.assertEquals(Integer.valueOf(K.CONSENSO_PROD_TERZI), tabellaPrivacy.elementoPrivacy[2].codiceDato);
    System.assertEquals('N', tabellaPrivacy.elementoPrivacy[2].consenso);
    System.assertEquals(Integer.valueOf(K.CONSENSO_PROMOZ_MKT), tabellaPrivacy.elementoPrivacy[3].codiceDato);
    System.assertEquals('N', tabellaPrivacy.elementoPrivacy[3].consenso);
    System.assertEquals(Integer.valueOf(K.CONSENSO_PROMOZ_TERZI), tabellaPrivacy.elementoPrivacy[4].codiceDato);
    System.assertEquals('N', tabellaPrivacy.elementoPrivacy[4].consenso);
    System.assertEquals(Integer.valueOf(K.CONSENSO_MOD_TRADIZ), tabellaPrivacy.elementoPrivacy[5].codiceDato);
    System.assertEquals('N', tabellaPrivacy.elementoPrivacy[5].consenso);
  }

}