@isTest
public with sharing class WGC_WsRestCrmUtils_Test {
    @isTest
    public static void test_addNewParameters(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        Opportunity o = WGC_AllDataFactory.createOpportunity(1, true).get(0);
        WsRestCrm.NvAggiornamentoInnescaVenditaInput input = new WsRestCrm.NvAggiornamentoInnescaVenditaInput();

        Test.startTest();
        WGC_WsRestCrmUtils.addNewParameters(input,o.Id);
        Test.stopTest();

    }
}