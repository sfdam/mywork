@isTest
private class BI_CRM_CaricamentoContattiVisite_TEST {

	@testSetup static void setup() {
		List<Account> accs = WGC_AllDataFactory.createAccount(1, true);
		Contact contatto = new Contact();
		contatto.FirstName = 'Marco';
		contatto.LastName = 'Rossi';
		contatto.AccountId = accs.get(0).Id;

		Contact contattoBis = new Contact();
		contattoBis.FirstName = 'Centralino';
		contattoBis.LastName = 'Test';
		contattoBis.AccountId = accs.get(0).Id;

		Task task = new Task();
		task.Subject = 'Ricontatto telefonico';
		task.Status = 'Aperto';
		task.WhatId = accs.get(0).Id;
		task.Originator__c = 'Web';
		task.Originator_di_dettaglio__c = 'Marketing';

		Event event = new Event();
		event.Subject = 'Visita Commerciale - ' + accs.get(0).Name;
		event.WhatId = accs.get(0).Id;
		event.Originator__c = 'Nessun Interesse';
		event.Originator__c = 'Pricing';
		event.DurationInMinutes = 60;
		event.ActivityDateTime = DateTime.now();

		Campaign campaign = new Campaign();
		campaign.Name = '1. WEB';


		insert contatto;
		insert contattoBis;
		insert task;
		insert event;
		insert campaign;
	}

	@isTest static void testModificaContatto() {
		CaricamentoContattiVisite__c test1 = new CaricamentoContattiVisite__c();
		Task task = [select Id FROM Task LIMIT 1];
		test1.ID_Attivita__c = task.Id;
		test1.Name = '107499';
		test1.Tipologia_Inserimento__c = 'contatto';
		test1.Data_Attivita__c = System.Today();
		test1.Assegnatario__c = 'Testing';
		test1.Esito_Livello_1__c = 'Assistenza';
		test1.Esito_Livello_2__c = 'Assistenza Esterna';
		test1.Commenti__c = 'Testo';

		Test.startTest();
		insert test1;
		Test.stopTest();
	}

	@isTest static void testModificaContatto2() {
		CaricamentoContattiVisite__c test15 = new CaricamentoContattiVisite__c();
		Integer s_num = 1;
		String result = String.valueOf(s_num++);      
		test15.ID_Attivita__c = Task.SObjectType.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
		test15.Name = '107499';
		test15.Tipologia_Inserimento__c = 'contatto';
		test15.Data_Attivita__c = System.Today();
		test15.Assegnatario__c = 'Testing';
		test15.Esito_Livello_1__c = 'Assistenza';
		test15.Esito_Livello_2__c = 'Assistenza Esterna';
		test15.Commenti__c = 'Testo';

		Test.startTest();
		insert test15;
		Test.stopTest();
	}

	@isTest static void testInserimentoContatto() {
		CaricamentoContattiVisite__c test2 = new CaricamentoContattiVisite__c();
		test2.Name = '107499';
		test2.Tipologia_Inserimento__c = 'contatto';
		test2.Data_Attivita__c = System.Today();
		test2.Campagna__c = '1. WEB';
		test2.Referente_Nome__c = 'Marco';
		test2.Referente_Cognome__c = 'Rossi';
		test2.Originator__c = 'Web';
		test2.Originator_Dettaglio__c = 'Marketing';
		test2.Assegnatario__c = 'Testing';
		test2.Esito_Livello_1__c = 'Assistenza';
		test2.Esito_Livello_2__c = 'Assistenza Esterna';
		test2.Commenti__c = 'Testo';

		Test.startTest();
		insert test2;
		Test.stopTest();
	}

	@isTest static void testInserimentoContatto2() {
		CaricamentoContattiVisite__c test5 = new CaricamentoContattiVisite__c();
		test5.Name = '107499';
		test5.Tipologia_Inserimento__c = 'contatto';
		test5.Data_Attivita__c = System.Today();
		test5.Campagna__c = '1. WEB';
		test5.Originator__c = 'Web';
		test5.Originator_Dettaglio__c = 'Marketing';
		test5.Assegnatario__c = 'Testing';
		test5.Esito_Livello_1__c = 'Assistenza';
		test5.Esito_Livello_2__c = 'Assistenza Esterna';
		test5.Commenti__c = 'Testo';

		Test.startTest();
		insert test5;
		Test.stopTest();
	}

