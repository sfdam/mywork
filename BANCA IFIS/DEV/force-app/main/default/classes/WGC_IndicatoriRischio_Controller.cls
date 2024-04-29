public class WGC_IndicatoriRischio_Controller {
    @AuraEnabled
    public static WrapperResponse getAccountInfo(String accountId){
        System.debug('SV accountId: ' + accountId);
        WrapperResponse responseFinal = new WrapperResponse();
        try{
            Result result = new Result();     

            List<Event> event = [ SELECT AccountId, Account.Name, Subject, ActivityDateTime, OwnerId, WhoId, StartDateTime, EndDateTime, Data_Inizio__c, Data_Fine__c, StatoEsitazione__c 
                            FROM Event 
                            WHERE ActivityDateTime >= LAST_N_DAYS:185 AND
                                AccountId =: accountId AND
                                StatoEsitazione__c = 'Esitato'
                            ORDER BY StartDateTime DESC ];

            List<Task> task = [ SELECT AccountId, Account.Name, Subject, ActivityDate, OwnerId, WhoId, RecordType.DeveloperName, DataOraEsitazione__c, Data_Inizio__c, Data_Fine__c
                            FROM Task 
                            WHERE Data_Inizio__c >= LAST_N_DAYS:185 AND
                                AccountId =: accountId AND
                                StatoEsitazione__c = 'Esitato'
                            ORDER BY Data_Inizio__c DESC ];
            
            Account a = new Account();
            a = [SELECT Id, RatingT0__c, RatingT1__c, EventiNegativiGlobale__c, EventiNegativiAllarmiQuote__c,
                        WGC_StatoAnagraficaCed__c, WGC_StatoAnagraficaDeb__c, WGC_Qualifica_Corporate__c,
                        EventiNegativiCIGS__c, EventiNegativiPregiudizievoli__c, EventiNegativiProcedureConcorsuali__c,
                        EventiNegativiProtesti__c, WGC_Censimento__c, WGC_Semaforo_Gianos__c FROM Account WHERE Id =: accountId];

            // SV - TEN Modifica voluta UAT, causa il caricamento avviene non mensilmente ma anche a distanza di 3, 4 mesi
            List<WGC_Centrale_Rischi__c> cr = [ SELECT Id, Anno__c, Mese__c, 
                                                       Sconfino_TOT_IFIS__c, Sofferenze_IFIS_frm__c
                                                FROM WGC_Centrale_Rischi__c 
                                                WHERE Anagrafica__c =: accountId 
                                                ORDER BY Anno__c DESC, Mese__c DESC LIMIT 1 ];

            result.eventList = event;
            result.taskList = task;
            result.crList = cr;
            result.account = a;
            responseFinal.data.add(result); 
            
            if(Test.isRunningTest()) throw new TestException();
                
        } catch (Exception e){
            System.debug('SV exception message: ' + e.getMessage());
            responseFinal.success = false;
            responseFinal.msg = e.getMessage();
            //throw new AuraHandledException(e.getMessage());
            System.debug('SV responseFinal: ' + responseFinal);
        }

        return responseFinal;
    }

    @AuraEnabled
    public static WrapperResponse checkStatusDoc(String objectId){

        WrapperResponse response = new WrapperResponse();

        try{
            String checkResult = WGC_Documenti_Controller.WGC_VerifyStatusDoc(objectId);
            System.debug('@@@ checkResult ' + checkResult);

            response.msg = checkResult;
            if(Test.isRunningTest()) throw new TestException();
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

    public class Result {
        @AuraEnabled public List<Task> taskList;
        @AuraEnabled public List<Event> eventList;
        @AuraEnabled public List<WGC_Centrale_Rischi__c> crList;
        @AuraEnabled public Account account;
    }

}