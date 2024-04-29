trigger QueueItemPreventivo on QueueItemPreventivo__c (after insert) {
  T tu = T.getInstance();

  if (T.isAfterInsert()) {
    TrgQueueItemPreventivo.calcoloPreventivo(tu);
  }

}