	@isTest static void testInserimentoContatto3() {
		CaricamentoContattiVisite__c test9 = new CaricamentoContattiVisite__c();
		test9.Name = '107499';
		test9.Tipologia_Inserimento__c = 'contatto';
		test9.Data_Attivita__c = System.Today();
		test9.Campagna__c = '1. WEB';
		test9.Originator__c = 'Web';
		test9.Originator_Dettaglio__c = '';
		test9.Assegnatario__c = 'Testing';
		test9.Esito_Livello_1__c = 'Assistenza';
		test9.Esito_Livello_2__c = 'Assistenza Esterna';
		test9.Commenti__c = 'Testo';

		Test.startTest();
		insert test9;
		Test.stopTest();
	}

	@isTest static void testInserimentoContatto4() {
		CaricamentoContattiVisite__c test10 = new CaricamentoContattiVisite__c();
		test10.Name = '107499';
		test10.Tipologia_Inserimento__c = 'contatto';
		test10.Data_Attivita__c = System.Today();
		test10.Campagna__c = '1. WEB';
		test10.Originator__c = 'Web';
		test10.Assegnatario__c = 'Testing';
		test10.Esito_Livello_1__c = 'Assistenza';
		test10.Esito_Livello_2__c = 'Assistenza Esterna';
		test10.Commenti__c = 'Testo';

		Test.startTest();
		insert test10;
		Test.stopTest();
	}

	@isTest static void testModificaReferente() {
		CaricamentoContattiVisite__c test3 = new CaricamentoContattiVisite__c();
		test3.Name = '107499';
		test3.Tipologia_Inserimento__c = 'REFERENTE';
		test3.Email__c = 'marco.rossi@gmail.com';
		test3.Telefono_prefisso__c = '0541';
		test3.Telefono_numero__c = '248536';
		test3.Cellulare__c = '3264875962';
		test3.Referente_Nome__c = 'Marco';
		test3.Referente_Cognome__c = 'Rossi';

		Test.startTest();
		insert test3;
		Test.stopTest();
	}

	@isTest static void testInserimentoReferente() {
		CaricamentoContattiVisite__c test4 = new CaricamentoContattiVisite__c();
		test4.Name = '107499';
		test4.Tipologia_Inserimento__c = 'REFERENTE';
		test4.Email__c = 'roberto.susa@gmail.com';
		test4.Telefono_prefisso__c = '0541';
		test4.Telefono_numero__c = '248536';
		test4.Cellulare__c = '3264875962';
		test4.Referente_Nome__c = 'Roberto';
		test4.Referente_Cognome__c = 'Susa';

		Test.startTest();
		insert test4;
		Test.stopTest();
	}

	@isTest static void testInserimentoReferente2() {
		CaricamentoContattiVisite__c test11 = new CaricamentoContattiVisite__c();
		test11.Name = '107499';
		test11.Tipologia_Inserimento__c = 'REFERENTE';
		test11.Email__c = 'roberto.susa@gmail.com';
		test11.Telefono_prefisso__c = '0541';
		test11.Telefono_numero__c = '248536';
		test11.Cellulare__c = '3264875962';

		Test.startTest();
		insert test11;
		Test.stopTest();
	}

	@isTest static void testModificaVisita() {
		CaricamentoContattiVisite__c test6 = new CaricamentoContattiVisite__c();
		Event event = [select Id FROM Event LIMIT 1];
		test6.ID_Attivita__c = event.Id;
		test6.Name = '107499';
		test6.Tipologia_Inserimento__c = 'visita';
		test6.Data_Attivita__c = System.Today();
		test6.Assegnatario__c = 'Testing';
		test6.Esito_Livello_1__c = 'Nessun Interesse';
		test6.Esito_Livello_2__c = 'Pricing';
		test6.Commenti__c = 'Testo';

		Test.startTest();
		insert test6;
		Test.stopTest();
	}

