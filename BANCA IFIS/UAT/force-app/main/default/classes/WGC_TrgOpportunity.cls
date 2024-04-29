public class WGC_TrgOpportunity {

    public static Boolean excuteInTest = false;
    
    public static void setupNewOpportunityFlags(List<Opportunity> opportunities) {

        for (Opportunity opp : opportunities) {
            // add logic here
            opp.WGC_FlagConsolidamento__c = false;
            opp.WGC_FlagRinnovo__c = false;
        }
    }

    public static void setupOriginator(List<sObject> activityList) {
        System.debug('SV setupOriginator: ' + activityList);
        
        if(!Test.isRunningTest() || excuteInTest){
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
                if((Id)sObj.get('AccountId') != null){
                    if((Id)sObj.get('AccountId') != null){
                        accountsId.add((Id)sObj.get('AccountId'));
                    }
                    recordTypeId.add((Id)sObj.get('RecordTypeId'));
                } else {
                    if((Id)sObj.get('Assuntore__c') != null){
                        accountsId.add((Id)sObj.get('Assuntore__c'));
                    }
                    recordTypeId.add((Id)sObj.get('RecordTypeId'));
                }            
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
											WGC_Forzatura__c = FALSE AND
                                            //(WGC_Forzatura__c = FALSE OR 
                                                //(WGC_Forzatura__c = TRUE AND 
                                                //WGC_Macro_Esito__c = 'Positivo')
                                            //) AND
                                            RecordType.DeveloperName != 'Promemoria' AND
                                            (NOT RecordType.DeveloperName LIKE '%Diario%')
                                            ORDER BY CreatedDate DESC ];

                taskList = [SELECT Id, AccountId, Originator__c, Originator_di_dettaglio__c, CreatedDate, WGC_Forzatura__c  
                                            FROM Task 
                                            WHERE CreatedDate >= LAST_N_MONTHS:12 AND 
                                            AccountId IN : accountsId AND 
											WGC_Forzatura__c = FALSE AND
                                            //(WGC_Forzatura__c = FALSE OR 
                                                //(WGC_Forzatura__c = TRUE AND 
                                                //WGC_Macro_Esito__c = 'Positivo')
                                            //) AND
                                            RecordType.DeveloperName != 'Promemoria' AND
                                            (NOT RecordType.DeveloperName LIKE '%Diario%')
                                            ORDER BY CreatedDate DESC ];

                oppList = [SELECT Id, AccountId, Originator__c, Originator_di_dettaglio__c, CreatedDate, WGC_Forzatura__c, StageName 
                                                FROM Opportunity 
                                                WHERE CreatedDate >= LAST_N_MONTHS:12 AND 
                                                AccountId IN : accountsId AND 
												WGC_Forzatura__c = FALSE
                                                //(WGC_Forzatura__c = FALSE OR 
                                                    //(WGC_Forzatura__c = TRUE AND 
                                                    //StageName != 'Persa')
                                                //)
                                                ORDER BY CreatedDate DESC ];

            }
                                            
            System.debug('SV eventList: ' + eventList);
            System.debug('SV taskList: ' + taskList);
            System.debug('SV oppList: ' + oppList);

            // Date dateLastEvent = date.newinstance(eventList[0].ActivityDateTime.year(), eventList[0].ActivityDateTime.month(), eventList[0].ActivityDateTime.day());
            // Date dateLastTask = taskList[0].ActivityDate;
            // Date dateLastOpportunity = oppList[0].Data_Apertura__c;

            for(SObject sObj : activityList) {
                System.debug(sObj);
                System.debug(string.valueof(sObj.getSObjectType()));
                System.debug( allRecordTypeMap.get((String)sObj.get('RecordTypeId')).get('DeveloperName'));
				System.debug('Originator__c: ' + string.valueof(sObj.get('Originator__c')));
				
                //if((String)sObj.get('Assuntore__c') == null){
                    //if( (string.valueof(sObj.getSObjectType()) == 'Opportunity' && ( allRecordTypeMap.get((String)sObj.get('RecordTypeId')).get('DeveloperName') != 'IFISOpportunitaFastFinance') || ((Boolean)sObj.get('TiAnticipo__c')) != true ) ){
                    if( string.valueof(sObj.getSObjectType()) == 'Opportunity' && string.valueof(sObj.get('StageName')) != 'Da Lavorare' && ((Boolean)sObj.get('TiAnticipo__c')) != true && string.valueof(sObj.get('Originator__c')) == null){
                        System.debug('SV sObj ID: ' +(Id)sObj.get('AccountId'));
                        System.debug('SV sObj ID: ' +(Id)sObj.get('Assuntore__c'));
                        System.debug('SV EventCount: ' + eventList.size());
                        System.debug('SV TaskCount: ' + taskList.size());
                        System.debug('SV OpportunityCount: ' + oppList.size());
                        Id activityId = (Id)sObj.get('AccountId') != null ? (Id)sObj.get('AccountId') : (Id)sObj.get('Assuntore__c');
                        System.debug('SV activityId: ' + activityId);

                        if(eventList.size() == 0 && taskList.size() == 0 && oppList.size() == 0){
                                
                            System.debug('SV NO ACTIVITY');

                                // sObj.put('Originator__c', (((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator__c')) != null || ((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator__c')) != '') ? ((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator__c')) : ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator__c);
                                // sObj.put('Originator_di_dettaglio__c', (((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator_dettaglio__c')) != null || ((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator_dettaglio__c')) != '') ? ((String)allAccMap.get((String)sObj.get('WhatId')).get('WGC_Originator_dettaglio__c')) : ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator_dettaglio__c);
                                
                                sObj.put('Originator__c', ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator__c);
                                sObj.put('Originator_di_dettaglio__c', ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator_dettaglio__c);
                                sObj.put('WGC_Forzatura__c', ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Forzatura__c == 'NO' ? false : ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Forzatura__c == 'SI' ? true : false);


                                System.debug('SV sObj: ' + sObj);

                        } else {
                            
                            System.debug('SV MD CANALE DI SVILUPPO: ' + ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Canale_di_sviluppo__c);
                            if(((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Forzatura__c.toUpperCase() == 'NO'){

                                Id lastActivityId = null;
                                DateTime lastActivityDate = null;
                                String lastActivityType = '';
                                String lastActivityOriginator = '';
                                String lastActivityOriginatorDetail = '';
                                Boolean isSettedOriginator = false;
                                String forType = '';
                                    for(Event event : eventList){
                                        if(event.AccountId == activityId && event.Originator__c != null && event.Originator_di_dettaglio__c != null){
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
                                        if(task.AccountId == activityId && task.Originator__c != null && task.Originator_di_dettaglio__c != null){
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
                                        forType = 'Opportunity';
                                        if(opp.AccountId == activityId && opp.Originator__c != null && opp.Originator_di_dettaglio__c != null /*&& opp.Originator__c != 'Cross Selling'*/){
                                            DateTime dateLastOpportunity = opp.CreatedDate;
                                            if(lastActivityDate == null || lastActivityDate < dateLastOpportunity){
                                                lastActivityDate = dateLastOpportunity;
                                                lastActivityType = 'OPPORTUNITY';
                                                lastActivityId = opp.Id;   
                                                lastActivityOriginator = opp.Originator__c;
                                                lastActivityOriginatorDetail = opp.Originator_di_dettaglio__c;
                                                isSettedOriginator = true;
                                            } 
                                            break;                             
                                        } 
                                    }

                                //SM - TEN FIX TENAM-254 Test aggiunto ELSE per non sovrascrivere quello scritto nell'if
                                if(forType == 'Opportunity' && !isSettedOriginator) {
                                    sObj.put('Originator__c', ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator__c);
                                    sObj.put('Originator_di_dettaglio__c', ((WGC_Originator__mdt) canaleDiSviluppoMap.get(user.Qualifica_Utente__c)).Originator_dettaglio__c);
                                } else {

                                    System.debug('SV FORZATURA: NO');
                                    System.debug('SV lastActivityDate: ' + lastActivityDate);
                                    System.debug('SV lastActivityType: ' + lastActivityType);
                                    System.debug('SV lastActivityId: ' + lastActivityId);
                                    System.debug('SV lastActivityOriginator: ' + lastActivityOriginator);
                                    System.debug('SV lastActivityOriginatorDetail: ' + lastActivityOriginatorDetail);

                                    sObj.put('Originator__c', lastActivityOriginator);
                                    sObj.put('Originator_di_dettaglio__c', lastActivityOriginatorDetail);

                                    System.debug('SV sObj: ' + sObj);
                                }
                                    
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
                        //System.debug(sObj.get('RecordType.DeveloperName'));
                    }
                /*} else {
                    System.debug('SV ORIGINATOR NON ESEGUITO');
                    System.debug((String)sObj.get('Assuntore__c'));
                }*/
            }
        }
    }
}