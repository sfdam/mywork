@isTest
public with sharing class WGC_LegalEntity_Utility_Test {
    
    @isTest
    public static void Test_getLinkLegalEntity(){
		WGC_AllDataFactory.disattivaTrigger();
        Account testAcc = WGC_AllDataFactory.createAccount(1,true).get(0);

        WGC_Link_Legal_Entity__c testLegEnt = new WGC_Link_Legal_Entity__c();

        testLegEnt.NDG__c='107499';
        testLegEnt.NDG_collegato__c='107499';
        testLegEnt.Anagrafica__c = testAcc.Id;
        testLegEnt.Anagrafica_collegata__c=testAcc.Id;
        testLegEnt.Cod_ist__c='889';
        testLegEnt.Cod_ist_collegato__c='889';
        insert testLegEnt;

        Test.startTest();
        WGC_LegalEntity_Utility.getLinkLegalEntity('107499','881');
        WGC_LegalEntity_Utility.getLinkLegalEntity('107499','889');
        WGC_LegalEntity_Utility.getLinkLegalEntity(null,null);
        Test.stopTest();
    }


    // FARE SECONDO METODO CHE ENTRA NELL'ELSE FINALE
    @isTest
    public static void Test_getAllAccount(){
		WGC_AllDataFactory.disattivaTrigger();
        Account testAcc = WGC_AllDataFactory.createAccount(1,true).get(0);

        WGC_Link_Legal_Entity__c testLegEnt = new WGC_Link_Legal_Entity__c();

        testLegEnt.NDG__c='107499';
        testLegEnt.NDG_collegato__c='107499';
        testLegEnt.Anagrafica__c = testAcc.Id;
        testLegEnt.Anagrafica_collegata__c=testAcc.Id;
        testLegEnt.Cod_ist__c='881';
        testLegEnt.Cod_ist_collegato__c='881';
        insert testLegEnt;

        Test.startTest();
        WGC_LegalEntity_Utility.getAllAccount('107499','881');
        Test.stopTest();
    }
}