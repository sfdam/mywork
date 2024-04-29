@isTest
private class WsRestCrmTest {

  @testSetup
  static void testSetup() {
    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();
    Account acc = TestUtils.creaAccount('Accaunt', dora, 'MI', '02213390343', 'rsscld50r15h501y', 'Prospect', '4321');
    Opportunity opp = TestUtils.CreaOpportunity(acc, 'Opportiuniti');
    TestUtils.creaEndpointServizi();
  }

  @isTest
  static void testNvAggiornamentoInnescaVendita() {
    WsRestCrm.NvAggiornamentoInnescaVenditaInput input = new WsRestCrm.NvAggiornamentoInnescaVenditaInput();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_NV_AGGIORNAMENTO_INNESCA_VENDITA));

    Test.startTest();
      WsRestCrm.NvAggiornamentoInnescaVenditaResponse response = WsRestCrm.NvAggiornamentoInnescaVendita(input, null);
    Test.stopTest();

    System.assert(response.isCorrect());
  }

  @isTest
  static void testNvInquiryStatoCartella() {
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_NV_INQUIRY_STATO_CARTELLA));

    Test.startTest();
      WsRestCrm.NvInquiryStatoCartellaResponse response = WsRestCrm.NvInquiryStatoCartella('881/00010/2017/000130');
    Test.stopTest();

    System.assert(response.isCorrect());
  }

  @isTest
  static void testRenderPdf() {
    WsRestCrm.RenderPdfInput input = new WsRestCrm.RenderPdfInput();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RENDER_PDF));

    Test.startTest();
      WsRestCrm.RenderPdfResponse response = WsRestCrm.RenderPdf(input);
    Test.stopTest();

    System.assert(response.isCorrect());
  }

}