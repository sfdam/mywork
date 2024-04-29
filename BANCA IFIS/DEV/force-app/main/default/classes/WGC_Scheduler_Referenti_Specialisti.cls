global class WGC_Scheduler_Referenti_Specialisti implements Schedulable{

  global void execute(SchedulableContext sc) {

    WGC_Batch_Referenti_Specialisti b = new WGC_Batch_Referenti_Specialisti();
    Database.executebatch(b, 200);
  }
}