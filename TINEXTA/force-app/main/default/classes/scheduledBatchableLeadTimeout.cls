global class scheduledBatchableLeadTimeout implements Schedulable{
global void execute(SchedulableContext sc) {
    WRT_BatchOnLeadTimeout b = new WRT_BatchOnLeadTimeout(); 
	database.executebatch(b);
	}
}