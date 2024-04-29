@isTest
private class CmpMagazzinoTest {

	// ATTENZIONE: CLASSE DEPRECATA DA RIMUOVERE

  @TestSetup
  static void dataSetup() {
    /*
    User utente = TestUtils.creaUtente('Utn');
	WGC_AllDataFactory.createUtenzaDefault();
    Campaign campagna = TestUtils.creaCampagna('Cmpgn1');

    Account a1 = TestUtils.creaAccount('Act1', utente, 'MI', '02213390343', 'rsscld50r15h501y', 'Cliente');
    Account a2 = TestUtils.creaAccount('Act2', utente, 'BO', '02213390344', 'rsscld50r15h501w', 'Prospect');
    Account a3 = TestUtils.creaAccount('Act3', utente, 'MB', '02213390345', 'rsscld50r15h501z', 'Prospect');

    Task t1 = TestUtils.creaTask(utente, a1, 'Subject1', 'Not Started', 'Normal', campagna);
    Task t2 = TestUtils.creaTask(utente, a2, 'Subject2', 'Not Started', 'Normal', campagna);
    Task t3 = TestUtils.creaTask(utente, a3, 'Subject3', 'Not Started', 'Normal', null);
	*/
  }

  @isTest
  static void testGetAccountList() {
    // SELECT Id, WhatId FROM Task
    // WHERE OwnerId = :userId
    //  AND Campagna__c = or != NULL
    //  AND WhatId IN (SELECT Id FROM Account WHERE RecordType.Name = :recordType
    // ORDER BY ActivityDate LIMIT 10
	
    CmpMagazzino.InterfaceAccount[] iaClienti = new List<CmpMagazzino.InterfaceAccount>();
    CmpMagazzino.InterfaceAccount[] iaProspect = new List<CmpMagazzino.InterfaceAccount>();
    CmpMagazzino.InterfaceAccount[] iaMagazzino = new List<CmpMagazzino.InterfaceAccount>();

    iaClienti = CmpMagazzino.getAccountList('clienti');
    iaProspect = CmpMagazzino.getAccountList('prospect');
    iaMagazzino = CmpMagazzino.getAccountList('magazzino');

	CmpMagazzino.InterfaceAccount iacc = new CmpMagazzino.InterfaceAccount();
	iacc.acc = null;
	iacc.priorita = 0;

	//System.assertEquals(null,iaClienti);
	//System.assertEquals(null,iaProspect);
	//System.assertEquals(null,iaMagazzino);

  }

  @isTest
  static void testResetPrioritaAccount() {
    WGC_AllDataFactory.createUtenzaDefault();
	List<Account> accList = WGC_AllDataFactory.createAccount(1, true);
    //System.assertEquals(null, CmpMagazzino.resetPrioritaAccount(accList.get(0).Id, 'Diretto'));

  }
}