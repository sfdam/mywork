@isTest
private with sharing class WGC_WsRestFF_Test {

    @testSetup
    static void testSetup() {

        WGC_AllDataFactory.createUtenzaDefault();

        TestUtils.impostaCS();

        // creo azienda e referenti
        Account accountFEG = new Account(
                Name = 'FEG SOCIETA PER AZIONI',
                BillingStreet = 'CORSO RE UMBERTO 1',
                BillingCity = 'TORINO',
                BillingState = 'TO',
                BillingPostalCode = '10121',
                CF__c = '10798070016',
                NDGGruppo__c = '123456'
        );
        insert accountFEG;
        accountFEG.Filiale__c = '5';
        update accountFEG;

        Contact referenteMarioBalo = TestUtils.creaReferente(accountFEG, 'BLAMRA80A01F205X', 'Mario', 'Balo', '123123');
        Contact referenteMariaBala = TestUtils.creaReferente(accountFEG, 'BLAMRA80A41F205B', 'Maria', 'Bala', '321321');

        // creo opportunita' e prodotti/linee
        // Opportunity oppFEG = TestUtils.CreaOpportunity(accountFEG, 'opportunitaFEG');

        // prova
        Opportunity oppFEG = WGC_AllDataFactory.createOpportunity2(1).get(0);
        oppFEG.Name = 'opportunitaFEG';
        oppFEG.AccountID = accountFEG.Id;
        oppFEG.Owner = accountFEG.Owner;
        insert oppFEG;

        Credito__c credito = new Credito__c();
        credito.Opportunita__c = oppFEG.Id;
        credito.WGC_Invia_Credito__c = true;
        insert credito;

        // creo attori e relazioni
        NDGLinea__c debitore = TestUtils.CreaNDGLineaDebitore(referenteMarioBalo, oppFeg);
        debitore.DivisaNew__c = '242';
        debitore.Fatturato__c = 800000;
        debitore.DiCuiProsoluto__c = 50000;
        debitore.Plafond__c = 400000;
        debitore.DurataNominale__c = 15;
        upsert debitore;

        NDGLinea__c garanteOmnibus = new NDGLinea__c(
                Contact__c = referenteMariaBala.Id,
                Opportunita__c = oppFEG.Id,
                DivisaNew__c = '242',
                Fatturato__c = 20000,
                DiCuiProsoluto__c = 10000,
                Plafond__c = 1000,
                DurataNominale__c = 10
        );
        insert garanteOmnibus;

        NDGLinea__c esecutoreAdeguataVerifica = new NDGLinea__c(
                Opportunita__c = oppFEG.Id,
                Account__c = accountFEG.Id,
                Tipo__c = 'Esecutore adeguata verifica'
        );
        insert esecutoreAdeguataVerifica;

        // creo endpoint
        TestUtils.creaEndpointServizi();
    }

    @isTest
    public static void test01(){
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());
        WGC_WsRestFF.censimentoTrattativa(opps.get(0).Id,'pre');
        Test.stopTest();
    }

    @isTest
    public static void test02(){
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());
        WGC_WsRestFF.confermaTrattativa(opps.get(0).Id);
        Test.stopTest();
    }

    @isTest
    public static void test03(){
        List<Credito__c> crediti = [SELECT Id FROM Credito__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());
        WGC_WsRestFF.calcoloInteressi(crediti.get(0).Id);
        Test.stopTest();
    }

    @isTest
    public static void test04(){
        List<Credito__c> crediti = [SELECT Id FROM Credito__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());
        WGC_WsRestFF.calcoloDip(crediti.get(0).Id);
        Test.stopTest();
    }

    @isTest
    public static void test05(){
        List<Credito__c> crediti = [SELECT Id FROM Credito__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());
        WGC_WsRestFF.calcoloIrr(crediti.get(0).Id);
        Test.stopTest();
    }

    @isTest
    public static void test06(){
        List<Credito__c> crediti = [SELECT Id FROM Credito__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WGC_WsRestFFMock());
        WGC_WsRestFF.calcoloCompensi(crediti.get(0).Id);
        Test.stopTest();
    }
}