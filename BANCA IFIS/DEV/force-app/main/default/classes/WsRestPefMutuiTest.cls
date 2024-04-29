@isTest
private class WsRestPefMutuiTest {
  // TODO: completare

  @testSetup
  static void testSetup() {
    TestUtils.creaEndpointServizi();
    TestUtils.impostaCS();
  }

  @isTest
  static void testPeriodiBilanciCensiti() {
    Test.startTest();
      Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_PERIODI_BILANCI_CENSITI));
      WsRestPefMutui.PeriodiBilanciCensitiResponse response = WsRestPefMutui.PeriodiBilanciCensiti(new WsRestPefMutui.PeriodiBilanciCensitiInput());
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testStatoCartella() {
    Test.startTest();
      Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_STATO_CARTELLA));
      WsRestPefMutui.StatoCartellaResponse response = WsRestPefMutui.StatoCartella(new WsRestPefMutui.StatoCartellaInput());
    Test.stopTest();
    System.assert(response.isCorrect());
  }

  @isTest
  static void testCheckStatoPef() {
    Test.startTest();
      Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_CHECK_STATO_PEF));
      WsRestPefMutui.CheckStatoPefResponse response = WsRestPefMutui.CheckStatoPef(new WsRestPefMutui.CheckStatoPefInput());
    Test.stopTest();
    System.assert(response.isCorrect());
  }

}