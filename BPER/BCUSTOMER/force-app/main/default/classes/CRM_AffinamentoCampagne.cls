public with sharing class CRM_AffinamentoCampagne {
    public static Contact userMap {
        get{
            if(userMap != null){
                return userMap;
            }
            userMap = [SELECT id, PTF_ReferenteElegibile__c, PTF_RegistrationNumber__c, Name, PTF_IdCED__c, AccountId, PTF_User__c, PTF_ProfiloLDAP__c, PTF_IsVice__c, PTF_Ruolo__c, PTF_TipologiaRuolo__r.Name,PTF_User__r.CRM_HasLab__c, PTF_User__r.Profilo__c,PTF_User__r.PTF_RuoloLDAP__c FROM Contact WHERE PTF_User__c =: UserInfo.getUserId()];
            return userMap;
        }set;
    }
    
    @AuraEnabled
    public static WrapperObj getCampaignMember(String recordId){

        WrapperObj response = new WrapperObj();
        Map<String, SObject> campaignMemberMap = new Map<String, SObject>();
        
        List<campaignMember__c> campaignMemberList = new List<campaignMember__c>();
        List<campaignMember__c> campaignMemberAffinati = new List<campaignMember__c>();
        
        if (recordId !=null){
            String query = 'SELECT Id, CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c, CRM_ValoreAttributo1_Text__c, ' + 
            ' CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c, CRM_ValoreAttributo2_Text__c, Campaign__r.Name, Campaign__r.CRM_NomeAttributo1__c, ' + 
            ' Campaign__r.CRM_NomeAttributo2__c, CRM_Account__r.CRM_NDG__c, CRM_Account__r.Name, CRM_Account__r.PTF_Filiale__r.Name,PTF_ModelloDiServizio__c, ' + 
            ' CRM_PrioritaContatto__c,CRM_Esito__c,PTF_Portafoglio__r.Name, CRM_Account__r.PTF_NaturaGiuridica__c,CRM_AssegnatarioUser__c,CRM_AssegnatarioUser__r.Name, ' + 
            ' CRM_CampaignMemberId__c, Campaign__r.CRM_NumClientiEliminati__c, Campaign__r.CRM_NumClientiInCampagna__c, Campaign__r.CRM_AffinamentoPerc__c, ' + 
            ' PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName,Campaign__r.CRM_Nome_Attributo_1_formula__c, Campaign__r.CRM_Nome_Attributo_2_formula__c ' + 
            ' FROM campaignMember__c ' + 
            ' WHERE ' + 
            ' Status__c != \'Eliminato\' AND ' + 
            ' Campaign__c = \'' + recordId + '\' ';

            if(userMap.PTF_User__r.Profilo__c.contains('NEC_F') ||
            (userMap.PTF_User__r.Profilo__c == 'CRM - Utente di Rete' && userMap.PTF_ReferenteElegibile__c)){
                query += ' AND CRM_Account__r.CRM_Filiale__c = \'' + userMap.AccountId + '\'';
            }
            if(userMap.PTF_IdCED__c =='6116' || userMap.PTF_IdCED__c =='21025'){
                 query += ' AND CRM_Account__r.ModelloDiServizio__c =\'Key Client Privati\' ';
            }
            if(userMap.PTF_User__r.PTF_RuoloLDAP__c =='069'){
                String userMapUserId = userMap.PTF_User__c;
                 query += ' AND  PTF_Portafoglio__r.Referente_User__c=:userMapUserId';
            }
            
            query += ' LIMIT 45000 ';
            campaignMemberList = Database.query(query);
            campaignMemberMap = SV_Utilities.keyBy(campaignMemberList, '{Campaign__c}_{CRM_CampaignMemberId__c}_{PTF_ModelloDiServizio__c}', true);

            String queryAff = ' SELECT Id' +
            ' FROM campaignMember__c' +
            ' WHERE ' +
            ' Status__c = \'Eliminato\' AND' +
            ' Campaign__c = \'' + recordId + '\' ';

            if(userMap.PTF_User__r.Profilo__c.contains('NEC_F')){
                queryAff += ' AND CRM_Account__r.CRM_Filiale__c = \'' + userMap.AccountId + '\'';
            }

            queryAff += ' LIMIT 45000 ';
            campaignMemberAffinati = Database.query(queryAff);
            
            /*campaignMemberList = [SELECT Id, CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c, CRM_ValoreAttributo1_Text__c, 
            CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c, CRM_ValoreAttributo2_Text__c, Campaign__r.Name, Campaign__r.CRM_NomeAttributo1__c, 
            Campaign__r.CRM_NomeAttributo2__c, CRM_Account__r.CRM_NDG__c, CRM_Account__r.Name, CRM_Account__r.PTF_Filiale__r.Name,PTF_ModelloDiServizio__c, 
            CRM_PrioritaContatto__c,CRM_Esito__c,PTF_Portafoglio__r.Name, CRM_Account__r.PTF_NaturaGiuridica__c,CRM_AssegnatarioUser__c,CRM_AssegnatarioUser__r.Name, 
            CRM_CampaignMemberId__c, Campaign__r.CRM_NumClientiEliminati__c, Campaign__r.CRM_NumClientiInCampagna__c, Campaign__r.CRM_AffinamentoPerc__c,
            PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName,Campaign__r.CRM_Nome_Attributo_1_formula__c, Campaign__r.CRM_Nome_Attributo_2_formula__c
            FROM campaignMember__c
            WHERE 
            Status__c != 'Eliminato' AND
            Campaign__c =:recordId
            LIMIT 45000];
            campaignMemberAffinati = [SELECT Id
            FROM campaignMember__c
            WHERE 
            Status__c = 'Eliminato' AND
            Campaign__c =:recordId
            LIMIT 45000];*/
        }
        
        response.campaignMemberList = campaignMemberList;
        response.campaignMemberMap = campaignMemberMap;

        if(!campaignMemberAffinati.isEmpty()){
            response.clientiAffinati = campaignMemberAffinati.size();
        }
        else{
                response.clientiAffinati = 0;   
        }

        System.debug('num of element: '+response.clientiAffinati + ' '+campaignMemberAffinati.size());

        return response;
    }

    @AuraEnabled
    public static WrapperObj getCampaignMemberAff(String recordId){

        WrapperObj response = new WrapperObj();
        Map<String, SObject> campaignMemberMap = new Map<String, SObject>();
        
        List<campaignMember__c> campaignMemberList = new List<campaignMember__c>();
        List<campaignMember__c> campaignMemberAffinati = new List<campaignMember__c>();
        
        if (recordId !=null){
            /*campaignMemberAffinati = [SELECT Id, CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c, CRM_ValoreAttributo1_Text__c, 
            CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c, CRM_ValoreAttributo2_Text__c, Campaign__r.Name, Campaign__r.CRM_NomeAttributo1__c, 
            Campaign__r.CRM_NomeAttributo2__c, CRM_Account__r.CRM_NDG__c, CRM_Account__r.Name, CRM_Account__r.PTF_Filiale__r.Name,PTF_ModelloDiServizio__c, 
            CRM_PrioritaContatto__c,CRM_Esito__c,PTF_Portafoglio__r.Name, CRM_Account__r.PTF_NaturaGiuridica__c,CRM_AssegnatarioUser__c,CRM_AssegnatarioUser__r.Name, 
            CRM_CampaignMemberId__c, Campaign__r.CRM_NumClientiEliminati__c, Campaign__r.CRM_NumClientiInCampagna__c, Campaign__r.CRM_AffinamentoPerc__c,
            CRM_NominativoUtente__c, CRM_DataEsclusione__c,CRM_NoteAffinamento__c, Motivo_Affinamento__c, Campaign__r.CRM_Nome_Attributo_1_formula__c, 
            Campaign__r.CRM_Nome_Attributo_2_formula__c, Campaign__r.CRM_AffinamentoInCorso__c,PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName, 
            PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName
            FROM campaignMember__c
            WHERE 
            Status__c = 'Eliminato' AND
            Campaign__c =:recordId
            LIMIT 45000];*/

            String query = ' SELECT Id, CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c, CRM_ValoreAttributo1_Text__c, ' +
            ' CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c, CRM_ValoreAttributo2_Text__c, Campaign__r.Name, Campaign__r.CRM_NomeAttributo1__c, ' +
            ' Campaign__r.CRM_NomeAttributo2__c, CRM_Account__r.CRM_NDG__c, CRM_Account__r.Name, CRM_Account__r.PTF_Filiale__r.Name,PTF_ModelloDiServizio__c, ' +
            ' CRM_PrioritaContatto__c,CRM_Esito__c,PTF_Portafoglio__r.Name, CRM_Account__r.PTF_NaturaGiuridica__c,CRM_AssegnatarioUser__c,CRM_AssegnatarioUser__r.Name, ' +
            ' CRM_CampaignMemberId__c, Campaign__r.CRM_NumClientiEliminati__c, Campaign__r.CRM_NumClientiInCampagna__c, Campaign__r.CRM_AffinamentoPerc__c,' +
            ' CRM_NominativoUtente__c, CRM_DataEsclusione__c,CRM_NoteAffinamento__c, Motivo_Affinamento__c, Campaign__r.CRM_Nome_Attributo_1_formula__c, ' +
            ' Campaign__r.CRM_Nome_Attributo_2_formula__c, Campaign__r.CRM_AffinamentoInCorso__c,PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName, ' +
            ' PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName' +
            ' FROM campaignMember__c' +
            ' WHERE ' +
            ' Status__c = \'Eliminato\' AND' +
            ' Campaign__c = \'' + recordId + '\' ';

            if(userMap.PTF_User__r.Profilo__c.contains('NEC_F') ||
            (userMap.PTF_User__r.Profilo__c == 'CRM - Utente di Rete' && userMap.PTF_ReferenteElegibile__c)){
                query += ' AND CRM_Account__r.CRM_Filiale__c = \'' + userMap.AccountId + '\'';
            }
            
            query += ' LIMIT 45000 ';

            campaignMemberAffinati = Database.query(query);
            campaignMemberMap = SV_Utilities.keyBy(campaignMemberAffinati, '{Campaign__c}_{CRM_CampaignMemberId__c}_{PTF_ModelloDiServizio__c}', true);
            
        }
        
        response.campaignMemberList = campaignMemberAffinati;
        response.campaignMemberMap = campaignMemberMap;

        return response;
    }

    @AuraEnabled
    public static Boolean setCampaignMember(List<String> cmList, String motivazione, String note){

        System.debug('SV setCampaignMember cmList: ' + cmList);

        List<CampaignMember> cmUpdateList = [ SELECT Id, Autore_Affinamento__c, Data_Affinamento__c, CRM_NoteAffinamento__c,
                                             Contact.Account.PTF_ABICED__c, CRM_AccNDG__c, Campaign.Codice_Campagna__c,
                                                              Campaign.Codice_Azione_Utente__c, Campaign.CRM_EndDateFormula__c, Motivo_Affinamento__c, 
                                                              Name, Status, CRM_Esito__c, description, CRM_Assegnatario__r.FederationIdentifier, Campaign.RecordTypeId, 
                                                              CRM_Assegnatario__r.LastName, CRM_Assegnatario__r.FirstName, CRM_AccMDS__c, CRM_AccPTF__c,Campaign.Status,
                                                              Campaign.Name, Campaign.CRM_TipologiaCampagna__c,Campaign.CRM_SottotipologiaCampagna__c, Campaign.CRM_Channel__c, 
                                                              Campaign.CRM_Progressivo__c,Campaign.Data_FineFormula__c, Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.Name, 
                                             Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c,Campaign.CRM_OwnerSystem__c, 
                                             Campaign.CRM_TipologiaCampagnaStep__c,Campaign.CRM_StatoFormula__c,Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName,
                                                               Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName,CRM_Note__c
                                                FROM CampaignMember
                                                WHERE Id IN : cmList ];

        for (CampaignMember x : cmUpdateList) {
            x.Status = 'Eliminato';
            x.CRM_NominativoUtente__c = UserInfo.getName();
            x.CRM_DataEsclusione__c = System.now();
            x.CRM_NoteAffinamento__c = note;
            x.CRM_Note__c = note;
            x.Motivo_Affinamento__c = motivazione;
        }
        String certificationName = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?  'salesforcetestclient2024' : 'salesforceprodclient2024';
        Boolean esito =  AggiornamentoEsitazioneInvocaWS.makeResponse('salvaEsitazioneAzioniNec',cmUpdateList, 'Eliminato', note, certificationName,true, null, true, false);
        System.debug('SV setCampaignMember cmList: ' + cmUpdateList);
        if(esito){
            update cmUpdateList;
        }

        return esito;

    }

    @AuraEnabled
    public static User getUserInfo(){
        return [SELECT id, Profile.Name FROM User WHERE id =:UserInfo.getUserId()];
    }
    
    public class WrapperObj {

        @AuraEnabled public Map<String, SObject> accMap;
        @AuraEnabled public Map<String, SObject> ptfMap;
        @AuraEnabled public Contact userMap;
        @AuraEnabled public Map<String, SObject> contactMap;
        @AuraEnabled public Map<String, SObject> campaignMemberMap;
        @AuraEnabled public List<SObject> campaignMemberList;
        @AuraEnabled public Integer clientiAffinati;
        
    }
}