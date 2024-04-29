trigger OnLeadTrigger on Lead (after insert, before update, after update) {
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
   
    if(trigger.isInsert){
        if(trigger.isBefore){
            System.debug('SV LEAD UPDATE trigger.isBefore');
            OnLeadTriggerHandler.updateFormaGiuridicaWRT(Trigger.new);
        }
        
        if(trigger.isAfter){
            System.debug('SV LEAD INSERT trigger.isAfter');
            User currentUser = [SELECT Id, Name, Societa__c,Escludi_da_Convalida__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
            OnLeadTriggerHandler.approveRecord(Trigger.new, currentUser);
            OnLeadTriggerHandler.copyConvertedLead(Trigger.newMap, currentUser);
        }        
    }
    
    if(trigger.isUpdate){
        if(trigger.isBefore){
            System.debug('SV LEAD UPDATE trigger.isUpdate');
            OnLeadTriggerHandler.WRT_StatoSegnalazione(Trigger.newMap);
            OnLeadTriggerHandler.updateFormaGiuridicaWRT(Trigger.new);
        }
        
        if(trigger.isAfter){
            System.debug('SV LEAD UPDATE trigger.isAfter');
            User currentUser = [SELECT Id, Name, Societa__c,Escludi_da_Convalida__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
            OnLeadTriggerHandler.approveRecord(Trigger.new, currentUser);
            OnLeadTriggerHandler.updateAccountSegn(Trigger.oldMap,Trigger.newMap, currentUser);
            OnLeadTriggerHandler.updateAccountReferenza(Trigger.oldMap,Trigger.newMap, currentUser);
            //OnLeadTriggerHandler_wSharing.relateActivityToConvertedAccount(Trigger.newMap, Trigger.oldMap);
            
        }
    }
}