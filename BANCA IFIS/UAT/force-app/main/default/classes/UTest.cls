@isTest
private class UTest {
  @isTest
  static void testKeyBy() {
    Account[] aL = new Account[]{
      new Account(Name = 'a1', BillingStreet = 'street1'),
      new Account(Name = 'a2', BillingStreet = 'street2'),
      new Account(Name = 'a3', BillingStreet = 'street3')
    };

    Map<String, SObject> testMap = U.keyBy(aL, 'BillingStreet');
    System.assertEquals(3, testMap.size());
    System.assertEquals(true, testMap.containsKey('street1'));
    System.assertEquals(true, testMap.containsKey('street2'));
    System.assertEquals(true, testMap.containsKey('street3'));
    System.assertEquals('a1', testMap.get('street1').get('Name'));
    System.assertEquals('a2', testMap.get('street2').get('Name'));
    System.assertEquals('a3', testMap.get('street3').get('Name'));

    testMap = U.keyBy(aL, '{BillingStreet}_{nAmE}', true);
    System.assertEquals(3, testMap.size());
    System.assertEquals(true, testMap.containsKey('street1_a1'));
    System.assertEquals(true, testMap.containsKey('street2_a2'));
    System.assertEquals(true, testMap.containsKey('street3_a3'));
    System.assertEquals('a1', testMap.get('street1_a1').get('Name'));
    System.assertEquals('a2', testMap.get('street2_a2').get('Name'));
    System.assertEquals('a3', testMap.get('street3_a3').get('Name'));

    testMap = U.keyBy(aL, '{BUllingStreet}_{nAmE}', true, true);
    System.assertEquals(3, testMap.size());
    System.assertEquals(true, testMap.containsKey('_a1'));
    System.assertEquals(true, testMap.containsKey('_a2'));
    System.assertEquals(true, testMap.containsKey('_a3'));
    System.assertEquals('a1', testMap.get('_a1').get('Name'));
    System.assertEquals('a2', testMap.get('_a2').get('Name'));
    System.assertEquals('a3', testMap.get('_a3').get('Name'));
  }

  @isTest
  static void testGroupBy() {
    Account[] aL = new Account[]{
      new Account(Name = 'a1', BillingStreet = 'street1'),
      new Account(Name = 'a1', BillingStreet = 'street1'),
      new Account(Name = 'a2', BillingStreet = 'street1')
    };

    Map<String, Account[]> testMap = U.groupBy(aL, 'BillingStreet');
    System.assertEquals(1, testMap.size());
    System.assertEquals(true, testMap.containsKey('street1'));
    System.assertEquals('a1', testMap.get('street1')[0].Name);
    System.assertEquals('a1', testMap.get('street1')[1].Name);
    System.assertEquals('a2', testMap.get('street1')[2].Name);

    testMap = U.groupBy(aL, '{BillingStreet}_{nAmE}', true);
    System.assertEquals(2, testMap.size());
    System.assertEquals(true, testMap.containsKey('street1_a1'));
    System.assertEquals(true, testMap.containsKey('street1_a2'));
    System.assertEquals('a1', testMap.get('street1_a1')[0].Name);
    System.assertEquals('a1', testMap.get('street1_a1')[1].Name);
    System.assertEquals('a2', testMap.get('street1_a2')[0].Name);

    //Test estrazione su campo non definito in datamodel
    testMap = U.groupBy(aL, '{BillingStreet}_{campoInesistente__c}', true);
    System.assertEquals(1, testMap.size());
    System.assertEquals(true, testMap.containsKey('street1_null'));
    System.assertEquals('a1', testMap.get('street1_null')[0].Name);
    System.assertEquals('a1', testMap.get('street1_null')[1].Name);
    System.assertEquals('a2', testMap.get('street1_null')[2].Name);
  }

  @isTest
  static void testGetIdSet(){
    Contact[] cL = new Contact[]{
      new Contact(Id = '003g000000CxTGm', FirstName = 'fn1', LastName = 'contact1', BirthDate = Date.valueOf('1990-01-01')),
      new Contact(Id = '003g000000CxTGo', FirstName = 'fn1', LastName = 'contact3', BirthDate = Date.valueOf('1996-01-01')),
      new Contact(Id = '003g000000CxTGn', FirstName = 'fn2', LastName = 'contact2', BirthDate = Date.valueOf('1992-01-01')),
      new Contact(Id = '003g000000CxTGn', FirstName = 'fn3', LastName = 'contact4', BirthDate = Date.valueOf('1992-01-01'))
    };

    Account[] aL = new Account[]{
      new Account(Id = '001g000000CxTGm', Name = '001'),
      new Account(Id = '001g000000CxTGo', Name = '002'),
      new Account(Id = '001g000000CxTGp', Name = '003'),
      new Account(Id = '001g000000CxTGq', Name = '004')
    };

    for (Integer i = 0; i < cL.size(); i++){
      cl.get(i).Account = al.get(i);
    }

    Set<Id> idSet1 = U.getIdSet(cL, 'Id');
    Set<Id> idSet2 = U.getIdSet(cL, 'Account.Id');

    System.assert(idSet1.contains(Id.valueOf('003g000000CxTGm')));
    System.assert(idSet1.contains(Id.valueOf('003g000000CxTGo')));
    System.assert(idSet1.contains(Id.valueOf('003g000000CxTGn')));

    System.assert(idSet2.contains(Id.valueOf('001g000000CxTGm')));
    System.assert(idSet2.contains(Id.valueOf('001g000000CxTGo')));
    System.assert(idSet2.contains(Id.valueOf('001g000000CxTGp')));
    System.assert(idSet2.contains(Id.valueOf('001g000000CxTGq')));
  }

