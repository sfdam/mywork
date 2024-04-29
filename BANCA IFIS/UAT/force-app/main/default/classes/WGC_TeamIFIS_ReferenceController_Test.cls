@isTest
public class WGC_TeamIFIS_ReferenceController_Test {
    @isTest
    public static void Test_WGC_TeamIFIS_ReferenceController(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(2,true);
        Id testId1 = Id.valueOf(listAcc.get(0).Id);
        Id testId2 = Id.valueOf(listAcc.get(1).Id);

        WGC_Link_Legal_Entity__c testLegEnt = new WGC_Link_Legal_Entity__c();
        testLegEnt.NDG__c='107400';
        testLegEnt.NDG_collegato__c='107400';
        testLegEnt.Anagrafica__c = listAcc.get(0).Id;
        testLegEnt.Anagrafica_collegata__c=listAcc.get(0).Id;
        testLegEnt.Cod_ist__c='889';
        testLegEnt.Cod_ist_collegato__c='889';
        insert testLegEnt;


        Test.startTest();
        WGC_TeamIFIS_ReferenceController.getAddressInfo(listAcc.get(0).id);
        WGC_TeamIFIS_ReferenceController.getUserReferenceFromAccount(testId1);
        WGC_TeamIFIS_ReferenceController.getUserReferenceFromAccount(testId2);
        WGC_TeamIFIS_ReferenceController.userIsSpecialista(listAcc.get(0).id);
        Test.stopTest();
    }

    @isTest
    public static void Test_WGC_TeamIFIS_ReferenceController2(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(2,true);
        Id testId1 = Id.valueOf(listAcc.get(0).Id);
        Id testId2 = Id.valueOf(listAcc.get(1).Id);

        WGC_Link_Legal_Entity__c testLegEnt = new WGC_Link_Legal_Entity__c();
        testLegEnt.NDG__c='107499';
        testLegEnt.NDG_collegato__c='107499';
        testLegEnt.Anagrafica__c = listAcc.get(0).Id;
        testLegEnt.Anagrafica_collegata__c=listAcc.get(0).Id;
        testLegEnt.Cod_ist_collegato__c = '889';
        testLegEnt.Cod_ist__c = '889';
        insert testLegEnt;


        Test.startTest();
        WGC_TeamIFIS_ReferenceController.getUserReferenceFromAccount(testId2);
        Test.stopTest();
    }
}