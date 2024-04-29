@isTest
public with sharing class WGC_EditAccount_Test {

    @isTest
    public static void Test_WGC_EditAccount(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(1,true);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        String acc = JSON.serialize(listAcc.get(0));
        Test.startTest();
        WGC_EditAccount.loadLayout(listAcc.get(0).Id);
    
        WGC_EditAccount.saveAccount(listAcc.get(0));
        
        Test.stopTest();
    }
}