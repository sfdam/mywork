/**
* Progetto:         Banca IFIS
* Sviluppata il:    21/10/2016
* Developer:        Zerbinati Francesco
*/

@isTest
private class TrgCampagnaTest {

  @testSetup
  static void dataSetup() {
    User dora = TestUtils.creaUtente('dora');
    TestUtils.creaUtente('passe');
    TestUtils.creaUtente('mane');
    TestUtils.creaUtente('zucca');
    TestUtils.creaUtente('eloisa');

    TestUtils.impostaCS();

    Account a = TestUtils.creaAccount('A',dora);
    a.WGC_Specialista_Factoring__c= dora.Id;
   
    update a;
    Lead l = TestUtils.creaLead('Stato che non fa scattare il trigger', 'ifisIdUnicoForm', 'firstName', 'lastName', 'ragioneSociale', '3393537383', 'email@email.com', '02168580120', '1', 'state', 'postalCode', 'tag', 'codiceOwner', 'messaggio', '1', 3);
    l.AccountCollegato__c = a.Id;

    update l;

    Contact c = TestUtils.creaReferente(a);
    c.IsReferenteCampagna__c = true;
    update c;
    Campaign camp = TestUtils.creaCampagna();
    TestUtils.creaMembroCampagna(camp, c);


   

  }

  @isTest
  static void testCreazioneTask() {
    // ottengo campagna e l'account
    Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Campagna'];
    Account a = [SELECT Id,OwnerId FROM Account WHERE Name = 'A'];

    // attivo campagna
    camp.DataContatto__c = Date.today();
    camp.IsActive = true;

    Test.startTest();
    update camp;
    Test.stopTest();

    Task t = [SELECT Id, Subject, ActivityDate, OwnerId, WhatId, Campagna__c FROM Task WHERE Subject = 'Contatto telefonico campagna' LIMIT 1];

    System.assertEquals('Contatto telefonico campagna',t.Subject);
    System.assertEquals(camp.DataContatto__c,t.ActivityDate);
    System.assertEquals(a.Id,t.WhatId);
    System.assertEquals(a.OwnerId,t.OwnerId);
    System.assertEquals(camp.Id,t.Campagna__c);

  }


}