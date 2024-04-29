@isTest
private class TiAnticipoUtilsTest {

	@testSetup
	static void setupData() {
		Funzionalita__c f = Funzionalita__c.getInstance();
		f.DisabilitaControlloCambioFaseOpp__c = true;
		f.DisabilitaNamingAutomaticaOpportunita__c = true;
		f.WGC_disabilita_per_batch__c = true; //adione-crm20
		upsert f;
		WGC_AllDataFactory.createUtenzaDefault();
		Account a = TestUtils.creaAccount('AccountTest');
		insert new Prodotto__c(CodiceUnivoco__c = 'ATDTiAnticipo');
		Cessione__c[] cessioni = new Cessione__c[] { };
		for (Integer i = 0; i< 5; i++) {
			cessioni.add(new Cessione__c(Name = 'test', Account__c = a.Id));
		}
		insert cessioni;
	}

	@isTest
	static void testCommunityUsername() {
		String res = TiAnticipoUtils.creaCommunityUsername('test12345@testmail.com');
		String acc = 'test12345@testmail.com' + '.' + ParametriTiAnticipo__c.getOrgDefaults().UsernameSuffix__c;
		System.assertEquals(acc, res);
	}

	@isTest
	static void testCalcolaSpeseIstruttoriaSenza() {
		List<Cessione__c> lst = [SELECT Id FROM Cessione__c];
		Account a = [SELECT Id, Name FROM Account WHERE name = 'AccountTest'];
		Cessione__c cSenza = TestUtils.creaCessioneCompleta(a);
		lst.add(cSenza);
		Set<Id> senza = new Set<Id> ();
		senza.add(cSenza.id);
		TiAnticipoUtils.calcolaSpeseIstruttoria(senza);

	}

	@isTest
	static void testCalcoloCostoPreventivoPubblico() {
		String segmentoRischio = '2';
		Decimal importoFattura = Decimal.valueOf('25800');
		Integer deltaGiorni = 60;

		TiAnticipoUtils.calcoloCostoPreventivoPubblico(segmentoRischio, importoFattura, deltaGiorni);
	}

	@isTest
	static void testGetCommissioneAtd() {
		String segmentoRischio = '2';
		Decimal importoFattura = Decimal.valueOf('25800');
		CommissioneATD__mdt[] commissioni = new CommissioneATD__mdt[] { };
		new CommissioneATD__mdt();

		TiAnticipoUtils.getCommissioneAtd(commissioni, segmentoRischio, importoFattura);
	}

	@isTest
	static void testGetUserAccountId() {
		Account acc = new Account(Name = 'AcmeTA');
		insert acc;
		UtenzeDefault__c ud = new UtenzeDefault__c();
		ud.IdAccountDiDefault__c = acc.Id;
		upsert ud;

		Id res = TiAnticipoUtils.getUserAccountId();
		//FIXME va eseguito come utente ta
		//System.assertEquals(ud.IdAccountDiDefault__c, res);
	}

	@isTest
	static void testGetUserContactId() {
		Contact con = new Contact(FirstName = 'Jon', LastName = 'DoeTA');
		insert con;
		UtenzeDefault__c ud = new UtenzeDefault__c();
		ud.IdReferenteDiDefault__c = con.Id;

		Id res = TiAnticipoUtils.getUserContactId();
		//FIXME va eseguito come utente ta
		//System.assertEquals(ud.IdReferenteDiDefault__c, res);
	}

	@isTest
	static void testsyncParametri() {
		List<Cessione__c> lst = [SELECT Id FROM Cessione__c];
		TiAnticipoUtils.syncParametri(lst);
	}

	@isTest
	static void testCalcoloDurataCredito() {
		Cessione__c cessione = [SELECT Id FROM Cessione__c LIMIT 1];
		Certificazione__c[] certs = new Certificazione__c[] { };
		Date scad = Date.today().addDays(120);
		Certificazione__c cert1 = new Certificazione__c(
		                                                Cessione__c = cessione.Id,
		                                                TerminiPagamento__c = 30,
		                                                DataPagamento__c = scad,
		                                                ImportoCertificato__c = Decimal.valueOf('12400')
		);
		insert cert1;
		certs.add(cert1);
		//test 1 cert
		TiAnticipoUtils.calcoloDurataCredito(certs);
		/* null pointer nel caso di 2+ certificazioni, devo sistemare i dati di test
		  Certificazione__c cert2 = new Certificazione__c(Cessione__c = cessione.Id, TerminiPagamento__c = 60, DataPagamento__c=scad, ImportoCertificato__c=Decimal.valueOf('25300'));
		  insert cert2;
		  certs.add(cert2);
		  Certificazione__c cert3 = new Certificazione__c(Cessione__c = cessione.Id, TerminiPagamento__c = 60, DataPagamento__c=scad, ImportoCertificato__c=Decimal.valueOf('46100'));
		  insert cert3;
		  certs.add(cert3);
		 
		  //test 3 certs
		  TiAnticipoUtils.calcoloDurataCredito(certs);
		 */
	}

