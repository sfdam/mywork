global class SchCheckStatoQQ implements Schedulable {
   global void execute(SchedulableContext sc) {
      BtcCheckStatoQQ b = new BtcCheckStatoQQ();
      Database.executebatch(b);
  }
}