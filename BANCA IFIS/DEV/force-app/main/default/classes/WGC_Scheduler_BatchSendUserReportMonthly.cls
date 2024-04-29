global class WGC_Scheduler_BatchSendUserReportMonthly implements Schedulable{

  global void execute(SchedulableContext sc) {

    WGC_BatchSendUserReportMonthly b = new WGC_BatchSendUserReportMonthly();
    Database.executebatch(b, 200);
  }
}