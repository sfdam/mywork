@isTest
public class WGC_Test_PosizioneController {

    @isTest
    public static void Test_getRecordData(){
        //Creo i dati di test
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        // Integer rand = Integer.valueOf(Math.random());
        // Account acc = new Account();
        // acc.Name = 'Test_Account'+rand;
        // acc.CodiceIstituto3N__c= '881';
        // acc.NDGGruppo__c= '107499';
        // insert acc;

        EndpointServizi__c endpoint = EndpointServizi__c.getInstance('settings');
        System.debug('@@@ endpoint ' + JSON.serialize(endpoint) );

        List<WGC_Linea_Prodotto__c> prods = WGC_AllDataFactory.createLineaProdotti(1, true);

        Account acc = [SELECT Id, Name FROM Account LIMIT 1];

        String titleFactoring = 'FACTORING CEDENTE';
        String titleLending = 'LENDING';
        String titleLeasing = 'LEASING';
        String titleAltro = 'ALTRO';

        RecordType rtFactCed = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'FACTORINGCEDENTE'];
        RecordType rtPdrCed = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'FACTORINGPIANIDIRIENTROCEDENTE'];
        RecordType rtPdrDeb = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'FACTORINGPIANIDIRIENTRODEBITORE'];
        RecordType rtConfDeb = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'CONFIRMINGDEBITORE'];
        RecordType rtPlafDeb = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'PLAFONDDEBITORE'];
        RecordType rtFin = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'FINANZIAMENTI'];
        RecordType rtLeas = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'LEASING'];
        RecordType rtCC = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'CONTICORRENTI'];
        RecordType rtPSR = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'ANTICIPIPACPSR'];
        RecordType rtCD = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'CONTIDEPOSITO'];
        RecordType rtGar = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'GARANZIE'];
        RecordType rtCP = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'CREDITIPROBLEMATICI'];
        RecordType rtCDF = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'CREDITIDIFIRMA'];
        RecordType rtNPL = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'NPL'];

        WGC_Posizione__c posizioneFactoring = new WGC_Posizione__c();
        //posizioneFactoring.RecordType.Name = titleFactoring;
        posizioneFactoring.Anagrafica__c = acc.Id;
        posizioneFactoring.RecordTypeId = rtFactCed.Id;
        posizioneFactoring.Impiego__c=10;
        posizioneFactoring.Accordato__c=10;

        insert posizioneFactoring;

        WGC_Posizione__c posizioneLending = new WGC_Posizione__c();
        //posizioneLending.RecordType.Name = titleLending;
        posizioneLending.RecordTypeId = rtFin.Id;
        posizioneLending.Anagrafica__c = acc.Id;
        posizioneLending.Impiego__c=10;
        posizioneLending.Accordato__c=10;

        insert posizioneLending;

        WGC_Posizione__c posizioneLeasing = new WGC_Posizione__c();
        //posizioneLeasing.RecordType.Name = titleLeasing;
        posizioneLeasing.RecordTypeId = rtLeas.Id;
        posizioneLeasing.Anagrafica__c = acc.Id;
        posizioneLeasing.Impiego__c=10;
        posizioneLeasing.Accordato__c=10;

        insert posizioneLeasing;

        WGC_Posizione__c posizioneGaranzie = new WGC_Posizione__c();
        //posizioneGaranzie.RecordType.Name = titleGaranzie;
        posizioneGaranzie.RecordTypeId = rtGar.Id;
        posizioneGaranzie.Anagrafica__c = acc.Id;
        posizioneGaranzie.Impiego__c=10;
        posizioneGaranzie.Accordato__c=10;

        insert posizioneGaranzie;

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());

        Test.startTest();
        WGC_PosizioneController.getRecordData(acc.Id);
        WGC_PosizioneController.getPositionPercent(acc.Id);
        WGC_PosizioneController.PosizioneContainer pc = WGC_PosizioneController.getFacCedente(acc.Id);
        WGC_PosizioneController.WrapperResponse resp = WGC_PosizioneController.aggiornaCampi_Prodotti_Posizione('Posizione',acc.Id);
        Test.stopTest();

    }

    @IsTest
    static void testAggiornaCampiProdotto(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();

        List<WGC_Linea_Prodotto__c> prods = WGC_AllDataFactory.createLineaProdotti(1, true);

        RecordType rtFactCed = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'FACTORINGCEDENTE'];
        RecordType rtPdrCed = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'FACTORINGPIANIDIRIENTROCEDENTE'];
        RecordType rtPdrDeb = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'FACTORINGPIANIDIRIENTRODEBITORE'];
        RecordType rtConfDeb = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'CONFIRMINGDEBITORE'];
        RecordType rtPlafDeb = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'PLAFONDDEBITORE'];
        RecordType rtFin = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'FINANZIAMENTI'];
        RecordType rtLeas = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'LEASING'];
        RecordType rtCC = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'CONTICORRENTI'];
        RecordType rtPSR = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'ANTICIPIPACPSR'];
        RecordType rtCD = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'CONTIDEPOSITO'];
        RecordType rtGar = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'GARANZIE'];
        RecordType rtCP = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'CREDITIPROBLEMATICI'];
        RecordType rtCDF = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'CREDITIDIFIRMA'];
        RecordType rtNPL = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Posizione__c' AND DeveloperName = 'NPL'];

        Account acc = [SELECT Id, Name FROM Account LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_PosizioneController.WrapperResponse resp2 = WGC_PosizioneController.aggiornaCampi_Prodotti_Posizione('Prodotto',acc.Id);
        Test.stopTest();
        
    }
}