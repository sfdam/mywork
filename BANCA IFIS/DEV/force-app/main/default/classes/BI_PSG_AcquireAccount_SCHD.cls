global class BI_PSG_AcquireAccount_SCHD implements Schedulable {

	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 

	global void execute(SchedulableContext sc) {
		go();
	}

	public void go() {    

        BI_PSG_AcquireAccount_BTCH btc = new BI_PSG_AcquireAccount_BTCH();
        Id batchId = Database.executeBatch(btc, 1);
    
	}  

}