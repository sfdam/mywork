public class WGC_Header_Attivita_FD_Controller {
    //TEN - 22-07-2019 -- Metodo per recuperare le info per il primo tab header
    @AuraEnabled
    public static WrapperResponse getTodayActivityUser_FD(Boolean isDirezioneFD){
        
        WrapperResponse response = new WrapperResponse();

        List<Task> contattiTelefonici = new List<Task>();
        List<Task> ricontattiTelefonici = new List<Task>();
        List<Task> promemoria = new List<Task>();

        try{
            Result_FD results = new Result_FD();

            if(isDirezioneFD){
                contattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        Subject LIKE 'Contatto Telefonico%' AND
                                        DiFiloDiretto__c = true];

                ricontattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        Subject LIKE 'Ricontatto Telefonico%' AND
                                        DiFiloDiretto__c = true];

                promemoria = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];
            } else {
                contattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId =: UserInfo.getUserId() AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        Subject LIKE 'Contatto Telefonico%' AND
                                        DiFiloDiretto__c = true];

                ricontattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId =: UserInfo.getUserId() AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        Subject LIKE 'Ricontatto Telefonico%' AND
                                        DiFiloDiretto__c = true];

                promemoria = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById =: UserInfo.getUserId() AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];
            }

            results.contattiTelefonici = contattiTelefonici;
            results.ricontattiTelefonici = ricontattiTelefonici;
            results.promemoria = promemoria;

            System.debug('@@@ results ' + JSON.serialize(results));

            response.data.add(results);                                    

        }
        catch(Exception e){
            response.success = false;
            response.msg = e.getMessage();
        }

        return response;
    }
    
    //Metodo utilizzato per i filtri
    @AuraEnabled
    public static WrapperResponse getTodayActivityUser_FD_Filtered(String userId, String teamName, Boolean isAllUser){
        
        WrapperResponse response = new WrapperResponse();

        List<Task> contattiTelefonici = new List<Task>();
        List<Task> ricontattiTelefonici = new List<Task>();
        List<Task> promemoria = new List<Task>();

        try{
            Result_FD results = new Result_FD();

            if(String.isNotBlank(userId)){
                contattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId =: UserInfo.getUserId() AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        Subject LIKE 'Contatto Telefonico%' AND
                                        DiFiloDiretto__c = true];

                ricontattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId =: UserInfo.getUserId() AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        Subject LIKE 'Ricontatto Telefonico%' AND
                                        DiFiloDiretto__c = true];

                promemoria = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById =: UserInfo.getUserId() AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];
            } else if(String.isNotBlank(teamName)){
                Map<Id,Sobject> idXUsr = new Map<Id,Sobject>([SELECT Id, Name FROM User WHERE WGC_Team_Filo_Diretto__c =: teamName]);

                contattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId IN: idXUsr.keySet() AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        Subject LIKE 'Contatto Telefonico%' AND
                                        DiFiloDiretto__c = true];

                ricontattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId IN: idXUsr.keySet() AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        Subject LIKE 'Ricontatto Telefonico%' AND
                                        DiFiloDiretto__c = true];

                promemoria = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById IN: idXUsr.keySet() AND 
                                        ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];
            } else if(String.isBlank(userId) && String.isBlank(teamName) && isAllUser){
                // Map<Id,Sobject> idXUsr = new Map<Id,Sobject>([SELECT Id, Name FROM User WHERE Profile.Name =: 'IFIS - Filo Diretto']);

                contattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        Subject LIKE 'Contatto Telefonico%' AND
                                        DiFiloDiretto__c = true];

                ricontattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        Subject LIKE 'Ricontatto Telefonico%' AND
                                        DiFiloDiretto__c = true];

                promemoria = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate =: System.Today() AND
                                        Status = 'Aperto' AND
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        CreatoDaFiloDiretto__c = true];
            }

            results.contattiTelefonici = contattiTelefonici;
            results.ricontattiTelefonici = ricontattiTelefonici;
            results.promemoria = promemoria;

            System.debug('@@@ results ' + JSON.serialize(results));

            response.data.add(results);                                    

        }
        catch(Exception e){
            response.success = false;
            response.msg = e.getMessage();
        }

        return response;
    }

    
    //TEN - 22-07-2019 -- Metodo per recuperare le info per il secondo tab header
    @AuraEnabled
    public static WrapperResponse getPastActivityUser_FD(Boolean isDirezioneFD){
        
        WrapperResponse response = new WrapperResponse();

        List<Task> contattiTelefonici = new List<Task>();
        List<Task> ricontattiTelefonici = new List<Task>();
        List<Task> promemoria = new List<Task>();

        try{
            Result_FD results = new Result_FD();

            if(isDirezioneFD){
                contattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate <: System.Today() AND 
                                        Subject LIKE 'Contatto Telefonico%' AND
                                        Status = 'Aperto' AND
                                        DiFiloDiretto__c = true];

                ricontattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate <: System.Today() AND
                                        Subject LIKE 'Ricontatto Telefonico%' AND
                                        Status = 'Aperto' AND
                                        DiFiloDiretto__c = true];

                promemoria = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate <: System.Today() AND 
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        Status = 'Aperto' AND
                                        CreatoDaFiloDiretto__c = true];
            } else {
                contattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId =: UserInfo.getUserId() AND 
                                        ActivityDate <: System.Today() AND 
                                        Subject LIKE 'Contatto Telefonico%' AND
                                        Status = 'Aperto' AND
                                        DiFiloDiretto__c = true];

                ricontattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId =: UserInfo.getUserId() AND 
                                        ActivityDate <: System.Today() AND
                                        Subject LIKE 'Ricontatto Telefonico%' AND
                                        Status = 'Aperto' AND
                                        DiFiloDiretto__c = true];

                promemoria = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById =: UserInfo.getUserId() AND 
                                        ActivityDate <: System.Today() AND 
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        Status = 'Aperto' AND
                                        CreatoDaFiloDiretto__c = true];
            }

            results.contattiTelefonici = contattiTelefonici;
            results.ricontattiTelefonici = ricontattiTelefonici;
            results.promemoria = promemoria;

            System.debug('@@@ results ' + JSON.serialize(results));

            response.data.add(results);                                    

        }
        catch(Exception e){
            response.success = false;
            response.msg = e.getMessage();
        }

        return response;
    }

    @AuraEnabled
    public static WrapperResponse getPastActivityUser_FD_Filtered(String userId, String teamName, Boolean isAllUser){
        
        WrapperResponse response = new WrapperResponse();

        List<Task> contattiTelefonici = new List<Task>();
        List<Task> ricontattiTelefonici = new List<Task>();
        List<Task> promemoria = new List<Task>();

        try{
            Result_FD results = new Result_FD();

            if(String.isNotBlank(userId)){
                contattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId =: userId AND 
                                        ActivityDate <: System.Today() AND 
                                        Subject LIKE 'Contatto Telefonico%' AND
                                        Status = 'Aperto' AND
                                        DiFiloDiretto__c = true];

                ricontattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId =: userId AND 
                                        ActivityDate <: System.Today() AND
                                        Subject LIKE 'Ricontatto Telefonico%' AND
                                        Status = 'Aperto' AND
                                        DiFiloDiretto__c = true];

                promemoria = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById =: userId AND 
                                        ActivityDate <: System.Today() AND 
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        Status = 'Aperto' AND
                                        CreatoDaFiloDiretto__c = true];
            } else if(String.isNotBlank(teamName)) {
                Map<Id,Sobject> idXUsr = new Map<Id,Sobject>([SELECT Id, Name FROM User WHERE WGC_Team_Filo_Diretto__c =: teamName]);
                contattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId IN: idXUsr.keySet() AND 
                                        ActivityDate <: System.Today() AND 
                                        Subject LIKE 'Contatto Telefonico%' AND
                                        Status = 'Aperto' AND
                                        DiFiloDiretto__c = true];

                ricontattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE OwnerId IN: idXUsr.keySet() AND 
                                        ActivityDate <: System.Today() AND
                                        Subject LIKE 'Ricontatto Telefonico%' AND
                                        Status = 'Aperto' AND
                                        DiFiloDiretto__c = true];

                promemoria = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE CreatedById IN: idXUsr.keySet() AND 
                                        ActivityDate <: System.Today() AND 
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        Status = 'Aperto' AND
                                        CreatoDaFiloDiretto__c = true];
            } else if(String.isBlank(userId) && String.isBlank(teamName) && isAllUser){
                contattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate <: System.Today() AND 
                                        Subject LIKE 'Contatto Telefonico%' AND
                                        Status = 'Aperto' AND
                                        DiFiloDiretto__c = true];

                ricontattiTelefonici = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate <: System.Today() AND
                                        Subject LIKE 'Ricontatto Telefonico%' AND
                                        Status = 'Aperto' AND
                                        DiFiloDiretto__c = true];

                promemoria = [SELECT Id, Subject 
                                        FROM Task 
                                        WHERE ActivityDate <: System.Today() AND 
                                        RecordType.DeveloperName = 'Promemoria' AND
                                        Status = 'Aperto' AND
                                        CreatoDaFiloDiretto__c = true];
            }

            results.contattiTelefonici = contattiTelefonici;
            results.ricontattiTelefonici = ricontattiTelefonici;
            results.promemoria = promemoria;

            System.debug('@@@ results ' + JSON.serialize(results));

            response.data.add(results);                                    

        }
        catch(Exception e){
            response.success = false;
            response.msg = e.getMessage();
        }

        return response;
    }

    @AuraEnabled
    public static WrapperResponse getTaskPrevisioneAvvioRapporto(Boolean isDirezioneFD){
        WrapperResponse response = new WrapperResponse();

        try{
            List<Task> listaPar = new List<Task>();

            if(isDirezioneFD){
                listaPar = [SELECT Id, Subject 
                            FROM Task
                            WHERE DAY_ONLY(CompletedDateTime) =: System.Today() AND
                            Status = 'Chiuso' AND
                            RecordType.DeveloperName = 'Previsione_Avvio_Rapporto'];
            } else {
                listaPar = [SELECT Id, Subject 
                            FROM Task
                            WHERE CreatedById =: UserInfo.getUserId() AND
                            DAY_ONLY(CompletedDateTime) =: System.Today() AND
                            Status = 'Chiuso' AND
                            RecordType.DeveloperName = 'Previsione_Avvio_Rapporto'];
            }

            response.data.add(listaPar);

        }
        catch(Exception e){
            response.success = false;
            response.msg = e.getMessage();
        }

        return response;
    }

    @AuraEnabled
    public static WrapperResponse getTaskPrevisioneAvvioRapporto_Filtered(String userId, String teamName, Boolean isAllUser){
        WrapperResponse response = new WrapperResponse();

        try{
            List<Task> listaPar = new List<Task>();

            if(String.isNotBlank(userId)){
                listaPar = [SELECT Id, Subject 
                            FROM Task
                            WHERE CreatedById =: userId AND
                            DAY_ONLY(CompletedDateTime) =: System.Today() AND
                            Status = 'Chiuso' AND
                            RecordType.DeveloperName = 'Previsione_Avvio_Rapporto'];
            } else if(String.isNotBlank(teamName)){
                Map<Id,Sobject> idXusr = new Map<Id,Sobject>([SELECT Id, Name FROM User WHERE WGC_Team_Filo_Diretto__c =: teamName]);
                listaPar = [SELECT Id, Subject 
                            FROM Task
                            WHERE CreatedById IN: idXusr.keySet() AND
                            DAY_ONLY(CompletedDateTime) =: System.Today() AND
                            Status = 'Chiuso' AND
                            RecordType.DeveloperName = 'Previsione_Avvio_Rapporto'];
            } else if(String.isBlank(userId) && String.isBlank(teamName) && isAllUser){
                listaPar = [SELECT Id, Subject 
                            FROM Task
                            WHERE DAY_ONLY(CompletedDateTime) =: System.Today() AND
                            Status = 'Chiuso' AND
                            RecordType.DeveloperName = 'Previsione_Avvio_Rapporto'];
            }

            response.data.add(listaPar);

        }
        catch(Exception e){
            response.success = false;
            response.msg = e.getMessage();
        }

        return response;
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<Object>();
        }
    }

    public class Result_FD{
        @AuraEnabled public List<Task> contattiTelefonici;
        @AuraEnabled public List<Task> ricontattiTelefonici;
        @AuraEnabled public List<Task> promemoria;

    }

}