@isTest
public class BI_COM_SuddivisioneTerritoriale_TEST {

	@testSetup
	static void setupDati() {	
		Profile p = [SELECT Id FROM Profile WHERE Name = 'IFIS - Filo Diretto'];
		User u = new User(Email = 'TestIFIS@testorg.com',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'TestIFIS@testorg.com', Alias = '123');
		insert u;
		Comune__c comune = new Comune__c(Name='MONTONE', Cab__c='38560', Cap__c='06014', Cin__c='9', CodiceCatastale__c='F685', ProvinciaEstesa__c='Perugia', Provincia__c='PG', SoloPerCF__c=false, FlagStorico__c=false, NomeRibes__c='MONTONE', Prefisso__c='750');
		insert comune;
		AssegnazioneAnagrafica__c assAnag = new AssegnazioneAnagrafica__c(CAP__c='06014', Comune__c=comune.Id, Filiale__c='Perugia', FiloDiretto__c=true, RefPrincipale__c=false, SviluppoDiretto__c=false, SviluppoIndiretto__c=false, Utente__c=u.Id, Web__c=false);
		insert assAnag;
		Date data = Date.today();
		Integer meseCorrente = data.month();
		Integer annoCorrente = data.year();
		Suddivisione_Territoriale_FD__c sudTer = new Suddivisione_Territoriale_FD__c(Operatore_FD__c=u.Id, Filiale__c='Perugia', Mese__c=meseCorrente, Anno__c =annoCorrente);
		insert sudTer;
	}

	@isTest 
	public static void testSuddivisioneTerritoriale() {

		Test.startTest();

		BI_COM_SuddivisioneTerritoriale_SCHD s = new BI_COM_SuddivisioneTerritoriale_SCHD();
		String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, s);

		Test.stopTest();
	}
}