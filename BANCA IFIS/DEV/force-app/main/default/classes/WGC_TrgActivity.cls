public class WGC_TrgActivity {
    
    public static Boolean excuteInTest = false;
    
    public static void setupOriginator(List<sObject> activityList) {
        System.debug('SV setupOriginator: ' + activityList);
        
        if((!Test.isRunningTest() || excuteInTest)){
            User user = [SELECT Id, Qualifica_Utente__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            System.debug('SV user: ' + user);

            // SV Metadato Canale di sviluppo
            Map<String, SObject> canaleDiSviluppoMap = U.keyBy([
                SELECT Id, DeveloperName, MasterLabel, NamespacePrefix, Label, 
                    QualifiedApiName, Originator__c, Originator_dettaglio__c, 
                    Forzatura__c, Canale_di_sviluppo__c, Qualifica_Utente__c 
                FROM WGC_Originator__mdt ], 'Qualifica_Utente__c');
            System.debug('SV canaleDiSviluppoMap: ' + canaleDiSviluppoMap);

            Set<Id> accountsId = new Set<Id>();
            Set<Id> recordTypeId = new Set<Id>();
            for(SObject sObj : activityList) {
                if((Id)sObj.get('WhatId') != null){
                    accountsId.add((Id)sObj.get('WhatId'));
                }
                recordTypeId.add((Id)sObj.get('RecordTypeId'));
            }

            Map<String, SObject> allAccMap = U.keyBy([
                SELECT Id, WGC_Canale_di_sviluppo__c, RecordTypeId, WGC_Originator__c, WGC_Originator_dettaglio__c 
                FROM Account 
                WHERE Id IN : accountsId ], 'Id');
                System.debug('SV accountsId: ' + accountsId);
            System.debug('SV allAccMap: ' + allAccMap);

            for (String fieldId : allAccMap.keySet()){
            recordTypeId.add((Id)allAccMap.get(fieldId).get('RecordTypeId'));
            }

            Schema.DescribeSObjectResult dsrEvent = Event.SObjectType.getDescribe();
            Schema.RecordTypeInfo defaultRecordTypeEvent;
            for(Schema.RecordTypeInfo rti : dsrEvent.getRecordTypeInfos()) {
                if(rti.isDefaultRecordTypeMapping()) {
                    defaultRecordTypeEvent = rti;
                }
            }
            
            Schema.DescribeSObjectResult dsrTask = Task.SObjectType.getDescribe();
            Schema.RecordTypeInfo defaultRecordTypeTask;
            for(Schema.RecordTypeInfo rti : dsrTask.getRecordTypeInfos()) {
                if(rti.isDefaultRecordTypeMapping()) {
                    defaultRecordTypeTask = rti;
                }
            }

            recordTypeId.add(defaultRecordTypeEvent.getRecordTypeId());
            recordTypeId.add(defaultRecordTypeTask.getRecordTypeId());

            Map<String, SObject> allRecordTypeMap = U.keyBy([
                SELECT Id, DeveloperName 
                FROM RecordType 
                WHERE Id IN : recordTypeId ], 'Id');
            System.debug('SV allRecordTypeMap: ' + allRecordTypeMap);

    /*
            Map<Id,AggregateResult> countEventsMap = new Map<id,AggregateResult>([SELECT AccountId Id, COUNT(Id) EventCount 
                                                                                    FROM Event 
                                                                                    WHERE CreatedDate = THIS_YEAR AND 
                                                                                        AccountId IN : accountsId AND 
                                                                                        (WGC_Forzatura__c = FALSE OR 
                                                                                            (WGC_Forzatura__c = TRUE AND 
                                                                                            WGC_Macro_Esito__c = 'Positivo')
                                                                                        ) AND
                                                                                        RecordType.DeveloperName != 'Promemoria' AND
                                                                                        (NOT RecordType.DeveloperName LIKE '%Diario%')
                                                                                    GROUP BY AccountId]);

            Map<Id,AggregateResult> countTasksMap = new Map<id,AggregateResult>([SELECT AccountId Id, COUNT(Id) TaskCount 
                                                                                    FROM Task 
                                                                                    WHERE CreatedDate = THIS_YEAR AND 
                                                                                        AccountId IN : accountsId AND 
                                                                                        (WGC_Forzatura__c = FALSE OR 
                                                                                            (WGC_Forzatura__c = TRUE AND 
                                                                                            WGC_Macro_Esito__c = 'Positivo')
                                                                                        ) AND
                                                                                        RecordType.DeveloperName != 'Promemoria' AND
                                                                                        (NOT RecordType.DeveloperName LIKE '%Diario%')
                                                                                    GROUP BY AccountId]);

            Map<Id,AggregateResult> countOppsMap = new Map<id,AggregateResult>([SELECT AccountId Id, COUNT(Id) OpportunityCount 
                                                                                    FROM Opportunity 
                                                                                    WHERE CreatedDate = THIS_YEAR AND 
                                                                                        AccountId IN : accountsId AND 
                                                                                        (WGC_Forzatura__c = FALSE OR 
                                                                                            (WGC_Forzatura__c = TRUE AND 
                                                                                            StageName = 'Positivo')
                                                                                        ) 
                                                                                    GROUP BY AccountId]);

            System.debug('SV countEventsMap: ' + countEventsMap);
            System.debug('SV countTasksMap: ' + countTasksMap);
            System.debug('SV countOppsMap: ' + countOppsMap);
    */
            List<Event> eventList     = new List<Event>();
            List<Task> taskList       = new List<Task>();
            List<Opportunity> oppList = new List<Opportunity>();

            if(accountsId.size() > 0){
                eventList = [SELECT Id, AccountId, Originator__c, Originator_di_dettaglio__c, CreatedDate, WGC_Forzatura__c, WGC_Macro_Esito__c 
                                        FROM Event 
                                        WHERE CreatedDate >= LAST_N_MONTHS:12 AND 
                                            AccountId IN : accountsId AND 
                                            (WGC_Forzatura__c = FALSE OR 
                                                (WGC_Forzatura__c = TRUE AND 
                                                WGC_Macro_Esito__c = 'Positivo')
                                            ) AND
                                            RecordType.DeveloperName != 'Promemoria' AND
                                            (NOT RecordType.DeveloperName LIKE '%Diario%')
                                            // SM - TEN - TENAM-254 Aggiunta condizione per Originator
                                            AND Originator__c != null
                                            ORDER BY CreatedDate DESC ];

                taskList = [SELECT Id, AccountId, Originator__c, Originator_di_dettaglio__c, CreatedDate, WGC_Forzatura__c  
                                            FROM Task 
                                            WHERE CreatedDate >= LAST_N_MONTHS:12 AND 
                                            AccountId IN : accountsId AND 
                                            (WGC_Forzatura__c = FALSE OR 
                                                (WGC_Forzatura__c = TRUE AND 
                                                WGC_Macro_Esito__c = 'Positivo')
                                            ) AND
                                            RecordType.DeveloperName != 'Promemoria' AND
                                            (NOT RecordType.DeveloperName LIKE '%Diario%')
                                            // SM - TEN - TENAM-254 Aggiunta condizione per Originator
                                            AND Originator__c != null
                                            ORDER BY CreatedDate DESC ];

                oppList = [SELECT Id, AccountId, Originator__c, Originator_di_dettaglio__c, CreatedDate, WGC_Forzatura__c 
                                                FROM Opportunity 
                                                WHERE CreatedDate >= LAST_N_MONTHS:12 AND 
                                                AccountId IN : accountsId AND 
                                                (WGC_Forzatura__c = FALSE OR 
                                                    (WGC_Forzatura__c = TRUE AND 
                                                    StageName = 'Positivo')
                                                ) 
                                                // SM - TEN - TENAM-254 Aggiunta condizione per Originator
                                                AND Originator__c != null
                                                ORDER BY CreatedDate DESC ];

            }
            
            System.debug('SV eventList: ' + eventList);
            System.debug('SV taskList: ' + taskList);
            System.debug('SV oppList: ' + oppList);

            // Date dateLastEvent = date.newinstance(eventList[0].ActivityDateTime.year(), eventList[0].ActivityDateTime.month(), eventList[0].ActivityDateTime.day());
            // Date dateLastTask = taskList[0].ActivityDate;
            // Date dateLastOpportunity = oppList[0].Data_Apertura__c;

            // AND RecordType.DeveloperName != 'WGC_Diario_Inserimento_Campagna'
            // AND RecordType.DeveloperName != 'WGC_Diario_Modifica_Qualifica'
            // AND RecordType.DeveloperName != 'WGC_Diario_Modifica_Rating'
            // AND RecordType.DeveloperName != 'WGC_Diario_Nuova_Opportunita'
            // AND RecordType.DeveloperName != 'Promemoria'

            for(SObject sObj : activityList) {

                if ((Boolean)sObj.get('WGC_IsCreatedFromLead__c')){
                    System.debug('SV ORIGINATOR NON ESEGUITO ACTIVITY FROM LEAD');
                    continue;
                }

                // SE RECORDTYPE NON VALORIZZATO, RECUPERO IL DEFAULT CONFIGURATO E LO SETTO SULL'OGGETTO
                if ( sObj.get('RecordTypeId') == null || String.isBlank(String.valueOf(sObj.get('RecordTypeId'))) ) {
                    if ( String.valueOf(sObj.getSObjectType()) == 'Task' )
                        sObj.put('RecordTypeId', defaultRecordTypeTask.getRecordTypeId());
                    else if ( String.valueOf(sObj.getSObjectType()) == 'Event' )
                        sObj.put('RecordTypeId', defaultRecordTypeEvent.getRecordTypeId());
                }

                System.debug(sObj);
                System.debug(string.valueof(sObj.getSObjectType()));
                System.debug( allRecordTypeMap.get((String)sObj.get('RecordTypeId')).get('DeveloperName'));
                if((String)sObj.get('WhatId') != null) System.debug(allRecordTypeMap.get((String)allAccMap.get((String)sObj.get('WhatId')).get('RecordTypeId')).get('DeveloperName'));
                
                if(((String)sObj.get('WhatId') != null) && allRecordTypeMap.get((String)allAccMap.get((String)sObj.get('WhatId')).get('RecordTypeId')).get('DeveloperName') != 'WGC_Tribunale' &&
                    allRecordTypeMap.get((String)sObj.get('RecordTypeId')).get('DeveloperName') != 'Promemoria' &&
                    allRecordTypeMap.get((String)sObj.get('RecordTypeId')).get('DeveloperName') != 'WGC_Diario_Inserimento_Campagna' && 
                    allRecordTypeMap.get((String)sObj.get('RecordTypeId')).get('DeveloperName') != 'WGC_Diario_Modifica_Qualifica' &&
                    allRecordTypeMap.get((String)sObj.get('RecordTypeId')).get('DeveloperName') != 'WGC_Diario_Modifica_Rating' &&
                    allRecordTypeMap.get((String)sObj.get('RecordTypeId')).get('DeveloperName') != 'WGC_Diario_Nuova_Opportunita'){
                    //if( (string.valueof(sObj.getSObjectType()) == 'Task' && allRecordTypeMap.get((String)sObj.get('RecordTypeId')).get('DeveloperName') != 'ContattoTelefonicoFastFinance') || (string.valueof(sObj.getSObjectType()) == 'Event' && allRecordTypeMap.get((String)sObj.get('RecordTypeId')).get('DeveloperName') != 'VisitaFastFinance')  ){
                    if( string.valueof(sObj.getSObjectType()) == 'Task' || string.valueof(sObj.getSObjectType()) == 'Event'){
                        System.debug('SV sObj ID: ' +(Id)sObj.get('WhatId'));
                        System.debug('SV EventCount: ' + eventList.size());
                        System.debug('SV TaskCount: ' + taskList.size());
                        System.debug('SV OpportunityCount: ' + oppList.size());

                        if(eventList.size() == 0 && taskList.size() == 0 && oppList.size() == 0){
                                
                                System.debug('SV NO ACTIVITY');

                                // sObj.put('Originator__c', (((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator__c')) != null || ((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator__c')) != '') ? ((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator__c')) : ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator__c);
                                // sObj.put('Originator_di_dettaglio__c', (((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator_dettaglio__c')) != null || ((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator_dettaglio__c')) != '') ? ((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator_dettaglio__c')) : ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator_dettaglio__c);
                                
                                sObj.put('Originator__c', ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator__c);
                                sObj.put('Originator_di_dettaglio__c', ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator_dettaglio__c);


                                System.debug('SV sObj: ' + sObj);

                        } else {
                            System.debug('SV MD CANALE DI SVILUPPO: ' + ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Canale_di_sviluppo__c);
                            if(((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Forzatura__c.toUpperCase() == 'NO'){

                                Id lastActivityId = null;
                                DateTime lastActivityDate = null;
                                String lastActivityType = '';
                                String lastActivityOriginator = '';
                                String lastActivityOriginatorDetail = '';
                                    for(Event event : eventList){
                                        if(event.AccountId == (Id)sObj.get('WhatId') && event.Originator__c != null && event.Originator_di_dettaglio__c != null){
                                            DateTime dateLastEvent = event.CreatedDate;
                                            if(lastActivityDate == null || lastActivityDate < dateLastEvent){
                                                lastActivityDate = dateLastEvent;
                                                lastActivityType = 'EVENT';   
                                                lastActivityId = event.Id;
                                                lastActivityOriginator = event.Originator__c;
                                                lastActivityOriginatorDetail = event.Originator_di_dettaglio__c;
                                            }    
                                            break;                         
                                        }
                                    }

                                    for(Task task : taskList){
                                        if(task.AccountId == (Id)sObj.get('WhatId') && task.Originator__c != null && task.Originator_di_dettaglio__c != null){
                                            DateTime dateLastTask = task.CreatedDate;
                                            if(lastActivityDate == null || lastActivityDate < dateLastTask){
                                                lastActivityDate = dateLastTask;
                                                lastActivityType = 'TASK';  
                                                lastActivityId = task.Id; 
                                                lastActivityOriginator = task.Originator__c;
                                                lastActivityOriginatorDetail = task.Originator_di_dettaglio__c;
                                            } 
                                            break;                             
                                        }
                                    }

                                    for(Opportunity opp : oppList){
                                        if(opp.AccountId == (Id)sObj.get('WhatId') && opp.Originator__c != null && opp.Originator_di_dettaglio__c != null){
                                            DateTime dateLastOpportunity = opp.CreatedDate;
                                            if(lastActivityDate == null || lastActivityDate < dateLastOpportunity){
                                                lastActivityDate = dateLastOpportunity;
                                                lastActivityType = 'OPPORTUNITY';
                                                lastActivityId = opp.Id;   
                                                lastActivityOriginator = opp.Originator__c;
                                                lastActivityOriginatorDetail = opp.Originator_di_dettaglio__c;
                                            } 
                                            break;                             
                                        }
                                    }

                                    System.debug('SV FORZATURA: NO');
                                    System.debug('SV lastActivityDate: ' + lastActivityDate);
                                    System.debug('SV lastActivityType: ' + lastActivityType);
                                    System.debug('SV lastActivityId: ' + lastActivityId);
                                    System.debug('SV lastActivityOriginator: ' + lastActivityOriginator);
                                    System.debug('SV lastActivityOriginatorDetail: ' + lastActivityOriginatorDetail);

                                    sObj.put('Originator__c', lastActivityOriginator);
                                    sObj.put('Originator_di_dettaglio__c', lastActivityOriginatorDetail);

                                    System.debug('SV sObj: ' + sObj);
                                    
                            } else {
                                System.debug('SV FORZATURA: SI');
                                sObj.put('Originator__c', ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator__c);
                                sObj.put('Originator_di_dettaglio__c', ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator_dettaglio__c);

                                System.debug('SV sObj: ' + sObj);
                            }
                        }
                    } else {
                        System.debug('SV ORIGINATOR NON ESEGUITO');
                        System.debug(string.valueof(sObj.getSObjectType()));
                    }
                } else {
                    
                    if((String)sObj.get('WhatId') != null){
                        System.debug('SV ORIGINATOR NON ESEGUITO');
                        System.debug(allRecordTypeMap.get((String)allAccMap.get((String)sObj.get('WhatId')).get('RecordTypeId')).get('DeveloperName'));
                    } else {
                        System.debug('SV ORIGINATOR DI DEFAULT WHAT-ID NULL');
                        sObj.put('Originator__c', 'Diretto');
                        sObj.put('Originator_di_dettaglio__c', 'Rete Commerciale Italia');
                    }
                }
            }
        } else {
            System.debug('SV ORIGINATOR NON ESEGUITO');
        }
    }

    //TEN - Simone Martinello 14/03/2019
    //Metodo in Before Insert per bloccare l'inserimento di un task associato ad una anagrafica, se esiste ancora un task aperto
    public static void checkTaskAperti(List<Task> allTasks){
        List<Task> tasks = new List<Task>();
        for(Task t : allTasks){
            System.debug('@@@ campagna ' + t.Campagna__c);
            if(t.Campagna__c == null){
                tasks.add(t);
            }
        }
        Set<Id> parentAccount = new Set<Id>();
        List<Task> parentTask = new List<Task>();
        List<RecordType> recordTypes = new List<RecordType>();
        List<Id> recordTypeIds = new List<Id>();
        
        recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN ('WGC_Diario_Inserimento_Campagna', 'WGC_Diario_Modifica_Qualifica', 'WGC_Diario_Modifica_Rating', 'WGC_Diario_Nuova_Opportunita', 'Promemoria', 'Previsione_Avvio_Rapporto', 'WGC_Segnalazione') AND SObjectType = 'Task'];
        System.debug('@@@ recordTypes '+ JSON.serialize(recordTypes));
        for(RecordType rt : recordTypes) {
            recordTypeIds.add(rt.Id);
        }
        System.debug('@@@ recordTypeIds '+recordTypeIds);

        //Recupero la lista di accountId associati ai task inseriti
        for(Task t : tasks){
            System.debug('@@@ task rt '+t.RecordTypeId);
            /*if(t.RecordTypeId != 'ContattoTelefonicoDiretto' || 
                t.RecordType.DeveloperName != 'WGC_Diario_Inserimento_Campagna' ||
                t.RecordType.DeveloperName != 'WGC_Diario_Modifica_Qualifica' ||
                t.RecordType.DeveloperName != 'WGC_Diario_Modifica_Rating' ||
                t.RecordType.DeveloperName != 'WGC_Diario_Nuova_Opportunita'){*/
            if(!recordTypeIds.contains(t.RecordTypeId)){
                System.debug('@@@ task '+t);
                if(t.WhatId != null){
                    parentAccount.add(t.WhatId);
                }
            }
        }

        //Recupero i task aperti associati all'anagrafica
        parentTask = [SELECT Id, WhatId, AccountId, Status, Esito__c, EsitoLivello1__c FROM Task 
        WHERE (WhatId IN : parentAccount AND Status = 'Aperto' AND RecordTypeId NOT IN : recordTypeIds AND OwnerId =: UserInfo.getUserId())];

        System.debug('@@@ parentTask ' + JSON.serialize(parentTask));
        Map<Id, Task> accountIdXTask = new Map<Id, Task>();

        //Se la lista di task associati non è vuota
        //Costrutisco la mappa di appoggio
        //E lancio un eccezzione
        if(!parentTask.isEmpty()){
            for(Task t : parentTask){
                accountIdXTask.put(t.WhatId, t);
            }
            
            for(Id accID : accountIdXTask.keySet()){
                // solleva eccezione
                accountIdXTask.get(accID).addError('Esitare i task precedenti associati a questa anagrafica');
            }
        }

    }

    //TEN - Simone Martinello 09/04/2019
    //Metodo in Before Insert per bloccare l'inserimento di un task associato ad una anagrafica, se esiste ancora un task aperto
    public static void checkEventiAperti(List<Event> allEvents){
        List<Event> events = new List<Event>();
        for(Event e : allEvents){
            if(e.Campagna__c == null){
                events.add(e);
            }
        }
        Set<Id> parentAccount = new Set<Id>();
        List<Event> parentEvent = new List<Event>();

        //Recupero la lista di accountId associati ai Event inseriti
        for(Event t : events){
            System.debug('@@@ Event '+t);
            if(t.WhatId != null){
                parentAccount.add(t.WhatId);
            }
        }

        //Recupero i Event aperti associati all'anagrafica
        parentEvent = [SELECT Id, WhatId, AccountId, Esito__c, EsitoLivello1__c FROM Event 
        WHERE (WhatId IN : parentAccount AND EsitoLivello1__c = null AND OwnerId =: UserInfo.getUserId())];

        System.debug('@@@ parentEvent ' + JSON.serialize(parentEvent));
        Map<Id, Event> accountIdXEvent = new Map<Id, Event>();

        //Se la lista di Event associati non è vuota
        //Costrutisco la mappa di appoggio
        //E lancio un eccezzione
        if(!parentEvent.isEmpty()){
            for(Event t : parentEvent){
                accountIdXEvent.put(t.WhatId, t);
            }
            
            for(Id accID : accountIdXEvent.keySet()){
                // solleva eccezione
                accountIdXEvent.get(accID).addError('Esitare i task precedenti associati a questa anagrafica');
            }
        }

    }
    
    //TEN - Giuseppe Bavetta 16/09/2019
    //Metodo in Before Insert per settare data fine e activity date
    public static void setDataFine(List<Task> allTasks){
        List<Task> tasks = new List<Task>();
        for(Task t : allTasks){
            if(!t.Subject.contains('campagna')){
                if(t.Data_Inizio__c != null) {
                    System.debug('@@@ Data inizio ' + t.Data_Inizio__c);
                    t.Data_Fine__c = t.Data_Inizio__c.addMinutes(15);
                    t.ActivityDate = Date.newinstance(t.Data_Inizio__c.year(), t.Data_Inizio__c.month(), t.Data_Inizio__c.day());
                    System.debug('@@@ Data fine ' + t.Data_Fine__c);
                    System.debug('@@@ activity Date ' + t.ActivityDate);
                }
            }
        }

    }
}