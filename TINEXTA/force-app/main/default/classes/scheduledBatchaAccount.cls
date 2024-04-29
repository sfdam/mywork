global class scheduledBatchaAccount implements Schedulable {
   global void execute(SchedulableContext sc) {
      CMK_BatchOnZonaAccount b = new CMK_BatchOnZonaAccount(); 
      database.executebatch(b);
   }
}