global class WGC_Scheduler_BatchSendUserReportWeekly implements Schedulable{

  global void execute(SchedulableContext sc) {

    WGC_BatchSendUserReportWeekly b = new WGC_BatchSendUserReportWeekly();
    Database.executebatch(b, 200);
  }
}