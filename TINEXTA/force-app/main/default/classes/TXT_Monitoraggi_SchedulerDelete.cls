public without sharing class TXT_Monitoraggi_SchedulerDelete implements Database.Batchable<SObject> {
    
    public String query;

    public TXT_Monitoraggi_SchedulerDelete(String query) {
        this.query = query;
        if(String.isBlank(this.query)){
            this.query = 'SELECT Id, State, StartTime, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE \'%Innolva Monitoraggi - GetProdottoDaNota%\' AND State = \'DELETED\' ORDER BY CreatedDate ASC';
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext info, List<CronTrigger> scheduledJobs) {
        for(CronTrigger ct : scheduledJobs){
            System.abortJob(ct.Id);
        }
    }

    public void finish(Database.BatchableContext info) {}
}