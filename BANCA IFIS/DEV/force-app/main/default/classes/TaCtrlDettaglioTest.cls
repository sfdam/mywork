@isTest
private class TaCtrlDettaglioTest {
    
    private static Integer nCessioni = 2;
    private static Integer nFatture = 3;
    private static Integer nAnomalie = 2;
    
    @testSetup
    static void setupData () {
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaControlloCambioFaseOpp__c = true;
        f.DisabilitaNamingAutomaticaOpportunita__c = true;
        f.WGC_disabilita_per_batch__c = true; //adione-crm20
        upsert f;
        
        ParametriTiAnticipo__c paramTA = ParametriTiAnticipo__c.getInstance();
        paramTA.Mail_Segnalazione_Errori__c = 'gestione.canali.salesforce@bancaifis.it';
        upsert paramTA;
        
        WGC_AllDataFactory.createUtenzaDefault();
        insert new Prodotto__c(CodiceUnivoco__c = 'ATDTiAnticipo');
        
        User u = TestUtils.creaUtente('userStd');
        
        Account acc = TestUtils.creaAccount('AccountTestTA', u);
        Cessione__c[] cessioni = new Cessione__c[] {};
            for (Integer i = 0; i < nCessioni; i++) {
                cessioni.add(new Cessione__c(Name = 'test', Account__c = acc.Id));
            }
        insert cessioni;
        
    }
    
