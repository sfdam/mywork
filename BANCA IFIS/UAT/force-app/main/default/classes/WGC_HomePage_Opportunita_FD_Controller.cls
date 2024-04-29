public class WGC_HomePage_Opportunita_FD_Controller {

     @AuraEnabled
    public static WrapperResponse getAllData() {
        
        Id profileId = userinfo.getProfileId();
        User user = [ SELECT Id, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        // IFIS - Direzione Commerciale

        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();
        
        try{
            
             List<WGC_Dettaglio_Visite__c> dettaglioVisiteList = new List<WGC_Dettaglio_Visite__c>();
             dettaglioVisiteList = [ SELECT Id, Name, CreatedDate, Esito_Visita__c, Iniziativa__c, Primo_Prodotto__c, Filiale__c, Data_Visita_Commerciale__c, Data_Contatto_Telefonico__c,
                                            Macro_Esito__c, Pratica_Presentata__c, Esito_Pratica__c, Rapporto_Avviato__c, Data_Avvio_Rapporto__c, Operatore_Filo_Diretto__c, Operatore_Filo_Diretto__r.WGC_Team_Filo_Diretto__c,
                                            Data_Esito_Pratica__c, Previsione_Avvio_Rapporto__c
                                FROM WGC_Dettaglio_Visite__c
                                WHERE Data_Visita_Commerciale__c >= LAST_N_YEARS:2 ];
                records.dettaglioVisiteList = dettaglioVisiteList;

                //Commentato -- inutilizzato
                // Set<Id> detVisIdSet = new Set<Id>();
                // for(WGC_Dettaglio_Visite__c detVis : dettaglioVisiteList){
                //     detVisIdSet.add(detVis.Id);
                // }

                // List<WGC_Prodotto_DettaglioVisite__c> prodottoDV = new List<WGC_Prodotto_DettaglioVisite__c>();
                // prodottoDV = [ SELECT Id, Name, Dettaglio_Visite__c, Tipologia_Prodotto__c
                //                 FROM WGC_Prodotto_DettaglioVisite__c
                //                 WHERE Dettaglio_Visite__c IN : detVisIdSet ];
                // records.prodottoDV = prodottoDV;
            
            
            result.data.add(records);
            
        } catch(exception e){
            result.success = false; 
            result.msg = e.getMessage();
            return result;
        }
        

        return result;        
    }
    
    @AuraEnabled
    public static User getUserInfo() {
        return [ SELECT Id, Name, Qualifica_Utente__c FROM User WHERE Id =: UserInfo.getUserId() ];
        
    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperRecords {

        @AuraEnabled public List<WGC_Dettaglio_Visite__c> dettaglioVisiteList;
        @AuraEnabled public List<WGC_Prodotto_DettaglioVisite__c> prodottoDV;


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
}