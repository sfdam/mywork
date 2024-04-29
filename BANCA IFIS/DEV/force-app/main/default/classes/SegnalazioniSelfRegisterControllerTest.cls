@isTest
private class SegnalazioniSelfRegisterControllerTest {
    @testSetup static void setup() {
        // Creo l'account
        Account a = new Account();
        a.Name = 'TEST SPA';
        a.NaturaGiuridica__c = 'IC';
        a.BI_CodiceAccordo__c = '321';
        
        insert a;
    }
    
    @isTest static void testCheckAccordoOk() {
        SegnalazioniSelfRegisterController.checkAccordo('321');
    }

 

    @isTest static void testCheckAccordoKo() {
        SegnalazioniSelfRegisterController.checkAccordo('567');
    }
    
    @isTest static void testRegistraUtente() {
        Id iddi = [SELECT Id FROM Account WHERE BI_CodiceAccordo__c = '321'].Id;
        SegnalazioniSelfRegisterController.registraUtente('321', 'Nome', 'Cognome', 'test@example.com', '+393331234567', iddi, '12345', '54321', 'IFIS - Segnalatori', true);
    }
    
}