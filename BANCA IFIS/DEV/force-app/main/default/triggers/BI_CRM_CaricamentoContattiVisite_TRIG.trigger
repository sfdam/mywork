trigger BI_CRM_CaricamentoContattiVisite_TRIG on CaricamentoContattiVisite__c(after insert) {
	try {
		List<CaricamentoContattiVisite__c> attivita = new List<CaricamentoContattiVisite__c> ();

		for (CaricamentoContattiVisite__c att : Trigger.new) {
			attivita.add(att);
		}

		System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(attivita));
	} catch(Exception e) {
		System.debug('Errore creazione attività: ' + e.getMessage());
	}
}