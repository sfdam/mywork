public class AlignNdgHierarchyQueue implements Queueable {
    private Set<String> walletsIdSet{get;set;}

    public AlignNdgHierarchyQueue(Set<String> walletsIdSet) {
        this.walletsIdSet = walletsIdSet;
    }
    public void execute(QueueableContext context) {
        Batch_AlignNdgHierarchy b = new Batch_AlignNdgHierarchy();
        b.walletsIdSet = this.walletsIdSet;
        Id batchJobId = Database.executeBatch(b, 200);
    }
}