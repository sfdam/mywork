/*  AL 2023-04-12 -- Aggiunta fields CRM_Author__c, Data_Uscita__c, Campaign__r.Tipologia_Azione__c
                        , Campaign__r.RecordType.DeveloperName
*/
public with sharing class CRM_AttributiCampagneTableController {

    public static Contact userMap {
        get{
            if(userMap != null){
                return userMap;
            }
            System.debug('UserInfo.getUserId: '+UserInfo.getUserId());
            List<Contact> coList = [SELECT id, PTF_ReferenteElegibile__c, PTF_RegistrationNumber__c, Name, PTF_IdCED__c, AccountId, PTF_User__c, PTF_ProfiloLDAP__c, PTF_IsVice__c, PTF_Ruolo__c, PTF_TipologiaRuolo__r.Name,PTF_User__r.CRM_HasLab__c,PTF_User__r.PTF_RuoloLDAP__c FROM Contact WHERE PTF_User__c =: UserInfo.getUserId()];
            if(!coList.isEmpty()){
                userMap = coList[0];
            }else{
                User u = [SELECT id, Profilo__c,idced__c FROM User WHERE Id =: UserInfo.getUserId()];
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
            String query = 'SELECT Id, Campaign__r.CRM_Ordinamento_Attributo__c, CRM_AssegnatarioUser__r.Name, Campaign__r.Ordinamento__c, CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c,CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c,CRM_ValoreAttributo2_Text__c, Campaign__c, Campaign__r.Name, Campaign__r.CRM_NomeAttributo1__c, Campaign__r.CRM_NomeAttributo2__c, CRM_Account__c, CRM_Account__r.CRM_NDG__c, CRM_Account__r.Name, CRM_Account__r.PTF_Filiale__r.Name,PTF_ModelloDiServizio__c, CRM_PrioritaContatto__c,CRM_Esito__c,PTF_Portafoglio__c, PTF_Portafoglio__r.Name,CRM_AssegnatarioFormula__c, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName, CRM_Data_Inserimento__c,CRM_CheckNewInsert__c, Campaign__r.CRM_Nome_Attributo_1_formula__c, Campaign__r.CRM_Nome_Attributo_2_formula__c, createdDate,CRM_Account__r.CRM_Filiale__c,PTF_Portafoglio__r.Referente_User__c,checkNewExit__c,CRM_CampaignMemberId__c, CRM_Account__r.CRM_Filiale__r.Name ' +
            ', CRM_Autore__c, Data_Uscita__c, Campaign__r.Tipologia_Azione__c, Campaign__r.RecordType.DeveloperName, CRM_AssegnatarioUser__c, Priorita_Campaign_Member__c ,ID_P3__c, Data_ingresso__c' + // AL 2023-04-12 -- Aggiunta fields MS - Aggiunta Data_ingresso__c
            ' FROM campaignMember__c' +
            ' WHERE ' +
            ' Status__c != \'Eliminato\' AND' +
            ' Campaign__c =:recordId AND' +
            ' CRM_Account__c != null AND' + 
            ' CRM_Account__r.ModelloDiServizio__c !=null';

            System.debug('userMap'+ userMap);
            if(userMap!=null){
                if((userMap.PTF_ProfiloLDAP__c == 'NEC_CR' && userMap.PTF_ReferenteElegibile__c) ||
                userMap.PTF_ProfiloLDAP__c.contains('NEC_F') ){
                    String userMapAccountId = userMap.AccountId;
                    query += ' AND CRM_Account__r.CRM_Filiale__c =: userMapAccountId ';
                }
                
                if(userMap.PTF_IdCED__c =='6116' || userMap.PTF_IdCED__c =='21025'){
                    query += ' AND CRM_Account__r.ModelloDiServizio__c =\'Key Client Privati\' ';
                }
                if(userMap.PTF_User__r.PTF_RuoloLDAP__c =='069'){
                    String userMapUserId = userMap.PTF_User__c;
                    query += ' AND  PTF_Portafoglio__r.Referente_User__c=:userMapUserId';
                }
                query += ' order by CRM_AssegnatarioFormulaId__C desc, Priorita_Campaign_Member__c asc ,ID_P3__c asc, createdDate desc, Data_Uscita__c desc  ';
                query += ' LIMIT 45000 ';
                campaignMemberList = Database.query(query);
                if (campaignMemberList.size() > 0){
                    campaignMemberMap = SV_Utilities.keyBy(campaignMemberList, '{Campaign__c}_{CRM_CampaignMemberId__c}_{PTF_ModelloDiServizio__c}', true);
                
                }
            }
        }else{
            
            String query = ' SELECT Id, CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c,CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c,CRM_ValoreAttributo2_Text__c, CRM_AssegnatarioUser__r.Name, Campaign__c, Campaign__r.Name, Campaign__r.CRM_NomeAttributo1__c, Campaign__r.CRM_NomeAttributo2__c, CRM_Account__c, CRM_Account__r.CRM_NDG__c, CRM_Account__r.Name, CRM_Account__r.PTF_Filiale__r.Name,PTF_ModelloDiServizio__c, CRM_PrioritaContatto__c,CRM_Esito__c,PTF_Portafoglio__c, PTF_Portafoglio__r.Name,CRM_AssegnatarioFormula__c, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName, CRM_Data_Inserimento__c, Campaign__r.CRM_Nome_Attributo_1_formula__c, Campaign__r.CRM_Nome_Attributo_2_formula__c, createdDate,CRM_Account__r.CRM_Filiale__c' +
            ', CRM_Autore__c, Data_Uscita__c, Campaign__r.Tipologia_Azione__c, Campaign__r.RecordType.DeveloperName, CRM_AssegnatarioUser__c, Priorita_Campaign_Member__c, ID_P3__c, createdDate, Data_ingresso__c' + // AL 2023-04-12 -- Aggiunta fields MS - Aggiunta Data_ingresso__c
            ' FROM campaignMember__c' +
            ' WHERE ' +
            ' Status__c != \'Eliminato\' AND' +
            ' CRM_Account__c != \'\'AND' + 
            ' CRM_Account__r.ModelloDiServizio__c !=null';

            if((userMap.PTF_ProfiloLDAP__c == 'CRM - Utente di Rete' && userMap.PTF_ReferenteElegibile__c)
              || (userMap.PTF_ProfiloLDAP__c == 'NEC_CR' && userMap.PTF_ReferenteElegibile__c)){
                String userMapAccountId = userMap.AccountId;
                query += ' AND CRM_Account__r.CRM_Filiale__c =: userMapAccountId ';
            }
            
            query += 'order by  CRM_AssegnatarioUser__c, Priorita_Campaign_Member__c ,ID_P3__c, createdDate, Data_Uscita__c  ';
            query += ' LIMIT 45000 ';
            campaignMemberList = Database.query(query);
            if (campaignMemberList.size() > 0){
                campaignMemberMap = SV_Utilities.keyBy(campaignMemberList, '{Campaign__c}_{CRM_CampaignMemberId__c}_{PTF_ModelloDiServizio__c}', true);
            }   
        }
        
        if (campaignMemberList.size()>0){
        response.campaignMemberList = campaignMemberList;
        response.campaignMemberMap = campaignMemberMap;
        
        }else{

            response.errorMessage = 'No campaign members found';
        }

        return response;
    }
    
    public class WrapperObj {
        @AuraEnabled public Map<String, SObject> accMap;
        @AuraEnabled public Map<String, SObject> ptfMap;
        @AuraEnabled public Contact userMap;
        @AuraEnabled public Map<String, SObject> contactMap;
        @AuraEnabled public Map<String, SObject> campaignMemberMap;
        @AuraEnabled public List<SObject> campaignMemberList;
        @AuraEnabled public String errorMessage;
    }
}