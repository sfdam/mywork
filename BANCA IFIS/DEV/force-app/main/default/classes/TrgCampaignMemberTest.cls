/**
* Progetto:         Banca IFIS
* Sviluppata il:    21/10/2016
* Developer:        Zerbinati Francesco
*/

@isTest
public with sharing class TrgCampaignMemberTest {

  @testSetup
  static void dataSetup() {
    WGC_AllDataFactory.createUtenzaDefault();
    Campaign camp = TestUtils.creaCampagna();
    Campaign camp2 = TestUtils.creaCampagna('TestCampaign');
    TestUtils.CreaImpostazioni(camp2);
    User dora = TestUtils.creaUtente('dora');

    Account a = TestUtils.creaAccount('A',dora);
    a.WGC_Specialista_Factoring__c= dora.Id;
    update a;

    Lead l = TestUtils.creaLead('Stato che non fa scattare il trigger', 'ifisIdUnicoForm', 'firstName', 'lastName', 'ragioneSociale', '3393537383', 'email@email.com', '02168580120', '1', 'state', 'postalCode', 'tag', 'codiceOwner', 'messaggio', '1', 3);
    l.AccountCollegato__c = a.Id;

    update l;
    
    Contact c = TestUtils.creaReferente(a);
  }

  @isTest
  static void testCreaTaskContatto() {
    // ottengo campagna, l'account e il contatto che diventerà membro
    Account a = [SELECT Id,OwnerId FROM Account WHERE Name = 'A'];
    Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Campagna'];
    Contact c = [SELECT Id,IsReferenteCampagna__c  FROM Contact LIMIT 1];
    c.IsReferenteCampagna__c = true;
    update c;
    Campaign camp2 = [SELECT Id FROM Campaign WHERE Name = 'TestCampaign'];
    System.debug('impostazioni id '+camp2.id);
    System.debug('campagna id '+camp.id);
    // attivo campagna
    camp.DataContatto__c = Date.today();
    camp.IsActive = true;
        update camp;

    Test.startTest();

    TestUtils.creaMembroCampagna(camp, c);
    Test.stopTest();

    Task t = [SELECT Id, Subject, ActivityDate, OwnerId, WhatId, Campagna__c FROM Task WHERE Subject = 'Contatto telefonico campagna' LIMIT 1];

    /*System.assertEquals('Contatto telefonico campagna',t.Subject);
    System.assertEquals(camp.DataContatto__c,t.ActivityDate);
    System.assertEquals(a.Id,t.WhatId);
    System.assertEquals(a.OwnerId,t.OwnerId);
    System.assertEquals(camp.Id,t.Campagna__c);*/


  }

}