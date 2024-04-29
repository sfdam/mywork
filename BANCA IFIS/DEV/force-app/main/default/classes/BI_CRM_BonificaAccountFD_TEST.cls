@isTest
public class BI_CRM_BonificaAccountFD_TEST {

	@isTest static void testSchedule() {
        User usr = [SELECT Id, Name FROM User WHERE UserRoleId != null and IsActive = true limit 1];        
        System.RunAs(usr) {
            //force var value to make test work
            BI_CRM_BonificaAccountFD_SCHD sh1 = new BI_CRM_BonificaAccountFD_SCHD();
            String sch = '0 30 * * * ?';
            System.schedule('Test for BI_CRM_BonificaAccountFD_SCHD', sch, sh1);
        }
	} 

	@testSetup
	static void BI_CRM_BonificaAccountFD_TEST_setupDati() {
	
		//insert new Funzionalita__c(DisabilitaTriggers__c=true);

		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' OR Name = 'Utente standard' LIMIT 1];

		System.debug('----------> ProfileId: ' + profileId);

		User ute = new User ();
		ute.FirstName = 'Utenza';
		ute.LastName = 'Default';
		ute.Username = 'tet@bancaifis.it';
		ute.Email = 'tet@bancaifis.it';
		ute.Alias = 'udfa';
		ute.CommunityNickname = 'udefault';
		ute.TimeZoneSidKey = 'Europe/Rome';
		ute.LocaleSidKey='it_IT';
		ute.EmailEncodingKey='UTF-8';
		ute.ProfileId=profileId.id;
		ute.LanguageLocaleKey='it';

		insert ute;
		String profileName = 'IFIS - Sviluppo Commerciale Filiali';
		Id profiloCommerciale = [
			SELECT Id 
			FROM Profile 
			WHERE name = :profileName
			LIMIT 1].Id;
		User userCommerciale = new User(Alias = 'User3', 
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
			TestUtils.creaAccount('ORTOFRUTTA MULTI SOCIETA A RESPONSABILITA LIMITATA', babeto, 'CZ', '03208400790', '03208400790');
		}
	}

	@isTest static void testBatch() {

		Test.startTest();

			BI_CRM_BonificaAccountFD_BTCH adc = new BI_CRM_BonificaAccountFD_BTCH();
			Database.executeBatch(adc);

		Test.stopTest();
	}

}