@isTest
private class WsRestDocumentaleTest {
  // TODO: completare

  @testSetup
  static void testSetup() {
    TestUtils.creaEndpointServizi();
    TestUtils.impostaCS();
  }

  //TODO: sistemare test
  @isTest
  static void testAggiungiOggetti() {
    //Test.startTest();
    //  Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_AGGIUNGI_OGGETTI));
    //  WsRestDocumentale.AggiungiOggettiResponse response = WsRestDocumentale.AggiungiOggetti(new WsRestDocumentale.AggiungiOggettiCancellaOggettiInput());
    //Test.stopTest();
    //System.assert(response.isCorrect());
  }

  @isTest
  static void testCancellaOggetti() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_CANCELLA_OGGETTI));
    WsRestDocumentale.CancellaOggettiInput data = new WsRestDocumentale.CancellaOggettiInput();
    data.datiDocumento = new WsRestDocumentale.DatiDocumento();
    WsRestDocumentale.CancellaOggettiResponse response = WsRestDocumentale.cancellaOggetti(data);
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testSearchDocument() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SEARCH_DOCUMENT));
    WsRestDocumentale.SearchDocumentDettaglioOggettoInput data = new WsRestDocumentale.SearchDocumentDettaglioOggettoInput();
    data.datiDocumento = new WsRestDocumentale.DatiDocumento();
    WsRestDocumentale.SearchDocumentResponse response = WsRestDocumentale.SearchDocument(data);
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testDettaglioOggetto() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_DETTAGLIO_OGGETTO));
    WsRestDocumentale.SearchDocumentDettaglioOggettoInput data = new WsRestDocumentale.SearchDocumentDettaglioOggettoInput();
    data.datiDocumento = new WsRestDocumentale.DatiDocumento();
    WsRestDocumentale.DettaglioOggettoResponse response = WsRestDocumentale.DettaglioOggetto(data);
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testAddIndiceSpastico() {
    WsRestDocumentale.DatiDocumento datiDoc = new WsRestDocumentale.DatiDocumento();

    Test.startTest();
    datiDoc.addIndiceSpastico('nome','valore','operatore');
    Test.stopTest();

    System.assertEquals(1, datiDoc.indice.size());
    System.assertEquals(null, datiDoc.indice[0].nome);
    System.assertEquals('nome', datiDoc.indice[0].id);
    System.assertEquals('valore', datiDoc.indice[0].valore);
    System.assertEquals('operatore', datiDoc.indice[0].operatore);
  }

  @isTest
  static void testGetDocumentName() {
    String DOCUMENT_TITLE = 'DocumentTitle';
    WsRestDocumentale.Elemento elem = new WsRestDocumentale.Elemento();
    elem.indice = new WsRestDocumentale.Indice[] {};
    elem.indice.add(new WsRestDocumentale.Indice(DOCUMENT_TITLE, 'valore'));

    Test.startTest();
    String response = elem.getDocumentName();
    Test.stopTest();

    System.assertEquals('valore', response);
  }

  @isTest
  static void testGetCodiceSottoclasse() {
    String DOCUMENT_SOTTOCLASSE = 'CODICESOTTOCLASSE';
    WsRestDocumentale.Elemento elem = new WsRestDocumentale.Elemento();
    elem.indice = new WsRestDocumentale.Indice[] {};
    elem.indice.add(new WsRestDocumentale.Indice(DOCUMENT_SOTTOCLASSE, 'valore'));

    Test.startTest();
    String response = elem.getCodiceSottoclasse();
    Test.stopTest();

    System.assertEquals('valore', response);
  }

}