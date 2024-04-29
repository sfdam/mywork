@isTest
public class WGC_Header_AttivitaController_Test {
    @isTest
    public static void Test_getActivityUser(){
        Test.startTest();
        WGC_Header_AttivitaController.getActivityUser();
        Test.stopTest();
    }

    //AdF
    @isTest
    public static void Test_getActivityUserWithParam(){
        Test.startTest();
        WGC_Header_AttivitaController.getActivityUser(UserInfo.getUserId(), 'direzione', UserInfo.getUserId(), 'utente');
        WGC_Header_AttivitaController.getActivityUser(UserInfo.getUserId(), 'direzione', '', 'utente');
        WGC_Header_AttivitaController.getActivityUser(UserInfo.getUserId(), 'direzione', '000', 'filiale');
        WGC_Header_AttivitaController.getActivityUser(UserInfo.getUserId(), 'direzione', '000;001', 'filiale');
        Test.stopTest();
    }


}