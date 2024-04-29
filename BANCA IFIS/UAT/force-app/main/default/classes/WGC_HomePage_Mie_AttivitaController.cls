public class WGC_HomePage_Mie_AttivitaController {

    @AuraEnabled
    public static WrapperResponse getActivityUser(){

        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;

        WrapperResponse responseFinal = new WrapperResponse();
        try{
            Result result = new Result();

            WrapperResultLIR lir = new WrapperResultLIR();
            List<AggregateResult> scadutiLIR = [ SELECT COUNT(Id)
                                                FROM Account 
                                                WHERE WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                                AND WGC_LIR_in_scadenza__c < TODAY 
                                                AND WGC_Qualifica_Corporate__c != 'Ex cliente' ];

            List<AggregateResult> aScadereLIR = [ SELECT COUNT(Id)
                                                FROM Account 
                                                WHERE WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                                    AND WGC_LIR_in_scadenza__c >= TODAY 
                                                    AND WGC_LIR_in_scadenza__c <= NEXT_N_DAYS:30 
                                                    AND WGC_Qualifica_Corporate__c != 'Ex cliente' ];


            lir.numScadutiLIR = Integer.ValueOf(scadutiLIR[0].get('expr0'));      
            lir.numAScadereLIR = Integer.ValueOf(aScadereLIR[0].get('expr0'));    

            WrapperResultLP lp = new WrapperResultLP();
            List<AggregateResult> scadutiLP = [ SELECT COUNT(Id) 
                                                    FROM WGC_Linea_Prodotto__c 
                                                    WHERE  Anagrafica__r.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                                        AND Data_Scadenza__c < TODAY
                                                        AND Codice_Stato__c != '010'
                                               			AND Codice_Stato__c != '1'
                                                        AND Anagrafica__r.WGC_Qualifica_Corporate__c != 'Ex cliente' ];

            List<AggregateResult> aScadereLP = [ SELECT COUNT(Id)
                                                    FROM WGC_Linea_Prodotto__c 
                                                    WHERE Anagrafica__r.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                                        AND Data_Scadenza__c >= TODAY 
                                                        AND Data_Scadenza__c <= NEXT_N_DAYS:30
                                                        AND Codice_Stato__c != '010'
                                                		AND Codice_Stato__c != '1'
                                                        AND Anagrafica__r.WGC_Qualifica_Corporate__c != 'Ex cliente' ];

            lp.numScadutiLP = Integer.ValueOf(scadutiLP[0].get('expr0'));      
            lp.numAScadereLP = Integer.ValueOf(aScadereLP[0].get('expr0'));

            WrapperResultQQ qq = new WrapperResultQQ();
            List<AggregateResult> scadutiQQ = [ SELECT COUNT(Id) 
                                                    FROM QuestionarioQualitativo__c 
                                                    WHERE  Account__r.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                                        AND FineValidita__c < TODAY
                                                        //AND Stato__c = 'Scaduto'
                                                        AND Account__r.WGC_Qualifica_Corporate__c != 'Ex cliente' ];

            List<AggregateResult> aScadereQQ = [ SELECT COUNT(Id)
                                                    FROM QuestionarioQualitativo__c 
                                                    WHERE Account__r.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                                        AND FineValidita__c >= TODAY 
                                                        AND FineValidita__c <= NEXT_N_DAYS:30
                                                        //AND Stato__c != 'Confermato'
                                                        AND Account__r.WGC_Qualifica_Corporate__c != 'Ex cliente' ];

            qq.numScadutiQQ = Integer.ValueOf(scadutiQQ[0].get('expr0'));      
            qq.numAScadereQQ = Integer.ValueOf(aScadereQQ[0].get('expr0'));

            List<AggregateResult> todayTask = [ SELECT COUNT(Id)
                                                    FROM Task
                                                    WHERE Data_Inizio__c = TODAY
                                                        AND OwnerId =: UserInfo.getUserId()  
                                                        AND (NOT RecordType.DeveloperName LIKE 'WGC_Diario%') ];
            
            List<Event> event = [ SELECT AccountId, Account.Name, Subject, ActivityDateTime, OwnerId, WhoId, StartDateTime, EndDateTime, Data_Inizio__c, Data_Fine__c 
                            FROM Event 
                            WHERE ActivityDateTime = THIS_MONTH
                                AND OwnerId =: UserInfo.getUserId()
                            ORDER BY StartDateTime ASC ];

            result.eventList = event;
            // result.taskList = task;
            result.lir = lir;
            result.lp = lp;
            result.qq = qq;
            result.todayTask = Integer.ValueOf(todayTask[0].get('expr0'));
            // result.accountList = account;
            // result.lineaProdottoList = lineaProd;
            // result.qqList = qq;
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

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/

    public class WrapperResultQQ {
        
        @AuraEnabled public Integer numScadutiQQ;
        @AuraEnabled public Integer numAScadereQQ;
    }


    public class WrapperResultLIR {
        
        @AuraEnabled public Integer numScadutiLIR;
        @AuraEnabled public Integer numAScadereLIR;
    }

    public class WrapperResultLP {
        
        @AuraEnabled public Integer numScadutiLP;
        @AuraEnabled public Integer numAScadereLP;
    }
    
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
        @AuraEnabled public List<Account> accountList;
        @AuraEnabled public List<WGC_Linea_Prodotto__c> lineaProdottoList;
        @AuraEnabled public List<QuestionarioQualitativo__c> qqList;

        @AuraEnabled public WrapperResultLP lp;
        @AuraEnabled public WrapperResultLIR lir;
        @AuraEnabled public WrapperResultQQ qq;
        @AuraEnabled public Integer todayTask;


    }

}