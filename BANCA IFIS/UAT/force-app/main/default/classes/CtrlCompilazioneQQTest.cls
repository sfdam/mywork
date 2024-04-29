@isTest
private class CtrlCompilazioneQQTest
{
  @TestSetup
  static void dataSetup() {

    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();
    Account a = TestUtils.creaAccount('A',dora);
    //Nesessario per confermare il qq
    // a.NDGGruppo__c = '123456';
    update a;
    QuestionarioQualitativo__c qq = TestUtils.creaQQ(a);
    TestUtils.creaEndpointServizi();
  }

  @isTest
  static void testInstance(){
    QuestionarioQualitativo__c qq = [SELECT Id, Opportunita__c, Account__c FROM QuestionarioQualitativo__c][0];
    CtrlCompilazioneQQ ctrl = new CtrlCompilazioneQQ(new ApexPages.StandardController(qq));
    System.assertEquals(qq.Id, ctrl.qq.Id);
    ctrl.backAndRefresh();
  }

  @isTest
  static void testGetModelloModulo(){
    System.assertEquals(6, CtrlCompilazioneQQ.getModelloModulo('aaa').size());
  }


  @isTest
  static void testFetchQQ()
  {
    Account a = [SELECT Id FROM Account WHERE Name = 'A'];
    QuestionarioQualitativo__c qq = [SELECT Id FROM QuestionarioQualitativo__c WHERE Account__c = :a.id];
    CtrlCompilazioneQQ.InputObj inp1 = new CtrlCompilazioneQQ.InputObj(a.id, qq.id);
    CtrlCompilazioneQQ.InputObj inp2 = new CtrlCompilazioneQQ.InputObj(a.id, null);

    Test.startTest();
    //test con qq id non vuoto
    CtrlCompilazioneQQ.OutputObj qqRecuperato = CtrlCompilazioneQQ.fetchQQ(inp1);
    System.assertEquals(qqRecuperato.qq.id, qq.id);
    System.assertEquals('domanda test',qqRecuperato.domande[0].domanda);

    //test con qq id vuoto
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_DATI_BILANCIO));
    //FIXME
    /*qqRecuperato = CtrlCompilazioneQQ.fetchQQ(inp2);
    System.assertEquals(qqRecuperato.qq.Account__c, a.id);*/
    Test.stopTest();
  }


  @isTest
  static void testRecuperaQQ()
  {
    Account a = [SELECT Id FROM Account WHERE Name = 'A'];
    QuestionarioQualitativo__c qq = [SELECT Id FROM QuestionarioQualitativo__c WHERE Account__c = :a.id];

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_DATI_BILANCIO));
    System.assertEquals(6, CtrlCompilazioneQQ.recuperaQQ('11','Small Business').size());
    Test.stopTest();
  }

  @isTest
  static void testFetchAltriQQ()
  {
    Account a = [SELECT Id FROM Account WHERE Name = 'A'];
    QuestionarioQualitativo__c qq = [SELECT Id FROM QuestionarioQualitativo__c WHERE Account__c = :a.id];
    CtrlCompilazioneQQ.InputObj inp1 = new CtrlCompilazioneQQ.InputObj(a.id, qq.id);
    TestUtils.creaQQ(a);

    Test.startTest();
    //test con qq id non vuoto
    List<QuestionarioQualitativo__c> qqRecuperati = CtrlCompilazioneQQ.fetchAltriQQ(inp1);
    System.assertEquals(1, qqRecuperati.size());
  }

  @isTest
  static void testSalvaQQ()
  {
    Account a = [SELECT Id FROM Account WHERE Name = 'A'];
    QuestionarioQualitativo__c qq = [SELECT Id, Account__c, NomeModello__c, Stato__c FROM QuestionarioQualitativo__c WHERE Account__c = :a.id];
    qq.Stato__c = 'Confermato';
    update qq;
    Map<Integer,CtrlCompilazioneQQ.Domanda[]> domande = new Map<Integer,CtrlCompilazioneQQ.Domanda[]>();
    List<CtrlCompilazioneQQ.Domanda> domandeInner = new List<CtrlCompilazioneQQ.Domanda>();
    domande.put(1,domandeInner);
    CtrlCompilazioneQQ.Domanda domanda = new CtrlCompilazioneQQ.Domanda();
    domandeInner.add(domanda);
    domanda.codiceDatoDomanda =  66000;
    domanda.codiceModulo =  66000;
    domanda.domanda =  'nuova risposta1';
    domanda.dominio =  new List<CtrlCompilazioneQQ.DominioRisposta>();
    domanda.value = 'BBBB';

    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_MODIFICA_DATI_AGGIUNTIVI_QQ));
    Test.startTest();
    CtrlCompilazioneQQ.salvaQQ(domande, qq);
    Test.stopTest();

    QuestionarioQualitativo__c qqAggiornato = [SELECT Id, Payload__c FROM QuestionarioQualitativo__c WHERE Account__c = :a.id];
    System.assertEquals(qqAggiornato.id, qq.id);
    System.assertEquals('[{"value":"BBBB","dominio":[],"domanda":"nuova risposta1","codiceModulo":66000,"codiceDatoDomanda":66000}]', qqAggiornato.Payload__c);
  }
}