global class SchBatchUpdateOpportunity implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        WGC_BatchUpdateOpportunity b = new WGC_BatchUpdateOpportunity();
        Database.executebatch(b);
    }
}