global class scheduledBatchableZonaCoMark implements Schedulable {
   global void execute(SchedulableContext sc) {
      CMK_BatchOnZonaCoMark b = new CMK_BatchOnZonaCoMark(); 
      database.executebatch(b);
   }
}