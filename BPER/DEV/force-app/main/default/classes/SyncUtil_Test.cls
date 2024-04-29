@isTest
private class SyncUtil_Test {

    static testMethod void myUnitTest() {
        Object o;
        Syncutil su = new SyncUtil(o);
        Test.startTest();
        Boolean isSync = SyncUtil.isSyncEnable();  
        Test.stopTest();
        System.assertEquals(true, isSync);
    }
}