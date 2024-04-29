@isTest
private class WsRestPdfParserTest {
    
    private static Integer nCessioni = 10;
    static User userCommerciale;
    static String profileName = 'IFIS - Sviluppo Commerciale Filiali';
    
    @testSetup
    static void setupData() {      
        TestUtils.creaEndpointServizi();
        Id profiloCommerciale = [
            SELECT Id 
            FROM Profile 
            WHERE name = :profileName
            LIMIT 1].Id;
        userCommerciale = new User(Alias = 'User3', 
                                   Email='UserThree@testorg.com', 
                                   EmailEncodingKey='UTF-8', 
                                   Username = 'UserThree@testorg.com', 
                                   LastName = 'UserThree', 
                                   ProfileId = profiloCommerciale, 
                                   Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali', 
                                   WGC_Canale_di_sviluppo__c = 'Rete Commerciale Ifis Impresa',
                                   LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US', 
                                   TimeZoneSidKey='America/Los_Angeles'
                                  );
        User babeto = TestUtils.creaUtente('babeto');
        System.runAs(userCommerciale) {
            Account a = TestUtils.creaAccount('Account TEST', babeto, 'MI', '02119590046', 'rsscld50r15h501y', 'Prospect', '4321');
            insert new Prodotto__c(CodiceUnivoco__c = 'ATDTiAnticipo');
            Cessione__c[] cessioni = new Cessione__c[] {};
                for (Integer i = 0; i < nCessioni; i++) {
                    cessioni.add(new Cessione__c(Name = 'test', Account__c = a.Id));
                }
            insert cessioni;
        }
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = EncodingUtil.base64Decode('this is a dummy string to emulate some content');
        cv.Description='Test';
        cv.Title='Test file Dummy';
        cv.PathOnClient = 'Test file Dummy.txt';
        insert cv;       
    }    
    
    @isTest
    static void testParseCertificazione() {
        Test.startTest();
        ContentVersion cvSel = [SELECT Id, PathOnClient, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, 
                                ContentDocument.LatestPublishedVersionId, VersionData, ContentSize 
                                FROM ContentVersion LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_PARSER_CERT));
        WsRestPdfParser.ParseCertificazioneResponse res = WsRestPdfParser.parseCertificazione(cvSel.ContentDocumentId);
        WsRestPdfParser.DatiCrediti dc = res.payload;
        Date dataPag = dc.getDataPagamento();
        Double impCer = dc.getImportoCertificato();
        Double ammCom = dc.getAmmontareComplessivoCredito();
        Double imp = dc.fatture.get(0).getImporto();
        Double impRic = dc.fatture.get(0).getImportoRiconosciuto();
        Date d = dc.fatture.get(0).getData();
    
        Test.stopTest();
    }

}