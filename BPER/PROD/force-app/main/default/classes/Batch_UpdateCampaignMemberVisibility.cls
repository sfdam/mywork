global without sharing class Batch_UpdateCampaignMemberVisibility implements Database.Batchable<sObject>{
    global Map<Id, Account> newMap;
    global Map<Id, Account> oldMap;
    global Set<String> accountIdSet;
    
    
    global Batch_UpdateCampaignMemberVisibility(Map<Id, Account> newMap, Map<Id, Account> oldMap, Set<String> accountIdSet) {
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.accountIdSet = accountIdSet;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){   
        String query ='SELECT Contact.AccountId, CRM_Portafoglio__c, CRM_Assegnatario__c,PTF_idCed__c,PTF_ModelloDiServizio__c,PTF_Area__c,PTF_DirezioneRegionale__c,PTF_Filiale__c FROM CampaignMember WHERE Contact.AccountId IN: accountIdSet AND isActive__c = true';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext info,List<CampaignMember> scope){
        for(CampaignMember campaignMember : scope){
            campaignMember.CRM_Portafoglio__c = newMap.get(campaignMember.Contact.AccountId).PTF_Portafoglio__c;
            campaignMember.PTF_ModelloDiServizio__c = (newMap.get(campaignMember.Contact.AccountId).PTF_Portafoglio__c != NULL) ? newMap.get(campaignMember.Contact.AccountId).ModelloDiServizio__c : 'Non Portafogliati';
            campaignMember.CRM_Assegnatario__c = null;
            campaignMember.PTF_idCed__c = newMap.get(campaignMember.Contact.AccountId).PTF_Filiale__c!= NULL ? newMap.get(campaignMember.Contact.AccountId).PTF_Filiale__r.PTF_IdCed__c : newMap.get(campaignMember.Contact.AccountId).CRM_Filiale__r.PTF_IdCed__c;
            campaignMember.PTF_Area__c = newMap.get(campaignMember.Contact.AccountId).PTF_Filiale__c!= NULL ? newMap.get(campaignMember.Contact.AccountId).PTF_Filiale__r.PTF_Area__c : newMap.get(campaignMember.Contact.AccountId).CRM_Filiale__r.PTF_Area__c;
            campaignMember.PTF_DirezioneRegionale__c = newMap.get(campaignMember.Contact.AccountId).PTF_Filiale__c!= NULL ? newMap.get(campaignMember.Contact.AccountId).PTF_Filiale__r.PTF_DirezioneRegionale__c : newMap.get(campaignMember.Contact.AccountId).CRM_Filiale__r.PTF_DirezioneRegionale__c;
            campaignMember.PTF_Filiale__c = newMap.get(campaignMember.Contact.AccountId).PTF_Filiale__c!= NULL ? newMap.get(campaignMember.Contact.AccountId).PTF_Filiale__c : newMap.get(campaignMember.Contact.AccountId).CRM_Filiale__c;
            
        }

        update scope;
    }

    global void finish (Database.BatchableContext BC){}
}