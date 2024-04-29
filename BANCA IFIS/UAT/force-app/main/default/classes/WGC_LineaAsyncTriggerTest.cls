@isTest
public class WGC_LineaAsyncTriggerTest {

    @TestSetup
    public static void makeData(){

        //WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createImpostazioni();

        UserRole ur =[SELECT DeveloperName,Id FROM UserRole WHERE DeveloperName = 'ResponsabileFiloDiretto'];
        UserRole urComm =[SELECT DeveloperName,Id FROM UserRole WHERE DeveloperName = 'AltaDirezione'];

        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Filo Diretto'];
        Profile PComm = [SELECT Id FROM Profile WHERE Name = 'IFIS - Sviluppo Commerciale Filiali'];

        User u = new User(Alias = 'IFIS_FD2', Email='TestIFIS_FD2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingFD2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS_FD2@testorg.com', NDGGruppo__c = '1234567899', WGC_Team_Filo_Diretto__c = 'New Team', Qualifica_Utente__c = 'Filo Diretto');
        u.UserRole=ur;
        Insert u;

        User u2 = new User(Alias = 'IFIS_CM2', Email='TestIFIS2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pComm.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS2@testorg.com', NDGGruppo__c = '1234567119', Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali');
        u2.UserRole=urComm;
        Insert u2;

        List<WGC_Dettaglio_Visite__c> dtList = WGC_AllDataFactory.createDettaglioVisite(1, u, u2);
        Insert dtList;

        Account acc = TestUtils.creaAccount('account');
        TestUtils.CreaOpportunity(acc);
    }
    
    @isTest
    public static void assertTest() {
        Test.enableChangeDataCapture();
        
        Test.startTest();

        WGC_AllDataFactory.createUtenzaDefault();
        // Account acc = TestUtils.creaAccount('account');
        // Opportunity opp = TestUtils.CreaOpportunity(acc);
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        WGC_Dettaglio_Visite__c dt = [SELECT Id, Ragione_Sociale__c FROM WGC_Dettaglio_Visite__c LIMIT 1];
        dt.Ragione_Sociale__c = acc.Id;
        Update dt;

        WGC_Linea_Prodotto__c lp = new WGC_Linea_Prodotto__c();
        lp.Anagrafica__c = acc.Id;
        lp.Opportunit__c = opp.Id;
        lp.Qualifica_Prodotto__c = 'Cliente attivo';
        lp.Data_ultima_cessione__c = System.Today().addDays(20);
        lp.Tipologia_Prodotto__c = 'FACTORING ORDINARIO';
        
        WGC_Linea_Prodotto__c lp2 = new WGC_Linea_Prodotto__c();
        lp2.Anagrafica__c = acc.Id;
        lp2.Opportunit__c = opp.Id;
        lp2.Qualifica_Prodotto__c = 'Cliente in avvio';

        List<WGC_Linea_Prodotto__c> lpList = new List<WGC_Linea_Prodotto__c>{lp, lp2};
        insert lpList;
        
        Test.stopTest();
        
        Test.getEventBus().deliver();
        
        List<WGC_Linea_Prodotto__c> lps = new List<WGC_Linea_Prodotto__c>();
        lps = [SELECT Id FROM WGC_Linea_Prodotto__c];
        System.assertEquals(2, lps.size());
    }

}