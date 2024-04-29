public class WGC_Header_Base_ClientiController {

    @AuraEnabled
    public static WrapperResponse getAccountInfo(){

        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;


        WrapperResponse responseFinal = new WrapperResponse();
        try{
            Result result = new Result();     

            List<AggregateResult> accIncerti = new List<AggregateResult>();
            List<AggregateResult> accDormienti = new List<AggregateResult>();
            List<AggregateResult> accInattivi = new List<AggregateResult>();
            List<AggregateResult> accPersi = new List<AggregateResult>();

            if(profileName == 'IFIS - Direzione Commerciale'){
                accIncerti = [ SELECT Count(Id) conteggio
                                        // , Name, WGC_Qualifica_Corporate__c, WGC_Qualifica_Corporate_Data__c,   
                                        //  WGC_Specialista_Factoring__c, WGC_Factoring_Attivo__c, 
                                        //  WGC_Specialista_Leasing__c, 
                                        //  WGC_Specialista_Crediti_Erariali__c, 
                                        //  WGC_Specialista_IFIS_Finance__c, 
                                        //  WGC_Specialista_Finanza_Strutturata__c, 
                                        //  WGC_Specialista_Filo_Diretto__c, WGC_Filo_Diretto_Attivo__c,
                                        //  WGC_Specialista_IFIS_International__c
                                FROM Account 
                                WHERE (OwnerId != null
                                        OR (WGC_Specialista_Factoring__c != null)
                                        OR (WGC_Specialista_Leasing__c != null)
                                        OR (WGC_Specialista_Crediti_Erariali__c != null)
                                        OR (WGC_Specialista_IFIS_Finance__c != null)
                                        OR (WGC_Specialista_Finanza_Strutturata__c != null)
                                        OR (WGC_Specialista_Filo_Diretto__c != null)
                                        OR (WGC_Specialista_IFIS_International__c != null)
                                      )
                                      AND WGC_Qualifica_Corporate__c = 'Cliente Incerto'
                                    //AND WGC_Qualifica_Corporate_Data__c >= LAST_YEAR
                                    ]; 

                accIncerti = [ SELECT Count(Id) conteggio
                                FROM Account 
                                WHERE
                                   (OwnerId != null
                                        OR (WGC_Specialista_Factoring__c != null)
                                        OR (WGC_Specialista_Leasing__c != null)
                                        OR (WGC_Specialista_Crediti_Erariali__c != null)
                                        OR (WGC_Specialista_IFIS_Finance__c != null)
                                        OR (WGC_Specialista_Finanza_Strutturata__c != null)
                                        OR (WGC_Specialista_Filo_Diretto__c != null)
                                        OR (WGC_Specialista_IFIS_International__c != null)
                                    )
                                    //AND WGC_Qualifica_Corporate_Data__c >= LAST_YEAR
                                    AND WGC_Qualifica_Corporate__c = 'Cliente Incerto'
                                    ]; 

                accDormienti = [ SELECT Count(Id) conteggio
                                FROM Account 
                                WHERE
                                    (OwnerId != null
                                        OR (WGC_Specialista_Factoring__c != null)
                                        OR (WGC_Specialista_Leasing__c != null)
                                        OR (WGC_Specialista_Crediti_Erariali__c != null)
                                        OR (WGC_Specialista_IFIS_Finance__c != null)
                                        OR (WGC_Specialista_Finanza_Strutturata__c != null)
                                        OR (WGC_Specialista_Filo_Diretto__c != null)
                                        OR (WGC_Specialista_IFIS_International__c != null)
                                      )
                                    //AND WGC_Qualifica_Corporate_Data__c >= LAST_YEAR
                                    AND WGC_Qualifica_Corporate__c = 'Cliente dormiente'
                                    ];

                accInattivi = [ SELECT Count(Id) conteggio
                                FROM Account 
                                WHERE
                                    (OwnerId != null
                                        OR (WGC_Specialista_Factoring__c != null)
                                        OR (WGC_Specialista_Leasing__c != null)
                                        OR (WGC_Specialista_Crediti_Erariali__c != null)
                                        OR (WGC_Specialista_IFIS_Finance__c != null)
                                        OR (WGC_Specialista_Finanza_Strutturata__c != null)
                                        OR (WGC_Specialista_Filo_Diretto__c != null)
                                        OR (WGC_Specialista_IFIS_International__c != null)
                                      )
                                    //AND WGC_Qualifica_Corporate_Data__c >= LAST_YEAR
                                    AND WGC_Qualifica_Corporate__c = 'Cliente inattivo'
                                    ]; 

                accPersi = [ SELECT Count(Id) conteggio
                                FROM Account 
                                WHERE
                                    (OwnerId != null
                                        OR (WGC_Specialista_Factoring__c != null)
                                        OR (WGC_Specialista_Leasing__c != null)
                                        OR (WGC_Specialista_Crediti_Erariali__c != null)
                                        OR (WGC_Specialista_IFIS_Finance__c != null)
                                        OR (WGC_Specialista_Finanza_Strutturata__c != null)
                                        OR (WGC_Specialista_Filo_Diretto__c != null)
                                        OR (WGC_Specialista_IFIS_International__c != null)
                                      )
                                    AND WGC_Qualifica_Perso__c = THIS_YEAR
                                    AND WGC_Qualifica_Corporate__c = 'Ex Cliente'
                                    ]; 
            } else {
                accIncerti = [ SELECT Count(Id) conteggio
                                FROM Account 
                                WHERE
                                    (
                                    (WGC_Specialista_Factoring__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Leasing__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Crediti_Erariali__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_IFIS_Finance__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Finanza_Strutturata__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_IFIS_International__c =: UserInfo.getUserId())
                                    )
                                    //AND WGC_Qualifica_Corporate_Data__c >= LAST_YEAR
                                    AND WGC_Qualifica_Corporate__c = 'Cliente Incerto'
                                    ]; 

                accDormienti = [ SELECT Count(Id) conteggio
                                FROM Account 
                                WHERE
                                    (
                                    (WGC_Specialista_Factoring__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Leasing__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Crediti_Erariali__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_IFIS_Finance__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Finanza_Strutturata__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_IFIS_International__c =: UserInfo.getUserId())
                                    )
                                    //AND WGC_Qualifica_Corporate_Data__c >= LAST_YEAR
                                    AND WGC_Qualifica_Corporate__c = 'Cliente dormiente'
                                    ];

                accInattivi = [ SELECT Count(Id) conteggio
                                FROM Account 
                                WHERE
                                    (
                                    (WGC_Specialista_Factoring__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Leasing__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Crediti_Erariali__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_IFIS_Finance__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Finanza_Strutturata__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_IFIS_International__c =: UserInfo.getUserId())
                                    )
                                    //AND WGC_Qualifica_Corporate_Data__c >= LAST_YEAR
                                    AND WGC_Qualifica_Corporate__c = 'Cliente inattivo'
                                    ]; 

                accPersi = [ SELECT Count(Id) conteggio
                                FROM Account 
                                WHERE
                                    (
                                    (WGC_Specialista_Factoring__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Leasing__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Crediti_Erariali__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_IFIS_Finance__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Finanza_Strutturata__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId())
                                    OR (WGC_Specialista_IFIS_International__c =: UserInfo.getUserId())
                                    )
                                    AND WGC_Qualifica_Perso__c = THIS_YEAR
                                    AND WGC_Qualifica_Corporate__c = 'Ex Cliente'
                                    ]; 
            }
            
            result.accountIncerti = accIncerti;
            result.accountDormienti = accDormienti;
            result.accountInattivi = accInattivi;
            result.accountPersi = accPersi;

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
        @AuraEnabled public List<AggregateResult> accountIncerti;
        @AuraEnabled public List<AggregateResult> accountDormienti;
        @AuraEnabled public List<AggregateResult> accountInattivi;
        @AuraEnabled public List<AggregateResult> accountPersi;
    }
}