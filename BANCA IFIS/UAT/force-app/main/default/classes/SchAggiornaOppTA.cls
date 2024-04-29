global class SchAggiornaOppTA implements Schedulable {
	global void execute(SchedulableContext sc) {
		BtcAggiornaOpp b = new BtcAggiornaOpp(true);
    Database.executebatch(b, 50);
	}
}