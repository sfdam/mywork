global class scheduledBatchableAccountTimeout implements Schedulable{
global void execute(SchedulableContext sc) {
    WRT_BatchOnAccountTimeout b = new WRT_BatchOnAccountTimeout(); 
	database.executebatch(b);
	}
}