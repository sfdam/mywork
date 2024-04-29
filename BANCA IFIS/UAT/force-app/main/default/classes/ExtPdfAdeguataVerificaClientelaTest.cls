/**
* Progetto:         Banca IFIS
* Sviluppata il:    19/01/2017
* Developer:        Giuliani Luigi
*/

@isTest
public with sharing class ExtPdfAdeguataVerificaClientelaTest {

  @testSetup
  static void dataSetup() {

    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();

    Account a1 = TestUtils.creaAccount('AccountCompleto', 'MI', '02213390343', 'rsscld50r15h501y');
    Contact c1 = TestUtils.creaReferente(a1, 'aaaaaa11a11a111a');
    Contact c2 = TestUtils.creaReferente(a1, 'bbbbbb11b11b111b');
    Opportunity o = TestUtils.CreaOpportunity(a1, 'test');
    NDGLinea__c ndg = testUtils.CreaNGDLineaTitolare(c1, o, false);
    NDGLinea__c ndgEsecutore = testUtils.CreaNGDLineaTitolare(c2, o, true);
    NDGLinea__c ndgTitolare = testUtils.CreaNGDLinea(c1, o);
    ndgTitolare.Tipo__c = 'Esecutore adeguata verifica';
    update ndgTitolare;

    Prodotto__c prod1 = TestUtils.creaProdotto('Mutuo', 'codiceProd', K.CODPROD_MUTUO, 'Prodotto bancario', 'Factoring');
    Prodotto__c prod2 = TestUtils.creaProdotto('Fido di cassa', 'codiceProd', K.CODPROD_FIDO, 'Prodotto di supporto', 'Factoring');
    Prodotto__c prod3= TestUtils.creaProdotto('Con proroga', 'codiceProd', K.CODPROD_CON_PROROGA, 'Factoring indiretto', 'Factoring');
    Prodotto__c prod4 = TestUtils.creaProdotto('IFIS Impresa', 'codiceProd', K.CODPROD_IFIS_IMPRESA, 'Prodotto bancario', 'Factoring');

    Map<String, SObject> types = U.getRecordTypes('Linea__c');
    List<Linea__c> linee = new List<Linea__c>();
    //TODO COLLEGARE PRODOTTI!!
    linee.add( new Linea__c(RecordTypeId = types.get('Fido').Id, Opportunity__c = o.id, FinalitaMutuo__c='test', Prodotto__c = prod1.Id) );
    linee.add( new Linea__c(RecordTypeId = types.get('Fido').Id, Opportunity__c = o.id, Prodotto__c = prod2.Id, Importo__c=1000) );
    linee.add( new Linea__c(RecordTypeId = types.get('Fido').Id, Opportunity__c = o.id, Prodotto__c = prod3.Id, DurataDilazione__c=10) );
    linee.add( new Linea__c(RecordTypeId = types.get('Fido').Id, Opportunity__c = o.id, Prodotto__c = prod4.Id, FinalitaMutuo__c='test') );
    insert linee;
  }

  @isTest
  static void testVerificaSeIndirizziUguali() {

    Account a1 = new Account();
    a1.ShippingCity = 'Milano';
    a1.ShippingStreet = 'via della Spiga 1';
    a1.ShippingPostalCode = '12345';

    Account a2 = new Account();
    a2.ShippingCity = 'Milano';
    a2.ShippingStreet = 'via della Spiga 1';
    a2.ShippingPostalCode = '12345';

    //caso 1: indirizzi uguali
    test.startTest();
    boolean answer = ExtPdfAdeguataVerificaClientela.verificaSeIndirizziUguali(a1.ShippingCity, a1.ShippingStreet, a1.ShippingPostalCode,
        a2.ShippingCity, a2.ShippingStreet, a2.ShippingPostalCode);
    System.assertEquals(TRUE, answer);
    //caso 2: con maiuscole e spazi
    a2.ShippingCity = 'MILANO';
    a2.ShippingStreet = 'Via della       Spiga 1';
    a2.ShippingPostalCode = ' 12345 ';
    answer = ExtPdfAdeguataVerificaClientela.verificaSeIndirizziUguali(a1.ShippingCity, a1.ShippingStreet, a1.ShippingPostalCode,
        a2.ShippingCity, a2.ShippingStreet, a2.ShippingPostalCode);
    System.assertEquals(TRUE, answer);
    //caso 3: città diversi
    a2.ShippingCity = 'TORINO';
    a2.ShippingStreet = 'via della Spiga 1';
    a2.ShippingPostalCode = '12345';
    answer = ExtPdfAdeguataVerificaClientela.verificaSeIndirizziUguali(a1.ShippingCity, a1.ShippingStreet, a1.ShippingPostalCode,
        a2.ShippingCity, a2.ShippingStreet, a2.ShippingPostalCode);
    System.assertEquals(FALSE, answer);
    //caso 4: via diversa
    a2.ShippingCity = 'Milano';
    a2.ShippingStreet = 'via Garibaldi 13';
    a2.ShippingPostalCode = '12345';
    answer = ExtPdfAdeguataVerificaClientela.verificaSeIndirizziUguali(a1.ShippingCity, a1.ShippingStreet, a1.ShippingPostalCode,
        a2.ShippingCity, a2.ShippingStreet, a2.ShippingPostalCode);
    System.assertEquals(FALSE, answer);
    //caso 5: codice postale diverso
    a2.ShippingCity = 'Milano';
    a2.ShippingStreet = 'via della Spiga 1';
    a2.ShippingPostalCode = '99999';
    answer = ExtPdfAdeguataVerificaClientela.verificaSeIndirizziUguali(a1.ShippingCity, a1.ShippingStreet, a1.ShippingPostalCode,
        a2.ShippingCity, a2.ShippingStreet, a2.ShippingPostalCode);
    System.assertEquals(FALSE, answer);
    test.stopTest();
  }

  @isTest
  static void testPopolaDatiCliente() {

    Opportunity opp = [SELECT id, Account.CF__c, Account.PIVA__c, Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Account.ShippingStreet, Account.ShippingCity, Account.ShippingPostalCode FROM Opportunity LIMIT 1];
    test.startTest();
    PageReference ref = new PageReference('/apex/PdfAdeguataVerificaClientela');
    ref.getParameters().put('id', String.valueOf(opp.Id));
    Test.setCurrentPage(ref);

    ApexPages.StandardController sc = new ApexPages.StandardController(opp);
    ExtPdfAdeguataVerificaClientela ctr = new ExtPdfAdeguataVerificaClientela(sc);
    test.stopTest();
    //verifico estrazione 2 contact
    System.assertEquals(2, ctr.titolariSize);
    //verifico estrazione cf e piva cliente
    String s = '02213390343';
    System.assertEquals(s.split(''), ctr.PIVACliente);
    s = 'rsscld50r15h501y';
    System.assertEquals(s.split(''), ctr.CFCliente);
    //verifico estrazione lineee
    System.assertNotEquals(null, ctr.lineeMutuo);
    System.assertNotEquals(null, ctr.lineaFidoDiCassa);
    System.assertEquals(1000, ctr.lineaFidoDiCassa.importo);
    System.assertNotEquals(null, ctr.lineaPlafondProroga);
    System.assertEquals(10, ctr.lineaPlafondProroga.durataDilazione);
    System.assertNotEquals(null, ctr.lineaIfisImpresa);
    //verific estrazione corretto esecutore
    NDGLinea__c ndgTit = [SELECT Id FROM NDGLinea__c WHERE Tipo__c = 'Esecutore adeguata verifica'];
    // System.assertEquals(ndgTit.id, ctr.esecutore.id); //todo test: sistemare
  }

  @isTest
  public static void testExtPdfAdeguataVerificaClientela() {

    Opportunity opp = [
      SELECT Id,
      Account.CF__c,
      Account.PIVA__c,
      Account.BillingStreet,
      Account.BillingCity,
      Account.BillingPostalCode,
      Account.ShippingStreet,
      Account.ShippingCity,
      Account.ShippingPostalCode
      FROM Opportunity
      LIMIT 1];

    Test.setCurrentPage(Page.PdfAdeguataVerificaClientela);
    ApexPages.currentPage().getParameters().put('id', opp.Id);

    Test.startTest();
    ExtPdfAdeguataVerificaClientela epavc = new ExtPdfAdeguataVerificaClientela();
    Test.stopTest();

    System.assertEquals(opp.Id, epavc.o.Id);

  }

}