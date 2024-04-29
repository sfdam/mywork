public class TrgQueueItemPreventivo {
  public static void calcoloPreventivo(T tu) {
    System.enqueueJob(new QbleCalcoloPreventivo(tu.triggerNew));
  }
}