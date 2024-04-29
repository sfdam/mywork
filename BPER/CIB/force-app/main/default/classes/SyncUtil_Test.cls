@isTest
private class SyncUtil_Test {

    static testMethod void myUnitTest() {
        Object o;
        Syncutil su = new SyncUtil(o);
        Boolean isSync = SyncUtil.isSyncEnable();  
    }
}