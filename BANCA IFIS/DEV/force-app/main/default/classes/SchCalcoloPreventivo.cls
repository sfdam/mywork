global class SchCalcoloPreventivo implements Schedulable {

    public static final Integer MAX_NUM_PREVENTIVI = 50;

    /**
     * Recupera gli ultimi MAX_NUM_PREVENTIVI preventivi da calcolare e li accoda
    **/
    global void execute(SchedulableContext sc) {

      QueueItemPreventivo__c[] preventiviDaCalcolare = [SELECT
        Id,
        Cessione__c,
        CreatedDate
        FROM QueueItemPreventivo__c
        WHERE Solved__c = false
        ORDER BY CreatedDate DESC
        LIMIT :MAX_NUM_PREVENTIVI];

      if (preventiviDaCalcolare.isEmpty()) return;

      System.enqueueJob(new QbleCalcoloPreventivo(preventiviDaCalcolare));
    }
}