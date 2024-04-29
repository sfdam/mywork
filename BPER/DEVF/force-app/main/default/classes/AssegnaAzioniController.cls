public with sharing class AssegnaAzioniController {

    public virtual class BaseException extends Exception {}

    public static Contact userMap {
        get{
            if(userMap != null){
                return userMap;
            }
            userMap = [SELECT id, PTF_ReferenteElegibile__c, PTF_RegistrationNumber__c, Name, PTF_IdCED__c, AccountId, PTF_User__c, PTF_ProfiloLDAP__c, PTF_IsVice__c, PTF_Ruolo__c, PTF_TipologiaRuolo__r.Name,PTF_User__r.CRM_HasLab__c, PTF_User__r.Profilo__c,PTF_User__r.CRM_PermissionSet__c FROM Contact WHERE PTF_User__c =: UserInfo.getUserId()];
            return userMap;
        }set;
    }

    @AuraEnabled
    public static WrapperObj getContact(){

        WrapperObj response = new WrapperObj();

        Map<String, SObject> accMap = new Map<String, SObject>();
        // Contact userMap = new Contact();
        Map<String, SObject> ptfMap = new Map<String, SObject>();
        Map<String, SObject> contactMap = new Map<String, SObject>();

        // userMap = [SELECT id, PTF_RegistrationNumber__c, Name, PTF_IdCED__c, AccountId, PTF_User__c, PTF_ProfiloLDAP__c, PTF_IsVice__c, PTF_Ruolo__c, PTF_TipologiaRuolo__r.Name,PTF_User__r.CRM_HasLab__c FROM Contact WHERE PTF_User__c =: UserInfo.getUserId()];
        response.userMap = userMap;
        response.accMap = accMap;

        contactMap = SV_Utilities.keyBy([SELECT Id, PTF_RegistrationNumber__c, Name, PTF_IdCED__c, AccountId, PTF_User__c, PTF_ProfiloLDAP__c, PTF_IsVice__c, PTF_Ruolo__c, PTF_TipologiaRuolo__r.Name, PTF_User__r.CRM_MMDSVisibili__c FROM Contact WHERE AccountId =: userMap.AccountId /*AND Id !=: userMap.Id*/ AND PTF_Ruolo__c != NULL AND PTF_User__c != NULL AND PTF_User__r.isActive = true], '{PTF_Ruolo__c}_{Id}', true);
        response.contactMap = contactMap; 
        response.ptfMap = ptfMap;

        AssegnazioniAzioniCS__c conf = AssegnazioniAzioniCS__c.getInstance();
        response.AssegnazioniAzioniConfig = conf;


        return response;
    }

    @AuraEnabled
    public static WrapperObj getCampaignMember(){

        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        String recordTypeTopDownMulti = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Multistep').getRecordTypeId();

        WrapperObj response = new WrapperObj();
        // Map<String, SObject> campaignMemberMap = new Map<String, SObject>();
        String query = 'SELECT Id, PTF_IdCed__c, PTF_ModelloDiServizio__c, PTF_Ambito__c, Status__c, CRM_Esito__c,' +
        ' CRM_CampaignMemberId__c, Campaign__c, Campaign__r.CRM_Categoria__c, Campaign__r.Name, Campaign__r.CRM_Priorita__c, ' +
        ' Campaign__r.CRM_EndDateFormula__c, Campaign__r.CRM_StartDateFormula__c,Campaign__r.RecordTypeId, Campaign__r.CRM_NomeAttributo1__c, Campaign__r.CRM_NomeAttributo2__c,' +
        ' CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c, CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c, CRM_ValoreAttributo2_Text__c,' +
        ' CRM_Account__r.CRM_NDG__c,CRM_Account__r.Name,CRM_Account__r.PTF_NaturaGiuridica__c, CRM_Account__r.PTF_Portafoglio__c,' +
        ' CRM_Account__r.PTF_Portafoglio__r.Name, CRM_Account__r.PTF_MicroWallet__r.Name, CRM_Account__r.ModelloDiServizio__c,' +
        ' CRM_Assegnatario__r.Name, CRM_Assegnatario__c, CRM_AssegnatarioUser__c, CRM_AssegnatarioUser__r.IsActive, CRM_AssegnatarioUser__r.Name, CRM_AssegnatarioUser__r.idCed__c,' +
        ' Campaign__r.Tipologia_Azione__c, CRM_Autore__c,CRM_Account__r.CRM_Filiale__c, CRM_Account__r.PTF_MiniPortafoglio__r.Name,  CRM_Account__r.PTF_MiniPortafoglio__c, Campaign__r.CRM_Nome_Attributo_1_formula__c, Campaign__r.CRM_Nome_Attributo_2_formula__c,                                            ' +
        'Campaign__r.CRM_TipologiaCampagna__c, Campaign__r.Priorita_Campagna__c '+
        ' FROM campaignMember__c' +
        ' WHERE ' +
        ' Status__c != \'Eliminato\' AND' +
        ' PTF_Ambito__c = \'AssegnazioneAzione\' AND' +
        ' (Campaign__r.RecordTypeId =: recordTypeTopDownMono OR Campaign__r.RecordTypeId =: recordTypeTopDownMulti) AND' +
        ' Campaign__r.CRM_CampagnaInCorso__c = true AND Campaign__r.CRM_Channel__c = \'Rete\' AND Campaign__r.CRM_SottotipologiaCampagna__c != \'Altra proposta\'AND CRM_Account__r.ModelloDiServizio__c !=null ';
        

        if(userMap.PTF_User__r.Profilo__c.contains('NEC_F') ||
        (userMap.PTF_User__r.Profilo__c == 'CRM - Utente di Rete' && userMap.PTF_ReferenteElegibile__c)){
            query += ' AND CRM_Account__r.CRM_Filiale__c = \'' + userMap.AccountId + '\'';
        }
        query += ' ORDER BY Campaign__r.Priorita_Campagna__c, Priorita_Campaign_Member__c';
        System.debug('query: '+query);
        query += ' LIMIT 45000 ';
        response.campaignMemberList = Database.query(query);
        
        /*List<campaignMember__c> campaignMemberList = [SELECT Id, PTF_IdCed__c, PTF_ModelloDiServizio__c, PTF_Ambito__c, Status__c, CRM_Esito__c,
        CRM_CampaignMemberId__c, Campaign__c, Campaign__r.CRM_Categoria__c, Campaign__r.Name, Campaign__r.CRM_Priorita__c, 
        Campaign__r.CRM_EndDateFormula__c, Campaign__r.CRM_StartDateFormula__c,Campaign__r.RecordTypeId, Campaign__r.CRM_NomeAttributo1__c, Campaign__r.CRM_NomeAttributo2__c,
        CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c, CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c, CRM_ValoreAttributo2_Text__c,
        CRM_Account__r.CRM_NDG__c, CRM_Account__r.PTF_Filiale__c, CRM_Account__r.Name,CRM_Account__r.PTF_NaturaGiuridica__c, CRM_Account__r.PTF_Portafoglio__c,
        CRM_Account__r.PTF_Portafoglio__r.Name, CRM_Account__r.ModelloDiServizio__c,
        CRM_Assegnatario__r.Name, CRM_Assegnatario__c, CRM_AssegnatarioUser__c, CRM_AssegnatarioUser__r.IsActive, CRM_AssegnatarioUser__r.Name, CRM_AssegnatarioUser__r.idCed__c,
        Campaign__r.Tipologia_Azione__c, CRM_Autore__c                                              
        FROM campaignMember__c
        WHERE 
        Status__c != 'Eliminato' AND
        PTF_Ambito__c = 'AssegnazioneAzione' AND
        (Campaign__r.RecordTypeId =: recordTypeTopDownMono OR Campaign__r.RecordTypeId =: recordTypeTopDownMulti) AND
        Campaign__r.CRM_CampagnaInCorso__c = true AND Campaign__r.CRM_Channel__c = 'Rete' AND PTF_IdCed__c =: userMap.PTF_Idced__c /*AND  CRM_Esito__c IN ('Da contattare','Da Ricontattare')
        LIMIT 45000];
        response.campaignMemberList = campaignMemberList;*/



        return response;
    }
    @AuraEnabled
    public static Map<String,Object> getEventMember(){

        String recordTypeTriggerBasedMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Trigger - Monostep').getRecordTypeId();
        String recordTypeTriggerBaseMulti = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Trigger - Multistep').getRecordTypeId();

        Map<String,Object> response;
        Map<String, SObject> eventMemberMap = new Map<String, SObject>();

        // VS 09/05/2022 - BPER_CR_Prioritizzazione - Aggiunti campi Campaign__r.CRM_TipologiaCampagna__c, Campaign__r.Priorita_Campagna__c nella query
        String query = 'SELECT Id, PTF_IdCed__c, PTF_ModelloDiServizio__c, PTF_Ambito__c, Status__c, CRM_Esito__c,' +
        ' CRM_CampaignMemberId__c, Campaign__c, Campaign__r.CRM_Categoria__c, Campaign__r.Name, Campaign__r.CRM_Priorita__c, ' + 
        ' Campaign__r.CRM_EndDateFormula__c, Campaign__r.CRM_StartDateFormula__c,Campaign__r.RecordTypeId,Campaign__r.CRM_NomeAttributo1__c, Campaign__r.CRM_NomeAttributo2__c,' + 
        ' CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c, CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c, CRM_ValoreAttributo2_Text__c,' + 
        ' CRM_Account__r.CRM_NDG__c,CRM_Account__r.Name,CRM_Account__r.PTF_NaturaGiuridica__c, CRM_Account__r.PTF_Portafoglio__c,' + 
        ' CRM_Account__r.PTF_Portafoglio__r.Name, CRM_Account__r.PTF_MicroWallet__r.Name, CRM_Account__r.ModelloDiServizio__c,' + 
        ' CRM_Assegnatario__r.Name, CRM_Assegnatario__c, CRM_AssegnatarioUser__c, CRM_AssegnatarioUser__r.IsActive, CRM_AssegnatarioUser__r.Name, CRM_AssegnatarioUser__r.idCed__c,' + 
        ' Campaign__r.Tipologia_Azione__c, CRM_Autore__c,CRM_Account__r.CRM_Filiale__c, CRM_Account__r.PTF_MiniPortafoglio__r.Name, CRM_Account__r.PTF_MiniPortafoglio__c, Campaign__r.CRM_Nome_Attributo_1_formula__c, Campaign__r.CRM_Nome_Attributo_2_formula__c,   ' +
        'Campaign__r.CRM_TipologiaCampagna__c, Campaign__r.Priorita_Campagna__c '+
        ' FROM campaignMember__c' + 
        ' WHERE ' + 
        ' Status__c != \'Eliminato\' AND' + 
        ' PTF_Ambito__c = \'AssegnazioneAzione\' AND' + 
        ' (Campaign__r.RecordTypeId =: recordTypeTriggerBasedMono OR Campaign__r.RecordTypeId =: recordTypeTriggerBaseMulti) AND' + 
        ' Campaign__r.CRM_CampagnaInCorso__c = true AND Campaign__r.CRM_Channel__c = \'Rete\' AND Campaign__r.CRM_SottotipologiaCampagna__c != \'Altra proposta\' AND CRM_Account__r.ModelloDiServizio__c !=null';

        if(userMap.PTF_User__r.Profilo__c.contains('NEC_F') ||
        (userMap.PTF_User__r.Profilo__c == 'CRM - Utente di Rete' && userMap.PTF_ReferenteElegibile__c)){
            query += ' AND CRM_Account__r.CRM_Filiale__c = \'' + userMap.AccountId + '\'';
        }

        query += ' LIMIT 45000 ';
        response = new Map<String,Object>{
            'eventsMemberList' => Database.query(query)
        };


        /*List<campaignMember__c> eventsMemberList = [SELECT Id, PTF_IdCed__c, PTF_ModelloDiServizio__c, PTF_Ambito__c, Status__c, CRM_Esito__c,
        CRM_CampaignMemberId__c, Campaign__c, Campaign__r.CRM_Categoria__c, Campaign__r.Name, Campaign__r.CRM_Priorita__c, 
        Campaign__r.CRM_EndDateFormula__c, Campaign__r.CRM_StartDateFormula__c,Campaign__r.RecordTypeId,Campaign__r.CRM_NomeAttributo1__c, Campaign__r.CRM_NomeAttributo2__c,
        CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c, CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c, CRM_ValoreAttributo2_Text__c,
        CRM_Account__r.CRM_NDG__c, CRM_Account__r.PTF_Filiale__c, CRM_Account__r.Name,CRM_Account__r.PTF_NaturaGiuridica__c, CRM_Account__r.PTF_Portafoglio__c,
        CRM_Account__r.PTF_Portafoglio__r.Name, CRM_Account__r.ModelloDiServizio__c,
        CRM_Assegnatario__r.Name, CRM_Assegnatario__c, CRM_AssegnatarioUser__c, CRM_AssegnatarioUser__r.IsActive, CRM_AssegnatarioUser__r.Name, CRM_AssegnatarioUser__r.idCed__c,
        Campaign__r.Tipologia_Azione__c, CRM_Autore__c 
        FROM campaignMember__c
        WHERE 
        Status__c != 'Eliminato' AND
        PTF_Ambito__c = 'AssegnazioneAzione' AND
        (Campaign__r.RecordTypeId =: recordTypeTriggerBasedMono OR Campaign__r.RecordTypeId =: recordTypeTriggerBaseMulti) AND
        Campaign__r.CRM_CampagnaInCorso__c = true  AND PTF_IdCed__c =: userMap.PTF_Idced__c
        LIMIT 45000];

        response = new Map<String,Object>{
            'eventsMemberList' => eventsMemberList
        };*/
        return response;
    }

    @AuraEnabled
    public static Map<String,Object> getOppsMember(String idCed){
		String recordTypeOptvsRete = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunita_da_cc_vs_rete').getRecordTypeId();
        String recordTypeOptCO = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunit_Comparatori').getRecordTypeId();
        String recordTypeOptNPS = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunit_NPS').getRecordTypeId();
        String recordTypeOptBanner = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunita_Ricontatti_da_DEM_e_Banner').getRecordTypeId();
        
        Map<String,Object> response;
        Map<String, SObject> oppMap = new Map<String, SObject>();

        List<Opportunity> oppsList = [SELECT Id, StageName, OwnerId, Owner.Name, Owner.idCed__c, Name, CRM_Canale__c, DescrizioneMds__c, CRM_Bisogno__c, CRM_DataCreazione__c, CRM_EsitoContatto__c, CRM_Oggetto__c,
        Account.ModelloDiServizio__c, Account.PTF_Portafoglio__c, Account.CRM_NDG__c, Account.PTF_Portafoglio__r.PTF_Filiale__r.PTF_IdCED__c, Owner.CRM_MMDSVisibili__c,
                                      Account.Name, CRM_Autore__c,CRM_Assegnatario__r.Name,CRM_Assegnatario__c,CloseDate FROM Opportunity WHERE StageName != 'Rifiutata' AND OwnerId != null AND DescrizioneMds__c IN ('Family', 'POE', 'Assente', 'Residuale', 'Non Portafogliati','') AND (PTF_IdCed__c =: idCed OR Account.CRM_Filiale__r.PTF_IdCed__c =: idCed) AND /*recordTypeid !=:recordTypeOptSelf AND*/ (CRM_Canale__c='Check-up' OR recordTypeid=:recordTypeOptvsRete OR recordTypeid=: recordTypeOptNPS OR recordTypeid=: recordTypeOptBanner OR recordTypeid=: recordTypeOptCO) AND CRM_Appuntamento_Presso_Filiale_Diversa__c=false AND CloseDate >=TODAY
                                      ORDER BY Name,CloseDate];
        response = new Map<String,Object>{
            'oppsList' => oppsList
        };
        return response;
    }

    @AuraEnabled
    public static Boolean reassignItem(List<String> evList, List<String> cmList, List<String> oppList, String toUser, Integer asyncThreshold){
        System.debug(LoggingLevel.DEBUG,'*** START -- reassignItem Method ***');
        System.debug('DK cmList' + JSON.serialize(cmList));
        System.debug('DK evList' + JSON.serialize(evList));
        System.debug('DK oppList: ' + JSON.serialize(oppList));
        List<CampaignMember> membersToupdate = new List<CampaignMember>();
        List<Opportunity> oppsToupdate = new List<Opportunity>();
        
        Boolean isAsync = false;
        
        if(!oppList.isEmpty()){
            for(String oppId : oppList){
                oppsToupdate.add(new Opportunity(Id = oppId, OwnerId = toUser));
            }
            update oppsToupdate;
        }

        /*if(!cmList.isEmpty()){
            for(String cmId : cmList){
                membersToupdate.add(new CampaignMember(Id = cmId, CRM_Assegnatario__c = toUser));
            }
            esito= true;
        }
        if(!evList.isEmpty()){
            for(String evId : evList){
                membersToupdate.add(new CampaignMember(Id = evId, CRM_Assegnatario__c = toUser));
            }
            esito = true;
        }*/

        /*if(!membersToupdate.isEmpty()){
            update membersToupdate;
        }*/

        List<String> cmEvList = new List<String>();
        cmEvList.addAll(cmList);
        cmEvList.addAll(evList);

        if(cmEvList.size() <= asyncThreshold){ 
            for(String cmId : cmEvList){
                membersToupdate.add(new CampaignMember(Id = cmId, CRM_Assegnatario__c = toUser));
            }
            update membersToupdate;
        }else if(cmEvList.size() > asyncThreshold && cmEvList.size() <= 1000){
            futureMethod(new List<String>{toUser}, cmEvList);
            isAsync = true;
        }else{
            invokeBatch(cmEvList,toUser);
            isAsync = true;
        }
        System.debug(LoggingLevel.DEBUG,'*** END -- reassignItem Method ***');
        return isAsync;
    }

    @AuraEnabled
    public static Boolean setCampaignMember(List<String> userList, List<String> cmList, Integer asyncThreshold){
        System.debug('SV setCampaignMember userList: ' + userList);
        System.debug('SV setCampaignMember cmList: ' + cmList);
        System.debug('SV setCampaignMember asyncThreshold: ' + asyncThreshold);
        List<CampaignMember> cmUpdateList = new List<CampaignMember>();
        Boolean isAsync = false;
            
        OnCampaignMemberTriggerHandler.trafficLightAssegnazioneAzione = true;
        if(cmList.size() <= asyncThreshold){ 
            for (String x : cmList) {
                CampaignMember y = new CampaignMember(Id=x, CRM_Assegnatario__c = userList[0]);
                cmUpdateList.add(y);
            }
            update cmUpdateList;
        }else if(cmList.size() > asyncThreshold && cmList.size() <= 1000){
            futureMethod(userList, cmList);
            isAsync = true;
        }else{
            invokeBatch(cmList,userList[0]);
            isAsync = true;
        }

        return isAsync;

    }

    @future
    public static void futureMethod(List<String> userList, List<String> cmList) {
        List<CampaignMember> cmUpdateList = new List<CampaignMember>();
        
        CustomNotificationType notificationType = 
        [SELECT Id, DeveloperName 
         FROM CustomNotificationType 
         WHERE DeveloperName='AssegnazioneMassiva'];

         // Create a new custom notification
         Messaging.CustomNotification notification = new Messaging.CustomNotification();
    
         // Set the contents for the notification
         notification.setTitle('Assegnazione Massiva');

         // Set the notification type and target
         notification.setNotificationTypeId(notificationType.Id);
         notification.setTargetPageRef('{ type: standard__navItemPage,attributes:{apiName: \'Assegna_Azioni\'} }');

        try {

            for (String x : cmList) {
                CampaignMember y = new CampaignMember(Id=x, CRM_Assegnatario__c = userList[0]);
                cmUpdateList.add(y);
            }
    
            update cmUpdateList;

            notification.setBody('L\'assegnazione massiva delle campagne da te selezionate risulta completata.');
    
        } catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
            notification.setBody('Errore durante la riassegnazione delle campagne.');

        } finally {
            // Actually send the notification
            notification.send(new Set<String>{UserInfo.getUserId()});
        }
    }

    @AuraEnabled
    public static Boolean setOpportunity(List<String> userList, List<String> oppList){
        System.debug('SV setOpportunity userList: ' + userList);
        System.debug('SV setOpportunity oppList: ' + oppList);

        List<Opportunity> oppUpdateList = [ SELECT Id, OwnerId
                                                FROM Opportunity
                                                WHERE Id IN : oppList ];

        for (Opportunity x : oppUpdateList) {
            x.OwnerId = userList[0];
            x.CRM_Assegnatario__c = userList[0];
        }

        update oppUpdateList;

        return true;

    }
    
    public static void invokeBatch(List<String> idced,String userIdToAssign) {
        
       /*List<String> idced = new List<String> {'00v0D000005rou5QAA','00v0D000005rou6QAA','00v0D000005rou7QAA'};
        String userIdToAssign = '0053X00000Ey24hQAB';        
        Batch_AssegnazioneAzioniMassiva bam = new Batch_AssegnazioneAzioniMassiva();
        bam.idCmList = idced;
        bam.userId = '0053X00000Ey24hQAB';       
        Database.executeBatch(bam,200);*/
        
        Batch_AssegnazioneAzioniMassiva bam = new Batch_AssegnazioneAzioniMassiva();
        bam.idCmList = idced;
        bam.userId = userIdToAssign;
        
        Database.executeBatch(bam,200);
    }
    
    


    public class WrapperObj {

        @AuraEnabled public Map<String, SObject> accMap;
        @AuraEnabled public Map<String, SObject> ptfMap;
        @AuraEnabled public Contact userMap;
        @AuraEnabled public Map<String, SObject> contactMap;
        @AuraEnabled public Map<String, SObject> campaignMemberMap;
        @AuraEnabled public List<SObject> campaignMemberList;
        @AuraEnabled public AssegnazioniAzioniCS__c AssegnazioniAzioniConfig;
    }

    public class UserWrapper{
        @AuraEnabled public String idUtente;
        @AuraEnabled public String nomeRisorsa;
        @AuraEnabled public Integer nOpportunita;
        @AuraEnabled public Integer nCampagne;
        @AuraEnabled public Integer nEventi;
    }
}