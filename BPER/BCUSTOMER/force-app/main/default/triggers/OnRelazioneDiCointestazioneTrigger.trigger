trigger OnRelazioneDiCointestazioneTrigger on CRM_AccountAccountJointOwnershipRelation__c (after insert) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_RelazioneDiCointestazioneTrigger__c) return;

    if(trigger.isInsert && trigger.isAfter){
        OnRelazioneDiCointestazioneHandler.UpdateNucleoCointestazione((List<CRM_AccountAccountJointOwnershipRelation__c>) Trigger.new);
    }
}