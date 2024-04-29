trigger OnOpportunityTeamTrigger on OpportunityTeamMember (after insert, before delete) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
    
    if (trigger.isafter && trigger.isinsert){
        system.debug('After Insert');
        OnOpportunityTeamTriggerHandler.QuoteSharing(trigger.new);
    }
    
    if (trigger.isbefore && trigger.isdelete){
        system.debug('Before Delete');
        	OnOpportunityTeamTriggerHandler.QuoteSharingDelete(trigger.old);
    }
    
}