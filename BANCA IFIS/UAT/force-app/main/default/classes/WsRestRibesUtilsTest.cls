/**
 * Questi sono fake tests
 */
@isTest
private class WsRestRibesUtilsTest {
  @testSetup
  static void testSetup() {
    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();

    Account a = TestUtils.creaAccount('A',dora);
    a.REA__c = '3333';
    a.ProvinciaCCIAA__c = '3333';
    a.CF__c = 'aaaaaa';
    update a;
    Contact c = TestUtils.creaReferente(a);
    c.lastName = 'test';
    update c;
    TestUtils.creaEndpointServizi();
  }

	@isTest static void testGetContacts() {
    Account a = [SELECT Id FROM Account LIMIT 1][0];
    WsRestRibesUtils rest = new WsRestRibesUtils();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(new List<String>{
      TestMockUtils.PAYLOAD_RIBES_INFORMAZIONIPG
    }));
    Test.startTest();
    rest.getContacts(a.Id, '3333', '33333');
    Test.stopTest();
	}

	@isTest static void testGetEventiNegativiSintetico() {
    Account a = [SELECT Id, REA__c, ProvinciaCCIAA__c, EventiNegativiIdTicket__c, NDGGruppo__c FROM Account LIMIT 1][0];
	System.debug('@@@ account ' + JSON.serialize(a));
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_EVENTI_NEGATIVI));
    Test.startTest();
    WsRestRibesUtils.getEventiNegativiSintetico(a.Id);
    //WsRestRibesUtils.getEventiNegativiAnalitico(a.Id);
    Test.stopTest();
	}
    
    @isTest static void testGetEventiNegativiAnalitico() {
    Account a = [SELECT Id, REA__c, ProvinciaCCIAA__c, EventiNegativiIdTicket__c, NDGGruppo__c FROM Account LIMIT 1][0];
	System.debug('@@@ account ' + JSON.serialize(a));
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_EVENTI_NEGATIVI));
    Test.startTest();
    //WsRestRibesUtils.getEventiNegativiSintetico(a.Id);
    WsRestRibesUtils.getEventiNegativiAnalitico(a.Id);
    Test.stopTest();
	}

	@isTest static void testUpdateBilancioSintetico() {
    Account a = [SELECT Id FROM Account LIMIT 1][0];
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_BILANCIO_SINTETICO));
    Test.startTest();
    WsRestRibesUtils.updateBilancioSintetico(a.Id);
    Test.stopTest();
	}
  
  // @isTest static void testupdateDatiAnagraficiRibesPg(){
  //   Account a = [SELECT Id, REA__c, ProvinciaCCIAA__c FROM Account LIMIT 1][0];
  //   Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_BILANCIO_SINTETICO));
  //   Test.startTest();
  //   Account ac = new WsRestRibesUtils().updateDatiAnagraficiRibesPg(a);
  //   Test.stopTest();
  // }
}