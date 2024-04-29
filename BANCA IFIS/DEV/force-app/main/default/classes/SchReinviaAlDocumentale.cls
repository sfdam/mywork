public without sharing class SchReinviaAlDocumentale implements Schedulable {
  public void execute(SchedulableContext sc) {
    BtcReinviaAlDocumentale b = new BtcReinviaAlDocumentale();
    Database.executebatch(b, 1);
  }
}