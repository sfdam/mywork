@isTest
public class BI_CRM_CaricamentoMassivoDebitori_TEST  {

		@isTest 
		static void testSchedule() {
        User usr = [SELECT Id, Name FROM User WHERE UserRoleId != null and IsActive = true limit 1];        
        System.RunAs(usr) {
            //force var value to make test work
            BI_CRM_CaricamentoMassivoDebitori_SCHD sh1 = new BI_CRM_CaricamentoMassivoDebitori_SCHD();
            String sch = '0 30 * * * ?';
            System.schedule('Test for BI_CRM_BonificaAccount_SCHD', sch, sh1);
        }
	} 

	@testSetup
	static void BI_CRM_CaricamentoMassivoDebitori_TEST_setupDati() {
	
		List<Account> acc = WGC_AllDataFactory.createAccount(2);
		acc.get(0).Tag_Caricamento__c = 'DEBITORE';
		acc.get(1).Tag_Caricamento__c = 'DEBITORE';
		acc.get(1).NaturaGiuridica__c = 'DI';
		insert acc;
	}

	@isTest static void testBatch() {

		Test.startTest();

		BI_CRM_CaricamentoMassivoDebitori_BTCH adc = new BI_CRM_CaricamentoMassivoDebitori_BTCH();
		Database.executeBatch(adc);

		Test.stopTest();
	}
}