	@isTest static void testModificaVisita2() {
		CaricamentoContattiVisite__c test16 = new CaricamentoContattiVisite__c();
		Integer s_num = 1;
		String result = String.valueOf(s_num++);      
		test16.ID_Attivita__c = Event.SObjectType.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
		test16.Name = '107499';
		test16.Tipologia_Inserimento__c = 'visita';
		test16.Data_Attivita__c = System.Today();
		test16.Assegnatario__c = 'Testing';
		test16.Esito_Livello_1__c = 'Nessun Interesse';
		test16.Esito_Livello_2__c = 'Pricing';
		test16.Commenti__c = 'Testo';

		Test.startTest();
		insert test16;
		Test.stopTest();
	}

	@isTest static void testInserimentoVisita() {
		CaricamentoContattiVisite__c test7 = new CaricamentoContattiVisite__c();
		test7.Name = '107499';
		test7.Tipologia_Inserimento__c = 'visita';
		test7.Data_Attivita__c = System.Today();
		test7.Originator__c = 'Web';
		test7.Originator_Dettaglio__c = 'IFIS_IMPRESA';
		test7.Assegnatario__c = 'Testing';
		test7.Esito_Livello_1__c = 'Nessun Interesse';
		test7.Esito_Livello_2__c = 'Pricing';
		test7.Commenti__c = 'Testo';

		Test.startTest();
		insert test7;
		Test.stopTest();
	}

	@isTest static void testInserimentoVisita2() {
		CaricamentoContattiVisite__c test8 = new CaricamentoContattiVisite__c();
		test8.Name = '1000';
		test8.Tipologia_Inserimento__c = 'visita';
		test8.Data_Attivita__c = System.Today();
		test8.Originator__c = 'Web';
		test8.Originator_Dettaglio__c = 'IFIS_IMPRESA';
		test8.Assegnatario__c = 'Testing';
		test8.Esito_Livello_1__c = 'Nessun Interesse';
		test8.Esito_Livello_2__c = 'Pricing';
		test8.Commenti__c = 'Testo';

		Test.startTest();
		insert test8;
		Test.stopTest();
	}

	//@isTest static void testInserimentoVisita3() {
		//CaricamentoContattiVisite__c test13 = new CaricamentoContattiVisite__c();
		//test13.Name = '107499';
		//test13.Tipologia_Inserimento__c = 'visita';
		//test13.Data_Attivita__c = System.Today();
		//test13.Originator__c = '';
		//test13.Originator_Dettaglio__c = 'IFIS_IMPRESA';
		//test13.Assegnatario__c = 'Testing';
		//test13.Esito_Livello_1__c = 'Nessun Interesse';
		//test13.Esito_Livello_2__c = 'Pricing';
		//test13.Commenti__c = 'Testo';

		//Test.startTest();
		//insert test13;
		//Test.stopTest();
	//}

	@isTest static void testInserimentoVisita4() {
		CaricamentoContattiVisite__c test14 = new CaricamentoContattiVisite__c();
		test14.Name = '107499';
		test14.Tipologia_Inserimento__c = 'visita';
		test14.Data_Attivita__c = System.Today();
		test14.Originator__c = 'Web';
		test14.Originator_Dettaglio__c = '';
		test14.Assegnatario__c = 'Testing';
		test14.Esito_Livello_1__c = 'Nessun Interesse';
		test14.Esito_Livello_2__c = 'Pricing';
		test14.Commenti__c = 'Testo';

		Test.startTest();
		insert test14;
		Test.stopTest();
	}

	@isTest static void testInserimento() {
		CaricamentoContattiVisite__c test12 = new CaricamentoContattiVisite__c();
		test12.Name = '107499';
		test12.Tipologia_Inserimento__c = 'ERRATO';

		Test.startTest();
		insert test12;
		Test.stopTest();
	}
}