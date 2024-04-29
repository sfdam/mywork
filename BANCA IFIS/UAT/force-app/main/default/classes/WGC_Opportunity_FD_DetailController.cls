public class WGC_Opportunity_FD_DetailController {
    
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
             dettaglioVisiteList = [ SELECT Id, Name, CreatedDate, Esito_Visita__c, Iniziativa__c, Primo_Prodotto__c, Filiale__c, Data_Visita_Commerciale__c,
                                            Macro_Esito__c, Pratica_Presentata__c, Esito_Pratica__c, Rapporto_Avviato__c, Operatore_Filo_Diretto__c, toLabel(Filiale_Settorista__c), Operatore_Filo_Diretto_Actual__c,
                                    		Data_Esito_Pratica__c, Data_avvio_rapporto__c, Previsione_Avvio_Rapporto__c
                                FROM WGC_Dettaglio_Visite__c
                                WHERE Data_Visita_Commerciale__c >= LAST_N_YEARS:2 ];
                records.dettaglioVisiteList = dettaglioVisiteList;

                //Commentato per errore Too many Query rows -- inutilizzato
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

    @AuraEnabled
    public static List<FilterGroup> getselectOptions_User() {

        List<FilterGroup> allOpts = new List<FilterGroup>();
        Set<String> uIds = new Set<String>();

        List<WGC_Dettaglio_Visite__c> dettaglioVisiteList = new List<WGC_Dettaglio_Visite__c>();
        dettaglioVisiteList = [ SELECT Id, Name, CreatedDate, Esito_Visita__c, Iniziativa__c, Primo_Prodotto__c, Filiale__c, Data_Visita_Commerciale__c,
                                    Macro_Esito__c, Pratica_Presentata__c, Esito_Pratica__c, Rapporto_Avviato__c, Operatore_Filo_Diretto__c, Operatore_Filo_Diretto_Actual__c, toLabel(Filiale_Settorista__c)
                                FROM WGC_Dettaglio_Visite__c
                                WHERE Data_Visita_Commerciale__c >= LAST_N_YEARS:2 ];

        for(WGC_Dettaglio_Visite__c dt : dettaglioVisiteList){
            uIds.add(dt.Operatore_Filo_Diretto_Actual__c);
        }
        
        // Get the list of picklist values for this field.
        list < User > values = [ SELECT Id, FirstName, LastName, Name, Profile.Name, isActive FROM User WHERE Name IN: uIds AND Profile.Name = 'IFIS - Filo Diretto' Order By IsActive DESC, Name ];

        Map<String, List<User>> mappaUG = (Map<String, List<User>>) U.groupBy(values, 'isActive');
        
        system.debug('SV values: ' + values);
        system.debug('SV mappaUG: ' + JSON.serialize(mappaUG));

        // Add these values to the selectoption list.
        for (String s : mappaUG.keySet()) {
            List<Filter> listaU = new List<Filter>();
            for(User u : mappaUG.get(s)){
                Filter f = new Filter(u.FirstName + ' ' + u.LastName, u.FirstName + ' ' + u.LastName);
                listaU.add(f);
            }
            
            FilterGroup fg = new FilterGroup(s == 'true' ? 'Utenti Attivi' : 'Utenti Disattivi', listaU);
            allOpts.add(fg);
        }
        system.debug('SV allOpts: ' + allOpts);
        
        return allOpts;
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

    public class FilterGroup{
        @AuraEnabled public String gruppo;
        @AuraEnabled public List<Filter> listaFiltri;

        public FilterGroup(){
            this.gruppo = '';
            this.listaFiltri = new List<Filter>();
        }

        public FilterGroup(String gruppo, List<Filter> filtri){
            this.gruppo = gruppo;
            this.listaFiltri = filtri;
        }
    }

    public class Filter{
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        //@AuraEnabled public Boolean isTeam;

        public Filter(){
            this.value = '';
            this.label = '';
            //this.isTeam = false;
        }

        public Filter(String value, String label){
            this.value = value;
            this.label = label;
            //this.isTeam = isTeam;
        }
    }

}