global class Batch_CloseIter implements Schedulable, Database.Batchable<sObject>,Database.stateful{
    
    public FunzionalitaITER__c f = FunzionalitaITER__c.getOrgDefaults();
    public Date startDate {

        get{

            if(startDate != null){

                return startDate;
            }
            days = Integer.valueOf(f.TimeLimit__c);
            startDate = f.TimeLimit__c != null? Date.today().addDays(-days): Date.today().addDays(-30);
            return startDate;
        }set;
    }

    public Integer days{get;set;} 

    public Date initialDate = f.StartDate__c;


    public List<SObject> woToUpdateList = new List<SObject>();

    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT id, Status, PTF_NotaInterventoTecnico__c, EndDate, Queues__c FROM WorkOrder WHERE Status = \'Pending\' AND CreatedDate <=: startDate';
        if(initialDate != null) query += ' AND CreatedDate >=: initialDate';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<WorkOrder> scope) {

        Map<String, SObject> woMap = SV_Utilities.keyBy(scope, 'Id');
        List<Approval.ProcessWorkitemRequest> pwirList = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem p: [SELECT Id, ProcessInstance.TargetObjectId
                                                FROM ProcessInstanceWorkitem
                                                WHERE ProcessInstance.Status='Pending' AND ProcessInstance.TargetObjectId IN:woMap.keySet()]){
            Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();

            result.setAction('Removed');          
            result.setWorkitemId(p.Id);
            pwirList.add(result);

        }

        Approval.process(pwirList);

        for(SOBJECT wo : woMap.values()){

            wo.put('Status', 'Annullato');
            wo.put('EndDate', DateTime.now());
            wo.put('PTF_NotaInterventoTecnico__c', 'Chiusura automatica dopo ' + days + ' giorni.');
        }

        // update woMap.values();
        woToUpdateList.addAll(woMap.values());
    }

    global void finish(Database.BatchableContext BC) {

        // update woToUpdateList;
        // List<String> queuesList = new List<String>();
        // for(SObject wo:woToUpdateList){
        //     queuesList.add('%' + (String)wo.get('Queues__c') + '%');
        // }
        // delete [SELECT id FROM Group WHERE DeveloperName LIKE: queuesList AND Type = 'Queue'];
        ID jobID = System.enqueueJob(new WorkOrderQueueableJobs(woToUpdateList));
    }

    global void execute(SchedulableContext SC) {
        
        Id batchJobId = Database.executeBatch(new Batch_CloseIter(), 200);
    }
}