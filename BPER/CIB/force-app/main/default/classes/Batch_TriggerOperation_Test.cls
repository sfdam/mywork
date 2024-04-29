@isTest
private class Batch_TriggerOperation_Test {
    @isTest
    static void unitTest() {
        List<Sobject> sobjList = new List<Sobject>();
        sobjList.add(new Account(Name='test'));
        Test.startTest();
        Batch_TriggerOperation batch = new Batch_TriggerOperation();
        batch.sObjectType = 'Account';
        batch.operationType = 'test';
        batch.sObjList = sobjList;
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void unitTest2() {
        List<Sobject> sobjList = new List<Sobject>();
        Account acc = new Account(Name='test2');
        insert acc;
        sobjList.add(acc);
        Test.startTest();
        Batch_TriggerOperation batch = new Batch_TriggerOperation();
        batch.sObjectType = 'Account';
        batch.operationType = 'update';
        batch.sObjList = sobjList;
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void unitTest3() {
        List<Sobject> sobjList = new List<Sobject>();
        Account acc = new Account(Name='test2');
        insert acc;
        sobjList.add(acc);
        Test.startTest();
        Batch_TriggerOperation batch = new Batch_TriggerOperation();
        batch.sObjectType = 'Account';
        batch.operationType = 'delete';
        batch.sObjList = sobjList;
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void unitTest4() {
        List<Sobject> sobjList = new List<Sobject>();
        Account acc = new Account(Name='test2');
        sobjList.add(acc);
        Test.startTest();
        Batch_TriggerOperation batch = new Batch_TriggerOperation();
        batch.sObjectType = 'Account';
        batch.operationType = 'insert';
        batch.sObjList = sobjList;
        Database.executeBatch(batch);
        Test.stopTest();
    }
}