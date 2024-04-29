public class WGC_HomePage_Mie_Attivita_FD_Controller {

    //Recupero i dati per generare il grafico "Aziende da contattare"
    @AuraEnabled
    public static WrapperResponse getDatiGraficoAziende(Boolean isDirezioneFD){

        WrapperResponse response = new WrapperResponse();

        try{
            Result results = new Result();
            List<Task> todaysActivity = new List<Task>();
            List<WGC_Andamentale__c> obiettivo = new List<WGC_Andamentale__c>();

            Decimal obiettivoCount = 0;
            Decimal actual = 0;

            if(isDirezioneFD){

                todaysActivity = [SELECT Id, Subject 
                                    FROM Task 
                                    WHERE ActivityDate =: System.Today() AND
                                    Status = 'Aperto' AND
                                    DiFiloDiretto__c = true AND
                                    ( Subject LIKE 'Contatto Telefonico%' OR Subject LIKE 'Ricontatto Telefonico%' ) ];

                obiettivo = [SELECT Id, CT_Budget__c, CT_Actual__c, Operatore__c
                                FROM WGC_Andamentale__c 
                                WHERE Data__c =: System.Today() 
                                ORDER BY LastModifiedDate DESC];

            } else {
                todaysActivity = [SELECT Id, Subject 
                                FROM Task 
                                WHERE OwnerId =: UserInfo.getUserId() AND 
                                ActivityDate =: System.Today() AND
                                Status = 'Aperto' AND
                                DiFiloDiretto__c = true AND
                                ( Subject LIKE 'Contatto Telefonico%' OR Subject LIKE 'Ricontatto Telefonico%' ) ];

                obiettivo = [SELECT Id, CT_Budget__c, CT_Actual__c, Operatore__c
                            FROM WGC_Andamentale__c 
                            WHERE Operatore__c =: UserInfo.getUserId() AND 
                            Data__c =: System.Today() 
                            ORDER BY LastModifiedDate DESC];
            }

            results.todaysActivity = todaysActivity;

            //Calcolo obiettivo e actual
            for(WGC_Andamentale__c andamento : obiettivo){
                if(isDirezioneFD){
                    obiettivoCount += andamento.CT_Budget__c != null ? andamento.CT_Budget__c : 0;
                    actual += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
                } else {
                    if(andamento.Operatore__c == UserInfo.getUserId()){
                        obiettivoCount += andamento.CT_Budget__c != null ? andamento.CT_Budget__c : 0;
                        actual += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
                    }
                }
            }
            //Setto l'obiettivo
            results.obiettivo = obiettivoCount;
            //Setto l'actual
            results.actual = actual;

            response.data.add(results);
        }
        catch(Exception e){
            System.debug('@@@ error ' + e.getMessage() + ' -- ' + e.getLineNumber());
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static WrapperResponse getDatiGraficoAziende_Filtered(String userId, String teamName, Boolean isAllUser){

        WrapperResponse response = new WrapperResponse();

        try{
            Result results = new Result();
            List<Task> todaysActivity = new List<Task>();
            List<WGC_Andamentale__c> obiettivo = new List<WGC_Andamentale__c>();

            Decimal obiettivoCount = 0;
            Decimal actual = 0;

            if(String.isNotBlank(userId)){
                todaysActivity = [SELECT Id, Subject 
                                FROM Task 
                                WHERE OwnerId =: userId AND 
                                ActivityDate =: System.Today() AND
                                Status = 'Aperto' AND
                                DiFiloDiretto__c = true AND
                                ( Subject LIKE 'Contatto Telefonico%' OR Subject LIKE 'Ricontatto Telefonico%' ) ];

                obiettivo = [SELECT Id, CT_Budget__c, CT_Actual__c, Operatore__c, Team__c
                            FROM WGC_Andamentale__c 
                            WHERE Operatore__c =: userId AND 
                            Data__c =: System.Today() 
                            ORDER BY LastModifiedDate DESC];
            } else if(String.isNotBlank(teamName)){
                Map<Id,Sobject> idXUsr = new Map<Id,Sobject>([SELECT Id, Name FROM User WHERE WGC_Team_Filo_Diretto__c =: teamName]);

                todaysActivity = [SELECT Id, Subject 
                                    FROM Task 
                                    WHERE OwnerId IN: idXUsr.keySet() AND 
                                    ActivityDate =: System.Today() AND
                                    Status = 'Aperto' AND
                                    DiFiloDiretto__c = true AND
                                    ( Subject LIKE 'Contatto Telefonico%' OR Subject LIKE 'Ricontatto Telefonico%' ) ];

                obiettivo = [SELECT Id, CT_Budget__c, CT_Actual__c, Operatore__c, Team__c
                                FROM WGC_Andamentale__c 
                                WHERE Operatore__c IN: idXUsr.keySet() AND
                                Data__c =: System.Today() 
                                ORDER BY LastModifiedDate DESC];
            } else if(String.isBlank(userId) && String.isBlank(teamName) && isAllUser){
                todaysActivity = [SELECT Id, Subject 
                                    FROM Task 
                                    WHERE ActivityDate =: System.Today() AND
                                    Status = 'Aperto' AND
                                    DiFiloDiretto__c = true AND
                                    ( Subject LIKE 'Contatto Telefonico%' OR Subject LIKE 'Ricontatto Telefonico%' ) ];

                obiettivo = [SELECT Id, CT_Budget__c, CT_Actual__c, Operatore__c, Team__c
                                FROM WGC_Andamentale__c 
                                WHERE Data__c =: System.Today() 
                                ORDER BY LastModifiedDate DESC];
            }

            results.todaysActivity = todaysActivity;

            //Calcolo obiettivo e actual
            for(WGC_Andamentale__c andamento : obiettivo){
                if(String.isBlank(userId) && String.isBlank(teamName) && isAllUser){
                    obiettivoCount += andamento.CT_Budget__c != null ? andamento.CT_Budget__c : 0;
                    actual += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
                } else if(String.isNotBlank(userId)){
                    if(andamento.Operatore__c == userId){
                        obiettivoCount += andamento.CT_Budget__c != null ? andamento.CT_Budget__c : 0;
                        actual += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
                    }
                } else if(String.isNotBlank(teamName)){
                    if(andamento.Team__c == teamName){
                        obiettivoCount += andamento.CT_Budget__c != null ? andamento.CT_Budget__c : 0;
                        actual += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
                    }
                }
            }
            //Setto l'obiettivo
            results.obiettivo = obiettivoCount;
            //Setto l'actual
            results.actual = actual;

            response.data.add(results);
        }
        catch(Exception e){
            System.debug('@@@ error ' + e.getMessage() + ' -- ' + e.getLineNumber());
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    //Recupero i dati per il secondo grafico "Commerciali da contattare"
    @AuraEnabled
    public static WrapperResponse getDatiGraficoCommerciali(Boolean isDirezioneFD){
        
        WrapperResponse response = new WrapperResponse();

        try{
            Result results = new Result();

            List<Task> promemoriaOggi = new List<Task>();
            List<Task> promemoriaChiusi = new List<Task>();

            if(isDirezioneFD){
                promemoriaOggi = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];

                promemoriaChiusi = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE DAY_ONLY(CompletedDateTime) =: System.Today() AND
                                        Status = 'Chiuso' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];
            } else {
                promemoriaOggi = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById =: UserInfo.getUserId() AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];

                promemoriaChiusi = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById =: UserInfo.getUserId() AND
                                        DAY_ONLY(CompletedDateTime) =: System.Today() AND
                                        Status = 'Chiuso' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];
            }

            results.todaysActivity = promemoriaOggi;
            results.todaysClosed = promemoriaChiusi;

            response.data.add(results);
        }
        catch(Exception e){
            response.message = e.getMessage() + ' -- ' + e.getLineNumber();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static WrapperResponse getDatiGraficoCommerciali_Filtered(String userId, String teamName, Boolean isAllUser){
        
        WrapperResponse response = new WrapperResponse();

        try{
            Result results = new Result();

            List<Task> promemoriaOggi = new List<Task>();
            List<Task> promemoriaChiusi = new List<Task>();

            if(String.isNotBlank(userId)){
                promemoriaOggi = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById =: userId AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];

                promemoriaChiusi = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById =: userId AND
                                        DAY_ONLY(CompletedDateTime) =: System.Today() AND
                                        Status = 'Chiuso' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];
            } else if(String.isNotBlank(teamName)){
                Map<Id,Sobject> idXUsr = new Map<Id,Sobject>([SELECT Id, Name FROM User WHERE WGC_Team_Filo_Diretto__c =: teamName]);

                promemoriaOggi = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById IN: idXUsr.keySet() AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];

                promemoriaChiusi = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById IN: idXUsr.keySet() AND
                                        DAY_ONLY(CompletedDateTime) =: System.Today() AND
                                        Status = 'Chiuso' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];
            } else if(String.isBlank(userId) && String.isBlank(teamName) && isAllUser){
                promemoriaOggi = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];

                promemoriaChiusi = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE DAY_ONLY(CompletedDateTime) =: System.Today() AND
                                        Status = 'Chiuso' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];
            }

            results.todaysActivity = promemoriaOggi;
            results.todaysClosed = promemoriaChiusi;

            response.data.add(results);
        }
        catch(Exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    public class WrapperResponse{
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }

    public class Result{
        @AuraEnabled public List<Sobject> todaysActivity;
        @AuraEnabled public List<Sobject> todaysClosed;
        @AuraEnabled public Decimal obiettivo;
        @AuraEnabled public Decimal actual;

        public Result(){
            this.todaysActivity = new List<Sobject>();
            this.todaysClosed = new List<Sobject>();
            this.obiettivo = 0;
            this.actual = 0;
        }
    }
}