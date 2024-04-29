@isTest
public class WGC_IndicatoriRischio_Controller_Test {
    @isTest
    public static void Test_getAccountInfo(){
        WGC_AllDataFactory.createUtenzaDefault();
        Account acc = new Account();
        acc.name = 'test';
        insert acc;
        Account a = [SELECT Id, Name FROM Account LIMIT 1];

        Test.startTest();
        WGC_IndicatoriRischio_Controller.getAccountInfo(acc.Id);
        WGC_IndicatoriRischio_Controller.checkStatusDoc(a.id);
        Test.stopTest();
    }

}