global class bifis_crm_b_S_MccNsaGenerateOpportunity implements Schedulable {

	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		go();
	}

	public void go() {    
        bifis_crm_b_MccNsaGenerateOpportunity btc = new bifis_crm_b_MccNsaGenerateOpportunity();
        Id batchId = Database.executeBatch(btc, 1);
    }  

}