    @isTest
    static void testFetchCessione() {
        Cessione__c c = [SELECT Id FROM Cessione__c LIMIT 1];
        Test.startTest();
        System.assert(TaCtrlDettaglio.fetchCessione(c.Id).cessione.Id == c.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testFetchCessioni() {
        Test.startTest();
        Cessione__c[] cc = TaCtrlDettaglio.fetchCessioni();
        Test.stopTest();
        //non usando utente portale, non trova nulla
        System.assertEquals(0, cc.size());
    }
    
    @isTest
    static void testUpsertCessione() {
        String newName = 'cambio nome per test';
        Cessione__c c = [SELECT Id FROM Cessione__c LIMIT 1];
        c.Name = newName;
        Test.startTest();
        TaCtrlDettaglio.DettaglioCessione dc = TaCtrlDettaglio.upsertCessione(JSON.serialize(c));
        Test.stopTest();
        System.assertEquals(newName, dc.cessione.name);
    }
    
    @isTest
    static void testFetchAnomalie() {
        Cessione__c cess = [SELECT Id FROM Cessione__c LIMIT 1];
        Anomalia__c[] anomalie = new Anomalia__c[] {};
            for (Integer i = 0; i < nAnomalie; i++) {
                anomalie.add(
                    new Anomalia__c(
                        Cessione__c = cess.Id,
                        Risolta__c = false,
                        TipoAnomalia__c = 'DURC',
                        SottoTipoAnomalia__c = 'Documento scaduto',
                        DescrizioneAnomalia__c = 'Descrizione test'
                    )
                );
            }
        insert anomalie;
        
        Test.startTest();
        TaCtrlDettaglio.fetchAnomalie();
        Test.stopTest();				
    }
    
    @isTest
    static void testSetReadedMessage() {
        Anomalia__c a = new Anomalia__c(Cessione__c = [SELECT Id FROM Cessione__c LIMIT 1].Id,
                                        Stato__c = 'Non Letto');
        insert a;
        
        Test.startTest();
        TaCtrlDettaglio.setReadedMessage(a.Id);      
        a = [SELECT Id, Stato__c FROM Anomalia__c WHERE Id = :a.Id];
        System.assert(a.Stato__c == 'Letto');
        Test.stopTest();
    }
    
    @isTest
    static void testCertificazioniFatture() {
        Account a = [SELECT Id FROM Account WHERE Name = 'AccountTestTA'];
        Cessione__c cessione = [SELECT Id FROM Cessione__c LIMIT 1];
        Certificazione__c certificazione = new Certificazione__c(Cessione__c = cessione.Id, TerminiPagamento__c = 30);
        insert certificazione;
        
        Test.startTest();
        TaCtrlDettaglio.fetchUploadCertificazioneInfo(cessione.Id);
        TaCtrlDettaglio.fetchCertificazioniFatture(cessione.Id);
        TaCtrlDettaglio.fetchFatture(cessione.Id);
        TaCtrlDettaglio.deleteCertificazione(certificazione.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testFetchFatture() {
        Account a = [SELECT Id FROM Account WHERE Name = 'AccountTestTA'];
        Cessione__c cessione = [SELECT Id FROM Cessione__c LIMIT 1];
        Certificazione__c cert = new Certificazione__c(Cessione__c = cessione.Id, TerminiPagamento__c = 30);
        insert cert;
        
        Fattura__c f = new Fattura__c(CertificazioneParent__c = cert.Id, DataFattura__c = Date.today());
        insert f;
        
        Test.startTest();
        Fattura__c[] ff = TaCtrlDettaglio.fetchFatture(cessione.Id);
        System.assertEquals(1, ff.size());
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateFatture() {
        Account a = [SELECT Id FROM Account WHERE Name = 'AccountTestTA'];
        Cessione__c cessione = [SELECT Id FROM Cessione__c LIMIT 1];
        Certificazione__c cert = new Certificazione__c(Cessione__c = cessione.Id, TerminiPagamento__c = 30);
        insert cert;
        
        Fattura__c f = new Fattura__c(CertificazioneParent__c = cert.Id, DataFattura__c = Date.today());
        insert f;
        
        // TestUtils.creaCessioneCompleta(a);
        Test.startTest();
        Boolean res = TaCtrlDettaglio.updateFatture(JSON.serialize([SELECT Id FROM Fattura__c]));
        System.assertEquals(true,res);
        Test.stopTest();
    }
    
    @IsTest
    static void testFetchDebitoriTA() {
        Account a = [SELECT Id FROM Account WHERE Name = 'AccountTestTA'];
        a.SegmentoRischio__c = '4';
        update a;
        
        Test.startTest();
        Account[] accs = TaCtrlDettaglio.fetchDebitoriTA();
        Test.stopTest();
        System.assertEquals(1, accs.size());
        
    }
    
    @IsTest
    static void testFetchCertificazioniFatture() {
        Cessione__c cessione = [SELECT Id FROM Cessione__c LIMIT 1];
        Certificazione__c cert = new Certificazione__c(Cessione__c = cessione.Id, TerminiPagamento__c = 30);
        insert cert;
        
        Test.startTest();
        Certificazione__c[] certs = TaCtrlDettaglio.fetchCertificazioniFatture(cessione.Id);
        Test.stopTest();
        System.assertEquals(1, certs.size());
    }
    
    @IsTest
    static void testDeleteCertificazione() {
        Cessione__c cessione = [SELECT Id FROM Cessione__c LIMIT 1];
        Certificazione__c cert = new Certificazione__c(Cessione__c = cessione.Id, TerminiPagamento__c = 30);
        insert cert;
        
        Test.startTest();
        TaCtrlDettaglio.deleteCertificazione(cert.Id);
        Certificazione__c[] certs = TaCtrlDettaglio.fetchCertificazioniFatture(cessione.Id);
        Test.stopTest();
        System.assertEquals(0, certs.size());
    }
    
    @IsTest
    static void testFetchPreventivoCorretto() {
        Cessione__c cessione = [SELECT Id FROM Cessione__c LIMIT 1];
        
        Test.startTest();
        Cessione__c res = TaCtrlDettaglio.FetchPreventivoCorretto(cessione.Id, true);
        Test.stopTest();
        System.assertEquals(cessione.Id, res.Id);
    }
    
    @IsTest
    static void testFetchUploadCertificazioneInfo() {
        Cessione__c cessione = [SELECT Id FROM Cessione__c LIMIT 1];
        
        Test.startTest();
        TaCtrlDettaglio.UploadCertificazioneInfo info = TaCtrlDettaglio.fetchUploadCertificazioneInfo(cessione.Id);
        Test.stopTest();
        System.assertEquals(cessione.id, info.cessione.id);
    }
    
    @IsTest
    static void testPopolaUltimoAccesso() {
        Cessione__c cessione = [SELECT Id, DataUltimoAccesso__c FROM Cessione__c LIMIT 1];
        Test.startTest();
        TaCtrlDettaglio.popolaUltimoAccesso(cessione.Id);
        TaCtrlDettaglio.DettaglioCessione dc = TaCtrlDettaglio.fetchCessione(cessione.Id);
        Test.stopTest();
        
        //per verificare ts devo chiamare da utente portale e creatore della cessione
    }
    
    @IsTest
    static void testEditNomeCessione() {
        Cessione__c cessione = [SELECT Id, DataUltimoAccesso__c FROM Cessione__c LIMIT 1];
        
        Test.startTest();
        TaCtrlDettaglio.editNomeCessione(cessione.Id, 'newName');
        TaCtrlDettaglio.DettaglioCessione dc = TaCtrlDettaglio.fetchCessione(cessione.Id);
        Test.stopTest();
        
        System.assertEquals('newName', dc.cessione.Name);
    }
    
    /*
@isTest
static void testAssociaDebitoriCertificazioni() {
User testUser = [SELECT Id, Name, Qualifica_Utente__c FROM User WHERE Alias = 'userStd' LIMIT 1];	
testUser.Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali';
System.debug('-------------> testUser: '+testUser);

System.runAs(testUser) {

Id meId = UserInfo.getUserId();
System.debug('-------------> meUserId: '+meId);
User me = [SELECT Id, Name FROM User WHERE Id =: meId  LIMIT 1];
System.debug('-------------> meUser: '+me);
Account acc = TestUtils.creaAccount('AccountTestTA', me);
System.debug('-------------> acc: '+acc);
Cessione__c cess = TestUtils.creaCessioneCompleta(acc);
System.debug('-------------> acc: '+cess);
Certificazione__c[] certificazioni = [SELECT Id, PartitaIvaDebitore__c FROM Certificazione__c WHERE Cessione__c = :cess.Id];
System.debug('-------------> certificazioni: '+certificazioni);

//
//			for (Certificazione__c c : certificazioni) {
//				c.Debitore__c = acc.id;
//				c.ImportoCertificato__c = 17500;
//				c.DataPagamento__c = Date.today().addMonths(10);
//			}
//			update certificazioni;
//			Certificazione__c[] certificazioni = [SELECT Id, Name, PartitaIvaDebitore__c, Cessione__c FROM Certificazione__c LIMIT 1];
//			Cessione__c c = [SELECT Id, CreatedById FROM Cessione__c WHERE id =: certificazioni[0].Cessione__c LIMIT 1];
//
System.debug('-------------> creator : '+cess.CreatedById);
Test.startTest();
System.debug('-------------> user: '+UserInfo.getUserId());
TaCtrlDettaglio.associaDebitoriCertificazioni(certificazioni);
Test.stopTest();
}
}
*/
    
}