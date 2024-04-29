global class Batch_CloseIter implements Schedulable, Database.Batchable<sObject>,Database.stateful{
    
    public FunzionalitaITER__c f = FunzionalitaITER__c.getOrgDefaults();

    public Map<String, IterConfiguration__c> iterConfigMap {
        get{
            if(iterConfigMap != null) return iterConfigMap;
            iterConfigMap = new Map<String, IterConfiguration__c>();
            for(IterConfiguration__c iterConfig : [SELECT UnitaOrganizzativa__c, TipoSpostamento__c, GiorniAnnullamento__c FROM IterConfiguration__c WHERE GiorniAnnullamento__c != NULL AND TipoSpostamento__c != NULL]){
                iterConfigMap.put(iterConfig.UnitaOrganizzativa__c + '_' + iterConfig.TipoSpostamento__c, iterConfig);
            }
            return iterConfigMap;
        }set;
    } 

    public Date initialDate = f.StartDate__c;

    public List<SObject> woToUpdateList = new List<SObject>();

    global Database.QueryLocator start(Database.BatchableContext BC) {

        Date maxDate = Test.isRunningTest() ? Date.today().addDays(10) : Date.today().addDays(-3);
        String query = 'SELECT id, Status, PTF_NotaInterventoTecnico__c, EndDate, Queues__c, PTF_Destinazione__c, PTF_Destinazione__r.PTF_FIliale__c, TipologiaSpostamento__c, CreatedDate FROM WorkOrder WHERE Status = \'Pending\' AND CreatedDate <=: maxDate';
        if(initialDate != null) query += ' AND CreatedDate >=: initialDate';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<WorkOrder> scope) {
		system.debug('scope' +scope);
        Map<String, SObject> woMap = SV_Utilities.keyBy(scope, 'Id');
        system.debug('woMap' +woMap);
        List<Approval.ProcessWorkitemRequest> pwirList = new List<Approval.ProcessWorkitemRequest>();
        Set<String> woToCloseSet = new Set<String>();
        for(WorkOrder wo : scope){

            System.debug('Dk wo: ' + JSOn.serialize(wo));
            Date startDate = null;
            Integer days = null;
            String configKey = wo.PTF_Destinazione__r.PTF_FIliale__c + '_' + wo.TipologiaSpostamento__c;
            System.debug('Dk configKey: ' + configKey);
            if(iterConfigMap.containsKey(configKey)){
                days = Integer.valueOf(iterConfigMap.get(configKey).GiorniAnnullamento__c);
            }else{
                days = 15;
            }
            startDate = Date.today().addDays(-days);
            System.debug('DK wo.CreatedDate:' + wo.CreatedDate);
            System.debug('DK startDate:' + startDate);
            if(wo.CreatedDate <= startDate){
	 		    System.debug('line 49');
                wo.Status = 'Annullato';
                wo.EndDate = DateTime.now();
                wo.PTF_NotaInterventoTecnico__c = 'Chiusura automatica dopo ' + days + ' giorni.';
                woToCloseSet.add(wo.Id);
                woToUpdateList.add(wo);
            }
        }
        for(ProcessInstanceWorkitem p: [SELECT Id, ProcessInstance.TargetObjectId
                                                FROM ProcessInstanceWorkitem
                                                WHERE ProcessInstance.Status='Pending' AND ProcessInstance.TargetObjectId IN:woToCloseSet]){
            Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();

            result.setAction('Removed');          
            result.setWorkitemId(p.Id);
            pwirList.add(result);
        }
        System.debug('pwirList');
        Approval.process(pwirList);
    }

    global void finish(Database.BatchableContext BC) {

        ID jobID = System.enqueueJob(new WorkOrderQueueableJobs(woToUpdateList));
    }

    global void execute(SchedulableContext SC) {
        
        Id batchJobId = Database.executeBatch(new Batch_CloseIter(), 200);
    }
}