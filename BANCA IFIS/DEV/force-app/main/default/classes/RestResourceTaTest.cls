@isTest
private class RestResourceTaTest {

  private static String CODICE_FISCALE = 'AAAQQQ12Q12Q123Q';


  @TestSetup
  static void setupData() {
    WGC_AllDataFactory.createUtenzaDefault();
    insert new Account(Name = 'test', SegmentoRischio__c = '1', CF__c = CODICE_FISCALE);
    insert new Account(Name = 'test', SegmentoRischio__c = '6');

    TestUtils.creaEndpointServizi();
  }

  @isTest
  static void testRestDebitori() {
    RestDebitori.Debitore[] debitori = RestDebitori.getDebitori().debitori;
    System.assert(debitori.size() == 1);
    System.assert(debitori[0].codiceFiscale == CODICE_FISCALE);
  }

  @isTest
  static void testRestPreventivatore() {
    Date dataFattura = Date.today();

    Date d1 = dataFattura - 5;
    RestPreventivatore.PreventivatoreResponse response = RestPreventivatore.calcoloPreventivo(
          CODICE_FISCALE,
          Decimal.valueOf(5000),
          d1.day() + '/' + d1.month() + '/' + d1.year()
        );
    System.assert(response.success == false && String.isNotBlank(response.message));

    Date d2 = dataFattura + 30;
    response = RestPreventivatore.calcoloPreventivo(
                 CODICE_FISCALE,
                 Decimal.valueOf(5000),
                 d2.day() + '/' + d2.month() + '/' + d2.year()
               );
    System.assert(response.success == true && String.isBlank(response.message));
  }

  @isTest
  static void testPdfParser () {
  /*
    ContentVersion cv = new ContentVersion(Title = 'test', ContentURL = 'http://www.google.com/');
    insert cv;

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_PDF_PARTSER));
    WsRestPdfParser.ParseCertificazioneResponse response = WsRestPdfParser.parseCertificazione(cv.Id);
    Test.stopTest();

    System.assert(response.isCorrect());

    WsRestPdfParser.ParseCertificazioneResponse payload = response;
    payload.getDataPagamento();
    payload.getImportoCertificato();
    payload.getAmmontareComplessivoCredito();

    WsRestPdfParser.Fattura[] fatture = payload.fatture;
    System.assert(fatture.size() == 1);

    WsRestPdfParser.Fattura fattura = payload.fatture[0];
    fattura.getImporto();
    fattura.getImportoRiconosciuto();
    fattura.getData();
	*/
  }
}