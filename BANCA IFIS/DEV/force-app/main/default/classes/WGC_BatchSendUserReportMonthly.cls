global class WGC_BatchSendUserReportMonthly implements Database.Batchable<sObject> {

    List<String> taskRecordTypes;
    List<String> eventRecordTypes;
    Id referentePromemoria;
    String reportId;
    OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where DisplayName = 'no-reply@bancaifis.it'];

    public WGC_BatchSendUserReportMonthly(){
        taskRecordTypes = new List<String>{'ContattoTelefonicoDiretto', 'Previsione_Avvio_Rapporto'};
        eventRecordTypes = new List<String>{'VisitaCommerciale'};
        referentePromemoria = Impostazioni__c.getInstance().Id_Referente_Promemoria__c;
        reportId = Impostazioni__c.getInstance().Id_ReportMensile__c;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        //system.debug([Select id, name, email, ManagerId from User where IsActive = true]);
        if(Test.isRunningTest()){
            return Database.getQueryLocator('Select id, name, email, Manager.Email from User WHERE Id =\'' + UserInfo.getUserId() + '\'');
        }
        else{
            return Database.getQueryLocator('Select id, name, email, Manager.Email from User where IsActive = true and Invio_Report__c = true');
        }
    }

    global void execute(Database.BatchableContext BC, List<User> scope) {

        try {
        
        List<Id> userIds = new List<Id>();
        for(User user : scope)
        {
            userIds.add(user.id);
        }

        //List<Integer> tasks = [Select count(Id), Owner.Id from Task Group by Owner.Id];
        //List<Integer> events = [Select count(Id), Owner.id from Event Group by Owner.Id];

        List<Task> tasks = [SELECT id, OwnerId FROM Task WHERE OwnerId IN :userIds AND DataOraEsitazione__c = null AND (RecordTypeDevName__c IN :taskRecordTypes OR (RecordTypeDevName__c = 'Promemoria' AND CreatedById = :referentePromemoria)) AND ActivityDate = LAST_N_MONTHS:12];
        List<Event> events = [SELECT id, OwnerId FROM Event WHERE OwnerId IN :userIds AND DataOraEsitazione__c = null AND RecordTypeDevName__c IN :eventRecordTypes AND  ActivityDateTime = LAST_N_MONTHS:12 AND accountId != NULL];
        
        Map<Id, Integer> taskCounts = new Map<Id, Integer>();
        Map<Id, Integer> eventCounts = new Map<Id, Integer>();

        for(Task task : tasks)
        {
            Integer val = taskCounts.get(task.OwnerId);
            if(val == null)
            {
                val = 0;
            }

            taskCounts.put(task.OwnerId, val+1);
        }

        for(Event event : events)
        {
            Integer val = eventCounts.get(event.OwnerId);
            if(val == null)
            {
                val = 0;  
            }

            eventCounts.put(event.OwnerId, val+1);
        }
        //List<Task> tasks = [SELECT id FROM Task WHERE OwnerId = :user.id AND DataOraEsitazione__c = null AND RecordTypeDevName__c IN :taskRecordTypes AND ActivityDate = LAST_N_DAYS:7];
        //List<Event> events = [SELECT id FROM Event WHERE OwnerId = :user.id AND DataOraEsitazione__c = null AND RecordTypeDevName__c IN :eventRecordTypes AND  ActivityDateTime = LAST_N_DAYS:7];

        //system.debug(scope);
		Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
            
        for(User user : scope)
        {

            if(taskCounts.get(user.Id)!=null||eventCounts.get(user.Id)!=null) {

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.orgwideemailaddressid = owea.Id;
            message.toAddresses = new String[] { user.Email };
            if(user.Manager.Email!=null)
            {
                message.ccaddresses = new String[] { user.Manager.Email, 'SalesExcellenceSupport@bancaifis.it.test'  };
            }
            //message.toAddresses = new String[] {'marcello.spadaccini@tengroup.it', 'vanessa.scarna@tengroup.it'};
            //message.ccaddresses = new String[] {};
            message.optOutPolicy = 'FILTER';
            message.subject = 'Attività Scadute';
            message.htmlbody = 
            'Salve ' + user.name + '<br><br>' +
            'la presente per ricordati che hai le seguenti attività scadute:<br>'+
            'Contatti Telefonici: ' + (taskCounts.get(user.Id)==null?0:taskCounts.get(user.Id)) + '<br>'+
            'Visite Commerciali: ' + (eventCounts.get(user.Id)==null?0:eventCounts.get(user.Id)) + '<br><br>'+
            'Per visualizzare l’elenco completo cliccare al seguente <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + reportId + '">link</a>'
            ;
            messages.Add(message);
            }
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
        } catch (Exception ex) {
            System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext BC) {}
}