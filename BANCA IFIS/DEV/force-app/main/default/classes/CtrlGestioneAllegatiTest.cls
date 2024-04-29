@isTest
public class CtrlGestioneAllegatiTest {

  @isTest
  public static void testGetInputObjField() {
    String oppId = 'OPP';
    String attId = 'ATT';
    String tipo = 'TIPO';
    String famigliaDocumento = 'FAMIGLIA_DOC';
	
    CtrlGestioneAllegati.InputObj input = new CtrlGestioneAllegati.InputObj(oppId, attId, tipo, famigliaDocumento);
    CtrlGestioneAllegati.InputObj[] inputs = new CtrlGestioneAllegati.InputObj[]{input};

    Test.startTest();
    Set<String> result1 = CtrlGestioneAllegati.getInputObjField(inputs, 'oppId');
    Set<String> result2 = CtrlGestioneAllegati.getInputObjField(inputs, 'attId');
    Set<String> result3 = CtrlGestioneAllegati.getInputObjField(inputs, 'tipo');
    Set<String> result4 = CtrlGestioneAllegati.getInputObjField(inputs, 'famigliaDocumento');
    Test.stopTest();

    System.assert(result1.contains(oppId));
    System.assert(result2.contains(attId));
    System.assert(result3.contains(tipo));
    System.assert(result4.contains(famigliaDocumento));
  }

  @isTest
  public static void testFetchAllegati() {
    String oppId = 'OPP';
    String attId = 'ATT';
    String tipo = 'TIPO';
    String famigliaDocumento = 'FAMIGLIA_DOC';
    CtrlGestioneAllegati.InputObj input = new CtrlGestioneAllegati.InputObj(oppId, attId, tipo, famigliaDocumento);

    Test.startTest();
    CtrlGestioneAllegati.fetchAllegati(input);
    Test.stopTest();
  }

  @isTest
  public static void testFetchPDF() {
    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();
    Account a = TestUtils.creaAccount('A',dora);
    Opportunity opp = TestUtils.CreaOpportunity(a, 'test');

    ContentVersion cv = new Contentversion();
    cv.Title = 'Title';
    cv.PathOnClient = 'Test';
    cv.VersionData = EncodingUtil.base64Decode('Test Version Data');
    insert cv;

    Allegato__c all = TestUtils.creaAllegato(opp, 'TIPO');
    TestUtils.creaContentDocumentLink(all, cv);

    String oppId = 'OPP';
    String attId = all.Id;
    String tipo = 'TIPO';
    String famigliaDocumento = 'Documenti identità';
    CtrlGestioneAllegati.InputObj input = new CtrlGestioneAllegati.InputObj(oppId, attId, tipo, famigliaDocumento);

    Test.startTest();
    ContentDocumentLink result = CtrlGestioneAllegati.fetchPDF(input);
    Test.stopTest();

    ContentDocumentLink cdl = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :all.Id];

    System.assertEquals(cdl.Id, result.Id);
  }

  @isTest
  public static void testSalvaAllegato() {
    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();
    TestUtils.creaEndpointServizi();
    Account a = TestUtils.creaAccount('A',dora);
    Opportunity opp = TestUtils.CreaOpportunity(a, 'test');

    NDGLinea__c n = TestUtils.CreaNGDLineaTitolare(new Contact(),opp,true,'Esecutore Adeguata Verifica');
    ContentVersion cv = new Contentversion();
    cv.Title = 'Title';
    cv.PathOnClient = 'Test';
    cv.VersionData = EncodingUtil.base64Decode('Test Version Data');
    insert cv;

    String oppId = opp.Id;
    String attId = cv.Id;
    //String tipo = 'TIPO';
    String tipo = 'PrivacyPfFirm';
    String famigliaDocumento = 'Documenti identità';
    CtrlGestioneAllegati.InputObj input = new CtrlGestioneAllegati.InputObj(oppId, attId, tipo, famigliaDocumento);

    Test.startTest();
    Boolean result = CtrlGestioneAllegati.salvaAllegato(input);
    Test.stopTest();

    System.assert(result);

  }

  @isTest
  public static void testGetContentDocumentId() {
    Test.startTest();
    WGC_AllDataFactory.createUtenzaDefault();
    Account acc = TestUtils.creaAccount('acc');
    Opportunity opp = TestUtils.creaOpportunity(acc, 'opp');
    Allegato__c allegato = TestUtils.creaAllegato(opp,'tipo');
    ContentDocumentLink cont = TestUtils.creaContentDocumentLink(allegato);

    System.assertNotEquals(null,CtrlGestioneAllegati.getContentDocumentId(opp.Id,'tipo'));

    Test.stoptest();
  }
}