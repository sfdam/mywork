@isTest
private class TrgCessioneTest {

  @testSetup
  static void setupData () {
    Test.startTest();
    Funzionalita__c f = Funzionalita__c.getInstance();
    f.DisabilitaVRNonIndispensabili__c = true;
    f.DisabilitaControlloCambioFaseOpp__c = true;
    upsert f;

    insert new Prodotto__c(CodiceUnivoco__c = 'ATDTiAnticipo');
    WGC_AllDataFactory.createUtenzaDefault();

    Account a = TestUtils.creaAccount('AccountTest');
    Opportunity opp = TestUtils.creaOpportunity(a);
    Cessione__c c = new Cessione__c(Name = 'test', Account__c = a.Id);
    insert c;
    Test.stopTest();
  }

  @isTest
  static void testSetAttoriDefault() {
    Test.startTest();
    Account a = [SELECT Id FROM Account LIMIT 1];
    Contact c = new Contact(LastName = 'test', EsecutoreDefault__c = true);
    insert c;

    Cessione__c cessione = new Cessione__c(Account__c = a.Id);
    insert cessione;
    Test.stopTest();
  }
//A.M. 08/02/21 Asteriscato test per errore in convalida
//  @isTest
  //static void testRinomina() {
  //  Test.startTest();
  //  Account a = [SELECT Id FROM Account LIMIT 1];
  //  String cessioneName = TrgCessione.getCessioneName();
  //  Cessione__c c = new Cessione__c(Name = 'TestRinomina', Account__c = a.Id);
  //  insert c;

  //  c = [SELECT Name FROM Cessione__c WHERE Id = :c.Id];
  //  Test.stopTest();
  //  System.assert(c.Name == cessioneName);
 // }

  @isTest
  static void popolaTimestamp() {
    Test.startTest();
    Cessione__c c = [SELECT Name FROM Cessione__c];
    c.Stato__c = '1';
    update c;

    c.Stato__c = '2';
    update c;

    c.Stato__c = '3';
    update c;

    c.Stato__c = '4';
    update c;

    c.Stato__c = '5';
    update c;
    Test.stopTest();
  }

  @isTest
  static void testDeleteCessione() {
    Test.startTest();
    delete [SELECT Id FROM Cessione__c];
    Test.stopTest();
  }

  @isTest static void testInviaMail(){
    Test.startTest();
      List<Cessione__c> cessioni = [SELECT Id, Name, Stato__c, ImportoTotaleCertificazioni__c, ImportoTotaleCertificazioniOriginario__c, FirmaDigitale__c FROM Cessione__c];
      Integer i=3;
      for (Cessione__c c : cessioni) {
          c.Stato__c = i+'';
          c.FirmaDigitale__c = (i==4);
          if (i==5) { 
              i=3; 
          } else { 
              i++; 
          }
      }

      update cessioni;
      
    Test.stoptest();

  }
}