trigger OnAccountTeamMemberTrigger on AccountTeamMember (after delete) {
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;

    if (Trigger.isDelete){
        System.debug('OnAccountTeamMemberTrigger IS DELETE');
        if(Trigger.isAfter){
            OnAccountTeamMemberTriggerHandler.DeleteCoverageTeamMember(Trigger.old);
        }
    }
}