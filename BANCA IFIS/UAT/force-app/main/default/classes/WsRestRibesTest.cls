@isTest
private class WsRestRibesTest {

  @testSetup
  static void testSetup() {
    TestUtils.creaEndpointServizi();
  }

  @isTest
  static void testStub() {
    WsRestRibes.GetListaAziendeResponse r1 = new WsRestRibes.GetListaAziendeResponse();
    System.assert(!r1.isCorrect());
    r1.payload = new WsRestRibes.Payload();
    System.assert(r1.isCorrect());

    WsRestRibes.GetInformazioniPGResponse r2 = new WsRestRibes.GetInformazioniPGResponse();
    System.assert(!r2.isCorrect());
    r2.payload = new WsRestRibes.Payload();
    r2.impresa = new WsRestRibes.AziendaFull();
    System.assert(r2.isCorrect());
    System.assert(r2.getImpresa() != null);
  }

  @isTest
  static void testGetListaAziende() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE_NOT_CESSATA));
    WsRestRibes.GetListaAziendeResponse response = WsRestRibes.getListaAziende('test', 'test', null);
    Test.stopTest();
    System.assert(response.isCorrect());
    System.assert(response.getAziende() != null && response.getAziende().size() == 1);
    System.assert(response.getAziende()[0].getFormaGiuridica() != null);
  }

  @isTest
  static void testGetInformazioniPG() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_INFORMAZIONIPG));
    WsRestRibes.GetInformazioniPGResponse response = WsRestRibes.getInformazioniPG('test', 'test');
    Test.stopTest();
    System.assert(response.isCorrect());
    System.assert(response.getImpresa() != null);
    System.assert(String.isNotBlank((response.getImpresa()).getAteco()));
  }
}