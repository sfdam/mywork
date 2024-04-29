trigger OnOpportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete) {
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
    if (Trigger.isInsert){
        if(Trigger.isBefore){
            User currentUser = [SELECT Id, Name, Societa__c, UserRole.Name, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
            OnOpportunityTriggerHandler.ereditaCampiFromObject(Trigger.new, currentUser); // WRT EREDITA CAMPO PAGAMENTO
            OnOpportunityTriggerHandler.AggiornaOppInfocert(Trigger.new);
            OnOpportunityTriggerHandler.changeOwner(Trigger.new, currentUser);
            OnOpportunityTriggerHandler.setFilds(Trigger.new); // WRT settaggio dei campi a partire da altri.	
            //OnOpportunityTriggerHandler.ApprovazioneSixtema(trigger.new);
        }

        if(Trigger.isAfter){
            User currentUser = [SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];

            OnOpportunityTriggerHandler.countOpportunityOnAccount(Trigger.new);
            OnOpportunityTriggerHandler.alignOutcome(Trigger.newMap, currentUser);
            // INTEGRAZIONE (SHAREPOINT, INFOSTORE)
            OnOpportunityTriggerHandler.makeCallOpportunity(Trigger.oldMap, Trigger.newMap, currentUser);

        }
    }

    if (Trigger.isUpdate){
        if(Trigger.isBefore){
            OnOpportunityTriggerHandler.setFilds(Trigger.new); // WRT settaggio dei campi a partire da altri.	
            OnOpportunityTriggerHandler.checkWOChiusaPersa(trigger.newMap, Trigger.oldMap); //AMS 001083	
        }

        if(Trigger.isAfter){
            User currentUser = [SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];
            OnOpportunityTriggerHandler.countOpportunityOnAccountUPDATE(Trigger.newMap, Trigger.oldMap);
            OnOpportunityTriggerHandler.alignOutcome(Trigger.newMap, currentUser);
            // INTEGRAZIONE (SHAREPOINT, INFOSTORE)
            OnOpportunityTriggerHandler.makeCallOpportunity(Trigger.oldMap, Trigger.newMap, currentUser);
            OnOpportunityTriggerHandler.AggiornoEsercizio(Trigger.newMap, Trigger.oldMap);
            OnOpportunityTriggerHandler.ChangeAccount(Trigger.newMap, Trigger.oldMap);
            OnOpportunityTriggerHandler.sharepointCMK(Trigger.new, Trigger.oldMap);

        }
    }

    if (Trigger.isDelete){
        if(trigger.isBefore){
            OnOpportunityTriggerHandler.blockDelete(Trigger.oldMap);
        }
        if(trigger.isAfter){
            OnOpportunityTriggerHandler.countOpportunityOnAccount(Trigger.old);
        }
    }
}