global class SchedWRT_BatchOnCPQCalculate implements Schedulable {
   global void execute(SchedulableContext sc) {
      WRT_BatchOnCPQCalculate b = new WRT_BatchOnCPQCalculate(); 
      database.executebatch(b);
   }
}