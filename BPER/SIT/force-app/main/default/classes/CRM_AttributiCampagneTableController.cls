public with sharing class CRM_AttributiCampagneTableController {

    public static Contact userMap {
        get{
            if(userMap != null){
                return userMap;
            }
            List<Contact> coList = [SELECT id, PTF_ReferenteElegibile__c, PTF_RegistrationNumber__c, Name, PTF_IdCED__c, AccountId, PTF_User__c, PTF_ProfiloLDAP__c, PTF_IsVice__c, PTF_Ruolo__c, PTF_TipologiaRuolo__r.Name,PTF_User__r.CRM_HasLab__c FROM Contact WHERE PTF_User__c =: UserInfo.getUserId()];
            if(!coList.isEmpty()){
                userMap = coList[0];
            }else{
                User u = [SELECT id, Profilo__c FROM User WHERE Id =: UserInfo.getUserId()];
                userMap = new Contact();
                userMap.PTF_User__c = u.Id;
                userMap.PTF_ProfiloLDAP__c = u.Profilo__c;
                userMap.AccountId = null;
            }
            return userMap;
        }set;
    }
    
    @AuraEnabled

    public static WrapperObj getCampaignMember(String recordId){

        WrapperObj response = new WrapperObj();
        Map<String, SObject> campaignMemberMap = new Map<String, SObject>();
        
        List<campaignMember__c> campaignMemberList = new List<campaignMember__c>();
        
        if (recordId !=null){
            /*campaignMemberList = [SELECT Id,Campaign__r.CRM_Ordinamento_Attributo__c, Campaign__r.Ordinamento__c, CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c,CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c,CRM_ValoreAttributo2_Text__c, Campaign__c, Campaign__r.Name, Campaign__r.CRM_NomeAttributo1__c, Campaign__r.CRM_NomeAttributo2__c, CRM_Account__c, CRM_Account__r.CRM_NDG__c, CRM_Account__r.Name, CRM_Account__r.PTF_Filiale__r.Name,PTF_ModelloDiServizio__c, CRM_PrioritaContatto__c,CRM_Esito__c,PTF_Portafoglio__c, PTF_Portafoglio__r.Name,CRM_AssegnatarioFormula__c, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName, CRM_Data_Inserimento__c,CRM_CheckNewInsert__c, Campaign__r.CRM_Nome_Attributo_1_formula__c, Campaign__r.CRM_Nome_Attributo_2_formula__c, createdDate 
            FROM campaignMember__c
            WHERE 
            Status__c != 'Eliminato' AND
            Campaign__c =:recordId AND
            CRM_Account__c != ''
            LIMIT 45000];*/

            String query = ' SELECT Id,Campaign__r.CRM_Ordinamento_Attributo__c, CRM_AssegnatarioUser__r.Name, Campaign__r.Ordinamento__c, CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c,CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c,CRM_ValoreAttributo2_Text__c, Campaign__c, Campaign__r.Name, Campaign__r.CRM_NomeAttributo1__c, Campaign__r.CRM_NomeAttributo2__c, CRM_Account__c, CRM_Account__r.CRM_NDG__c, CRM_Account__r.Name, CRM_Account__r.PTF_Filiale__r.Name,PTF_ModelloDiServizio__c, CRM_PrioritaContatto__c,CRM_Esito__c,PTF_Portafoglio__c, PTF_Portafoglio__r.Name,CRM_AssegnatarioFormula__c, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName, CRM_Data_Inserimento__c,CRM_CheckNewInsert__c, Campaign__r.CRM_Nome_Attributo_1_formula__c, Campaign__r.CRM_Nome_Attributo_2_formula__c, createdDate,CRM_Account__r.CRM_Filiale__c ' +
            ' FROM campaignMember__c' +
            ' WHERE ' +
            ' Status__c != \'Eliminato\' AND' +
            ' Campaign__c =:recordId AND' +
            ' CRM_Account__c != null AND' + 
            ' CRM_Account__r.ModelloDiServizio__c !=null';

            if(userMap.PTF_ProfiloLDAP__c.contains('NEC_F') ||
            (userMap.PTF_ProfiloLDAP__c == 'NEC_CR' && userMap.PTF_ReferenteElegibile__c)){
                String userMapAccountId = userMap.AccountId;
                query += ' AND CRM_Account__r.CRM_Filiale__c =: userMapAccountId ';
            }
            
            query += ' LIMIT 45000 ';
            campaignMemberList = Database.query(query);
            
            campaignMemberMap = SV_Utilities.keyBy(campaignMemberList, '{Campaign__c}_{CRM_CampaignMemberId__c}_{PTF_ModelloDiServizio__c}', true);
   
        }else{
            /*campaignMemberList = [SELECT Id, CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c,CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c,CRM_ValoreAttributo2_Text__c, Campaign__c, Campaign__r.Name, Campaign__r.CRM_NomeAttributo1__c, Campaign__r.CRM_NomeAttributo2__c, CRM_Account__c, CRM_Account__r.CRM_NDG__c, CRM_Account__r.Name, CRM_Account__r.PTF_Filiale__r.Name,PTF_ModelloDiServizio__c, CRM_PrioritaContatto__c,CRM_Esito__c,PTF_Portafoglio__c, PTF_Portafoglio__r.Name,CRM_AssegnatarioFormula__c, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName, CRM_Data_Inserimento__c, Campaign__r.CRM_Nome_Attributo_1_formula__c, Campaign__r.CRM_Nome_Attributo_2_formula__c, createdDate
            FROM campaignMember__c
            WHERE 
            Status__c != 'Eliminato' AND
            CRM_Account__c != ''
            LIMIT 45000];*/

            String query = ' SELECT Id, CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c,CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c,CRM_ValoreAttributo2_Text__c, CRM_AssegnatarioUser__r.Name, Campaign__c, Campaign__r.Name, Campaign__r.CRM_NomeAttributo1__c, Campaign__r.CRM_NomeAttributo2__c, CRM_Account__c, CRM_Account__r.CRM_NDG__c, CRM_Account__r.Name, CRM_Account__r.PTF_Filiale__r.Name,PTF_ModelloDiServizio__c, CRM_PrioritaContatto__c,CRM_Esito__c,PTF_Portafoglio__c, PTF_Portafoglio__r.Name,CRM_AssegnatarioFormula__c, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName, CRM_Data_Inserimento__c, Campaign__r.CRM_Nome_Attributo_1_formula__c, Campaign__r.CRM_Nome_Attributo_2_formula__c, createdDate,CRM_Account__r.CRM_Filiale__c' +
            ' FROM campaignMember__c' +
            ' WHERE ' +
            ' Status__c != \'Eliminato\' AND' +
            ' CRM_Account__c != \'\'AND' + 
            ' CRM_Account__r.ModelloDiServizio__c !=null';

            if(userMap.PTF_ProfiloLDAP__c.contains('NEC_F') ||
            (userMap.PTF_ProfiloLDAP__c == 'CRM - Utente di Rete' && userMap.PTF_ReferenteElegibile__c)){
                String userMapAccountId = userMap.AccountId;
                query += ' AND CRM_Account__r.CRM_Filiale__c =: userMapAccountId ';
            }
            
            query += ' LIMIT 45000 ';
            campaignMemberList = Database.query(query);

            campaignMemberMap = SV_Utilities.keyBy(campaignMemberList, '{Campaign__c}_{CRM_CampaignMemberId__c}_{PTF_ModelloDiServizio__c}', true);

        }
        
        response.campaignMemberList = campaignMemberList;
        response.campaignMemberMap = campaignMemberMap;

        return response;
    }
    
    public class WrapperObj {

        @AuraEnabled public Map<String, SObject> accMap;
        @AuraEnabled public Map<String, SObject> ptfMap;
        @AuraEnabled public Contact userMap;
        @AuraEnabled public Map<String, SObject> contactMap;
        @AuraEnabled public Map<String, SObject> campaignMemberMap;
        @AuraEnabled public List<SObject> campaignMemberList;
    }

}