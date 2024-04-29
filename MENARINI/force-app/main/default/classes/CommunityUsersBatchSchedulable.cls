global class CommunityUsersBatchSchedulable implements Schedulable{
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new CommunityUsersBatch(), 200);
    }
}