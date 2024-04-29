global class scheduledBatchaAccountYesterday implements Schedulable {
   global void execute(SchedulableContext sc) {
      CMK_BatchOnZonaAccountYesterday b = new CMK_BatchOnZonaAccountYesterday(); 
      database.executebatch(b);
   }
}