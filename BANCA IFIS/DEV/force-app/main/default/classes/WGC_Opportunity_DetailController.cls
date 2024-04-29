public class WGC_Opportunity_DetailController {

    @AuraEnabled
    public static WrapperResponse getAllData() {
        
        Id profileId = userinfo.getProfileId();
        User user = [ SELECT Id, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        // IFIS - Direzione Commerciale

        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();

        try{

            if(profileName.contains('Filo Diretto')){ // PROFILI FILO DIRETTO
                List<WGC_Dettaglio_Visite__c> dettaglioVisiteList = new List<WGC_Dettaglio_Visite__c>();
                dettaglioVisiteList = [ SELECT Id, Name, CreatedDate, Esito_Visita__c, Iniziativa__c, Primo_Prodotto__c, Filiale__c, Data_Visita_Commerciale__c
                                FROM WGC_Dettaglio_Visite__c
                                WHERE CreatedDate >= LAST_N_YEARS:2 ];
                records.dettaglioVisiteList = dettaglioVisiteList;

                Set<Id> detVisIdSet = new Set<Id>();
                for(WGC_Dettaglio_Visite__c detVis : dettaglioVisiteList){
                    detVisIdSet.add(detVis.Id);
                }

                List<WGC_Prodotto_DettaglioVisite__c> prodottoDV = new List<WGC_Prodotto_DettaglioVisite__c>();
                prodottoDV = [ SELECT Id, Name, Dettaglio_Visite__c, Tipologia_Prodotto__c
                                FROM WGC_Prodotto_DettaglioVisite__c
                                WHERE Dettaglio_Visite__c IN : detVisIdSet ];
                records.prodottoDV = prodottoDV;

            } else { // TUTTI GLI ALTRI PROFILI
                            
                List<WGC_New_Business__c> accList = new List<WGC_New_Business__c>();
                if(profileName == 'IFIS - Direzione Commerciale'){
                    accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c 
                                FROM WGC_New_Business__c
                                WHERE Data_New_Business__c >= LAST_N_YEARS:2 ];
                } else {
                    accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c   
                                FROM WGC_New_Business__c
                                WHERE NDG_Settorista__c =: user.NDGGruppo__c AND NDG_Settorista__c != ''
                                    AND Data_New_Business__c >= LAST_N_YEARS:2 ];
                }
                records.accountList = accList;

                Set<Id> accIdSet = new Set<Id>();
                for(WGC_New_Business__c acc : accList){
                    accIdSet.add(acc.Anagrafica__r.Id);
                }

                List<Opportunity> oppList = new List<Opportunity>();
                if(profileName == 'IFIS - Direzione Commerciale'){
                    oppList = [ SELECT Id, AccountId, OwnerId, StageName, Originator__c, CreatedDate, Data_Inizio__c, IsOppNSA__c, FaseDiCaduta__c                                       
                                FROM Opportunity 
                                WHERE Account.WGC_Specialista_Factoring__c != null 
                                    AND AccountId NOT IN : accIdSet
                                    AND Data_Inizio__c > LAST_N_YEARS:2 ];
                } else {
                    oppList = [ SELECT Id, AccountId, OwnerId, StageName, Originator__c, CreatedDate, Data_Inizio__c, IsOppNSA__c, FaseDiCaduta__c                                          
                                FROM Opportunity 
                                WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                    AND OwnerId =: UserInfo.getUserId() 
                                    AND AccountId NOT IN : accIdSet 
                                    AND IsOppNSA__c = FALSE
                                    AND Data_Inizio__c > LAST_N_YEARS:2 ];
                }
                records.opportunityList = oppList;

                List<Event> eventList = new List<Event>();
                if(profileName == 'IFIS - Direzione Commerciale'){
                    eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c                                              
                                    FROM Event 
                                    WHERE Account.WGC_Specialista_Factoring__c != null 
                                        AND AccountId NOT IN : accIdSet 
                                        AND RecordType.DeveloperName != 'Promemoria'
                                        AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                        AND Data_Inizio__c > LAST_N_YEARS:2 ];
                } else {
                    eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c                                              
                                    FROM Event 
                                    WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                        AND Account.WGC_Factoring_Attivo__c = TRUE
                                        AND OwnerId =: UserInfo.getUserId() 
                                        AND AccountId NOT IN : accIdSet 
                                        AND RecordType.DeveloperName != 'Promemoria'
                                        AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                        AND Data_Inizio__c > LAST_N_YEARS:2 ];
                }
                records.eventList = eventList;

                List<Task> taskList = new List<Task>();
                if(profileName == 'IFIS - Direzione Commerciale'){
                    taskList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, Status, Campagna__c, Campagna__r.Status, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c, RecordType.DeveloperName                                           
                                    FROM Task 
                                    WHERE Account.WGC_Specialista_Factoring__c != null 
                                    AND AccountId NOT IN : accIdSet 
                                    AND RecordType.DeveloperName != 'Promemoria'
                                    AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                    AND Data_Inizio__c > LAST_N_YEARS:2 ];
                } else {
                    taskList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, Status, Campagna__c, Campagna__r.Status, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c, RecordType.DeveloperName                                           
                                    FROM Task 
                                    WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                    AND OwnerId =: UserInfo.getUserId() 
                                    AND AccountId NOT IN : accIdSet 
                                    AND RecordType.DeveloperName != 'Promemoria'
                                    AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                    AND Data_Inizio__c > LAST_N_YEARS:2 ];
                }
                records.taskList = taskList;

                List<WGC_Best_Practice__c> bpList = [ SELECT Id, OwnerId, LastModifiedDate, Redemption_Dettaglio__c, Convertion_Dettaglio__c, 
                                                            T0_Dettaglio__c, T1_Dettaglio__c, Qualita_Dettaglio__c, Year__c, Week__c, Month__c, Task__c, Visite__c, 
                                                            Opportunita__c, Clienti_Attivati__c 
                                                    FROM WGC_Best_Practice__c 
                                                    WHERE Year__c != ''
                                                    ORDER BY OwnerId, Week__c
                                                    LIMIT 40 ];
                records.bestPracticeList = bpList;

                List<Task> valCampagna = [ SELECT Id, Campagna__c 
                                        FROM Task 
                                        WHERE ownerID =: UserInfo.getUserId() AND  
                                                Campagna__c != '' AND 
                                                recordtype.DeveloperName NOT IN ('Promemoria', 'WGC_Diario_Inserimento_Campagna', 'WGC_Diario_Modifica_Qualifica', 'WGC_Diario_Modifica_Rating', 'WGC_Diario_Nuova_Opportunita') ];

                records.valCampagna = valCampagna.size();

                List<CampaignMember> valCampaignMember = [ SELECT Id 
                                            FROM CampaignMember 
                                            WHERE Contact.Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() ];

                records.valCampaignMember = valCampaignMember.size();

                List<Opportunity> valOpportunity = [ SELECT Id 
                                        FROM Opportunity 
                                        WHERE ownerID =: UserInfo.getUserId() AND 
                                                (Originator__c='Web' OR 
                                                    Originator__c='Marketing') ];

                records.valOpportunity = valOpportunity.size();

            }

            result.data.add(records);

        } catch(exception e){
            result.success = false; 
            result.msg = e.getMessage();
            return result;
        }

        /*
        
        try{

            List<WGC_New_Business__c> accList = new List<WGC_New_Business__c>();
            if(profileName == 'IFIS - Direzione Commerciale'){
                // accList = [ SELECT Id, Name, StatoCensimento__c, WGC_Qualifica_Corporate__c, WGC_Specialista_Factoring__c, WGC_Factoring_Attivo__c, CreatedDate, WGC_Originator__c
                //             FROM Account 
                //             WHERE WGC_Specialista_Factoring__c != null
                //                 AND WGC_Qualifica_Corporate__c = 'Cliente Attivo'
                //                 AND CreatedDate > LAST_N_YEARS:2 ];
                accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c 
                            FROM WGC_New_Business__c
                            WHERE Data_New_Business__c >= LAST_N_YEARS:2 ];
            } else if(profileName == 'IFIS - Filo Diretto'){
                accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c 
                            FROM WGC_New_Business__c
                            WHERE NDG_Filo_Diretto__c =: user.NDGGruppo__c AND NDG_Filo_Diretto__c != ''
                                AND Data_New_Business__c >= LAST_N_YEARS:2 ];
            } else {
                // accList = [ SELECT Id, Name, StatoCensimento__c, WGC_Qualifica_Corporate__c, WGC_Specialista_Factoring__c, WGC_Factoring_Attivo__c, CreatedDate, WGC_Originator__c 
                //             FROM Account 
                //             WHERE WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                //                 AND WGC_Qualifica_Corporate__c = 'Cliente Attivo'
                //                 AND CreatedDate > LAST_N_YEARS:2 ];
                accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c   
                            FROM WGC_New_Business__c
                            WHERE NDG_Settorista__c =: user.NDGGruppo__c AND NDG_Settorista__c != ''
                                AND Data_New_Business__c >= LAST_N_YEARS:2 ];

            }
            records.accountList = accList;

            Set<Id> accIdSet = new Set<Id>();
            for(WGC_New_Business__c acc : accList){
                accIdSet.add(acc.Anagrafica__r.Id);
            }

            List<Opportunity> oppList = new List<Opportunity>();
            if(profileName == 'IFIS - Direzione Commerciale'){
                oppList = [ SELECT Id, AccountId, OwnerId, StageName, Originator__c, CreatedDate, Data_Inizio__c, IsOppNSA__c, FaseDiCaduta__c                                       
                            FROM Opportunity 
                            WHERE Account.WGC_Specialista_Factoring__c != null 
                                AND AccountId NOT IN : accIdSet
                                AND Data_Inizio__c > LAST_N_YEARS:2 ];
            } else if(profileName == 'IFIS - Filo Diretto'){
                oppList = [ SELECT Id, AccountId, OwnerId, StageName, Originator__c, CreatedDate, Data_Inizio__c, IsOppNSA__c, FaseDiCaduta__c, NDG_Filo_Diretto__c                                          
                            FROM Opportunity 
                            WHERE NDG_Filo_Diretto__c =: user.NDGGruppo__c AND NDG_Filo_Diretto__c != ''
                                AND AccountId NOT IN : accIdSet 
                                AND IsOppNSA__c = FALSE
                                AND Data_Inizio__c > LAST_N_YEARS:2 ];
            } else {
                oppList = [ SELECT Id, AccountId, OwnerId, StageName, Originator__c, CreatedDate, Data_Inizio__c, IsOppNSA__c, FaseDiCaduta__c                                          
                            FROM Opportunity 
                            WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                AND OwnerId =: UserInfo.getUserId() 
                                AND AccountId NOT IN : accIdSet 
                                AND IsOppNSA__c = FALSE
                                AND Data_Inizio__c > LAST_N_YEARS:2 ];
            }
            records.opportunityList = oppList;

            List<Event> eventList = new List<Event>();
            if(profileName == 'IFIS - Direzione Commerciale'){
                eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c                                              
                              FROM Event 
                              WHERE Account.WGC_Specialista_Factoring__c != null 
                                AND AccountId NOT IN : accIdSet 
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND Data_Inizio__c > LAST_N_YEARS:2 ];
            } else if(profileName == 'IFIS - Filo Diretto'){
                eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c, CreatedById, CreatoDaFiloDiretto__c                                              
                              FROM Event 
                              WHERE CreatedById =: UserInfo.getUserId() 
                                AND CreatoDaFiloDiretto__c = TRUE
                                AND AccountId NOT IN : accIdSet 
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND Data_Inizio__c > LAST_N_YEARS:2 ];
            } else {
                eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c                                              
                              FROM Event 
                              WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                AND Account.WGC_Factoring_Attivo__c = TRUE
                                AND OwnerId =: UserInfo.getUserId() 
                                AND AccountId NOT IN : accIdSet 
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND Data_Inizio__c > LAST_N_YEARS:2 ];
            }
            records.eventList = eventList;

            List<Task> taskList = new List<Task>();
            if(profileName == 'IFIS - Direzione Commerciale'){
                taskList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, Status, Campagna__c, Campagna__r.Status, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c, RecordType.DeveloperName                                           
                             FROM Task 
                             WHERE Account.WGC_Specialista_Factoring__c != null 
                             AND AccountId NOT IN : accIdSet 
                             AND RecordType.DeveloperName != 'Promemoria'
                             AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                             AND Data_Inizio__c > LAST_N_YEARS:2 ];
            } else if(profileName == 'IFIS - Filo Diretto'){
                taskList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, Status, Campagna__c, Campagna__r.Status, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c, RecordType.DeveloperName, DiFiloDiretto__c                                           
                             FROM Task 
                             WHERE DiFiloDiretto__c = TRUE
                             AND OwnerId =: UserInfo.getUserId() 
                             AND AccountId NOT IN : accIdSet 
                             AND RecordType.DeveloperName != 'Promemoria'
                             AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                             AND Data_Inizio__c > LAST_N_YEARS:2 ];
            } else {
                taskList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, Status, Campagna__c, Campagna__r.Status, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c, RecordType.DeveloperName                                           
                             FROM Task 
                             WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                             AND OwnerId =: UserInfo.getUserId() 
                             AND AccountId NOT IN : accIdSet 
                             AND RecordType.DeveloperName != 'Promemoria'
                             AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                             AND Data_Inizio__c > LAST_N_YEARS:2 ];
            }
            records.taskList = taskList;

            List<WGC_Best_Practice__c> bpList = [ SELECT Id, OwnerId, LastModifiedDate, Redemption_Dettaglio__c, Convertion_Dettaglio__c, 
                                                        T0_Dettaglio__c, T1_Dettaglio__c, Qualita_Dettaglio__c, Year__c, Week__c, Month__c, Task__c, Visite__c, 
                                                        Opportunita__c, Clienti_Attivati__c 
                                                  FROM WGC_Best_Practice__c 
                                                  WHERE Year__c != ''
                                                  ORDER BY OwnerId, Week__c
                                                  LIMIT 40 ];
            records.bestPracticeList = bpList;

            List<Task> valCampagna = [ SELECT Id, Campagna__c 
                                       FROM Task 
                                       WHERE ownerID =: UserInfo.getUserId() AND  
                                            Campagna__c != '' AND 
                                            recordtype.DeveloperName NOT IN ('Promemoria', 'WGC_Diario_Inserimento_Campagna', 'WGC_Diario_Modifica_Qualifica', 'WGC_Diario_Modifica_Rating', 'WGC_Diario_Nuova_Opportunita') ];

            records.valCampagna = valCampagna.size();

            List<CampaignMember> valCampaignMember = [ SELECT Id 
                                        FROM CampaignMember 
                                        WHERE Contact.Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() ];

            records.valCampaignMember = valCampaignMember.size();

            List<Opportunity> valOpportunity = [ SELECT Id 
                                       FROM Opportunity 
                                       WHERE ownerID =: UserInfo.getUserId() AND 
                                            (Originator__c='Web' OR 
                                                Originator__c='Marketing') ];

            records.valOpportunity = valOpportunity.size();

            result.data.add(records);
        } catch(exception e){
            result.success = false; 
            result.msg = e.getMessage();
            return result;
        }

        */
        
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
        @AuraEnabled public List<WGC_New_Business__c> accountList;
        @AuraEnabled public List<Opportunity> opportunityList;
        @AuraEnabled public List<Event> eventList;
        @AuraEnabled public List<Task> taskList;
        @AuraEnabled public List<WGC_Best_Practice__c> bestPracticeList;
        @AuraEnabled public Integer valCampagna;
        @AuraEnabled public Integer valCampaignMember;
        @AuraEnabled public Integer valOpportunity;
        // @AuraEnabled public List<Task> taskListIC;


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