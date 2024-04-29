public class WGC_Activity_Recap_Controller {

    //adione SDHDFNZ-72324     - rimossa colonna SCADENZA
    static final String[] CAMPI_EVENTO = new String[]{'Subject', 'ActivityDateTime', 'Account.Id','Account.Name','StartDateTime', /*'EndDateTime',*/ 'Owner.Name'};
    static final String[] CAMPI_TASK = new String[]{'Subject', 'ActivityDate', 'Account.Id','Account.Name','Data_Inizio__c', /*'Data_Fine__c',*/ 'Owner.Name', 'Status'};
    static final String[] CAMPI_OPTY = new String[]{'Name','AccountId','Account.Name','StageName','CreatedDate','Owner.Name'};


    @AuraEnabled
    public static WrapperResponse getHeaderData(){
            // /*Id, AccountId, Account.Name, WhoId, StartDateTime, EndDateTime, */
            //STATUS SOLO SU TASK

            //Prendo le informazioni dell'utente per eseguire diverse query in base al tipo di profilo
            Id uId = UserInfo.getUserId();
            User u = [SELECT Id, Profile.Name, Qualifica_Utente__c FROM User WHERE Id =: uId];
            
            Map<Id,Sobject> utentiFD = new Map<Id,Sobject>([SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE WGC_Team_Filo_Diretto__c != null AND IsActive = true]);

            List<Event> event = new List<Event>();

            if(u.Qualifica_Utente__c.contains('Filo Diretto')){
                if(u.Profile.Name == 'IFIS - Direzione Commerciale - Filo Diretto'){
                    event = [ SELECT ActivityDateTime, Subject, AccountId, Account.Name, OwnerId, Owner.Name, Esito__c, EsitoLivello1__c, StartDateTime, EndDateTime
                    FROM Event 
                    WHERE CreatedById IN: utentiFD.keySet()
                        AND WhatId != null
                        AND EsitoLivello1__c = null
                        //AND OwnerId =: UserInfo.getUserId() 
                    ORDER BY EndDateTime ASC ];
                } else {
                    event = [ SELECT ActivityDateTime, Subject, AccountId, Account.Name, OwnerId, Owner.Name, Esito__c, EsitoLivello1__c, StartDateTime, EndDateTime
                    FROM Event 
                    WHERE CreatedById =: uId
                        AND WhatId != null
                        AND EsitoLivello1__c = null
                             //AND OwnerId =: UserInfo.getUserId() 
                    ORDER BY EndDateTime ASC ];
                }
            }
            else{
                event = [ SELECT ActivityDateTime, Subject, AccountId, Account.Name, OwnerId, Owner.Name, Esito__c, EsitoLivello1__c, StartDateTime, EndDateTime
                FROM Event 
                WHERE ActivityDateTime >= LAST_N_MONTHS:12
                    AND OwnerId =: UserInfo.getUserId() 
                    AND (
                            (Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId())
                            OR (Account.WGC_Specialista_Leasing__c =: UserInfo.getUserId())
                            OR (Account.WGC_Specialista_Crediti_Erariali__c =: UserInfo.getUserId())
                            OR (Account.WGC_Specialista_IFIS_Finance__c =: UserInfo.getUserId())
                            OR (Account.WGC_Specialista_Finanza_Strutturata__c =: UserInfo.getUserId())
                            OR (Account.WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId())
                            OR (Account.WGC_Specialista_IFIS_International__c =: UserInfo.getUserId())
                            )
                    AND EsitoLivello1__c = null
                    AND WhatId != null
                ORDER BY EndDateTime ASC ];
            }


            List<HeaderTable> headerEvento = populateHeaderTable('Event', CAMPI_EVENTO);
            Table tabellaEvento = new Table();
            tabellaEvento.records = event;
            tabellaEvento.campiTabella = headerEvento;

            //System.debug('@@@ tabella ' + JSON.serialize(tabellaEvento));
            //Schema.getGlobalDescribe().get('ObjectName').getDescribe().fields.getMap().get('FieldName').getDescribe().getLabel();

            List<Task> task = new List<Task>();
            Table tabellaTask = new Table();

            if(u.Qualifica_Utente__c.contains('Filo Diretto')){
                System.debug('@@@ sono filo diretto ' + u.Profile.Name );
                task = [SELECT Id, AccountId, Subject, Campagna__r.Name, Owner.Name, What.Id, What.Name, WhoId, ActivityDate, DataRicontatto__c, Status, RecordTypeId 
                        FROM Task 
                        WHERE Status='Aperto' AND 
                        DiFiloDiretto__c = true AND 
                        (RecordType.DeveloperName = 'ContattoTelefonicoDiretto' OR RecordType.DeveloperName = 'ContattoTelefonicoIndiretto') AND 
                        WhatId != null 
                        ORDER BY ActivityDate ASC];
            }
            else{
                System.debug('@@@ non sono filo direttto ' + u.Profile.Name);
                task = [ SELECT Id, AccountId, Account.Name, Subject, ActivityDate, OwnerId, Owner.Name, WhoId, Data_Inizio__c, Data_Fine__c, Status, RecordType.DeveloperName
                            FROM Task 
                            WHERE Data_Inizio__c >= LAST_N_MONTHS:12
                                AND OwnerId =: UserInfo.getUserId()
                                AND (
                                        (Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Leasing__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Crediti_Erariali__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_IFIS_Finance__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Finanza_Strutturata__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_IFIS_International__c =: UserInfo.getUserId())
                                      )
                                AND EsitoLivello1__c = null
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND RecordType.DeveloperName != 'Previsione_Avvio_Rapporto'
                                AND RecordType.DeveloperName != 'Segnalazione'
                                AND WhatId != null
                            ORDER BY ActivityDate ASC ];

                List<HeaderTable> headerTask = populateHeaderTable('Task', CAMPI_TASK);
                tabellaTask.campiTabella = headerTask;
            }

            
            tabellaTask.records = task;
            

            //System.debug('@@@ tabella ' + JSON.serialize(tabellaTask));
            List<Opportunity> opp = new List<Opportunity>();
            List<Opportunity> optyIstruttoria = new List<Opportunity>();
            List<Opportunity> optyPerfContratti = new List<Opportunity>();
            List<Opportunity> optyAttProdotto = new List<Opportunity>();
            Table tabellaOptyAttProdotto = new Table();
            Table tabellaOptyPerfContratti = new Table();
            Table tabellaOptyIstruttoria = new Table();

            if(u.Qualifica_Utente__c.contains('Filo Diretto')){
                if(u.Profile.Name == 'IFIS - Direzione Commerciale - Filo Diretto'){
                    opp = [SELECT Id, AccountId, Account.Name, Name, ToLabel(StageName), CreatedDate, OwnerId, Owner.Name,/*IsClosed, IsWon,*/ Data_Inizio__c, Data_Fine__c, Data_flow__c 
                            FROM Opportunity 
                            WHERE IsClosed = false
                            AND Account.WGC_Specialista_Filo_Diretto__c IN: utentiFD.keySet()
                            AND Account.WGC_Filo_Diretto_Attivo__c = true
                            //AND Originator__c = 'Contact Center'
                            ORDER BY CreatedDate ASC];

                } else {
                    opp = [SELECT Id, AccountId, Account.Name, Name, ToLabel(StageName), CreatedDate, OwnerId, Owner.Name,/*IsClosed, IsWon,*/ Data_Inizio__c, Data_Fine__c, Data_flow__c 
                            FROM Opportunity 
                            WHERE IsClosed = false
                            AND Account.WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId()
                            AND Account.WGC_Filo_Diretto_Attivo__c = true
                            //AND Originator__c = 'Contact Center'
                            ORDER BY CreatedDate ASC];
                }

                //Divido le opty in più liste in base allo stato
                for(Opportunity o : opp){
                    if(o.StageName == 'In Istruttoria'){
                        optyIstruttoria.add(o);
                    }
                    else if(o.StageName == 'Firma Contratti'){
                        optyPerfContratti.add(o);
                    }
                    else if(o.StageName == 'Da Avviare'){
                        optyAttProdotto.add(o);
                    }
                }

                List<HeaderTable> headerOptyIstruttoria = populateHeaderTable('Opportunity', CAMPI_OPTY);
                tabellaOptyIstruttoria.records = optyIstruttoria;
                tabellaOptyIstruttoria.campiTabella = headerOptyIstruttoria;

                //System.debug('@@@ tabella istruttoria ' + JSON.serialize(tabellaOptyIstruttoria));

                List<HeaderTable> headerOptyPerfContratti = populateHeaderTable('Opportunity', CAMPI_OPTY);
                tabellaOptyPerfContratti.records = optyPerfContratti;
                tabellaOptyPerfContratti.campiTabella = headerOptyPerfContratti;

                //System.debug('@@@ tabella perf contratti ' + JSON.serialize(tabellaOptyPerfContratti));

                List<HeaderTable> headerOptyAttProdotto = populateHeaderTable('Opportunity', CAMPI_OPTY);
                tabellaOptyAttProdotto.records = optyAttProdotto;
                tabellaOptyAttProdotto.campiTabella = headerOptyAttProdotto;

                //System.debug('@@@ tabella att prodotto ' + JSON.serialize(tabellaOptyAttProdotto));
            }
            else{
                opp = [SELECT Id, AccountId, Account.Name, Name, ToLabel(StageName), CreatedDate, OwnerId, Owner.Name,/*IsClosed, IsWon,*/ Data_Inizio__c, Data_Fine__c, Data_flow__c 
                    FROM Opportunity 
                    WHERE IsClosed = false
                    AND OwnerId =: UserInfo.getUserId()
                    ORDER BY CreatedDate ASC];

                //Divido le opty in più liste in base allo stato
                for(Opportunity o : opp){
                    if(o.StageName == 'In Istruttoria'){
                        optyIstruttoria.add(o);
                    }
                    else if(o.StageName == 'Firma Contratti'){
                        optyPerfContratti.add(o);
                    }
                    else if(o.StageName == 'Da Avviare'){
                        optyAttProdotto.add(o);
                    }
                }

                List<HeaderTable> headerOptyIstruttoria = populateHeaderTable('Opportunity', CAMPI_OPTY);
                
                tabellaOptyIstruttoria.records = optyIstruttoria;
                tabellaOptyIstruttoria.campiTabella = headerOptyIstruttoria;

                //System.debug('@@@ tabella istruttoria ' + JSON.serialize(tabellaOptyIstruttoria));

                List<HeaderTable> headerOptyPerfContratti = populateHeaderTable('Opportunity', CAMPI_OPTY);
                
                tabellaOptyPerfContratti.records = optyPerfContratti;
                tabellaOptyPerfContratti.campiTabella = headerOptyPerfContratti;

                //System.debug('@@@ tabella perf contratti ' + JSON.serialize(tabellaOptyPerfContratti));

                List<HeaderTable> headerOptyAttProdotto = populateHeaderTable('Opportunity', CAMPI_OPTY);

                tabellaOptyAttProdotto.records = optyAttProdotto;
                tabellaOptyAttProdotto.campiTabella = headerOptyAttProdotto;

                //System.debug('@@@ tabella att prodotto ' + JSON.serialize(tabellaOptyAttProdotto));
            }

            //Promemoria solo per Filo Diretto
            List<Task> promemoria = new List<Task>();
            Table tabellaPromemoria = new Table();

            if(u.Qualifica_Utente__c.contains('Filo Diretto')){
                if(u.Profile.Name == 'IFIS - Direzione Commerciale - Filo Diretto'){
                    promemoria = [SELECT Id, Account.Id, Account.Name, Subject, Campagna__r.Name, Owner.Name, What.Id, What.Name, WhoId, ActivityDate, DataRicontatto__c, Status, RecordTypeId 
                                  FROM Task 
                                  WHERE Status='Aperto' 
                                  AND DiFiloDiretto__c = true 
                                  AND RecordType.DeveloperName = 'Promemoria' 
                                  AND CreatedById IN: utentiFD.keySet() 
                                  AND WhatId != null 
                                  AND OwnerId =: UserInfo.getUserId()
                                  ORDER BY ActivityDate ASC];
                } else {
                    promemoria = [SELECT Id, Account.Id, Account.Name, Subject, Campagna__r.Name, Owner.Name, What.Id, What.Name, WhoId, ActivityDate, DataRicontatto__c, Status, RecordTypeId 
                                  FROM Task 
                                  WHERE Status='Aperto' 
                                  AND DiFiloDiretto__c = true 
                                  AND RecordType.DeveloperName = 'Promemoria' 
                                  AND CreatedById IN: utentiFD.keySet() 
                                  AND WhatId != null 
                                  AND OwnerId =: UserInfo.getUserId()
                                  ORDER BY ActivityDate ASC];
                }

                List<HeaderTable> headerPromemoria = populateHeaderTable('Task', CAMPI_TASK);
                tabellaPromemoria.records = promemoria;
                tabellaPromemoria.campiTabella = headerPromemoria;
                //System.debug('@@@ tabella promemoria ' + JSON.serialize(tabellaPromemoria));
            }

            //Attività completate solo per Filo Diretto
            // List<Activity> completate = new List<Activity>();
            List<Task> completateTask = new List<Task>();
            List<Event> completateEvent = new List<Event>();
            // List<Object> completateObj = new List<Object>();
            Table tabellacompletateTask = new Table();
            Table tabellacompletateEvent = new Table();

            if(!u.Qualifica_Utente__c.contains('Filo Diretto')){
                completateTask = [SELECT Id, Account.Id, Account.Name, Subject, Campagna__r.Name, Owner.Name, What.Id, What.Name, WhoId, ActivityDate, DataRicontatto__c, Status, RecordTypeId, Data_Inizio__c, Data_Fine__c FROM Task WHERE EsitoLivello1__c != null AND OwnerId =: UserInfo.getUserId() AND DataOraEsitazione__c = THIS_YEAR AND WhatId != null ORDER BY DataOraEsitazione__c ASC];
                completateEvent = [SELECT Id, Account.Id, Account.Name, Subject, Campagna__r.Name, Owner.Name, What.Id, What.Name, WhoId, ActivityDateTime, DataRicontatto__c, RecordTypeId, Data_Inizio__c, Data_Fine__c, StartDateTime, EndDateTime FROM Event WHERE EsitoLivello1__c != null AND OwnerId =: UserInfo.getUserId() AND DataOraEsitazione__c = THIS_YEAR AND WhatId != null ORDER BY DataOraEsitazione__c ASC];
                List<HeaderTable> headerCompletateTask = populateHeaderTable('Task', CAMPI_TASK);
                List<HeaderTable> headerCompletateEvent = populateHeaderTable('Event', CAMPI_EVENTO);

                tabellacompletateTask.records = completateTask;
                tabellacompletateTask.campiTabella = headerCompletateTask;

                tabellacompletateEvent.records = completateEvent;
                tabellacompletateEvent.campiTabella = headerCompletateEvent;
            }
                        
            TableContainer table = new TableContainer();
            table.event = tabellaEvento;
            table.task = tabellaTask;
            table.oppIstruttoria = tabellaOptyIstruttoria;
            table.oppPerfContratti = tabellaOptyPerfContratti;
            table.oppAttProdotto = tabellaOptyAttProdotto;
            table.promemoria = tabellaPromemoria.campiTabella == null ? null : tabellaPromemoria;
            table.completateTask = tabellacompletateTask.campiTabella == null ? null : tabellacompletateTask;
            table.completateEvent = tabellacompletateEvent.campiTabella == null ? null : tabellacompletateEvent;

            System.debug('@@@ table ' + table);

            WrapperResponse wrap = new WrapperResponse();
            wrap.data.add(table);

            return wrap;
    }

    public static List<HeaderTable> populateHeaderTable(String objectName, List<String> listaCampi){
        List<HeaderTable> Header = new List<HeaderTable>();

        for(String field : listaCampi){
            HeaderTable singleField = new HeaderTable();
            String label;
            String fieldType;

            if(!field.contains('.')){
                label = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(field).getDescribe().getLabel();
                fieldType = String.valueOf(Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(field).getDescribe().getType());
                //System.debug('@@@ fieldType string ' + fieldType);
                //System.debug('@@@ fieldType string ' + Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(field).getDescribe().getType());
            }
            else{
                List<String> tmp = field.split('\\.');
                //l'oggetto owner è user
                if(tmp.get(tmp.size()-2) == 'Owner'){
                    label = Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(tmp.get(tmp.size()-1)).getDescribe().getLabel();
                    fieldType = String.valueOf(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(tmp.get(tmp.size()-1)).getDescribe().getType());
                }
                else{
                    label = Schema.getGlobalDescribe().get(tmp.get(tmp.size()-2)).getDescribe().fields.getMap().get(tmp.get(tmp.size()-1)).getDescribe().getLabel();
                    fieldType = String.valueOf(Schema.getGlobalDescribe().get(tmp.get(tmp.size()-2)).getDescribe().fields.getMap().get(tmp.get(tmp.size()-1)).getDescribe().getType());
                }
            }


            singleField.label = label;
            singleField.apiName = field;
            singleField.type = fieldType;

            Header.add(singleField);
        }

        return Header;
    }

    @AuraEnabled
    public static WrapperResponse getUserType(String userId){
        System.debug('@@@ userId ' + userId);
        WrapperResponse wrap = new WrapperResponse();

        try{
            User u = [SELECT Id, Name, Profile.Name, ProfileId, Qualifica_Utente__c FROM User WHERE Id =: userId];

            System.debug('@@@ user ' + u);

            wrap.data.add(u);
            return wrap;
        }
        catch(Exception e){
            wrap.message = e.getMessage();
            wrap.success = false;
            return wrap;
        }


    }
 

    public class WrapperResponse{
        @AuraEnabled
        public List<Object> data;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }

    public class TableContainer{
        @AuraEnabled
        public Table event;
        @AuraEnabled
        public Table task;
        @AuraEnabled
        public Table oppIstruttoria;
        @AuraEnabled
        public Table oppPerfContratti;
        @AuraEnabled
        public Table oppAttProdotto;
        @AuraEnabled
        public Table promemoria;
        @AuraEnabled
        public Table completateTask;
        @AuraEnabled
        public Table completateEvent;

        public TableContainer(){
            this.event = new Table();
            this.task = new Table();
            this.oppIstruttoria = new Table();
            this.oppPerfContratti = new Table();
            this.oppAttProdotto = new Table();
            //Non istanziato per crearlo solo in caso di FD (Filo Diretto)
            this.promemoria = promemoria;
            this.completateTask = completateTask;
            this.completateEvent = completateEvent;
        }
    }

    public class Table{
        @AuraEnabled
        public List<Object> records;
        @AuraEnabled
        public List<HeaderTable> campiTabella;

    }

    public class HeaderTable{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String apiName;
        @AuraEnabled
        public String type;

        public HeaderTable(){
            this.label = label;
            this.apiName = apiName;
            this.type = type;
        }
    }
}