@isTest
public class WGC_SoggettiCollegatiController_Test {
    @isTest
    public static void Test_WGC_SoggettiCollegatiController(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(4,true);
        Test.startTest();
        WGC_SoggettiCollegatiController.getSogettiCollegati(listAcc.get(0).Id,'Competitors');
        WGC_SoggettiCollegatiController.getSogettiCollegati(listAcc.get(1).Id,'Vicinanza geografica');
        WGC_SoggettiCollegatiController.getSogettiCollegati(listAcc.get(2).Id,'Tribunali');
        WGC_SoggettiCollegatiController.getSogettiCollegati(listAcc.get(3).Id,'Gruppi');
        WGC_SoggettiCollegatiController.getSogettiCollegati(null, null);

        Test.stopTest();
    }
}