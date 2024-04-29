global class BI_COM_PuliziaLogC_SCHD implements Schedulable{

	global void execute(SchedulableContext sc) {
		go();
	}

	public void go() {    

        BI_COM_PuliziaLogC_BTCH btc = new BI_COM_PuliziaLogC_BTCH();
        Id batchId = Database.executeBatch(btc);
    
	}  

}