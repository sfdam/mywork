@isTest
private class ExtSfdcLookupTest {

  @testSetup
  static void dataSetup() {
    User utente = TestUtils.creaUtente('Usr');
    WGC_AllDataFactory.createUtenzaDefault();
    TestUtils.creaAccount('Act1', utente, 'MI', '02213390343', 'rsscld50r15h501y');
    TestUtils.creaAccount('Act2', utente, 'BO', '02213390344', 'rsscld50r15h501w');
    TestUtils.creaAccount('Act3', utente, 'MB', '02213390345', 'rsscld50r15h501z');
    Comune__c mi = TestUtils.creaComune('Milano', 'MI', '20121');
	mi.CodiceCatastale__c = 'F205'; 
	update mi;
    Comune__c bg = TestUtils.creaComune('Bergamo', 'BG', '24121');
	bg.CodiceCatastale__c = 'A794';
	update bg;
  }

  @isTest
  static void testSearchComuni() {

    String[] otherFields = new String[]{'Cap__c'};
    String[] valuesToExclude = null;
    String filters = '';

    Test.startTest();
    Comune__c[] results = (Comune__c[]) ExtSfdcLookup.searchComuni(
      'Name',
      'Provincia__c',
      otherFields,
      'Comune__c',
      'Milano',
      valuesToExclude
    );
    Test.stopTest();

    System.assertEquals(1, results.size());
    System.assertEquals('Milano', results[0].Name);
    System.assertEquals('MI', results[0].Provincia__c);
    System.assertEquals('20121', results[0].Cap__c);
  }

  @IsTest
  static void testSearchCodiceCatastaleComune() {
	
	String res = ExtSfdcLookup.searchCodiceCatastaleComune('Milano','MI');
	System.assertEquals('F205', res);
  }

  @isTest
  static void testSearch() {

    String[] otherFields = new String[]{'ShippingState', 'CF__c'};
    String[] valuesToExclude = new String[]{'02213390344'};
    String filters = '';

    Test.startTest();
    Account[] results = (Account[]) ExtSfdcLookup.search(
      'Name',
      'PIVA__c',
      otherFields,
      'Account',
      'Act',
      valuesToExclude
    );
    Test.stopTest();

    System.assertEquals(2, results.size());
    System.assertEquals('Act1', results[0].Name);
    System.assertEquals('02213390343', results[0].PIVA__c);
    System.assertEquals('MI', results[0].ShippingState);
    System.assertEquals('rsscld50r15h501y', results[0].CF__c);
    System.assertEquals('Act3', results[1].Name);
    System.assertEquals('02213390345', results[1].PIVA__c);
    System.assertEquals('MB', results[1].ShippingState);
    System.assertEquals('rsscld50r15h501z', results[1].CF__c);

  }

  @isTest
  static void testSearchFilters() {

    // SELECT fieldLabel, fieldValue, otherFields
    // WHERE fieldLabel LIKE value
    //   AND fieldValue NOT IN valuesToExclude
    //   AND filters
    // FROM targetObj
    // LIMIT 100

    String[] otherFields = new String[]{'ShippingState', 'CF__c'};
    String[] valuesToExclude = new String[]{'02213390344'};
    String filters = '';

    Test.startTest();
    Account[] results = (Account[]) ExtSfdcLookup.search(
      'Name',
      'PIVA__c',
      otherFields,
      'Account',
      'Act',
      valuesToExclude,
      filters
    );
    Test.stopTest();

    System.assertEquals(2, results.size());
    System.assertEquals('Act1', results[0].Name);
    System.assertEquals('02213390343', results[0].PIVA__c);
    System.assertEquals('MI', results[0].ShippingState);
    System.assertEquals('rsscld50r15h501y', results[0].CF__c);
    System.assertEquals('Act3', results[1].Name);
    System.assertEquals('02213390345', results[1].PIVA__c);
    System.assertEquals('MB', results[1].ShippingState);
    System.assertEquals('rsscld50r15h501z', results[1].CF__c);

  }

@isTest
  static void testInverseLookup() {

    // SELECT fieldLabel, fieldValue, otherFields
    // WHERE fieldValue = value
    // FROM targetObj

    String[] otherFields = new String[]{'ShippingState', 'CF__c'};

    Test.startTest();
    Account result = (Account) ExtSfdcLookup.inverseLookup('Name', 'PIVA__c', otherFields, 'Account', '02213390344');
    Test.stopTest();

    System.assertEquals('Act2', result.Name);
    System.assertEquals('02213390344', result.PIVA__c);
    System.assertEquals('BO', result.ShippingState);
    System.assertEquals('rsscld50r15h501w', result.CF__c);

  }

  @isTest
  static void testFetchStatiEsteri() {
    Comune__c c = TestUtils.creaStatoEstero('RUSSIA');

    String[] result = ExtSfdcLookup.fetchStatiEsteri();
    System.assertEquals(result[0], 'RUSSIA');
    System.assertEquals(1, result.size());
  }

  @isTest
  static void testFetchStatiEsteriFull() {
    Comune__c c = TestUtils.creaStatoEstero('RUSSIA');
    Comune__c[] result = ExtSfdcLookup.fetchStatiEsteriFull();
    System.assertEquals(result[0].Name, 'RUSSIA');
    System.assertEquals(1, result.size());
  }

  @isTest
  static void testSearchRecent() {

    // SELECT fieldLabel, fieldValue, otherFields
    // WHERE fieldValue NOT IN valuesToExclude
    // FROM targetObj
    // ORDER BY LastViewedDate DESC

    String[] otherFields = new String[]{'ShippingState', 'CF__c'};
    String[] valuesToExclude = new String[]{'02213390344'};

    Test.startTest();
    Account[] results = (Account[]) ExtSfdcLookup.searchRecent(
      'Name',
      'PIVA__c',
      otherFields,
      'Account',
      valuesToExclude
    );
    Test.stopTest();

    System.assertEquals(2, results.size());
  }

}