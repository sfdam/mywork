@isTest
public inherited sharing class NexiPaymentIntegrationCtrlTest {
    
    @TestSetup
    static void makeData(){
        EndpointServizi__c es = new EndpointServizi__c();
        es.WRT_Nexi_Ecobonus_Init__c = 'https://test.monetaonline.it/monetaweb/payment/2/xml';
        es.WRT_Nexi_Ecobonus_Redirect__c = 'https://test.monetaonline.it/monetaweb/page/hosted/2/html?paymentId=';
        es.WRT_Nexi_Notifica__c = 'https://tinexta-tinextagroup.cs105.force.com/EcoBonusWRT/services/apexrest/v1.0/NexiPaymentNotify';
        insert es;

        UtenzeDefault__c ud = new UtenzeDefault__c();
        ud.WRT_Nexi_Codice_Terminale__c = 'CodiceTerminale';
        ud.WRT_Nexi_Password_Terminale__c = 'PasswordTerminale';
        insert ud;
    }

    @isTest
    static void PaymentInitTestOk(){

        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory());

        Test.startTest();
        Map<String,Object> response = NexiPaymentIntegrationCtrl.paymentInit(1000, 'Test1', 'test@test.invalid');
        Test.stopTest();
    }

    @isTest
    static void PaymentInitTestKo(){
        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory(400, 'KO', '<error><errorcode>XYZ123</errorcode><errormessage>Invalid amount</errormessage></error>', new Map<String,String>()));

        Test.startTest();
        Map<String,Object> response = NexiPaymentIntegrationCtrl.paymentInit(1000, 'Test2', 'test@test.invalid');
        Test.stopTest();
    }

    @isTest
    static void findPaymentTestOk(){
        WRT_Transazione__c transazioneTest = new WRT_Transazione__c(Result__c = 'APPROVED', PaymentId__c = '123');
        insert transazioneTest;

        Test.startTest();
        Map<String,Object> response = NexiPaymentIntegrationCtrl.findPayment('123');
        Test.stopTest();
    }

    @isTest
    static void handlePaymentInitTest(){

        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory());

        NexiPaymentIntegrationCtrl.ActionRequest request = new NexiPaymentIntegrationCtrl.ActionRequest();
        request.amount = 100;
        request.nome = 'nome';
        request.cognome = 'cognome';
        request.email = 'test@test.it';

        Test.startTest();
            NexiPaymentIntegrationCtrl.handlePaymentInit(new List<NexiPaymentIntegrationCtrl.ActionRequest>{request});
        Test.stopTest();
    }
}