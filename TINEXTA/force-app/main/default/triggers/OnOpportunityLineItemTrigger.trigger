trigger OnOpportunityLineItemTrigger on OpportunityLineItem (before insert,before update, after update) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;

    if(trigger.isUpdate){
        if(trigger.isAfter){
            System.debug('SV OpportunityLineItem UPDATE trigger.isUpdate');
            OnOpportunityLineItemTriggerHandler.makeOpportunityLineItem(Trigger.NewMap, Trigger.OldMap);
        } 
        if(trigger.isBefore){
            //OnOpportunityLineItemTriggerHandler.AggiornoQuote(trigger.new);
        }
    }
    
    if(trigger.isInsert){
       if(trigger.isBefore){
            System.debug('EU OpportunityLineItem Before Insert');
           // OnOpportunityLineItemTriggerHandler.verifynumberOLI(trigger.new);
           OnOpportunityLineItemTriggerHandler.AggiornoEsercizio(trigger.new);
           //OnOpportunityLineItemTriggerHandler.AggiornoQuote(trigger.new);
        }        
    }
    
}