	@isTest
	static void testCalcoloC138() {
		Cessione__c cessione = [SELECT Id FROM Cessione__c LIMIT 1];
		Certificazione__c[] certs = new Certificazione__c[] { };
		Date scad = Date.today().addDays(120);
		Certificazione__c cert1 = new Certificazione__c(
		                                                Cessione__c = cessione.Id,
		                                                TerminiPagamento__c = 30,
		                                                DataPagamento__c = scad,
		                                                ImportoCertificato__c = Decimal.valueOf('12400')
		);
		insert cert1;
		certs.add(cert1);
		Account debitore = [SELECT Id, Name FROM Account WHERE name = 'AccountTest'];
		List<CommissioneATD__mdt> commissioniAtd = [SELECT Id,
		                                            CommissioneATDMese__c,
		                                            SegmentoRischio__c,
		                                            EstremoInferiore__c,
		                                            EstremoSuperiore__c
		                                            FROM CommissioneATD__mdt
		                                            WHERE SegmentoRischio__c = '3'];
		CommissioneATD__mdt commissioneAtd = commissioniAtd[0];
		TiAnticipoUtils.calcoloC138(certs, debitore, commissioneAtd);
	}

	@isTest
	static void test_sendInfoMail() {
		ParametriTiAnticipo__c paramTA = new ParametriTiAnticipo__c();
		paramTA.Mail_Segnalazione_Errori__c = 'gestione.canali.salesforce@bancaifis.it';
		upsert paramTA;
		TiAnticipoUtils.sendInfoMail('test messagge for sendInfoMail testing');
	}

	@isTest
	static void test_sendErrorMail() {
		ParametriTiAnticipo__c paramTA = new ParametriTiAnticipo__c();
		paramTA.Mail_Segnalazione_Errori__c = 'gestione.canali.salesforce@bancaifis.it';
		upsert paramTA;
		Ex.GenericException e = new Ex.GenericException('blah blah');
		TiAnticipoUtils.sendErrorMail(e.getMessage(), 'test messagge for sendErrorMail testing');
	}

	@isTest
	static void testCanBeUtenteTitolare() {
		TiAnticipoUtils.canBeUtenteTitolare();
	}

	@isTest
	static void testSetUtenteTitolare_IsUtenteTitolare() {
		WGC_Originator__mdt originatorMD = [
		                                    SELECT Qualifica_Utente__c
		                                    FROM WGC_Originator__mdt
		                                    WHERE DeveloperName = 'Portali_TiAnticipo_Area_Riservata'
		                                   ];
		Profile taProfile = [SELECT Id FROM Profile WHERE Name = 'IFIS - TiAnticipo' LIMIT 1];
		User uRunning = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		Account acc = TestUtils.creaAccount('TA Sample Account', uRunning);
		Contact con = new Contact(FirstName = 'Alfa', LastName = 'Gamma', AccountId = acc.Id);
		insert con;
		User u = new User();
		u.Username = 'ta@dummy.com';
		u.Email = 'ta@dummy.com';
		u.FirstName = 'NomeTA';
		u.LastName = 'Cognome';
		u.TimeZoneSidKey = 'Europe/Rome';
		u.CommunityNickname = u.Username.left(40);
		u.Alias = 'tadummy';
		u.LocaleSidKey = 'en_US';
		u.EmailEncodingKey = 'UTF-8';
		u.ProfileId = taProfile.Id;
		u.LanguageLocaleKey = 'en_US';
		u.Qualifica_Utente__c = originatorMD.Qualifica_Utente__c; //Ti Anticipo
		u.ContactId = con.Id;


		system.debug('-----> user: ' + u);
		system.debug('-----> account: ' + acc);
		Test.startTest();
		System.runAs(u) {
			Boolean res = TiAnticipoUtils.setUtenteTitolare();
			System.assertEquals(true, res);

			Boolean res2 = TiAnticipoUtils.isUtenteTitolare();
			System.assertEquals(true, res2);
		}
		Test.stopTest();
	}

	/*
	  @isTest
	  static void testCalcolaSpeseIstruttoriaCon() {
	  List<Cessione__c> lst = [SELECT Id FROM Cessione__c];
	  Account a = [SELECT Id, Name FROM Account WHERE name='AccountTest'];
	  Cessione__c cCon = TestUtils.creaCessioneCompleta(a);
	  lst.add(cCon);
	  Certificazione__c[] certs = new Certificazione__c[]{};
	  Date scad = Date.today().addDays(120);
	  Certificazione__c cert1 = new Certificazione__c(
	  Cessione__c = cCon.Id, 
	  TerminiPagamento__c = 30, 
	  DataPagamento__c=scad, 
	  ImportoCertificato__c=Decimal.valueOf('12400')
	  );
	  insert cert1;
	  Set<Id> con = new Set<Id>();
	  con.add(cCon.id);
	  TiAnticipoUtils.calcolaSpeseIstruttoria(con);
	  }
	*/
}