  @isTest
  static void testGetRecordTypes() {
    Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
    Map<String, SObject> rtMap2 = U.getRecordTypes('Account');

    for(SObject rt : rtMap2.values()) {
      System.assertEquals(true, rtMap.containsKey((String) rt.get('Name')));
    }
  }

  @isTest
  static void testFilter() {
    Account[] aL = new Account[]{
      new Account(Name = 'a1', BillingStreet = 'street'),
      new Account(Name = 'a2', BillingStreet = 'street'),
      new Account(Name = 'a3', BillingStreet = 'plaza')
    };

    Account[] filteredAL = U.filter(aL, 'BillingStreet', 'street');
    System.assertEquals(2, filteredAL.size());
    System.assertEquals('a1', filteredAL[0].Name);
    System.assertEquals('a2', filteredAL[1].Name);

    filteredAL = U.filter(aL, 'BillingStreet', 'street', false);
    System.assertEquals(1, filteredAL.size());
    System.assertEquals('a3', filteredAL[0].Name);

    filteredAL = U.filter(aL, 'BillingStreet', new Set<String>{'street','plaza'});
    System.assertEquals(3, filteredAL.size());
    System.assertEquals('a3', filteredAL[2].Name);

    Object objectSet = new Set<String>{'street'};
    filteredAL = U.filter(aL, 'BillingStreet', objectSet, false);
    System.assertEquals(1, filteredAL.size());
    System.assertEquals('a3', filteredAL[0].Name);
  }

  @isTest
  static void testGetSetMethods() {
    Contact[] cL = new Contact[]{
      new Contact(Id = '003g000000CxTGm', AccountId = '001g000000CxTGm', FirstName = 'fn1', LastName = 'contact1', BirthDate = Date.valueOf('1990-01-01')),
      new Contact(Id = '003g000000CxTGo', AccountId = '001g000000CxTGo', FirstName = 'fn1', LastName = 'contact3', BirthDate = Date.valueOf('1996-01-01')),
      new Contact(Id = '003g000000CxTGn', AccountId = '001g000000CxTGo', FirstName = 'fn2', LastName = 'contact2', BirthDate = Date.valueOf('1992-01-01')),
      new Contact(Id = '003g000000CxTGn', AccountId = '001g000000CxTGo', FirstName = null, LastName = 'contact4', BirthDate = Date.valueOf('1992-01-01'))
    };

    Set<Id> accountIds = U.getIdSet(cL, 'AccountId');
    System.assertEquals(2, accountIds.size());
    System.assertEquals(true, accountIds.containsAll(new Id[]{'001g000000CxTGo', '001g000000CxTGm'}));

    Set<String> firstNameSet = U.getSet(cL, 'FirstName');
    System.assertEquals(2, firstNameSet.size());
    System.assertEquals(true, firstNameSet.containsAll(new String[]{'fn1', 'fn2'}));
  }

  @isTest
  static void testReverse() {
    String[] items = new String[]{'abc', 'cde', 'fgh'};
    String[] reversed = (String[]) U.reverse(items);
    System.assertEquals('fgh', reversed[0]);
    System.assertEquals('cde', reversed[1]);
    System.assertEquals('abc', reversed[2]);

    Decimal[] numericItems = new Decimal[]{6, 3, 2, 7, 8};
    Decimal[] numericReversed = (Decimal[]) U.reverse(numericItems);
    System.assertEquals(8, numericReversed[0]);
    System.assertEquals(7, numericReversed[1]);
    System.assertEquals(2, numericReversed[2]);
    System.assertEquals(3, numericReversed[3]);
    System.assertEquals(6, numericReversed[4]);
  }

  @isTest
  static void testToMethods() {
    String[] stringList = new String[]{'abc', 'cde', 'fgh'};
    Set<String> stringSet = new Set<String>();
    stringSet.add('abc');
    stringSet.add('cde');
    stringSet.add('fgh');
    Set<Id> idSet = new Set<Id>();
    idSet.add('003g000000CxTGm');
    idSet.add('003g000000CxTGo');
    idSet.add('003g000000CxTGn');

    Set<String> convertedSet = U.toSet(stringList);
    System.assert(convertedSet.contains(stringList[0]));
    System.assert(convertedSet.contains(stringList[1]));
    System.assert(convertedSet.contains(stringList[2]));
    System.assertEquals(stringList.size(), convertedSet.size());

    String[] convertedList = U.toList(stringSet);
    System.assertEquals(stringSet.size(), convertedList.size());

    Id[] idList = U.toIdList(idSet);
    System.assertEquals(idSet.size(), idList.size());
  }

  @isTest
  static void testMassSet() {
    Account[] aL = new Account[]{
      new Account(Name = 'a1', BillingStreet = 'street1'),
      new Account(Name = 'a2', BillingStreet = 'street2'),
      new Account(Name = 'a3', BillingStreet = 'street3')
    };

    U.massSet(aL, 'PIVA__c', '000');
    System.assertEquals('000', aL[0].PIVA__c);
    System.assertEquals('000', aL[1].PIVA__c);
    System.assertEquals('000', aL[2].PIVA__c);
  }
}