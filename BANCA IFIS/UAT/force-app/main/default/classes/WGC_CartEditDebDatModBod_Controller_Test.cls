@isTest
public with sharing class WGC_CartEditDebDatModBod_Controller_Test {
    
    @isTest
    public static void test_Method() {
        User usr = TestUtils.creaUtente('User1');
        Account a = TestUtils.creaAccountDEB('Test',usr);
        a.Ateco__c = '0';
        update a;
        System.debug('acc: '+a);

        Ateco__c atecoTest = new Ateco__c(Name='Test', Status__c='0',Cedacri__c = '0');
        insert atecoTest;
        System.debug('ateco: '+atecoTest);

        Test.startTest();
            String atecoStatus = WGC_CartEditDebDataModalBody_Controller.getAtecoStatus(a.Id);
        Test.stopTest();
    }
}