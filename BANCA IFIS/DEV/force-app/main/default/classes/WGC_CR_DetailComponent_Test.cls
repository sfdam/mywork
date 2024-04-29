@isTest
public class WGC_CR_DetailComponent_Test {

    @isTest
    public static void Test_Metodo(){
        // WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault();
        //List<Account> listAcc = WGC_AllDataFactory.createAccount(1,true);
        List<WGC_Centrale_Rischi__c> listCenRis = WGC_AllDataFactory.createCentraleRischi(2,true);
        Test.startTest();
        WGC_CR_DetailComponent.getAllData(listCenRis.get(0).Anagrafica__c);
        WGC_CR_DetailComponent.getDataCR(listCenRis.get(0).Anagrafica__c);
        Test.stopTest();
    }

}