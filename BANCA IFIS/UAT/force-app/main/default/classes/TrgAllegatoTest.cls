@isTest
private class TrgAllegatoTest {
	@isTest
	static void testTriggerAllegato() {
    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();
    Account a = TestUtils.creaAccount('A',dora);
    // a.NDGGruppo__c = '3333';
    update a;
    Opportunity opp = TestUtils.CreaOpportunity(a);


    Test.startTest();
    Allegato__c allegato = TestUtils.creaAllegato(opp, 'RSFFirm');
    System.debug(allegato);


    opp = [SELECT RSFFirmata__c FROM Opportunity WHERE Id = : opp.Id];
    System.debug(opp.RSFFirmata__c);
    System.assertEquals(true,opp.RSFFirmata__c);

    allegato.Tipo__c = 'MAVFirm';
    update allegato;

    opp = [SELECT RSFFirmata__c, MAVFirmato__c FROM Opportunity WHERE Id = : opp.Id];
    System.assertEquals(true, opp.MAVFirmato__c);
    System.assertEquals(false, opp.RSFFirmata__c);
    Test.stopTest();

	}
}