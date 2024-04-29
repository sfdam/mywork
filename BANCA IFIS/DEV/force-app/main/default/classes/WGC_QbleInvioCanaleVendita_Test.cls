@isTest
public class WGC_QbleInvioCanaleVendita_Test {

    @isTest
    public static void costruttore_test(){
        WGC_AllDataFactory.createLagKey();

        List<WGC_WSUtils_Cart.PEF40Input> listaPEF40 = new List<WGC_WSUtils_Cart.PEF40Input>();

        WGC_WsUtils_Cart.PEF40Input input = new WGC_WsUtils_Cart.PEF40Input();
        input.codiceIstituto3N = 881;
        input.codNdg = 111;
        input.numLineaCredito = 111;
        input.codCanale = '111';

        listaPEF40.add(input);

        Test.setMock(HttpCalloutMock.Class, new WGC_HttpRequestController_MockImpl());

        WGC_QbleInvioCanaleVendita costruttore = new WGC_QbleInvioCanaleVendita(listaPEF40);
        Test.startTest();
        System.enqueueJob(costruttore);
        Test.stopTest();

    }

    @isTest
    public static void costruttore_vuoto_test(){
        List<WGC_WSUtils_Cart.PEF40Input> listaPEF40_empty = new List<WGC_WSUtils_Cart.PEF40Input>();

        Test.startTest();
        System.enqueueJob(new WGC_QbleInvioCanaleVendita(listaPEF40_empty));
        Test.stopTest();
    }
}