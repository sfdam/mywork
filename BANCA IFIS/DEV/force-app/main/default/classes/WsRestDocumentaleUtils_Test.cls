@isTest
public class WsRestDocumentaleUtils_Test {
    
    @isTest
    public static void test_inviaDocumentoSingoloQble(){
        Allegato__c allegato = new Allegato__c();
        insert allegato;
        Test.startTest();
        WsRestDocumentaleUtils.inviaDocumentoSingoloQble(allegato.Id);
        Test.stopTest();
    }
    
    /*
    @isTest
    public static void test_recuperaDocumentiAsync(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        Opportunity opp = WGC_AllDataFactory.createOpportunity(1,true).get(0);
        
        List<WsRestDocumentale.Elemento> listElementi = new List<WsRestDocumentale.Elemento>();
        WsRestDocumentale.Elemento elemento = new WsRestDocumentale.Elemento();
        listElementi.add(elemento);
        List<WsRestDocumentale.Lettore> listLettori = new List<WsRestDocumentale.Lettore>();
        WsRestDocumentale.Lettore lettore = new WsRestDocumentale.Lettore();
        listLettori.add(lettore);
        WsRestDocumentale.SearchDocumentOutput prova = new WsRestDocumentale.SearchDocumentOutput();
        prova.elemento = listElementi;
        prova.lettori = listLettori;

        System.debug('@DebugProva: '+ JSON.serialize(prova));
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WsRestDocumentaleUtils.recuperaDocumentiAsync(opp.Id);
        Test.stopTest();
    }
	*/

    @isTest
    public static void test_getDettaglioDocumento(){
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        Allegato__c allegato = new Allegato__c();
        insert allegato;

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        // WsRestDocumentaleUtils.getDettaglioDocumento(allegato.Id);
        Test.stopTest();
    }
}