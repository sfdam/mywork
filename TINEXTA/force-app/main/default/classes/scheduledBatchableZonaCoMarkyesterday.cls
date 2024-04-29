global class scheduledBatchableZonaCoMarkyesterday implements Schedulable {

   global void execute(SchedulableContext sc) {
      CMK_BatchOnZonaCoMarkYesterday b = new CMK_BatchOnZonaCoMarkYesterday(); 
      database.executebatch(b);
   }
}