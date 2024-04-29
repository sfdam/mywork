@isTest
private class QueryBuilderTest {
  @isTest
  static void test() {
    Account acc = new Account(Name = 'Burlington');

    String query = QueryBuilder.newInstance('Account', new String[] {'Name', 'Id', 'Industry'})
      .beginFilter()
        .add('Industry', QBOp.QNOT_EQUAL, 'pippo')
        .add('CreatedDate', QBOp.QEQUAL, Datetime.newInstance(2016, 01, 01, 10, 2, 3))
        .beginOr()
          .add('Name', QBOp.QLIKE, acc.Name)
          .add('Name', QBOp.QIN, new Set<String>{'a','b'})
        .end()
        .beginOr()
          .add('Name', QBOp.QLIKE, acc.Name)
          .add('Industry', QBOp.QNOT_EQUAL, 'pippo')
        .end()
      .endFilter()
      .orderBy(new String[]{'Name','Id'})
      .setLimit(10)
      .getQuery();

    System.assertEquals('SELECT Name, Id, Industry FROM Account WHERE Industry != \'pippo\' AND CreatedDate = 2016-01-01T10:02:03.000+0100 AND (Name LIKE \'Burlington\' OR Name IN (\'a\',\'b\')) AND (Name LIKE \'Burlington\' OR Industry != \'pippo\') ORDER BY Name, Id LIMIT 10', query);
  }

  @isTest
  static void testComplex() {
    Account filtriAccount = new Account(Name = 'Account*');
    Contact c = new Contact(LastName = 'pippo');

    String query = QueryBuilder.newInstance('Account', new String[] {'Id', 'Name', 'Account__c'})
      .beginFilter()
        .add('Parent.Name', QBOp.QLIKE, filtriAccount.Name)
        .add('Parent.Type', QBOp.QEQUAL, filtriAccount.Type)
        .add('Parent.Industry', QBOp.QEQUAL, filtriAccount.Industry)
        .add('Name', QBOp.QLIKE, filtriAccount.Name)
        .add('Industry', QBOp.QEQUAL, filtriAccount.Industry, true)
        .beginCrossFilter('AccountId', 'Contact')
          .add('LastName', QBOp.QLIKE, c.LastName)
        .endCrossFilter()
        .beginCrossFilter('AccountId', 'Opportunity')
          .add('Name', QBOp.QEQUAL, null)
        .endCrossFilter(false)
        .beginCrossFilter('AccountId', 'Opportunity')
          .add('Name', QBOp.QEQUAL, null)
        .endCrossFilter(true)
      .endFilter()
      .getQuery();

    System.assertEquals('SELECT Id, Name, Account__c FROM Account WHERE Parent.Name LIKE \'Account%\' AND Name LIKE \'Account%\' AND Industry = NULL AND Id IN (SELECT Contact FROM AccountId WHERE LastName LIKE \'pippo\') AND Id IN (SELECT Opportunity FROM AccountId)', query);
  }

  @isTest
  static void testAdditionalMethods() {
    String query = QueryBuilder.newInstance('Account', new String[] {'Id'})
      .beginFilter()
        .addUntyped('Name != NULL')
        .addUntyped('Industry != NULL', false)
        .addUntyped('Industry = NULL', true)
        .beginOr()
          .add('Name', QBOp.QEQUAL, 'prova')
          .beginAnd()
            .add('Industry', QBOp.QEQUAL, 'abc')
            .add('Website', QBOp.QNOT_EQUAL, 'abc')
          .end()
        .end()
      .endFilter()
      .getQuery();

    System.assertEquals('SELECT Id FROM Account WHERE Name != NULL AND Industry = NULL AND (Name = \'prova\' OR (Industry = \'abc\' AND Website != \'abc\'))', query);
  }

  @isTest
  static void testCollections() {
    Set<String> stringSet = new Set<String>{'a','b','c'};
    List<String> stringList = new List<String>{'a','b','c'};
    Set<Id> idSet = new Set<Id>{'00158000003Nlbx','00158000003Nlbz'};
    List<Id> idList = new List<Id>{'00158000003Nlbx','00158000003Nlbz'};
    List<Date> dateList = new List<Date>{Date.newInstance(2016,01,01), Date.newInstance(2016,01,02)};
    Set<Date> dateSet = new Set<Date>{Date.newInstance(2016,01,01), Date.newInstance(2016,01,02)};
    List<Datetime> datetimeList = new List<Datetime>{Datetime.newInstance(2016,01,01,0,0,0), Datetime.newInstance(2016,01,02,0,0,0)};
    Set<Datetime> datetimeSet = new Set<Datetime>{Datetime.newInstance(2016,01,01,0,0,0), Datetime.newInstance(2016,01,02,0,0,0)};
    List<Decimal> decimalList = new List<Decimal>{10,20};
    Set<Decimal> decimalSet = new Set<Decimal>{10,20};
    List<Double> doubleList = new List<Double>{20.0,30.0};
    Set<Double> doubleSet = new Set<Double>{20.0,30.0};
    List<Integer> integerList = new List<Integer>{30,40};
    Set<Integer> integerSet = new Set<Integer>{30,40};

    String query = QueryBuilder.newInstance('Account', new String[]{'Id'})
      .beginFilter()
        .add('Id', QBOp.QEQUAL, idSet)
        .add('Id', QBOp.QEQUAL, idList)
        .add('Industry', QBOp.QIN, stringSet)
        .add('Website', QBOp.QIN, stringList)
        .add('CreatedDate', QBOp.QIN, datetimeList)
        .add('CreatedDate', QBOp.QIN, datetimeSet)
        .add('LastModifiedDate', QBOp.QIN, dateList)
        .add('LastModifiedDate', QBOp.QIN, dateSet)
        .add('TestDecimal__c', QBOp.QIN, decimalList)
        .add('TestDecimal__c', QBOp.QIN, decimalSet)
        .add('TestDouble__c', QBOp.QIN, doubleList)
        .add('TestDouble__c', QBOp.QIN, doubleSet)
        .add('TestInteger__c', QBOp.QIN, integerList)
        .add('TestInteger__c', QBOp.QIN, integerSet)
      .endFilter()
      .getQuery();

    System.assertEquals('SELECT Id FROM Account WHERE Id = (\'00158000003NlbxAAC\',\'00158000003NlbzAAC\') AND Id = (\'00158000003NlbxAAC\',\'00158000003NlbzAAC\') AND Industry IN (\'a\',\'b\',\'c\') AND Website IN (\'a\',\'b\',\'c\') AND CreatedDate IN (2016-01-01T00:00:00.000+0100,2016-01-02T00:00:00.000+0100) AND CreatedDate IN (2016-01-01T00:00:00.000+0100,2016-01-02T00:00:00.000+0100) AND LastModifiedDate IN (2016-01-01,2016-01-02) AND LastModifiedDate IN (2016-01-01,2016-01-02) AND TestDecimal__c IN (10,20) AND TestDecimal__c IN (10,20) AND TestDouble__c IN (20.0,30.0) AND TestDouble__c IN (20.0,30.0) AND TestInteger__c IN (30,40) AND TestInteger__c IN (30,40)', query);
  }
}