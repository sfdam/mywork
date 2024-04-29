global class BI_COM_SuddivisioneTerritoriale_BTCH implements Database.Batchable<sObject>, Database.Stateful {

	public List<Suddivisione_Territoriale_FD__c> scope;
	String query;
	List<Suddivisione_Territoriale_FD__c> sudd;


	global BI_COM_SuddivisioneTerritoriale_BTCH() {
		Date data = Date.today();
		Integer meseCorrente = data.month();
		Integer annoCorrente = data.year();
		sudd = new List<Suddivisione_Territoriale_FD__c> ([select Id, Operatore_FD__c, Filiale__c from Suddivisione_Territoriale_FD__c where Mese__c = :meseCorrente AND Anno__c = :annoCorrente]);
		Map<String, Suddivisione_Territoriale_FD__c> suddMap = new Map<String, Suddivisione_Territoriale_FD__c> ();
		for (Suddivisione_Territoriale_FD__c s : sudd) {
			suddMap.put(s.Filiale__c, s);
		}

		String str = '(';
		for (String z : suddMap.keySet()) {
			str += '\'' + z + '\', ';
		}
		str = str.removeEnd(', ');
		str += ')';

		query = 'select Id, Utente__c, Filiale__c FROM AssegnazioneAnagrafica__c WHERE FiloDiretto__c = true AND Filiale__c IN ' + str;
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {

		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<AssegnazioneAnagrafica__c> scope) {
		try {
			List<AssegnazioneAnagrafica__c> listUpdate = new List<AssegnazioneAnagrafica__c>();
			Map<Id,AssegnazioneAnagrafica__c> mapUpdate = new Map<Id,AssegnazioneAnagrafica__c>();

			if (sudd.size() > 0) {
				for (Suddivisione_Territoriale_FD__c zona : sudd) {
					for (AssegnazioneAnagrafica__c ass : scope) {
						if (ass.Filiale__c == zona.Filiale__c)
						ass.Utente__c = zona.Operatore_FD__c;
						listUpdate.add(ass);
					}
				}
				//rimuovo eventuali id duplicati
				mapUpdate.putAll(listUpdate);
				update mapUpdate.values();
			}

		} catch(Exception ex) {
			System.debug('Errore nella riassegnazione territoriale: ' + ex);
		}
	}

	global void finish(Database.BatchableContext bc) {

		AsyncApexJob aaj = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CompletedDate FROM AsyncApexJob WHERE Id = :BC.getJobId()];
		System.debug('@@@ query sul job ' + aaj);

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		String[] toAddresses = new String[] { 'ict.am.crmmulticanalita@bancaifis.it' };
		mail.setToAddresses(toAddresses);
		mail.setSubject('Aggiornamento Suddivisione Territoriale FD ' + aaj.Status);
		mail.setBccSender(false);
		mail.setUseSignature(false);
		OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'ict.am.crmmulticanalita@bancaifis.it' LIMIT 1];
		mail.setOrgWideEmailAddressId(owea.Id);
		mail.setPlainTextBody('The apex job processed ' + aaj.TotalJobItems + ' Batches with ' + aaj.NumberOfErrors + ' failures');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

}