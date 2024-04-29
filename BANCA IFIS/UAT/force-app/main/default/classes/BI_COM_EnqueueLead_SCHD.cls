global class BI_COM_EnqueueLead_SCHD implements Schedulable {

	global void execute(SchedulableContext sc) {
		go();
	}

	public void go() {
		//recupero lead odierni non qualificati
		List<Lead> leads = [
		                    SELECT Id
		                    FROM Lead
		                    WHERE CreatedDate = LAST_N_DAYS:5
		                    AND Status = 'Non qualificato'
		                   ];

		//li rimando in elaborazione forzando update sullo stato
		U.massSet(leads, 'Status', 'Da qualificare');
		update(leads);
	}
}