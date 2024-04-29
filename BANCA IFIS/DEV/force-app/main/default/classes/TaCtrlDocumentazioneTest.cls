@isTest
private class TaCtrlDocumentazioneTest {
    
    private static Integer nCessioni = 10;
    static User userCommerciale;
    static String profileName = 'IFIS - Sviluppo Commerciale Filiali';
    
    @testSetup
    static void setupData() {
        WGC_AllDataFactory.createUtenzaDefault();
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaControlloCambioFaseOpp__c = true;
        f.DisabilitaNamingAutomaticaOpportunita__c = true;
        f.WGC_disabilita_per_batch__c = true; //adione-crm20
        upsert f;
        
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
        
    }
    
    @isTest
    static void testGetDocumentiUpload() {
        Cessione__c c = [SELECT Stato__c FROM Cessione__c LIMIT 1];
        TaCtrlDocumentazione.getDocumentiUpload(c.Id);
        
    }
    
    @isTest
    static void testSalvaAllegatoCessione() {
        Cessione__c c = [SELECT Stato__c FROM Cessione__c LIMIT 1];
		Account a = [SELECT Id, ConsensiPrivacyModificati__c FROM Account WHERE PIVA__c ='02119590046' LIMIT 1];
		//Opportunity o = new Opportunity(Name='Test Opp', Cessione__c=c.Id, Account=a, StageName='In Istruttoria', CloseDate=Date.today().addDays(30));
		Opportunity o = [SELECT Id FROM Opportunity WHERE Cessione__c =:c.id LIMIT 1];
		Contact con = new Contact(FirstName='Test', LastName='Contact', ConsensiPrivacyModificati__c=true);
		insert con;
		NDGLinea__c esecutore = new NDGLinea__c(Contact__c=con.Id, Opportunita__c=o.Id, Tipo__c='Esecutore Adeguata Verifica');
		insert esecutore;
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = EncodingUtil.base64Decode('this is a dummy string to emulate some content');
        cv.Description='Test v1';
        cv.Title='dummy file for testing.pdf';
        cv.PathOnClient = 'http://www.dummy.com/dummy file for testing.pdf';
        insert cv;
        Test.startTest();
        //test caricamento
        TaCtrlDocumentazione.salvaAllegatoCessione(
            'RSF',
            'Bilanci',
            cv.Id,
            c.Id,
            'test'
        );
        
        //test caricamento con versione precedente esistente
        ContentVersion cv2 = new ContentVersion();
        cv2.ContentLocation = 'S';
        cv2.VersionData = EncodingUtil.base64Decode('this is a dummy string to emulate some content');
        cv2.Description='Test v2';
        cv2.Title='dummy file for testing v2.pdf';
        cv2.PathOnClient = 'http://www.dummy.com/dummy file for testing v2.pdf';
        insert cv2;
        TaCtrlDocumentazione.salvaAllegatoCessione(
            'RSF',
            'Bilanci',
            cv2.Id,
            c.Id,
            'test'
        );
        
        //test caricamento altri cod. doc.
		Blob bbb = EncodingUtil.base64Decode('this is a dummy string to emulate some content');
        ContentVersion cvMAV = new ContentVersion(Title = 'MAV', PathOnClient='http://www.dummy.com/MAV.pdf', VersionData=bbb);
        insert cvMAV;
        TaCtrlDocumentazione.salvaAllegatoCessione(
            'MAV',
            'Bilanci',
            cvMAV.Id,
            c.Id,
            'test'
        );
        ContentVersion cvMTC = new ContentVersion(Title = 'MTC', PathOnClient='http://www.dummy.com/MTC.pdf', VersionData=bbb);
        insert cvMTC;
        TaCtrlDocumentazione.salvaAllegatoCessione(
            'ModuloTecnicheDiComunicazione',
            'Bilanci',
            cvMTC.Id,
            c.Id,
            'PrivacyFirm'
        );
        ContentVersion cvAPP = new ContentVersion(Title = 'APP', PathOnClient='http://www.dummy.com/APP.pdf', VersionData=bbb);
        insert cvAPP;
        TaCtrlDocumentazione.salvaAllegatoCessione(
            'APP',
            'Bilanci',
            cvAPP.Id,
            c.Id,
            'PrivacyPfFirm'
        );
        ContentVersion cvDURC = new ContentVersion(Title = 'DURC', PathOnClient='http://www.dummy.com/DURC.pdf', VersionData=bbb);
        insert cvDURC;
        TaCtrlDocumentazione.salvaAllegatoCessione(
            'durc',
            'Bilanci',
            cvDURC.Id,
            c.Id,
            'test'
        );
        ContentVersion cvFATT = new ContentVersion(Title = 'FATT',PathOnClient='http://www.dummy.com/FATT.pdf', VersionData=bbb);
        insert cvFATT;
        TaCtrlDocumentazione.salvaAllegatoCessione(
            'FATT',
            'Bilanci',
            cvFATT.Id,
            c.Id,
            'test'
        );
        Test.stopTest();
    }
    
