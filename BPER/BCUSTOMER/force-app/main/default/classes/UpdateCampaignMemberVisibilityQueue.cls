public class UpdateCampaignMemberVisibilityQueue implements Queueable {
    Map<Id, Account> newMap{get;set;}
    Map<Id, Account> oldMap{get;set;}
    Set<String> accountIdSet{get;set;}
    public UpdateCampaignMemberVisibilityQueue(Map<Id, Account> newMap, Map<Id, Account> oldMap, Set<String> accountIdSet) {
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.accountIdSet = accountIdSet;
    }
    public void execute(QueueableContext context) {
        Batch_UpdateCampaignMemberVisibility ucmv = new Batch_UpdateCampaignMemberVisibility(newMap, oldMap, accountIdSet);
        database.executeBatch(ucmv);
    }
}