    /* va aggiunto il mock del servizio parser pdf certificazione
@isTest
static void testSalvaCertificazione() {
Test.startTest();
Account acc = [SELECT Id, Name FROM Account WHERE name='Account TEST'];
acc.ConsensiPrivacyModificati__c=false;
update acc;
Cessione__c cess = TestUtils.creaCessioneCompleta(acc);
ContentVersion cv = new ContentVersion();
cv.ContentLocation = 'S';
cv.VersionData = EncodingUtil.base64Decode('this is a dummy string to emulate some content');
cv.Description='Test';
cv.Title='Test file Dummy';
cv.PathOnClient = cv.Title + '.' + cv.FileExtension;
insert cv;

TaCtrlDocumentazione.salvaCertificazione(cv.Id, cess.Id);
Test.stopTest();
}
*/
    @isTest
    static void testSalvaAllegatoCertificazione() {
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE name='Account TEST'];
        acc.ConsensiPrivacyModificati__c=false;
        update acc;
        Cessione__c cess = TestUtils.creaCessioneCompleta(acc);
        Certificazione__c cert = [SELECT Id FROM Certificazione__c WHERE Cessione__c =: cess.Id];
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId=acc.Id, Cessione__c=cess.Id );
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = EncodingUtil.base64Decode('this is a dummy string to emulate some content');
        cv.Description='Test';
        cv.Title='Test file Dummy';
        cv.PathOnClient = cv.Title + '.' + cv.FileExtension;
        insert cv;
        
        TaCtrlDocumentazione.salvaAllegatoCertificazione(
            cess.Id,
            cert.Id,
            cv.Id,
            'Identificazione cliente', //famiglia
            'PrivacyFirm' //tipoDoc
        );
        Test.stopTest();
        
    }
    
    
    @isTest
    static void testDocumentiPrivacyCaricati() {
        Account a = [SELECT Id, Name FROM Account WHERE name='Account TEST'];
        Cessione__c c = [SELECT Stato__c FROM Cessione__c LIMIT 1];
        Contact con = new Contact(FirstName='Gioia', LastName='Bella');
        insert con;
        Opportunity o = new Opportunity(Account=a, Name='alphaville', StageName='In Istruttoria', CloseDate=Date.today().addDays(30));
        insert o;
        NDGLinea__c l = new NDGLinea__c(
            Tipo__c = 'Esecutore adeguata verifica',
            Cessione__c = c.Id,
            Account__c = a.Id,
            Contact__c= con.Id,
            Opportunita__c = o.Id
        );
        insert l;
        
        TaCtrlDocumentazione.documentiPrivacyCaricati(c.Id);
    }
    
    @isTest
    static void testgeneraDocumentazioneStatica() {
        
        EndpointServizi__c eps = new EndpointServizi__c();         
        eps.Name = 'settings';
        eps.UrlDocumentiTaStatici__c = 'www.testserver.com';        
        insert eps;
        //Map<String, EndpointServizi__c> eg = EndpointServizi__c.getAll();
        //System.debug('---> '+eg);
        
        String[] res = TaCtrlDocumentazione.generaDocumentazioneStatica();
        //System.assertEquals(3, res.size());
    }
    
    @IsTest
    static void testGetDocumentiAnomali() {
        Cessione__c c = [SELECT Stato__c FROM Cessione__c LIMIT 1];
        Anomalia__c a = new Anomalia__c(
            Cessione__c = c.Id,
            Risolta__c = false,
            TipoAnomalia__c = 'DURC',
            SottoTipoAnomalia__c = 'Documento scaduto',
            DescrizioneAnomalia__c = 'Descrizione test'
        );
        insert a;
        
        TaCtrlDocumentazione.InfoDoc[] docs = TaCtrlDocumentazione.getDocumentiAnomali(c.Id);
        
        System.assertEquals(1, docs.size());
    }
    
    @isTest
    static void testGetDocumentiDinamiciDownload() {
        String[] codiceDocumento = new String[]{};
            
            TaCtrlDocumentazione.InfoDoc[] docs = TaCtrlDocumentazione.getDocumentiDinamiciDownload(codiceDocumento);
        System.assertEquals(5, docs.size());
    }
    
    @isTest
    static void testDeleteDocument() {
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        TaCtrlDocumentazione.deleteDocument(cv.Id);
    }
    
    @IsTest
    static void testGetDocumentiDownload() {
        Account a = [SELECT Id, Name FROM Account WHERE name='Account TEST'];
        Cessione__c c = [SELECT Stato__c FROM Cessione__c LIMIT 1];
        NDGLinea__c l = new NDGLinea__c(
            Tipo__c = 'Esecutore adeguata verifica',
            Cessione__c = c.Id,
            Account__c = a.Id
        );

        //test with input
        TaCtrlDocumentazione.InfoDoc[] docs = TaCtrlDocumentazione.getDocumentiDownload(c.Id);
        System.assertEquals(8, docs.size());
    }
       
	@IsTest
	static void testChiudiAnomalia() {
		Cessione__c cess = [SELECT Id, Stato__c FROM Cessione__c LIMIT 1];
		Anomalia__c ano = new Anomalia__c();
		ano.Risolta__c = false;
		ano.Cessione__c = cess.Id;
		insert ano;

		TaCtrlDocumentazione.chiudiAnomalia(ano.Id);
		Anomalia__c anoUpd = [SELECT Id, Risolta__c FROM Anomalia__c WHERE Id=:ano.Id LIMIT 1];

		System.assertEquals(true, anoUpd.Risolta__c);
	}
    
	@IsTest
	static void testChiudiAnomaliaAttore() {
		Contact con = new Contact(FirstName='Mario', LastName='Rossi');
		insert con;
		Cessione__c cess = [SELECT Id, Stato__c FROM Cessione__c LIMIT 1];
		Anomalia__c ano = new Anomalia__c();
		ano.Risolta__c = false;
		ano.Cessione__c = cess.Id;
		ano.Attore__c = con.Id;
		insert ano;

		TaCtrlDocumentazione.chiudiAnomaliaAttore(con.Id);
		List<Anomalia__c> anoUpd = [SELECT Id, Risolta__c FROM Anomalia__c WHERE Attore__c = :con.Id];
		for (Anomalia__c a : anoUpd) {
		System.assertEquals(true, a.Risolta__c); 
		}
	}
    
    	
	@AuraEnabled
	public static String getFoglioInformativoDownload() {
		try {
			return TaCtrlDocumentazione.getFoglioInformativoDownload();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.getFoglioInformativoDownload',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}
}